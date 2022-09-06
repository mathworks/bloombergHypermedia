function [data,response] = getData(c,usercatalog,requestID,requestYYYYMMDD)
%GETDATA Retrieve Bloomberg Hypermedia request data.
%   [DATA,RESPONSE] = GETDATA(C,USERCATALOG,REQUESTID,REQUESTYYYYMMDD)
%   returns the data for a given request.  C is the bloombergHypermedia 
%   object, USERCATALOG is the user's catalog id, REQUESTID is the data 
%   request id and REQUESTYYYYMMDD is the request date in YYYYMMDD format.
%
%   For example,
%
%   [data,response] = getData(b,"myid","r20220523195612215b68","20220523")
%
%   See also bloombergHypermeda, createRequest.

%   Copyright 2022 The MathWorks, Inc. 

% Set http method
method = "GET";

% Create EAP path for request
eapPath = strcat("/eap/catalogs/",usercatalog,"/datasets/",requestID,"/snapshots/",requestYYYYMMDD,"/distributions/",requestID,".bbg");

% Send request data and get response
response = bhapiEngine(c,method,eapPath,eapPath);

try

  % Parse data
  textData = textscan(response.Body.Data,'%s','Delimiter','\n');
  stringData = string(textData{:});

  % Get request type
  requestTypeInd = contains(stringData,"PROGRAMNAME");
  
  % Get data defined by START-OF-DATA and END-OF-DATA entries
  dataInd = find(stringData == "START-OF-DATA" | stringData == "END-OF-DATA");
  cellData = stringData(dataInd(1)+1:dataInd(2)-1);

  switch stringData(requestTypeInd)
    
      case "PROGRAMNAME=getdata"

        % Get delimiter type
        delimTypeInd = contains(stringData,"DELIMITER");
        delimString = stringData(delimTypeInd);
        delimiter = extractAfter(delimString,"=");

        % Get number of records
        numRecords = height(cellData);
        fields = strsplit(cellData{1},delimiter);
        fieldData = cell(numRecords-1,length(fields));

        % First record is field list
        for i = 2:numRecords
          recordData = strsplit(cellData{i},delimiter);
          switch delimiter
            case "|"
              fieldData(i-1,:) = recordData;
            case ","
              fieldData(i-1,:) = recordData(1:end-1);

          end
        end
        data = array2table(string(fieldData(:,1:end-1)),"VariableNames",fields(1:end-1));

      case "PROGRAMNAME=gethistory"

        % Get fields defined by START-OF-FIELDS and END-OF-FIELDS entries
        fieldsDataInd = find(stringData == "START-OF-FIELDS" | stringData == "END-OF-FIELDS");
        fieldData = stringData(fieldsDataInd(1)+1:fieldsDataInd(2)-1);

        % Preallocate output, historical data has 5 columns of data for
        % each historical request plus the number of fields requested
        numRecords = height(cellData);
        tmpData = cell(numRecords,length(fieldData)+5);
        for i = 1:numRecords
          recordData = strsplit(cellData{i},"|");
          tmpData(i,:) = recordData(1:end-1);
        end

        timestamps = str2double(tmpData(:,5));
        data = table2timetable(array2table(string(tmpData(:,[1:4,6:end])),...
            'VariableNames',["SECURITIES";"ERROR CODE";"NUM FLDS";"MARKET";fieldData]),...
            'RowTimes',datetime(timestamps,"ConvertFrom","yyyymmdd"));

      case "PROGRAMNAME=getactions"

        % Get number of records, data starts at third record
        numRecords = height(cellData);
        actionData = cell(1,numRecords-2);

        % Parse action data
        for i = 3:numRecords
          recordData = strsplit(cellData{i},"|");
          actionData{i-2} = array2table(string(recordData(1:end-1)));
        end

        % Convert to table
        data = cell2table(actionData);

      otherwise

        % If PROGRAMNAME is not recognized, return response text
        data = stringData;
 
  end

catch
  
  % Return response text if it has been created, otherwise return
  % ResponseMessage
  if exist("stringData","var")
    data = stringData;
  else
    data = response;
  end
end

