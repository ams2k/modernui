{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit PanelPlusPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  PanelPlus, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('PanelPlus', @PanelPlus.Register);
end;

initialization
  RegisterPackage('PanelPlusPackage', @Register);
end.
