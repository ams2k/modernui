unit Util.CEP;

// Acesso ao serviço CEP

{
  WINDOWS requer as seguintes DLLs
    libeay32.dll
    ssleay32.dll
    libssl-3.dll
}

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser,
  fphttpclient, ssockets, openssl, opensslsockets;

type

  { TUtilCep }

  TUtilCep = class
  private
    FBairro: string;
    FCidade: string;
    FComplemento: string;
    FUnidade: string;
    FDDD: string;
    FIBGE: string;
    FLogradouro: string;
    FRegiao: string;
    FSIAFI: string;
    FUF_Nome: string;
    FUF_Sigla: string;
    FGIA: string;
    FErro: string;
    function ApiCEP(ACEP: Integer): string;
  public
    property Logradouro: string read FLogradouro;
    property Complemento: string read FComplemento;
    property Unidade: string read FUnidade;
    property Bairro: string read FBairro;
    property Cidade: string read FCidade;
    property UF_Sigla: string read FUF_Sigla;
    property UF_Nome: string read FUF_Nome;
    property DDD: string read FDDD;
    property IBGE: string read FIBGE;
    property SIAFI: string read FSIAFI;
    property GIA: string read FGIA;
    property Regiao: string read FRegiao;
    function GetCEP(ACEP: Integer): Boolean;
    property GetErro: string read FErro;
  end;

implementation

{ TUtilCep }

function TUtilCep.ApiCEP(ACEP: Integer): string;
// Obtém o resultado a partir da API da viacep
// ACEP: Número do cep, ex 14781260
var
  httpClient: TFPHTTPClient;
begin
  Result := '';
  FErro  := '';

  if ACEP < 1 then Exit;

  httpClient := TFPHTTPClient.Create(nil);

  try
    try
      // Definir o protocolo SSL
      // Adicionar cabeçalho user-agent para evitar bloqueio de requisições
      httpClient.AddHeader('User-Agent', 'Mozilla/5.0');
      Result := httpClient.Get('https://viacep.com.br/ws/'+ RightStr('00000000' + IntToStr(ACEP), 8) + '/json');
    except
      on e: ESocketError do begin
        Result := '';
        FErro := e.Message;
      end;
      on e: Exception do begin
        Result := '';
        FErro := e.Message;
      end;
    end;

  finally
    httpClient.Free;
  end;

  Result := Trim(Result);
end;

function TUtilCep.GetCEP(ACEP: Integer): Boolean;
var
  res: string;
  lobj: TJSONData;
  lJson: TJSONObject;
begin
  Result := False;
  FErro  := '';
  res    := ApiCEP( ACEP );

  if FErro <> '' then Exit;

  if Length(res) > 0 then begin
     FErro  := '';

     try
       try
         lobj := GetJSON( res ); //será liberado da memória em lJson.Free
         lJson := TJSONObject( lobj );

         FLogradouro  := lJson.Get('logradouro', '');
         FComplemento := lJson.Get('complemento', '');
         FUnidade     := lJson.Get('unidade', '');
         FBairro      := lJson.Get('bairro', '');
         FCidade      := lJson.Get('localidade', '');
         FUF_Sigla    := lJson.Get('uf', '');
         FUF_Nome     := lJson.Get('estado', '');
         FRegiao      := lJson.Get('regiao', '');
         FIBGE        := lJson.Get('ibge', '');
         FGIA         := lJson.Get('gia', '');
         FDDD         := lJson.Get('ddd', '');
         FSIAFI       := lJson.Get('siafi', '');

         Result       := True;
       except
         on E: Exception do
           FErro  := E.Message;
       end;
     finally
       res := '';
       lJson.Free;
     end;
  end;
end;

end.

