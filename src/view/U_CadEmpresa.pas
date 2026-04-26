unit U_CadEmpresa;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.DateUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Mask, FireDAC.Comp.Client, Data.DB,
  U_CertificadoService, U_Entidade, U_Certificado, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TForm_CadastroEmpresa = class(TForm)
    Label1: TLabel;
    Edit_Documento: TMaskEdit;
    Label2: TLabel;
    Edit_Razao: TEdit;
    Label3: TLabel;
    Edit_Email: TEdit;
    Label4: TLabel;
    Combo_UF: TComboBox;
    Check_Ativo: TCheckBox;
    Btn_Salvar: TButton;
    Label5: TLabel;
    Combo_Doc: TComboBox;
    Label6: TLabel;
    Bevel1: TBevel;
    Label_Certificado: TLabel;
    Edit_Certificado: TEdit;
    FDQuery1: TFDQuery;
    Btn_Cancelar: TButton;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Btn_SalvarClick(Sender: TObject);
    procedure Label_CertificadoClick(Sender: TObject);
    procedure Btn_CancelarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FEntidade: TEntidade;
    FCertCaminho: string;
    FCertSenha: string;

    function GetUFSelecionada: Integer;
    function SomenteNumeros(const Texto: string): string;
    procedure CarregarUFs;

  public
    procedure Novo;
    procedure CarregarEmpresa(ID: Integer);
  end;

var
  Form_CadastroEmpresa: TForm_CadastroEmpresa;

implementation

{$R *.dfm}

uses
  U_DM;

{ ================= AUXILIARES ================= }

function TForm_CadastroEmpresa.SomenteNumeros(const Texto: string): string;
begin
  Result := Texto.Replace('.', '')
                 .Replace('-', '')
                 .Replace('/', '')
                 .Trim;
end;

function TForm_CadastroEmpresa.GetUFSelecionada: Integer;
begin
  if Combo_UF.ItemIndex >= 0 then
    Result := Integer(Combo_UF.Items.Objects[Combo_UF.ItemIndex])
  else
    Result := 0;
end;

procedure TForm_CadastroEmpresa.CarregarUFs;
var
  Query: TFDQuery;
begin
  Combo_UF.Clear;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := DM.FDConnection1;
    Query.SQL.Text := 'SELECT id, sigla, nome FROM uf ORDER BY sigla';
    Query.Open;

    while not Query.Eof do
    begin
      Combo_UF.Items.AddObject(
        Query.FieldByName('sigla').AsString + ' - ' +
        Query.FieldByName('nome').AsString,
        TObject(Query.FieldByName('id').AsInteger)
      );
      Query.Next;
    end;

  finally
    Query.Free;
  end;
end;

{ ================= CERTIFICADO ================= }

procedure TForm_CadastroEmpresa.Label_CertificadoClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
begin
  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Filter := 'Certificado (*.pfx)|*.pfx';

    if OpenDialog.Execute then
    begin
      FCertCaminho := OpenDialog.FileName;

      FCertSenha := InputBox('Certificado', 'Digite a senha do certificado:', '');
      if FCertSenha = '' then Exit;

      Edit_Certificado.Text := FCertCaminho;
    end;

  finally
    OpenDialog.Free;
  end;
end;

{ ================= CONTROLE ================= }

procedure TForm_CadastroEmpresa.Novo;
begin
  FEntidade.Limpar;

  Edit_Documento.Clear;
  Edit_Razao.Clear;
  Edit_Email.Clear;
  Edit_Certificado.Clear;

  FCertCaminho := '';
  FCertSenha := '';

  Combo_Doc.ItemIndex := 0;
  Combo_UF.ItemIndex := -1;

  Check_Ativo.Checked := True;
end;

procedure TForm_CadastroEmpresa.CarregarEmpresa(ID: Integer);
var
  Q: TFDQuery;
begin
  FEntidade.Carregar(ID);
  if FEntidade.ID <> 0 then
  begin
    Edit_Documento.Text := FEntidade.Documento;
    Edit_Razao.Text := FEntidade.RazaoSocial;
    Edit_Email.Text := FEntidade.Email;
    Check_Ativo.Checked := FEntidade.Ativo;
    Combo_Doc.ItemIndex := FEntidade.TipoToInt - 1;
    Combo_UF.ItemIndex :=
      Combo_UF.Items.IndexOfObject(TObject(FEntidade.UFID));
  end;
  // ================= CERTIFICADO =================
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DM.FDConnection1;
    Q.SQL.Text :=
      'SELECT caminho_pfx, senha FROM certificado ' +
      'WHERE entidade_id = ? AND ativo = 1';
    Q.Params[0].AsInteger := ID; // ou use Params[0]
    Q.Open;
    if not Q.Eof then
    begin
      FCertCaminho := Q.FieldByName('caminho_pfx').AsString;
      FCertSenha := Q.FieldByName('senha').AsString;
      Edit_Certificado.Text := FCertCaminho;
    end
    else
    begin
      FCertCaminho := '';
      FCertSenha := '';
      Edit_Certificado.Clear;
    end;
  finally
    Q.Free;
  end;
