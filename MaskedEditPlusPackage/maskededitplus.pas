unit MaskedEditPlus;

// ALdo Marcio Soares - ams2kg@gmail.com - 08/06/2025
// Edit com máscara: Cpf, Cnpj, Cep, Currency, Data, Time, Telefone, Password e o padrão.

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, ExtCtrls, Graphics, LCLType, LCLIntf, LResources,
  Types, DateUtils, StrUtils, Math, Strings,
  FPImage, FPReadPNG, FPReadJPEG;

type
  TMaskedEditMode = (emDefault, emCpf, emCnpj, emCurrency, emPhone, emPassword, emDate, emCep, emTime);
  TMaskedEditDateFmt = (edDMY, edYMD, edMDY);

  { TMaskedEditPlus }

  TMaskedEditPlus = class(TCustomControl)
    FEdit: TEdit;
    FSpyButton: TPanel;

    private
      FBorderBottom: Boolean;
      FCharCase: TEditCharCase;
      FCurrencyPercent: Boolean;
      FDateFmt: TMaskedEditDateFmt;
      FEditMode: TMaskedEditMode;
      FBorderColor: TColor;
      FBorderRadius: Integer;
      FBorderStyle: TPenStyle;
      FBorderWidth: Integer;
      FCurrDecimals: integer;
      FCurrSymbol: string;
      FIsValid: Boolean;
      FMaxLength: Integer;
      FNumbersOnly: Boolean;
      FOnChange: TNotifyEvent;
      FOnClick: TKeyEvent;
      FOnEnter: TNotifyEvent;
      FOnExit: TNotifyEvent;
      FOnKeyDown: TKeyEvent;
      FOnKeyPress: TKeyPressEvent;
      FOnKeyUp: TKeyEvent;
      FOnMouseDown: TMouseEvent;
      FOnMouseEnter: TNotifyEvent;
      FOnMouseLeave: TNotifyEvent;
      FOnMouseMove: TMouseMoveEvent;
      FOnMouseUp: TMouseEvent;
      FPasswordSpy: Boolean;
      FPlaceholder: string;
      FReadOnly: Boolean;
      FText: string;
      FPasswordVisible: Boolean;
      FFocusColor: TColor;
      FFocusColorText: TColor;
      FTemFoco : Boolean;
      FCurrencyValue: Double;
      FHint, FHintTemp: String;
      FDateValue: TDate;
      FAlignment: TAlignment;
      FEditDefaultColor: TColor;
      FChangingText: Boolean;
      procedure AjustaShowPassword;
      procedure Configurar;
      procedure Entrando;
      function GetCharCase: TEditCharCase;
      function GetDateValue: TDate;
      function GetEditDefaultColor: TColor;
      function GetHint: string;
      procedure Saindo;
      function GetAlignment: TAlignment;
      function GetCurrencyValue: Double;
      function GetText: string;
      procedure SetAlignment(AValue: TAlignment);
      procedure SetBorderBottom(AValue: Boolean);
      procedure SetBorderColor(AValue: TColor);
      procedure SetBorderRadius(AValue: Integer);
      procedure SetBorderStyle(AValue: TPenStyle);
      procedure SetBorderWidth(AValue: Integer);
      procedure SetCharCase(AValue: TEditCharCase);
      procedure SetCurrDecimals(AValue: integer);
      procedure SetCurrencyPercent(AValue: Boolean);
      procedure SetCurrencyValue(AValue: Double);
      procedure SetCurrSymbol(AValue: string);
      procedure SetDateFmt(AValue: TMaskedEditDateFmt);
      procedure SetDateValue(AValue: TDate);
      procedure SetEditDefaultColor(AValue: TColor);
      procedure SetEditMode(AValue: TMaskedEditMode);
      procedure SetFocusedColor(AValue: TColor);
      procedure SetHint(AValue: string);
      procedure SetIsValid(AValue: Boolean);
      procedure SetMaxLength(AValue: Integer);
      procedure SetPlaceholder(AValue: string);
      procedure SetReadOnly(AValue: Boolean);
      procedure SetSPasswordSpy(AValue: Boolean);
      procedure SetText(AValue: string);
      procedure SpyIcon(Sender: TObject);
      procedure UpdatePlaceholder;
      procedure FormatInput;
      //currency
      function FormataCurrencyWithSimbol: string;
      function NumeroParaReal(valor: Real; const dec: Integer = 2; const bFormatoREAL: Boolean = True): String;
      function RealParaNumero(s: string): Double;
      function RemoveFormatacaoCurrency(s: string): string;
      function ReplaceStr(const S, Srch, Replace: string): string;
      procedure CampoCurrency(var key: Char; const bFormatoREAL: Boolean);
      procedure UpdateTextColorCurrency;

      procedure ValidaCPF;
      procedure ValidaCNPJ;
      procedure ValidaData;
      procedure ValidaTelefone;
      procedure ValidaTime;

      procedure SpyPassword(Sender: TObject);
      procedure SpyMouseEnter(Sender: TObject);
      procedure SpyMouseLeave(Sender: TObject);
    protected
      procedure Paint; override;
      procedure Resize; override;
      procedure SetFocus; override;

      procedure EditChange(Sender: TObject);
      procedure EditClick(Sender: TObject);
      procedure EditEnter(Sender: TObject);
      procedure EditExit(Sender: TObject);
      procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
      procedure EditKeyPress(Sender: TObject; var Key: char);
      procedure EditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure EditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure EditMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      procedure EditMouseEnter(Sender: TObject);
      procedure EditMouseLeave(Sender: TObject);
    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      property DateValue: TDate read GetDateValue write SetDateValue;
      procedure Clear;
      function IsValidCPF(ACPF: string = ''): Boolean;
      function IsValidCNPJ(ACNPJ: string = ''): Boolean;
      property IsValid: Boolean read FIsValid write SetIsValid;
      function FormataCurrency(AValue: Double; ADecimals: Integer = 2; bFormatoReal: Boolean = True): String;
      function FormataCPF(AValue: string): string;
      function FormataCNPJ(AValue: string): string;
      function FormataCEP(AValue: string): string;
      function FormataData(AValue: string; ADateFmt: TMaskedEditDateFmt = edDMY): string;
      function FormataTelefone(AValue: string): string;
      function FormataTime(AValue: string): string;
      function OnlyNumbers(const S: String): String;
      function TextUnformatted: string;
    published
      property Align;
      property Alignment: TAlignment read GetAlignment write SetAlignment;
      property Anchors;
      property CharCase: TEditCharCase read GetCharCase write SetCharCase default ecNormal;
      property Color;
      property Enabled;
      property Font;
      property Hint: string read GetHint write SetHint;
      property ParentFont;
      property ParentColor;
      property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
      property TabStop default True;
      property TabOrder;
      property ShowHint;
      property Visible;

      property OnClick;
      property OnChange: TNotifyEvent read FOnChange write FOnChange;
      property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
      property OnExit: TNotifyEvent read FOnExit write FOnExit;
      property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
      property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
      property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
      property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
      property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
      property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
      property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
      property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;

      property BorderColor: TColor read FBorderColor write SetBorderColor default clGray;
      property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 0;
      property BorderStyle: TPenStyle read FBorderStyle write SetBorderStyle default psSolid;
      property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 1;
      property BorderBottom: Boolean read FBorderBottom write SetBorderBottom default false;

      property CurrencyDecimals: integer read FCurrDecimals write SetCurrDecimals default 2;
      property CurrencySymbol: string read FCurrSymbol write SetCurrSymbol;
      property CurrencyValue: Double read GetCurrencyValue write SetCurrencyValue;
      property CurrencyPercent: Boolean read FCurrencyPercent write SetCurrencyPercent default false;
      property DateFmt: TMaskedEditDateFmt read FDateFmt write SetDateFmt;
      property MaxLength: Integer read FMaxLength write SetMaxLength default 0;
      property NumbersOnly: Boolean read FNumbersOnly write FNumbersOnly default false;
      property EditMode: TMaskedEditMode read FEditMode write SetEditMode;
      property DefaultColor: TColor read GetEditDefaultColor write SetEditDefaultColor default clDefault;
      property PasswordSpy: Boolean read FPasswordSpy write SetSPasswordSpy default false;
      property Placeholder: string read FPlaceholder write SetPlaceholder;
      property Text: string read GetText write SetText; //deprecated 'use Caption no lugar';
      property FocusedColor: TColor read FFocusColorText write SetFocusedColor default clGray;
  end;

