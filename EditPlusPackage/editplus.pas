unit EditPlus;

// Edit Box com ícone à esquerda, borda colorida
// Aldo Márcio Soares

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LCLType, LCLIntf, LResources, Controls, ExtCtrls, StdCtrls, Graphics,
  Types, Buttons, EditExt, StrUtils, Math, Strings;

type

  { TEditPlus }

  TEditPlus = class(TCustomControl)
    FEdit: TEditExt;
    FSpyButton: TPanel;
  private
    FAlignment: TAlignment;
    FBorderLineStyle: TPenStyle;
    FBorderLineWidth: Integer;
    FBorderEnabled: Boolean;
    FBorderColor: TColor;
    FCornerRadius: Integer;
    FDarkTheme: Boolean;
    FCurSymbol: String;
    FDecimalPlaces: Integer;
    FFocusColorText: TColor;
    FIconBackColor: TColor;
    FIconTransparent: Boolean;
    FIsCurrency: Boolean;
    FMaxLength: Integer;
    FNumbersOnly: Boolean;
    FNumericValue: Double;
    FOnEnter: TNotifyEvent;
    FOnExit: TNotifyEvent;
    FRecuoRight: Integer;
    FHint, FHintTemp: String;
    FText: string;
    FCharCase: TEditCharCase;
    FEditDefaultColor: TColor;

    FIcon: TPicture;
    FIconStretch: Boolean;
    FIconVisible: Boolean;
    FIconWidth: Integer;
    FDefaultIconWidth: Integer;
    FImage: TImage;

    FReadOnly: Boolean;
    FPlaceholder: string;
    FPasswordChar: Char;
    FPasswordSpy: Boolean;
    FPasswordVisible: Boolean;

    FOnChange: TNotifyEvent;
    FOnClick: TKeyEvent;
    FOnKeyDown: TKeyEvent;
    FOnKeyUp: TKeyEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseUp: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;

    function GetAlignment: TAlignment;
    function GetCharCase: TEditCharCase;
    function GetCurSymbol: String;
    function GetDecimalPlaces: Integer;
    function GetEditDefaultColor: TColor;
    function GetHint: string;
    function GetIsCurrency: Boolean;
    function GetMaxLength: Integer;
    function GetNumericValue: Double;
    procedure SetAlignment(AValue: TAlignment);
    procedure SetBorderLineStyle(AValue: TPenStyle);
    procedure SetBorderLineWidth(AValue: Integer);
    procedure SetCharCase(AValue: TEditCharCase);
    procedure SetCurSymbol(AValue: String);
    procedure SetDarkTheme(AValue: Boolean);
    procedure SetDecimalPlaces(AValue: Integer);
    procedure SetEditDefaultColor(AValue: TColor);
    procedure SetFocusedColor(AValue: TColor);
    procedure SetHint(AValue: string);
    procedure SetIconBackColor(AValue: TColor);
    procedure SetIconStretch(AValue: Boolean);
    procedure SetIcon(const AValue: TPicture);
    procedure IconChanged(Sender: TObject);
    procedure SetIconTransparent(AValue: Boolean);
    procedure SetIconVisible(AValue: Boolean);
    procedure SetIconWidth(AValue: Integer);
    procedure SetIsCurrency(AValue: Boolean);
    procedure SetMaxLength(AValue: Integer);
    procedure SetNumbersOnly(AValue: Boolean);
    procedure SetNumericValue(AValue: Double);

    procedure SetPlaceholder(const AValue: string);
    procedure SetReadOnly(AValue: Boolean);
    procedure UpdatePlaceholder;

    procedure SetPasswordChar(AValue: Char);
    procedure SetShowPasswordToggle(AValue: Boolean);

    procedure SetBorderEnabled(AValue: Boolean);
    procedure SetBorderColor(AValue: TColor);
    procedure SetCornerRadius(AValue: Integer);

    procedure SpyPasswordClick(Sender: TObject);
    procedure SpyMouseEnter(Sender: TObject);
    procedure SpyMouseLeave(Sender: TObject);
    procedure SpyIcon(Sender: TObject);

    procedure UpdateStyles;

    function GetEditText: string;
    procedure SetEditText(const AValue: string);
    procedure AjustaShowPassword;
    procedure Configurar;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure SetFocus; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoEnter; override;
    procedure DoExit; override;

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

    procedure ImageMouseClick(Sender: TObject);
    procedure ImageMouseEnter(Sender: TObject);
    procedure ImageMouseLeave(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    { Retorna apenas os números contidos em Text }
    function GetNumbersOnly(const S: String = ''): String;
    { Retorna a parte inteira e positiva do Text }
    function TextToInteger: Int64;
  published
    property Align;
    property Anchors;
    property CharCase: TEditCharCase read GetCharCase write SetCharCase default ecNormal;
    property Color;
    property Font;
    property Hint: string read GetHint write SetHint;
    property ParentFont;
    property ParentColor;
    property TabStop default True;
    property TabOrder;
    property ShowHint;
    property Visible;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property Alignment: TAlignment read GetAlignment write SetAlignment default taLeftJustify;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick: TKeyEvent read FOnClick write FOnClick;
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

    property Text: string read GetEditText write SetEditText;
    property MaxLength: Integer read GetMaxLength write SetMaxLength default 0;
    property CurrencyMode: Boolean read GetIsCurrency write SetIsCurrency default False;
    property CurrencyValue: Double read GetNumericValue write SetNumericValue;
    property CurrentDecimals: Integer read GetDecimalPlaces write SetDecimalPlaces default 2;
    property CurrencySymbol: String read GetCurSymbol write SetCurSymbol;
    property Placeholder: string read FPlaceholder write SetPlaceholder;
    property NumbersOnly: Boolean read FNumbersOnly write SetNumbersOnly default false;
    property DefaultColor: TColor read GetEditDefaultColor write SetEditDefaultColor default clDefault;
    property FocusedColor: TColor read FFocusColorText write SetFocusedColor default clGray;

    property Icon: TPicture read FIcon write SetIcon;
    property IconVisible: Boolean read FIconVisible write SetIconVisible default True;
    property IconStretch: Boolean read FIconStretch write SetIconStretch default False;
    property IconWidth: Integer read FIconWidth write SetIconWidth default 27;
    property IconTransparent: Boolean read FIconTransparent write SetIconTransparent default False;
    property IconBackColor: TColor read FIconBackColor write SetIconBackColor default clWhite;

    property PasswordChar: Char read FPasswordChar write SetPasswordChar;
    property PasswordSpy: Boolean read FPasswordSpy write SetShowPasswordToggle;

    property BorderEnabled: Boolean read FBorderEnabled write SetBorderEnabled default True;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clGray;
    property BorderRadius: Integer read FCornerRadius write SetCornerRadius default 4;
    property BorderStyle: TPenStyle read FBorderLineStyle write SetBorderLineStyle default psSolid;
    property BorderWidth: Integer read FBorderLineWidth write SetBorderLineWidth default 1;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I editplus_icon.lrs}
  RegisterComponents('ModernUI',[TEditPlus]);
