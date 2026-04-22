object MainFrm: TMainFrm
  Left = 458
  Top = 271
  BorderStyle = bsNone
  Caption = 'MainFrm'
  ClientHeight = 114
  ClientWidth = 218
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnMouseDown = FormMouseDown
  PixelsPerInch = 96
  TextHeight = 13
  object LCD: TLCD
    Left = 20
    Top = 52
    Width = 39
    Height = 28
    OffColor = 49
    SegWidth = 9
    SegHeight = 9
    LineWidth = 1
    Gap = 0
    Digits = 2
    Value = 15
    ShowSign = False
  end
  object Edit: TAlignEdit
    Left = 7
    Top = 13
    Width = 98
    Height = 20
    BorderStyle = bsNone
    TabOrder = 0
    OnKeyPress = EditKeyPress
    OnMouseDown = FormMouseDown
    Alignment = taCenter
  end
  object Timer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerTimer
    Left = 152
    Top = 16
  end
end
