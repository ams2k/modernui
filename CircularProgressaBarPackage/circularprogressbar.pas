unit CircularProgressBar;

// Circular Progress Bar

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LCLType, LCLIntf, Controls, Graphics, ExtCtrls,
  Dialogs, LMessages, LResources, Math;

type
  TCircleStyle = (FULL, ARC, DOUBLEARC, BALLS);

  { TCircularProgressBar }

  TCircularProgressBar = class(TCustomControl)
  private
    FAngleLeft: Double;
    FAngleRight: Double;
    FBallCount: Integer;
    FCircleGradiente: Boolean;
    FCircleStyle: TCircleStyle;
    FProgress: Integer;
    FInfinite: Boolean;
    FCircleFirstColor: TColor;
    FCircleSecondColor: TColor;
    FCircleBackColor: TColor;
    FSpeed: Single;
    FSpeedFull: Integer;
    FThickness: Integer;
    FAngleArc: Single;
    FAngleFull: Integer;
    FTimer: TTimer;
    FMinValue: Integer;
    FMaxValue: Integer;
    FCurrentValue: Integer;
    procedure SetBallCount(AValue: Integer);
    procedure SetFCircleGradiente(AValue: Boolean);
    procedure SetProgress(Value: Integer);
    procedure SetInfinite(Value: Boolean);
    procedure SetCircleFirstColor(Value: TColor);
    procedure SetCircleSecondColor(Value: TColor);
    procedure SetCircleBackColor(AValue: TColor);
    procedure SetCircleStyle(AValue: TCircleStyle);
    procedure SetSpeed(AValue: Single);
    procedure SetThickness(Value: Integer);
    procedure SetMinValue(Value: Integer);
    procedure SetMaxValue(Value: Integer);
    procedure SetCurrentValue(Value: Integer);
    procedure UpdateProgress;
    procedure TimerTick(Sender: TObject);
    function InterpolateColor(StartColor, EndColor: TColor; Fraction: Single): TColor;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure DrawProgressArc;
    procedure DrawProgressFull;
    procedure DrawProgressBalls;
    procedure DrawProgressDoubleArc;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Anchors;
    property Color;
    property Enabled;
    property Font;
    property Height;
    property ParentColor;
    property ParentFont;
    property Visible;
    property Width;

    property Progress: Integer read FProgress write SetProgress default 0;
    property Infinite: Boolean read FInfinite write SetInfinite default False;
    property CircleFirstColor: TColor read FCircleFirstColor write SetCircleFirstColor default clGreen;
    property CircleSecondColor: TColor read FCircleSecondColor write SetCircleSecondColor default clLime;
    property CircleBackColor: TColor read FCircleBackColor write SetCircleBackColor default clSilver;
    property CircleStyle: TCircleStyle read FCircleStyle write SetCircleStyle;
    property CircleGradiente: Boolean read FCircleGradiente write SetFCircleGradiente default False;

    property Thickness: Integer read FThickness write SetThickness default 10;
    property MinValue: Integer read FMinValue write SetMinValue default 0;
    property MaxValue: Integer read FMaxValue write SetMaxValue default 100;
    property CurrentValue: Integer read FCurrentValue write SetCurrentValue default 0;
    property Speed: Single read FSpeed write SetSpeed;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I circularprogressbar_icon.lrs}
  RegisterComponents('ModernUI', [TCircularProgressBar]);
end;

constructor TCircularProgressBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 100;
  Height := 100;
  FProgress := 0;
  FInfinite := False;
  FCircleFirstColor := RGBToColor(239, 174, 23); // Laranja
  FCircleSecondColor := RGBToColor(239, 234, 77); // Amarelado claro
  FCircleBackColor := clSilver;
  FCircleGradiente := False;
  FCircleStyle := ARC;
  FThickness := 10;
  FAngleArc := 90;
  FAngleFull := 90;
  FMinValue := 0;
  FMaxValue := 100;
  FCurrentValue := 0;
  FSpeed := 10.0;
  FSpeedFull := Ceil(FSpeed);
  FBallCount := 10;
  FAngleLeft := 0;
  FAngleRight := 180;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := 25; // 20 FPS
  FTimer.OnTimer := @TimerTick;
  FTimer.Enabled := FInfinite;
