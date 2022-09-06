function [fields,response] = getFields(c,userCatalog,field)
%GETFIELDS Retrieve request information.
%   [FIELDLIST,RESPONSE] = GETFIELDS(C,USERCATALOG,FIELD)
%   returns a list of all available fields or information about a given 
%   field.  C is the bloombergHypermedia object, USERCATALOG is the user's 
%   catalog id and FIELD is the field name.  If FIELD is not specified, all
%   available field information is returned.
%
%   For example,
%
%   [requestList,response] = getFields(b,"bbg")
%   [requestList,response] = getFields(b,"bbg","pxLast")
%
%   See also bloombergHypermedia.

%   Copyright 2022 The MathWorks, Inc. 

% Set http method
method = "GET";

% Create EAP path for request
eapPath = strcat("/eap/catalogs/", string(userCatalog), "/fields/");
if exist("field","var") && ~isempty(field)
  eapPath = strcat(eapPath,field,"/");
end

% Send request data
response = bhapiEngine(c,method,eapPath,eapPath);

switch string(response.StatusCode)
  case "303"
    % Parse pages in response
    fields = parsePagesResponse(c,method,eapPath,response);
  case "200"
    % Parse response with only a single page
    fields = struct2table(jsondecode(native2unicode(response.Body.Data)'),"AsArray",true);
  otherwise
    % All other response types
    fields = response;
end