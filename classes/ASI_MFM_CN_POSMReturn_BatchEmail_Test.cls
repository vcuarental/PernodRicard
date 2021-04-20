@isTest
private class ASI_MFM_CN_POSMReturn_BatchEmail_Test {
    public class TestObj {

        public List<User> lstUsr;
        public User user1;
        public User user2;
        public ASI_MFM_POSM_Return_Request__c tmpPOSMRequest;
        public ASI_MFM_POSM_Return_Request_Item__c tmpRequestItem;
        public List<ASI_MFM_POSM_Return_Request_Item__c> tmpLtRequestItem;

        public Id ORDER_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM_Return_Batch_Approval');
        public Id ITEM_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_MFM_POSM_Return_Request_Item__cASI_MFM_CN_POSM_Return_Request_Item_Batch_Approval');
       
        
        public TestObj(){
              lstUsr = new List<User>();
            User1 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'test99',BypassVR__c = true, BypassWF__c  = true, BypassTriggers__c  = 'Autofollow_User_InsertUpdate; AutoJoin_User_InsertUpdate; ChatterEmailSettings; ESNProjectTrigger; AP01; ASI_HK_CRM_SalesOrderAssignApprover; ASI_MFM_ValidateSubBrandCode; ASI_MFM_GF_LockPOLine; ASI_CRM_CN_AccountsCRMCodeAutoNumber; ASI_CRM_TW_AccountMovement_TgrHdlr; ASI_CRM_CN_AccountsAdditional_TriggerCls; ASI_CRM_CN_ContractPONoAutoNumber; ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr; ASI_CRM_CN_Contract_TriggerClass; ASI_MFM_TR_ByPassTrigger; ASI_MFM_KR_Cross_Fiscal_Year_Checking; Autofollow_User_InsertUpdate,AutoJoin_Us', ASI_MFM_Bypass_Callouts__c = true, email='test99' + '@dev.com', emailencodingkey='UTF-8', firstname='test99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='test99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
            User2 = new User(managerid = UserInfo.getUserId(), ASI_MFM_Team__c = 'ABCD', ASI_MFM_Country__c ='CN', alias = 'tes99',BypassVR__c = true, BypassWF__c  = true, BypassTriggers__c  = 'Autofollow_User_InsertUpdate; AutoJoin_User_InsertUpdate; ChatterEmailSettings; ESNProjectTrigger; AP01; ASI_HK_CRM_SalesOrderAssignApprover; ASI_MFM_ValidateSubBrandCode; ASI_MFM_GF_LockPOLine; ASI_CRM_CN_AccountsCRMCodeAutoNumber; ASI_CRM_TW_AccountMovement_TgrHdlr; ASI_CRM_CN_AccountsAdditional_TriggerCls; ASI_CRM_CN_ContractPONoAutoNumber; ASI_CRM_CN_GenPhPayeeLnItmNo_TgrHdlr; ASI_CRM_CN_Contract_TriggerClass; ASI_MFM_TR_ByPassTrigger; ASI_MFM_KR_Cross_Fiscal_Year_Checking; Autofollow_User_InsertUpdate,AutoJoin_Us',ASI_MFM_Bypass_Callouts__c = true, email='tes99' + '@dev.com', emailencodingkey='UTF-8', firstname='tes99', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='Europe/London', username='tes99' + '@pernod-ricard.com',ProfileId = UserInfo.getProfileId(), UserRoleId = UserInfo.getUserRoleId(), isActive=true);
            lstUsr.add(user1);
            lstUsr.add(user2);
            insert lstUsr;

            for(user u : [SELECT Id, Name, ManagerId,BypassVR__c,BypassWF__c,BypassTriggers__c, ASI_MFM_Bypass_Callouts__c, ASI_MFM_Country__c, UserRole.DeveloperName 
                          FROM User
                          WHERE id =: user1.id 
                          OR id =: user2.id
                          LIMIT 2]){
                              if(user1.id == u.id){
                                  user1 = u;
                              }else{
                                  user2 = u;
                              }
                          }
            System.runAs(user1){
                createPOSMRequest();
            }
        }

        private void createPOSMRequest() {
            tmpPOSMRequest = new ASI_MFM_POSM_Return_Request__c(
                recordtypeid =  ORDER_APPROVAL_ID,
                ASI_MFM_Return_Request_Date__c = Date.today(),
                ASI_MFM_Return_Request_Contact__c = 'Testing 0 Cancel',
                ASI_MFM_Request_Status__c = 'Open'
            ); 
            insert tmpPOSMRequest;    

            ASI_MFM_POSM_Return_Request__c fr = new ASI_MFM_POSM_Return_Request__c(
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request__cASI_MFM_CN_POSM'),
                ASI_MFM_Request_Status__c = 'Open',
                ASI_MFM_Return_Request_Date__c = Date.today(),
                ASI_MFM_Return_Request_Contact__c = 'Testing 1 Approve'
            );
            insert fr;
            tmpRequestItem = new ASI_MFM_POSM_Return_Request_Item__c(
                recordtypeid =  ITEM_APPROVAL_ID,
                ASI_MFM_Request_Order__c = tmpPOSMRequest.Id,
                ASI_MFM_Owner__c = user2.id,
                ASI_MFM_Approval_Status__c = 'Open',
                ASI_POSM_Return_Request_Approval_Header__c = tmpPOSMRequest.Id
            );
            insert tmpRequestItem;

            tmpLtRequestItem =new List<ASI_MFM_POSM_Return_Request_Item__c>();            
            ASI_MFM_POSM_Return_Request_Item__c ri = new ASI_MFM_POSM_Return_Request_Item__c(
                recordtypeid =  Global_RecordTypeCache.getRtId('ASI_MFM_POSM_Return_Request_Item__cASI_MFM_CN_POSM_Request_Item'),
                ASI_MFM_Request_Order__c = fr.Id,
                ASI_MFM_Owner__c = user2.id,
                ASI_MFM_Approval_Status__c = 'Open',
                ASI_MFM_POSM_Return_Reques_Approval_Item__c = tmpRequestItem.Id
            );
            
            tmpLtRequestItem.add(ri);            
            try{insert tmpLtRequestItem;}catch(Exception e){}

        }
    }

    static testMethod void testMethod1() {
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            Test.startTest();
            
            ASI_MFM_POSM_Return_Request__c oHeader = testObj.tmpPOSMRequest;
            
            ASI_MFM_CN_POSM_Batch_EmailCON ApprovalEmailPDFCON = new ASI_MFM_CN_POSM_Batch_EmailCON();
            ApprovalEmailPDFCON.currentHeaderID = oHeader.ID;
            
            Boolean initTest = ApprovalEmailPDFCON.init();
            
            Test.stopTest();
        }
    }

    static testMethod void testMethod2() {
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            Test.startTest();
            
            ASI_MFM_POSM_Return_Request_Item__c itHeader = testObj.tmpRequestItem;
            
            ASI_MFM_CN_POSMReturnItem_Batch_EmailCON ApprovalEmailPDFCON = new ASI_MFM_CN_POSMReturnItem_Batch_EmailCON();
            ApprovalEmailPDFCON.currentHeaderID = itHeader.ID;
            
            Boolean initTest = ApprovalEmailPDFCON.init();
            
            Test.stopTest();
        }
    }
}