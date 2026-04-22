object TrackingSetupFrm: TTrackingSetupFrm
  Left = 791
  Top = 185
  Width = 843
  Height = 583
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  Caption = 'Tracking setup'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox: TPaintBox
    Tag = 1
    Left = 8
    Top = 7
    Width = 659
    Height = 493
    OnMouseMove = PaintBoxMouseMove
    OnPaint = PaintBoxPaint
  end
  object Label19: TLabel
    Left = 370
    Top = 510
    Width = 44
    Height = 13
    Caption = 'Smoke y:'
  end
  object Label20: TLabel
    Left = 474
    Top = 510
    Width = 8
    Height = 13
    Caption = '%'
  end
  object Label1: TLabel
    Left = 568
    Top = 512
    Width = 39
    Height = 13
    Caption = 'Y offset:'
  end
  object XLcd: TLCD
    Left = 17
    Top = 505
    Width = 44
    Height = 27
    OffColor = 43
    SegWidth = 7
    SegHeight = 8
    LineWidth = 1
    Gap = 1
    Digits = 3
    ShowLead0 = False
    ShowSign = False
  end
  object YLcd: TLCD
    Left = 65
    Top = 505
    Width = 44
    Height = 27
    OffColor = 43
    SegWidth = 7
    SegHeight = 8
    LineWidth = 1
    Gap = 1
    Digits = 3
    ShowLead0 = False
    ShowSign = False
  end
  object FollowMouseCB: TAprCheckBox
    Left = 126
    Top = 510
    Width = 91
    Height = 17
    Caption = 'Follow mouse'
    TabOrder = 0
    TabStop = True
  end
  object Panel1: TPanel
    Left = 678
    Top = 457
    Width = 151
    Height = 74
    TabOrder = 1
    object Label7: TLabel
      Left = 1
      Top = 1
      Width = 149
      Height = 14
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Camera'
      Color = 16756912
      ParentColor = False
    end
    object FlipCB: TAprCheckBox
      Left = 81
      Top = 23
      Width = 41
      Height = 17
      Caption = 'Flip'
      TabOrder = 0
      TabStop = True
      OnClick = FlipCBClick
    end
    object MirrorCB: TAprCheckBox
      Left = 25
      Top = 23
      Width = 49
      Height = 17
      Caption = 'Mirror'
      TabOrder = 1
      TabStop = True
      OnClick = MirrorCBClick
    end
    object CamSettingsBtn: TButton
      Left = 12
      Top = 45
      Width = 61
      Height = 22
      Caption = 'Settings'
      TabOrder = 2
      OnClick = CamSettingsBtnClick
    end
    object InfoBtn: TButton
      Left = 83
      Top = 45
      Width = 56
      Height = 22
      Caption = 'Info'
      TabOrder = 3
      OnClick = InfoBtnClick
    end
  end
  object Panel2: TPanel
    Left = 678
    Top = 273
    Width = 150
    Height = 177
    TabOrder = 2
    object Label8: TLabel
      Left = 1
      Top = 1
      Width = 148
      Height = 13
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Tracking'
      Color = 16756912
      ParentColor = False
    end
    object Label3: TLabel
      Left = 10
      Top = 29
      Width = 69
      Height = 13
      Caption = 'Low threshold:'
    end
    object Label4: TLabel
      Left = 10
      Top = 53
      Width = 71
      Height = 13
      Caption = 'High threshold:'
    end
    object Label5: TLabel
      Left = 10
      Top = 77
      Width = 71
      Height = 13
      Caption = 'Jump distance:'
    end
    object Label6: TLabel
      Left = 10
      Top = 101
      Width = 76
      Height = 13
      Caption = 'Merge distance:'
    end
    object MinAreaLbl: TLabel
      Left = 13
      Top = 125
      Width = 66
      Height = 13
      Caption = 'Mininum area:'
    end
    object LowThresholdEdit: TAprSpinEdit
      Left = 88
      Top = 25
      Width = 50
      Height = 20
      Value = 30.000000000000000000
      Max = 99999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = LowThresholdEditChange
      Increment = 1.000000000000000000
      EditText = '30'
      TabOrder = 0
    end
    object HighThresholdEdit: TAprSpinEdit
      Left = 88
      Top = 49
      Width = 50
      Height = 20
      Value = 40.000000000000000000
      Max = 99999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = HighThresholdEditChange
      Increment = 1.000000000000000000
      EditText = '40'
      TabOrder = 1
    end
    object JumpDEdit: TAprSpinEdit
      Left = 88
      Top = 73
      Width = 50
      Height = 20
      Value = 25.000000000000000000
      Max = 99999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = JumpDEditChange
      Increment = 1.000000000000000000
      EditText = '25'
      TabOrder = 2
    end
    object MergeDEdit: TAprSpinEdit
      Left = 88
      Top = 97
      Width = 50
      Height = 20
      Value = 25.000000000000000000
      Max = 99999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = MergeDEditChange
      Increment = 1.000000000000000000
      EditText = '25'
      TabOrder = 3
    end
    object MinAreaEdit: TAprSpinEdit
      Left = 88
      Top = 121
      Width = 50
      Height = 20
      Value = 500.000000000000000000
      Max = 99999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = MinAreaEditChange
      Increment = 1.000000000000000000
      EditText = '500'
      TabOrder = 4
    end
    object BackGndBtn: TButton
      Left = 9
      Top = 147
      Width = 75
      Height = 23
      Caption = 'Background'
      TabOrder = 5
      OnClick = BackGndBtnClick
    end
    object SetBackGndBtn: TButton
      Left = 93
      Top = 147
      Width = 48
      Height = 23
      Caption = 'Set'
      TabOrder = 6
      OnClick = SetBackGndBtnClick
    end
  end
  object Panel3: TPanel
    Left = 678
    Top = 3
    Width = 150
    Height = 266
    TabOrder = 3
    object Label9: TLabel
      Left = 1
      Top = 1
      Width = 148
      Height = 14
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'Draw'
      Color = 11511183
      ParentColor = False
    end
    object BackGndDrawPanel: TPanel
      Left = 16
      Top = 20
      Width = 117
      Height = 73
      Color = 13685705
      TabOrder = 0
      object Label11: TLabel
        Left = 1
        Top = 1
        Width = 115
        Height = 14
        Align = alTop
        Alignment = taCenter
        AutoSize = False
        Caption = 'Background'
        Color = 11511183
        ParentColor = False
      end
      object NormalRB: TRadioButton
        Left = 10
        Top = 20
        Width = 57
        Height = 17
        Caption = 'Normal'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object SubtractedRB: TRadioButton
        Left = 10
        Top = 53
        Width = 77
        Height = 17
        Caption = 'Subtracted'
        TabOrder = 1
      end
      object BackGndRB: TRadioButton
        Left = 10
        Top = 36
        Width = 87
        Height = 17
        Caption = 'Background'
        TabOrder = 2
      end
    end
    object ForeGndDrawPanel: TPanel
      Left = 14
      Top = 100
      Width = 120
      Height = 159
      Color = 13685705
      TabOrder = 1
      object Label14: TLabel
        Left = 1
        Top = 1
        Width = 118
        Height = 14
        Align = alTop
        Alignment = taCenter
        AutoSize = False
        Caption = 'Foreground'
        Color = 11511183
        ParentColor = False
      end
      object ThresholdsViewRB: TRadioButton
        Left = 7
        Top = 27
        Width = 99
        Height = 17
        Caption = 'Track thresholds'
        TabOrder = 0
        TabStop = True
      end
      object TrackingViewRB: TRadioButton
        Left = 7
        Top = 43
        Width = 83
        Height = 17
        Caption = 'Tracking info'
        Checked = True
        TabOrder = 1
        TabStop = True
      end
      object StripsCB: TAprCheckBox
        Left = 21
        Top = 63
        Width = 47
        Height = 17
        Caption = 'Strips'
        TabOrder = 2
        TabStop = True
      end
      object TargetsCB: TAprCheckBox
        Left = 21
        Top = 120
        Width = 61
        Height = 17
        Caption = 'Targets'
        TabOrder = 4
        TabStop = True
      end
      object BlobsCB: TAprCheckBox
        Left = 21
        Top = 101
        Width = 57
        Height = 17
        Caption = 'Blobs'
        TabOrder = 5
        TabStop = True
      end
      object MaskCB: TAprCheckBox
        Left = 21
        Top = 139
        Width = 84
        Height = 17
        Caption = 'Track mask'
        TabOrder = 6
        TabStop = True
      end
      object AllStripsCB: TAprCheckBox
        Left = 37
        Top = 79
        Width = 47
        Height = 17
        Caption = 'All'
        TabOrder = 3
        TabStop = True
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 537
    Width = 835
    Height = 19
    Panels = <>
  end
  object YOffsetFractionEdit: TAprSpinEdit
    Left = 417
    Top = 506
    Width = 51
    Height = 20
    Max = 100.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = YOffsetFractionEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 5
  end
  object TrackMaskBtn: TButton
    Left = 488
    Top = 505
    Width = 75
    Height = 25
    Caption = 'Track mask'
    TabOrder = 6
    OnClick = TrackMaskBtnClick
  end
  object YOffsetEdit: TAprSpinEdit
    Left = 610
    Top = 506
    Width = 50
    Height = 20
    Value = 30.000000000000000000
    Min = -99.000000000000000000
    Max = 99.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = YOffsetEditChange
    Increment = 1.000000000000000000
    EditText = '30'
    TabOrder = 7
  end
  object Button1: TButton
    Left = 272
    Top = 507
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 8
    OnClick = Button1Click
  end
end
