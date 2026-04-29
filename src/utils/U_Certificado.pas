unit U_Certificado;

interface

uses
  System.SysUtils, System.Classes, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, U_DM;

type
  TCertificado = class
  private
    FID: Integer;
    FEntidadeID: Integer;
    FCaminho: string;
    FSenha: string;
    FDataAtivacao: TDateTime;
    FDataValidade: TDateTime;
    FNumeroSerie: string;
    FAtivo: Boolean;

  public
    property ID: Integer read FID write FID;
    property EntidadeID: Integer read FEntidadeID write FEntidadeID;
    property Caminho: string read FCaminho write FCaminho;
    property Senha: string read FSenha write FSenha;
    property DataAtivacao: TDateTime read FDataAtivacao write FDataAtivacao;
    property DataValidade: TDateTime read FDataValidade write FDataValidade;
    Property NumeroSerie: string read FNumeroSerie write FNumeroSerie;
    property Ativo: Boolean read FAtivo write FAtivo;

    procedure Limpar;
    procedure CarregarAtivo(EntidadeID: Integer);
    procedure Salvar;
    procedure DesativarOutros;

  end;

implementation

{ TCertificado }

procedure TCertificado.Limpar;
begin
  FID := 0;
  FEntidadeID := 0;
  FCaminho := '';
  FSenha := '';
  FDataAtivacao := 0;
  FDataValidade := 0;
  FAtivo := True;
end;

procedure TCertificado.CarregarAtivo(EntidadeID: Integer);
var
  Q: TFDQuery;
begin
  Limpar;

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DM.FDConnection1;
    Q.SQL.Text :=
      'SELECT * FROM certificado WHERE entidade_id = ? AND ativo = 1 LIMIT 1';
    Q.Params[0].AsInteger := EntidadeID;
    Q.Open;

    if not Q.IsEmpty then
    begin
      FID := Q.FieldByName('id').AsInteger;
      FEntidadeID := Q.FieldByName('entidade_id').AsInteger;
      FCaminho := Q.FieldByName('caminho_pfx').AsString;
      FSenha := Q.FieldByName('senha').AsString;
      FDataAtivacao := Q.FieldByName('data_ativacao').AsDateTime;
      FDataValidade := Q.FieldByName('data_validade').AsDateTime;
      FAtivo := Q.FieldByName('ativo').AsInteger = 1;
    end;

  finally
    Q.Free;
  end;
end;

procedure TCertificado.DesativarOutros;
begin
  DM.FDConnection1.ExecSQL(
    'UPDATE certificado SET ativo = 0 WHERE entidade_id = ?',
    [FEntidadeID]
  );
end;

procedure TCertificado.Salvar;
begin
  if FEntidadeID = 0 then
    raise Exception.Create('Entidade não definida para o certificado');

  DesativarOutros;

  DM.FDConnection1.ExecSQL(
    'INSERT INTO certificado (entidade_id, caminho_pfx, senha, data_ativacao, data_validade, numero_serie, ativo) ' +
    'VALUES (?, ?, ?, ?, ?, ?, ?)',
    [
      FEntidadeID,
      FCaminho,
      FSenha,
      FDataAtivacao,
      FDataValidade,
      FNumeroSerie,
      Ord(FAtivo)
    ]
  );
end;

end.