end;

{ TEditPlus }

constructor TEditPlus.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ControlStyle := ControlStyle + [csAcceptsControls, csSetCaption, csOpaque];
  DoubleBuffered := True;

  FEditDefaultColor := clWhite; //clBtnFace;
  Width := 150;
  Height := 32;
  TabStop := True;
  FAlignment := taLeftJustify;
  Color := FEditDefaultColor;

  FBorderEnabled := True;
  FBorderColor := $00BCBEBF;
  FCornerRadius := 4;
  FRecuoRight := 2;
  FBorderLineStyle := psSolid;
  FBorderLineWidth := 1;
  FHint := '';
  FHintTemp := '';
  FFocusColorText := clBlue;
  FNumbersOnly := False;

  FDefaultIconWidth := 27;
  FIconWidth := FDefaultIconWidth;
  FIconStretch := False;
  FIconVisible := True;
  FIconTransparent := False;
  FIconBackColor := clWhite;
  FPasswordVisible := False;

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
  FImage.BorderSpacing.Bottom := 0;
  FImage.BorderSpacing.Around := 0;
  FImage.Center := True;
  FImage.Stretch := FIconStretch;
  FImage.Visible := FIconVisible;
  FImage.OnClick := @ImageMouseClick;;
  FImage.OnMouseEnter := @ImageMouseEnter;
  FImage.OnMouseLeave := @ImageMouseLeave;

  // Edit box
  FEdit := TEditExt.Create(Self);
  FEdit.Parent := Self;
  Fedit.Alignment := taLeftJustify;
  FEdit.Anchors := [akLeft, akRight];
  FEdit.AnchorSideLeft.Side := asrLeft;
  FEdit.AnchorSideRight.Side := asrRight;
  FEdit.BorderStyle := bsNone;
  FEdit.TabStop := True;
  FEdit.CharCase := FCharCase;
  FEdit.Text := FText;
  FEdit.ParentFont := True;
  FEdit.ParentFont := True;
  Fedit.Color := FEditDefaultColor; //clBtnFace
  FEdit.AutoSelect := False;
  FEdit.AutoSize := True;
  FEdit.NumbersOnly := FNumbersOnly;
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
  FSpyButton.Color := clBtnFace;// Color;
  FSpyButton.ControlStyle := FSpyButton.ControlStyle + [csOpaque]; // melhora desempenho;
  FSpyButton.Width := 20;
  FSpyButton.Caption := '';
  FSpyButton.Alignment := taCenter; // texto no centro horizontamente
  FSpyButton.Font.Color := clGray;
  FSpyButton.Cursor := crHandPoint; //crArrow;
  FSpyButton.Hint := '';
  FSpyButton.ShowHint := False;
  FSpyButton.BringToFront;
  FSpyButton.OnClick := @SpyPasswordClick;
  FSpyButton.OnMouseEnter := @SpyMouseEnter;
  FSpyButton.OnMouseLeave := @SpyMouseLeave;
  FSpyButton.OnPaint := @SpyIcon;

  Color := FEdit.Color;
  Invalidate;
