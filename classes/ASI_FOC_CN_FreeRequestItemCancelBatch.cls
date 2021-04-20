/*****************************************************************************************************************
* Name:        ASI_FOC_CN_FreeRequestItemCancelBatch       
* Test Class:  ASI_FOC_CN_FreeRequestItemCancelBatch
* Description: Cancel
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    -----------------------------------------------------------------------------
* 2020-11-14       wangzhiqiang                  Create Class
*****************************************************************************************************************/
global class ASI_FOC_CN_FreeRequestItemCancelBatch implements Database.Batchable<sObject> {
    public String query;
    public static String STATUS_CANCEL = 'Cancelled';

    global ASI_FOC_CN_FreeRequestItemCancelBatch() {

        this.query = 'SELECT Id,ASI_FOC_Brand_Director_Approval_Status__c FROM ASI_FOC_Request_Item__c WHERE '+
                     'ASI_FOC_Brand_Director_Approval_Status__c !=:STATUS_CANCEL' +
                     ' AND ASI_FOC_Request_Order__r.ASI_FOC_Request_Status__c =:STATUS_CANCEL' +
                     ' AND RecordType.Name =\'CN POSM Request Item\'';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        
        List<ASI_FOC_Request_Item__c> repackList = (List<ASI_FOC_Request_Item__c>) scope;

        Set<Id> repackIdSet = new Set<Id>();
        for(ASI_FOC_Request_Item__c repack : repackList) {
            repackIdSet.add(repack.Id);
            repack.ASI_FOC_Brand_Director_Approval_Status__c = STATUS_CANCEL;
        }
        List<Id> ltWorkItemIds = new List<Id>();
        ltWorkItemIds = GetWorkItemIds(repackIdSet);
        RejectWorkItems(ltWorkItemIds);

        update repackList;
    }

    global void finish(Database.BatchableContext BC) {

    }

    @TestVisible
    private List<Id> GetWorkItemIds(Set<id> setId) {
        List<Id> ltWorkItemIds = new List<Id>();
        for (List<ProcessInstance> pis : [Select (Select Id From Workitems) From ProcessInstance p WHERE p.TargetObjectId IN :setId AND p.Status = 'Pending']) {
            for (ProcessInstance pi : pis) {
                for (List<ProcessInstanceWorkitem> wis : pi.Workitems) {
                    for (ProcessInstanceWorkitem wi : wis ) {
                        ltWorkItemIds.add(wi.id);
                    }
                }
            }
        }
        return ltWorkItemIds;
    }
    
    @TestVisible
    private void RejectWorkItems(List<Id> ltWorkItemIds) {
        List<Approval.ProcessWorkitemRequest> ltReq = new List<Approval.ProcessWorkitemRequest>();
        for (Id oId: ltWorkItemIds){
            Approval.ProcessWorkitemRequest oReq = new Approval.ProcessWorkitemRequest();
            oReq.setComments('Auto Cancelled');
            oReq.setAction('Removed'); 
            oReq.setWorkitemId(oId);
            ltReq.add(oReq);
        }
        if (ltReq.size()>0) List<Approval.ProcessResult> oResult = Approval.process(ltReq);
    }
}