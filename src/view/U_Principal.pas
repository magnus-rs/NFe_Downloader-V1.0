unit U_Principal;
interface
uses
  Winapi.Windows, Winapi.Messages, System.IOUtils, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
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
  TNodeEmpresa = class
  public
    ID: Integer;
    Documento: string;
  end;

  TForm_Principal = class(TForm)
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Sair1: TMenuItem;
    Manifestar1: TMenuItem;
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
    DataSource_NFE_Entrada: TDataSource;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    Label2: TLabel;
    Label3: TLabel;
    Button_Buscar: TSpeedButton;
    Label4: TLabel;
    StatusBar2: TStatusBar;
    DBGrid_NFE_Entrada: TDBGrid;
    Panel7: TPanel;
    FDQuery1: TFDQuery;
    Empresas1: TMenuItem;
    Pop_TreeView: TPopupMenu;
    Pop_Incluir: TMenuItem;
    Pop_Editar: TMenuItem;
    Pop_Excluir: TMenuItem;
    Confirmacao: TMenuItem;
    naorealizada1: TMenuItem;
    Desconhecida: TMenuItem;
    CienciadeOperacao1: TMenuItem;
    Btn_BuscaSefaz: TSpeedButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    Btn_DownloadXML: TSpeedButton;
    Configuracoes: TMenuItem;
    FDQuery1XML: TWideStringField;
    FDQuery1numero: TStringField;
    FDQuery1serie: TStringField;
    FDQuery1tipo: TStringField;
    FDQuery1status: TStringField;
    FDQuery1emitente_cnpj: TStringField;
    FDQuery1emitente_nome: TStringField;
    FDQuery1cfop: TStringField;
    FDQuery1natureza: TStringField;
    FDQuery1uf: TStringField;
    FDQuery1data_emissao: TDateTimeField;
    FDQuery1chave: TStringField;
    FDQuery1dest_cnpj: TStringField;
    FDQuery1dest_nome: TStringField;
    FDQuery1tipo_doc: TWideStringField;
    FDQuery1manifestacao: TStringField;
    FDQuery1valor_total: TFloatField;
    FDQuery1xml_rel_path: TStringField;
    procedure FormCreate(Sender: TObject);
    procedure Empresas1Click(Sender: TObject);
    procedure Pop_EditarClick(Sender: TObject);
    procedure Pop_ExcluirClick(Sender: TObject);
    procedure TreeView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Pop_IncluirClick(Sender: TObject);
    procedure Certificados1Click(Sender: TObject);
    procedure Sair1Click(Sender: TObject);
    procedure ConfiguracoesClick(Sender: TObject);
    procedure Btn_BuscaSefazClick(Sender: TObject);
    procedure ProcessarResumo(const AXML, ANSU, EDocumento: string);
    procedure ProcessarNFeCompleta(const AXML, ANSU, EDocumento: string);
    procedure ProcessarEvento(const AXML, ANSU, EDocumento: string);
//    procedure SalvarTotaisNFe(ANFeID: Integer; const AXML: string);
    function SalvarXML(const AXML, Chave, Tipo, EDocumento: string): string;
    procedure Button_BuscarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure FormDestroy(Sender: TObject);
  private
    function GetFilial(const CNPJ: string): string;
    function GetEntidadeSelecionada: Integer;
    function GetNodeEntidade(Node: TTreeNode): TTreeNode;
    function FormatarDocumento(const Doc: string): string;
    procedure CarregarTreeEntidades;
    procedure AtualizarDadosNFe(ATree: TTreeView; IdEmpresa: Integer; NovaData: TDateTime; NovoNSU: string);
    { Private declarations }
  public
    { Public declarations }
  end;
var
  Form_Principal: TForm_Principal;

implementation
{$R *.dfm}

uses U_DM, U_CadEmpresa, U_Configurações, U_XMLUtils, U_Config,
  U_configService;

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

    CarregarTreeEntidades; //  atualiza árvore

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

procedure TForm_Principal.TreeView1Change(
  Sender: TObject;
  Node: TTreeNode);
var
  Empresa: TNodeEmpresa;
begin
  if not Assigned(Node) then
    Exit;

  // somente empresa
  if Node.Level <> 0 then
    Exit;

  if not Assigned(Node.Data) then
    Exit;

  Empresa := TNodeEmpresa(Node.Data);

  FDQuery1.Close;

  FDQuery1.ParamByName('CNPJ').AsString :=
    Empresa.Documento;

  FDQuery1.Open;
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

