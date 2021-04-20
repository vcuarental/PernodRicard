public without sharing class ASI_CRM_CN_ReturnContractByBACtrl {
    public string contractId {set;get;}
    public ASI_TH_CRM_Contract__c contract {set;get;}
    private static final String APPROVE_ACTION = 'Reject';
    private ProcessInstanceWorkitem soWorkitem;
    
    public ASI_CRM_CN_ReturnContractByBACtrl (ApexPages.StandardController con) {
       
        this.contractId = con.getId();
        
        List<ASI_TH_CRM_Contract__c> contractHeaders = [SELECT Id, ASI_CRM_CN_Return_Flag__c, ASI_CRM_Branch__c,
            ASI_CRM_CN_Return_Comments__c, ASI_CRM_CN_Return_Status__c, ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Return_Amount__c  
            FROM ASI_TH_CRM_Contract__c WHERE Id = :contractId];
            
        if(contractHeaders != null && contractHeaders.size()>0){
            this.contract = contractHeaders[0];
        }
        this.soWorkitem = workitemFromRecordId(this.contractId);        
    }

    public PageReference cancel(){
        PageReference resultPage = new PageReference('/'+this.contractId);
        return resultPage;
    }
    
    private Approval.ProcessWorkitemRequest approvalRequest() {
        Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
        if(this.soWorkitem != null){
            approvalReq.setWorkitemId(this.soWorkitem.Id);
            approvalReq.setComments(this.contract.ASI_CRM_CN_Return_Comments__c);
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
        PageReference resultPage = new PageReference('/'+this.contractId);
        Approval.ProcessWorkitemRequest approvalReq = approvalRequest();

        //contract.ASI_CRM_CN_Return_Comments__c = '';
        contract.ASI_CRM_CN_Return_Status__c = 'Pending by User';
        contract.ASI_CRM_CN_Return_Flag__c = true;
        contract.ASI_CRM_Branch__c = 'returned';
        contract.ASI_CRM_CN_Return_Amount__c = contract.ASI_CRM_CN_Total_Contract_Amount__c;
        //payment.ASI_MFM_CN_Payment_Original_Amount__c= payment.ASI_MFM_Payment_Amount__c;

        try{
            update this.contract;
            //Ben.fong@elufasys.com 2015-06-29
            if (approvalReq != null)
                Approval.ProcessResult approvalResult = Approval.process(approvalReq);
            contract.ASI_CRM_CN_Return_Comments__c = 'Returned-'  + contract.ASI_CRM_CN_Return_Comments__c;
            contract.ASI_CRM_Branch__c = '';
            update this.contract;
            //End 2015-06-29
        }
        catch (exception e){
            System.debug(e.getMessage());
        }
        return resultPage;
    }
}