procedure Register;

implementation

{ TMaskedEditPlus }

procedure Register;
begin
  {$I maskededitplus_icon.lrs}
  RegisterComponents('ModernUI',[TMaskedEditPlus]);
end;

constructor TMaskedEditPlus.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Width := 150;
  Height := 22;
  DoubleBuffered := True;
  ControlStyle := ControlStyle + [csAcceptsControls, csSetCaption];
  TabStop := True;
  Visible := True;

  FBorderColor := $00BCBEBF;
  FBorderRadius := 0;
  FBorderStyle := psSolid;
  FBorderWidth := 1;
  FBorderBottom:= false;

  FCurrDecimals := 2;
  FCurrSymbol := 'R$';
  FMaxLength := 0;
  FPasswordSpy := False;
  FText := '';
  FHint := '';
  FHintTemp := '';
  FEditMode := emDefault;
  FPasswordVisible := false;
  FTemFoco := False;
  FFocusColor := $D5FFFF;
  FFocusColorText := clBlue;
  FEditDefaultColor := clDefault; //clBtnFace;
  FDateFmt:= edDMY;
  FCurrencyValue := 0.0;
  FCurrencyPercent := False;
  FNumbersOnly := False;
  FIsValid := true;
  FAlignment := taLeftJustify;
  FChangingText := False;

  // Edit box
  FEdit := TEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.Align := alClient;
  Fedit.Alignment := taLeftJustify;
  FEdit.Anchors := [akTop, akLeft, akRight, akBottom];
  FEdit.AnchorSideLeft.Side := asrBottom;
  FEdit.AnchorSideRight.Side := asrBottom;
  FEdit.AnchorSideBottom.Side := asrBottom;
  FEdit.BorderSpacing.Left := 1;
  FEdit.BorderSpacing.Top := 1;
  FEdit.BorderSpacing.Right := 1;
  FEdit.BorderSpacing.Bottom := 1;
  FEdit.BorderSpacing.Around := 1;
  FEdit.BorderStyle := bsNone;
  FEDIT.Height := Height;
  FEdit.TabStop := True;
  FEdit.Text := FText;
  FEdit.ParentFont := True;
  Fedit.Color := FEditDefaultColor;
  FEdit.CharCase := FCharCase;
  FEdit.AutoSelect := False;
  FEdit.AutoSize := False;
  FEdit.OnClick := @EditClick;
  FEdit.OnEnter := @EditEnter;
  FEdit.OnExit := @EditExit;
  Fedit.OnChange := @EditChange;
  FEdit.OnKeyDown := @EditKeyDown;
  FEdit.OnKeyUp := @EditKeyUp;
  FEdit.OnKeyPress := @EditKeyPress;
  FEdit.OnMouseDown := @EditMouseDown;
  FEdit.OnMouseUp := @EditMouseUp;
  FEdit.OnMouseMove := @EditMouseMove;
  FEdit.OnMouseEnter := @EditMouseEnter;
  FEdit.OnMouseLeave := @EditMouseLeave;

  // botão à esquerda para ver/ocultar a senha
  FSpyButton := TPanel.Create(Self);
  FSpyButton.Parent := Self;
  FSpyButton.Align := alRight;
  FSpyButton.Anchors := [akTop, akRight, akBottom];
  FSpyButton.AnchorSideTop.Side := asrBottom;
  FSpyButton.AnchorSideRight.Side := asrBottom;
  FSpyButton.AnchorSideBottom.Side := asrBottom;
  FSpyButton.AnchorSideLeft.Side := asrBottom;
  FSpyButton.BevelOuter := bvNone;
  FSpyButton.BorderSpacing.Left := 0;
  FSpyButton.BorderSpacing.Top := 1;
  FSpyButton.BorderSpacing.Bottom := 1;
  FSpyButton.BorderSpacing.Right := 1;
  FSpyButton.BorderSpacing.Around := 1;
  FSpyButton.Visible := False;
  FSpyButton.Color := Color;
  FSpyButton.ControlStyle := FSpyButton.ControlStyle + [csOpaque]; // melhora desempenho;
  FSpyButton.Width := 20;
  FSpyButton.Caption := '';
  FSpyButton.Alignment := taCenter; // texto no centro horizontamente
  FSpyButton.Font.Color := clGray;
  FSpyButton.Cursor := crHandPoint; //crArrow;
  FSpyButton.Hint := '';
  FSpyButton.ShowHint := False;
  FSpyButton.BringToFront;
  FSpyButton.OnClick := @SpyPassword;
  FSpyButton.OnMouseEnter := @SpyMouseEnter;
  FSpyButton.OnMouseLeave := @SpyMouseLeave;
  FSpyButton.OnPaint := @SpyIcon;

  Configurar;
  Invalidate;
end;

destructor TMaskedEditPlus.Destroy;
begin
  if Assigned(FEdit) then FEdit.Free;
  if Assigned(FSpyButton) then FSpyButton.Free;
  inherited Destroy;
end;

function TMaskedEditPlus.IsValidCPF(ACPF: string): Boolean;
var
  i, Soma, Resto: Integer;
  Num: string;
