unit MazeSolver;

interface
uses PABCSystem, Queue, GraphABC;

type  TKind = (Free,Wall,Start, Finish); //Что может быть в ячейке лабиринта
      PCell = ^TCell;
      TCell = record //Ячейка
        row,col:integer; //Собственное положение
        Counter:integer; //Счетчик для алгоритма
        Mark:boolean;  //Пометка для другого алгоритма
        Kind:TKind; //Проходимая или нет (0 - можно 1 - препятствие)
        From:^TCell; //Откуда пришел алгоритм
        InPath:boolean; //Является ли частью найденного пути
      end;

procedure RandomMaze(newRows,newColumns:integer); //Создать случайный
function LoadMaze(FileName:string):boolean; //Загрузить из файла
function SaveMaze(FileName:string):boolean; //Сохранить в файл

procedure SetCell(row,column:integer; value:TKind); //Установить значение
function GetCell(row,column:integer):TKind; //Узнать значение

function Solve():boolean;

function StartColumn:integer;
function StartRow:integer;
function FinishColumn:integer;
function FinishRow:integer;


var Rows,Columns:integer; //Размеры
var M:array of array of TCell; //Лабиринт

implementation

//Очистить ячейку
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

//Изменить размеры лабиринта
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
//      ГЕНЕРАЦИЯ  СЛУЧАЙНОГО  ЛАБИРИНТА                    //
//**********************************************************//
(*
Используется алгоритм:
предполагается, что изначально у каждой клетки есть стенки со всех четырех сторон,
которые отделяют ее от соседних клеток.
1. Сделайте начальную клетку текущей и отметьте ее как посещенную.
2. Пока есть непосещенные клетки
        1. Если текущая клетка имеет непосещенных «соседей»
                1. Протолкните текущую клетку в очередь
                2. Выберите случайную клетку из соседних
                3. Уберите стенку между текущей клеткой и выбранной
                4. Сделайте выбранную клетку текущей и отметьте ее как посещенную.
        2. Иначе если очередь не пуста
                1. Выдерните клетку из очереди
                2. Сделайте ее текущей
*)

//Создать "целый" лабиринт, без проходов, только с дырками
procedure InitMaze0;
var row,col:integer;
    NR,NC:integer;
begin
  //Генератор умеет делать только лабиринты нечетного размера,
  //по краям которых стенки, а в середине - червоточины
  if Rows mod 2 = 0 then inc(Rows);
  if Columns mod 2 = 0 then inc(Columns);
  ResizeArray(Rows,Columns); //Очитить заодно
  NR := Rows div 2;
  NC := Columns div 2;

 //Сплошная стенка
  for row:=0 to Rows-1 do
   for col:=0 to Columns-1 do
   begin
    M[row][col].Kind := Wall;
   end; 

 //Проходы
  for row:=0 to NR-1 do
   for col:=0 to NC-1 do
    M[2*row+1,2*col+1].Kind := Free;
end;



var Sosed:array[0..3] of PCell;//Список соседей
    NSosed:integer;//Количество соседей

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

//Вспомогательная - составить список непомеченных соседей
procedure NotMarkSosedi(Cell:PCell);
var row,col:integer;
begin
     row := Cell^.row;
     col := Cell^.col;
     NSosed := 0;
     SaveSosed(row-2,col); //Вверх
     SaveSosed(row, col+2);//Направо
     SaveSosed(row, col-2);//Налево
     SaveSosed(row+2, col);//Вниз
end;

//
procedure RandomMaze(newRows,newColumns:integer); //Создать случайный
var _row,_col:integer;
    Cell:PCell;//"Текущая клетка"
    Selected:integer;//Выбранный сосед
    NNotMarked:integer; //Количество не посещенных клеток
    NR,NC:integer; 
begin
   Rows := newRows;
   Columns := newColumns;
   InitMaze0; //Подготовить
   NR := Rows div 2;
   NC := Columns div 2;
