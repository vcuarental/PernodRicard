/*********************************************************************************
 * Name:ASI_CRM_JP_CreateTnEController
 * Description: Controller to create tnE for Call Details
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 01/12/2014       Laputa: Hank          Created
*********************************************************************************/        
public with sharing class ASI_CRM_JP_CreateTnEController{ 
    public ASI_CRM_JP_CreateTnEController(ApexPages.StandardSetController stdSetController) {
        strIds = ApexPages.currentPage().getParameters().get('recs').split(',',-2);
        selectedDetails = [Select Id, ASI_CRM_Actual_Amount__c,ASI_CRM_Tax_Routing__c,ASI_CRM_Tax_Routing__r.ASI_JP_TnE_Expense_Category__c, ASI_CRM_Total_Number_of_Attendees__c, ASI_CRM_JP_All_Attendees__c, ASI_CRM_Visit_Date_Formula__c, ASI_CRM_Customer__r.Name, ASI_CRM_Call_Plan__r.Id, ASI_CRM_Call_Plan__r.ASI_CRM_TnE_Number__r.Id From ASI_CRM_Call_Detail__c Where Id In :strIds ];
        plan.id = selectedDetails.get(0).ASI_CRM_Call_Plan__r.Id;
        plan.ASI_CRM_TnE_Number__c = selectedDetails.get(0).ASI_CRM_Call_Plan__r.ASI_CRM_TnE_Number__r.Id;
    }
    
    public PageReference save(){
        TnEHeader = [Select Id, ASI_TnE_Due_Date_Mapping__r.ASI_JP_TnE_Period_To__c From ASI_TnE_ClaimHeader__c Where Id = :plan.ASI_CRM_TnE_Number__c];
        for (ASI_CRM_Call_Detail__c detail:selectedDetails) {
            ASI_TnE_ClaimDetail__c TnEDetail= new ASI_TnE_ClaimDetail__c();
            TnEDetail.ASI_TnE_ClaimHeader__c = TnEHeader.Id;
            TnEDetail.ASI_TnE_Expense_Category__c = detail.ASI_CRM_Tax_Routing__r.ASI_JP_TnE_Expense_Category__c;
            TnEDetail.ASI_TnE_Expense_Classification__c = detail.ASI_CRM_Tax_Routing__c;
            TnEDetail.ASI_TnE_Receipt_Date__c = TnEHeader.ASI_TnE_Due_Date_Mapping__r.ASI_JP_TnE_Period_To__c;
            TnEDetail.ASI_TnE_Receipt_Amount__c = detail.ASI_CRM_Actual_Amount__c;
            TnEDetail.ASI_TnE_Total_Number_Pax__c = detail.ASI_CRM_Total_Number_of_Attendees__c;
            TnEDetail.ASI_TnE_Attendee_Name__c = detail.ASI_CRM_JP_All_Attendees__c;
            TnEDetail.ASI_TnE_Details_of_Expense__c = ((datetime)detail.ASI_CRM_Visit_Date_Formula__c).format('yyyy-MM-dd') + ' ' + detail.ASI_CRM_Customer__r.Name;
            TnEDetail.recordtypeid = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimDetail__cASI_JP_TnE_Claim_Detail');
            TnEDetailsMap.put(detail.Id, TnEDetail);
        }
        
        insert TnEDetailsMap.Values();
        
        for (ASI_CRM_Call_Detail__c detail:selectedDetails) {
            detail.ASI_CRM_Status__c = 'TnE Created';
            detail.ASI_CRM_Sys_Call_Plan_TnE__c = null;
            detail.ASI_CRM_TnE_Detail_No__c = TnEDetailsMap.get(detail.Id).Id;
        }
        update selectedDetails;
        PageReference planPage = new ApexPages.StandardController(plan).view();
        planPage.setRedirect(true);
        return planPage;
        
    }  
    
    private List<String> strIds = new List<String>();
    private ASI_TnE_ClaimHeader__c TnEHeader = new ASI_TnE_ClaimHeader__c();
    private Map<Id, ASI_TnE_ClaimDetail__c> TnEDetailsMap = new Map<Id, ASI_TnE_ClaimDetail__c>();
    private List<ASI_CRM_Call_Detail__c> selectedDetails = new List<ASI_CRM_Call_Detail__c>();
    private ASI_CRM_Call_Plan__c plan = new ASI_CRM_Call_Plan__c();
}