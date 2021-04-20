/*********************************************************************************
 * Name: ASI_HK_CRM_VisitationPlanDetail_BeforeInsert
 * Description: Before insert for Visitation Plan
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 22/05/2017       Hugo Cheung             Created          
*/
trigger ASI_HK_CRM_VisitationPlanDetail_BeforeInsert on ASI_HK_CRM_Visitation_Plan_Detail__c (before insert) {
    if(trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_VN')) {
        new ASI_CRM_VN_VPDetailSetProductListing(trigger.new);
        new ASI_CRM_VN_VPDetailAssignDefaultSubBrand(trigger.new);
    }
    
    if(trigger.new[0].RecordTypeId != null && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_CRM_PH')) {
        ASI_CRM_PH_VisitationDetailTriggerCtrl.copyMenuListingAndPouringFromLatestVisitation(trigger.new);
    }
}