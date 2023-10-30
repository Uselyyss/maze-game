unit Queue;

interface

type
      //�������
      PQueueElement = ^TQueueElement;
      TQueueElement = record
        r,c:integer; //���������� ������
        Next:PQueueElement; //��������� � �������
      end;

procedure Push(E:PQueueElement); overload;
procedure Push(r,c:integer); overload;

function Pop:PQueueElement;  overload;
function Pop(var r:integer; var c:integer):boolean; overload;
function Empty:boolean;
function assigned(p:pointer):boolean;

implementation

var First:PQueueElement = nil; //������� - ������ �������
var Last:PQueueElement = nil; //������� - ��������� �������

function assigned(p:pointer):boolean;
begin
  Result := p <> nil;
end;
//��������� � �������
procedure Push(E:PQueueElement);
begin
  if not assigned(First) then begin
    First := E;
    Last := E;
    exit;
  end;
  Last^.Next := E;
  Last := E;
end;

procedure Push(r,c:integer);
var E:PQueueElement;
begin
  new(E);
  E^.r := r;
  E^.c := c;
  Push(E);
end;

//������� �� �������
function Pop:PQueueElement;
begin
   Result := First;
   First := First^.Next;
   if First = nil then Last := nil;
end;

function Pop(var r:integer; var c:integer):boolean; 
var E:PQueueElement;
begin
  E := Pop;
  Result := assigned(E); if not Result then exit;
  r := E^.r;
  c := E^.c;
  Dispose(E);
end;


function Empty:boolean;
begin
  Result := not assigned(First);
end;


end.
