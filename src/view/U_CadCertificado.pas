unit U_CadCertificado;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids;

type
  TForm_CadCertificado = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Panel2: TPanel;
    StringGrid1: TStringGrid;
    Label1: TLabel;
    Btn_Buscar: TButton;
    Btn_Atualizar: TButton;
    Btn_Vincular: TButton;
    Btn_Cancelar: TButton;
    procedure Btn_CancelarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_CadCertificado: TForm_CadCertificado;

implementation

{$R *.dfm}

procedure TForm_CadCertificado.Btn_CancelarClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TForm_CadCertificado.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   Btn_CancelarClick(Sender);
end;

end.
