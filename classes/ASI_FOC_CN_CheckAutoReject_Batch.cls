/*
 * 20200319:AM - batch job to replace time-based workflow "ASI_FOC_CN_Auto_Reject"
 * *** some FOC records failed to reject automatically after 5 days and it does not allow to monitor time-based workflow on production
*/ 

Global class ASI_FOC_CN_CheckAutoReject_Batch implements Database.Batchable<sObject>, Database.Stateful{

    Private Static Final Id CN_FOC_RT_CN_POSM = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM');
    Private Static Final Id CN_FOC_RT_CN_POSM_RO = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM_Read_Only');
    Private Static Final Id CN_FOC_RT_CN_REJECT = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Request_and_Items_Read_Only');
    
    Private Static Final Set<String> CN_FOC_RT_SET = new Set<String>{
        Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request')
        , Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request_Read_Only')
        , CN_FOC_RT_CN_REJECT
        , CN_FOC_RT_CN_POSM
        , CN_FOC_RT_CN_POSM_RO
    };
        
	Private Static Final Set<String> CN_FOC_EX_Status_SET = new Set<String>{
        'Open','Rejected','Final','Completed','Cancelled','Approved','Draft','Rejected by System','Rejected by Finance'
    };

    Global Database.QueryLocator start(Database.BatchableContext BC){
        string sSQL = ' SELECT ID,RecordTypeId ' +
            			' FROM ASI_FOC_Free_Goods_Request__c ' + 
            			' WHERE RecordTypeId IN :CN_FOC_RT_SET ' +
            				' AND ASI_FOC_Request_Status__c NOT IN :CN_FOC_EX_Status_SET ' +
            				' AND ASI_FOC_SYS_Submitted_Time__c != NULL ' +

            				' AND ASI_FOC_SYS_Submitted_Time__c != LAST_N_DAYS:5 ' +
            				' AND ASI_FOC_SYS_Submitted_Time__c = LAST_N_DAYS:365 ' +

            				//' AND ASI_FOC_SYS_Submitted_Time__c = LAST_N_DAYS:5 ' +	//for test
            			' ORDER BY ASI_FOC_SYS_Submitted_Time__c ASC ';
        return Database.getQueryLocator(sSQL);
    }
    
    Global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ASI_FOC_Free_Goods_Request__c> ltOrgScope = (List<ASI_FOC_Free_Goods_Request__c>) scope;

        //copy from ASI_FOC_Free_Goods_Request_TriggerClass start
		Set<id> setHeader = new Set<id>();
        for(ASI_FOC_Free_Goods_Request__c oFOC : ltOrgScope) {
            setHeader.add(oFOC.id);
        }
        
        List<Id> ltWorkItemIds = new List<Id>();
        ltWorkItemIds = GetWorkItemIds(setHeader);
        RejectWorkItems(ltWorkItemIds);   
        
        List<ASI_FOC_Request_Item__c> ltItem = [SELECT Id,ASI_FOC_Brand_Director_Approval_Required__c, ASI_FOC_Brand_Director_Approval_Status__c FROM ASI_FOC_Request_Item__c
                                                 WHERE ASI_FOC_Request_Order__c IN :setHeader];

        Set<id> setItem = new Set<id>();
        for(ASI_FOC_Request_Item__c oItem : ltItem) {
            setItem.add(oItem.id);
        }
        ltWorkItemIds.clear();
        ltWorkItemIds = GetWorkItemIds(setItem);
        RejectWorkItems(ltWorkItemIds);
        //copy from ASI_FOC_Free_Goods_Request_TriggerClass end
        
        List<ASI_FOC_Free_Goods_Request__c> ltFOC_1st = new List<ASI_FOC_Free_Goods_Request__c>();
        List<ASI_FOC_Free_Goods_Request__c> ltFOC_2nd = new List<ASI_FOC_Free_Goods_Request__c>();
        for(ASI_FOC_Free_Goods_Request__c oFOC : ltOrgScope) {
            boolean bForPOSM = FALSE;
            id idRT_RO = CN_FOC_RT_CN_REJECT;
            if (oFOC.RecordTypeId == CN_FOC_RT_CN_POSM || oFOC.RecordTypeId == CN_FOC_RT_CN_POSM_RO) {
                bForPOSM = TRUE;
                idRT_RO = CN_FOC_RT_CN_POSM_RO;
            }
            
            ltFOC_1st.add(new ASI_FOC_Free_Goods_Request__c(
                Id=oFOC.Id,ASI_MFM_ForPOSMCart__c=bForPOSM,ASI_FOC_Sys_Approved_By_Finance__c=FALSE,ASI_FOC_Rejected_by_System__c=TRUE,ASI_FOC_Request_Status__c='Rejected by System',RecordTypeId=idRT_RO
            ));
            ltFOC_2nd.add(new ASI_FOC_Free_Goods_Request__c(
                Id=oFOC.Id,ASI_FOC_Sys_Approved_By_Finance__c=FALSE,RecordTypeId=idRT_RO
            ));
        }
        update ltFOC_1st;
        update ltFOC_2nd;
        
    }
    
    Global void finish(Database.BatchableContext BC){
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