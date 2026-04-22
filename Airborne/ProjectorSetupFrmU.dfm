object ProjectorSetupFrm: TProjectorSetupFrm
  Left = 579
  Top = 490
  BorderStyle = bsDialog
  Caption = 'Projector'
  ClientHeight = 73
  ClientWidth = 191
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 19
    Top = 14
    Width = 21
    Height = 13
    Caption = 'Left:'
  end
  object Label3: TLabel
    Left = 7
    Top = 46
    Width = 31
    Height = 13
    Caption = 'Width:'
  end
  object Label4: TLabel
    Left = 97
    Top = 47
    Width = 34
    Height = 13
    Caption = 'Height:'
  end
  object Label1: TLabel
    Left = 107
    Top = 14
    Width = 22
    Height = 13
    Caption = 'Top:'
  end
  object WidthEdit: TAprSpinEdit
    Left = 40
    Top = 42
    Width = 48
    Height = 20
    Max = 9999.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = WidthEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 0
  end
  object TopEdit: TAprSpinEdit
    Left = 133
    Top = 10
    Width = 48
    Height = 20
    Max = 9999.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = TopEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 1
  end
  object HeightEdit: TAprSpinEdit
    Left = 133
    Top = 43
    Width = 48
    Height = 20
    Max = 9999.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = HeightEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 2
  end
  object LeftEdit: TAprSpinEdit
    Left = 41
    Top = 10
    Width = 48
    Height = 20
    Max = 9999.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = LeftEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 3
  end
end
