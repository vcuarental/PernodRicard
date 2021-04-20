@isTest
public class EUR_CRM_ZA_TestAssignWarehouseMangr {

    public static User eurSysUser;
    public static User eurSysUser2;

    public static void dataSetup(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='EUR_CRM_ZA_TestSendEmailAttHandler@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='EUR_CRM_ZA_TestSendEmailAttHandler@test.com');
        insert eurSysUser;

        eurSysUser2 = new User(Alias = 'stand2', Email='EUR_CRM_ZA_TestSendEmailAttHandler2@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName2', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='EUR_CRM_ZA_TestSendEmailAttHandler2@test.com');
        insert eurSysUser2;
    }

    static testMethod void testexecution(){
        dataSetup();
        System.runAs(eurSysUser){
            Test.startTest();

                Id ZAOnTradeAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', 'EUR_ZA_On_Trade_Direct');
                
                List<EUR_CRM_Account__c> accountList = new List<EUR_CRM_Account__c>();
                EUR_CRM_Account__c account = new EUR_CRM_Account__C(
                    recordTypeId = ZAOnTradeAccountRecordTypeId,
                    Name = 'Test Account',
                    EUR_CRM_Warehouse_Manager__c = eurSysUser.Id
                );
                accountList.add(account);

                EUR_CRM_Account__c account2 = new EUR_CRM_Account__C(
                    recordTypeId = ZAOnTradeAccountRecordTypeId,
                    Name = 'Test Account 2',
                    EUR_CRM_Warehouse_Manager__c = eurSysUser2.Id
                );
                accountList.add(account2);
                insert accountList;
                
                EUR_CRM_POSM_Order__c posm = EUR_CRM_ZA_TestClassHelper.createPOSMOrder(1, account)[0];
                insert posm;

                posm = [SELECT Id, EUR_CRM_Account__c, EUR_CRM_Warehouse_Manager__c FROM EUR_CRM_POSM_Order__c WHERE Id =: posm.Id];
                System.assertEquals(account.EUR_CRM_Warehouse_Manager__c, posm.EUR_CRM_Warehouse_Manager__c);

                posm.EUR_CRM_Account__c = account2.Id;
                update posm;
                posm = [SELECT Id, EUR_CRM_Account__c, EUR_CRM_Warehouse_Manager__c FROM EUR_CRM_POSM_Order__c WHERE Id =: posm.Id];
                System.assertEquals(account2.EUR_CRM_Warehouse_Manager__c, posm.EUR_CRM_Warehouse_Manager__c);

            Test.stopTest();
        }
    }
}