end;

destructor TCircularProgressBar.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

procedure TCircularProgressBar.SetProgress(Value: Integer);
begin
  if FProgress = Value then Exit;
  FProgress := EnsureRange(Value, 0, 100);
  if (FMaxValue > FMinValue) then
    FCurrentValue := FMinValue + Round((FProgress / 100) * (FMaxValue - FMinValue));
  Invalidate;
end;

procedure TCircularProgressBar.SetFCircleGradiente(AValue: Boolean);
begin
  if FCircleGradiente = AValue then Exit;
  FCircleGradiente := AValue;
  Invalidate;
end;

procedure TCircularProgressBar.SetBallCount(AValue: Integer);
begin
  if FBallCount = AValue then Exit;
  FBallCount := AValue;
  if FBallCount < 5 then FBallCount := 5;
  Invalidate;
end;

procedure TCircularProgressBar.SetInfinite(Value: Boolean);
begin
  if FInfinite <> Value then begin
    FInfinite := Value;
    FAngleArc := 0;
    FAngleFull := 0;
    FTimer.Enabled := FInfinite;
    Invalidate;
  end;
end;

procedure TCircularProgressBar.SetCircleFirstColor(Value: TColor);
begin
  if FCircleFirstColor = Value then Exit;
  FCircleFirstColor := Value;
  Invalidate;
end;

procedure TCircularProgressBar.SetCircleSecondColor(Value: TColor);
begin
  if FCircleSecondColor = Value then Exit;
  FCircleSecondColor := Value;
  Invalidate;
end;

procedure TCircularProgressBar.SetCircleBackColor(AValue: TColor);
begin
  if FCircleBackColor = AValue then Exit;
  FCircleBackColor := AValue;
  Invalidate;
end;

procedure TCircularProgressBar.SetCircleStyle(AValue: TCircleStyle);
begin
  if FCircleStyle = AValue then Exit;
  FCircleStyle := AValue;
  FAngleArc := 0;
  FAngleFull := 0;
  Invalidate;
end;

procedure TCircularProgressBar.SetSpeed(AValue: Single);
begin
  if FSpeed = AValue then Exit;
  FSpeed := AValue;
  Invalidate;
end;

procedure TCircularProgressBar.SetThickness(Value: Integer);
begin
  if FThickness = Value then Exit;
  FThickness := EnsureRange(Value, 1, Min(Width, Height) div 4);
  Invalidate;
end;

procedure TCircularProgressBar.SetMinValue(Value: Integer);
begin
  if FMinValue = Value then Exit;
  FMinValue := Value;
  if FMaxValue <= FMinValue then
    FMaxValue := FMinValue + 1;
  UpdateProgress;
  Invalidate;
end;

procedure TCircularProgressBar.SetMaxValue(Value: Integer);
begin
  if FMaxValue = Value then Exit;
  FMaxValue := Value;
  if FMaxValue <= FMinValue then
    FMaxValue := FMinValue + 1;
  UpdateProgress;
  Invalidate;
end;

procedure TCircularProgressBar.SetCurrentValue(Value: Integer);
begin
  if FCurrentValue = Value then Exit;
  FCurrentValue := EnsureRange(Value, FMinValue, FMaxValue);
  UpdateProgress;
  Invalidate;
end;

procedure TCircularProgressBar.UpdateProgress;
begin
  if FMaxValue > FMinValue then
    FProgress := Round(((FCurrentValue - FMinValue) / (FMaxValue - FMinValue)) * 100)
  else
    FProgress := 0;
end;

procedure TCircularProgressBar.TimerTick(Sender: TObject);
begin
  if FInfinite then begin
    //ARC
    FAngleArc := FAngleArc - FSpeed;; // Alterado para girar no sentido horário (decrementa o ângulo)
    if FAngleArc <= -360 then FAngleArc := FAngleArc + 360; // Mantém o ângulo no intervalo [0, -360]

    // FULL
    FAngleFull := FAngleFull - FSpeedFull;
    if FAngleFull <= -360 then FAngleFull := FAngleFull + 360;

    //double arc - arco 1
    FAngleLeft := FAngleLeft - FSpeed;
    if FAngleLeft <= -360 then FAngleLeft := FAngleLeft + 360;

    //double arc - arco 2
    FAngleRight := FAngleRight - FSpeed;
    if FAngleRight <= -360 then FAngleRight := FAngleRight + 360;

    Invalidate;
  end;
