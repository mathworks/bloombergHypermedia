function [triggerID,response] = createTrigger(c,userCatalog,payload)
%CREATETRIGGER Bloomberg Hypermedia trigger for data requests.
%   [TRIGGERID,RESPONSE] = CREATETRIGGER(C,USERCATALOG,PAYLOAD) creates
%   a Bloomberg Hypermerdia trigger.   C is the bloombergHypermerdia
%   object, USERCATALOG is the user's catalog id and PAYLOAD is the
%   structure that defines the trigger.
%
%   For example,
%
%   payload.type = "PricingSnapshotTrigger";
%   payload.identifier = "dailySnap5PM";
%   payload.title = "Daily 5 PM snapshot";
%   payload.description = "Daily job for 5 PM snapshot";
%   payload.snapshotTime = "17:00:00";
%   payload.snapshotTimeZoneName = "America/New_York";
%   payload.snapshotDate = "2022-06-24";
%   payload.frequency = "daily";
%
%   [triggerID,response] = createTrigger(b,"myid",payload)
%
%   returns
%
%   triggerID = 
% 
%     "dailySnap5PM"
% 
%   response = 
% 
%   ResponseMessage with properties:
% 
%     StatusLine: 'HTTP/1.1 201 CREATED'
%     StatusCode: Created
%         Header: [1×14 matlab.net.http.HeaderField]
%           Body: [1×1 matlab.net.http.MessageBody]
%      Completed: 0
%
%   See also bloombergHypermedia, createFieldList, createRequest, createUniverse, getTriggers.

%   Copyright 2022 The MathWorks, Inc. 

% Create the unique universe request identifier
triggerID = payload.identifier;

% Convert the payload structure to json bytes
bytes = bloombergHypermedia.payloadToBytes(payload);

% Set the request parameters
method = "POST";
eapPath = strcat("/eap/catalogs/", string(userCatalog), "/triggers/");

% Send request data
response = bhapiEngine(c,method,eapPath,eapPath,bytes);