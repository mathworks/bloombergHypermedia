function [universeList,response] = getUniverses(c,userCatalog,universeID)
%GETUNIVERSES Retrieve universe information.
%   [UNIVERSES,RESPONSE] = GETUNIVERSES(C,USERCATALOG,UNIVERSEID)
%   returns information about all available universes or a given universe.
%   C is the bloombergHypermedia object, USERCATALOG is the user's 
%   catalog id and UNIVERSEID is the universe identifier.   If UNIVERSEID
%   is not specified, all available universe information is returned.
%
%   For example,
%
%   [universeID,response] = getUniverses(b,"myid")
%
%   returns
%
%   universeID =
% 
%   3x7 table
% 
%                x_id                  x_type                       description                            identifier                        issued                            modified                                title                 
%     __________________________    ____________    ____________________________________________    _________________________    _______________________________    _______________________________    ______________________________________
% 
%     {'u20220624164457b749fe/'}    {'Universe'}    {'Test historical data universe'           }    {'u20220624164457b749fe'}    {'2022-06-24T20:45:04.884335Z'}    {'2022-06-24T20:45:04.884335Z'}    {'Test Universe'                     }
%     {'u20220624164333cf0191/'}    {'Universe'}    {'Test historical data universe'           }    {'u20220624164333cf0191'}    {'2022-06-24T20:43:41.265126Z'}    {'2022-06-24T20:43:41.265126Z'}    {'Test Universe'                     }
%     {'u202206241641101e6147/'}    {'Universe'}    {'Test historical data universe, SHOP, IBM'}    {'u202206241641101e6147'}    {'2022-06-24T20:41:15.059055Z'}    {'2022-06-24T20:41:15.059055Z'}    {'Test Universe 24-Jun-2022 16:40:41'}
% 
%   response = 
% 
%   ResponseMessage with properties:
% 
%     StatusLine: 'HTTP/1.1 303 SEE OTHER'
%     StatusCode: SeeOther
%         Header: [1x14 matlab.net.http.HeaderField]
%           Body: [1x1 matlab.net.http.MessageBody]
%      Completed: 0
%
%   universeID = getUniverses(b,"myid","u2022052413354920f366")
%
%   returns
%
%   universeID =
% 
%   1x3 table
% 
%     x_type      identifierType    identifierValue
%   __________    ______________    _______________
% 
%   Identifier        TICKER         ZYX US Equity 
%
%   See also bloombergHypermedia, createUniverse.

%   Copyright 2022 The MathWorks, Inc. 

% Set http method
method = "GET";

% Create universeID string
if ~exist('universeID','var')
    universeID = "";
else
    universeID = strcat(universeID,"/");
end

% Create EAP path for request
eapPath = strcat("/eap/catalogs/", string(userCatalog), "/universes/",universeID);

% Send request data
response = bhapiEngine(c,method,eapPath,eapPath);

switch string(response.StatusCode)
  case "303"
    % Parse pages in response
    universeList = parsePagesResponse(c,method,eapPath,response);
  case "200"
    % Parse response with only a single page
    universeList = struct2table(jsondecode(native2unicode(response.Body.Data)'),"AsArray",true);
  otherwise
    % All other response types
    universeList = response;
end