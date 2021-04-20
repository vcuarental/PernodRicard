/*********************************************************************************
 * Name: ASI_CRM_TW_CancelPlan_Ctrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 01/13/2017       Introv: Twinkle LI      Created
*********************************************************************************/

public without sharing class ASI_CRM_TW_CancelPlan_Ctrl {
    public boolean boolError { get; set; }
    public String planId { get; set; }
    public ASI_MFM_Plan__c plan { get; set; }
    public List<ASI_MFM_PO__c> listPO { get; set; }
    public List<PermissionSetAssignment> listCurrentUserPerSet { get; set; }
    
    public ASI_CRM_TW_CancelPlan_Ctrl (ApexPages.StandardController standardController){
        init();
        
        if(plan.ASI_MFM_Status__c == 'Cancel'){
            boolError = TRUE;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Plan is cencelled already.'));
        }
        if(listCurrentUserPerSet == null || listCurrentUserPerSet.size() <= 0){
            boolError = TRUE;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You are not authorized to perform this action.'));
        }
        else if(listPO != null && listPO.size() > 0){
            boolError = TRUE;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot cancel Plan with POs.'));
        }
    }
    
    public void init(){
        planId = ApexPages.currentPage().getParameters().get('id');
        plan = [SELECT ASI_MFM_Status__c FROM ASI_MFM_Plan__c WHERE id =: planId];
        
        listCurrentUserPerSet = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() 
                                 AND (PermissionSet.Name in ('ASI_CRM_TW_IT_Admin') OR 
                                 PermissionSet.Name in ('ASI_CRM_TW_Regional_Sales_Assist') OR
                                 PermissionSet.Name in ('ASI_CRM_TW_TMKT_Users'))];                                 
        listPO = [SELECT Id FROM ASI_MFM_PO__c WHERE ASI_MFM_Plan__c =: planId];
    }
    
    public PageReference cancelAction(){
        plan.ASI_MFM_Status__c = 'Cancel';
        
        try {
            update plan;
        }
        catch(DmlException  err){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,err.getMessage()));
            return null;
        }
        
        PageReference redirectPage = new PageReference('/' + planId);
        return redirectPage;
    }
    
    public PageReference redirectPage(){
        PageReference redirectPage = new PageReference('/' + planId);
        return redirectPage;
    }
}