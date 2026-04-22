object BackGndFinderFrm: TBackGndFinderFrm
  Left = 220
  Top = 207
  BorderStyle = bsSingle
  ClientHeight = 504
  ClientWidth = 820
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox: TPaintBox
    Tag = 1
    Left = 4
    Top = 5
    Width = 659
    Height = 493
  end
  object BackGndPanel: TPanel
    Left = 670
    Top = 5
    Width = 145
    Height = 163
    Color = 14075584
    TabOrder = 0
    object BackGndFinderLbl: TLabel
      Left = 1
      Top = 1
      Width = 143
      Height = 14
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Background'
      Color = 10667934
      ParentColor = False
    end
    object Label10: TLabel
      Left = 17
      Top = 114
      Width = 50
      Height = 13
      Caption = 'Threshold:'
    end
    object Label1: TLabel
      Left = 41
      Top = 139
      Width = 26
      Height = 13
      Caption = 'Time:'
    end
    object ForceBackGndBtn: TButton
      Left = 8
      Top = 59
      Width = 129
      Height = 21
      Caption = 'Force all to background'
      TabOrder = 2
      OnClick = ForceBackGndBtnClick
    end
    object DelayCB: TAprCheckBox
      Left = 23
      Top = 87
      Width = 105
      Height = 17
      Caption = 'Delay 5 seconds'
      TabOrder = 3
      TabStop = True
    end
    object BrighterRB: TRadioButton
      Left = 11
      Top = 21
      Width = 113
      Height = 17
      Caption = 'Brighter subtraction'
      TabOrder = 0
      OnClick = BrighterRBClick
    end
    object AbsoluteRB: TRadioButton
      Left = 11
      Top = 38
      Width = 125
      Height = 17
      Caption = 'Absolute subtraction'
      TabOrder = 1
      OnClick = AbsoluteRBClick
    end
    object BackGndThresholdEdit: TAprSpinEdit
      Left = 71
      Top = 110
      Width = 48
      Height = 20
      Min = 1.000000000000000000
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = BackGndThresholdEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 4
    end
    object BackGndTimeEdit: TAprSpinEdit
      Left = 71
      Top = 135
      Width = 48
      Height = 20
      Min = 1.000000000000000000
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = BackGndTimeEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 5
    end
  end
  object Panel3: TPanel
    Left = 670
    Top = 175
    Width = 145
    Height = 226
    TabOrder = 1
    object Label9: TLabel
      Left = 1
      Top = 1
      Width = 143
      Height = 14
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Draw'
      Color = 11511183
      ParentColor = False
    end
    object BackGndDrawPanel: TPanel
      Left = 14
      Top = 25
      Width = 117
      Height = 80
      Color = 13685705
      TabOrder = 0
      object Label11: TLabel
        Left = 1
        Top = 1
        Width = 115
        Height = 14
        Align = alTop
        Alignment = taCenter
        AutoSize = False
        Caption = 'Background'
        Color = 11511183
        ParentColor = False
      end
      object NormalRB: TRadioButton
        Left = 10
        Top = 20
        Width = 57
        Height = 17
        Caption = 'Normal'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object SubtractedRB: TRadioButton
        Left = 10
        Top = 54
        Width = 77
        Height = 17
        Caption = 'Subtracted'
        TabOrder = 1
      end
      object BackGndRB: TRadioButton
        Left = 10
        Top = 37
        Width = 81
        Height = 17
        Caption = 'Background'
        TabOrder = 2
      end
    end
    object ForeGndDrawPanel: TPanel
      Left = 12
      Top = 114
      Width = 120
      Height = 100
      Color = 13685705
      TabOrder = 1
      object Label14: TLabel
        Left = 1
        Top = 1
        Width = 118
        Height = 14
        Align = alTop
        Alignment = taCenter
        AutoSize = False
        Caption = 'Foreground'
        Color = 11511183
        ParentColor = False
      end
      object NormalFGRB: TRadioButton
        Left = 7
        Top = 22
        Width = 99
        Height = 17
        Caption = 'Normal'
        TabOrder = 0
        TabStop = True
      end
      object ThresholdsRB: TRadioButton
        Left = 7
        Top = 40
        Width = 83
        Height = 17
        Caption = 'Thresholds'
        TabOrder = 1
      end
      object ChangingRB: TRadioButton
        Left = 7
        Top = 58
        Width = 106
        Height = 17
        Caption = 'Changing pixels'
        TabOrder = 2
      end
      object PixelStatesRB: TRadioButton
        Left = 7
        Top = 76
        Width = 106
        Height = 17
        Caption = 'Pixel states'
        Checked = True
        TabOrder = 3
        TabStop = True
      end
    end
  end
  object BackGndTimer: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = BackGndTimerTimer
    Left = 27
    Top = 23
  end
end
