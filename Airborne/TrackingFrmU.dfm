object TrackingFrm: TTrackingFrm
  Left = 614
  Top = 602
  Width = 1112
  Height = 760
  Caption = 'TrackingFrm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox: TPaintBox
    Left = 6
    Top = 5
    Width = 960
    Height = 720
    OnPaint = PaintBoxPaint
  end
  object Panel2: TPanel
    Left = 975
    Top = 16
    Width = 122
    Height = 97
    TabOrder = 0
    object Label13: TLabel
      Left = 1
      Top = 1
      Width = 120
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Face finding'
      Color = 13683917
      ParentColor = False
    end
    object Label14: TLabel
      Left = 25
      Top = 48
      Width = 38
      Height = 13
      Caption = 'Scaling:'
    end
    object Label15: TLabel
      Left = 9
      Top = 24
      Width = 55
      Height = 13
      Caption = 'Consensus:'
    end
    object Label16: TLabel
      Left = 22
      Top = 73
      Width = 41
      Height = 13
      Caption = 'Min size:'
    end
    object ScalingEdit: TAprSpinEdit
      Left = 65
      Top = 45
      Width = 48
      Height = 20
      Decimals = 2
      Min = 1.049999952316284000
      Max = 2.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = ScalingEditChange
      Increment = 0.050000000745058060
      EditText = '0.00'
      TabOrder = 0
    end
    object ConsensusEdit: TAprSpinEdit
      Left = 65
      Top = 21
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = ConsensusEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
    object MinSizeEdit: TAprSpinEdit
      Left = 65
      Top = 70
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = MinSizeEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 2
    end
  end
  object Panel9: TPanel
    Left = 975
    Top = 120
    Width = 123
    Height = 97
    TabOrder = 1
    object Label46: TLabel
      Left = 1
      Top = 1
      Width = 121
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Eye finding'
      Color = 13683917
      ParentColor = False
    end
    object Label47: TLabel
      Left = 24
      Top = 24
      Width = 38
      Height = 13
      Caption = 'Scaling:'
    end
    object Label48: TLabel
      Left = 8
      Top = 48
      Width = 55
      Height = 13
      Caption = 'Consensus:'
    end
    object Label49: TLabel
      Left = 21
      Top = 73
      Width = 41
      Height = 13
      Caption = 'Min size:'
    end
    object EyesScalingEdit: TAprSpinEdit
      Left = 64
      Top = 21
      Width = 48
      Height = 20
      Decimals = 2
      Min = 1.049999952316284000
      Max = 2.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EyesScalingEditChange
      Increment = 0.050000000745058060
      EditText = '0.00'
      TabOrder = 0
    end
    object EyesConsensusEdit: TAprSpinEdit
      Left = 64
      Top = 45
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EyesConsensusEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
    object EyesMinSizeEdit: TAprSpinEdit
      Left = 64
      Top = 69
      Width = 48
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EyesMinSizeEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 2
    end
  end
end
