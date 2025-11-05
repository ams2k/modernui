unit DBGridPlus;

// DBGrid com opção de titulos com fundo em cor gradiente e a linha selecionada também.

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LCLIntf, LCLType, LResources, Forms, Controls, Graphics, Dialogs,
  Grids, DBGrids, DB, Math;

type
  TDBGridPlusStyle = (gsDefault, gsModern, gsClassic, gsClean);

  { TDBGridPlus }

  TDBGridPlus = class(TDBGrid)
  private
    FDefaultBorderColor: TColor;
    FGridLinesColor: TColor;
    FGridLinesStyle: TPenStyle;
    FGridRows: Integer;
    FGridStyle: TDBGridPlusStyle;
    FHeaderGradient: Boolean;
    FHeaderGradientColorOne: TColor;
    FHeaderGradientColorTwo: TColor;
    FRowGradientOnSelected: Boolean;
    FRowGradientColorOne: TColor;
    FRowGradientColorTwo: TColor;
    FSelectedRowColor: TColor;
    FSelectedRowFontColor: TColor;
    FColumnTitleColor, FColumnFontColor: TColor;

    FZebra: Boolean;
    procedure SetDefaultBorderColor(AValue: TColor);
    procedure SetGridLinesColor(AValue: TColor);
    procedure SetGridLinesStyle(AValue: TPenStyle);
    procedure SetGridRows(AValue: Integer);
    procedure SetHeaderGradient(AValue: Boolean);
    procedure SetHeaderGradientColorOne(AValue: TColor);
    procedure SetHeaderGradientColorTwo(AValue: TColor);
    procedure SetRowGradientOnSelected(AValue: Boolean);
    procedure SetRowGradientColorOne(AValue: TColor);
    procedure SetRowGradientColorTwo(AValue: TColor);
    procedure SetSelectedRowColor(AValue: TColor);
    procedure SetSelectedRowFontColor(AValue: TColor);
    procedure SetZebra(AValue: Boolean);
    procedure SetGridStyle(AValue: TDBGridPlusStyle);
    function LightenColor(AColor: TColor; Percent: Integer): TColor;
    procedure ApplyStylePreset(APreset: TDBGridPlusStyle);
    function HTMLColorToRGB(AHtmlColor: String): TColor;
    function IsCharWord(ch: char): boolean;
    function IsCharHex(ch: char): boolean;
  protected
    procedure DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState); override;
  public
    constructor Create(AOwner: TComponent); override;
    function Data_RowsCount: Integer;
    function Data_RowIndex: Integer;
    function Data_IsEmpty: Boolean;
    function Data_GetField(AField:string): TField;
    function Data_GetIndex(AIndex: Integer): TField;
    function Data_RowFields(AIndex: Integer): TFields;
    procedure Data_First;
    procedure Data_Next;
    procedure Data_GoTo(AIndex:Integer);
  published
    property HeaderGradient: Boolean read FHeaderGradient write SetHeaderGradient default True;
    property HeaderGradientColorOne: TColor read FHeaderGradientColorOne write SetHeaderGradientColorOne;
    property HeaderGradientColorTwo: TColor read FHeaderGradientColorTwo write SetHeaderGradientColorTwo;
    property RowGradientOnSelected: Boolean read FRowGradientOnSelected write SetRowGradientOnSelected default True;
    property RowGradientColorOne: TColor read FRowGradientColorOne write SetRowGradientColorOne;
    property RowGradientColorTwo: TColor read FRowGradientColorTwo write SetRowGradientColorTwo;
    property SelectedRowColor: TColor read FSelectedRowColor write SetSelectedRowColor;
    property SelectedRowFontColor: TColor read FSelectedRowFontColor write SetSelectedRowFontColor;
    property Zebra: Boolean read FZebra write SetZebra;
    property GridStyle: TDBGridPlusStyle read FGridStyle write SetGridStyle default gsModern;
    property GridLinesStyle: TPenStyle read FGridLinesStyle write SetGridLinesStyle default psSolid;
    property GridLinesColor: TColor read FGridLinesColor write SetGridLinesColor default clSilver;
    property GridRows: Integer read FGridRows write SetGridRows;
    property DefaultBorderColor: TColor read FDefaultBorderColor write SetDefaultBorderColor default clSilver;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I dbgridplus_icon.lrs}
  RegisterComponents('ModernUI',[TDBGridPlus]);