begin
  if (ACPF.Trim = '') then ACPF := FEdit.Text;
  Num := OnlyNumbers(ACPF);
  if (Length(Num) <> 11) or (Num = StringOfChar(Num[1], 11)) then Exit(False);
  Soma := 0;
  for i := 1 to 9 do Soma := Soma + StrToInt(Num[i]) * (11 - i);
  Resto := (Soma * 10) mod 11;
  if Resto = 10 then Resto := 0;
  if Resto <> StrToInt(Num[10]) then Exit(False);
  Soma := 0;
  for i := 1 to 10 do Soma := Soma + StrToInt(Num[i]) * (12 - i);
  Resto := (Soma * 10) mod 11;
  if Resto = 10 then Resto := 0;
  Result := Resto = StrToInt(Num[11]);
end;

function TMaskedEditPlus.IsValidCNPJ(ACNPJ: string): Boolean;
const
  Peso1: array[1..12] of Integer = (5,4,3,2,9,8,7,6,5,4,3,2);
  Peso2: array[1..13] of Integer = (6,5,4,3,2,9,8,7,6,5,4,3,2);
var
  i, Soma, Resto: Integer;
  Num: string;
begin
  if (ACNPJ.Trim = '') then ACNPJ := FEdit.Text;
  Num := OnlyNumbers(ACNPJ);
  if (Length(Num) <> 14) or (Num = StringOfChar(Num[1], 14)) then Exit(False);
  Soma := 0;
  for i := 1 to 12 do Soma := Soma + StrToInt(Num[i]) * Peso1[i];
  Resto := Soma mod 11;
  if Resto < 2 then Resto := 0 else Resto := 11 - Resto;
  if Resto <> StrToInt(Num[13]) then Exit(False);
  Soma := 0;
  for i := 1 to 13 do Soma := Soma + StrToInt(Num[i]) * Peso2[i];
  Resto := Soma mod 11;
  if Resto < 2 then Resto := 0 else Resto := 11 - Resto;
  Result := Resto = StrToInt(Num[14]);
end;

function TMaskedEditPlus.FormataCurrency(AValue: Double; ADecimals: Integer = 2; bFormatoReal: Boolean = True): String;
// formata o valor para R$ -1.234,56
// FormatFloat(FCurrSymbol + '#,##0.' + StringOfChar('0', FCurrDecimals), FCurrencyValue);
begin
  Result := NumeroParaReal(AValue, ADecimals, bFormatoReal);
end;

function TMaskedEditPlus.FormataCPF(AValue: string): string;
//formata o Cpf
var
  Raw: string;
begin
  Raw := OnlyNumbers(AValue);
  if Length(Raw) > 11 then Delete(Raw, 12, MaxInt);
  if Length(Raw) >= 10 then
    Raw := Format('%s.%s.%s-%s', [Copy(Raw,1,3), Copy(Raw,4,3), Copy(Raw,7,3), Copy(Raw,10,2)])
  else if Length(Raw) >= 7 then
    Raw := Format('%s.%s.%s', [Copy(Raw,1,3), Copy(Raw,4,3), Copy(Raw,7)])
  else if Length(Raw) >= 4 then
    Raw := Format('%s.%s', [Copy(Raw,1,3), Copy(Raw,4)]);

  Result := Raw;
end;

function TMaskedEditPlus.FormataCNPJ(AValue: string): string;
//formata o Cnpj
var
  Raw: string;
begin
  Raw := OnlyNumbers(FEdit.Text);
  if Length(Raw) > 14 then Delete(Raw, 15, MaxInt);
  if Length(Raw) >= 13 then
    Raw := Format('%s.%s.%s/%s-%s', [Copy(Raw,1,2), Copy(Raw,3,3), Copy(Raw,6,3), Copy(Raw,9,4), Copy(Raw,13,2)])
  else if Length(Raw) >= 9 then
    Raw := Format('%s.%s.%s/%s', [Copy(Raw,1,2), Copy(Raw,3,3), Copy(Raw,6,3), Copy(Raw,9)])
  else if Length(Raw) >= 6 then
    Raw := Format('%s.%s.%s', [Copy(Raw,1,2), Copy(Raw,3,3), Copy(Raw,6)])
  else if Length(Raw) >= 3 then
    Raw := Format('%s.%s', [Copy(Raw,1,2), Copy(Raw,3)]);

  Result := Raw;
end;

function TMaskedEditPlus.FormataCEP(AValue: string): string;
//formata o Cep
var
  Raw: string;
begin
  Raw := OnlyNumbers(FEdit.Text);
  if Length(Raw) > 8 then Delete(Raw, 9, MaxInt);
  if Length(Raw) >= 6 then
    Raw := Format('%s-%s', [Copy(Raw,1,5), Copy(Raw,6,3)]);

  Result := Raw;
end;

function TMaskedEditPlus.FormataData(AValue: string; ADateFmt: TMaskedEditDateFmt = edDMY): string;
//formata a data
var
  Raw: string;
begin
  Raw := OnlyNumbers(AValue);
  case ADateFmt of
    edDMY: { dd/mm/yyyy }
      begin
        if Length(Raw) >= 5 then
          Raw := Format('%s/%s/%s', [Copy(Raw,1,2), Copy(Raw,3,2), Copy(Raw,5,4)])
        else if Length(Raw) >= 3 then
          Raw := Format('%s/%s', [Copy(Raw,1,2), Copy(Raw,3,2)])
        else if Length(Raw) >= 1 then
          Raw := Format('%s', [Copy(Raw,1,2)]);
      end;
    edYMD: { yyyy-mm-dd }
      begin
        if Length(Raw) >= 7 then
          Raw := Format('%s-%s-%s', [Copy(Raw,1,4), Copy(Raw,5,2), Copy(Raw,7,2) ])
        else if Length(Raw) >= 5 then
          Raw := Format('%s-%s', [Copy(Raw,1,4), Copy(Raw,5,2)])
        else if Length(Raw) >= 4 then
          Raw := Format('%s', [Copy(Raw,1,4)]);
      end;
    edMDY: { mm/dd/yyyy }
      begin
        if Length(Raw) >= 5 then
          Raw := Format('%s/%s/%s', [Copy(Raw,1,2), Copy(Raw,3,2), Copy(Raw,5,4)])
        else if Length(Raw) >= 3 then
          Raw := Format('%s/%s', [Copy(Raw,1,2), Copy(Raw,3,2)])
        else if Length(Raw) >= 1 then
          Raw := Format('%s', [Copy(Raw,1,2)]);
      end;
  end;

  Result := Raw;
end;

function TMaskedEditPlus.FormataTelefone(AValue: string): string;
//formata o telefone
var
  Raw: string;
