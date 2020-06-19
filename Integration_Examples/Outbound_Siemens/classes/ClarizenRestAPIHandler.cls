/*
Name: ClarizenRestAPIHandler
Author: Luiz Almeida (RC-BR IT PTM)
Date: 2019.11.10
Description: Callout class for Clarizen Integration. Holds all callout methods used during the process.
TestClass: ClarienRestAPI_Test
*/
public class ClarizenRestAPIHandler {
    
    private static String sessionId = null;
    private static Datetime usedAt = null;
    
    private static String getSessionId() {
        //Clarizen: Session expires after 10 minutes of inactivity. The timer resets when the session is used.
        if(sessionId == null | (usedAt != null && ((Datetime.now().getTime() - usedAt.getTime())/60000) >= 10))
            sessionId = login();
       
        usedAt = Datetime.now();
        return sessionId;
    }
    
    public static String login() {
        NamedCredential namedCredential = [SELECT Id, DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = 'ClarizenAPI' LIMIT 1];
        
        String entityId = null, status = 'Failed', error = '';
        Integer tryCount = 0;
        
        HttpRequest request;
        HttpResponse response = new HttpResponse();
        String sessionId = null;
        
        do {
            try {
            	Map<HttpRequest, HttpResponse> apiResult = requestToAPI('authentication/login', 'GET', '{"userName":"{!$Credential.UserName}","password":"{!$Credential.Password}"}');
                request = new List<HttpRequest>(apiResult.keySet())[0];
                response = apiResult.get(request);
        
            	if(response.getStatusCode() == 200) {
                    Map<String, Object> loginResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            		sessionId = 'Session ' + loginResults.get('sessionId').toString();
                    status = 'Success';
            	}
            } catch(Exception e) {
                error = e.getMessage();
            }
            tryCount++;
        } while(response.getStatusCode() != 200 && tryCount < 3);
        
        return sessionId;
    }
    
    public static String createEntity(String entityType, String jsonValue, Interface_Queue__c interfaceQueue) {
        String entityId = null, status = 'Failed', error = '';
        Integer tryCount = 0;
        
        HttpRequest request;
        HttpResponse response = new HttpResponse();
        
        do {
            try {
            	Map<HttpRequest, HttpResponse> apiResult = requestToAPI('data/objects/' + entityType, 'PUT', jsonValue);
                request = new List<HttpRequest>(apiResult.keySet())[0];
                response = apiResult.get(request);
        
            	if(response.getStatusCode() == 200) {
                    Map<String, Object> projectResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    entityId = projectResults.get('id').toString();
                    status = 'Success';
            	}
            } catch(Exception e) {
                error = e.getMessage();
            }
            tryCount++;
        } while(response.getStatusCode() != 200 && tryCount < 3);

        sendLog(interfaceQueue, request, response, entityId, status, error);
        return entityId;
    }

    @future(callout=true)
    public static void createEntities(String entitiesJson, String interfaceQueueJson) {
        Interface_Queue__c interfaceQueue = (Interface_Queue__c) JSON.deserialize(interfaceQueueJson, Interface_Queue__c.class);
        String status = 'Failed', error = '';
        Integer tryCount = 0;
        
        HttpRequest request;        
        HttpResponse response = new HttpResponse();
        
        do {
            try {
            	Map<HttpRequest, HttpResponse> apiResult = requestToAPI('bulk/execute', 'POST', '{"requests":' + entitiesJson + ', "transactional":false}');
                request = new List<HttpRequest>(apiResult.keySet())[0];
                response = apiResult.get(request);
        
            	if(response.getStatusCode() == 200) {
                    Map<String, Object> projectResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    status = 'Success';
            	}
            } catch(Exception e) {
                error = e.getMessage();
            }
            tryCount++;
        } while(response.getStatusCode() != 200 && tryCount < 3);

        insert fillLog(interfaceQueue, request, response, '', status, error);
    }
    
    public static void updateEntity(String entityId, String jsonValue) {        
        requestToAPI('data/objects' + entityId, 'POST', jsonValue);
    }
    
    public static String queryEntity(String entityType, Map<String, String> searchFields) {
        String entityId = null;
        
        String searchJson = '';
        Integer i = 0;
        for (String keyField : searchFields.keySet()) {
            i++;
            
            searchJson = searchJson + '{"leftExpression":{"fieldName":"' + keyField + '"},"operator":"In","rightExpression":{"values":["' + searchFields.get(keyField) + '"]}}';
            
            if (i < searchFields.size())
                searchJson = searchJson + ',';
        }
        
        Map<HttpRequest, HttpResponse> apiResult = requestToAPI('data/entityQuery', 'GET', '{"typeName":"' + entityType + '","fields":[],"paging":{"limit":1},"where":{"and": [' + searchJson + ']}}');
        HttpRequest request = new List<HttpRequest>(apiResult.keySet())[0];
        HttpResponse response = apiResult.get(request);
        
        if(response.getStatusCode() == 200) {
            Map<String, Object> queryResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> a = (List<Object>) queryResults.get('entities');
            
            if(a.size() == 1)
                entityId = String.valueOf(a.get(0)).split('=')[1].replace('}', '');
        }
        
        return entityId;
    }
    
