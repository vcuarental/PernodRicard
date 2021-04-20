trigger ASI_KOR_ItemGroupDocument_AfterDelete on ASI_KOR_Item_Group_Document__c (after delete) {
	
	List<ASI_KOR_TriggerAbstract> triggerClasses = new List<ASI_KOR_TriggerAbstract> {
		new ASI_KOR_AttachDocDeleteChatterFile()
	};
	
	for (ASI_KOR_TriggerAbstract triggerClass : triggerClasses) {
		triggerClass.executeTriggerAction(ASI_KOR_TriggerAbstract.TriggerAction.AFTER_DELETE, trigger.old, null, trigger.oldMap);
	}
}