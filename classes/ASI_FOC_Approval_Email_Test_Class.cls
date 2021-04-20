@isTest(SeeAllData=true)
private class ASI_FOC_Approval_Email_Test_Class {
    
    static testMethod void testFOCApprovalEmailWithBD() {
        user u = [select userRole.developerName, username from user where id = :userInfo.getUserId()];
        u.ASI_CN_NPL_Receive_Approval_Request__c = 'If I am an approver or delegated approver';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator GDT']; 
        user delU = [SELECT id,ASI_CN_NPL_Receive_Approval_Request__c,DelegatedApproverId from user where profileid = :p.id and isactive = true and id != :userInfo.getUserId() limit 1];
        u.DelegatedApproverId = delU.id;
        
        update u;
        
        System.runAs(u){
            System.debug('Run test as:' + u.username + ' ID: ' + u.id);
            
            ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
            insert rt;
            
            ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=u.id);
            insert rc;  
            
            ASI_FOC_Route_Criteria__c debugrc = [select ASI_FOC_Approver__c, ASI_FOC_Threshold__c from ASI_FOC_Route_Criteria__c where ASI_FOC_Approver__c = :u.id limit 1];
            
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
            insert po;
            
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'), ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='Open', ASI_FOC_Approver_1__c=u.id );
            insert fr;
            
            apexpages.Standardcontroller sc = new apexpages.Standardcontroller(fr);
            ASI_FOC_SubmitRequestController cx = new ASI_FOC_SubmitRequestController(sc);
            cx.goBack();
            cx.submitRequest();
            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true);
            insert ri;  
            
            fr = [select ASI_FOC_Request_Status__c,recordTypeId, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
            sc = new apexpages.Standardcontroller(fr);
            cx = new ASI_FOC_SubmitRequestController(sc);
            cx.submitRequest();
            
            ri.ASI_FOC_Brand_Approver__c = u.id;
            update ri;        
            fr = [select ASI_FOC_Request_Status__c,recordTypeId, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
            sc = new apexpages.Standardcontroller(fr);
            cx = new ASI_FOC_SubmitRequestController(sc);        
            cx.submitRequest();         
        }
    }
    
    static testMethod void testFOCApprovalEmailNoBD() {
        user u = [select userRole.developerName, username from user where id = :userInfo.getUserId()];
        u.ASI_CN_NPL_Receive_Approval_Request__c = 'If I am an approver or delegated approver';
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator GDT' limit 1 ]; 
        user delU = [SELECT id,ASI_CN_NPL_Receive_Approval_Request__c,DelegatedApproverId from user where profileid = :p.id and isactive = true and id != :userInfo.getUserId() limit 1];
        u.DelegatedApproverId = delU.id;
        
        update u;
        
        System.runAs(u){
            System.debug('Run test as:' + u.username + ' ID: ' + u.id);
            ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
            insert rt;
            
            ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=u.id);
            insert rc;  
            
            ASI_FOC_Route_Criteria__c debugrc = [select ASI_FOC_Approver__c, ASI_FOC_Threshold__c from ASI_FOC_Route_Criteria__c where ASI_FOC_Approver__c = :u.id limit 1];
            
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
            insert po;
            
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'), ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='Open', ASI_FOC_Approver_1__c=u.id );
            insert fr;
            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=false);
            insert ri;  
            
