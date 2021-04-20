/*********************************************************************************
 * Name:ASI_CRM_SG_SalesOrder_TriggerHandler 
 * Description: Some field update logic for Sales Order    
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/03/2015       Laputa: Conrad          Created
 * 23/05/2017       Wilken Lee          	Added Delete Validation
*********************************************************************************/

public with sharing class ASI_CRM_SG_SalesOrder_TriggerHandler extends ASI_CRM_SG_TriggerAbstract {
    
    public ASI_CRM_SG_SalesOrder_TriggerHandler() {
        super('ASI_CRM_SG_SalesOrder_TriggerHandler');
    }
	
	public static void salesOrderBeforeDeleteValidation(List<ASI_KOR_Sales_Order_Request__c> soList){
		for (ASI_KOR_Sales_Order_Request__c so:soList){
			if (so.ASI_KOR_Order_Status__c != 'New')
				so.addError('Only new order can be deleted');
		}
	}
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<ASI_KOR_Sales_Order_Request__c> soList = (List<ASI_KOR_Sales_Order_Request__c>)sObjList;
        
        List<ASI_CRM_SG_Branch_Plant_Code_Mapping__c> branchPlantMapList = [SELECT ID, Name, Branch_Plant_Code__c FROM ASI_CRM_SG_Branch_Plant_Code_Mapping__c];
        Map<String, ASI_CRM_SG_Branch_Plant_Code_Mapping__c> branchPlantMap = new Map<String, ASI_CRM_SG_Branch_Plant_Code_Mapping__c>();
        
        for(ASI_CRM_SG_Branch_Plant_Code_Mapping__c branchCode : branchPlantMapList) {
            branchPlantMap.put(branchCode.name, branchCode);
        }
        system.debug('branchPlantMap ' + branchPlantMap);
        for(ASI_KOR_Sales_Order_Request__c so : soList) {
            if(so.ASI_CRM_SG_Ship_To__c == null) {
                so.ASI_CRM_SG_Ship_To__c = so.ASI_CRM_SG_Customer__c;
            }
            String soDeveloperName = Global_RecordTypeCache.getRt(so.recordTypeid).developerName;
            system.debug('soDeveloperName ' + soDeveloperName );
            if(branchPlantMap.containsKey(soDeveloperName)) {
                system.debug('branchPlantMap.get(soDeveloperName).Branch_Plant_Code__c ' + branchPlantMap.get(soDeveloperName).Branch_Plant_Code__c);
                so.ASI_KOR_Branch_Plant_code__c = branchPlantMap.get(soDeveloperName).Branch_Plant_Code__c;
            }
        }
    }
}