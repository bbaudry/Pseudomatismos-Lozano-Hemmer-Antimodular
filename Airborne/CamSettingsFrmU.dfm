object CamSettingsFrm: TCamSettingsFrm
  Left = 569
  Top = 144
  Width = 335
  Height = 107
  Caption = 'Camera settings'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 153
    Height = 65
    Color = 14141894
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 137
      Height = 14
      Alignment = taCenter
      AutoSize = False
      Caption = 'Exposure'
      Color = 13869224
      ParentColor = False
    end
    object ExposureEdit: TNBFillEdit
      Left = 10
      Top = 32
      Width = 135
      Height = 21
      ArrowColor = 16744576
      BackGndColor = 14341570
      FillColor = 13146220
      FillWidth = 50
      ArrowWidth = 14
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Max = 100
      Value = 50
      OnValueChange = ExposureEditValueChange
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 168
    Top = 8
    Width = 153
    Height = 65
    Color = 14141894
    TabOrder = 1
    object Label2: TLabel
      Left = 8
      Top = 8
      Width = 137
      Height = 14
      Alignment = taCenter
      AutoSize = False
      Caption = 'Gain'
      Color = 13869224
      ParentColor = False
    end
    object GainEdit: TNBFillEdit
      Left = 8
      Top = 32
      Width = 136
      Height = 21
      ArrowColor = 16744576
      BackGndColor = 14341570
      FillColor = 13146220
      FillWidth = 70
      ArrowWidth = 14
      EditFont.Charset = DEFAULT_CHARSET
      EditFont.Color = clWindowText
      EditFont.Height = -11
      EditFont.Name = 'MS Sans Serif'
      EditFont.Style = []
      EditColor = clWindow
      Alignment = taCenter
      SpeedUpDelay = 200
      SpeedUpPeriod = 50
      Max = 100
      Value = 50
      OnValueChange = GainEditValueChange
      TabOrder = 0
    end
  end
end
