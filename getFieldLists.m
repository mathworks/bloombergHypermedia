function [fieldLists,response] = getFieldLists(c,userCatalog,fieldListID)
%GETFIELDLISTS Retrieve field list information.
%   [FIELDLISTS,RESPONSE] = GETFIELDLISTS(C,USERCATALOG,FIELDLISTID)
%   returns information about all available field lists or a given field
%   list.  C is the bloombergHypermedia object, USERCATALOG is the user's 
%   catalog id and FIELDLISTID is the field list identifier.  If
%   FIELDLISTID is not specified, all available field list information is
%   returned.
%
%   For example, 
%
%   fieldLists = getFieldLists(b,"myid")
%
%   returns
%
%    fieldLists =
% 
%   5x7 table
% 
%                    x_id                        x_type                description                      identifier                            issued                            modified                         title          
%     __________________________________    _________________    ________________________    _________________________________    _______________________________    _______________________________    ________________________
% 
%     {'fieldList20220524132236008066/'}    {'DataFieldList'}    {'Test data field list'}    {'fieldList20220524132236008066'}    {'2022-05-24T17:22:43.382760Z'}    {'2022-05-24T17:22:43.382760Z'}    {'Test Data Field List'}
%     {'fieldList202205241313321728d3/'}    {'DataFieldList'}    {'Test data field list'}    {'fieldList202205241313321728d3'}    {'2022-05-24T17:14:12.975472Z'}    {'2022-05-24T17:14:12.975472Z'}    {'Test Data Field List'}
%     {'fieldList20220126170728fd5f42/'}    {'DataFieldList'}    {'Test data field list'}    {'fieldList20220126170728fd5f42'}    {'2022-01-26T22:07:29.867704Z'}    {'2022-01-26T22:07:29.867704Z'}    {'Test Data Field List'}
%     {'fieldList202201261705200f7cb3/'}    {'DataFieldList'}    {'Test data field list'}    {'fieldList202201261705200f7cb3'}    {'2022-01-26T22:05:21.910409Z'}    {'2022-01-26T22:05:21.910409Z'}    {'Test Data Field List'}
%     {'fieldList202201261703442bf16a/'}    {'DataFieldList'}    {'Test data field list'}    {'fieldList202201261703442bf16a'}    {'2022-01-26T22:03:45.166328Z'}    {'2022-01-26T22:03:45.166328Z'}    {'Test Data Field List'}
%
% response = 
% 
%   ResponseMessage with properties:
% 
%     StatusLine: 'HTTP/1.1 303 SEE OTHER'
%     StatusCode: SeeOther
%         Header: [1x14 matlab.net.http.HeaderField]
%           Body: [1x1 matlab.net.http.MessageBody]
%      Completed: 1
%
% 
%   fieldList = getFieldLists(b,"myid","fieldList20220524132236008066")
%
%   returns
%
%   fieldList =
% 
%   3x8 table
% 
%                                   x_id                                    cleanName       dlCommercialModelCategory      identifier      loadingSpeed        mnemonic                              title                              type     
%     ________________________________________________________________    ______________    _________________________    ______________    ____________    ________________    _________________________________________________    _____________
% 
%     {'https://api.bloomberg.com/eap/catalogs/bbg/fields/pxAsk'     }    {'pxAsk'     }     {'Pricing - Intraday'}      {'pxAsk'     }      {'Hare'}      {'PX_ASK'      }    {'Ask Price'                                    }    {'Price'    }
%     {'https://api.bloomberg.com/eap/catalogs/bbg/fields/pxLast'    }    {'pxLast'    }     {'Pricing - Intraday'}      {'pxLast'    }      {'Hare'}      {'PX_LAST'     }    {'Last Price'                                   }    {'Price'    }
%     {'https://api.bloomberg.com/eap/catalogs/bbg/fields/idBbGlobal'}    {'idBbGlobal'}     {'Open Source'       }      {'idBbGlobal'}      {'Hare'}      {'ID_BB_GLOBAL'}    {'Financial Instrument Global Identifier (FIGI)'}    {'Character'}
%
%   See also createFieldLists.

%   Copyright 2022 The MathWorks, Inc. 

% Set http method
method = "GET";

% Create universeID string
if ~exist("fieldListID","var")
    fieldListID = "";
else
    fieldListID = strcat(fieldListID,"/");
end

% Create EAP path for request
eapPath = strcat("/eap/catalogs/", string(userCatalog), "/fieldLists/",fieldListID);

% Send request data
response = bhapiEngine(c,method,eapPath,eapPath);

switch string(response.StatusCode)
  case "303"
    % Parse pages in response
    fieldLists = parsePagesResponse(c,method,eapPath,response);
  case "200"
    % Parse response with only a single page
    fieldLists = struct2table(jsondecode(native2unicode(response.Body.Data)'),"AsArray",true);
  otherwise
    % All other response types
    fieldLists = response;
end