end;

destructor TEditPlus.Destroy;
begin
  FIcon.Free;
  FreeAndNil(FImage);
  FreeAndNil(FEdit);
  FreeAndNil(FSpyButton);
  inherited Destroy;
end;

procedure TEditPlus.Clear;
begin
  FText := '';

  if FEdit.NumbersOnly then
    FEdit.Text := '0'
  else
    FEdit.Clear;

  FNumericValue := 0;
  Invalidate;
end;

function TEditPlus.GetNumbersOnly(const S: String): String;
//retorna apenas números
var
  c: Char;
  v: string;
begin
  Result := '';
  v := S;
  if (v = '') then v := FEdit.Text;

  for c in v do
    if (c in ['0'..'9']) then Result := Result + c;
end;

function TEditPlus.TextToInteger: Int64;
//retorna o conteúdo numérico de Text para Integer
var
  v: string;
  i: integer;
begin
  Result := 0;

  if FIsCurrency then
  begin
    v := FloatToStr( CurrencyValue );
    i := Pos(DefaultFormatSettings.DecimalSeparator, v);
    if i > 0 then v := LeftStr(v, i-1);
    Result := StrToInt64Def( GetNumbersOnly(v), 0);
  end
  else
    Result := StrToInt64Def( GetNumbersOnly(), 0);
end;

procedure TEditPlus.SetIcon(const AValue: TPicture);
// Carrega o ícone
begin
  if Assigned(FIcon) then
    FIcon.Assign(AValue);
end;

procedure TEditPlus.IconChanged(Sender: TObject);
// define/exibe a Picture
begin
  FImage.Picture := FIcon;
  Invalidate;
end;

procedure TEditPlus.SetIconTransparent(AValue: Boolean);
begin
  if FIconTransparent = AValue then Exit;
  FIconTransparent := AValue;
  Invalidate;
end;

procedure TEditPlus.SetIconVisible(AValue: Boolean);
// visibilidade do ícone
begin
  if FIconVisible = AValue then Exit;
  FIconVisible := AValue;
  FImage.Visible := FIconVisible;

  Invalidate;
end;

procedure TEditPlus.SetIconStretch(AValue: Boolean);
// se o ícone poderá ser expandido
begin
  if FIconStretch = AValue then Exit;
  FIconStretch := AValue;
  FImage.Stretch := AValue;
  Invalidate;
end;