end;

{ ================= SALVAR ================= }

procedure TForm_CadastroEmpresa.Btn_CancelarClick(Sender: TObject);
begin
    ModalResult := mrCancel;
end;

procedure TForm_CadastroEmpresa.Btn_SalvarClick(Sender: TObject);
var
  Doc: string;
  Cert: TCertificado;
  InfoCert: TInfoCertificado;
begin
  if Combo_Doc.ItemIndex < 0 then
    raise Exception.Create('Selecione o tipo (CPF ou CNPJ)');

  if Trim(Edit_Documento.Text) = '' then
    raise Exception.Create('Informe o documento');

  if Trim(Edit_Razao.Text) = '' then
    raise Exception.Create('Informe a Razão Social');

  if GetUFSelecionada = 0 then
    raise Exception.Create('Selecione a UF');

  Doc := SomenteNumeros(Edit_Documento.Text);

  if FCertCaminho <> '' then
  begin
    InfoCert := TCertificadoService.LerCertificado(FCertCaminho, FCertSenha);
    if InfoCert.Documento <> Doc then
      raise Exception.Create(
        'O certificado pertence a outro CPF/CNPJ.'
      );
  end;

  if (Combo_Doc.ItemIndex = 0) and (Length(Doc) <> 14) then
    raise Exception.Create('CNPJ inválido');

  if (Combo_Doc.ItemIndex = 1) and (Length(Doc) <> 11) then
    raise Exception.Create('CPF inválido');

  // Preenche entidade
  FEntidade.Tipo := TTipoDocumento(Combo_Doc.ItemIndex);
  FEntidade.Documento := Doc;
  FEntidade.RazaoSocial := Edit_Razao.Text;
  FEntidade.Email := Edit_Email.Text;
  FEntidade.UFID := GetUFSelecionada;
  FEntidade.Ativo := Check_Ativo.Checked;

  DM.FDConnection1.StartTransaction;
  try
    // salva entidade
    FEntidade.Salvar;

    // insere Ult_NSU
    DM.FDConnection1.ExecSQL(
      'INSERT OR IGNORE INTO distribuicao_dfe (entidade_id, ultimo_nsu) ' +
      'VALUES (?, ?)',
      [FEntidade.ID, '0']
    );

    // certificado
    if FCertCaminho <> '' then
    begin
      InfoCert := TCertificadoService.LerCertificado(FCertCaminho, FCertSenha);

      // valida vínculo
      if SomenteNumeros(InfoCert.Documento) <> FEntidade.Documento then
        raise Exception.CreateFmt(
          'Certificado pertence a %s (%s), diferente do documento informado.',
          [InfoCert.Nome, InfoCert.Documento]
        );

      // valida vencimento
      if InfoCert.Validade < Date then
        raise Exception.Create('Certificado está vencido.');

      Cert := TCertificado.Create;
      try
        Cert.EntidadeID := FEntidade.ID;
        Cert.Caminho := FCertCaminho;
        Cert.Senha := FCertSenha;
        Cert.DataValidade := InfoCert.Validade;
        Cert.NumeroSerie := InfoCert.NumeroSerie;
        Cert.Ativo := True;

        Cert.Salvar;
      finally
        Cert.Free;
      end;
    end;

    DM.FDConnection1.Commit;

    ShowMessage('Cadastro salvo com sucesso!');
    ModalResult := mrOk;

  except
    on E: Exception do
    begin
      DM.FDConnection1.Rollback;

      if Pos('entidade.documento', LowerCase(E.Message)) > 0 then
        ShowMessage('Já existe um cadastro com este documento.')
      else
        ShowMessage('Erro ao salvar: ' + E.Message);
    end;
  end;
end;

{ ================= FORM ================= }

procedure TForm_CadastroEmpresa.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Btn_CancelarClick(Sender);
end;

procedure TForm_CadastroEmpresa.FormCreate(Sender: TObject);
begin
  CarregarUFs;

  Combo_Doc.Items.Clear;
  Combo_Doc.Items.Add('CNPJ');
  Combo_Doc.Items.Add('CPF');

  Label_Certificado.Font.Color := clBlue;
  Label_Certificado.Cursor := crHandPoint;

  FEntidade := TEntidade.Create;
  FEntidade.Limpar;

  Novo;
end;

procedure TForm_CadastroEmpresa.FormDestroy(Sender: TObject);
begin
  FEntidade.Free;
end;

end.
