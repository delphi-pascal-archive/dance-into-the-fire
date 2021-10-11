unit uSprite;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,Contnrs;

const
  DEFAULT_TRANSPARENT_COLOR = $ff00ff;
  // Resiste au KILL utiliser ForceKill pr le détruire quand même
  INVINCIBLE = 2147483647;
  ALL = 0;
  // sans groupe
  OTHER = -1;
  
type
  T3dPoint = record
    X,Y,Z : integer;
  end;
  TSpriteList = class;
  { - TSprite ---------------------------------------------------------- }

  TSprite = class(TObject)

  private
    fTag : Longint;
    fParentList : TSpriteList;

    fCanvas : TCanvas;
    isEnable : boolean;
    fClientRect : TRect;

    fBitmap : TBitmap;
    fBlend : BLENDFUNCTION;
    fSupportAlphaBlend : boolean;

    fRect : TRect;
    fDestRect : TRect;
    fShadowBitmap : TBitmap;
    fCoordShadow : TPoint;
    isShadow : boolean;
    fCoord : T3dPoint;
    fWidth , fHeight : integer;
    fNumberOfFrames : integer;
    fNbframeX,fNbFrameY : integer;
    fIndexFrames : integer;

    fSpeed       : single;
    fDirection   : single;
    _SpCosMul    : integer;
    _SpSinMul    : integer;

    isDead : boolean;

    procedure MAJDestRect;
    procedure SetIndexFrames (AIndexFrames : integer);
    procedure SetParentList(AParentList : TSpriteList);

    procedure SetAlpha (AOpaque : byte);
    function GetAlpha : byte;

    procedure SetBitmap (ABitmap : TBitmap);
    procedure MakeShadow;
    procedure SetCanvas (ACanvas : TCanvas);

    procedure SetSingle(index : integer; val : single);
    procedure Move;
    procedure ComputeSPD;
    procedure SetTag (ATag : longint);

    constructor Create;overload;
  public
    property ParentList : TSpriteList read fParentList;
    property Canvas : TCanvas read fCanvas write SetCanvas;
    property ClientRect : TRect read fClientRect write fClientRect;
    property Bitmap : TBitmap read fBitmap write SetBitmap;
    property Alpha : byte read GetAlpha write SetAlpha;
    property NumberOfFrames : integer read fNumberOfFrames;
    property IndexFrames : integer read fIndexFrames write SetIndexFrames;
    property Shadow : boolean read isShadow write isShadow;
    property Coord : T3dPoint read fCoord;
    property Rect : TRect read fRect;
    property DestRect : TRect read fDestRect;
    property Width : integer read fWidth;
    property Height : integer read fHeight;
    property Speed       : single  index 0 read fSpeed       write SetSingle;
    property Direction   : single  index 1 read fDirection   write SetSingle;
    property Dead : boolean read isDead;
    property Tag : longint read fTag write SetTag;

    procedure Kill;
    procedure ForceKill ;
    function  isCollide (ASprite : TSprite) : boolean;
    procedure SetCoord (APoint : TPoint);overload;
    procedure SetCoord (X,Y : integer);overload;
    procedure SetZCoord(Z : integer);
    procedure  SetCoordShadow (X,Y : integer);
    destructor Destroy;override;

    procedure Progress;virtual;
    procedure Draw;virtual;

    constructor Create(ABitmap : TBitmap ; AWidth,AHeight : integer);overload;
    constructor Create(AFileName : TFileName;AWidth,AHeight : integer);overload;
  end;

  { - TSpriteList ---------------------------------------------------------- }
  TSpriteList = class(TObjectList)
  protected
    function  Get( Index : Integer ) : TSprite;
    procedure Put( Index : Integer; Item : TSprite );
  public
    property Items[ Index : Integer ] : TSprite read Get write Put; default;
    constructor Create;
  end;

  { - TSpriteEngine ---------------------------------------------------------- }
  TSpriteEngine = class(TObject)
  private
    fCanvas : TCanvas;
    fBackground : TBitmap;
    isBackgroundLoad : boolean;
    isLock : boolean ;
    isEnable : boolean;
    fClientRect : TRect;
    ListSprites : TSpriteList;
    isNeedSort : boolean;
    isTransparent : boolean;
    fTransparentColor : TColor;
    isSupportAlphaBlend : boolean;

    isAutoCapacity : boolean;
    fTag : longint;

    procedure SetCanvas(ACanvas : TCanvas );

    procedure SetClientRect(AClientRect : TRect);
    function  GetMaxSprite : integer;
    procedure SetTransparentColor (ATransparentColor : TColor);
    procedure SetTransparent(Transparent : boolean);
    function GetCapacity : integer;
    procedure SortZSprites; // trié sur z
  public
    property Sort : boolean read isNeedSort write isNeedSort;
    property Transparent : boolean read isTransparent write SetTransparent;
    property TransparentColor : TColor read fTransparentColor write SetTransparentColor;

    property CountSprite : integer read GetMaxSprite;
    property AutoCapacity : boolean read isAutoCapacity  write isAutoCapacity;
    property Capacity : integer read GetCapacity;
    property Canvas : TCanvas read fCanvas write SetCanvas;
    property ClientRect : TRect read fClientRect write SetClientRect;
    property Tag :longint read fTag write fTag;

    property SupportAlphaBlend : boolean read isSupportAlphaBlend;

    procedure SetBackground(ABackground : TBitmap);overload;
    procedure SetBackground(FileName : String);overload;
    
    procedure Clear;overload;
    procedure Clear (ForceKill : boolean);overload;
    procedure RemoveKillSprite;
    procedure AddSprite( Item : TSprite );
    procedure RemoveSprite( Item : TSprite );
    procedure Move;
    procedure Lock;
    procedure Unlock;
    procedure Draw;

    constructor Create(ACanvas : TCanvas;AClientRect : TRect);
    destructor Destroy;override;
  end;


