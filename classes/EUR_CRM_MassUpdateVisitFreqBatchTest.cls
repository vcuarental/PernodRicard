@isTest
public class EUR_CRM_MassUpdateVisitFreqBatchTest {
    static string COUNTRY_CODE{get;set;}
    
    static void dataInsert()
    {
        COUNTRY_CODE = 'BG';
         Id rtId = [select id from recordtype where developername = 'EUR_BG_Wholesaler' and sobjecttype = 'eur_crm_account__c' limit 1].id;
        EUR_CRM_Group_Outlet_Type__c goutletType = new EUR_CRM_Group_Outlet_Type__c(EUR_CRM_Name__c='Restaurant');
        insert goutletType;
        EUR_CRM_Outlet_Type__c outletType = new EUR_CRM_Outlet_Type__c(EUR_CRM_Name__c='Restaurant', EUR_CRM_Group_Outlet_Type__c=goutletType.Id);
        insert outletType;
        EUR_CRM_Image_Level__c imgLevel = new EUR_CRM_Image_Level__c(EUR_CRM_Name__c='Leading');
        insert imgLevel;
        EUR_CRM_Volume_Potential__c volPotential = new EUR_CRM_Volume_Potential__c(EUR_CRM_Name__c='High');
        insert volPotential;
        EUR_CRM_Visit_Frequency__c visitFreq = new EUR_CRM_Visit_Frequency__c(name='once a week');
        insert visitFreq;
        EUR_CRM_Visit_Frequency_Criteria__c visitCriteria = new EUR_CRM_Visit_Frequency_Criteria__c(EUR_CRM_Visit_Frequency__c=visitFreq.Id, 
            EUR_CRM_Group_Outlet_Type__c=goutletType.Id, EUR_CRM_Outlet_Type__c=outletType.Id, EUR_CRM_Image_Level__c=imgLevel.Id, EUR_CRM_Volume_Potential__c=volPotential.id);
        insert visitCriteria;
        
        List<EUR_CRM_Customer_Taxonomy__c> CustomerTaxonomys = New List<EUR_CRM_Customer_Taxonomy__c>();
        
        EUR_CRM_Customer_Taxonomy__c CustomerTaxonomy1 = New EUR_CRM_Customer_Taxonomy__c(Name = 'BG_OFF_Wholesalers',
                                                                                          EUR_CRM_External_ID__c = 'BG_OFF_Wholesalers',
                                                                                          RecordTypeId = [SELECT Id FROM RecordType Where sObjectType = 'EUR_CRM_Customer_Taxonomy__c' and DeveloperName = 'EUR_BG_Wholesalers_Customer_Taxonomy' Limit 1].ID, 
                                                                                          EUR_CRM_Level_1__c = 'Wholesalers',
                                                                                          EUR_CRM_Level_2__c = 'Wholesalers');
        
        EUR_CRM_Customer_Taxonomy__c CustomerTaxonomy2 = New EUR_CRM_Customer_Taxonomy__c(Name = 'BG_Traditional',
                                                                                          EUR_CRM_External_ID__c = 'BG_Traditional',
                                                                                          RecordTypeId = [SELECT Id FROM RecordType Where sObjectType = 'EUR_CRM_Customer_Taxonomy__c' and DeveloperName = 'EUR_BG_Traditional_Off_Trade_Customer_Taxonomy' Limit 1].ID, 
                                                                                          EUR_CRM_Level_1__c = 'Traditional',
                                                                                          EUR_CRM_Level_2__c = 'Traditional');
        CustomerTaxonomys.add(CustomerTaxonomy1);
        CustomerTaxonomys.add(CustomerTaxonomy2);
        
        insert CustomerTaxonomys;
        
        EUR_CRM_Account__c acct = new EUR_CRM_Account__c(Name='GB test on trade Supplier account');
        acct.EUR_CRM_Group_Outlet_Type__c = goutletType.Id;
        acct.EUR_CRM_Outlet_Type__c = outletType.Id;
        acct.EUR_CRM_Image_Level__c = imgLevel.id;
        acct.EUR_CRM_Volume_Potential__c = volPotential.Id;
        acct.recordtypeid = rtId;
        acct.EUR_CRM_Status__c = 'Inactive';
        //acct.EUR_JB_Customer_Taxonomy__c = CunstomerTaxonomy.Id;
        insert acct;
    }
    static testmethod void testMassUpdateImageLevelThreshold() {
        dataInsert();
        Test.startTest();
        //EUR_CRM_MassUpdateVisitFrequencyBatch theBatchJob = new EUR_CRM_MassUpdateVisitFrequencyBatch(COUNTRY_CODE);
        //theBatchJob.countryCodeStr = COUNTRY_CODE;
        //Database.executeBatch(theBatchJob);
        EUR_CRM_MassUpdateVisitFrequencyCntrl ctrl = new EUR_CRM_MassUpdateVisitFrequencyCntrl();
        ctrl.countryCodeStr  = COUNTRY_CODE;
        ctrl.updateVF();
        Test.stopTest();
    } 
}