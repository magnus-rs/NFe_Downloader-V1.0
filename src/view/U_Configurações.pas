unit U_Configurações;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IOUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  FileCtrl;

type
  TForm_Configuracoes = class(TForm)
    Panel1: TPanel;
    PageControl1: TPageControl;
    Panel2: TPanel;

    TS_Geral: TTabSheet;
    TS_Diretorios: TTabSheet;
    TS_OpenSSL: TTabSheet;

    Combo_AmbientePadrao: TComboBox;
    Label1: TLabel;

    Edit_Timeout: TEdit;
    Label2: TLabel;

    Check_LogAtivo: TCheckBox;

    Label3: TLabel;
    Edit_PathBaseXML: TEdit;
    Button_PathBaseXML: TButton;

    Label4: TLabel;
    Edit_PathSchemas: TEdit;
    Button_PathSchemas: TButton;

    Label5: TLabel;
    Edit_LibSSL: TEdit;

    Label6: TLabel;
    Edit_LibCrypto: TEdit;

    OpenDialog1: TOpenDialog;



    Btn_Salvar: TButton;
    Btn_Fechar: TButton;
    Label7: TLabel;
    Edit_PathDB: TEdit;
    Button_PathDB: TButton;


    procedure FormShow(Sender: TObject);

    procedure Btn_SalvarClick(Sender: TObject);
    procedure Btn_FecharClick(Sender: TObject);

    procedure Button_PathBaseXMLClick(Sender: TObject);
    procedure Button_PathSchemasClick(Sender: TObject);
    procedure Button_PathDBClick(Sender: TObject);

  private
    procedure CarregarConfiguracoes;
    procedure SalvarConfiguracoes;
  public

  end;

var
  Form_Configuracoes: TForm_Configuracoes;

implementation

{$R *.dfm}

uses
  U_ConfigService;

{ TForm_Configuracoes }

procedure TForm_Configuracoes.FormShow(Sender: TObject);
begin
  CarregarConfiguracoes;
end;

procedure TForm_Configuracoes.CarregarConfiguracoes;
begin
  TConfigService.Carregar;

  // Ambiente
  case TConfigService.Config.AmbientePadrao of
    1: Combo_AmbientePadrao.ItemIndex := 0; // Produção
    2: Combo_AmbientePadrao.ItemIndex := 1; // Homologação
  else
    Combo_AmbientePadrao.ItemIndex := 1;
  end;

  // Geral
  Edit_Timeout.Text :=
    IntToStr(TConfigService.Config.Timeout);

  Check_LogAtivo.Checked :=
    TConfigService.Config.Log;

  // Diretórios
  Edit_PathBaseXML.Text :=
    TConfigService.Config.PathBaseXML;

  Edit_PathSchemas.Text :=
    TConfigService.Config.PathSchemas;

  Edit_PathDB.Text :=
    TConfigService.Config.PathDB;

  // OpenSSL
  Edit_LibSSL.Text :=
    TConfigService.Config.LibSSL;

  Edit_LibCrypto.Text :=
    TConfigService.Config.LibCrypto;
end;

procedure TForm_Configuracoes.SalvarConfiguracoes;
begin
  // Ambiente
  case Combo_AmbientePadrao.ItemIndex of
    0: TConfigService.Config.AmbientePadrao := 1;
    1: TConfigService.Config.AmbientePadrao := 2;
  else
    TConfigService.Config.AmbientePadrao := 2;
  end;

  // Geral
  TConfigService.Config.Timeout :=
    StrToIntDef(Edit_Timeout.Text, 30000);

  TConfigService.Config.Log :=
    Check_LogAtivo.Checked;

  // Diretórios
  TConfigService.Config.PathBaseXML :=
    Trim(Edit_PathBaseXML.Text);

  TConfigService.Config.PathSchemas :=
    Trim(Edit_PathSchemas.Text);

  TConfigService.Config.PathDB :=
    Trim(Edit_PathDB.Text);

  // OpenSSL
  TConfigService.Config.LibSSL :=
    Trim(Edit_LibSSL.Text);

  TConfigService.Config.LibCrypto :=
    Trim(Edit_LibCrypto.Text);

  // Salvar INI
  TConfigService.Salvar;
end;

procedure TForm_Configuracoes.Btn_SalvarClick(Sender: TObject);
begin
  try
    SalvarConfiguracoes;

    ShowMessage('Configurações salvas com sucesso.');

    ModalResult := mrOk;

  except
    on E: Exception do
      ShowMessage('Erro ao salvar configurações: ' + E.Message);
  end;
end;

procedure TForm_Configuracoes.Btn_FecharClick(Sender: TObject);
begin
  Close;
end;

procedure TForm_Configuracoes.Button_PathBaseXMLClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := Edit_PathBaseXML.Text;

  if SelectDirectory('Selecione a pasta XML', '', Dir) then
    Edit_PathBaseXML.Text :=
      IncludeTrailingPathDelimiter(Dir);
end;

procedure TForm_Configuracoes.Button_PathDBClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := Edit_PathDB.Text;

  if SelectDirectory('Selecione a pasta do Banco de Dados', '', Dir) then
    Edit_PathDB.Text :=
      IncludeTrailingPathDelimiter(Dir);
end;

procedure TForm_Configuracoes.Button_PathSchemasClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := Edit_PathSchemas.Text;

  if SelectDirectory('Selecione a pasta Schemas', '', Dir) then
    Edit_PathSchemas.Text :=
      IncludeTrailingPathDelimiter(Dir);
end;

end.
