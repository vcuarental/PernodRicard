@isTest
private class ASI_MFM_CN_Repack_ApprovalCtrlTest {
    static testMethod void testMethod1() {

    	Id strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM');
        ASI_MFM_POSM_Return_Request__c rq = new ASI_MFM_POSM_Return_Request__c(
                recordtypeid = strRTId,
                ASI_MFM_Request_Status__c = 'Open',
                ASI_MFM_Return_Request_Date__c = Date.today(),
                ASI_MFM_Return_Request_Contact__c = 'Testing',
                ASI_MFM_Item_Code_Before_Repack2_Des__c = 'test2',
                ASI_MFM_Item_Code_Before_Repack3_Des__c = 'test3',
                ASI_MFM_Item_Code_Before_Repack4_Des__c = 'test4',
                ASI_MFM_Item_Code_Before_Repack5_Des__c = 'test5'
            );
        insert rq;
         Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setComments('automated approval');
                request.setObjectId(rq.id);
                  
                Approval.ProcessResult result = Approval.process(request);
                System.debug(LoggingLevel.INFO,'提交审批结果：'+ result.isSuccess());
        ApexPages.StandardController sc = new ApexPages.StandardController(rq);
        ApexPages.currentPage().getParameters().put('id', rq.Id);

        ProcessInstance instance =[SELECT Id,TargetObject.Id, (SELECT Id,CreatedDate,Actor.Name, StepStatus,CreatedBy.name,OriginalActor.Name,ProcessNode.Name, Comments 
         FROM StepsAndWorkitems  order by ProcessNodeId desc) FROM ProcessInstance where TargetObject.Id =:rq.Id order by CreatedDate desc];
 
        System.debug(LoggingLevel.INFO, '*** instance: ' + instance);
        ASI_MFM_CN_Repack_ApprovalCtrl extens = new ASI_MFM_CN_Repack_ApprovalCtrl(sc);
        extens.dummyVar = false;
        extens.init();

         ASI_MFM_CN_Repack_ApprovalCtrl extens1 = new ASI_MFM_CN_Repack_ApprovalCtrl();

    }
}