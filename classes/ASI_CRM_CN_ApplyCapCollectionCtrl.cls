public with sharing class ASI_CRM_CN_ApplyCapCollectionCtrl {

	private ASI_CRM_AccountsAdditionalField__c customer;

	public ASI_CRM_CN_ApplyCapCollectionCtrl(ApexPages.StandardController controller){
		customer = (ASI_CRM_AccountsAdditionalField__c)controller.getRecord();
	}
	
	public void init(){
		customer.ASI_CRM_CN_Send_Cap_Collection_Email__c = true;
		update customer;
	}

}