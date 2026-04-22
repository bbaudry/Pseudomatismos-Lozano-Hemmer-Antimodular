object MainFrm: TMainFrm
  Left = 1659
  Top = 459
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 132
  ClientWidth = 184
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnMouseDown = FormMouseDown
  PixelsPerInch = 96
  TextHeight = 13
  object GLPanel: TCanvasPanel
    Left = 0
    Top = 0
    Width = 184
    Height = 132
    Align = alClient
    TabOrder = 0
    OnMouseDown = GLPanelMouseDown
    OnPaint = GLPanelPaint
  end
  object BackGndTimer: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = BackGndTimerTimer
    Left = 8
    Top = 8
  end
  object PopupMenu: TPopupMenu
    Left = 56
    Top = 8
    object CalibrateItem: TMenuItem
      Caption = 'Recalibrate in 3 seconds (stand away from camera)'
      OnClick = CalibrateItemClick
    end
    object SettingsItem: TMenuItem
      Caption = '&Settings'
      OnClick = SettingsItemClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object QuitProgramItem: TMenuItem
      Caption = 'Quit program'
      OnClick = QuitProgramItemClick
    end
  end
  object DebugMenu: TPopupMenu
    AutoPopup = False
    OwnerDraw = True
    Left = 96
    Top = 8
    object TakeBackGndIn10sItem: TMenuItem
      Caption = 'Recalibrate in 10 seconds (stand away from the camera)'
      OnClick = TakeBackGndIn10sItemClick
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object SetupDisplayItem: TMenuItem
      Caption = '&Setup display'
      OnClick = SetupDisplayItemClick
    end
    object SetupTrackingItem: TMenuItem
      Caption = '&Setup tracking'
      OnClick = SetupTrackingItemClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object ViewTrackingItem: TMenuItem
      Caption = 'View tracking'
      OnClick = ViewTrackingItemClick
    end
    object Usesegmentertracking1: TMenuItem
      Caption = 'Use segmenter tracking'
    end
  end
  object SecretMenu: TPopupMenu
    Left = 136
    Top = 8
    object CellTestItem: TMenuItem
      Caption = '&Cell test'
      OnClick = CellTestItemClick
    end
    object BlowUpTestItem: TMenuItem
      Caption = '&Blow up test'
      OnClick = BlowUpTestItemClick
    end
    object TrackTestItem: TMenuItem
      Caption = '&Track test'
      OnClick = TrackTestItemClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object ShowSuperCellsItem: TMenuItem
      Caption = 'Show super cells'
      OnClick = ShowSuperCellsItemClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object StopWatchItem: TMenuItem
      Caption = 'StopWatch?'
      OnClick = StopWatchItemClick
    end
    object TestCellsItem: TMenuItem
      Caption = 'Test Cells'
      OnClick = TestCellsItemClick
    end
    object ShowTestPatternItem: TMenuItem
      Caption = 'Show test pattern'
      OnClick = ShowTestPatternItemClick
    end
  end
  object CameraTimer: TTimer
    Enabled = False
    Interval = 33
    OnTimer = CameraTimerTimer
    Left = 24
    Top = 48
  end
end
