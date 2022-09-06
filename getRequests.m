function [requestList,response] = getRequests(c,userCatalog,requestID)
%GETREQUESTS Retrieve request information.
%   [REQUESTLIST,RESPONSE] = GETREQUESTS(C,USERCATALOG,REQUESTID)
%   returns information about all available requests or a given universe.
%   C is the bloombergHypermedia object, USERCATALOG is the user's 
%   catalog id and REQUESTID is the request identifier. If REQUESTID is not
%   specified, all available request information is returned.
%
%   For example,
%
%   [requestList,response] = getRequests(b,"myid")
%
%   requestList =
% 
%   20x7 table
% 
%                x_id                       x_type                             description                            identifier                        issued                            modified                              title               
%     __________________________    _______________________    ____________________________________________    _________________________    _______________________________    _______________________________    __________________________________
% 
%     {'r202206241847412b247f/'}    {'HistoryRequest'     }    {'My favorite history request'             }    {'r202206241847412b247f'}    {'2022-06-24T22:47:41.893774Z'}    {'2022-06-24T22:47:41.893774Z'}    {'My History Request'            }
%     {'r2022062418474059e59d/'}    {'DataRequest'        }    {'Test request with universe and fieldList'}    {'r2022062418474059e59d'}    {'2022-06-24T22:47:40.920272Z'}    {'2022-06-24T22:47:40.920272Z'}    {'My Request24-Jun-2022 18:47:40'}
%     {'r20220607080616968d38/'}    {'BvalSnapshotRequest'}    {'Tier 1 BVAL Snapshot Request'            }    {'r20220607080616968d38'}    {'2022-06-07T12:06:21.678095Z'}    {'2022-06-07T12:06:21.678095Z'}    {'Sample BVAL Snapshot Request'  }
% 
% 
% response = 
% 
%   ResponseMessage with properties:
% 
%     StatusLine: 'HTTP/1.1 303 SEE OTHER'
%     StatusCode: SeeOther
%         Header: [1x14 matlab.net.http.HeaderField]
%           Body: [1x1 matlab.net.http.MessageBody]
%      Completed: 0
%
%   requestList = getRequests(b,"myid","r202202011239375f2c43")
%
%   returns
%
%   requestList =
%
%   1x15 table
% 
%   x_context        x_id             x_type                                             dataset                                                  description                                                       fieldList                                              formatting           identifier                        issued                            modified                pricingSourceOptions    runtimeOptions            title                                         trigger                                                                    universe                                    
%   __________    __________    __________________    ______________________________________________________________________________    _______________________________    ____________________________________________________________________________________________    __________    _________________________    _______________________________    _______________________________    ____________________    ______________    ______________________    ________________________________________________________________    _______________________________________________________________________________
% 
%   1x1 struct    {0x0 char}    {'HistoryRequest'}    {'https://api.bloomberg.com/eap/catalogs/myid/datasets/r202206241847412b247f/'}    {'My favorite history request'}    {'https://api.bloomberg.com/eap/catalogs/myid/fieldLists/histFieldList2022060611005354b015/'}    1x1 struct    {'r202206241847412b247f'}    {'2022-06-24T22:47:41.893774Z'}    {'2022-06-24T22:47:41.893774Z'}         1x1 struct           1x1 struct      {'My History Request'}    {'https://api.bloomberg.com/eap/catalogs/bbg/triggers/oneshot/'}    {'https://api.bloomberg.com/eap/catalogs/myid/universes/u2022060615481086fc10/'}
%
%   See also bloombergHypermedia, createRequest.

%   Copyright 2022 The MathWorks, Inc. 

% Set http method
method = "GET";

% Create universeID string
if ~exist("requestID","var")
    requestID = "";
else
    requestID = strcat(requestID,"/");
end

% Create EAP path for request
eapPath = strcat("/eap/catalogs/", string(userCatalog), "/requests/",requestID);

% Send request data
response = bhapiEngine(c,method,eapPath,eapPath);

switch string(response.StatusCode)
  case "303"
    % Parse pages in response
    requestList = parsePagesResponse(c,method,eapPath,response);
  case "200"
    % Parse response with only a single page
    requestList = struct2table(jsondecode(native2unicode(response.Body.Data)'),"AsArray",true);
  otherwise
    % All other response types
    requestList = response;
end