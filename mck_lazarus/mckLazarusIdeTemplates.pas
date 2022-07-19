unit mckLazarusIdeTemplates;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazIDEIntf, ProjectIntf, Controls, Forms;

type
  { TKOLApplicationDescriptor }

  TKOLApplicationDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

  { TFileDescPascalUnitWithKOLForm }

  TFileDescPascalUnitWithKOLForm = class(TFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetResourceSource(const ResourceName: string): string; override;
    function CreateSource(const Filename, SourceName,
                          ResourceName: string): string; override;
    function GetInterfaceSource(const Filename, SourceName,
                                ResourceName: string): string; override;
  end;

procedure Register;

implementation

uses LazFileUtils, CodeToolManager;

procedure Register;
begin
  RegisterProjectDescriptor(TKOLApplicationDescriptor.Create);
  RegisterProjectFileDescriptor(TFileDescPascalUnitWithKOLForm.Create);
end;

{ TKOLApplicationDescriptor }

constructor TKOLApplicationDescriptor.Create;
begin
  inherited Create;
  Name := 'KOL Application';
end;

function TKOLApplicationDescriptor.GetLocalizedName: string;
begin
  Result := 'KOL Toolkit Application';
end;

function TKOLApplicationDescriptor.GetLocalizedDescription: string;
var
  le: string;
begin
  le := System.LineEnding;
  Result := 'KOL Toolkit Application'+le+le
           +'An application based on the KOL Toolkit.';
end;

function TKOLApplicationDescriptor.InitProject(AProject: TLazProject): TModalResult;
var
  le: string;
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  inherited InitProject(AProject);

  MainFile := AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject := true;
  AProject.AddFile(MainFile, false);
  AProject.MainFileID := 0;

  // create program source
  le := LineEnding;
  NewSource :=
     '{ KOL MCK } // Do not remove this line!'+le
    +'{$DEFINE KOL_MCK}'+le
    +'{$ifdef FPC} {$mode delphi} {$endif}'+le
    +'program Project1;'+le
    +le
    +'uses'+le
    +'  KOL;'+le
    +le
    +'begin // PROGRAM START HERE -- Please do not remove this comment'+le
    +'  Application.Initialize;'+le
    +'  Application.Run;'+le
    +'end.'+le
    +le;

  AProject.MainFile.SetSourceText(NewSource);

  // compiler options
  with AProject.LazCompilerOptions do begin
    Win32GraphicApp:=True;
    SyntaxMode:='Delphi';
    ShowHints:=False;
    GenerateDebugInfo:=True;
    UseLineInfoUnit:=False;
    UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  end;

  AProject.AddPackageDependency('MirrorKOLPackage');

  Result := mrOK;
end;

function TKOLApplicationDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult;
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
  if Result = mrOk then
    Result:=LazarusIDE.DoNewEditorFile(ProjectFileDescriptors.FindByName('KOL Form'),'','',
                         [nfIsPartOfProject,nfOpenInEditor,nfCreateDefaultSrc]);
end;

{ TFileDescPascalUnitWithKOLForm }

constructor TFileDescPascalUnitWithKOLForm.Create;
begin
  inherited Create;
  Name:='KOL Form';
  ResourceClass:=TForm;
  UseCreateFormStatements:=true;
end;

function TFileDescPascalUnitWithKOLForm.GetInterfaceUsesSection: string;
begin
  Result:='Forms';
end;

function TFileDescPascalUnitWithKOLForm.GetLocalizedName: string;
begin
  Result:='KOL Form';
end;

function TFileDescPascalUnitWithKOLForm.GetLocalizedDescription: string;
begin
  Result:='Create a new unit with a KOL form';
end;

function TFileDescPascalUnitWithKOLForm.GetResourceSource(const ResourceName: string): string;
var
  le: string;
begin
  le := LineEnding;
  Result :=
    'inherited '+ ResourceName+': T'+ResourceName+le+
    '  Width = 400'+le+
    '  Height = 300'+le+
    '  Left = '+IntToStr((Screen.Width - 400) div 2)+le+
    '  Top = '+IntToStr((Screen.Height - 300) div 2)+le;

  if LazarusIDE.ActiveProject.FileCount < 3 then
    Result:=Result+
      '  object KOLProject: TKOLProject'+le+
      '    projectDest = '''+ ExtractFilenameOnly(LazarusIDE.ActiveProject.MainFile.Filename) + ''''+le+
      '    left = 8'+le+
      '    top = 8'+le+
//      '    sourcePath = ''non_existing_folder_for_kol_project'''+le+
      '    projectDest = ''empty_temp_project'''+le+
      '  end'+le;

  Result:=Result+
    '  object KOL'+ResourceName+': TKOLForm'+le+
    '    left = 40'+le+
    '    top = 8'+le+
    '  end'+le+
    'end'+le;
end;

function TFileDescPascalUnitWithKOLForm.CreateSource(const Filename, SourceName, ResourceName: string): string;
begin
  Result:=inherited CreateSource(Filename, SourceName, ResourceName);
  CodeToolBoss.CreateFile(ChangeFileExt(Filename, DefaultResFileExt));
end;

function TFileDescPascalUnitWithKOLForm.GetInterfaceSource(const Filename, SourceName, ResourceName: string): string;
var
  LE: string;
begin
  LE:=LineEnding;
  Result:=
     'type'+LE
    +'  T'+ResourceName+' = class('+ResourceClass.ClassName+')'+LE
    +'    KOL'+ResourceName+': TKOLForm;'+LE;

  if LazarusIDE.ActiveProject.FileCount < 3 then
    Result:=Result
    +'    KOLProject: TKOLProject;'+LE;

  Result:=Result
    +'  private'+LE
    +'    { private declarations }'+LE
    +'  public'+LE
    +'    { public declarations }'+LE
    +'  end;'+LE
    +LE
    +'var'+LE
    +'  '+ResourceName+': T'+ResourceName+';'+LE
    +LE;
end;

end.
