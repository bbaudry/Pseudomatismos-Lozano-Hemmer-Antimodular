unit Ks;

interface

uses
  Windows;

type
   TKsIdentifier = record
     SetGuid : TGUID;
     Id      : DWord;
     Flags   : DWord;
     Alignment : Int64;
   end;

   TKsProperty = TKsIdentifier;
   PKsProperty = ^TKsProperty;

   TKsMethod = TKsIdentifier;
   PKsMethod = ^TKsMethod;

   TKsEvent = TKsIdentifier;
   PKsEvent = ^TKsEvent;

implementation

end.