//Левый нижний угол
//1. Сделайте начальную клетку текущей и отметьте ее как посещенную.
  _row := 2*NR-1;
  _col := 1;
  Cell := @M[_row][_col];
  NNotMarked := NR * NC; //В начале не посещены все клетки
  M[_row][_col].Mark := true;
  dec(NNotMarked);
  
 //Пока есть непосещенные клетки
  while NNotMarked > 0 do begin
    //1. Если текущая клетка имеет непосещенных «соседей»
    //Выбрать случайное направление
     //Узнать количество непосещенных соседей
     //Составить их список
     NotMarkSosedi(Cell);
     if (NSosed > 0) then begin
         //1. Протолкните текущую клетку в очередь
         Push(Cell^.row,Cell^.col);
         //2. Выберите случайную клетку из соседних
         Selected := random(NSosed);
         //3. Уберите стенку между текущей клеткой и выбранной
         _row := (Cell^.row + Sosed[Selected]^.row) div 2;
         _col := (Cell^.col + Sosed[Selected]^.col) div 2;
         M[_row][_col].Kind := Free;
         
         //4. Сделайте выбранную клетку текущей и отметьте ее как посещенную.
         Cell := Sosed[Selected];
         with Cell^ do M[row][col].Mark := true; dec(NNotMarked);
      end
      else begin
        //Взять клетку из очереди
        //2. Иначе если очередь не пуста
        //        1. Выдерните клетку из очереди
        //        2. Сделайте ее текущей
        Pop(_row,_col);
        Cell := @M[_row][_col];
      end;
  end;
  
  //Отметить вход и выход
  M[0][2*NC-1].Kind := Start;
  M[2*NR-1][0].Kind := Finish;

end;
//*********************************************************//


function LoadMaze(FileName:string):boolean; //Загрузить из файла
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
  //Попытаться пройти лабиринт [хотя это и неправильный подход. Возможно, пользователь заготовку делает]
  if not Solve then exit;
  Result := true;
end;


function SaveMaze(FileName:string):boolean; //Сохранить в файл
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


procedure SetCell(row,column:integer; value:TKind); //Установить значение
begin
  M[row][column].Kind := value;
end;

function GetCell(row,column:integer):TKind; //Узнать значение
begin
  Result := M[row][column].Kind;
end;

//Создать новый элемент
function NewElement(r,c:integer):PQueueElement;
begin
  new(Result);
  Result^.r := r;
  Result^.c := c;
  Result^.next := nil;
end;

//Проверить, можно ли сюда двигаться
function CanMove(r0,c0,r,c:integer):boolean;
begin
  Result := false;
  if r<0 then exit; //Нет, это за границей поля
  if c<0 then exit;
  if r >= Length(M) then exit;
  if c >= Length(M[0]) then exit;

  if M[r][c].Kind = Wall then exit;//Поле не проходимое? 
  Result := M[r0][c0].Counter+1<M[r][c].Counter; //Имеет смысл, если путь короче
end;

//"Переместить"
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
  //Решение задачи
 
  //Ячейки - это граф, каждая граничит с верхней/нижней/левой/правой
  Rows := Length(M);
  Columns := Length(M[0]);
  //Очистить состояние (кроме Kind), установить Count = бесконечности
  for r:=0 to Rows-1 do
   for c:=0 to Columns-1 do
    with M[r][c] do
     begin
       Counter := Rows*Columns+1; //Больше не бывает
       From:=nil; //Ниоткуда
       InPath:=false; //Не является частью пути
     end;

  //Методом обхода в ширину
  //Добавить стартовую ячейку в очередь
  
  sr := StartRow;
  sc := StartColumn;
  
  Push(NewElement(sr,sc));
  M[sr][sc].Counter := 0; //Путь в начало имеет 0 длину
  M[sr][sc].InPath := true;
  //Пока очередь не пуста
  while not Empty do begin
    //Получить из очереди ячейку
    E := Pop;
    r := E^.r;
    c := E^.c;
    dispose(E); //Больше не нужен
    //Если есть возможность переместиться в одном из 4 направлений
    //и при этом Count в новом месте > текущего + 1
    //То отправить эту ячейку в очередь
    if CanMove(r,c,r-1,c) then Move(r,c,r-1,c);
    if CanMove(r,c,r+1,c) then Move(r,c,r+1,c);
    if CanMove(r,c,r,c-1) then Move(r,c,r,c-1);
    if CanMove(r,c,r,c+1) then Move(r,c,r,c+1);
  end; //while

  //Очередь пуста. Начиная от финиша отметить все, входящие в путь
  //Вообще есть путь?
  fr := FinishRow;
  fc := FinishColumn;
  if not assigned(M[fr][fc].From) then begin
    Writeln('Пути нет');
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