procedure TForm_Principal.Btn_BuscaSefazClick(Sender: TObject);
var
  QBusca: TFDQuery;
  Node: TTreeNode;
  ID, I: Integer;
  Caminho, NomeArquivo, Chave, TipoDoc: string;
  AultNSU, vNSU, XML: string;
  AultimaBusca, AProximaBusca, DataEmissao: TDateTime;
  Atualizar: boolean;
  Empresa: TNodeEmpresa;
begin
  Atualizar := False;
  QBusca := TFDQuery.Create(nil);
  Node := GetNodeEntidade(TreeView1.Selected);

  if not Assigned(Node) then
  begin
    ShowMessage('Selecione uma entidade.');
    Exit;
  end;

  {ID := Integer(Node.Data);
  if ID = 0 then Exit; }

  if not Assigned(Node.Data) then
   begin
      ShowMessage('Entidade inválida.');
      Exit;
   end;

  Empresa := TNodeEmpresa(Node.Data);

  ID := Empresa.ID;

  if ID = 0 then
    Exit;

  try
    QBusca.Connection := DM.FDConnection1;
    QBusca.SQL.Text :=
      'SELECT e.id, e.documento, e.razao_social, e.uf_id, e.ambiente, ' +
      'c.numero_serie, c.data_ativacao, c.data_validade, c.caminho_pfx, c.senha, ' +
      'd.ultima_busca, d.ultimo_nsu, u.codigo_ibge ' +
      'FROM entidade e ' +
      'LEFT JOIN certificado c ON c.entidade_id = e.id AND c.ativo = 1 ' +
      'LEFT JOIN distribuicao_dfe d ON d.entidade_id = e.id ' +
      'LEFT JOIN uf u ON u.id = e.uf_id ' +
      'WHERE e.id = ? ' +
      'ORDER BY e.razao_social';
    QBusca.Params[0].AsInteger := ID;
    QBusca.Open;

    if not QBusca.FieldByName('ultima_busca').IsNull then
    begin
      AUltimaBusca := QBusca.FieldByName('ultima_busca').AsDateTime;
      if MinutesBetween(Now, AUltimaBusca) < 62 then
      begin
        AProximaBusca := IncHour(AUltimaBusca, 1);
        ShowMessage(
          'A última consulta foi realizada há menos de 1 hora.' + sLineBreak +
          'Aguarde para evitar bloqueio por uso indevido da SEFAZ.'+ sLineBreak +
          'Próxima busca: ' + DateTimeToStr(AProximaBusca)
        );
        Atualizar := false;
        Exit;
      end;
    end;

    with ACBrNFe1.Configuracoes do begin

      Geral.SSLLib := libOpenSSL;
      Geral.SSLCryptLib := cryOpenSSL;
      Geral.SSLHttpLib := httpOpenSSL;
      Geral.SSLXmlSignLib := xsLibXml2;

      Certificados.ArquivoPFX := QBusca.FieldByName('caminho_pfx').AsString;
      Certificados.Senha := QBusca.FieldByName('senha').AsString;

      Arquivos.PathSchemas := TConfigService.Config.PathSchemas;

      {Arquivos.PathNFe :=
        TConfigService.CaminhoBaseXML +
        QBusca.FieldByName('Documento').AsString; }

      Arquivos.PathNFe :=
          TPath.Combine(
            TConfigService.CaminhoBaseXML,
            Empresa.Documento );

      {Arquivos.DownloadDFe.PathDownload :=
        TConfigService.CaminhoBaseXML +
        QBusca.FieldByName('Documento').AsString;}

      Arquivos.DownloadDFe.PathDownload :=
          TPath.Combine(
            TConfigService.CaminhoBaseXML,
            Empresa.Documento );

    end;

    try
      ACBrNFe1.SSL.CarregarCertificado;

      ACBrNFe1.DistribuicaoDFePorUltNSU(
        QBusca.FieldByName('codigo_ibge').AsInteger,
        QBusca.FieldByName('documento').AsString,
        QBusca.FieldByName('ultimo_nsu').AsString
      );

    except
      on E: Exception do
      begin

        // 656 = Consumo Indevido
        if ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.cStat = 656 then
        begin
          ShowMessage(
            'Consumo indevido detectado.' + sLineBreak +
            'A SEFAZ exige intervalo mínimo de 1 hora.'  + sLineBreak +
            'A Próxima busca deve ser feita as: ' + DateTimeToStr(IncHour(Now(), 1))
          );

          QBusca.Close;
          QBusca.SQL.Clear;

          QBusca.SQL.Text :=
            'UPDATE distribuicao_dfe SET ' +
            'ultimo_nsu = :UltimoNSU, ' +
            'ultima_busca = :UltimaBusca ' +
            'WHERE entidade_id = :EmpID';

          QBusca.ParamByName('UltimoNSU').AsString :=
            ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.ultNSU;

          QBusca.ParamByName('UltimaBusca').AsDateTime :=
            ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.dhResp;

          QBusca.ParamByName('EmpID').AsInteger := ID;

          QBusca.ExecSQL;

          CarregarTreeEntidades;

          Exit;
        end;

        // Outros erros
        raise Exception.Create(
          'Erro ao consultar SEFAZ: ' + E.Message
        );
      end;
    end;

    Caminho := TPath.Combine(
      TConfigService.CaminhoBaseXML,
      QBusca.FieldByName('documento').AsString );

    Caminho := IncludeTrailingPathDelimiter(Caminho);

    AultNSU := ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.ultNSU;

    if ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.DocZip.Count = 0 then
    begin
      QBusca.Close;
      QBusca.SQL.Clear;

      QBusca.ResourceOptions.ParamCreate := True;

      QBusca.SQL.Text :=
        'UPDATE distribuicao_dfe SET ' +
        'ultimo_nsu = :UltimoNSU, ' +
        'ultima_busca = :UltimaBusca ' +
        'WHERE entidade_id = :EmpID';

      QBusca.ParamByName('UltimoNSU').AsString :=
        ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.ultNSU;

      QBusca.ParamByName('UltimaBusca').AsDateTime :=
        ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.dhResp;

      QBusca.ParamByName('EmpID').AsInteger := ID;

      QBusca.ExecSQL;

      CarregarTreeEntidades;
      ShowMessage('Nenhum novo documento encontrado!!!');
      exit;
    end;

    ShowMessage('Total de documentos encontrados: ' + IntToStr(ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Count));

    for I := 0 to ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Count - 1 do
    begin
      with ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.docZip.Items[i] do
      begin
        vNSU := NSU;
        if schema = schresNFe then
        begin
           ProcessarResumo(XML, vNSU, Empresa.Documento );   //QBusca.FieldByName('documento').AsString);
        end
        else if schema = schprocNFe then
        begin
           ProcessarNFeCompleta(XML, vNSU, Empresa.Documento);  //QBusca.FieldByName('documento').AsString);
        end
        else if schema = schprocEventoNFe then
        begin
           ProcessarEvento(XML, vNSU, Empresa.Documento);   //QBusca.FieldByName('documento').AsString);
        end ;
      end;
    end;

   Atualizar := True;

  finally

    if Atualizar then
    begin
      QBusca.Close;
      QBusca.SQL.Clear;

      QBusca.ResourceOptions.ParamCreate := True;

      QBusca.SQL.Text :=
        'UPDATE distribuicao_dfe SET ' +
        'ultimo_nsu = :UltimoNSU, ' +
        'ultima_busca = :UltimaBusca ' +
        'WHERE entidade_id = :EmpID';

      QBusca.ParamByName('UltimoNSU').AsString :=
        ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.ultNSU;

      QBusca.ParamByName('UltimaBusca').AsDateTime :=
        ACBrNFe1.WebServices.DistribuicaoDFe.retDistDFeInt.dhResp;

      QBusca.ParamByName('EmpID').AsInteger := ID;

      QBusca.ExecSQL;

      CarregarTreeEntidades;
    end;

    QBusca.Free;
    ACBrNFe1.SSL.DescarregarCertificado;

  end;

