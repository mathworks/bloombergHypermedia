classdef bloombergHypermedia < handle
%BLOOMBERGHYPERMEDIA Bloomberg Hypermedia connection.
%   C = BLOOMBERGHYPERMEDIA(CREDENTIALSJSON,TIMEOUT) creates a 
%   Bloomberg Hypermedia connection object. CREDENTIALSJSON can 
%   be input as a string scalar or character vector.  TIMEOUT is the 
%   request value in milliseconds and input as a numeric value. The default 
%   value is 200 milliseconds. C is a bloombergHypermedia object.
%
%   For example,
%   
%   credentialsJson = '{"client_id":"c2ca6aa390b4b79ab15ffec6ab83c08","client_secret":"f027f167ce92b6e56dfc99d1c36d75733ca66dd73d3fcac37a4de35f39d9060","name":"BloombergHAPIDevelopment","scopes":["eap","beapData","reportingapi"],"expiration_date":1673126340450,"created_date":1625692740450}'
%   c = bloombergHypermedia(credentialsJson)
%
%   returns
%
%   c = 
%   
%     bloombergHypermedia with properties:
%   
%       TimeOut: 200.00
%
%   See also createFieldList, createUniverse, createRequest, getData, getFieldLists, getUniverses, getRequests, getTriggers.

