object DM: TDM
  OldCreateOrder = False
  OnDestroy = DataModuleDestroy
  Height = 332
  Width = 455
  object FDConnection1: TFDConnection
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