end;

procedure TForm_Principal.Button_BuscarClick(Sender: TObject);
begin
    FDQuery1.Close;
    FDQuery1.ParamByName('DATA_INI').AsDateTime :=
          StartOfTheDay(DateTimePicker1.DateTime);
    FDQuery1.ParamByName('DATA_FIM').AsDateTime :=
          EndOfTheDay(DateTimePicker2.DateTime);
    FDquery1.Open;
end;

procedure TForm_Principal.ProcessarResumo(
  const AXML, ANSU, EDocumento: string);
var
  Chave, Caminho: string;
  DataEmi: TDateTime;
  QRes: TFDQuery;
begin
  QRes := TFDQuery.Create(nil);
  try
    QRes.Connection := DM.FDConnection1;

    Chave := ExtrairChave(AXML);
    DataEmi := ExtrairData(AXML);

    Caminho := SalvarXML(
      AXML,
      Chave,
      'RES',
      EDocumento
    );

    // verifica se já existe
    QRes.SQL.Text :=
      'SELECT id, tipo_xml FROM nfe WHERE chave = :chave';

    QRes.ParamByName('chave').AsString := Chave;
    QRes.Open;

    // =====================================
    // JÁ EXISTE → UPDATE
    // =====================================
    if not QRes.IsEmpty then
    begin
      QRes.Close;

      QRes.SQL.Text :=
        'UPDATE nfe SET ' +
        'nsu = :nsu, ' +
        'tipo_xml = :tipo_xml, ' +
        'data_emissao = :data_emissao, ' +
        'xml_rel_path = :xml_rel_path, ' +
        'status = :status ' +
        'WHERE chave = :chave';

      QRes.ParamByName('nsu').AsString := ANSU;
      QRes.ParamByName('tipo_xml').AsString := 'RES';
      QRes.ParamByName('data_emissao').AsDateTime := DataEmi;
      QRes.ParamByName('xml_rel_path').AsString := Caminho;
      QRes.ParamByName('status').AsString := 'RESUMO';
      QRes.ParamByName('chave').AsString := Chave;

      QRes.ExecSQL;
    end

    // =====================================
    // NÃO EXISTE → INSERT
    // =====================================
    else
    begin
      QRes.Close;

      QRes.SQL.Text :=
        'INSERT INTO nfe (' +
        'cnpj, chave, nsu, tipo_xml, data_emissao, status, xml_rel_path' +
        ') VALUES (' +
        ':cnpj, :chave, :nsu, :tipo_xml, :data_emissao, :status, :xml_rel_path)';

      QRes.ParamByName('cnpj').AsString := EDocumento;
      QRes.ParamByName('chave').AsString := Chave;
      QRes.ParamByName('nsu').AsString := ANSU;
      QRes.ParamByName('tipo_xml').AsString := 'RES';
      QRes.ParamByName('data_emissao').AsDateTime := DataEmi;
      QRes.ParamByName('status').AsString := 'RESUMO';
      QRes.ParamByName('xml_rel_path').AsString := Caminho;

      QRes.ExecSQL;
    end;

  finally
    QRes.Free;
  end;
