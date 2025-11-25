unit ToggleButtonPlus;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Graphics, LCLType, LCLIntf, Controls, Types, LMessages,
  LResources, ExtCtrls, StdCtrls, Math;

{ TToggleButtonPlus }

type
  TToggleEvent = procedure(Sender: TObject; var Allow: Boolean) of object;

  TToggleStyle = (mbsPrimary, mbsSuccess, mbsDanger, mbsFlat, mbsOutlined);

  TToggleButtonPlus = class(TCustomControl)
  private
    FBackgroundColor: TColor;
    FBorderLineWidth: Integer;
    FOnChange: TNotifyEvent;
    FOnBeforeToggle: TToggleEvent;
    FOnAfterToggle: TNotifyEvent;
    FStyle: TToggleStyle;
    FToggleBorder: Boolean;
    FToggleBorderColor: TColor;
    FToggleBorderStyle: TPenStyle;

    FToggleColorArea: TColor;
    FToggleColorOn: TColor;
    FToggleColorOff: TColor;

    FBorderEnabled: Boolean;
    FBorderLineStyle: TPenStyle;
    FBorderColor: TColor;
    FBorderRadius: Integer;

    FCaption: String;
    FChecked: Boolean;

    FEnableAnimation: Boolean;
    FAnimTimer: TTimer;
    FAnimPos: Integer;
    FAnimDirection: Integer;

    procedure SetBackgroundColor(AValue: TColor);
    procedure SetStyle(AValue: TToggleStyle);
    procedure SetToggleBorder(AValue: Boolean);
    procedure SetToggleBorderColor(AValue: TColor);
    procedure SetToggleBorderStyle(AValue: TPenStyle);
    procedure SetToggleColorArea(AValue: TColor);
    procedure SetToggleColorOn(AValue: TColor);
    procedure SetToggleColorOff(AValue: TColor);

    procedure SetBorderEnabled(AValue: Boolean);
    procedure SetBorderLineStyle(AValue: TPenStyle);
    procedure SetBorderColor(AValue: TColor);
    procedure SetBorderLineWidth(AValue: Integer);
    procedure SetBorderRadius(AValue: Integer);

    procedure SetCaption(AValue: String);
    procedure SetChecked(AValue: Boolean);

    procedure SetEnableAnimation(AValue: Boolean);
    procedure AnimStep(Sender: TObject);
    procedure BeginAnimation(NewState: Boolean);

    procedure UpdateStyleColors;
    function IsCharWord(ch: char): boolean;
    function IsCharHex(ch: char): boolean;
    function HTMLColorToRGB(AHtmlColor: String): TColor;
    function LightenColor(AColor: TColor; Percent: Integer): TColor;
  protected
    procedure Paint; override;
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Anchors;
    property Enabled;
    property Font;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnBeforeToggle: TToggleEvent read FOnBeforeToggle write FOnBeforeToggle;
    property OnAfterToggle: TNotifyEvent read FOnAfterToggle write FOnAfterToggle;

    property Checked: Boolean read FChecked write SetChecked default False;
    property Caption: String read FCaption write SetCaption;

    property ToggleColorOn: TColor read FToggleColorOn write SetToggleColorOn default clLime;
    property ToggleColorOFf: TColor read FToggleColorOff write SetToggleColorOff default clGray;
    property ToggleColorArea: TColor read FToggleColorArea write SetToggleColorArea default clSkyBlue;
    property ToggleBorder: Boolean read FToggleBorder write SetToggleBorder default True;
    property ToggleBorderColor: TColor read FToggleBorderColor write SetToggleBorderColor default clGray;
    property ToggleBorderStyle: TPenStyle read FToggleBorderStyle write SetToggleBorderStyle default psSolid;
    property ToggleAnimation: Boolean read FEnableAnimation write SetEnableAnimation default True;

    property BorderEnabled: Boolean read FBorderEnabled write SetBorderEnabled default True;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clGray;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 6;
    property BorderStyle: TPenStyle read FBorderLineStyle write SetBorderLineStyle default psSolid;
    property BorderWidth: Integer read FBorderLineWidth write SetBorderLineWidth default 1;

    property Style: TToggleStyle read FStyle write SetStyle default mbsPrimary;
    property BackGroundColor: TColor read FBackgroundColor write SetBackgroundColor default clDefault;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I togglebuttonplus_icon.lrs}
  RegisterComponents('ModernUI',[TToggleButtonPlus]);