implementation

uses Math,Jpeg,uMain;




procedure PreMultiply(aBmp: TBitmap);
var PData       : PRGBQuad;
  I, BytesTotal : Integer;
begin
  BytesTotal := aBMP.Width * aBMP.Height;
  If aBmp.PixelFormat = pf32Bit then
  begin
    PData := aBMP.ScanLine[aBMP.Height-1];
    for I := 0 to BytesTotal - 1 do
    begin
      with PData^ do
      begin
      // préparation des pixels avant l'appel a AlphaBlend
      // http://msdn.microsoft.com/en-us/library/ms532306(VS.85).aspx
        RGBRed := (RGBRed * rgbReserved) div 255;
        RGBGreen := (RGBGreen * rgbReserved) div 255;
        RGBBlue := (RGBBlue * rgbReserved) div 255;
      end;
      Inc(PData);
    end;
  end;
end;

{ - TSprite ---------------------------------------------------------- }
constructor TSprite.Create;
begin
  inherited Create;
  fBitmap := TBitmap.Create;

  fBlend.BlendOp:=AC_SRC_OVER;
  fBlend.BlendFlags:=0;
  SetAlpha(255);

  fShadowBitmap := TBitmap.Create;

  isShadow:=false;
  SetCoord(0,0);
  fCoord.Z:=-1;
  SetCoordShadow(1,1);
  SetIndexFrames(0);
  Tag := OTHER;

end;

constructor TSprite.Create(ABitmap : TBitmap;AWidth,AHeight : integer);
begin
  self.Create;
  fWidth:=AWidth;
  fHeight:=AHeight;
  SetBitmap(ABitmap);
end;

constructor TSprite.Create(AFileName : TFileName;AWidth,AHeight : integer);
var
  ext : String;
  jpg : TJpegImage;
  Bmp : TBitmap;
begin
  self.Create;

  fWidth:=AWidth;
  fHeight:=AHeight;

  Bmp := TBitmap.Create;
  jpg := TJpegImage.Create;

  ext := UpperCase(ExtractFileExt(AFileName));

  if(ext = '.BMP') then Bmp.LoadFromFile(AFileName)
  else begin
    if(ext = '.JPG') or (ext='.JPEG') then begin
      jpg.LoadFromFile(AFileName);
      Bmp.Assign(jpg);
    end else
    // format inconnu
    MessageBox(0,'Format non supporté !','Erreur Format',MB_OK);
  end;
  SetBitmap(Bmp);
  jpg.Free;
  Bmp.Free;
end;

destructor TSprite.Destroy;
begin
  fBitmap.Free;
  fShadowBitmap.Free;
  inherited Destroy;
end;

procedure TSprite.SetTag (ATag : longint);
begin
  if ATag<>ALL then fTag := ATag;
