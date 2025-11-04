{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit MaskedEditPlusPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  MaskedEditPlus, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('MaskedEditPlus', @MaskedEditPlus.Register);
end;

initialization
  RegisterPackage('MaskedEditPlusPackage', @Register);
end.