end;

{ TToggleButtonPlus }

constructor TToggleButtonPlus.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 100;
  Height := 25;
  FChecked := False;
  FCaption := 'Toggle Button';

  FToggleColorOn := clLime;
  FToggleColorOff := clBtnFace;
  FToggleColorArea := clSkyBlue;
  FToggleBorder := True;
  FToggleBorderColor := clGray;
  FToggleBorderStyle := psSolid;

  FBorderEnabled := True;
  FBorderColor := clGray;
  FBorderRadius := 6;
  FBorderLineStyle := psSolid;
  FBorderLineWidth := 1;

  FStyle := mbsPrimary;
  FBackgroundColor := clDefault;

  FEnableAnimation := True;
  FAnimTimer := TTimer.Create(Self);
  FAnimTimer.Enabled := False;
  FAnimTimer.Interval := 15;
  FAnimTimer.OnTimer := @AnimStep;

  FAnimPos := 100;

  UpdateStyleColors;
  Invalidate;
end;

destructor TToggleButtonPlus.Destroy;
begin
  FAnimTimer.Free;
  inherited Destroy;
end;

procedure TToggleButtonPlus.SetEnableAnimation(AValue: Boolean);
begin
  if FEnableAnimation = AValue then Exit;
  FEnableAnimation := AValue;
end;

procedure TToggleButtonPlus.BeginAnimation(NewState: Boolean);
var
  Allow: Boolean;
begin
  Allow := True;

  if Assigned(FOnBeforeToggle) then
    FOnBeforeToggle(Self, Allow);

  if not Allow then Exit;

  FAnimDirection := IfThen(NewState, -1, 1);
  FAnimPos := IfThen(NewState, 100, 0);
  FAnimTimer.Enabled := True;
end;

procedure TToggleButtonPlus.AnimStep(Sender: TObject);
begin
  Inc(FAnimPos, FAnimDirection * 10);
  if (FAnimPos < 0) or (FAnimPos > 100) then
  begin
    FAnimTimer.Enabled := False;
    FChecked := FAnimDirection < 0;
    if Assigned(FOnChange) then FOnChange(Self);
    if Assigned(FOnAfterToggle) then FOnAfterToggle(Self);
    FAnimPos := EnsureRange(FAnimPos, 0, 100);
  end;
  Invalidate;
end;

procedure TToggleButtonPlus.UpdateStyleColors;
begin
  case FStyle of
    mbsPrimary:
      begin
        FToggleColorOn := HTMLColorToRGB('#00aaff');
        FToggleColorOff := clBtnFace;
        FToggleColorArea := clSkyBlue;
        FToggleBorder := True;
        FToggleBorderColor := HTMLColorToRGB('#0085c8');
        FToggleBorderStyle := psSolid;

        FBorderEnabled := True;
        FBorderColor := clGray;
        FBorderRadius := 6;
        FBorderLineStyle := psSolid;
        FBorderLineWidth := 1;
        FBackgroundColor := clDefault;
      end;
    mbsSuccess:
      begin
        FToggleColorOn := clLime;
        FToggleColorOff := clBtnFace;
        FToggleColorArea := clWhite;
        FToggleBorder := True;
        FToggleBorderColor := HTMLColorToRGB('#699e00');
        FToggleBorderStyle := psSolid;

        FBorderEnabled := True;
        FBorderColor := clGray;
        FBorderRadius := 6;
        FBorderLineStyle := psSolid;
        FBorderLineWidth := 1;
        FBackgroundColor := clDefault;
      end;
    mbsDanger:
      begin
        FToggleColorOn := HTMLColorToRGB('#ffaa00');
        FToggleColorOff := clBtnFace;
        FToggleColorArea := clWhite;
        FToggleBorder := True;
        FToggleBorderColor := HTMLColorToRGB('#d18b00');;
        FToggleBorderStyle := psSolid;

        FBorderEnabled := True;
        FBorderColor := clGray;
        FBorderRadius := 6;
        FBorderLineStyle := psSolid;
        FBorderLineWidth := 1;
        FBackgroundColor := clDefault;
      end;
    mbsFlat:
      begin
        FToggleColorOn := clWhite;
        FToggleColorOff := clGray;
        FToggleColorArea := HTMLColorToRGB('#e3e3e3');
        FToggleBorder := False;
        FToggleBorderColor := HTMLColorToRGB('#888888');;
        FToggleBorderStyle := psSolid;

        FBorderEnabled := False;
        FBorderColor := clGray;
        FBorderRadius := 6;
        FBorderLineStyle := psSolid;
        FBorderLineWidth := 1;
        FBackgroundColor := clDefault;
      end;
    mbsOutlined:
      begin
        FToggleColorOn := $FFE6E6E6;
        FToggleColorOff := clGray;
        FToggleColorArea := HTMLColorToRGB('#e3e3e3');
        FToggleBorder := False;
        FToggleBorderColor := HTMLColorToRGB('#888888');;
        FToggleBorderStyle := psSolid;

        FBorderEnabled := True;
        FBorderColor := $007337F5;;
        FBorderRadius := 6;
        FBorderLineStyle := psSolid;
        FBorderLineWidth := 1;
        FBackgroundColor := clDefault;
      end;
  end;
