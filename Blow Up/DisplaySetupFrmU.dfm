object DisplaySetupFrm: TDisplaySetupFrm
  Left = 1637
  Top = 147
  BorderStyle = bsDialog
  Caption = 'Setup display'
  ClientHeight = 347
  ClientWidth = 760
  Color = 13749200
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object DoneBtn: TButton
    Left = 672
    Top = 307
    Width = 75
    Height = 31
    Caption = 'Done'
    TabOrder = 7
    OnClick = DoneBtnClick
  end
  object DisplayPanel: TPanel
    Left = 7
    Top = 7
    Width = 290
    Height = 268
    TabOrder = 0
    object RowsLbl: TLabel
      Left = 145
      Top = 63
      Width = 53
      Height = 13
      Caption = 'columns by'
    end
    object ColumnsLbl: TLabel
      Left = 20
      Top = 63
      Width = 67
      Height = 13
      Caption = 'Maximum grid:'
    end
    object Label4: TLabel
      Left = 8
      Top = 6
      Width = 273
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'Display settings'
      Color = 12891050
      ParentColor = False
    end
    object Label25: TLabel
      Left = 185
      Top = 32
      Width = 40
      Height = 13
      Caption = 'seconds'
    end
    object Label29: TLabel
      Left = 257
      Top = 63
      Width = 22
      Height = 13
      Caption = 'rows'
    end
    object Label30: TLabel
      Left = 23
      Top = 89
      Width = 64
      Height = 13
      Caption = 'Minimum grid:'
    end
    object Label10: TLabel
      Left = 145
      Top = 90
      Width = 53
      Height = 13
      Caption = 'columns by'
    end
    object Label31: TLabel
      Left = 257
      Top = 90
      Width = 22
      Height = 13
      Caption = 'rows'
    end
    object Label35: TLabel
      Left = 32
      Top = 241
      Width = 82
      Height = 13
      Caption = 'Collapse Y offset:'
    end
    object ViewCamIdleYBtn: TSpeedButton
      Left = 179
      Top = 237
      Width = 57
      Height = 22
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'View'
      Glyph.Data = {
        BE000000424DBE0000000000000076000000280000000D000000090000000100
        0400000000004800000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00666666666666
        600066660000066660006600F7E7F006600060FF7C4C7FF060000FFFE404EFFF
        000060FF7C4C7FF060006600F7E7F00660006606000006066000666606060666
        6000}
      OnClick = ViewCamIdleYBtnClick
    end
    object XCells1Edit: TAprSpinEdit
      Left = 91
      Top = 59
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = XCells1EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 2
    end
    object YCells1Edit: TAprSpinEdit
      Left = 203
      Top = 60
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = YCells1EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 3
    end
    object GroupBox1: TGroupBox
      Left = 16
      Top = 111
      Width = 257
      Height = 121
      Caption = 'SuperCells'
      TabOrder = 6
      object Label26: TLabel
        Left = 12
        Top = 71
        Width = 54
        Height = 13
        Caption = 'Make up to'
      end
      object Label27: TLabel
        Left = 124
        Top = 71
        Width = 118
        Height = 13
        Caption = 'supercells measuring 2x2'
      end
      object Label13: TLabel
        Left = 124
        Top = 47
        Width = 118
        Height = 13
        Caption = 'supercells measuring 1x2'
      end
      object Label11: TLabel
        Left = 12
        Top = 47
        Width = 54
        Height = 13
        Caption = 'Make up to'
      end
      object Label8: TLabel
        Left = 12
        Top = 23
        Width = 54
        Height = 13
        Caption = 'Make up to'
      end
      object Label9: TLabel
        Left = 124
        Top = 23
        Width = 118
        Height = 13
        Caption = 'supercells measuring 2x1'
      end
      object Label23: TLabel
        Left = 38
        Top = 97
        Width = 87
        Height = 13
        Caption = 'Scale for hi-res by:'
      end
      object SuperCell2x2Edit: TAprSpinEdit
        Left = 71
        Top = 67
        Width = 48
        Height = 20
        Max = 255.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = SuperCell2x2EditChange
        Increment = 1.000000000000000000
        EditText = '0'
        TabOrder = 0
      end
      object SuperCell1x2Edit: TAprSpinEdit
        Left = 71
        Top = 43
        Width = 48
        Height = 20
        Max = 255.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = SuperCell1x2EditChange
        Increment = 1.000000000000000000
        EditText = '0'
        TabOrder = 1
      end
      object SuperCell2x1Edit: TAprSpinEdit
        Left = 71
        Top = 19
        Width = 48
        Height = 20
        Max = 255.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = SuperCell2x1EditChange
        Increment = 1.000000000000000000
        EditText = '0'
        TabOrder = 2
      end
      object SuperCellScaleEdit: TAprSpinEdit
        Left = 128
        Top = 93
        Width = 48
        Height = 20
        Min = 1.000000000000000000
        Max = 20.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = SuperCellScaleEditChange
        Increment = 1.000000000000000000
        EditText = '0'
        TabOrder = 3
      end
    end
    object GridPeriodEdit: TAprSpinEdit
      Left = 125
      Top = 28
      Width = 54
      Height = 20
      Decimals = 1
      Min = 0.100000001490116100
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = GridPeriodEditChange
      Increment = 0.100000001490116100
      EditText = '0.0'
      TabOrder = 1
    end
    object DynamicGridCB: TAprCheckBox
      Left = 12
      Top = 29
      Width = 107
      Height = 17
      Caption = 'Change grid every'
      TabOrder = 0
      TabStop = True
      OnClick = DynamicGridCBClick
    end
    object XCells2Edit: TAprSpinEdit
      Left = 92
      Top = 86
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = XCells2EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 4
    end
    object YCells2Edit: TAprSpinEdit
      Left = 202
      Top = 88
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = YCells2EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 5
    end
    object CamIdleYEdit: TAprSpinEdit
      Left = 116
      Top = 237
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = CamIdleYEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 7
    end
  end
  object OutlinePanel: TPanel
    Left = 8
    Top = 281
    Width = 290
    Height = 58
    TabOrder = 1
    object Label12: TLabel
      Left = 8
      Top = 6
      Width = 273
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'Outline'
      Color = 12891050
      ParentColor = False
    end
    object GridShape: TShape
      Left = 49
      Top = 27
      Width = 35
      Height = 21
    end
    object Label5: TLabel
      Left = 16
      Top = 31
      Width = 27
      Height = 13
      Caption = 'Color:'
    end
    object WidthLbl: TLabel
      Left = 188
      Top = 32
      Width = 31
      Height = 13
      Caption = 'Width:'
    end
    object OutlineColorBtn: TBitBtn
      Left = 93
      Top = 26
      Width = 78
      Height = 24
      Caption = 'Change color'
      TabOrder = 0
      OnClick = OutlineColorBtnClick
    end
    object GridWidthEdit: TAprSpinEdit
      Left = 224
      Top = 28
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = GridWidthEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
  end
  object BlowUpAnimationPanel: TPanel
    Left = 303
    Top = 281
    Width = 193
    Height = 58
    TabOrder = 4
    object Label1: TLabel
      Left = 8
      Top = 6
      Width = 177
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'BlowUp animation'
      Color = 12891050
      ParentColor = False
    end
    object Label2: TLabel
      Left = 14
      Top = 30
      Width = 71
      Height = 13
      Caption = 'Transition time:'
    end
    object Label6: TLabel
      Left = 138
      Top = 30
      Width = 40
      Height = 13
      Caption = 'seconds'
    end
    object TransitionTimeEdit: TAprSpinEdit
      Left = 87
      Top = 26
      Width = 48
      Height = 20
      Value = 9.899999618530273000
      Decimals = 1
      Min = 0.100000001490116100
      Max = 9.899999618530273000
      Alignment = taCenter
      Enabled = True
      OnChange = TransitionTimeEditChange
      Increment = 1.000000000000000000
      EditText = '9.9'
      TabOrder = 0
    end
  end
  object BlowUpTriggerPanel: TPanel
    Left = 303
    Top = 8
    Width = 290
    Height = 145
    TabOrder = 2
    object Label3: TLabel
      Left = 8
      Top = 6
      Width = 273
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'BlowUp trigger'
      Color = 12891050
      ParentColor = False
    end
    object Label15: TLabel
      Left = 21
      Top = 32
      Width = 61
      Height = 13
      Caption = 'Trigger level:'
    end
    object Label16: TLabel
      Left = 11
      Top = 58
      Width = 71
      Height = 13
      Caption = 'Untrigger level:'
    end
    object Label28: TLabel
      Left = 189
      Top = 113
      Width = 92
      Height = 13
      Caption = 'seconds of blow-up'
    end
    object Label24: TLabel
      Left = 12
      Top = 84
      Width = 85
      Height = 13
      Caption = 'Delay untrigger by'
    end
    object Label32: TLabel
      Left = 155
      Top = 83
      Width = 40
      Height = 13
      Caption = 'seconds'
    end
    object TriggerLevelEdit: TAprSpinEdit
      Left = 84
      Top = 28
      Width = 50
      Height = 20
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = TriggerLevelEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
    object UntriggerLevelEdit: TAprSpinEdit
      Left = 85
      Top = 54
      Width = 50
      Height = 20
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = UntriggerLevelEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
    object ForceUntriggerCB: TAprCheckBox
      Left = 11
      Top = 112
      Width = 131
      Height = 17
      Caption = 'Force an untrigger after'
      TabOrder = 4
      TabStop = True
      OnClick = ForceUntriggerCBClick
    end
    object ForceUntriggerDelayEdit: TAprSpinEdit
      Left = 143
      Top = 110
      Width = 42
      Height = 20
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = ForceUntriggerDelayEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 5
    end
    object Panel1: TPanel
      Left = 183
      Top = 25
      Width = 73
      Height = 45
      TabOrder = 2
      object Label18: TLabel
        Left = 6
        Top = 2
        Width = 62
        Height = 13
        Caption = 'Current level:'
      end
      object CurrentLevelLCD: TLCD
        Left = 17
        Top = 18
        Width = 38
        Height = 21
        OffColor = 45
        SegWidth = 7
        SegHeight = 6
        LineWidth = 1
        Gap = 1
        Digits = 3
        ShowLead0 = False
        Value = 255
        ShowSign = False
      end
    end
    object UntriggerDelayEdit: TAprSpinEdit
      Left = 104
      Top = 80
      Width = 46
      Height = 20
      Value = 999.000000000000000000
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = UntriggerDelayEditChange
      Increment = 1.000000000000000000
      EditText = '999'
      TabOrder = 3
    end
  end
  object BlowUpTargetPanel: TPanel
    Left = 303
    Top = 156
    Width = 290
    Height = 119
    Color = 13291474
    TabOrder = 3
    object Label20: TLabel
      Left = 8
      Top = 6
      Width = 273
      Height = 14
      Alignment = taCenter
      AutoSize = False
      Caption = 'BlowUp to'
      Color = 12891050
      ParentColor = False
    end
    object Label21: TLabel
      Left = 264
      Top = 38
      Width = 8
      Height = 13
      Caption = '%'
    end
    object TenactiyLbl: TLabel
      Left = 153
      Top = 72
      Width = 44
      Height = 13
      Caption = 'Tenactiy:'
    end
    object BlowUpToBestBlobRB: TRadioButton
      Left = 19
      Top = 24
      Width = 102
      Height = 17
      Caption = 'Dominant blob'
      TabOrder = 0
      OnClick = BlowUpToBestBlobRBClick
    end
    object BlowUpToForeGndRB: TRadioButton
      Left = 19
      Top = 42
      Width = 78
      Height = 17
      Caption = 'Foreground'
      TabOrder = 1
      OnClick = BlowUpToForeGndRBClick
    end
    object BlowUpToBackGndRB: TRadioButton
      Left = 19
      Top = 61
      Width = 78
      Height = 17
      Caption = 'Background'
      TabOrder = 2
      OnClick = BlowUpToBackGndRBClick
    end
    object BlowUpToAnythingRB: TRadioButton
      Left = 19
      Top = 79
      Width = 78
      Height = 17
      Caption = 'Anything'
      TabOrder = 3
      OnClick = BlowUpToAnythingRBClick
    end
    object KeepBlowUpYCB: TAprCheckBox
      Left = 127
      Top = 37
      Width = 81
      Height = 17
      Caption = 'Keep y within'
      TabOrder = 5
      TabStop = True
      OnClick = KeepBlowUpYCBClick
    end
    object BlowUpYFractionEdit: TAprSpinEdit
      Left = 212
      Top = 34
      Width = 48
      Height = 20
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = BlowUpYFractionEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 6
    end
    object TenacityEdit: TAprSpinEdit
      Left = 200
      Top = 68
      Width = 50
      Height = 20
      Min = 1.000000000000000000
      Max = 20.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = TenacityEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 7
    end
    object BlowUpToZoomRB: TRadioButton
      Left = 19
      Top = 98
      Width = 54
      Height = 12
      Caption = 'Zoom'
      TabOrder = 4
      OnClick = BlowUpToZoomRBClick
    end
  end
  object BlowUpParametersPanel: TPanel
    Left = 600
    Top = 8
    Width = 153
    Height = 288
    TabOrder = 6
    object Label14: TLabel
      Left = 8
      Top = 7
      Width = 136
      Height = 14
      Alignment = taCenter
      AutoSize = False
      Caption = 'BlowUp parameters'
      Color = 12891050
      ParentColor = False
    end
    object Label17: TLabel
      Left = 22
      Top = 37
      Width = 41
      Height = 13
      Caption = 'Min size:'
    end
    object MinLevelLbl: TLabel
      Left = 22
      Top = 89
      Width = 45
      Height = 13
      Caption = 'Min level:'
    end
    object Label19: TLabel
      Left = 22
      Top = 62
      Width = 44
      Height = 13
      Caption = 'Max size:'
    end
    object MinSizeEdit: TAprSpinEdit
      Left = 73
      Top = 33
      Width = 46
      Height = 20
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = MinSizeEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
    object KeepAspectCB: TAprCheckBox
      Left = 14
      Top = 119
      Width = 124
      Height = 17
      Caption = 'Maintain aspect ratio'
      TabOrder = 3
      TabStop = True
      OnClick = KeepAspectCBClick
    end
    object MinLevelEdit: TAprSpinEdit
      Left = 73
      Top = 85
      Width = 46
      Height = 20
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = MinLevelEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 2
    end
    object MaxSizeEdit: TAprSpinEdit
      Left = 73
      Top = 59
      Width = 46
      Height = 20
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = MaxSizeEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
    object FollowPanel: TPanel
      Left = 8
      Top = 147
      Width = 137
      Height = 133
      TabOrder = 4
      object AveragesLbl: TLabel
        Left = 18
        Top = 30
        Width = 57
        Height = 13
        Caption = 'X averages:'
      end
      object Label7: TLabel
        Left = 18
        Top = 54
        Width = 57
        Height = 13
        Caption = 'Y averages:'
      end
      object Label33: TLabel
        Left = 18
        Top = 78
        Width = 55
        Height = 13
        Caption = 'Max speed:'
      end
      object Label34: TLabel
        Left = 18
        Top = 107
        Width = 69
        Height = 13
        Caption = 'Current speed:'
      end
      object SpeedLcd: TLCD
        Left = 90
        Top = 102
        Width = 38
        Height = 21
        OffColor = 45
        SegWidth = 7
        SegHeight = 6
        LineWidth = 1
        Gap = 1
        Digits = 3
        ShowLead0 = False
        Value = 255
        ShowSign = False
      end
      object TrackerEnabledCB: TAprCheckBox
        Left = 6
        Top = 7
        Width = 50
        Height = 17
        Caption = 'Follow'
        TabOrder = 0
        TabStop = True
        OnClick = TrackerEnabledCBClick
      end
      object TrackerXAveragesEdit: TAprSpinEdit
        Left = 78
        Top = 27
        Width = 46
        Height = 20
        Min = 1.000000000000000000
        Max = 64.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = TrackerXAveragesEditChange
        Increment = 1.000000000000000000
        EditText = '0'
        TabOrder = 1
      end
      object TrackerYAveragesEdit: TAprSpinEdit
        Left = 78
        Top = 51
        Width = 46
        Height = 20
        Min = 1.000000000000000000
        Max = 64.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = TrackerYAveragesEditChange
        Increment = 1.000000000000000000
        EditText = '0'
        TabOrder = 2
      end
      object TrackerMaxSpeedEdit: TAprSpinEdit
        Left = 78
        Top = 75
        Width = 46
        Height = 20
        Min = 1.000000000000000000
        Max = 64.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = TrackerMaxSpeedEditChange
        Increment = 1.000000000000000000
        EditText = '0'
        TabOrder = 3
      end
    end
  end
  object BlowUpHelpPanel: TPanel
    Left = 502
    Top = 281
    Width = 91
    Height = 58
    TabOrder = 5
    object Label22: TLabel
      Left = 8
      Top = 6
      Width = 75
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'BlowUp help'
      Color = 12891050
      ParentColor = False
    end
    object BlowUpHelpBtn: TBitBtn
      Left = 33
      Top = 26
      Width = 25
      Height = 25
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
      TabOrder = 0
      OnClick = BlowUpHelpBtnClick
    end
  end
  object ColorDlg: TColorDialog
    Left = 415
    Top = 240
  end
end
