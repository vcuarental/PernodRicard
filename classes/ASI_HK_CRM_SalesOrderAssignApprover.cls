public with sharing class ASI_HK_CRM_SalesOrderAssignApprover extends ASI_HK_CRM_TriggerAbstract {

	public ASI_HK_CRM_SalesOrderAssignApprover() {
		super('ASI_HK_CRM_SalesOrderAssignApprover');
	}
	
	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE)
			&& !isBypassByCurrentUser()) {
			List<ASI_HK_CRM_Sales_Order__c> soList = (List<ASI_HK_CRM_Sales_Order__c>)sObjList;
			
			ASI_HK_CRM_ApproverAssignHelper approverAssignHelper = new ASI_HK_CRM_ApproverAssignHelper('ASI_HK_CRM_Sales_Order__c');
			approverAssignHelper.init();
			for (ASI_HK_CRM_Sales_Order__c so : soList) {
				approverAssignHelper.processRecord(so);
			}
		}
	}

}