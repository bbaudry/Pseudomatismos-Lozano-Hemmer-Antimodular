object DisplaySetupFrm: TDisplaySetupFrm
  Left = 262
  Top = 472
  BorderStyle = bsDialog
  Caption = 'Display'
  ClientHeight = 167
  ClientWidth = 215
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object WidthLbl: TLabel
    Left = 22
    Top = 41
    Width = 31
    Height = 13
    Caption = 'Width:'
  end
  object RowsLbl: TLabel
    Left = 118
    Top = 13
    Width = 27
    Height = 13
    Caption = 'Rows'
  end
  object ColumnsLbl: TLabel
    Left = 11
    Top = 14
    Width = 40
    Height = 13
    Caption = 'Columns'
  end
  object HeightLbl: TLabel
    Left = 116
    Top = 40
    Width = 34
    Height = 13
    Caption = 'Height:'
  end
  object WidthEdit: TAprSpinEdit
    Left = 58
    Top = 37
    Width = 48
    Height = 20
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = WidthEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 2
  end
  object ColumnsEdit: TAprSpinEdit
    Left = 58
    Top = 10
    Width = 48
    Height = 20
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = ColumnsEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 0
  end
  object RowsEdit: TAprSpinEdit
    Left = 151
    Top = 10
    Width = 48
    Height = 20
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = RowsEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 1
  end
  object HeightEdit: TAprSpinEdit
    Left = 152
    Top = 36
    Width = 48
    Height = 20
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = HeightEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 3
  end
  object MakeBmpsBtn: TBitBtn
    Left = 24
    Top = 72
    Width = 163
    Height = 30
    Caption = 'Generate bmps from movs'
    TabOrder = 4
    OnClick = MakeBmpsBtnClick
    Glyph.Data = {
      4E010000424D4E01000000000000760000002800000012000000120000000100
      040000000000D800000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00660000000000
      066666000000668777777777000666000000668FFFFFFFF7070666000000668F
      FF44FFF7070006000000668FFF44FFF7070706000000668F444444F707070600
      0000668F444444F7070706000000668FFF44FFF7070706000000668FFF44FFF7
      070706000000668FFFFFFFF7070706000000668FFFFFF000070706000000668F
      FFFFF7F8F70706000000668FFFFFF7800007060000006688888888F7F8F70600
      000066668FFFFFF7800006000000666688888888F7F8660000006666668FFFFF
      F78666000000666666888888886666000000}
  end
  object DoneBtn: TButton
    Left = 120
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Done'
    TabOrder = 5
    OnClick = DoneBtnClick
  end
  object OverwriteCB: TAprCheckBox
    Left = 40
    Top = 110
    Width = 145
    Height = 17
    Caption = 'Overwrite existing files'
    TabOrder = 6
    TabStop = True
  end
end
