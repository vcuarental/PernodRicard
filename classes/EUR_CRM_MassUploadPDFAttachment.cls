global class EUR_CRM_MassUploadPDFAttachment implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

	public String query;
	global String sessionId;
	public List<String> contractIdList;
	/*private String BASIC_CONTRACT = 'Basic Contract';
	private String CONCEPT_CONTRACT = 'Concept Contract';
	private String STANDARD_CONTRACT = 'Standard Contract';*/

	global EUR_CRM_MassUploadPDFAttachment(String contractIds) {
		this.sessionId = sessionId;
		this.contractIdList = contractIds.split(',');
		this.query = 'select id,Name,EUR_CRM_Contract_Sub_Type__c,EUR_CRM_Contract_Copy_File_Name__c from EUR_CRM_Contract__c where id in: contractIdList';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug(Database.getQueryLocator(query));
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<EUR_CRM_Contract__c> scope) {
		for(EUR_CRM_Contract__c contract: scope) {
			Id contractId = contract.id;
			
			if(contractId == null)
			    continue;

			/*PageReference pdf = null;
			
			if(contract.EUR_CRM_Contract_Sub_Type__c == BASIC_CONTRACT){
			    pdf = Page.EUR_CRM_DE_ContractPDF_Basic;     
			}else if(contract.EUR_CRM_Contract_Sub_Type__c == CONCEPT_CONTRACT){
			    pdf = Page.EUR_CRM_DE_ContractPDF_Concept;
			}else{
			    return;
			} 
			pdf.getParameters().put('id',contractId);

			System.debug(pdf);*/
			System.debug(contractId);

			EUR_CRM_DE_AttachContractPDFContent.attachPDFToContract(contract, sessionId);
		}
	}

	global void finish(Database.BatchableContext BC) {

	}

}