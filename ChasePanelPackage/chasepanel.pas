unit ChasePanel;

// Autor: Aldo Marcio Soares - ams2kg@gmail.com
// Painel com elementos gráficos ao seu redor, em movimento como aqueles painéis de propaganda antigos.
// Marquee Frames

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LCLType, LCLIntf, Controls, Graphics, ExtCtrls,
  Dialogs, LMessages, LResources, Math;

type
  { TChasePanel }

  TChasePanel = class(TPanel)
  private
    FAutoSize: Boolean;
    FRefreshPanel: Boolean;
    TimerMarquee: TTimer;
    TimerResize: TTimer;
    FShape: TShapeType;

    FActive, FUpdatingSize, FExecutando: Boolean;
    FElementColor, FAlternateColor, FElementBorderColor: TColor;
    FElementSize, FSpeed, F_MaxX, F_MaxY, FSpacing: Integer;
    FWidth, FHeight: Integer;

    procedure Marquee_Create;
    procedure Marquee_Destroy;
    procedure Marquee_NewObject(X, Y: Integer; AColor: TColor; ADirecao: Integer);
    procedure SetActive(AValue: Boolean);
    procedure SetAlternateColor(AValue: TColor);
    procedure SetElementBorderColor(AValue: TColor);
    procedure SetElementColor(AValue: TColor);
    procedure SetElementSize(AValue: Integer);
    procedure SetRefreshPanel(AValue: Boolean);
    procedure SetShape(AValue: TShapeType);
    procedure SetSpeed(AValue: Integer);
    procedure TimerMarqueeTick(Sender: TObject);
    procedure TimerResizeTick(Sender: TObject);
  protected
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property AutoSize: Boolean read FAutoSize stored False; //desativa para evitar travamento
    property BevelOuter;
    property BevelInner;
    property BevelWidth;
    property BorderStyle;
    property BorderWidth;
    property Height;
    property Width;

    property Active: Boolean read FActive write SetActive default True;
    property ElementPrimaryColor: TColor read FElementColor write SetElementColor default clYellow;
    property ElementSecondaryColor: TColor read FAlternateColor write SetAlternateColor default clWhite;
    property ElementBorderColor: TColor read FElementBorderColor write SetElementBorderColor default clBlack;
    property ElementSize: Integer read FElementSize write SetElementSize default 20;
    property RefreshPanel: Boolean read FRefreshPanel write SetRefreshPanel;
    property Shape: TShapeType read FShape write SetShape default stStar;
    property Speed: Integer read FSpeed write SetSpeed default 5;
    procedure Start;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I chasepanel_icon.lrs}
  RegisterComponents('ModernUI',[TChasePanel]);
end;

constructor TChasePanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FExecutando           := False;
  FUpdatingSize         := False;
  FActive               := True;
  FWidth                := 292;
  FHeight               := 172;
  Width                 := FWidth;
  Height                := FHeight;
  F_MaxX                := Width;
  F_MaxY                := Height;

  BevelOuter            := bvNone;
  BorderStyle           := bsNone;

  FSpeed                := 5;
  FElementSize          := 20;
  FSpacing              := FElementSize + 10;
  FElementColor         := clYellow;
  FAlternateColor       := clWhite;
  FElementBorderColor   := clBlack;
  FShape                := stStar;

  TimerMarquee          := TTimer.Create(Self);
  TimerMarquee.Enabled  := False;
  TimerMarquee.Interval := 50;
  TimerMarquee.OnTimer  := @TimerMarqueeTick;

  TimerResize           := TTimer.Create(Self);
  TimerResize.Enabled   := True;
  TimerResize.Interval  := 10;
  TimerResize.OnTimer   := @TimerResizeTick;

  Marquee_Create;
end;

destructor TChasePanel.Destroy;
begin
  if Assigned(TimerMarquee) then begin
    TimerMarquee.Enabled := False;
    TimerMarquee.Free;
  end;

  if Assigned(TimerResize) then begin
    TimerResize.Enabled := False;
    TimerResize.Free;
  end;

  Marquee_Destroy;

  inherited Destroy;