end;

function TToggleButtonPlus.IsCharWord(ch: char): boolean;
// caracteres válidos
begin
  Result := ch in ['a'..'z', 'A'..'Z', '_', '0'..'9'];
end;

function TToggleButtonPlus.IsCharHex(ch: char): boolean;
// caracteres válidos
begin
  Result := ch in ['0'..'9', 'a'..'f', 'A'..'F'];
end;

function TToggleButtonPlus.HTMLColorToRGB(AHtmlColor: String): TColor;
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

function TToggleButtonPlus.LightenColor(AColor: TColor; Percent: Integer): TColor;
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

procedure TToggleButtonPlus.SetChecked(AValue: Boolean);
begin
  if FChecked = AValue then Exit;
  if FEnableAnimation then
    BeginAnimation(AValue)
  else
  begin
    FChecked := AValue;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TToggleButtonPlus.SetToggleColorOn(AValue: TColor);
begin
   if FToggleColorOn = AValue then Exit;
  FToggleColorOn := AValue;
  Invalidate;
end;

procedure TToggleButtonPlus.SetToggleColorOff(AValue: TColor);
begin
  if FToggleColorOff = AValue then Exit;
  FToggleColorOff := AValue;
  Invalidate;
end;

procedure TToggleButtonPlus.SetToggleColorArea(AValue: TColor);
begin
  if FToggleColorArea = AValue then Exit;
  FToggleColorArea := AValue;
  Invalidate;
end;

procedure TToggleButtonPlus.SetToggleBorder(AValue: Boolean);
begin
  if FToggleBorder = AValue then Exit;
  FToggleBorder := AValue;
  Invalidate;
end;

procedure TToggleButtonPlus.SetStyle(AValue: TToggleStyle);
begin
  if FStyle = AValue then Exit;
  FStyle := AValue;
  UpdateStyleColors;
  Invalidate;
end;

procedure TToggleButtonPlus.SetBackgroundColor(AValue: TColor);
begin
  if FBackgroundColor = AValue then Exit;
  FBackgroundColor := AValue;
  Invalidate;
end;

procedure TToggleButtonPlus.SetToggleBorderColor(AValue: TColor);
begin
  if FToggleBorderColor = AValue then Exit;
  FToggleBorderColor := AValue;
  Invalidate;
end;

procedure TToggleButtonPlus.SetToggleBorderStyle(AValue: TPenStyle);
begin
  if FToggleBorderStyle = AValue then Exit;
  FToggleBorderStyle := AValue;
  Invalidate;
end;

procedure TToggleButtonPlus.SetBorderEnabled(AValue: Boolean);
begin
  if FBorderEnabled = AValue then Exit;
  FBorderEnabled := AValue;
  Invalidate;
end;

procedure TToggleButtonPlus.SetBorderLineStyle(AValue: TPenStyle);
begin
  if FBorderLineStyle = AValue then Exit;
  FBorderLineStyle := AValue;
  Invalidate;
end;

procedure TToggleButtonPlus.SetCaption(AValue: String);
begin
  if FCaption = AValue then Exit;
  FCaption := AValue;
  Invalidate;
end;

procedure TToggleButtonPlus.SetBorderColor(AValue: TColor);
begin
  if FBorderColor = AValue then Exit;
  FBorderColor := AValue;
  Invalidate;
