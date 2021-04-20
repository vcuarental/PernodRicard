public without sharing class ASI_HK_CRM_SalesOrderRecallController {

    private static final String STATUS_AFTER_RECALL = 'Draft';
    private static final Set<String> STATUS_ALLOW_RECALL = new Set<String> {
        'Submitted'
    };
    public ID soId { get; private set; }
    
    public ASI_HK_CRM_SalesOrderRecallController(ApexPages.StandardController stdCon) {
        System.debug('kde1');
        this.soId = stdCon.getId();
    }
    
    public PageReference doRecall() {
        PageReference redirectPage = null;
        if (soId != null) {
            System.debug('kde2');
            ASI_HK_CRM_Sales_Order__c so = [SELECT Id, OwnerId, ASI_HK_CRM_Order_Status_Name__c FROM ASI_HK_CRM_Sales_Order__c WHERE Id = : soId];
            if (UserInfo.getUserId() != so.OwnerId) {
                System.debug('kde3');
                showPageError('You are not the owner of this record');
            } else if (!STATUS_ALLOW_RECALL.contains(so.ASI_HK_CRM_Order_Status_Name__c)) {
                System.debug('kde4');
                showPageError('The current approval stage cannot be recalled');
            } else {
                ProcessInstanceWorkitem workitem = workitemFromRecordId(soId);
                System.debug('kde5');
                if (workitem != null) {
                    System.debug('kde6');
                    Approval.ProcessWorkitemRequest recallReq = new Approval.ProcessWorkitemRequest();
                    recallReq.setWorkitemId(workitem.Id);
                    recallReq.setAction('Removed');
                    so.ASI_HK_CRM_Order_Status_Name__c = STATUS_AFTER_RECALL;
                    System.Savepoint sp = database.setSavepoint();
                    try {
                        System.debug('kde7');
                        update so;
                        Approval.ProcessResult recallResult = Approval.process(recallReq);
                        redirectPage = new PageReference('/' + soId);
                    } catch (Exception e) {
                        database.rollback(sp);
                        showPageError(e.getMessage());
                    }
                } else {
                    showPageError('No approval process is running');
                }
            }
        } else {
            showPageError('Invalid ID');
        }
        return redirectPage;
    }
    
    private ProcessInstanceWorkitem workitemFromRecordId(ID recordId) {
        if (recordId == null) return null;
        List<ProcessInstanceWorkitem> workitems = [SELECT Id, ActorId FROM ProcessInstanceWorkitem 
        WHERE ProcessInstance.TargetObjectId = :recordId];
        if(workitems.size() > 0){
            return workitems[0];} else {return null;}
    }
    
    private void showPageMessage(ApexPages.Severity severity, String msg) { ApexPages.addMessage(new ApexPages.Message(severity, msg)); }
    private void showPageError(String msg) { showPageMessage(ApexPages.Severity.ERROR, msg); }

}