object JpgViewFrm: TJpgViewFrm
  Left = 334
  Top = 433
  BorderStyle = bsSingle
  Caption = 'JpgViewFrm'
  ClientHeight = 438
  ClientWidth = 655
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 13
    Top = 10
    Width = 37
    Height = 13
    Caption = 'Video #'
  end
  object PaintBox: TPaintBox
    Left = 8
    Top = 32
    Width = 640
    Height = 400
    OnPaint = PaintBoxPaint
  end
  object VideoEdit: TAprSpinEdit
    Left = 58
    Top = 6
    Width = 48
    Height = 20
    Value = 1.000000000000000000
    Min = 1.000000000000000000
    Max = 999.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = VideoEditChange
    Increment = 1.000000000000000000
    EditText = '1'
    TabOrder = 0
  end
  object ScrollBar: TScrollBar
    Left = 120
    Top = 8
    Width = 528
    Height = 16
    Min = 1
    PageSize = 0
    Position = 1
    TabOrder = 1
    OnChange = ScrollBarChange
  end
end