    public static String createDocument(String contentDocumentId, Map<String, String> customFields, Interface_Queue__c interfaceQueue) {      
        ContentDocument cd = [Select Id,LatestPublishedVersionId From ContentDocument Where Id = :contentDocumentId LIMIT 1];
            
        ContentVersion cv = [Select Id,Title,VersionData,FileType,FileExtension,ContentSize,Send_to_Clarizen__c From ContentVersion Where ContentDocumentId =:cd.Id AND Id =:cd.LatestPublishedVersionId LIMIT 1];
        
        //Check if this file should be sent to Clarizen
        if(!cv.Send_to_Clarizen__c)
            return null;
        
        //Possible FileType: Calendar, Document, GanttWidget, Image, Link, PDF, Presentation, RoadmapWidget, Spreadsheet, Text, Word
        
        String fileType;
        
        switch on cv.FileType {
            when 'POWER_POINT', 'POWER_POINT_X' {
            	fileType = 'Presentation';
            }
            when 'WORD', 'WORD_X' {
                fileType = 'Word';
            }
            when 'EXCEL', 'EXCEL_X', 'EXCEL_M' {
                fileType = 'Spreadsheet';
            }
            when 'PNG', 'JPEG', 'JPG', 'GIF' {
                fileType = 'Image';
            }
            when else {
            	fileType = cv.FileType;
            }
        }
        
        String extraJsonContent = '';
        
        for(String fieldName : customFields.keySet())
            extraJsonContent = extraJsonContent + ',"' + fieldName + '":"' + customFields.get(fieldName) + '"';

        String body;
        
        if(cv.ContentSize <= 6000000)
        	body = '{"Name":"' + cv.Title + '.' + cv.FileExtension + '", "StorageType":"File", "FileType":"'+FileType+'", "Content":"' + EncodingUtil.base64Encode(cv.VersionData) + '" ' + extraJsonContent + '}';
        /*else
            body = '{"Name":"' + cv.Title + '.' + cv.FileExtension + '", "StorageType":"File", "FileType":"'+FileType+'", "Content":"" ' + extraJsonContent + '}';
        */
        String documentId = null, status = 'Failed', error = '';
        Integer tryCount = 0;

        HttpResponse response = new HttpResponse();
        HttpRequest request;
        do {
            try {
            	Map<HttpRequest, HttpResponse> apiResult = requestToAPI('data/objects/document', 'PUT', body);
            	request = new List<HttpRequest>(apiResult.keySet())[0];
            	response = apiResult.get(request);
        
            	if(response.getStatusCode() == 200) {
                    Map<String, Object> documentResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
               	 	documentId = documentResults.get('id').toString();
                    status = 'Success';
                    
                    /*if(cv.ContentSize >= 6000000) {
                        //Create Interface Queue copy for future method usage
                        Interface_Queue__c contentInterfaceQueue = (Interface_Queue__c) JSON.deserialize(JSON.serialize(interfaceQueue), Interface_Queue__c.class);
                    	
                        sendFileContent(documentId, cv.Id, JSON.serialize(contentInterfaceQueue));
                    }*/
            	}
            } catch(Exception e) {
                error = e.getMessage();
            }
            tryCount++;
        } while(response.getStatusCode() != 200 && tryCount < 3);
        
        sendLog(interfaceQueue, request, response, documentId, status, error);
        
        return documentId;
    }
    /*
    @future(callout=true)
    public static void sendFileContent(String documentId, String contentVersionId, String interfaceQueueJson) {
        Interface_Queue__c interfaceQueue = (Interface_Queue__c) JSON.deserialize(interfaceQueueJson, Interface_Queue__c.class);
        
		ContentVersion cv = [Select FileExtension, Title, VersionData, ContentSize From ContentVersion Where id = :contentVersionId LIMIT 1];
        
        String uploadUrl = getUploadUrl();
        
        String boundary = '__boundary__xxx';
        String fileContent = EncodingUtil.base64Encode(cv.VersionData);
        String header = '--' + boundary+'\n'
                    + 'Content-Disposition: form-data; name="file"; filename="' + cv.Title + '.' + cv.FileExtension + '"\n'
                    +'Content-Type: application/octet-stream\n\n';
        String footer = '\n--' + boundary + '--';
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(uploadUrl);
        request.setMethod('POST');
        request.setHeader('Authorization', getSessionId());
        request.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
        request.setHeader('Content-Length', String.valueOf(fileContent.length()));
        request.setBody(header + fileContent + footer);
        HttpResponse response = http.send(request);

		if(response.getStatusCode() == 200) {            
            Map<HttpRequest, HttpResponse> apiResult = requestToAPI('files/upload', 'POST', '{"documentId":"' + documentId + '", "uploadUrl":"' + uploadUrl + '", "fileInformation":{"storage":"Server","fileName":"' + cv.Title + '.' + cv.FileExtension + '","url":"' + documentId + '","subType":"","extendedInfo":""}}');
            request = new List<HttpRequest>(apiResult.keySet())[0];
            response = apiResult.get(request);
            
            insert fillLog(interfaceQueue, request, response, documentId, 'Success', '');
        }  
    }*/

