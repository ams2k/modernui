{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit ToggleButtonPlusPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  ToggleButtonPlus, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ToggleButtonPlus', @ToggleButtonPlus.Register);
end;

initialization
  RegisterPackage('ToggleButtonPlusPackage', @Register);
end.
