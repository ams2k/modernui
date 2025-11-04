unit Util.Imagem;   
   
// Aldo Marcio Soares - ams2kg@gmail.com - 05/2025   
// manipulação de imagem (foto) em banco de dados   
   
{$mode ObjFPC}{$H+}   
   
interface   
   
uses   
  Classes, SysUtils, Controls, Graphics, ExtCtrls, ZDataset, SQLDB, DB, Math, 
  LCLType, // HBitmap type  
  IntfGraphics, // TLazIntfImage type  
  fpImage, // TFPColor type   
  FPReadJpeg, FPWriteJpeg, // jpg support  
  FPImgCanv, FPWritePNG;  
   
type   
   
  { TUtilImagem }   
   
  TUtilImagem = class   
  private  
  
  public  
    class procedure GetImage(var AImage: TImage; AQuery: TZQuery; const AFieldName: string);  
    class procedure GetStream(AImage: TImage; var AQuery: TZQuery; const AFieldName: string); 
    class procedure GetImageSQLQuery(var AImage: TImage; AQuery: TSQLQuery; const AFieldName: string); 
    class procedure GetStreamSQLQuery(AImage: TImage; var AQuery: TSQLQuery; const AFieldName: string); 
    class procedure ResizeImagem(var AImage: TImage; w, h: Integer);  
    class function ResizeBitmap(var AImage: TImage; w, h: Integer): TBitmap;  
    class procedure ResizeToImageBox(var AImage: TImage);
    class procedure CreateAvatar(var AImage: TImage; const ABorderColor: TColor;
                                 const ABorderWidth: Integer; const ABackgroundColor: TColor);  
    class function RoundAvatarBitmap(const ASource: TBitmap; const ABorderColor: TColor;  
                                     const ABorderWidth: Integer; const ABackgroundColor: TColor): TBitmap;  
  end;   
   
implementation   
   
{ TUtilImagem }   
   
class procedure TUtilImagem.GetImage(var AImage: TImage; AQuery: TZQuery; const AFieldName: string);   
//pega a imagem do zquery e jogo no TImage   
var   
  Stream: TMemoryStream;   
begin   
  AImage := TImage.Create(nil);   
  AImage.Picture := nil;

  if not AQuery.FieldByName(AFieldName).IsNull then begin   
    //carrega a foto   
    Stream := TMemoryStream.Create;   
    try   
      TBlobField(AQuery.FieldByName(AFieldName)).SaveToStream(Stream);   
      if Stream.Size > 0 then begin   
        Stream.Position := 0;   
        AImage.Picture.Bitmap.LoadFromStream(Stream);  // ou LoadFromFile se preferir PNG/JPG   
      end else   
        AImage.Picture := nil;   
    finally   
      Stream.Free;   
    end;   
  end;   
end;   
   
class procedure TUtilImagem.GetStream(AImage: TImage; var AQuery: TZQuery; const AFieldName: string);   
// converte a imagem do TImage para Stream e carrega no zquery   
var   
  Stream: TMemoryStream;   
begin   
  //joga a foto no stream   
  Stream := TMemoryStream.Create;
  try
    AImage.Picture.Bitmap.SaveToStream(Stream);
    Stream.Position := 0;
    AQuery.ParamByName(AFieldName).LoadBinaryFromStream(Stream);
  finally
    Stream.Free;
  end;
end; 
 
class procedure TUtilImagem.GetImageSQLQuery(var AImage: TImage; AQuery: TSQLQuery; const AFieldName: string); 
//pega a imagem do sqlquery e jogo no TImage 
var 
  Stream: TMemoryStream; 
begin 
  AImage := TImage.Create(nil); 
  AImage.Picture := nil;

  if not AQuery.FieldByName(AFieldName).IsNull then begin 
    //carrega a foto 
    Stream := TMemoryStream.Create; 
    try 
      TBlobField(AQuery.FieldByName(AFieldName)).SaveToStream(Stream); 
      if Stream.Size > 0 then begin 
        Stream.Position := 0; 
        AImage.Picture.Bitmap.LoadFromStream(Stream);  // ou LoadFromFile se preferir PNG/JPG 
      end else 
        AImage.Picture := nil; 
    finally 
      Stream.Free; 
    end; 
  end; 
end; 
 
class procedure TUtilImagem.GetStreamSQLQuery(AImage: TImage; var AQuery: TSQLQuery; const AFieldName: string); 
// converte a imagem do TImage para Stream e carrega no sqlquery 
var 
  Stream: TMemoryStream; 
begin 
  //joga a foto no stream 
  Stream := TMemoryStream.Create;
  try
    AImage.Picture.Bitmap.SaveToStream(Stream);
    Stream.Position := 0;
    AQuery.ParamByName(AFieldName).LoadFromStream(Stream, ftBlob);
  finally
    Stream.Free;
  end;
