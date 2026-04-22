object BmpViewFrm: TBmpViewFrm
  Left = 932
  Top = 202
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 578
  ClientWidth = 806
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 16
    Top = 13
    Width = 46
    Height = 16
    Caption = 'Video #'
  end
  object PaintBox: TPaintBox
    Left = 10
    Top = 71
    Width = 788
    Height = 493
    OnPaint = PaintBoxPaint
  end
  object VideoNumberLbl: TLabel
    Left = 136
    Top = 13
    Width = 50
    Height = 16
    Caption = '(000.vid)'
  end
  object VideoEdit: TAprSpinEdit
    Left = 71
    Top = 10
    Width = 53
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
    Left = 228
    Top = 10
    Width = 421
    Height = 20
    Min = 1
    PageSize = 0
    Position = 1
    TabOrder = 1
    OnChange = ScrollBarChange
  end
  object IntensityEdit: TNBFillEdit
    Left = 56
    Top = 39
    Width = 215
    Height = 25
    ArrowBackGndColor = 5135459
    BackGndColor = 5135459
    FillWidth = 130
    ArrowWidth = 20
    Title = 'Intensity =100%'
    EditFont.Charset = DEFAULT_CHARSET
    EditFont.Color = clBlack
    EditFont.Height = -13
    EditFont.Name = 'MS Sans Serif'
    EditFont.Style = []
    EditColor = clWindow
    Alignment = taCenter
    SpeedUpDelay = 200
    SpeedUpPeriod = 50
    Max = 100
    Value = 100
    OnValueChange = IntensityEditValueChange
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -14
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    TabOrder = 2
  end
end
