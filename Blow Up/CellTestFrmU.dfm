object CellTestFrm: TCellTestFrm
  Left = 282
  Top = 206
  Width = 658
  Height = 545
  Caption = 'CellTestFrm'
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
  object PaintBox: TPaintBox
    Left = 4
    Top = 7
    Width = 640
    Height = 480
    OnMouseDown = PaintBoxMouseDown
    OnMouseMove = PaintBoxMouseMove
    OnMouseUp = PaintBoxMouseUp
    OnPaint = PaintBoxPaint
  end
  object Label1: TLabel
    Left = 13
    Top = 498
    Width = 58
    Height = 13
    Caption = 'Hilight cell #'
  end
  object HiLitCellEdit: TAprSpinEdit
    Left = 75
    Top = 494
    Width = 48
    Height = 20
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 0
  end
end
