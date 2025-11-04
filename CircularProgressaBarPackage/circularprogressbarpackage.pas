{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit CircularProgressBarPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  CircularProgressBar, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('CircularProgressBar', @CircularProgressBar.Register);
end;

initialization
  RegisterPackage('CircularProgressBarPackage', @Register);
end.
