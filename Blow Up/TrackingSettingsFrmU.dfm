object TrackingSettingsFrm: TTrackingSettingsFrm
  Left = 600
  Top = 749
  VertScrollBar.Visible = False
  BorderStyle = bsDialog
  Caption = 'Tracking Settings'
  ClientHeight = 511
  ClientWidth = 963
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object CamPB: TPaintBox
    Left = 2
    Top = 5
    Width = 640
    Height = 480
    OnPaint = CamPBPaint
  end
  object Label1: TLabel
    Left = 744
    Top = 312
    Width = 50
    Height = 13
    Caption = 'Threshold:'
  end
  object Memo: TMemo
    Left = 649
    Top = 23
    Width = 309
    Height = 231
    Color = clInfoBk
    Lines.Strings = (
      'Decrease the detection threshold if you want the tracking to be'
      'more sensitive and thus have more areas triggered.'
      ''
      
        'Before setting the trigger level first check the current level a' +
        'nd '
      'then set the trigger level to about half the current level.'
      ''
      'The trigger level determines how much area of the camera '
      'image a person needs to take up before a BlowUp is triggered.'
      ''
      'The red area on the camera image and the current level are '
      'directly related. Notice how the current level decreases'
      'to 0 when you step outside the camera image. Also, a smaller '
      'person or a person further away will not take up as'
      'much area and thus the current level will be lower.'
      ''
      
        'So it is important to find the right trigger level that suits th' +
        'e '
      'exhibition environment.'
      '')
    ReadOnly = True
    TabOrder = 0
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 492
    Width = 963
    Height = 19
    Panels = <
      item
        Text = 'Camera not found'
        Width = 240
      end
      item
        Text = '9999 verbs loaded'
        Width = 50
      end>
    SimplePanel = True
  end
  object ThresholdEdit: TAprSpinEdit
    Left = 797
    Top = 308
    Width = 48
    Height = 20
    Min = 1.000000000000000000
    Max = 999.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = ThresholdEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 1
  end
  object BlowUpTriggerPanel: TPanel
    Left = 703
    Top = 344
    Width = 186
    Height = 81
    TabOrder = 2
    object Label3: TLabel
      Left = 8
      Top = 6
      Width = 170
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'BlowUp trigger'
      Color = 12891050
      ParentColor = False
    end
    object Label15: TLabel
      Left = 21
      Top = 32
      Width = 61
      Height = 13
      Caption = 'Trigger level:'
    end
    object TriggerLevelEdit: TAprSpinEdit
      Left = 25
      Top = 48
      Width = 50
      Height = 20
      Max = 999.000000000000000000
      Alignment = taCenter
      Enabled = True
      OnChange = TriggerLevelEditChange
      Increment = 1.000000000000000000
      EditText = '0'
      TabOrder = 0
    end
    object Panel1: TPanel
      Left = 104
      Top = 28
      Width = 73
      Height = 45
      TabOrder = 1
      object Label18: TLabel
        Left = 6
        Top = 2
        Width = 62
        Height = 13
        Caption = 'Current level:'
      end
      object CurrentLevelLCD: TLCD
        Left = 17
        Top = 18
        Width = 38
        Height = 21
        OffColor = 45
        SegWidth = 7
        SegHeight = 6
        LineWidth = 1
        Gap = 1
        Digits = 3
        ShowLead0 = False
        Value = 255
        ShowSign = False
      end
    end
  end
end