begin
  Raw := OnlyNumbers(FEdit.Text);
  if Length(Raw) > 11 then Delete(Raw, 12, MaxInt);
  if Length(Raw) = 11 then
    Raw := Format('(%s) %s-%s', [Copy(Raw,1,2), Copy(Raw,3,5), Copy(Raw,8,4)])
  else if Length(Raw) = 10 then
    Raw := Format('(%s) %s-%s', [Copy(Raw,1,2), Copy(Raw,3,4), Copy(Raw,7,4)])
  else if Length(Raw) = 9 then
    Raw := Format('%s-%s', [Copy(Raw,1,5), Copy(Raw,6,4)])
  else if Length(Raw) = 8 then
    Raw := Format('%s-%s', [Copy(Raw,1,4), Copy(Raw,5,4)]);

  Result := Raw;
end;

function TMaskedEditPlus.FormataTime(AValue: string): string;
//formata o horário
var
  Raw: string;
begin
  Raw := OnlyNumbers(FEdit.Text);
  if Length(Raw) > 6 then Delete(Raw, 7, MaxInt);
  if Length(Raw) >= 5 then
    Raw := Format('%s:%s:%s', [Copy(Raw,1,2), Copy(Raw,3,2), Copy(Raw,5,2)])
  else if Length(Raw) >= 3 then
    Raw := Format('%s:%s', [Copy(Raw,1,2), Copy(Raw,3,2)])
  else if Length(Raw) >= 1 then
    Raw := Format('%s', [Copy(Raw,1,2)]);

  Result := Raw;
end;

function TMaskedEditPlus.TextUnformatted: string;
//remove a formatação do Text
begin
  case FEditMode of
    emCpf, emCnpj, emCep, emPhone:
      Result := OnlyNumbers(FEdit.Text);
    emCurrency:
      Result := RemoveFormatacaoCurrency(FEdit.Text).Replace('.','').Replace(',','.');
  else
    Result := FEdit.Text;
  end;
end;

procedure TMaskedEditPlus.Paint;
var
  R: TRect;
  cor: TColor;
begin
  inherited Paint;

  //desenha a borda do objeto
  if FBorderWidth > 0 then begin
    cor := FBorderColor;
    if FTemFoco then cor := clSkyBlue; // FFocusColorText;
    if not FIsValid then cor := clRed;

    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := cor;
    Canvas.Pen.Width := FBorderWidth;
    Canvas.Pen.Style := FBorderStyle;
    R := ClientRect;

    if FBorderBottom then begin
      Canvas.Pen.Width := 2;
      Canvas.MoveTo(R.Left+2, R.Bottom-1);
      Canvas.LineTo(R.Right-2, R.Bottom-1);
    end
    else
      if FBorderRadius > 0 then
        Canvas.RoundRect(R, FBorderRadius, FBorderRadius)
      else
        Canvas.Rectangle(R);
  end;
end;

procedure TMaskedEditPlus.Resize;
begin
  inherited Resize;
  if Height < 20 then Height := 20;
  if Width < 20 then Width := 20;
  Invalidate;
end;

procedure TMaskedEditPlus.SetFocus;
begin
  inherited SetFocus;
  if Assigned(FEdit) and FEdit.CanFocus then
    FEdit.SetFocus;
end;

procedure TMaskedEditPlus.Clear;
begin
  FText := '';
  FEdit.Text := '';
  FCurrencyValue := 0;
  FIsValid := True;
  Invalidate;
end;

function TMaskedEditPlus.GetAlignment: TAlignment;
begin
  if Assigned(FEdit) then begin
    Result := FEdit.Alignment;
  end else begin
    Result := taLeftJustify;
  end;
end;

function TMaskedEditPlus.GetCurrencyValue: Double;
begin
  Result := 0.00;
  if FEditMode = emCurrency then
    Result := RealParaNumero(FEdit.Text);
end;

function TMaskedEditPlus.GetText: string;
begin
  Result := FEdit.Text;
end;

procedure TMaskedEditPlus.SetAlignment(AValue: TAlignment);
begin
  if FEdit.Alignment = AValue then Exit;
  FAlignment := AValue;
  FEdit.Alignment := AValue;
end;

procedure TMaskedEditPlus.SetBorderBottom(AValue: Boolean);
begin
  if FBorderBottom = AValue then Exit;
  FBorderBottom := AValue;
  FBorderRadius := 0;
  Invalidate;
end;

procedure TMaskedEditPlus.SetBorderColor(AValue: TColor);
begin
  if FBorderColor = AValue then Exit;
  FBorderColor := AValue;
  Invalidate;
end;

procedure TMaskedEditPlus.SetBorderRadius(AValue: Integer);
begin
  if FBorderRadius = AValue then Exit;
  if AValue < 0 then AValue := 0;
  if (AValue > 0) and FBorderBottom then Exit;
  FBorderRadius := AValue;
  Invalidate;
end;

procedure TMaskedEditPlus.SetBorderStyle(AValue: TPenStyle);
begin
  if FBorderStyle = AValue then Exit;
  FBorderStyle := AValue;
  Invalidate;
end;

procedure TMaskedEditPlus.SetBorderWidth(AValue: Integer);
begin
  if FBorderWidth = AValue then Exit;
  if AValue<0 then AValue := 0;
  if AValue>3 then AValue := 3;
  FBorderWidth := AValue;
  Invalidate;
end;

procedure TMaskedEditPlus.SetCharCase(AValue: TEditCharCase);
begin
  if FCharCase = AValue then Exit;
  FCharCase := AValue;
  FEdit.CharCase := AValue;
end;

procedure TMaskedEditPlus.SetCurrDecimals(AValue: integer);
begin
  if FCurrDecimals = AValue then Exit;
  if AValue < 0 then AValue := 0;
  FCurrDecimals := AValue;
end;

procedure TMaskedEditPlus.SetCurrencyPercent(AValue: Boolean);
begin
  if FCurrencyPercent = AValue then Exit;
  FCurrencyPercent := AValue;
end;

procedure TMaskedEditPlus.SetCurrencyValue(AValue: Double);
begin
  if FEditMode <> emCurrency then Exit;
  FCurrencyValue := AValue;
  FEdit.Text := NumeroParaReal(AValue, FCurrDecimals);
  FEdit.Text := FormataCurrencyWithSimbol;
  FormatInput;
end;

procedure TMaskedEditPlus.SetCurrSymbol(AValue: string);
begin
  if FCurrSymbol = AValue then Exit;
  if Length(AValue)>3 then AValue := AValue.Substring(0, 3);
  FCurrSymbol := AValue;
end;

procedure TMaskedEditPlus.SetDateFmt(AValue: TMaskedEditDateFmt);
//altera o formato da data
begin
  if FDateFmt = AValue then Exit;
  ValidaData;
  FDateFmt := AValue;
  SetDateValue(FDateValue);
end;

