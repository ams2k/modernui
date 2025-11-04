unit ButtonRetro;

// Botão ao estilo do visual basic 4

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, ImgList, LResources, LCLType, LCLIntf,
  LMessages, Forms;

type

  TImagePosition = (ipLeft, ipRight, ipTop, ipBottom, ipCenter);

  { TButtonRetro }


    TButtonRetro = class(TCustomControl)
    private
      FDown: Boolean;
      FHoverColor: TColor;
      FHover: Boolean;
      FMouseOver: Boolean;
      FFocused: Boolean;
      FFlatStyle: Boolean;
      FImageList: TImageList;
      FImageIndex: Integer;
      FImagePosition: TImagePosition;
      procedure SetHoverColor(AValue: TColor);
      procedure SetImageList(AValue: TImageList);
      procedure SetImageIndex(AValue: Integer);
      procedure SetFlatStyle(AValue: Boolean);
      procedure SetImagePosition(AValue: TImagePosition);
    protected
      procedure Paint; override;
      procedure MouseEnter; override;
      procedure MouseLeave; override;
      procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
      procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
      procedure DoEnter; override;
      procedure DoExit; override;
      procedure KeyDown(var Key: Word; Shift: TShiftState); override;
      procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    public
      constructor Create(AOwner: TComponent); override;
    published
      property Align;
      property Anchors;
      property Caption;
      property Color;
      property Enabled;
      property Font;
      property ParentFont;
      property ParentColor;
      property PopupMenu;
      property ShowHint;
      property TabOrder;
      property TabStop;
      property Visible;
      property OnClick;
      property OnEnter;
      property OnExit;
      property OnMouseDown;
      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseMove;
      property OnMouseUp;

      property FlatStyle: Boolean read FFlatStyle write SetFlatStyle default False;
      property ImageList: TImageList read FImageList write SetImageList;
      property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;
      property ImagePosition: TImagePosition read FImagePosition write SetImagePosition default ipLeft;
      property HoverColor: TColor read FHoverColor write SetHoverColor;
    end;
procedure Register;

implementation

procedure Register;
begin
  {$I buttonretro_icon.lrs}
  RegisterComponents('ModernUI',[TButtonRetro]);
end;

{ TButtonRetro }

constructor TButtonRetro.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents, csSetCaption, csDoubleClicks];
  Width := 80;
  Height := 28;
  FHover := False;
  FHoverColor := clSkyBlue;
  TabStop := True;
  FImageIndex := -1;
  FImagePosition := ipLeft;
  Color := clBtnFace;
end;

procedure TButtonRetro.SetImageList(AValue: TImageList);
begin
  FImageList := AValue;
  Invalidate;
end;

procedure TButtonRetro.SetHoverColor(AValue: TColor);
begin
  if FHoverColor = AValue then Exit;
  FHoverColor := AValue;
  Invalidate;
end;

procedure TButtonRetro.SetImageIndex(AValue: Integer);
begin
  if FImageIndex <> AValue then
  begin
    FImageIndex := AValue;
    Invalidate;
  end;
end;

procedure TButtonRetro.SetFlatStyle(AValue: Boolean);
begin
  if FFlatStyle <> AValue then
  begin
    FFlatStyle := AValue;
    Invalidate;
  end;
end;

procedure TButtonRetro.SetImagePosition(AValue: TImagePosition);
begin
  if FImagePosition <> AValue then
  begin
    FImagePosition := AValue;
    Invalidate;
  end;
end;

procedure TButtonRetro.Paint;
var
  R: TRect;
  Offset: Integer = 0;
  TextRect: TRect;
  ImgW, ImgH, ImgX, ImgY, TxtX, TxtY: Integer;
  FaceColor: TColor;