end;

procedure TSprite.SetParentList(AParentList : TSpriteList);
begin
  fParentList := AParentList;
end;

procedure TSprite.SetCanvas (ACanvas : TCanvas);
begin
  fCanvas := ACanvas;
  isEnable := Assigned(fCanvas);
end;

function TSprite.GetAlpha : byte;
begin
  result := fBlend.AlphaFormat;
end;

procedure TSprite.SetAlpha(AOpaque : byte);
begin
  fBlend.SourceConstantAlpha:=AOpaque;
end;

procedure TSprite.SetBitmap(ABitmap : TBitmap);
begin
  fBitmap.Assign(ABitmap);

  fNbframeX:=fBitmap.Width div fWidth;
  fNbFrameY:=fBitmap.Height div fHeight;

  fNumberOfFrames :=fNbframeX*fNbframeY;
  SetIndexFrames(fIndexFrames);
  MakeShadow;
end;

procedure TSprite.MakeShadow;
begin
  fShadowBitmap.Assign(Bitmap);
  fShadowBitmap.Mask(Bitmap.TransparentColor);
end;

procedure TSprite.SetIndexFrames (AIndexFrames : integer);
var
  posX : integer;
  pX : integer;
  posY : integer;
begin
  fIndexFrames :=AIndexFrames;

  if(fIndexFrames<0) then fIndexFrames:=0;
  if(fIndexFrames>fNumberOfFrames-1) then fIndexFrames:=fNumberOfFrames-1;

  posX:=fWidth*fIndexFrames;
  posY:=0;

  if(fIndexFrames>=fNbFrameX) then begin

    posY:=(posX div fBitmap.Width)*fHeight;
    
    pX:=(fIndexFrames+1) mod fNbFrameX;
    if(pX=0) then
      posX:=(fNbFrameX-1)*fWidth
    else
      posX:=((pX)-1) *fWidth ;

  end;
  
  with fRect do begin
    Left := posX;
    Right :=posX+fWidth;
    Top:=posY;
    Bottom := posY+fHeight;
  end;
end;

procedure TSprite.SetCoordShadow (X,Y : integer);
begin
  fCoordShadow.X:=X;
  fCoordShadow.Y:=Y;
end;

procedure TSprite.ComputeSPD;
var ST,CT : extended;
begin
  SinCos(fDirection,ST,CT);
  _SpCosMul := round(fSpeed * CT);
  _SpSinMul := round(fSpeed * ST);
end;

procedure TSprite.SetSingle(index : integer; val : single);
begin
  case index of
    0 : fSpeed     := val;
    1 : fDirection := DegToRad(val);
  end;
  ComputeSPD;
end;

function TSprite.isCollide(ASprite : TSprite):boolean;
var
  Dummy:TRect;
begin
  Result:=IntersectRect(Dummy,fDestRect,ASprite.DestRect);
end;

procedure TSprite.Kill;
begin
  if fTag<>INVINCIBLE then isDead:=True;
end;

procedure TSprite.ForceKill;
begin
  isDead:=True;
end;
procedure TSprite.MAJDestRect;
begin
  fDestRect.Left := fCoord.X;
  fDestRect.Right := fCoord.X + fWidth;
  fDestRect.Top := fCoord.Y;
  fDestRect.Bottom := fCoord.Y + fHeight;
end;

procedure TSprite.SetCoord(APoint : TPoint);
begin
  fCoord.X := APoint.X;
  fCoord.Y := APoint.Y;
  MAJDestRect;
end;

procedure TSprite.SetCoord (X,Y : integer);
begin
  fCoord.X := X;
  fCoord.Y := Y;
  MAJDestRect;
end;

procedure TSprite.SetZCoord(Z : integer);
begin
  fCoord.Z := Z;
end;


procedure TSprite.Move;
var
x,y : integer;
p : TPoint;
begin
  x := fCoord.X;
  y := fCoord.Y;
  x := x + _SpCosMul;
  y := y + _SpSinMul;
  p.X := x;
  p.Y := y;
  SetCoord(P);
end;

procedure TSprite.Progress;
begin
  Move;
end;

