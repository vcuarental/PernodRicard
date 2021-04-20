@isTest
private class ASI_FOC_CN_FreeRequestItemCancelTest {
    static testMethod void testMethod1() {



        String CART_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM');
        String CART_ITEM_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_POSM_Request_Item');
        List<ASI_FOC_Free_Goods_Request__c> reqList = new List<ASI_FOC_Free_Goods_Request__c>();
        
        ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(
                                    ASI_MFM_ForPOSMCart__c = TRUE, ASI_FOC_Sys_Submitted__c = True, 
                                    ASI_FOC_Sys_Approved_By_Logistic__c = True, ASI_FOC_Request_Status__c = 'Cancelled', 
                                    ASI_FOC_Request_Type__c='Logistic Cost', 
                                    ASI_FOC_Batch_Import_KEY__c='123',
                                    recordtypeid = CART_ID);
        insert fr;
        
        List<ASI_FOC_Request_Item__c> reqItemList = new List<ASI_FOC_Request_Item__c>();
        reqItemList.add(new ASI_FOC_Request_Item__c(
                recordTypeId=CART_ITEM_ID,ASI_FOC_Batch_Import_KEY__c='123',ASI_FOC_Request_Order__c = fr.Id,
                ASI_FOC_Brand_Director_Approval_Required__c = true,ASI_FOC_Brand_Approver__c = System.UserInfo.getUserId()
            ));
        insert reqItemList;
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
		req1.setObjectId(reqItemList[0].Id);
		//req1.setSubmitterId(UserInfo.getUserId());
		Approval.ProcessResult result = Approval.process(req1);


    	Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        Database.executebatch(new ASI_FOC_CN_FreeRequestItemCancelBatch());    
     }
}