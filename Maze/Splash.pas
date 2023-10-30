unit Splash;

interface
uses PABCSystem, GraphABC;

procedure DrawSplash;

implementation

procedure DrawSplash;
var i:integer;
    x0,y0:integer;
begin
  x0 := GraphABC.Window.Width div 2;
  y0 := GraphABC.Window.Height div 2;
  
  for i:= 20 downto 1 do
  begin
    GraphABC.SetBrushColor(RGB(random(255),random(255),random(255)));
    FillEllipse(x0-i*10,y0-i*10,x0+i*10,y0+i*10);
    DrawEllipse(x0-i*10,y0-i*10,x0+i*10,y0+i*10);
  end;
  
  GraphABC.SetBrushColor(clWhite);
  y0 := 20; x0 := 20;
  GraphABC.TextOut(x0,y0,'Программа ЛАБИРИНТ');
  GraphABC.TextOut(x0,y0+20,'Выполнил СТУДЕНТ');
  GraphABC.TextOut(x0,y0+40,'2021');

  //Sleep(3000);
  Sleep(2000);
  
  
  GraphABC.SetBrushColor(clWhite);
  FillRectangle(0,0,GraphABC.Window.Width,GraphABC.Window.Height);

end;
  
begin
 Randomize;
 DrawSplash;
end.