procedure TMaskedEditPlus.SetDateValue(AValue: TDate);
//entra com a data
begin
  if FEditMode = emDate then begin
    case FDateFmt of
      edDMY: FEdit.Text := FormatDateTime('dd/mm/yyyy', AValue);
      edMDY: FEdit.Text := FormatDateTime('mm/dd/yyyy', AValue);
      edYMD: FEdit.Text := FormatDateTime('yyyy-mm-dd', AValue);
    end;
    FIsValid := True;
    FDateValue := AValue;
    FormatInput;
  end;
end;

procedure TMaskedEditPlus.SetEditDefaultColor(AValue: TColor);
begin
  if FEditDefaultColor = AValue then Exit;
  FEditDefaultColor := AValue;
  FEdit.Color := AValue;
end;

procedure TMaskedEditPlus.SetEditMode(AValue: TMaskedEditMode);
//modos do editor
begin
  if FEditMode = AValue then Exit;
  FEditMode := AValue;
  FPasswordVisible := False;

  if FEditMode = emPassword then
    FEdit.PasswordChar := '*'
  else
    FEdit.PasswordChar := #0;

  Configurar;
  AjustaShowPassword;
end;

procedure TMaskedEditPlus.SetFocusedColor(AValue: TColor);
begin
  if FFocusColorText = AValue then Exit;
  FFocusColorText := AValue;
  Invalidate;
end;

procedure TMaskedEditPlus.SetHint(AValue: string);
begin
  FHint := AValue;
  if (FHintTemp = '') and not (AValue.Contains('inválid')) then FHintTemp := AValue;
  inherited Hint := AValue; // propaga para TControl
end;

procedure TMaskedEditPlus.SetIsValid(AValue: Boolean);
begin
  if FIsValid = AValue then Exit;
  FIsValid := AValue;
  Invalidate;
end;

procedure TMaskedEditPlus.SetMaxLength(AValue: Integer);
begin
  if FMaxLength = AValue then Exit;
  FMaxLength := AValue;
  FEdit.MaxLength := AValue;
end;

procedure TMaskedEditPlus.SetPlaceholder(AValue: string);
begin
  if FPlaceholder = AValue then Exit;
  FPlaceholder := AValue;
  UpdatePlaceholder;
end;

procedure TMaskedEditPlus.SetReadOnly(AValue: Boolean);
begin
  if FReadOnly = AValue then Exit;
  FReadOnly := AValue;
  FEdit.ReadOnly := AValue;
  Invalidate;
end;

procedure TMaskedEditPlus.SetSPasswordSpy(AValue: Boolean);
begin
  if FPasswordSpy = AValue then Exit;
  FPasswordSpy := AValue;
end;

procedure TMaskedEditPlus.SetText(AValue: string);
begin
  FText := AValue;
  FEdit.Text := AValue;
  FIsValid := True;
  Configurar;
end;

procedure TMaskedEditPlus.UpdatePlaceholder;
begin
  if (FEdit.Text = '') and not FEdit.Focused then begin
    FEdit.PasswordChar := #0;
    FEdit.Alignment:= taLeftJustify;
    FEdit.TextHint := FPlaceholder;
  end else
    FEdit.Alignment:= FAlignment;

  AjustaShowPassword;
end;

procedure TMaskedEditPlus.FormatInput;
//cpf, cnpj, cep, currency, data, telefone
begin
  if FChangingText then Exit;

  FChangingText := True;

  if not FIsValid then
    FEdit.Font.Color := clRed
  else begin
    FEdit.Font.Color := Font.Color;
    if FTemFoco then FEdit.Font.Color := FFocusColorText;
  end;

  case FEditMode of
    emCurrency: { -1.235,79 }
      begin
        //formatação ocorre na "procedure CampoCurrency()"
        FEdit.Alignment := FAlignment;
        FEdit.SelStart := Length(FEdit.Text);
        FIsValid := True;
        UpdateTextColorCurrency;
      end;
    emCpf: { xxx.xxx.xxx-xx }
      begin
        FEdit.Text := FormataCPF(FEdit.Text);
        FEdit.SelStart := Length(FEdit.Text);
      end;
    emCnpj: { xx.xxx.xxx/xxxx-xx }
      begin
        FEdit.Text := FormataCNPJ(FEdit.Text);
        FEdit.SelStart := Length(FEdit.Text);
      end;
    emPhone: { (xx) 9xxxx-xxxx, (xx) xxxx-xxxx, 9xxxx-xxxx, xxxx-xxxx }
      begin
        FEdit.Text := FormataTelefone(FEdit.Text);
        FEdit.SelStart := Length(FEdit.Text);
      end;
    emCep:
      begin { 14781-260 }
        FEdit.Text := FormataCEP(FEdit.Text);
        FEdit.SelStart := Length(FEdit.Text);
      end;
    emDate: { dd/mm/yyyy, yyyy-mm-dd, mm/dd/yyyy }
      begin
        FEdit.Text := FormataData(FEdit.Text, FDateFmt);
        FEdit.SelStart := Length(FEdit.Text);
      end;
    emPassword:
      begin
        FAlignment := taLeftJustify;
        Fedit.Alignment := taLeftJustify;
        AjustaShowPassword;
        FEdit.SelStart := Length(FEdit.Text);
      end;
    emTime:
      begin
        ValidaTime;
        FEdit.Text := FormataTime(FEdit.Text);
        FEdit.SelStart := Length(FEdit.Text);
      end;
    emDefault:
      begin
        Fedit.Alignment := FAlignment;
        FEdit.MaxLength := FMaxLength;
        Fedit.NumbersOnly := FNumbersOnly;
      end
  end;

  FMaxLength := FEdit.MaxLength;
  FNumbersOnly := FEdit.NumbersOnly;
  FChangingText := False;
end;

function TMaskedEditPlus.OnlyNumbers(const S: String): String;
var
  c: Char;
begin
  Result := '';
  for c in S do
    if (c in ['0'..'9']) then Result := Result + c;
end;

function TMaskedEditPlus.ReplaceStr(const S, Srch, Replace: string): string;
// Substitui um valor por outro dentro da string
var
  i: Integer;
  Source: string;
begin
  Source := S;
  Result := '';

  repeat
    i := Pos(UpperCase(Srch), UpperCase(Source));
    if i > 0 then begin
      Result := Result + Copy(Source, 1, i - 1) + Replace;
      Source := Copy(Source, i + Length(Srch), MaxInt);
    end
    else
      Result := Result + Source;
  until i <= 0;
end;

function TMaskedEditPlus.NumeroParaReal(valor: Real; const dec: Integer; const bFormatoREAL: Boolean): String;
// converte o número para o formato Real(String).
// Exemplo: 2406.93 --> 2.406,93
var
  vlr: string;
