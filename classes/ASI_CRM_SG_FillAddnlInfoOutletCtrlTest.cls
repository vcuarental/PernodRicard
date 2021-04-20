/**********************************************************************************
 * Name : ASI_CRM_SG_FillAddnlInfoOutletCtrlTest
 * Created : DC @04/21/2016 9:30 AM
 * Revision History:
 * 1. 04/21/2016 - [DC 1.0] Created
 **********************************************************************************/
@isTest
private class ASI_CRM_SG_FillAddnlInfoOutletCtrlTest {

    //public static Integer businessRegistrationNumber = 123456789;
    
    @TestSetup
    static void createTestData() {
		/*
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(
            Alias  = 'standt', 
            email = 'newUser@newUser.com', 
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US', 
            LocaleSidKey = 'en_US', 
            ASI_Company_Name__c = 'Testcompany',
            ASI_MFM_Country__c = 'TW',
            ProfileId  = p.Id, 
            ManagerId = UserInfo.getUserId(),
            TimeZoneSidKey = 'America/Los_Angeles', 
            username = 'newUser1234@newUser1234.com'
        );
        insert u;
		*/ 

        Id customerRecTypeId = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c
                                     .getRecordTypeInfosByName()
                                     .get('Converted Outlets (SG)').getRecordTypeId();

        list<ASI_CRM_AccountsAdditionalField__c> lstCustomer = 
            new list<ASI_CRM_AccountsAdditionalField__c>();

        for(Integer i=0; i<1; i++) {
            
            lstCustomer.add( new ASI_CRM_AccountsAdditionalField__c(
                Name = 'TestCustomer',
                RecordTypeId = customerRecTypeId,
                ASI_CRM_SG_Customer_Price_Group__c = NULL,
                ASI_CRM_SG_Search_Type__c = NULL,
                ASI_CRM_SG_Business_Unit__c = NULL,
                ASI_CRM_SG_GDF_Country__c = NULL,
                ASI_CRM_SG_CCC_Location__c = NULL,
                ASI_CRM_SG_A_B_Amount_Codes__c = NULL,
                ASI_CRM_SG_Statement_Cycle__c = NULL,
                ASI_CRM_SG_Payment_Terms_A_R__c = NULL,
                ASI_CRM_SG_Tax_Rate_Area__c = NULL,
                ASI_CRM_SG_Send_Statement_To__c = NULL,
                ASI_CRM_SG_Batch_Processing_Mode__c = NULL,
                ASI_CRM_Adjustment_Schedule__c = NULL,
                ASI_CRM_Currency_Code__c = NULL,
                ASI_CRM_SG_Tax_Expl_Code__c = NULL
                //ASI_CRM_Business_Registration_Number__c = String.valueOf(businessRegistrationNumber)
            ));
            
            //businessRegistrationNumber += 1;
            
        }

        insert lstCustomer;
        
        /* This part is not required

        Id prefixRecTypeId = Schema.SObjectType.ASI_MFM_Prefix__c
                                   .getRecordTypeInfosByName()
                                   .get('ASI MFM SG Prefix').getRecordTypeId();
        
        list<ASI_MFM_Prefix__c>  lstPrefix = new list<ASI_MFM_Prefix__c>();

        lstPrefix.add( new ASI_MFM_Prefix__c(
            Name = 'PO15',
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = 'FY1920',
            RecordTypeId = prefixRecTypeId
        ));

        lstPrefix.add( new ASI_MFM_Prefix__c(
            Name = 'PN15',
            ASI_MFM_Module__c = 'PLAN',
            ASI_MFM_Fiscal_year__c = 'FY1920',
            OwnerId = u.Id,
            Plan_Type__c = 'Marketing A&P Plan',
            RecordTypeId = prefixRecTypeId
        ));

        insert lstPrefix;

        userRole r = [SELECT Id
                           , Name
                           , DeveloperName
                        FROM UserRole 
                       WHERE Id = : userinfo.getUserRoleId() ];
        
        list<ASI_MFM_Role_Prefix_Relationship__c> lstRel = new list<ASI_MFM_Role_Prefix_Relationship__c>();

        lstRel.add( new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c = lstPrefix[0].id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        ));

        lstRel.add( new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c = lstPrefix[1].id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        ));

        insert lstRel;

        Id accountRecTypeId = Schema.SObjectType.Account
                                    .getRecordTypeInfosByName()
                                    .get('HK Supplier').getRecordTypeId();

        Account acntRecord = new Account(
            Name = 'TestAccount',
            RecordTypeId = accountRecTypeId,
            ASI_HK_CRM_Inactive__c = false
        );
        insert acntRecord;

        Id planRecTypeId = Schema.SObjectType.ASI_MFM_Plan__c
                                 .getRecordTypeInfosByName()
                                 .get('SG Plan').getRecordTypeId();

        ASI_MFM_Plan__c planRecord = new ASI_MFM_Plan__c(
            ASI_MFM_Plan_Name__c = 'TestPlan',
            ASI_MFM_Prefix__c = lstPrefix[1].Id,
            ASI_MFM_Plan_Description__c = 'Testing plabn',
            ASI_MFM_Start_Date__c = Date.today(),
            RecordTypeId = planRecTypeId,
            ASI_MFM_End_Date__c = Date.today(),
            ASI_MFM_Plan_Raised_Date__c = date.today()
        );
        insert planRecord;

        Id poRecTypeId = Schema.SObjectType.ASI_MFM_PO__c
                                     .getRecordTypeInfosByName()
                                     .get('SG PO').getRecordTypeId();

        ASI_MFM_PO__c purchaseOrder = new ASI_MFM_PO__c(
            ASI_MFM_PO_Name__c = 'TestPO',
            ASI_MFM_Prefix__c = lstPrefix[0].Id,
            RecordTypeId = poRecTypeId,
            ASI_MFM_Plan__c = planRecord.Id,
            ASI_MFM_SG_Customer__c = acntRecord.Id,
            ASI_MFM_PO_Start_Date__c = Date.today(),
            ASI_MFM_PO_End_Date__c = Date.today(),
            ASI_MFM_PO_Raised_Date__c = Date.today(),
            ASI_MFM_Currency__c = 'SGD',
            ASI_MFM_Supplier_Name__c = acntRecord.Id
        );
        insert purchaseOrder;
        
        */

    }

    static testMethod void testQuery() {
      
        ASI_CRM_AccountsAdditionalField__c customerRecord = [SELECT Id
                                                               FROM ASI_CRM_AccountsAdditionalField__c 
                                                              LIMIT 1];

        Test.startTest(); // Starts the scope of test

            ApexPAges.StandardController sc = new ApexPages.StandardController(customerRecord);
            ASI_CRM_SG_FillAdditionalInfoOutletCtrl controller = new ASI_CRM_SG_FillAdditionalInfoOutletCtrl(sc);
            controller.toggleSort();
            controller.save();
            controller.firstPage();
            controller.lastPage();
            controller.prevPage();
            controller.nextPage();
            Apexpages.currentPage().getParameters().put('PO_Number', 'PO15');
            Apexpages.currentPage().getParameters().put('PO_Line_Number', 'TestCustomer');
            Apexpages.currentPage().getParameters().put('Suppliers', 'TestAccount');
            Apexpages.currentPage().getParameters().put('GLdates', '2016-4-21');
            controller.runSearch();

        Test.stopTest(); // Starts the scope of test
    }
}