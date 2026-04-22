unit QMakerU;

interface

uses
  Classes, Windows, SysUtils, Global;

const
  MaxQHistory      = 100;
  MaxPhraseHistory = 10;
  MaxPhrases       = 10000;
  MaxGroups        = 3;
  MaxLists         = 8;
  EnglishLists     = 8;
  SpanishLists     = 7;

type
  TGroupFrequencyArray = array[1..MaxGroups] of Single;

  TQuestionLanguage = (qlEnglish,qlSpanish,qlBothRandom,qlBothSequence);

  TCharArray = array[1..999999] of Char;
  PCharArray = ^TCharArray;

  TIndexChoice = record
    Index1,Index2,Index3 : Integer;
  end;

  TQuestionHistory = record
    Index : Integer;
    Entry : array[1..MaxQHistory] of TIndexChoice;
  end;
  TQuestionHistoryArray = array[1..MaxGroups] of TQuestionHistory;

  TPhrase = String[100];
  TPhraseArray = array[1..MaxPhrases] of TPhrase;
  PPhraseArray = ^TPhraseArray;

  TPhraseHistory = record
    Index : Integer;
    Entry : array[1..MaxPhraseHistory] of Integer;
  end;

  TPhraseList = record
    Count    : Integer;
    Phrase   : PPhraseArray;
    History  : TPhraseHistory;
  end;
  TPhraseListArray = array[1..MaxLists] of TPhraseList;

  TQuestionMakerInfo = record
    EnglishGroupFreq : TGroupFrequencyArray;
    SpanishGroupFreq : TGroupFrequencyArray;
    Language         : TQuestionLanguage;
    QPerLanguage     : Integer;
    QPerMinute       : Integer;
    Reserved         : array[1..256] of Byte;
  end;

  TCurrentLanguage = (clEnglish,clSpanish);

  TQuestionMaker = class(TObject)
  private
    EnglishList : array[1..EnglishLists] of TPhraseList;
    SpanishList : array[1..SpanishLists] of TPhraseList;

// question history
    EnglishQHistory : TQuestionHistoryArray;
    SpanishQHistory : TQuestionHistoryArray;

    QCount           : Integer;
    CurrentLanguage  : TCurrentLanguage;

    procedure LoadPhraseLists;
    procedure LoadPhraseListFromResource(Name:String;var PhraseList:TPhraseList);
    procedure FreePhraseLists;

    function  GetInfo:TQuestionMakerInfo;
    procedure SetInfo(NewInfo:TQuestionMakerInfo);

    function RandomPhraseIndex(var PhraseList:TPhraseList):Integer;
    function RandomEnglishPhraseIndex(ListIndex:Integer):Integer;
    function RandomSpanishPhraseIndex(ListIndex:Integer):Integer;

    function QuestionAsked(var QHistory:TQuestionHistory;I1,I2,I3:Integer):Boolean;

  public
    EnglishGroupFreq : TGroupFrequencyArray;
    SpanishGroupFreq : TGroupFrequencyArray;
    Language         : TQuestionLanguage;
    QPerLanguage     : Integer;
    QPerMinute       : Integer;
    Question         : String;
    LastQuestionTime : DWord;

    property Info:TQuestionMakerInfo read GetInfo write SetInfo;

    constructor Create;
    destructor  Destroy; override;

    procedure ShowEnglishListInLines(I:Integer;Lines:TStrings);

    function  EnglishQuestion:String;
    function  SpanishQuestion:String;
    procedure MakeNextQuestion;
    procedure Initialize;
    function  TimeForANewQuestion:Boolean;
  end;

var
  QuestionMaker : TQuestionMaker;

function DefaultQuestionMakerInfo:TQuestionMakerInfo;

implementation

