unit Delphi.MSXML.Tests.Behaviour;

interface
uses
  DUnitX.TestFramework,
  Delphi.MSXML,
  Spring.Collections.Enumerable;

type

  [TestFixture]
  TMSXMLBehaviourTests = class(TObject)
  strict protected
    FXml: TMSXML;
    function GetTestRootDirectory: String;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestImplicitStringWillLoadStringIntoANewDocument;
    [Test]
    procedure TestImplicitDocumentWillBeKeptByRecord;
    [Test]
    procedure TestUninitializedRecordHasAlwaysADocumentInstance;
    [Test]
    procedure TestUnitializedRecordHasExistingButEmptyDocument;
    [TestCase('Test1', 'ejrhkwjehrkjwehr.xml')]
    [TestCase('Test2', 'testdata\invalidxml.xml')]
    procedure TestLoadFromNotExistingOrInvalidFileWillReturnFalse(const AFilePath: String);
    [TestCase('Test1', 'ejrhkwjehrkjwehr.xml')]
    [TestCase('Test2', 'testdata\invalidxml.xml')]
    procedure TestLoadFromNotExistingOrInvalidFileWillNotThrowAny(const AFilePath: String);

  end;

implementation

uses
  Winapi.msxml,
  System.IOUtils,
  System.SysUtils;

{ TMSXMLBehaviourTests }

procedure TMSXMLBehaviourTests.Setup;
begin
  FXml.EnableXPath;
end;

procedure TMSXMLBehaviourTests.TearDown;
begin
  FXML.Free;
end;

procedure TMSXMLBehaviourTests.TestImplicitDocumentWillBeKeptByRecord;
var
  LDocument: DOMDocument;
begin
  LDocument := CoDOMDocument.Create;
  Assert.AreNotEqual(LDocument, FXML.Value);

  FXML := LDocument;
  Assert.AreEqual(LDocument, FXML.Value);
end;

procedure TMSXMLBehaviourTests.TestUninitializedRecordHasAlwaysADocumentInstance;
begin
  Assert.IsNotNull(FXml.Value);
end;

procedure TMSXMLBehaviourTests.TestUnitializedRecordHasExistingButEmptyDocument;
begin
  Assert.IsNotNull(FXml.Value);
  Assert.IsNull(FXml.Value.documentElement);
end;

procedure TMSXMLBehaviourTests.TestImplicitStringWillLoadStringIntoANewDocument;
const
  XMLCONTENT =
    '<?xml version="1.0" encoding="UTF-8"?>' +
      '<bookstore>' +
      '<book category="COOKING">' +
      '  <title lang="en">Everyday Italian</title>' +
      '  <author>Giada De Laurentiis</author>' +
      '  <year>2005</year>' +
      '  <price>30.00</price>' +
      '</book>' +
      '<book category="CHILDREN">' +
      '  <title lang="en">Harry Potter</title>' +
      '  <author>J K. Rowling</author>' +
      '  <year>2005</year>' +
      '  <price>29.99</price>' +
      '</book>' +
      '<book category="WEB">' +
      '  <title lang="en">XQuery Kick Start</title>' +
      '  <author>James McGovern</author>' +
      '  <author>Per Bothner</author>' +
      '  <author>Kurt Cagle</author>' +
      '  <author>James Linn</author>' +
      '  <author>Vaidyanathan Nagarajan</author>' +
      '  <year>2003</year>' +
      '  <price>49.99</price>' +
      '</book>' +
      '<book category="WEB">' +
      '  <title lang="en">Learning XML</title>' +
      '  <author>Erik T. Ray</author>' +
      '  <year>2003</year>' +
      '  <price>39.95</price>' +
      '</book>' +
      '</bookstore>';
var
  LFoundNode: IXMLDomNode;
begin
  FXML := XMLCONTENT;
  FXml.EnableXPath;
  Assert.IsTrue(FXML.Query('//bookstore', LFoundNode));
  Assert.IsTrue(FXML.Query('//bookstore/book[1]', LFoundNode));
  Assert.IsTrue(FXML.Query('//bookstore/book[2]', LFoundNode));
  Assert.IsTrue(FXML.Query('//bookstore/book[3]', LFoundNode));
  Assert.IsTrue(FXML.Query('//bookstore/book[4]', LFoundNode));
end;

procedure TMSXMLBehaviourTests.TestLoadFromNotExistingOrInvalidFileWillReturnFalse(const AFilePath: String);
var
  LFilePath: String;
begin
  LFilePath := GetTestRootDirectory + AFilePath;
  Assert.IsFalse(FXml.LoadFromFile(LFilePath));
end;

procedure TMSXMLBehaviourTests.TestLoadFromNotExistingOrInvalidFileWillNotThrowAny(const AFilePath: String);
var
  LFilePath: String;
begin
  LFilePath := GetTestRootDirectory + AFilePath;

  Assert.WillNotRaiseAny(
  procedure
  begin
    FXml.LoadFromFile(LFilePath);
  end
  );
end;

function TMSXMLBehaviourTests.GetTestRootDirectory: String;
begin
  Result := TDirectory.GetParent(TDirectory.GetCurrentDirectory);
  Result := IncludeTrailingPathDelimiter(Result);
end;

initialization
  TDUnitX.RegisterTestFixture(TMSXMLBehaviourTests);
end.
