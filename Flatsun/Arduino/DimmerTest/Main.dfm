object MainFrm: TMainFrm
  Left = 120
  Top = 335
  BorderStyle = bsSingle
  Caption = 'Serial Test'
  ClientHeight = 87
  ClientWidth = 302
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Lcd: TLCD
    Left = 112
    Top = 16
    Width = 100
    Height = 40
    OffColor = 64
    SegHeight = 14
    Digits = 3
    ShowLead0 = False
    Value = 255
    ShowSign = False
  end
  object ReadBtn: TButton
    Left = 13
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Read'
    TabOrder = 0
    OnClick = ReadBtnClick
  end
  object AutoCB: TAprCheckBox
    Left = 16
    Top = 41
    Width = 49
    Height = 17
    Caption = 'Auto'
    TabOrder = 1
    TabStop = True
    OnClick = AutoCBClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 68
    Width = 302
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ComPort: TCommPortDriver
    Port = pnCOM6
    PortName = '\\.\COM6'
    BaudRate = brCustom
    BaudRateValue = 115200
    OnReceiveData = ComPortReceiveData
    Left = 216
    Top = 25
  end
  object Timer: TTimer
    Enabled = False
    Interval = 50
    OnTimer = TimerTimer
    Left = 256
    Top = 25
  end
end
