/*
Name: ClarizenRestAPI_SingleMock
Author: Luiz Almeida (RC-BR IT PTM)
Date: 2019.11.10
Description: Mock used for ClarizenRestAPI testing. It overrides callouts made to Clarizen API.
TestClass: ClarienRestAPI_Test
*/
public class ClarizenRestAPI_SingleMock {
	protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Map<String, String> responseHeaders;
    
    public ClarizenRestAPI_SingleMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
        this.responseHeaders = responseHeaders;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(code);
        resp.setStatus(status);
        resp.setBody(bodyAsString);
        
        if (responseHeaders != null) {
            for (String key : responseHeaders.keySet()) {
                resp.setHeader(key, responseHeaders.get(key));
            }
        }
        return resp;
    }
}