begin
  vlr := FloatToStrF(valor, ffCurrency, 999, dec );
  vlr := RemoveFormatacaoCurrency(vlr);

  If (not bFormatoREAL) or (FCurrDecimals < 1) Then //'Não coloca "." separando as milhares
     vlr := ReplaceStr(vlr, ThousandSeparator, ''); //TFormatSettings

  Result := vlr;
end;

function TMaskedEditPlus.RealParaNumero(s: string): Double;
// Converte uma string em formato R$ em valor de ponto flutuante
var
  num: String;
  valor: Double;
  erro: Integer = 0;
  idiv : Float;
begin
  num := Trim(s);
  valor := 0.0;
  idiv := Power(10.0, FCurrDecimals);  // 10^x

  If num = '' Then num := '0';

  // Exemplo: 1.235,99 --> 1235.99
  num := RemoveFormatacaoCurrency(num);
  num := ReplaceStr(num, ',', 'p');
  num := ReplaceStr(num, '.', '');
  num := ReplaceStr(num, 'p', '.');

  // transforma em ponto número de flutuante
  Val(num, valor, erro);

  //valor := Round(valor * idiv) / idiv;
  valor := RoundTo(valor, -1 * FCurrDecimals);

  Result := valor;
end;

procedure TMaskedEditPlus.CampoCurrency(var key: Char; const bFormatoREAL: Boolean);
// processa a entrada Currency e formata
var
  vlr: String;
  sinal: String;
  valor: Double;
  erro: Integer = 0;
  idiv: Float;
begin
  try
     vlr := RemoveFormatacaoCurrency(FEdit.Text);

     If FCurrDecimals < 1 Then begin
       If Key = Chr(8) Then Exit;
       If Pos(Key, '-0123456789') = 0 Then key := Chr(0);
       If Length(vlr) >= FEdit.MaxLength Then key := Chr(0);
       FEdit.SelStart := Length(vlr);
     end;

     if key = Chr(0) then Exit;

     vlr := ReplaceStr(vlr, '.', ''); // remove separador de milhares
     sinal := '';
     idiv  := Power(10.0, FCurrDecimals);

     If Pos('-', vlr) >= 1 Then sinal := '-';

     vlr := ReplaceStr(vlr, '-', '');
     vlr := ReplaceStr(vlr, ',', '');

     Val(vlr, valor, erro);

     vlr := FloatToStr(valor);

     If Key = Chr(8) Then begin
       Key := Chr(0);
       If Length(vlr) > 0 Then vlr := Copy(vlr, 1, Length(vlr) -1);
     end
     else begin
       If Length(FEdit.Text) >= FEdit.MaxLength Then begin
         key := chr(0);
         Exit;
       end;

       If Pos(Key, '-0123456789') < 1 Then begin
         Key := chr(0);
         Exit;
       End;

       if Key = '-' then
         if sinal = '' then sinal := '-' else sinal := ''
       else
         vlr := vlr + Key;

       Key := chr(0);
     end;

     erro := 0;
     Val(vlr, valor, erro);

     if (valor = 0) and (sinal = '-') then sinal := '';

     vlr := FloatToStrF(valor/idiv, ffCurrency, 999, FCurrDecimals);

     vlr := RemoveFormatacaoCurrency(vlr);

     If (not bFormatoREAL) or (FCurrDecimals < 1) Then //'Não coloca "." separando as milhares
        vlr := ReplaceStr(vlr, '.', '');

     FEdit.Text := sinal + vlr;
     FEdit.SelStart := Length(FEdit.Text);
     key := chr(0);
     FCurrencyValue := valor;
     UpdateTextColorCurrency;
  except
  end;
end;

function TMaskedEditPlus.RemoveFormatacaoCurrency(s: string): string;
// remove a formatação ficando penas [-.,0123456789]
var
  c: Char;
begin
  Result := '';
  for c in s do
    if c in ['0'..'9', '-',',', '.'] then // 'A'..'Z'
      AppendStr(Result, c);
end;

function TMaskedEditPlus.FormataCurrencyWithSimbol: string;
//formata o valor currency com o simbolo monetário/percentual informado
//FormatFloat(FCurrSymbol + '#,##0.' + StringOfChar('0', FCurrDecimals), FCurrencyValue);
var
  simbolo: string;
begin
  // Formata o valor como moeda, usando o número de casas decimais especificado
  if (FEditMode = emCurrency) and (FCurrDecimals > 0) then begin
    simbolo := Trim(FCurrSymbol);

    if (simbolo <> '') then simbolo := simbolo + ' ';

    Result := NumeroParaReal(FCurrencyValue, FCurrDecimals, (FEditMode = emCurrency));

    if (Length(Result) + Length(simbolo) <= FEdit.MaxLength) then
       Result := simbolo + Result;
  end else
    Result := FEdit.Text;
end;

procedure TMaskedEditPlus.UpdateTextColorCurrency;
// se o valor for negativo, exibe na cor fermelha
begin
  // Define a cor do texto: vermelho para valores negativos,
  // cor padrão para valores não-negativos
  if FEditMode <> emCurrency then Exit;

  if (FCurrencyValue < 0) or (Pos('-', FEdit.Text) > 0) then
    FEdit.Font.Color := clRed
  else
    if FTemFoco then
      FEdit.Font.Color := FFocusColorText
    else
      FEdit.Font.Color := Font.Color; // clDefault é a cor padrão do sistema
end;

procedure TMaskedEditPlus.ValidaCPF;
//checa se o cpf informado é válido
begin
  Hint := FHintTemp;
  FIsValid := True;

  if (FEditMode = emCpf) and (Length(FEdit.Text)>0) and not IsValidCPF(FEdit.Text) then begin
    FEdit.Font.Color := clRed;
    Hint := 'CPF inválido';
    ShowHint := True;
    FIsValid := False;
  end;
end;

procedure TMaskedEditPlus.ValidaCNPJ;
//checa se o Cnpj informado é válido
begin
  Hint := FHintTemp;
  FIsValid := True;

  if (FEditMode = emCnpj) and (Length(FEdit.Text)>0) and not IsValidCNPJ(FEdit.Text) then begin
    FEdit.Font.Color := clRed;
    Hint := 'CNPJ inválido';
    ShowHint := True;
    FIsValid := False;
  end;
end;

procedure TMaskedEditPlus.ValidaData;
//checa se a data informada é váida
var
  s: array of string;
  a: string;
  b: Boolean;
  d,m,y: integer;
