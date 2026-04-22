object MenuFrm: TMenuFrm
  Left = 1015
  Top = 417
  BorderStyle = bsDialog
  Caption = 'v1.08'
  ClientHeight = 206
  ClientWidth = 371
  Color = 13880777
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 232
    Top = 131
    Width = 76
    Height = 13
    Caption = 'Move threshold:'
  end
  object SetupBtn: TBitBtn
    Left = 14
    Top = 81
    Width = 88
    Height = 25
    Caption = 'Smoke'
    TabOrder = 0
    OnClick = SetupBtnClick
  end
  object ExitBtn: TBitBtn
    Left = 112
    Top = 151
    Width = 89
    Height = 25
    Caption = 'Exit program'
    TabOrder = 1
    OnClick = ExitBtnClick
  end
  object CameraBtn: TButton
    Left = 13
    Top = 14
    Width = 89
    Height = 25
    Caption = 'Camera'
    TabOrder = 2
    OnClick = CameraBtnClick
  end
  object ViewTrackingBtn: TButton
    Left = 14
    Top = 47
    Width = 88
    Height = 25
    Caption = 'View tracking'
    TabOrder = 3
    OnClick = ViewTrackingBtnClick
  end
  object CalibrateBtn: TButton
    Left = 112
    Top = 14
    Width = 89
    Height = 25
    Caption = 'Calibrate'
    TabOrder = 4
    OnClick = CalibrateBtnClick
  end
  object MouseTestBtn: TButton
    Left = 112
    Top = 47
    Width = 89
    Height = 25
    Caption = 'Mouse test'
    TabOrder = 5
    OnClick = MouseTestBtnClick
  end
  object ProjectorMaskBtn: TButton
    Left = 112
    Top = 81
    Width = 89
    Height = 25
    Caption = 'Projector mask'
    TabOrder = 6
    OnClick = ProjectorMaskBtnClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 187
    Width = 371
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object FountainBtn: TButton
    Left = 14
    Top = 116
    Width = 88
    Height = 25
    Caption = 'Particles'
    TabOrder = 8
    OnClick = FountainBtnClick
  end
  object SaveBmpBtn: TButton
    Left = 112
    Top = 116
    Width = 89
    Height = 25
    Caption = 'Save bmp'
    TabOrder = 9
    OnClick = SaveBmpBtnClick
  end
  object ShowRG: TRadioGroup
    Left = 224
    Top = 8
    Width = 121
    Height = 105
    Caption = 'Show'
    ItemIndex = 3
    Items.Strings = (
      'Velocity'
      'Temperature'
      'Pressure'
      'Density')
    TabOrder = 10
    OnClick = ShowRGClick
  end
  object ResetBtn: TButton
    Left = 15
    Top = 152
    Width = 87
    Height = 25
    Caption = 'Reset'
    TabOrder = 11
    OnClick = ResetBtnClick
  end
  object HomeThresholdEdit: TAprSpinEdit
    Left = 232
    Top = 148
    Width = 73
    Height = 20
    Max = 999999.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = HomeThresholdEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 12
  end
end
