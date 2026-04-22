object PointGreySettingsFrm: TPointGreySettingsFrm
  Left = 1402
  Top = 83
  BorderStyle = bsDialog
  Caption = 'Point Grey Camera settings'
  ClientHeight = 433
  ClientWidth = 457
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
  object RegisterLbl: TLabel
    Left = 266
    Top = 354
    Width = 51
    Height = 13
    Caption = 'Register: $'
  end
  object Label1: TLabel
    Left = 276
    Top = 380
    Width = 39
    Height = 13
    Caption = 'Value: $'
  end
  object PropertyPanel: TPanel
    Left = 8
    Top = 106
    Width = 249
    Height = 324
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
      FillWidth = 85
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
    object GainEdit: TNBFillEdit
      Tag = 2
      Left = 7
      Top = 53
      Width = 165
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 85
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
      FillWidth = 85
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
    object ShutterEdit: TNBFillEdit
      Tag = 7
      Left = 7
      Top = 157
      Width = 165
      Height = 21
      ArrowColor = 12615680
      BackGndColor = 16638434
      FillColor = 16227430
      FillWidth = 85
      ArrowWidth = 15
      Title = 'Shutter'
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
      FillWidth = 85
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
      FillWidth = 85
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
      OnOverFlow = ControlCBClick
      TabOrder = 5
    end
    object BrightnessCB: TAprCheckBox
      Tag = 1
      Left = 178
      Top = 28
      Width = 15
      Height = 17
      TabOrder = 6
      TabStop = True
    end
    object GainCB: TAprCheckBox
      Tag = 2
      Left = 178
      Top = 55
      Width = 15
      Height = 17
      TabOrder = 7
      TabStop = True
    end
    object SaturationCB: TAprCheckBox
      Tag = 3
      Left = 178
      Top = 81
      Width = 15
      Height = 17
      TabOrder = 8
      TabStop = True
    end
    object SharpnessCB: TAprCheckBox
      Tag = 4
      Left = 178
      Top = 107
      Width = 15
      Height = 17
      TabOrder = 9
      TabStop = True
    end
    object GammaCB: TAprCheckBox
      Tag = 5
      Left = 178
      Top = 133
      Width = 15
      Height = 17
      TabOrder = 10
      TabStop = True
    end
    object ShutterCB: TAprCheckBox
      Tag = 7
      Left = 178
      Top = 159
      Width = 15
      Height = 17
      TabOrder = 11
      TabStop = True
    end
    object BrightnessOnOffCB: TAprCheckBox
      Tag = 1
      Left = 218
      Top = 28
      Width = 15
      Height = 17
      TabOrder = 12
      TabStop = True
    end
    object GainOnOffCB: TAprCheckBox
      Tag = 2
      Left = 218
      Top = 56
      Width = 15
      Height = 17
      TabOrder = 13
      TabStop = True
    end
    object SaturationOnOffCB: TAprCheckBox
      Tag = 3
      Left = 218
      Top = 81
      Width = 15
      Height = 17
      TabOrder = 14
      TabStop = True
    end
    object SharpnessOnOffCB: TAprCheckBox
      Tag = 4
      Left = 218
      Top = 107
      Width = 15
      Height = 17
      TabOrder = 15
      TabStop = True
    end
    object GammaOnOffCB: TAprCheckBox
      Tag = 5
      Left = 218
      Top = 133
      Width = 15
      Height = 17
      TabOrder = 16
      TabStop = True
    end
    object ShutterOnOffCB: TAprCheckBox
      Tag = 7
      Left = 218
      Top = 159
      Width = 15
      Height = 17
      TabOrder = 17
      TabStop = True
    end
    object Panel1: TPanel
      Left = 6
      Top = 236
      Width = 236
      Height = 81
      Color = 14271692
      TabOrder = 18
      object Label2: TLabel
        Left = 8
        Top = 7
        Width = 69
        Height = 13
        Caption = 'White balance'
        Color = 13413034
        ParentColor = False
      end
      object RedWhiteBalanceEdit: TNBFillEdit
        Tag = 6
        Left = 7
        Top = 25
        Width = 155
        Height = 21
        ArrowColor = 12615680
        BackGndColor = 16638434
        FillColor = 16227430
        FillWidth = 75
        ArrowWidth = 15
        Title = 'Red'
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
        OnValueChange = WhiteBalanceEditChange
        TabOrder = 0
      end
      object WhiteBalanceCB: TAprCheckBox
        Tag = 6
        Left = 171
        Top = 5
        Width = 15
        Height = 17
        Enabled = False
        TabOrder = 1
        TabStop = True
        OnClick = WhiteBalanceEditChange
      end
      object WhiteBalanceOnOffCB: TAprCheckBox
        Tag = 6
        Left = 211
        Top = 5
        Width = 15
        Height = 17
        TabOrder = 2
        TabStop = True
        OnClick = WhiteBalanceEditChange
      end
      object BlueWhiteBalanceEdit: TNBFillEdit
        Tag = 6
        Left = 7
        Top = 52
        Width = 155
        Height = 21
        ArrowColor = 12615680
        BackGndColor = 16638434
        FillColor = 16227430
        FillWidth = 75
        ArrowWidth = 15
        Title = 'Blue'
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
        OnValueChange = WhiteBalanceEditChange
        TabOrder = 3
      end
    end
    object ColorEnableEdit: TNBFillEdit
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
      TabOrder = 19
    end
    object HueEdit: TNBFillEdit
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
      TabOrder = 20
    end
    object HueCB: TAprCheckBox
      Tag = 7
      Left = 178
      Top = 185
      Width = 15
      Height = 17
      TabOrder = 21
      TabStop = True
    end
    object HueOnOffCB: TAprCheckBox
      Tag = 6
      Left = 218
      Top = 185
      Width = 15
      Height = 17
      TabOrder = 22
      TabStop = True
    end
    object ColorEnableOnOffCB: TAprCheckBox
      Tag = 7
      Left = 218
      Top = 211
      Width = 15
      Height = 17
      TabOrder = 23
      TabStop = True
    end
    object ColorEnableCB: TAprCheckBox
      Tag = 7
      Left = 178
      Top = 211
      Width = 15
      Height = 17
      TabOrder = 24
      TabStop = True
    end
  end
  object ReadRegisterBtn: TButton
    Left = 388
    Top = 350
    Width = 58
    Height = 21
    Caption = 'Read'
    TabOrder = 2
    OnClick = ReadRegisterBtnClick
  end
  object WriteRegisterBtn: TButton
    Left = 387
    Top = 377
    Width = 58
    Height = 21
    Caption = 'Write'
    TabOrder = 3
    OnClick = WriteRegisterBtnClick
  end
  object RegisterValueEdit: THexEdit
    Left = 320
    Top = 376
    Width = 58
    Height = 21
    NumBase = ebHex
    MaxValue = 16777215
    MinValue = 0
    TabOrder = 4
    Validate = False
    Value = 0
  end
  object RegisterAddressEdit: THexEdit
    Left = 320
    Top = 350
    Width = 58
    Height = 21
    NumBase = ebHex
    MaxValue = 65535
    MinValue = 0
    TabOrder = 1
    Validate = False
    Value = 2060
  end
  object Panel2: TPanel
    Left = 264
    Top = 106
    Width = 185
    Height = 237
    Color = 13879758
    TabOrder = 5
    object Label3: TLabel
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
    object Label4: TLabel
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
      Top = 58
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
      Top = 117
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
      Top = 119
      Width = 15
      Height = 17
      TabOrder = 5
      TabStop = True
      OnClick = ControlCBClick
    end
    object RollEdit: TNBFillEdit
      Left = 7
      Top = 87
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
      Top = 89
      Width = 15
      Height = 17
      TabOrder = 7
      TabStop = True
      OnClick = ControlCBClick
    end
    object IrisEdit: TNBFillEdit
      Left = 7
      Top = 175
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
      Top = 177
      Width = 15
      Height = 17
      TabOrder = 9
      TabStop = True
      OnClick = ControlCBClick
    end
    object ExposureEdit: TNBFillEdit
      Left = 7
      Top = 146
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
      Top = 148
      Width = 15
      Height = 17
      TabOrder = 11
      TabStop = True
      OnClick = ControlCBClick
    end
    object FocusEdit: TNBFillEdit
      Left = 7
      Top = 205
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
      Top = 207
      Width = 15
      Height = 17
      TabOrder = 13
      TabStop = True
      OnClick = ControlCBClick
    end
  end
  object Memo: TMemo
    Left = 7
    Top = 8
    Width = 442
    Height = 89
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
    TabOrder = 6
  end
  object CamBtn: TButton
    Left = 324
    Top = 405
    Width = 33
    Height = 22
    Caption = 'Cam'
    TabOrder = 7
    OnClick = CamBtnClick
  end
  object PinBtn: TButton
    Left = 364
    Top = 405
    Width = 33
    Height = 22
    Caption = 'Pin'
    TabOrder = 8
    OnClick = PinBtnClick
  end
end
