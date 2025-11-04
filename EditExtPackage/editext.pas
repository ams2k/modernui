{
 EditExt
 Edit com opção para entrada de valores númericos inteiro e monetário
}

unit EditExt;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, Graphics, Controls, StrUtils, Math, Strings;

type

  { TEditExt }

  TEditExt = class(TEdit)
  private
    FCurSymbol: String;
    FFocusColor: TColor;
    FTemFoco : Boolean;
    FDefaultColor: TColor;
    FDefaultFontColor: TColor;
    FFocusColorText: TColor;
    FIsCurrency: Boolean;
    FNumericValue: Double;
    FDecimalPlaces: Integer;
    FOnClick: TNotifyEvent;
    procedure SetCurSymbol(AValue: String);
    procedure SetIsCurrency(AValue: Boolean);
    procedure SetNumericValue(AValue: Double);
    procedure SetDecimalPlaces(AValue: Integer);
    procedure UpdateTextColor;
    function FormatValue: String;
    function ReplaceStr(const S, Srch, Replace: string): string;
    function NumeroParaReal(valor: Real; const dec: Integer = 2; const bFormatoREAL: Boolean = True): String;
    function RealParaNumero(s: string): Real;
    procedure CampoValor(var key: Char; const bFormatoREAL: Boolean = True);
    procedure Configurar;
    function RemoveFormatacao(s: string): string;
  protected
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure Click; override; // Sobrescreve o método Click
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    // exibe na paleta de propriedade
    property FocusColor: TColor read FFocusColor write FFocusColor;
    property FocusColorText: TColor read FFocusColorText write FFocusColorText;
    property NumIsCurrency: Boolean read FIsCurrency write SetIsCurrency default false;
    property NumCurrencyValue: Double read FNumericValue write SetNumericValue;
    property NumDecimalPlaces: Integer read FDecimalPlaces write SetDecimalPlaces default 2;
    property NumCurrencySymbol: String read FCurSymbol write SetCurSymbol;
    property OnClick: TNotifyEvent read FOnClick write FOnClick; // Propriedade para o evento OnClick
  end;

procedure Register;

implementation

uses
  LCLType, LResources;

procedure Register;
begin
  {$I editext_icon.lrs}
  RegisterComponents('ModernUI',[TEditExt]);
end;

constructor TEditExt.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //R$ 99.999.999,99 = 13 + 3 = 16 caracteres
  Configurar;

  FDefaultColor := clWhite;
  FFocusColor := TColor($D5FFFF);
  FFocusColorText := clBlue;
  FDefaultFontColor := Font.Color; //clDefault;
  FCurSymbol := ''; // 'R$'
  FNumericValue := 0.00;
  FDecimalPlaces := 2; // Define 2 casas decimais como padrão
  Text := FormatValue; // Exibe o valor inicial formatado
  UpdateTextColor;     // Atualiza a cor do texto inicial
end;

procedure TEditExt.SetNumericValue(AValue: Double);
// recebe o valor
begin
  if (FNumericValue <> AValue) then
  begin
    Configurar;
    FNumericValue := AValue;
    Text := FormatValue; // Atualiza o campo de texto com a formatação monetária
    UpdateTextColor;     // Atualiza a cor do texto com base no valor
  end;
end;

procedure TEditExt.SetIsCurrency(AValue: Boolean);
// define se é currency
begin
  Configurar;
  if (FIsCurrency = AValue) then Exit;
  FIsCurrency := AValue;
  NumbersOnly := False;
end;

procedure TEditExt.SetCurSymbol(AValue: String);
// define a exibição do símbolo monetário R$
begin
  if (FCurSymbol = AValue) then Exit;
  FCurSymbol := Trim(AValue);
  if (Length(FCurSymbol) > 3) then FCurSymbol := Copy(FCurSymbol, 1, 3);
  Configurar;
end;

procedure TEditExt.SetDecimalPlaces(AValue: Integer);
// define a quantidade de casas decimais
begin
  if (AValue < 0) or (AValue > 4) then AValue := 2;
  if (AValue >= 0) and (AValue <> FDecimalPlaces) then
  begin
    FDecimalPlaces := AValue;
    Configurar;
    Text := FormatValue; // Atualiza o campo de texto para aplicar o novo número de casas decimais
  end;
end;

procedure TEditExt.UpdateTextColor;
// se o valor for negativo, exibe na cor fermelha
begin
  // Define a cor do texto: vermelho para valores negativos,
  // cor padrão para valores não-negativos
  if not FIsCurrency then Exit;

  if (FNumericValue < 0) or (Pos('-', Text) > 0) then
    Font.Color := clRed
  else begin
    if FTemFoco then
      Font.Color := FFocusColorText
    else
      Font.Color := FDefaultFontColor; // clDefault é a cor padrão do sistema
  end;
