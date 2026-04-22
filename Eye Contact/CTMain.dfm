object CTMainFrm: TCTMainFrm
  Left = 37
  Top = 349
  Width = 1017
  Height = 544
  Caption = 'CTMainFrm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object RawPB: TPaintBox
    Left = 8
    Top = 8
    Width = 640
    Height = 480
    OnPaint = RawPBPaint
  end
  object MonoPB: TPaintBox
    Left = 664
    Top = 16
    Width = 160
    Height = 120
    OnPaint = MonoPBPaint
  end
  object DilatedPB: TPaintBox
    Left = 664
    Top = 144
    Width = 160
    Height = 120
    OnPaint = DilatedPBPaint
  end
  object Button1: TButton
    Left = 720
    Top = 336
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Zprof: TZprofiler
    VisibleInDesignMode = False
    Left = 816
    Top = 24
  end
end
