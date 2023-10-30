unit MazeSolver;

interface
uses PABCSystem, Queue, GraphABC;

type  TKind = (Free,Wall,Start, Finish); //��� ����� ���� � ������ ���������
      PCell = ^TCell;
      TCell = record //������
        row,col:integer; //����������� ���������
        Counter:integer; //������� ��� ���������
        Mark:boolean;  //������� ��� ������� ���������
        Kind:TKind; //���������� ��� ��� (0 - ����� 1 - �����������)
        From:^TCell; //������ ������ ��������
        InPath:boolean; //�������� �� ������ ���������� ����
      end;

procedure RandomMaze(newRows,newColumns:integer); //������� ���������
function LoadMaze(FileName:string):boolean; //��������� �� �����
function SaveMaze(FileName:string):boolean; //��������� � ����

procedure SetCell(row,column:integer; value:TKind); //���������� ��������
function GetCell(row,column:integer):TKind; //������ ��������

function Solve():boolean;

function StartColumn:integer;
function StartRow:integer;
function FinishColumn:integer;
function FinishRow:integer;


var Rows,Columns:integer; //�������
var M:array of array of TCell; //��������

implementation

//�������� ������
procedure ClearCell(r,c:integer);
begin

  with M[r][c] do
    begin
      row := r;
      col := c;
      Kind := Free;
      From := nil;
      Counter := 0;
      Mark := false;
      InPath := false;
    end
end;

//�������� ������� ���������
procedure ResizeArray(NewRows,NewColumns:integer);
var 
    r,c:integer;
begin
   SetLength(M,NewRows);
   for r := 0 to NewRows-1 do
    begin
      SetLength(M[r],NewColumns);
      for c:=0 to NewColumns-1 do ClearCell(r,c);
    end;
    
    Rows:=NewRows;
    Columns := NewColumns;
    
end;

//**********************************************************//
//      ���������  ����������  ���������                    //
//**********************************************************//
(*
������������ ��������:
��������������, ��� ���������� � ������ ������ ���� ������ �� ���� ������� ������,
������� �������� �� �� �������� ������.
1. �������� ��������� ������ ������� � �������� �� ��� ����������.
2. ���� ���� ������������ ������
        1. ���� ������� ������ ����� ������������ ��������
                1. ����������� ������� ������ � �������
                2. �������� ��������� ������ �� ��������
                3. ������� ������ ����� ������� ������� � ���������
                4. �������� ��������� ������ ������� � �������� �� ��� ����������.
        2. ����� ���� ������� �� �����
                1. ��������� ������ �� �������
                2. �������� �� �������
*)

//������� "�����" ��������, ��� ��������, ������ � �������
procedure InitMaze0;
var row,col:integer;
    NR,NC:integer;
begin
  //��������� ����� ������ ������ ��������� ��������� �������,
  //�� ����� ������� ������, � � �������� - �����������
  if Rows mod 2 = 0 then inc(Rows);
  if Columns mod 2 = 0 then inc(Columns);
  ResizeArray(Rows,Columns); //������� ������
  NR := Rows div 2;
  NC := Columns div 2;

 //�������� ������
  for row:=0 to Rows-1 do
   for col:=0 to Columns-1 do
   begin
    M[row][col].Kind := Wall;
   end; 

 //�������
  for row:=0 to NR-1 do
   for col:=0 to NC-1 do
    M[2*row+1,2*col+1].Kind := Free;
end;



var Sosed:array[0..3] of PCell;//������ �������
    NSosed:integer;//���������� �������

function ValidCell(r,c:integer):boolean;
begin
  Result := True;
  Result := Result and (r>0);
  Result := Result and (r<Rows);
  Result := Result and (c>0);
  Result := Result and (c<Columns);
end;

procedure SaveSosed(r,c:integer);
begin
  if not ValidCell(r,c) then exit;
  if not M[r][c].Mark then 
  begin
    Sosed[NSosed]:=@M[r][c]; inc(NSosed);  
  end;
end;

