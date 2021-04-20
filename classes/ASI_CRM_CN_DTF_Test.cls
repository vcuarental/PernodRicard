@isTest
public class ASI_CRM_CN_DTF_Test
{
    public class TestObj {

        public List<User> lstUsr;
        public User user1;
        public User user2;
        
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
                createDUA();
            }
        }
        
        private void createDUA() {
            //create fix approval route
            Id oRTId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route');
            ASI_CRM_Fix_Approval_Route__c oAppRoute = new ASI_CRM_Fix_Approval_Route__c(RecordTypeId=oRTId, ASI_CRM_CN_Type__c='Data Usage Application', ASI_CRM_CN_Region_Area_Channel__c='EC Tmall', ASI_CRM_CN_Approver_1__c=user2.id, ASI_CRM_CN_Approver_2__c=user2.id);
            insert oAppRoute;
        }
	}

    static testMethod void testTriggerClass()
    {
        List<User> tempUsers = ASI_TnE_KR_TestClassHelper.createTestUser(); //user list
        ASI_CRM_DTF__c dtf = new ASI_CRM_DTF__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_DTF__cASI_CRM_CN_DTF_Standard'), 
                                                ASI_CRM_CN_Project_Name__c = 'Test', 
                                                ASI_CRM_CN_Status__c = 'Draft', 
                                                ASI_CRM_CN_Planned_Launch_Date__c=Date.TODAY(), 
                                                ASI_CRM_CN_Project_Duration__c = 'One off', 
                                                ASI_CRM_CN_Duration_Detail__c = 'Test', 
                                                ASI_CRM_CN_Elements_of_backgroundContext__c = 'Test', 
                                                ASI_CRM_CN_Idea_Description__c = 'Test', 
                                                ASI_CRM_CN_ObjectivesAchievements__c = 'Test', 
                                                ASI_CRM_CN_Require_Support__c = 'Test', 
                                                ASI_CRM_CN_Data_Capture_Mechanism__c = 'Test', 
                                                ASI_CRM_CN_Measurements__c = 'Test', 
                                                ASI_CRM_CN_Website__c = TRUE, 
                                                ASI_CRM_CN_Improve_Awareness_Affinity__c = TRUE, 
                                                ASI_CRM_CN_autoApprove__c = FALSE);
        
        /*Group pg = new Group(Name = 'ASI CRM CN DTF Approver Group', 
                             DeveloperName = 'ASI_CRM_CN_DTF_Approver_Group');
        insert pg;
        List<GroupMember> GMlist = new List<GroupMember>();
        GroupMember GM = new GroupMember();
        GM.GroupId = pg.Id;
        GM.UserOrGroupId = tempUsers[0].Id;
        GMList.add(GM);
        insert GMList;*/
        
        Test.startTest();
        insert dtf;
        /*
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(dtf.Id);
        Approval.process(req1);
		*/
        dtf.ASI_CRM_CN_autoApprove__c = TRUE;
        dtf.ASI_CRM_CN_Status__c = 'Submitted';
        update dtf;
        Test.stopTest();
    }//end test method: testTriggerClass
    
    static testMethod void testTriggerClass_DUA() {
        TestObj testObj = new TestObj();
        
        User User1 = testObj.user1;
        System.runAs(user1){
            Test.startTest();
            
            Id oRTId = Global_RecordTypeCache.getRtId('ASI_CRM_DTF__cASI_CRM_CN_Data_Usage_Application');
            ASI_CRM_DTF__c oDTF = new ASI_CRM_DTF__c(recordTypeId = oRTId,
                                                    	ASI_CRM_Channel__c = 'EC Tmall',
                                                      	ASI_CRM_PII_Status__c = 'Inactive'
            );
            
            insert oDTF;
            
            oDTF.ASI_CRM_PII_Status__c = 'Active';
            update oDTF;
            
            Test.stopTest();
        }
    }
    
}//end class: ASI_CRM_CN_DTF_Test