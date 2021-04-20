public with sharing class ASI_HK_CRM_SalesOrderAssignAutoNumber extends ASI_HK_CRM_TriggerAbstract {
	
	public ASI_HK_CRM_SalesOrderAssignAutoNumber() {
		super('ASI_HK_CRM_SalesOrderAssignAutoNumber');
	}
	
	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		if ((tAction == TriggerAction.BEFORE_INSERT)
			&& !isBypassByCurrentUser()) {
			List<ASI_HK_CRM_Sales_Order__c> soList = (List<ASI_HK_CRM_Sales_Order__c>)sObjList;
			ASI_HK_CRM_AutoNumberAssignment autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_HK_CRM_Sales_Order__c');
			for (ASI_HK_CRM_Sales_Order__c so : soList) {
				so.Name = autoNumAssign.nextAutoNumStr();
			}
			autoNumAssign.writeToDB();
		}
	}

}