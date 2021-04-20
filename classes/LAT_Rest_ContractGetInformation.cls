@RestResource(urlMapping='/LAT_Rest_ContractGetInformation/*')
global with sharing class LAT_Rest_ContractGetInformation {

	@HttpPost
    global static void ContractGetInformation() {
        RestRequest req = RestContext.request;
        //Body input = (Body)System.JSON.deserialize(req.requestBody.toString(), Body.class);

		ContractDummy contratoDummy = (ContractDummy)System.JSON.deserialize(req.requestBody.toString(), ContractDummy.class);
		
		System.debug('%%%%% Inputdummy : ' + contratoDummy);
		
		LAT_ContractsWS.Contract contract =  parseDummy(contratoDummy);

    	System.debug('%%%%% Input contract : ' + contract);

    	Response res = new Response();
    	Result r = new Result();
    	r.result = LAT_ContractsWS.getContractInformation(contract);
    	res.getContractInformationResponse = r;
    	System.debug('%%%%% res.getContractInformationResponse : ' + r.result);
		
    	System.debug('%%%%% res : ' + res);

    	RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(res));
		RestContext.response.statusCode     = 200;
        
	}

	public class Response {
		public Result getContractInformationResponse;
	}

	public class Result {
		public LAT_ContractsWS.ContractInformation result;
	}

	public class Body {
		public LAT_ContractsWS.Contract contract;
	}	
	public static LAT_ContractsWS.Contract parseDummy(ContractDummy con){
		LAT_ContractsWS.Contract retorno = new LAT_ContractsWS.Contract();
		retorno.contractTerms = Integer.valueOf(con.contract.contractTerms);
		retorno.recordType = con.contract.recordType;
		retorno.roiSegment = con.contract.roiSegment;
		retorno.uf = con.contract.uf;

		retorno.payments = new List<LAT_ContractsWS.Payments>();
		retorno.contractVolume = new List<LAT_ContractsWS.ContractVolume>();

		for (LAT_ContractsWS.Payments payment : con.contract.payments) {
			retorno.payments.add(payment);
		}

		for (LAT_ContractsWS.ContractVolume conVolume : con.contract.contractVolume) {

			if(conVolume.boxesMaximum != null && conVolume.boxesMinimum == null){
				conVolume.boxesMinimum = conVolume.boxesMaximum;
			}

			System.debug('conVolume: ' + conVolume);

			retorno.contractVolume.add(conVolume);

			System.debug('retorno.contractVolume: ' + retorno.contractVolume);
		}

		return retorno;
	}
	public class Contract{
		public String recordType;
		public Decimal contractTerms;
		public List<LAT_ContractsWS.Payments> payments;
		public List<LAT_ContractsWS.ContractVolume> contractVolume;
		public String roiSegment;
		public String uf;
	}

	public class ContractDummy{
		public Contract contract;
	}

	
 }