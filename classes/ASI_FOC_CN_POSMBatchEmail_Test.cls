@isTest
private class ASI_FOC_CN_POSMBatchEmail_Test {

	public class TestObj {

        public List<User> lstUsr;
        public User user1;
        public User user2;
        public ASI_FOC_Free_Goods_Request__c tmpPOSMRequest;
        public ASI_FOC_Request_Item__c tmpRequestItem;
        public List<ASI_FOC_Request_Item__c> tmpLtRequestItem;
       
        
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
        	tmpPOSMRequest = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Status__c = 'Approved by Logistic'
                                                                                    , ASI_FOC_Request_Type__c='POSM'
                                                                                    , ASI_FOC_Description__c='POSM'
                                                                                    , ASI_FOC_Batch_Import_KEY__c = 'Test1234'
                                                                                    , recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_CN_POSM_Batch_Approval'));
            insert tmpPOSMRequest;            
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_POSM_Request_Approval__c = tmpPOSMRequest.Id,ASI_MFM_ForPOSMCart__c = TRUE, ASI_FOC_Sys_Submitted__c = True, ASI_FOC_Sys_Approved_By_Logistic__c = True, ASI_FOC_Request_Status__c = 'Approved by Logistic', ASI_FOC_Request_Type__c='Logistic Cost', recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM'));
            insert fr;
            tmpRequestItem = new ASI_FOC_Request_Item__c(  ASI_FOC_Brand_Director_Approval_Status__c = 'Open'
                                                                                    , ASI_FOC_Request_Order__c=fr.id
                                                                                    , ASI_FOC_POSM_Request_Approval__c = tmpPOSMRequest.Id
                                                                                    , ASI_FOC_Batch_Import_KEY__c = 'Test12345'                                                                                       
                                                                                    , recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_CRM_CN_POSM_Request_Item_Batch_Approval'));
            insert tmpRequestItem;
            tmpLtRequestItem =new List<ASI_FOC_Request_Item__c>();            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_MFM_Request_Item_Approval__c=tmpRequestItem.Id , ASI_FOC_Brand_Director_Approval_Status__c = 'Approved', ASI_FOC_ETL_Complete__c = false, ASI_FOC_Request_Order__c=fr.id,  ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'));
            
            tmpLtRequestItem.add(ri);            
            try{insert tmpLtRequestItem;}catch(Exception e){}

        }
    }

    static testMethod void testMethod1() {
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            Test.startTest();
            
            ASI_FOC_Free_Goods_Request__c oHeader = testObj.tmpPOSMRequest;
            
            ASI_FOC_CN_POSM_BatchEmailCON ApprovalEmailPDFCON = new ASI_FOC_CN_POSM_BatchEmailCON();
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
            
            ASI_FOC_Request_Item__c itHeader = testObj.tmpRequestItem;
            
            ASI_FOC_CN_POSM_Item_BatchEmailCON ApprovalEmailPDFCON = new ASI_FOC_CN_POSM_Item_BatchEmailCON();
            ApprovalEmailPDFCON.currentHeaderID = itHeader.ID;
            
            Boolean initTest = ApprovalEmailPDFCON.init();
            
            Test.stopTest();
        }
    }
}