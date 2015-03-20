unit Delphi.MSXML.Tests.Attributes;


interface
uses
  DUnitX.TestFramework,
  Delphi.MSXML,
  Winapi.msxml;

type

  [TestFixture]
  TAttributeTests = class(TObject)
  strict protected
    FMSXMLHelper: TMSXML;
    FXMLNodeToTestWith: IXMLDomNode;
  strict protected const
    NODENAME = 'attributeTestNode';
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [TestCase('Test1', 'a')]
    [TestCase('Test1', 'anystring')]
    procedure TestAddAttributeWithValidNameWillPass(const AAttributeName: String);

    [TestCase('Test1', '')]
    [TestCase('Test2', '   ')]
    procedure TestAddAttributeWithInvalidNameWillFail(const AAttributeName: String);

    [TestCase('Test1', 'name')]
    procedure TestAddAttribute(const AAttributeName: String);

    [TestCase('Test1', 'name,value')]
    procedure TestAddAttributeWithValue(const AAttributeName: String; const AAttributeValue: String);

    [TestCase('Test1', 'name')]
    procedure TestRemoveAttribute(const AAttributeName: String);

    [TestCase('Test1', 'name')]
    procedure TestRemoveNotExistingAttributeWillPassWithoutErrors(const AAttributeName: String);

    [TestCase('Test1', 'name')]
    procedure TestAddAttributeWithExistingNameWillNotAddANewAttribute(const AAttributeName: String);

    [TestCase('Test1', 'name')]
    procedure TestTryGetExistingAttributeWillReturnTrue(const AAttributeName: String);

    [TestCase('Test1', 'name')]
    procedure TestTryGetNotExistingAttributeWillReturnFalse(const AAttributeName: String);

    [TestCase('Test1', 'name')]
    procedure TestTryGetExistingAttributeWillReturnAttribute(const AAttributeName: String);

    [TestCase('Test1', 'name')]
    procedure TestTryGetNotExistingAttributeWillReturnNIL(const AAttributeName: String);

    [TestCase('Test1', 'name,value')]
    procedure TestUpdateAttributeValue(const AAttributeName: String; const AAttributeValue: String);
  end;

implementation

uses
  Delphi.MSXML.Helper.Guard,
  System.SysUtils;


{ TAttributeTests }

procedure TAttributeTests.TestAddAttributeWithExistingNameWillNotAddANewAttribute(const AAttributeName: String);
begin
  Assert.AreEqual(0, FXMLNodeToTestWith.attributes.length);

  FMSXMLHelper.CreateAndAddAttribute(FXMLNodeToTestWith, AAttributeName);
  Assert.AreEqual(1, FXMLNodeToTestWith.attributes.length);

  FMSXMLHelper.CreateAndAddAttribute(FXMLNodeToTestWith, AAttributeName);
  FMSXMLHelper.CreateAndAddAttribute(FXMLNodeToTestWith, AAttributeName);
  FMSXMLHelper.CreateAndAddAttribute(FXMLNodeToTestWith, AAttributeName);
  Assert.AreEqual(1, FXMLNodeToTestWith.attributes.length);
end;

procedure TAttributeTests.TearDown;
begin
  FMSXMLHelper.Free;
end;

procedure TAttributeTests.TestAddAttribute(const AAttributeName: String);
begin
  Assert.AreEqual(0, FXMLNodeToTestWith.attributes.length);

  FMSXMLHelper.CreateAndAddAttribute(FXMLNodeToTestWith, AAttributeName);
  Assert.AreEqual(1, FXMLNodeToTestWith.attributes.length);

  FMSXMLHelper.CreateAndAddAttribute(FXMLNodeToTestWith, AAttributeName+AAttributeName);
  Assert.AreEqual(2, FXMLNodeToTestWith.attributes.length);
end;

procedure TAttributeTests.TestRemoveAttribute(const AAttributeName: String);
begin
  Assert.AreEqual(0, FXMLNodeToTestWith.attributes.length);

  FMSXMLHelper.CreateAndAddAttribute(FXMLNodeToTestWith, AAttributeName);
  Assert.AreEqual(1, FXMLNodeToTestWith.attributes.length);

  FMSXMLHelper.RemoveAttribute(FXMLNodeToTestWith, AAttributeName);
  Assert.AreEqual(0, FXMLNodeToTestWith.attributes.length);
end;

