unit U_Config;

interface

uses
  System.SysUtils;

function GetSQLPath: string;
function SolicitarCaminhoDB: string;

implementation

uses
  Vcl.Dialogs;

function SolicitarCaminhoDB: string;
var
  OpenDialog: TOpenDialog;
begin
  Result := '';

  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Filter :=
      'SQLite DB (*.db)|*.db';

    OpenDialog.Title :=
      'Selecione o banco de dados';

    if OpenDialog.Execute then
      Result := OpenDialog.FileName;

  finally
    OpenDialog.Free;
  end;
end;

function GetSQLPath: string;
begin
  Result :=
    IncludeTrailingPathDelimiter(
      ExtractFileDir(
        ExtractFileDir(ParamStr(0))
      )
    ) + 'sql\init.sql';
end;

end.
