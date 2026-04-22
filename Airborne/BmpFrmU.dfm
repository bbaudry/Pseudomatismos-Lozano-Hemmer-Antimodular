object BmpFrm: TBmpFrm
  Left = 296
  Top = 172
  BorderStyle = bsDialog
  ClientHeight = 337
  ClientWidth = 318
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnMouseMove = FormMouseMove
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Timer: TTimer
    Enabled = False
    Interval = 40
    OnTimer = TimerTimer
    Left = 72
    Top = 56
  end
end
