@IsTest
public class EUR_CRM_ZA_TestUpdateSOTeleSales {
    public static User eurSysUser;
    public static User eurSysUser2;
    public static User eurSysUser3;

    @TestSetup
    static void dataSetup(){
        Profile p = [SELECT Id FROM Profile WHERE Name Like 'EUR SSA Admin%' ];
        Profile zaTeleAgent = [SELECT Id FROM Profile WHERE Name Like 'EUR ZA Telesales Agent' ];
        UserRole r = [select id from UserRole where Developername ='EMEA'];

        eurSysUser = new User(Alias = 'standt', Email='EUR_CRM_ZA_TestSendEmailAttHandler@test.com', userroleid=r.id,
                              EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = zaTeleAgent.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='EUR_CRM_ZA_TestSendEmailAttHandler@test.com');
        insert eurSysUser;

        eurSysUser2 = new User(Alias = 'stand2', Email='EUR_CRM_ZA_TestSendEmailAttHandler2@test.com', userroleid=r.id,
                               EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName2', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = zaTeleAgent.Id,
                               TimeZoneSidKey='America/Los_Angeles', UserName='EUR_CRM_ZA_TestSendEmailAttHandler2@test.com');
        insert eurSysUser2;


        eurSysUser3 = new User(Alias = 'stand3', Email='EUR_CRM_ZA_TestSendEmailAttHandler3@test.com', userroleid=r.id,
                               EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName3', LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = zaTeleAgent.Id, ManagerId = eurSysUser.Id, EUR_CRM_Telesales_Agent__c = eurSysUser.Id,
                               TimeZoneSidKey='America/Los_Angeles', UserName='EUR_CRM_ZA_TestSendEmailAttHandler3@test.com');
        insert eurSysUser3;

    }

    @IsTest
    static void testUpdateSOTeleSales(){

        EUR_CRM_Sales_Order__c salesOrder;
        EUR_CRM_Apex_Configuration__c runningNumber = new EUR_CRM_Apex_Configuration__c();
        runningNumber.EUR_CRM_Prefix__c = 'Testing';
        runningNumber.EUR_CRM_Running_Number_Length__c = 5;
        runningNumber.EUR_CRM_Running_Number__c = 1;
        runningNumber.EUR_CRM_Module__c = 'EUR_CRM_Running_Number';
        runningNumber.EUR_CRM_Country_Code__c = 'ZA';
        insert runningNumber;

        Test.startTest();

        User eurSysUser = [select Id,EUR_CRM_Telesales_Agent__c from User where Email='EUR_CRM_ZA_TestSendEmailAttHandler3@test.com'];
        User eurSysUser4 = [select Id from User where Email='EUR_CRM_ZA_TestSendEmailAttHandler2@test.com'];
        System.runAs(eurSysUser){

            Id ZAOnTradeAccountRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', 'EUR_ZA_On_Trade_Indirect');
            Id ZASalesOrderRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Sales_Order__c', 'EUR_Direct');


            //RecordType zarecordType = [select Id, DeveloperName from RecordType where DeveloperName  = 'EUR_ZA_Direct_Sales_Order'];
            EUR_CRM_Account__c account = new EUR_CRM_Account__C(
                recordTypeId = ZAOnTradeAccountRecordTypeId,
                Name = 'Test Account'
            );
            insert account;

            /*EUR_CRM_Sales_Order__c salesOrder = new EUR_CRM_Sales_Order__c(
//Name = 'ZA-SO-0000000001',
recordType = zarecordType,
//recordType.DeveloperName = 'EUR_ZA_Direct_Sales_Order', 
EUR_CRM_Order_Status__c = 'Draft',
EUR_CRM_Account__c = account.Id,
EUR_CRM_Order_Date__c = System.today()            
);*/


            salesOrder = EUR_CRM_ZA_TestClassHelper.createSalesOrder(1,account).get(0);
            salesOrder.EUR_CRM_Order_Status__c = 'Draft';
            insert salesOrder;

            eurSysUser.EUR_CRM_Telesales_Agent__c = eurSysUser4.Id;
            update eurSysUser;
            Test.stopTest();
        }
        System.assertEquals(eurSysUser4.Id,[SELECT EUR_CRM_Telesales_Agent__c FROM EUR_CRM_Sales_Order__c WHERE Id = :salesOrder.Id][0].EUR_CRM_Telesales_Agent__c);
    }

}