global class ASI_MFM_CN_RepackCheckAutoRejectBatch implements Database.Batchable<sObject> {

    private static final Id REPACK_RT_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_Repack_Request_Form');
    private static final Id REPACK_RO_RT_ID = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_Repack_Request_Form_RO');
    private static final Set<String> RT_ID_SET = new Set<String>{REPACK_RT_ID,REPACK_RO_RT_ID};
    private static final Set<String> STATUS_SET = new Set<String>{'Submitted','In Progress'};

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String sSQL = ' SELECT Id,RecordTypeId,ASI_MFM_Request_Status__c ' +
                        ' FROM ASI_MFM_POSM_Return_Request__c ' + 
                        ' WHERE RecordTypeId IN :RT_ID_SET ' +
                            ' AND ASI_MFM_Request_Status__c IN :STATUS_SET ' +
                            ' AND ASI_MFM_Repack_SYS_Submitted_Time__c != NULL ' +
                            ' AND ASI_MFM_Repack_SYS_Submitted_Time__c != LAST_N_DAYS:5 ' +
                            ' AND ASI_MFM_Repack_SYS_Submitted_Time__c = LAST_N_DAYS:365 ' +
                        ' ORDER BY ASI_MFM_Repack_SYS_Submitted_Time__c ASC ';
        return Database.getQueryLocator(sSQL);
    }

    global void execute(Database.BatchableContext BC, list<Sobject> scope) {
        List<ASI_MFM_POSM_Return_Request__c> repackList = (List<ASI_MFM_POSM_Return_Request__c>) scope;

        Set<Id> repackIdSet = new Set<Id>();
        for(ASI_MFM_POSM_Return_Request__c repack : repackList) {
            repackIdSet.add(repack.Id);
            repack.ASI_MFM_Request_Status__c = 'Rejected by System';
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
            oReq.setComments('Rejected By System');
            oReq.setAction('Reject'); 
            oReq.setWorkitemId(oId);
            ltReq.add(oReq);
        }
        if (ltReq.size()>0) List<Approval.ProcessResult> oResult = Approval.process(ltReq);
    }
}