//��������������� - ��������� ������ ������������ �������
procedure NotMarkSosedi(Cell:PCell);
var row,col:integer;
begin
     row := Cell^.row;
     col := Cell^.col;
     NSosed := 0;
     SaveSosed(row-2,col); //�����
     SaveSosed(row, col+2);//�������
     SaveSosed(row, col-2);//������
     SaveSosed(row+2, col);//����
end;

//
procedure RandomMaze(newRows,newColumns:integer); //������� ���������
var _row,_col:integer;
    Cell:PCell;//"������� ������"
    Selected:integer;//��������� �����
    NNotMarked:integer; //���������� �� ���������� ������
    NR,NC:integer; 
begin
   Rows := newRows;
   Columns := newColumns;
   InitMaze0; //�����������
   NR := Rows div 2;
   NC := Columns div 2;
//����� ������ ����
//1. �������� ��������� ������ ������� � �������� �� ��� ����������.
  _row := 2*NR-1;
  _col := 1;
  Cell := @M[_row][_col];
  NNotMarked := NR * NC; //� ������ �� �������� ��� ������
  M[_row][_col].Mark := true;
  dec(NNotMarked);
  
 //���� ���� ������������ ������
  while NNotMarked > 0 do begin
    //1. ���� ������� ������ ����� ������������ ��������
    //������� ��������� �����������
     //������ ���������� ������������ �������
     //��������� �� ������
     NotMarkSosedi(Cell);
     if (NSosed > 0) then begin
         //1. ����������� ������� ������ � �������
         Push(Cell^.row,Cell^.col);
         //2. �������� ��������� ������ �� ��������
         Selected := random(NSosed);
         //3. ������� ������ ����� ������� ������� � ���������
         _row := (Cell^.row + Sosed[Selected]^.row) div 2;
         _col := (Cell^.col + Sosed[Selected]^.col) div 2;
         M[_row][_col].Kind := Free;
         
         //4. �������� ��������� ������ ������� � �������� �� ��� ����������.
         Cell := Sosed[Selected];
         with Cell^ do M[row][col].Mark := true; dec(NNotMarked);
      end
      else begin
        //����� ������ �� �������
        //2. ����� ���� ������� �� �����
        //        1. ��������� ������ �� �������
        //        2. �������� �� �������
        Pop(_row,_col);
        Cell := @M[_row][_col];
      end;
  end;
  
  //�������� ���� � �����
  M[0][2*NC-1].Kind := Start;
  M[2*NR-1][0].Kind := Finish;

end;
//*********************************************************//


function LoadMaze(FileName:string):boolean; //��������� �� �����
var F:TextFile;
    row,col:integer;
    t:integer;
begin
   Result := FileExists(FileName);
   if not Result then Exit;
   
   AssignFile(F,FileName);
   ReSet(F);
   ReadLn(F,Rows);
   ReadLn(F,Columns);

   ResizeArray(Rows,Columns);

   for row:=0 to Rows-1 do
   begin
      for col := 0 to Columns-1 do
      begin
         ClearCell(row,col);
         Read(F,t);
         M[row][col].Kind := TKind(t);
      end;
      ReadLn(F);
   end;
   CloseFile(F);
end;



function StartColumn:integer;
var r,c:integer;
begin
  for r:=0 to Rows-1 do
   for c:=0 to Columns-1 do
    if M[r][c].Kind = Start then begin
      Result := c;
      exit;
    end;
 Result := -1;   
end;

function StartRow:integer;
var r,c:integer;
begin
  for r:=0 to Rows-1 do
   for c:=0 to Columns-1 do
    if M[r][c].Kind = Start then begin
      Result := r;
      exit;
    end;
 Result := -1;   
end;



function FinishColumn:integer;
var r,c:integer;
begin
  for r:=0 to Rows-1 do
   for c:=0 to Columns-1 do
    if M[r][c].Kind = Finish then begin
      Result := c;
      exit;
    end;
 Result := -1;   
end;

function FinishRow:integer;
var r,c:integer;
begin
  for r:=0 to Rows-1 do
   for c:=0 to Columns-1 do
    if M[r][c].Kind = Finish then begin
      Result := r;
      exit;
    end;
 Result := -1;   
end;

