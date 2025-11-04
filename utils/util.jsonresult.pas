unit Util.JsonResult;

{
 Autor: Aldo Márcio Soares - ams2kg@gmail.com - 28/04/2025 🔥

 Ferramenta para tornar o uso do json mais amigável, com chamadas encadeadas.

 Pode retornar:
 - JsonObject (.GetObject), JsonString (.GetString(True))
 - ArrayObject (.GetObject),  ArrayString (.GetString(True))

 LJsonObject := TJsonResult.New.Success(True).Message('Dados cadastrados').GetObject;
 WriteLn( TJsonResult.New.Success(True).Message('Dados cadastrados').GetString(True) );

1) -------------------------------------------

var
  j, sub: TJsonResult;
  sub2: TJSONArray;
begin
  sub := TJsonResult.New
      .AddPair('codigo', 101)
      .AddPair('descricao', 'Produto A');

  sub2 := TJSONArray.Create;
  sub2.Add(TJsonResult.New.AddPair('idprod', 1).AddPair('produto', 'Arroz').AddPair('valor', 27.94).GetObject);
  sub2.Add(TJsonResult.New.AddPair('idprod', 2).AddPair('produto', 'feijão').AddPair('valor', 7.15).GetObject);
  sub2.Add(TJsonResult.New.AddPair('idprod', 3).AddPair('produto', 'café').AddPair('valor', 37.99).GetObject);

  j := TJsonResult.New
    .Success(true)
    .Message('cadastro confirmado')
    .AddPair('id', 1)
    .AddPair('nome', 'Márcio')
    .AddPair('ativo', True)
    .AddPair('salario', 4235.70)
    .AddPairArray('coordenadas', [37.195156336091998, 55.978631048365003, 2.2100000000000000E+002])
    .AddPair('x', 21.32489273474837)
    .AddPairCurrency('bonus', 1500.50)
    .AddPairDateTime('criado_em', Now)
    .AddPairDate('aniversario', EncodeDate(1967, 1, 28))
    .AddPairTime('entrada', Now)
    .AddPairTime('saida', IncMinute(Now, 10) )
    .AddPairFloatFormatted('double_formated', 13565.54580)
    .AddPairNull('obs')
    .AddPairArray('cidades', ['São Paulo', 'Rio de Janeiro', 'Curitiba'])
    .AddPairArray('quantidades', [10, 20, 30])
    .AddPairArray('precos', [5.99, 10.49, 8.75])
    .AddPairObject('produto', sub)
    .AddPairArray('lista_itens', sub2);

  edtDados.Text := j.GetString(true);

  j.SaveToFile('dados.json');

   j.Free;
   sub.Free;
   //sub2.Free;
end;

2) -------------Array------------------------------

var
  j: TJSONArray;
begin
  j := TJSONArray.Create;
  j.Add(TJsonResult.New.AddPair('idprod', 1).AddPair('produto', 'Arroz').AddPair('valor', 27.94).GetObject);
  j.Add(TJsonResult.New.AddPair('idprod', 2).AddPair('produto', 'feijão').AddPair('valor', 7.15).GetObject);
  j.Add(TJsonResult.New.AddPair('idprod', 3).AddPair('produto', 'café').AddPair('valor', 37.99).GetObject);

  //edtDados.Text := j.AsJSON;
  edtDados.Text := TJsonResult.Create.FormatJson(j.AsJSON);

  j.Free;
end;

3) -------------Array------------------------------

var
  j: TJsonResult;
begin
  j := TJsonResult.Create;
  j.AddToArray(TJsonResult.New.AddPair('id', 1).AddPair('nome', 'João').AddPair('idade', 27).AddPair('salario', 1515.95).GetObject);
  j.AddToArray(TJsonResult.New.AddPair('id', 2).AddPair('nome', 'Maria').AddPair('idade', 15).AddPair('salario', 47905.00).GetObject);
  j.AddToArray(TJsonResult.New.AddPair('id', 3).AddPair('nome', 'José').AddPair('idade', 37).AddPair('salario', 2093.79).GetObject);

  edtDados.Text := j.GetArrayString(true);

  j.Free;
end;

4) -------------------------------------------

var
  j: TJsonResult;
begin
  j := TJsonResult.Create;
  j.LoadFromFile('dados.json');
  edtDados.Text := j.GetString(True);
  j.Free;
  ShowMessage('dados.json carregado!');
}

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser;

