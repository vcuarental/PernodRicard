@isTest(IsParallel=false)
public class EUR_CRM_MassUpdatePRS_Test {
public static EUR_CRM_Apex_Configuration__c createApexConfig(){
EUR_CRM_Apex_Configuration__c config = new EUR_CRM_Apex_Configuration__c();
config.EUR_CRM_Module__c = 'EUR_CRM_Account_Running_Number';
config.EUR_CRM_Country_Code__c='BG';
config.EUR_CRM_Account_RecordType_DevName__c='EUR_BG_Traditional_Off_Trade';
config.EUR_CRM_Prefix__c = 'f';
return config;
}
    public Static String RECORD_TYPE_BE_PRS_A_VP      = 'EUR_BE_PRS_Segmentation_Aspect_Volume_Potential';
    public Static String RECORD_TYPE_BE_PRS_A_IL      = 'EUR_BE_PRS_Segmentation_Aspect_Image_Level';

    @testSetup static void createConfig(){
        EUR_CRM_Apex_Configuration__c config = new EUR_CRM_Apex_Configuration__c();
        config.EUR_CRM_Module__c = 'EUR_CRM_Account_Running_Number';
        config.EUR_CRM_Country_Code__c='BG';
        config.EUR_CRM_Account_RecordType_DevName__c='EUR_BG_Traditional_Off_Trade';
        config.EUR_CRM_Prefix__c = 'f';
        insert config;
    }

    static testMethod void testEUR_CRM_MassUpdatePRSFinalResultBatchBBP()
    {
        //EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        //apexConfig = createApexConfig();
        //insert apexConfig;

        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG();

//        Test.startTest();
        System.RunAS(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA){
            Id rtid = [SELECT id from recordType where SObjectType = 'EUR_CRM_PRS_Seg_Aspect_Criteria__c' and DeveloperName = 'EUR_PRS_Segmentation_Aspect_Criteria_BBP' Limit 1].id;
            EUR_CRM_PRS_Seg_Aspect_Criteria__c PRS_SAC = [select Id,EUR_CRM_Is_Weight_Changed__c from EUR_CRM_PRS_Seg_Aspect_Criteria__c
            where EUR_CRM_Is_Weight_Changed__c = false and recordtypeId = :rtid Limit 1];
            PRS_SAC.EUR_CRM_Is_Weight_Changed__c = True;
            UPdate PRS_SAC;
        }


        //test.startTest();
        EUR_CRM_MassUpdatePRSFinalResultBatch batchjob = new EUR_CRM_MassUpdatePRSFinalResultBatch('BG','BrandBuilding');
        database.executeBatch(batchjob);
//        Test.stopTest();
    }

    static  testMethod void testEUR_CRM_MassUpdatePRSFinalResultBatchBP()
    {
        //EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        //apexConfig = createApexConfig();
        //insert apexConfig;

        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG();

//        Test.startTest();
        System.RunAS(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA){
            Id rtid = [SELECT id from recordType where SObjectType = 'EUR_CRM_PRS_Seg_Aspect_Criteria__c' and DeveloperName = 'EUR_PRS_Segmentation_Aspect_Criteria_BP' Limit 1].id;
            EUR_CRM_PRS_Seg_Aspect_Criteria__c PRS_SAC = [select Id,EUR_CRM_Is_Weight_Changed__c from EUR_CRM_PRS_Seg_Aspect_Criteria__c
            where EUR_CRM_Is_Weight_Changed__c = false and recordtypeId = :rtid Limit 1];
            PRS_SAC.EUR_CRM_Is_Weight_Changed__c = true;
            update PRS_SAC;
        }
        //GDT test.startTest();
        EUR_CRM_MassUpdatePRSFinalResultBatch batchjob = new EUR_CRM_MassUpdatePRSFinalResultBatch('BG','BusinessPotential');
        database.executeBatch(batchjob);
        //GDT test.stopTest();
//        Test.stopTest();
    }

    static  testMethod void testEUR_CRM_MassUpdatePRSFinalResultBatchIL()
    {
        //EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        //apexConfig = createApexConfig();
        //insert apexConfig;

        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG();

//        Test.startTest();
        System.RunAS(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA){
            Id rtid = [SELECT id from recordType where SObjectType = 'EUR_CRM_PRS_Seg_Aspect_Criteria__c' and DeveloperName = 'EUR_PRS_Segmentation_Aspect_Criteria_BP' Limit 1].id;
            EUR_CRM_PRS_Seg_Aspect_Criteria__c PRS_SAC = [select Id,EUR_CRM_Is_Weight_Changed__c from EUR_CRM_PRS_Seg_Aspect_Criteria__c
            where EUR_CRM_Is_Weight_Changed__c = false and recordtypeId = :rtid Limit 1];
            PRS_SAC.EUR_CRM_Is_Weight_Changed__c = true;
            update PRS_SAC;
        }
        //GDT test.startTest();
        EUR_CRM_MassUpdatePRSFinalResultBatch batchjob = new EUR_CRM_MassUpdatePRSFinalResultBatch('BG','ImageLevel');
        database.executeBatch(batchjob);
        //GDT test.stopTest();
//        Test.stopTest();
    }