end;

{ TDBGridPlus }

constructor TDBGridPlus.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Options := [dgTitles,dgColumnResize,dgColumnMove,dgColLines,dgRowLines,dgTabs,
              dgRowSelect,dgConfirmDelete,dgCancelOnExit];
  ReadOnly := True;

  SelectedRowColor := HTMLColorToRGB('#5ed9ff');
  SelectedRowFontColor := clBlue;
  FGridStyle := gsModern;

  ApplyStylePreset(FGridStyle);
end;

function TDBGridPlus.Data_RowsCount: Integer;
//quantidade de registros
begin
  Result := 0;
  if (DataSource <> nil) then
    Result := DataSource.DataSet.RecordCount;
end;

function TDBGridPlus.Data_RowIndex: Integer;
//linha atual no dataset
begin
  Result := -1;
  if (DataSource <> nil) then
    Result := DataSource.DataSet.RecNo;
end;

function TDBGridPlus.Data_IsEmpty: Boolean;
//checa se há inicialização do datasource
begin
  Result := (DataSource = nil) or (DataSource.DataSet = nil);
end;

procedure TDBGridPlus.Data_First;
begin
  DataSource.DataSet.First;
end;

procedure TDBGridPlus.Data_Next;
begin
  DataSource.DataSet.Next;
end;

procedure TDBGridPlus.Data_GoTo(AIndex: Integer);
begin
  DataSource.DataSet.RecNo := AIndex;
end;

function TDBGridPlus.Data_GetField(AField:string): TField;
//retorna o campo atual
begin
  Result := DataSource.DataSet.FieldByName(AField);
end;

function TDBGridPlus.Data_GetIndex(AIndex: Integer): TField;
//retorna o campo conforme seu index
begin
  Result := DataSource.DataSet.Fields[AIndex];
end;

function TDBGridPlus.Data_RowFields(AIndex: Integer): TFields;
//retorna os campos conforme linha da grid
begin
  DataSource.DataSet.RecNo := AIndex;
  Result := DataSource.DataSet.Fields;
end;

procedure TDBGridPlus.DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState);
// desenha o título e as células de dados
var
  LText: String = '';
  Color1, Color2, CorFonte: TColor;
  IsFixed, IsSelected: Boolean;
  IsModern: Boolean;