end;

procedure TToggleButtonPlus.SetBorderLineWidth(AValue: Integer);
begin
  if FBorderLineWidth = AValue then Exit;
  if AValue < 0 then AValue := 0;
  FBorderLineWidth := AValue;
  Invalidate;
end;

procedure TToggleButtonPlus.SetBorderRadius(AValue: Integer);
begin
  if FBorderRadius = AValue then Exit;
  if (AValue < 0) then AValue := 0;
  if (AValue > 12) then AValue := 12;
  FBorderRadius := AValue;
  Invalidate;
end;

procedure TToggleButtonPlus.Click;
begin
  inherited Click;
  SetChecked(not FChecked);
end;

procedure TToggleButtonPlus.Paint;
var
  R: TRect;
  Radius, BallSize, BallPos, SwitchWidth: Integer;
  TextRect: TRect;
  CaptionText: String;
  ToggleAreaHeight, lTop, lLeft, lRight: Integer;
  FBallColor, FCircleColor: TColor;
begin
  if Height < 25 then Height := 25;

  Canvas.Font := Font;
  ToggleAreaHeight := 20;
  lTop := (Height - ToggleAreaHeight) div 2;
  lLeft := 2;
  Radius := ToggleAreaHeight div 2;
  BallSize := ToggleAreaHeight - 6;
  SwitchWidth := ToggleAreaHeight * 2;
  CaptionText := FCaption;

  // ---- Área do Toggle -----
  // Fundo do Toggle
  Canvas.Brush.Color := FToggleColorArea;
  Canvas.Pen.Style := psClear;
  Canvas.RoundRect(lLeft, lTop, SwitchWidth, lTop + ToggleAreaHeight, Radius, Radius);

  // Borda do Toggle
  if FToggleBorder then begin
    Canvas.Pen.Color := FToggleBorderColor;
    Canvas.Pen.Style := FToggleBorderStyle;
    Canvas.Brush.Style := bsClear;
    Canvas.RoundRect(lLeft, lTop, SwitchWidth, lTop + ToggleAreaHeight, Radius, Radius);
  end;

  // ---- Bolinha do Toggle ----

  // cor do círculo ao redor da bolinha
  if FChecked then
    FCircleColor := FToggleColorOn
  else
    FCircleColor := FToggleColorOff;

  // cor da bolinha mais clara que a cor do círculo
  FBallColor := LightenColor(FCircleColor, 70);

  // coordenadas das bolinha dentro da área do toggle
  lTop := lTop + 3;   // Top da bolinha dentro da área do toggle
  lLeft := lLeft + 2; // Left da bolinha
  lRight := lLeft + SwitchWidth - BallSize - (BallSize div 2); // Rigth da bolinha

  // Animação posicional
  if FEnableAnimation and FAnimTimer.Enabled then
    BallPos := Round(FAnimPos / 100 * lRight)
  else if FChecked then
    BallPos := lLeft
  else
    BallPos := lRight;

  if BallPos < lLeft then BallPos := lLeft;
  if BallPos > lRight then BallPos := lRight;

  // Bolinha
  Canvas.Brush.Color := FBallColor;
  Canvas.Ellipse(BallPos, lTop, BallPos + BallSize, lTop + BallSize);

  // Círculo da Bolinha
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Color := FCircleColor;
  Canvas.Pen.Width := 1;
  Canvas.Ellipse(BallPos, lTop, BallPos + BallSize, lTop + BallSize);

  // ---- Área deste componente ----

  // borda do componente
  if FBorderEnabled then begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Style := FBorderLineStyle;
    Canvas.Pen.Color := FBorderColor;
    Canvas.Pen.Width := FBorderLineWidth;
  end;

  // pinta a borda do componente
  R := ClientRect;

  if FBorderRadius > 0 then
    Canvas.RoundRect(R, FBorderRadius, FBorderRadius)
  else
    Canvas.Rectangle(R);

  // Texto
  TextRect.Left := SwitchWidth + 5;
  TextRect.Top := lTop;
  TextRect.Right := Width - 1;
  TextRect.Bottom := Height - 1;
  Canvas.Brush.Style := bsClear;
  Canvas.TextRect(TextRect, TextRect.Left, (Height - Canvas.TextHeight(CaptionText)) div 2, CaptionText);
end;


end.