end;

function TCircularProgressBar.InterpolateColor(StartColor, EndColor: TColor; Fraction: Single): TColor;
var
  R1, G1, B1, R2, G2, B2: Byte;
  R, G, B: Integer;
begin
  StartColor := ColorToRGB(StartColor);
  EndColor := ColorToRGB(EndColor);
  R1 := Red(StartColor);
  G1 := Green(StartColor);
  B1 := Blue(StartColor);
  R2 := Red(EndColor);
  G2 := Green(EndColor);
  B2 := Blue(EndColor);

  R := Round(R1 + Fraction * (R2 - R1));
  G := Round(G1 + Fraction * (G2 - G1));
  B := Round(B1 + Fraction * (B2 - B1));

  Result := RGBToColor(EnsureRange(R, 0, 255), EnsureRange(G, 0, 255), EnsureRange(B, 0, 255));
end;

procedure TCircularProgressBar.DrawProgressArc;
var
  Rect: TRect;
  i, CenterX, CenterY, Radius: Integer;
  StartAngle, EndAngle, SweepAngle: Single;
  R1, G1, B1, R2, G2, B2: Byte;
  R, G, B: Byte;
  ArcLength: Single;
  Progresso: Single;
begin
  CenterX := Width div 2;
  CenterY := Height div 2;
  Radius := Min(Width, Height) div 2 - (FThickness div 2);
  Rect := Bounds(CenterX - Radius, CenterY - Radius, Radius * 2, Radius * 2);

  //circulo de fundo
  Canvas.Pen.Color := FCircleBackColor;
  Canvas.Pen.Width := FThickness;
  Canvas.Brush.Style := bsClear;
  Canvas.Arc(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
             CenterX + Radius, CenterY, CenterX + Radius, CenterY);

  //configura o progresso
  if FInfinite then begin
    StartAngle := FAngleArc;
    SweepAngle := -120; //sentido horário é negativo
  end else begin
    StartAngle := 90;
    SweepAngle := (-360 * FProgress / 100);  //sentido horário é negativo
  end;

  Canvas.Pen.Color   := FCircleFirstColor; //cor da caneta
  Canvas.Pen.Width   := FThickness; //espessura da caneta
  Canvas.Brush.Style := bsClear; //sem preenchimento

  if not FInfinite and (FProgress < 1) then
    Canvas.Pen.Color := FCircleBackColor;

  if not FCircleGradiente then begin
    //sem gradiente
    Canvas.Arc(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
      Round(CenterX + Radius * Cos(DegToRad(StartAngle + SweepAngle))),
      Round(CenterY - Radius * Sin(DegToRad(StartAngle + SweepAngle))),
      Round(CenterX + Radius * Cos(DegToRad(StartAngle))),
      Round(CenterY - Radius * Sin(DegToRad(StartAngle))));
  end
  else begin
    //gradiente

    if FInfinite then begin
      // Modo infinito: arco rotativo de comprimento fixo
      // Extrai componentes RGB das cores inicial e final
      RedGreenBlue(FCircleFirstColor, R1, G1, B1);
      RedGreenBlue(FCircleSecondColor, R2, G2, B2);

      ArcLength := 90; // Comprimento do arco em graus

      for I := 0 to 29 do begin
        // Interpola as cores
        R := R1 + Round((R2 - R1) * (I / 29));
        G := G1 + Round((G2 - G1) * (I / 29));
        B := B1 + Round((B2 - B1) * (I / 29));

        Canvas.Pen.Color := RGBToColor(R, G, B);
        StartAngle := FAngleArc + I * (ArcLength / 30);
        EndAngle   := StartAngle + (ArcLength / 30);

        Canvas.Arc(
          CenterX - Radius, CenterY - Radius,
          CenterX + Radius, CenterY + Radius,
          Round(Cos(DegToRad(StartAngle)) * Radius + CenterX),
          Round(-Sin(DegToRad(StartAngle)) * Radius + CenterY),
          Round(Cos(DegToRad(EndAngle)) * Radius + CenterX),
          Round(-Sin(DegToRad(EndAngle)) * Radius + CenterY)
        );
      end;
    end
    else begin
      // Modo determinado: arco proporcional ao progresso

      ArcLength := (-360 * FProgress / 100);  //sentido horário é negativo

      if FProgress > 0 then begin
        // Extrai componentes RGB das cores inicial e final
        RedGreenBlue(FCircleSecondColor, R1, G1, B1);
        RedGreenBlue(FCircleFirstColor, R2, G2, B2);

        for I := 0 to 29 do begin
          // Interpola as cores
          R := R1 + Round((R2 - R1) * (I / 30));
          G := G1 + Round((G2 - G1) * (I / 30));
          B := B1 + Round((B2 - B1) * (I / 30));

          if FProgress < 10 then begin
            StartAngle := 90;
            EndAngle   := 90 + ArcLength;
          end else begin
            StartAngle := 90 + (I * ArcLength / 30);
            EndAngle   := 90 + ((I + 1) * ArcLength / 30);
          end;

          Canvas.Pen.Color := RGBToColor(R, G, B);

          Canvas.Arc(
             CenterX - Radius, CenterY - Radius,
             CenterX + Radius, CenterY + Radius,
             Round(CenterX + Radius * Cos(DegToRad(EndAngle))),
             Round(CenterY - Radius * Sin(DegToRad(EndAngle))),
             Round(CenterX + Radius * Cos(DegToRad(StartAngle))),
             Round(CenterY - Radius * Sin(DegToRad(StartAngle)))
          );
        end;
      end;
    end;
  end;
