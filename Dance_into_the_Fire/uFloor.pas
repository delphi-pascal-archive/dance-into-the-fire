unit uFloor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,uSprite;
type
  TTypeFloor = (LAVE);

  TFloor = class (TSprite)
  private
    fType : TTypeFloor;
    fAnimIni , fAnimMax,fAnimCpt,fAnimTps : integer;
    procedure SetAnim(AType :TTypeFloor) ;
    procedure Anim;
  public
    constructor Create (AType : TTypeFloor;X,Y : integer);reintroduce;
    procedure Draw;override;
  end;

implementation
uses Math;

constructor TFloor.Create(AType : TTypeFloor;X,Y : integer);
begin
  fType := AType;
  inherited Create('MEDIA\GFX\Floor.bmp',64,64);
  SetAnim(fType);
  SetCoord(X,Y);
  // le plus bas vu que c le sol ... 
  SetZCoord(0);
end;

procedure TFloor.SetAnim(AType :TTypeFloor);
begin
  case fType of
    LAVE :
     begin
      fAnimIni:=0;
      fAnimMax:=3;
      fAnimCpt:=0;
      fAnimTps:=4;
      Alpha:=75;
     end;
  end;
  IndexFrames := fAnimIni;

end;

procedure TFloor.Anim;
begin
  inc(fAnimCpt,1);
  if fAnimCpt < fAnimTps then exit;
  fAnimCpt:=0;
  IndexFrames := IndexFrames+1;
  if IndexFrames > fAnimMax-1 then IndexFrames := fAnimIni;
end;

procedure TFloor.Draw;
begin
  Anim;
  inherited Draw;
end;


end.