procedure TEditPlus.SetIconWidth(AValue: Integer);
// largura do ícone
begin
  if FIconWidth = AValue then Exit;
  FIconWidth := AValue;
  if (FIconWidth < 0) then FIconWidth := 0;
  if (FIconWidth <= 0) and FIconVisible then FIconWidth := FDefaultIconWidth;
  FImage.Width := FIconWidth;
  Invalidate;
end;

procedure TEditPlus.SetBorderLineStyle(AValue: TPenStyle);
// tipo de borda deste componente
begin
  if FBorderLineStyle = AValue then Exit;
  FBorderLineStyle := AValue;
  Invalidate;
end;

procedure TEditPlus.SetBorderLineWidth(AValue: Integer);
// largura da borda deste componente
begin
  if FBorderLineWidth = AValue then Exit;
  FBorderLineWidth := AValue;
  Invalidate;
end;

procedure TEditPlus.SetCharCase(AValue: TEditCharCase);
begin
  if FCharCase = AValue then Exit;
  FCharCase := AValue;
  FEdit.CharCase := AValue;
end;

function TEditPlus.GetCurSymbol: String;
// simbolo do Currency do Edit (R$ ou vazio)
begin
  FCurSymbol := FEdit.NumCurrencySymbol;
  Result := FCurSymbol;
end;

function TEditPlus.GetAlignment: TAlignment;
// alinhamento do texto no Edit
begin
  FAlignment := FEdit.Alignment;
  Result := FAlignment;
end;

function TEditPlus.GetCharCase: TEditCharCase;
begin
  Result := FEdit.CharCase;
end;

function TEditPlus.GetDecimalPlaces: Integer;
// casas decimais para Currency no Edit
begin
  FDecimalPlaces := FEdit.NumDecimalPlaces;
  Result := FDecimalPlaces;
end;

function TEditPlus.GetEditDefaultColor: TColor;
begin
  Result := FEditDefaultColor;
end;

function TEditPlus.GetHint: string;
begin
  Result := FHint;
end;

function TEditPlus.GetIsCurrency: Boolean;
// define se entra em edição em modo monetário/currenty
begin
  FIsCurrency := FEdit.NumIsCurrency;
  Result := FIsCurrency;
end;

function TEditPlus.GetMaxLength: Integer;
// quantidade máxima de caracteres no Edit
begin
  FMaxLength := FEdit.MaxLength;
  Result := FMaxLength;
end;

function TEditPlus.GetNumericValue: Double;
// retorna o valor numérico do Currency no Edit
begin
  FNumericValue := FEdit.NumCurrencyValue;
  Result := FNumericValue;
end;

procedure TEditPlus.SetAlignment(AValue: TAlignment);
// define o alinhamento do texto no Edit
begin
  if FAlignment = AValue then Exit;
  FAlignment := AValue;
  FEdit.Alignment := AValue;
end;

procedure TEditPlus.SetCurSymbol(AValue: String);
// define o simbolo do valor currency (R$ ou vazio)
begin
  if FCurSymbol = AValue then Exit;
  FCurSymbol := AValue;
  FEdit.NumCurrencySymbol := AValue;
end;

procedure TEditPlus.SetDarkTheme(AValue: Boolean);
// Define entre modo escuro e claro
begin
  if FDarkTheme = AValue then Exit;
  FDarkTheme := AValue;
  UpdateStyles;
end;

procedure TEditPlus.SetDecimalPlaces(AValue: Integer);
// define quantidade de casas decimais do Currency no edit
begin
  if FDecimalPlaces = AValue then Exit;
  FDecimalPlaces := AValue;
  FEdit.NumDecimalPlaces := AValue;
end;

procedure TEditPlus.SetEditDefaultColor(AValue: TColor);
begin
  if FEditDefaultColor = AValue then Exit;
  FEditDefaultColor := AValue;
  FEdit.Color := AValue;
end;

procedure TEditPlus.SetFocusedColor(AValue: TColor);
begin
  if FFocusColorText = AValue then Exit;
  FFocusColorText := AValue;
  Invalidate;
end;

procedure TEditPlus.SetHint(AValue: string);
begin
  FHint := AValue;
  if (FHintTemp = '') and not (AValue.Contains('inválid')) then FHintTemp := AValue;
  inherited Hint := AValue; // propaga para TControl
end;