end;

procedure TChasePanel.TimerMarqueeTick(Sender: TObject);
// animação dos objetos
var
  obj: TShape;
  i: Integer;
begin
  if (FActive and FExecutando and not FUpdatingSize) then
  begin
    // Itera sobre todos os objetos
    for i := 0 to Pred(Self.ComponentCount) do
    begin
      if (Self.Components[i] is TShape) then begin
         obj := Self.Components[i] as TShape; //não destruir usando obj.Free

         // 1. Movimentação baseada na Direção Atual
        case obj.Tag of
          1: obj.Left := obj.Left + FSpeed; //para a direita
          2: obj.Top  := obj.Top  + FSpeed; //para baixo
          3: obj.Left := obj.Left - FSpeed; //para a esquerda
          4: obj.Top  := obj.Top  - FSpeed; //para cima
        end;

        // 2. Verificação de Canto (e Mudança de Direção)

        // Canto Superior Direito -> Mudar para Baixo
        if (obj.Tag = 1) and (obj.Left >= F_MaxX) then
        begin
          obj.Left := F_MaxX;
          obj.Tag  := 2; //para baixo
        end

        // Canto Inferior Direito -> Mudar para Esquerda
        else if (obj.Tag = 2) and (obj.Top >= F_MaxY) then
        begin
          obj.Top := F_MaxY;
          obj.Tag := 3; //para a esquerda
        end

        // Canto Inferior Esquerdo -> Mudar para Cima
        else if (obj.Tag = 3) and (obj.Left <= 0) then
        begin
          obj.Left := 0;
          obj.Tag := 4; //para cima
        end

        // Canto Superior Esquerdo -> Mudar para Direita
        else if (obj.Tag = 4) and (obj.Top <= 0) then
        begin
          obj.Top := 0;
          obj.Tag := 1; //para a direita
        end;
      end; //if
    end; //for
  end; //if
end;

procedure TChasePanel.TimerResizeTick(Sender: TObject);
//recria os objetos após o evento Resize
begin
  if (not FUpdatingSize and not FExecutando and ((FWidth <> Width) or (FHeight <> Height))) then
  begin
    TimerResize.Interval := 1500;
    FWidth  := Width;
    FHeight := Height;
    Marquee_Create;
  end;
end;

procedure TChasePanel.Marquee_Create;
//cria os objetos ao redor do TPanel
var
  i, X, Y, Width_Panel, Heigth_Panel: Integer;
  lcolor: TColor;
begin
  if FUpdatingSize then Exit;

  FUpdatingSize := True;

  Marquee_Destroy;

  //limites
  Width_Panel  := Width - FElementSize;
  Heigth_Panel := Height - FElementSize;

  //1. Borda Superior (move para a direita)
  i := 0;
  Y := 0;
  X := FSpacing;

  while X < Width_Panel do
  begin
    if i = 0 then lcolor := FElementColor else lcolor := FAlternateColor;
    i := 1 - i;
    F_MaxX := X; //guarda última posição .Left antes de estourar o .Width do Panel

    Marquee_NewObject(X, Y, lcolor, 1); //move para a direita

    X := X + FSpacing;
  end;

  // 2. Borda Direita (move para baixo)
  X := F_MaxX;
  Y := FSpacing;

  while Y < Heigth_Panel do
  begin
    if i = 0 then lcolor := FElementColor else lcolor := FAlternateColor;
    i := 1 - i;
    F_MaxY := Y; //guarda última posição .Top antes de estourar o .Height do Panel

    Marquee_NewObject(X, Y, lcolor, 2); //move para baixo

    Y := Y + FSpacing;
  end;

  // 3. Borda Inferior (move para a esquerda)
  Y := F_MaxY;
  X := F_MaxX - FSpacing;

  while X >= 0 do
  begin
    if i = 0 then lcolor := FElementColor else lcolor := FAlternateColor;
    i := 1 - i;

    Marquee_NewObject(X, Y, lcolor, 3); //move para a esquerda

    X := X - FSpacing;
  end;

  // 4. Borda Esquerda (move para cima)
  X := 0;
  Y := F_MaxY - FSpacing;

  while Y >= 0 do
  begin
    if i = 0 then lcolor := FElementColor else lcolor := FAlternateColor;
    i := 1 - i;

    Marquee_NewObject(X, Y, lcolor, 4); //move para cima

    Y := Y - FSpacing;
  end;

  //ajusta dimensões do componente
  FHeight := F_MaxY + FElementSize + 2;
  FWidth  := F_MaxX + FElementSize + 2;
  Height  := FHeight;
  Width   := FWidth;

  FUpdatingSize := False;
  TimerMarquee.Enabled := FActive;
