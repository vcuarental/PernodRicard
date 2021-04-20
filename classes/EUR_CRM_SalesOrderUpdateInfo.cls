/*************************************************
* General purpose auto populatation of email fields in Sales Order (EU)
* Called Before Insert and Before Update
* Current email fields:
* EUR_CRM_Distributor_Email__c
* EUR_CRM_KD_CS_Email__c
* EUR_CRM_Wholesaler_Email__c
************************************************/

public with sharing class EUR_CRM_SalesOrderUpdateInfo extends EUR_CRM_TriggerAbstract{

	private static final String CLASS_NAME = 'EUR_CRM_SalesOrderUpdateInfo';
    private String KDEmailAddress;
    private Set<String> validCC_WholesalerEmail = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'validCC_WholesalerEmail');
    private Set<String> validCC_KDEmailAddress = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(CLASS_NAME, 'validCC_KDEmailAddress');
//    private Set<String> validCC_WholesalerEmail = new Set<String>{'BG'};

    public EUR_CRM_SalesOrderUpdateInfo() {
        super('EUR_CRM_SalesOrderUpdateInfo');
        
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<Id, sObject> newMap, Map<Id, sObject> oldMap) {
        // Retrieve the KD CS email from the User who created the SO
        if(Trigger.IsInsert){
            User currentUser = [SELECT EUR_CRM_KD_CS_Email__c FROM User WHERE Id = :UserInfo.getUserId()];
            if(currentUser != null) {
                KDEmailAddress = currentUser.EUR_CRM_KD_CS_Email__c;
            }
        }

		List<EUR_CRM_Sales_Order__c> salesOrderList = (List<EUR_CRM_Sales_Order__c>) sObjList;
		Set<Id> accountIds = new Set<Id>();
        Set<Id> csLinkIds  = new Set<Id>();
        Set<Id> wholesalerIds = new Set<Id>();

		for(EUR_CRM_Sales_Order__c so: salesOrderList) {
			accountIds.add(so.EUR_CRM_Distributor__c);
//            if(so.EUR_CRM_Country_Code__c == 'RU'){
            if(validCC_KDEmailAddress.contains(so.EUR_CRM_Country_Code__c)){
                csLinkIds.add(so.EUR_CRM_CIS_Link__c);
            }
            if(validCC_WholesalerEmail.contains(so.EUR_CRM_Country_Code__c)){
                wholesalerIds.add(so.EUR_CRM_Wholesaler__c);
            }
		}
		// Updates the distributor's Email from the distributor's record
		Map<Id, EUR_CRM_Account__c> distributorsMap = new Map<Id,EUR_CRM_Account__c>([SELECT Id, EUR_CRM_Email__c FROM EUR_CRM_Account__c WHERE Id IN : accountIds]);
		Map<Id, EUR_CRM_CISLink__c> csLinkMap = new Map<Id, EUR_CRM_CISLink__c>([SELECT Id, EUR_CRM_Distributor_Account__c, EUR_CRM_Distributor_Account__r.EUR_CRM_Email__c FROM EUR_CRM_CISLink__c WHERE Id IN : csLinkIds]);
        Map<Id, EUR_CRM_Account__c> wholesalerMap = new Map<Id, EUR_CRM_Account__c>([SELECT Id, EUR_CRM_Email__c FROM EUR_CRM_Account__c WHERE Id IN : wholesalerIds]);


        for(EUR_CRM_Sales_Order__c so : salesOrderList){
			try{
                // Populate the distributor email. 
                // For RU, the value is from the CIS Link
                if(validCC_KDEmailAddress.contains(so.EUR_CRM_Country_Code__c)){
                    if(csLinkMap.KeySet().contains(so.EUR_CRM_CIS_Link__c)){
                        so.EUR_CRM_Distributor_Email__c = csLinkMap.get(so.EUR_CRM_CIS_Link__c).EUR_CRM_Distributor_Account__r.EUR_CRM_Email__c;
                    }
                } else {
                    if(distributorsMap.KeySet().contains(so.EUR_CRM_Distributor__c)){
    				    so.EUR_CRM_Distributor_Email__c = distributorsMap.get(so.EUR_CRM_Distributor__c).EUR_CRM_Email__c;
                    }
                }

                // populate the wholesale email 
                if(validCC_WholesalerEmail.contains(so.EUR_CRM_Country_Code__c)){
                    if(wholesalerMap.KeySet().contains(so.EUR_CRM_Wholesaler__c)){
                        so.EUR_CRM_Wholesaler_Email__c = wholesalerMap.get(so.EUR_CRM_Wholesaler__c).EUR_CRM_Email__c;
                    }
                }

                // Populate KD CS email on insert
                if(KDEmailAddress != null){
                    so.EUR_CRM_KD_CS_Email__c = KDEmailAddress;
                }
			}
			catch (Exception e){
				continue;
			}
		}    	   	
    }
}