begin
  inherited DrawCell(ACol, ARow, ARect, AState);
  // Em caso de erros out of index, retire dgIndicator de Options

  if Columns.Count < 1 then Exit;

  IsFixed    := (ARow < FixedRows);
  IsSelected := gdSelected in AState;
  IsModern   := not (FGridStyle = gsDefault);

  if (dgIndicator in Options) and IsModern then
    Options := Options - [dgIndicator];

  //try
  if IsFixed and IsModern then begin
    // Títulos das células
    Color1   := FColumnTitleColor;
    CorFonte := FColumnFontColor;
    LText    := Columns[ACol].Title.Caption;
    Color1   := Columns[ACol].Title.Color;
    CorFonte := Columns[ACol].Title.Font.Color;

    // cor do titulo definido no dbgrid
    Color2 := LightenColor(Color1, 60);

    if FHeaderGradient then begin
      // gradiente de fundo dos títulos
      Color1 := FHeaderGradientColorOne;
      Color2 := FHeaderGradientColorTwo;

      // Desenha o gradiente
      Canvas.GradientFill(ARect, Color1, Color2, gdVertical);
    end else begin
      // sem gradiente
      Canvas.Brush.Color := Color1;
      Canvas.FillRect(ARect);
    end;

    // Desenha o texto do título
    Canvas.Font.Color := CorFonte;
    Canvas.TextRect(ARect, ARect.Left + 4, ARect.Top + 2, LText);
  end;

  if not IsFixed and IsModern then begin
    // células de dados
    if (ACol >= 0) and (ACol < Columns.Count) and Assigned(Columns[ACol].Field) then
      LText := Columns[ACol].Field.AsString;

    if IsSelected then begin
      // linha selecionada

      if FRowGradientOnSelected then begin
        // linha selecionada com gradiente
        Color1 := FRowGradientColorOne;
        Color2 := FRowGradientColorTwo;

        // Linha selecionada sem foco → cinza degradê
        if not Focused then begin
          // Cinza escuro → cinza claro
          Color1 := RGBToColor(180, 180, 180);
          Color2 := RGBToColor(230, 230, 230);
        end;

        // Desenha o gradiente
        Canvas.GradientFill(ARect, Color1, Color2, gdVertical);

        // Cor do texto  e estilo da fonte
        if Focused then begin
          Canvas.Font.Color := FSelectedRowFontColor;
          Canvas.Font.Style := []; //  [fsBold]
        end;
      end
      else begin
        // linha selecionada sem gradiente
        Canvas.Brush.Color := FSelectedRowColor;
        Canvas.Font.Color  := FSelectedRowFontColor;
        Canvas.FillRect(ARect);
      end;
    end
    else if Zebra then begin
      // linha não selecionada
      if (ARow mod 2 = 0) then Color1 := AlternateColor else Color1 := Color;
      Canvas.Brush.Color := Color1;
      Canvas.FillRect(ARect);
    end
    else begin
      // todas as linhas terão a mesma cor definida em Grid.Color
      Canvas.Brush.Color := Color;
      Canvas.FillRect(ARect);
    end;

    // desenha o texto na célula
    DefaultDrawColumnCell(ARect, ACol, Columns[ACol], AState);
  end;

  // desenho das bordas da célula: __|
  if (dgColLines in Options)  then begin //and (ACol < Columns.Count-1) then begin
    //coluna à direita
    Canvas.Pen.Color := FGridLinesColor;
    Canvas.Pen.Style := FGridLinesStyle;
    Canvas.MoveTo(ARect.Right - 1, ARect.Top);
    Canvas.LineTo(ARect.Right - 1, ARect.Bottom);
  end;

  //if (dgRowLines in Options) and (ARow < RowCount-1) and (not IsFixed) then begin

  if (dgRowLines in Options) and (not IsFixed) then begin
    // linha abaixo, com exceção da célula do título
    Canvas.Pen.Color := FGridLinesColor;
    Canvas.Pen.Style := FGridLinesStyle;
    Canvas.MoveTo(ARect.Left, ARect.Bottom - 1);
    Canvas.LineTo(ARect.Right, ARect.Bottom - 1);
  end;
end;

procedure TDBGridPlus.SetGridRows(AValue: Integer);
// ajusta o Height da grid conforme a quantidade de linha informada
begin
  if FGridRows = AValue then Exit;
  if AValue < 0 then Avalue := 0;
  if AValue > 100 then AValue := 100;

  FGridRows := AValue;

  if FGridRows > 0 then
    Height := DefaultRowHeight * AValue + DefaultRowHeight * 2;

  FGridRows := 0;

  Invalidate;
end;

procedure TDBGridPlus.SetHeaderGradient(AValue: Boolean);
begin
  if FHeaderGradient = AValue then Exit;
  FHeaderGradient := AValue;
  Invalidate;
end;

procedure TDBGridPlus.SetHeaderGradientColorOne(AValue: TColor);
begin
  if FHeaderGradientColorOne = AValue then Exit;
  FHeaderGradientColorOne := AValue;
  Invalidate;
end;

