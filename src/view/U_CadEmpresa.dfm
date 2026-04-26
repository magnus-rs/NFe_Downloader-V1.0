object Form_CadastroEmpresa: TForm_CadastroEmpresa
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Base de Cadastros'
  ClientHeight = 315
  ClientWidth = 502
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clDefault
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 40
    Width = 58
    Height = 13
    Caption = 'Documento:'
  end
  object Label2: TLabel
    Left = 24
    Top = 72
    Width = 67
    Height = 13
    Caption = 'Raz'#227'o Social: '
  end
  object Label3: TLabel
    Left = 24
    Top = 104
    Width = 28
    Height = 13
    Caption = 'Email:'
  end
  object Label4: TLabel
    Left = 24
    Top = 136
    Width = 17
    Height = 13
    Caption = 'UF:'
  end
  object Label5: TLabel
    Left = 112
    Top = 176
    Width = 3
    Height = 13
  end
  object Label6: TLabel
    Left = 24
    Top = 189
    Width = 56
    Height = 13
    Caption = 'Certificado:'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 176
    Width = 476
    Height = 57
    Shape = bsFrame
  end
  object Label_Certificado: TLabel
    Left = 78
    Top = 213
    Width = 311
    Height = 13
    Caption = 
      'Importar o certificado A1 a partir do arquivo digital.  [.pfx, .' +
      'cert]'
    Color = clAqua
    DragCursor = crHandPoint
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentColor = False
    ParentFont = False
    OnClick = Label_CertificadoClick
  end
  object Edit_Documento: TMaskEdit
    Left = 176
    Top = 37
    Width = 165
    Height = 21
    TabOrder = 1
    Text = ''
  end
  object Edit_Razao: TEdit
    Left = 96
    Top = 69
    Width = 369
    Height = 21
    CharCase = ecUpperCase
    TabOrder = 2
  end
  object Edit_Email: TEdit
    Left = 96
    Top = 101
    Width = 369
    Height = 21
    CharCase = ecLowerCase
    TabOrder = 3
  end
  object Combo_UF: TComboBox
    Left = 96
    Top = 133
    Width = 227
    Height = 21
    Style = csDropDownList
    TabOrder = 4
  end
  object Check_Ativo: TCheckBox
    Left = 406
    Top = 39
    Width = 43
    Height = 17
    Caption = 'Ativo'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object Btn_Salvar: TButton
    Left = 112
    Top = 256
    Width = 113
    Height = 25
    Caption = 'Salvar'
    TabOrder = 6
    OnClick = Btn_SalvarClick
  end
  object Combo_Doc: TComboBox
    Left = 96
    Top = 37
    Width = 74
    Height = 21
    TabOrder = 0
    Text = 'CNPJ'
    Items.Strings = (
      'CNPJ'
      'CPF')
  end
  object Edit_Certificado: TEdit
    Left = 83
    Top = 186
    Width = 389
    Height = 21
    TabOrder = 7
  end
  object Btn_Cancelar: TButton
    Left = 260
    Top = 256
    Width = 113
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 8
    OnClick = Btn_CancelarClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 502
    Height = 25
    Align = alTop
    Caption = 'Cadastro de Empresas'
    TabOrder = 9
    ExplicitWidth = 492
  end
  object FDQuery1: TFDQuery
    Left = 376
    Top = 128
  end
end
