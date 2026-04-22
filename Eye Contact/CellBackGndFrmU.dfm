object CellBackGndFrm: TCellBackGndFrm
  Left = 331
  Top = 275
  Width = 436
  Height = 352
  Caption = 'Autobackground test'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object XCellsLbl: TLabel
    Left = 195
    Top = 236
    Width = 35
    Height = 13
    Caption = 'X Cells:'
  end
  object YCellsLbl: TLabel
    Left = 195
    Top = 260
    Width = 35
    Height = 13
    Caption = 'Y Cells:'
  end
  object MaxCountLbl: TLabel
    Left = 291
    Top = 260
    Width = 53
    Height = 13
    Caption = 'Max count:'
  end
  object ThresholdLbl: TLabel
    Left = 293
    Top = 236
    Width = 50
    Height = 13
    Caption = 'Threshold:'
  end
  object TimeLbl: TLabel
    Left = 250
    Top = 292
    Width = 26
    Height = 13
    Caption = 'Time:'
  end
  object BackGndBtn: TBitBtn
    Left = 12
    Top = 254
    Width = 144
    Height = 21
    Caption = 'Take background reference'
    TabOrder = 0
    OnClick = BackGndBtnClick
  end
  object XCellsEdit: TAprSpinEdit
    Left = 234
    Top = 232
    Width = 47
    Height = 20
    Value = 1.000000000000000000
    Min = 1.000000000000000000
    Max = 100.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = XCellsEditChange
    Increment = 1.000000000000000000
    EditText = '1'
    TabOrder = 1
  end
  object YCellsEdit: TAprSpinEdit
    Left = 234
    Top = 256
    Width = 47
    Height = 20
    Value = 1.000000000000000000
    Min = 1.000000000000000000
    Max = 100.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = YCellsEditChange
    Increment = 1.000000000000000000
    EditText = '1'
    TabOrder = 2
  end
  object MaxCountEdit: TAprSpinEdit
    Left = 348
    Top = 256
    Width = 52
    Height = 20
    Value = 1.000000000000000000
    Max = 999.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = MaxCountEditChange
    Increment = 1.000000000000000000
    EditText = '1'
    TabOrder = 3
  end
  object ThresholdEdit: TAprSpinEdit
    Left = 348
    Top = 232
    Width = 52
    Height = 20
    Value = 1.000000000000000000
    Min = 1.000000000000000000
    Max = 100.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = ThresholdEditChange
    Increment = 1.000000000000000000
    EditText = '1'
    TabOrder = 4
  end
  object MinTimeEdit: TAprSpinEdit
    Left = 284
    Top = 287
    Width = 52
    Height = 20
    Value = 60.000000000000000000
    Decimals = 1
    Min = 1.000000000000000000
    Max = 999999.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = MinTimeEditChange
    Increment = 1.000000000000000000
    EditText = '60.0'
    TabOrder = 5
  end
  object DrawGB: TGroupBox
    Left = 7
    Top = 282
    Width = 171
    Height = 39
    Caption = 'Draw'
    TabOrder = 6
    object DrawCellsCB: TAprCheckBox
      Left = 9
      Top = 16
      Width = 56
      Height = 17
      Caption = 'Cells'
      TabOrder = 0
      TabStop = True
    end
    object ShowCountsCB: TAprCheckBox
      Left = 58
      Top = 16
      Width = 56
      Height = 17
      Caption = 'Counts'
      TabOrder = 1
      TabStop = True
    end
    object ShowAgesCB: TAprCheckBox
      Left = 117
      Top = 16
      Width = 46
      Height = 17
      State = cbChecked
      Caption = 'Ages'
      Checked = True
      TabOrder = 2
      TabStop = True
    end
  end
  object EnabledCB: TCheckBox
    Left = 11
    Top = 232
    Width = 153
    Height = 17
    Caption = 'Auto background enabled'
    TabOrder = 7
  end
  object TabControl: TTabControl
    Left = 4
    Top = 4
    Width = 421
    Height = 221
    TabOrder = 8
    Tabs.Strings = (
      'Raw'
      'Background'
      'Subtracted'
      'Thresholded'
      'TestBackGnd'
      'TestBackGnd -')
    TabIndex = 0
    object PaintBox: TPaintBox
      Left = 136
      Top = 55
      Width = 160
      Height = 120
      OnPaint = PaintBoxPaint
    end
  end
end
