object SetupFrm: TSetupFrm
  Left = 426
  Top = 253
  Width = 653
  Height = 629
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ShowLbl: TLabel
    Left = 40
    Top = 152
    Width = 27
    Height = 13
    Caption = 'Show'
  end
  object Label1: TLabel
    Left = 136
    Top = 152
    Width = 80
    Height = 13
    Caption = 'columns of video'
  end
  object Label2: TLabel
    Left = 16
    Top = 40
    Width = 32
    Height = 13
    Caption = 'Label2'
  end
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 32
    Height = 13
    Caption = 'Videos'
  end
  object AprSpinEdit1: TAprSpinEdit
    Left = 73
    Top = 148
    Width = 48
    Height = 20
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 280
    Top = 72
    Width = 185
    Height = 41
    Caption = 'Panel1'
    TabOrder = 1
  end
end
