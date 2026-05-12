unit U_ConfigService;

interface

uses
  System.SysUtils,
  System.IniFiles,
  System.IOUtils,
  FireDAC.Comp.Client,
  ACBrNFe,
  ACBrDFeSSL,
  pcnConversao;

type
  TConfig = record
    // GERAL
    AmbientePadrao: Integer;
    Timeout: Integer;
    Log: Boolean;

    // PATHS
    PathBaseXML: string;
    PathSchemas: string;

    // OPENSSL
    LibSSL: string;
    LibCrypto: string;

    // BANCO
    PathDB: string;
  end;

  TConfigService = class
  private
    class function ResolverPath(const Caminho: string): string;
  public
    class var Config: TConfig;

    // PATHS
    class function GetIniPath: string;

    // LEITURA
    class function LerString(
      const Section, Ident, Default: string
    ): string;

    class function LerInteger(
      const Section, Ident: string;
      Default: Integer
    ): Integer;

    class function LerBoolean(
      const Section, Ident: string;
      Default: Boolean
    ): Boolean;

    // ESCRITA
    class procedure GravarString(
      const Section, Ident, Valor: string
    );

    class procedure GravarInteger(
      const Section, Ident: string;
      Valor: Integer
    );

    class procedure GravarBoolean(
      const Section, Ident: string;
      Valor: Boolean
    );

    // CONFIG
    class procedure Carregar;
    class procedure Salvar;

    // HELPERS
    class function CaminhoDB: string;
    class function CaminhoBaseXML: string;

    // APLICAÇÕES
    class procedure AplicarBanco(
      FDConnection: TFDConnection
    );

    class procedure AplicarACBr(
      ACBr: TACBrNFe
    );
  end;

implementation

{ TConfigService }

class function TConfigService.GetIniPath: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'config.ini';
end;

class function TConfigService.ResolverPath(
  const Caminho: string
): string;
begin
  if Trim(Caminho) = '' then
    Exit('');

  if ExtractFileDrive(Caminho) = '' then
    Result := TPath.Combine(
      ExtractFilePath(ParamStr(0)),
      Caminho
    )
  else
    Result := Caminho;
end;

class function TConfigService.LerString(
  const Section, Ident, Default: string
): string;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetIniPath);
  try
    Result := Ini.ReadString(
      Section,
      Ident,
      Default
    );
  finally
    Ini.Free;
  end;
end;

class function TConfigService.LerInteger(
  const Section, Ident: string;
  Default: Integer
): Integer;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetIniPath);
  try
    Result := Ini.ReadInteger(
      Section,
      Ident,
      Default
    );
  finally
    Ini.Free;
  end;
end;

class function TConfigService.LerBoolean(
  const Section, Ident: string;
  Default: Boolean
): Boolean;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetIniPath);
  try
    Result := Ini.ReadBool(
      Section,
      Ident,
      Default
    );
  finally
    Ini.Free;
  end;
end;

class procedure TConfigService.GravarString(
  const Section, Ident, Valor: string
);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetIniPath);
  try
    Ini.WriteString(
      Section,
      Ident,
      Valor
    );
  finally
    Ini.Free;
  end;
end;

class procedure TConfigService.GravarInteger(
  const Section, Ident: string;
  Valor: Integer
);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetIniPath);
  try
    Ini.WriteInteger(
      Section,
      Ident,
      Valor
    );
  finally
    Ini.Free;
  end;
end;

class procedure TConfigService.GravarBoolean(
  const Section, Ident: string;
  Valor: Boolean
);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetIniPath);
  try
    Ini.WriteBool(
      Section,
      Ident,
      Valor
    );
  finally
    Ini.Free;
  end;
end;

class procedure TConfigService.Carregar;
begin
  // GERAL
  Config.AmbientePadrao :=
    LerInteger('GERAL', 'AmbientePadrao', 2);

  Config.Timeout :=
    LerInteger('GERAL', 'Timeout', 30000);

  Config.Log :=
    LerBoolean('GERAL', 'Log', True);

  // PATHS
  Config.PathBaseXML :=
    LerString('PATHS', 'BaseXML', 'dados\xml\');

  Config.PathSchemas :=
    LerString('PATHS', 'Schemas', '');

  // OPENSSL
  Config.LibSSL :=
    LerString('OPENSSL', 'LibSSL', '');

  Config.LibCrypto :=
    LerString('OPENSSL', 'LibCrypto', '');

  // BANCO
  Config.PathDB :=
    LerString('BANCO', 'PathDB', 'dados\nfe.db');
end;

class procedure TConfigService.Salvar;
begin
  // GERAL
  GravarInteger(
    'GERAL',
    'AmbientePadrao',
    Config.AmbientePadrao
  );

  GravarInteger(
    'GERAL',
    'Timeout',
    Config.Timeout
  );

  GravarBoolean(
    'GERAL',
    'Log',
    Config.Log
  );

  // PATHS
  GravarString(
    'PATHS',
    'BaseXML',
    Config.PathBaseXML
  );

  GravarString(
    'PATHS',
    'Schemas',
    Config.PathSchemas
  );

  // OPENSSL
  GravarString(
    'OPENSSL',
    'LibSSL',
    Config.LibSSL
  );

  GravarString(
    'OPENSSL',
    'LibCrypto',
    Config.LibCrypto
  );

  // BANCO
  GravarString(
    'BANCO',
    'PathDB',
    Config.PathDB
  );
end;

class function TConfigService.CaminhoDB: string;
begin
  Result := ResolverPath(Config.PathDB);
end;

class function TConfigService.CaminhoBaseXML: string;
begin
  Result := IncludeTrailingPathDelimiter(
    ResolverPath(Config.PathBaseXML)
  );
end;

class procedure TConfigService.AplicarBanco(
  FDConnection: TFDConnection
);
var
  DBPath: string;
begin
  DBPath := CaminhoDB;

  ForceDirectories(
    ExtractFilePath(DBPath)
  );

  if FDConnection.Connected then
    FDConnection.Connected := False;

  FDConnection.Params.Database := DBPath;
  FDConnection.Connected := True;
end;

class procedure TConfigService.AplicarACBr(
  ACBr: TACBrNFe
);
begin
  // SCHEMAS
  ACBr.Configuracoes.Arquivos.PathSchemas :=
    ResolverPath(Config.PathSchemas);

  // TIMEOUT
  ACBr.Configuracoes.WebServices.TimeOut :=
    Config.Timeout;

  // OPENSSL
  ACBr.Configuracoes.Geral.SSLLib :=
    libOpenSSL;

  ACBr.Configuracoes.Geral.SSLCryptLib :=
    cryOpenSSL;

  ACBr.Configuracoes.Geral.SSLHttpLib :=
    httpOpenSSL;

  ACBr.Configuracoes.Geral.SSLXmlSignLib :=
    xsLibXml2;

  // AMBIENTE
  case Config.AmbientePadrao of
    1:
      ACBr.Configuracoes.WebServices.Ambiente :=
        taProducao;

    2:
      ACBr.Configuracoes.WebServices.Ambiente :=
        taHomologacao;

  else
    ACBr.Configuracoes.WebServices.Ambiente :=
      taHomologacao;
  end;
end;

end.
