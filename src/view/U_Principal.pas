unit U_Principal;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.Grids, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ToolWin, System.DateUtils, System.UITypes,
  ACBrBase,
  ACBrDFe,
  ACBrNFe,
  ACBrDFeSSL,
  ACBrNFeConfiguracoes,
  ACBrDFeConfiguracoes,
  pcnConversaoNFe,
  pcnConversao,
  ACBrNFeNotasFiscais,
  ACBrNFeWebServices,
  System.Generics.Collections, Data.DB, Vcl.Buttons, Vcl.DBGrids,
  Datasnap.DBClient, FileCtrl, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, U_CadCertificado;
type
  TForm_Principal = class(TForm)
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Sair1: TMenuItem;
    Sair2: TMenuItem;
    Cadastros1: TMenuItem;
    Certificados1: TMenuItem;
    ToolBar1: TToolBar;
    StatusBar1: TStatusBar;
    ACBrNFe1: TACBrNFe;
    Panel1: TPanel;
    TreeView1: TTreeView;
    Panel2: TPanel;
    Panel3: TPanel;
    TreeView2: TTreeView;
    Panel4: TPanel;
    Panel5: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    CDataSet_NFE_Entrada: TClientDataSet;
    DataSource_NFE_Entrada: TDataSource;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    Label2: TLabel;
    Label3: TLabel;
    Button_Buscar: TSpeedButton;
    Label4: TLabel;
    CDataSet_NFE_EntradaNFeNúmero: TStringField;
    CDataSet_NFE_EntradaNFeSérie: TStringField;
    CDataSet_NFE_EntradaNFeCTeTipo: TStringField;
    CDataSet_NFE_EntradaEmissão: TStringField;
    CDataSet_NFE_EntradaValor: TCurrencyField;
    CDataSet_NFE_EntradaVencimento: TDateField;
    CDataSet_NFE_EntradaEmitente: TStringField;
    CDataSet_NFE_EntradaCFOP: TStringField;
    CDataSet_NFE_EntradaNatureza: TStringField;
    CDataSet_NFE_EntradaNFeChave: TStringField;
    StatusBar2: TStatusBar;
    DBGrid_NFE_Entrada: TDBGrid;
    Panel7: TPanel;
    FDQuery1: TFDQuery;
    Empresas1: TMenuItem;
    Pop_TreeView: TPopupMenu;
    Pop_Incluir: TMenuItem;
    Pop_Editar: TMenuItem;
    Pop_Excluir: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Empresas1Click(Sender: TObject);
    procedure Pop_EditarClick(Sender: TObject);
    procedure Pop_ExcluirClick(Sender: TObject);
    procedure TreeView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Pop_IncluirClick(Sender: TObject);
    procedure Certificados1Click(Sender: TObject);
    procedure Sair1Click(Sender: TObject);
  private
    function GetFilial(const CNPJ: string): string;
    function GetEntidadeSelecionada: Integer;
    function GetNodeEntidade(Node: TTreeNode): TTreeNode;
    function FormatarDocumento(const Doc: string): string;
    procedure CarregarTreeEntidades;
    { Private declarations }
  public
    { Public declarations }
  end;
var
  Form_Principal: TForm_Principal;

implementation
{$R *.dfm}

uses U_DM, U_CadEmpresa;

function TForm_Principal.GetFilial(const CNPJ: string): string;
begin
  if Length(CNPJ) = 14 then
    Result := Copy(CNPJ, 9, 4)
  else
    Result := '----';
end;

function TForm_Principal.GetEntidadeSelecionada: Integer;
begin
  if Assigned(TreeView1.Selected) then
    Result := Integer(TreeView1.Selected.Data)
  else
    Result := 0;
end;

function TForm_Principal.GetNodeEntidade(Node: TTreeNode): TTreeNode;
begin
  while Assigned(Node) and Assigned(Node.Parent) do
    Node := Node.Parent;
  Result := Node;
end;