end;

procedure TCircularProgressBar.DrawProgressFull;
var
  Rec: TRect;
  CenterX, CenterY, Radius: Integer;
  StartAngle, EndAngle, SweepAngle: Single;
  i: Integer;
  R1, G1, B1, R2, G2, B2: Byte;
  R, G, B: Byte;
  ArcLength: Single;
  Progresso: Single;
begin
  CenterX := Width div 2;
  CenterY := Height div 2;
  Radius := Min(Width, Height) div 2;
  Rec := Bounds(CenterX - Radius, CenterY - Radius, Radius * 2, Radius * 2);

  // Desenha o círculo cheio de fundo
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := FCircleBackColor;
  Canvas.Pen.Style := psClear;
  Canvas.Ellipse(ClientRect);

  // Configura o progresso
  if FInfinite then begin
    StartAngle := FAngleFull;
    SweepAngle := 180; //Setor de 180 graus para rotação infinita
  end
  else begin
    StartAngle := 90; // Começa do topo
    SweepAngle := (-360 * FProgress / 100);
  end;

  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := FCircleFirstColor;

  if not FInfinite and (FProgress < 1) then
    Canvas.Brush.Color := FCircleBackColor;

  if not FCircleGradiente then begin
    //sem gradiente
    Canvas.Pie(Rec.Left, Rec.Top, Rec.Right, Rec.Bottom,
        Round(CenterX + Radius * Cos(DegToRad(StartAngle + SweepAngle))),
        Round(CenterY - Radius * Sin(DegToRad(StartAngle + SweepAngle))),
        Round(CenterX + Radius * Cos(DegToRad(StartAngle))),
        Round(CenterY - Radius * Sin(DegToRad(StartAngle))));
  end
  else begin
    //gradiente

    if FInfinite then begin
      // Modo infinito: arco rotativo de comprimento fixo
      // Extrai componentes RGB das cores inicial e final
      RedGreenBlue(FCircleFirstColor, R1, G1, B1);
      RedGreenBlue(FCircleSecondColor, R2, G2, B2);

      ArcLength := 120; // Comprimento do arco em graus

      for I := 0 to 29 do begin
        // Interpola as cores
        R := R1 + Round((R2 - R1) * (I / 29));
        G := G1 + Round((G2 - G1) * (I / 29));
        B := B1 + Round((B2 - B1) * (I / 29));

        Canvas.Pen.Color   := RGBToColor(R, G, B);
        Canvas.Brush.Color := Canvas.Pen.Color;

        StartAngle := FAngleFull + I * (ArcLength / 30);
        EndAngle   := StartAngle + (ArcLength / 30);

        Canvas.Pie(
          CenterX - Radius, CenterY - Radius,
          CenterX + Radius, CenterY + Radius,
          Round(Cos(DegToRad(StartAngle)) * Radius + CenterX),
          Round(-Sin(DegToRad(StartAngle)) * Radius + CenterY),
          Round(Cos(DegToRad(EndAngle)) * Radius + CenterX),
          Round(-Sin(DegToRad(EndAngle)) * Radius + CenterY)
        );
      end;
    end
    else begin
      // Modo determinado: arco proporcional ao progresso
      if FMaxValue <> FMinValue then
        Progresso := (CurrentValue - FMinValue) / (FMaxValue - FMinValue)
      else
        Progresso := 0;

      // Comprimento do arco baseado no progresso
      ArcLength := (-360 * FProgress / 100);  //sentido horário é negativo

      if ArcLength > 0 then begin
        // Extrai componentes RGB das cores inicial e final
        RedGreenBlue(FCircleSecondColor, R1, G1, B1);
        RedGreenBlue(FCircleFirstColor, R2, G2, B2);

        for I := 0 to 29 do begin
          // Interpola as cores
          R := R1 + Round((R2 - R1) * (I / 30));
          G := G1 + Round((G2 - G1) * (I / 30));
          B := B1 + Round((B2 - B1) * (I / 30));

          Canvas.Brush.Color := RGBToColor(R, G, B);

          if ArcLength < 10 then begin
            StartAngle := 90 ;
            EndAngle   := 90 + ArcLength;
          end else begin
            StartAngle := 90 + (I * ArcLength / 30);
            EndAngle   := 90 + ((I + 1) * ArcLength / 30);
          end;

          Canvas.Pie(
            CenterX - Radius, CenterY - Radius,
            CenterX + Radius, CenterY + Radius,
            Round(Cos(DegToRad(StartAngle)) * Radius + CenterX),
            Round(-Sin(DegToRad(StartAngle)) * Radius + CenterY),
            Round(Cos(DegToRad(EndAngle)) * Radius + CenterX),
            Round(-Sin(DegToRad(EndAngle)) * Radius + CenterY)
          );
        end;
      end;
    end;
  end;
