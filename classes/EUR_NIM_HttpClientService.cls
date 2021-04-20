/**
* @Description Separate class to put http logic
* @Author Minakshi
* @Copyright PARX
*/
public with sharing class EUR_NIM_HttpClientService
{
    public static HttpRequest generateRequest(String method, String calloutEndpoint, String contentType, String body)
    {
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setEndpoint('callout:' + calloutEndpoint);
        request.setTimeout(120000);
        request.setHeader('Content-Type', contentType);
        request.setBody(body);
        return request;
    }

    public static HttpResponse getResponse(HttpRequest request)
    {
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }
}