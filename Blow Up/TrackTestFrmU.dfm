object TrackTestFrm: TTrackTestFrm
  Left = 1656
  Top = 633
  BorderStyle = bsSingle
  Caption = 'Tracking Test'
  ClientHeight = 700
  ClientWidth = 782
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 208
    Top = 555
    Width = 50
    Height = 13
    Caption = 'Pen width:'
  end
  object MainPanel: TPanel
    Left = 8
    Top = 7
    Width = 768
    Height = 530
    Color = 13553358
    TabOrder = 0
    object PaintBox: TPaintBox
      Tag = 1
      Left = 6
      Top = 44
      Width = 640
      Height = 480
      OnMouseDown = PaintBoxMouseDown
      OnMouseMove = PaintBoxMouseMove
      OnPaint = PaintBoxPaint
    end
    object MagPB: TPaintBox
      Tag = 1
      Left = 654
      Top = 44
      Width = 105
      Height = 105
    end
    object Label12: TLabel
      Left = 10
      Top = 17
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object XLcd: TLCD
      Left = 24
      Top = 10
      Width = 50
      Height = 25
      OffColor = 45
      SegWidth = 7
      SegHeight = 7
      LineWidth = 1
      Gap = 1
      Digits = 3
      ShowLead0 = False
      Value = 255
      ShowSign = False
    end
    object Label13: TLabel
      Left = 87
      Top = 17
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object YLcd: TLCD
      Left = 101
      Top = 10
      Width = 50
      Height = 25
      OffColor = 45
      SegWidth = 7
      SegHeight = 7
      LineWidth = 1
      Gap = 1
      Digits = 3
      ShowLead0 = False
      Value = 255
      ShowSign = False
    end
    object Label16: TLabel
      Left = 164
      Top = 16
      Width = 6
      Height = 13
      Caption = 'I:'
    end
    object ILcd: TLCD
      Left = 176
      Top = 10
      Width = 50
      Height = 25
      OffColor = 45
      SegWidth = 7
      SegHeight = 7
      LineWidth = 1
      Gap = 1
      Digits = 3
      ShowLead0 = False
      Value = 255
      ShowSign = False
    end
    object DrawBackGndPanel: TPanel
      Left = 652
      Top = 171
      Width = 109
      Height = 102
      Color = 13685705
      TabOrder = 0
      object Label11: TLabel
        Left = 7
        Top = 8
        Width = 96
        Height = 14
        Alignment = taCenter
        AutoSize = False
        Caption = 'Background'
        Color = 11511183
        ParentColor = False
      end
      object NormalRB: TRadioButton
        Left = 10
        Top = 26
        Width = 57
        Height = 17
        Caption = 'Normal'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object BackGndRB: TRadioButton
        Left = 10
        Top = 43
        Width = 81
        Height = 17
        Caption = 'Background'
        TabOrder = 1
      end
      object SubtractedRB: TRadioButton
        Left = 10
        Top = 61
        Width = 77
        Height = 17
        Caption = 'Subtracted'
        TabOrder = 2
      end
      object AccumulatedCB: TAprCheckBox
        Left = 20
        Top = 80
        Width = 83
        Height = 17
        Caption = 'Accumulated'
        TabOrder = 3
        TabStop = True
        OnClick = AccumulatedCBClick
      end
    end
    object DrawForeGndPanel: TPanel
      Left = 651
      Top = 282
      Width = 110
      Height = 202
      Color = 13685705
      TabOrder = 1
      object Label14: TLabel
        Left = 6
        Top = 8
        Width = 98
        Height = 14
        Alignment = taCenter
        AutoSize = False
        Caption = 'Foreground'
        Color = 11511183
        ParentColor = False
      end
      object TrackThresholdsRB: TRadioButton
        Left = 7
        Top = 65
        Width = 99
        Height = 17
        Caption = 'Track thresholds'
        TabOrder = 2
        TabStop = True
      end
      object TrackingViewRB: TRadioButton
        Left = 7
        Top = 82
        Width = 83
        Height = 17
        Caption = 'Tracking info'
        Checked = True
        TabOrder = 3
        TabStop = True
      end
      object StripsCB: TAprCheckBox
        Left = 21
        Top = 101
        Width = 47
        Height = 17
        State = cbChecked
        Caption = 'Strips'
        Checked = True
        TabOrder = 4
        TabStop = True
      end
      object BlobsCB: TAprCheckBox
        Left = 21
        Top = 138
        Width = 57
        Height = 17
        State = cbChecked
        Caption = 'Blobs'
        Checked = True
        TabOrder = 5
        TabStop = True
      end
      object BackGndThresholdsRB: TRadioButton
        Left = 7
        Top = 46
        Width = 99
        Height = 17
        Caption = 'Back thresholds'
        TabOrder = 1
        TabStop = True
      end
      object BlobOutlinesCB: TAprCheckBox
        Left = 21
        Top = 159
        Width = 84
        Height = 17
        State = cbChecked
        Caption = 'Blob outlines'
        Checked = True
        TabOrder = 6
        TabStop = True
      end
      object BackGndStatusRB: TRadioButton
        Left = 7
        Top = 27
        Width = 99
        Height = 17
        Caption = 'Backgnd status'
        TabOrder = 0
        TabStop = True
      end
      object CellWindowsCB: TAprCheckBox
        Left = 21
        Top = 180
        Width = 82
        Height = 17
        Caption = 'Cell windows'
        TabOrder = 7
        TabStop = True
      end
      object ColorStripsCB: TAprCheckBox
        Left = 37
        Top = 117
        Width = 47
        Height = 17
        State = cbChecked
        Caption = 'Color'
        Checked = True
        TabOrder = 8
        TabStop = True
      end
    end
  end
  object BackGndPanel: TPanel
    Left = 176
    Top = 583
    Width = 313
    Height = 106
    Color = 14075584
    TabOrder = 2
    object BackGndFinderLbl: TLabel
      Left = 8
      Top = 8
      Width = 297
      Height = 14
      Alignment = taCenter
      AutoSize = False
      Caption = 'Background'
      Color = 10667934
      ParentColor = False
    end
    object Label8: TLabel
      Left = 27
      Top = 53
      Width = 50
      Height = 13
      Caption = 'Threshold:'
    end
    object Label10: TLabel
      Left = 34
      Top = 78
      Width = 42
      Height = 13
      Caption = 'Min time:'
    end
    object Label1: TLabel
      Left = 134
      Top = 78
      Width = 11
      Height = 13
      Caption = '(s)'
    end
    object ForceBackGndBtn: TButton
      Left = 171
      Top = 36
      Width = 129
      Height = 21
      Caption = 'Force all to background'
      TabOrder = 3
      OnClick = ForceBackGndBtnClick
    end
    object DelayCB: TAprCheckBox
      Left = 183
      Top = 62
      Width = 105
      Height = 17
      Caption = 'Delay 5 seconds'
      TabOrder = 4
      TabStop = True
    end
    object BackGndFinderThresholdEdit: TAprSpinEdit
      Left = 80
      Top = 49
      Width = 50
      Height = 20
      Min = 1.000000000000000000
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = BackGndFinderThresholdEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
    object BackGndFinderMinTimeEdit: TAprSpinEdit
      Left = 80
      Top = 74
      Width = 50
      Height = 20
      Min = 1.000000000000000000
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = BackGndFinderMinTimeEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 2
    end
    object BackGndFinderEnabledCB: TAprCheckBox
      Left = 12
      Top = 28
      Width = 146
      Height = 17
      Caption = 'Auto background enabled'
      TabOrder = 0
      TabStop = True
      OnClick = BackGndFinderEnabledCBClick
    end
  end
  object TrackingPanel: TPanel
    Left = 496
    Top = 543
    Width = 280
    Height = 146
    Color = 13551574
    TabOrder = 3
    object TrackingSettingsLbl: TLabel
      Left = 6
      Top = 7
      Width = 266
      Height = 15
      Alignment = taCenter
      AutoSize = False
      Caption = ' Tracking parameters'
      Color = 12626085
      ParentColor = False
    end
    object PrevFrameLowThresholdLbl: TLabel
      Left = 13
      Top = 30
      Width = 69
      Height = 13
      Caption = 'Low threshold:'
    end
    object PrevFrameHighThresholdLbl: TLabel
      Left = 11
      Top = 53
      Width = 71
      Height = 13
      Caption = 'High threshold:'
    end
    object PrevFrameJumpDLbl: TLabel
      Left = 12
      Top = 99
      Width = 71
      Height = 13
      Caption = 'Jump distance:'
    end
    object PrevFrameMinAreaLbl: TLabel
      Left = 12
      Top = 76
      Width = 68
      Height = 13
      Caption = 'Minimum area:'
    end
    object PrevFrameMergeDLbl: TLabel
      Left = 8
      Top = 121
      Width = 76
      Height = 13
      Caption = 'Merge distance:'
    end
    object Label2: TLabel
      Left = 161
      Top = 32
      Width = 44
      Height = 13
      Caption = 'Cull area:'
    end
    object LowThresholdEdit: TAprSpinEdit
      Left = 86
      Top = 26
      Width = 50
      Height = 20
      Min = 1.000000000000000000
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = LowThresholdEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
    object HighThresholdEdit: TAprSpinEdit
      Left = 86
      Top = 49
      Width = 50
      Height = 20
      Min = 1.000000000000000000
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = HighThresholdEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
    object JumpDEdit: TAprSpinEdit
      Left = 86
      Top = 95
      Width = 50
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = JumpDEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 3
    end
    object MinAreaEdit: TAprSpinEdit
      Left = 86
      Top = 72
      Width = 50
      Height = 20
      Value = 50.000000000000000000
      Min = 50.000000000000000000
      Max = 999999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = MinAreaEditChange
      Increment = 1.000000000000000000
      EditText = '50'
      TabOrder = 2
    end
    object MergeDEdit: TAprSpinEdit
      Left = 86
      Top = 118
      Width = 50
      Height = 20
      Value = 1.000000000000000000
      Min = 1.000000000000000000
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = MergeDEditChange
      Increment = 1.000000000000000000
      EditText = '1'
      TabOrder = 4
    end
    object SmearRG: TRadioGroup
      Left = 165
      Top = 73
      Width = 89
      Height = 66
      Caption = 'Smear'
      Items.Strings = (
        'Classic'
        'Soft edges'
        'Hard edges')
      TabOrder = 6
      OnClick = SmearRGClick
    end
    object CullAreaEdit: TAprSpinEdit
      Left = 207
      Top = 28
      Width = 50
      Height = 20
      Value = 50.000000000000000000
      Min = 50.000000000000000000
      Max = 999999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = CullAreaEditChange
      Increment = 1.000000000000000000
      EditText = '50'
      TabOrder = 5
    end
    object AntiMergeCB: TAprCheckBox
      Left = 168
      Top = 55
      Width = 71
      Height = 17
      Caption = 'Anti-merge'
      TabOrder = 7
      TabStop = True
      OnClick = AntiMergeCBClick
    end
  end
  object CameraPanel: TPanel
    Left = 8
    Top = 583
    Width = 161
    Height = 105
    Color = 13291474
    TabOrder = 1
    object Label7: TLabel
      Left = 6
      Top = 5
      Width = 145
      Height = 14
      Alignment = taCenter
      AutoSize = False
      Caption = 'Camera'
      Color = 13083562
      ParentColor = False
    end
    object SettingsBtn: TButton
      Left = 10
      Top = 74
      Width = 55
      Height = 22
      Caption = 'Settings'
      TabOrder = 2
      OnClick = SettingsBtnClick
    end
    object CamBtn: TButton
      Left = 75
      Top = 74
      Width = 33
      Height = 22
      Caption = 'Cam'
      TabOrder = 3
      OnClick = CamBtnClick
    end
    object PinBtn: TButton
      Left = 119
      Top = 74
      Width = 32
      Height = 22
      Caption = 'Pin'
      TabOrder = 4
      OnClick = PinBtnClick
    end
    object FlipCB: TAprCheckBox
      Tag = 1
      Left = 35
      Top = 25
      Width = 40
      Height = 20
      Caption = 'Flip'
      TabOrder = 0
      TabStop = True
      OnClick = FlipCBClick
    end
    object MirrorCB: TAprCheckBox
      Tag = 1
      Left = 35
      Top = 45
      Width = 46
      Height = 20
      Caption = 'Mirror'
      TabOrder = 1
      TabStop = True
      OnClick = MirrorCBClick
    end
  end
  object ClearBtn: TButton
    Left = 12
    Top = 548
    Width = 53
    Height = 25
    Caption = 'Clear'
    TabOrder = 4
    OnClick = ClearBtnClick
  end
  object LoadBtn: TButton
    Left = 76
    Top = 548
    Width = 53
    Height = 25
    Caption = 'Load'
    TabOrder = 5
    OnClick = LoadBtnClick
  end
  object SaveBtn: TButton
    Left = 140
    Top = 548
    Width = 53
    Height = 25
    Caption = 'Save'
    TabOrder = 6
    OnClick = SaveBtnClick
  end
  object PenWidthEdit: TAprSpinEdit
    Left = 260
    Top = 551
    Width = 50
    Height = 20
    Value = 10.000000000000000000
    Min = 1.000000000000000000
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = BackGndFinderThresholdEditChange
    Increment = 1.000000000000000000
    EditText = '10'
    TabOrder = 7
  end
  object OpenDialog: TOpenDialog
    Filter = 'Calibration files|*.cal'
    Left = 658
    Top = 15
  end
  object DelayTimer: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = DelayTimerTimer
    Left = 248
    Top = 16
  end
  object AutoStartTimer: TTimer
    Enabled = False
    Interval = 5000
    Left = 280
    Top = 16
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Calibration files|*.cal'
    Left = 698
    Top = 15
  end
end
