function [requestID,response] = createRequest(c,userCatalog,universeID,fieldListID,triggerID)
%CREATEREQUEST Bloomberg Hypermedia data request.
%   [REQUESTID,RESPONSE] = CREATEREQUEST(C,USERCATALOG,UNIVERSEID,FIELDLISTID,TRIGGERID)
%   creates a Bloomberg Hypermedia data request. C is the
%   bloombergHypermedia object, UNIVERSEID, FIELDLISTID and TRIGGERID are
%   the universe, field list and trigger identifiers used to define the
%   request.  TRIGGERID defaults to a one time request if not specified.
%
%   [REQUESTID,RESPONSE] = CREATEREQUEST(C,PAYLOAD)
%   creates a Bloomberg Hypermedia data request. C is the
%   bloombergHypermedia object and PAYLOAD is a structure with the request
%   information.
%
%   For example,
%
%   [requestID,response] = createRequest(b,"myid","u20220126162804d2b7dd","fieldList202201261703442bf16a")
%
%   returns
%
%   requestID = 
% 
%     "r20220524135441e10a41"
% 
% 
% response = 
% 
%   ResponseMessage with properties:
% 
%     StatusLine: 'HTTP/1.1 201 CREATED'
%     StatusCode: Created
%         Header: [1×14 matlab.net.http.HeaderField]
%           Body: [1×1 matlab.net.http.MessageBody]
%      Completed: 1
%
%  requestID = "r" + bloombergHypermedia.generateResourcePostfix;
%  payload.type = "DataRequest";
%  payload.identifier = requestID;
%  payload.title = "My Request";
%  payload.description = "Test request with universe and fieldList";
%  payload.universe = strcat(c.URL,"/eap/catalogs/catalogid/universes/universeid");
%  payload.fieldList = strcat(c.URL,"/eap/catalogs/catalogid/fieldLists/fieldlistid");
%  payload.trigger = strcat(c.URL,"/eap/catalogs/bbg/triggers/oneshot/");
%  payload.formatting.type = "DataFormat";
%  payload.formatting.columnHeader = true;
%  payload.formatting.dateFormat = "yyyymmdd";
%  payload.formatting.delimiter = "|";
%  payload.formatting.fileType = "unixFileType";
%  payload.formatting.outputFormat = "variableOutputFormat";
%  payload.pricingSourceOptions.type = "DataPricingSourceOptions";
%  payload.pricingSourceOptions.prefer.mnemonic = "BGN"; 
%
%  [requestID,response] = createRequest(b,payload)
%
%   returns
%
%   requestID = 
% 
%     "r20220524135441e10a41"
% 
% 
% response = 
% 
%   ResponseMessage with properties:
% 
%     StatusLine: 'HTTP/1.1 201 CREATED'
%     StatusCode: Created
%         Header: [1×14 matlab.net.http.HeaderField]
%           Body: [1×1 matlab.net.http.MessageBody]
%      Completed: 1
%
%   See also bloombergHypermedia, getData.

%   Copyright 2022 The MathWorks, Inc. 

% Create payload structure if universe and field list identifiers given
if nargin > 3

  % Create unique request identifier
  requestID = "r" + bloombergHypermedia.generateResourcePostfix;
  payload.type = "DataRequest";
  payload.identifier = requestID;
  payload.title = "My Request";
  payload.description = "Test request with universe and fieldList";
  payload.universe = strcat(c.URL,"/eap/catalogs/", string(userCatalog), "/universes/",universeID);
  payload.fieldList = strcat(c.URL,"/eap/catalogs/", string(userCatalog), "/fieldLists/",fieldListID);

  if ~exist("triggerID","var") || isempty(triggerID)
    payload.trigger = strcat(c.URL,"/eap/catalogs/bbg/triggers/oneshot/");
  else
    payload.trigger = strcat(c.URL,"/eap/catalogs/", string(userCatalog), "/triggers/",triggerID);
  end

  payload.formatting.type = "DataFormat";
  payload.formatting.columnHeader = true;
  payload.formatting.dateFormat = "yyyymmdd";
  payload.formatting.delimiter = "|";
  payload.formatting.fileType = "unixFileType";
  payload.formatting.outputFormat = "variableOutputFormat";
  payload.pricingSourceOptions.type = "DataPricingSourceOptions";
  payload.pricingSourceOptions.prefer.mnemonic = "BGN";

else

  % Complete payload structure was input
  payload = universeID;
  requestID = payload.identifier;
  
end

% Convert payload to json bytes
bytes = bloombergHypermedia.payloadToBytes(payload);

% Set request parameters
method = "POST";
eapPath = strcat("/eap/catalogs/", string(userCatalog), "/requests/");

% Send request data
response = bhapiEngine(c,method,eapPath,eapPath,bytes);