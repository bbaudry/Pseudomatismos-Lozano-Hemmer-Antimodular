object FireISettingsFrm: TFireISettingsFrm
  Left = 1327
  Top = 114
  BorderStyle = bsDialog
  Caption = 'Camera settings'
  ClientHeight = 259
  ClientWidth = 545
  Color = 13750731
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object ShutterEdit: TNBFillEdit
    Tag = 1
    Left = 8
    Top = 91
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
    Left = 220
    Top = 95
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 1
    TabStop = True
  end
  object GainEdit: TNBFillEdit
    Tag = 1
    Left = 8
    Top = 123
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
    Left = 220
    Top = 127
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 3
    TabStop = True
  end
  object UBEdit: TNBFillEdit
    Tag = 1
    Left = 280
    Top = 99
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
    Left = 492
    Top = 119
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 5
    TabStop = True
  end
  object VREdit: TNBFillEdit
    Tag = 1
    Left = 280
    Top = 131
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
  object HueEdit: TNBFillEdit
    Tag = 1
    Left = 280
    Top = 163
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
    TabOrder = 7
  end
  object HueCB: TAprCheckBox
    Left = 492
    Top = 167
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 8
    TabStop = True
  end
  object SaturationEdit: TNBFillEdit
    Tag = 1
    Left = 280
    Top = 195
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
    TabOrder = 9
  end
  object SaturationCB: TAprCheckBox
    Left = 492
    Top = 199
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 10
    TabStop = True
  end
  object BrightnessEdit: TNBFillEdit
    Tag = 1
    Left = 8
    Top = 163
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
    TabOrder = 11
  end
  object BrightnessCB: TAprCheckBox
    Left = 220
    Top = 167
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 12
    TabStop = True
  end
  object SharpnessEdit: TNBFillEdit
    Tag = 1
    Left = 8
    Top = 195
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
    TabOrder = 13
  end
  object SharpnessCB: TAprCheckBox
    Left = 220
    Top = 199
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 14
    TabStop = True
  end
  object GammaEdit: TNBFillEdit
    Tag = 1
    Left = 8
    Top = 227
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
    TabOrder = 15
  end
  object GammaCB: TAprCheckBox
    Left = 220
    Top = 231
    Width = 46
    Height = 17
    Caption = 'Auto'
    TabOrder = 16
    TabStop = True
  end
  object Memo: TMemo
    Left = 7
    Top = 8
    Width = 530
    Height = 74
    Color = clInfoBk
    Lines.Strings = (
      
        'Please set the camera so that it works for your lighting conditi' +
        'ons.'
      ''
      
        'Typically it is best to first reduce Brightness then Contrast an' +
        'd finally Exposure only if you have to.'
      ''
      
        'Please avoid using automatical control if possible, except maybe' +
        ' white balance.')
    TabOrder = 17
  end
  object CamBtn: TButton
    Left = 356
    Top = 229
    Width = 33
    Height = 22
    Caption = 'Cam'
    TabOrder = 18
    OnClick = CamBtnClick
  end
  object PinBtn: TButton
    Left = 396
    Top = 229
    Width = 33
    Height = 22
    Caption = 'Pin'
    TabOrder = 19
    OnClick = PinBtnClick
  end
end
