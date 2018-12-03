type
  TGLImageHelper = class helper for TGLImage
    procedure Draw3x3Batched(const DrawRects: PFloatRectangleArray; const Count: Integer;
      const CornerTop, CornerRight, CornerBottom, CornerLeft: Single);
  end;

procedure TGLImageHelper.Draw3x3Batched(const DrawRects: PFloatRectangleArray; const Count: Integer;
   const CornerTop, CornerRight, CornerBottom, CornerLeft: Single);
var
  ScreenRects, ImageRects: packed array of TFloatRectangle;
  DrawAddCount: Cardinal;

  { Add the quad to draw to ScreenRects, ImageRects.
    This looks and behaves like TGLImageCore.Draw,
    but the actual drawing is delayed to later. }
  procedure DrawAdd(const X, Y, DrawWidth, DrawHeight: Single;
    const ImageX, ImageY, ImageWidth, ImageHeight: Single);
  begin
    ScreenRects[DrawAddCount] := FloatRectangle(X, Y, DrawWidth, DrawHeight);
    ImageRects[DrawAddCount] := FloatRectangle(ImageX, ImageY, ImageWidth, ImageHeight);
    Inc(DrawAddCount);
  end;

var
  XScreenLeft, XScreenRight, YScreenBottom, YScreenTop,
    HorizontalScreenSize, VerticalScreenSize: Single;
  XImageLeft, XImageRight, YImageBottom, YImageTop,
    HorizontalImageSize, VerticalImageSize: Single;
  EpsilonT, EpsilonR, EpsilonB, EpsilonL: Single;
  DrawCornerTop, DrawCornerRight, DrawCornerBottom, DrawCornerLeft: Single;

  I: Integer;
const
  { We tweak texture coordinates a little, to avoid bilinear filtering
    that would cause border colors to "bleed" over the texture inside.
    Something minimally > 0.5 is necessary. }
  Epsilon = 0.51;
begin
  DrawCornerTop    := CornerTop    * ScaleCorners;
  DrawCornerRight  := CornerRight  * ScaleCorners;
  DrawCornerBottom := CornerBottom * ScaleCorners;
  DrawCornerLeft   := CornerLeft   * ScaleCorners;

  DrawAddCount := 0;

  SetLength(ScreenRects, Count * 9);
  SetLength(ImageRects, Count * 9);

  {if not ( (    CornerLeft +     CornerRight <     Width) and
           (DrawCornerLeft + DrawCornerRight < DrawRects^[I].Width) and
           (    CornerBottom +     CornerTop <     Height) and
           (DrawCornerBottom + DrawCornerTop < DrawRects^[I].Height)) then
  begin
    if Log and not IgnoreTooLargeCorners then
      WritelnLog('TGLImageCore.Draw3x3', 'Image corners are too large to draw it: corners are %f %f %f %f, image size is %d %d, draw area size is %f %f',
        [CornerTop, CornerRight, CornerBottom, CornerLeft,
         Width, Height,
         DrawRects^[I].Width, DrawRects^[I].Height]);
    Exit;
  end; }

  XImageLeft := 0;
  XImageRight  :=         Width -     CornerRight;
  YImageBottom := 0;
  YImageTop  :=         Height -     CornerTop;
  for I := 0 to Pred(Count) do
  begin
    XScreenLeft := DrawRects^[I].Left;
    XScreenRight := DrawRects^[I].Left + DrawRects^[I].Width - DrawCornerRight;

    YScreenBottom := DrawRects^[I].Bottom;
    YScreenTop := DrawRects^[I].Bottom + DrawRects^[I].Height - DrawCornerTop;

    { setup rotations }
    {if Rotation <> 0 then
    begin
      UseScreenCenter := true; // only temporary for this Draw3x3 call
      ScreenCenterX := X + FCenterX * DrawWidth;
      ScreenCenterY := Y + FCenterY * DrawHeight;
    end;}

    { 4 corners }
    DrawAdd(XScreenLeft, YScreenBottom, DrawCornerLeft, DrawCornerBottom,
             XImageLeft,  YImageBottom,     CornerLeft,     CornerBottom);
    DrawAdd(XScreenRight, YScreenBottom, DrawCornerRight, DrawCornerBottom,
             XImageRight,  YImageBottom,     CornerRight,     CornerBottom);
    DrawAdd(XScreenRight, YScreenTop, DrawCornerRight, DrawCornerTop,
             XImageRight,  YImageTop,     CornerRight,     CornerTop);
    DrawAdd(XScreenLeft, YScreenTop, DrawCornerLeft, DrawCornerTop,
             XImageLeft,  YImageTop,     CornerLeft,     CornerTop);

    { 4 sides }
    HorizontalScreenSize := DrawRects^[I].Width - DrawCornerLeft - DrawCornerRight;
    HorizontalImageSize  :=     Width -     CornerLeft -     CornerRight;
    VerticalScreenSize := DrawRects^[I].Height - DrawCornerTop - DrawCornerBottom;
    VerticalImageSize  :=     Height -     CornerTop -     CornerBottom;

    DrawAdd(XScreenLeft + DrawCornerLeft, YScreenBottom, HorizontalScreenSize, DrawCornerBottom,
             XImageLeft +     CornerLeft,  YImageBottom,  HorizontalImageSize,     CornerBottom);
    DrawAdd(XScreenLeft + DrawCornerLeft, YScreenTop, HorizontalScreenSize, DrawCornerTop,
             XImageLeft +     CornerLeft,  YImageTop,  HorizontalImageSize,     CornerTop);

    DrawAdd(XScreenLeft, YScreenBottom + DrawCornerBottom, DrawCornerLeft, VerticalScreenSize,
             XImageLeft,  YImageBottom +     CornerBottom,     CornerLeft,  VerticalImageSize);
    DrawAdd(XScreenRight, YScreenBottom + DrawCornerBottom, DrawCornerRight, VerticalScreenSize,
             XImageRight,  YImageBottom +     CornerBottom,     CornerRight,  VerticalImageSize);

    { inside }
    if CornerLeft > 0   then EpsilonL := Epsilon else EpsilonL := 0;
    if CornerTop > 0    then EpsilonT := Epsilon else EpsilonT := 0;
    if CornerRight > 0  then EpsilonR := Epsilon else EpsilonR := 0;
    if CornerBottom > 0 then EpsilonB := Epsilon else EpsilonB := 0;

    DrawAdd(DrawRects^[I].Left + DrawCornerLeft           , DrawRects^[I].Bottom + DrawCornerBottom           , HorizontalScreenSize, VerticalScreenSize,
                    CornerLeft + EpsilonL,         CornerBottom + EpsilonB, HorizontalImageSize - (EpsilonL+EpsilonR), VerticalImageSize - (EpsilonT+EpsilonB));
  end;

  //Assert(DrawAddCount = Count * 9);
  Draw(@ScreenRects[0], @ImageRects[0], DrawAddCount);

  {UseScreenCenter := false;}
end;