    public static boolean attach(String linkUrl, String parentId, String objectType, String objectId, Interface_Queue__c interfaceQueue) {
        String entityId = null, status = 'Failed', error = '';
        Integer tryCount = 0;
        
        HttpRequest request;
        HttpResponse response = new HttpResponse();
        do {
            try {
                Map<HttpRequest, HttpResponse> apiResult = requestToAPI('data/objects/' + linkUrl, 'PUT', '{"Entity":"' + parentId + '","' + objectType + '":"' + objectId + '"}');
                request = new List<HttpRequest>(apiResult.keySet())[0];
                response = apiResult.get(request);
            
                if(response.getStatusCode() == 200) {
                        Map<String, Object> attachResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        entityId = attachResults.get('id').toString();
                        status = 'Success';
                }
            } catch(Exception e) {
                error = e.getMessage();
            }
            tryCount++;
        } while(response.getStatusCode() != 200 && tryCount < 3);
       
        sendLog(interfaceQueue, request, response, entityId, status, error);
        
        if(entityId != null)
            return true;
        
        return false;
    }
    /*
    public static void getEntitySchema(List<String> entitiesNames) {
        String jsonContent = '';
        
        Integer i = 1;
        for(String entityName : entitiesNames) {
            jsonContent = jsonContent + '"' + entityName + '"';
            
              if (i < entitiesNames.size())
                jsonContent = jsonContent + ',';
            i++;
        }
        
        Map<HttpRequest, HttpResponse> apiResult = requestToAPI('metadata/describeEntities', 'GET', '{"typeNames":['+ jsonContent + ']}');
        HttpRequest request = new List<HttpRequest>(apiResult.keySet())[0];
        HttpResponse response = apiResult.get(request);
        
        if(response.getStatusCode() == 200) {
            Map<String, Object> projectResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(projectResults);
        }
    }*/
    /*
    public static String getUploadUrl() {
        Map<HttpRequest, HttpResponse> apiResult = requestToAPI('files/getUploadUrl', 'GET', '');
        HttpRequest request = new List<HttpRequest>(apiResult.keySet())[0];
        HttpResponse response = apiResult.get(request);
        
        String uploadUrl = null;
        
        if(response.getStatusCode() == 200) {
            Map<String, Object> projectResults = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            uploadUrl = projectResults.get('uploadUrl').toString();
            uploadUrl = uploadUrl.replace('https://api2.clarizen.com/v2.0/services', 'callout:ClarizenAPI');
        }
        
        return uploadUrl;
    }*/
    
    private static Map<HttpRequest, HttpResponse> requestToAPI(String endpoint, String method, String body) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(120000);
        request.setEndpoint('callout:ClarizenAPI/' + endpoint);
        request.setMethod(method);
        if(!endpoint.equals('files/getUploadUrl'))
        	request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('Accept', 'application/json');
        if(!endpoint.equals('authentication/login'))
        	request.setHeader('Authorization', getSessionId());
        if(!endpoint.equals('files/getUploadUrl'))
        	request.setBody(body);
        
        Map<HttpRequest, HttpResponse> result = new Map<HttpRequest, HttpResponse>();
        result.put(request, http.send(request));
        
        return result;
    }
    
    public static void sendLog(Interface_Queue__c interfaceQueue, HttpRequest request, HttpResponse response, String returnedKey, String status, String error) {
		Interface_Queue__c filledLog = fillLog(interfaceQueue, request, response, returnedKey, status, error);      
        ClarizenRestAPI.interfaceQueues.add(filledLog);
    }
    
    public static Interface_Queue__c fillLog(Interface_Queue__c interfaceQueue, HttpRequest request, HttpResponse response, String returnedKey, String status, String error) {
        if(request.getBody() == null)
            interfaceQueue.Sent_Body__c = 'Not sent.';
        else if(request.getBody().length() <= 131072)
        	interfaceQueue.Sent_Body__c = request.getBody().unescapeHtml4();
        else
            interfaceQueue.Sent_Body__c = 'Body too big.';
        
        interfaceQueue.Method__c = request.getMethod();
        interfaceQueue.Requested_URL__c = request.getEndpoint();
        
        if(response.getBody() == null)
            interfaceQueue.Body__c = 'Not sent.';
        else if(response.getBody().length() <= 131072)
        	interfaceQueue.Body__c = response.getBody().unescapeHtml4();
        else
            interfaceQueue.Sent_Body__c = 'Body too big.';
        
        interfaceQueue.Key__c = returnedKey;
        interfaceQueue.Status__c = status;
        
        return interfaceQueue;
    }
}