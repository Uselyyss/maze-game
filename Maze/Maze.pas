uses Splash, Records, MazeSolver, GraphABC;
const CellSize = 20;

 //Имитация процедуры Writeln для графического режима
 //(стандартная не дает возможность начать вывод с начала страницы)
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
  
  
 //Меню 
 var selected:integer = 0;   
 var Enter:boolean = false;
 var Refresh:boolean = false;

 var MenuStrings:array of String = 
 (
 'Инструкции',
 'Ввести имя игрока',
 'Создать лабиринт',
 'Загрузить лабиринт',
 'Сохранить лабиринт',
 'Пройти лабиринт',
 'Лучшее решение',
 'Выход'
 );

 procedure Info;
 var i:integer;
 begin
  line := 0;
  for i:=Low(MenuStrings) to High(MenuStrings) do 
   WriteLnX(MenuStrings[i]);
  DrawRectangle(0, 20*selected, 150, 20*(selected+1));
 end;

//X Y - координаты мышки
//M - нажатая кнопка (1 = левый, 2-правый, 0 - средний) 
procedure MouseDown(X, Y, M : Integer);
begin
  selected := Y div 20;
  Refresh := true;
  Enter := true;
end;

procedure KeyDown(key: integer); { процедура обработки нажатия клавиш }
var L:integer;
begin
 L := Length(MenuStrings);
 Refresh := true;
 if key=VK_Left then selected := (selected + L - 1) mod L; { влево }
 if key=VK_Right then selected := (selected + 1) mod L; { вправо }
 if key=VK_Up then selected := (selected + L - 1) mod L; { вверх }
 if key=VK_Down then selected :=(selected + 1) mod L; { вниз }
 if key=VK_Escape then CloseWindow; {выход насовсем?}
 if key=VK_Return then Enter := true; { выбор }
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

//Помощь
procedure Help;
begin
  GraphABC.ClearWindow;
  line := 0;
  WritelnX('Это помощь');
  WritelnX('Нажмите <ENTER>');
  Readln;
end;

//Ввод имени
var PlayerName:string = 'Неизвестный';
procedure SetName;
begin
  line := 0;
  GraphABC.ClearWindow;
  WritelnX('Введите имя игрока');
  WritelnX('и нажмите <ENTER>');
  Readln(PlayerName);
  Window.Caption := 'Игрок : '+PlayerName;
end;

//Вывести лабиринт
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
        else SetBrushColor(clBlack); //Не бывает
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
    SetBrushColor(clWhite); //Вернуть нормальный цвет кисточки
end;

//Создать случайный лабиринт
procedure RandomMaze; 
var newRows,newColumns:integer;
begin
  //Узнать размеры лабиринта
  newRows := 0; newColumns:=0;
  while (newRows<=1) or (newColumns<=1) or (newRows>20) or (newColumns>30) do begin
    GraphABC.ClearWindow;
    line := 0;
    Writelnx('Сколько строчек в лабиринте');
    dec(line);
    Readln(newRows);
    Writelnx('В лабиринте'+IntToStr(newRows)+' строк               ');  
    Writelnx('Сколько столбцов в лабиринте');
    Readln(newColumns);
    Writelnx('В лабиринте'+IntToStr(newRows)+' столбцов             ');  
  end;
  
  //Создать
  RandomMaze(newRows, newColumns);
  //Показать
  line := 20;
  GraphABC.ClearWindow;
  ShowMaze;
end;


//Загрузить лабиринт из файла
procedure LoadMaze;
var FileName:string;
begin
  line := 0;
  GraphABC.ClearWindow;
  WritelnX('Загрузка');
  WritelnX('Введите имя файла с лабиринтом');
  WritelnX('и нажмите <ENTER>');
  Readln(FileName);
  if not LoadMaze(FileName) then begin
    Writelnx('Проблемы с файлом '+FileName);
    Readln;
    exit;
  end;

  line := 20;
  GraphABC.ClearWindow;
  ShowMaze;
end;

//Сохранить лабиринт
procedure SaveMaze;
var FileName:string;
begin
  line := 0;
  GraphABC.ClearWindow;
  WritelnX('Сохранение');
  WritelnX('Введите имя файла с лабиринтом');
  WritelnX('и нажмите <ENTER>');
  Readln(FileName);
  GraphABC.ClearWindow;
  
  if not SaveMaze(FileName) then begin
    line := 0;
    Writelnx('Пути нет');
    Writelnx('Проблемы с лабиринтом');
    Writelnx('Он должен иметь старт,финиш');
    Writelnx('И быть проходимым');
    WritelnX('нажмите <ENTER>');
    Readln;
    exit;
  end;

end;



//Редактировать лабиринт

//X Y - координаты мышки
//M - нажатая кнопка (1 = левый, 2-правый, 0 - средний) 

//Левая кнопка мыши переключает клетку между состояниями "стена - свободна"
//Правая кнопка мыши переключает клетку между состояниями "вход - выход"

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

//ПРОБЕЛ переключает текущую клетку между состояниями "стена - свободна"
//ENTER переключает текущую клетку между состояниями "вход - выход"
//Стрелки перемещают курсор

