object CamSettingsFrm: TCamSettingsFrm
  Left = 410
  Top = 156
  BorderStyle = bsDialog
  Caption = 'Camera settings'
  ClientHeight = 403
  ClientWidth = 456
  Color = 14010824
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object PropertyPanel: TPanel
    Left = 8
    Top = 104
    Width = 249
    Height = 291
    Color = 13879758
    TabOrder = 0
    object AutoPropertyLbl: TLabel
      Left = 174
      Top = 6
      Width = 22
      Height = 13
      Caption = 'Auto'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
    end
    object PropertyLbl: TLabel
      Left = 55
      Top = 6
      Width = 39
      Height = 13
      Caption = 'Property'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
    end
    object PropertyOnOffLbl: TLabel
      Left = 210
      Top = 6
      Width = 33
      Height = 13
      Caption = 'On/Off'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
    end
    object BrightnessEdit: TNBFillEdit
      Tag = 1
      Left = 7
      Top = 27
      Width = 165
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Brightness'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      TabOrder = 0
    end
    object ContrastEdit: TNBFillEdit
      Tag = 2
      Left = 7
      Top = 53
      Width = 165
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Contrast'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      TabOrder = 1
    end
    object SaturationEdit: TNBFillEdit
      Tag = 3
      Left = 7
      Top = 79
      Width = 165
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Saturation'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      TabOrder = 2
    end
    object BacklightCompensationEdit: TNBFillEdit
      Tag = 7
      Left = 7
      Top = 183
      Width = 165
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'BL Comp'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      TabOrder = 3
    end
    object SharpnessEdit: TNBFillEdit
      Tag = 4
      Left = 7
      Top = 105
      Width = 165
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Sharpness'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      TabOrder = 4
    end
    object GammaEdit: TNBFillEdit
      Tag = 5
      Left = 7
      Top = 131
      Width = 165
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Gamma'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      TabOrder = 5
    end
    object WhiteBalanceEdit: TNBFillEdit
      Tag = 6
      Left = 7
      Top = 157
      Width = 165
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'White Balance'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Max = 9999999
      Value = 1234567
      TabOrder = 6
    end
    object BrightnessCB: TAprCheckBox
      Tag = 1
      Left = 178
      Top = 28
      Width = 15
      Height = 17
      TabOrder = 7
      TabStop = True
    end
    object ContrastCB: TAprCheckBox
      Tag = 2
      Left = 178
      Top = 56
      Width = 15
      Height = 17
      TabOrder = 8
      TabStop = True
    end
    object SaturationCB: TAprCheckBox
      Tag = 3
      Left = 178
      Top = 81
      Width = 15
      Height = 17
      TabOrder = 9
      TabStop = True
    end
    object SharpnessCB: TAprCheckBox
      Tag = 4
      Left = 178
      Top = 107
      Width = 15
      Height = 17
      TabOrder = 10
      TabStop = True
    end
    object GammaCB: TAprCheckBox
      Tag = 5
      Left = 178
      Top = 133
      Width = 15
      Height = 17
      TabOrder = 11
      TabStop = True
    end
    object WhiteBalanceCB: TAprCheckBox
      Tag = 6
      Left = 178
      Top = 159
      Width = 15
      Height = 17
      TabOrder = 12
      TabStop = True
    end
    object BacklightCompensationCB: TAprCheckBox
      Tag = 7
      Left = 178
      Top = 185
      Width = 15
      Height = 17
      TabOrder = 13
      TabStop = True
    end
    object GainEdit: TNBFillEdit
      Tag = 7
      Left = 7
      Top = 209
      Width = 165
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Gain'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      TabOrder = 14
    end
    object GainCB: TAprCheckBox
      Tag = 7
      Left = 178
      Top = 211
      Width = 15
      Height = 17
      TabOrder = 15
      TabStop = True
    end
    object HueEdit: TNBFillEdit
      Tag = 7
      Left = 7
      Top = 235
      Width = 165
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Hue'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      TabOrder = 16
    end
    object HueCB: TAprCheckBox
      Tag = 7
      Left = 178
      Top = 237
      Width = 15
      Height = 17
      TabOrder = 17
      TabStop = True
    end
    object ColorEnableEdit: TNBFillEdit
      Tag = 7
      Left = 7
      Top = 261
      Width = 165
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Color enable'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      TabOrder = 18
    end
    object ColorEnableCB: TAprCheckBox
      Tag = 7
      Left = 178
      Top = 263
      Width = 15
      Height = 17
      TabOrder = 19
      TabStop = True
    end
    object BrightnessOnOffCB: TAprCheckBox
      Tag = 1
      Left = 218
      Top = 28
      Width = 15
      Height = 17
      TabOrder = 20
      TabStop = True
    end
    object ContrastOnOffCB: TAprCheckBox
      Tag = 2
      Left = 218
      Top = 56
      Width = 15
      Height = 17
      TabOrder = 21
      TabStop = True
    end
    object SaturationOnOffCB: TAprCheckBox
      Tag = 3
      Left = 218
      Top = 81
      Width = 15
      Height = 17
      TabOrder = 22
      TabStop = True
    end
    object SharpnessOnOffCB: TAprCheckBox
      Tag = 4
      Left = 218
      Top = 107
      Width = 15
      Height = 17
      TabOrder = 23
      TabStop = True
    end
    object GammaOnOffCB: TAprCheckBox
      Tag = 5
      Left = 218
      Top = 133
      Width = 15
      Height = 17
      TabOrder = 24
      TabStop = True
    end
    object WhiteBalanceOnOffCB: TAprCheckBox
      Tag = 6
      Left = 218
      Top = 159
      Width = 15
      Height = 17
      TabOrder = 25
      TabStop = True
    end
    object BackLightCompensationOnOffCB: TAprCheckBox
      Tag = 7
      Left = 218
      Top = 185
      Width = 15
      Height = 17
      TabOrder = 26
      TabStop = True
    end
    object ColorEnableOnOffCB: TAprCheckBox
      Tag = 7
      Left = 218
      Top = 263
      Width = 15
      Height = 17
      TabOrder = 27
      TabStop = True
    end
    object HueOnOffCB: TAprCheckBox
      Tag = 6
      Left = 218
      Top = 237
      Width = 15
      Height = 17
      TabOrder = 28
      TabStop = True
    end
    object GainOnOffCB: TAprCheckBox
      Tag = 5
      Left = 218
      Top = 211
      Width = 15
      Height = 17
      TabOrder = 29
      TabStop = True
    end
  end
  object ControlPanel: TPanel
    Left = 264
    Top = 119
    Width = 185
    Height = 244
    Color = 13879758
    TabOrder = 1
    object ControlLbl: TLabel
      Left = 61
      Top = 7
      Width = 33
      Height = 13
      Caption = 'Control'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
    end
    object AutoControlLbl: TLabel
      Left = 157
      Top = 7
      Width = 22
      Height = 13
      Caption = 'Auto'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
    end
    object TiltEdit: TNBFillEdit
      Left = 7
      Top = 59
      Width = 147
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Tilt'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      OnUnderFlow = ControlEditValueChange
      TabOrder = 0
    end
    object TiltCB: TAprCheckBox
      Left = 161
      Top = 60
      Width = 15
      Height = 17
      TabOrder = 1
      TabStop = True
      OnClick = ControlCBClick
    end
    object PanEdit: TNBFillEdit
      Left = 7
      Top = 29
      Width = 147
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Pan'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      OnUnderFlow = ControlEditValueChange
      TabOrder = 2
    end
    object PanCB: TAprCheckBox
      Left = 161
      Top = 31
      Width = 15
      Height = 17
      TabOrder = 3
      TabStop = True
      OnClick = ControlCBClick
    end
    object ZoomEdit: TNBFillEdit
      Left = 7
      Top = 121
      Width = 147
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Zoom'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      OnUnderFlow = ControlEditValueChange
      TabOrder = 4
    end
    object ZoomCB: TAprCheckBox
      Left = 161
      Top = 123
      Width = 15
      Height = 17
      TabOrder = 5
      TabStop = True
      OnClick = ControlCBClick
    end
    object RollEdit: TNBFillEdit
      Left = 7
      Top = 90
      Width = 147
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Roll'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      OnUnderFlow = ControlEditValueChange
      TabOrder = 6
    end
    object RollCB: TAprCheckBox
      Left = 161
      Top = 91
      Width = 15
      Height = 17
      TabOrder = 7
      TabStop = True
      OnClick = ControlCBClick
    end
    object IrisEdit: TNBFillEdit
      Left = 7
      Top = 182
      Width = 147
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Iris'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      OnUnderFlow = ControlEditValueChange
      TabOrder = 8
    end
    object IrisCB: TAprCheckBox
      Left = 161
      Top = 184
      Width = 15
      Height = 17
      TabOrder = 9
      TabStop = True
      OnClick = ControlCBClick
    end
    object ExposureEdit: TNBFillEdit
      Left = 7
      Top = 151
      Width = 147
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Exposure'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      OnUnderFlow = ControlEditValueChange
      TabOrder = 10
    end
    object ExposureCB: TAprCheckBox
      Left = 161
      Top = 153
      Width = 15
      Height = 17
      TabOrder = 11
      TabStop = True
      OnClick = ControlCBClick
    end
    object FocusEdit: TNBFillEdit
      Left = 7
      Top = 213
      Width = 147
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 75
      ArrowWidth = 15
      Title = 'Focus'
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Value = 50
      OnUnderFlow = ControlEditValueChange
      TabOrder = 12
    end
    object FocusCB: TAprCheckBox
      Left = 161
      Top = 215
      Width = 15
      Height = 17
      TabOrder = 13
      TabStop = True
      OnClick = ControlCBClick
    end
  end
  object Memo: TMemo
    Left = 6
    Top = 7
    Width = 443
    Height = 86
    Color = clInfoBk
    Lines.Strings = (
      
        'Please set the camera so that it works for your lighting conditi' +
        'ons.'
      ''
      
        'Typically it is best to first reduce Brightness then Contrast an' +
        'd finally Exposure only if you '
      'have to.'
      ''
      
        'Please avoid using automatical control if possible, except maybe' +
        ' white balance.')
    TabOrder = 2
  end
  object CamBtn: TButton
    Left = 316
    Top = 374
    Width = 33
    Height = 22
    Caption = 'Cam'
    TabOrder = 3
    OnClick = CamBtnClick
  end
  object PinBtn: TButton
    Left = 356
    Top = 374
    Width = 33
    Height = 22
    Caption = 'Pin'
    TabOrder = 4
    OnClick = PinBtnClick
  end
end
