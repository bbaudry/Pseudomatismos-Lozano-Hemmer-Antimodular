object MainFrm: TMainFrm
  Left = 0
  Top = 207
  BorderStyle = bsSingle
  Caption = 'Airborne'
  ClientHeight = 227
  ClientWidth = 282
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object GLPanel: TCanvasPanel
    Left = 0
    Top = 0
    Width = 282
    Height = 227
    Align = alClient
    TabOrder = 0
    OnMouseDown = GLPanelMouseDown
    OnMouseMove = GLPanelMouseMove
    OnResize = GLPanelResize
  end
  object Timer: TTimer
    Enabled = False
    Interval = 10
    OnTimer = TimerTimer
    Left = 40
    Top = 48
  end
  object PopupMenu: TPopupMenu
    Left = 8
    Top = 8
    object SetupItem: TMenuItem
      Caption = '&Setup'
      OnClick = SetupItemClick
    end
    object SaveItem: TMenuItem
      Caption = 'Save'
      OnClick = SaveItemClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ExitItem: TMenuItem
      Caption = 'E&xit'
      OnClick = ExitItemClick
    end
  end
  object DelayTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = DelayTimerTimer
    Left = 40
    Top = 96
  end
  object CameraTimer: TTimer
    Enabled = False
    Interval = 30
    OnTimer = CameraTimerTimer
    Left = 80
    Top = 56
  end
end
