unit U_CertificadoRepository;

interface

uses
  System.SysUtils, System.DateUtils , ACBrNFe, ACBrDFeSSL,
  FireDAC.Comp.Client, FireDAC.Stan.Param;



type
  TCertificadoRepository = class
  private
    FConn: TFDCustomConnection;
  public
    constructor Create(AConn: TFDCustomConnection);

    function OnlyNumber(const S:string): string;
    function ImportarPFX(const Caminho, Senha: string): Integer;
    procedure VincularCertificado(CertId, EntidadeId: Integer);
    procedure Ativar(CertId, EntidadeId: Integer);
    procedure Excluir(CertId: Integer);
  end;

implementation

{ TCertificadoRepository }

constructor TCertificadoRepository.Create(AConn: TFDCustomConnection);
begin
  FConn := AConn;
end;

function TCertificadoRepository.OnlyNumber(const S: string): string;
var
  C: Char;
begin
  Result := '';
  for C in S do
    if CharInSet(C,['0'..'9']) then
      Result := Result + C;
end;

function TCertificadoRepository.ImportarPFX(const Caminho, Senha: string): Integer;
var
  Q: TFDQuery;
  SSL: TDFeSSL;
  NumeroSerie, CNPJ: string;
  DataValidade, DataAtivacao: TDate;
  EntidadeId: Integer;
begin
  SSL := TDFeSSL.Create;
  Q := TFDQuery.Create(nil);

  //  Configuração SSL
  SSL.SSLCryptLib := cryOpenSSL;
  SSL.SSLHttpLib := httpOpenSSL;
  SSL.SSLXmlSignLib := xsLibXml2;

  try
    SSL.ArquivoPFX := Caminho;
    SSL.Senha := Senha;
    SSL.CarregarCertificado;

    //  Dados do certificado
    NumeroSerie := SSL.DadosCertificado.NumeroSerie;
    DataValidade := SSL.DadosCertificado.DataVenc;
    DataAtivacao := SSL.DadosCertificado.DataInicioValidade;

    //  CNPJ (sem máscara)
    CNPJ := OnlyNumber(SSL.DadosCertificado.CNPJ);

    Q.Connection := FConn;

    //   Verifica duplicidade
    Q.SQL.Text := 'SELECT id FROM certificado WHERE numero_serie = :serie';
    Q.ParamByName('serie').AsString := NumeroSerie;
    Q.Open;

    if not Q.IsEmpty then
      Exit(Q.FieldByName('id').AsInteger);

    Q.Close;

    //  Buscar entidade pelo CNPJ
    EntidadeId := 0;

    Q.SQL.Text := 'SELECT id FROM entidade WHERE documento = :cnpj';
    Q.ParamByName('cnpj').AsString := CNPJ;
    Q.Open;

    if not Q.IsEmpty then
      EntidadeId := Q.FieldByName('id').AsInteger;

    Q.Close;

    //  Inserir certificado
    Q.SQL.Text :=
      'INSERT INTO certificado ' +
      '(numero_serie, data_ativacao, data_validade, ativo, caminho_pfx, senha, entidade_id) ' +
      'VALUES (:numero_serie, :data_ativacao, :data_validade, 0, :caminho_pfx, :senha, :entidade_id)';

    Q.ParamByName('numero_serie').AsString := NumeroSerie;
    Q.ParamByName('data_ativacao').AsDate := DataAtivacao;
    Q.ParamByName('data_validade').AsDate := DataValidade;
    Q.ParamByName('caminho_pfx').AsString := Caminho;
    Q.ParamByName('senha').AsString := Senha;
    Q.ParamByName('entidade_id').AsInteger := EntidadeId;

    Q.ExecSQL;

    //  Recupera ID (SQLite)
    Q.SQL.Text := 'SELECT last_insert_rowid() AS id';
    Q.Open;

    Result := Q.FieldByName('id').AsInteger;

    // Ativa automaticamente se vinculou
    if EntidadeId <> 0 then
      Ativar(Result, EntidadeId);

  finally
    Q.Free;
    SSL.Free;
  end;
end;

procedure TCertificadoRepository.VincularCertificado(CertId, EntidadeId: Integer);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;

    Q.SQL.Text :=
      'UPDATE certificado SET entidade_id = :entidade_id WHERE id = :id';

    Q.ParamByName('entidade_id').AsInteger := EntidadeId;
    Q.ParamByName('id').AsInteger := CertId;

    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TCertificadoRepository.Ativar(CertId, EntidadeId: Integer);
var
  Q: TFDQuery;
begin
  if EntidadeId = 0 then
    raise Exception.Create('Certificado não está vinculado a uma entidade.');

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;

    FConn.StartTransaction;
    try
      // Desativa todos da entidade
      Q.SQL.Text :=
        'UPDATE certificado SET ativo = 0 WHERE entidade_id = :entidade_id';
      Q.ParamByName('entidade_id').AsInteger := EntidadeId;
      Q.ExecSQL;

      // Ativa o selecionado
      Q.SQL.Text :=
        'UPDATE certificado SET ativo = 1 WHERE id = :id';
      Q.ParamByName('id').AsInteger := CertId;
      Q.ExecSQL;

      FConn.Commit;
    except
      FConn.Rollback;
      raise;
    end;

  finally
    Q.Free;
  end;
end;

procedure TCertificadoRepository.Excluir(CertId: Integer);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;

    Q.SQL.Text := 'DELETE FROM certificado WHERE id = :id';
    Q.ParamByName('id').AsInteger := CertId;

    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
