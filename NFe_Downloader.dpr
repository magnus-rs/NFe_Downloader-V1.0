program NFe_Downloader;
uses
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  U_Principal in 'src\view\U_Principal.pas' {Form_Principal},
  U_DM in 'src\data\U_DM.pas' {DM: TDataModule},
  U_Config in 'src\utils\U_Config.pas',
  U_CadEmpresa in 'src\view\U_CadEmpresa.pas' {Form_CadastroEmpresa},
  U_CertificadoService in 'src\service\U_CertificadoService.pas',
  U_Entidade in 'src\utils\U_Entidade.pas',
  U_Certificado in 'src\utils\U_Certificado.pas',
  U_CadCertificado in 'src\view\U_CadCertificado.pas' {Form_CadCertificado};

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
  Application.CreateForm(TForm_CadastroEmpresa, Form_CadastroEmpresa);
  Application.CreateForm(TForm_CadCertificado, Form_CadCertificado);
  Application.Run;

end.