begin
  FDateValue := EncodeDate(1900,1,1);
  FIsValid := True;
  Hint := FHintTemp;

  if (FEditMode = emDate) and (Length(FEdit.Text)>0) then begin
    b := True;
    if Length(FEdit.Text) = 10 then begin
      a := FEdit.Text;

      case FDateFmt of
        edDMY: { dd/mm/yyyy }
          begin
            s := a.Split(['/'], TStringSplitOptions.ExcludeEmpty);
            d := StrToIntDef(s[0],0);
            m := StrToIntDef(s[1],0);
            y := StrToIntDef(s[2],0);
          end;
        edYMD: { yyyy-mm-dd }
          begin
            s := a.Split(['-'], TStringSplitOptions.ExcludeEmpty);
            y := StrToIntDef(s[0],0);
            m := StrToIntDef(s[1],0);
            d := StrToIntDef(s[2],0);
          end;
        edMDY: { mm/dd/yyyy }
          begin
            s := a.Split(['/'], TStringSplitOptions.ExcludeEmpty);
            m := StrToIntDef(s[0],0);
            d := StrToIntDef(s[1],0);
            y := StrToIntDef(s[2],0);
          end;
      end;

      if (d<1) or (d>31) then b := False;
      if (m=2) and (d>29) then b := False;
      if (m=2) and (y mod 4 <> 0) and (d>28) then b := False;
      if (m<1) or (m>12) then b := False;
      if (y<1) then b := False;

      if b then begin
        try
          FDateValue := EncodeDate(y, m, d);
          b := True;
        except
          b := False;
        end;
      end;

      SetLength(s, 0);
    end else
      b := False;

    if not b then begin
      FEdit.Font.Color := clRed;
      Hint := 'Data inválida';
      FIsValid := False;
      FDateValue := EncodeDate(1900,1,1);
    end;
  end;
end;

procedure TMaskedEditPlus.ValidaTelefone;
//checa se o telefone está no formatdo correto
begin
  Hint := FHintTemp;
  FIsValid := True;

  if (FEditMode = emPhone) and (Length(FEdit.Text) > 0) then begin
    if (Length(FEdit.Text) <> 11) and (Length(FEdit.Text) <> 9) and (Length(FEdit.Text) <> 8) then begin
      FEdit.Font.Color := clRed;
      Hint := 'Telefone inválido';
      ShowHint := True;
      FIsValid := False;
    end;
  end;
end;

procedure TMaskedEditPlus.ValidaTime;
//checa se o horário está correto hh:mm:ss
var
  s: array of string;
  a: string;
  b: Boolean;
  hh, mm, ss: integer;
  dt: TDateTime;
begin
  FIsValid := True;
  Hint := FHintTemp;

  if (FEditMode = emTime) and (Length(FEdit.Text)>0) then begin
    b := True;
    if Length(FEdit.Text) = 8 then begin
      a := FEdit.Text;
      s := a.Split([':'], TStringSplitOptions.ExcludeEmpty);
      hh := StrToIntDef(s[0],0);
      mm := StrToIntDef(s[1],0);
      ss := StrToIntDef(s[2],0);

      if (hh<0) or (hh>23) then b := False;
      if (mm<0) or (mm>59) then b := False;
      if (ss<0) or (ss>59) then b := False;

      if b then begin
        try
          dt := EncodeDateTime(1900, 1, 1, hh, mm, ss, 0);
          b := True;
        except
          b := False;
        end;
      end;

      SetLength(s, 0);
    end else
      b := False;

    if not b then begin
      FEdit.Font.Color := clRed;
      Hint := 'Horário inválido';
      FIsValid := False;
    end;
  end;
end;

procedure TMaskedEditPlus.Configurar;
// algumas configurações
begin
  case FEditMode of
    emCurrency:
      begin
        if FMaxLength = 0 then begin
          // R$ -999.999.999,99
          // 999.999.999.999,99
          FMaxLength := 18;
          if FCurrDecimals < 1 then FMaxLength := 10;
        end;

        if Length(FCurrSymbol) > 3 then
          FCurrSymbol := Trim(Copy(FCurrSymbol, 1, 3));

        if FCurrDecimals > 0 then
          FAlignment := taRightJustify
        else
          FCurrSymbol := '';

        FEdit.Alignment := FAlignment;
        FEdit.MaxLength := FMaxLength;
        FEdit.AutoSelect := False;
        FormatInput;
      end;
    emCpf, emCnpj:
      begin
        FCurrencyValue := 0;
        FAlignment := taRightJustify;

        if FEditMode = emCpf then FMaxLength := 14;
        if FEditMode = emCnpj then FMaxLength := 18;
        if FEditMode = emCpf then ValidaCPF;
        if FEditMode = emCnpj then ValidaCNPJ;

        FEdit.Alignment := FAlignment;
        FEdit.AutoSelect := False;
        FEdit.MaxLength := FMaxLength;
        FormatInput;
      end;
    emCep, emDate:
      begin
        FCurrencyValue := 0;
        FAlignment := taCenter;

        if FEditMode = emCep then FMaxLength := 9;
        if FEditMode = emDate then FMaxLength := 10;

        Fedit.Alignment := FAlignment;
        FEdit.AutoSelect := False;
        FEdit.MaxLength := FMaxLength;

        if FEditMode = emDate then ValidaData;
        FormatInput;
      end;
    emPhone:
      begin
        FCurrencyValue := 0;
        FAlignment := taLeftJustify;
        Fedit.Alignment := FAlignment;
        FEdit.AutoSelect := False;
        FEdit.MaxLength := 15;
        ValidaTelefone;
        FormatInput;
      end;
    emTime:
      begin
        FCurrencyValue := 0;
        FAlignment := taCenter;
        Fedit.Alignment := FAlignment;
        FEdit.AutoSelect := False;
        FEdit.MaxLength := 8;
        ValidaTime;
        FormatInput;
      end;
  else
    begin
      FCurrencyValue := 0;
      Fedit.Alignment := FAlignment;
      FormatInput;
    end;
  end;

  FEdit.Enabled := Enabled;
  FEdit.ReadOnly := ReadOnly;
  FMaxLength := FEdit.MaxLength;
end;

procedure TMaskedEditPlus.Entrando;
// algumas configurações no OnClick e OnEnter
begin
  Configurar;

  if not ReadOnly then begin
    FTemFoco := True;
    FEdit.Color := FFocusColor;
    FEdit.Font.Color := FFocusColorText;
  end;

  case FEditMode of
    emCurrency:
      begin
        FCurrencyValue := RealParaNumero(FEdit.Text);
        FText := RemoveFormatacaoCurrency(FEdit.Text);
        FEdit.Text := FText;
        FEdit.SelStart := Length(FEdit.Text);
        UpdateTextColorCurrency;
      end;
  end;

  AjustaShowPassword;
end;

function TMaskedEditPlus.GetCharCase: TEditCharCase;
begin
  Result := FEdit.CharCase;
end;

function TMaskedEditPlus.GetDateValue: TDate;
//retorna a data contida em Text
begin
  ValidaData;
  Result := FDateValue;
end;

function TMaskedEditPlus.GetEditDefaultColor: TColor;
begin
  Result := FEditDefaultColor;