procedure TSprite.Draw;
begin
  if not isEnable then exit;
  
  with fCanvas do begin
    if isShadow then
      TransparentBlt(fcanvas.Handle,fDestRect.Left+fCoordShadow.X,fDestRect.Top+fCoordShadow.Y,fWidth,fHeight,fShadowBitmap.Canvas.Handle,fRect.Left,fRect.Top,fWidth,fHeight,fShadowBitmap.TransparentColor);

    if not Bitmap.Transparent then
      CopyRect(fDestRect,fBitmap.Canvas,fRect)
    else begin
      if fSupportAlphaBlend then
        AlphaBlend(fcanvas.Handle,fDestRect.Left,fDestRect.Top,fWidth,fHeight,fBitmap.Canvas.Handle,fRect.Left,fRect.Top,fWidth,fHeight,fBlend)
      else
        TransparentBlt(fcanvas.Handle,fDestRect.Left,fDestRect.Top,fWidth,fHeight,fBitmap.Canvas.Handle,fRect.Left,fRect.Top,fWidth,fHeight,fBitmap.TransparentColor);
    end;

  end;
end;

{ - TSpriteList ---------------------------------------------------------- }
constructor TSpriteList.Create;
begin
  inherited Create(True);
end;

function TSpriteList.Get( Index : Integer ) : TSprite;
begin
  Result := inherited Get( Index );
end;

procedure TSpriteList.Put( Index : Integer; Item : TSprite );
begin
  inherited Put( Index, Item );
end;

{ - TSpriteEngine ---------------------------------------------------------- }

constructor TSpriteEngine.Create(ACanvas : TCanvas;AClientRect : TRect);
begin
  inherited Create;
  fBackground := TBitmap.Create;

  ListSprites := TSpriteList.Create;
  SetCanvas(ACanvas);
  isBackgroundLoad:=false;
  Unlock;

  fClientRect:=AClientRect;
  SetTransparent(True);

  SetTransparentColor(DEFAULT_TRANSPARENT_COLOR);
  isAutoCapacity := True;
  Tag := ALL;
  
  // msdn : Device does not support any of these capabilities.
  if  GetDeviceCaps(ACanvas.Handle,SHADEBLENDCAPS)= 0 then
    isSupportAlphaBlend := false
  else
    isSupportAlphaBlend := true;

  isSupportAlphaBlend := true;
  isNeedSort:=false;
end;

destructor TSpriteEngine.Destroy;
begin
  Clear;
  ListSprites.Free;
  fBackground.Free;
  inherited Destroy;
end;

procedure TSpriteEngine.SetTransparentColor (ATransparentColor : TColor);
var
  i : integer;
begin
  fTransparentColor:=ATransparentColor;
  for i:=0 to GetMaxSprite -1 do
    ListSprites.Items[i].Bitmap.TransparentColor:=fTransparentColor;
end;

procedure TSpriteEngine.SetTransparent(Transparent : boolean);
var
  i : integer;
begin
  isTransparent:=Transparent;
  for i:=0 to GetMaxSprite -1 do
    ListSprites.Items[i].Bitmap.Transparent:=Transparent;
end;

procedure TSpriteEngine.SetBackground (ABackground : TBitmap);
begin
  fBackground.Assign(ABackground);
  isBackgroundLoad:=True;
end;

procedure TSpriteEngine.SetBackground (FileName : String);
var
  ext : String;
  jpg : TJpegImage;
  Bmp : TBitmap;
begin
  jpg := TJpegImage.Create;
  Bmp := TBitmap.Create;

  ext := UpperCase(ExtractFileExt(FileName));
  if(ext = '.BMP') then fBackground.LoadFromFile(FileName)
  else begin
    if(ext = '.JPG') or (ext='.JPEG') then begin
      jpg.LoadFromFile(FileName);
      Bmp.Assign(jpg);
    end else
    // format inconnu
    MessageBox(0,'Format non supporté !','Erreur Format',MB_OK);
  end;

  fBackground.Assign(Bmp);
  isBackgroundLoad:=True;
  jpg.Free;
  Bmp.Free;
end;

procedure TSpriteEngine.SortZSprites;
  function CompareZ( Item1, Item2 : TSprite ) : Integer;
  begin
    if Item1.Coord.Z < Item2.Coord.Z then
      Result := -1
    else if Item1.Coord.Z > Item2.Coord.Z then
      Result := 1
    else
      Result := 0;
  end;
begin
  ListSprites.Sort( @CompareZ );
end;

procedure TSpriteEngine.AddSprite( Item : TSprite );
var
  pPix : pRGBQuad;
  x : integer;