end;

procedure TChasePanel.Marquee_Destroy;
// remove os objetos da memória
var
  i: Integer;
begin
  for i := Pred(Self.ComponentCount) downto 0 do
    if Self.Components[i] is TShape then
      Self.Components[i].Free;
end;

procedure TChasePanel.Marquee_NewObject(X, Y: Integer; AColor: TColor; ADirecao: Integer);
// cria e adiciona objetos ao redor deste componente
var
  obj: TShape;
begin
  obj             := TShape.Create(Self);
  obj.Parent      := Self;
  obj.Shape       := FShape; // stSquare, stStar;
  obj.Width       := FElementSize;
  obj.Height      := FElementSize;
  obj.Brush.Color := AColor;

  if FElementBorderColor = clNone then
    obj.Pen.Color := AColor
  else
    obj.Pen.Color := FElementBorderColor;

  obj.Left        := X;
  obj.Top         := Y;
  obj.Visible     := True;
  obj.Tag         := ADirecao; //sentido do movimento: 1-direita, 2-desce, 3-esquerda, 4-sobe
end;

procedure TChasePanel.SetActive(AValue: Boolean);
begin
  if FActive = AValue then Exit;
  FActive := AValue;
end;

procedure TChasePanel.SetAlternateColor(AValue: TColor);
//redefine a cor altenada do objeto
begin
  if FAlternateColor = AValue then Exit;
  FAlternateColor := AValue;
  Marquee_Create;
end;

procedure TChasePanel.SetElementBorderColor(AValue: TColor);
//define a cor da borda dos objetos
begin
  if FElementBorderColor = AValue then Exit;
  FElementBorderColor := AValue;
  Marquee_Create;
end;

procedure TChasePanel.SetElementColor(AValue: TColor);
//redefine a cor principal do objeto
begin
  if FElementColor = AValue then Exit;
  FElementColor := AValue;
  Marquee_Create;
end;

procedure TChasePanel.SetElementSize(AValue: Integer);
//redefine o tamanho dos objetos
begin
  if FElementSize = AValue then Exit;
  if AValue < 10 then AValue := 10;
  if AValue > 50 then AValue := 50;
  FElementSize := AValue;
  FSpacing := FElementSize + FElementSize div 2;
  Marquee_Create;
end;

procedure TChasePanel.SetRefreshPanel(AValue: Boolean);
//atualiza o componente
begin
  if FRefreshPanel = AValue then Exit;
  FRefreshPanel := AValue;
  Marquee_Create;
end;

procedure TChasePanel.SetShape(AValue: TShapeType);
//redefine o formato do objeto
begin
  if FShape = AValue then Exit;
  FShape := AValue;
  Marquee_Create;
end;

procedure TChasePanel.SetSpeed(AValue: Integer);
//define a velocidade a animação
begin
  if FSpeed = AValue then Exit;
  if AValue < 2 then AValue := 2;
  if AValue > 20 then AValue := 20;
  FSpeed := AValue;
end;

procedure TChasePanel.Start;
//inicia a animação dos objetos
begin
  FExecutando := True;
end;

procedure TChasePanel.Resize;
//evento de resize do componente
begin
  inherited Resize;
  if Height < 172 then Height := 172;
  if Width < 292 then Width := 292;
end;

end.
