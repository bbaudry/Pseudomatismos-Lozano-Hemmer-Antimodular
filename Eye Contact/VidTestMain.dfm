object VidTestMainFrm: TVidTestMainFrm
  Left = 981
  Top = 309
  Width = 282
  Height = 238
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox: TPaintBox
    Left = 64
    Top = 40
    Width = 64
    Height = 80
    OnPaint = PaintBoxPaint
  end
  object FrameLbl: TLabel
    Left = 16
    Top = 192
    Width = 90
    Height = 13
    Caption = 'Frame #999 of 999'
  end
  object PaintBox1: TPaintBox
    Left = 144
    Top = 40
    Width = 64
    Height = 80
    OnPaint = PaintBoxPaint
  end
  object Label1: TLabel
    Left = 16
    Top = 13
    Width = 37
    Height = 13
    Caption = 'Video #'
  end
  object OfLbl: TLabel
    Left = 120
    Top = 13
    Width = 30
    Height = 13
    Caption = 'of 865'
  end
  object ScrollBar: TScrollBar
    Left = 16
    Top = 168
    Width = 241
    Height = 16
    PageSize = 0
    TabOrder = 0
    OnChange = ScrollBarChange
  end
  object IntensityEdit: TNBFillEdit
    Left = 32
    Top = 135
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
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clYellow
    Font.Height = -14
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    TabOrder = 1
  end
  object VideoEdit: TAprSpinEdit
    Left = 60
    Top = 8
    Width = 53
    Height = 20
    Value = 1.000000000000000000
    Min = 1.000000000000000000
    Max = 999.000000000000000000
    Alignment = taCenter
    Enabled = True
    Increment = 1.000000000000000000
    EditText = '1'
    TabOrder = 2
  end
  object ViewLoadedBtn: TButton
    Left = 172
    Top = 5
    Width = 75
    Height = 25
    Caption = 'View loaded'
    TabOrder = 3
  end
end
