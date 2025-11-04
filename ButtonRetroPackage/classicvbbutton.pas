unit ClassicVBButton;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Graphics, LResources, LCLType, LMessages, Forms;

type
  TImagePosition = (ipLeft, ipRight, ipTop, ipBottom, ipCenter);

  TClassicVBButton = class(TCustomControl)
  private
    FCaption: string;
    FImage: TPicture;
    FImagePosition: TImagePosition;
    FPressed: Boolean;
    FFocused: Boolean;
    FFlat: Boolean;
    procedure SetCaption(const AValue: string);
    procedure SetImage(const AValue: TPicture);
    procedure SetImagePosition(const AValue: TImagePosition);
    procedure SetFlat(const AValue: Boolean);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure DrawButton(ACanvas: TCanvas);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Caption: string read FCaption write SetCaption;
    property Image: TPicture read FImage write SetImage;
    property ImagePosition: TImagePosition read FImagePosition write SetImagePosition default ipLeft;
    property Flat: Boolean read FFlat write SetFlat default False;
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
  RegisterComponents('Samples', [TClassicVBButton]);
end;

constructor TClassicVBButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 100;
  Height := 30;
  FImage := TPicture.Create;
  FCaption := 'Button';
  FImagePosition := ipLeft;
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csDoubleClicks, csSetCaption, csCaptureMouse, csTabStop, csFocusable];
  TabStop := True;
end;

destructor TClassicVBButton.Destroy;
begin
  FImage.Free;
  inherited Destroy;
end;

procedure TClassicVBButton.SetCaption(const AValue: string);
begin
  if FCaption <> AValue then
  begin
    FCaption := AValue;
    Invalidate;
  end;
end;

procedure TClassicVBButton.SetImage(const AValue: TPicture);
begin
  FImage.Assign(AValue);
  Invalidate;
end;

procedure TClassicVBButton.SetImagePosition(const AValue: TImagePosition);
begin
  if FImagePosition <> AValue then
  begin
    FImagePosition := AValue;
    Invalidate;
  end;
end;

procedure TClassicVBButton.SetFlat(const AValue: Boolean);
begin
  if FFlat <> AValue then
  begin
    FFlat := AValue;
    Invalidate;
  end;
end;

procedure TClassicVBButton.DrawButton(ACanvas: TCanvas);
var
  R: TRect;
  TextSize: TSize;
  TextPos, ImgPos: TPoint;
begin
  R := ClientRect;

  if not FFlat then
  begin
    if FPressed then
    begin
      ACanvas.Pen.Color := clBtnShadow;
      ACanvas.Line(R.Left, R.Bottom-1, R.Left, R.Top);
      ACanvas.LineTo(R.Right-1, R.Top);

      ACanvas.Pen.Color := clBtnHighlight;
      ACanvas.Line(R.Right-1, R.Top+1, R.Right-1, R.Bottom-1);
      ACanvas.LineTo(R.Left+1, R.Bottom-1);
    end
    else
    begin
      ACanvas.Pen.Color := clBtnHighlight;
      ACanvas.Line(R.Left, R.Bottom-1, R.Left, R.Top);
      ACanvas.LineTo(R.Right-1, R.Top);

      ACanvas.Pen.Color := clBtnShadow;
      ACanvas.Line(R.Right-1, R.Top+1, R.Right-1, R.Bottom-1);
      ACanvas.LineTo(R.Left+1, R.Bottom-1);
    end;
  end;

  ACanvas.Brush.Style := bsClear;
  ACanvas.Font := Font;
  TextSize := ACanvas.TextExtent(FCaption);

  case FImagePosition of
    ipLeft:
      begin
        ImgPos := Point(5, (Height - FImage.Height) div 2);
        TextPos := Point(ImgPos.X + FImage.Width + 5, (Height - TextSize.cy) div 2);
      end;
    ipRight:
      begin
        TextPos := Point(5, (Height - TextSize.cy) div 2);
        ImgPos := Point(TextPos.X + TextSize.cx + 5, (Height - FImage.Height) div 2);
      end;
    ipTop:
      begin
        ImgPos := Point((Width - FImage.Width) div 2, 5);
        TextPos := Point((Width - TextSize.cx) div 2, ImgPos.Y + FImage.Height + 2);
      end;
    ipBottom:
      begin
        TextPos := Point((Width - TextSize.cx) div 2, 5);
        ImgPos := Point((Width - FImage.Width) div 2, TextPos.Y + TextSize.cy + 2);
      end;
    ipCenter:
      begin
        if Assigned(FImage.Graphic) then
          ImgPos := Point((Width - FImage.Width) div 2, (Height - FImage.Height) div 2)
        else
          ImgPos := Point(0, 0);
        TextPos := Point((Width - TextSize.cx) div 2, (Height - TextSize.cy) div 2);
      end;
  end;

  if Assigned(FImage.Graphic) then
    ACanvas.Draw(ImgPos.X, ImgPos.Y, FImage.Graphic);

  ACanvas.TextOut(TextPos.X + Ord(FPressed), TextPos.Y + Ord(FPressed), FCaption);
end;

procedure TClassicVBButton.Paint;
begin
  Canvas.Lock;
  try
    Canvas.Brush.Color := Color;
    Canvas.FillRect(ClientRect);
    DrawButton(Canvas);

    if FFocused and Enabled then
    begin
      Canvas.Pen.Style := psDot;
      Canvas.Pen.Color := clWindowText;
      Canvas.Brush.Style := bsClear;
      Canvas.Rectangle(3, 3, Width - 3, Height - 3);
    end;
  finally
    Canvas.Unlock;
  end;
end;

procedure TClassicVBButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  FPressed := True;
  Invalidate;
end;

procedure TClassicVBButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  FPressed := False;
  Invalidate;
  Click;
end;

procedure TClassicVBButton.DoEnter;
begin
  inherited DoEnter;
  FFocused := True;
  Invalidate;
end;

procedure TClassicVBButton.DoExit;
begin
  inherited DoExit;
  FFocused := False;
  Invalidate;
end;

procedure TClassicVBButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_SPACE) or (Key = VK_RETURN) then
  begin
    FPressed := True;
    Invalidate;
  end;
end;

procedure TClassicVBButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
  if (Key = VK_SPACE) or (Key = VK_RETURN) then
  begin
    FPressed := False;
    Invalidate;
    Click;
  end;
end;

end.