procedure TDBGridPlus.SetHeaderGradientColorTwo(AValue: TColor);
begin
  if FHeaderGradientColorTwo = AValue then Exit;
  FHeaderGradientColorTwo := AValue;
  Invalidate;
end;

procedure TDBGridPlus.SetRowGradientOnSelected(AValue: Boolean);
begin
  if FRowGradientOnSelected = AValue then Exit;
  FRowGradientOnSelected := AValue;
  Invalidate;
end;

procedure TDBGridPlus.SetRowGradientColorOne(AValue: TColor);
begin
  if FRowGradientColorOne = AValue then Exit;
  FRowGradientColorOne := AValue;
  Invalidate;
end;

procedure TDBGridPlus.SetRowGradientColorTwo(AValue: TColor);
begin
  if FRowGradientColorTwo = AValue then Exit;
  FRowGradientColorTwo := AValue;
  Invalidate;
end;

procedure TDBGridPlus.SetSelectedRowColor(AValue: TColor);
begin
  if FSelectedRowColor = AValue then Exit;
  FSelectedRowColor := AValue;
  Invalidate;
end;

procedure TDBGridPlus.SetSelectedRowFontColor(AValue: TColor);
begin
  if FSelectedRowFontColor = AValue then Exit;
  FSelectedRowFontColor := AValue;
  Invalidate;
end;

procedure TDBGridPlus.SetGridLinesStyle(AValue: TPenStyle);
begin
  if FGridLinesStyle = AValue then Exit;
  FGridLinesStyle := AValue;
  Invalidate;
end;

procedure TDBGridPlus.SetDefaultBorderColor(AValue: TColor);
//define a cor da grid, não das linhas
begin
  if FDefaultBorderColor = AValue then Exit;
  FDefaultBorderColor := AValue;
  BorderColor := AValue;
  Invalidate;
end;

procedure TDBGridPlus.SetGridLinesColor(AValue: TColor);
// cor das grid lines
begin
  if FGridLinesColor = AValue then Exit;
  FGridLinesColor := AValue;
  GridLineColor := AValue;
  Invalidate;
end;

procedure TDBGridPlus.SetZebra(AValue: Boolean);
// cores alteranadas ?
begin
  if FZebra = AValue then Exit;
  FZebra := AValue;
  Invalidate;
end;

procedure TDBGridPlus.SetGridStyle(AValue: TDBGridPlusStyle);
begin
  if FGridStyle = AValue then Exit;
  FGridStyle := AValue;
  ApplyStylePreset(AValue);
end;

function TDBGridPlus.LightenColor(AColor: TColor; Percent: Integer): TColor;
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