function DefaultQuestionMakerInfo:TQuestionMakerInfo;
begin
  with Result do begin
    EnglishGroupFreq[1]:=34;
    EnglishGroupFreq[2]:=33;
    EnglishGroupFreq[3]:=33;
    SpanishGroupFreq[1]:=34;
    SpanishGroupFreq[2]:=33;
    SpanishGroupFreq[3]:=33;
    Language:=qlBothSequence;
    QPerLanguage:=3;
    QPerMinute:=33;
    FillChar(Reserved,SizeOf(Reserved),0);
  end;
end;

constructor TQuestionMaker.Create;
begin
  inherited;
  LoadPhraseLists;
  Initialize;
end;

destructor TQuestionMaker.Destroy;
begin
  FreePhraseLists;
  inherited;
end;

procedure TQuestionMaker.Initialize;
var
  I : Integer;
begin
  QCount:=0;
  CurrentLanguage:=clEnglish;
  Question:='';

// English history
  for I:=1 to EnglishLists do with EnglishList[I].History do begin
    Index:=1;
    FillChar(Entry,SizeOf(Entry),0);
  end;
  for I:=1 to 3 do with EnglishQHistory[I] do begin
    Index:=1;
    FillChar(Entry,SizeOf(Entry),0);
  end;

// Spanish history
  for I:=1 to SpanishLists do with SpanishList[I].History do begin
    Index:=1;
    FillChar(Entry,SizeOf(Entry),0);
  end;
  for I:=1 to 3 do with SpanishQHistory[I] do begin
    Index:=1;
    FillChar(Entry,SizeOf(Entry),0);
  end;
  LastQuestionTime:=0;
end;

function TQuestionMaker.GetInfo:TQuestionMakerInfo;
begin
  Result.EnglishGroupFreq:=EnglishGroupFreq;
  Result.SpanishGroupFreq:=SpanishGroupFreq;
  Result.Language:=Language;
  Result.QPerLanguage:=QPerLanguage;
  Result.QPerMinute:=QPerMinute;
  FillChar(Result.Reserved,SizeOf(Result.Reserved),0);
end;

procedure TQuestionMaker.SetInfo(NewInfo:TQuestionMakerInfo);
begin
//  EnglishGroupFreq:=NewInfo.EnglishGroupFreq;
//  SpanishGroupFreq:=NewInfo.SpanishGroupFreq;

  EnglishGroupFreq[1]:=20;
  EnglishGroupFreq[2]:=60;
  EnglishGroupFreq[3]:=20;

  SpanishGroupFreq[1]:=60;
  SpanishGroupFreq[2]:=20;
  SpanishGroupFreq[3]:=20;

  Language:=NewInfo.Language;
  QPerLanguage:=NewInfo.QPerLanguage;
  QPerMinute:=NewInfo.QPerMinute;
end;

procedure TQuestionMaker.LoadPhraseListFromResource(Name:String;var PhraseList:TPhraseList);
var
  Stream  : TResourceStream;
  Data    : PCharArray;
  I,I1,I2 : Integer;
  PhraseI   : Integer;
begin
  Stream:=TResourceStream.Create(HInstance,Name,RT_RCDATA);
  try
    Stream.Position:=0;
    GetMem(Data,Stream.Size);
    try
      Stream.Read(Data^,Stream.Size);

// count the Phrases - the end of the file has no #13
      PhraseList.Count:=0;
      for I:=1 to Stream.Size do if Data^[I]=#13 then Inc(PhraseList.Count);
      if Data^[Stream.Size]<>#13 then Inc(PhraseList.Count);

// get some memory
      GetMem(PhraseList.Phrase,PhraseList.Count*SizeOf(TPhrase));

// store the Phrases
      I1:=1;
      I2:=0;
      PhraseI:=0;
      repeat
        Inc(I2);
        if Data^[I2]=#13 then begin
          Inc(PhraseI);
          PhraseList.Phrase^[PhraseI]:='';
          for I:=I1 to I2-1 do PhraseList.Phrase^[PhraseI]:=PhraseList.Phrase^[PhraseI]+Data^[I];
          I1:=I2+2;
        end;
      until (I2=Stream.Size);

