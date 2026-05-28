unit Util.Criptografia;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, base64, BlowFish, md5;

// Pode ser necessário instalar a biblioteca DCPcrypt (tem no online package)

type

  { TCriptografa }

  TCriptografa = class
    private
      FKey: string;
    public
      constructor Create(ASecretKey: string = 'key@secret9');
      function Encrypt(AValueToEncrypt: string): string;
      function Decrypt(AValueToDecrypt: String): string;
      function Encrypt64(AValueToEncrypt: string): string;
      function Decrypt64(AValueToDecrypt: String): string;
      function Encrypt_MD5(const AValue: string): string;
      class function new: TCriptografa;
  end;

implementation

{ TCriptografa }

constructor TCriptografa.Create(ASecretKey: string);
begin
  if Trim(ASecretKey) <> '' then
    FKey := ASecretKey;
end;

class function TCriptografa.new: TCriptografa;
begin
  Result := TCriptografa.Create();
end;

function TCriptografa.Encrypt(AValueToEncrypt: string): string;
//criptografa a string em AValue
var
  en: TBlowFishEncryptStream;
  s1: TStringStream;
begin
  s1 := TStringStream.Create('');
  en := TBlowFishEncryptStream.Create(FKey, s1);
  en.WriteAnsiString( AValueToEncrypt );
  en.Free;
  Result := s1.DataString;
  s1.Free;
end;

function TCriptografa.Decrypt(AValueToDecrypt: String): string;
//descriptografa a string em AValue
var
  de: TBlowFishDeCryptStream;
  s1: TStringStream;
begin
  s1 := TStringStream.Create( AValueToDecrypt );
  de := TBlowFishDeCryptStream.Create(FKey, s1);

  try
    Result := de.ReadAnsiString;
  except
    Result := AValueToDecrypt;
  end;

  de.Free;
  s1.Free;
end;

function TCriptografa.Encrypt64(AValueToEncrypt: string): string;
//criptografa uma string em base64
begin
  Result := EncodeStringBase64( AValueToEncrypt );
end;

function TCriptografa.Decrypt64(AValueToDecrypt: String): string;
//descriptografa uma string criptografada em base64
begin
  Result := DecodeStringBase64( AValueToDecrypt );
end;

function TCriptografa.Encrypt_MD5(const AValue: string): string;
// criptografa a senha usando MD5
begin
  Result := MD5Print(MD5String(AValue));
end;

end.

