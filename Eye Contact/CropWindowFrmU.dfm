object CropWindowFrm: TCropWindowFrm
  Left = 254
  Top = 223
  BorderStyle = bsSingle
  Caption = 'Crop Window'
  ClientHeight = 628
  ClientWidth = 657
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object CameraPB: TPaintBox
    Left = 5
    Top = 142
    Width = 640
    Height = 480
    OnMouseDown = CameraPBMouseDown
    OnMouseMove = CameraPBMouseMove
  end
  object SmallPB: TPaintBox
    Left = 445
    Top = 6
    Width = 160
    Height = 120
  end
  object AspectRatioCB: TAprCheckBox
    Left = 18
    Top = 8
    Width = 143
    Height = 17
    Caption = 'Maintain 4:3 aspect ratio'
    TabOrder = 0
    TabStop = True
    OnClick = AspectRatioCBClick
  end
  object Memo: TMemo
    Left = 13
    Top = 68
    Width = 345
    Height = 35
    Color = clInfoBk
    Lines.Strings = (
      'Click once to place the first corner of the cropping window.'
      'Click again to place the second corner.')
    TabOrder = 1
  end
  object FlipImageCB: TAprCheckBox
    Left = 18
    Top = 33
    Width = 97
    Height = 17
    Caption = 'Flip image'
    TabOrder = 2
    TabStop = True
    OnClick = FlipImageCBClick
  end
  object CamSettingsBtn: TBitBtn
    Left = 195
    Top = 14
    Width = 89
    Height = 25
    Caption = 'Settings'
    TabOrder = 3
    OnClick = CamSettingsBtnClick
    Glyph.Data = {
      4E010000424D4E01000000000000760000002800000012000000120000000100
      040000000000D800000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00666666666666
      6666660000006666666666666666660000006666666666666666660000006666
      666666666666660000006668000000008666660000006668F888888806600600
      00006668F79707080008060000006668F7777778080806000000666877777778
      0707060000006660888887780F0706000000086000000878088F060000000808
      888880FF8668860000000F8FFFFFF08886666600000008688888866666666600
      0000666666666666666666000000666666666666666666000000666666666666
      666666000000666666666666666666000000}
  end
end
