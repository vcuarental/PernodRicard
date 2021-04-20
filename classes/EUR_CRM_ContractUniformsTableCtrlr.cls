public with sharing class EUR_CRM_ContractUniformsTableCtrlr {

	public String contractId {get;set;}
	//public List<EUR_CRM_Contract_Product_Item__c> contractEvents {get;set;}
	
	public EUR_CRM_ContractUniformsTableCtrlr(){
		//contractEvents = new List<EUR_CRM_Contract_Product_Item__c>();
	}
	
	public List<ContractUniformsWrapper> getContractUniforms(){
		List<ContractUniformsWrapper> conUniforms = new List<ContractUniformsWrapper>();
		Set<Id> conActIds = new Set<Id>();
		Id uniformsId;
		Map<Id, EUR_CRM_Contract_Activity_Item__c> conActItem = new Map<Id, EUR_CRM_Contract_Activity_Item__c>();
		
		for(EUR_CRM_Mechanic_Type__c mechType : [SELECT Id, Name FROM EUR_CRM_Mechanic_Type__c WHERE EUR_CRM_Country_Code__c = 'ZA']){
			if(mechType.Name == 'Uniforms'){
				uniformsId = mechType.Id;
			}
		}
		
		for(EUR_CRM_Contract_Activity_Item__c cAct : [SELECT Id,EUR_CRM_Mechanic_Type__c, EUR_CRM_Name__c, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c, EUR_CRM_Payment_Term__c 
														FROM EUR_CRM_Contract_Activity_Item__c WHERE EUR_CRM_Contract__c = :contractId]){
			if(cAct.EUR_CRM_Mechanic_Type__c == uniformsId){
				conActIds.add(cAct.Id);
				//conActItem.put(cAct.id, cAct);
			}
		}
		
		for(EUR_CRM_Contract_Product_Item__c cProd : [SELECT Id, EUR_CRM_Brand_Name__c, EUR_CRM_Marketing_Amount__c, EUR_CRM_Contract_Activity_Item__c FROM 
															EUR_CRM_Contract_Product_Item__c WHERE EUR_CRM_Contract_Activity_Item__c IN :conActIds]){
																
			conUniforms.add(new ContractUniformsWrapper(cProd.EUR_CRM_Brand_Name__c,
														cProd.EUR_CRM_Marketing_Amount__c));	
		}
		return conUniforms;
	}
	
	public class ContractUniformsWrapper{
		public String brandName {get;set;}
		public Decimal amount {get;set;}
		
		public ContractUniformsWrapper(String brandName, Decimal amount){
			this.brandName = brandName;
			this.amount = amount;
			
		}
	}
}