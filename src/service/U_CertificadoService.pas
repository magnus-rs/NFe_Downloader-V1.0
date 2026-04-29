unit U_CertificadoService;

interface

uses
  System.SysUtils, System.DateUtils , ACBrNFe, ACBrDFeSSL;

type
  TInfoCertificado = record
    Validade: TDateTime;
    Ativacao: TDateTime;
    Documento: string; // CPF ou CNPJ
    Nome: string;
    NumeroSerie: string;
  end;
  TCertificadoService = class
  public
    class function LerCertificado(const Caminho, Senha: string): TInfoCertificado;
  end;

implementation


{ TCertificadoService }
class function TCertificadoService.LerCertificado(const Caminho, Senha: string): TInfoCertificado;
var
  ACBr: TACBrNFe;
begin
  if not FileExists(Caminho) then
    raise Exception.Create('Arquivo de certificado não encontrado.');
  if Trim(Senha) = '' then
    raise Exception.Create('Senha do certificado não informada.');
  ACBr := TACBrNFe.Create(nil);
  try
    //  Configuração SSL
    ACBr.Configuracoes.Geral.SSLLib := libOpenSSL;
    ACBr.Configuracoes.Geral.SSLCryptLib := cryOpenSSL;
    ACBr.Configuracoes.Geral.SSLHttpLib := httpOpenSSL;
    ACBr.Configuracoes.Geral.SSLXmlSignLib := xsLibXml2;
    //  Certificado
    ACBr.Configuracoes.Certificados.ArquivoPFX := Caminho;
    ACBr.Configuracoes.Certificados.Senha := Senha;
    //  Carregar certificado
    ACBr.SSL.CarregarCertificado;
    //  Preencher estrutura
    Result.Validade := DateOf(ACBr.SSL.CertDataVenc); // sem horário
    Result.Ativacao := DateOf(ACBr.SSL.CertDataVenc); // sem horário
    Result.Documento := ACBr.SSL.CertCNPJ;
    Result.Nome := ACBr.SSL.CertRazaoSocial;
    Result.NumeroSerie := ACBr.SSL.CertNumeroSerie;
    //  validação básica
    if Result.Documento = '' then
      raise Exception.Create('Não foi possível obter CPF/CNPJ do certificado.');
  finally
    ACBr.Free;
  end;
end;
end.
