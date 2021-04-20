/* History                          Desc                          Log #                Status        Deployment State
 * -------------------------------------------------------------------------------------------------------------------
 * 2015-05-20 Alan Wong (Elufa)     Create     					  cn-sfdc-event-003    Developed
*/
trigger ASI_MFM_Event_BeforeInsert on ASI_MFM_Event__c (before insert) {
	if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_MFM_CN')){
        ASI_MFM_CN_Event_TriggerCls.routineBeforeInsert(trigger.new);
    }  
}