object ScrubTestFrm: TScrubTestFrm
  Left = 407
  Top = 419
  BorderStyle = bsSingle
  Caption = 'Scrub test'
  ClientHeight = 217
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object FramePB: TPaintBox
    Left = 10
    Top = 14
    Width = 469
    Height = 41
    OnPaint = FramePBPaint
  end
  object VelocityPB: TPaintBox
    Left = 11
    Top = 72
    Width = 348
    Height = 137
    OnPaint = VelocityPBPaint
  end
  object VideoPB: TPaintBox
    Left = 371
    Top = 129
    Width = 64
    Height = 80
  end
  object VideoLbl: TLabel
    Left = 376
    Top = 75
    Width = 30
    Height = 13
    Caption = 'Video:'
  end
  object VideoEdit: TAprSpinEdit
    Left = 412
    Top = 71
    Width = 48
    Height = 20
    Value = 1.000000000000000000
    Min = 1.000000000000000000
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = VideoEditChange
    Increment = 1.000000000000000000
    EditText = '1'
    TabOrder = 1
  end
  object TriggeredCB: TAprCheckBox
    Left = 374
    Top = 103
    Width = 73
    Height = 17
    Caption = 'Triggered'
    TabOrder = 0
    TabStop = True
    OnClick = TriggeredCBClick
  end
  object Timer: TTimer
    Enabled = False
    Interval = 20
    OnTimer = TimerTimer
    Left = 424
    Top = 8
  end
end