type

  { TJSONFloat4Number }

  TJSONFloat4Number = class(TJSONFloatNumber)
  protected
    function GetAsString: TJSONStringType; override;
  end;

  { TJsonResult }

  TJsonResult = class
  private
    FCountArray: Integer;
    FCountPairs: Integer;
    FCountPairsArray: Integer;
    FJson: TJsonObject;
    FArray: TJSONArray;

  public
    constructor Create;
    destructor Destroy; override;
    class function New: TJsonResult; static;

    property CountPairs: Integer read FCountPairs;
    property CountPairsArray: Integer read FCountPairsArray;
    property CountArray: Integer read FCountArray;

    function Success(AValue: Boolean): TJsonResult;
    function Message(AMsg: String): TJsonResult;

    function AddPair(const AKey, AValue: String): TJsonResult; overload;
    function AddPair(const AKey: String; AValue: Boolean): TJsonResult; overload;
    function AddPair(const AKey: String; AValue: Integer): TJsonResult; overload;
    function AddPair(const AKey: String; AValue: Double): TJsonResult; overload;

    function AddPairDate(const AKey: String; AValue: TDateTime): TJsonResult;
    function AddPairDateTime(const AKey: String; AValue: TDateTime): TJsonResult;
    function AddPairTime(const AKey: String; AValue: TDateTime): TJsonResult;
    function AddPairCurrency(const AKey: String; AValue: Double; const CurrencySymbol: String = 'R$'): TJsonResult;
    function AddPairFloatFormatted(const AKey: String; AValue: Double; const ADecimals: Integer = 2): TJsonResult;

    function AddPairNull(const AKey: String): TJsonResult;
    function AddPairObject(const AKey: String; AObject: TJsonResult): TJsonResult;
    function AddPairArray(const AKey: String; const AValues: array of String): TJsonResult; overload;
    function AddPairArray(const AKey: String; const AValues: array of Integer): TJsonResult; overload;
    function AddPairArray(const AKey: String; const AValues: array of Double): TJsonResult; overload;
    function AddPairArray(const AKey: String; AJsonArray: TJSONArray): TJsonResult; overload;

    function AddToArray(AJson: TJSONObject): TJsonResult;
    function GetArray: TJSONArray;
    function GetArrayString(AFormatted: Boolean = False): String;
    function GetArrayFromField(AField: String): TJSONArray;

    function SaveToFile(const AFileName: String): Boolean;
    function LoadFromFile(const AFileName: String): Boolean;

    function PrettyPrintJSON(const AJSON: String; AIndent: String = '  '): String;
    function GetObject: TJsonObject;
    function GetString(AFormatted: Boolean = False): String;
    function FormatJson(AJson: String): String;
  end;

implementation

{ TJSONFloat4Number }

function TJSONFloat4Number.GetAsString: TJSONStringType;
// regula o formato de exibição de valores com ponto flutuante,
// sem mostrar valores em formato científico.
var
  F: TJSONFloat;
  fs: TFormatSettings;
begin
  //Result := inherited GetAsString;
  F := GetAsFloat;
  fs := DefaultFormatSettings;
  fs.DecimalSeparator := '.';

  Result := FormatFloat('0.00##########', F, fs);
end;

{ TJsonResult }

constructor TJsonResult.Create;
begin
  SetJSONInstanceType(jitNumberFloat, TJSONFloat4Number);
  FJson  := TJsonObject.Create;
  FArray := TJSONArray.Create;
  FCountArray := 0;
  FCountPairs := 0;
  FCountPairsArray := 0;
end;

destructor TJsonResult.Destroy;
begin
  FArray.Free;
  FJson.Free;
  inherited Destroy;
end;

{ Instância estática }
class function TJsonResult.New: TJsonResult;
begin
  Result := TJsonResult.Create;
end;

{ Adiciona um Success ao Json }
function TJsonResult.Success(AValue: Boolean): TJsonResult;
begin
  FJson.Add('success', TJSONBoolean.Create(AValue));
  FCountPairs := FCountPairs + 1;
  Result := Self;
end;

{ Adiciona uma Message ao Json }
function TJsonResult.Message(AMsg: String): TJsonResult;
begin
  FJson.Add('message', TJSONString.Create(AMsg));
  FCountPairs := FCountPairs + 1;
  Result := Self;
end;

function TJsonResult.AddPair(const AKey, AValue: String): TJsonResult;
//string
begin
  FJson.Add(AKey, TJSONString.Create(AValue));
  FCountPairs := FCountPairs + 1;
  Result := Self;
end;

function TJsonResult.AddPair(const AKey: String; AValue: Boolean): TJsonResult;
//boolean
begin
  FJson.Add(AKey, TJSONBoolean.Create(AValue));
  FCountPairs := FCountPairs + 1;
  Result := Self;
