object DM: TDM
  OldCreateOrder = False
  OnDestroy = DataModuleDestroy
  Height = 332
  Width = 455
  object FDConnection1: TFDConnection
    Params.Strings = (
      'CharacterSet=UTF-8'
      'DriverID=SQLite'
      'Database=C:\dev.pascal\GITHUB\NFe_Downloader-V1.0\dados\nfe.db')
    LoginPrompt = False
    Left = 104
    Top = 96
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 232
    Top = 97
  end
  object FDScript1: TFDScript
    SQLScripts = <>
    Connection = FDConnection1
    ScriptOptions.CharacterSet = 'UTF8'
    Params = <>
    Macros = <>
    Left = 104
    Top = 176
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 224
    Top = 176
  end
end
