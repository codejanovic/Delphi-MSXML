unit Delphi.MSXML;

interface

uses
  Winapi.msxml,
  Spring.Collections;

const
  PROPERTY_SELECTIONLANGUAGE = 'SelectionLanguage';
  SELECTIONLANGUAGE_XPATH = 'XPath';
type

  TMSXML = record
  private
    FDocument: DOMDocument;

    procedure SuppressAllExceptions;
    procedure InternalCreateNewXmlDocument;
  public
    constructor Create(const AXMLContent: String); overload;
    constructor Create(const ADocument: DOMDocument); overload;

    procedure Free;

    class operator Implicit(const value: String): TMSXML;
    class operator Implicit(const value: DOMDocument): TMSXML;
    class operator Implicit(const value: TMSXML): String;
    class operator Implicit(const value: TMSXML): DOMDocument;

    function GetValue: DOMDocument;
    property Value: DOMDocument read GetValue;

  public
    function HasParseErrors: boolean;

    function LoadFromFile(const AFileName: String): boolean;
    function LoadFromContent(const AXMLContent: String): boolean;

    procedure EnableUTF8Encoding;
    procedure EnableXPath;
    function IsXPathEnabled: boolean;

    procedure RemoveAllChildNodes(const ANode: IXMLDomNode);
    procedure CopyAllChildNodes(const ASource: IXMLDomNode; const ADestination: IXMLDomNode);

    function ChildNodes: IEnumerable<IXMLDOMNode>;
    function ChildNodesOf(const AParentNode: IXMLDOMNode): IEnumerable<IXMLDOMNode>;
    function CreateAndAddProcessInstruction(const ATarget: String; const AData: String): IXMLDOMProcessingInstruction; overload;
    function CreateAndAddProcessInstruction(const ANode: IXMLDomNode; const ATarget: String; const AData: String): IXMLDOMProcessingInstruction; overload;
    function CreateChildNode(const AParentNode: IXMLDOmNode; const AChildNodeName: String): IXMLDomNode; overload;
    function CreateChildNode(const AChildNodeName: String): IXMLDomNode; overload;
    function CreateNode(const ANodeName: String): IXMLDomNode;
    function CreateAndAddAttribute(const ANode: IXMLDomNode; const AAttributeName: string; const AAttributeValue: string = ''): IXMLDOMAttribute;

    function Query(const AQueryString: String; out OFoundNode: IXMLDomNode): boolean; overload;
    function Query(const ANode: IXMLDOMNode; const AQueryString: String; out OFoundNode: IXMLDomNode): boolean; overload;
    function QueryMultiple(const AQueryString: String; out OFoundNodeList: IXMLDomNodeList): boolean; overload;
    function QueryMultiple(const ANode: IXMLDOMNode; const AQueryString: String; out OFoundNodeList: IXMLDomNodeList): boolean; overload;

    procedure RemoveAttribute(const ANode: IXMLDomNode; const AAttributeName: string);
    procedure UpdateAttributeValue(const ANode: IXMLDomNode; const AAttributeName, AAttributeValue: string);
    function TryGetAttribute(const ANode: IXMLDomNode; const AAttributeName: String; out OFoundAttribute: IXMLDOMAttribute): boolean;
  end;

implementation

uses
  Spring,
  System.SysUtils,
  Delphi.MSXML.Helper.Guard;

{ TMSXML }

constructor TMSXML.Create(const AXMLContent: String);
begin
  Value.loadXML(AXMLContent);
end;

constructor TMSXML.Create(const ADocument: DOMDocument);
begin
  FDocument := ADocument;
end;

class operator TMSXML.Implicit(const value: DOMDocument): TMSXML;
begin
  Result.Create(value);
end;

class operator TMSXML.Implicit(const value: String): TMSXML;
begin
  Result.Create(value);
end;

class operator TMSXML.Implicit(const value: TMSXML): DOMDocument;
begin
  Result := value.Value;
end;

class operator TMSXML.Implicit(const value: TMSXML): String;
begin
  Result := value.Value.XML;
end;

procedure TMSXML.Free;
begin
  FDocument := NIL;
end;

function TMSXML.GetValue: DOMDocument;
begin
  if not Assigned(FDocument) then
    InternalCreateNewXmlDocument;

  Result := FDocument;
end;

procedure TMSXML.InternalCreateNewXmlDocument;
begin
  FDocument := CoDOMDocument.Create;
  FDocument.async := false;
  FDocument.validateOnParse := false;
  FDocument.resolveExternals :=false;
end;

function TMSXML.LoadFromFile(const AFileName: String): boolean;
begin
  Value.load(AFileName);
  Result :=  not HasParseErrors;
end;

function TMSXML.LoadFromContent(const AXMLContent: String): boolean;
begin
  Value.loadXML(AXMLContent);
  Result := not HasParseErrors;
end;

procedure TMSXML.CopyAllChildNodes(const ASource, ADestination: IXMLDomNode);
var
  i: Integer;
  sourceChildNode: IXMLDomNode;
begin
  Guard.CheckNotNull(ASource, 'missing Source Node');
  Guard.CheckNotNull(ADestination, 'missing Destination Node');

  for I := 0 to ASource.childNodes.length -1 do
  begin
    sourceChildNode := ASource.childNodes.item[i];
    ADestination.appendChild(sourceChildNode.cloneNode(true));
  end;
end;

function TMSXML.CreateChildNode(const AParentNode: IXMLDOmNode; const AChildNodeName: String): IXMLDomNode;
begin
  Guard.CheckNotNull(AParentNode, 'missing Parentnode');

  Result := CreateNode(AChildNodeName);
  AParentNode.appendChild(Result);
end;

