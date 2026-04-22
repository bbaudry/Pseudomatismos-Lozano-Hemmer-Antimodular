object BmpMakeFrm: TBmpMakeFrm
  Left = 460
  Top = 91
  BorderStyle = bsSingle
  Caption = 'Extracting frames'
  ClientHeight = 120
  ClientWidth = 361
  Color = 12692671
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object VideoPB: TAprProgBar
    Left = 14
    Top = 9
    Width = 329
    Height = 24
    BackGndColor = 13087158
    FillColor = 13392791
    Title = 'Video #1 of 300'
    Value = 50.000000000000000000
    Max = 100.000000000000000000
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    TabOrder = 0
  end
  object FramePB: TAprProgBar
    Left = 14
    Top = 44
    Width = 329
    Height = 24
    BackGndColor = 13087158
    FillColor = 13392791
    Title = 'Frame #1 of 999'
    Value = 50.000000000000000000
    Max = 100.000000000000000000
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    TabOrder = 1
  end
  object CancelBtn: TBitBtn
    Left = 262
    Top = 82
    Width = 75
    Height = 28
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = CancelBtnClick
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000130B0000130B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333FFFFF3333333333999993333333333F77777FFF333333999999999
      33333337777FF377FF3333993370739993333377FF373F377FF3399993000339
      993337777F777F3377F3393999707333993337F77737333337FF993399933333
      399377F3777FF333377F993339903333399377F33737FF33377F993333707333
      399377F333377FF3377F993333101933399377F333777FFF377F993333000993
      399377FF3377737FF7733993330009993933373FF3777377F7F3399933000399
      99333773FF777F777733339993707339933333773FF7FFF77333333999999999
      3333333777333777333333333999993333333333377777333333}
    NumGlyphs = 2
  end
end
