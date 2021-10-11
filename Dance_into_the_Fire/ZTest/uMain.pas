unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,ExtCtrls,Contnrs,uSprite,uSpriteText;

type

  TBallon = class (TSprite)
    private
      procedure CheckClientRect;
    public
      constructor Create(X,Y : integer);reintroduce;
      procedure Progress;override;
  end;

  TPylone = class (TSprite)
    private

    public
      constructor Create(X,Y,Width,Height : integer);reintroduce;
  end;
  TMainForm = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FPSSprite : TSpriteText;
  public
    //généreusement "emprunté" à bacterius ;)
    procedure Fps;
  end;
const
  MAX_SPRITES = 50;
var
  MainForm: TMainForm;
  LastT: Integer=0;
  FPSCount: Integer=0;
  FramesPerSecond: Integer=0;
  SpriteEngine : TSpriteEngine;
implementation

uses Math;

{$R *.dfm}
 { - TPylone ---------------------------------------------------------- }
constructor TPylone.Create(X,Y,Width,Height : integer);
var
  Bmp : TBitmap;
begin
  Bmp := TBitmap.Create;
  Bmp.Width:=Width;
  Bmp.Height:=Height;
  Bmp.Canvas.Brush.Color:=ClBlack;
  Bmp.Canvas.FillRect(Bmp.Canvas.ClipRect);
  inherited Create(Bmp,Width,Height);
  SetCoord(X,Y);
  // plus le Z est Grand , plus l'object est affiché au dessus ...
  // ici seul les ballons orange passeront au dessus ...
  // cfr : CheckClientRect
  SetZCoord(25);
  // la méthode Kill n'a pas d'effet sur lui ...
  Tag := INVINCIBLE ;
  Bmp.Free;
end;

 { - TBallon ---------------------------------------------------------- }
procedure TBallon.CheckClientRect;
begin
  if (Coord.X > (ClientRect.Right - Width)) or (Coord.X < ClientRect.Left)  then begin
    Speed := - Speed;
    IndexFrames := IndexFrames + 1 ;
    self.SetZCoord(IndexFrames*10);
    Alpha := 255 - IndexFrames*25 ;
    if (IndexFrames >= NumberOfFrames -1) then kill;
    SpriteEngine.Sort:=True;
  end;
end;

constructor TBallon.Create(X,Y : integer);
begin
  inherited Create('Media\GFX\Ballon.bmp',30,35);
  SetCoord(X,Y);

  while(Speed = 0) do
    Speed := RandomRange(-8,8);
end;

procedure TBallon.Progress;
begin
  CheckClientRect;
  inherited Progress;
end;
 { - TMainForm ---------------------------------------------------------- }
procedure TMainForm.FPS; // Calcul des FPS
var
  T: Integer;
begin
  T := GetTickCount;

  if T-LastT >= 1000 then
  begin
    FramesPerSecond := FPSCount;
    LastT := T;
    fpsCount := 0;
  end
  else
  Inc(FPSCount);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;
  Randomize;

  Width := 640;
  Height := 480;
  Top :=  Screen.Height div 2 - Height div 2;
  Left := Screen.Width  div 2 - Width  div 2;

  SpriteEngine := TSpriteEngine.Create(Canvas,ClientRect);
  SpriteEngine.SetBackground('MEDIA\GFX\Background.bmp');

  FPSSprite := TSpriteText.Create(' ');
  FPSSprite.SetZCoord(10);
  SpriteEngine.AddSprite(FPSSprite);
  SpriteEngine.AddSprite(TPylone.Create(SpriteEngine.ClientRect.Right div 2 - 25,0,50,SpriteEngine.ClientRect.Bottom));

  Timer1.Enabled:=True;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SpriteEngine.Free;
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
  SpriteEngine.Draw;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled:=False;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE : close;
    VK_F1 : SpriteEngine.AutoCapacity := not SpriteEngine.AutoCapacity;
    VK_F2 : SpriteEngine.Transparent := not SpriteEngine.Transparent;
    VK_F3 : SpriteEngine.Clear;
  end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  SpriteEngine.Move;
  SpriteEngine.RemoveKillSprite;
  FPSSprite.Text:= Format('FPS : %d , Nombre de Sprite(s) : %d',[FramesPerSecond,SpriteEngine.CountSprite]);
  Invalidate;
  if SpriteEngine.CountSprite> MAX_SPRITES then exit;
    SpriteEngine.AddSprite(TBallon.Create(Random(SpriteEngine.ClientRect.Right),Random(SpriteEngine.ClientRect.Bottom)));
end;

procedure TMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  SpriteEngine.AddSprite(TBallon.Create(X,Y));
end;

end.
