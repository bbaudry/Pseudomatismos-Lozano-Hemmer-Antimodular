object TrackViewFrm: TTrackViewFrm
  Left = 601
  Top = 467
  BorderStyle = bsDialog
  Caption = 'Track view'
  ClientHeight = 490
  ClientWidth = 838
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox: TPaintBox
    Tag = 1
    Left = 4
    Top = 4
    Width = 640
    Height = 480
  end
  object BlowUpTargetPanel: TPanel
    Left = 653
    Top = 82
    Width = 181
    Height = 172
    Color = 13291474
    TabOrder = 1
    object Label20: TLabel
      Left = 9
      Top = 7
      Width = 163
      Height = 14
      Alignment = taCenter
      AutoSize = False
      Caption = 'BlowUp to'
      Color = 12891050
      ParentColor = False
    end
    object Label21: TLabel
      Left = 156
      Top = 120
      Width = 8
      Height = 13
      Caption = '%'
    end
    object TenactiyLbl: TLabel
      Left = 41
      Top = 149
      Width = 44
      Height = 13
      Caption = 'Tenactiy:'
    end
    object Label2: TLabel
      Left = 165
      Top = 90
      Width = 7
      Height = 13
      Caption = 'X'
    end
    object BlowUpToBestBlobRB: TRadioButton
      Left = 19
      Top = 25
      Width = 92
      Height = 17
      Caption = 'Dominant blob'
      TabOrder = 0
      OnClick = BlowUpToBestBlobRBClick
    end
    object BlowUpToForeGndRB: TRadioButton
      Left = 19
      Top = 41
      Width = 78
      Height = 17
      Caption = 'Foreground'
      TabOrder = 1
      OnClick = BlowUpToForeGndRBClick
    end
    object BlowUpToBackGndRB: TRadioButton
      Left = 19
      Top = 57
      Width = 78
      Height = 17
      Caption = 'Background'
      TabOrder = 2
      OnClick = BlowUpToBackGndRBClick
    end
    object BlowUpToAnythingRB: TRadioButton
      Left = 19
      Top = 73
      Width = 78
      Height = 17
      Caption = 'Anything'
      TabOrder = 3
      OnClick = BlowUpToAnythingRBClick
    end
    object KeepBlowUpYCB: TAprCheckBox
      Left = 15
      Top = 119
      Width = 81
      Height = 17
      Caption = 'Keep y within'
      TabOrder = 6
      TabStop = True
      OnClick = KeepBlowUpYCBClick
    end
    object BlowUpYFractionEdit: TAprSpinEdit
      Left = 102
      Top = 116
      Width = 48
      Height = 20
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = BlowUpYFractionEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 7
    end
    object TenacityEdit: TAprSpinEdit
      Left = 88
      Top = 145
      Width = 50
      Height = 20
      Min = 1.000000000000000000
      Max = 20.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = TenacityEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 8
    end
    object BlowUpToZoomRB: TRadioButton
      Left = 19
      Top = 93
      Width = 90
      Height = 10
      Caption = 'Zoom - scale ='
      TabOrder = 4
      OnClick = BlowUpToZoomRBClick
    end
    object ZoomScaleEdit: TAprSpinEdit
      Left = 112
      Top = 86
      Width = 48
      Height = 20
      Decimals = 2
      Min = 0.009999999776482582
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = ZoomScaleEditChange
      Increment = 0.100000001490116100
      EditText = '0.00'
      TabOrder = 5
    end
  end
  object DrawPanel: TPanel
    Left = 653
    Top = 4
    Width = 182
    Height = 75
    TabOrder = 0
    object Label22: TLabel
      Left = 8
      Top = 6
      Width = 164
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'Draw'
      Color = 12891050
      ParentColor = False
    end
    object StripsCB: TAprCheckBox
      Left = 101
      Top = 21
      Width = 47
      Height = 17
      State = cbChecked
      Caption = 'Strips'
      Checked = True
      TabOrder = 2
      TabStop = True
    end
    object BlobsCB: TAprCheckBox
      Left = 101
      Top = 38
      Width = 57
      Height = 17
      State = cbChecked
      Caption = 'Blobs'
      Checked = True
      TabOrder = 3
      TabStop = True
    end
    object CellWindowsCB: TAprCheckBox
      Left = 11
      Top = 21
      Width = 82
      Height = 17
      State = cbChecked
      Caption = 'Cell windows'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object SuperCellsCB: TAprCheckBox
      Left = 11
      Top = 37
      Width = 82
      Height = 17
      State = cbChecked
      Caption = 'Super cells'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
    object TargetCB: TAprCheckBox
      Left = 11
      Top = 54
      Width = 82
      Height = 17
      State = cbChecked
      Caption = 'Target center'
      Checked = True
      TabOrder = 4
      TabStop = True
    end
  end
  object BlowUpParametersPanel: TPanel
    Left = 653
    Top = 256
    Width = 180
    Height = 229
    TabOrder = 2
    object Label14: TLabel
      Left = 8
      Top = 7
      Width = 163
      Height = 14
      Alignment = taCenter
      AutoSize = False
      Caption = 'BlowUp parameters'
      Color = 12891050
      ParentColor = False
    end
    object MinLevelLbl: TLabel
      Left = 38
      Top = 32
      Width = 61
      Height = 13
      Caption = 'Trigger level:'
    end
    object Label1: TLabel
      Left = 36
      Top = 83
      Width = 62
      Height = 13
      Caption = 'Current level:'
    end
    object CurrentLevelLCD: TLCD
      Left = 101
      Top = 78
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
    object AveragesLbl: TLabel
      Left = 38
      Top = 128
      Width = 57
      Height = 13
      Caption = 'X averages:'
    end
    object Label7: TLabel
      Left = 38
      Top = 152
      Width = 57
      Height = 13
      Caption = 'Y averages:'
    end
    object Label33: TLabel
      Left = 38
      Top = 176
      Width = 55
      Height = 13
      Caption = 'Max speed:'
    end
    object Label3: TLabel
      Left = 35
      Top = 204
      Width = 69
      Height = 13
      Caption = 'Current speed:'
    end
    object SpeedLcd: TLCD
      Left = 106
      Top = 199
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
    object Label4: TLabel
      Left = 28
      Top = 56
      Width = 71
      Height = 13
      Caption = 'Untrigger level:'
    end
    object TrackerEnabledCB: TAprCheckBox
      Left = 20
      Top = 107
      Width = 53
      Height = 17
      Caption = 'Follow'
      TabOrder = 2
      TabStop = True
      OnClick = TrackerEnabledCBClick
    end
    object TriggerLevelEdit: TAprSpinEdit
      Left = 102
      Top = 28
      Width = 46
      Height = 20
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = TriggerLevelEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
    object TrackerYAveragesEdit: TAprSpinEdit
      Left = 98
      Top = 149
      Width = 46
      Height = 20
      Min = 1.000000000000000000
      Max = 64.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = TrackerYAveragesEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 4
    end
    object TrackerXAveragesEdit: TAprSpinEdit
      Left = 98
      Top = 125
      Width = 46
      Height = 20
      Min = 1.000000000000000000
      Max = 64.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = TrackerXAveragesEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 3
    end
    object TrackerMaxSpeedEdit: TAprSpinEdit
      Left = 98
      Top = 173
      Width = 46
      Height = 20
      Min = 1.000000000000000000
      Max = 64.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = TrackerMaxSpeedEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 5
    end
    object UntriggerLevelEdit: TAprSpinEdit
      Left = 102
      Top = 52
      Width = 46
      Height = 20
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = UntriggerLevelEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
  end
end
