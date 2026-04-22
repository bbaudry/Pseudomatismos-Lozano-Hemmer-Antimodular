object ProjectorMaskFrm: TProjectorMaskFrm
  Left = 184
  Top = 278
  BorderStyle = bsDialog
  Caption = 'Projector mask'
  ClientHeight = 296
  ClientWidth = 538
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object EnableCB: TAprCheckBox
    Left = 8
    Top = 8
    Width = 97
    Height = 17
    Caption = 'Enable mask'
    TabOrder = 0
    TabStop = True
    OnClick = EnableCBClick
  end
  object Panel1: TPanel
    Left = 8
    Top = 32
    Width = 97
    Height = 73
    TabOrder = 1
    object Label2: TLabel
      Left = 1
      Top = 1
      Width = 95
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Top left point'
      Color = 13814475
      ParentColor = False
    end
    object Label3: TLabel
      Left = 18
      Top = 25
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object Label4: TLabel
      Left = 18
      Top = 49
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object TopLeftXEdit: TAprSpinEdit
      Left = 32
      Top = 21
      Width = 48
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
    object TopLeftYEdit: TAprSpinEdit
      Left = 32
      Top = 45
      Width = 48
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 208
    Top = 32
    Width = 97
    Height = 73
    TabOrder = 2
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 95
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Top right point'
      Color = 13814475
      ParentColor = False
    end
    object Label5: TLabel
      Left = 18
      Top = 25
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object Label6: TLabel
      Left = 18
      Top = 49
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object TopRightXEdit: TAprSpinEdit
      Left = 32
      Top = 21
      Width = 48
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
    object TopRightYEdit: TAprSpinEdit
      Left = 32
      Top = 45
      Width = 49
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
  end
  object Panel3: TPanel
    Left = 208
    Top = 216
    Width = 97
    Height = 73
    TabOrder = 3
    object Label7: TLabel
      Left = 1
      Top = 1
      Width = 95
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Bottom right point'
      Color = 13814475
      ParentColor = False
    end
    object Label8: TLabel
      Left = 17
      Top = 25
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object Label9: TLabel
      Left = 17
      Top = 49
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object BottomRightXEdit: TAprSpinEdit
      Left = 31
      Top = 21
      Width = 49
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
    object BottomRightYEdit: TAprSpinEdit
      Left = 31
      Top = 45
      Width = 49
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
  end
  object Panel4: TPanel
    Left = 8
    Top = 216
    Width = 97
    Height = 73
    TabOrder = 4
    object Label10: TLabel
      Left = 1
      Top = 1
      Width = 95
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Bottom left point'
      Color = 13814475
      ParentColor = False
    end
    object Label11: TLabel
      Left = 17
      Top = 25
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object Label12: TLabel
      Left = 17
      Top = 49
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object BottomLeftXEdit: TAprSpinEdit
      Left = 31
      Top = 21
      Width = 49
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
    object BottomLeftYEdit: TAprSpinEdit
      Left = 31
      Top = 45
      Width = 49
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
  end
  object Panel5: TPanel
    Left = 104
    Top = 112
    Width = 105
    Height = 98
    TabOrder = 5
    object Label13: TLabel
      Left = 1
      Top = 1
      Width = 103
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Center point'
      Color = 13814475
      ParentColor = False
    end
    object Label14: TLabel
      Left = 20
      Top = 25
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object Label15: TLabel
      Left = 20
      Top = 49
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object Label16: TLabel
      Left = 8
      Top = 74
      Width = 36
      Height = 13
      Caption = 'Radius:'
    end
    object CenterXEdit: TAprSpinEdit
      Left = 34
      Top = 21
      Width = 49
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
    object CenterYEdit: TAprSpinEdit
      Left = 34
      Top = 45
      Width = 49
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
    object CenterREdit: TAprSpinEdit
      Left = 48
      Top = 70
      Width = 48
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = EditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 2
    end
  end
  object DrawMaskBtn: TButton
    Left = 120
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Draw mask'
    TabOrder = 6
    OnClick = DrawMaskBtnClick
  end
  object ScrollBox: TScrollBox
    Left = 313
    Top = 6
    Width = 214
    Height = 283
    HorzScrollBar.Range = 1050
    VertScrollBar.Range = 1400
    AutoScroll = False
    TabOrder = 7
    object PaintBox: TPaintBox
      Left = 0
      Top = 0
      Width = 1050
      Height = 1400
      OnMouseDown = PaintBoxMouseDown
      OnPaint = PaintBoxPaint
    end
  end
  object SaveBtn: TBitBtn
    Left = 120
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Save mask'
    TabOrder = 8
    OnClick = SaveBtnClick
  end
end