%   Copyright 2022 The MathWorks, Inc. 

  properties
    TimeOut
  end
  
  properties (Hidden = true)
    ClientId
    ClientSecret
    ClientSecretBytes
    DebugModeValue
    MediaType
    URL   
  end
  
  properties (Access = 'private')
    Token 
  end
  
  methods (Access = 'public')
  
      function c = bloombergHypermedia(credentialsString,timeout,url,mediatype,debugmodevalue)
         
        %  Registered barchart users will have an authentication token
        if nargin < 1
          error("datafeed:bloombergHypermedia:missingCredentials","Contact Bloomberg for Hypermedia credentials for data requests.");
        end
        
        % Set request timeout value
        if nargin < 2 || isempty(timeout)
          c.TimeOut = 200;
        else
          c.TimeOut = timeout;
        end

        % Create HTTP URL object
        if nargin < 3 || isempty(url)
          HttpURI = matlab.net.URI("https://api.bloomberg.com");
        else
          HttpURI = matlab.net.URI(url);
        end
        c.URL = HttpURI.EncodedURI;
        
        % Specify HTTP media type i.e. application content to deal with
        if nargin < 4 || isempty(mediatype)
          HttpMediaType = matlab.net.http.MediaType("application/json; charset=UTF-8");
        else
          HttpMediaType = matlab.net.http.MediaType(mediatype);
        end
        c.MediaType = string(HttpMediaType.MediaInfo);

        % Set http request debug value
        if nargin < 5 || isempty(debugmodevalue)
          c.DebugModeValue = 0;
        else
          c.DebugModeValue = debugmodevalue;
        end
        
        % Timeout value for requests
        if exist("timeout","var") && ~isempty(timeout)
          c.TimeOut = timeout;
        else
          c.TimeOut = 200;
        end
        
        credentialsStruct = jsondecode(credentialsString);

        % Convert clientSecret to bytes
        clientSecretBytes = bloombergHypermedia.clientSecretToBytes(credentialsStruct);

        % Set the hidden object properties for subsequent requests
        c.ClientId = credentialsStruct.client_id;
        c.ClientSecret = credentialsStruct.client_secret;
        c.ClientSecretBytes = clientSecretBytes;

        % Generate token
        method = "GET";
        eapPath = "/eap/catalogs/";
        
        % Send request data
        response = bhapiEngine(c,method,eapPath,eapPath);

        % Check for response error
        if isprop(response.Body.Data,"errors") 
          responseError = response.Body.Data.errors;
          error(strcat(responseError.title," ",responseError.errorcode," ",responseError.status," ",responseError.detail))
        end

      end
      

      function response = bhapiEngine(c,httpMethod, eapPath, nextEapPath, jsonPayloadBytes)
      % BHAPIENGINE Core request function used by all methods.

        % Generate a token
        t = bloombergHypermedia.javaJwtTokenGenerator(c.ClientId, c.ClientSecretBytes, c.URL, httpMethod, eapPath);

        % Create components for request
        HttpURI = matlab.net.URI(strcat(c.URL,nextEapPath));
        HttpHeader = matlab.net.http.HeaderField("JWT",t,"alg","HS256","api-version","2","Content-Type",c.MediaType);
        RequestMethod = matlab.net.http.RequestMethod(httpMethod);

        % Create the request message
        switch lower(httpMethod)

          case 'get'
            
            Request = matlab.net.http.RequestMessage(RequestMethod,HttpHeader);
            
          case 'post'
            
            HttpBody = matlab.net.http.MessageBody();
            HttpBody.Payload = jsonPayloadBytes;
            Request = matlab.net.http.RequestMessage(RequestMethod,HttpHeader,HttpBody);

        end

        % Set options
        options = matlab.net.http.HTTPOptions('ConnectTimeout',c.TimeOut,'Debug',c.DebugModeValue);

        % Send Request
        response = send(Request,HttpURI,options);

      end

      function responseTable = parsePagesResponse(c,method,eapPath,response)
      %PARSEPAGESRESPONSE Parse responses with multiple pages.

          % Get response code
          responseDataStruct = jsondecode(native2unicode(response.Body.Data)');
          statusCode = responseDataStruct.statusCode;

          % Loop through pages of universes response
          if (statusCode == 303)

            % Get the location of the next pages in the response
            headerValues = string({response.Header.Name}');
            locationIndex = strcmpi(headerValues,"location");
            nextEapPath = response.Header(locationIndex).Value;
            pagedResponse = bhapiEngine(c,method,eapPath,nextEapPath);
 
            % Get number of pages in complete response
            headerValues = string({pagedResponse.Header.Name}');
            linkIndex = strcmpi(headerValues, "link");

            % Link with rel=next has path to next page
            pageLinks = string({pagedResponse.Header(linkIndex).Value}');
            lastPageIndex = contains(pageLinks,"rel=last","IgnoreCase",true);
            lastPageLink = pageLinks(lastPageIndex);
            numResponsePages = double(extractAfter(extractBefore(lastPageLink,";"),"page="));
            responseListTables = cell(numResponsePages,1);
            responseData = jsondecode(native2unicode(pagedResponse.Body.Data'));
            responseListTables{1} = struct2table(responseData.contains);
  

            % Process all pages in response
            for p = 2:numResponsePages
      
              % Get pages info found in Header
              headerValues = string({pagedResponse.Header.Name}');
              linkIndex = strcmpi(headerValues, "link");

              % Link with rel=next has path to next page
              pageLinks = string({pagedResponse.Header(linkIndex).Value}');
              nextPageIndex = contains(pageLinks,"rel=next","IgnoreCase",true);
              if any(nextPageIndex) 
      
                  nextPageLink = pageLinks(nextPageIndex);
                  nextEapPath = extractAfter(extractBefore(nextPageLink,";"),c.URL);
                  pagedResponse = bhapiEngine(c,method,eapPath,nextEapPath);
                  responseData = jsondecode(native2unicode(pagedResponse.Body.Data'));
        
                  % Convert field list structures into tables, accounted for single
                  % row responses
                  try
                    responseListTables{p} = struct2table(responseData.contains);
                  catch
                    responseListTables{p} = struct2table(responseData.contains,"AsArray",true);
                  end
 
              end

            end
  
          end

          % Convert field list data into table
          responseTable = vertcat(responseListTables{:});

      end
  end
  
  methods (Static)

      function clientSecretBytes = clientSecretToBytes(credentialsStruct,expiryFlag)
      %CLIENTSECRETTOBYTES Convert client secret to corresponding bytes.

        clientSecret = credentialsStruct.client_secret;
        clientSecretLength = length(clientSecret);
        clientSecretBytes = uint8(zeros(clientSecretLength/2,1));
        j = 1;
        for i = 1:2:clientSecretLength
          clientSecretBytes(j) = hex2dec(clientSecret(i:i+1));
          j = j + 1;
        end
        expiresAt = datetime(credentialsStruct.expiration_date/1000,"ConvertFrom","posixtime");
        dys = days(expiresAt - datetime);
        
        if exist("expiryFlag","var") && expiryFlag
          if dys < 0
            error("credentials expired")
          else
            fprintf("credentials expire in %f days\n",dys)
          end
        end

      end


      function t = javaJwtTokenGenerator(clientId, clientSecretBytes, url, method, eapPath)
      %JAVAJWTTOKENGENERATOR Create JSON web token.

        import io.jsonwebtoken.*;
        import io.jsonwebtoken.SignatureAlgorithm.*;

        HttpURI = java.net.URL(url);

        JWT_METHOD = "method";
        JWT_PATH = "path";
        JWT_HOST = "host";
        JWT_CLIENT_ID = "client_id";
        JWT_REGION = "region";

        currentTime = datetime;
        currentTime.TimeZone = datetime.SystemTimeZone;
        starttime = int32(posixtime(currentTime)-180);
        exptime = int32(posixtime(currentTime)+180+25);
        uuid = matlab.lang.internal.uuid;

        claims = java.util.HashMap;
        claims.put(Claims.ISSUED_AT, starttime);
        claims.put(Claims.NOT_BEFORE, starttime);
        claims.put(Claims.EXPIRATION, exptime);
        claims.put(Claims.ISSUER, clientId);
        claims.put(Claims.ID, uuid);
        claims.put(JWT_METHOD, method);
        claims.put(JWT_PATH, eapPath);
        claims.put(JWT_HOST, HttpURI.getHost);
        claims.put(JWT_CLIENT_ID, clientId);
        claims.put(JWT_REGION, "default");

        token = Jwts.builder().setClaims(claims);
        t = token.signWith(io.jsonwebtoken.SignatureAlgorithm.HS256, clientSecretBytes).compact();

      end

      function id_postfix = generateResourcePostfix
      %GENERATERESOURCEPOSTFIX Generate unique postfix to use as a part of resource identifier.

        uuid = matlab.lang.internal.uuid;
        currentTime = datetime;
        currentTime.Format = "yyyyMMddHHmmss";

        id_postfix = string(currentTime) + extractBetween(uuid,1,6);
      end

      function bytes = payloadToBytes(payload)
      %PAYLOADTOBYTES Convert payload structure to json bytes.

        jsonPayload = jsonencode(payload);
jsonPayload = replace(jsonPayload,"type","@type");
jsonPayload = replace(jsonPayload,"""id""","""@id""");
bytes = unicode2native(jsonPayload);

      end

  end

end