@RestResource(urlMapping='/LAT_Rest_ContractGetClientPDF/*')
global with sharing class LAT_Rest_ContractGetClientPDF {
	
	public static final Set<String> EVENT_DEVELOPER_NAMES = new Set<String>{'LAT_Eventos_Contrato_de_Parceria', 'LAT_Eventos_Contrato_de_Parceria_Distribuidor'};

	@HttpPost
    global static void POST(String contractId) {
        List<LAT_Contract2__c> lstContracts = null;
		LAT_Contract2__c objContract = null;
		LAT_Rest_Contracts.ServiceResponse objResponse = null;
		PageReference objPDF = null;
		String strContractId = null;

		strContractId = contractId; 
		System.debug('LAT_Rest_ContractGetClientPDF.POST [strContractId : ' + strContractId + '] ->');
		lstContracts = [SELECT Id, RecordType.DeveloperName FROM LAT_Contract2__c WHERE Id = :strContractId];
        if(!lstContracts.isEmpty()) {
			objContract = lstContracts[0];
			System.debug('LAT_Rest_ContractGetClientPDF.POST [objContract.RecordType : ' + objContract.RecordType.DeveloperName + '] ->');

			if(LAT_ContractsCalculations.EVENT_DEVELOPER_NAMES.contains(objContract.RecordType.DeveloperName) || objContract.RecordType.DeveloperName == LAT_ContractsCalculations.EVENT_PRODUCER_SIMULATION  || objContract.RecordType.DeveloperName == LAT_ContractsCalculations.EVENT_DISTRIBUTOR_SIMULATION ){
				System.debug('LAT_Rest_ContractGetClientPDF.POST [objContract.RecordType : ' + objContract.RecordType.DeveloperName + '] ->');
				if (objContract.RecordType.DeveloperName == LAT_ContractsCalculations.EVENT_DISTRIBUTOR || objContract.RecordType.DeveloperName == LAT_ContractsCalculations.EVENT_DISTRIBUTOR_SIMULATION) {
					System.debug('LAT_Rest_ContractGetClientPDF.POST [Generating Distribuidor PDF]');
					objPDF = Page.LAT_ContractDistributorBusinessAgreement;
					objPDF.getParameters().put('contractId',strContractId);
				} else { 
					System.debug('LAT_Rest_ContractGetClientPDF.POST [Generating Produtor PDF]');
					objPDF = Page.LAT_ContractAPDocumentsPDF;
					objPDF.getParameters().put('type','annex1');
				}
			} else if(objContract.RecordType.DeveloperName == 'LAT_CartaAtivacao'){
				System.debug('LAT_Rest_ContractGetClientPDF.POST [Generating Carta Activacion PDF]');
				objPDF = Page.LAT_ContractActivationLetterDocumentsPDF;
			} else {
				System.debug('LAT_Rest_ContractGetClientPDF.POST [Generating other PDF]');
				objPDF = Page.LAT_ContractCoverPDF;
			}
        	 
	        objPDF.getParameters().put('id',strContractId);
			objPDF.setRedirect(true);
			
	        RestContext.response.responseBody   = objPDF.getContentAsPDF();
	        RestContext.response.addHeader('Content-Type', 'application/pdf');
	        RestContext.response.statusCode  = 200;
        } else {
        	objResponse = new LAT_Rest_Contracts.ServiceResponse(strContractId, 'NOT FOUND CONTRACT', false);
	        RestContext.response.addHeader('Content-Type', 'application/json');
	        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(objResponse));
    	    RestContext.response.statusCode = 400;    
		}  
		
		System.debug('LAT_Rest_ContractGetClientPDF.POST [] <-');
    }
}