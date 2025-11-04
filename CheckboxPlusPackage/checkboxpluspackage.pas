{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit CheckboxPlusPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  CheckBoxPlus, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('CheckBoxPlus', @CheckBoxPlus.Register);
end;

initialization
  RegisterPackage('CheckboxPlusPackage', @Register);
end.
