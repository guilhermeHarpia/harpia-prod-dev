/*
Name: ClarizenRestAPI_MultiMock
Author: Luiz Almeida (RC-BR IT PTM)
Date: 2019.11.10
Description: Mock used for ClarizenRestAPI testing. It holds the SingleMocks, used to overrides callouts made to Clarizen API.
TestClass: ClarienRestAPI_Test
*/
public class ClarizenRestAPI_MultiMock implements HttpCalloutMock {
	Map<String, ClarizenRestAPI_SingleMock> requests;

	public ClarizenRestAPI_MultiMock() {
		this.requests = new Map<String, ClarizenRestAPI_SingleMock>();
	}

	public HTTPResponse respond(HTTPRequest req) {
		ClarizenRestAPI_SingleMock mock = requests.get(req.getEndpoint());
		if (mock != null) {
			return mock.respond(req);
		} else {
    		System.debug('[Mock] Not handled: ' + req);
            return new HTTPResponse();
		}
	}

	public void addRequestMock(String url, ClarizenRestAPI_SingleMock mock) {
		requests.put(url, mock);
	}
}