end;

procedure TForm_Principal.ProcessarNFeCompleta(
  const AXML, ANSU, EDocumento: string);
var
  QProc: TFDQuery;

  NFeID: Integer;

  Chave: string;
  Numero: string;
  Serie: string;
  Modelo: string;

  DataEmi: TDateTime;
  DataAut: TDateTime;

  ValorTotal: Double;

  EmitCNPJ: string;
  EmitNome: string;

  DestCNPJ: string;
  DestNome: string;

  UF: string;
  CFOP: string;
  Natureza: string;

  Status: string;
  Caminho: string;

  ListaImpostos: TList<TImpostoInfo>;
  Imposto: TImpostoInfo;

begin
  QProc := TFDQuery.Create(nil);

  ListaImpostos := nil;

  try
    QProc.Connection := DM.FDConnection1;

    { =========================================
      EXTRAÇÕES
      ========================================= }

    Chave      := ExtrairChave(AXML);

    Numero     := ExtrairNumeroNFe(AXML);
    Serie      := ExtrairSerieNFe(AXML);
    Modelo     := ExtrairModeloNFe(AXML);

    DataEmi    := ExtrairDataEmissao(AXML);
    DataAut    := ExtrairDataAutorizacao(AXML);

    ValorTotal := ExtrairValorTotal(AXML);

    EmitCNPJ   := ExtrairEmitenteCNPJ(AXML);
    EmitNome   := ExtrairEmitenteNome(AXML);

    DestCNPJ   := ExtrairDestCNPJ(AXML);
    DestNome   := ExtrairDestNome(AXML);

    UF         := ExtrairUF(AXML);

    CFOP       := ExtrairCFOPPrincipal(AXML);

    Natureza   := ExtrairNaturezaOperacao(AXML);

    Status     := 'AUTORIZADA';

    Caminho :=
      SalvarXML(
        AXML,
        Chave,
        'NFe',
        EDocumento);

    { =========================================
      UPDATE
      ========================================= }

    QProc.SQL.Text :=
      'UPDATE nfe SET ' +
      'nsu = :nsu, ' +
      'numero = :numero, ' +
      'serie = :serie, ' +
      'modelo = :modelo, ' +
      'tipo_xml = :tipo_xml, ' +
      'data_emissao = :data_emissao, ' +
      'data_autorizacao = :data_autorizacao, ' +
      'valor_total = :valor_total, ' +
      'emitente_cnpj = :emitente_cnpj, ' +
      'emitente_nome = :emitente_nome, ' +
      'dest_cnpj = :dest_cnpj, ' +
      'dest_nome = :dest_nome, ' +
      'uf = :uf, ' +
      'cfop = :cfop, ' +
      'natureza = :natureza, ' +
      'status = :status, ' +
      'xml_rel_path = :xml_rel_path ' +
      'WHERE chave = :chave';

    QProc.ParamByName('nsu').AsString := ANSU;

    QProc.ParamByName('numero').AsString := Numero;
    QProc.ParamByName('serie').AsString := Serie;
    QProc.ParamByName('modelo').AsString := Modelo;

    QProc.ParamByName('tipo_xml').AsString := 'PROC';

    QProc.ParamByName('data_emissao').AsDateTime := DataEmi;
    QProc.ParamByName('data_autorizacao').AsDateTime := DataAut;

    QProc.ParamByName('valor_total').AsFloat := ValorTotal;

    QProc.ParamByName('emitente_cnpj').AsString := EmitCNPJ;
    QProc.ParamByName('emitente_nome').AsString := EmitNome;

    QProc.ParamByName('dest_cnpj').AsString := DestCNPJ;
    QProc.ParamByName('dest_nome').AsString := DestNome;

    QProc.ParamByName('uf').AsString := UF;
    QProc.ParamByName('cfop').AsString := CFOP;

    QProc.ParamByName('natureza').AsString := Natureza;

    QProc.ParamByName('status').AsString := Status;

    QProc.ParamByName('xml_rel_path').AsString := Caminho;

    QProc.ParamByName('chave').AsString := Chave;

    QProc.ExecSQL;

    { =========================================
      INSERT
      ========================================= }

    if QProc.RowsAffected = 0 then
    begin
      QProc.Close;

      QProc.SQL.Text :=
        'INSERT INTO nfe (' +
        'cnpj, chave, nsu, numero, serie, modelo, tipo_xml, ' +
        'data_emissao, data_autorizacao, valor_total, ' +
        'emitente_cnpj, emitente_nome, dest_cnpj, dest_nome, ' +
        'uf, cfop, natureza, status, xml_rel_path' +
        ') VALUES (' +
        ':cnpj, :chave, :nsu, :numero, :serie, :modelo, :tipo_xml, ' +
        ':data_emissao, :data_autorizacao, :valor_total, ' +
        ':emitente_cnpj, :emitente_nome, :dest_cnpj, :dest_nome, ' +
        ':uf, :cfop, :natureza, :status, :xml_rel_path)';

      QProc.ParamByName('cnpj').AsString := EDocumento;

      QProc.ParamByName('chave').AsString := Chave;
      QProc.ParamByName('nsu').AsString := ANSU;

      QProc.ParamByName('numero').AsString := Numero;
      QProc.ParamByName('serie').AsString := Serie;
      QProc.ParamByName('modelo').AsString := Modelo;

      QProc.ParamByName('tipo_xml').AsString := 'PROC';

      QProc.ParamByName('data_emissao').AsDateTime := DataEmi;
      QProc.ParamByName('data_autorizacao').AsDateTime := DataAut;

      QProc.ParamByName('valor_total').AsFloat := ValorTotal;

      QProc.ParamByName('emitente_cnpj').AsString := EmitCNPJ;
      QProc.ParamByName('emitente_nome').AsString := EmitNome;

      QProc.ParamByName('dest_cnpj').AsString := DestCNPJ;
      QProc.ParamByName('dest_nome').AsString := DestNome;

      QProc.ParamByName('uf').AsString := UF;
      QProc.ParamByName('cfop').AsString := CFOP;

      QProc.ParamByName('natureza').AsString := Natureza;

      QProc.ParamByName('status').AsString := Status;

      QProc.ParamByName('xml_rel_path').AsString := Caminho;

      QProc.ExecSQL;
    end;

    { =========================================
      LOCALIZAR ID
      ========================================= }

    QProc.Close;

    QProc.SQL.Text :=
      'SELECT id FROM nfe WHERE chave = :chave';

    QProc.ParamByName('chave').AsString := Chave;

    QProc.Open;

    if QProc.IsEmpty then
      Exit;

    NFeID :=
      QProc.FieldByName('id').AsInteger;

    QProc.Close;

    { =========================================
      LIMPA IMPOSTOS ANTIGOS
      ========================================= }

    QProc.SQL.Text :=
      'DELETE FROM nfe_impostos ' +
      'WHERE nfe_id = :nfe_id';

    QProc.ParamByName('nfe_id').AsInteger := NFeID;

    QProc.ExecSQL;

    { =========================================
      EXTRAI NOVOS IMPOSTOS
      ========================================= }

    ListaImpostos := ExtrairImpostos(AXML);

    for Imposto in ListaImpostos do
    begin
      QProc.Close;

      QProc.SQL.Text :=
        'INSERT INTO nfe_impostos (' +
        'nfe_id, tipo_imposto, cst, cbenef, ' +
        'base_calculo, percentual_aliquota, percentual_reducao, ' +
        'valor_imposto, ' +
        'base_ibs, aliquota_ibs, valor_ibs, ' +
        'base_cbs, aliquota_cbs, valor_cbs, ' +
        'observacao )' +

        'VALUES (' +
        ':nfe_id, :tipo_imposto, :cst, :cbenef, ' +
        ':base_calculo, :percentual_aliquota, :percentual_reducao, ' +
        ':valor_imposto, ' +
        ':base_ibs, :aliquota_ibs, :valor_ibs, ' +
        ':base_cbs, :aliquota_cbs, :valor_cbs, ' +
        ':observacao)';

      QProc.ParamByName('nfe_id').AsInteger :=
        NFeID;

      QProc.ParamByName('tipo_imposto').AsString :=
        Imposto.TipoImposto;

     // QProc.ParamByName('origem_imposto').AsString :=
     //   Imposto.OrigemImposto;

      QProc.ParamByName('cst').AsString :=
        Imposto.CST;

      QProc.ParamByName('cbenef').AsString :=
        Imposto.CBenef;

      QProc.ParamByName('base_calculo').AsFloat :=
        Imposto.BaseCalculo;

      // QProc.ParamByName('base_calculo_reduzida').AsFloat :=
      //  Imposto.BaseCalculoReduzida;

      QProc.ParamByName('percentual_aliquota').AsFloat :=
        Imposto.Aliquota;

      QProc.ParamByName('percentual_reducao').AsFloat :=
        Imposto.PercentualReducao;

      QProc.ParamByName('valor_imposto').AsFloat :=
        Imposto.ValorImposto;

      // QProc.ParamByName('valor_isento').AsFloat :=
      //  Imposto.ValorIsento;

      { IBS }

      QProc.ParamByName('base_ibs').AsFloat :=
        Imposto.BaseIBS;

      QProc.ParamByName('aliquota_ibs').AsFloat :=
        Imposto.AliquotaIBS;

      QProc.ParamByName('valor_ibs').AsFloat :=
        Imposto.ValorIBS;

      { CBS }

      QProc.ParamByName('base_cbs').AsFloat :=
        Imposto.BaseCBS;

      QProc.ParamByName('aliquota_cbs').AsFloat :=
        Imposto.AliquotaCBS;

      QProc.ParamByName('valor_cbs').AsFloat :=
        Imposto.ValorCBS;


      QProc.ParamByName('observacao').AsString :=
        Imposto.Observacao;

      QProc.ExecSQL;
