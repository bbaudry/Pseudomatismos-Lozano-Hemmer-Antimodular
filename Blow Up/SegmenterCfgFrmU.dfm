object SegmenterCfgFrm: TSegmenterCfgFrm
  Left = 376
  Top = 235
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderStyle = bsDialog
  ClientHeight = 466
  ClientWidth = 629
  Color = 13815242
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 225
    Top = 15
    Width = 60
    Height = 13
    Caption = '= foreground'
  end
  object Shape1: TShape
    Left = 207
    Top = 15
    Width = 14
    Height = 14
    Brush.Color = clBlue
  end
  object MagPB: TPaintBox
    Left = 384
    Top = 37
    Width = 100
    Height = 100
    OnPaint = MagPBPaint
  end
  object XLcd: TLCD
    Left = 518
    Top = 40
    Width = 48
    Height = 24
    OffColor = 70
    SegWidth = 8
    SegHeight = 7
    LineWidth = 1
    Gap = 1
    Digits = 3
    ShowLead0 = False
    ShowSign = False
  end
  object YLcd: TLCD
    Left = 518
    Top = 72
    Width = 48
    Height = 24
    OffColor = 70
    SegWidth = 8
    SegHeight = 7
    LineWidth = 1
    Gap = 1
    Digits = 3
    ShowLead0 = False
    ShowSign = False
  end
  object XLbl: TLabel
    Left = 504
    Top = 46
    Width = 10
    Height = 13
    Caption = 'X:'
  end
  object YLbl: TLabel
    Left = 504
    Top = 78
    Width = 10
    Height = 13
    Caption = 'Y:'
  end
  object ILcd: TLCD
    Left = 518
    Top = 112
    Width = 48
    Height = 24
    OffColor = 70
    SegWidth = 8
    SegHeight = 7
    LineWidth = 1
    Gap = 1
    Digits = 3
    ShowLead0 = False
    ShowSign = False
  end
  object Label4: TLabel
    Left = 506
    Top = 118
    Width = 6
    Height = 13
    Caption = 'I:'
  end
  object Panel1: TPanel
    Left = 8
    Top = 7
    Width = 305
    Height = 181
    TabOrder = 0
    object CameraLbl: TLabel
      Left = 11
      Top = 8
      Width = 283
      Height = 14
      Alignment = taCenter
      AutoSize = False
      Caption = 'Camera'
      Color = 10983081
      ParentColor = False
    end
    object CamPB: TPaintBox
      Left = 15
      Top = 50
      Width = 160
      Height = 120
      OnMouseDown = PaintBoxMouseDown
      OnMouseMove = PaintBoxMouseMove
      OnPaint = CamPBPaint
    end
    object CamBtn: TButton
      Left = 204
      Top = 116
      Width = 33
      Height = 25
      Caption = 'Cam'
      TabOrder = 0
      OnClick = CamBtnClick
    end
    object PinBtn: TButton
      Left = 244
      Top = 116
      Width = 33
      Height = 25
      Caption = 'Pin'
      TabOrder = 1
      OnClick = PinBtnClick
    end
    object CamSettingsBtn: TButton
      Left = 202
      Top = 87
      Width = 75
      Height = 24
      Caption = 'Settings'
      TabOrder = 2
      OnClick = CamSettingsBtnClick
    end
    object CropWindowBtn: TBitBtn
      Left = 187
      Top = 145
      Width = 106
      Height = 27
      Caption = 'Crop window'
      TabOrder = 3
      OnClick = CropWindowBtnClick
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        7777777777777777777777770000777777777777777777777777777777777777
        0000777077777777707777777877777777787777000077787777777778777777
        7777777777777777000070808080808080807778787878787878787700007778
        8888888888777777777777777777777700007770888888888077777778777777
        7778777700007778888888888877777777777777777777770000777088888888
        8077777778777777777877770000777888888888887777777777777777777777
        0000777088888888807777777877777777787777000077788888888888777777
        7777777777777777000077708888888880777777787777777778777700007778
        8888888888777777777777777777777700007080808080808080777878787878
        7878787700007778777777777877777777777777777777770000777077777777
        7077777778777777777877770000777777777777777777777777777777777777
        0000}
      NumGlyphs = 2
    end
    object UseITableCB: TAprCheckBox
      Left = 17
      Top = 27
      Width = 190
      Height = 17
      Caption = 'Compensate for radial intensity drop'
      TabOrder = 4
      TabStop = True
      OnClick = UseITableCBClick
    end
    object FlipImageCB: TAprCheckBox
      Left = 201
      Top = 45
      Width = 72
      Height = 17
      Caption = 'Flip image'
      TabOrder = 5
      TabStop = True
      OnClick = FlipImageCBClick
    end
    object MirrorImageCB: TAprCheckBox
      Left = 201
      Top = 64
      Width = 80
      Height = 17
      Caption = 'Mirror image'
      TabOrder = 6
      TabStop = True
      OnClick = MirrorImageCBClick
    end
  end
  object Panel2: TPanel
    Left = 8
    Top = 195
    Width = 305
    Height = 265
    TabOrder = 1
    object ThresholdLbl: TLabel
      Left = 37
      Top = 161
      Width = 50
      Height = 13
      Caption = 'Threshold:'
    end
    object TimeLbl: TLabel
      Left = 25
      Top = 212
      Width = 62
      Height = 13
      Caption = 'Max FG time:'
    end
    object SegmenterLbl: TLabel
      Left = 19
      Top = 8
      Width = 238
      Height = 14
      Alignment = taCenter
      AutoSize = False
      Caption = 'Segmenter'
      Color = 10983081
      ParentColor = False
    end
    object SegmenterPB: TPaintBox
      Left = 17
      Top = 28
      Width = 160
      Height = 120
      OnMouseDown = PaintBoxMouseDown
      OnMouseMove = PaintBoxMouseMove
      OnPaint = SegmenterPBPaint
    end
    object BackGndShape: TShape
      Left = 211
      Top = 164
      Width = 14
      Height = 14
      Brush.Color = clBlack
    end
    object BackGndLbl: TLabel
      Left = 229
      Top = 164
      Width = 66
      Height = 13
      Caption = '= background'
    end
    object ForeGroundShape: TShape
      Left = 211
      Top = 182
      Width = 14
      Height = 14
      Brush.Color = clBlue
    end
    object ForeGndLbl: TLabel
      Left = 229
      Top = 182
      Width = 60
      Height = 13
      Caption = '= foreground'
    end
    object Label2: TLabel
      Left = 229
      Top = 200
      Width = 50
      Height = 13
      Caption = '= sampling'
    end
    object Shape2: TShape
      Left = 211
      Top = 200
      Width = 14
      Height = 14
      Brush.Color = clRed
    end
    object DriftThresholdLbl: TLabel
      Left = 15
      Top = 186
      Width = 72
      Height = 13
      Caption = 'Drift Threshold:'
    end
    object ThresholdEdit: TAprSpinEdit
      Left = 89
      Top = 158
      Width = 48
      Height = 20
      Value = 3.000000000000000000
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = ThresholdEditChange
      Increment = 1.000000000000000000
      EditText = '3'
      TabOrder = 0
    end
    object MaxFGTimeEdit: TAprSpinEdit
      Left = 89
      Top = 208
      Width = 48
      Height = 20
      Value = 99.900001525878910000
      Decimals = 1
      Max = 99.900001525878910000
      Alignment = taCenter
      Enabled = True
      OnChange = MaxFGTimeEditChange
      Increment = 1.000000000000000000
      EditText = '99.9'
      TabOrder = 1
    end
    object MeanRB: TRadioButton
      Left = 190
      Top = 43
      Width = 73
      Height = 17
      Caption = 'Averaged'
      TabOrder = 2
    end
    object ThresholdedRB: TRadioButton
      Left = 190
      Top = 93
      Width = 81
      Height = 17
      Caption = 'Thresholded'
      TabOrder = 3
    end
    object StatesRB: TRadioButton
      Left = 190
      Top = 147
      Width = 81
      Height = 17
      Caption = 'States'
      TabOrder = 4
    end
    object Button1: TButton
      Left = 24
      Top = 238
      Width = 129
      Height = 21
      Caption = 'Force all to background'
      TabOrder = 5
      OnClick = SetBackGndBtnClick
    end
    object DeviationRB: TRadioButton
      Left = 190
      Top = 76
      Width = 73
      Height = 17
      Caption = 'Deviation'
      TabOrder = 6
    end
    object IntensityRB: TRadioButton
      Left = 190
      Top = 26
      Width = 67
      Height = 17
      Caption = 'Intensity'
      Checked = True
      TabOrder = 7
      TabStop = True
    end
    object DelayCB: TAprCheckBox
      Left = 164
      Top = 240
      Width = 63
      Height = 17
      State = cbChecked
      Caption = 'Delay 5s'
      Checked = True
      TabOrder = 8
      TabStop = True
    end
    object BackGndAvgRB: TRadioButton
      Left = 190
      Top = 60
      Width = 99
      Height = 17
      Caption = 'Background avg'
      TabOrder = 9
    end
    object AgesRB: TRadioButton
      Left = 190
      Top = 129
      Width = 113
      Height = 17
      Caption = 'Ages'
      TabOrder = 10
    end
    object DriftThresholdEdit: TAprSpinEdit
      Left = 89
      Top = 183
      Width = 48
      Height = 20
      Value = 3.000000000000000000
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = DriftThresholdEditChange
      Increment = 1.000000000000000000
      EditText = '3'
      TabOrder = 11
    end
    object SegmenterHelpBtn: TBitBtn
      Left = 264
      Top = 8
      Width = 25
      Height = 25
      TabOrder = 12
      OnClick = SegmenterHelpBtnClick
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333FFFFF3333333333F797F3333333333F737373FF333333BFB999BFB
        33333337737773773F3333BFBF797FBFB33333733337333373F33BFBFBFBFBFB
        FB3337F33333F33337F33FBFBFB9BFBFBF3337333337F333373FFBFBFBF97BFB
        FBF37F333337FF33337FBFBFBFB99FBFBFB37F3333377FF3337FFBFBFBFB99FB
        FBF37F33333377FF337FBFBF77BF799FBFB37F333FF3377F337FFBFB99FB799B
        FBF373F377F3377F33733FBF997F799FBF3337F377FFF77337F33BFBF99999FB
        FB33373F37777733373333BFBF999FBFB3333373FF77733F7333333BFBFBFBFB
        3333333773FFFF77333333333FBFBF3333333333377777333333}
      NumGlyphs = 2
    end
    object DriftingRB: TRadioButton
      Left = 190
      Top = 111
      Width = 81
      Height = 17
      Caption = 'Drifting'
      TabOrder = 13
    end
  end
  object Panel3: TPanel
    Left = 321
    Top = 178
    Width = 300
    Height = 281
    TabOrder = 2
    object Label9: TLabel
      Left = 11
      Top = 8
      Width = 278
      Height = 14
      Alignment = taCenter
      AutoSize = False
      Caption = 'Tracker'
      Color = 10983081
      ParentColor = False
    end
    object TrackerPB: TPaintBox
      Left = 16
      Top = 28
      Width = 160
      Height = 120
      OnMouseDown = PaintBoxMouseDown
      OnMouseMove = PaintBoxMouseMove
      OnPaint = TrackerPBPaint
    end
    object TrackerPercentageLbl: TLabel
      Left = 15
      Top = 163
      Width = 58
      Height = 13
      Caption = 'Percentage:'
    end
    object TriggerAgeLbl: TLabel
      Left = 15
      Top = 187
      Width = 57
      Height = 13
      Caption = 'Trigger age:'
    end
    object UntriggerAgeLbl: TLabel
      Left = 15
      Top = 211
      Width = 67
      Height = 13
      Caption = 'Untrigger age:'
    end
    object ShowLbl: TLabel
      Left = 185
      Top = 28
      Width = 100
      Height = 15
      Alignment = taCenter
      AutoSize = False
      Caption = 'Show'
      Color = 11312277
      ParentColor = False
    end
    object TrackerPercentageEdit: TAprSpinEdit
      Left = 84
      Top = 158
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = TrackerPercentageEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
    object TriggerAgeEdit: TAprSpinEdit
      Left = 84
      Top = 182
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = TriggerAgeEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
    object UntriggerAgeEdit: TAprSpinEdit
      Left = 84
      Top = 206
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = UntriggerAgeEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 2
    end
    object DilateCB: TAprCheckBox
      Left = 17
      Top = 232
      Width = 67
      Height = 17
      Caption = 'Dilate R='
      TabOrder = 3
      TabStop = True
      OnClick = DilateCBClick
    end
    object DilateREdit: TAprSpinEdit
      Left = 84
      Top = 230
      Width = 48
      Height = 20
      Value = 1.000000000000000000
      Decimals = 1
      Min = 0.800000011920928900
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = DilateREditChange
      Increment = 0.100000001490116100
      EditText = '1.0'
      TabOrder = 4
    end
    object ShowCellOutlinesCB: TAprCheckBox
      Left = 196
      Top = 85
      Width = 97
      Height = 17
      Caption = 'Outlines of cells'
      TabOrder = 5
      TabStop = True
      OnClick = ShowCBClick
    end
    object ShowCoveredCellsCB: TAprCheckBox
      Left = 196
      Top = 103
      Width = 97
      Height = 17
      Caption = 'Covered cells'
      TabOrder = 6
      TabStop = True
      OnClick = ShowCBClick
    end
    object ShowTriggeredCellsCB: TAprCheckBox
      Left = 196
      Top = 139
      Width = 97
      Height = 17
      Caption = 'Triggered cells'
      TabOrder = 7
      TabStop = True
      OnClick = ShowCBClick
    end
    object ShowActiveCellsCB: TAprCheckBox
      Left = 196
      Top = 157
      Width = 97
      Height = 17
      Caption = 'Active cells'
      TabOrder = 8
      TabStop = True
      OnClick = ShowCBClick
    end
    object FillInteriorCB: TAprCheckBox
      Left = 147
      Top = 201
      Width = 67
      Height = 17
      Caption = 'Fill interior'
      TabOrder = 9
      TabStop = True
      OnClick = FillInteriorCBClick
    end
    object AvgCellIRB: TRadioButton
      Left = 184
      Top = 48
      Width = 87
      Height = 17
      Caption = 'Average cell I'
      TabOrder = 10
    end
    object TrackingInfoRB: TRadioButton
      Left = 184
      Top = 66
      Width = 87
      Height = 17
      Caption = 'Tracking info'
      Checked = True
      TabOrder = 11
      TabStop = True
    end
    object SuppressLoneCellsCB: TAprCheckBox
      Left = 147
      Top = 223
      Width = 133
      Height = 17
      Caption = 'Suppress lone cells'
      TabOrder = 12
      TabStop = True
      OnClick = SuppressLoneCellsCBClick
    end
    object SupressIslandsCB: TAprCheckBox
      Left = 17
      Top = 254
      Width = 149
      Height = 17
      Caption = 'Supress islands with area <'
      TabOrder = 13
      TabStop = True
      OnClick = SupressIslandsCBClick
    end
    object MinBlobAreaEdit: TAprSpinEdit
      Left = 169
      Top = 251
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = MinBlobAreaEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 14
    end
    object ShowBlobsCB: TAprCheckBox
      Left = 196
      Top = 121
      Width = 85
      Height = 17
      Caption = 'Non-islands'
      TabOrder = 15
      TabStop = True
      OnClick = ShowCBClick
    end
    object ShowOutlinesCB: TAprCheckBox
      Left = 196
      Top = 175
      Width = 69
      Height = 17
      Caption = 'Outlines'
      TabOrder = 16
      TabStop = True
      OnClick = ShowCBClick
    end
  end
  object DelayTimer: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = DelayTimerTimer
    Left = 144
    Top = 143
  end
end
