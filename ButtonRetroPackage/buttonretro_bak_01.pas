unit ButtonRetro;

// Botão ao estilo do visual basic 4

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LResources, LCLType, LMessages, Forms;

type
  TButtonTheme = (vbClassic, vbDark);

  { TButtonRetro }

  TButtonRetro = class(TCustomControl)
  private
    FCaption: string;
    FImage: TPicture;
    FPressed: Boolean;
    FFocused: Boolean;
    FFlat: Boolean;
    FTheme: TButtonTheme;
    FHover: Boolean;
    FHoverColor: TColor;
    FBorderColor: TColor;
    procedure SetCaption(const AValue: string);
    procedure SetImage(const AValue: TPicture);
    procedure SetFlat(const AValue: Boolean);
    procedure SetTheme(const AValue: TButtonTheme);
    procedure SetHoverColor(const AValue: TColor);
    procedure SetBorderColor(const AValue: TColor);
    procedure UpdateColors;
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
    procedure DrawButton(ACanvas: TCanvas; OffsetX, OffsetY: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Caption: string read FCaption write SetCaption;
    property Image: TPicture read FImage write SetImage;
    property Flat: Boolean read FFlat write SetFlat default False;
    property Theme: TButtonTheme read FTheme write SetTheme default vbClassic;
    property HoverColor: TColor read FHoverColor write SetHoverColor;
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property Align;
    property Anchors;
    property Enabled;
    property Font;
    property Color;
    property ParentFont;
    property ParentColor;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property TabOrder;
    property TabStop;
    property OnClick;
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
  Width := 100;
  Height := 30;
  FImage := TPicture.Create;
  FCaption := 'Button';
  FFlat := False;
  FTheme := vbClassic;
  FHover := False;
  FHoverColor := clSkyBlue;
  FBorderColor := clBtnShadow;
  UpdateColors;
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csDoubleClicks, csSetCaption, csCaptureMouse];
  TabStop := True;
end;

destructor TButtonRetro.Destroy;
begin
  FImage.Free;
  inherited Destroy;
end;

procedure TButtonRetro.SetCaption(const AValue: string);
begin
  if FCaption <> AValue then
  begin
    FCaption := AValue;
    Invalidate;
  end;
end;

procedure TButtonRetro.SetImage(const AValue: TPicture);
begin
  FImage.Assign(AValue);
  Invalidate;
end;

procedure TButtonRetro.SetFlat(const AValue: Boolean);
begin
  if FFlat <> AValue then
  begin
    FFlat := AValue;
    Invalidate;
  end;
end;

procedure TButtonRetro.SetTheme(const AValue: TButtonTheme);
begin
  if FTheme <> AValue then
  begin
    FTheme := AValue;
    UpdateColors;
    Invalidate;
  end;
end;

procedure TButtonRetro.SetHoverColor(const AValue: TColor);
begin
  FHoverColor := AValue;
  Invalidate;
end;

procedure TButtonRetro.SetBorderColor(const AValue: TColor);
begin
  FBorderColor := AValue;
  Invalidate;
end;

procedure TButtonRetro.UpdateColors;
begin
  case FTheme of
    vbClassic:
      begin
        Color := clBtnFace;
        Font.Color := clBlack;
      end;
    vbDark:
      begin
        Color := clBlack;
        Font.Color := clWhite;
      end;
  end;
end;

procedure TButtonRetro.DrawButton(ACanvas: TCanvas; OffsetX, OffsetY: Integer);
var
  R: TRect;
  TextPos, ImgPos: TPoint;
  FaceColor: TColor;
begin
  R := Rect(0, 0, Width, Height);

  if FHover then
    FaceColor := FHoverColor
  else
    FaceColor := Color;

  ACanvas.Brush.Color := FaceColor;
  ACanvas.FillRect(R);

  if not FFlat then begin
    if FPressed then
    begin
      ACanvas.Pen.Color := clBtnShadow;
      ACanvas.MoveTo(R.Left, R.Bottom - 1);
      ACanvas.LineTo(R.Left, R.Top);
      ACanvas.LineTo(R.Right - 1, R.Top);

      ACanvas.Pen.Color := clBtnHighlight;
      ACanvas.MoveTo(R.Right - 1, R.Top + 1);
      ACanvas.LineTo(R.Right - 1, R.Bottom - 1);
      ACanvas.LineTo(R.Left + 1, R.Bottom - 1);
    end
    else
    begin
      ACanvas.Pen.Color := clBtnHighlight;
      ACanvas.MoveTo(R.Left, R.Bottom - 1);
      ACanvas.LineTo(R.Left, R.Top);
      ACanvas.LineTo(R.Right - 1, R.Top);

      ACanvas.Pen.Color := clBtnShadow;
      ACanvas.MoveTo(R.Right - 1, R.Top + 1);
      ACanvas.LineTo(R.Right - 1, R.Bottom - 1);
      ACanvas.LineTo(R.Left + 1, R.Bottom - 1);
    end;
  end
  else
  begin
    ACanvas.Pen.Color := FBorderColor;
    ACanvas.Rectangle(R);
  end;

  ACanvas.Brush.Style := bsClear;
  ACanvas.Font := Font;
  TextPos := Point(Width div 2 - ACanvas.TextWidth(FCaption) div 2,
                   Height div 2 - ACanvas.TextHeight(FCaption) div 2);

  if Assigned(FImage.Graphic) then
  begin
    ImgPos := Point(5, Height div 2 - FImage.Height div 2);
    ACanvas.Draw(ImgPos.X, ImgPos.Y, FImage.Graphic);
    Inc(TextPos.X, FImage.Width + 5);
  end;

  ACanvas.TextOut(TextPos.X, TextPos.Y, FCaption);
end;

procedure TButtonRetro.Paint;
var
  OffsetX, OffsetY: Integer;
begin
  inherited Paint;

  if FPressed then begin
    OffsetX := 1;
    OffsetY := 1;
  end
  else begin
    OffsetX := 0;
    OffsetY := 0;
  end;

  DrawButton(Canvas, OffsetX, OffsetY);
end;

procedure TButtonRetro.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  FPressed := True;
  Invalidate;
end;

procedure TButtonRetro.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  FPressed := False;
  Invalidate;
  Click;
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
    FPressed := True;
    Invalidate;
  end;
end;

procedure TButtonRetro.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  if (Key = VK_SPACE) or (Key = VK_RETURN) then
  begin
    FPressed := False;
    Invalidate;
    Click;
  end;
end;

procedure TButtonRetro.MouseEnter;
begin
  inherited MouseEnter;
  FHover := True;
  Invalidate;
end;

procedure TButtonRetro.MouseLeave;
begin
  inherited MouseLeave;
  FHover := False;
  Invalidate;
end;

end.
