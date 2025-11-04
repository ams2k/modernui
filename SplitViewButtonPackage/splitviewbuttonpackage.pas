{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit SplitViewButtonPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  SplitViewButton, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('SplitViewButton', @SplitViewButton.Register);
end;

initialization
  RegisterPackage('SplitViewButtonPackage', @Register);
end.
