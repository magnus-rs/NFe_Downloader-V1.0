unit U_CadCertificado;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  System.DateUtils, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Grids,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.DBGrids;

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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form_CadCertificado: TForm_CadCertificado;

implementation

{$R *.dfm}

end.
