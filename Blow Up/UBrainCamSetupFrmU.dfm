object UBrainCamSettingsFrm: TUBrainCamSettingsFrm
  Left = 678
  Top = 168
  Width = 286
  Height = 398
  Caption = 'Camera settings'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ShutterEdit: TNBFillEdit
    Tag = 1
    Left = 12
    Top = 13
    Width = 205
    Height = 25
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 16227430
    FillWidth = 125
    ArrowWidth = 12
    Title = 'Shutter'
    EditFont.Charset = DEFAULT_CHARSET
    EditFont.Color = clWindowText
    EditFont.Height = -14
    EditFont.Name = 'MS Sans Serif'
    EditFont.Style = []
    EditColor = clWindow
    Alignment = taCenter
    SpeedUpDelay = 200
    SpeedUpPeriod = 50
    Value = 50
    TabOrder = 0
  end
  object ShutterCB: TAprCheckBox
    Left = 224
    Top = 17
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 1
    TabStop = True
  end
  object GainEdit: TNBFillEdit
    Tag = 1
    Left = 12
    Top = 45
    Width = 205
    Height = 25
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 16227430
    FillWidth = 125
    ArrowWidth = 12
    Title = 'Gain'
    EditFont.Charset = DEFAULT_CHARSET
    EditFont.Color = clWindowText
    EditFont.Height = -14
    EditFont.Name = 'MS Sans Serif'
    EditFont.Style = []
    EditColor = clWindow
    Alignment = taCenter
    SpeedUpDelay = 200
    SpeedUpPeriod = 50
    Value = 50
    TabOrder = 2
  end
  object GainCB: TAprCheckBox
    Left = 224
    Top = 49
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 3
    TabStop = True
  end
  object UBEdit: TNBFillEdit
    Tag = 1
    Left = 12
    Top = 93
    Width = 205
    Height = 25
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 9424077
    FillWidth = 125
    ArrowWidth = 12
    Title = 'U/B'
    EditFont.Charset = DEFAULT_CHARSET
    EditFont.Color = clWindowText
    EditFont.Height = -14
    EditFont.Name = 'MS Sans Serif'
    EditFont.Style = []
    EditColor = clWindow
    Alignment = taCenter
    SpeedUpDelay = 200
    SpeedUpPeriod = 50
    Value = 50
    TabOrder = 4
  end
  object UbCB: TAprCheckBox
    Left = 224
    Top = 97
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 5
    TabStop = True
  end
  object VREdit: TNBFillEdit
    Tag = 1
    Left = 12
    Top = 125
    Width = 205
    Height = 25
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 9424077
    FillWidth = 125
    ArrowWidth = 12
    Title = 'V/R'
    EditFont.Charset = DEFAULT_CHARSET
    EditFont.Color = clWindowText
    EditFont.Height = -14
    EditFont.Name = 'MS Sans Serif'
    EditFont.Style = []
    EditColor = clWindow
    Alignment = taCenter
    SpeedUpDelay = 200
    SpeedUpPeriod = 50
    Value = 50
    TabOrder = 6
  end
  object VrCB: TAprCheckBox
    Left = 224
    Top = 129
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 7
    TabStop = True
  end
  object HueEdit: TNBFillEdit
    Tag = 1
    Left = 12
    Top = 157
    Width = 205
    Height = 25
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 9424077
    FillWidth = 125
    ArrowWidth = 12
    Title = 'Hue'
    EditFont.Charset = DEFAULT_CHARSET
    EditFont.Color = clWindowText
    EditFont.Height = -14
    EditFont.Name = 'MS Sans Serif'
    EditFont.Style = []
    EditColor = clWindow
    Alignment = taCenter
    SpeedUpDelay = 200
    SpeedUpPeriod = 50
    Value = 50
    TabOrder = 8
  end
  object HueCB: TAprCheckBox
    Left = 224
    Top = 161
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 9
    TabStop = True
  end
  object SaturationEdit: TNBFillEdit
    Tag = 1
    Left = 12
    Top = 189
    Width = 205
    Height = 25
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 9424077
    FillWidth = 125
    ArrowWidth = 12
    Title = 'Saturation'
    EditFont.Charset = DEFAULT_CHARSET
    EditFont.Color = clWindowText
    EditFont.Height = -14
    EditFont.Name = 'MS Sans Serif'
    EditFont.Style = []
    EditColor = clWindow
    Alignment = taCenter
    SpeedUpDelay = 200
    SpeedUpPeriod = 50
    Value = 50
    TabOrder = 10
  end
  object SaturationCB: TAprCheckBox
    Left = 224
    Top = 193
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 11
    TabStop = True
  end
  object BrightnessEdit: TNBFillEdit
    Tag = 1
    Left = 12
    Top = 237
    Width = 205
    Height = 25
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 12623033
    FillWidth = 125
    ArrowWidth = 12
    Title = 'Brightness'
    EditFont.Charset = DEFAULT_CHARSET
    EditFont.Color = clWindowText
    EditFont.Height = -14
    EditFont.Name = 'MS Sans Serif'
    EditFont.Style = []
    EditColor = clWindow
    Alignment = taCenter
    SpeedUpDelay = 200
    SpeedUpPeriod = 50
    Value = 50
    TabOrder = 12
  end
  object BrightnessCB: TAprCheckBox
    Left = 224
    Top = 241
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 13
    TabStop = True
  end
  object SharpnessEdit: TNBFillEdit
    Tag = 1
    Left = 12
    Top = 269
    Width = 205
    Height = 25
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 12623033
    FillWidth = 125
    ArrowWidth = 12
    Title = 'Sharpness'
    EditFont.Charset = DEFAULT_CHARSET
    EditFont.Color = clWindowText
    EditFont.Height = -14
    EditFont.Name = 'MS Sans Serif'
    EditFont.Style = []
    EditColor = clWindow
    Alignment = taCenter
    SpeedUpDelay = 200
    SpeedUpPeriod = 50
    Value = 50
    TabOrder = 14
  end
  object SharpnessCB: TAprCheckBox
    Left = 224
    Top = 273
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 15
    TabStop = True
  end
  object GammaEdit: TNBFillEdit
    Tag = 1
    Left = 12
    Top = 301
    Width = 205
    Height = 25
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 12623033
    FillWidth = 125
    ArrowWidth = 12
    Title = 'Gamma'
    EditFont.Charset = DEFAULT_CHARSET
    EditFont.Color = clWindowText
    EditFont.Height = -14
    EditFont.Name = 'MS Sans Serif'
    EditFont.Style = []
    EditColor = clWindow
    Alignment = taCenter
    SpeedUpDelay = 200
    SpeedUpPeriod = 50
    Value = 50
    TabOrder = 16
  end
  object GammaCB: TAprCheckBox
    Left = 224
    Top = 305
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 17
    TabStop = True
  end
  object ShowListBtn: TButton
    Left = 52
    Top = 337
    Width = 75
    Height = 25
    Caption = 'Show list'
    TabOrder = 18
    OnClick = ShowListBtnClick
  end
  object VenderInfoBtn: TButton
    Left = 140
    Top = 337
    Width = 75
    Height = 25
    Caption = 'Vender Info'
    TabOrder = 19
    OnClick = VenderInfoBtnClick
  end
end