end;

function TJsonResult.AddPair(const AKey: String; AValue: Integer): TJsonResult;
//integer
begin
  FJson.Add(AKey, TJSONIntegerNumber.Create(AValue));
  FCountPairs := FCountPairs + 1;
  Result := Self;
end;

function TJsonResult.AddPair(const AKey: String; AValue: Double): TJsonResult;
//double
begin
  FJson.Add(AKey, TJSONFloatNumber.Create(AValue));
  FCountPairs := FCountPairs + 1;
  Result := Self;
end;

function TJsonResult.AddPairDate(const AKey: String; AValue: TDateTime): TJsonResult;
begin
  FJson.Add(AKey, TJSONString.Create(FormatDateTime('yyyy-mm-dd', AValue)));
  FCountPairs := FCountPairs + 1;
  Result := Self;
end;

function TJsonResult.AddPairDateTime(const AKey: String; AValue: TDateTime): TJsonResult;
begin
  FJson.Add(AKey, TJSONString.Create(FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', AValue)));
  FCountPairs := FCountPairs + 1;
  Result := Self;
end;

function TJsonResult.AddPairTime(const AKey: String; AValue: TDateTime): TJsonResult;
begin
  FJson.Add(AKey, TJSONString.Create(FormatDateTime('hh:nn:ss', AValue)));
  FCountPairs := FCountPairs + 1;
  Result := Self;
end;

function TJsonResult.AddPairCurrency(const AKey: String; AValue: Double; const CurrencySymbol: String): TJsonResult;
begin
  FJson.Add(AKey, TJSONString.Create(CurrencySymbol + ' ' + FormatFloat('#,##0.00', AValue)));
  FCountPairs := FCountPairs + 1;
  Result := Self;
end;

function TJsonResult.AddPairFloatFormatted(const AKey: String; AValue: Double; const ADecimals: Integer = 2): TJsonResult;
//formata double as string com casas decimais indicadas
var
  lDecimals: Integer;
  sValor: String;
begin
  // sValor := FormatFloat('#0.####', AValue).Replace(',', '.');
  lDecimals := ADecimals;
  if lDecimals < 0 then lDecimals := 0;
  sValor := Format('%0.' + IntToStr(lDecimals) +'f', [AValue]).Replace(',', '.');
  FJson.Add(AKey, TJSONString.Create(sValor));
  FCountPairs := FCountPairs + 1;
  Result := Self;
end;

function TJsonResult.AddPairNull(const AKey: String): TJsonResult;
// um valor NULL
begin
  FJson.Add(AKey, TJSONNull.Create);
  FCountPairs := FCountPairs + 1;
  Result := Self;
end;

function TJsonResult.AddPairObject(const AKey: String; AObject: TJsonResult): TJsonResult;
//adiciona um objeto (JSonResult)
begin
  FJson.Add(AKey, AObject.FJson.Clone as TJSONData); // Clona para manter dono
  FCountPairs := FCountPairs + 1;
  Result := Self;
end;

function TJsonResult.AddPairArray(const AKey: String; const AValues: array of String): TJsonResult;
//adiciona uma array de string [Barretos, Colina, Bebedouro]
var
  arr: TJSONArray;
  i: Integer;
begin
  arr := TJSONArray.Create;

  for i := 0 to High(AValues) do
    arr.Add(TJSONString.Create(AValues[i]));

  FJson.Add(AKey, arr);
  FCountPairsArray := FCountPairsArray + 1;
  Result := Self;
end;

function TJsonResult.AddPairArray(const AKey: String; const AValues: array of Integer): TJsonResult;
//adiciona um array de inteiros
var
  arr: TJSONArray;
  i: Integer;
begin
  arr := TJSONArray.Create;

  for i := 0 to High(AValues) do
    arr.Add(TJSONIntegerNumber.Create(AValues[i]));

  Fjson.Add(AKey, arr);
  FCountPairsArray := FCountPairsArray + 1;
  Result := Self;
end;

function TJsonResult.AddPairArray(const AKey: String; const AValues: array of Double): TJsonResult;
//adiciona um array de double
var
  arr: TJSONArray;
  i: Integer;
begin
  arr := TJSONArray.Create;

  for i := 0 to High(AValues) do
    arr.Add(TJSONFloatNumber.Create(AValues[i]));

  FJson.Add(AKey, arr);
  FCountPairsArray := FCountPairsArray + 1;
  Result := Self;
end;

function TJsonResult.AddPairArray(const AKey: String; AJsonArray: TJSONArray): TJsonResult;
// adiciona um objeto jsonarray
begin
  FJson.Add(AKey, AJsonArray);
  FCountPairsArray := FCountPairsArray + 1;
  Result := Self;
end;

function TJsonResult.AddToArray(AJson: TJSONObject): TJsonResult;
//adicionar um objeto json ao array de objetos. Ex: {"id": 10, "cidade": "Barretos"}
begin
  FArray.Add(AJson);
  Result := Self;
end;

function TJsonResult.GetArrayString(AFormatted: Boolean): String;
//retorna o array em formato string
var
  dados: TJSONData;
begin
  // GetJSON é necessário para que TJSONFloat4Number atue
  dados := GetJSON( FArray.AsJSON );

  if AFormatted then
    Result := dados.FormatJSON() //; PrettyPrintJSON( FArray.AsJSON )
  else
    Result := dados.AsJSON;

  if Assigned(dados) then dados.Free;
end;

function TJsonResult.GetArrayFromField(AField: String): TJSONArray;
//retorna um array do campo array indicado
begin
  Result := TJSONArray.Create;
  try
    Result := FJson.Arrays[AField];
  finally
  end;
end;

function TJsonResult.GetArray: TJSONArray;
// retorna o array em formato objeto json
begin
  Result := FArray;
end;

function TJsonResult.SaveToFile(const AFileName: String): Boolean;
//salva o json em arquivo
var
  Stream: TFileStream;
  S: String;
begin
  Result := False;
  try
    S := GetString(True);
    Stream := TFileStream.Create(AFileName, fmCreate);
    try
      Stream.WriteBuffer(Pointer(S)^, Length(S));
      Result := True;
    finally
      Stream.Free;
    end;
  except
    on E: Exception do
      Result := False;
  end;
end;

function TJsonResult.LoadFromFile(const AFileName: String): Boolean;
// carrega um json de um arquivo
var
  Stream: TFileStream;
  Parser: TJSONParser;
  Data: TJSONData;
begin
  Result := False;
  try
    Stream := TFileStream.Create(AFileName, fmOpenRead);
    try
      Parser := TJSONParser.Create(Stream, True);
      try
        Data := Parser.Parse;
        if Assigned(Data) and (Data.JSONType = jtObject) then
        begin
          FJson.Free;
          FJson := TJSONObject(Data);
          Result := True;
        end
        else
          Data.Free;
      finally
        Parser.Free;
      end;
    finally
      Stream.Free;
    end;
  except
    on E: Exception do
      Result := False;
  end;
end;

function TJsonResult.PrettyPrintJSON(const AJSON: String; AIndent: String): String;
// Json formataddo
var
    i, Level: Integer;
    c: Char;
    InString: Boolean;
begin
    Result := '';
    Level := 0;
    InString := False;

    for i := 1 to Length(AJSON) do
    begin
      c := AJSON[i];

      case c of
        '"':
          begin
            Result += c;
            if (i = 1) or (AJSON[i-1] <> '\') then
              InString := not InString;
          end;
        '{', '[':
          begin
            Result += c;
            if not InString then
            begin
              Inc(Level);
              Result += LineEnding + StringOfChar(' ', Level * Length(AIndent));
            end;
          end;
        '}', ']':
          begin
            if not InString then
            begin
              Dec(Level);
              Result += LineEnding + StringOfChar(' ', Level * Length(AIndent)) + c;
            end
            else
              Result += c;
          end;
        ',':
          begin
            Result += c;
            if not InString then
              Result += LineEnding + StringOfChar(' ', Level * Length(AIndent));
          end;
        ':':
          begin
            Result += c;
            if not InString then
              Result += ' ';
          end;
      else
        Result += c;
      end;
    end;
end;

{ Retorna o objeto Json }
function TJsonResult.GetObject: TJsonObject;
begin
  Result := FJson;
end;

{ Retorna o objeto Json em formato string }
function TJsonResult.GetString(AFormatted: Boolean = False): String;
var
  dados: TJSONData;
begin
  // GetJSON é necessário para que TJSONFloat4Number atue
  dados := GetJSON( FJson.AsJSON );

  if AFormatted then // formatado
    Result := dados.FormatJSON() //; PrettyPrintJSON( FArray.AsJSON )
  else
    Result := dados.AsJSON;

  if Assigned(dados) then dados.Free;
end;

function TJsonResult.FormatJson(AJson: String): String;
var
  dados: TJSONData;
begin
  // GetJSON é necessário para que TJSONFloat4Number atue
  dados := GetJSON( AJSON );
  Result := dados.FormatJSON();
  if Assigned(dados) then dados.Free;
end;


end.

