unit U_CadCertificado;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.DateUtils, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.DBGrids,
  U_CertificadoRepository;

type
  TForm_CadCertificado = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Panel2: TPanel;
    Label1: TLabel;
    Btn_Buscar: TButton;
    Btn_Atualizar: TButton;
    Btn_Vincular: TButton;
    Btn_Cancelar: TButton;
    Btn_Excluir: TButton;
    qryCertificados: TFDQuery;
    dsCertificados: TDataSource;
    DBGrid1: TDBGrid;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Btn_AtualizarClick(Sender: TObject);
    procedure Btn_BuscarClick(Sender: TObject);
    procedure Btn_VincularClick(Sender: TObject);
    procedure Btn_ExcluirClick(Sender: TObject);
    procedure Btn_CancelarClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
  private
    FRepo: TCertificadoRepository;
    procedure CarregarCertificados;
    procedure ConfigurarGrid;
  public
  end;

var
  Form_CadCertificado: TForm_CadCertificado;

implementation

{$R *.dfm}

uses U_DM;

{ ========================= INIT ========================= }

procedure TForm_CadCertificado.FormCreate(Sender: TObject);
begin
  qryCertificados.Connection := DM.FDConnection1;

  FRepo := TCertificadoRepository.Create(qryCertificados.Connection);

  DBGrid1.Options := DBGrid1.Options - [dgEditing];

  ConfigurarGrid;
  CarregarCertificados;
end;

procedure TForm_CadCertificado.FormDestroy(Sender: TObject);
begin
  FRepo.Free;
end;

{ ========================= LOAD ========================= }

procedure TForm_CadCertificado.CarregarCertificados;
begin
qryCertificados.Active := False;
qryCertificados.Active := True;
end;

{ ========================= BUTTONS ========================= }

procedure TForm_CadCertificado.Btn_AtualizarClick(Sender: TObject);
begin
  CarregarCertificados;
end;

procedure TForm_CadCertificado.Btn_BuscarClick(Sender: TObject);
var
  Caminho, Senha: string;
begin
  if not OpenDialog1.Execute then Exit;

  Caminho := OpenDialog1.FileName;
  Senha := InputBox('Certificado', 'Digite a senha do certificado:', '');

  if Senha = '' then Exit;

  try
    FRepo.ImportarPFX(Caminho, Senha);
    ShowMessage('Certificado importado com sucesso!');
    CarregarCertificados;
  except
    on E: Exception do
      ShowMessage('Erro ao importar: ' + E.Message);
  end;
end;

procedure TForm_CadCertificado.Btn_VincularClick(Sender: TObject);
var
  CertId, EntidadeId: Integer;
begin
  if qryCertificados.IsEmpty then Exit;

  CertId := qryCertificados.FieldByName('id').AsInteger;

  EntidadeId := StrToIntDef(
    InputBox('Vincular', 'Informe o ID da Entidade:', '0'),
    0
  );

  if EntidadeId = 0 then Exit;

  try
    FRepo.VincularCertificado(CertId, EntidadeId);
    ShowMessage('Certificado vinculado!');
    CarregarCertificados;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TForm_CadCertificado.Btn_ExcluirClick(Sender: TObject);
var
  Id: Integer;
begin
  if qryCertificados.IsEmpty then Exit;

  Id := qryCertificados.FieldByName('id').AsInteger;

  if MessageDlg('Deseja excluir o certificado?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    try
      FRepo.Excluir(Id);
      ShowMessage('Certificado excluído!');
      CarregarCertificados;
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  end;
end;

procedure TForm_CadCertificado.Btn_CancelarClick(Sender: TObject);
begin
  Close;
end;

{ ========================= GRID ========================= }

procedure TForm_CadCertificado.DBGrid1DblClick(Sender: TObject);
var
  Id, EntidadeId: Integer;
begin
  if qryCertificados.IsEmpty then Exit;

  Id := qryCertificados.FieldByName('id').AsInteger;
  EntidadeId := qryCertificados.FieldByName('entidade_id').AsInteger;

  try
    FRepo.Ativar(Id, EntidadeId);
    CarregarCertificados;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TForm_CadCertificado.ConfigurarGrid;
begin
  DBGrid1.Columns.Clear;

  with DBGrid1.Columns.Add do
  begin
    FieldName := 'numero_serie';
    Title.Caption := 'Serial';
    Width := 110;
  end;

  with DBGrid1.Columns.Add do
  begin
    FieldName := 'razao_social';
    Title.Caption := 'Empresa';
    Width := 250;
  end;

  with DBGrid1.Columns.Add do
  begin
    FieldName := 'documento';
    Title.Caption := 'Documento';
    Width := 110;
  end;

  with DBGrid1.Columns.Add do
  begin
    FieldName := 'data_validade';
    Title.Caption := 'Validade';
    Width := 85;
  end;

  with DBGrid1.Columns.Add do
  begin
    FieldName := 'ativo_desc';
    Title.Caption := 'Ativo';
    Width := 55;
  end;
end;

end.
