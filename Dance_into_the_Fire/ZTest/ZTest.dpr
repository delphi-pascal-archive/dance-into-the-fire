program ZTest;

uses
  Forms,
  uMain in 'uMain.pas' {MainForm},
  uSprite in 'uSprite.pas',
  uSpriteText in 'uSpriteText.pas',
  uExplosion in 'uExplosion.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
