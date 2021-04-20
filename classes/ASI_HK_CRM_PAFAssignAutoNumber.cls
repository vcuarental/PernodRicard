public with sharing class ASI_HK_CRM_PAFAssignAutoNumber extends ASI_HK_CRM_TriggerAbstract {
	
	public ASI_HK_CRM_PAFAssignAutoNumber() {
		super('ASI_HK_CRM_PAFAssignAutoNumber');
	}
	
	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		if ((tAction == TriggerAction.BEFORE_INSERT)
			&& !isBypassByCurrentUser()) {
			List<ASI_HK_CRM_Pre_Approval_Form__c> pafList = (List<ASI_HK_CRM_Pre_Approval_Form__c>)sObjList;
			ASI_HK_CRM_AutoNumberAssignment autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_HK_CRM_Pre_Approval_Form__c');
			for (ASI_HK_CRM_Pre_Approval_Form__c paf : pafList) {
				paf.Name = autoNumAssign.nextAutoNumStr();
			}
			autoNumAssign.writeToDB();
		}
	}

}