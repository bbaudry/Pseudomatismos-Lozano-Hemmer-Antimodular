object RunFrm: TRunFrm
  Left = 303
  Top = 746
  Width = 408
  Height = 293
  Caption = 'RunFrm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu
  Position = poScreenCenter
  OnClick = FormClick
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Timer: TTimer
    Enabled = False
    Interval = 40
    OnTimer = TimerTimer
    Left = 24
    Top = 24
  end
  object PopupMenu: TPopupMenu
    Left = 72
    Top = 24
    object TakeBackGndItem: TMenuItem
      Caption = '&Take background image in 3s'
      OnClick = TakeBackGndItemClick
    end
    object CameraSettingsItem: TMenuItem
      Caption = '&Camera settings'
      OnClick = CameraSettingsItemClick
    end
    object ViewTrackingItem: TMenuItem
      Caption = 'View tracking'
      OnClick = ViewTrackingItemClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object ShowTriggeredCellsItem: TMenuItem
      Caption = '&Show triggered cells'
      OnClick = ShowTriggeredCellsItemClick
    end
    object SaveToFileItem: TMenuItem
      Caption = 'Save to &file'
      OnClick = SaveToFileItemClick
    end
    object Dash2: TMenuItem
      Caption = '-'
    end
    object AutoCalibrateItem: TMenuItem
      Caption = 'Auto-calibrate'
      OnClick = AutoCalibrateItemClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ExitItem: TMenuItem
      Caption = 'E&xit'
      OnClick = ExitItemClick
    end
  end
  object BackGndTimer: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = BackGndTimerTimer
    Left = 32
    Top = 104
  end
end
