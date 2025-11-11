{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit ChasePanelPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  ChasePanel, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ChasePanel', @ChasePanel.Register);
end;

initialization
  RegisterPackage('ChasePanelPackage', @Register);
end.
