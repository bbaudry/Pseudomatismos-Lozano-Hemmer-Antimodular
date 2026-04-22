object CalibrateFrm: TCalibrateFrm
  Left = 225
  Top = 46
  BorderStyle = bsNone
  Caption = 'CalibrateFrm'
  ClientHeight = 147
  ClientWidth = 164
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox: TPaintBox
    Left = 2
    Top = 2
    Width = 160
    Height = 120
  end
  object ProgressBar: TAprProgBar
    Left = 2
    Top = 127
    Width = 160
    Height = 16
    BackGndColor = 14274756
    FillColor = 12752563
    Value = 50.000000000000000000
    Max = 100.000000000000000000
    TabOrder = 0
  end
  object Timer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerTimer
    Left = 56
    Top = 24
  end
end
