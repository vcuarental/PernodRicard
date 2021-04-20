public with sharing class EUR_CRM_ContractPOSMaterialTableCtrlr {

	public String contractId {get;set;}
	//public List<EUR_CRM_Contract_Product_Item__c> contractEvents {get;set;}
	
	public EUR_CRM_ContractPOSMaterialTableCtrlr(){
		//contractEvents = new List<EUR_CRM_Contract_Product_Item__c>();
	}
	
	public List<ContractPOSWrapper> getContractPOSMaterials(){
		List<ContractPOSWrapper> conPOSMaterials = new List<ContractPOSWrapper>();
		Set<Id> conActIds = new Set<Id>();
		Id posMaterialId;
		Map<Id, EUR_CRM_Contract_Activity_Item__c> conActItem = new Map<Id, EUR_CRM_Contract_Activity_Item__c>();
		
		for(EUR_CRM_Mechanic_Type__c mechType : [SELECT Id, Name FROM EUR_CRM_Mechanic_Type__c WHERE EUR_CRM_Country_Code__c = 'ZA']){
			if(mechType.Name == 'POS material'){
				posMaterialId = mechType.Id;
			}
		}
		
		for(EUR_CRM_Contract_Activity_Item__c cAct : [SELECT Id,EUR_CRM_Mechanic_Type__c, EUR_CRM_Name__c, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c, EUR_CRM_Payment_Term__c 
														FROM EUR_CRM_Contract_Activity_Item__c WHERE EUR_CRM_Contract__c = :contractId]){
			if(cAct.EUR_CRM_Mechanic_Type__c == posMaterialId){
				conActIds.add(cAct.Id);
				//conActItem.put(cAct.id, cAct);
			}
		}
		
		for(EUR_CRM_Contract_Product_Item__c cProd : [SELECT Id, EUR_CRM_Brand_Name__c, EUR_CRM_Description__c, EUR_CRM_Marketing_Amount__c, EUR_CRM_Contract_Activity_Item__c FROM 
															EUR_CRM_Contract_Product_Item__c WHERE EUR_CRM_Contract_Activity_Item__c IN :conActIds]){
																
			conPOSMaterials.add(new ContractPOSWrapper(cProd.EUR_CRM_Brand_Name__c, 
												    	cProd.EUR_CRM_Description__c,
														cProd.EUR_CRM_Marketing_Amount__c));	
		}
		return conPOSMaterials;
	}
	
	public class ContractPOSWrapper{
		public String brandName {get;set;}
		public String description {get;set;}
		public Decimal amount {get;set;}
		
		public ContractPOSWrapper(String brandName, String description, Decimal amount){
			this.brandName = brandName;
			this.description = description;
			this.amount = amount;
		}
	}
}