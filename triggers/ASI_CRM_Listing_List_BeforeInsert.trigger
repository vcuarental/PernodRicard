/*********************************************************************************
 * Name:ASI_CRM_Listing_List_BeforeInsert
 * Description: Listing List object Before Insert
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 15/12/2014       Laputa: Conrad          Created
*********************************************************************************/
trigger ASI_CRM_Listing_List_BeforeInsert on ASI_CRM_Listing_List__c (before insert) {

    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
    if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Listing_List')) {
        ASI_CRM_JP_triggerClasses.add(new ASI_CRM_JP_ListingList_Validate());
    }

    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }        

}