function TMSXML.CreateNode(const ANodeName: String): IXMLDomNode;
begin
  Result := Value.createElement(ANodeName);
end;

function TMSXML.CreateAndAddProcessInstruction(const ATarget, AData: String): IXMLDOMProcessingInstruction;
begin
  Result := CreateAndAddProcessInstruction(Value, ATarget, AData);
end;

function TMSXML.CreateAndAddProcessInstruction(const ANode: IXMLDomNode; const ATarget, AData: String): IXMLDOMProcessingInstruction;
begin
  Result := Value.createProcessingInstruction(ATarget, AData);
  ANode.appendChild(Result);
end;

function TMSXML.CreateChildNode(const AChildNodeName: String): IXMLDomNode;
begin
  Result := CreateChildNode(Value, AChildNodeName);
end;

function TMSXML.CreateAndAddAttribute(const ANode: IXMLDomNode; const AAttributeName, AAttributeValue: string): IXMLDOMAttribute;
begin
  Guard.CheckNotNull(ANode, 'missing Node');
  Guard.CheckIsAttributeNameValid(AAttributeName);

  Result := Value.createAttribute(AAttributeName);
  Result.text := AAttributeValue;

  ANode.attributes.setNamedItem(Result);
end;

procedure TMSXML.EnableUTF8Encoding;
begin
  CreateAndAddProcessInstruction('xml', ' version=''1.0'' encoding=''UTF-8''');
end;

procedure TMSXML.EnableXPath;
begin
  Value.setProperty(PROPERTY_SELECTIONLANGUAGE, SELECTIONLANGUAGE_XPATH);
end;

function TMSXML.HasParseErrors: boolean;
begin
  Result := Value.parseError.errorCode <> 0;
end;

function TMSXML.IsXPathEnabled: boolean;
const
  XPATH = 'XPath';
begin
  Result := XPATH.Equals(Value.getProperty(PROPERTY_SELECTIONLANGUAGE));
end;

procedure TMSXML.SuppressAllExceptions;
begin
end;

function TMSXML.TryGetAttribute(const ANode: IXMLDomNode; const AAttributeName: String; out OFoundAttribute: IXMLDOMAttribute): boolean;
begin
  Guard.CheckNotNull(ANode, 'missing Node');

  OFoundAttribute := ANode.attributes.getNamedItem(AAttributeName) AS IXMLDOMAttribute;
  Result := Assigned(OFoundAttribute);
end;

procedure TMSXML.UpdateAttributeValue(const ANode: IXMLDomNode; const AAttributeName, AAttributeValue: string);
var
  attribute: IXMLDOMAttribute;
begin
  Guard.CheckNotNull(ANode, 'missing Node');

  if not TryGetAttribute(ANode, AAttributeName, attribute) then
    Guard.RaiseAttributeNotFoundError(AAttributeName, ANode.nodeName);

  attribute.text := AAttributeValue;
end;

procedure TMSXML.RemoveAllChildNodes(const ANode: IXMLDomNode);
var
  i: Integer;
  childsToDelete: IList<IXMLDomNode>;
  childNodeToDelete: IXMLDomNode;
begin
  Guard.CheckNotNull(ANode, 'missing Node');

  childsToDelete := TCollections.CreateList<IXMLDomNode>;
  for I := 0 to ANode.childNodes.length -1 do
    childsToDelete.add(ANode.childNodes.item[i]);

  for childNodeToDelete in childsToDelete do
    ANode.RemoveChild(childNodeToDelete);
end;

procedure TMSXML.RemoveAttribute(const ANode: IXMLDomNode; const AAttributeName: string);
begin
  Guard.CheckNotNull(ANode, 'missing Node');
  ANode.attributes.removeNamedItem(AAttributeName);
end;

function TMSXML.Query(const AQueryString: String; out OFoundNode: IXMLDomNode): boolean;
begin
  Result := Query(Value, AQueryString, OFoundNode);
end;

function TMSXML.QueryMultiple(const ANode: IXMLDOMNode; const AQueryString: String; out OFoundNodeList: IXMLDomNodeList): boolean;
begin
  Guard.CheckNotNull(ANode, 'missing Node');
  Guard.CheckFalse(Trim(AQueryString).IsEmpty, 'missing XPath QueryString');

  try
    try
      OFoundNodeList := ANode.selectNodes(AQueryString);
    except
      SuppressAllExceptions
    end;
  finally
    Result := Assigned(OFoundNodeList);
  end;
end;

function TMSXML.Query(const ANode: IXMLDOMNode; const AQueryString: String; out OFoundNode: IXMLDomNode): boolean;
begin
  Guard.CheckNotNull(ANode, 'missing Node');
  Guard.CheckFalse(Trim(AQueryString).IsEmpty, 'missing XPath QueryString');

  try
    try
      OFoundNode := ANode.selectSingleNode(AQueryString);
    except
      SuppressAllExceptions
    end;
  finally
    Result := Assigned(OFoundNode);
  end;
end;

function TMSXML.QueryMultiple(const AQueryString: String; out OFoundNodeList: IXMLDomNodeList): boolean;
begin
  Result := QueryMultiple(Value, AQueryString, OFoundNodeList);
end;

function TMSXML.ChildNodes: IEnumerable<IXMLDOMNode>;
begin
  Result := ChildNodesOf(Value);
end;

function TMSXML.ChildNodesOf(const AParentNode: IXMLDOMNode): IEnumerable<IXMLDOMNode>;
var
  LChildNodes: IList<IXMLDOMNode>;
  I: Integer;
begin
  LChildNodes := TCollections.CreateList<IXMLDOMNode>;
  Result := LChildNodes;

  for I := 0 to AParentNode.childNodes.length -1 do
    LChildNodes.Add(AParentNode.childNodes.item[i]);
end;

end.