end;

procedure TCircularProgressBar.DrawProgressBalls;
var
  Rect: TRect;
  CenterX, CenterY, Radius: Integer;
  BallAngle, ArcLength: Single;
  I, CalculatedBallCount: Integer;
  R1, G1, B1, R2, G2, B2: Byte;
  R, G, B: Byte;
  Progresso: Single;
  BallX, BallY, BallRadius: Integer;
  Circumference, ArcLengthInPixels, Gap: Single;
begin
  inherited Paint;
  CenterX := Width div 2;
  CenterY := Height div 2;

  Radius := Min(Width, Height) div 2 - (FThickness div 2);
  Rect := Bounds(CenterX - Radius, CenterY - Radius, Radius * 2, Radius * 2);

  //circulo de fundo
  Canvas.Pen.Color := FCircleBackColor;
  Canvas.Pen.Width := FThickness;
  Canvas.Brush.Style := bsClear;
  Canvas.Arc(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
             CenterX + Radius, CenterY, CenterX + Radius, CenterY);

  Canvas.Pen.Style := psSolid;
  Canvas.Brush.Style := bsSolid;

  // Extrai componentes RGB das cores inicial e final
  if FCircleGradiente then begin
    RedGreenBlue(FCircleSecondColor, R1, G1, B1);
    RedGreenBlue(FCircleFirstColor, R2, G2, B2);
  end
  else begin
    RedGreenBlue(FCircleFirstColor, R1, G1, B1);
    RedGreenBlue(FCircleFirstColor, R2, G2, B2);
  end;

  // Define o raio das bolas com base em Thickness
  BallRadius := (FThickness div 2);
  BallRadius := Ceil((FThickness - 4) div 2);
  if BallRadius < 2 then BallRadius := 2;
  Gap := BallRadius * 2 + 1; // Espaço mínimo entre bolas (em pixels)

  if FInfinite then begin
    // Modo infinito: bolas ao longo de um arco fixo de 120 graus
    ArcLength := 120;
    Circumference := 2 * Pi * Radius;
    ArcLengthInPixels := (ArcLength / 360) * Circumference;

    // Calcula o número de bolas para evitar sobreposição
    CalculatedBallCount := Floor(ArcLengthInPixels / (FThickness + Gap));
    if CalculatedBallCount < 1 then CalculatedBallCount := 1; // Pelo menos uma bola se houver progresso

    for I := 0 to CalculatedBallCount - 1 do begin
      // Calcula a posição angular de cada bola
      BallAngle := FAngleArc - (I * ArcLength / CalculatedBallCount); // Sentido horário

      // Interpola as cores
      if CalculatedBallCount > 1 then begin
        R := R1 + Round((R2 - R1) * (I / (CalculatedBallCount - 1)));
        G := G1 + Round((G2 - G1) * (I / (CalculatedBallCount - 1)));
        B := B1 + Round((B2 - B1) * (I / (CalculatedBallCount - 1)));
      end
      else begin
        R := R1;
        G := G1;
        B := B1;
      end;

      Canvas.Pen.Color := RGBToColor(R, G, B);
      Canvas.Brush.Color := Canvas.Pen.Color;

      // Calcula a posição da bola no círculo
      BallX := Round(Cos(DegToRad(BallAngle)) * Radius + CenterX);
      BallY := Round(-Sin(DegToRad(BallAngle)) * Radius + CenterY);

      // Desenha a bola
      Canvas.Ellipse(
        BallX - BallRadius, BallY - BallRadius,
        BallX + BallRadius, BallY + BallRadius
      );
    end;
  end
  else begin
    // Modo determinado: bolas ao longo de um arco proporcional ao progresso
    if FMaxValue <> FMinValue then
      Progresso := (FCurrentValue - FMinValue) / (FMaxValue - FMinValue)
    else
      Progresso := 0;

    ArcLength := Progresso * 360; // Comprimento do arco baseado no progresso

    if ArcLength > 0 then begin
      // Calcula a circunferência e o comprimento do arco em pixels
      Circumference := 2 * Pi * Radius;
      ArcLengthInPixels := (ArcLength / 360) * Circumference;

      // Calcula o número de bolas para evitar sobreposição
      CalculatedBallCount := Floor(ArcLengthInPixels / (FThickness + Gap));

      if CalculatedBallCount < 1 then CalculatedBallCount := 1; // Pelo menos uma bola se houver progresso

      for I := 0 to CalculatedBallCount - 1 do begin
        // Calcula a posição angular de cada bola
        BallAngle := 90 - (I * ArcLength / CalculatedBallCount); // Sentido horário

        // Interpola as cores
        if CalculatedBallCount > 1 then begin
          R := R1 + Round((R2 - R1) * (I / (CalculatedBallCount - 1)));
          G := G1 + Round((G2 - G1) * (I / (CalculatedBallCount - 1)));
          B := B1 + Round((B2 - B1) * (I / (CalculatedBallCount - 1)));
        end
        else begin
          R := R1;
          G := G1;
          B := B1;
        end;

        Canvas.Pen.Color := RGBToColor(R, G, B);
        Canvas.Brush.Color := Canvas.Pen.Color;

        // Calcula a posição da bola no círculo
        BallX := Round(Cos(DegToRad(BallAngle)) * Radius + CenterX);
        BallY := Round(-Sin(DegToRad(BallAngle)) * Radius + CenterY);

        // Desenha a bola
        Canvas.Ellipse(
          BallX - BallRadius, BallY - BallRadius,
          BallX + BallRadius, BallY + BallRadius
        );
      end;
    end;
  end;
