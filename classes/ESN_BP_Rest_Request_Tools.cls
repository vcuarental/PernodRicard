public with sharing class ESN_BP_Rest_Request_Tools {
	/**
	*
	*	Function that sends HTTP Rest Request
	*/
	@future (callout=true)
	public static void REST_Request(String method, String endpoint, Map<String,String> header, String body){
		HttpResponse response = new HttpResponse();
		HttpRequest req = new HttpRequest();
		

		//Set HTTPRequest Method
		req.setMethod(method);

		//Set HTTPRequest header properties
		for(String headerValue : header.KeySet()){
			req.setHeader(headerValue, header.get(headerValue));
		}
		
		// Set the HTTPRequest endpoint
		req.setEndpoint(endpoint);

		//Set the HTTPRequest body	
		req.setBody(body); 	

		Http http = new Http();
		  
		try {
		 	
			//Execute web service
		    response = http.send(req);
		    System.debug('===> Response: '+response);	
		    System.debug('===> Response body: '+response.getBody());
				
		} catch(System.CalloutException e) {
			//Exception handling
			System.debug('ESN_BP Exception thrown while sending following HTTP Rest request '+req.toString());
			System.debug('ESN_BP Exception has the following exception message '+e.getMessage());
			System.debug('ESN_BP Exception was caused by '+e.getCause());
			System.debug('ESN_BP Exception full stack trace '+e.getStackTraceString());
		}				    
	}
}