object SetupFrm: TSetupFrm
  Left = 409
  Top = 118
  BorderStyle = bsDialog
  Caption = '"33 Questions per Minute" by Rafael Lozano-Hemmer'
  ClientHeight = 386
  ClientWidth = 431
  Color = 14012360
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object FontsLbl: TLabel
    Left = 8
    Top = 143
    Width = 196
    Height = 16
    AutoSize = False
    Caption = ' Fonts'
    Color = 9868950
    ParentColor = False
  end
  object AlignmentLbl: TLabel
    Left = 221
    Top = 7
    Width = 196
    Height = 16
    AutoSize = False
    Caption = ' Alignment'
    Color = 9868950
    ParentColor = False
  end
  object LineSpacingLbl: TLabel
    Left = 230
    Top = 227
    Width = 63
    Height = 13
    Caption = 'Line spacing:'
  end
  object BackGndColorLbl: TLabel
    Left = 230
    Top = 180
    Width = 87
    Height = 13
    Caption = 'Background color:'
  end
  object QuestionsPerMinuteLbl: TLabel
    Left = 230
    Top = 203
    Width = 102
    Height = 13
    Caption = 'Questions per minute:'
  end
  object LanguageLbl: TLabel
    Left = 8
    Top = 7
    Width = 207
    Height = 16
    AutoSize = False
    Caption = ' Language'
    Color = 9868950
    ParentColor = False
  end
  object QuestionsLbl: TLabel
    Left = 127
    Top = 103
    Width = 45
    Height = 13
    Caption = 'questions'
  end
  object AskLbl: TLabel
    Left = 43
    Top = 167
    Width = 18
    Height = 13
    Caption = 'Ask'
  end
  object BeforeSwitchingLbl: TLabel
    Left = 44
    Top = 121
    Width = 129
    Height = 13
    Caption = 'before switching languages'
  end
  object LogFolderLbl: TLabel
    Left = 222
    Top = 125
    Width = 113
    Height = 13
    Caption = 'User input log file folder:'
  end
  object MiscLbl: TLabel
    Left = 217
    Top = 107
    Width = 200
    Height = 16
    AutoSize = False
    Caption = ' Miscellaneous'
    Color = 9868950
    ParentColor = False
  end
  object Label1: TLabel
    Left = 9
    Top = 202
    Width = 195
    Height = 16
    AutoSize = False
    Caption = ' Borders'
    Color = 9868950
    ParentColor = False
  end
  object XBorderLbl: TLabel
    Left = 20
    Top = 229
    Width = 10
    Height = 13
    Caption = 'X:'
  end
  object YBorderLbl: TLabel
    Left = 100
    Top = 229
    Width = 10
    Height = 13
    Caption = 'Y:'
  end
  object QuestionFontBtn: TBitBtn
    Left = 15
    Top = 164
    Width = 75
    Height = 24
    Caption = 'Question'
    TabOrder = 9
    OnClick = QuestionFontBtnClick
  end
  object InputFontBtn: TBitBtn
    Left = 96
    Top = 164
    Width = 75
    Height = 24
    Caption = 'Input'
    TabOrder = 10
    OnClick = InputFontBtnClick
  end
  object HAlignmentRG: TRadioGroup
    Left = 234
    Top = 29
    Width = 81
    Height = 66
    Caption = 'Horizontal'
    Items.Strings = (
      'Left'
      'Middle'
      'Right')
    TabOrder = 11
    OnClick = HAlignmentRGClick
  end
  object VAlignmentRG: TRadioGroup
    Left = 327
    Top = 29
    Width = 81
    Height = 66
    Caption = 'Vertical'
    Items.Strings = (
      'Top'
      'Middle'
      'Bottom')
    TabOrder = 12
    OnClick = VAlignmentRGClick
  end
  object LineSpacingEdit: TAprSpinEdit
    Left = 312
    Top = 225
    Width = 39
    Height = 20
    Min = -255.000000000000000000
    Max = 255.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = LineSpacingEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 8
  end
  object BackGndColorBtn: TColorBtn
    Left = 342
    Top = 180
    Width = 18
    Height = 16
    OnClick = BackGndColorBtnClick
    TabOrder = 6
  end
  object QuestionsPerMinuteEdit: TAprSpinEdit
    Left = 360
    Top = 200
    Width = 49
    Height = 20
    Value = 1.000000000000000000
    Min = 1.000000000000000000
    Max = 9999.000000000000000000
    Alignment = taCenter
    Enabled = True
    Increment = 1.000000000000000000
    EditText = '1'
    TabOrder = 7
  end
  object EnglishRB: TRadioButton
    Left = 18
    Top = 28
    Width = 73
    Height = 16
    Caption = 'English'
    TabOrder = 1
  end
  object SpanishRB: TRadioButton
    Left = 18
    Top = 45
    Width = 73
    Height = 16
    Caption = 'Spanish'
    TabOrder = 2
  end
  object BothRandomRB: TRadioButton
    Left = 18
    Top = 65
    Width = 106
    Height = 13
    Caption = 'Both randomly'
    TabOrder = 3
  end
  object BothSequenceRB: TRadioButton
    Left = 18
    Top = 84
    Width = 132
    Height = 14
    Caption = 'Both in sequence'
    TabOrder = 4
  end
  object QuestionsPerLanguageEdit: TAprSpinEdit
    Left = 76
    Top = 101
    Width = 44
    Height = 20
    Value = 1.000000000000000000
    Min = 1.000000000000000000
    Max = 999.000000000000000000
    Alignment = taCenter
    Enabled = True
    Increment = 1.000000000000000000
    EditText = '1'
    TabOrder = 5
  end
  object SaveBtn: TBitBtn
    Left = 272
    Top = 350
    Width = 69
    Height = 26
    Caption = '&Save'
    TabOrder = 13
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
  object CancelBtn: TBitBtn
    Left = 352
    Top = 350
    Width = 75
    Height = 26
    Caption = '&Cancel'
    TabOrder = 0
    OnClick = CancelBtnClick
    Glyph.Data = {
      DE010000424DDE01000000000000760000002800000024000000120000000100
      0400000000006801000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      333333333333333333333333000033338833333333333333333F333333333333
      0000333911833333983333333388F333333F3333000033391118333911833333
      38F38F333F88F33300003339111183911118333338F338F3F8338F3300003333
      911118111118333338F3338F833338F3000033333911111111833333338F3338
      3333F8330000333333911111183333333338F333333F83330000333333311111
      8333333333338F3333383333000033333339111183333333333338F333833333
      00003333339111118333333333333833338F3333000033333911181118333333
      33338333338F333300003333911183911183333333383338F338F33300003333
      9118333911183333338F33838F338F33000033333913333391113333338FF833
      38F338F300003333333333333919333333388333338FFF830000333333333333
      3333333333333333333888330000333333333333333333333333333333333333
      0000}
    NumGlyphs = 2
    Style = bsNew
  end
  object XBorderEdit: TAprSpinEdit
    Left = 38
    Top = 226
    Width = 50
    Height = 20
    Max = 999.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = XBorderEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 14
  end
  object YBorderEdit: TAprSpinEdit
    Left = 118
    Top = 226
    Width = 50
    Height = 20
    Max = 999.000000000000000000
    Alignment = taCenter
    Enabled = True
    OnChange = YBorderEditChange
    Increment = 1.000000000000000000
    EditText = '0'
    TabOrder = 15
  end
  object LogFolderEdit: TEdit
    Left = 223
    Top = 142
    Width = 162
    Height = 21
    TabOrder = 16
  end
  object BrowseBtn: TButton
    Left = 385
    Top = 142
    Width = 21
    Height = 21
    Caption = '...'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 17
    OnClick = BrowseBtnClick
  end
  object Memo1: TMemo
    Left = 16
    Top = 256
    Width = 395
    Height = 86
    Color = clInfoBk
    Lines.Strings = (
      'Credits:'
      'Rafael Lozano-Hemmer - concept, direction.'
      'Conroy Badger - programming.'
      
        'Will Bauer, Ana Parga, Mar'#237'a Velarde Torres, Luis Jim'#233'nez-Carl'#233's' +
        ', Luis Parga, '
      
        'Gabriela Ravent'#243's and Rebecca MacSween - assistance, word entry ' +
        'and '
      'classification.')
    ReadOnly = True
    TabOrder = 18
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 160
    Top = 32
  end
  object ColorDialog: TColorDialog
    Left = 160
    Top = 64
  end
  object LogFolderDlg: TOpenDialog
    Left = 112
    Top = 48
  end
end
