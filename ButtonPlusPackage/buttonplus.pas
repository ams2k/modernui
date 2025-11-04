unit ButtonPlus;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, LCLType, LCLIntf, Controls, Types, LMessages,
  LResources, ExtCtrls, StdCtrls, ImgList, Math;

type
  TButtonPlusStyle = (mbsPrimary, mbsSuccess, mbsDanger, mbsFlat, mbsOutlined, mbsNormal);

  { TButtonPlus }

  TButtonPlus = class(TCustomControl)
  private
    FIcon: TPicture;
    FIconBackColor: TColor;
    FImage: TImage;

    FBlinkTimer: TTimer;
    FBlinkState: Boolean;
    FBlinkCount: Integer;
    FBlinkMaxCount: Integer;
    FBlinkInterval: Integer;
    FBlinkDuration: Integer;

    FBorderEnabled: Boolean;
    FBorderLineStyle: TPenStyle;
    FBorderLineWidth: Integer;
    FIconStretch: Boolean;
    FIconTransparent: Boolean;
    FIconVisible: Boolean;
    FIconWidth: Integer;
    FImageIndex: Integer;
    FImages: TCustomImageList;
    FStyle: TButtonPlusStyle;
    FHover: Boolean;
    FCaption: String;
    FSpacing: Integer;
    FCornerRadius: Integer;
    FTextColor: TColor;
    FBorderColor: TColor;
    FColorMouseIn: TColor;
    FColorMouseOut: TColor;
    FCaptionAlignment: TAlignment;
    FUseGradient: Boolean;

    procedure DoBlink(Sender: TObject);
    procedure SetBorderEnabled(AValue: Boolean);
    procedure SetBorderLineStyle(AValue: TPenStyle);
    procedure SetBorderLineWidth(AValue: Integer);
    procedure SetCaption(const AValue: String);
    procedure SetColorMouseIn(AValue: TColor);
    procedure SetColorMouseOut(AValue: TColor);
    procedure SetIconBackColor(AValue: TColor);
    procedure SetIconStretch(AValue: Boolean);
    procedure SetIconTransparent(AValue: Boolean);
    procedure SetIconVisible(AValue: Boolean);
    procedure SetIconWidth(AValue: Integer);
    procedure SetImageIndex(AValue: Integer);
    procedure SetStyle(const AValue: TButtonPlusStyle);
    procedure SetIcon(const AValue: TPicture);
    procedure SetCornerRadius(AValue: Integer);
    procedure SetCaptionAlignment(AValue: TAlignment);
    procedure SetUseGradient(AValue: Boolean);
    procedure UpdateStyleColors;
    procedure IconChanged(Sender: TObject);
    function IsCharWord(ch: char): boolean;
    function IsCharHex(ch: char): boolean;
    function HTMLColorToRGB(AHtmlColor: String): TColor;
    function LightenColor(AColor: TColor; Percent: Integer): TColor;
  protected
    procedure Paint; override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Click; override;

    procedure ImageClick(Sender: TObject);
    procedure ImageMouseEnter(Sender: TObject);
    procedure ImageMouseLeave(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Anchors;
    property Color;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentColor;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;

    property Caption: String read FCaption write SetCaption;
    property CaptionAlignment: TAlignment read FCaptionAlignment write SetCaptionAlignment;
    property Style: TButtonPlusStyle read FStyle write SetStyle default mbsFlat;

    property Images: TCustomImageList read FImages write FImages;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;

    property Icon: TPicture read FIcon write SetIcon;
    property IconVisible: Boolean read FIconVisible write SetIconVisible default True;
    property IconStretch: Boolean read FIconStretch write SetIconStretch default False;
    property IconWidth: Integer read FIconWidth write SetIconWidth default 30;
    property IconTransparent: Boolean read FIconTransparent write SetIconTransparent default False;
    property IconBackColor: TColor read FIconBackColor write SetIconBackColor default clWhite;

    property Spacing: Integer read FSpacing write FSpacing;
    property TextColor: TColor read FTextColor write FTextColor;
    property UseGradient: Boolean read FUseGradient write SetUseGradient default False;

    property BorderEnabled: Boolean read FBorderEnabled write SetBorderEnabled default True;
    property BorderColor: TColor read FBorderColor write FBorderColor default clGray;
    property BorderRadius: Integer read FCornerRadius write SetCornerRadius default 6;
    property BorderStyle: TPenStyle read FBorderLineStyle write SetBorderLineStyle default psSolid;
    property BorderWidth: Integer read FBorderLineWidth write SetBorderLineWidth default 1;

    property ColorMouseIn: TColor read FColorMouseIn write SetColorMouseIn;
    property ColorMouseOut: TColor read FColorMouseOut write SetColorMouseOut;
  end;

procedure Register;

implementation

{ TButtonPlus }

procedure Register;
begin
  {$I buttonplus_icon.lrs}
  RegisterComponents('ModernUI',[TButtonPlus]);
end;

constructor TButtonPlus.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Height := 32;
  Width := 100;
  Font.Color := clWhite;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
  TabStop := True;

  FBlinkInterval := 50; // ms
  FBlinkDuration := 200; // ms
  FBlinkTimer := TTimer.Create(Self);
  FBlinkTimer.Interval := 10;
  FBlinkTimer.Enabled := False;
  FBlinkTimer.OnTimer := @DoBlink;

  FCaption := 'Button Plus';
  FSpacing := 8;
  FCaptionAlignment := taCenter;
  FHover := False;
  FStyle := mbsPrimary;

  FImageIndex := -1;
  FIconTransparent := False;
  FIconVisible := True;
  FIconStretch := False;
  FIconWidth := 30;
  FIconBackColor := clWhite;

  FBorderEnabled := True;
  FBorderColor := $00BCBEBF;
  FCornerRadius := 0;
  FBorderLineStyle := psSolid;
  FBorderLineWidth := 1;
  FUseGradient := False;

  // icone da imagem à direita
  FIcon := TPicture.Create;
  FIcon.OnChange := @IconChanged;

  // imagem à direita
  FImage := TImage.Create(Self);
  FImage.Parent := Self;
  FImage.Width := FIconWidth;
  FImage.Align := alLeft;
  FImage.Anchors := [akTop, akLeft, akBottom];
  FImage.AnchorSideLeft.Side := asrBottom;
  FImage.AnchorSideRight.Side := asrBottom;
  FImage.AnchorSideBottom.Side := asrBottom;
  FImage.BorderSpacing.Left := 1;
  FImage.BorderSpacing.Top := 1;
  FImage.BorderSpacing.Right := 0;
  FImage.BorderSpacing.Bottom := 1;
  FImage.BorderSpacing.Around := 1;
  FImage.Center := True;
  FImage.Stretch := FIconStretch;
  FImage.Visible := FIconVisible;
  FImage.Transparent := FIconTransparent;
  FImage.OnClick := @ImageClick;
  FImage.OnMouseEnter := @ImageMouseEnter;
  FImage.OnMouseLeave := @ImageMouseLeave;

  UpdateStyleColors;
  Invalidate;
end;

destructor TButtonPlus.Destroy;
begin
  FIcon.Free;
  FreeAndNil(FImage);
  FBlinkTimer.Free;
  inherited Destroy;
end;

procedure TButtonPlus.SetCaption(const AValue: String);
begin
  if FCaption = AValue then Exit;
  FCaption := AValue;
  Invalidate;
end;

procedure TButtonPlus.SetColorMouseIn(AValue: TColor);
begin
  if FColorMouseIn = AValue then Exit;
  FColorMouseIn := AValue;
  Invalidate;
end;

procedure TButtonPlus.SetColorMouseOut(AValue: TColor);
begin
  if FColorMouseOut = AValue then Exit;
  FColorMouseOut := AValue;
  Invalidate;
end;

procedure TButtonPlus.SetIconBackColor(AValue: TColor);
begin
  if FIconBackColor = AValue then Exit;
  FIconBackColor := AValue;
  Invalidate;
end;

procedure TButtonPlus.SetBorderLineStyle(AValue: TPenStyle);
begin
  if FBorderLineStyle = AValue then Exit;
  FBorderLineStyle := AValue;
  Invalidate;
end;

procedure TButtonPlus.DoBlink(Sender: TObject);
begin
  Inc(FBlinkCount);
  FBlinkState := not FBlinkState;

  FHover := FBlinkState;

  Invalidate;

  if FBlinkCount * FBlinkInterval >= FBlinkDuration then begin
    FBlinkTimer.Enabled := False;
    Invalidate;
    inherited Click;
  end;
end;

procedure TButtonPlus.SetBorderEnabled(AValue: Boolean);
begin
  if FBorderEnabled = AValue then Exit;
  FBorderEnabled := AValue;
  Invalidate;
end;

procedure TButtonPlus.SetBorderLineWidth(AValue: Integer);
begin
  if FBorderLineWidth = AValue then Exit;
  FBorderLineWidth := AValue;
  Invalidate;
end;

procedure TButtonPlus.SetIconStretch(AValue: Boolean);
begin
  if FIconStretch = AValue then Exit;
  FIconStretch := AValue;
  Invalidate;
end;

procedure TButtonPlus.SetIconTransparent(AValue: Boolean);
begin
  if FIconTransparent = AValue then Exit;
  FIconTransparent := AValue;
  FImage.Transparent := AValue;
  Invalidate;
end;

procedure TButtonPlus.SetIconVisible(AValue: Boolean);
begin
  if FIconVisible = AValue then Exit;
  FIconVisible := AValue;
  FImage.Visible := FIconVisible;
  Invalidate;
end;

procedure TButtonPlus.SetIconWidth(AValue: Integer);
begin
  if FIconWidth = AValue then Exit;
  FIconWidth := AValue;
  FImage.Width := FIconWidth;
  Invalidate;
end;

procedure TButtonPlus.SetImageIndex(AValue: Integer);
var
  TempBitmap: TBitmap;
begin
  if FImageIndex = AValue then Exit;
  FImageIndex := AValue;

  if Assigned(FImages) and (FImageIndex >= 0) and (FImageIndex < FImages.Count) then begin
    TempBitmap := TBitmap.Create;
    try
      TempBitmap.SetSize(FImages.Width, FImages.Height);
      FImages.GetBitmap(FImageIndex, TempBitmap);
      FIcon.Assign(TempBitmap); // ou: FIcon.Bitmap := TempBitmap;
      Invalidate;
    finally
      TempBitmap.Free;
    end;
  end;
end;

procedure TButtonPlus.SetCaptionAlignment(AValue: TAlignment);
begin
  if FCaptionAlignment = AValue then Exit;
  FCaptionAlignment := AValue;
  Invalidate;
end;

procedure TButtonPlus.SetUseGradient(AValue: Boolean);
begin
  if FUseGradient = AValue then Exit;
  FUseGradient := AValue;
  Invalidate;
end;

procedure TButtonPlus.SetCornerRadius(AValue: Integer);
begin
  if FCornerRadius = AValue then Exit;
  if (AValue < 0) then AValue := 0;
  if (AValue > 12) then AValue := 12;
  FCornerRadius := AValue;
  Invalidate;
end;

procedure TButtonPlus.SetStyle(const AValue: TButtonPlusStyle);
begin
  if FStyle = AValue then Exit;
  FStyle := AValue;
  UpdateStyleColors;
  Invalidate;
end;

procedure TButtonPlus.SetIcon(const AValue: TPicture);
begin
  if Assigned(FIcon) then
    FIcon.Assign(AValue);
end;

procedure TButtonPlus.IconChanged(Sender: TObject);
begin
  if Assigned(FImage) then
    FImage.Picture := FIcon;

  Invalidate;
end;

procedure TButtonPlus.UpdateStyleColors;
begin
  case FStyle of
    mbsPrimary:
      begin
        FColorMouseOut := HTMLColorToRGB('#00aaff');// $007337F5;
        FColorMouseIn := HTMLColorToRGB('#0097e2');// $005A2DD0;
        FBorderColor := HTMLColorToRGB('#0000ff');// clNone;
        FTextColor := clWhite;
      end;
    mbsSuccess:
      begin
        FColorMouseOut := HTMLColorToRGB('#34eb61');// $0028A745;
        FColorMouseIn := HTMLColorToRGB('#2dce55');// $00218C3A;
        FBorderColor := HTMLColorToRGB('#005500');// clNone;
        FTextColor := clWhite;
      end;
    mbsDanger:
      begin
        FColorMouseOut := HTMLColorToRGB('#ff7462');// $00DC3545;
        FColorMouseIn := HTMLColorToRGB('#df6356');// $00B02B39;
        FBorderColor := HTMLColorToRGB('#aa0000');// clNone;
        FTextColor := clWhite;
      end;
    mbsFlat:
      begin
        FColorMouseOut := clNone;
        FColorMouseIn := $00E0E0E0;
        FBorderColor := clGray;
        FTextColor := clBlack;
      end;
    mbsOutlined:
      begin
        FColorMouseOut := $FFE6E6E6;
        FColorMouseIn := clNone;
        FBorderColor := $007337F5;
        FTextColor := $007337F5;
      end;
    mbsNormal:
      begin
        FColorMouseOut := HTMLColorToRGB('#dddddd');
        FColorMouseIn := HTMLColorToRGB('#bbbbbb');
        FBorderColor := HTMLColorToRGB('#707070');
        FTextColor := clBlack;
      end;
  end;
end;

function TButtonPlus.IsCharWord(ch: char): boolean;
// caracteres válidos
begin
  Result := ch in ['a'..'z', 'A'..'Z', '_', '0'..'9'];
end;

function TButtonPlus.IsCharHex(ch: char): boolean;
// caracteres válidos
begin
  Result := ch in ['0'..'9', 'a'..'f', 'A'..'F'];
end;

function TButtonPlus.HTMLColorToRGB(AHtmlColor: String): TColor;
// converte a cor no formato #00aaff para
//
// https://wiki.freepascal.org/Colors
//
var
  N1, N2, N3: integer;
  i, iLen: integer;
begin
  Result := clWhite;

  if (AHtmlColor <> '') and (AHtmlColor[1] = '#') then Delete(AHtmlColor, 1, 1);
  if (AHtmlColor = '') then exit;

  //delete after first nonword char
  i := 1;
  while (i <= Length(AHtmlColor)) and IsCharWord(AHtmlColor[i]) do Inc(i);
  Delete(AHtmlColor, i, Maxint);

  //permitido apenas #rgb, #rrggbb
  iLen := Length(AHtmlColor);
  if (iLen <> 3) and (iLen <> 6) then exit;

  for i := 1 to iLen do
    if not IsCharHex(AHtmlColor[i]) then exit;

  if iLen = 6 then begin
    // #AABBCC
    N1 := StrToInt('$' + Copy(AHtmlColor, 1, 2));
    N2 := StrToInt('$' + Copy(AHtmlColor, 3, 2));
    N3 := StrToInt('$' + Copy(AHtmlColor, 5, 2));
  end else
  begin
    // #ABC
    N1 := StrToInt('$' + AHtmlColor[1] + AHtmlColor[1]);
    N2 := StrToInt('$' + AHtmlColor[2] + AHtmlColor[2]);
    N3 := StrToInt('$' + AHtmlColor[3] + AHtmlColor[3]);
  end;

  Result := RGBToColor(N1, N2, N3);
end;

function TButtonPlus.LightenColor(AColor: TColor; Percent: Integer): TColor;
// retorna uma cor com um percentual da cor indicada em AColor
var
  R, G, B: Integer;
begin
  R := GetRValue(AColor);
  G := GetGValue(AColor);
  B := GetBValue(AColor);

  R := Round(R + (255 - R) * (Percent / 100));
  G := Round(G + (255 - G) * (Percent / 100));
  B := Round(B + (255 - B) * (Percent / 100));

  Result := RGBToColor(R, G, B);
end;

procedure TButtonPlus.MouseEnter;
begin
  inherited MouseEnter;

  FHover := True;

  Invalidate;
end;

procedure TButtonPlus.MouseLeave;
begin
  inherited MouseLeave;

  FHover := False;

  Invalidate;
end;

procedure TButtonPlus.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  Invalidate;
end;

procedure TButtonPlus.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  Invalidate;
end;

procedure TButtonPlus.Click;
begin
  // Iniciar piscada
  FBlinkCount := 0;
  FBlinkState := False;
  FBlinkTimer.Interval := FBlinkInterval;
  FBlinkMaxCount := FBlinkDuration div FBlinkInterval;
  FBlinkTimer.Enabled := True;

  //inherited Click;
end;

procedure TButtonPlus.ImageClick(Sender: TObject);
begin
  // Iniciar piscada
  FBlinkCount := 0;
  FBlinkState := False;
  FBlinkTimer.Interval := FBlinkInterval;
  FBlinkMaxCount := FBlinkDuration div FBlinkInterval;
  FBlinkTimer.Enabled := True;

  //inherited Click;
end;

procedure TButtonPlus.ImageMouseEnter(Sender: TObject);
begin
  inherited MouseEnter;

  FHover := True;

  Invalidate;
end;

procedure TButtonPlus.ImageMouseLeave(Sender: TObject);
begin
  inherited MouseLeave;

  FHover := False;

  Invalidate;
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

procedure TButtonPlus.Paint;
var
  R: TRect;
  Color1, Color2: TColor;
  iLimite: Integer;
begin
  Canvas.Font := Font;
  Canvas.Brush.Style := bsSolid;
  R := ClientRect;
  iLimite := 0;

  // pinta o fundo da área do ícone
  if (FIconVisible) and (FIconWidth > 0) and (not FIconTransparent) then begin
    iLimite := FImage.Left + FIconWidth + 1;
    R.Right := iLimite;
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := FIconBackColor;
    Canvas.FillRect(R);
    R := ClientRect;
    R.Left := iLimite;
  end;

  // Cor de fundo conforme posição do mouse no objeto
  if FHover then
    Canvas.Brush.Color := FColorMouseIn
  else
    Canvas.Brush.Color := FColorMouseOut;

  // cor de fundo
  if (FUseGradient) and (not FHover) and (FColorMouseOut <> clNone) then begin
    // gradiente de fundo dos títulos
    Color1 := FColorMouseOut;
    Color2 := LightenColor(FColorMouseOut, 55);

    // Desenha o gradiente
    R := Rect(iLimite, 0, Width - 1, Height - 1);
    Canvas.Pen.Style := psSolid;
    Canvas.GradientFill(R, Color1, Color2, gdVertical);
  end else begin
    // fundo sem gradiente
    R := Rect(iLimite, 0, Width - 1, Height - 1);
    Canvas.Brush.Style := bsSolid;
    Canvas.Pen.Style := psSolid;
    Canvas.FillRect(R);
  end;

  // Definição de borda
  if FStyle = mbsOutlined then begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Style := FBorderLineStyle;
    Canvas.Pen.Color := FTextColor;
    Canvas.Pen.Width := FBorderLineWidth;
  end
  else if FBorderEnabled then begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Style := FBorderLineStyle;
    Canvas.Pen.Color := FBorderColor;
    Canvas.Pen.Width := FBorderLineWidth;
  end;

  // pinta a borda
  R := ClientRect;

  if FCornerRadius > 0 then
    Canvas.RoundRect(R, FCornerRadius, FCornerRadius)
  else
    Canvas.Rectangle(R);

  // para o texto
  if FIconVisible then
    R.Left := 4 + FImage.Width + FSpacing
  else
    R.Left := 8;

  R.Right := Width - 1;
  // Texto
  Canvas.Font.Color := FTextColor;
  Canvas.Brush.Style := bsClear;
  DrawCaptionText(Canvas, R, FCaption, FCaptionAlignment);
end;

end.
