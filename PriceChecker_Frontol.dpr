program PriceChecker_Frontol;

uses
  Forms,
  main in 'main.pas' {Form_Posrednik};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Price checker <-> frontol';
  Application.CreateForm(TForm_Posrednik, Form_Posrednik);
  Application.Run;
end.
