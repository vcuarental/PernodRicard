public without sharing class ASI_MFM_CN_ReturnPaymentByFinanceCtrl {

    public string paymentId {set;get;}
    public ASI_MFM_Payment__c payment {set;get;}
    private static final String APPROVE_ACTION = 'Reject';
    private ProcessInstanceWorkitem soWorkitem;
    
    public ASI_MFM_CN_ReturnPaymentByFinanceCtrl(ApexPages.StandardController con) {
       
        this.paymentId = con.getId();
        
        List<ASI_MFM_Payment__c> paymentHeaders = [SELECT Id, ASI_MFM_CN_Return_Flag__c, 
            ASI_MFM_CN_Return_Comments__c, ASI_MFM_CN_Return_Status__c, ASI_MFM_Payment_Amount__c,
            ASI_MFM_CN_Payment_Original_Amount__c 
            FROM ASI_MFM_Payment__c WHERE Id = :paymentId];
            
        if(paymentHeaders != null && paymentHeaders.size()>0){
            this.payment = paymentHeaders[0];
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
            //------ edited by leo @2014/12/04 - change from '***BA/Finance Return*** ' to '***Return*** ' ------
            //approvalReq.setComments('***BA/Finance Return*** ' + this.Payment.ASI_MFM_CN_Return_Comments__c);
            if(this.Payment.ASI_MFM_CN_Return_Comments__c != null && this.Payment.ASI_MFM_CN_Return_Comments__c != '')
                approvalReq.setComments('***Return*** ' + this.Payment.ASI_MFM_CN_Return_Comments__c);
            else
                approvalReq.setComments('***Return***');
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
        //20160902
        payment.ASI_MFM_CN_Return_Flag__c = true;
        try{
            update this.payment;
        }
        catch (exception e){
            System.debug(e.getMessage());
        }
        //20160902
        if (approvalReq != null)
                        Approval.ProcessResult approvalResult = Approval.process(approvalReq);
        payment.ASI_MFM_CN_Return_Comments__c = '';                
        payment.ASI_MFM_CN_Return_Status__c = 'Pending by User';
        payment.ASI_MFM_CN_Return_Flag__c = true;
        payment.ASI_MFM_CN_Payment_Original_Amount__c= payment.ASI_MFM_Payment_Amount__c;
        //system.debug(po.ASI_MFM_PO_Original_Amount__c);
        try{
            update this.payment;
        }
        catch (exception e){
            System.debug(e.getMessage());
        }
        return resultPage;
    }


}