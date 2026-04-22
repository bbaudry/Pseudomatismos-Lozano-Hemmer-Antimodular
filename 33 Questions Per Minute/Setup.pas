unit Setup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, TriSplit, StdCtrls, AprSpin, ExtCtrls, Buttons, ColorBtn, QMakerU,
  Global, FileCtrl;

type
  TSetupFrm = class(TForm)
    QuestionFontBtn: TBitBtn;
    InputFontBtn: TBitBtn;
    FontsLbl: TLabel;
    AlignmentLbl: TLabel;
    HAlignmentRG: TRadioGroup;
    VAlignmentRG: TRadioGroup;
    LineSpacingLbl: TLabel;
    LineSpacingEdit: TAprSpinEdit;
    BackGndColorLbl: TLabel;
    BackGndColorBtn: TColorBtn;
    FontDialog: TFontDialog;
    ColorDialog: TColorDialog;
    QuestionsPerMinuteLbl: TLabel;
    QuestionsPerMinuteEdit: TAprSpinEdit;
    LanguageLbl: TLabel;
    EnglishRB: TRadioButton;
    SpanishRB: TRadioButton;
    BothRandomRB: TRadioButton;
    BothSequenceRB: TRadioButton;
    QuestionsLbl: TLabel;
    QuestionsPerLanguageEdit: TAprSpinEdit;
    AskLbl: TLabel;
    BeforeSwitchingLbl: TLabel;
    LogFolderLbl: TLabel;
    MiscLbl: TLabel;
    SaveBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Label1: TLabel;
    XBorderLbl: TLabel;
    XBorderEdit: TAprSpinEdit;
    YBorderLbl: TLabel;
    YBorderEdit: TAprSpinEdit;
    LogFolderEdit: TEdit;
    BrowseBtn: TButton;
    LogFolderDlg: TOpenDialog;
    Memo1: TMemo;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure SaveBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure QuestionFontBtnClick(Sender: TObject);
    procedure InputFontBtnClick(Sender: TObject);
    procedure HAlignmentRGClick(Sender: TObject);
    procedure VAlignmentRGClick(Sender: TObject);
    procedure XBorderEditChange(Sender: TObject);
    procedure YBorderEditChange(Sender: TObject);
    procedure BackGndColorBtnClick(Sender: TObject);
    procedure LineSpacingEditChange(Sender: TObject);
    procedure BrowseBtnClick(Sender: TObject);

  private
    Save            : Boolean;
    OldQMakerInfo   : TQuestionMakerInfo;
    OldLogFolder    : TLogFolder;
    OldBackColor    : TColor;
    OldLineSpacing  : Integer;
    OldQuestionFont : TFontRecord;
    OldInputFont    : TFontRecord;
    OldHAlignment   : THorizontalAlignment;
    OldVAlignment   : TVerticalAlignment;
    OldXBorder      : Integer;
    OldYBorder      : Integer;

  public
    procedure Initialize;
  end;

var
  SetupFrm: TSetupFrm;

implementation

{$R *.dfm}

uses
  CfgFile, Main, Routines, LogFile;

procedure TSetupFrm.Initialize;
begin
  Save:=False;
  OldLogFolder:=LogFolder;
  OldBackColor:=BackGndColor;
  OldLineSpacing:=LineSpacing; 
  OldQuestionFont:=QuestionFont;
  OldInputFont:=InputFont; 
  OldHAlignment:=HAlignment;
  OldVAlignment:=VAlignment;
  OldXBorder:=XBorder;
  OldYBorder:=YBorder;

  with QuestionMaker do begin
    OldQMakerInfo:=Info;

// language
    Case QuestionMaker.Language of
      qlEnglish      : EnglishRB.Checked:=True;
      qlSpanish      : SpanishRB.Checked:=True;
      qlBothRandom   : BothRandomRB.Checked:=True;
      qlBothSequence : BothSequenceRB.Checked:=True;
    end;
    QuestionsPerLanguageEdit.Value:=QPerLanguage;

// borders
    XBorderEdit.Value:=XBorder;
    YBorderEdit.Value:=YBorder;

// alignment
    HAlignmentRG.ItemIndex:=Ord(HAlignment);
    VAlignmentRG.ItemIndex:=Ord(VAlignment);

// miscellaneous
    LogFolderEdit.Text:=LogFolder;
    BackGndColorBtn.Color:=BackGndColor;
    QuestionsPerMinuteEdit.Value:=QPerMinute;
    LineSpacingEdit.Value:=LineSpacing;
  end;
end;

procedure TSetupFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#13 then Perform(WM_NEXTDLGCTL,0,0)
  else if Key=#27 then Close;
end;