end;

function TMaskedEditPlus.GetHint: string;
begin
  Result := FHint;
end;

procedure TMaskedEditPlus.Saindo;
// algumas configurações no OnExit
begin
  if ReadOnly or not Enabled then Exit;

  FTemFoco := False;

  case FEditMode of
    emCurrency:
      begin
        // Tenta converter o valor para Double ao sair do campo e aplica a formatação
        FCurrencyValue := RealParaNumero(FEdit.Text); //StrToFloat(Text);
        FEdit.Text := FormataCurrencyWithSimbol;
        UpdateTextColorCurrency; // Atualiza a cor do texto com base no valor atualizado
      end;
    emCpf:
      begin
        ValidaCPF;
        FormatInput;
      end;
    emCnpj:
      begin
        ValidaCNPJ;
        FormatInput;
      end;
    emPhone:
      begin
        FormatInput;
      end;
     emCep:
       begin
         FormatInput;
       end;
     emDate:
       begin
         ValidaData;
         FormatInput;
       end;
     emTime:
       begin
         ValidaTime;
         FormatInput;
       end;
  else
    begin
      FormatInput;
    end;
  end;

  FEdit.Color := FEditDefaultColor;
  UpdatePlaceholder;
end;

procedure TMaskedEditPlus.SpyPassword(Sender: TObject);
//click no olho
begin
  if FEditMode <> emPassword then Exit;
  if (FEdit.TextHint <> '') and (FEdit.Text = '') then Exit;
  FPasswordVisible := not FPasswordVisible;

  if FPasswordVisible then
    FEdit.PasswordChar := #0
  else
    FEdit.PasswordChar := '*';

  SetFocus;
  AjustaShowPassword;
end;

procedure TMaskedEditPlus.SpyMouseEnter(Sender: TObject);
begin
  Hint := '';
  FSpyButton.Font.Color := clBlue;
  FSpyButton.Color := FEdit.Color;
  FSpyButton.Repaint;
end;

procedure TMaskedEditPlus.SpyMouseLeave(Sender: TObject);
begin
  Hint := FHintTemp;
  FSpyButton.Font.Color := clGray; // clBtnText;
  FSpyButton.Color := FEdit.Color;
  FSpyButton.Repaint;
end;

procedure TMaskedEditPlus.SpyIcon(Sender: TObject);
//exibe olho aberto (True) ou fechado (False)
var
  FPic: TPicture;
begin
  FPic := TPicture.Create;
  try
    // carrega imagem do recurso Lazarus (spy_icon.lrs)
    if not FPasswordVisible then
      FPic.LoadFromLazarusResource('spy_show')
    else
      FPic.LoadFromLazarusResource('spy_hide');

    // desenha no canvas do Panel
    FSpyButton.Canvas.Draw(
      (FSpyButton.Width - FPic.Width) div 2,   // centraliza horizontal
      (FSpyButton.Height - FPic.Height) div 2, // centraliza vertical
      FPic.Graphic
    );
  finally
    FPic.Free;
  end;
end;

procedure TMaskedEditPlus.EditChange(Sender: TObject);
begin
  if FChangingText then Exit;
  FormatInput;

  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaskedEditPlus.EditClick(Sender: TObject);
begin
  if FReadOnly then Exit;
  FTemFoco := ((not ReadOnly) and Enabled); //true
  Entrando;
  Invalidate;
end;

procedure TMaskedEditPlus.EditEnter(Sender: TObject);
begin
  if FReadOnly then Exit;
  if Assigned(FOnEnter) then
    FOnEnter(Self);

  FTemFoco := ((not ReadOnly) and Enabled); //true
  Entrando;
  Invalidate;
end;

procedure TMaskedEditPlus.EditExit(Sender: TObject);
begin
  FTemFoco := False;
  Saindo;
  Invalidate;

  if Assigned(FOnExit) then
    FOnExit(Self);
end;

procedure TMaskedEditPlus.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if FReadOnly then Key := 0;
  FTemFoco := True;

  case FEditMode of
    emCpf, emCnpj, emCep, emCurrency, emDate, emPhone:
      begin
        if (Key = VK_LEFT) or (Key = VK_RIGHT) or (Key = VK_UP) or (Key = VK_DOWN) or
           (Key = VK_HOME) or (Key = VK_END) or (Key = VK_PRIOR) or (Key = VK_NEXT) then
        begin
          Key := 0; //invalida keys: up, down, left, right e outras
        end;
      end;
  end;

  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, Key, Shift);
end;

procedure TMaskedEditPlus.EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FTemFoco := True;

  if Assigned(FOnKeyUp) then
    FOnKeyUp(Self, Key, Shift);
end;

procedure TMaskedEditPlus.EditKeyPress(Sender: TObject; var Key: char);
begin
  FTemFoco := True;
  FIsValid := True;

  case FEditMode of
    emCurrency:
      CampoCurrency(Key, not FCurrencyPercent);
    emCpf, emCnpj, emPhone, emDate, emCep, emTime:
      begin
        If not (Key in ['0'..'9', #8]) Then Key := #0;
        if (Key <> #8) and (Length(OnlyNumbers(FEdit.Text)) >= FEdit.MaxLength) then Key := #0;
      end;
  end;

  if Assigned(FOnKeyPress) then
    FOnKeyPress(Self, Key);
end;

procedure TMaskedEditPlus.EditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TMaskedEditPlus.EditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TMaskedEditPlus.EditMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, Shift, X, Y);
end;

procedure TMaskedEditPlus.EditMouseEnter(Sender: TObject);
begin
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TMaskedEditPlus.EditMouseLeave(Sender: TObject);
begin
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TMaskedEditPlus.AjustaShowPassword;
// Ajusta o Edit para modo Password ou normal
var
  irecuo: Integer = 1;
begin
  if FEditMode <> emPassword then Exit;
  //if FBorderRadius > 0 then irecuo := FBorderRadius else irecuo := 1;
  FSpyButton.Visible := (FEditMode = emPassword) and FPasswordSpy and (FEdit.Text <> '');
  FSpyButton.Color := FEdit.Color;

  if FSpyButton.Visible then begin
    FEdit.BorderSpacing.Right := 0;
    FSpyButton.BorderSpacing.Right := irecuo;
  end
  else begin
    FEdit.BorderSpacing.Right := irecuo;
    FSpyButton.BorderSpacing.Right := 1;
  end;

  // não oculta o placeholder
  if (FEditMode = emPassword) and not FPasswordVisible then begin
    if (FEdit.Text = '') and (FEdit.TextHint <> '') then
      FEdit.PasswordChar := #0
    else
      FEdit.PasswordChar := '*';
  end;

  Invalidate;
end;

initialization
{$I spy_icon.lrs} //spy_show, spy_hide

end.