procedure KeyDownEdit(key: integer); { процедура обработки нажатия клавиш }
begin
 Refresh := true;
 if key=VK_Left then selectedColumn := (selectedColumn + Columns - 1) mod Columns; { влево }
 if key=VK_Right then selectedColumn := (selectedColumn + 1) mod Columns; { вправо }
 if key=VK_Up then selectedRow := (selectedRow + Rows - 1) mod Rows; { вверх }
 if key=VK_Down then selectedRow :=(selectedRow + 1) mod Rows; { вниз }
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
  //Показать лабиринт
  ShowMaze;
  //Настроить обработчики мыши и клавиатуры
  OnKeyDown := KeyDownEdit;
  OnMouseDown := MouseDownEdit;
  //Выполняться до тех пор, пока пользователь не потребует закончить
  selectedRow := 0;
  selectedColumn:=0;
  endEdit:=false;
  Refresh := false;
  while not endEdit do begin
    ShowMaze;
    line := 15;
    Writelnx('Esc - закончить');
    Writelnx('ENTER - старт или финиш');
    Writelnx('ПРОБЕЛ - проход или стена');
    Writelnx('Стрелки  - перемещение');
    Writelnx('Правый мышь - старт или финиш');
    Writelnx('Левый мышь - проход или стена');
    SetPenColor(clRed);
    SetBrushColor(clTransparent);
    Rectangle(selectedColumn*CellSize, selectedRow*cellSize,(selectedColumn+1)*CellSize, (selectedRow+1)*cellSize);
    SetPenColor(clBlack);

    while not Refresh do;    Refresh := false;
  end;

  //Освободить обработчики
  OnKeyDown := KeyDownEdit;
  OnMouseDown := MouseDownEdit;
end;


//Полезность
procedure ShowRecords;
var i:integer;
begin
 line := 0;
 ClearWindow;
 Writelnx('Таблица рекордов');
  for i:=1 to 10 do Writelnx(GetRecords[i].Name+'.....'+GetRecords[i].Score);
 Readln;
end;

//Пройти лабиринт вручную
var StepCounter:integer;

procedure KeyDownPlay(key: integer); { процедура обработки нажатия клавиш }
var newColumn,newRow:integer;
begin
 Refresh := true;
 newColumn := selectedColumn;
 newRow := selectedRow;
 
 if key=VK_Left then newColumn := (selectedColumn + Columns - 1) mod Columns; { влево }
 if key=VK_Right then newColumn := (selectedColumn + 1) mod Columns; { вправо }
 if key=VK_Up then newRow := (selectedRow + Rows - 1) mod Rows; { вверх }
 if key=VK_Down then newRow :=(selectedRow + 1) mod Rows; { вниз }

 if M[newRow][newColumn].Kind = Wall then exit; //Там стена 
 inc(stepCounter);
 selectedColumn := newColumn;
 selectedRow := newRow;
 M[selectedRow][selectedColumn].InPath := true;
end;


procedure PlayMaze;
var Best:integer;
    r,c:integer;
begin
  //Решить задачу, 
  if not Solve then exit;
  //Стереть путь, запомнить длину пути
  Best := 0;
  for r := 0 to Rows-1 do 
   for c:= 0 to Columns-1 do
    if M[r][c].InPath then begin
      inc(Best);
      M[r][c].InPath := false;
    end;

  //Настроить клавиши
  OnKeyDown := KeyDownPlay;
  
  //Начальная позиция
  selectedColumn := StartColumn;
  selectedRow := StartRow;
  //счетчик
  StepCounter := 0;
  //Обработка
  while M[selectedRow][selectedColumn].Kind <> Finish do begin
    ShowMaze;
    //Отметить положение игрока
    SetBrushColor(clRed);
    Ellipse(selectedColumn*CellSize+1,selectedRow*CellSize+1, (selectedColumn+1)*CellSize-1,(selectedRow+1)*CellSize-1);
    SetBrushColor(clWhite);
    while not Refresh do;
    Refresh := false;
  end;
  
  //запись результатов
  //Коррекция количества шагов (учесть выход и вход)
  inc(StepCounter);
  AddRecord(PlayerName,1000*Best div StepCounter);
  OnKeyDown := nil;
  ShowRecords;
end;

//Решить лабиринт автоматически
procedure SolveMaze;
begin
   Solve();
   ShowMaze();
   Readln;
end;


begin
  Window.Caption := 'Игрок : '+PlayerName;
  while true do begin
    case Menu of 
    //'Инструкции',
    1:Help;
    //'Ввести имя игрока',
    2:SetName;
    //'Создать лабиринт',
    3:begin RandomMaze; EditMaze; end;
   //'Загрузить лабиринт',
    4:begin LoadMaze; EditMaze; end;
   // 'Сохранить лабиринт',
    5:SaveMaze;
   // 'Пройти лабиринт',
    6:PlayMaze;
   //'Лучшее решение',
    7:SolveMaze;
   //'Выход'
    8:break;
    end;
  end;  
  //Вывести таблицу рекордов
  ShowRecords;
  GraphABC.Window.Close;
end.