begin
  Item.SetCanvas(fCanvas);
  Item.fSupportAlphaBlend := isSupportAlphaBlend;

  if Item.Bitmap.PixelFormat<>pf32bit then begin
    Item.Bitmap.PixelFormat := pf32bit;
    if(isSupportAlphaBlend) then begin
      Item.fBlend.AlphaFormat:=AC_SRC_ALPHA;
      pPix := Item.Bitmap.ScanLine[Item.Bitmap.Height - 1];
      for x:=0 to Item.Bitmap.Width * Item.Bitmap.Height - 1 do begin
        if RGB(pPix^.rgbRed,pPix^.rgbGreen,pPix^.rgbBlue) = DEFAULT_TRANSPARENT_COLOR then
          pPix^.rgbReserved:=0
        else
          pPix^.rgbReserved:=255;
        inc (pPix);
      end;
      PreMultiply(Item.Bitmap);
    end;
  end
  else
    Item.fBlend.AlphaFormat:=AC_SRC_ALPHA;

  Item.ClientRect := fClientRect;
  Item.SetParentList(ListSprites);
  Item.Bitmap.Transparent:=isTransparent;
  Item.Bitmap.TransparentColor:=fTransparentColor;
  ListSprites.Add(Item);
  isNeedSort:=true;
end;

procedure TSpriteEngine.RemoveSprite( Item : TSprite );
begin
  ListSprites.Remove(TSprite(Item));
end;

function TSpriteEngine.GetMaxSprite : integer;
begin
  result := ListSprites.Count;
end;

procedure TSpriteEngine.Move;
var
  i : integer;
begin
  if not isEnable then exit;
  if ListSprites.Count < 0 then exit;

  for i:=0 to GetMaxSprite-1 do begin
    if not ListSprites.Items[i].Dead then ListSprites.Items[i].Progress;
  end;

  if isNeedSort then
  begin
    SortZSprites;
    isNeedSort := false;
  end;

end;

procedure TSpriteEngine.Lock;
begin
  isLock := true;
end;

procedure TSpriteEngine.Unlock;
begin
  isLock := false;
end;

procedure TSpriteEngine.Draw;
var
  i: integer;
begin
  if not isEnable then exit;
  if ListSprites.Count < 0 then exit;
  MainForm.Fps;
  if islock then exit;
  if(isBackgroundLoad) then fCanvas.StretchDraw(fClientRect,fBackground);
  for i := 0 to GetMaxSprite - 1 do begin
    if not ListSprites.Items[i].Dead then begin
      if fTag = ALL then ListSprites[i].Draw else
       begin
        if ListSprites.Items[i].Tag = fTag then ListSprites[i].Draw;
       end;
    end;
  end;
end;

procedure TSpriteEngine.SetClientRect(AClientRect : TRect);
var
  i : integer;
begin
  fClientRect := AClientRect;
  for i:=0 to GetMaxSprite-1 do
    ListSprites.Items[i].ClientRect:=fClientRect;
end;

procedure TSpriteEngine.SetCanvas(ACanvas : TCanvas );
begin
  fCanvas := ACanvas;
  isEnable:=Assigned(fCanvas);
end;

procedure TSpriteEngine.Clear (ForceKill : boolean);
var
  i : integer;
begin
  if ForceKill then begin
      for i:=0 to GetMaxSprite-1 do begin
        ListSprites.Items[i].ForceKill;
      end;
      RemoveKillSprite;
  end else
    Clear;
end;

procedure TSpriteEngine.Clear;
var
  i : integer;
begin
  for i:=0 to GetMaxSprite-1 do begin
    ListSprites.Items[i].Kill;
  end;
  RemoveKillSprite;
end;



procedure TSpriteEngine.RemoveKillSprite;
var
  i,max : integer;
begin
  max :=GetMaxSprite;
  // cfr http://www.delphifr.com/forum/sujet-TOBJECTLIST-REMOVE_1261196.aspx?p=2
  // rt15
  for i:= (max - 1) downto 0 do begin
    if ListSprites.Items[i].isDead then ListSprites.Remove(ListSprites.Items[i]);
  end;

  if isAutoCapacity then ListSprites.Capacity := ListSprites.Count;
end;

function TSpriteEngine.GetCapacity : integer;
begin
  result := ListSprites.Capacity;
end;

end.
