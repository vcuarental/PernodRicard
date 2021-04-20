/*********************************************************************************
 * Name:ASI_CRM_JP_SetCallPlanDraftController
 * Description: Change the Call Plan recordtype back for editing
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -------------------------------------
 * 31/07/2015       Laputa: Hank            Created
*********************************************************************************/
public without sharing class ASI_CRM_JP_SetCallPlanDraftController{
    private ASI_CRM_Call_Plan__c plan;
    public ASI_CRM_JP_SetCallPlanDraftController(ApexPages.StandardController controller){
        plan = (ASI_CRM_Call_Plan__c)controller.getRecord();
        plan = [Select recordtypeId From ASI_CRM_Call_Plan__c Where Id = :plan.Id];
    }
    public PageReference save(){
        plan.recordtypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Call_Plan__cASI_CRM_JP_Call_Plan');
        update plan;
        PageReference planPage = new ApexPages.StandardController(plan).view();
        planPage.setRedirect(true);
        return planPage;
    }
}