unit uMario;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,uSprite;
type


  TMario = class (TSprite)
  private
    fAnim : integer;
    procedure SetAnim;
    procedure CheckClientRect;
  public
    constructor Create (X,Y : integer);reintroduce;
    procedure Progress;override;
    procedure Draw;override;
  end;

implementation
uses Math;

constructor TMario.Create (X,Y : integer);
begin
  inherited Create('MEDIA\GFX\Mario.bmp',32,32);
  IndexFrames:=0;
  SetCoord(X,Y);
  SetZCoord(100);
  fAnim:=0;
end;

procedure TMario.CheckClientRect;
begin
  if (Coord.X < ClientRect.Left) then SetCoord(ClientRect.Left,Coord.Y);

  if (Coord.X > ClientRect.Right) then SetCoord(ClientRect.Right,Coord.Y);

  if (Coord.Y < ClientRect.Top) then SetCoord(Coord.X,ClientRect.Top);

  if (Coord.Y > ClientRect.Right) then SetCoord(Coord.X,ClientRect.Right);

end;

procedure TMario.SetAnim;
begin
  inc(fAnim,1);
  if fAnim < 10 then exit;
  fAnim:=0;
  IndexFrames := IndexFrames + 1;
  if(IndexFrames>=NumberOfFrames-1) then IndexFrames:=0;
end;

procedure TMario.Progress;
begin
  CheckClientRect;
  inherited Progress;
end;

procedure TMario.Draw;
begin
  SetAnim;
  inherited Draw;
end;


end.