end;

  finally
    ListaImpostos.Free;
    QProc.Free;
  end;
end;

procedure TForm_Principal.ProcessarEvento(
  const AXML, ANSU, EDocumento: string);
var
  QEvent: TFDQuery;
  Chave: string;
  Caminho: string;
  NFeID: Integer;
begin
  QEvent := TFDQuery.Create(nil);
  try
    QEvent.Connection := DM.FDConnection1;

    Chave := ExtrairChave(AXML);

    // localizar NF-e
    QEvent.SQL.Text :=
      'SELECT id FROM nfe WHERE chave = :chave';

    QEvent.ParamByName('chave').AsString := Chave;
    QEvent.Open;

    // Se não existir, cria placeholder
    if QEvent.IsEmpty then
    begin
      QEvent.Close;

      QEvent.SQL.Text :=
        'INSERT INTO nfe (' +
        'cnpj, chave, nsu, tipo_xml, status, xml_rel_path' +
        ') VALUES (' +
        ':cnpj, :chave, :nsu, :tipo_xml, :status, :xml_rel_path)';

      QEvent.ParamByName('cnpj').AsString := EDocumento;
      QEvent.ParamByName('chave').AsString := Chave;
      QEvent.ParamByName('nsu').AsString := ANSU;
      QEvent.ParamByName('tipo_xml').AsString := 'EVENTO';
      QEvent.ParamByName('status').AsString := 'PENDENTE';
      QEvent.ParamByName('xml_rel_path').AsString := '';

      QEvent.ExecSQL;

      // buscar ID recém criado
      QEvent.SQL.Text :=
        'SELECT id FROM nfe WHERE chave = :chave';

      QEvent.ParamByName('chave').AsString := Chave;
      QEvent.Open;
    end;

    NFeID := QEvent.FieldByName('id').AsInteger;
    QEvent.Close;

    // agora salva XML
    Caminho := SalvarXML(
      AXML,
      Chave,
      'EVENTO',
      EDocumento
    );

    // inserir evento
    QEvent.SQL.Text :=
      'INSERT INTO nfe_eventos (' +
      'nfe_id, tipo_evento, descricao, data_evento, xml_rel_path' +
      ') VALUES (' +
      ':nfe_id, :tipo_evento, :descricao, :data_evento, :xml_rel_path)';

    QEvent.ParamByName('nfe_id').AsInteger := NFeID;

    QEvent.ParamByName('tipo_evento').AsString :=
      ExtrairTipoEvento(AXML);

    QEvent.ParamByName('descricao').AsString :=
      ExtrairDescricaoEvento(AXML);

    QEvent.ParamByName('data_evento').AsDateTime :=
      ExtrairDataEvento(AXML);

    QEvent.ParamByName('xml_rel_path').AsString :=
      Caminho;

    QEvent.ExecSQL;

  finally
    QEvent.Free;
  end;
