public with sharing class ASI_KOR_GoogleMapHelper {
	private static String GoogleGeocodingURL = 'https://maps.googleapis.com/maps/api/geocode/json';
	private static String GoogleGeocodingURL_PARAM_ADDRESS = 'address';
	private static String GoogleGeocodingURL_PARAM_SENSOR = 'sensor';
	private static String GoogleGeocodingURL_METHOD = 'GET';
	public static final String STATUS_OK = 'OK';
	public static final String STATUS_OVER_QUERY_LIMIT = 'OVER_QUERY_LIMIT';

	public static String[] getLatLngByAddressStr(String addressStr) {
		String[] results = new String[2];
		HttpRequest httpReq = new HttpRequest();
		String url = GoogleGeocodingURL;
		url += '?' + GoogleGeocodingURL_PARAM_ADDRESS + '=' + EncodingUtil.urlEncode(addressStr, 'UTF-8');
		url += '&' + GoogleGeocodingURL_PARAM_SENSOR + '=false';
		httpReq.setEndpoint(url);
		httpReq.setMethod(GoogleGeocodingURL_METHOD);
		
		// Start sending the request
		System.debug(LoggingLevel.INFO, 'Getting Lat Lng Info of address: ' + addressStr);
		HttpResponse httpResp = new Http().send(httpReq);
		
		String bodyStr = httpResp.getBody();
		System.debug(bodyStr);
		JSONParser parser = JSON.createParser(bodyStr);
		
		String status = null;
		while (parser.nextToken() != null) {
			if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
				if (parser.getText() == 'status') {
					parser.nextToken();
					status = parser.getText();
				} else if (parser.getText() == 'location') {
					// Get the value. 
					parser.nextToken();
					parser.nextToken();
					parser.nextToken();
					results[0] = parser.getText();
	
					parser.nextToken();
					parser.nextToken();
					results[1] = parser.getText();
				}
			}
			if (results[0] != null && status != null) break;
		}
		if (status != STATUS_OK) {
			throw new ASI_KOR_CustomException(status);
		}
		return results;
	}
}