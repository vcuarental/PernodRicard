/*
* LAT_PromotionalActionMessageController
* Author: Martin Prado (martin@zimmic.com)
* Date: 07/30/2017
*/
public with sharing class LAT_PromotionalActionMessageController {

	private final LAT_PromotionalAction__c AP;
	public String messageText {get;set;}

	// Constructor
	public LAT_PromotionalActionMessageController(ApexPages.StandardController controller) {
		this.AP = (LAT_PromotionalAction__c)controller.getRecord();
		messageText = '';
		List<LAT_AccountInAction__c> accInAction = [SELECT Id, ClientNotAdhering__c FROM LAT_AccountInAction__c WHERE ClientNotAdhering__c = true AND LAT_PromotionalAction__c =: this.AP.id];
		if(accInAction.size()>0){
			messageText = 'Há clientes que não estão aderentes a Ação Promocional.';
			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.WARNING, messageText);
	   		ApexPages.addMessage(errorMsg);
		}


	}

}