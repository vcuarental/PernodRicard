/**
 * Created by illia on 06.08.18.
 */

@isTest
global with sharing class EUR_CRM_AccountGeolocationBatchMockTest implements HttpCalloutMock {
    private Integer statusCode;
    private Boolean isBadResponse;

    global EUR_CRM_AccountGeolocationBatchMockTest(Integer statusCode, Boolean isBadResponse) {
        this.statusCode = statusCode;
        this.isBadResponse = isBadResponse;
    }


    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        req.setEndpoint('http://example.com/example/test');
        System.assertEquals('http://example.com/example/test', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());

        HttpResponse res = new HttpResponse();
        String body = '';

        res.setHeader('Content-Type', 'application/json');
        if (statusCode == 200) {
            body = isBadResponse == false ? this.getPositiveResponseBody() : this.getNegativeResponseBody();
        }
        res.setStatusCode(statusCode);


        res.setBody(body);
        return res;
    }

    private String getPositiveResponseBody() {
        return '{"results" : [' +
            '{' +
            '"address_components":[' +
            '{"long_name" : "1600",' +
            '"short_name" : "1600",' +
            '"types" : [ "street_number" ]' +
            '},' +
            '{' +
            '"long_name" : "Amphitheatre Pkwy",' +
            '"short_name" : "Amphitheatre Pkwy",' +
            '"types" : [ "route" ]' +
            '},' +
            '{' +
            '"long_name" : "Mountain View",' +
            '"short_name" : "Mountain View",' +
            '"types" : [ "locality", "political" ]' +
            '},' +
            '{' +
            '"long_name" : "Santa Clara County",' +
            '"short_name" : "Santa Clara County",' +
            '"types" : [ "administrative_area_level_2", "political" ]' +
            '},' +
            '{' +
            '"long_name" : "California",' +
            '"short_name" : "CA",' +
            '"types" : [ "administrative_area_level_1", "political" ]' +
            '},' +
            '{' +
            '"long_name" : "United States",' +
            '"short_name" : "US",' +
            '"types" : [ "country", "political" ]' +
            '},' +
            '{' +
            '"long_name" : "94043",' +
            '"short_name" : "94043",' +
            '"types" : [ "postal_code" ]' +
            '}' +
            '],' +
            '"formatted_address" : "1600 Amphitheatre Parkway, Mountain View, CA 94043, USA",' +
            '"geometry" : {' +
            '"location" : {' +
            '"lat" : 37.4224764,' +
            '"lng" : -122.0842499' +
            '},' +
            '"location_type" : "ROOFTOP",' +
            '"viewport" : {"northeast" : {' +
            '"lat" : 37.4238253802915,' +
            '"lng" : -122.0829009197085' +
            '       },' +
            '"southwest" : {' +
            '"lat" : 37.4211274197085,' +
            '"lng" : -122.0855988802915' +
            '}' +
            '}' +
            '},' +
            '"place_id" : "ChIJ2eUgeAK6j4ARbn5u_wAGqWA",' +
            '"types" : [ "street_address" ]' +
            '}' +
            '],' +
            '"status" : "OK"' +
            '}';
    }

    private String getNegativeResponseBody() {
        return '{"results" : [' +
            '{' +
            '"address_components":[' +
            '{"long_name" : "1600",' +
            '"short_name" : "1600",' +
            '"types" : [ "street_number" ]' +
            '},' +
            '{' +
            '"long_name" : "Amphitheatre Pkwy",' +
            '"short_name" : "Amphitheatre Pkwy",' +
            '"types" : [ "route" ]' +
            '},' +
            '{' +
            '"long_name" : "Mountain View",' +
            '"short_name" : "Mountain View",' +
            '"types" : [ "locality", "political" ]' +
            '},' +
            '{' +
            '"long_name" : "Santa Clara County",' +
            '"short_name" : "Santa Clara County",' +
            '"types" : [ "administrative_area_level_2", "political" ]' +
            '},' +
            '{' +
            '"long_name" : "California",' +
            '"short_name" : "CA",' +
            '"types" : [ "administrative_area_level_1", "political" ]' +
            '},' +
            '{' +
            '"long_name" : "United States",' +
            '"short_name" : "US",' +
            '"types" : [ "country", "political" ]' +
            '},' +
            '{' +
            '"long_name" : "94043",' +
            '"short_name" : "94043",' +
            '"types" : [ "postal_code" ]' +
            '}' +
            '],' +
            '"formatted_address" : "1600 Amphitheatre Parkway, Mountain View, CA 94043, USA",' +
            '"geometry" : {' +
            '"location" : {' +
//            '"lat" : 37.4224764,' +
//            '"lng" : -122.0842499' +
            '},' +
            '"location_type" : "ROOFTOP",' +
            '"viewport" : {"northeast" : {' +
            '"lat" : 37.4238253802915,' +
            '"lng" : -122.0829009197085' +
            '       },' +
            '"southwest" : {' +
            '"lat" : 37.4211274197085,' +
            '"lng" : -122.0855988802915' +
            '}' +
            '}' +
            '},' +
            '"place_id" : "ChIJ2eUgeAK6j4ARbn5u_wAGqWA",' +
            '"types" : [ "street_address" ]' +
            '}' +
            '],' +
            '"status" : "OK"' +
            '}';
    }
}