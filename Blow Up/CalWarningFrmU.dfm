object CalWarningFrm: TCalWarningFrm
  Left = 522
  Top = 162
  BorderStyle = bsNone
  Caption = 'CalWarningFrm'
  ClientHeight = 86
  ClientWidth = 226
  Color = clBtnFace
  Enabled = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 3
    Height = 13
  end
  object Label2: TLabel
    Left = 24
    Top = 56
    Width = 97
    Height = 13
    Caption = 'Reference update in'
  end
  object Lcd: TLCD
    Left = 127
    Top = 49
    Width = 17
    Height = 25
    BackColor = 13682367
    OnColor = clBlack
    OffColor = 13221302
    SegWidth = 8
    SegHeight = 8
    LineWidth = 1
    Gap = 1
    Digits = 1
    ShowLead0 = False
    Value = 3
    ShowSign = False
  end
  object Label3: TLabel
    Left = 150
    Top = 56
    Width = 40
    Height = 13
    Caption = 'seconds'
  end
  object Shape1: TShape
    Left = 0
    Top = 0
    Width = 226
    Height = 86
    Align = alClient
    Brush.Style = bsClear
  end
  object Memo: TMemo
    Left = 8
    Top = 8
    Width = 209
    Height = 34
    Color = clInfoBk
    Lines.Strings = (
      'Please stand away from the camera while '
      'the background reference is updated')
    TabOrder = 0
  end
  object Timer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerTimer
    Left = 176
    Top = 24
  end
end
