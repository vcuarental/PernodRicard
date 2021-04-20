@isTest
public class ASI_LUX_TW_UploadImageController_Test {
    
    public static testMethod void mainTest () 
    {
    
       List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Running_Number__c = 2315;
        runnNumTest.ASI_HK_CRM_Format__c = 'SO-{YY}{000000}';
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_HK';
        testRunningNumList.add(runnNumTest2);
        
        Insert testRunningNumList;

        Account testAcc = new Account();
        testAcc.recordTypeID = Global_RecordTypeCache.getRtId('AccountASI_Luxury_Account_HK_Second_Contact');
        testAcc.FirstName = 'testFirst';
        testAcc.LastName = 'testLast';
        testAcc.ASI_LUX_Gender__c = 'Male';
        testAcc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc.ASI_HK_CRM_Grade__c = 'D';
        testAcc.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc.ASI_LUX_Le_Cercle_Member__c = false;
        
        Insert testAcc;
        //Contact ctnt = new Contact(name = 'testContact', accountid = );
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(testAcc); 
        ASI_LUX_TW_UploadImageController TWImageController = new ASI_LUX_TW_UploadImageController(stdController);
        TWImageController.fileName = 'testFile';
        TWImageController.fileBody = Blob.valueOf('Test Data');
        TWImageController.UploadFile();
        TWImageController.insertNewAttachments();
        TWImageController.cancel();
        TWImageController.UploadFile();
    }
    
    public static testMethod void mainTest2 () 
    {
    
       List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Running_Number__c = 2315;
        runnNumTest.ASI_HK_CRM_Format__c = 'SO-{YY}{000000}';
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_HK';
        testRunningNumList.add(runnNumTest2);
        
        Insert testRunningNumList;

        Account testAcc = new Account();
        testAcc.recordTypeID = Global_RecordTypeCache.getRtId('AccountASI_Luxury_Account_HK_Second_Contact');
        testAcc.FirstName = 'testFirst';
        testAcc.LastName = 'testLast';
        testAcc.ASI_LUX_Gender__c = 'Male';
        testAcc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc.ASI_HK_CRM_Grade__c = 'D';
        testAcc.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc.ASI_LUX_Le_Cercle_Member__c = false;
        
        Insert testAcc;
        
        Contact ctnt = [SELECT ID, Name,  ASI_LUX_Sys_Profile_Picture_URL__c FROM Contact WHERE accountID = :testAcc.id]; 
        Attachment att = new Attachment(name='testfile2.png', body = Blob.valueOf('Test Data'), ParentID=ctnt.id);
        insert att;
        ctnt.ASI_LUX_Sys_Profile_Picture_URL__c = 'notnillDummy&file=' + att.id;
        update ctnt;

        //Contact ctnt = new Contact(name = 'testContact', accountid = );
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(testAcc); 
        ASI_LUX_TW_UploadImageController TWImageController = new ASI_LUX_TW_UploadImageController(stdController);
        TWImageController.fileName = 'testFile.png';
        TWImageController.fileBody = Blob.valueOf('Test Data');
        TWImageController.UploadFile();
        TWImageController.insertNewAttachments();
        TWImageController.cancel();
        TWImageController.UploadFile();
    }

}