procedure TEditPlus.SetIconBackColor(AValue: TColor);
begin
  if FIconBackColor = AValue then Exit;
  FIconBackColor := AValue;
  Invalidate;
end;

procedure TEditPlus.SetIsCurrency(AValue: Boolean);
// define modo Currency/Normal no Edit
begin
  if FIsCurrency = AValue then Exit;

  FIsCurrency := AValue;
  Configurar;
  AjustaShowPassword;
end;

procedure TEditPlus.SetMaxLength(AValue: Integer);
// define quantidade de caracteres no Edit
begin
  if FMaxLength = AValue then Exit;
  FMaxLength := AValue;
  FEdit.MaxLength := FMaxLength;
end;

procedure TEditPlus.SetNumbersOnly(AValue: Boolean);
begin
  if FNumbersOnly = AValue then Exit;
  FNumbersOnly := AValue;
  FEdit.NumbersOnly := FNumbersOnly;
end;

procedure TEditPlus.SetNumericValue(AValue: Double);
// define o valor numérico do currency no Edit
begin
  if FNumericValue = AValue then Exit;
  FNumericValue := AValue;
  FEdit.NumCurrencyValue := AValue;
end;

function TEditPlus.GetEditText: string;
// retorna o texto do Edit
begin
  Result := FEdit.Text;
end;

procedure TEditPlus.SetEditText(const AValue: string);
// define o texto no Edit
begin
  FText := AValue;

  if FEdit.NumbersOnly and (AValue = '') then
    FEdit.Text := '0'
  else
    FEdit.Text := AValue;

  FPasswordVisible := False;
  Configurar;
  AjustaShowPassword;
end;


procedure TEditPlus.AjustaShowPassword;
// Ajusta o Edit para modo Password ou normal
var
  irecuo: Integer = 1;
begin
  FSpyButton.Visible := (FPasswordChar <> #0) and FPasswordSpy and (FEdit.Text <> '');
  FSpyButton.Color := FEdit.Color;

  if FSpyButton.Visible then begin
    FEdit.BorderSpacing.Right := 0;
    FSpyButton.BorderSpacing.Right := irecuo;
  end
  else begin
    FEdit.BorderSpacing.Right := irecuo;
    FSpyButton.BorderSpacing.Right := 2;
  end;

  // não oculta o placeholder
  if (FPasswordChar <> #0) and not FPasswordVisible then begin
    if (FEdit.Text = '') and (FEdit.TextHint <> '') then
      FEdit.PasswordChar := #0
    else
      FEdit.PasswordChar := '*';
  end;

  Color := FEdit.Color;
  Invalidate;
end;

procedure TEditPlus.Configurar;
//ajusta a entrada de dados
begin
  if FIsCurrency then begin
    FAlignment := taRightJustify;
    FPasswordVisible := False;
    FPasswordChar := #0;
    FPasswordSpy := False;
  end
  else begin
    FAlignment := taLeftJustify;
    FNumericValue := 0;
  end;

  FEdit.Alignment := FAlignment;
  FEdit.PasswordChar := FPasswordChar;
  Color := FEdit.Color;
end;

procedure TEditPlus.SetPlaceholder(const AValue: string);
begin
  if FPlaceholder = AValue then Exit;
  FPlaceholder := AValue;
  UpdatePlaceholder;
end;

procedure TEditPlus.SetReadOnly(AValue: Boolean);
begin
  if FReadOnly = AValue then Exit;
  FReadOnly := AValue;
  FEdit.ReadOnly := AValue;
end;

procedure TEditPlus.UpdatePlaceholder;
begin
  if (FEdit.TextHint = '') then Exit;
  if (FEdit.Text = '') and not FEdit.Focused then begin
    FEdit.PasswordChar := #0;
    FEdit.Alignment:= taLeftJustify;
    FEdit.TextHint := FPlaceholder;
  end else
    FEdit.Alignment:= FAlignment;

  AjustaShowPassword;
end;

procedure TEditPlus.EditEnter(Sender: TObject);
begin
  if FReadOnly then Exit;
  if Assigned(FOnEnter) then
    FOnEnter(Self);

  FSpyButton.Color := FEdit.Color;
  AjustaShowPassword;
end;

procedure TEditPlus.EditExit(Sender: TObject);
begin
  FPasswordVisible := False;
  UpdatePlaceholder;
  FSpyButton.Color := clBtnFace; //Color;

  if Assigned(FOnExit) then
    FOnExit(Self);
end;

procedure TEditPlus.EditChange(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Self);

  AjustaShowPassword;
end;

procedure TEditPlus.EditClick(Sender: TObject);
begin
  //Click;
  if FReadOnly then Exit;

  if (FPasswordChar <> #0) then begin
    FSpyButton.Color := FEdit.Color;
  end;

  Invalidate;
end;

procedure TEditPlus.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_TAB) and (ssShift in Shift) then //Shift Tab
  begin
    Key := 0;
    Parent.SelectNext(Self, False, True); //ir para o controle anterior no parent
    Exit;
  end;

  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, Key, Shift);
end;

procedure TEditPlus.EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyUp) then
    FOnKeyUp(Self, Key, Shift);
