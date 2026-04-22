object AvtSettingsFrm: TAvtSettingsFrm
  Left = 2139
  Top = 113
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderStyle = bsDialog
  Caption = 'AVT driver settings'
  ClientHeight = 325
  ClientWidth = 457
  Color = 14076615
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object AutoPropertyLbl: TLabel
    Left = 184
    Top = 148
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
  object PropertyOnOffLbl: TLabel
    Left = 220
    Top = 148
    Width = 46
    Height = 13
    Caption = 'One push'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
  end
  object PaintBox: TPaintBox
    Left = 285
    Top = 75
    Width = 160
    Height = 120
    OnPaint = PaintBoxPaint
  end
  object GainEdit: TNBFillEdit
    Tag = 2
    Left = 9
    Top = 163
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
    OnValueChange = EditChange
    TabOrder = 2
  end
  object GainAutoCB: TAprCheckBox
    Tag = 2
    Left = 188
    Top = 165
    Width = 15
    Height = 17
    TabOrder = 3
    TabStop = True
    OnClick = EditChange
  end
  object GainOnePushCB: TAprCheckBox
    Tag = 2
    Left = 236
    Top = 166
    Width = 15
    Height = 17
    TabOrder = 4
    TabStop = True
    OnClick = EditChange
  end
  object DebayeringCB: TAprCheckBox
    Left = 10
    Top = 126
    Width = 73
    Height = 17
    Caption = 'Debayering'
    TabOrder = 0
    TabStop = True
    OnClick = EditChange
  end
  object BWDebayeringCB: TAprCheckBox
    Left = 98
    Top = 126
    Width = 105
    Height = 17
    Caption = 'B/W Debayering'
    TabOrder = 1
    TabStop = True
    OnClick = EditChange
  end
  object GammaCB: TCheckBox
    Left = 210
    Top = 126
    Width = 57
    Height = 17
    Caption = 'Gamma'
    TabOrder = 5
    OnClick = EditChange
  end
  object WhiteBalanceUEdit: TNBFillEdit
    Tag = 2
    Left = 9
    Top = 189
    Width = 165
    Height = 21
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 16227430
    FillWidth = 85
    ArrowWidth = 15
    Title = 'White Balance U'
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
    OnValueChange = EditChange
    TabOrder = 6
  end
  object WhiteBalanceUAutoCB: TAprCheckBox
    Tag = 2
    Left = 188
    Top = 191
    Width = 15
    Height = 17
    TabOrder = 7
    TabStop = True
    OnClick = EditChange
  end
  object WhiteBalanceUOnePushCB: TAprCheckBox
    Tag = 2
    Left = 236
    Top = 192
    Width = 15
    Height = 17
    TabOrder = 8
    TabStop = True
    OnClick = EditChange
  end
  object WhiteBalanceVEdit: TNBFillEdit
    Tag = 2
    Left = 9
    Top = 215
    Width = 165
    Height = 21
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 16227430
    FillWidth = 85
    ArrowWidth = 15
    Title = 'White Balance V'
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
    OnValueChange = EditChange
    TabOrder = 9
  end
  object WhiteBalanceVAutoCB: TAprCheckBox
    Tag = 2
    Left = 188
    Top = 217
    Width = 15
    Height = 17
    TabOrder = 10
    TabStop = True
    OnClick = EditChange
  end
  object WhiteBalanceVOnePushCB: TAprCheckBox
    Tag = 2
    Left = 236
    Top = 218
    Width = 15
    Height = 17
    TabOrder = 11
    TabStop = True
    OnClick = EditChange
  end
  object BrightnessEdit: TNBFillEdit
    Tag = 2
    Left = 9
    Top = 242
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
    OnValueChange = EditChange
    TabOrder = 12
  end
  object BrightnessAutoCB: TAprCheckBox
    Tag = 2
    Left = 188
    Top = 244
    Width = 15
    Height = 17
    TabOrder = 13
    TabStop = True
    OnClick = EditChange
  end
  object BrightnessOnePushCB: TAprCheckBox
    Tag = 2
    Left = 236
    Top = 245
    Width = 15
    Height = 17
    TabOrder = 14
    TabStop = True
    OnClick = EditChange
  end
  object ExposureEdit: TNBFillEdit
    Tag = 2
    Left = 9
    Top = 268
    Width = 165
    Height = 21
    ArrowColor = 12615680
    BackGndColor = 16638434
    FillColor = 16227430
    FillWidth = 85
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
    OnValueChange = EditChange
    TabOrder = 15
  end
  object ExposureAutoCB: TAprCheckBox
    Tag = 2
    Left = 188
    Top = 270
    Width = 15
    Height = 17
    TabOrder = 16
    TabStop = True
    OnClick = EditChange
  end
  object ExposureOnePushCB: TAprCheckBox
    Tag = 2
    Left = 236
    Top = 271
    Width = 15
    Height = 17
    TabOrder = 17
    TabStop = True
    OnClick = EditChange
  end
  object ShowPixelsOverThresholdCB: TAprCheckBox
    Left = 288
    Top = 50
    Width = 150
    Height = 17
    Caption = 'Show pixels over threshold'
    TabOrder = 18
    TabStop = True
  end
  object Memo: TMemo
    Left = 5
    Top = 4
    Width = 264
    Height = 113
    Color = clInfoBk
    Lines.Strings = (
      'Please set the camera so that it works for your lighting '
      'conditions.'
      ''
      'Typically it is best to first reduce Brightness then '
      'Contrast and finally Exposure only if you have to.'
      ''
      'Please avoid using automatical control if possible, '
      'except maybe white balance.')
    TabOrder = 19
  end
  object CamBtn: TButton
    Left = 84
    Top = 298
    Width = 117
    Height = 22
    Caption = 'Camera properties'
    TabOrder = 20
    OnClick = CamBtnClick
  end
end
