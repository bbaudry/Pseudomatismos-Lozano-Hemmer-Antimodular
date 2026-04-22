object CloudSetupFrm: TCloudSetupFrm
  Left = 710
  Top = 226
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Setup'
  ClientHeight = 325
  ClientWidth = 440
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object SmokePanel: TPanel
    Left = 7
    Top = 7
    Width = 426
    Height = 255
    Color = 14535615
    TabOrder = 0
    object Label26: TLabel
      Left = 1
      Top = 1
      Width = 424
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Smoke settings'
      Color = 13683917
      ParentColor = False
    end
    object Label1: TLabel
      Left = 24
      Top = 23
      Width = 100
      Height = 13
      Caption = 'Ambient temperature:'
    end
    object Label2: TLabel
      Left = 24
      Top = 51
      Width = 98
      Height = 13
      Caption = 'Impulse temperature:'
    end
    object Label3: TLabel
      Left = 48
      Top = 79
      Width = 75
      Height = 13
      Caption = 'Impulse density:'
    end
    object Label4: TLabel
      Left = 43
      Top = 107
      Width = 79
      Height = 13
      Caption = 'Jacobi iterations:'
    end
    object Label5: TLabel
      Left = 264
      Top = 24
      Width = 49
      Height = 13
      Caption = 'Time step:'
    end
    object Label6: TLabel
      Left = 40
      Top = 137
      Width = 85
      Height = 13
      Caption = 'Smoke buoyancy:'
    end
    object Label7: TLabel
      Left = 51
      Top = 165
      Width = 70
      Height = 13
      Caption = 'Smoke weight:'
    end
    object Label8: TLabel
      Left = 200
      Top = 51
      Width = 115
      Height = 13
      Caption = 'Temperature dissipation:'
    end
    object Label9: TLabel
      Left = 224
      Top = 80
      Width = 92
      Height = 13
      Caption = 'Velocity dissipation:'
    end
    object Label10: TLabel
      Left = 224
      Top = 108
      Width = 90
      Height = 13
      Caption = 'Density dissipation:'
    end
    object Label11: TLabel
      Left = 272
      Top = 136
      Width = 41
      Height = 13
      Caption = 'Cell size:'
    end
    object Label12: TLabel
      Left = 241
      Top = 164
      Width = 71
      Height = 13
      Caption = 'Gradient scale:'
    end
    object Label15: TLabel
      Left = 10
      Top = 228
      Width = 27
      Height = 13
      Caption = 'Show'
    end
    object Label19: TLabel
      Left = 98
      Top = 228
      Width = 83
      Height = 13
      Caption = 'smoke sources at'
    end
    object Label20: TLabel
      Left = 242
      Top = 227
      Width = 107
      Height = 13
      Caption = '% of the target'#39's height'
    end
    object Label13: TLabel
      Left = 282
      Top = 196
      Width = 44
      Height = 13
      Caption = 'Max size:'
    end
    object AmbientTemperatureEdit: TAprSpinEdit
      Left = 127
      Top = 19
      Width = 66
      Height = 20
      Decimals = 1
      Max = 99.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = AmbientTemperatureEditChange
      Increment = 0.100000001490116100
      EditText = '0.0'
      TabOrder = 0
    end
    object ImpulseTemperatureEdit: TAprSpinEdit
      Left = 127
      Top = 47
      Width = 66
      Height = 20
      Decimals = 1
      Min = -99.000000000000000000
      Max = 99.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = ImpulseTemperatureEditChange
      Increment = 0.100000001490116100
      EditText = '0.0'
      TabOrder = 1
    end
    object ImpulseDensityEdit: TAprSpinEdit
      Left = 127
      Top = 75
      Width = 66
      Height = 20
      Decimals = 2
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = ImpulseDensityEditChange
      Increment = 0.009999999776482582
      EditText = '0.00'
      TabOrder = 2
    end
    object JacobiIterationsEdit: TAprSpinEdit
      Left = 127
      Top = 103
      Width = 66
      Height = 20
      Min = 1.000000000000000000
      Max = 12.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = JacobiIterationsEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 3
    end
    object TimeStepEdit: TAprSpinEdit
      Left = 319
      Top = 20
      Width = 66
      Height = 20
      Decimals = 3
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = TimeStepEditChange
      Increment = 0.009999999776482582
      EditText = '0.000'
      TabOrder = 4
    end
    object SmokeBuoyancyEdit: TAprSpinEdit
      Left = 127
      Top = 133
      Width = 66
      Height = 20
      Decimals = 2
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = SmokeBuoyancyEditChange
      Increment = 0.100000001490116100
      EditText = '0.00'
      TabOrder = 5
    end
    object SmokeWeightEdit: TAprSpinEdit
      Left = 127
      Top = 161
      Width = 66
      Height = 20
      Decimals = 3
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = SmokeWeightEditChange
      Increment = 0.009999999776482582
      EditText = '0.000'
      TabOrder = 6
    end
    object TemperatureDissipationEdit: TAprSpinEdit
      Left = 319
      Top = 47
      Width = 66
      Height = 20
      Decimals = 4
      Min = 0.949999988079071000
      Max = 0.999899983406066900
      Alignment = taCenter
      Enabled = True
      OnChange = TemperatureDissipationEditChange
      Increment = 0.009999999776482582
      EditText = '0.0000'
      TabOrder = 7
    end
    object VelocityDissipationEdit: TAprSpinEdit
      Left = 319
      Top = 76
      Width = 66
      Height = 20
      Decimals = 4
      Min = 0.949999988079071000
      Max = 0.999899983406066900
      Alignment = taCenter
      Enabled = True
      OnChange = VelocityDissipationEditChange
      Increment = 0.009999999776482582
      EditText = '0.0000'
      TabOrder = 8
    end
    object DensityDissipationEdit: TAprSpinEdit
      Left = 319
      Top = 104
      Width = 66
      Height = 20
      Decimals = 4
      Min = 0.949999988079071000
      Max = 0.999899983406066900
      Alignment = taCenter
      Enabled = True
      OnChange = DensityDissipationEditChange
      Increment = 0.009999999776482582
      EditText = '0.0000'
      TabOrder = 9
    end
    object CellSizeEdit: TAprSpinEdit
      Left = 319
      Top = 132
      Width = 66
      Height = 20
      Decimals = 2
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = CellSizeEditChange
      Increment = 0.009999999776482582
      EditText = '0.00'
      TabOrder = 10
    end
    object GradientScaleEdit: TAprSpinEdit
      Left = 319
      Top = 160
      Width = 66
      Height = 20
      Decimals = 3
      Max = 10.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = GradientScaleEditChange
      Increment = 0.009999999776482582
      EditText = '0.000'
      TabOrder = 11
    end
    object SmokeColorBtn: TColorBtn
      Left = 178
      Top = 193
      Width = 78
      Height = 23
      Caption = 'Smoke Color'
      OnClick = SmokeColorBtnClick
      TabOrder = 12
    end
    object BackGndColorBtn: TColorBtn
      Left = 45
      Top = 193
      Width = 107
      Height = 23
      Caption = 'Background color'
      OnClick = BackGndColorBtnClick
      TabOrder = 13
    end
    object SourcesEdit: TAprSpinEdit
      Left = 41
      Top = 224
      Width = 51
      Height = 20
      Min = 1.000000000000000000
      Max = 10.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = SourcesEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 14
    end
    object YOffsetFractionEdit: TAprSpinEdit
      Left = 185
      Top = 224
      Width = 51
      Height = 20
      Max = 100.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = YOffsetFractionEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 15
    end
    object MaxSizeEdit: TAprSpinEdit
      Left = 329
      Top = 192
      Width = 51
      Height = 20
      Min = 1.000000000000000000
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = MaxSizeEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 16
    end
  end
  object Panel2: TPanel
    Left = 80
    Top = 269
    Width = 296
    Height = 49
    Color = 14012360
    TabOrder = 1
    object Label17: TLabel
      Left = 1
      Top = 1
      Width = 294
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Resolution'
      Color = 13683917
      ParentColor = False
    end
    object Label25: TLabel
      Left = 47
      Top = 23
      Width = 31
      Height = 13
      Caption = 'Width:'
    end
    object Label56: TLabel
      Left = 158
      Top = 24
      Width = 34
      Height = 13
      Caption = 'Height:'
    end
    object XResEdit: TAprSpinEdit
      Left = 84
      Top = 20
      Width = 58
      Height = 20
      Min = 100.000000000000000000
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = XResEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
    object YResEdit: TAprSpinEdit
      Left = 199
      Top = 19
      Width = 58
      Height = 20
      Min = 100.000000000000000000
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = YResEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
  end
  object ColorDlg: TColorDialog
    Left = 200
    Top = 120
  end
end
