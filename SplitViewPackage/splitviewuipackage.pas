{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit SplitViewUIPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  SplitViewUI, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('SplitViewUI', @SplitViewUI.Register);
end;

initialization
  RegisterPackage('SplitViewUIPackage', @Register);
end.
