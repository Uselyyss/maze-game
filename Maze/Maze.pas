uses Splash, Records, MazeSolver, GraphABC;
const CellSize = 20;

 //�������� ��������� Writeln ��� ������������ ������
 //(����������� �� ���� ����������� ������ ����� � ������ ��������)
 var line:integer = 0;
 procedure WritelnX(s:string);
 begin
   TextOut(0,line*20,s);
   inc(line);
 end;

 procedure WritelnX(s:string; i:integer);
 begin
  s := s + IntToStr(i);
  Writelnx(s);
 end;
  
  
 //���� 
 var selected:integer = 0;   
 var Enter:boolean = false;
 var Refresh:boolean = false;

 var MenuStrings:array of String = 
 (
 '����������',
 '������ ��� ������',
 '������� ��������',
 '��������� ��������',
 '��������� ��������',
 '������ ��������',
 '������ �������',
 '�����'
 );

 procedure Info;
 var i:integer;
 begin
  line := 0;
  for i:=Low(MenuStrings) to High(MenuStrings) do 
   WriteLnX(MenuStrings[i]);
  DrawRectangle(0, 20*selected, 150, 20*(selected+1));
 end;

//X Y - ���������� �����
//M - ������� ������ (1 = �����, 2-������, 0 - �������) 
procedure MouseDown(X, Y, M : Integer);
begin
  selected := Y div 20;
  Refresh := true;
  Enter := true;
end;

procedure KeyDown(key: integer); { ��������� ��������� ������� ������ }
var L:integer;
begin
 L := Length(MenuStrings);
 Refresh := true;
 if key=VK_Left then selected := (selected + L - 1) mod L; { ����� }
 if key=VK_Right then selected := (selected + 1) mod L; { ������ }
 if key=VK_Up then selected := (selected + L - 1) mod L; { ����� }
 if key=VK_Down then selected :=(selected + 1) mod L; { ���� }
 if key=VK_Escape then CloseWindow; {����� ��������?}
 if key=VK_Return then Enter := true; { ����� }
end;

 function Menu:integer;
 begin
    OnMouseDown := MouseDown;
    OnKeyDown := KeyDown;
 
    Enter := false;
    while not Enter do
    begin
      GraphABC.ClearWindow;
      Info;
      while not Refresh do;
      Refresh := false;
    end;
 
    Result := selected+1;
    //Readln(Result);
    GraphABC.ClearWindow;
    line := 0;
    
   OnMouseDown := nil;
   OnKeyDown := nil;
 end;

//������
procedure Help;
begin
  GraphABC.ClearWindow;
  line := 0;
  WritelnX('��� ������');
  WritelnX('������� <ENTER>');
  Readln;
end;

//���� �����
var PlayerName:string = '�����������';
procedure SetName;
begin
  line := 0;
  GraphABC.ClearWindow;
  WritelnX('������� ��� ������');
  WritelnX('� ������� <ENTER>');
  Readln(PlayerName);
  Window.Caption := '����� : '+PlayerName;
end;

//������� ��������
procedure ShowMaze;
var r,c:integer;
    x1,y1,x2,y2:integer;
begin
  GraphABC.ClearWindow;
  for r:=0 to Rows-1 do
   for c:=0 to Columns-1 do
    begin
      y1 := r * CellSize;
      y2 := y1 + CellSize;
      x1 := c * CellSize;
      x2 := x1 + CellSize;
      case M[r][c].Kind of
        Free:SetBrushColor(clWhite);
        Wall:SetBrushColor(clBlue);
        Start:SetBrushColor(clYellow);
        Finish:SetBrushColor(clGreen);
        else SetBrushColor(clBlack); //�� ������
      end;
      FillRectangle(x1,y1,x2,y2);
      SetPenColor(clBlack);
      DrawRectangle(x1,y1,x2,y2);
      if M[r][c].InPath then begin
        SetPenColor(clGreen);
        DrawRectangle(x1+3,y1+3,x2-3,y2-3);
        SetPenColor(clBlack);
      end;
    end;
    SetBrushColor(clWhite); //������� ���������� ���� ��������
end;