end; 
   
class procedure TUtilImagem.ResizeImagem(var AImage: TImage; w, h: Integer);   
//redimensiona a imagem   
var   
  newBitmap: TBitmap;   
begin   
  if AImage.Picture.Bitmap.Width > 0 then begin   
    newBitmap := TBitmap.Create;
    try
      newBitmap.Canvas.Brush.Color := clWhite;
      newBitmap.PixelFormat := pf24bit;
      newBitmap.SetSize(w, h);

      // Desenha a imagem original redimensionada dentro do novo bitmap
      newBitmap.Canvas.StretchDraw( Rect(0, 0, w, h), AImage.Picture.Graphic );
      AImage.Picture := nil;
      AImage.Picture.Bitmap.Assign(newBitmap);
    finally
      newBitmap.Free;
    end;
  end;   
end;   
   
class procedure TUtilImagem.ResizeToImageBox(var AImage: TImage);   
//ajusta a imagem para o tamanho do TImage   
var   
  newBitmap: TBitmap;   
begin   
  if AImage.Picture.Bitmap.Width > 0 then
  begin
    newBitmap := TBitmap.Create;
    try
      newBitmap.Canvas.Brush.Color := clWhite;
      newBitmap.PixelFormat := pf24bit;
      newBitmap.SetSize(AImage.ClientWidth, AImage.ClientHeight);
      newBitmap.Canvas.StretchDraw( AImage.ClientRect, AImage.Picture.Graphic );
      AImage.Picture := nil;
      AImage.Picture.Bitmap.Assign(newBitmap);
    finally
      newBitmap.Free;
    end;
  end;   
end;  
  
class function TUtilImagem.ResizeBitmap(var AImage: TImage; w, h: Integer): TBitmap;  
//cria uma imagem com as dimensões indicadas  
begin  
  Result := TBitmap.Create;  
  if AImage.Picture.Bitmap.Width > 0 then begin  
    Result.Canvas.Brush.Color := clWhite;  
    Result.PixelFormat := pf24bit;  
    Result.SetSize(w, h);  
    Result.Canvas.StretchDraw( AImage.ClientRect, AImage.Picture.Graphic );  
  end;  
end;  

class procedure TUtilImagem.CreateAvatar(var AImage: TImage;
                                         const ABorderColor: TColor;
                                         const ABorderWidth: Integer;
                                         const ABackgroundColor: TColor);
//ajusta a imagem para o tamanho do TImage
begin
  if AImage.Picture.Bitmap.Width > 0 then begin
    if (AImage.Picture.Bitmap.Width > AImage.Width) or (AImage.Picture.Bitmap.Height > AImage.Height) then
      //redimensiona a imagem para width e height do AImage
      ResizeToImageBox(AImage);

    AImage.Picture.Bitmap.Assign( RoundAvatarBitmap(AImage.Picture.Bitmap, ABorderColor, ABorderWidth, ABackgroundColor) );
  end;
end; 

class function TUtilImagem.RoundAvatarBitmap(const ASource: TBitmap; const ABorderColor: TColor;  
                                             const ABorderWidth: Integer; const ABackgroundColor: TColor): TBitmap;  
// cria um avatar da imagem informada  
var  
  CircleSize, Radius: Integer;  
  x, y, cx, cy: Integer;  
  dist: Double;  
begin  
  CircleSize := Min(ASource.Width, ASource.Height);  
  Radius := CircleSize div 2;  
  cx := Radius;  
  cy := Radius;  
  
  Result := TBitmap.Create;  
  Result.SetSize(CircleSize, CircleSize);  
  Result.PixelFormat := pf24bit;  
  
  // pinta fundo  
  Result.Canvas.Brush.Color := ABackgroundColor;  
  Result.Canvas.FillRect(0,0,CircleSize,CircleSize);  
  
  // percorre pixel a pixel  
  for y := 0 to CircleSize - 1 do  
    for x := 0 to CircleSize - 1 do  
    begin  
      dist := sqrt(sqr(x - cx) + sqr(y - cy));  
  
      if dist <= (Radius - ABorderWidth) then  
      begin  
        // dentro do círculo: copia da origem  
        Result.Canvas.Pixels[x,y] := ASource.Canvas.Pixels[x,y];  
      end  
      else if dist <= Radius then  
      begin  
        // borda  
        Result.Canvas.Pixels[x,y] := ABorderColor;  
      end  
      else  
      begin  
        // fora do círculo: já está no BackgroundColor  
      end;  
    end;  
end;  
  
end.   
  

