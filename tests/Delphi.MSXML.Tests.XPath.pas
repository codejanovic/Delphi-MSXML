unit Delphi.MSXML.Tests.XPath;

interface
uses
  DUnitX.TestFramework,
  Delphi.MSXML;

type

  [TestFixture]
  TXPathTests = class(TObject)
  strict protected
    FMSXML: TMSXML;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure Teardown;

    [TestCase('Test1', '/bookstore/book[1]')]
    [TestCase('Test2', '/bookstore/book[last()]')]
    [TestCase('Test3', '/bookstore/book[last()-1]')]
    [TestCase('Test4', '/bookstore/book[position()<3]')]
    [TestCase('Test5', '//title[@lang]')]
    [TestCase('Test6', '//title[@lang=''en'']')]
    [TestCase('Test7', '/bookstore/book[price>35.00]')]
    [TestCase('Test8', '/bookstore/book[price>35.00]/title')]
    procedure TestGetSingleNodeFromXPath(const AXPathQuery: String);
  end;

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

implementation

uses
  Spring,
  Winapi.msxml;


{ TXPathTests }

procedure TXPathTests.Setup;
begin
  Guard.CheckTrue(FMSXML.LoadFromContent(XMLCONTENT));
  FMSXML.EnableXPath;
end;

procedure TXPathTests.Teardown;
begin
  FMSXML.Free;
end;

procedure TXPathTests.TestGetSingleNodeFromXPath(const AXPathQuery: String);
var
  LResultNode: IXMLDomNode;
begin
  Assert.IsTrue(FMSXML.Query(AXPathQuery, LResultNode));
  Assert.IsNotNull(LResultNode);
end;

initialization
  TDUnitX.RegisterTestFixture(TXPathTests);
end.