procedure TSetupFrm.SaveBtnClick(Sender: TObject);
begin
  Save:=True;
  Close;
end;

procedure TSetupFrm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TSetupFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Save then with QuestionMaker do begin

// language
    if EnglishRB.Checked then Language:=qlEnglish
    else if SpanishRB.Checked then Language:=qlSpanish
    else if BothRandomRB.Checked then Language:=qlBothRandom
    else if BothSequenceRB.Checked then Language:=qlBothSequence;
    QPerLanguage:=Round(QuestionsPerLanguageEdit.Value);

// miscellaneous
    LogFolder:=LogFolderEdit.Text;
    if LogFolder[Length(LogFolder)]<>'\' then LogFolder:=LogFolder+'\';
    QPerMinute:=Round(QuestionsPerMinuteEdit.Value);
    SaveCfgFile;
  end
  else begin
    QuestionMaker.Info:=OldQMakerInfo;
    LogFolder:=OldLogFolder;
    BackGndColor:=OldBackColor;
    LineSpacing:=OldLineSpacing;
    QuestionFont:=OldQuestionFont;
    InputFont:=OldInputFont;
    HAlignment:=OldHAlignment;
    VAlignment:=OldVAlignment;
    XBorder:=OldXBorder;
    YBorder:=OldYBorder;
    MainFrm.SetBackGndColor;
    MainFrm.InitQLabelFonts;
    MainFrm.ShowQuestion;
  end;
end;

procedure TSetupFrm.QuestionFontBtnClick(Sender: TObject);
begin
  FontDialog.Font.Name:=QuestionFont.Name;
  FontDialog.Font.Size:=QuestionFont.Size;
  FontDialog.Font.Color:=QuestionFont.Color;
  FontDialog.Font.Style:=QuestionFont.Style;
  if FontDialog.Execute then begin
    QuestionFont.Name:=FontDialog.Font.Name;
    QuestionFont.Size:=FontDialog.Font.Size;
    QuestionFont.Color:=FontDialog.Font.Color;
    QuestionFont.Style:=FontDialog.Font.Style;
    MainFrm.InitQLabelFonts;
    MainFrm.ShowQuestion;
  end;
end;

procedure TSetupFrm.InputFontBtnClick(Sender: TObject);
begin
  FontDialog.Font.Name:=InputFont.Name;
  FontDialog.Font.Size:=InputFont.Size;
  FontDialog.Font.Color:=InputFont.Color;
  FontDialog.Font.Style:=InputFont.Style;
  if FontDialog.Execute then begin
    InputFont.Name:=FontDialog.Font.Name;
    InputFont.Size:=FontDialog.Font.Size;
    InputFont.Color:=FontDialog.Font.Color;
    InputFont.Style:=FontDialog.Font.Style;
    MainFrm.InitEditAndLcd;
  end;
end;

procedure TSetupFrm.HAlignmentRGClick(Sender: TObject);
begin
  Case HAlignmentRG.ItemIndex of
    0 : HAlignment:=haLeft;
    1 : HAlignment:=haMiddle;
    2 : HAlignment:=haRight;
  end;
  MainFrm.ShowQuestion;
end;

procedure TSetupFrm.VAlignmentRGClick(Sender: TObject);
begin
  Case VAlignmentRG.ItemIndex of
    0 : VAlignment:=vaTop;
    1 : VAlignment:=vaMiddle;
    2 : VAlignment:=vaBottom;
  end;
  MainFrm.ShowQuestion;
end;

procedure TSetupFrm.XBorderEditChange(Sender: TObject);
begin
  XBorder:=Round(XBorderEdit.Value);
  MainFrm.ShowQuestion;
end;

procedure TSetupFrm.YBorderEditChange(Sender: TObject);
begin
  YBorder:=Round(YBorderEdit.Value);
  MainFrm.ShowQuestion; 
end;

procedure TSetupFrm.BackGndColorBtnClick(Sender: TObject);
begin
  ColorDialog.Color:=BackGndColor;
  if ColorDialog.Execute then begin
    BackGndColor:=ColorDialog.Color;
    MainFrm.Color:=BackGndColor;
    BackGndColorBtn.Color:=BackGndColor;
  end;
end;

procedure TSetupFrm.LineSpacingEditChange(Sender: TObject);
begin
  LineSpacing:=Round(LineSpacingEdit.Value);
  MainFrm.ShowQuestion;
end;

procedure TSetupFrm.BrowseBtnClick(Sender: TObject);
begin
  LogFolderDlg.InitialDir:=LogFolderEdit.Text;
  LogFolderDlg.FileName:=LogFileName;
  if LogFolderDlg.Execute then begin
    LogFolderEdit.Text:=ExtractFilePath(LogFolderDlg.FileName);
  end;
end;

end.