end;

function TEditExt.FormatValue: String;
// format o conteúdo do campo text quando o foco sair do campo
var
  simbolo: string;
begin
  // Formata o valor como moeda, usando o número de casas decimais especificado
  if (FIsCurrency) and (FDecimalPlaces > 0) then
  begin
    simbolo := Trim(FCurSymbol);
    if (simbolo <> '') then simbolo := simbolo + ' ' else simbolo := '';
    //Result := FormatFloat(FCurSymbol + '#,##0.' + StringOfChar('0', FDecimalPlaces), FNumericValue);
    Result := NumeroParaReal(FNumericValue, FDecimalPlaces, FIsCurrency);

    if (Length(Result) + Length(simbolo) <= MaxLength) then
       Result := simbolo + Result;

    UpdateTextColor;
  end
  else
    Result := Text;
end;

function TEditExt.ReplaceStr(const S, Srch, Replace: string): string;
// Substitui um valor por outro dentro da string
var
  i: Integer;
  Source: string;
begin
  Source := S;
  Result := '';

  repeat
    i := Pos(UpperCase(Srch), UpperCase(Source));
    if i > 0 then
    begin
      Result := Result + Copy(Source, 1, i - 1) + Replace;
      Source := Copy(Source, i + Length(Srch), MaxInt);
    end
    else
      Result := Result + Source;
  until i <= 0;
end;

function TEditExt.NumeroParaReal(valor: Real; const dec: Integer;
  const bFormatoREAL: Boolean): String;
// converte o número para o formato Real(String).
// Exemplo: 2406.93 --> 2.406,93
var
  vlr: string;
begin
  vlr := FloatToStrF(valor, ffCurrency, 999, dec );
  vlr := RemoveFormatacao(vlr);

  If (not bFormatoREAL) or (FDecimalPlaces < 1) Then //'Não coloca "." separando as milhares
     vlr := ReplaceStr(vlr, '.', '');

  Result := vlr;
end;

function TEditExt.RealParaNumero(s: string): Real;
// Converte uma string em formato R$ em valor de ponto flutuante
var
  num: String;
  valor: Real;
  erro: Integer;
  idiv : Float;
begin
  num := Trim(s);
  valor := 0;
  erro := 0;
  idiv := Power(10, FDecimalPlaces);  // 10^x

  If num = '' Then num := '0';

  // Exemplo: 1.235,99 --> 1235.99
  num := RemoveFormatacao(num);
  num := ReplaceStr(num, ',', 'p');
  num := ReplaceStr(num, '.', '');
  num := ReplaceStr(num, 'p', '.');

  // transforma em ponto número de flutuante
  Val(num, valor, erro);

  //valor := Round(valor * idiv) / idiv;
  valor := RoundTo(valor, -1 * FDecimalPlaces);

  Result := valor;
end;

procedure TEditExt.CampoValor(var key: Char; const bFormatoREAL: Boolean = True);
// processa a entrada dos digitos
var
  vlr: String;
  sinal: String;
  valor: Double;
  erro: Integer;
  idiv: Float;
begin
  try
     vlr := RemoveFormatacao(Text);

     If FDecimalPlaces < 1 Then
     begin
        If Key = Chr(8) Then Exit;
        If Pos(Key, '-0123456789') = 0 Then key := Chr(0);
        If Length(vlr) >= MaxLength Then key := Chr(0);
        SelStart := Length(vlr);
     end;
     
     if key = Chr(0) then Exit;

     vlr := ReplaceStr(vlr, '.', ''); // remove separador de milhares
     sinal := '';
     idiv  := Power(10, FDecimalPlaces);

     If Pos('-', vlr) >= 1 Then sinal := '-';

     vlr := ReplaceStr(vlr, '-', '');
     vlr := ReplaceStr(vlr, ',', '');

     Val(vlr, valor, erro);

     vlr := FloatToStr(valor);

     If Key = Chr(8) Then
     begin
        Key := Chr(0);
        If Length(vlr) > 0 Then vlr := Copy(vlr, 1, Length(vlr) -1);
     end
     else
     begin
        If Length(Text) >= MaxLength Then
        begin
           key := chr(0);
           Exit;
        end;

        If Pos(Key, '-0123456789') < 1 Then
        begin
           Key := chr(0);
           Exit;
        End;

        if Key = '-' then
        begin
          if sinal = '' then
             sinal := '-'
          else
             sinal := '';
        end
        else
          vlr := vlr + Key;

        Key := chr(0);
     end;

     erro := 0;
     Val(vlr, valor, erro);

     if (valor = 0) and (sinal = '-') then sinal := '';

     vlr := FloatToStrF(valor/idiv, ffCurrency, 999, FDecimalPlaces);

     vlr := RemoveFormatacao(vlr);

     If (not bFormatoREAL) or (FDecimalPlaces < 1) Then //'Não coloca "." separando as milhares
        vlr := ReplaceStr(vlr, '.', ''); 

     Text := sinal + vlr;
     SelStart := Length(Text);
     key := chr(0);
     UpdateTextColor;
  finally
  end;