function TForm_Principal.FormatarDocumento(const Doc: string): string;
begin
  if Length(Doc) = 14 then
    Result := Copy(Doc,1,2)+'.'+Copy(Doc,3,3)+'.'+Copy(Doc,6,3)+'/'+
              Copy(Doc,9,4)+'-'+Copy(Doc,13,2)
  else if Length(Doc) = 11 then
    Result := Copy(Doc,1,3)+'.'+Copy(Doc,4,3)+'.'+Copy(Doc,7,3)+'-'+
              Copy(Doc,10,2)
  else
    Result := Doc;
end;

procedure TForm_Principal.Pop_EditarClick(Sender: TObject);
var
  Node: TTreeNode;
  ID: Integer;
  Frm: TForm_CadastroEmpresa;
begin
  Node := GetNodeEntidade(TreeView1.Selected);
  if not Assigned(Node) then
  begin
    ShowMessage('Selecione uma entidade.');
    Exit;
  end;
  ID := Integer(Node.Data);
  if ID = 0 then Exit;
  Frm := TForm_CadastroEmpresa.Create(nil);
  try
    Frm.CarregarEmpresa(ID);
    if Frm.ShowModal = mrOk then
      CarregarTreeEntidades; //  atualização automática
  finally
    Frm.Free;
  end;
  CarregarTreeEntidades;
end;

procedure TForm_Principal.Pop_ExcluirClick(Sender: TObject);
var
  Node: TTreeNode;
  ID: Integer;
