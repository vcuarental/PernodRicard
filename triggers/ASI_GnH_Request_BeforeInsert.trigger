/****************************************************************************************************************************
 * Name:ASI_GnH_Request_BeforeInsert
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-06-22       Laputa: Hugo Cheung     Created
 * 2017-07-20		Laputa: Kevin Choi		Added KR Trigger Class:ASI_GnH_KR_Request_PopulateApprover
****************************************************************************************************************************/
trigger ASI_GnH_Request_BeforeInsert on ASI_GnH_Request__c (before insert) {

    List<ASI_GnH_Request_TriggerAbstract> processorList = new List<ASI_GnH_Request_TriggerAbstract>();
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_GnH_TW_Request')) {
        processorList.add(new ASI_GnH_Request_PopulateApprover());
    }
    //Added by Laputa 20-07-2017
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_GnH_KR')) {
        processorList.add(new ASI_GnH_KR_Request_checkApplicantEmpty());
        processorList.add(new ASI_GnH_KR_Request_PopulateApprover());
    }
	//End Added by Laputa 20-07-2017
    for(ASI_GnH_Request_TriggerAbstract processor : processorList) {

        processor.executeTriggerAction(ASI_GnH_Request_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);

    }
    
}