unit U_Entidade;

interface

uses
  System.SysUtils, System.Classes, Data.DB, FireDAC.Stan.Param, FireDAC.Comp.Client, U_DM;

type
  TTipoDocumento = (tdCNPJ, tdCPF);

  TEntidade = class
  private
    FID: Integer;
    FTipo: TTipoDocumento;
    FDocumento: string;
    FRazaoSocial: string;
    FEmail: string;
    FUFID: Integer;
    FAtivo: Boolean;

  public
    property ID: Integer read FID write FID;
    property Tipo: TTipoDocumento read FTipo write FTipo;
    property Documento: string read FDocumento write FDocumento;
    property RazaoSocial: string read FRazaoSocial write FRazaoSocial;
    property Email: string read FEmail write FEmail;
    property UFID: Integer read FUFID write FUFID;
    property Ativo: Boolean read FAtivo write FAtivo;

    procedure Limpar;
    procedure Carregar(ID: Integer);
    procedure Salvar;
    procedure Excluir;

    function OnlyNumber(const S: string): string;
    function TipoToInt: Integer;
    procedure IntToTipo(Value: Integer);
  end;

implementation
{ TEntidade }

procedure TEntidade.Limpar;
begin
  FID := 0;
  FDocumento := '';
  FRazaoSocial := '';
  FEmail := '';
  FUFID := 0;
  FAtivo := True;
  FTipo := tdCNPJ;
end;

function TEntidade.TipoToInt: Integer;
begin
  case FTipo of
    tdCNPJ: Result := 1;
    tdCPF: Result := 2;
  else
    Result := 1;
  end;
end;

procedure TEntidade.IntToTipo(Value: Integer);
begin
  case Value of
    1: FTipo := tdCNPJ;
    2: FTipo := tdCPF;
  else
    FTipo := tdCNPJ;
  end;
end;

procedure TEntidade.Carregar(ID: Integer);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := DM.FDConnection1;
    Q.SQL.Text := 'SELECT * FROM entidade WHERE id = ?';
    Q.Params[0].AsInteger := ID;
    Q.Open;

    if not Q.IsEmpty then
    begin
      FID := Q.FieldByName('id').AsInteger;
      FDocumento := Q.FieldByName('documento').AsString;
      FRazaoSocial := Q.FieldByName('razao_social').AsString;
      FEmail := Q.FieldByName('email').AsString;
      FUFID := Q.FieldByName('uf_id').AsInteger;
      FAtivo := Q.FieldByName('ativo').AsInteger = 1;

      IntToTipo(Q.FieldByName('tipo').AsInteger);
    end;

  finally
    Q.Free;
  end;
end;

function TEntidade.OnlyNumber(const S: string): string;
var
  C: Char;
begin
  Result := '';
  for C in S do
    if CharInSet(C,['0'..'9']) then
      Result := Result + C;

end;

procedure TEntidade.Salvar;
begin
  if FID = 0 then
  begin
    DM.FDConnection1.ExecSQL(
      'INSERT INTO entidade (tipo, documento, razao_social, email, uf_id, ativo) ' +
      'VALUES (?, ?, ?, ?, ?, ?)',
      [
        TipoToInt,
        OnlyNumber(FDocumento),
        FRazaoSocial,
        FEmail,
        FUFID,
        Ord(FAtivo)
      ]
    );

    // pegar ID gerado
    FID := DM.FDConnection1.ExecSQLScalar('SELECT last_insert_rowid()');
  end
  else
  begin
    DM.FDConnection1.ExecSQL(
      'UPDATE entidade SET tipo = ?, documento = ?, razao_social = ?, email = ?, uf_id = ?, ativo = ? ' +
      'WHERE id = ?',
      [
        TipoToInt,
        OnlyNumber(FDocumento),
        FRazaoSocial,
        FEmail,
        FUFID,
        Ord(FAtivo),
        FID
      ]
    );
  end;
end;

procedure TEntidade.Excluir;
begin
  if FID = 0 then Exit;

  DM.FDConnection1.ExecSQL(
    'DELETE FROM entidade WHERE id = ?',
    [FID]
  );
end;

end.