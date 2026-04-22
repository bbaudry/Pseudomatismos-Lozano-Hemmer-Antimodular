object TrackingSetupFrm: TTrackingSetupFrm
  Left = 49
  Top = 145
  BorderStyle = bsDialog
  Caption = 'Camera and Tracking setup'
  ClientHeight = 242
  ClientWidth = 486
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object CameraLbl: TLabel
    Left = 8
    Top = 5
    Width = 169
    Height = 15
    Alignment = taCenter
    AutoSize = False
    Caption = 'Camera'
    Color = 13341814
    ParentColor = False
  end
  object ShowLbl: TLabel
    Left = 352
    Top = 5
    Width = 124
    Height = 15
    Alignment = taCenter
    AutoSize = False
    Caption = 'Show'
    Color = 13341814
    ParentColor = False
  end
  object TrackerLbl: TLabel
    Left = 195
    Top = 5
    Width = 140
    Height = 15
    Alignment = taCenter
    AutoSize = False
    Caption = 'Tracker'
    Color = 13341814
    ParentColor = False
  end
  object TrackerThresholdLbl: TLabel
    Left = 204
    Top = 56
    Width = 50
    Height = 13
    Caption = 'Threshold:'
  end
  object TrackerPercentageLbl: TLabel
    Left = 204
    Top = 80
    Width = 58
    Height = 13
    Caption = 'Percentage:'
  end
  object AutoBackGndLbl: TLabel
    Left = 195
    Top = 184
    Width = 140
    Height = 15
    Alignment = taCenter
    AutoSize = False
    Caption = 'Auto background'
    Color = 13341814
    ParentColor = False
  end
  object TriggerAgeLbl: TLabel
    Left = 204
    Top = 104
    Width = 57
    Height = 13
    Caption = 'Trigger age:'
  end
  object UntriggerAgeLbl: TLabel
    Left = 204
    Top = 128
    Width = 67
    Height = 13
    Caption = 'Untrigger age:'
  end
  object ShowCellOutlinesCB: TAprCheckBox
    Left = 358
    Top = 27
    Width = 97
    Height = 17
    Caption = 'Outlines of cells'
    TabOrder = 0
    TabStop = True
    OnClick = ShowCBClick
  end
  object ShowPixelsOverThresholdCB: TAprCheckBox
    Left = 358
    Top = 112
    Width = 115
    Height = 17
    Caption = 'Pixels over threshold'
    TabOrder = 1
    TabStop = True
    OnClick = ShowCBClick
  end
  object TabControl: TTabControl
    Left = 8
    Top = 77
    Width = 180
    Height = 161
    TabOrder = 2
    Tabs.Strings = (
      'Raw'
      'Background'
      'Subtracted')
    TabIndex = 0
    object PaintBox: TPaintBox
      Left = 10
      Top = 31
      Width = 160
      Height = 120
    end
  end
  object CamBtn: TButton
    Left = 107
    Top = 48
    Width = 33
    Height = 22
    Caption = 'Cam'
    TabOrder = 3
    OnClick = CamBtnClick
  end
  object PinBtn: TButton
    Left = 146
    Top = 49
    Width = 33
    Height = 22
    Caption = 'Pin'
    TabOrder = 4
    OnClick = PinBtnClick
  end
  object TrackerThresholdEdit: TAprSpinEdit
    Left = 273
    Top = 51
    Width = 48
    Height = 20
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = TrackerThresholdEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 5
  end
  object TrackerPercentageEdit: TAprSpinEdit
    Left = 273
    Top = 75
    Width = 48
    Height = 20
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = TrackerPercentageEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 6
  end
  object SaveBtn: TBitBtn
    Left = 409
    Top = 209
    Width = 67
    Height = 24
    Caption = '&Done'
    TabOrder = 7
    OnClick = SaveBtnClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      3333333333333333333333330000333333333333333333333333F33333333333
      00003333344333333333333333388F3333333333000033334224333333333333
      338338F3333333330000333422224333333333333833338F3333333300003342
      222224333333333383333338F3333333000034222A22224333333338F338F333
      8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
      33333338F83338F338F33333000033A33333A222433333338333338F338F3333
      0000333333333A222433333333333338F338F33300003333333333A222433333
      333333338F338F33000033333333333A222433333333333338F338F300003333
      33333333A222433333333333338F338F00003333333333333A22433333333333
      3338F38F000033333333333333A223333333333333338F830000333333333333
      333A333333333333333338330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
    Style = bsNew
  end
  object ShowActiveCellsCB: TAprCheckBox
    Left = 358
    Top = 90
    Width = 97
    Height = 17
    Caption = 'Active cells'
    TabOrder = 8
    TabStop = True
    OnClick = ShowCBClick
  end
  object TakeBackGndBtn: TButton
    Left = 198
    Top = 25
    Width = 131
    Height = 22
    Caption = 'Set background after 3s'
    TabOrder = 9
    OnClick = TakeBackGndBtnClick
  end
  object AutoBackGndTestBtn: TBitBtn
    Left = 227
    Top = 208
    Width = 75
    Height = 23
    Caption = 'Setup'
    TabOrder = 10
    OnClick = AutoBackGndTestBtnClick
    NumGlyphs = 2
  end
  object TriggerAgeEdit: TAprSpinEdit
    Left = 273
    Top = 99
    Width = 48
    Height = 20
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = TriggerAgeEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 11
  end
  object UntriggerAgeEdit: TAprSpinEdit
    Left = 273
    Top = 123
    Width = 48
    Height = 20
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = UntriggerAgeEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 12
  end
  object DilateCB: TAprCheckBox
    Left = 206
    Top = 149
    Width = 67
    Height = 17
    Caption = 'Dilate R='
    TabOrder = 13
    TabStop = True
    OnClick = DilateCBClick
  end
  object ShowCoveredCellsCB: TAprCheckBox
    Left = 358
    Top = 48
    Width = 97
    Height = 17
    Caption = 'Covered cells'
    TabOrder = 14
    TabStop = True
    OnClick = ShowCBClick
  end
  object ShowTriggeredCellsCB: TAprCheckBox
    Left = 358
    Top = 69
    Width = 97
    Height = 17
    Caption = 'Triggered cells'
    TabOrder = 15
    TabStop = True
    OnClick = ShowCBClick
  end
  object DilateREdit: TAprSpinEdit
    Left = 273
    Top = 147
    Width = 48
    Height = 20
    Value = 1.000000000000000000
    Decimals = 1
    Min = 0.800000011920929000
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = DilateREditChange
    Increment = 0.100000001490116100
    EditText = '1.0'
    TabOrder = 16
  end
  object FlipImageCB: TAprCheckBox
    Left = 55
    Top = 25
    Width = 73
    Height = 17
    Caption = 'Flip image'
    TabOrder = 17
    TabStop = True
    OnClick = FlipImageCBClick
  end
  object CamSettingsBtn: TBitBtn
    Left = 10
    Top = 46
    Width = 89
    Height = 25
    Caption = 'Settings'
    TabOrder = 18
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
  object DelayTimer: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = DelayTimerTimer
    Left = 32
    Top = 96
  end
end
