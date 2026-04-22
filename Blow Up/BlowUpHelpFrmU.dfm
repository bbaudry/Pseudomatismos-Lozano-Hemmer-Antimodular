object BlowUpHelpFrm: TBlowUpHelpFrm
  Left = 774
  Top = 88
  BorderStyle = bsDialog
  Caption = 'Help for BlowUp parameters'
  ClientHeight = 259
  ClientWidth = 430
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 430
    Height = 259
    Align = alClient
    Color = clInfoBk
    Lines.Strings = (
      
        'The blowup effect triggers when the coverage level - which is th' +
        'e percentage of pixels in '
      
        'the camera image that aren'#39't considered background pixels - reac' +
        'hes the trigger level.'
      
        'It zooms back out when the coverage level falls below the untrig' +
        'ger level.'
      ''
      
        'The min size parameter is the smallest width of the camera view ' +
        'that will be zoomed into.'
      
        'The max size parameter is the largest width of the camera view t' +
        'hat will be zoomed into.'
      ''
      
        'The min level specifies what the coverage in the camera view nee' +
        'ds to be before its '
      'considered interesting enough to zoom into.'
      ''
      
        'The zoomed in cells will track if the follow check box is checke' +
        'd.'
      'You can specify the averaging for this in the averages edit.'
      ''
      
        'If you want the cells to maintain the camera'#39's aspect ratio, che' +
        'ck off the aspect ratio '
      'check box.'
      ''
      
        'Tenacity refers to how hard the system tries to find the best ta' +
        'rget area to zoom to. More '
      
        'tenacity means better windows (in terms of adhering to the min o' +
        'r max level) but the '
      'trade off is more windows will be overlapped and clustered.')
    TabOrder = 0
  end
end
