unit U_Config;

interface

uses
  System.SysUtils;

function GetINIPath: string;
function GetDatabasePathFromINI: string;
procedure SaveDatabasePathToINI(const Path: string);
function SolicitarCaminhoDB: string;

implementation

uses
  System.IniFiles,
  Vcl.Dialogs;

function GetINIPath: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'config.ini';
end;

function GetDatabasePathFromINI: string;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetINIPath);
  try
    Result := Ini.ReadString('Database', 'Path', '');
  finally
    Ini.Free;
  end;
end;

procedure SaveDatabasePathToINI(const Path: string);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetINIPath);
  try
    Ini.WriteString('Database', 'Path', Path);
  finally
    Ini.Free;
  end;
end;

function SolicitarCaminhoDB: string;
var
  OpenDialog: TOpenDialog;
begin
  Result := '';

  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Filter := 'SQLite DB (*.db)|*.db';
    OpenDialog.Title := 'Selecione o banco de dados';

    if OpenDialog.Execute then
      Result := OpenDialog.FileName;
  finally
    OpenDialog.Free;
  end;
end;

end.