end;

procedure TEditPlus.EditKeyPress(Sender: TObject; var Key: char);
begin
  if Assigned(FOnKeyPress) then
    FOnKeyPress(Self, Key);
end;

procedure TEditPlus.EditMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TEditPlus.EditMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TEditPlus.EditMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, Shift, X, Y);
end;

procedure TEditPlus.EditMouseEnter(Sender: TObject);
begin
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TEditPlus.EditMouseLeave(Sender: TObject);
begin
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TEditPlus.ImageMouseClick(Sender: TObject);
begin
  SetFocus;
end;

procedure TEditPlus.ImageMouseEnter(Sender: TObject);
begin
  if Assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TEditPlus.ImageMouseLeave(Sender: TObject);
begin
  if Assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TEditPlus.SetPasswordChar(AValue: Char);
begin
  if (AValue <> #0) then
    SetIsCurrency(False);

  FPasswordChar := AValue;
  Configurar;
  AjustaShowPassword;
end;

procedure TEditPlus.SetShowPasswordToggle(AValue: Boolean);
begin
  FPasswordSpy := AValue;
  AjustaShowPassword;
end;

procedure TEditPlus.UpdateStyles;
begin
  if FDarkTheme then
  begin
    Color := clBlack;
    FEdit.Color := clBlack;
    FEdit.Font.Color := clWhite;
    BorderColor := clGray;
  end
  else
  begin
    Color := clWhite;
    FEdit.Color := clWhite;
    FEdit.Font.Color := clBlack;
    BorderColor := clSilver;
  end;
  Invalidate;
end;

procedure TEditPlus.SetBorderEnabled(AValue: Boolean);
begin
  if FBorderEnabled <> AValue then
  begin
    FBorderEnabled := AValue;
    Invalidate;
  end;
end;

procedure TEditPlus.SetBorderColor(AValue: TColor);
begin
  if FBorderColor <> AValue then
  begin
    FBorderColor := AValue;
    Invalidate;
  end;
end;

procedure TEditPlus.SetCornerRadius(AValue: Integer);
begin
  if FCornerRadius <> AValue then
  begin
    FCornerRadius := AValue;
    if FCornerRadius > 0 then
      FRecuoRight := 3
    else
      FRecuoRight := 2;

    Invalidate;
  end;
end;

procedure TEditPlus.SpyPasswordClick(Sender: TObject);
//click no olho
begin
  if (FPasswordChar = #0) then Exit;
  if (FEdit.TextHint <> '') and (FEdit.Text = '') then Exit;
  FPasswordVisible := not FPasswordVisible;

  if (FEdit.Text <> '') then begin
    if FPasswordVisible then
      FEdit.PasswordChar := #0
    else
      FEdit.PasswordChar := '*';
  end;

  Invalidate;
end;

procedure TEditPlus.SpyMouseEnter(Sender: TObject);
begin
  Hint := '';
  FSpyButton.Font.Color := clBlue;
  FSpyButton.Color := FEdit.Color;
  FSpyButton.Repaint;
end;

procedure TEditPlus.SpyMouseLeave(Sender: TObject);
begin
  Hint := FHintTemp;
  FSpyButton.Font.Color := clGray; // clBtnText;
  FSpyButton.Color := FEdit.Color;
  FSpyButton.Repaint;
end;

procedure TEditPlus.SpyIcon(Sender: TObject);
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

procedure TEditPlus.Resize;
var
  lpos, lwidth: integer;

begin
  inherited Resize;

  if Height < 20 then Height := 20;
  if Width < 20 then Width := 20;

  if Assigned(FEdit) then begin
    lwidth := ClientWidth;
    if FImage.Visible then lwidth := lwidth - FImage.Width;
    if FSpyButton.Visible then lwidth := lwidth - FSpyButton.Width;

    if FImage.Visible then lpos := FImage.Left + FImage.Width else lpos := 0;

    if FEdit.Height >= Height then Height := FEdit.Height + 4;

    FEdit.Top := (ClientHeight - FEdit.Height) div 2;
    FEdit.Left := lpos + 3;
    FEdit.Width := lwidth - 6;
  end;

  Invalidate;
end;

procedure TEditPlus.SetFocus;
begin
  inherited SetFocus;
  if Assigned(FEdit) and FEdit.CanFocus then
    FEdit.SetFocus;
end;

procedure TEditPlus.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);

  if Button = mbLeft then begin
    SetFocus;
    Color := FEdit.Color;
    Invalidate;
  end;
end;

procedure TEditPlus.DoEnter;
begin
  //inherited DoEnter;
  if FReadOnly then Exit;
  if Assigned(FOnEnter) then
    FOnEnter(Self);

  Color := FEdit.Color;
  Invalidate;
end;

procedure TEditPlus.DoExit;
begin
  //inherited DoExit;
  if Assigned(FOnExit) then
    FOnExit(Self);

  Color := FEdit.Color;
  Invalidate;
end;

procedure TEditPlus.Paint;
var
  R: TRect;
  cor: TColor;
  lLeft: integer;
begin
  inherited Paint;

  Self.Cursor := crIBeam;

  //para evitar "fantasmas" nos cantos
  Canvas.Brush.Color := Parent.Color;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  //cor do fundo do componente
  cor := FEditDefaultColor;

  if not Enabled then begin
    cor := TColor($00E7E7E7);
    Self.Cursor := crDefault;
  end;

  //desenha a borda do objeto
  Canvas.Brush.Color := cor;

  if FBorderEnabled then begin
    R := ClientRect;
    Canvas.Pen.Color := FBorderColor;
    Canvas.Pen.Width := FBorderLineWidth;
    Canvas.Pen.Style := FBorderLineStyle;
    //R := Rect(0, 0, Width - 1, Height - 1);

    if FCornerRadius > 0 then
      Canvas.RoundRect(R, FCornerRadius, FCornerRadius)
    else
      Canvas.Rectangle(R);
  end
  else
    Canvas.Rectangle(ClientRect);

  lLeft := 1;

  // pinta o fundo da área do ícone
  if (FIconVisible) and (FIconWidth > 0) and (not FIconTransparent) then begin
    R := ClientRect;
    R.Top := R.Top + 1;
    R.Left := R.Left + 1;
    R.Width := FImage.Width;
    R.Height := R.Height - 2;
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := FIconBackColor;
    Canvas.FillRect(R);
    lLeft := FEdit.Left;
  end;

  if not Enabled then
    cor := TColor($00E7E7E7)
  else
    cor := FEdit.Color;

  //pinta o fundo do Edit
  R := ClientRect;
  R.Top := R.Top + 1;
  R.Left := lLeft;
  R.Bottom := R.Bottom - 1;
  R.Width := FEdit.Width + 1;
  Canvas.Pen.Style := psClear;
  Canvas.Brush.Color := cor;
  Canvas.Brush.Style := bsSolid;
  Canvas.Rectangle(R);

  //redesenha a borda novamente
  Canvas.Brush.Style := bsClear;

  if FBorderEnabled then begin
    cor := FBorderColor;
    if FEdit.Focused then cor := clSkyBlue;

    R := ClientRect;
    Canvas.Pen.Color := cor;
    Canvas.Pen.Width := FBorderLineWidth;
    Canvas.Pen.Style := FBorderLineStyle;

    if FCornerRadius > 0 then
      Canvas.RoundRect(R, FCornerRadius, FCornerRadius)
    else
      Canvas.Rectangle(R);
  end
  else
    Canvas.Rectangle(ClientRect);
end;

initialization
{$I spy_icon.lrs}

end.
