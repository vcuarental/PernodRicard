@isTest
public class EUR_CRM_DK_TestMassCreateFollowUpActions {
    public static User eurSysUser;

    static testMethod void setUser(){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
            UserRole r = [select id from UserRole where Developername ='EMEA'];
            eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
            EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
            insert eurSysUser;
        }
    }

    static testMethod void testON1(){
        System.Debug('@@@testON1>>');
        setUser();
        System.runAs(new User(Id = eurSysUser.Id)){
            
            //Insert Account
            Id accRTId = Global_RecordTypeCache.getRTId('EUR_CRM_Account__cEUR_DK_On_Trade');
            System.Debug('@@@Account RTId:' + accRTId);
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(RecordTypeId = accRTId,
                                                                Name = 'test', 
                                                                EUR_CRM_Status__c = 'Active',
                                                                OwnerId = eurSysUser.Id);
            System.Debug('@@@Insert account>>');
            insert account;
			System.Debug('@@@Insert account>>');
            
            EUR_CRM_Product_Toolkit__c productToolkit = new EUR_CRM_Product_Toolkit__c();
            productToolkit.Name = 'Testing';
            productToolkit.RecordTypeId = Global_RecordTypeCache.getRTId('EUR_CRM_Product_Toolkit__cEUR_DK_ON_Trade_Product_Toolkit');
            insert productToolkit;
			
			EUR_CRM_Product_Toolkit_Item__c productToolkitItem = new EUR_CRM_Product_Toolkit_Item__c();
            productToolkitItem.EUR_CRM_Product_Toolkit__c = productToolkit.Id;
            productToolkitItem.RecordTypeId = Global_RecordTypeCache.getRTId('EUR_CRM_Product_Toolkit_Item__cEUR_DK_ON_Trade_Product_Toolkit_Item');
            insert productToolkitItem;
            
            EUR_CRM_Visit_Action__c visitAction = new EUR_CRM_Visit_Action__c();
            visitAction.RecordTypeId = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_ON_Trade_Adhoc_Activate_Toolkit');
            visitAction.RecordType = Global_RecordTypeCache.getRTRec('EUR_CRM_Visit_Action__cEUR_DK_ON_Trade_Adhoc_Activate_Toolkit');
            visitAction.EUR_CRM_Active__c = true;
            visitAction.EUR_CRM_Activation_End_Date__c = Date.Today() - 1;
            visitAction.EUR_CRM_Product_Toolkit__c = productToolkit.Id;
            
            EUR_CRM_Visit_Action__c visitAction2 = new EUR_CRM_Visit_Action__c();
            visitAction2.RecordTypeId = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_OFF_Trade_Adhoc_Activate_Toolkit');
            visitAction2.RecordType = Global_RecordTypeCache.getRTRec('EUR_CRM_Visit_Action__cEUR_DK_OFF_Trade_Adhoc_Activate_Toolkit');
            visitAction2.EUR_CRM_Active__c = true;
            visitAction2.EUR_CRM_Activation_End_Date__c = Date.Today() - 1;
            visitAction2.EUR_CRM_Product_Toolkit__c = productToolkit.Id;
            
            EUR_CRM_Visit_Action__c visitAction3 = new EUR_CRM_Visit_Action__c();
            visitAction3.RecordTypeId = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_ON_Trade_Adhoc_Create_Indiv_Account_OP');
            visitAction3.RecordType = Global_RecordTypeCache.getRTRec('EUR_CRM_Visit_Action__cEUR_DK_ON_Trade_Adhoc_Create_Indiv_Account_OP');
            visitAction3.EUR_CRM_Active__c = true;
            visitAction3.EUR_CRM_Activation_End_Date__c = Date.Today() - 1;
            visitAction3.EUR_CRM_Product_Toolkit__c = productToolkit.Id;
            
            EUR_CRM_Visit_Action__c visitAction4 = new EUR_CRM_Visit_Action__c();
            visitAction4.RecordTypeId = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_OFF_Trade_Adhoc_Create_Indiv_Account_OP');
            visitAction4.RecordType = Global_RecordTypeCache.getRTRec('EUR_CRM_Visit_Action__cEUR_DK_OFF_Trade_Adhoc_Create_Indiv_Account_OP');
            visitAction4.EUR_CRM_Active__c = true;
            visitAction4.EUR_CRM_Activation_End_Date__c = Date.Today() - 1;
            visitAction4.EUR_CRM_Product_Toolkit__c = productToolkit.Id;
            
            System.Debug('@@@Insert visitAction>>');
            List<EUR_CRM_Visit_Action__c> visitActionList = new List<EUR_CRM_Visit_Action__c>();
            visitActionList.add(visitAction);
            visitActionList.add(visitAction2);
            visitActionList.add(visitAction3);
            visitActionList.add(visitAction4);
            insert visitActionList;
			System.Debug('@@@Insert visitAction<<');
            // Run the batch 
            // 
            System.Debug('@@@Batch Start>>');
            Test.startTest();
                Database.executeBatch(new EUR_CRM_DK_MassCreateFollowUpActions());
            Test.stopTest();
			System.Debug('@@@Batch End<<');
            // Asserts
            Id ON_TOOLKIT_FOLLOW_RT_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_ON_Trade_Adhoc_Activate_Toolkit_Follow_Up');
            System.Debug('@@@Follow Up Action RTID:' + ON_TOOLKIT_FOLLOW_RT_ID);
            account = [SELECT Id, OwnerId FROM EUR_CRM_Account__c WHERE Id =: account.Id];
            System.Debug('@@@Account Select:' + account);
            Map<Id, EUR_CRM_Visit_Action__c> visitActionsMap = new Map<Id, EUR_CRM_Visit_Action__c>([SELECT Id, RecordTypeId, RecordType.DeveloperName, EUR_CRM_Active__c, 
                                                                                                            EUR_CRM_Product_Toolkit__c, EUR_CRM_Account__c
                                                                                                     FROM EUR_CRM_Visit_Action__c
                                                                                                     WHERE EUR_CRM_Account__c =: account.Id]);
			System.Debug('@@@visitActionsMap:' + visitActionsMap);
            if(visitActionsMap.KeySet().size() > 0){
                for(EUR_CRM_Visit_Action__c visit : visitActionsMap.Values()){
                    if(visit.Id == visitAction.Id){
                        System.AssertEquals(visit.EUR_CRM_Active__c, false);
                    } else {
                        System.AssertEquals(visit.EUR_CRM_Active__c, true);
                        System.AssertEquals(visit.EUR_CRM_Account__c, account.Id);
                        System.AssertEquals(visit.RecordType.DeveloperName, ON_TOOLKIT_FOLLOW_RT_ID);
                    }
                }
            }           
        }
        System.Debug('@@@testON1<<');
    }

    static TestMethod void testON2(){
        System.Debug('@@@testON2>>');
        setUser();
        System.runAs(new User(Id = eurSysUser.Id)){
            
            //Insert Account
            Id accRTId = Global_RecordTypeCache.getRTId('EUR_CRM_Account__cEUR_DK_On_Trade');
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(RecordTypeId = accRTId,
                                                                Name = 'test', 
                                                                EUR_CRM_Status__c = 'Active',
                                                                EUR_CRM_Force_Image_Level__c = 'Iconic');
            insert account;
            
            account.EUR_CRM_Force_Image_Level__c = null;
            update account;

            EUR_CRM_Visit_Action__c visitAction = new EUR_CRM_Visit_Action__c();
            visitAction.RecordTypeId = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_ON_Trade_Adhoc_Create_Indiv_Account_OP');
            visitAction.RecordType = Global_RecordTypeCache.getRTRec('EUR_CRM_Visit_Action__cEUR_DK_ON_Trade_Adhoc_Create_Indiv_Account_OP');
            visitAction.EUR_CRM_Active__c = true;
            visitAction.EUR_CRM_Activation_End_Date__c = Date.Today() - 1;
            insert visitAction;

            // Run the batch 
            Test.startTest();
                Database.executeBatch(new EUR_CRM_DK_MassCreateFollowUpActions());
            Test.stopTest();

            // Asserts
            Id ON_INDIV_FOLLOW_RT_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_ON_Trade_Adhoc_Create_Indiv_Account_OP_Follow_Up');
            account = [SELECT Id, OwnerId FROM EUR_CRM_Account__c WHERE Id =: account.Id];
            Map<Id, EUR_CRM_Visit_Action__c> visitActionsMap = new Map<Id, EUR_CRM_Visit_Action__c>([SELECT Id, RecordTypeId, RecordType.DeveloperName, EUR_CRM_Active__c, 
                                                                                                            EUR_CRM_Product_Toolkit__c, EUR_CRM_Account__c
                                                                                                     FROM EUR_CRM_Visit_Action__c
                                                                                                     WHERE EUR_CRM_Account__c =: account.Id]);

            if(visitActionsMap.KeySet().size() > 0){
                for(EUR_CRM_Visit_Action__c visit : visitActionsMap.Values()){
                    if(visit.Id == visitAction.Id){
                        System.AssertEquals(visit.EUR_CRM_Active__c, false);
                    } else {
                        System.AssertEquals(visit.EUR_CRM_Active__c, true);
                        System.AssertEquals(visit.EUR_CRM_Account__c, account.Id);
                        System.AssertEquals(visit.RecordType.DeveloperName, ON_INDIV_FOLLOW_RT_ID);
                    }
                }
            }           
        }
        System.Debug('@@@testON2<<');
    }

    static void testOFF1(){
        System.Debug('@@@testOFF1>>');
        setUser();
        System.runAs(new User(Id = eurSysUser.Id)){
            
            //Insert Account
            Id accRTId = Global_RecordTypeCache.getRTId('EUR_CRM_Account__cEUR_DK_On_Trade');
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(RecordTypeId = accRTId,
                                                                Name = 'test', 
                                                                EUR_CRM_Status__c = 'Active');
            insert account;

            EUR_CRM_Visit_Action__c visitAction = new EUR_CRM_Visit_Action__c();
            visitAction.RecordTypeId = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_OFF_Trade_Adhoc_Activate_Toolkit');
            visitAction.RecordType = Global_RecordTypeCache.getRTRec('EUR_CRM_Visit_Action__cEUR_DK_OFF_Trade_Adhoc_Activate_Toolkit');
            visitAction.EUR_CRM_Active__c = true;
            visitAction.EUR_CRM_Activation_End_Date__c = Date.Today() - 1;
            insert visitAction;

            // Run the batch 
            Test.startTest();
                Database.executeBatch(new EUR_CRM_DK_MassCreateFollowUpActions());
            Test.stopTest();

            // Asserts
            Id OFF_TOOLKIT_FOLLOW_RT_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_OFF_Trade_Adhoc_Activate_Toolkit_Follow_Up');
            account = [SELECT Id, OwnerId FROM EUR_CRM_Account__c WHERE Id =: account.Id];
            Map<Id, EUR_CRM_Visit_Action__c> visitActionsMap = new Map<Id, EUR_CRM_Visit_Action__c>([SELECT Id, RecordTypeId, RecordType.DeveloperName, EUR_CRM_Active__c, 
                                                                                                            EUR_CRM_Product_Toolkit__c, EUR_CRM_Account__c
                                                                                                     FROM EUR_CRM_Visit_Action__c
                                                                                                     WHERE EUR_CRM_Account__c =: account.Id]);

            if(visitActionsMap.KeySet().size() > 0){
                for(EUR_CRM_Visit_Action__c visit : visitActionsMap.Values()){
                    if(visit.Id == visitAction.Id){
                        System.AssertEquals(visit.EUR_CRM_Active__c, false);
                    } else {
                        System.AssertEquals(visit.EUR_CRM_Active__c, true);
                        System.AssertEquals(visit.EUR_CRM_Account__c, account.Id);
                        System.AssertEquals(visit.RecordType.DeveloperName, OFF_TOOLKIT_FOLLOW_RT_ID);
                    }
                }
            }           
        }
        System.Debug('@@@testOFF1<<');
    }

    static TestMethod void testOFF2(){
        System.Debug('@@@testOFF2>>');
        setUser();
        System.runAs(new User(Id = eurSysUser.Id)){
            
            //Insert Account
            Id accRTId = Global_RecordTypeCache.getRTId('EUR_CRM_Account__cEUR_DK_On_Trade');
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(RecordTypeId = accRTId,
                                                                Name = 'test', 
                                                                EUR_CRM_Status__c = 'Active');
            insert account;

            EUR_CRM_Visit_Action__c visitAction = new EUR_CRM_Visit_Action__c();
            visitAction.RecordTypeId = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_OFF_Trade_Adhoc_Create_Indiv_Account_OP');
            visitAction.RecordType = Global_RecordTypeCache.getRTRec('EUR_CRM_Visit_Action__cEUR_DK_OFF_Trade_Adhoc_Create_Indiv_Account_OP');
            visitAction.EUR_CRM_Active__c = true;
            visitAction.EUR_CRM_Activation_End_Date__c = Date.Today() - 1;
            insert visitAction;

            // Run the batch 
            Test.startTest();
                Database.executeBatch(new EUR_CRM_DK_MassCreateFollowUpActions());
            Test.stopTest();

            // Asserts
            Id OFF_INDIV_FOLLOW_RT_ID = Global_RecordTypeCache.getRTId('EUR_CRM_Visit_Action__cEUR_DK_OFF_Trade_Adhoc_Create_Indiv_Account_OP_Follow_Up');
            account = [SELECT Id, OwnerId FROM EUR_CRM_Account__c WHERE Id =: account.Id];
            Map<Id, EUR_CRM_Visit_Action__c> visitActionsMap = new Map<Id, EUR_CRM_Visit_Action__c>([SELECT Id, RecordTypeId, RecordType.DeveloperName, EUR_CRM_Active__c, 
                                                                                                            EUR_CRM_Product_Toolkit__c, EUR_CRM_Account__c
                                                                                                     FROM EUR_CRM_Visit_Action__c
                                                                                                     WHERE EUR_CRM_Account__c =: account.Id]);

            if(visitActionsMap.KeySet().size() > 0){
                for(EUR_CRM_Visit_Action__c visit : visitActionsMap.Values()){
                    if(visit.Id == visitAction.Id){
                        System.AssertEquals(visit.EUR_CRM_Active__c, false);
                    } else {
                        System.AssertEquals(visit.EUR_CRM_Active__c, true);
                        System.AssertEquals(visit.EUR_CRM_Account__c, account.Id);
                        System.AssertEquals(visit.RecordType.DeveloperName, OFF_INDIV_FOLLOW_RT_ID);
                    }
                }
            }           
        }
        System.Debug('@@@testOFF2<<');
    }
}