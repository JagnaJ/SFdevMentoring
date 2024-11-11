@IsTest
private class SmartCarIntegrationMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if (req.getEndpoint().contains('/location')) {
            res.setBody('{"latitude": 37.7749, "longitude": -122.4194}');
        } else {
            res.setBody('{"make": "TOYOTA", "model": "RAV 4", "year": 2020}');
        }
        
        res.setStatusCode(200);
        return res;
    }
}