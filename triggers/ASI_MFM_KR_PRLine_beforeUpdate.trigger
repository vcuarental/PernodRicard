trigger ASI_MFM_KR_PRLine_beforeUpdate on ASI_MFM_Purchase_Request_Line__c (before update)
{
	ASI_MFM_KR_PRLine_TriggerClass.beforeUpdateMethod(Trigger.New);
}//end trigger