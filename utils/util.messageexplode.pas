unit Util.MessageExplode;

// Aldo Marcio Soares - ams2kg@gmail.com - 05/2025
// Exibe mensagem em estilo explode/implode
//
//ShowExplodeMessage(self, 'Sucesso', etSuccess, epCenter);
//ShowExplodeMessage(self, 'Alerta', etWarning, epTop);
//ShowExplodeMessage(self, 'Alerta 2', etWarning, epTop, 50);
//ShowExplodeMessage(self, 'Falhou!' + sLineBreak + 'Corrija o problema.', etFatal, epBottom);
   
{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls, ExtCtrls, Graphics, LCLIntf, LCLType, Types, Math;

type
  TMessageExplodeType = (etSuccess, etWarning, etFatal);
  TExplodePosition = (epTop, epCenter, epBottom);

  { TMessageExplode }

  TMessageExplode = class(TCustomControl)
  private
    FMessage: string;
    FMessageType: TMessageExplodeType;
    FPosition: TExplodePosition;
    FTargetWidth, FTargetHeight: Integer;
    FBaseLeft, FBaseTop, FTop: Integer;
    AnimationTimer, AutoCloseTimer, FLineTimer: TTimer;
    AnimationStep: Integer;
    AnimateShow, AnimateHide: Boolean;
    FLineProgress, FLineProgressWidth: Integer;
    function CalculateTextHeight(const AText: string): Integer;
    procedure DoAnimationTimer(Sender: TObject);
    procedure DoLineTimer(Sender: TObject);
    procedure StartAnimation;
    procedure StartAutoClose(Timeout: Integer);
    procedure DoAutoClose(Sender: TObject);
    procedure AdjustSizeForText;
    procedure UpdatePosition;
  protected
    procedure Paint; override;
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShowMessage(AMessage: string; AType: TMessageExplodeType; 
                          APosition: TExplodePosition; ATop: Integer = 0);
  end;

procedure ShowExplodeMessage(AOwner: TWinControl; const AMsg: string; AMsgType: TMessageExplodeType;
                             APos: TExplodePosition = epTop; ATop: Integer = 0);

implementation

procedure ShowExplodeMessage(AOwner: TWinControl; const AMsg: string; AMsgType: TMessageExplodeType;
                             APos: TExplodePosition; ATop: Integer);
var
  Popup: TMessageExplode;
begin
  Popup := TMessageExplode.Create(AOwner);
  Popup.Parent := AOwner;
  Popup.ShowMessage(AMsg, AMsgType, APos, ATop);
end;

{ TMessageExplode }

constructor TMessageExplode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Visible := False;

  AnimationTimer := TTimer.Create(Self);
  AnimationTimer.Enabled := False;
  AnimationTimer.Interval := 15;
  AnimationTimer.OnTimer := @DoAnimationTimer;

  AutoCloseTimer := TTimer.Create(Self);
  AutoCloseTimer.Enabled := False;
  AutoCloseTimer.OnTimer := @DoAutoClose;

  FLineTimer := TTimer.Create(Self);
  FLineTimer.Enabled := False;
  FLineTimer.Interval := 50;
  FLineTimer.OnTimer := @DoLineTimer;

  SetBounds(0, 0, 10, 10);
end;

destructor TMessageExplode.Destroy;
begin
  AutoCloseTimer.Free;
  AnimationTimer.Free;
  FLineTimer.Free;
  inherited Destroy;
end;

procedure TMessageExplode.AdjustSizeForText;
var
  TmpCanvas: TControlCanvas;
  R: TRect;
  flags: Longint;
  TxtW, TxtH: Integer;
begin
  TmpCanvas := TControlCanvas.Create;
  try
    TmpCanvas.Control := Self;
    TmpCanvas.Font := Font;
    TxtW := TmpCanvas.TextWidth(FMessage) + 40;
    TxtH := TmpCanvas.TextHeight(FMessage) + 20;

    // Calcula quebras de linha e aumenta altura
    R := Rect(10, 10, Width - 10, Height - 10);
    flags := DT_CENTER or DT_VCENTER or DT_WORDBREAK;
    DrawText(TmpCanvas.Handle, PChar(FMessage), Length(FMessage), R, flags);

    // Dimensões finais
    FTargetWidth := Max(380, R.Right + 40); //largura máxima deste componente
    FTargetHeight := CalculateTextHeight(FMessage);

    FLineProgress := FTargetWidth - 20;
    FLineProgressWidth := FLineProgress;

    Width := FTargetWidth;
    Height := FTargetHeight;
  finally
    TmpCanvas.Free;
  end;
end;

procedure TMessageExplode.UpdatePosition;
begin
  if Parent = nil then Exit;

  case FPosition of
    epTop:
      begin
        Left := (Parent.Width - Width) div 2;
        Top := 20 + FTop;
      end;
    epCenter:
      begin
        Left := (Parent.Width - Width) div 2;
        Top := (Parent.Height - Height) div 2;
      end;
    epBottom:
      begin
        Left := (Parent.Width - Width) div 2;
        Top := Parent.Height - Height - 20;
      end;
  end;

  FBaseLeft := Left + Width div 2;
  FBaseTop := Top + Height div 2;
end;

procedure TMessageExplode.ShowMessage(AMessage: string; AType: TMessageExplodeType; 
                                      APosition: TExplodePosition; ATop: Integer);
begin
  FMessage := AMessage;
  FMessageType := AType;
  FPosition := APosition;

  AdjustSizeForText;
  UpdatePosition;

  FTop := ATop;
  Width := 1;
  Height := 1;
  AnimationStep := 0;
  AnimateShow := True;
  AnimateHide := False;

  Visible := True;
  BringToFront;
  StartAnimation;
end;

procedure TMessageExplode.StartAnimation;
begin
  AnimationStep := 0;
  AnimationTimer.Enabled := True;
end;

procedure TMessageExplode.StartAutoClose(Timeout: Integer);
begin
  AutoCloseTimer.Interval := Timeout;
  AutoCloseTimer.Enabled := True;
  FLineTimer.Enabled := True;
end;

procedure TMessageExplode.DoAutoClose(Sender: TObject);
begin
  AutoCloseTimer.Enabled := False;
  AnimateHide := True;
  AnimationStep := 0;
  AnimationTimer.Enabled := True;
  FLineTimer.Enabled := False;
end;

procedure TMessageExplode.DoAnimationTimer(Sender: TObject);
const
  ANIMATION_STEPS = 10;
var
  NewW, NewH: Integer;
begin
  Inc(AnimationStep);

  if AnimateShow then
  begin
    NewW := (FTargetWidth * AnimationStep) div ANIMATION_STEPS;
    NewH := (FTargetHeight * AnimationStep) div ANIMATION_STEPS;
    Width := NewW;
    Height := NewH;

    Left := FBaseLeft - Width div 2;
    Top := FBaseTop - Height div 2;

    if AnimationStep >= ANIMATION_STEPS then
    begin
      AnimateShow := False;
      Width := FTargetWidth;
      Height := FTargetHeight;
      UpdatePosition;

      if FMessageType = etSuccess then
        StartAutoClose(3500)
      else
        StartAutoClose(30000);
    end;
  end
  else if AnimateHide then
  begin
    NewW := (FTargetWidth * (ANIMATION_STEPS - AnimationStep)) div ANIMATION_STEPS;
    NewH := (FTargetHeight * (ANIMATION_STEPS - AnimationStep)) div ANIMATION_STEPS;
    Width := NewW;
    Height := NewH;

    Left := FBaseLeft - Width div 2;
    Top := FBaseTop - Height div 2;

    if AnimationStep >= ANIMATION_STEPS then
    begin
      AnimationTimer.Enabled := False;
      Visible := False;
      Parent := nil;
      Free;
    end;
  end;

  if not (csDestroying in ComponentState) and Visible and HandleAllocated then begin
    Invalidate;
  end;
end;

procedure TMessageExplode.DoLineTimer(Sender: TObject);
begin
  if FLineProgress > 0 then
  begin
    FLineProgress := FLineProgress - Round(FLineProgressWidth / (AutoCloseTimer.Interval / FLineTimer.Interval));
    if FLineProgress < 0 then FLineProgress := 0;
    Invalidate;
  end else
    DoAutoClose(Sender);
end;

procedure TMessageExplode.Paint;
var
  R: TRect;
  bgColor, lineColor: TColor;
  flags: Longint;
begin
  Canvas.Brush.Style := bsSolid;

  case FMessageType of
    etSuccess: begin bgColor := $DFFFD6; lineColor := RGBToColor(195,222,186); end;
    etWarning: begin bgColor := RGBToColor(255,255,179); lineColor := RGBToColor(217,217,151) ; end; // $FFF4CC; //azul claro
    etFatal:   begin bgColor := RGBToColor(255,180,180); lineColor := RGBToColor(214,151,159); end;   // $FFD6D6; // vinho claro
  end;

  Canvas.Brush.Color := bgColor;
  Canvas.Pen.Color := lineColor;
  Canvas.Pen.Width := 2;

  R := ClientRect;
  R.Top := 1;
  R.Left := 1;
  Canvas.RoundRect(R, 12, 12);

  //texto
  R := Rect(10, 10, Width - 10, Height - 10);
  flags := DT_CENTER or DT_VCENTER or DT_WORDBREAK; //or DT_NOPREFIX or DT_SINGLELINE;
  DrawText(Canvas.Handle, PChar(FMessage), Length(FMessage), R, flags);

  if not AnimateHide and AutoCloseTimer.Enabled and (FLineProgress > 0) then begin
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Color := clSkyBlue;
    Canvas.Pen.Width := 4;
    Canvas.MoveTo(10, Height - 6);
    Canvas.LineTo(10 + FLineProgress, Height - 6);
  end;
end;

procedure TMessageExplode.Click;
begin
  inherited Click;
  DoAutoClose(Self);
end;

function TMessageExplode.CalculateTextHeight(const AText: string): Integer;
var
  R: TRect;
  flags: Longint;
begin
  R := Rect(0, 0, FTargetWidth - 20, 0);
  flags := DT_CALCRECT or DT_WORDBREAK;
  DrawText(GetDC(0), PChar(AText), Length(AText), R, flags);
  Result := R.Bottom - R.Top + 20;
end;

end.
