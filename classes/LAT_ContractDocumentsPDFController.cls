public with sharing class LAT_ContractDocumentsPDFController {
    public LAT_Contract2__c contract { get;set; }
	public String body { get; set; }
	public String contractName { get; set; }
	public Boolean isApproved { get; set; }
	public Boolean needsPresidentSign { get;set; }
    public Boolean needsDirectorFinanciero { get;set; }
    public Boolean needsDirectorComercial { get;set; }
    public Boolean isprestige { get;set; }

	private final Set<String> EVENT_DEVELOPER_NAMES = new Set<String>{'LAT_Eventos_Contrato_de_Parceria', 'LAT_Eventos_Contrato_de_Parceria_Distribuidor'};

	public LAT_ContractDocumentsPDFController() {
		System.debug('LAT_ContractDocumentsPDFController [] ->');

		initializePage();

		System.debug('LAT_ContractDocumentsPDFController [] <-');
	}

	private void initializePage() {
		Id objContractid = null;
		String strDocumentName = null;

		System.debug('initializePage [] ->');

		objContractid = System.CurrentPageReference().getParameters().get('id');
		strDocumentName = System.CurrentPageReference().getParameters().get('docName');
		if(String.isNotBlank(objContractid)) {
			this.contractName = '';
			this.body = '';
			this.isApproved = false;
			
			if (String.isBlank(strDocumentName)) {
				strDocumentName = 'MinutaPadrao';
			}

			this.contract = retrieveContract(objContractid);
			if(this.contract != null) {
				this.body = retrieveBody(strDocumentName, contract);

				if(EVENT_DEVELOPER_NAMES.contains(contract.RecordType.DeveloperName)) {
					this.needsPresidentSign = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_PRESIDENT_GREATER_THAN_EVENTOS);
					this.needsDirectorFinanciero = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN_EVENTOS);
					this.needsDirectorComercial = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN_EVENTOS);
				} else if(contract.RecordType.DeveloperName == 'LAT_BR_Acordo') {
					this.needsPresidentSign = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_PRESIDENT_GREATER_THAN_EVENTOS);
					this.needsDirectorFinanciero = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN_EVENTOS);
					this.needsDirectorComercial = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN_EVENTOS);				
				} else {
					this.isprestige = (contract.LAT_ClientRegional__c == 'REG NBD');
					if (this.isprestige){
						this.needsPresidentSign = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_PRESIDENT_GREATER_THAN_PRESTIGE);
						this.needsDirectorFinanciero = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN_PRESTIGE);
						this.needsDirectorComercial = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN_PRESTIGE);
					} else {
						if(contract.RecordType.DeveloperName != 'LAT_CartaAtivacao'){
							needsPresidentSign = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_PRESIDENT_GREATER_THAN);
							needsDirectorFinanciero = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN);
							needsDirectorComercial = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN);
						}
					}
				}
			} else {
				throw new LAT_Rest_Contracts.RestContractException('No se ha encontrado el contrato ingresado');
			}
		} else {
			throw new LAT_Rest_Contracts.RestContractException('El contrato ingresado no puede ser nulo');
		}
		System.debug('initializePage [] <-');
	}

	private LAT_Contract2__c retrieveContract(Id objContractId) {
		List<LAT_Contract2__c> lstContract = null;
		LAT_Contract2__c objContract = null;

		System.debug('retrieveContract [objContractId : ' + objContractId + '] ->');

		lstContract = [SELECT  	LAT_Digital__c, RecordType.DeveloperName, LAT_ClientRegional__c,Revenue__c, RegionalCustomerOnPremise__c,Comments__c, 
							   	VodkaClubCabinets__c, WhiskyClubCabinets__c, DJBooth__c, BarsShelves__c,
							   	Name ,  CustomerSignatory__c, CustomerSignatory__r.name, Status__c, createdBy.Name,
								RecordType.Name, Account__r.regional__r.Name, Account__r.Nielsen_Area__r.Name, Account__r.Billing_Address__c, Account__r.Billing_Number__c,
								Account__r.Revenue_City__c,  Account__r.Revenue_Postal_Code__c,  Account__r.Revenue_Address__c, Account__r.Revenue_Number__c ,
								Account__r.Revenue_UF__c, Account__r.Billing_UF__c, Account__r.Billing_City_Code__c, Account__r.Billing_PostalCode__c,
								Account__r.Corporate_Name__c, Account__r.name, Account__r.Revenue_City__r.name, Account__r.Sub_Channel_Rating__r.name,
								Account__r.CNPJ__c, Account__r.State_Registration__c, Account__r.subType__c, StartDate__c, EndDate__c, ContractTerms__c,
								ROI__c, TotalProductsPerceivedValue__c, TotalMoneyPerceivedValue__c,convertCurrency(ContractValue__c),
								OriginalContractNumber__c, OriginalContractName__c,TradingConditionNegotiated__c,
								(SELECT Provider__c, CNPJ__c FROM LAT_Providers__r),
								(SELECT Category__c,Contract__c,CurrencyIsoCode,ExclusivityPromotional__c,Id,Name,Notes__c,Priority__c,VisualExclusivity__c FROM Acordos_Promocionales__r),
		  						(SELECT ProductGroup__r.Name, BoxesContract__c,BusinessCondition__c,CurrencyIsoCode,Id,LAT_Contract__c,Name,ProductGroup__c FROM LAT_ContractVolumes__r),
								(SELECT  Ammount__c,Finality__c,PaymentDate__c,ProductGroup__c,RecordTypeId,Status__c,ProductGroup__r.Name,  RecordType.Name, Type__c,Volumen__c FROM LAT_Payments__r ORDER BY PaymentDate__c ASC ),
								(SELECT Type__c, Comment__c FROM Contrapartidas_de_Visibilidades__r),
								(SELECT Client__c, Client__r.Name, Client__r.CNPJ__c  FROM Clientes_do_Contrato__r)
						   	FROM LAT_Contract2__c 
							WHERE Id =: objContractId];
		if(!lstContract.IsEmpty()) {
			objContract = lstContract[0];
		}

		System.debug('retrieveContract [' + objContract + '] <-');
		return objContract;		
	}

	private String retrieveBody(String strContractDocument, LAT_Contract2__c objContract) {
		List<LAT_ContractDocs__c> lstContractDocument = null;
		String strBody = null;

		System.debug('retrieveBody [strContractDocument : ' + strContractDocument + ' - objContract : ' + objContract + '] ->');
		
		lstContractDocument = [SELECT Id, body__c FROM LAT_ContractDocs__c WHERE Name =: strContractDocument];
		strBody = (!lstContractDocument.IsEmpty()) ? convertTags(lstContractDocument[0].body__c, objContract) : '';

		System.debug('retrieveBody [' + strBody + '] <-');

		return strBody;
	}

	private String convertTags(String strBody, LAT_Contract2__c objContract) {
		String strNegociated = null;

		System.debug('convertTags [strBody : ' + strBody + ' - objContract : ' + objContract + '] ->');
		
		if(objContract != null && String.isNotBlank(strBody) ){
			strNegociated = (objContract.TradingConditionNegotiated__c != null) ? objContract.TradingConditionNegotiated__c : 'N/A';
			contractName =  objContract.Name;
			isApproved =  (objContract.Status__c == 'Aprovado');

			strBody = strBody.replace('[STARTDATE]', String.valueOf(objContract.StartDate__c.format())).replace('[ENDATE]', String.valueOf(contract.EndDate__c.format())).replace('[CCNEGOCIATED]', strNegociated);
		}

		System.debug('convertTags [' + strBody + '] <-');
		return strBody;
	}
}