end;

function TForm_Principal.SalvarXML(
  const AXML,
        Chave,
        Tipo,
        EDocumento: string): string;
var
  CaminhoBase: string;
  NomeArquivo: string;
begin
  CaminhoBase := TPath.Combine(
    TConfigService.Config.PathBaseXML,
    EDocumento
  );

  CaminhoBase := TPath.Combine(
    CaminhoBase,
    Tipo
  );

  ForceDirectories(CaminhoBase);

  NomeArquivo := TPath.Combine(
    CaminhoBase,
    Chave + '.xml'
  );

  // salva em UTF8
  TFile.WriteAllText(
    NomeArquivo,
    AXML,
    TEncoding.UTF8
  );

  Result := NomeArquivo;
end;

procedure TForm_Principal.CarregarTreeEntidades;
var
  Q: TFDQuery;
  NodeEntidade, NodeCert, NodeNFe: TTreeNode;
  TextoEntidade, TipoDoc, TipoCert: string;
  Doc: string;
  DataValidade: TDate;
  DataAtivacao: TDate;
  EmpresaObj: TNodeEmpresa;
begin
  TreeView1.Items.BeginUpdate;
  TreeView1.Items.Clear;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DM.FDConnection1;

    Q.SQL.Text :=
      'SELECT e.id, e.documento, e.razao_social, e.uf_id, ' +
      'c.numero_serie, c.data_ativacao, c.data_validade, c.caminho_pfx, c.senha, ' +
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

      EmpresaObj := TNodeEmpresa.Create;
      EmpresaObj.ID :=
        Q.FieldByName('id').AsInteger;
      EmpresaObj.Documento :=
        Q.FieldByName('documento').AsString;

      NodeEntidade := TreeView1.Items.Add(nil, TextoEntidade);
      NodeEntidade.Data := EmpresaObj;                             ///Pointer(Q.FieldByName('id').AsInteger);

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
        DataAtivacao := Q.FieldByName('data_ativacao').AsDateTime;

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
          DateToStr(DataAtivacao)
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

