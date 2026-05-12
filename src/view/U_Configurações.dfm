object Form_Configuracoes: TForm_Configuracoes
  Left = 0
  Top = 0
  Caption = 'Configura'#231#245'es'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 635
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Configura'#231#245'es Globais'
    TabOrder = 0
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 25
    Width = 635
    Height = 233
    ActivePage = TS_Diretorios
    Align = alClient
    TabOrder = 1
    object TS_Geral: TTabSheet
      Caption = 'Geral'
      object Label1: TLabel
        Left = 20
        Top = 19
        Width = 86
        Height = 13
        Caption = 'Ambiente Padr'#227'o:'
      end
      object Label2: TLabel
        Left = 20
        Top = 72
        Width = 40
        Height = 13
        Caption = 'TimeOut'
      end
      object Combo_AmbientePadrao: TComboBox
        Left = 20
        Top = 38
        Width = 213
        Height = 21
        TabOrder = 0
        Text = 'Combo_AmbientePadrao'
        Items.Strings = (
          'Produ'#231#227'o'
          'Homologa'#231#227'o')
      end
      object Edit_Timeout: TEdit
        Left = 20
        Top = 88
        Width = 121
        Height = 21
        TabOrder = 1
        Text = 'Edit_Timeout'
      end
      object Check_LogAtivo: TCheckBox
        Left = 20
        Top = 128
        Width = 97
        Height = 17
        Caption = 'Log Ativo'
        TabOrder = 2
      end
    end
    object TS_Diretorios: TTabSheet
      Caption = 'Diret'#243'rios'
      ImageIndex = 1
      object Label3: TLabel
        Left = 32
        Top = 65
        Width = 106
        Height = 13
        Caption = 'Path Padr'#227'o para XML'
      end
      object Label4: TLabel
        Left = 32
        Top = 114
        Width = 131
        Height = 13
        Caption = 'Path Padr'#227'o Schemas(XSD)'
      end
      object Label7: TLabel
        Left = 32
        Top = 16
        Width = 130
        Height = 13
        Caption = 'Path para a Base de Dados'
      end
      object Edit_PathBaseXML: TEdit
        Left = 32
        Top = 84
        Width = 346
        Height = 21
        TabOrder = 0
        Text = 'Edit_PathBaseXML'
      end
      object Edit_PathSchemas: TEdit
        Left = 32
        Top = 133
        Width = 346
        Height = 21
        TabOrder = 1
        Text = 'Edit_PathSchemas'
      end
      object Button_PathBaseXML: TButton
        Left = 384
        Top = 82
        Width = 97
        Height = 25
        Caption = 'Path XML'
        TabOrder = 2
        OnClick = Button_PathBaseXMLClick
      end
      object Button_PathSchemas: TButton
        Left = 384
        Top = 131
        Width = 97
        Height = 25
        Caption = 'Path Schemas'
        TabOrder = 3
        OnClick = Button_PathSchemasClick
      end
      object Edit_PathDB: TEdit
        Left = 32
        Top = 37
        Width = 346
        Height = 21
        TabOrder = 4
        Text = 'Edit_PathDB'
      end
      object Button_PathDB: TButton
        Left = 384
        Top = 35
        Width = 97
        Height = 25
        Caption = 'Path DB'
        TabOrder = 5
        OnClick = Button_PathDBClick
      end
    end
    object TS_OpenSSL: TTabSheet
      Caption = 'OpenSSL'
      ImageIndex = 2
      object Label5: TLabel
        Left = 24
        Top = 32
        Width = 80
        Height = 13
        Caption = 'Pasta LibSSL DLL'
      end
      object Label6: TLabel
        Left = 24
        Top = 88
        Width = 96
        Height = 13
        Caption = 'Pasta LibCrypto DLL'
      end
      object Edit_LibSSL: TEdit
        Left = 24
        Top = 51
        Width = 313
        Height = 21
        TabOrder = 0
        Text = 'Edit_LibSSL'
      end
      object Edit_LibCrypto: TEdit
        Left = 24
        Top = 107
        Width = 313
        Height = 21
        TabOrder = 1
        Text = 'Edit_LibCrypto'
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 258
    Width = 635
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object Btn_Salvar: TButton
      Left = 136
      Top = 6
      Width = 129
      Height = 25
      Caption = 'Salvar'
      TabOrder = 0
      OnClick = Btn_SalvarClick
    end
    object Btn_Fechar: TButton
      Left = 356
      Top = 6
      Width = 129
      Height = 25
      Caption = 'Fechar'
      TabOrder = 1
      OnClick = Btn_FecharClick
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 164
    Top = 193
  end
end
