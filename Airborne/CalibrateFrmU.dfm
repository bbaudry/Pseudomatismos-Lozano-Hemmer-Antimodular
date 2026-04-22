object CalibrateFrm: TCalibrateFrm
  Left = 64
  Top = 154
  BorderStyle = bsDialog
  Caption = 'Calibration'
  ClientHeight = 568
  ClientWidth = 797
  Color = clBtnFace
  DefaultMonitor = dmPrimary
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnActivate = FormActivate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox: TPaintBox
    Left = 7
    Top = 68
    Width = 659
    Height = 493
    OnMouseDown = PaintBoxMouseDown
    OnMouseMove = PaintBoxMouseMove
    OnPaint = PaintBoxPaint
  end
  object CameraPanel: TPanel
    Left = 8
    Top = 4
    Width = 641
    Height = 55
    TabOrder = 0
    object Label7: TLabel
      Left = 1
      Top = 1
      Width = 639
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Camera'
      Color = 14339266
      ParentColor = False
    end
    object SaveKImageBtn: TBitBtn
      Left = 12
      Top = 21
      Width = 153
      Height = 25
      Caption = 'Save calibration image #'
      TabOrder = 0
      OnClick = SaveKImageBtnClick
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
        555555FFFFFFFFFF55555000000000055555577777777775FFFF00B8B8B8B8B0
        0000775F5555555777770B0B8B8B8B8B0FF07F75F555555575F70FB0B8B8B8B8
        B0F07F575FFFFFFFF7F70BFB0000000000F07F557777777777570FBFBF0FFFFF
        FFF07F55557F5FFFFFF70BFBFB0F000000F07F55557F777777570FBFBF0FFFFF
        FFF075F5557F5FFFFFF750FBFB0F000000F0575FFF7F777777575700000FFFFF
        FFF05577777F5FF55FF75555550F00FF00005555557F775577775555550FFFFF
        0F055555557F55557F755555550FFFFF00555555557FFFFF7755555555000000
        0555555555777777755555555555555555555555555555555555}
      NumGlyphs = 2
    end
    object KImageEdit: TAprSpinEdit
      Left = 171
      Top = 23
      Width = 48
      Height = 20
      Max = 255.000000000000000000
      Alignment = taCenter
      Enabled = True
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
    object InternalCalBtn: TBitBtn
      Left = 228
      Top = 21
      Width = 129
      Height = 25
      Caption = 'Load calibration file'
      TabOrder = 2
      OnClick = InternalCalBtnClick
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
        5555555555555555555555555555555555555555555555555555555555555555
        555555555555555555555555555555555555555FFFFFFFFFF555550000000000
        55555577777777775F55500B8B8B8B8B05555775F555555575F550F0B8B8B8B8
        B05557F75F555555575F50BF0B8B8B8B8B0557F575FFFFFFFF7F50FBF0000000
        000557F557777777777550BFBFBFBFB0555557F555555557F55550FBFBFBFBF0
        555557F555555FF7555550BFBFBF00055555575F555577755555550BFBF05555
        55555575FFF75555555555700007555555555557777555555555555555555555
        5555555555555555555555555555555555555555555555555555}
      NumGlyphs = 2
    end
    object UndistortCB: TCheckBox
      Left = 468
      Top = 24
      Width = 65
      Height = 17
      Caption = 'Undistort'
      TabOrder = 4
    end
    object ShowKInfoBtn: TBitBtn
      Left = 367
      Top = 21
      Width = 93
      Height = 25
      Caption = 'Show details'
      TabOrder = 3
      OnClick = ShowKInfoBtnClick
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333FFFFF3333333333F797F3333333333F737373FF333333BFB999BFB
        33333337737773773F3333BFBF797FBFB33333733337333373F33BFBFBFBFBFB
        FB3337F33333F33337F33FBFBFB9BFBFBF3337333337F333373FFBFBFBF97BFB
        FBF37F333337FF33337FBFBFBFB99FBFBFB37F3333377FF3337FFBFBFBFB99FB
        FBF37F33333377FF337FBFBF77BF799FBFB37F333FF3377F337FFBFB99FB799B
        FBF373F377F3377F33733FBF997F799FBF3337F377FFF77337F33BFBF99999FB
        FB33373F37777733373333BFBF999FBFB3333373FF77733F7333333BFBFBFBFB
        3333333773FFFF77333333333FBFBF3333333333377777333333}
      NumGlyphs = 2
    end
    object CameraSettingsBtn: TBitBtn
      Left = 557
      Top = 21
      Width = 75
      Height = 25
      Caption = 'Settings'
      TabOrder = 5
      OnClick = CameraSettingsBtnClick
    end
  end
  object FollowCB: TCheckBox
    Left = 704
    Top = 494
    Width = 65
    Height = 17
    Caption = 'Follow'
    TabOrder = 5
    OnClick = FollowCBClick
  end
  object ShowDetailsBtn: TBitBtn
    Left = 688
    Top = 460
    Width = 94
    Height = 24
    Caption = 'Show details'
    TabOrder = 4
    OnClick = ShowDetailsBtnClick
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333FFFFF3333333333F797F3333333333F737373FF333333BFB999BFB
      33333337737773773F3333BFBF797FBFB33333733337333373F33BFBFBFBFBFB
      FB3337F33333F33337F33FBFBFB9BFBFBF3337333337F333373FFBFBFBF97BFB
      FBF37F333337FF33337FBFBFBFB99FBFBFB37F3333377FF3337FFBFBFBFB99FB
      FBF37F33333377FF337FBFBF77BF799FBFB37F333FF3377F337FFBFB99FB799B
      FBF373F377F3377F33733FBF997F799FBF3337F377FFF77337F33BFBF99999FB
      FB33373F37777733373333BFBF999FBFB3333373FF77733F7333333BFBFBFBFB
      3333333773FFFF77333333333FBFBF3333333333377777333333}
    NumGlyphs = 2
  end
  object CalBtn: TBitBtn
    Left = 688
    Top = 428
    Width = 93
    Height = 25
    Caption = 'Calibrate'
    TabOrder = 3
    OnClick = CalBtnClick
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00337000000000
      73333337777777773F333308888888880333337F3F3F3FFF7F33330808089998
      0333337F737377737F333308888888880333337F3F3F3F3F7F33330808080808
      0333337F737373737F333308888888880333337F3F3F3F3F7F33330808080808
      0333337F737373737F333308888888880333337F3F3F3F3F7F33330808080808
      0333337F737373737F333308888888880333337F3FFFFFFF7F33330800000008
      0333337F7777777F7F333308000E0E080333337F7FFFFF7F7F33330800000008
      0333337F777777737F333308888888880333337F333333337F33330888888888
      03333373FFFFFFFF733333700000000073333337777777773333}
    NumGlyphs = 2
  end
  object PlacePanel: TPanel
    Left = 676
    Top = 204
    Width = 116
    Height = 214
    Color = 13292238
    TabOrder = 2
    DesignSize = (
      116
      214)
    object MagPB: TPaintBox
      Left = 8
      Top = 8
      Width = 100
      Height = 100
      OnClick = MagPBClick
    end
    object XLbl: TLabel
      Left = 27
      Top = 166
      Width = 10
      Height = 13
      Caption = 'X:'
    end
    object PlacePtLbl: TLabel
      Left = 13
      Top = 117
      Width = 63
      Height = 13
      Caption = 'Place point #'
    end
    object YLbl: TLabel
      Left = 27
      Top = 190
      Width = 10
      Height = 13
      Caption = 'Y:'
    end
    object PointEdit: TAprSpinEdit
      Left = 14
      Top = 135
      Width = 48
      Height = 20
      Value = 1.000000000000000000
      Min = 1.000000000000000000
      Max = 5.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = PointEditChange
      Increment = 1.000000000000000000
      EditText = '1'
      Anchors = [akTop, akRight]
      TabOrder = 0
    end
    object XEdit: TAprSpinEdit
      Left = 43
      Top = 162
      Width = 48
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = CalPtEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      OnExit = CalPtEditChange
      TabOrder = 1
    end
    object YEdit: TAprSpinEdit
      Left = 43
      Top = 186
      Width = 48
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = CalPtEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      OnExit = CalPtEditChange
      TabOrder = 2
    end
  end
  object ProjectorWindowPanel: TPanel
    Left = 674
    Top = 66
    Width = 116
    Height = 122
    TabOrder = 1
    object Label2: TLabel
      Left = 28
      Top = 25
      Width = 21
      Height = 13
      Caption = 'Left:'
    end
    object Label1: TLabel
      Left = 24
      Top = 49
      Width = 22
      Height = 13
      Caption = 'Top:'
    end
    object Label4: TLabel
      Left = 14
      Top = 97
      Width = 34
      Height = 13
      Caption = 'Height:'
    end
    object Label3: TLabel
      Left = 17
      Top = 73
      Width = 31
      Height = 13
      Caption = 'Width:'
    end
    object Label5: TLabel
      Left = 1
      Top = 1
      Width = 114
      Height = 13
      Align = alTop
      Alignment = taCenter
      Caption = 'Projector window'
      Color = 14339266
      ParentColor = False
    end
    object LeftEdit: TAprSpinEdit
      Left = 50
      Top = 21
      Width = 48
      Height = 20
      Min = -9999.000000000000000000
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = LeftEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
    object TopEdit: TAprSpinEdit
      Left = 50
      Top = 45
      Width = 48
      Height = 20
      Min = -9999.000000000000000000
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = TopEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 1
    end
    object HeightEdit: TAprSpinEdit
      Left = 50
      Top = 93
      Width = 48
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = HeightEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 3
    end
    object WidthEdit: TAprSpinEdit
      Left = 50
      Top = 69
      Width = 48
      Height = 20
      Max = 9999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = WidthEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 2
    end
  end
  object LoadCalDlg: TOpenDialog
    DefaultExt = 'cal'
    Filter = 'Calibration files|*.cal'
    Left = 32
    Top = 104
  end
end