begin
  Node := GetNodeEntidade(TreeView1.Selected);

  if not Assigned(Node) then
  begin
    ShowMessage('Selecione uma entidade.');
    Exit;
  end;

  ID := Integer(Node.Data);

  if ID = 0 then Exit;

  //  confirmação
  if MessageDlg('Deseja excluir esta entidade e todos os dados vinculados?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  DM.FDConnection1.StartTransaction;
  try
    //  1. excluir certificados
    DM.FDConnection1.ExecSQL(
      'DELETE FROM certificado WHERE entidade_id = :ID',
      [ID]
    );

    //  2. excluir distribuição
    DM.FDConnection1.ExecSQL(
      'DELETE FROM distribuicao_dfe WHERE entidade_id = :ID',
      [ID]
    );

    //  3. excluir entidade
    DM.FDConnection1.ExecSQL(
      'DELETE FROM entidade WHERE id = :ID',
      [ID]
    );

    DM.FDConnection1.Commit;

    ShowMessage('Entidade excluída com sucesso.');

    CarregarTreeEntidades; // 🔥 atualiza árvore

  except
    on E: Exception do
    begin
      DM.FDConnection1.Rollback;
      ShowMessage('Erro ao excluir: ' + E.Message);
    end;
  end;
end;

procedure TForm_Principal.Pop_IncluirClick(Sender: TObject);
begin
   Form_CadastroEmpresa.Novo;
   Form_CadastroEmpresa.ShowModal;
   CarregarTreeEntidades;
end;

procedure TForm_Principal.Sair1Click(Sender: TObject);
begin
   Close;
end;

procedure TForm_Principal.TreeView1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Node: TTreeNode;
begin
  if Button = mbRight then
  begin
    Node := TreeView1.GetNodeAt(X, Y);
    if Assigned(Node) then
      TreeView1.Selected := Node;
  end;
end;

procedure TForm_Principal.CarregarTreeEntidades;
var
  Q: TFDQuery;
  NodeEntidade, NodeCert, NodeNFe: TTreeNode;
  TextoEntidade, TipoDoc, TipoCert: string;
  Doc: string;
  DataValidade: TDate;
begin
  TreeView1.Items.BeginUpdate;
  TreeView1.Items.Clear;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DM.FDConnection1;

    Q.SQL.Text :=
      'SELECT e.id, e.documento, e.razao_social, ' +
      'c.numero_serie, c.data_ativacao, c.data_validade, c.caminho_pfx, ' +
      'd.ultima_busca, d.ultimo_nsu ' +
      'FROM entidade e ' +
      'LEFT JOIN certificado c ON c.entidade_id = e.id AND c.ativo = 1 ' +
      'LEFT JOIN distribuicao_dfe d ON d.entidade_id = e.id ' +
      'ORDER BY e.razao_social';

    Q.Open;

    while not Q.Eof do
    begin
      Doc := Q.FieldByName('documento').AsString;

      //  Tipo documento
      if Length(Doc) = 11 then
        TipoDoc := 'CPF'
      else
        TipoDoc := 'CNPJ';

      //  Nó principal (melhor formatado)
      TextoEntidade := GetFilial(Q.FieldByName('documento').AsString) + ' : ' +
                                 Q.FieldByName('razao_social').AsString;

      NodeEntidade := TreeView1.Items.Add(nil, TextoEntidade);
      NodeEntidade.Data := Pointer(Q.FieldByName('id').AsInteger);

      //  Documento formatado
      TreeView1.Items.AddChild(
        NodeEntidade,
        TipoDoc + ': ' + FormatarDocumento(Doc)
      );

      // ================= CERTIFICADO =================

      if not Q.FieldByName('numero_serie').IsNull then
      begin
        //  Detectar tipo (A1/A3 simples)
        if Q.FieldByName('caminho_pfx').AsString <> '' then
          TipoCert := 'A1'
        else
          TipoCert := 'A3';

        DataValidade := Q.FieldByName('data_validade').AsDateTime;

        //  Nó principal do certificado
        if DataValidade < Date then
          NodeCert := TreeView1.Items.AddChild(
            NodeEntidade,
            'CERTIFICADO (' + TipoCert + ') - VENCIDO'
          )
        else
          NodeCert := TreeView1.Items.AddChild(
            NodeEntidade,
            'CERTIFICADO (' + TipoCert + ')'
          );

        //  Subitens
        TreeView1.Items.AddChild(
          NodeCert,
          'Início: ' +
          DateToStr(Q.FieldByName('data_ativacao').AsDateTime)
        );

        TreeView1.Items.AddChild(
          NodeCert,
          'Fim: ' +
          DateToStr(DataValidade)
        );
      end
      else
      begin
        TreeView1.Items.AddChild(NodeEntidade, 'CERTIFICADO: Nenhum');
      end;

      // ================= NFE =================

      NodeNFe := TreeView1.Items.AddChild(NodeEntidade, 'NFe Dados');

      if not Q.FieldByName('ultima_busca').IsNull then
        TreeView1.Items.AddChild(
          NodeNFe,
          'Última Busca: ' +
          DateTimeToStr(Q.FieldByName('ultima_busca').AsDateTime)
        )
      else
        TreeView1.Items.AddChild(NodeNFe, 'Última Busca: Nunca');

      if not Q.FieldByName('ultimo_nsu').IsNull then
        TreeView1.Items.AddChild(
          NodeNFe,
          'Último NSU: ' +
          Q.FieldByName('ultimo_nsu').AsString
        )
      else
        TreeView1.Items.AddChild(NodeNFe, 'Último NSU: 0');

      Q.Next;
    end;

  finally
    Q.Free;
    TreeView1.Items.EndUpdate;
  end;
end;

procedure TForm_Principal.Certificados1Click(Sender: TObject);
begin
   Form_CadCertificado.ShowModal;
   CarregarTreeEntidades;
end;

procedure TForm_Principal.Empresas1Click(Sender: TObject);
begin
   Form_CadastroEmpresa.Novo;
   Form_CadastroEmpresa.ShowModal;
   CarregarTreeEntidades;
end;

procedure TForm_Principal.FormCreate(Sender: TObject);
begin
  CarregarTreeEntidades;
  DateTimePicker2.DateTime := Now();
  DateTimePicker1.DateTime := (Now()-60);
end;

end.