end;

procedure TCircularProgressBar.DrawProgressDoubleArc;
var
  Rect: TRect;
  CenterX, CenterY, Radius: Integer;
  I, FArcLength: Integer;
  StartAngle, EndAngle, SweepAngle: Single;
  PercentText: string;
  TextWidth, TextHeight: Integer;
  R1, G1, B1, R2, G2, B2: Byte;
  R, G, B: Byte;
begin
  inherited Paint;

  FArcLength := 60;
  CenterX := Width div 2;
  CenterY := Height div 2;
  Radius := Min(Width, Height) div 2 - (FThickness div 2);
  Rect := Bounds(CenterX - Radius, CenterY - Radius, Radius * 2, Radius * 2);

  //circulo de fundo
  Canvas.Pen.Color := FCircleBackColor;
  Canvas.Pen.Width := FThickness;
  Canvas.Brush.Style := bsClear;
  Canvas.Arc(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
             CenterX + Radius, CenterY, CenterX + Radius, CenterY);

  Canvas.Pen.Width := FThickness;
  Canvas.Pen.Color := FCircleFirstColor;

  if FCircleGradiente then begin
    RedGreenBlue(FCircleFirstColor, R1, G1, B1);
    RedGreenBlue(FCircleSecondColor, R2, G2, B2);

    for I := 0 to 29 do begin
      // Interpola as cores
      R := R1 + Round((R2 - R1) * (I / 29));
      G := G1 + Round((G2 - G1) * (I / 29));
      B := B1 + Round((B2 - B1) * (I / 29));

      Canvas.Pen.Color   := RGBToColor(R, G, B);

      // Desenha o arco da esquerda
      StartAngle := FAngleLeft + I * (FArcLength / 30);
      EndAngle   := StartAngle + (FArcLength / 30);

      Canvas.Arc(
        Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
        Round(CenterX + Radius * Cos(DegToRad(StartAngle))),
        Round(CenterY - Radius * Sin(DegToRad(StartAngle))),
        Round(CenterX + Radius * Cos(DegToRad(EndAngle))),
        Round(CenterY - Radius * Sin(DegToRad(EndAngle)))
      );

      // Desenha o arco da direita
      StartAngle := FAngleRight + I * (FArcLength / 30);
      EndAngle   := StartAngle + (FArcLength / 30);

      Canvas.Arc(
        Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
        Round(CenterX + Radius * Cos(DegToRad(StartAngle))),
        Round(CenterY - Radius * Sin(DegToRad(StartAngle))),
        Round(CenterX + Radius * Cos(DegToRad(EndAngle))),
        Round(CenterY - Radius * Sin(DegToRad(EndAngle)))
      );
    end;
  end
  else begin
    // Desenha o arco da esquerda
    Canvas.Arc(
      Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
      Round(CenterX + Radius * Cos(DegToRad(FAngleLeft))),
      Round(CenterY - Radius * Sin(DegToRad(FAngleLeft))),
      Round(CenterX + Radius * Cos(DegToRad(FAngleLeft + FArcLength))),
      Round(CenterY - Radius * Sin(DegToRad(FAngleLeft + FArcLength)))
    );

    // Desenha o arco da direita
    Canvas.Arc(
      Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
      Round(CenterX + Radius * Cos(DegToRad(FAngleRight))),
      Round(CenterY - Radius * Sin(DegToRad(FAngleRight))),
      Round(CenterX + Radius * Cos(DegToRad(FAngleRight + FArcLength))),
      Round(CenterY - Radius * Sin(DegToRad(FAngleRight + FArcLength)))
    );
  end;

  if (FProgress > 0) then begin
    FInfinite := True;
    FTimer.Enabled := True;
  end;
