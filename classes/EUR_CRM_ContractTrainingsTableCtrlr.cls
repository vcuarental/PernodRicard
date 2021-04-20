public with sharing class EUR_CRM_ContractTrainingsTableCtrlr {

	public String contractId {get;set;}
	//public List<EUR_CRM_Contract_Product_Item__c> contractEvents {get;set;}
	
	public EUR_CRM_ContractTrainingsTableCtrlr(){
		//contractEvents = new List<EUR_CRM_Contract_Product_Item__c>();
	}
	
	public List<ContractTrainingsWrapper> getContractTrainings(){
		List<ContractTrainingsWrapper> conTrainings = new List<ContractTrainingsWrapper>();
		Set<Id> conActIds = new Set<Id>();
		Id trainingsId;
		Map<Id, EUR_CRM_Contract_Activity_Item__c> conActItem = new Map<Id, EUR_CRM_Contract_Activity_Item__c>();
		
		for(EUR_CRM_Mechanic_Type__c mechType : [SELECT Id, Name FROM EUR_CRM_Mechanic_Type__c WHERE EUR_CRM_Country_Code__c = 'ZA']){
			if(mechType.Name == 'Trainings'){
				trainingsId = mechType.Id;
			}
		}
		
		for(EUR_CRM_Contract_Activity_Item__c cAct : [SELECT Id,EUR_CRM_Mechanic_Type__c,EUR_CRM_Mechanic__c, EUR_CRM_Mechanic__r.Name, EUR_CRM_Name__c,
														EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c, EUR_CRM_Payment_Term__c 
														FROM EUR_CRM_Contract_Activity_Item__c WHERE EUR_CRM_Contract__c = :contractId]){
			if(cAct.EUR_CRM_Mechanic_Type__c == trainingsId){
				conActIds.add(cAct.Id);
				conActItem.put(cAct.id, cAct);
			}
		}
		
		for(EUR_CRM_Contract_Product_Item__c cProd : [SELECT Id, EUR_CRM_Brand_Name__c, EUR_CRM_No_of_People__c, EUR_CRM_Contract_Activity_Item__c FROM 
															EUR_CRM_Contract_Product_Item__c WHERE EUR_CRM_Contract_Activity_Item__c IN :conActIds]){
																
			conTrainings.add(new ContractTrainingsWrapper(conActItem.get(cProd.EUR_CRM_Contract_Activity_Item__c).EUR_CRM_Mechanic__r.Name, 
													cProd.EUR_CRM_No_of_People__c));	
		}
		return conTrainings;
	}
	
	public class ContractTrainingsWrapper{
		public String trainingName {get;set;}
		public Decimal numOfPeople {get;set;}
		
		
		public ContractTrainingsWrapper(String trainingName, Decimal numOfPeople){
			this.trainingName = trainingName;
			this.numOfPeople = numOfPeople;
			
		}
	}
}