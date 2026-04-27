object Form_CadCertificado: TForm_CadCertificado
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Base de Cadastros'
  ClientHeight = 299
  ClientWidth = 689
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 689
    Height = 25
    Align = alTop
    Caption = 'Certificados Importados'
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 31
    Width = 674
    Height = 202
    Caption = '  Selecione um Certificado Digital  '
    TabOrder = 1
    object Label1: TLabel
      Left = 7
      Top = 176
      Width = 246
      Height = 13
      Caption = 'Todos os certificados importados s'#227'o exibidos aqui.'
    end
    object Panel2: TPanel
      Left = 3
      Top = 24
      Width = 668
      Height = 143
      BevelOuter = bvLowered
      TabOrder = 0
      object DBGrid1: TDBGrid
        Left = 1
        Top = 1
        Width = 666
        Height = 141
        Align = alClient
        DataSource = dsCertificados
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
  end
  object Btn_Buscar: TButton
    Left = 8
    Top = 248
    Width = 106
    Height = 25
    Caption = 'Buscar Certificado'
    TabOrder = 2
  end
  object Btn_Atualizar: TButton
    Left = 232
    Top = 248
    Width = 106
    Height = 25
    Caption = 'Atualizar Lista'
    TabOrder = 3
  end
  object Btn_Vincular: TButton
    Left = 368
    Top = 248
    Width = 233
    Height = 25
    Caption = 'Vincular certificado a uma empresa'
    TabOrder = 4
  end
  object Btn_Cancelar: TButton
    Left = 607
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 5
  end
  object Btn_Excluir: TButton
    Left = 120
    Top = 248
    Width = 106
    Height = 25
    Caption = 'Excluir Certificado'
    TabOrder = 6
  end
  object qryCertificados: TFDQuery
    Left = 451
    Top = 71
  end
  object dsCertificados: TDataSource
    DataSet = qryCertificados
    Left = 451
    Top = 119
  end
end
