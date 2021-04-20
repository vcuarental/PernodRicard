public with sharing class ASI_HK_CRM_PAFItemParentSummaryUpdate extends ASI_HK_CRM_TriggerAbstract {
	
	public ASI_HK_CRM_PAFItemParentSummaryUpdate() {
		super('ASI_HK_CRM_PAFItemParentSummaryUpdate');
	}
	
	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		if ((tAction == TriggerAction.AFTER_INSERT || tAction == TriggerAction.AFTER_UPDATE
			|| tAction == TriggerAction.AFTER_DELETE || tAction == TriggerAction.AFTER_UNDELETE)
			&& !isBypassByCurrentUser()) {
			List<ASI_HK_CRM_Pre_Approval_Form_Item__c> pafItemList = (List<ASI_HK_CRM_Pre_Approval_Form_Item__c>)sObjList;
			
			Set<ID> updatedPAFHeaderIds = new Set<ID>();
			for (ASI_HK_CRM_Pre_Approval_Form_Item__c pafItem : pafItemList) {
				if (pafItem.ASI_HK_CRM_Pre_Approval_Form_Lookup__c != null) {
					updatedPAFHeaderIds.add(pafItem.ASI_HK_CRM_Pre_Approval_Form_Lookup__c);
				}
			}
			
			ASI_HK_CRM_PAFSummaryCalculator pafSummaryCalculator = new ASI_HK_CRM_PAFSummaryCalculator();
			List<ASI_HK_CRM_Pre_Approval_Form__c> parentPAFList = pafSummaryCalculator.getRefreshedPAF(updatedPAFHeaderIds);
			update parentPAFList;
		}
	}

}