            fr = [select RecordTypeId, ASI_FOC_Request_Status__c, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
            apexpages.Standardcontroller sc = new apexpages.Standardcontroller(fr);
            ASI_FOC_SubmitRequestController cx = new ASI_FOC_SubmitRequestController(sc);
            cx.goBack();
            cx.submitRequest();
        }
    }
    
    static testMethod void testFOCApprovalError() {
        user u = [select userRole.developerName, username from user where id = :userInfo.getUserId()];
        u.ASI_CN_NPL_Receive_Approval_Request__c = 'If I am an approver or delegated approver';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator GDT']; 
        user delU = [SELECT id,ASI_CN_NPL_Receive_Approval_Request__c,DelegatedApproverId from user where profileid = :p.id and isactive = true and id != :userInfo.getUserId() limit 1];
        u.DelegatedApproverId = delU.id;
        
        update u;
        
        System.runAs(u){
            System.debug('Run test as:' + u.username + ' ID: ' + u.id);
            ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
            insert rt;
            
            ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=u.id);
            insert rc;  
            
            ASI_FOC_Route_Criteria__c debugrc = [select ASI_FOC_Approver__c, ASI_FOC_Threshold__c from ASI_FOC_Route_Criteria__c where ASI_FOC_Approver__c = :u.id limit 1];
            
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
            insert po;
            
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'), ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='Submitted', ASI_FOC_Approver_1__c=u.id );
            insert fr;
            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=1000, ASI_FOC_Brand_Director_Approval_Required__c=false);
            insert ri;  
			Test.startTest();
        	System.debug(Limits.getDMLRows());            
            fr = [select ASI_FOC_Request_Status__c, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
            apexpages.Standardcontroller sc = new apexpages.Standardcontroller(fr);
            ASI_FOC_SubmitRequestController cx = new ASI_FOC_SubmitRequestController(sc);
            ri.ASI_FOC_Free_Good_Cost__c = 300000;
            ri.ASI_FOC_Request_Quantity_Bottle__c=10;
            update ri;
            cx.goBack();
            cx.submitRequest();
            ri.ASI_FOC_Free_Good_Cost__c = 1;
            ri.ASI_FOC_Request_Quantity_Bottle__c=1;
            update ri;
            cx.goBack();
            cx.submitRequest();
            fr.ASI_FOC_Request_Status__c='Open';
            update fr;
            cx.goBack();
            cx.submitRequest();
            Test.stopTest();
        }
    }
    
    static testMethod void testFOCApprovalError2() {
        user u = [select userRole.developerName, username from user where id = :userInfo.getUserId()];
        u.ASI_CN_NPL_Receive_Approval_Request__c = 'If I am an approver or delegated approver';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator GDT']; 
        user delU = [SELECT id,ASI_CN_NPL_Receive_Approval_Request__c,DelegatedApproverId from user where profileid = :p.id and isactive = true and id != :userInfo.getUserId() limit 1];
        u.DelegatedApproverId = delU.id;
        
        update u;
        
        System.runAs(u){
            System.debug('Run test as:' + u.username + ' ID: ' + u.id);
            ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName, ASI_FOC_Logistic_Approver__c = u.id);
            insert rt;
            
            ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=u.id);
            insert rc;  
            
            ASI_FOC_Route_Criteria__c debugrc = [select ASI_FOC_Approver__c, ASI_FOC_Threshold__c from ASI_FOC_Route_Criteria__c where ASI_FOC_Approver__c = :u.id limit 1];
            
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
            insert po;
            
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'), ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='Completed', ASI_FOC_Approver_1__c=u.id );
            insert fr;
            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=false);
            insert ri;  
            
            fr = [select ASI_FOC_Request_Status__c, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
            apexpages.Standardcontroller sc = new apexpages.Standardcontroller(fr);
            ASI_FOC_SubmitRequestController cx = new ASI_FOC_SubmitRequestController(sc);
            cx.goBack();
            cx.submitRequest();
        }
    }
    
    static testMethod void testFOCApprovalNormal() {
        user u = [select userRole.developerName, username from user where id = :userInfo.getUserId()];
        u.ASI_CN_NPL_Receive_Approval_Request__c = 'If I am an approver or delegated approver';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator GDT']; 
        user delU = [SELECT id,ASI_CN_NPL_Receive_Approval_Request__c,DelegatedApproverId from user where profileid = :p.id and isactive = true and id != :userInfo.getUserId() limit 1];
        u.DelegatedApproverId = delU.id;
        
        update u;
        
        System.runAs(u){
            System.debug('Run test as:' + u.username + ' ID: ' + u.id);
            ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName, ASI_FOC_Logistic_Approver__c = u.id);
            insert rt;
            
            ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=u.id);
            insert rc;  
            
            ASI_FOC_Route_Criteria__c debugrc = [select ASI_FOC_Approver__c, ASI_FOC_Threshold__c from ASI_FOC_Route_Criteria__c where ASI_FOC_Approver__c = :u.id limit 1];
            
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
            insert po;
            
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'), ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='Open', ASI_FOC_Approver_1__c=u.id );
            insert fr;
            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=false);
            insert ri;  
            
            fr = [select ASI_FOC_Request_Status__c,recordTypeId, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, ASI_FOC_Budget_Amount__c, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
            apexpages.Standardcontroller sc = new apexpages.Standardcontroller(fr);
            ASI_FOC_SubmitRequestController cx = new ASI_FOC_SubmitRequestController(sc);
            cx.goBack();
            cx.confirm();
            cx.submitRequest();
        }
    }
    
    static testMethod void testFOCApprovalNormal2() {
        user u = [select userRole.developerName, username from user where id = :userInfo.getUserId()];
        u.ASI_CN_NPL_Receive_Approval_Request__c = 'If I am an approver or delegated approver';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator GDT']; 
        user delU = [SELECT id,ASI_CN_NPL_Receive_Approval_Request__c,DelegatedApproverId from user where profileid = :p.id and isactive = true and id != :userInfo.getUserId() limit 1];
        u.DelegatedApproverId = delU.id;
        
        update u;
        
        System.runAs(u){
            System.debug('Run test as:' + u.username + ' ID: ' + u.id);
            ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName, ASI_FOC_Logistic_Approver__c = u.id);
            insert rt;
            
            ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=u.id);
            insert rc;  
            
            ASI_FOC_Route_Criteria__c debugrc = [select ASI_FOC_Approver__c, ASI_FOC_Threshold__c from ASI_FOC_Route_Criteria__c where ASI_FOC_Approver__c = :u.id limit 1];
            
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=100000000, ASI_FOC_Date__c=date.today());
            insert po;
            
            final Integer numOfSKU = 5;
            List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
            ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
            for (Integer i = 0; i < numOfSKU; i++) {
                skuList.add(skuGen.generateSKU(null));
            }
            insert skuList;
            
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'), ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='Open', ASI_FOC_Approver_1__c=u.id );
            insert fr;
            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=90000, ASI_FOC_Brand_Director_Approval_Required__c=false, ASI_FOC_Request_Quantity_Bottle__c = 1000);
            insert ri;  
            
            fr = [select ASI_FOC_Request_Status__c, ASI_FOC_Sys_Submitted__c, ASI_FOC_PO_Remaining_Amount__c, ASI_FOC_Budget_Amount__c, recordtypeid, ASI_FOC_Approver_1__c from ASI_FOC_Free_Goods_Request__c where id = :fr.id];
            apexpages.Standardcontroller sc = new apexpages.Standardcontroller(fr);
            ASI_FOC_SubmitRequestController cx = new ASI_FOC_SubmitRequestController(sc);
            cx.goBack();
            cx.submitRequest();
        }
    }
}