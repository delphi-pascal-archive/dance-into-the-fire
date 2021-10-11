unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, uSprite, uFlamme, uMario, uFloor;

type
  TFlammeForm = class(TForm)
    Timer1: TTimer;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer2Timer(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    SpriteEngine : TSpriteEngine;
    Flamme : TFlamme;
    Mario : TMario;
  public
    procedure GenerateMap;
  end;

var
  FlammeForm: TFlammeForm;
  Level : integer = 1;
implementation

{$R *.dfm}
procedure TFlammeForm.GenerateMap;
var
  x,y : integer;
begin
  SpriteEngine.Lock;
  for x:=0 to SpriteEngine.ClientRect.Right do begin
    for y:=0 to SpriteEngine.ClientRect.Bottom do begin
      if (x mod 64 = 0) and (y mod 64 = 0 ) then begin SpriteEngine.AddSprite(TFloor.Create(LAVE,x,y)); inc(Level,1); end;
    end;
  end;
  SpriteEngine.Unlock;
end;

procedure TFlammeForm.FormCreate(Sender: TObject);
begin
  DoubleBuffered:=True;
  Width := 640;
  Height := 480;
  Top := Screen.Height div 2 - Height div 2;
  Left := Screen.Width div 2 - Width div 2;
  SpriteEngine:= TSpriteEngine.Create(Canvas,ClientRect);
  SpriteEngine.SetBackground('MEDIA\GFX\BackGround.JPG');
  Mario := TMario.Create(SpriteEngine.ClientRect.Right div 2, SpriteEngine.ClientRect.Bottom div 2);

  SpriteEngine.AddSprite(Mario);
  (* Creation de la " Map " *)
  GenerateMap;
end;

procedure TFlammeForm.FormPaint(Sender: TObject);
begin
  if Assigned(SpriteEngine) then SpriteEngine.Draw
end;

procedure TFlammeForm.Timer1Timer(Sender: TObject);
begin
  if Assigned(SpriteEngine) then begin
    SpriteEngine.Move;
    Invalidate;
    if SpriteEngine.CountSprite > Level then exit;
    SpriteEngine.AddSprite(TFlamme.Create(Type1,Random(SpriteEngine.ClientRect.Right),SpriteEngine.ClientRect.Bottom));
    SpriteEngine.Sort:=True;
  end;
end;

procedure TFlammeForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(SpriteEngine) then SpriteEngine.AddSprite(TFlamme.Create(Type1,X,Y));
end;

procedure TFlammeForm.Timer2Timer(Sender: TObject);
begin
  Inc(Level,10);
end;

procedure TFlammeForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  ShowCursor(False);
  if Assigned(Mario) then Mario.SetCoord(X,Y);
end;

procedure TFlammeForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE : Close;
  end; 
end;

end.
