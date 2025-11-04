unit PanelPlus;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Graphics, LCLType, LCLIntf, Controls, Types, LMessages,
  LResources, ExtCtrls, StdCtrls, Math;

type

  { TPanelPlus }

  TPanelPlus = class(TPanel)
  private
    FBorderLineColor: TColor;
    FBorderLineEnabled: Boolean;
    FBorderLineRadius: Integer;
    FBorderLineStyle: TPenStyle;
    procedure SetBorderLIneColor(AValue: TColor);
    procedure SetBorderLineEnabled(AValue: Boolean);
    procedure SetBorderLineRadius(AValue: Integer);
    procedure SetBorderLineStyle(AValue: TPenStyle);

  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property BorderLineEnabled: Boolean read FBorderLineEnabled write SetBorderLineEnabled default True;
    property BorderLineColor: TColor read FBorderLineColor write SetBorderLineColor default clGray;
    property BorderLineRadius: Integer read FBorderLineRadius write SetBorderLineRadius default 12;
    property BorderLineStyle: TPenStyle read FBorderLineStyle write SetBorderLineStyle default psSolid;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I panelplus_icon.lrs}
  RegisterComponents('ModernUI',[TPanelPlus]);
end;

{ TPanelPlus }

constructor TPanelPlus.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  BevelColor := clDefault;
  BevelInner := bvNone;
  BevelOuter := bvNone;
  BevelWidth := 1;
  BorderStyle := bsNone;

  FBorderLineEnabled := True;
  FBorderLineColor := $00BCBEBF;
  FBorderLineRadius := 12;
  FBorderLineStyle := psSolid;
end;

procedure TPanelPlus.SetBorderLIneColor(AValue: TColor);
begin
  if FBorderLineColor = AValue then Exit;
  FBorderLineColor := AValue;
  Invalidate;
end;

procedure TPanelPlus.SetBorderLineEnabled(AValue: Boolean);
begin
  if FBorderLineEnabled = AValue then Exit;
  FBorderLineEnabled := AValue;

  if AValue then begin
    BevelColor := clDefault;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    BevelWidth := 1;
    BorderStyle := bsNone;
  end;

  Invalidate;
end;

procedure TPanelPlus.SetBorderLineRadius(AValue: Integer);
begin
  if FBorderLineRadius = AValue then Exit;
  FBorderLineRadius := AValue;
  Invalidate;
end;

procedure TPanelPlus.SetBorderLineStyle(AValue: TPenStyle);
begin
  if FBorderLineStyle = AValue then Exit;
  FBorderLineStyle := AValue;
  Invalidate;
end;

procedure TPanelPlus.Paint;
begin
  inherited Paint;

  Canvas.Font := Font;
  Canvas.Brush.Style := bsClear;

  if FBorderLineEnabled and (BorderStyle = bsNone) then begin
    Canvas.Pen.Style := FBorderLineStyle;
    Canvas.Pen.Color := FBorderLineColor;
    Canvas.Pen.Width := BorderWidth;

    if FBorderLineRadius > 0 then
      Canvas.RoundRect(ClientRect, FBorderLineRadius, FBorderLineRadius)
    else
      Canvas.Rectangle(ClientRect);
  end;
end;

end.
