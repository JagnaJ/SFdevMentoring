public class SmartCarMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        
        if (req.getEndpoint().contains('/vehicles')) {
            res.setBody('{"vehicles":["90dddba8-ee06-4593-bb83-41f2bc276d3c","f34368e7-6989-4b6f-b61d-44c8d2eb28ff"],"paging":{"count":2,"offset":0}}');
        } else if (req.getEndpoint().contains('/vehicles/90dddba8-ee06-4593-bb83-41f2bc276d3c')) {
            res.setBody('{"make":"Toyota","model":"Camry","year":2023,"location":{"latitude":37.7749,"longitude":-122.4194}}');
        }
        
        return res;
    }
}