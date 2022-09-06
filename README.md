# Getting Started with Bloomberg Hypermedia in MATLAB&reg;

## Description

This interface allows users to access the Bloomberg Hypermedia directly from MATLAB.  Quantative analysts and asset managers can use the available historical and current market data to make investment decisions related to risk and return optimization.

## System Requirements

- MATLAB R2022a or later
- Bloomberg Hypermedia credentials supplied by Bloomberg: https://console.bloomberg.com/
- JWT authentication is used by the API to validate requests.  

The files

- jjwt-0.9.1.jar
- gson-2.8.5.jar
- jjtw-api-0.11.2.jar
- jjtw-gson-0.11.2.jar
- jjtw-impl-0.11.2.jar

must be included on the MATLAB Java classpath.

## Features

Users can retrieve Bloomberg Hypermedia data directly from MATLAB.

Four items steps must be taken to access data:

1. Create a universe of securites.
2. Create a field list of data items.
3. Create a trigger to schedule a data request.
4. Create a data request.

Once the data request has been scheduled and completed, the user can download the resulting data set directly into MATLAB.  Note that in this script, the user must replace "myid" with their user id.
A Bloomberg Hypermedia connection is required so that is created first using the user's credentials.
```MATLAB
credentialsString = '{"client_id":"89beaeab724bbdf5e186b733c58af2","client_secret":"77050429aee81eb31793fb10fa4301c54911db545de8b2990252ffe2b56b11","name":"BloombergHAIDevelopment","scopes":["eap","beapData","reportingapi"],"expiration_date":1699198358934,"created_date":1651764758934}'
b = bloombergHypermedia(credentialsString)
```
## Step 1.   Create a universe of securities

### Create a payload structure that has the security list.
```MATLAB
universePayload.type = "Universe";
universePayload.identifier = "u" + bloombergHypermedia.generateResourcePostfix;
universePayload.title = "Test Universe " + string(datetime);
universePayload.description = "Test historical data universe - ZYX, WVU";
universePayload.contains{1}.type = "Identifier";
universePayload.contains{1}.identifierType = "TICKER";
universePayload.contains{1}.identifierValue = "ZYX US Equity";
universePayload.contains{2}.type = "Identifier";
universePayload.contains{2}.identifierType = "TICKER";
universePayload.contains{2}.identifierValue = "WVU US Equity"
```
### Next, the universe is created.
```MATLAB
[universeID, response] = createUniverse(b, "myid", universePayload)
```

## Step 2.   Create a field list

### Create a payload structure with the data fields to be requested.
```MATLAB
fieldListPayload.type = "DataFieldList";
fieldListPayload.identifier = "fieldList" + bloombergHypermedia.generateResourcePostfix;
fieldListPayload.title = "Test Data Field List";
fieldListPayload.description = "Test data field list";
fieldListPayload.contains{1}.id = "https://api.bloomberg.com/eap/catalogs/bbg/fields/pxAsk/";
fieldListPayload.contains{2}.id = "https://api.bloomberg.com/eap/catalogs/bbg/fields/pxLast/";
fieldListPayload.contains{3}.id = "https://api.bloomberg.com/eap/catalogs/bbg/fields/idBbGlobal/"
```
### Next, the field list is created.
```MATLAB
[fieldListID, response] = createFieldList(b,"myid",fieldListPayload)
```

## Step 3.   Create a trigger for scheduling a request

### Create a payload structure with the parameters to schedule a request, called a trigger.
```MATLAB
triggerPayload.type = "PricingSnapshotTrigger";
triggerPayload.identifier = "dailySnap5PM";
triggerPayload.title = "Daily 5 PM snapshot";
triggerPayload.description = "Daily job for 5 PM snapshot";
triggerPayload.snapshotTime = "17:00:00";
triggerPayload.snapshotTimeZoneName = "America/New_York";
triggerPayload.snapshotDate = "2022-06-24";
triggerPayload.frequency = "daily";
```
### Next, the trigger is created.
```MATLAB
[triggerID,response] = createTrigger(b,"myid",triggerPayload)
```
## Step 4. Use the universeID, fieldListID and triggerID to create a data request

### Create a payload structure to define the data request using an existing universe, field list and trigger. For this example, the prebuilt oneshot request trigger is used.
```MATLAB
requestPayload.type = "DataRequest";
requestPayload.identifier = "r" + bloombergHypermedia.generateResourcePostfix;
requestPayload.title = "My Request";
requestPayload.description = "Test request with universe, fieldList and trigger";
requestPayload.universe = strcat(b.URL,"/eap/catalogs/myid/universes/",universeID);
requestPayload.fieldList = strcat(b.URL,"/eap/catalogs/myid/fieldLists/",fieldListID);
requestPayload.trigger = strcat(b.URL,"/eap/catalogs/bbg/triggers/oneshot");
requestPayload.formatting.type = "DataFormat";
requestPayload.formatting.columnHeader = true;
requestPayload.formatting.dateFormat = "yyyymmdd";
requestPayload.formatting.delimiter = "|";
requestPayload.formatting.fileType = "unixFileType";
requestPayload.formatting.outputFormat = "variableOutputFormat";
requestPayload.pricingSourceOptions.type = "DataPricingSourceOptions";
requestPayload.pricingSourceOptions.prefer.mnemonic = "BGN";
```
### Next, the request is created.
```MATLAB
[requestID,response] = createRequest(b,"myid",requestPayload)
```
Once the request has been created and run on the Bloomberg server, the data returned by the request can be retrieved from MATLAB.    The date the request was created is also needed to retrieve the data.
```MATLAB
requestInfo = getRequests(b,"myid",requestID)
requestDate = requestInfo.issued{1}(1,[1:4,6:7,9:10])
[data,response] = getData(b,"myid",requestID,requestDate)
```
## Additional functions

The interface includes functions to retrieve universe, field list, trigger and request information.   The functions are 
```MATLAB
getUniverses
getFieldLists
getTriggers
getRequests
```
   Addtionally, the function getFields will return the entire available Bloomberg field list or information about a given field.   Note that retrieving the entire available field list takes a siginificant amount of time.

## License

The license is available in the LICENSE.TXT file in this GitHub repository.

All use of data provided or made available by Bloomberg or its affiliates is governed by the terms and conditions set forth in the applicable agreements between Bloomberg or its affiliates and such Customer and shall not purport to grant any Customer any rights not granted by Bloomberg or its affiliates with respect to any data or services provided or made available by Bloomberg or its affiliates.

Community Support

MATLAB Central

Copyright 2022 The MathWorks, Inc.