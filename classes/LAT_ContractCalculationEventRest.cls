@RestResource(urlMapping='/LAT_ContractCalculationEventRest/')
global with sharing class LAT_ContractCalculationEventRest {
	@HttpPost
	global static void post() {
		LAT_ContractHandlerJSON.ContractCalculationProdutor objCalculosProductor = null;
		LAT_ContractHandlerJSON.ContractCalculationDistribuidor objContractCalculationDistribuidor = null;
		LAT_Rest_Contracts.ServiceResponse objResponse = null;
        LAT_ContractHandlerJSON objRequest = null;
		String strResult = null;
		RestRequest objRESTRequest = null;
		LAT_ContractsCalculations objContractCalculation = null;
		LAT_Contract2__c objContract = null;
		LAT_ContractsCalculations objCC = null;

		System.debug('LAT_ContractCalculationEventRest.post [] ->');		
		try {
			objRESTRequest = RestContext.request;
			RestContext.response.statusCode = 400;
            System.debug('LAT_ContractCalculationEventRest.POST [request : ' + objRESTRequest.requestBody.toString() + ']');
            objRequest = (LAT_ContractHandlerJSON)System.JSON.deserialize(objRESTRequest.requestBody.toString(), LAT_ContractHandlerJSON.class);

			if(objRequest != null) {
				objContractCalculation = new LAT_ContractsCalculations();
				if(objRequest.recordType == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_Rest_Contracts.CONTRACTS_EVENTS_PARCERIA_PRODUTOR).getRecordTypeId() || objRequest.recordType == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_Rest_Contracts.CONTRACTS_EVENTS_SIMULACION_PRODUTOR).getRecordTypeId()) {
					System.debug('LAT_ContractCalculationEventRest.post [ContractCalculationProdutor]');
					System.debug('LAT_ContractCalcuLAT_ContractCLAT_ContractCalculationEventRestalculationEventRestlationRest.post [ContractCalculationDistribuidor]');
					objCC = new LAT_ContractsCalculations();

					strResult = objCC.calculatePaymentsInformationEventos2(objRequest);

					RestContext.response.statusCode = 200;		                    
				} else if( objRequest.recordType == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_Rest_Contracts.CONTRACTS_EVENTS_PARCERIA_DISTRIBUIDOR).getRecordTypeId() || objRequest.recordType == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_Rest_Contracts.CONTRACTS_EVENTS_SIMULACION_DISTRIBUIDOR).getRecordTypeId() ) { 
					System.debug('LAT_ContractCalcuLAT_ContractCLAT_ContractCalculationEventRestalculationEventRestlationRest.post [ContractCalculationDistribuidor]');
					objCC = new LAT_ContractsCalculations();

					strResult = objCC.calculatePaymentsInformationEventos2(objRequest);

					RestContext.response.statusCode = 200;		
				} else {
                    System.debug('LAT_ContractCalculationEventRest.post [No se encontro el contrato : ' + objRequest.recordType + ']');

                    objResponse = new LAT_Rest_Contracts.ServiceResponse(null, 'El tipo de contrato no es válido [Error : 110 - RecordType : ' + objRequest.recordType + ']', false);
					strResult = JSON.serialize(objResponse);	
					RestContext.response.statusCode = 400;			
                }
			} else {
				System.debug('LAT_ContractCalculationEventRest.post [Requerimineto nulo]');

				objResponse = new LAT_Rest_Contracts.ServiceResponse(null, 'No se pudo obtener la informacion del contrato [Error : 100]', false);
				strResult = JSON.serialize(objResponse);
				RestContext.response.statusCode = 400;
			}
		} catch(Exception Ex) {
			debugException(Ex);
			objResponse = new LAT_Rest_Contracts.ServiceResponse(null, Ex.getMessage(), false);
			strResult = JSON.serialize(objResponse);
			RestContext.response.statusCode = 400;
		}
		
		System.debug('LAT_ContractCalculationEventRest.post [strResult : ' + strResult + ']');

		RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(strResult);

		System.debug('LAT_ContractCalculationEventRest.post [' + RestContext.response.responseBody  + '] <-');
	}

	@TestVisible
	public static void debugException(Exception Ex) {
		System.debug('debugException [] ->');

		if(Ex != null) {
			System.debug('debugException [message : ' + Ex.getMessage() + ']');
			System.debug('debugException [stacktrace : ' + Ex.getStackTraceString() + ']');
			if(Ex.getCause() != null) {
				debugException(Ex.getCause());
			}
		}
		System.debug('debugException [] <-');
	}

	
	@TestVisible
	private static LAT_Contract2__c retrieveContractDistributor(Id objContractid) {
		List<LAT_Contract2__c> lstContract = null;

		lstContract = [	SELECT ROINetSalesRoiPrevisto__c, TotalProductsPRBCostCondComercial__c, TotalTaxNetSales__c, TotalShippingAP__c , TotalShippingNetSales__c, 
						(SELECT LAT_Tipo_de_Evento__c, LAT_PredictedROI__c, LAT_External_Id__c From Eventos__r ) 
						FROM LAT_Contract2__c 
						WHERE Id =: objContractid];

		return lstContract[0];
	}

	@TestVisible
	private static LAT_Contract2__c retrieveContractProdutor(Id objContractid) {
		List<LAT_Contract2__c> lstContract = null;

		lstContract = [	SELECT TotalProductsPRBCostCondComercial__c,	
								TotalProductsPRBCostCondComercialNetSale__c,
								TotalProductsPRBCostPatrocinio__c,
								TotalProductsPRBCostPatrocinioNetSales__c,
								TotalTaxAP__c,
								TotalTaxNetSales__c,
								TotalShippingAP__c,
								TotalShippingNetSales__c, 
								TotalMoneyPRBCost__c,	
								TotalEventContractPRBCost__c,
								TotalEventContractPRBCostNetSales__c,
								TotalProductsPerceivedValueCondComercial__c,
								TotalProductsPerceivedValuePatrocinio__c,
								TotalMoneyPerceivedValue__c,
								LAT_TotalContractOnInvoice__c,
								TotalEventContractPerceivedValue__c,
								ROIApRoiPrevisto__c,	
								ROIApMeta__c,	
								ROIApVsMeta__c,
								ROINetSalesRoiPrevisto__c,	
								ROINetSalesMeta__c,	
								ROINetSalesVsMeta__c,
								ROIContratoRoiPrevisto__c,	
								ROIContratoMeta__c,	
								ROIContratoVsMeta__c,
								(SELECT LAT_Tipo_de_Evento__c, 
										LAT_PredictedROI__c, 
										LAT_External_Id__c 
										From Eventos__r ) 
						FROM LAT_Contract2__c 
						WHERE Id =: objContractid];

		return lstContract[0];
	}
}