{procedure TForm_Principal.SalvarTotaisNFe(ANFeID: Integer; const AXML: string);
var
  QTotais: TFDQuery;
begin
  QTotais := TFDQuery.Create(nil);
  try
    QTotais.Connection := DM.FDConnection1;

    // evita duplicidade
    QTotais.SQL.Text :=
      'DELETE FROM nfe_totais WHERE nfe_id = :nfe_id';

    QTotais.ParamByName('nfe_id').AsInteger := ANFeID;

    QTotais.ExecSQL;

    // insert
    QTotais.SQL.Text :=
      'INSERT INTO nfe_totais (' +
      'nfe_id, base_icms, valor_icms, valor_icms_st, ' +
      'valor_pis, valor_cofins, valor_ipi, valor_frete, ' +
      'valor_seguro, valor_desconto, valor_outros' +
      ') VALUES (' +
      ':nfe_id, :base_icms, :valor_icms, :valor_icms_st, ' +
      ':valor_pis, :valor_cofins, :valor_ipi, :valor_frete, ' +
      ':valor_seguro, :valor_desconto, :valor_outros)';

    QTotais.ParamByName('nfe_id').AsInteger := ANFeID;

    QTotais.ParamByName('base_icms').AsFloat :=
      ExtrairBaseICMS(AXML);

    QTotais.ParamByName('valor_icms').AsFloat :=
      ExtrairValorICMS(AXML);

    QTotais.ParamByName('valor_icms_st').AsFloat :=
      ExtrairValorICMSST(AXML);

    QTotais.ParamByName('valor_pis').AsFloat :=
      ExtrairValorPIS(AXML);

    QTotais.ParamByName('valor_cofins').AsFloat :=
      ExtrairValorCOFINS(AXML);

    QTotais.ParamByName('valor_ipi').AsFloat :=
      ExtrairValorIPI(AXML);

    QTotais.ParamByName('valor_frete').AsFloat :=
      ExtrairValorFrete(AXML);

    QTotais.ParamByName('valor_seguro').AsFloat :=
      ExtrairValorSeguro(AXML);

    QTotais.ParamByName('valor_desconto').AsFloat :=
      ExtrairValorDesconto(AXML);

    QTotais.ParamByName('valor_outros').AsFloat :=
      ExtrairValorOutros(AXML);

    QTotais.ExecSQL;

  finally
    QTotais.Free;
  end;
end;  }

