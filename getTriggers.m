function [triggersList,response] = getTriggers(c,userCatalog,triggerID)
%GETTRIGGERS Retrieve request information.
%   [TRIGGERSLIST,RESPONSE] = GETTRIGGERS(C,USERCATALOG,TRIGGERID)
%   returns information about all available requests or a given universe.
%   C is the bloombergHypermedia object, USERCATALOG is the user's 
%   catalog id and TRIGGERID is the trigger identifier.  If TRIGGERID is
%   not specified, all trigger information is returned.
%
%   For example,
%
%   [triggersList,response] = getTriggers(b,"bbg")
%
%   returns
%
%   triggersList =
% 
%   12x7 table
% 
%         x_id                x_type                                                                                                        description                                                                                               identifier                 issued                            modified                          title          
%     ____________    _______________________    _________________________________________________________________________________________________________________________________________________________________________________________________    ___________    _______________________________    _______________________________    _________________________
% 
%     {'lo12pm/' }    {'BvalSnapshotTrigger'}    {'Schedule a request for a BVAL cash security valuation snapshot at 12:00 in London. London snapshots include European asset backed security valuations.'                                       }    {'lo12pm' }    {'2021-05-12T10:40:56.617063Z'}    {'2021-05-12T10:40:56.617063Z'}    {'London 12 PM'         }
%     {'lo3pm/'  }    {'BvalSnapshotTrigger'}    {'Schedule a request for a BVAL cash security valuation snapshot at 15:00 in London. London snapshots include European asset backed security valuations.'                                       }    {'lo3pm'  }    {'2021-05-12T10:40:56.541710Z'}    {'2021-05-12T10:40:56.541710Z'}    {'London 3 PM'          }
%     {'lo4pm/'  }    {'BvalSnapshotTrigger'}    {'Schedule a request for a BVAL cash security valuation snapshot at 16:15 in London. London snapshots include European asset backed security valuations.'                                       }    {'lo4pm'  }    {'2021-05-12T10:40:56.409099Z'}    {'2021-05-12T10:40:56.409099Z'}    {'London 4:15 PM'       }
%     {'ny3pm/'  }    {'BvalSnapshotTrigger'}    {'Schedule a request for a BVAL cash security valuation snapshot at 15:00 in New York. New York snapshots include Municipal, structured product, and European asset backed security valuations.'}    {'ny3pm'  }    {'2021-05-12T10:40:56.322681Z'}    {'2021-05-12T10:40:56.322681Z'}    {'New York 3 PM'        }
%     {'ny4pm/'  }    {'BvalSnapshotTrigger'}    {'Schedule a request for a BVAL cash security valuation snapshot at 16:00 in New York. New York snapshots include Municipal, structured product, and European asset backed security valuations.'}    {'ny4pm'  }    {'2021-05-12T10:40:56.177794Z'}    {'2021-05-12T10:40:56.177794Z'}    {'New York 4 PM'        }
%     {'sh5pm/'  }    {'BvalSnapshotTrigger'}    {'Schedule a request for a BVAL cash security valuation snapshot at 17:00 in Shanghai.'                                                                                                         }    {'sh5pm'  }    {'2021-05-12T10:40:56.065967Z'}    {'2021-05-12T10:40:56.065967Z'}    {'Shanghai 5 PM'        }
%     {'sy5pm/'  }    {'BvalSnapshotTrigger'}    {'Schedule a request for a BVAL cash security valuation snapshot at 17:00 in Sydney.'                                                                                                           }    {'sy5pm'  }    {'2021-05-12T10:40:56.001790Z'}    {'2021-05-12T10:40:56.001790Z'}    {'Sydney 5 PM'          }
%     {'to3pm/'  }    {'BvalSnapshotTrigger'}    {'Schedule a request for a BVAL cash security valuation snapshot at 15:00 in Tokyo. Tokyo snapshots include Japanese mortgage-backed security valuations.'                                      }    {'to3pm'  }    {'2021-05-12T10:40:55.867717Z'}    {'2021-05-12T10:40:55.867717Z'}    {'Tokyo 3 PM'           }
%     {'to4pm/'  }    {'BvalSnapshotTrigger'}    {'Schedule a request for a BVAL cash security valuation snapshot at 16:00 in Tokyo. Tokyo snapshots include Japanese mortgage-backed security valuations.'                                      }    {'to4pm'  }    {'2021-05-12T10:40:55.763853Z'}    {'2021-05-12T10:40:55.763853Z'}    {'Tokyo 4 PM'           }
%     {'to5pm/'  }    {'BvalSnapshotTrigger'}    {'Schedule a request for a BVAL cash security valuation snapshot at 17:00 in Tokyo. Tokyo snapshots include Japanese mortgage-backed security valuations.'                                      }    {'to5pm'  }    {'2021-05-12T10:40:55.655269Z'}    {'2021-05-12T10:40:55.655269Z'}    {'Tokyo 5 PM'           }
%     {'oneshot/'}    {'ScheduledTrigger'   }    {'Schedule a request to run once only (a oneshot request), no sooner than 15 minutes after request submission.'                                                                                 }    {'oneshot'}    {'2021-02-19T12:47:09.842828Z'}    {'2021-02-19T12:47:09.842828Z'}    {'Run Once (Oneshot)'   }
%     {'submit/' }    {'SubmitTrigger'      }    {'Process the request as soon as it's submitted. This will use ad hoc scheduling functionality.'                                                                                                }    {'submit' }    {'2019-04-29T10:52:17.127424Z'}    {'2019-04-29T10:52:17.156772Z'}    {'On Submission Trigger'}
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
%   triggersList = getTriggers(b,"bbg","lo12pm")
% 
% triggersList =
% 
%  1x12 table
% 
%    x_context        x_id               x_type                                                                                    description                                                                            frequency    identifier                issued                            modified                referencedByActiveRequests    snapshotTime    snapshotTimeZoneName         title      
%    __________    __________    _______________________    __________________________________________________________________________________________________________________________________________________________    _________    __________    _______________________________    _______________________________    __________________________    ____________    ____________________    ________________
% 
%    1x1 struct    {0x0 char}    {'BvalSnapshotTrigger'}    {'Schedule a request for a BVAL cash security valuation snapshot at 12:00 in London. London snapshots include European asset backed security valuations.'}    {'once'}     {'lo12pm'}    {'2021-05-12T10:40:56.617063Z'}    {'2021-05-12T10:40:56.617063Z'}              true                {'12:00:00'}     {'Europe/London'}      {'London 12 PM'}
% 
%
%   See also bloombergHypermedia.

%   Copyright 2022 The MathWorks, Inc. 

% Set http method
method = "GET";

% Create universeID string
if ~exist("triggerID","var")
    triggerID = "";
else
    triggerID = strcat(triggerID,"/");
end

% Create EAP path for request
eapPath = strcat("/eap/catalogs/", string(userCatalog), "/triggers/",triggerID);

% Send request data
response = bhapiEngine(c,method,eapPath,eapPath);

switch string(response.StatusCode)
  case "303"
    % Parse pages in response
    triggersList = parsePagesResponse(c,method,eapPath,response);
  case "200"
    % Parse response with only a single page
    triggersList = struct2table(jsondecode(native2unicode(response.Body.Data)'),"AsArray",true);
  otherwise
    % All other response types
    triggersList = response;
end