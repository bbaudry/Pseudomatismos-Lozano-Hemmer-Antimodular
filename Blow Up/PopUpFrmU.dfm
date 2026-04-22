object PopUpFrm: TPopUpFrm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  ClientHeight = 71
  ClientWidth = 289
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object RecalBtn: TButton
    Left = 8
    Top = 8
    Width = 273
    Height = 25
    Caption = 'Recalibrate in 3 seconds (stand away from camera)'
    TabOrder = 0
    OnClick = RecalBtnClick
  end
  object SettingsBtn: TButton
    Left = 24
    Top = 39
    Width = 105
    Height = 25
    Caption = 'Settings'
    TabOrder = 1
    OnClick = SettingsBtnClick
  end
  object QuitBtn: TButton
    Left = 152
    Top = 39
    Width = 107
    Height = 25
    Caption = 'Quit program'
    TabOrder = 2
    OnClick = QuitBtnClick
  end
  object Timer1: TTimer
    Interval = 3000
    OnTimer = Timer1Timer
    Left = 136
    Top = 16
  end
end