    static  testMethod void testEUR_CRM_MassUpdatePRSFinalResultBatchVP()
    {
        //EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        //apexConfig = createApexConfig();
        //insert apexConfig;

        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG();

//        Test.startTest();
        System.RunAS(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA){
            Id rtid = [SELECT id from recordType where SObjectType = 'EUR_CRM_PRS_Seg_Aspect_Criteria__c' and DeveloperName = 'EUR_PRS_Segmentation_Aspect_Criteria_BP' Limit 1].id;
            EUR_CRM_PRS_Seg_Aspect_Criteria__c PRS_SAC = [select Id,EUR_CRM_Is_Weight_Changed__c from EUR_CRM_PRS_Seg_Aspect_Criteria__c
            where EUR_CRM_Is_Weight_Changed__c = false and recordtypeId = :rtid Limit 1];
            PRS_SAC.EUR_CRM_Is_Weight_Changed__c = true;
            update PRS_SAC;
        }
        //GDT test.startTest();
        EUR_CRM_MassUpdatePRSFinalResultBatch batchjob = new EUR_CRM_MassUpdatePRSFinalResultBatch('BG','VolumePotential');
        database.executeBatch(batchjob);
        //GDT test.stopTest();
//        Test.stopTest();
    }

    static testMethod void testEUR_CRM_MassUpdatePRSFinalResultCriteria()
    {
        //EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
        //apexConfig = createApexConfig();
        //insert apexConfig;

        EUR_CRM_PRS_TestClassUtilityHelper.testInitBG();

//        Test.startTest();
        System.RunAS(EUR_CRM_PRS_TestClassUtilityHelper.BG_UserA){
            Id rtidbbp = [SELECT id from recordType where SObjectType = 'EUR_CRM_PRS_Seg_Aspect_Criteria__c' and DeveloperName = 'EUR_PRS_Segmentation_Aspect_Criteria_BBP' Limit 1].id;
            EUR_CRM_PRS_Seg_Aspect_Criteria__c PRS_SAC1 = [select Id,EUR_CRM_Is_Weight_Changed__c from EUR_CRM_PRS_Seg_Aspect_Criteria__c
            where EUR_CRM_Is_Weight_Changed__c = false and recordtypeId = :rtidbbp Limit 1];
            PRS_SAC1.EUR_CRM_Is_Weight_Changed__c = true;
            update PRS_SAC1;

            Id rtidbp = [SELECT id from recordType where SObjectType = 'EUR_CRM_PRS_Seg_Aspect_Criteria__c' and DeveloperName = 'EUR_PRS_Segmentation_Aspect_Criteria_BP' Limit 1].id;
            EUR_CRM_PRS_Seg_Aspect_Criteria__c PRS_SAC2 = [select Id,EUR_CRM_Is_Weight_Changed__c from EUR_CRM_PRS_Seg_Aspect_Criteria__c
            where EUR_CRM_Is_Weight_Changed__c = false and recordtypeId = :rtidbp Limit 1];
            PRS_SAC2.EUR_CRM_Is_Weight_Changed__c = true;
            update PRS_SAC2;

            Id rtidil = [SELECT id from recordType where SObjectType = 'EUR_CRM_PRS_Seg_Aspect_Criteria__c' and DeveloperName = 'EUR_PRS_Segmentation_Aspect_Criteria_Image_Level' Limit 1].id;
            EUR_CRM_PRS_Seg_Aspect_Criteria__c PRS_SAC3 = [select Id,EUR_CRM_Is_Weight_Changed__c from EUR_CRM_PRS_Seg_Aspect_Criteria__c
            where EUR_CRM_Is_Weight_Changed__c = false and recordtypeId = :rtidil Limit 1];
            PRS_SAC3.EUR_CRM_Is_Weight_Changed__c = true;
            update PRS_SAC3;

            Id rtidvp = [SELECT id from recordType where SObjectType = 'EUR_CRM_PRS_Seg_Aspect_Criteria__c' and DeveloperName = 'EUR_PRS_Segmentation_Aspect_Criteria_Volume_Potential' Limit 1].id;
            EUR_CRM_PRS_Seg_Aspect_Criteria__c PRS_SAC4 = [select Id,EUR_CRM_Is_Weight_Changed__c from EUR_CRM_PRS_Seg_Aspect_Criteria__c
            where EUR_CRM_Is_Weight_Changed__c = false and recordtypeId = :rtidvp Limit 1];
            PRS_SAC4.EUR_CRM_Is_Weight_Changed__c = true;
            update PRS_SAC4;
        }

        //GDT test.startTest();
        EUR_CRM_MassUpdatePRSFinalResultCriteria batchjob = new EUR_CRM_MassUpdatePRSFinalResultCriteria();
        batchjob.countryCodeStr = 'BG';
        batchjob.runBrandBuildingBatchJob();
        batchjob.runBusinessPotentialBatchJob();
        batchjob.runImageLevelBatchJob();
        batchjob.runVolumePotentialBatchJob();
        //GDT test.stopTest();
//        Test.stopTest();
    }

    static testMethod void testEUR_CRM_MassUpdatePRSFinalResultCriteria2()
    {
        EUR_CRM_MassUpdatePRSFinalResultCriteria batchjob = new EUR_CRM_MassUpdatePRSFinalResultCriteria();
        batchjob.countryCodeStr = 'BG';
        batchjob.runBrandBuildingBatchJob();
        batchjob.runBusinessPotentialBatchJob();
        batchjob.runImageLevelBatchJob();
        batchjob.runVolumePotentialBatchJob();
    }

}