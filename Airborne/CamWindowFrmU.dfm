object CamWindowFrm: TCamWindowFrm
  Left = 0
  Top = 497
  Width = 841
  Height = 539
  Caption = 'Camera window'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox: TPaintBox
    Left = 10
    Top = 8
    Width = 694
    Height = 496
  end
  object Panel1: TPanel
    Left = 716
    Top = 16
    Width = 108
    Height = 160
    TabOrder = 0
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 106
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Window'
      Color = 13229503
      ParentColor = False
    end
    object Label2: TLabel
      Left = 22
      Top = 63
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object Label3: TLabel
      Left = 22
      Top = 87
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object Label4: TLabel
      Left = 20
      Top = 111
      Width = 14
      Height = 13
      Caption = 'W:'
    end
    object Label5: TLabel
      Left = 22
      Top = 135
      Width = 11
      Height = 13
      Caption = 'H:'
    end
    object FullWindowBtn: TButton
      Left = 16
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Full'
      TabOrder = 0
      OnClick = FullWindowBtnClick
    end
    object XEdit: TAprSpinEdit
      Left = 37
      Top = 59
      Width = 48
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = WindowEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
    object YEdit: TAprSpinEdit
      Left = 37
      Top = 83
      Width = 48
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = WindowEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 2
    end
    object WEdit: TAprSpinEdit
      Left = 37
      Top = 107
      Width = 48
      Height = 21
      Value = 659.000000000000000000
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = WindowEditChange
      Increment = 1.000000000000000000
      EditText = '659'
      TabOrder = 3
    end
    object HEdit: TAprSpinEdit
      Left = 37
      Top = 131
      Width = 48
      Height = 20
      Value = 493.000000000000000000
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = WindowEditChange
      Increment = 1.000000000000000000
      EditText = '493'
      TabOrder = 4
    end
  end
end