// grab the last one too
      if Data^[I2]<>#13 then begin
        Inc(PhraseI);
        PhraseList.Phrase^[PhraseI]:='';
        for I:=I1 to I2 do PhraseList.Phrase^[PhraseI]:=PhraseList.Phrase^[PhraseI]+Data^[I];
      end;
    finally
      FreeMem(Data);
    end;
  finally
    Stream.Free;
  end;
end;

procedure TQuestionMaker.LoadPhraseLists;
var
  I : Integer;
begin
  for I:=1 to EnglishLists do begin
    LoadPhraseListFromResource('English'+IntToStr(I),EnglishList[I]);
  end;
  for I:=1 to SpanishLists do begin
    LoadPhraseListFromResource('Spanish'+IntToStr(I),SpanishList[I]);
  end;
end;

procedure TQuestionMaker.FreePhraseLists;
var
  I : Integer;
begin
  for I:=1 to EnglishLists do FreeMem(EnglishList[I].Phrase);
  for I:=1 to SpanishLists do FreeMem(SpanishList[I].Phrase);
end;

procedure TQuestionMaker.ShowEnglishListInLines(I:Integer;Lines:TStrings);
var
  W : Integer;
begin
  with EnglishList[I] do for W:=1 to Count do begin
    Lines.Add(EnglishList[I].Phrase^[W]);
  end;
end;

function TQuestionMaker.QuestionAsked(var QHistory:TQuestionHistory;I1,I2,I3:Integer):Boolean;
var
  Count,I : Integer;
begin
  with QHistory do begin
    I:=Index;
    Count:=0;
    repeat
      Inc(Count);
      if I>1 then Dec(I)
      else I:=MaxQHistory;
      Result:=(Entry[I].Index1=I1) and (Entry[I].Index2=I2) and
              (Entry[I].Index3=I3);
    until (Count=MaxQHistory) or Result;
  end;
end;

function TQuestionMaker.RandomPhraseIndex(var PhraseList:TPhraseList):Integer;
const
  TimeOut = 100;
var
  I,Count   : Integer;
  StartTime : DWord;
begin
  StartTime:=GetTickCount;
  repeat

// pick a phrase in the range
    Result:=Random(PhraseList.Count+1);

// look for a repeat in the last PhraseHistory choices from this list
    with PhraseList.History do begin
      I:=Index;
      Count:=0;
      repeat
        Inc(Count);
        if I>1 then Dec(I)
        else I:=MaxPhraseHistory;
        if Entry[I]=Result then Result:=0;
      until (Count=MaxPhraseHistory) or (Result=0);
    end;
  until (Result>0) or ((GetTickCount-StartTime)>TimeOut);

// make sure one is chosen even if we must repeat
  if Result=0 then Result:=Random(PhraseList.Count)+1;

// record it in the history
  with PhraseList.History do begin
    Entry[Index]:=Result;
    if Index<MaxPhraseHistory then Inc(Index)
    else Index:=1;
  end;
end;

function TQuestionMaker.RandomEnglishPhraseIndex(ListIndex:Integer):Integer;
var
  StartTime,I : Integer;
begin
// there's no history for these phrase lists
  if (MaxPhraseHistory=0) or (ListIndex in [1,4,7]) then begin
    Result:=Random(EnglishList[ListIndex].Count)+1;
    Exit;
  end
  else Result:=RandomPhraseIndex(EnglishList[ListIndex]);
end;

function TQuestionMaker.EnglishQuestion:String;
var
  StartTime                 : DWord;
  T1,T2,I1,I2,I3,Dice,Group : Integer;
  Done,TimedOut             : Boolean;
  Phrase1,Phrase2,Phrase3   : String;
