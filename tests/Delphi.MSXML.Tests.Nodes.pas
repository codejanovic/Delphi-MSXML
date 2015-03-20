unit Delphi.MSXML.Tests.Nodes;

interface
uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TNodesTests = class(TObject) 
  public
    [Test]
    procedure TestCopyNodeToAnotherDocumentIsACopy;
    [Test]
    procedure TestChildNodesAreCorrect;
    [Test]
    procedure TestChildNodesOfAreCorrect;
  end;

implementation

uses
  Delphi.MSXML,
  Winapi.msxml, Spring.Collections;

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

{ TNodesTests }

procedure TNodesTests.TestCopyNodeToAnotherDocumentIsACopy;
var
  doc1,
  doc2: TMSXML;
  root1,
  root2: IXMLDomNode;
begin
  root1 := doc1.CreateChildNode('rootnode');
  root2 := doc2.Value.appendChild(root1.cloneNode(true));

  Assert.AreEqual(root1.text, root2.text);
  root1.text := 'im the root1 node';
  Assert.AreNotEqual(root1.text, root2.text);
end;

procedure TNodesTests.TestChildNodesAreCorrect;
var
  LMSXML: TMSXML;
  LResult: IEnumerable<IXMLDOMNode>;
begin
  Assert.IsTrue(LMSXML.LoadFromContent(XMLCONTENT));
  LResult := LMSXML.ChildNodes;
  Assert.AreEqual(LResult.Count, LMSXML.Value.childNodes.length);
end;

procedure TNodesTests.TestChildNodesOfAreCorrect;
var
  LMSXML: TMSXML;
  LResult: IEnumerable<IXMLDOMNode>;
begin
  Assert.IsTrue(LMSXML.LoadFromContent(XMLCONTENT));
  LResult := LMSXML.ChildNodesOf(LMSXML.Value.documentElement);
  Assert.AreEqual(LResult.Count, LMSXML.Value.documentElement.childNodes.length);
end;

initialization
  TDUnitX.RegisterTestFixture(TNodesTests);
end.
