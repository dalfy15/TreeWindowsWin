program TreeWindowsWin;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, 
  Main in 'Main.pas' {fmMain};

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled := True;
  Application.Initialize;
  Application.Title := 'Windows Browser';
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.

