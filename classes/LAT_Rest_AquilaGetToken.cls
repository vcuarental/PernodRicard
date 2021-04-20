@RestResource(urlMapping='/LAT_Rest_AquilaGetToken/*')
global with sharing class  LAT_Rest_AquilaGetToken {
	
	public static String GET_TOKEN = 'generate-sso-token';
	public static String API_SECRET = 'api-secret';

	@HttpGet
    global static void GET() {
    	System.debug('%%%% email : ' + UserInfo.getUserEmail());
		GetTokenResponse response = getToken(UserInfo.getUserEmail());
		System.debug('%%%% response : ' + response);
		if(response.token != null) {
			ServiceResponse res = new ServiceResponse (response.token);
			RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(res)); 
			RestContext.response.statusCode     = 200;
		} else {
			ServiceResponse res = new ServiceResponse ('ERROR',response.message, false );
			RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(res)); 
			RestContext.response.statusCode     = 400;
		}
		RestContext.response.addHeader('Content-Type', 'application/json');

    }

    public static GetTokenResponse getToken(String email){
    	System.debug('en getToken, email : ' + email);
        LAT_IMM_Operations__c operation = LAT_IMM_Operations__c.getInstance(GET_TOKEN);
        GetTokenRequestBody pBody = new GetTokenRequestBody(email);

        LAT_IMM_Logs__c log             = new LAT_IMM_Logs__c();
        log.LAT_Request__c              = JSON.serialize(pBody);
        log.LAT_Service__c              = GET_TOKEN;
        log.LAT_TimeStamp__c            = Datetime.now();
		
		GetTokenResponse retorno;
        try {

	        String endpoint = operation.EndpointUrl__c + GET_TOKEN;
	       
	        HttpRequest req = new HttpRequest();
	        req.setHeader('Content-Type', 'application/json');
	        req.setEndpoint(endpoint);
	        req.setMethod(operation.Http_operation__c);
	        req.setHeader(API_SECRET, operation.x_Api_key__c);
	        req.setTimeout(2 * 50 * 1000);

            req.setBody(JSON.serialize(pBody));
	        
	        System.debug('%%%%%% request url : ' + req.getEndpoint());
	        System.debug('%%%%%% request API_SECRET : ' + req.getHeader(API_SECRET));
	        System.debug('%%%%%% request Body : ' + req.getBody());
	        
	        Http http = new Http();
	        HTTPResponse res;
	        
	        res = http.send(req);
	        
            retorno = (GetTokenResponse)System.JSON.deserialize(res.getBody(), GetTokenResponse.class);
            System.debug('%%%% retorno : ' + retorno);
            log.LAT_Response__c = (retorno.message == null)?'Success' : 'Error: '+retorno.message;
        } catch (Exception e) {
        	System.debug('%%%% errorrorororrr : ' + e);
            log.LAT_IMM_Id__c   = 'ERROR';
            log.LAT_Response__c = e.getMessage() + ' || ' + e.getStackTraceString();
        }

        
        insert log;
        
    	return retorno;
    }

    public class ServiceResponse {

        public ServiceResponse(String pToken) {
            success = true;
            token = pToken;
        }


        public ServiceResponse(String msg, Boolean bool) {
            success = bool;
            message = msg;
        }

        public ServiceResponse(String msg, String error, Boolean bool) {
            success = bool;
            message = msg;
            errorCode = error;
        }

        public String token;
        public Boolean success;
        public String message;
        public String errorCode;
    }

    public class GetTokenResponse {
		public String token;
        public Boolean success;
        public String message;
    }

    public class GetTokenRequestBody {

    	public GetTokenRequestBody(String pEmail){
    		email = pEmail;
    	}

		public String email;
    }
}