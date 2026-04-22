object PixelBackGndFrm: TPixelBackGndFrm
  Left = 47
  Top = 210
  Width = 474
  Height = 257
  Caption = 'Autobackground test'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object ThresholdLbl: TLabel
    Left = 325
    Top = 108
    Width = 50
    Height = 13
    Caption = 'Threshold:'
  end
  object TimeLbl: TLabel
    Left = 349
    Top = 140
    Width = 26
    Height = 13
    Caption = 'Time:'
  end
  object BackGndBtn: TBitBtn
    Left = 316
    Top = 63
    Width = 144
    Height = 21
    Caption = 'Take background reference'
    TabOrder = 1
    OnClick = BackGndBtnClick
  end
  object ThresholdEdit: TAprSpinEdit
    Left = 380
    Top = 104
    Width = 52
    Height = 20
    Value = 1.000000000000000000
    Min = 1.000000000000000000
    Max = 999.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = ThresholdEditChange
    Increment = 1.000000000000000000
    EditText = '1'
    TabOrder = 2
  end
  object MinTimeEdit: TAprSpinEdit
    Left = 380
    Top = 136
    Width = 52
    Height = 20
    Value = 60.000000000000000000
    Decimals = 1
    Min = 1.000000000000000000
    Max = 999999.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = MinTimeEditChange
    Increment = 1.000000000000000000
    EditText = '60.0'
    TabOrder = 3
  end
  object TabControl: TTabControl
    Left = 4
    Top = 4
    Width = 301
    Height = 221
    TabOrder = 0
    Tabs.Strings = (
      'Raw'
      'Background'
      'Subtracted'
      'Thresholded'
      'States')
    TabIndex = 0
    object PaintBox: TPaintBox
      Left = 64
      Top = 55
      Width = 160
      Height = 120
      OnPaint = PaintBoxPaint
    end
  end
end
