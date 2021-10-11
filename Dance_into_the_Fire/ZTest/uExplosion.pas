unit uExplosion;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,uSprite;
type
  TTypeExplosion =(Type1 , Type2);
  TExplosion = class(TSprite)
  private
    fSpeedCount : integer;
    fSpeedAnim : integer;
    fTypeExplosion : TTypeExplosion;
    procedure CheckAlpha;
  public
    property SpeedAnim : integer read fSpeedAnim write fSpeedAnim;

    constructor Create(ATypeExplosion:TTypeExplosion;X,Y : integer);
    procedure Draw;override;
  end;

implementation

constructor TExplosion.Create(ATypeExplosion:TTypeExplosion;X,Y : integer);
begin
  fTypeExplosion := ATypeExplosion;
  case fTypeExplosion of
  Type1 : inherited Create('MEDIA/Explosion/Explosion1.bmp',64,64);
  Type2 : inherited Create('MEDIA/Explosion/Explosion2.bmp',64,64);
  end;

  SetCoord(X,Y);
  IndexFrames:=0;
  // vitesse maxi
  fSpeedAnim:=-1;
  fSpeedCount:=0;
end;

procedure TExplosion.CheckAlpha;
begin
  inc(fSpeedCount,1);
  if(fSpeedCount >= fSpeedAnim) then begin
      IndexFrames:=IndexFrames + 1;
      fSpeedCount :=0;
      if IndexFrames>NumberOfFrames-2 then Kill;
  end;
  Alpha := 255-Round(IndexFrames * ( 255 / (NumberOfFrames-1)));
end;

procedure TExplosion.Draw;
begin
  CheckAlpha;
  inherited Draw;
end;


end.
 