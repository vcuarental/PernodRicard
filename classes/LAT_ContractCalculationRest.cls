@RestResource(urlMapping='/LAT_ContractCalculationRest/')
global without sharing class LAT_ContractCalculationRest {
	@HttpPost
	global static void post(String contractId) {
		ContractCalculationProdutor objCalculosProductor = null;
		ContractCalculationDistribuidor objContractCalculationDistribuidor = null;
		ContractCalculationNormal objContractCalculationNormal = null;
		String strResult = null;
		Decimal dblRoi = null;
		List<LAT_Contract2__c> lstContract = null;
		LAT_Rest_Contracts.ServiceResponse objResponse = null;
		
		System.debug('LAT_ContractCalculationRest.post [contractId : ' + contractId  + '] ->');
		
		try {
			lstContract = [	SELECT RecordTypeId 
							FROM LAT_Contract2__c 
							WHERE Id=:contractId 
							LIMIT 1];

			if(!lstContract.IsEmpty()) {
				if(lstContract[0].RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_Rest_Contracts.CONTRACTS_EVENTS_PARCERIA_PRODUTOR).getRecordTypeId()) {
					System.debug('LAT_ContractCalculationRest.post [ContractCalculationProdutor]');
					
					objCalculosProductor = new ContractCalculationProdutor();
					strResult = JSON.serialize(objCalculosProductor, false);		

				} else if(lstContract[0].RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_Rest_Contracts.CONTRACTS_EVENTS_PARCERIA_DISTRIBUIDOR).getRecordTypeId()) { 
					System.debug('LAT_ContractCalculationRest.post [ContractCalculationDistribuidor]');
					
					objContractCalculationDistribuidor = new ContractCalculationDistribuidor();
					

					strResult = JSON.serialize(objContractCalculationDistribuidor, false);

				} else {
					System.debug('LAT_ContractCalculationRest.post [ContractCalculationNormal]');

					objContractCalculationNormal = new ContractCalculationNormal();
					objContractCalculationNormal.roi = String.valueOf(LAT_ContractsWS.emulateRoi(contractId));
					strResult = JSON.serialize(objContractCalculationNormal, false);
				}
			} else {
				System.debug('LAT_ContractCalculationRest.post [No se encontro el contrato : ' + contractId + ']');

				objResponse = new LAT_Rest_Contracts.ServiceResponse(null, 'No se encontró el contrato que desea calcular [' + contractId + ']', false);
				strResult = JSON.serialize(objResponse);
			}
		} catch(Exception Ex) {
			objResponse = new LAT_Rest_Contracts.ServiceResponse(null, Ex.getMessage(), false);
			strResult = JSON.serialize(objResponse);
		}
		
		System.debug('LAT_ContractCalculationRest.post [strResult : ' + strResult + ']');

		RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(strResult);

		System.debug('LAT_ContractCalculationRest.post [' + RestContext.response.responseBody  + '] <-');
	}

	public class ContractCalculationProdutor {
		public String totalProductosCondicionComercial {get; set; }
		public String totalProductosPatrocinio {get; set; }
		public String totalImposto {get; set; }
		public String totalFrete {get; set; }
		public String totalDinero {get; set; }
		public String totalContrato {get; set; }
		public String totalInvoice {get; set; }
		public String roiAP {get; set; }
		public String roiNETSales {get; set; }

		public ContractCalculationProdutor() {
			this.totalProductosCondicionComercial = '0';
			this.totalProductosPatrocinio = '0';
			this.totalImposto = '0';
			this.totalFrete = '0';
			this.totalDinero = '0';
			this.totalContrato = '0';
			this.totalInvoice = '0';
			this.roiAP = '0';
			this.roiNETSales = '0';
		}
	}

	public class ContractCalculationDistribuidor {
		public String roi_oninvoice {get; set; }
		public String roi_offinvoice {get; set; }		

		public String total_offinvoice {get; set; }		
		public String total_imposto {get; set; }
		public String total_flete {get; set; }

		public List<ContractCalculationEvent> eventos {get; set; }		

		public ContractCalculationDistribuidor() {
			this.roi_oninvoice = '0';
			this.roi_offinvoice = '0';
			this.total_offinvoice = '0';
			this.total_imposto = '0';
			this.total_flete = '0';	

			this.eventos = new List<ContractCalculationEvent>();	
		}
	}

	public class ContractCalculationEvent {
		public String type {get; set; }		
		public String roi {get; set; }		
		public String invoice {get; set; }
	}

	public class ContractCalculationNormal {
		public String roi {get; set; }
	}
}