end;

procedure TCircularProgressBar.Paint;
var
  CenterX, CenterY: Integer;
  PercentText: string;
  TextWidth, TextHeight: Integer;
  bShowPercentual: Boolean;
begin
  inherited Paint;

  bShowPercentual := not FInfinite;

  if FCircleStyle = FULL then
    DrawProgressFull
  else if FCircleStyle = BALLS then begin
    bShowPercentual := (FProgress > 0);
    DrawProgressBalls;
  end
  else if FCircleStyle = DOUBLEARC then
    DrawProgressDoubleArc
  else
    DrawProgressArc;

  if bShowPercentual then begin
    CenterX := Width div 2;
    CenterY := Height div 2;

    Canvas.Brush.Style := bsClear;
    Canvas.Font := Font;
    PercentText := Format('%d%%', [FProgress]);
    TextWidth := Canvas.TextWidth(PercentText);
    TextHeight := Canvas.TextHeight(PercentText);
    Canvas.TextOut(CenterX - TextWidth div 2, CenterY - TextHeight div 2, PercentText);
  end;
end;

procedure TCircularProgressBar.Resize;
begin
  inherited Resize;
  if Width < 60 then Width := 60;
  if Height < 60 then Height := 60;
  Width := Height;
  Invalidate;
end;

end.
