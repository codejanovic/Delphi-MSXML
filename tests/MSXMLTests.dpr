program MSXMLTests;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}
uses
  SysUtils,
  TestInsight.DUnitX,
  TestInsight.Client,
  System.Win.ComObj,
  Winapi.ActiveX,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  Delphi.MSXML.Tests.XPath in 'Delphi.MSXML.Tests.XPath.pas',
  Delphi.MSXML.Tests.Nodes in 'Delphi.MSXML.Tests.Nodes.pas',
  Delphi.MSXML.Tests.Behaviour in 'Delphi.MSXML.Tests.Behaviour.pas',
  Delphi.MSXML in '..\Delphi.MSXML.pas',
  Delphi.MSXML.Tests.Attributes in 'Delphi.MSXML.Tests.Attributes.pas',
  Delphi.MSXML.Helper.Guard in '..\Delphi.MSXML.Helper.Guard.pas';

function IsTestInsightRunning: Boolean;
var
  client: ITestInsightClient;
begin
  client := TTestInsightRestClient.Create;
  client.StartedTesting(0);
  Result := not client.HasError;
end;

procedure RunDUnitXConsoleRunner;
var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;
    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end;

begin
  CoInitializeEx(nil, COINIT_MULTITHREADED);

  {$IFDEF TESTINSIGHT}
  if IsTestInsightRunning then
    TestInsight.DUnitX.RunRegisteredTests
  else
  {$ENDIF}
    RunDUnitXConsoleRunner;
end.
