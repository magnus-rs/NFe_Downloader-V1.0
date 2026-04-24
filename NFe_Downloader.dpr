program NFe_Downloader;
uses
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  U_Principal in 'src\view\U_Principal.pas' {Form_Principal},
  U_DM in 'src\data\U_DM.pas' {DM: TDataModule},
  U_Config in 'src\utils\U_Config.pas';

{$R *.res}
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
    try
    DM.Conectar;
  except
    on E: Exception do
    begin
      ShowMessage('Erro ao conectar banco: ' + E.Message);
      Halt;
    end;
  end;

  Application.CreateForm(TForm_Principal, Form_Principal);
  Application.Run;

end.
