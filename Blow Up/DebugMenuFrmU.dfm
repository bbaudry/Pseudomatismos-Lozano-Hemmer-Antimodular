object DebugMenuFrm: TDebugMenuFrm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  ClientHeight = 74
  ClientWidth = 289
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object RecalBtn: TButton
    Left = 8
    Top = 8
    Width = 273
    Height = 25
    Caption = 'Recalibrate in 10 seconds (stand away from camera)'
    TabOrder = 0
    OnClick = RecalBtnClick
  end
  object DisplayBtn: TBitBtn
    Left = 8
    Top = 41
    Width = 75
    Height = 25
    Caption = 'Display'
    TabOrder = 1
    OnClick = DisplayBtnClick
  end
  object TrackingBtn: TBitBtn
    Left = 89
    Top = 41
    Width = 96
    Height = 25
    Caption = 'Setup tracking'
    TabOrder = 2
    OnClick = TrackingBtnClick
  end
  object ViewTrackingBtn: TBitBtn
    Left = 192
    Top = 41
    Width = 89
    Height = 25
    Caption = 'View tracking'
    TabOrder = 3
    OnClick = ViewTrackingBtnClick
  end
end
