public with sharing class EUR_CRM_ContractEventsTableCtrlr {

	public String contractId {get;set;}
	//public List<EUR_CRM_Contract_Product_Item__c> contractEvents {get;set;}
	
	public EUR_CRM_ContractEventsTableCtrlr(){
		//contractEvents = new List<EUR_CRM_Contract_Product_Item__c>();
	}
	
	public List<ContractEventWrapper> getContractEvents(){
		List<ContractEventWrapper> conEvents = new List<ContractEventWrapper>();
		Set<Id> conActIds = new Set<Id>();
		Id eventsId;
		Map<Id, EUR_CRM_Contract_Activity_Item__c> conActItem = new Map<Id, EUR_CRM_Contract_Activity_Item__c>();
		
		for(EUR_CRM_Mechanic_Type__c mechType : [SELECT Id, Name FROM EUR_CRM_Mechanic_Type__c WHERE EUR_CRM_Country_Code__c = 'ZA']){
			if(mechType.Name == 'Events'){
				eventsId = mechType.Id;
			}
		}
		
		for(EUR_CRM_Contract_Activity_Item__c cAct : [SELECT Id,EUR_CRM_Mechanic_Type__c, EUR_CRM_Name__c, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c, EUR_CRM_Payment_Term__c 
														FROM EUR_CRM_Contract_Activity_Item__c WHERE EUR_CRM_Contract__c = :contractId]){
			if(cAct.EUR_CRM_Mechanic_Type__c == eventsId){
				conActIds.add(cAct.Id);
				conActItem.put(cAct.id, cAct);
			}
		}
		
		for(EUR_CRM_Contract_Product_Item__c cProd : [SELECT Id, EUR_CRM_Brand_Name__c, EUR_CRM_Marketing_Amount__c, EUR_CRM_Contract_Activity_Item__c FROM 
															EUR_CRM_Contract_Product_Item__c WHERE EUR_CRM_Contract_Activity_Item__c IN :conActIds]){
																
			conEvents.add(new ContractEventWrapper(cProd.EUR_CRM_Brand_Name__c, 
													conActItem.get(cProd.EUR_CRM_Contract_Activity_Item__c).EUR_CRM_Name__c, 
													cProd.EUR_CRM_Marketing_Amount__c,
													conActItem.get(cProd.EUR_CRM_Contract_Activity_Item__c).EUR_CRM_Start_Date__c, 
													conActItem.get(cProd.EUR_CRM_Contract_Activity_Item__c).EUR_CRM_End_Date__c, 
													conActItem.get(cProd.EUR_CRM_Contract_Activity_Item__c).EUR_CRM_Payment_Term__c));	
		}
		return conEvents;
	}
	
	public class ContractEventWrapper{
		public String brandName {get;set;}
		public String eventName {get;set;}
		public Decimal amount {get;set;}
		public Date startDate {get;set;}
		public Date endDate {get;set;}
		public String paymentTerms {get;set;}
		
		public ContractEventWrapper(String brandName, String eventName, Decimal amount, Date startDate, Date endDate, String paymentTerms){
			this.brandName = brandName;
			this.eventName = eventName;
			this.amount = amount;
			this.startDate = startDate;
			this.endDate = endDate;
			this.paymentTerms = paymentTerms;
		}
	}
}