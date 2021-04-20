public without sharing class ASI_CRM_SG_Edit_Approved_PR_Ctrl {
    public boolean boolError { get; set; }
    public ASI_TH_CRM_PaymentRequest__c pr { get; set; }
    public List<PermissionSetAssignment> listCurrentUserPerSet { get; set; }
    public String prId { get; set; }
	public String rejectComment { get; set; }
    
    public ASI_CRM_SG_Edit_Approved_PR_Ctrl (ApexPages.StandardController standardController){
        init();
        if(pr.ASI_TH_CRM_Status__c == 'Approved'){
            if(listCurrentUserPerSet == null || listCurrentUserPerSet.size() <= 0){
                boolError = TRUE;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You are not authorized to perform this action.'));
            }
			else if (pr.ASI_CRM_Sync_to_JDE__c == true){
                boolError = TRUE;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Payment Request has already been interfaced to JDE. Please contact IT for data patching.'));
            }
        }
        else{
            boolError = TRUE;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Only Approved Payment Request can be rejected.'));
        }
    }
    
    public void init(){
        prId = ApexPages.currentPage().getParameters().get('id');
        pr = [SELECT ASI_TH_CRM_Status__c, ASI_CRM_Reject_Return_Comments__c, ASI_CRM_Sync_to_JDE__c, ASI_CRM_SG_Finance_Verified__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id =: prId];
        
        
        listCurrentUserPerSet = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'ASI_CRM_SG_Finance_User'];                                
                                    


        system.debug('listCurrentUserPerSet: ' + listCurrentUserPerSet);    
    }
    
    public PageReference rejectAction(){
        pr.ASI_TH_CRM_Status__c = 'Rejected';
        pr.ASI_CRM_Reject_Return_Comments__c = rejectComment;
		pr.ASI_CRM_SG_Finance_Verified__c = false;
		
        try {
            update pr;
        }
        catch(DmlException  err){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,err.getMessage()));
            return null;
        }
        
        PageReference redirectPage = new PageReference('/' + prId);
        return redirectPage;
    }
    
    public PageReference redirectPage(){
        PageReference redirectPage = new PageReference('/' + prId);
        return redirectPage;
    }	
}