begin
// pick the question group
  T1:=Round(EnglishGroupFreq[1]);
  T2:=Round(EnglishGroupFreq[2]);

// roll the virtual dice
  Dice:=Random(100);
  if Dice<T1 then Group:=1
  else if Dice<T2 then Group:=2
  else Group:=3;

// pick 3 indexes from the Phrase lists
  Done:=False;
  StartTime:=GetTickCount;
  repeat
    Case Group of
      1:begin
          I1:=RandomEnglishPhraseIndex(1); // A
          I2:=RandomEnglishPhraseIndex(2); // B
          I3:=RandomEnglishPhraseIndex(3); // C
        end;
      2:begin
          I1:=RandomEnglishPhraseIndex(4); // D
          I2:=RandomEnglishPhraseIndex(5); // E
          I3:=RandomEnglishPhraseIndex(6); // F
        end;
      3:begin
          I1:=RandomEnglishPhraseIndex(7); // G
          I2:=RandomEnglishPhraseIndex(8); // H
          I3:=RandomEnglishPhraseIndex(3); // C
        end;
    end;

// put a limit on how long this can take
    TimedOut:=(GetTickCount-StartTime)>1000;

// if this choice hasn't been taken, generate the text
// allow a duplicate choice if too much time has passed - probably will never
// happen with phrase lists of reasonable size
    if TimedOut or not QuestionAsked(EnglishQHistory[Group],I1,I2,I3) then begin
      Case Group of
        1:begin
            Phrase1:=EnglishList[1].Phrase^[I1];
            Phrase2:=EnglishList[2].Phrase^[I2];
            Phrase3:=EnglishList[3].Phrase^[I3];
          end;
        2:begin
            Phrase1:=EnglishList[4].Phrase^[I1];
            Phrase2:=EnglishList[5].Phrase^[I2];
            Phrase3:=EnglishList[6].Phrase^[I3];
          end;
        3:begin
            Phrase1:=EnglishList[7].Phrase^[I1];
            Phrase2:=EnglishList[8].Phrase^[I2];
            Phrase3:=EnglishList[3].Phrase^[I3];
          end;
      end;

// form the text
      Result:=Phrase1;
      if Result='' then Result:=Phrase2
      else Result:=Result+' '+Phrase2;
      if Result='' then Result:=Phrase3
      else Result:=Result+' '+Phrase3;

// the 1st letter should be uppercase and the question should end in a "?"
      if Result<>'' then Result[1]:=UpCase(Result[1]);
      Result:=Result+'?';
      Done:=True;
    end;
  until Done or TimedOut;

// record this choice as taken
  with EnglishQHistory[Group] do begin
    Entry[Index].Index1:=I1;
    Entry[Index].Index2:=I2;
    Entry[Index].Index3:=I3;
    if Index<MaxQHistory then Inc(Index)
    else Index:=1;
  end;
end;

function TQuestionMaker.RandomSpanishPhraseIndex(ListIndex:Integer):Integer;
begin
// there's no history for these Phrase lists
  if (MaxPhraseHistory=0) or (ListIndex in [1,4,7]) then begin
    Result:=Random(SpanishList[ListIndex].Count)+1;
    Exit;
  end

// for the rest, we need to check the history
  else Result:=RandomPhraseIndex(SpanishList[ListIndex]);
end;

function TQuestionMaker.SpanishQuestion:String;
var
  Group,StartTime   : Integer;
  T1,T2,I1,I2,I3    : Integer;
  Dice              : Integer;
  TimedOut,Done     : Boolean;
  Phrase1,Phrase2,Phrase3 : String;
begin
// pick the question group
  T1:=Round(SpanishGroupFreq[1]);
  T2:=Round(SpanishGroupFreq[2]);

// roll the virtual dice
  Dice:=Random(100);
  if Dice<T1 then Group:=1
  else if Dice<T2 then Group:=2
  else Group:=3;