//������� ��������� ��������
procedure RandomMaze; 
var newRows,newColumns:integer;
begin
  //������ ������� ���������
  newRows := 0; newColumns:=0;
  while (newRows<=1) or (newColumns<=1) or (newRows>20) or (newColumns>30) do begin
    GraphABC.ClearWindow;
    line := 0;
    Writelnx('������� ������� � ���������');
    dec(line);
    Readln(newRows);
    Writelnx('� ���������'+IntToStr(newRows)+' �����               ');  
    Writelnx('������� �������� � ���������');
    Readln(newColumns);
    Writelnx('� ���������'+IntToStr(newRows)+' ��������             ');  
  end;
  
  //�������
  RandomMaze(newRows, newColumns);
  //��������
  line := 20;
  GraphABC.ClearWindow;
  ShowMaze;
end;


//��������� �������� �� �����
procedure LoadMaze;
var FileName:string;
begin
  line := 0;
  GraphABC.ClearWindow;
  WritelnX('��������');
  WritelnX('������� ��� ����� � ����������');
  WritelnX('� ������� <ENTER>');
  Readln(FileName);
  if not LoadMaze(FileName) then begin
    Writelnx('�������� � ������ '+FileName);
    Readln;
    exit;
  end;

  line := 20;
  GraphABC.ClearWindow;
  ShowMaze;
end;

//��������� ��������
procedure SaveMaze;
var FileName:string;
begin
  line := 0;
  GraphABC.ClearWindow;
  WritelnX('����������');
  WritelnX('������� ��� ����� � ����������');
  WritelnX('� ������� <ENTER>');
  Readln(FileName);
  GraphABC.ClearWindow;
  
  if not SaveMaze(FileName) then begin
    line := 0;
    Writelnx('���� ���');
    Writelnx('�������� � ����������');
    Writelnx('�� ������ ����� �����,�����');
    Writelnx('� ���� ����������');
    WritelnX('������� <ENTER>');
    Readln;
    exit;
  end;

end;



//������������� ��������

//X Y - ���������� �����
//M - ������� ������ (1 = �����, 2-������, 0 - �������) 

//����� ������ ���� ����������� ������ ����� ����������� "����� - ��������"
//������ ������ ���� ����������� ������ ����� ����������� "���� - �����"

var selectedRow,selectedColumn:integer;
    endEdit:boolean;

procedure MouseDownEdit(X, Y, MM : Integer);
begin
  selectedRow := Y div cellSize;
  selectedColumn := X div cellSize;
  if selectedRow<0 then exit;
  if selectedColumn<0 then exit;
  if selectedRow >= Rows then exit;
  if selectedColumn >= Columns then exit;
  if MM = 1 then
  begin
   if M[selectedRow][selectedColumn].Kind = Free 
     then M[selectedRow][selectedColumn].Kind:=Wall
     else M[selectedRow][selectedColumn].Kind:=Free;
  end;
  if MM = 2 then begin
   if M[selectedRow,selectedColumn].Kind = Start 
     then M[selectedRow,selectedColumn].Kind:=Finish
     else M[selectedRow,selectedColumn].Kind:=Start;
  end;
  
  Refresh := true;
end;

//������ ����������� ������� ������ ����� ����������� "����� - ��������"
//ENTER ����������� ������� ������ ����� ����������� "���� - �����"
//������� ���������� ������

procedure KeyDownEdit(key: integer); { ��������� ��������� ������� ������ }
begin
 Refresh := true;
 if key=VK_Left then selectedColumn := (selectedColumn + Columns - 1) mod Columns; { ����� }
 if key=VK_Right then selectedColumn := (selectedColumn + 1) mod Columns; { ������ }
 if key=VK_Up then selectedRow := (selectedRow + Rows - 1) mod Rows; { ����� }
 if key=VK_Down then selectedRow :=(selectedRow + 1) mod Rows; { ���� }
 if key=VK_Escape then endEdit := true;
 if key=VK_Space then 
   if M[selectedRow,selectedColumn].Kind = Free 
     then M[selectedRow,selectedColumn].Kind:=Wall
     else M[selectedRow,selectedColumn].Kind:=Free;
 if key=VK_Return then 
   if M[selectedRow,selectedColumn].Kind = Start 
     then M[selectedRow,selectedColumn].Kind:=Finish
     else M[selectedRow,selectedColumn].Kind:=Start;
 
end;


