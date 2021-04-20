/*********************************************************************************
 * Name:ASI_BRD_Generic_UploadAccPage_Test
 * Description: Test Class for ASI_BRD_Generic_UploadAccPageController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 06/14/2016       Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_BRD_Generic_UploadAccPage_Test{
    @testSetup static void setupData(){
        ASI_BRD_Generic_TestClassHelper.createCrmMapping();
        ASI_BRD_Generic_TestClassHelper.createRunningNo();
        ASI_BRD_Generic_TestClassHelper.createDefValMapping();
    }
    
    static testMethod void ASI_BRD_Generic_UploadAccPageController_Test(){
        Group fakeGroup = new Group(Name = 'ASI LUX SG Users');
        insert fakeGroup;
        User u = ASI_BRD_Generic_TestClassHelper.createUser('Taiwan');
        GroupMember fakeMember = new GroupMember(GroupId = fakeGroup.id, UserOrGroupId = u.id);
        insert fakeMember;
        test.startTest();
        System.runAs(u){
            ASI_BRD_Generic_UploadAccPageController controller = new ASI_BRD_Generic_UploadAccPageController();
            controller.isLux = true;
            controller.isBrand = true;
        }
        test.stopTest();
    }
    
    static testMethod void ASI_BRD_Generic_UploadAccControllerLux_Test(){
        User u = ASI_BRD_Generic_TestClassHelper.createUser('Taiwan');
        System.runas(u){
            test.startTest();
            ASI_BRD_Generic_UploadAccControllerLux controller = new ASI_BRD_Generic_UploadAccControllerLux();
            controller.fields = 'Salutation,FirstName,LastName,PersonEmail,ASI_CRM_Birthday_Year__pc,ASI_LUX_Birthday_Month__c,ASI_LUX_Birthday_Day__c,ASI_LUX_Company_Name__c,ASI_LUX_Occupation_Title__c,ASI_LUX_Preferred_Contact_Number__c,ASI_LUX_Preferred_Language_1__c,ASI_LUX_Gender__c,ASI_BRD_Country_of_Residence__pc,ASI_LUX_Membership_Category__c,ASI_LUX_Profile__c,ASI_LUX_Occasion_at_First_Meeting__c,ASI_BRD_Primary_Market__pc,ASI_BRD_Salesforce_Campaign_Reference__pc,ASI_BRD_Acquired_By__pc,ASI_BRD_Ignore_Matching_Records__pc';
            controller.fieldsLabel  = 'Salutation,First Name,Last Name,Email,Birthday (Year),Birthday (Month),Birthday (Day),Company Name,Occupation Title,Preferred Contact Number,Preferred Language 1,Gender,Country of Residence,Membership Category,Profile,Occasion at First Meeting,Acquisition Market,Acquisition Campaign,Acquisition Brand,Ignore Matching Records';
            controller.country = '';
            controller.nameFile = 'test2.csv';
            controller.fileSize = 100;
            controller.contentFile = Blob.valueof('Salutation,First Name,Last Name,Email,Gender,Occasion at First Meeting,Acquisition Market,Acquisition Campaign,Preferred Language 1,Country of Residence,Acquisition Brand,Ignore Matching Records,Profile,Preferred Contact Number,Membership Category\nMr.,test,test,test@test.com,test,Taiwan,test,English,China,Chivas,false,test,12345678,HNWI');
            controller.template = '';
            controller.Msg = '';
            controller.BatchId = null;
            controller.AttId = null;
            controller.currentPageURL = '';
            controller.parentObjectAPIName = 'ASI_TnE_Mass_Upload_Log__c';
            controller.ParentObjectUploadMsg = 'ASI_TnE_Error_Message__c';
            controller.upsertMode = false;
            controller.isLux = true;
            controller.reportName = '';
            controller.accReport = '';
            controller.getItems();
            controller.getAccReport();
            controller.uploadCSVByBatch();
            string[] result = controller.StatusMsgs;
            test.stopTest();
        }
    }
    
    static testMethod void ASI_BRD_Generic_UploadAccController_Test(){
        User u = ASI_BRD_Generic_TestClassHelper.createUser('Taiwan');
        System.runas(u){
            test.startTest();
            ASI_BRD_Generic_UploadAccController controller = new ASI_BRD_Generic_UploadAccController();
            controller.fields = 'Salutation,FirstName,LastName,PersonEmail,ASI_CRM_Birthday_Year__pc,ASI_LUX_Birthday_Month__c,ASI_LUX_Birthday_Day__c,ASI_LUX_Company_Name__c,ASI_LUX_Occupation_Title__c,ASI_LUX_Preferred_Contact_Number__c,ASI_LUX_Preferred_Language_1__c,ASI_LUX_Gender__c,ASI_BRD_Country_of_Residence__pc,ASI_LUX_Membership_Category__c,ASI_LUX_Profile__c,ASI_LUX_Occasion_at_First_Meeting__c,ASI_BRD_Primary_Market__pc,ASI_BRD_Salesforce_Campaign_Reference__pc,ASI_BRD_Acquired_By__pc,ASI_BRD_Ignore_Matching_Records__pc';
            controller.fieldsLabel  = 'Salutation,First Name,Last Name,Email,Birthday (Year),Birthday (Month),Birthday (Day),Company Name,Occupation Title,Preferred Contact Number,Preferred Language 1,Gender,Country of Residence,Membership Category,Profile,Occasion at First Meeting,Acquisition Market,Acquisition Campaign,Acquisition Brand,Ignore Matching Records';
            controller.country = '';
            controller.nameFile = 'test.csv';
            controller.fileSize = 100;
            controller.contentFile = Blob.valueof('Salutation,First Name,Last Name,Email,Gender,Occasion at First Meeting,Acquisition Market,Acquisition Campaign,Preferred Language 1,Country of Residence,Acquisition Brand,Ignore Matching Records,Profile,Preferred Contact Number,Membership Category\nMr.,test,test,test@test.com,test,Taiwan,test,English,China,Chivas,false,test,12345678,tset');
            controller.template = '';
            controller.Msg = '';
            controller.BatchId = null;
            controller.AttId = null;
            controller.currentPageURL = '';
            controller.parentObjectAPIName = 'ASI_TnE_Mass_Upload_Log__c';
            controller.ParentObjectUploadMsg = 'ASI_TnE_Error_Message__c';
            controller.upsertMode = false;
            controller.isLux = false;
            controller.reportName = '';
            controller.accReport = '';
            controller.getItems();
            controller.getAccReport();
            controller.uploadCSVByBatch();
            string[] result = controller.StatusMsgs;
            test.stopTest();
        }
    }
    
    //Achieve more coverage by hitting some exceptions
    static testMethod void ASI_BRD_Generic_UploadAccController_Test2(){
        User u = ASI_BRD_Generic_TestClassHelper.createUser('Taiwan');
        System.runas(u){
            ASI_BRD_Generic_TestClassHelper.createAcc('test@test.com','test@test.com','12345678','12345678');
            test.startTest();
            ASI_BRD_Generic_UploadAccController controller = new ASI_BRD_Generic_UploadAccController();
            controller.fields = 'Salutation,ASI_LUX_LeCercle_Member_Since_Date__c,FirstName,LastName,PersonEmail,ASI_CRM_Birthday_Year__pc,ASI_LUX_Birthday_Month__c,ASI_LUX_Birthday_Day__c,ASI_LUX_Company_Name__c,ASI_LUX_Occupation_Title__c,ASI_LUX_Preferred_Contact_Number__c,ASI_LUX_Preferred_Language_1__c,ASI_LUX_Gender__c,ASI_BRD_Country_of_Residence__pc,ASI_LUX_Membership_Category__c,ASI_LUX_Profile__c,ASI_LUX_Occasion_at_First_Meeting__c,ASI_BRD_Primary_Market__pc,ASI_BRD_Salesforce_Campaign_Reference__pc,ASI_BRD_Acquired_By__pc,ASI_BRD_Ignore_Matching_Records__pc';
            controller.fieldsLabel  = 'Salutation,Le Cercle Member Since Date,First Name,Last Name,Email,Birthday (Year),Birthday (Month),Birthday (Day),Company Name,Occupation Title,Preferred Contact Number,Preferred Language 1,Gender,Country of Residence,Membership Category,Profile,Occasion at First Meeting,Acquisition Market,Acquisition Campaign,Acquisition Brand,Ignore Matching Records';
            controller.country = '';
            controller.nameFile = 'test.csv';
            controller.fileSize = 100;
            controller.contentFile = Blob.valueof('Salutation,First Name,Last Name,Email,Gender,Occasion at First Meeting,Acquisition Market,Acquisition Campaign,Preferred Language 1,Country of Residence,Acquisition Brand,Ignore Matching Records,Profile,Preferred Contact Number,Membership Category,Le Cercle Member Since Date\nMr.,test,test,test@test.com,test,Taiwan,test,English,China,Chivas,false,test,12345678,tset,20150101');
            controller.template = '';
            controller.Msg = '';
            controller.BatchId = null;
            controller.AttId = null;
            controller.currentPageURL = '';
            controller.parentObjectAPIName = 'ASI_TnE_Mass_Upload_Log__c';
            controller.ParentObjectUploadMsg = 'ASI_TnE_Error_Message__c';
            controller.upsertMode = false;
            controller.isLux = false;
            controller.reportName = '';
            controller.accReport = '';
            controller.getItems();
            controller.getAccReport();
            controller.uploadCSVByBatch();
            string[] result = controller.StatusMsgs;
            test.stopTest();
        }
    }
    
    //Achieve more coverage by hitting some exceptions
    static testMethod void ASI_BRD_Generic_UploadAccController_Test3(){
        User u = ASI_BRD_Generic_TestClassHelper.createUser('Taiwan');
        System.runas(u){
            ASI_BRD_Generic_TestClassHelper.createAcc('test@test.com','test@test.com','12345678','12345678');
            test.startTest();
            ASI_BRD_Generic_UploadAccController controller = new ASI_BRD_Generic_UploadAccController();
            controller.fields = 'Salutation,ASI_LUX_LeCercle_Member_Since_Date__c,FirstName,LastName,PersonEmail,ASI_CRM_Birthday_Year__pc,ASI_LUX_Birthday_Month__c,ASI_LUX_Birthday_Day__c,ASI_LUX_Company_Name__c,ASI_LUX_Occupation_Title__c,ASI_LUX_Preferred_Contact_Number__c,ASI_LUX_Preferred_Language_1__c,ASI_LUX_Gender__c,ASI_BRD_Country_of_Residence__pc,ASI_LUX_Membership_Category__c,ASI_LUX_Profile__c,ASI_LUX_Occasion_at_First_Meeting__c,ASI_BRD_Primary_Market__pc,ASI_BRD_Salesforce_Campaign_Reference__pc,ASI_BRD_Acquired_By__pc,ASI_BRD_Ignore_Matching_Records__pc';
            controller.fieldsLabel  = 'Salutation,Le Cercle Member Since Date,First Name,Last Name,Email,Birthday (Year),Birthday (Month),Birthday (Day),Company Name,Occupation Title,Preferred Contact Number,Preferred Language 1,Gender,Country of Residence,Membership Category,Profile,Occasion at First Meeting,Acquisition Market,Acquisition Campaign,Acquisition Brand,Ignore Matching Records';
            controller.country = '';
            controller.nameFile = 'test.csv';
            controller.fileSize = 100;
            controller.contentFile = Blob.valueof('Salutation,First Name,Last Name,Email,Gender,Occasion at First Meeting,Acquisition Market,Acquisition Campaign,Preferred Language 1,Country of Residence,Acquisition Brand,Ignore Matching Records,Profile,Preferred Contact Number,Membership Category\nMr.,test,test,test@test.com,test,Taiwan,test,English,China,Chivas,false,test,12345678,tset');
            controller.template = '';
            controller.Msg = '';
            controller.BatchId = null;
            controller.AttId = null;
            controller.currentPageURL = '';
            controller.parentObjectAPIName = 'ASI_TnE_Mass_Upload_Log__c';
            controller.ParentObjectUploadMsg = 'ASI_TnE_Error_Message__c';
            controller.upsertMode = false;
            controller.isLux = false;
            controller.reportName = '';
            controller.accReport = '';
            controller.getItems();
            controller.getAccReport();
            controller.uploadCSVByBatch();
            string[] result = controller.StatusMsgs;
            test.stopTest();
        }
    }
}