procedure TAttributeTests.TestRemoveNotExistingAttributeWillPassWithoutErrors(const AAttributeName: String);
begin
  Assert.AreEqual(0, FXMLNodeToTestWith.attributes.length);

  FMSXMLHelper.RemoveAttribute(FXMLNodeToTestWith, AAttributeName);
  Assert.AreEqual(0, FXMLNodeToTestWith.attributes.length);
end;

procedure TAttributeTests.TestTryGetExistingAttributeWillReturnAttribute(const AAttributeName: String);
var
  LResultAttribute: IXMLDOMAttribute;
  LExpectedAttribute: IXMLDOMAttribute;
begin
  LExpectedAttribute := FMSXMLHelper.CreateAndAddAttribute(FXMLNodeToTestWith, AAttributeName);
  FMSXMLHelper.TryGetAttribute(FXMLNodeToTestWith, AAttributeName, LResultAttribute);

  Assert.IsNotNull(LResultAttribute);
  Assert.AreSame(LExpectedAttribute, LResultAttribute);
end;

procedure TAttributeTests.TestTryGetExistingAttributeWillReturnTrue(const AAttributeName: String);
var
  LAttribute: IXMLDOMAttribute;
begin
  FMSXMLHelper.CreateAndAddAttribute(FXMLNodeToTestWith, AAttributeName);
  Assert.IsTrue(FMSXMLHelper.TryGetAttribute(FXMLNodeToTestWith, AAttributeName, LAttribute));
end;

procedure TAttributeTests.TestTryGetNotExistingAttributeWillReturnFalse(const AAttributeName: String);
var
  LAttribute: IXMLDOMAttribute;
begin
  Assert.AreEqual(0, FXMLNodeToTestWith.attributes.length);
  Assert.IsFalse(FMSXMLHelper.TryGetAttribute(FXMLNodeToTestWith, AAttributeName, LAttribute));
end;

procedure TAttributeTests.TestTryGetNotExistingAttributeWillReturnNIL(const AAttributeName: String);
var
  LAttribute: IXMLDOMAttribute;
begin
  Assert.AreEqual(0, FXMLNodeToTestWith.attributes.length);
  FMSXMLHelper.TryGetAttribute(FXMLNodeToTestWith, AAttributeName, LAttribute);

  Assert.IsNull(LAttribute);
end;

procedure TAttributeTests.Setup;
begin
  FXMLNodeToTestWith := FMSXMLHelper.CreateChildNode(FMSXMLHelper.Value, NODENAME);
end;

procedure TAttributeTests.TestAddAttributeWithInvalidNameWillFail(const AAttributeName: String);
begin
  Assert.WillRaise(
    procedure
    begin
      FMSXMLHelper.CreateAndAddAttribute(FXMLNodeToTestWith, AAttributeName);
    end,
    EMSXMLInvalidAttributeNameError
  );
end;

procedure TAttributeTests.TestAddAttributeWithValidNameWillPass(const AAttributeName: String);
begin
  Assert.WillNotRaiseAny(
    procedure
    begin
      FMSXMLHelper.CreateAndAddAttribute(FXMLNodeToTestWith, AAttributeName);
    end
  );
end;

procedure TAttributeTests.TestAddAttributeWithValue(const AAttributeName, AAttributeValue: String);
var
  LAttribute: IXMLDOMAttribute;
begin
  Assert.AreEqual(0, FXMLNodeToTestWith.attributes.length);

  LAttribute := FMSXMLHelper.CreateAndAddAttribute(FXMLNodeToTestWith, AAttributeName, AAttributeValue);
  Assert.AreEqual(AAttributeValue, LAttribute.text);
end;

procedure TAttributeTests.TestUpdateAttributeValue(const AAttributeName, AAttributeValue: String);
var
  LAttribute: IXMLDOMAttribute;
begin
  Assert.AreEqual(0, FXMLNodeToTestWith.attributes.length);

  LAttribute := FMSXMLHelper.CreateAndAddAttribute(FXMLNodeToTestWith, AAttributeName);
  Assert.AreEqual(1, FXMLNodeToTestWith.attributes.length);
  Assert.IsEmpty(LAttribute.text);

  FMSXMLHelper.UpdateAttributeValue(FXMLNodeToTestWith, AAttributeName, AAttributeValue);
  Assert.AreEqual(AAttributeValue, LAttribute.text);
end;

initialization
  TDUnitX.RegisterTestFixture(TAttributeTests);
end.