procedure EditMaze;
begin
  //�������� ��������
  ShowMaze;
  //��������� ����������� ���� � ����������
  OnKeyDown := KeyDownEdit;
  OnMouseDown := MouseDownEdit;
  //����������� �� ��� ���, ���� ������������ �� ��������� ���������
  selectedRow := 0;
  selectedColumn:=0;
  endEdit:=false;
  Refresh := false;
  while not endEdit do begin
    ShowMaze;
    line := 15;
    Writelnx('Esc - ���������');
    Writelnx('ENTER - ����� ��� �����');
    Writelnx('������ - ������ ��� �����');
    Writelnx('�������  - �����������');
    Writelnx('������ ���� - ����� ��� �����');
    Writelnx('����� ���� - ������ ��� �����');
    SetPenColor(clRed);
    SetBrushColor(clTransparent);
    Rectangle(selectedColumn*CellSize, selectedRow*cellSize,(selectedColumn+1)*CellSize, (selectedRow+1)*cellSize);
    SetPenColor(clBlack);

    while not Refresh do;    Refresh := false;
  end;

  //���������� �����������
  OnKeyDown := KeyDownEdit;
  OnMouseDown := MouseDownEdit;
end;


//����������
procedure ShowRecords;
var i:integer;
begin
 line := 0;
 ClearWindow;
 Writelnx('������� ��������');
  for i:=1 to 10 do Writelnx(GetRecords[i].Name+'.....'+GetRecords[i].Score);
 Readln;
end;

//������ �������� �������
var StepCounter:integer;

procedure KeyDownPlay(key: integer); { ��������� ��������� ������� ������ }
var newColumn,newRow:integer;
begin
 Refresh := true;
 newColumn := selectedColumn;
 newRow := selectedRow;
 
 if key=VK_Left then newColumn := (selectedColumn + Columns - 1) mod Columns; { ����� }
 if key=VK_Right then newColumn := (selectedColumn + 1) mod Columns; { ������ }
 if key=VK_Up then newRow := (selectedRow + Rows - 1) mod Rows; { ����� }
 if key=VK_Down then newRow :=(selectedRow + 1) mod Rows; { ���� }

 if M[newRow][newColumn].Kind = Wall then exit; //��� ����� 
 inc(stepCounter);
 selectedColumn := newColumn;
 selectedRow := newRow;
 M[selectedRow][selectedColumn].InPath := true;
end;


procedure PlayMaze;
var Best:integer;
    r,c:integer;
begin
  //������ ������, 
  if not Solve then exit;
  //������� ����, ��������� ����� ����
  Best := 0;
  for r := 0 to Rows-1 do 
   for c:= 0 to Columns-1 do
    if M[r][c].InPath then begin
      inc(Best);
      M[r][c].InPath := false;
    end;

  //��������� �������
  OnKeyDown := KeyDownPlay;
  
  //��������� �������
  selectedColumn := StartColumn;
  selectedRow := StartRow;
  //�������
  StepCounter := 0;
  //���������
  while M[selectedRow][selectedColumn].Kind <> Finish do begin
    ShowMaze;
    //�������� ��������� ������
    SetBrushColor(clRed);
    Ellipse(selectedColumn*CellSize+1,selectedRow*CellSize+1, (selectedColumn+1)*CellSize-1,(selectedRow+1)*CellSize-1);
    SetBrushColor(clWhite);
    while not Refresh do;
    Refresh := false;
  end;
  
  //������ �����������
  //��������� ���������� ����� (������ ����� � ����)
  inc(StepCounter);
  AddRecord(PlayerName,1000*Best div StepCounter);
  OnKeyDown := nil;
  ShowRecords;
end;

//������ �������� �������������
procedure SolveMaze;
begin
   Solve();
   ShowMaze();
   Readln;
end;


begin
  Window.Caption := '����� : '+PlayerName;
  while true do begin
    case Menu of 
    //'����������',
    1:Help;
    //'������ ��� ������',
    2:SetName;
    //'������� ��������',
    3:begin RandomMaze; EditMaze; end;
   //'��������� ��������',
    4:begin LoadMaze; EditMaze; end;
   // '��������� ��������',
    5:SaveMaze;
   // '������ ��������',
    6:PlayMaze;
   //'������ �������',
    7:SolveMaze;
   //'�����'
    8:break;
    end;
  end;  
  //������� ������� ��������
  ShowRecords;
  GraphABC.Window.Close;
end.
