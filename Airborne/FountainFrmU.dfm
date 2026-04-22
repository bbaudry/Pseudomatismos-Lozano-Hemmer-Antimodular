object FountainFrm: TFountainFrm
  Left = 467
  Top = 258
  Width = 338
  Height = 243
  Caption = 'Particle settings'
  Color = clSilver
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object ThresholdsPanel: TPanel
    Left = 6
    Top = 128
    Width = 136
    Height = 76
    Color = 13749195
    TabOrder = 1
    object Label4: TLabel
      Left = 1
      Top = 1
      Width = 134
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Thresholds'
      Color = 12101261
      ParentColor = False
    end
    object Label2: TLabel
      Left = 11
      Top = 25
      Width = 30
      Height = 13
      Caption = 'Move:'
    end
    object Label15: TLabel
      Left = 11
      Top = 51
      Width = 31
      Height = 13
      Caption = 'Home:'
    end
    object HomeThresholdEdit: TAprSpinEdit
      Left = 45
      Top = 47
      Width = 73
      Height = 20
      Max = 999999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = HomeThresholdEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
    object MoveThresholdEdit: TAprSpinEdit
      Left = 45
      Top = 21
      Width = 73
      Height = 20
      Max = 999999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = MoveThresholdEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
  end
  object TextPanel: TPanel
    Left = 8
    Top = 9
    Width = 313
    Height = 108
    Color = 13749195
    TabOrder = 0
    object Label11: TLabel
      Left = 1
      Top = 1
      Width = 311
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Text'
      Color = 12101261
      ParentColor = False
    end
    object Label17: TLabel
      Left = 231
      Top = 25
      Width = 27
      Height = 13
      Caption = 'Color:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label1: TLabel
      Left = 224
      Top = 51
      Width = 23
      Height = 13
      Caption = 'Size:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object PlacementPanel: TPanel
      Left = 9
      Top = 22
      Width = 93
      Height = 77
      Color = 13749195
      TabOrder = 0
      object Label24: TLabel
        Left = 1
        Top = 1
        Width = 91
        Height = 13
        Align = alTop
        Alignment = taCenter
        Caption = 'Placement'
        Color = 12101261
        ParentColor = False
      end
      object Label27: TLabel
        Left = 14
        Top = 27
        Width = 10
        Height = 13
        Caption = 'X:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label28: TLabel
        Left = 14
        Top = 52
        Width = 10
        Height = 13
        Caption = 'Y:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object StaticYEdit: TAprSpinEdit
        Left = 28
        Top = 48
        Width = 53
        Height = 20
        Decimals = 2
        Min = -1.000000000000000000
        Max = 1.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = StaticYEditChange
        Increment = 0.009999999776482582
        EditText = '0.00'
        TabOrder = 1
      end
      object StaticXEdit: TAprSpinEdit
        Left = 28
        Top = 23
        Width = 53
        Height = 20
        Decimals = 2
        Min = -1.000000000000000000
        Max = 1.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = StaticXEditChange
        Increment = 0.009999999776482582
        EditText = '0.00'
        TabOrder = 0
      end
    end
    object SpacingPanel: TPanel
      Left = 113
      Top = 22
      Width = 93
      Height = 77
      Color = 13749195
      TabOrder = 1
      object Label16: TLabel
        Left = 1
        Top = 1
        Width = 91
        Height = 13
        Align = alTop
        Alignment = taCenter
        Caption = 'Spacing'
        Color = 12101261
        ParentColor = False
      end
      object Label18: TLabel
        Left = 15
        Top = 27
        Width = 10
        Height = 13
        Caption = 'X:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label19: TLabel
        Left = 15
        Top = 51
        Width = 10
        Height = 13
        Caption = 'Y:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object StaticYSpacingEdit: TAprSpinEdit
        Left = 28
        Top = 48
        Width = 53
        Height = 20
        Decimals = 2
        Min = -1.000000000000000000
        Max = 1.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = StaticYSpacingEditChange
        Increment = 0.009999999776482582
        EditText = '0.00'
        TabOrder = 1
      end
      object StaticXSpacingEdit: TAprSpinEdit
        Left = 28
        Top = 23
        Width = 53
        Height = 20
        Decimals = 2
        Min = -1.000000000000000000
        Max = 1.000000000000000000
        Alignment = taCenter
        Enabled = True
        OnChange = StaticXSpacingEditChange
        Increment = 0.009999999776482582
        EditText = '0.00'
        TabOrder = 0
      end
    end
    object ShowTextBtn: TButton
      Left = 240
      Top = 74
      Width = 57
      Height = 25
      Caption = 'Show'
      TabOrder = 4
      OnClick = ShowTextBtnClick
    end
    object ColorPanel: TPanel
      Left = 264
      Top = 21
      Width = 23
      Height = 21
      Color = 254
      TabOrder = 2
      OnClick = ColorPanelClick
    end
    object SizeEdit: TAprSpinEdit
      Left = 251
      Top = 47
      Width = 45
      Height = 20
      Min = -9999.000000000000000000
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = SizeEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 3
    end
  end
  object FadeTimePanel: TPanel
    Left = 158
    Top = 128
    Width = 163
    Height = 76
    Color = 13749195
    TabOrder = 2
    object Label22: TLabel
      Left = 1
      Top = 1
      Width = 161
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Other'
      Color = 12101261
      ParentColor = False
    end
    object Label3: TLabel
      Left = 20
      Top = 50
      Width = 54
      Height = 13
      Caption = 'Wait alpha:'
    end
    object Label5: TLabel
      Left = 14
      Top = 25
      Width = 60
      Height = 13
      Caption = 'Fade in time:'
    end
    object FadeTimeEdit: TAprSpinEdit
      Left = 79
      Top = 21
      Width = 63
      Height = 20
      Decimals = 1
      Max = 10.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = FadeTimeEditChange
      Increment = 0.100000001490116100
      EditText = '0.0'
      TabOrder = 0
    end
    object WaitAlphaEdit: TAprSpinEdit
      Left = 78
      Top = 47
      Width = 64
      Height = 20
      Decimals = 2
      Min = -1.000000000000000000
      Max = 1.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = WaitAlphaEditChange
      Increment = 0.009999999776482582
      EditText = '0.00'
      TabOrder = 1
    end
  end
  object ColorDlg: TColorDialog
    Left = 216
    Top = 88
  end
end
