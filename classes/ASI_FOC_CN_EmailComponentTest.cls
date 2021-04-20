@isTest
private class ASI_FOC_CN_EmailComponentTest {
    static testMethod void FOC_ApprovalRequestComponentTest() {
        user u = [select userRole.developerName, username from user where id = :userInfo.getUserId()];
        u.ASI_CN_NPL_Receive_Approval_Request__c = 'If I am an approver or delegated approver';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator GDT']; 
        user delU = [SELECT id,ASI_CN_NPL_Receive_Approval_Request__c,DelegatedApproverId from user where profileid = :p.id and isactive = true and id != :userInfo.getUserId() limit 1];
        u.DelegatedApproverId = delU.id;
        
        update u;
        
        System.runAs(u){
            System.debug('Run test as:' + u.username + ' ID: ' + u.id);
            
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
            insert po;
            
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'), ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='Open', ASI_FOC_Approver_1__c=u.id );
            insert fr;
            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true);
            insert ri;  
            
            apexpages.Standardcontroller sc = new apexpages.Standardcontroller(fr);
            ASI_FOC_CN_ApprovalRequestComponentCON c1 = new ASI_FOC_CN_ApprovalRequestComponentCON();
            ASI_FOC_CN_ApprovalRequestComponentCON cx = new ASI_FOC_CN_ApprovalRequestComponentCON(sc);
            cx.RIID = fr.id;
            cx.dummyVar = true;
            cx.init();            
        }
    }
    
    static testMethod void FOC_CancelQuantityComponentTest() {
        user u = [select userRole.developerName, username from user where id = :userInfo.getUserId()];
        u.ASI_CN_NPL_Receive_Approval_Request__c = 'If I am an approver or delegated approver';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator GDT']; 
        user delU = [SELECT id,ASI_CN_NPL_Receive_Approval_Request__c,DelegatedApproverId from user where profileid = :p.id and isactive = true and id != :userInfo.getUserId() limit 1];
        u.DelegatedApproverId = delU.id;
        
        update u;
        
        System.runAs(u){
            System.debug('Run test as:' + u.username + ' ID: ' + u.id);
            
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
            insert po;
            
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'), ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='Open', ASI_FOC_Approver_1__c=u.id );
            insert fr;
            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true);
            insert ri;  
            
            apexpages.Standardcontroller sc = new apexpages.Standardcontroller(ri);
            ASI_FOC_CN_CancelQtyEmailComponentCON c1 = new ASI_FOC_CN_CancelQtyEmailComponentCON();
            ASI_FOC_CN_CancelQtyEmailComponentCON cx = new ASI_FOC_CN_CancelQtyEmailComponentCON(sc);
            cx.RIID = ri.id;
            cx.dummyVar = true;
            cx.init();            
        }
    }
    
    static testMethod void FOC_RejectedComponentTest() {
        user u = [select userRole.developerName, username from user where id = :userInfo.getUserId()];
        u.ASI_CN_NPL_Receive_Approval_Request__c = 'If I am an approver or delegated approver';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator GDT']; 
        user delU = [SELECT id,ASI_CN_NPL_Receive_Approval_Request__c,DelegatedApproverId from user where profileid = :p.id and isactive = true and id != :userInfo.getUserId() limit 1];
        u.DelegatedApproverId = delU.id;
        
        update u;
        
        System.runAs(u){
            System.debug('Run test as:' + u.username + ' ID: ' + u.id);
            
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
            insert po;
            
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request'), ASI_FOC_Request_Type__c='Consumer A&P', ASI_FOC_PO__c=po.id, ASI_FOC_Request_Status__c='Open', ASI_FOC_Approver_1__c=u.id );
            insert fr;
            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true);
            insert ri;  
            
            apexpages.Standardcontroller sc = new apexpages.Standardcontroller(ri);
            ASI_FOC_CN_RejectEmailComponentCON c1 = new ASI_FOC_CN_RejectEmailComponentCON();
            ASI_FOC_CN_RejectEmailComponentCON cx = new ASI_FOC_CN_RejectEmailComponentCON(sc);
            cx.RIID = ri.id;
            cx.dummyVar = true;
            cx.init();            
        }
    }
}