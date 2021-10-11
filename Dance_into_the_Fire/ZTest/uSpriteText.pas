unit uSpriteText;

interface
uses Windows, Messages, SysUtils, Variants, Classes, Graphics,uSprite;

type
  TStyleText = (Normal , Bold , Italic );
  TAlignementText = (Left , Center , Right );

  TSpriteText = class(TSprite)
  private
    fText : String;
    fStyle : TStyleText;
    fPos : TAlignementText;
    tX,tY : integer;

    fLen : integer;
    procedure SetText(AText:String);
    procedure SetAlignement(AAlignement : TAlignementText);
    procedure SetStyle(AStyle : TStyleText);
  public
    property Style : TStyleText read fStyle write SetStyle;
    property Alignement :TAlignementText read fPos write SetAlignement;
    property Text :String read fText write SetText;
    constructor Create(AText : String);
    procedure Draw;override;
  end;


implementation
{ - TSpriteText ---------------------------------------------------------- }
constructor TSpriteText.Create(AText : String);
var
  Bmp : TBitmap;
begin
  inherited Create;

  Bmp := TBitmap.Create;

  fLen := Length(AText);
  Bmp.Width := fLen * 7;
  Bmp.Height := 30;
  tY:=Bmp.Height div 4 ;

  Bmp.Transparent:=True;
  Bmp.TransparentColor:=DEFAULT_TRANSPARENT_COLOR;

  inherited Create(Bmp,Bmp.Width,Bmp.Height);
  Tag := INVINCIBLE;
  SetAlignement(Left);
  SetText(AText);
  Bmp.Free;

end;
procedure TSpriteText.SetAlignement(AAlignement : TAlignementText);
begin
  fPos := AAlignement;
  case fPos of
    Left : tX:=0;
    Center : tX := Bitmap.Width div 4;
    Right : tX := Bitmap.Width div 2 ;
  end;
end;


procedure TSpriteText.SetText(AText:String);
begin
  fText:=AText;
  fLen := Length(fText);
  Bitmap.Width := fLen * 7;
  if (Bitmap.Transparent) then begin
    Bitmap.Canvas.Brush.Color:=Bitmap.TransparentColor;
    Bitmap.Canvas.FillRect(Bitmap.Canvas.ClipRect);
  end;
  Bitmap.Canvas.TextOut(tX,tY,fText);
end;

procedure TSpriteText.SetStyle(AStyle : TStyleText);
begin
  fStyle := AStyle;
end;

procedure TSpriteText.Draw;
begin
  Canvas.Draw(Coord.X,Coord.Y,Bitmap);
end;

end.
  
