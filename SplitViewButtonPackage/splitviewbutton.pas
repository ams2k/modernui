unit SplitViewButton;

// Componente criado para uso com o TSplitViewUI
{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, LCLType, LCLIntf, Controls, Types, LMessages,
  LResources, ExtCtrls, StdCtrls, ImgList, Math;

type

  { TSplitViewButton }

  TSplitViewButton = class(TCustomControl)
  private
    FClickTimer: TTimer;
    FAlignment: TAlignment;
    FBorderColor: TColor;
    FCaption: String;
    FHover: Boolean;
    FHoverColor: TColor;
    FImageIndex: Integer;
    FImageLeftStart: Integer;
    FImages: TCustomImageList;
    FSeparatorColor: TColor;
    FShowRightArrow: Boolean;
    FSpacing: Integer;
    FTextColor: TColor;
    FUseGradient: Boolean;

    procedure AnimateClick(Sender: TObject);
    procedure SetAlignment(AValue: TAlignment);
    procedure SetBorderColor(AValue: TColor);
    procedure SetCaption(AValue: String);
    procedure SetHoverColor(AValue: TColor);
    procedure SetImageIndex(AValue: Integer);
    procedure SetImageLeftStart(AValue: Integer);
    procedure SetSeparatorColor(AValue: TColor);
    procedure SetShowRightArrow(AValue: Boolean);
    procedure SetSpacing(AValue: Integer);
    procedure SetUseGradient(AValue: Boolean);
    function LightenColor(AColor: TColor; Percent: Integer): TColor;
  protected
    procedure Paint; override;
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Anchors;
    property BorderStyle;
    property BorderWidth;
    property Color;
    property Cursor;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentColor;
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

    property Alignment: TAlignment read FAlignment write SetAlignment default taCenter;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clGray;
    property Caption: String read FCaption write SetCaption;
    property HoverColor: TColor read FHoverColor write SetHoverColor;
    property Images: TCustomImageList read FImages write FImages;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;
    property ImageLeftStart: Integer read FImageLeftStart write SetImageLeftStart default 4;
    property SeparatorColor: TColor read FSeparatorColor write SetSeparatorColor;
    property Spacing: Integer read FSpacing write SetSpacing;
    property TextColor: TColor read FTextColor write FTextColor;
    property UseGradient: Boolean read FUseGradient write SetUseGradient default False;
    property ShowRightArrow: Boolean read FShowRightArrow write SetShowRightArrow default False;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I splitviewbutton_icon.lrs}
  RegisterComponents('ModernUI',[TSplitViewButton]);
end;

constructor TSplitViewButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Align := alNone; //alTop;
  Alignment := taLeftJustify;
  BorderStyle := bsNone;
  Color := $2E2E2E;
  Font.Color := clWhite;
  Height := 40;
  Width := 100;
  TabStop := True;

  FBorderColor := $2E2E2E;
  FCaption := 'SplitViewButton';
  FImageIndex := -1;
  FImageLeftStart := 4;
  FHover := False;
  FHoverColor := clSkyBlue;
  FSeparatorColor := $4E4E4E;//RGBToColor(255, 216, 60);
  FSpacing := 8;
  FUseGradient := False;
  FShowRightArrow := False;

  //animação no click
  FClickTimer := TTimer.Create(Self);
  FClickTimer.Enabled := False;
  FClickTimer.Interval := 50;
  FClickTimer.OnTimer := @AnimateClick;
end;

destructor TSplitViewButton.Destroy;
begin
  FClickTimer.Free;
  inherited Destroy;
end;

procedure TSplitViewButton.SetHoverColor(AValue: TColor);
begin
  if FHoverColor = AValue then Exit;
  FHoverColor := AValue;
  Invalidate;
end;

procedure TSplitViewButton.SetImageIndex(AValue: Integer);
//define o ícone
begin
  if FImageIndex = AValue then Exit;
  FImageIndex := AValue;
  Invalidate;
end;

procedure TSplitViewButton.SetImageLeftStart(AValue: Integer);
begin
  if FImageLeftStart = AValue then Exit;
  FImageLeftStart := AValue;
  Invalidate;
end;

procedure TSplitViewButton.SetSeparatorColor(AValue: TColor);
begin
  if FSeparatorColor = AValue then Exit;
  FSeparatorColor := AValue;
  Invalidate;
end;

procedure TSplitViewButton.SetShowRightArrow(AValue: Boolean);
begin
  if FShowRightArrow = AValue then Exit;
  FShowRightArrow := AValue;
  Invalidate;
end;

procedure TSplitViewButton.SetSpacing(AValue: Integer);
begin
  if FSpacing = AValue then Exit;
  FSpacing := AValue;
  Invalidate;
end;

procedure TSplitViewButton.SetUseGradient(AValue: Boolean);
begin
  if FUseGradient = AValue then Exit;
  FUseGradient := AValue;
  Invalidate;
end;

function TSplitViewButton.LightenColor(AColor: TColor; Percent: Integer): TColor;
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

procedure TSplitViewButton.MouseEnter;
begin
  inherited MouseEnter;

  FHover := True;

  Invalidate;
end;

