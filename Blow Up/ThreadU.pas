unit ThreadU;

interface

uses
  Windows, Messages, Controls;

// routine thread starts at
function  ThreadEntryRoutine(Info:Pointer):integer; stdcall;

var
  X1,X2 : integer;

const
  CallBackMsg     = WM_USER+1;
  DoneCallBackMsg = WM_User+1;

type
  TCallBackThread = class(TObject)
  private
    CallerHandle : THandle;
    Period       : Integer; // ms

// priority property routines
    procedure SetPriority(NewPriority : integer);
    function  GetPriority : integer;
    procedure WMDoneCallBack(var Msg:TMessage); message DoneCallBackMsg;

  public
    ThreadID : DWord;
    Handle   : THandle;
    Stopped  : Boolean;

    constructor Create(iHandle:THandle);
    destructor  Destroy; override;

    property Priority : integer read GetPriority write SetPriority;

// public routines
    procedure Start(iPeriod:Integer);
    procedure Stop;
    procedure RunLoop;
  end;

var
  Thread : TCallBackThread;

implementation

uses
  MMSystem, Dialogs, Forms, Math, SysUtils;

function ThreadEntryRoutine(Info:Pointer):integer; stdcall;
begin
// enter our tracking loop
  Thread.RunLoop;
end;

constructor TCallBackThread.Create(iHandle:THandle);
begin
  inherited Create;
  CallerHandle:=iHandle;
  Stopped:=True;
end;

destructor TCallBackThread.Destroy;
var
  Msg : TMsg;
begin
  if not Stopped then Stop;

// clear any pending messages
  PeekMessage(Msg,CallerHandle,CallBackMsg,CallBackMsg,PM_REMOVE);
end;

procedure TCallBackThread.SetPriority(NewPriority:integer);
begin
// THREAD_PRIORITY_TIMECRITICAL   - causes other threads to starve
// THREAD_PRIORITY_HIGHEST        - +2     4.2-4.3
// THREAD_PRIORITY_ABOVE_NORMAL   - +1     4.2-4.3
// THREAD_PRIORITY_NORMAL         -  0     4.2-4.6
// THREAD_PRIORITY_BELOW_NORMAL   - -1
// THREAD_PRIORITY_LOWEST         - -2
  SetThreadPriority(Handle,NewPriority);
end;

function TCallBackThread.GetPriority : integer;
begin
  Result:=GetThreadPriority(Handle);
end;

procedure TCallBackThread.Start(iPeriod:Integer);
begin
  Period:=iPeriod;
  
// create the thread
  Handle:=CreateThread(nil,0,@ThreadEntryRoutine,nil,0,ThreadID);
  if Handle=0 then ShowMessage('Unable to create thread!')
  else begin
    Stopped:=False;

// normal priority is ok
    Priority:=THREAD_PRIORITY_NORMAL;
  end;

// force feed it messages until we succeed - see Win32.Hlp
  repeat
    Application.ProcessMessages;
  until PostThreadMessage(ThreadID,DoneCallBackMsg,0,0);
end;

procedure TCallBackThread.Stop;
begin
  PostThreadMessage(ThreadID,DoneCallBackMsg,1,0);

// wait for it to die
  WaitForSingleObject(Handle,3000);

// free the handle
  CloseHandle(Handle);
end;

procedure TCallBackThread.RunLoop;
var
  Msg : TMsg;
begin
// create the message queue
  GetMessage(Msg,0,0,0);

// we'll sit in this loop until the thread is terminated
  repeat

// wait until the caller isn't busy
    while PeekMessage(Msg,CallerHandle,0,0,PM_NOREMOVE) do;

// tell the main thread it's time to update again
    PostMessage(CallerHandle,CallBackMsg,0,0);
    if Period>1 then Sleep(Period-1);

// wait until the main thread signals to us that it's ready
    while not PeekMessage(Msg,0,DoneCallBackMsg,DoneCallBackMsg,PM_REMOVE) do begin
      Sleep(1);
    end;
  until (Msg.wParam>0);
end;

procedure TCallBackThread.WMDoneCallBack(var Msg:TMessage);
begin
end;

end.