procedure TDBGridPlus.ApplyStylePreset(APreset: TDBGridPlusStyle);
begin
  //Títulos das Colunas
  FColumnTitleColor := clBtnFace;
  FColumnFontColor  := clBlack;

  Options := [dgTitles,dgColumnResize,dgColumnMove,dgColLines,dgRowLines,dgTabs,dgRowSelect,dgConfirmDelete,dgCancelOnExit,dgDisplayMemoText];

  case APreset of
    gsDefault:
      begin
        Flat := False;
        AlternateColor := clWindow;
        Color := RGBToColor(238, 238, 238);
        DefaultBorderColor := clSilver;
        GridLinesColor := clSilver;
        // usar cores alternadas nas linhas de dados
        Zebra := False;
        //títulos da células - tons de cinza
        FHeaderGradient         := False;
        FHeaderGradientColorOne := RGBToColor(180, 180, 180);
        FHeaderGradientColorTwo := RGBToColor(230, 230, 230);
        // linha selecionada - tons de verde
        FRowGradientOnSelected := False;
        FRowGradientColorOne   := RGBToColor(111, 255, 135);
        FRowGradientColorTwo   := RGBToColor(199, 252, 212);
      end;
    gsModern:
      begin
        FColumnFontColor  := clWhite;
        Flat := True;
        AlternateColor := $00EFE7DE;
        FixedColor := clBtnShadow;
        Color := RGBToColor(238, 238, 238);
        DefaultBorderColor := clSkyBlue;
        GridLinesColor := clSkyBlue;
        // usar cores alternadas nas linhas de dados
        Zebra := True;
        //títulos da células - tons de azul mais escuro
        FHeaderGradient          := True;
        FHeaderGradientColorOne  := RGBToColor(24, 24, 150);
        FHeaderGradientColorTwo  := HTMLColorToRGB('#8e8ec9');
        // linha selecionada - tons de laranja
        FRowGradientOnSelected := True;
        FRowGradientColorOne   := RGBToColor(255, 199, 110);
        FRowGradientColorTwo   := RGBToColor(243, 255, 189);
      end;
    gsClassic:
      begin
        Flat := True;
        FColumnFontColor  := clBlack;
        AlternateColor := $00EFE7DE;
        Color := RGBToColor(238, 238, 238);
        DefaultBorderColor := clSkyBlue;
        GridLinesColor := clSkyBlue;
        // usar cores alternadas nas linhas de dados
        Zebra := True;
        //títulos da células - tons de azul mais claro
        FHeaderGradient          := True;
        FHeaderGradientColorOne  := $00A77A17;
        FHeaderGradientColorTwo  := $00E6E5A3;
        // linha selecionada - tons de verde
        FRowGradientOnSelected := True;
        FRowGradientColorOne   := RGBToColor(111, 255, 135);
        FRowGradientColorTwo   := RGBToColor(199, 252, 212);
      end;
    gsClean:
      begin
        FColumnTitleColor := $00F0F0F0;
        FColumnFontColor  := $006D6D71;
        Flat := True;
        AlternateColor := $00FEFEFE;
        BorderStyle := bsNone;
        Color := $00FEFEFE;
        DefaultBorderColor := $00F3E4D5;
        GridLinesColor := $00F3E4D5;
        GridLinesStyle := psDash;
        HeaderGradient := False;
        Options := [dgTitles,dgColumnResize,dgColumnMove,dgRowLines,dgTabs,dgRowSelect,dgConfirmDelete,dgCancelOnExit,dgDisplayMemoText];
        RowGradientOnSelected := False;
        SelectedRowColor := $00F5F4E6;
        SelectedRowFontColor := $00842323;
        Zebra := False;
      end;
  end;

  Invalidate;
end;

function TDBGridPlus.HTMLColorToRGB(AHtmlColor: String): TColor;
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

  //permitido apenas #rgb (#ccc), #rrggbb (#efefef)
  iLen := Length(AHtmlColor);
  if (iLen <> 3) and (iLen <> 6) then exit;

  for i := 1 to iLen do
    if not IsCharHex(AHtmlColor[i]) then exit;

  if iLen = 6 then begin
    // #AABBCC
    N1 := StrToInt('$' + Copy(AHtmlColor, 1, 2));
    N2 := StrToInt('$' + Copy(AHtmlColor, 3, 2));
    N3 := StrToInt('$' + Copy(AHtmlColor, 5, 2));
  end else begin
    // #ABC
    N1 := StrToInt('$' + AHtmlColor[1] + AHtmlColor[1]);
    N2 := StrToInt('$' + AHtmlColor[2] + AHtmlColor[2]);
    N3 := StrToInt('$' + AHtmlColor[3] + AHtmlColor[3]);
  end;

  Result := RGBToColor(N1, N2, N3);
end;

function TDBGridPlus.IsCharWord(ch: char): boolean;
// caracteres válidos
begin
  Result := ch in ['a'..'z', 'A'..'Z', '_', '0'..'9'];
end;

function TDBGridPlus.IsCharHex(ch: char): boolean;
// caracteres válidos
begin
  Result := ch in ['0'..'9', 'a'..'f', 'A'..'F'];
end;

end.
