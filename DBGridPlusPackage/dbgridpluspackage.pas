{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit DBGridPlusPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  DBGridPlus, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('DBGridPlus', @DBGridPlus.Register);
end;

initialization
  RegisterPackage('DBGridPlusPackage', @Register);
end.
