unit uFlamme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,uSprite;
type
  TTypeFlamme = (Type1);

  TFlamme = class (TSprite)
  private
    fNbCycle : integer;
    fType : TTypeFlamme;
    procedure SetAnim;
    procedure CheckClientRect;
    procedure Collide;
  public
    constructor Create (AType : TTypeFlamme;X,Y : integer);reintroduce;
    procedure Progress;override;
    procedure Draw;override;
  end;

implementation
uses Math;

constructor TFlamme.Create (AType : TTypeFlamme;X,Y : integer);
begin
  fType := AType;
  case fType of
    Type1 :
     begin
      inherited Create('MEDIA\GFX\Flamme.bmp',19,38);
      IndexFrames:=0;
     end;
  end;
  SetCoord(X,Y);
  while(Speed = 0)do
    Speed := RandomRange(-8,8);
  fNbCycle := 0;
  Direction := Random (360);

  SetZCoord(50);
end;

procedure TFlamme.CheckClientRect;
begin
  if (Coord.X < ClientRect.Left) then begin SetCoord(ClientRect.Right,Coord.Y); inc(fNbCycle,1); end;

  if (Coord.X > ClientRect.Right) then begin SetCoord(ClientRect.Left,Coord.Y); inc(fNbCycle,1); end;

  if (Coord.Y < ClientRect.Top) then begin SetCoord(Coord.X,ClientRect.Bottom); inc(fNbCycle,1); end;

  if (Coord.Y > ClientRect.Right) then begin SetCoord(Coord.X,ClientRect.Top); inc(fNbCycle,1); end;

  if fNbCycle > 10 then Kill;
end;
procedure TFlamme.Collide;
var
  i : integer;
begin
  // on parcours la liste
  for i:=0 to ParentList.Count-1 do begin
    // on recherche notre Mario ...
    if ParentList.Items[i].ClassName='TMario' then begin
      // si collision, tt le monde meurt : la flamme qui touche et mario !
      if isCollide(ParentList.Items[i]) then begin
        ParentList.Items[i].Kill;
        Kill;
      end;
      exit;
    end;
  end;
end;

procedure TFlamme.SetAnim;
begin
  case fType of
    Type1 :
     begin
      IndexFrames := IndexFrames + 1;
      if(IndexFrames>=NumberOfFrames-1) then IndexFrames:=0;
     end;
  end;
end;

procedure TFlamme.Progress;
begin
  CheckClientRect;
  Collide;
  inherited Progress;
end;

procedure TFlamme.Draw;
begin
  SetAnim;
  inherited Draw;
end;

end.
