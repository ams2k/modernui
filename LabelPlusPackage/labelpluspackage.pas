{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit LabelPlusPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  LabelPlus, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('LabelPlus', @LabelPlus.Register);
end;

initialization
  RegisterPackage('LabelPlusPackage', @Register);
end.