procedure TSplitViewButton.MouseLeave;
begin
  inherited MouseLeave;

  FHover := False;

  Invalidate;
end;

procedure TSplitViewButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  Invalidate;
end;

procedure TSplitViewButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  Invalidate;
end;

procedure TSplitViewButton.Click;
begin
  FClickTimer.Enabled := True;
  Invalidate;
end;

procedure TSplitViewButton.AnimateClick(Sender: TObject);
//click cria um efeito no botão
begin
   FClickTimer.Enabled := False;
   Invalidate;
   inherited Click;
end;

procedure TSplitViewButton.SetAlignment(AValue: TAlignment);
begin
  if FAlignment = AValue then Exit;
  FAlignment := AValue;
  Invalidate;
end;

procedure TSplitViewButton.SetBorderColor(AValue: TColor);
begin
  if FBorderColor = AValue then Exit;
  FBorderColor := AValue;
  Invalidate;
end;

procedure TSplitViewButton.SetCaption(AValue: String);
begin
  if FCaption = AValue then Exit;
  FCaption := AValue;
  Invalidate;
end;

procedure TSplitViewButton.Paint;
var
  R: TRect;
  Color1, Color2: TColor;
  iLimite: Integer;
  IconTop, TextTop, TotalHeight: Integer;
  bIconVisible: Boolean;
  TextSize: TSize;
  IconSpace, IconW, IconH: Integer;
  ContentLeft: Integer;
  P: array[0..2] of TPoint;
  CentroY, X1, X2: Integer;
begin
  Canvas.Font := Font;
  Canvas.Brush.Style := bsSolid;
  R := ClientRect;
  iLimite := 0;

  // Cor de fundo conforme posição do mouse no objeto
  if FHover then
    Canvas.Brush.Color := FHoverColor
  else
    Canvas.Brush.Color := Color;

  // cor de fundo
  if FUseGradient and not FHover  then begin
    // gradiente de fundo do botão
    Color1 := Color;
    Color2 := LightenColor(Color, 55);

    // Desenha o gradiente
    R := Rect(iLimite, 0, Width, Height-1);
    Canvas.Pen.Style := psSolid;
    Canvas.GradientFill(R, Color1, Color2, gdVertical);
  end else begin
    // fundo sem gradiente
    R := Rect(iLimite, 0, Width, Height-1);
    Canvas.Brush.Style := bsSolid;
    Canvas.Pen.Style := psSolid;
    Canvas.FillRect(R);
  end;

  //separador
  R := Rect(iLimite, Height-1, Width, Height);
  Canvas.Brush.Color := FSeparatorColor;
  Canvas.Brush.Style := bsSolid;
  Canvas.Pen.Style := psSolid;
  Canvas.FillRect(R);

  R := ClientRect;

  bIconVisible := Assigned(FImages) and (FImageIndex >= 0);
  IconW := 0;
  IconH := 0;

  if Assigned(FImages) and (FImageIndex >= 0) then begin
    IconW := FImages.Width;
    IconH := FImages.Height;
  end;

  IconSpace := IfThen(bIconVisible, IconW + 4, 0); // espaço reservado para ícone

  // Texto
  TextSize := Canvas.TextExtent(FCaption);
  TotalHeight := Max(TextSize.cy, IconH);

  // Alinhamento horizontal
  case FAlignment of
    taLeftJustify: ContentLeft := 2 + FImageLeftStart; //distanciamento da esquerda
    taCenter: ContentLeft := (Width - (TextSize.cx + IconSpace)) div 2;
    taRightJustify: ContentLeft := Width - (TextSize.cx + IconSpace);
  end;

  // Alinhamento vertical
  TextTop := (Height - TotalHeight) div 2 + 1;

  //clicou no botão, aplica efeito de mousedown
  if FClickTimer.Enabled then begin
    TextTop := TextTop + 3;
    ContentLeft := ContentLeft + 4;
  end;

  // Ícone
  if bIconVisible then begin
    IconTop := TextTop + (TextSize.cy - IconW) div 2 + 1;

    if Assigned(FImages) and (FImageIndex >= 0) and (FImageIndex < FImages.Count) then
      FImages.Draw(Canvas, ContentLeft, IconTop, FImageIndex, True);
  end;

  // Texto
  if (FCaption <> '') then begin
    Canvas.Brush.Style := bsClear;
    Canvas.TextOut(ContentLeft + IconSpace + FSpacing, TextTop, FCaption);
  end;

  // seta à direita
  if FShowRightArrow then begin
    R := ClientRect;
    // calcular posição no final do botão
    CentroY := (R.Top + R.Bottom) div 2; // meio vertical
    X2 := R.Right - 6;                   // 6 pixels antes do fim
    X1 := X2 - 6;                        // largura da seta (6 px)

    // pontos do triângulo apontando para a direita
    P[0] := Point(X1, CentroY-4); // ponta superior
    P[1] := Point(X1, CentroY+4); // ponta inferior
    P[2] := Point(X2, CentroY);   // ponta direita

    Canvas.Brush.Color := Font.Color;
    Canvas.Pen.Style := psClear; // sem contorno
    Canvas.Polygon(P);
  end;
end;

end.
