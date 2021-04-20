public without sharing class ASI_CRM_CN_ReturnPaymentByBACtrl{
    public string paymentId {set;get;}
    public ASI_TH_CRM_PaymentRequest__c payment {set;get;}
    private static final String APPROVE_ACTION = 'Reject';
    private ProcessInstanceWorkitem soWorkitem;
    
    public ASI_CRM_CN_ReturnPaymentByBACtrl (ApexPages.StandardController con) {
       
        this.paymentId = con.getId();
        
        List<ASI_TH_CRM_PaymentRequest__c> paymentcontractHeaders = [SELECT Id, ASI_CRM_CN_Return_Flag__c, ASI_CRM_Branch__c,
            ASI_CRM_CN_Return_Comments__c, ASI_CRM_CN_Return_Status__c, ASI_CRM_CN_Total_Payment__c, ASI_CRM_CN_Return_Amount__c 
            FROM ASI_TH_CRM_PaymentRequest__c WHERE Id = :paymentId];
            
        if(paymentcontractHeaders != null && paymentcontractHeaders.size()>0){
            this.payment = paymentcontractHeaders[0];
        }
        this.soWorkitem = workitemFromRecordId(this.paymentId);        
    }

    public PageReference cancel(){
        PageReference resultPage = new PageReference('/'+this.paymentId);
        return resultPage;
    }
    
    private Approval.ProcessWorkitemRequest approvalRequest() {
        Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
        if(this.soWorkitem != null){
            approvalReq.setWorkitemId(this.soWorkitem.Id);
            approvalReq.setComments(this.payment.ASI_CRM_CN_Return_Comments__c);
            approvalReq.setAction(APPROVE_ACTION);
        }
        else 
            return null;
        return approvalReq;
    }
    
    private ProcessInstanceWorkitem workitemFromRecordId(ID recordId) {
        if (recordId == null) return null;
        List<ProcessInstanceWorkitem> workitems = [SELECT Id, ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :recordId];
        return (workitems.size() > 0) ? workitems[0] : null;
    }
    
    public PageReference doApprove() {
        PageReference resultPage = new PageReference('/'+this.paymentId);
        Approval.ProcessWorkitemRequest approvalReq = approvalRequest();
        
        //payment.ASI_CRM_CN_Return_Comments__c = ''; //20160415
        payment.ASI_CRM_CN_Return_Status__c = 'Pending by User';
        payment.ASI_CRM_CN_Return_Flag__c = true;
        payment.ASI_CRM_Branch__c = 'returned';
        payment.ASI_CRM_CN_Return_Amount__c = payment.ASI_CRM_CN_Total_Payment__c;
        //payment.ASI_MFM_CN_Payment_Original_Amount__c= payment.ASI_MFM_Payment_Amount__c;

        try{
            update this.payment;
            //Ben.fong@elufasys.com 2015-06-29
            if (approvalReq != null)
                Approval.ProcessResult approvalResult = Approval.process(approvalReq);
            payment.ASI_CRM_CN_Return_Comments__c = 'Returned-'  + payment.ASI_CRM_CN_Return_Comments__c;
            payment.ASI_CRM_Branch__c = '';
            update this.payment;
            //End 2015-06-29
        }
        catch (exception e){
            System.debug(e.getMessage());
        }
        return resultPage;
    }
}