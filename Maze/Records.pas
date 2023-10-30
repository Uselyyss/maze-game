unit Records;

interface
uses System;

type TRecord = record
  Name:string;
  Score:integer;
end;

type TRecordArray = array[1..10] of TRecord;
var R:TRecordArray;

function AddRecord(Name:string; Score:integer):boolean;
function GetRecords:TRecordArray;

implementation

const RecordFileName = 'Score.dat';

procedure SaveRecords;
var F:TextFile;
    I:integer;
begin
     AssignFile(F,RecordFileName); Rewrite(F);
     for I:=1 to 10 do
     begin
       Writeln(F,R[I].Name);
       Writeln(F,R[I].Score);
     end;
     CloseFile(F);
end;


function AddRecord(Name:string; Score:integer):boolean;
var I:integer;
    T:TRecord;
begin
 Result := Score > R[10].Score;
 if not Result then exit; //Никакого места
 R[10].Score := Score;
 R[10].Name := Name;
 
 for I:=9 downto 1 do
   if R[i].Score < R[i+1].Score then 
    begin
      T:=R[i]; R[i]:=R[i+1]; R[i+1]:=T;       
    end
    else break;
 
 SaveRecords;
   
end;


function GetRecords:TRecordArray;
begin
  Result := R;
end;

procedure LoadRecords;
var F:TextFile;
    I:integer;
begin
  if FileExists(RecordFileName) then begin
     AssignFile(F,RecordFileName); Reset(F);
     for I:=1 to 10 do
     begin
       Readln(F,R[I].Name);
       Readln(F,R[I].Score);
     end;
     CloseFile(F);
  end else begin
     for I:=1 to 10 do
     begin
       R[I].Name := 'свободно';
       R[I].Score := 0;
     end;
  end;
end;

begin
  LoadRecords;
end.
