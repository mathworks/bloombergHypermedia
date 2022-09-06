function [fieldListID,response] = createFieldList(c,userCatalog,payload)
%CREATEFIELDLIST Bloomberg Hypermedia field list for data requests.
%   [FIELDLISTID,RESPONSE] = CREATEFIELDLIST(C,USERCATALOG,PAYLOAD) creates
%   a Bloomberg Hypermerdia field list.   C is the bloombergHypermerdia
%   object, USERCATALOG is the user's catalog id and PAYLOAD is the
%   structure that defines the field list. 
%
%   For example,
%
%   payload.type = "DataFieldList";
%   payload.identifier = "fieldList" + bloombergHypermedia.generateResourcePostfix;;
%   payload.title = "Test Data Field List";
%   payload.description = "Test data field list";
%   payload.contains{1}.id = "https://api.bloomberg.com/eap/catalogs/bbg/fields/pxAsk/";
%   payload.contains{2}.id = "https://api.bloomberg.com/eap/catalogs/bbg/fields/pxLast/";
%   payload.contains{3}.id = "https://api.bloomberg.com/eap/catalogs/bbg/fields/idBbGlobal/";
%
%   [fieldListID,response] = createFieldList(b,"myid",payload)
%
%   returns
%
%   fieldListID = 
% 
%     "f20220524131412b9a77b"
% 
% 
%   response = 
% 
%      ResponseMessage with properties:
% 
%        StatusLine: 'HTTP/1.1 201 CREATED'
%        StatusCode: Created
%           Header: [1×14 matlab.net.http.HeaderField]
%             Body: [1×1 matlab.net.http.MessageBody]
%        Completed: 1
%
%   See also bloombergHypermedia, createUniverse, createRequest, getFieldLists.

%   Copyright 2022 The MathWorks, Inc. 

% Create unique field list identifier for request
fieldListID = payload.identifier;

% Convert the payload structure to json bytes
bytes = bloombergHypermedia.payloadToBytes(payload);

% Set the request parameters
method = "POST";
eapPath = strcat("/eap/catalogs/", string(userCatalog), "/fieldLists/");

% Send request data
response = bhapiEngine(c,method,eapPath,eapPath,bytes);