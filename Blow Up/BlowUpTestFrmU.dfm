object BlowUpTestFrm: TBlowUpTestFrm
  Left = 984
  Top = 84
  Width = 965
  Height = 619
  Caption = 'BlowUp Test'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox: TPaintBox
    Tag = 1
    Left = 4
    Top = 4
    Width = 640
    Height = 480
    OnMouseDown = PaintBoxMouseDown
    OnMouseMove = PaintBoxMouseMove
    OnPaint = PaintBoxPaint
  end
  object Label3: TLabel
    Left = 208
    Top = 507
    Width = 50
    Height = 13
    Caption = 'Pen width:'
  end
  object ClearBtn: TButton
    Left = 12
    Top = 500
    Width = 53
    Height = 25
    Caption = 'Clear'
    TabOrder = 0
    OnClick = ClearBtnClick
  end
  object LoadBtn: TButton
    Left = 76
    Top = 500
    Width = 53
    Height = 25
    Caption = 'Load'
    TabOrder = 1
    OnClick = LoadBtnClick
  end
  object SaveBtn: TButton
    Left = 140
    Top = 500
    Width = 53
    Height = 25
    Caption = 'Save'
    TabOrder = 2
    OnClick = SaveBtnClick
  end
  object PenWidthEdit: TAprSpinEdit
    Left = 260
    Top = 503
    Width = 50
    Height = 20
    Value = 10.000000000000000000
    Min = 1.000000000000000000
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    Increment = 1.000000000000000000
    EditText = '10'
    TabOrder = 3
  end
  object BlowUpTriggerPanel: TPanel
    Left = 655
    Top = 8
    Width = 290
    Height = 145
    TabOrder = 4
    object Label1: TLabel
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
    Left = 655
    Top = 164
    Width = 290
    Height = 119
    Color = 13291474
    TabOrder = 5
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
    Left = 656
    Top = 296
    Width = 289
    Height = 169
    TabOrder = 6
    object Label14: TLabel
      Left = 8
      Top = 7
      Width = 273
      Height = 14
      Alignment = taCenter
      AutoSize = False
      Caption = 'BlowUp parameters'
      Color = 12891050
      ParentColor = False
    end
    object Label17: TLabel
      Left = 22
      Top = 43
      Width = 41
      Height = 13
      Caption = 'Min size:'
    end
    object MinLevelLbl: TLabel
      Left = 22
      Top = 95
      Width = 45
      Height = 13
      Caption = 'Min level:'
    end
    object Label19: TLabel
      Left = 22
      Top = 68
      Width = 44
      Height = 13
      Caption = 'Max size:'
    end
    object MinSizeEdit: TAprSpinEdit
      Left = 73
      Top = 39
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
      Top = 125
      Width = 124
      Height = 17
      Caption = 'Maintain aspect ratio'
      TabOrder = 3
      TabStop = True
      OnClick = KeepAspectCBClick
    end
    object MinLevelEdit: TAprSpinEdit
      Left = 73
      Top = 91
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
      Top = 65
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
      Left = 141
      Top = 27
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
        Top = 8
        Width = 50
        Height = 16
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
  object BlowUpAnimationPanel: TPanel
    Left = 704
    Top = 474
    Width = 193
    Height = 58
    TabOrder = 7
    object Label2: TLabel
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
    object Label4: TLabel
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
  object DrawForeGndPanel: TPanel
    Left = 364
    Top = 491
    Width = 233
    Height = 95
    Color = 13685705
    TabOrder = 8
    object Label5: TLabel
      Left = 7
      Top = 3
      Width = 218
      Height = 14
      Alignment = taCenter
      AutoSize = False
      Caption = 'Draw'
      Color = 11511183
      ParentColor = False
    end
    object Label8: TLabel
      Left = 112
      Top = 24
      Width = 113
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'Hi-light cell at'
      Color = 13088945
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label9: TLabel
      Left = 125
      Top = 47
      Width = 38
      Height = 13
      Caption = 'Column:'
    end
    object Label10: TLabel
      Left = 136
      Top = 71
      Width = 25
      Height = 13
      Caption = 'Row:'
    end
    object StripsCB: TAprCheckBox
      Left = 17
      Top = 20
      Width = 47
      Height = 17
      State = cbChecked
      Caption = 'Strips'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object BlobsCB: TAprCheckBox
      Left = 17
      Top = 37
      Width = 57
      Height = 17
      State = cbChecked
      Caption = 'Blobs'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
    object CellWindowsCB: TAprCheckBox
      Left = 17
      Top = 55
      Width = 44
      Height = 17
      State = cbChecked
      Caption = 'Cells'
      Checked = True
      TabOrder = 2
      TabStop = True
    end
    object SuperCellsCB: TAprCheckBox
      Left = 17
      Top = 73
      Width = 76
      Height = 17
      State = cbChecked
      Caption = 'Super cells'
      Checked = True
      TabOrder = 3
      TabStop = True
    end
    object ColEdit: TAprSpinEdit
      Left = 166
      Top = 42
      Width = 48
      Height = 20
      Value = 1.000000000000000000
      Min = 1.000000000000000000
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      Increment = 1.000000000000000000
      EditText = '1'
      TabOrder = 4
    end
    object RowEdit: TAprSpinEdit
      Left = 166
      Top = 66
      Width = 48
      Height = 20
      Value = 1.000000000000000000
      Min = 1.000000000000000000
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      Increment = 1.000000000000000000
      EditText = '1'
      TabOrder = 5
    end
  end
  object ColorDlg: TColorDialog
    Left = 767
    Top = 240
  end
end
