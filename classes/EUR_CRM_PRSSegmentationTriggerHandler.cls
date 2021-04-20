public with sharing class EUR_CRM_PRSSegmentationTriggerHandler extends EUR_CRM_TriggerHandler{

	override public void beforeInsert(){
		new EUR_CRM_PRSSegmentationToAccHandler().onBeforeInsert(Trigger.new);
	}
	override public void afterInsert() {
		new EUR_CRM_PRSSegmentationToAccHandler().updateAccountPros(Trigger.new);
	}

	override public void beforeUpdate() {
		new EUR_CRM_PRSSegmentationToAccHandler().updatePriorityLevelCriteria(Trigger.new, (Map<Id, EUR_CRM_PRS_Segmentation__c>) Trigger.oldMap);
	}

	override public void afterUpdate(){
		new EUR_CRM_PRSSegmentationToAccHandler().updateAccountPros(Trigger.new, (Map<Id, EUR_CRM_PRS_Segmentation__c>) Trigger.oldMap);
		new EUR_CRM_DynGroupMemberChildHandler().onAfterUpdate(Trigger.new,Trigger.oldMap);
	}
	override public void afterDelete(){
		new EUR_CRM_DynGroupMemberChildHandler().onAfterDelete(Trigger.new);
	}
	override public void afterUndelete(){
		new EUR_CRM_DynGroupMemberChildHandler().onAfterUndelete(Trigger.new);
	}
}