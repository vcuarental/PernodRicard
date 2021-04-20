@RestResource(urlMapping='/LAT_Rest_CheckPaymentRelease/*')
global with sharing class LAT_Rest_CheckPaymentRelease {

	@HttpPost
    global static void CheckPaymentRelease(String paymentId){
    	
    	System.debug('%%%% contrato : ' +paymentId);
    	LAT_ContractsWS.Payment res = LAT_ContractsWS.checkPaymentRelease(paymentId);
    	System.debug('%%%% res : ' + JSON.serialize(res));

    	ServiceResponse response = new ServiceResponse(res);
    	RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(response));
        RestContext.response.statusCode     = 200;
        
    }

    global class ServiceResponse {

		global LAT_ContractsWS.Payment result;

		global ServiceResponse(LAT_ContractsWS.Payment res) {
			result = res;
		}	

	}
}