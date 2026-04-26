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
  OnClose = FormClose
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
    ExplicitWidth = 492
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
      object StringGrid1: TStringGrid
        Left = 1
        Top = 1
        Width = 666
        Height = 141
        Align = alClient
        BorderStyle = bsNone
        DefaultRowHeight = 16
        RowCount = 2
        TabOrder = 0
        ExplicitLeft = 3
      end
    end
  end
  object Btn_Buscar: TButton
    Left = 24
    Top = 248
    Width = 121
    Height = 25
    Caption = 'Buscar Certificado'
    TabOrder = 2
  end
  object Btn_Atualizar: TButton
    Left = 168
    Top = 248
    Width = 121
    Height = 25
    Caption = 'Atualizar Lista'
    TabOrder = 3
  end
  object Btn_Vincular: TButton
    Left = 328
    Top = 248
    Width = 233
    Height = 25
    Caption = 'Vincular certificado a uma empresa'
    TabOrder = 4
  end
  object Btn_Cancelar: TButton
    Left = 584
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 5
    OnClick = Btn_CancelarClick
  end
end
