function [universeID,response] = createUniverse(c,userCatalog,payload)
%CREATEUNIVERSE Bloomberg Hypermedia universe for data requests.
%   [UNIVERSEID,RESPONSE] = CREATEUNIVERSE(C,USERCATALOG,PAYLOAD) creates
%   a Bloomberg Hypermerdia universe.   C is the bloombergHypermerdia
%   object, USERCATALOG is the user's catalog id and PAYLOAD is the
%   structure that defines the universe.
%
%   For example,
%
%   payload.type = "Universe";
%   payload.identifier = "u" + bloombergHypermedia.generateResourcePostfix;
%   payload.title = "Test Universe";
%   payload.description = "Test historical data universe";
%   payload.contains{1}.type = "Identifier";
%   payload.contains{1}.identifierType = "TICKER";
%   payload.contains{1}.identifierValue = "IBM US Equity";
%
%   [universeID,response] = createUniverse(b,"myid",payload)
%
%   returns
%
%   universeID = 
% 
%     "u2022052413354920f366"
% 
%   response = 
% 
%   ResponseMessage with properties:
% 
%     StatusLine: 'HTTP/1.1 201 CREATED'
%     StatusCode: Created
%         Header: [1×14 matlab.net.http.HeaderField]
%           Body: [1×1 matlab.net.http.MessageBody]
%      Completed: 1
%
%   See also bloombergHypermedia, createFieldList, createRequest, getUniverses.

%   Copyright 2022 The MathWorks, Inc. 

% Create the unique universe request identifier
universeID = payload.identifier;

% Convert the payload structure to json bytes
bytes = bloombergHypermedia.payloadToBytes(payload);

% Set the request parameters
method = "POST";
eapPath = strcat("/eap/catalogs/", string(userCatalog), "/universes/");

% Send request data
response = bhapiEngine(c,method,eapPath,eapPath,bytes);