unit Delphi.MSXML.Helper.Guard;

interface

uses
  Spring,
  System.SysUtils;

type
  EMSXMLAttributeNotFoundError = class(Exception);
  EMSXMLInvalidAttributeNameError = class(Exception);

  TMSXMLWrapperGuardHelper = record helper for Guard
  public
    class function CheckIsAttributeNameValid(const AAttributeName: String): boolean; static;
    class procedure RaiseInvalidAttributeNameError(const AAttributeName: String); static;
    class procedure RaiseAttributeNotFoundError(const AAttributeName: String; const ANodeName: String); static;
  end;


implementation


{ TMSXMLWrapperGuardHelper }

class procedure TMSXMLWrapperGuardHelper.RaiseAttributeNotFoundError(const AAttributeName, ANodeName: String);
begin
  raise EMSXMLAttributeNotFoundError.Create('requested attribute "' + AAttributeName + '" not found in node "' + ANodeName + '"');
end;

class function TMSXMLWrapperGuardHelper.CheckIsAttributeNameValid(const AAttributeName: String): boolean;
begin
  Result := not Trim(AAttributeName).IsEmpty;
  if not Result then
    RaiseInvalidAttributeNameError(AAttributeName);
end;

class procedure TMSXMLWrapperGuardHelper.RaiseInvalidAttributeNameError(const AAttributeName: String);
begin
  raise EMSXMLInvalidAttributeNameError.Create('attribute name is not valid: "' + AAttributeName +'"');
end;

end.
