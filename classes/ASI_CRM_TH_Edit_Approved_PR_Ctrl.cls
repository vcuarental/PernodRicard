/*********************************************************************************
 * Name: ASI_CRM_TH_PromotionCalendarCommonClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/05/2016       Introv: Twinkle LI      Created
*********************************************************************************/

public without sharing class ASI_CRM_TH_Edit_Approved_PR_Ctrl {
    public boolean boolError { get; set; }
    public ASI_TH_CRM_PaymentRequest__c pr { get; set; }
    public List<PermissionSetAssignment> listCurrentUserPerSet { get; set; }
    public String prId { get; set; }
    
    public ASI_CRM_TH_Edit_Approved_PR_Ctrl (ApexPages.StandardController standardController){
        init();
        if(pr.ASI_TH_CRM_Status__c == 'Approved'){
            if(listCurrentUserPerSet == null || listCurrentUserPerSet.size() <= 0){
                boolError = TRUE;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You are not authorized to perform this action.'));
            }
        }
        else{
            boolError = TRUE;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Only Approved Payment Request can be rejected.'));
        }
    }
    
    public void init(){
        prId = ApexPages.currentPage().getParameters().get('id');
        pr = [SELECT ASI_TH_CRM_Status__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id =: prId];
        
        listCurrentUserPerSet = [SELECT Id FROM PermissionSetAssignment
                                 WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'ASI_CRM_TH_Reject_Payment_Request'];
        system.debug('listCurrentUserPerSet: ' + listCurrentUserPerSet);    
    }
    
    public PageReference rejectAction(){
        pr.ASI_TH_CRM_Status__c = 'Rejected';
        update pr;
        
        PageReference redirectPage = new PageReference('/' + prId);
        return redirectPage;
    }
    
    public PageReference redirectPage(){
        PageReference redirectPage = new PageReference('/' + prId);
        return redirectPage;
    }
}