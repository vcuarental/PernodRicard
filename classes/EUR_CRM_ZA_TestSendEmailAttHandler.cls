@isTest
public class EUR_CRM_ZA_TestSendEmailAttHandler {

    public static User eurSysUser;

    public static void dataSetup(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='EUR_CRM_ZA_TestSendEmailAttHandler@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='EUR_CRM_ZA_TestSendEmailAttHandler@test.com');
        insert eurSysUser;
    }

    static testMethod void testEmailSending(){
        dataSetup();
        System.runAs(eurSysUser){
            Test.startTest();
                Id ZAOnTradeAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', 'EUR_ZA_On_Trade_Direct');
                Id ZAContractRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract__c', 'EUR_ZA_Outlet_Contract');
                
                EUR_CRM_Account__c account = new EUR_CRM_Account__C(
                    recordTypeId = ZAOnTradeAccountRecordTypeId,
                    Name = 'Test Account',
                    EUR_CRM_Business_Type__c = 'Outlet'
                );
                insert account;
                
                EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c(
                    recordTypeId = ZAContractRecordTypeId,
                    EUR_CRM_Account__c = account.Id,
                    EUR_CRM_Start_Date__c = System.today(),
                    EUR_CRM_End_Date__c = System.today(),
                    EUR_CRM_Status__c = 'Draft',
                    EUR_CRM_Event_Manager__c = eurSysUser.Id
                );
                insert contract;

                Attachment att = new Attachment(
                    Name = 'EUR_ZA_Outlet_Contract_Soft_Copy',
                    ParentId = contract.Id,
                    Body = Blob.valueOf('{Test:Test}')
                );
                insert att;

                EUR_CRM_ZA_SendEmailAttachmentHandler.sendEmails(new List<EUR_CRM_Contract__c>{contract});
            Test.stopTest();
        }
    }
}