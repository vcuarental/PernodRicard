@RestResource(urlMapping='/LAT_Rest_GetContractInformation/*')
global with sharing class LAT_Rest_GetContractInformation {
	
	@HttpPost
    global static GetResponse getContractInformation(LAT_ContractsWS.Contract contract) {

    	return new GetResponse(LAT_ContractsWS.getContractInformation(contract));
    }

    global class GetResponse {
		global LAT_ContractsWS.ContractInformation getContractInformationResponse;
		global GetResponse (LAT_ContractsWS.ContractInformation param) {
			getContractInformationResponse = param;
		}
    }
}