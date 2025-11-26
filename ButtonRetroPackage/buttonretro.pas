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
      FCaptionAlignment: TAlignment;
      FMouseDown: Boolean;
      FHoverColor: TColor;
      FHover: Boolean;
      FMouseOver: Boolean;
      FFocused: Boolean;
      FFlatStyle: Boolean;
      FImageList: TImageList;
      FImageIndex: Integer;
      FImagePosition: TImagePosition;
      procedure SetCaptionAlignment(AValue: TAlignment);
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
      property CaptionAlignment: TAlignment read FCaptionAlignment write SetCaptionAlignment;
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
  FFlatStyle := False;
  FHover := False;
  FHoverColor := clSkyBlue;
  TabStop := True;
  FImageIndex := -1;
  FImagePosition := ipLeft;
  Color := $00D6D6D6; //clBtnFace; //$00B9B9B9 (VB6) //$00D6D6D6 (um pouco mais claro)
  FCaptionAlignment := taCenter;
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

procedure TButtonRetro.SetCaptionAlignment(AValue: TAlignment);
begin
  if FCaptionAlignment = AValue then Exit;
  FCaptionAlignment := AValue;
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
    FMouseDown := True;
    Invalidate;
  end;
end;

procedure TButtonRetro.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button = mbLeft then begin
    FMouseDown := False;
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
    FMouseDown := True;
    Invalidate;
  end;
end;

procedure TButtonRetro.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  if (Key = VK_SPACE) or (Key = VK_RETURN) then
  begin
    FMouseDown := False;
    Invalidate;
    Click;
  end;
end;

procedure DrawCaptionText(ACanvas: TCanvas; ARect: TRect; const AText: string;
                          Alignment: TAlignment; AVertCenter: Boolean = True);
var
  Flags: Cardinal;
begin
  Flags := DT_SINGLELINE or DT_NOPREFIX;

  case Alignment of
    taLeftJustify:  Flags := Flags or DT_LEFT;
    taRightJustify: Flags := Flags or DT_RIGHT;
    taCenter:       Flags := Flags or DT_CENTER;
  end;

  if AVertCenter then
    Flags := Flags or DT_VCENTER;

  DrawText(ACanvas.Handle, PChar(AText), -1, ARect, Flags);
end;

procedure TButtonRetro.Paint;
var
  R: TRect;
  Offset: Integer;
  ImgW, ImgH, ImgX, ImgY, dx, dy: Integer;
  FaceColor: TColor;
begin
  R  := ClientRect;
  Offset := 0;
  dx := 4;
  dy := 4;

  if FHover then
    FaceColor := FHoverColor
  else
    FaceColor := Color;

  //fundo
  Canvas.Brush.Color := FaceColor;
  Canvas.FillRect(R);

  R.Top    := R.Top + 1;
  R.Left   := R.Left + 1;
  R.Right  := R.Right - 1;
  R.Bottom := R.Bottom - 1;

  if not FFlatStyle then
  begin
    if FMouseDown then
      //DrawEdge(Canvas.Handle, R, EDGE_SUNKEN, BF_RECT)
      Frame3d(Canvas.Handle, R, 3, bvLowered)
    else
      //DrawEdge(Canvas.Handle, R, EDGE_RAISED, BF_RECT);
      Frame3d(Canvas.Handle, R, 3, bvRaised);
  end;

  InflateRect(R, -dx, -dy);

  if FMouseDown then Offset := 1;

  if FFlatStyle then
  begin
    dx := 0;
    dy := 0;
  end;

  Canvas.Font := Font;

  //posicionamento do ícone
  if Assigned(FImageList) and (FImageIndex >= 0) then
  begin
    ImgW := FImageList.Width;
    ImgH := FImageList.Height;

    case FImagePosition of
      ipLeft: //centralizado a esquerda do botão
        begin
          ImgX := R.Left + Offset;
          ImgY := R.Top + (R.Height - ImgH) div 2 + Offset;
          R.Left := R.Left + ImgW + Offset * 2;
          R.Top  := R.Top + Offset * 2;
        end;
      ipRight: //centralizado a direita do botão
        begin
          ImgX := R.Right - ImgW - Offset;
          ImgY := R.Top + (R.Height - ImgH) div 2 + Offset;
          R.Right := R.Right - ImgW - Offset * 2;
          R.Top   := R.Top + Offset * 2;
        end;
      ipTop: //centralizado no topo do botão (ok)
        begin
          ImgX := R.Left + (R.Width - ImgW) div 2;
          ImgY := R.Top + Offset;
          R.Top := R.Top + ImgH + dy + Offset;
          FCaptionAlignment := taCenter;
        end;
      ipBottom: //centralizado na base do botão (ok)
        begin
          ImgX := R.Left + (R.Width - ImgW) div 2;
          ImgY := R.Bottom - ImgH + Offset;
          R.Bottom := R.Bottom - ImgH + Offset;
          R.Top := R.Top + Offset;
          FCaptionAlignment := taCenter;
        end;
      ipCenter: //no centro do botão
        begin
          ImgX := R.Left + (R.Width - ImgW) div 2 + Offset;
          ImgY := R.Top + (R.Height - ImgH) div 2 + Offset;
          R.Top := R.Top + Offset * 2;
          R.Left := R.Left + Offset;
          FCaptionAlignment := taCenter;
        end;
    end; //case

    FImageList.Draw(Canvas, ImgX, ImgY, FImageIndex, Enabled)
  end
  else begin
    R.Top  := R.Top  + Offset * 2;
    R.Left := R.Left + Offset;
  end; //if

  //borda
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;

  if FFocused then
    Canvas.Pen.Color := clBlack
  else
    Canvas.Pen.Color := $00707070;

  Canvas.Rectangle(ClientRect);

  //Canvas.TextOut(TxtX, TxtY, Caption);
  DrawCaptionText(Canvas, R, Caption, FCaptionAlignment);

  //focus?
  if (FFocused and Enabled) then
  begin
    R := ClientRect;
    R.Top := R.Top + dy + 1;
    R.Left := R.Left + dx + 1;
    R.Right := R.Right - dx - 1;
    R.Bottom := R.Bottom - dy - 1;

    Canvas.Pen.Style := psDot;
    Canvas.Pen.Color := clGray;
    Canvas.Rectangle(R);
  end;

  //if FFocused then
    //DrawFocusRect(Canvas.Handle, R);
end;

end.


