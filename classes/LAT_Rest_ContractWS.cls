@RestResource(urlMapping='/LAT_Rest_ContractWS/*')
global with sharing class LAT_Rest_ContractWS {
	@HttpPost
    global static void ContractGeneratePayment(String contractId){
    	
    	System.debug('%%%% contrato : ' +contractId);
    	Boolean res = LAT_ContractsWS.generatePaymentWS(contractId);

    	ServiceResponse response = new ServiceResponse(res);
    	RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(response));
        if (response.generatePaymentWSResponse.result) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }

    }

    global class ServiceResponse {

		global GeneratePaymentWSResponse generatePaymentWSResponse;

		global ServiceResponse(Boolean bool) {
			generatePaymentWSResponse = new GeneratePaymentWSResponse(bool);
		}	

	}

	global class GeneratePaymentWSResponse {
		global Boolean result;

		public GeneratePaymentWSResponse(Boolean bool) {
        	result = bool;
    	}
	}
 }