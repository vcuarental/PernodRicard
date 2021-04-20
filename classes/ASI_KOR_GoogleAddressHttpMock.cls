@isTest
public class ASI_KOR_GoogleAddressHttpMock implements HttpCalloutMock {
	
	public static Decimal DEF_LAT = 22.2942880;
	public static Decimal DEF_LNG = 114.1719010;
	
	public HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json; charset=UTF-8');
		res.setStatusCode(200);
		res.setBody('{"results" : [{"address_components" : [{"long_name" : "Hong Kong Space Museum","short_name" : "Hong Kong Space Museum","types" : [ "point_of_interest", "establishment" ]},{"long_name" : "Hong Kong","short_name" : "HK","types" : [ "country", "political" ]}],"formatted_address" : "Hong Kong Space Museum, 10 Salisbury Road, Hongkong, Hong Kong","geometry" : {"location" : {"lat" : ' + DEF_LAT + ',"lng" : ' + DEF_LNG + '},"location_type" : "APPROXIMATE","viewport" : {"northeast" : {"lat" : 22.30461150,"lng" : 114.18790840},"southwest" : {"lat" : 22.28396370,"lng" : 114.15589360}}},"types" : [ "point_of_interest", "museum", "establishment" ]}],"status" : "OK"}');
		return res;
	}
}