// pick 3 indexes from the Phrase lists
  Done:=False;
  StartTime:=GetTickCount;
  repeat
    Case Group of
      1:begin
          I1:=RandomSpanishPhraseIndex(1); // A
          I2:=RandomSpanishPhraseIndex(2); // B
          I3:=RandomSpanishPhraseIndex(3); // C
        end;
      2:begin
          I1:=RandomSpanishPhraseIndex(4); // D
          I2:=RandomSpanishPhraseIndex(5); // E
          I3:=RandomSpanishPhraseIndex(6); // F
        end;
      3:begin
          I1:=RandomSpanishPhraseIndex(7); // G
          I2:=RandomSpanishPhraseIndex(2); // B
          I3:=RandomSpanishPhraseIndex(6); // F
        end;
    end;

// put a limit on how long this can take
    TimedOut:=(GetTickCount-StartTime)>1000;

// if this choice hasn't been taken, generate the text
// allow a duplicate choice if too much time has passed - probably will never
// happen with Phrase lists of reasonable size
    if TimedOut or not QuestionAsked(SpanishQHistory[Group],I1,I2,I3) then begin
      Case Group of
        1:begin
            Phrase1:=SpanishList[1].Phrase^[I1];
            Phrase2:=SpanishList[2].Phrase^[I2];
            Phrase3:=SpanishList[3].Phrase^[I3];
          end;
        2:begin
            Phrase1:=SpanishList[4].Phrase^[I1];
            Phrase2:=SpanishList[5].Phrase^[I2];
            Phrase3:=SpanishList[6].Phrase^[I3];
          end;
        3:begin
            Phrase1:=SpanishList[7].Phrase^[I1];
            Phrase2:=SpanishList[2].Phrase^[I2];
            Phrase3:=SpanishList[6].Phrase^[I3];
          end;
      end;

// form the text
      Result:=#191+Phrase1;
      if Phrase2<>'' then begin
        if Result=#191 then Result:=Result+Phrase2
        else Result:=Result+' '+Phrase2;
      end;
      if Phrase3<>'' then begin
        if Result=#191 then Result:=Result+Phrase3
        else Result:=Result+' '+Phrase3;
      end;

// the 1st letter should be uppercase and the question should end in a "?"
      if Length(Result)>1 then Result[2]:=UpCase(Result[2]);
      Result:=Result+'?';
      Done:=True;
    end;
  until Done or TimedOut;

// record this choice as taken
  with SpanishQHistory[Group] do begin
    Entry[Index].Index1:=I1;
    Entry[Index].Index2:=I2;
    Entry[Index].Index3:=I3;
    if Index<MaxQHistory then Inc(Index)
    else Index:=1;
  end;
end;

procedure TQuestionMaker.MakeNextQuestion;
begin
  Case Language of
    qlEnglish : CurrentLanguage:=clEnglish;
    qlSpanish : CurrentLanguage:=clSpanish;
    qlBothRandom :
      if Random(100)>50 then CurrentLanguage:=clEnglish
      else CurrentLanguage:=clSpanish;
    qlBothSequence :
      begin
        if QCount<QPerLanguage then Inc(QCount)
        else begin
          QCount:=1;
          Case CurrentLanguage of
            clEnglish : CurrentLanguage:=clSpanish;
            clSpanish : CurrentLanguage:=clEnglish;
          end;
        end;
      end;
  end;
  Case CurrentLanguage of
    clEnglish : Question:=EnglishQuestion;
    clSpanish : Question:=SpanishQuestion;
  end;
end;

function TQuestionMaker.TimeForANewQuestion:Boolean;
var
  NextQuestionTime : DWord;
begin
  NextQuestionTime:=LastQuestionTime+Round(60000/QPerMinute);
  if GetTickCount>=NextQuestionTime then begin
    Result:=True;
    LastQuestionTime:=GetTickCount;
  end
  else Result:=False;
end;

end.