procedure TForm_Principal.AtualizarDadosNFe(ATree: TTreeView; IdEmpresa: Integer; NovaData: TDateTime; NovoNSU: string);
var
  NodeEmpresa, NodeNFe, NodeInfo: TTreeNode;
  i: Integer;
begin
  NodeEmpresa := nil;
  // 1. Localiza o nó da empresa pelo ID armazenado no .Data
  for i := 0 to ATree.Items.Count - 1 do
  begin
    if Integer(ATree.Items[i].Data) = IdEmpresa then
    begin
      NodeEmpresa := ATree.Items[i];
      Break;
    end;
  end;
  if NodeEmpresa <> nil then
  begin
    // 2. Procura o nó "NFe Dados" dentro desta empresa
    NodeNFe := NodeEmpresa.getFirstChild;
    while NodeNFe <> nil do
    begin
      if NodeNFe.Text = 'NFe Dados' then
      begin
        // 3. Atualiza os netos (os valores de busca e NSU)
        NodeInfo := NodeNFe.getFirstChild;
        while NodeInfo <> nil do
        begin
          if Pos('Última Busca:', NodeInfo.Text) > 0 then
            NodeInfo.Text := 'Última Busca: ' + DateTimeToStr(NovaData);
          if Pos('Último NSU:', NodeInfo.Text) > 0 then
            NodeInfo.Text := 'Último NSU: ' + NovoNSU;
          NodeInfo := NodeNFe.GetNextChild(NodeInfo);
        end;
        Break;
      end;
      NodeNFe := NodeEmpresa.GetNextChild(NodeNFe);
    end;
  end;
end;


procedure TForm_Principal.Certificados1Click(Sender: TObject);
begin
   Form_CadCertificado.ShowModal;
   CarregarTreeEntidades;
end;

procedure TForm_Principal.ConfiguracoesClick(Sender: TObject);
begin
  Form_configuracoes.ShowModal;
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

procedure TForm_Principal.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to TreeView1.Items.Count - 1 do
  begin
    if Assigned(TreeView1.Items[I].Data) then
      TObject(TreeView1.Items[I].Data).Free;
  end;
end;

procedure TForm_Principal.FormShow(Sender: TObject);
begin
  FDQuery1.ParamByName('DATA_INI').AsDateTime :=
    StartOfTheDay(DateTimePicker1.DateTime);
  FDQuery1.ParamByName('DATA_FIM').AsDateTime :=
    EndOfTheDay(DateTimePicker2.DateTime);
  FDQuery1.Active := True;
end;

end.
