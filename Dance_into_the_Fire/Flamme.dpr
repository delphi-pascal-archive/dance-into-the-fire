program Flamme;

uses
  Forms,
  uMain in 'uMain.pas' {FlammeForm},
  uFlamme in 'uFlamme.pas',
  uMario in 'uMario.pas',
  uFloor in 'uFloor.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFlammeForm, FlammeForm);
  Application.Run;
end.