function AllOk:boolean;
begin
  Result := False;
  if StartColumn < 0 then exit;
  if FinishColumn < 0 then exit;
  //���������� ������ �������� [���� ��� � ������������ ������. ��������, ������������ ��������� ������]
  if not Solve then exit;
  Result := true;
end;


function SaveMaze(FileName:string):boolean; //��������� � ����
var F:TextFile;
    row,col:integer;
begin
   Result := AllOk;
   if not Result then exit;
   
   AssignFile(F,FileName);
   ReWrite(F);
   WriteLn(F,Rows);
   WriteLn(F,Columns);

   for row:=0 to Rows-1 do
   begin
      for col := 0 to Columns-1 do
         Write(F,ord(M[row][col].Kind):2);
      WriteLn(F);
   end;
   CloseFile(F);
end;


procedure SetCell(row,column:integer; value:TKind); //���������� ��������
begin
  M[row][column].Kind := value;
end;

function GetCell(row,column:integer):TKind; //������ ��������
begin
  Result := M[row][column].Kind;
end;

//������� ����� �������
function NewElement(r,c:integer):PQueueElement;
begin
  new(Result);
  Result^.r := r;
  Result^.c := c;
  Result^.next := nil;
end;

//���������, ����� �� ���� ���������
function CanMove(r0,c0,r,c:integer):boolean;
begin
  Result := false;
  if r<0 then exit; //���, ��� �� �������� ����
  if c<0 then exit;
  if r >= Length(M) then exit;
  if c >= Length(M[0]) then exit;

  if M[r][c].Kind = Wall then exit;//���� �� ����������? 
  Result := M[r0][c0].Counter+1<M[r][c].Counter; //����� �����, ���� ���� ������
end;

//"�����������"
procedure Move(r0,c0,r,c:integer);
begin
  M[r][c].Counter := M[r0][c0].Counter+ 1;
  M[r][c].From := @M[r0][c0];
  Push(NewElement(r,c));
end;


function Solve():boolean;
var r,c:integer;
    Rows,Columns:integer;
    E : PQueueElement;
    P : PCell;
    
    sr,sc,fr,fc : integer;
    
begin
  //������� ������
 
  //������ - ��� ����, ������ �������� � �������/������/�����/������
  Rows := Length(M);
  Columns := Length(M[0]);
  //�������� ��������� (����� Kind), ���������� Count = �������������
  for r:=0 to Rows-1 do
   for c:=0 to Columns-1 do
    with M[r][c] do
     begin
       Counter := Rows*Columns+1; //������ �� ������
       From:=nil; //��������
       InPath:=false; //�� �������� ������ ����
     end;

  //������� ������ � ������
  //�������� ��������� ������ � �������
  
  sr := StartRow;
  sc := StartColumn;
  
  Push(NewElement(sr,sc));
  M[sr][sc].Counter := 0; //���� � ������ ����� 0 �����
  M[sr][sc].InPath := true;
  //���� ������� �� �����
  while not Empty do begin
    //�������� �� ������� ������
    E := Pop;
    r := E^.r;
    c := E^.c;
    dispose(E); //������ �� �����
    //���� ���� ����������� ������������� � ����� �� 4 �����������
    //� ��� ���� Count � ����� ����� > �������� + 1
    //�� ��������� ��� ������ � �������
    if CanMove(r,c,r-1,c) then Move(r,c,r-1,c);
    if CanMove(r,c,r+1,c) then Move(r,c,r+1,c);
    if CanMove(r,c,r,c-1) then Move(r,c,r,c-1);
    if CanMove(r,c,r,c+1) then Move(r,c,r,c+1);
  end; //while

  //������� �����. ������� �� ������ �������� ���, �������� � ����
  //������ ���� ����?
  fr := FinishRow;
  fc := FinishColumn;
  if not assigned(M[fr][fc].From) then begin
    Writeln('���� ���');
    Result := false;
    Readln;
    Exit;
  end;
  P := @M[fr][fc];
  while assigned(P) do begin
    P^.InPath:=true;
    P := P^.From;
  end;
  Result := true;
end;

end.
