unit Global;

interface

uses
  Windows, Graphics;

const
  CountDownPeriod = 10000;
  EditTimeOut     = 10000;
    
type
  TFontRecord = record
    Name  : String[20];
    Size  : Integer;
    Color : TColor;
    Style : Set of TFontStyle;
  end;

  TLogFolder = String[255];

  THorizontalAlignment = (haLeft,haMiddle,haRight);

  TVerticalAlignment = (vaTop,vaMiddle,vaBottom);

var
  LogFolder    : TLogFolder;
  QuestionFont : TFontRecord;
  InputFont    : TFontRecord;
  BackGndColor : TColor;
  HAlignment   : THorizontalAlignment;
  VAlignment   : TVerticalAlignment;
  LineSpacing  : Integer;
  XBorder      : Integer;
  YBorder      : Integer; 

implementation


end.