begin
  R := ClientRect;

  if FHover then
    FaceColor := FHoverColor
  else
    FaceColor := Color;

  //fundo
  Canvas.Brush.Color := FaceColor;
  Canvas.FillRect(R);

  R.Top := R.Top + 1;
  R.Left := R.Left + 1;
  R.Right := R.Right - 1;
  R.Bottom := R.Bottom - 1;

  if not FFlatStyle then
  begin
    if FDown then
      //DrawEdge(Canvas.Handle, R, EDGE_SUNKEN, BF_RECT)
      Frame3d(Canvas.Handle, R, 3, bvLowered)
    else
      //DrawEdge(Canvas.Handle, R, EDGE_RAISED, BF_RECT);
      Frame3d(Canvas.Handle, R, 3, bvRaised);
  end;

  InflateRect(R, -4, -4);

  if FDown then Offset := 1;

  Canvas.Font := Font;
  TextRect := R;

  ImgW := 0;
  ImgH := 0;
  if Assigned(FImageList) and (FImageIndex >= 0) then
  begin
    ImgW := FImageList.Width;
    ImgH := FImageList.Height;
  end;

  TxtX := R.Left + Offset;
  TxtY := R.Top + Offset;

  case FImagePosition of
    ipLeft:
      begin
        ImgX := R.Left + Offset;
        ImgY := R.Top + (R.Height - ImgH) div 2 + Offset;
        TxtX := ImgX + ImgW + 4;
        TxtY := R.Top + (R.Height - Canvas.TextHeight(Caption)) div 2 + Offset;
      end;
    ipRight:
      begin
        TxtX := R.Left + Offset;
        TxtY := R.Top + (R.Height - Canvas.TextHeight(Caption)) div 2 + Offset;
        ImgX := R.Right - ImgW - 4 + Offset;
        ImgY := R.Top + (R.Height - ImgH) div 2 + Offset;
      end;
    ipTop:
      begin
        ImgX := R.Left + (R.Width - ImgW) div 2 + Offset;
        ImgY := R.Top + Offset;
        TxtX := R.Left + (R.Width - Canvas.TextWidth(Caption)) div 2 + Offset;
        TxtY := ImgY + ImgH + 4;
      end;
    ipBottom:
      begin
        TxtX := R.Left + (R.Width - Canvas.TextWidth(Caption)) div 2 + Offset;
        TxtY := R.Top + Offset;
        ImgX := R.Left + (R.Width - ImgW) div 2 + Offset;
        ImgY := TxtY + Canvas.TextHeight(Caption) + 4;
      end;
    ipCenter:
      begin
        if ImgW > 0 then
        begin
          ImgX := R.Left + (R.Width - ImgW) div 2 + Offset;
          ImgY := R.Top + (R.Height - ImgH) div 2 + Offset;
        end;
        TxtX := R.Left + (R.Width - Canvas.TextWidth(Caption)) div 2 + Offset;
        TxtY := R.Top + (R.Height - Canvas.TextHeight(Caption)) div 2 + Offset;
      end;
  end;

  if (FImageList <> nil) and (FImageIndex >= 0) then
    FImageList.Draw(Canvas, ImgX, ImgY, FImageIndex, Enabled);

  //borda
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Color := clBlack;
  Canvas.Rectangle(ClientRect);

  Canvas.TextOut(TxtX, TxtY, Caption);

  //focus?
  if FFocused and Enabled then begin
    R := ClientRect;
    R.Top := R.Top + 5;
    R.Left := R.Left + 5;
    R.Right := R.Right - 5;
    R.Bottom := R.Bottom - 5;

    Canvas.Pen.Style := psDot;
    Canvas.Pen.Color := clGray;
    Canvas.Rectangle(R);
  end;

  //if FFocused then
    //DrawFocusRect(Canvas.Handle, R);
end;

procedure TButtonRetro.MouseEnter;
begin
  inherited MouseEnter;
  FHover := FHoverColor <> clNone;
  Invalidate;
end;

procedure TButtonRetro.MouseLeave;
begin
  inherited MouseLeave;
  FHover := False;
  Invalidate;
end;

procedure TButtonRetro.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbLeft then begin
    FDown := True;
    Invalidate;
  end;
end;

procedure TButtonRetro.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button = mbLeft then begin
    FDown := False;
    Invalidate;
    Click;
  end;
end;

procedure TButtonRetro.DoEnter;
begin
  inherited DoEnter;
  FFocused := True;
  Invalidate;
end;

procedure TButtonRetro.DoExit;
begin
  inherited DoExit;
  FFocused := False;
  Invalidate;
end;

procedure TButtonRetro.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_SPACE) or (Key = VK_RETURN) then
  begin
    FDown := True;
    Invalidate;
  end;
end;

procedure TButtonRetro.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  if (Key = VK_SPACE) or (Key = VK_RETURN) then
  begin
    FDown := False;
    Invalidate;
    Click;
  end;
end;

end.


