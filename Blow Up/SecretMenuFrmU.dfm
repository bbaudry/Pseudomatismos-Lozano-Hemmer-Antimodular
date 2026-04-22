object SecretMenuFrm: TSecretMenuFrm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  ClientHeight = 213
  ClientWidth = 122
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object CellTestBtn: TBitBtn
    Left = 8
    Top = 8
    Width = 104
    Height = 25
    Caption = 'Cell test'
    TabOrder = 0
    OnClick = CellTestBtnClick
  end
  object BlowupTestBtn: TBitBtn
    Left = 8
    Top = 39
    Width = 104
    Height = 25
    Caption = 'Blowup test'
    TabOrder = 1
    OnClick = BlowupTestBtnClick
  end
  object TrackTestBtn: TBitBtn
    Left = 8
    Top = 70
    Width = 104
    Height = 25
    Caption = 'Track test'
    TabOrder = 2
    OnClick = TrackTestBtnClick
  end
  object StopWatchBtn: TBitBtn
    Left = 8
    Top = 101
    Width = 104
    Height = 25
    Caption = 'Stopwatch'
    TabOrder = 3
    OnClick = StopWatchBtnClick
  end
  object TestCellsBtn: TBitBtn
    Left = 8
    Top = 132
    Width = 104
    Height = 25
    Caption = 'Test cells'
    TabOrder = 4
    OnClick = TestCellsBtnClick
  end
  object ShowSuperCellsCB: TAprCheckBox
    Left = 8
    Top = 166
    Width = 97
    Height = 17
    Caption = 'Show super cells'
    TabOrder = 5
    TabStop = True
    OnClick = ShowSuperCellsCBClick
  end
  object ShowTestPatternCB: TAprCheckBox
    Left = 8
    Top = 186
    Width = 104
    Height = 17
    Caption = 'Show test pattern'
    TabOrder = 6
    TabStop = True
    OnClick = ShowTestPatternCBClick
  end
end
