object AvtSettingsFrm: TAvtSettingsFrm
  Left = 50
  Top = 163
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderStyle = bsDialog
  Caption = 'AVT driver settings'
  ClientHeight = 302
  ClientWidth = 277
  Color = 14076615
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
  object AutoPropertyLbl: TLabel
    Left = 184
    Top = 124
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
    Top = 124
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
  object GainEdit: TNBFillEdit
    Tag = 2
    Left = 9
    Top = 139
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
    TabOrder = 0
  end
  object GainAutoCB: TAprCheckBox
    Tag = 2
    Left = 188
    Top = 141
    Width = 15
    Height = 17
    TabOrder = 1
    TabStop = True
    OnClick = EditChange
  end
  object WhiteBalanceUEdit: TNBFillEdit
    Tag = 2
    Left = 9
    Top = 165
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
    TabOrder = 3
  end
  object WhiteBalanceUAutoCB: TAprCheckBox
    Tag = 2
    Left = 188
    Top = 167
    Width = 15
    Height = 17
    TabOrder = 4
    TabStop = True
    OnClick = EditChange
  end
  object WhiteBalanceVEdit: TNBFillEdit
    Tag = 2
    Left = 9
    Top = 191
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
    TabOrder = 6
  end
  object WhiteBalanceVAutoCB: TAprCheckBox
    Tag = 2
    Left = 188
    Top = 193
    Width = 15
    Height = 17
    TabOrder = 7
    TabStop = True
    OnClick = EditChange
  end
  object BrightnessEdit: TNBFillEdit
    Tag = 2
    Left = 9
    Top = 218
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
    TabOrder = 9
  end
  object BrightnessAutoCB: TAprCheckBox
    Tag = 2
    Left = 188
    Top = 220
    Width = 15
    Height = 17
    TabOrder = 10
    TabStop = True
    OnClick = EditChange
  end
  object ExposureEdit: TNBFillEdit
    Tag = 2
    Left = 9
    Top = 244
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
    TabOrder = 12
  end
  object ExposureAutoCB: TAprCheckBox
    Tag = 2
    Left = 188
    Top = 246
    Width = 15
    Height = 17
    TabOrder = 13
    TabStop = True
    OnClick = EditChange
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
    TabOrder = 15
  end
  object CamBtn: TButton
    Left = 84
    Top = 274
    Width = 117
    Height = 22
    Caption = 'Camera properties'
    TabOrder = 16
    OnClick = CamBtnClick
  end
  object GainOnePushBtn: TButton
    Tag = 2
    Left = 236
    Top = 142
    Width = 15
    Height = 17
    TabOrder = 2
    OnClick = GainOnePushBtnClick
  end
  object WhiteBalanceUOnePushBtn: TButton
    Tag = 2
    Left = 236
    Top = 168
    Width = 15
    Height = 17
    TabOrder = 5
    OnClick = WhiteBalanceUOnePushBtnClick
  end
  object WhiteBalanceVOnePushBtn: TButton
    Tag = 2
    Left = 236
    Top = 194
    Width = 15
    Height = 17
    TabOrder = 8
    OnClick = WhiteBalanceVOnePushBtnClick
  end
  object BrightnessOnePushBtn: TButton
    Tag = 2
    Left = 236
    Top = 221
    Width = 15
    Height = 17
    TabOrder = 11
    OnClick = BrightnessOnePushBtnClick
  end
  object ExposureOnePushBtn: TButton
    Tag = 2
    Left = 236
    Top = 247
    Width = 15
    Height = 17
    TabOrder = 14
    OnClick = ExposureOnePushBtnClick
  end
  object Timer: TTimer
    Enabled = False
    Left = 224
    Top = 80
  end
end
