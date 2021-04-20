public without sharing class ASI_MFM_CAP_PaymentAssignApprover {
    
    public ID paymentID {get;set;}
    
    public ASI_MFM_CAP_PaymentAssignApprover ()
    {
        this.paymentID = apexpages.currentpage().getparameters().get('id');
    }
    
    public ASI_MFM_CAP_PaymentAssignApprover (ApexPages.StandardController controller)
    {
        this.paymentID = apexpages.currentpage().getparameters().get('id');
    }

    public pageReference updateApprover() {
        try {
            ASI_MFM_Payment__c payment = [SELECT ID, Name, ownerid, ASI_MFM_Sys_Approver_1__c 
                                            FROM ASI_MFM_Payment__c WHERE ID = : paymentID limit 1];
            if (payment != null)
            {
                if (payment.ownerid != userinfo.getuserid())
                {
                    payment.ASI_MFM_Sys_Approver_1__c = payment.ownerid;
                }
                payment.ASI_MFM_Approved__c = true;
                update payment;
            }
        }
        catch (QueryException e) {
            PageReference ref = new pagereference('/' + paymentID);
            ref.setRedirect(true);
            return ref;
        }
                
        PageReference ref = new pagereference('/apex/ASI_SubmitApprovalPage?id='+paymentID);
        ref.setRedirect(true);
        return ref;
        
   }

}