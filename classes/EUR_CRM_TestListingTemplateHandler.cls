@isTest
public with sharing class EUR_CRM_TestListingTemplateHandler {

    public static User testUser;
    public static void setUser(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name =: profileName];
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMEA'];
        testUser = new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName='userEmail1234aokelastName', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
        
        insert testUser;
    }

    /**
    *   testMethod: testTemplateCriteriaAccounts
    *   Tests listing template assignment to On trade accounts using template criteria
    *
    */
    static testMethod void testTemplateCriteriaAccounts() {
        setUser('EUR System Admin');
        
        System.runAs(testUser) {
            
            Id accountRecordTypeId = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_MA_On_Trade'].id;
            Id templateRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_JB_Template__c' and developername ='EUR_MA_On_Trade_Template'].id;
            Id templateCriteriaRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_JB_Template_Criteria__c' and developername ='EUR_MA_On_Trade_Template_Criteria'].id;
            Id groupOutletRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_Group_Outlet_Type__c' and developername ='EUR_MA_Group_Outlet_Type'].id;
            Id outletRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_Outlet_Type__c' and developername ='EUR_MA_Outlet_Type'].id;
            Id imageLevelRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_Image_Level__c' and developername ='EUR_MA_Image_Level'].id;
            Id volumePotentialRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_Volume_Potential__c' and developername ='EUR_MA_Volume_Potential'].id;
            
            EUR_CRM_Group_Outlet_Type__c groupOutletType = new EUR_CRM_Group_Outlet_Type__c(recordTypeId = groupOutletRecordTypeId, EUR_CRM_Name__c = 'Test');
            insert GroupOutletType;
            EUR_CRM_Outlet_Type__c outletType = new EUR_CRM_Outlet_Type__c(
                EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id,
                recordTypeId = outletRecordTypeId,
                EUR_CRM_Name__c = 'Test'
            );
            insert outletType;
            EUR_CRM_Image_Level__c imageLevel = new EUR_CRM_Image_Level__c(
                recordTypeId = imageLevelRecordTypeId,
                EUR_CRM_Name__c = 'Test'
            );
            insert imageLevel;
            EUR_CRM_Volume_Potential__c volumePotential = new EUR_CRM_Volume_Potential__c(
                recordTypeid = volumePotentialRecordTypeId,
                EUR_CRM_Name__c = 'Test'
            );
            insert volumePotential;
            
            EUR_CRM_JB_Template__c offTemplate = new EUR_CRM_JB_Template__c(name='test', recordTypeId = templateRecordTypeId);
            insert offTemplate;
            EUR_CRM_JB_Template_Criteria__c offTemplateCriteria = new EUR_CRM_JB_Template_Criteria__c(
                EUR_JB_Template__c = offTemplate.Id,
                recordTypeId = templateCriteriaRecordTypeId,
                EUR_JB_Active__c = true,
                EUR_JB_Group_Outlet_Type__c = groupOutletType.Id,
                EUR_JB_Outlet_Type__c = outletType.Id,
                EUR_JB_Image_Level__c = imageLevel.Id,
                EUR_JB_Volume_Potential__c = volumePotential.Id
            );
            insert offTemplateCriteria;            
            
            EUR_CRM_Account__c account = new EUR_CRM_Account__c(
                name='Test Account', recordTypeId = accountRecordTypeId,
                EUR_CRM_Outlet_Classification__c = 'Counter service', EUR_CRM_Outlet_Classification_Type__c = 'Wine & Spirits'
            );
            insert account;
            
            Test.startTest();
            
            account.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
            account.EUR_CRM_Outlet_Type__c = outletType.Id;
            account.EUR_CRM_Image_Level__c = imageLevel.Id;
            account.EUR_CRM_Volume_Potential__c = volumePotential.Id;
            
            update account;
            
            account = [SELECT EUR_CRM_Listing_Template__c FROM EUR_CRM_Account__c WHERE Id = :account.Id];
            
            System.assertEquals(offTemplate.Id, account.EUR_CRM_Listing_Template__c);
            
            Test.stopTest();
        }
    }

    /**
    *   testMethod: testCustomerTaxonomyAccounts
    *   Tests listing template assignment to Off trade accounts using customer taxonomy
    *
    */
    static testMethod void testCustomerTaxonomyAccounts() {
        setUser('EUR System Admin');
        
        System.runAs(testUser) {
            
            Id accountRecordTypeId = [select id from RecordType where sobjecttype='eur_crm_account__C' and developername ='EUR_MA_Off_Trade'].id;
            Id templateRecordTypeId = [select id from RecordType where sobjecttype='EUR_CRM_JB_Template__c' and developername ='EUR_MA_Off_Trade_Template'].id;
            Id customerTaxonomyRecordTypeId = [SELECT Id FROM RecordType WHERE sobjecttype='EUR_CRM_Customer_Taxonomy__c' AND Developername = 'EUR_MA_Off_Trade_Customer_Taxonomy'].id;

            EUR_CRM_Customer_Taxonomy__c customerTaxonomy = new EUR_CRM_Customer_Taxonomy__c(
                Name = 'Test',
                recordtypeid = customerTaxonomyRecordTypeId
            );
            insert customerTaxonomy;

            EUR_CRM_JB_Template__c offTemplate = new EUR_CRM_JB_Template__c(
                name='test', recordTypeId = templateRecordTypeId,
                EUR_CRM_Customer_Taxonomy__c = customerTaxonomy.Id
            );
            insert offTemplate;
            EUR_CRM_JB_Template_Criteria__c offTemplateCriteria = new EUR_CRM_JB_Template_Criteria__c(
                EUR_JB_Template__c = offTemplate.Id,
                EUR_JB_Active__c = true
            );
            insert offTemplateCriteria;

            EUR_CRM_Account__c account = new EUR_CRM_Account__c(
                name='Test Account', recordTypeId = accountRecordTypeId,
                EUR_CRM_Outlet_Classification__c = 'Counter service', EUR_CRM_Outlet_Classification_Type__c = 'Wine & Spirits'
            );
            insert account;
            
            Test.startTest();
            account.EUR_JB_Customer_Taxonomy__c = customerTaxonomy.Id;
            update account;
            
            account = [SELECT EUR_CRM_Listing_Template__c FROM EUR_CRM_Account__c WHERE Id = :account.Id];
            
            System.assertEquals(offTemplate.Id, account.EUR_CRM_Listing_Template__c);
            
            Test.stopTest();        
        }
    }
}