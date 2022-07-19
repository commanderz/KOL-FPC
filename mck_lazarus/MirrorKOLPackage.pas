{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit MirrorKOLPackage;

{$warn 5023 off : no warning about unused units}
interface

uses
  KOL, KOLadd, KOLDirDlgEx, mirror, mckCtrls, mckObjs, mckLazarusIdeTemplates, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('mirror', @mirror.Register);
  RegisterUnit('mckCtrls', @mckCtrls.Register);
  RegisterUnit('mckObjs', @mckObjs.Register);
  RegisterUnit('mckLazarusIdeTemplates', @mckLazarusIdeTemplates.Register);
end;

initialization
  RegisterPackage('MirrorKOLPackage', @Register);
end.