end;

procedure TEditExt.Configurar;
// algumas configurações
begin
   //FDefaultFontColor := Font.Color;

   if FIsCurrency then
   begin
     if MaxLength = 0 then
     begin
       // R$ -999.999.999,99
       // 999.999.999.999,99
       MaxLength := 18;

       if FDecimalPlaces < 1 then MaxLength := 10;
     end;

     if Length(FCurSymbol) > 3 then
        FCurSymbol := Trim(Copy(FCurSymbol, 1, 3));

     if FDecimalPlaces > 0 then
        Alignment := taRightJustify
     else
        FCurSymbol := '';

     NumbersOnly := False;
     AutoSelect := False;
     SelStart := Length(Text);
   end;
end;

function TEditExt.RemoveFormatacao(s: string): string;
// remove a formatação ficando penas [-.,0123456789]
var
  c: Char;
begin
  Result := '';

  for c in s do
  begin
     if c in ['0'..'9', '-',',', '.'] then // 'A'..'Z'
     begin
       AppendStr(Result, c);
     end;
  end;
end;

procedure TEditExt.Click;
// click dentro do campo
begin
  inherited Click;

  Configurar;

  if (ReadOnly) or (not Enabled) then Exit;
  if (Length(FCurSymbol) > 0) and (not FIsCurrency) then FCurSymbol := '';

  if FIsCurrency then
  begin
    Text := RemoveFormatacao(Text);
    SelStart := Length(Text);
    UpdateTextColor;
  end;

  if Assigned(FOnClick) then
    FOnClick(Self); // Dispara o evento OnClick, se estiver atribuído
end;

procedure TEditExt.DoEnter;
// cor de fundo do campo text quando ganha foco
begin
  inherited DoEnter;

  Configurar;

  if (ReadOnly) or (not Enabled) then Exit;
  if (Length(FCurSymbol) > 0) and (not FIsCurrency) then FCurSymbol := '';

  FDefaultFontColor := Font.Color;
  Font.Color := FFocusColorText;
  FTemFoco := True;

  if FIsCurrency then
  begin
    Text := RemoveFormatacao(Text);
    SelStart := Length(Text);
    UpdateTextColor;
  end;

  Color := FFocusColor;
end;

procedure TEditExt.DoExit;
// cor de fundo do campo text quando perde foco e
// formatação da saída no campo de currency
begin
  inherited DoExit;

  FTemFoco := False;
  Color := FDefaultColor;
  Font.Color := FDefaultFontColor;

  if (ReadOnly) or (not Enabled) then Exit;
  if not FIsCurrency then Exit;

  try
    // Tenta converter o valor para Double ao sair do campo e aplica a formatação
    FNumericValue := RealParaNumero(Text); //StrToFloat(Text);
    Text := FormatValue;
    UpdateTextColor; // Atualiza a cor do texto com base no valor atualizado
  except
    on E: Exception do
      Text := FormatValue; // Reverte para o último valor válido
  end;
end;

procedure TEditExt.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if FIsCurrency then begin
    begin
      if (Key = VK_LEFT) or (Key = VK_RIGHT) or (Key = VK_UP) or (Key = VK_DOWN) or
         (Key = VK_HOME) or (Key = VK_END) or (Key = VK_PRIOR) or (Key = VK_NEXT) then
      begin
        Key := 0; //invalida keys: up, down, left, right e outras
      end;
     end;
  end;

  inherited KeyDown(Key, Shift);
end;

procedure TEditExt.KeyPress(var Key: Char);
// digitação no campo
begin
  if key = #13 then
  begin
    try
      FNumericValue := RealParaNumero(Text);
    except
      on E: Exception do
        FNumericValue := 0;
    end;
  end;

  inherited KeyPress(Key);

  if (ReadOnly) or (not Enabled) then Exit;
  if not FIsCurrency then Exit;

  CampoValor(key, FIsCurrency);
end;

end.
