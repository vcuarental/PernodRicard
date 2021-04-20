trigger ASI_GiftBox_RequestHeaderBeforeUpdate on ASI_GiftBox_Request_Header__c (before update) {
	//20190520 Wilken: Limit Gift Box trigger class to be executed by Gift Box Request data only
	if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_GiftBox_VN_Request')){
		ASI_GiftBox_RequestHeaderTriggerClass.routineBeforeUpdate(trigger.new);
	}
}