unit U_DM;

interface

uses
  System.SysUtils, System.Classes, Vcl.Dialogs, Vcl.Controls, System.UITypes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Data.DB, FireDAC.Comp.Client,
  FireDAC.Comp.ScriptCommands, FireDAC.Stan.Util, FireDAC.Comp.UI,
  FireDAC.Comp.Script;

type
  TDM = class(TDataModule)
    FDConnection1: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    FDScript1: TFDScript;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    function GetDBPath: string;
    procedure Conectar;
    procedure Desconectar;
    procedure CriarBanco(const Path: string);
    procedure ExecutarScriptSQL(const FileName: string);
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses U_Config;

{$R *.dfm}

function TDM.GetDBPath: string;
begin
  Result :=
    IncludeTrailingPathDelimiter(
      ExtractFileDir(ExtractFileDir(ParamStr(0)))
    ) + 'dados\nfe.db';
end;

procedure TDM.Conectar;
var
  DBPath: string;
begin
  FDConnection1.DriverName := 'SQLite';

  DBPath := GetDatabasePathFromINI;

  // 1. Se não tem caminho → pedir
  if DBPath = '' then
  begin
    DBPath := SolicitarCaminhoDB;

    if DBPath = '' then
      raise Exception.Create('Banco de dados não informado.');

    SaveDatabasePathToINI(DBPath);
  end;

  // 2. Se caminho existe mas arquivo não → perguntar se cria
  if not FileExists(DBPath) then
  begin
    if MessageDlg('Banco de dados não encontrado. Deseja criar um novo?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      CriarBanco(DBPath);
    end
    else
    begin
      // usuário pode escolher outro
      DBPath := SolicitarCaminhoDB;

      if (DBPath = '') or (not FileExists(DBPath)) then
        raise Exception.Create('Banco de dados inválido.');

      SaveDatabasePathToINI(DBPath);
    end;
  end;

  // 3. Conectar
  FDConnection1.Params.Database := DBPath;
  FDConnection1.Connected := True;
end;

procedure TDM.CriarBanco(const Path: string);
begin
  ForceDirectories(ExtractFilePath(Path));

  FDConnection1.Params.Database := Path;
  FDConnection1.Connected := True;

  ExecutarScriptSQL(GetSQLPath);
  FDConnection1.Connected := False;
end;


procedure TDM.DataModuleDestroy(Sender: TObject);
begin
   Desconectar;
end;

procedure TDM.Desconectar;
begin
  if FDConnection1.Connected then
    FDConnection1.Connected := False;
end;

procedure TDM.ExecutarScriptSQL(const FileName: string);
var
  SQLText: TStringList;
begin
  if not FileExists(FileName) then
    raise Exception.Create('Arquivo SQL não encontrado: ' + FileName);

  FDScript1.Connection := FDConnection1;

  SQLText := TStringList.Create;
  try
    SQLText.LoadFromFile(FileName, TEncoding.UTF8); // força UTF-8

    FDScript1.SQLScripts.Clear;
    FDScript1.SQLScripts.Add.SQL.Text := SQLText.Text;

  finally
    SQLText.Free;
  end;

  FDConnection1.StartTransaction;
  try
    FDScript1.ExecuteAll;
    FDConnection1.Commit;
  except
    FDConnection1.Rollback;
    raise;
  end;
end;


end.

