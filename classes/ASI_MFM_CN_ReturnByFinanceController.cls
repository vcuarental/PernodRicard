public without sharing class ASI_MFM_CN_ReturnByFinanceController {
    public string poid {set;get;}
    public ASI_MFM_PO__c PO {set;get;}
    private static final String APPROVE_ACTION = 'Reject';
    private ProcessInstanceWorkitem soWorkitem;
    
    public ASI_MFM_CN_ReturnByFinanceController(ApexPages.StandardController con) {
        this.POId = con.getId();
        List<ASI_MFM_PO__c> poHeaders = [
          SELECT Id, ASI_MFM_CN_Return_Flag__c, ASI_MFM_Return_Comments__c,ASI_MFM_PO_Amount__c,  ASI_MFM_Return_Status__c, ASI_MFM_PO_Original_Amount__c
          FROM ASI_MFM_PO__c WHERE Id = :poid];
         if(poHeaders != null && poHeaders.size()>0){
            this.po = poHeaders[0];
         }
         this.soWorkitem = workitemFromRecordId(this.poid);
        
    }
    
    public PageReference cancel(){
        PageReference resultPage = new PageReference('/'+this.poid);
        return resultPage;
    }
    
    private Approval.ProcessWorkitemRequest approvalRequest() {
        Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
        if(this.soWorkitem != null){
            approvalReq.setWorkitemId(this.soWorkitem.Id);
            //------ edited by leo @2014/12/04 - change from '***BA/Finance Return*** ' to '***Return*** ' ------
            //approvalReq.setComments('***BA/Finance Return*** ' + this.po.ASI_MFM_Return_Comments__c);
            if(this.po.ASI_MFM_Return_Comments__c != null && this.po.ASI_MFM_Return_Comments__c != '')
                approvalReq.setComments('***Return*** ' + this.po.ASI_MFM_Return_Comments__c);
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
        PageReference resultPage = new PageReference('/'+this.poid);
        
        // Edited by Michael Yip (Introv) 18Jun2014 to put return comments in notification email
        //po.ASI_MFM_Return_Comments__c = '';                
        po.ASI_MFM_Return_Status__c = 'Pending by User';
        po.ASI_MFM_CN_Return_Flag__c = true;
        po.ASI_MFM_PO_Original_Amount__c = po.ASI_MFM_PO_Amount__c;
        try{
        update this.po;
        }
        catch (exception e){
            System.debug(e.getMessage());
        }
        system.debug(this.po);
        Approval.ProcessWorkitemRequest approvalReq = approvalRequest();
        if (approvalReq != null)
                        Approval.ProcessResult approvalResult = Approval.process(approvalReq);
        
        return resultPage;
    }
    
}