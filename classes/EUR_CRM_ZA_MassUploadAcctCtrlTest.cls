@isTest
public class EUR_CRM_ZA_MassUploadAcctCtrlTest {

    public static EUR_CRM_Account__c euaccount = new EUR_CRM_Account__c();
    public static EUR_CRM_Visit_Frequency__c visitFrequency = new EUR_CRM_Visit_Frequency__c();
    public static EUR_CRM_Route_Template__c routeTemplate = new EUR_CRM_Route_Template__c();

    public static User eurSysUser;
    public static void setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name ='EUR System Admin']; 
        UserRole r = [select id from UserRole where Developername ='EMEA'];
        eurSysUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        insert eurSysUser;

    }

    public static void dataInsert1(){

        visitFrequency = EUR_CRM_ZA_TestClassHelper.createVisitFrequency(1,'ZA Visit Frequency TEST').get(0);
        visitFrequency.EUR_CRM_External_ID__c = 'ZA_VF_28_1';
        insert visitFrequency;
        system.assertNotEquals(visitFrequency, null);

        euaccount = EUR_CRM_ZA_TestClassHelper.createEUAccount(1,'Test EU ACCOUNT', 'EUR_ZA_On_Trade_Direct').get(0);
        euaccount.EUR_CRM_Visit_Frequency__c = visitFrequency.Id;
        euaccount.EUR_CRM_Preferred_Day__c = 'Monday';
        insert euaccount;
        system.assertNotEquals(euaccount, null);


        routeTemplate = EUR_CRM_ZA_TestClassHelper.createRT(1,'Test ROUTE TEMPLATE').get(0);
        insert routeTemplate;
        system.assertNotEquals(routeTemplate, null);
    }

    static testMethod void test1(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
            dataInsert1();

            String accountId = String.valueOf(euaccount.Id).substring(0, 15);
            String ownerId = String.valueOf(Userinfo.getUserId()).substring(0, 15);
            String visitFreqId = String.valueOf(visitFrequency.Id).substring(0, 15);

            
            EUR_CRM_MassUploadAccountController mAcctUpload = new EUR_CRM_MassUploadAccountController();
            mAcctUpload.currentPageURL = routeTemplate.Id;
            mAcctUpload.redirectRT();
            mAcctUpload.refreshPage2();

            
            mAcctUpload.contentFile = blob.valueOf('ID,Account Name,Owner,Visit Frequency,Preferred Day\r'+ accountId +',TEST ACCOUNT,'+ ownerId +','+ visitFreqId +',Monday');
            mAcctUpload.nameFile = 'Test1.csv';
            //mAcctUpload.fileSize = 5000;
            mAcctUpload.fields = 'ID Name OwnerId EUR_CRM_Visit_Frequency__c EUR_CRM_Preferred_Day__c';
            mAcctUpload.fieldsLabel = 'ID,Account Name, Owner, Visit Frequency, Preferred Day';
            mAcctUpload.parentObjectAPIName = 'EUR_CRM_MassUploadLog__c';
            mAcctUpload.recordtypeName = 'EUR_ZA_Route_Template';

            mAcctUpload.uploadCSVByBatch();


            Test.stopTest();

         }
    }

    static testMethod void test2(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
            dataInsert1();

            String accountId = String.valueOf(euaccount.Id).substring(0, 15);
            String ownerId = String.valueOf(Userinfo.getUserId()).substring(0, 15);
            String visitFreqId = String.valueOf(visitFrequency.Id).substring(0, 15);

            
            EUR_CRM_MassUploadAccountController mAcctUpload = new EUR_CRM_MassUploadAccountController();
            mAcctUpload.currentPageURL = routeTemplate.Id;
            mAcctUpload.redirectRT();
            mAcctUpload.refreshPage2();

            
            mAcctUpload.contentFile = blob.valueOf('ID,Account Name,Owner,Visit Frequency,Preferred Day\r'+ accountId +',TEST ACCOUNT,'+ ownerId +','+ visitFreqId +',Monday');
            mAcctUpload.nameFile = 'Test1.csv';
            mAcctUpload.fileSize = 5000;
            mAcctUpload.fields = 'ID Name OwnerId EUR_CRM_Visit_Frequency__c EUR_CRM_Preferred_Day__c';
            mAcctUpload.fieldsLabel = 'ID,Account Name, Owner, Visit Frequency, Preferred Day';
            mAcctUpload.parentObjectAPIName = 'EUR_CRM_MassUploadLog__c';
            mAcctUpload.recordtypeName = 'EUR_ZA_Route_Template';
            mAcctUpload.ObjAPIName = 'EUR_CRM_Account__c';
            mAcctUpload.ParentObjectUploadMsg = 'EUR_CRM_Error_Message__c';

            mAcctUpload.uploadCSVByBatch();


            Test.stopTest();

         }
    }

    static testMethod void test3(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
            dataInsert1();

            String accountId = String.valueOf(euaccount.Id).substring(0, 15);
            String ownerId = String.valueOf(Userinfo.getUserId()).substring(0, 15);
            String visitFreqId = String.valueOf(visitFrequency.Id).substring(0, 15);

            
            EUR_CRM_MassUploadAccountController mAcctUpload = new EUR_CRM_MassUploadAccountController();
            mAcctUpload.currentPageURL = routeTemplate.Id;
            mAcctUpload.redirectRT();
            mAcctUpload.refreshPage2();

            
            mAcctUpload.contentFile = blob.valueOf('ID,Account Name,Owner,Visit Frequency,Preferred Day\r'+ accountId +',TEST ACCOUNT,'+ ownerId +','+ visitFreqId +',Monday');
            mAcctUpload.nameFile = 'Test1.csv';
            mAcctUpload.fileSize = 5000;
            mAcctUpload.fields = 'ID Name OwnerId EUR_CRM_Visit_Frequency__c EUR_CRM_Preferred_Day__c';
            mAcctUpload.fieldsLabel = 'ID,Account Name, Owner, Visit Frequency, Preferred Day';
            mAcctUpload.parentObjectAPIName = 'EUR_CRM_MassUploadLog__c';
            mAcctUpload.recordtypeName = 'EUR_ZA_Route_Template';
            mAcctUpload.ObjAPIName = 'EUR_CRM_Account__c';
            mAcctUpload.ParentObjectUploadMsg = 'EUR_CRM_Error_Message__c';

            mAcctUpload.uploadCSVByBatch();
            mAcctUpload.isPublishReady = true;

            mAcctUpload.publishEvents();
            Test.stopTest();

            List<String> sm = mAcctUpload.StatusMsgs;

            mAcctUpload.redirectRT();

            List<String> sm2 = mAcctUpload.StatusMsgs;
            List<String> sm3 = mAcctUpload.StatusMsgs;
            List<String> sm4 = mAcctUpload.StatusMsgs;


            

         }
    }

    //ERROR SCENARIO
    static testMethod void test4(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
            dataInsert1();

            String accountId = String.valueOf(euaccount.Id).substring(0, 15);
            String ownerId = String.valueOf(Userinfo.getUserId()).substring(0, 15);
            String visitFreqId = String.valueOf(visitFrequency.Id).substring(0, 15);

            
            EUR_CRM_MassUploadAccountController mAcctUpload = new EUR_CRM_MassUploadAccountController();
            mAcctUpload.currentPageURL = routeTemplate.Id;
            mAcctUpload.redirectRT();
            mAcctUpload.refreshPage2();

            
            mAcctUpload.contentFile = blob.valueOf('IdTEST,Account Name,Owner,Visit Frequency,Preferred Day\r'+ accountId +',TEST ACCOUNT,'+ ownerId +','+ visitFreqId +',Monday');
            mAcctUpload.nameFile = 'Test1.csv';
            mAcctUpload.fileSize = 5000;
            mAcctUpload.fields = 'ID Name OwnerId EUR_CRM_Visit_Frequency__c EUR_CRM_Preferred_Day__c';
            mAcctUpload.fieldsLabel = 'ID,Account Name, Owner, Visit Frequency, Preferred Day';
            mAcctUpload.parentObjectAPIName = 'EUR_CRM_MassUploadLog__c';
            mAcctUpload.recordtypeName = 'EUR_ZA_Route_Template';
            mAcctUpload.ObjAPIName = 'EUR_CRM_Account__c';
            mAcctUpload.ParentObjectUploadMsg = 'EUR_CRM_Error_Message__c';

            mAcctUpload.uploadCSVByBatch();
            mAcctUpload.isPublishReady = true;

            mAcctUpload.publishEvents();


            Test.stopTest();


            

         }
    }

    //ERROR SCENARIO
    static testMethod void test5(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
            dataInsert1();

            String accountId = String.valueOf(euaccount.Id).substring(0, 14);
            accountId = accountId + 'P';
            String ownerId = String.valueOf(Userinfo.getUserId()).substring(0, 15);
            String visitFreqId = String.valueOf(visitFrequency.Id).substring(0, 15);

            
            EUR_CRM_MassUploadAccountController mAcctUpload = new EUR_CRM_MassUploadAccountController();
            mAcctUpload.currentPageURL = routeTemplate.Id;
            mAcctUpload.redirectRT();
            mAcctUpload.refreshPage2();

            
            mAcctUpload.contentFile = blob.valueOf('Id,Account Name,Owner,Visit Frequency,Preferred Day\r'+ accountId +',TEST ACCOUNT,'+ ownerId +','+ visitFreqId +',Monday');
            mAcctUpload.nameFile = 'Test1.csv';
            mAcctUpload.fileSize = 5000;
            mAcctUpload.fields = 'ID Name OwnerId EUR_CRM_Visit_Frequency__c EUR_CRM_Preferred_Day__c';
            mAcctUpload.fieldsLabel = 'ID,Account Name, Owner, Visit Frequency, Preferred Day';
            mAcctUpload.parentObjectAPIName = 'EUR_CRM_MassUploadLog__c';
            mAcctUpload.recordtypeName = 'EUR_ZA_Route_Template';
            mAcctUpload.ObjAPIName = 'EUR_CRM_Account__c';
            mAcctUpload.ParentObjectUploadMsg = 'EUR_CRM_Error_Message__c';

            mAcctUpload.uploadCSVByBatch();
            mAcctUpload.isPublishReady = true;

            mAcctUpload.publishEvents();


            Test.stopTest();


            

         }
    }

    //ERROR SCENARIO
    static testMethod void test6(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
            dataInsert1();

            String accountId = String.valueOf(euaccount.Id).substring(0, 15);
            //accountId = accountId + 'P';
            String ownerId = String.valueOf(Userinfo.getUserId()).substring(0, 15);
            String visitFreqId = String.valueOf(visitFrequency.Id).substring(0, 15);

            
            EUR_CRM_MassUploadAccountController mAcctUpload = new EUR_CRM_MassUploadAccountController();
            mAcctUpload.currentPageURL = routeTemplate.Id;
            mAcctUpload.redirectRT();
            mAcctUpload.refreshPage2();

            
            mAcctUpload.contentFile = blob.valueOf('Id,Account Name,Owner,Visit Frequency,Preferred Day\r'+ accountId +',TEST ACCOUNT,'+ ownerId +','+ visitFreqId +',Monday\r'+ accountId +',TEST ACCOUNT,'+ ownerId +','+ visitFreqId +',Monday\r');
            mAcctUpload.nameFile = 'Test1.csv';
            mAcctUpload.fileSize = 5000;
            mAcctUpload.fields = 'ID Name OwnerId EUR_CRM_Visit_Frequency__c EUR_CRM_Preferred_Day__c';
            mAcctUpload.fieldsLabel = 'ID,Account Name, Owner, Visit Frequency, Preferred Day';
            mAcctUpload.parentObjectAPIName = 'EUR_CRM_MassUploadLog__c';
            mAcctUpload.recordtypeName = 'EUR_ZA_Route_Template';
            mAcctUpload.ObjAPIName = 'EUR_CRM_Account__c';
            mAcctUpload.ParentObjectUploadMsg = 'EUR_CRM_Error_Message__c';

            mAcctUpload.uploadCSVByBatch();
            mAcctUpload.isPublishReady = true;

            mAcctUpload.publishEvents();


            Test.stopTest();


            

         }
    }

    static testMethod void test7(){
        setUser();
        System.runAs(eurSysUser){
            Test.startTest();
            dataInsert1();

            String accountId = String.valueOf(euaccount.Id).substring(0, 15);
            String ownerId = String.valueOf(Userinfo.getUserId()).substring(0, 15);
            String visitFreqId = String.valueOf(visitFrequency.Id).substring(0, 15);

            
            EUR_CRM_MassUploadAccountController mAcctUpload = new EUR_CRM_MassUploadAccountController();
            mAcctUpload.currentPageURL = routeTemplate.Id;
            mAcctUpload.redirectRT();
            mAcctUpload.refreshPage2();

            
            mAcctUpload.contentFile = blob.valueOf('ID,Account Name,Owner,Visit Frequency,Preferred Day\r'+ accountId +',TEST ACCOUNT,'+ ownerId +','+ visitFreqId +',Monday');
            mAcctUpload.nameFile = 'Test1.csv';
            mAcctUpload.fileSize = 5000;
            mAcctUpload.fields = 'ID Name OwnerId EUR_CRM_Visit_Frequency__c EUR_CRM_Preferred_Day__c';
            mAcctUpload.fieldsLabel = 'ID,Account Name, Owner, Visit Frequency, Preferred Day';
            mAcctUpload.parentObjectAPIName = 'EUR_CRM_MassUploadLog__c';
            mAcctUpload.recordtypeName = 'EUR_ZA_Route_Template';
            mAcctUpload.ObjAPIName = 'EUR_CRM_Account__c';
            mAcctUpload.ParentObjectUploadMsg = 'EUR_CRM_Error_Message__c';

            mAcctUpload.uploadCSVByBatch();
            mAcctUpload.isPublishReady = true;

            mAcctUpload.publishEvents();
            Test.stopTest();

            List<String> sm = mAcctUpload.StatusMsgs;

            mAcctUpload.redirectRT();

            List<String> sm2 = mAcctUpload.StatusMsgs;
            List<String> sm3 = mAcctUpload.StatusMsgs;
            List<String> sm4 = mAcctUpload.StatusMsgs;

            PageReference pageRef = new PageReference('/apex/EUR_CRM_ZA_RT_Clear_Calendar');
            pageRef.getParameters().put('id', routeTemplate.Id);
            Test.SetCurrentPage(pageRef);

            ApexPages.StandardController sc = new ApexPages.StandardController(routeTemplate);
            EUR_CRM_ZA_RT_Clear_Calendar clearCalendar = new EUR_CRM_ZA_RT_Clear_Calendar(sc);
            
            clearCalendar.deleteEvents();

         }
    }
}