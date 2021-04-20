/***************************************************************************************************************************
 * Name:        ASI_HK_CRM_VisitationPlan_BeforeUpdate
 * Description: Apex class for ASI_HK_CRM_VisitationPlan_BeforeUpdate
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-19       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

trigger ASI_HK_CRM_VisitationPlan_BeforeUpdate on ASI_HK_CRM_Visitation_Plan__c (before update) {
    if (Trigger.new[0].recordtypeId != null && (Global_RecordTypeCache.getRt(Trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN_Visitation_Plan')) ){
        ASI_CRM_VN_VisitationPlan_TriggerClass.routineBeforeUpdate(Trigger.new);
    }
}