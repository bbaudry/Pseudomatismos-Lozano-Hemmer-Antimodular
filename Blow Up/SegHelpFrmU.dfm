object SegmenterHelpFrm: TSegmenterHelpFrm
  Left = 680
  Top = 143
  BorderStyle = bsDialog
  Caption = 'Segmenter help'
  ClientHeight = 707
  ClientWidth = 548
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 545
    Height = 705
    Color = clInfoBk
    Lines.Strings = (
      
        'The segmenter determines which of the pixels in an image are for' +
        'eground and which are background. There are '
      'three parameters that control the segmenter.'
      ''
      '#1) Threshold:'
      '============'
      
        'This is the amount a pixel must differ from the background befor' +
        'e it'#39's considered part of the foreground.'
      ''
      '#3) Max FG time:'
      '=============='
      
        'Max foreground time is the maximum amount of time is seconds tha' +
        't a pixel can be part of the foreground. When a '
      
        'pixel has been part of the foreground for longer than this time,' +
        ' it goes into sampling more where the new average '
      
        'background value is sampled and calculated. A lower foreground t' +
        'ime means a faster reponse to changing lighting '
      
        'or room conditions, but setting the value too low can cause the ' +
        'system to set valid foreground pixels to the '
      
        'background (ie someone standing in front of the display for a lo' +
        'ng time), effectively erasing them from the tracking.'
      ''
      '#4) Drift threshold:'
      '==============='
      
        'Drift threshold allows the system to continuously sample the bac' +
        'kground and allow the system to update in '
      
        'response to small changes in the background, such as natural lig' +
        'hting changing in intensity gradually throughout '
      'the day.'
      ''
      
        'You can force all the pixels into sample mode by pressing the "F' +
        'orce all to background" button. This will cause the '
      
        'pixels to start sampling. When each of the pixels is stable for ' +
        'long enough, their averages will become the new '
      
        'average background reference. If you check off the delay 5s opti' +
        'on, the system will delay 5 seconds before '
      
        'putting the segmenter into sample mode, giving you time to move ' +
        'away from the camera so it can sample against a '
      'vacant background.'
      ''
      'There are several view options for the segmenter.'
      ''
      'Intensity : This shows the camera image as R+G+B '
      ''
      
        'Averaged : This show the average pixel values that the camera us' +
        'es as reference between background and '
      'foreground.'
      ''
      
        'Deviation : This shows how much each of the pixels varies from t' +
        'he average. The image is exaggerated - only '
      
        'pure white pixels are actually different enough to be considered' +
        ' part of the foreground.'
      ''
      
        'Thresholded : This shows the pixels that are different from the ' +
        'background by more than the threshold value.'
      ''
      
        'Sample counts : The brighter the pixel the more good samples the' +
        ' pixel has. Typically when a pixel is sampled it '
      
        'will go from black to bright red and then to black again, meanin' +
        'g it'#39's no longer sampling and is now considered part '
      'of the background.'
      ''
      
        'Ages : A brighter pixel means the pixel has been considered part' +
        ' of the foreground for longer. A pixel will go from '
      
        'black to bright red - and then black again when the system marks' +
        ' it for sampling to become part of the '
      'background.'
      ''
      
        'States : This simply show the states of the pixels. Black is bac' +
        'kground, blue is foreground, and red is sampling.')
    TabOrder = 0
  end
end
