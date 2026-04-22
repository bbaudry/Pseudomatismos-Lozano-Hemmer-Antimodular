object MouseTestFrm: TMouseTestFrm
  Left = 324
  Top = 286
  BorderStyle = bsDialog
  Caption = 'Mouse test'
  ClientHeight = 621
  ClientWidth = 678
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Scaled = False
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox: TPaintBox
    Left = 9
    Top = 119
    Width = 659
    Height = 493
  end
  object Label2: TLabel
    Left = 8
    Top = 12
    Width = 39
    Height = 13
    Caption = 'Targets:'
  end
  object TabControl: TTabControl
    Left = 7
    Top = 37
    Width = 661
    Height = 73
    TabOrder = 0
    Tabs.Strings = (
      '1')
    TabIndex = 0
    object Label3: TLabel
      Left = 8
      Top = 40
      Width = 30
      Height = 13
      Caption = 'Scale:'
    end
    object AprSpinEdit2: TAprSpinEdit
      Left = 42
      Top = 37
      Width = 48
      Height = 20
      Value = 1.000000000000000000
      Decimals = 1
      Max = 9.899999618530273000
      Alignment = taCenter
      Enabled = True
      Increment = 1.000000000000000000
      EditText = '1.0'
      TabOrder = 0
    end
    object ScrollBar: TScrollBar
      Left = 96
      Top = 39
      Width = 553
      Height = 16
      Max = 759
      Min = -100
      PageSize = 0
      TabOrder = 1
      OnChange = ScrollBarChange
    end
  end
  object TargetsEdit: TAprSpinEdit
    Left = 49
    Top = 9
    Width = 48
    Height = 20
    Value = 1.000000000000000000
    Min = 1.000000000000000000
    Max = 9999.000000000000000000
    Alignment = taCenter
    Enabled = True
    Increment = 1.000000000000000000
    EditText = '1'
    TabOrder = 1
  end
  object Button1: TButton
    Left = 136
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 2
    OnClick = Button1Click
  end
  object ObstacleSB: TScrollBar
    Left = 232
    Top = 13
    Width = 377
    Height = 16
    Max = 256
    PageSize = 0
    TabOrder = 3
    OnChange = ObstacleSBChange
  end
end
