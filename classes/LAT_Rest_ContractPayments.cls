@RestResource(urlMapping='/LAT_Rest_ContractPayments/*')
global without sharing class LAT_Rest_ContractPayments {
	
	@HttpPost
    global static void groupPayments(List<String> payments) {
    	
    	Body input = new Body(payments);
    	System.debug('%%%%% Input : ' + input);
    	Result res = new Result(LAT_ContractsWS.groupPayments(input.payments));
    	System.debug('%%%%% res.groupPayments : ' + res.paymentIds);

    	RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(res));
		RestContext.response.statusCode     = 200;
        
	}

	@HttpPut
    global static void checkPaymentRelease(String paymentId) {
    	
    	System.debug('%%%%% Input : ' + paymentId);
    	Result res = new Result(LAT_ContractsWS.checkPaymentRelease(paymentId));
    	System.debug('%%%%% res.groupPayments : ' + res);
    	Response r = new Response();
    	r.checkPaymentReleaseResponse = res;

    	RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(r));
		RestContext.response.statusCode     = 200;
        
	}
	
	public class Response {
		public Result checkPaymentReleaseResponse;
	}

	public class Result {
		
		public Result(List<LAT_ContractsWS.paymentToAprove> pPayments) {
			paymentIds = new List<String>();
			for(LAT_ContractsWS.paymentToAprove s : pPayments) {
				paymentIds.add(s.paymentID);
			}
		}
		public Result(LAT_ContractsWS.Payment payment) {
			result = payment;
		}
		public List<String> paymentIds {get; set;}
		LAT_ContractsWS.Payment result;
	}

	public class Body {

		public Body(List<String> pPayments) {
			payments = new List<LAT_ContractsWS.paymentToAprove>();
			for(String s : pPayments) {
				LAT_ContractsWS.paymentToAprove nuevo = new LAT_ContractsWS.paymentToAprove();
				nuevo.paymentID = s;
				payments.add(nuevo);
			}
		}
		public List<LAT_ContractsWS.paymentToAprove> payments {get; set;}
	}
}