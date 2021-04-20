@isTest
public class EUR_CRM_MassUpdatePRSQuestionBatchTest {
    
    @TestSetup
    static void setupDate() 
    {
       EUR_CRM_PRS_TestClassUtilityHelper.testInitBG_2nd();
       //EUR_CRM_PRS_TestClassUtilityHelper.testInitBE();
    }
    
    public static EUR_CRM_Apex_Configuration__c createApexConfig(){
        EUR_CRM_Apex_Configuration__c config = new EUR_CRM_Apex_Configuration__c();
        config.EUR_CRM_Module__c = 'EUR_CRM_Account_Running_Number';
        config.EUR_CRM_Country_Code__c='BG';
        config.EUR_CRM_Account_RecordType_DevName__c='EUR_BG_Traditional_Off_Trade';
        config.EUR_CRM_Prefix__c = 'f';
        return config;
    }
    
    static testMethod void testEUR_CRM_MassUpdatePRSQuestionsExtBBP()
   {
       EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
       apexConfig = createApexConfig();
       insert apexConfig;
       test.startTest();
       EUR_CRM_MassUpdatePRSQuestionsExt  batchjob = new EUR_CRM_MassUpdatePRSQuestionsExt();
       batchjob.enableBBPBool = true;
       batchjob.countryCodeStr = 'BG';
       batchjob.criteriaSetLevel = 'Brand_Building_Potential';
       batchjob.runBrandBuildingBatchJob();
       batchjob.runBusinessPotentialBatchJob();
       test.stopTest();
   }
    
   static testMethod void testEUR_CRM_MassUpdatePRSQuestionsExtBP()
   {
       EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
       apexConfig = createApexConfig();
       insert apexConfig;
       test.startTest();
       EUR_CRM_MassUpdatePRSQuestionsExt  batchjob = new EUR_CRM_MassUpdatePRSQuestionsExt();
       batchjob.enableBPBool = true;
       batchjob.countryCodeStr = 'BG';
       batchjob.criteriaSetLevel = 'BusinessPotential';
       batchjob.runBrandBuildingBatchJob();
       batchjob.runBusinessPotentialBatchJob();
       test.stopTest();
   }
     
    static testMethod void testEUR_CRM_MassUpdatePRSQuestionsExtIL()
   {
       EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
       apexConfig = createApexConfig();
       insert apexConfig;
       test.startTest();
       EUR_CRM_MassUpdatePRSQuestionsExt  batchjob = new EUR_CRM_MassUpdatePRSQuestionsExt();
       batchjob.enableILBool = true;
       batchjob.countryCodeStr = 'BG';
       batchjob.criteriaSetLevel = 'ImageLevel';
       batchjob.runImageLevelBatchJob();
       batchjob.runBusinessPotentialBatchJob();
       test.stopTest();
   } 
    
    static testMethod void testEUR_CRM_MassUpdatePRSQuestionsExtVP()
   {
       EUR_CRM_Apex_Configuration__c apexConfig = new EUR_CRM_Apex_Configuration__c();
       apexConfig = createApexConfig();
       insert apexConfig;
       test.startTest();
       EUR_CRM_MassUpdatePRSQuestionsExt  batchjob = new EUR_CRM_MassUpdatePRSQuestionsExt();
       batchjob.enableVPBool = true;
       batchjob.countryCodeStr = 'BG';
       batchjob.criteriaSetLevel = 'VolumePotential';
       batchjob.runVolumePotentialBatchJob();
       batchjob.runBusinessPotentialBatchJob();
       test.stopTest();
   }
    
    static testMethod void testEUR_CRM_MassUpdatePRSQuestionsExt()
    {
        EUR_CRM_MassUpdatePRSQuestionsBatch batch = new EUR_CRM_MassUpdatePRSQuestionsBatch('BE');
        
    }
    
    static testMethod void testcalculateAnswerWeight()
    {
        EUR_CRM_MassUpdatePRSQuestionsBatch batch = new EUR_CRM_MassUpdatePRSQuestionsBatch('BE');
        double result;
        test.startTest();
        List<EUR_CRM_PRS_Question_Criteria__c> testQuestion = new List<EUR_CRM_PRS_Question_Criteria__c>();
        result = batch.calculateAnswerWeight(testQuestion, 1, null, 'Currency_Input');
        system.assertEquals(0, result);
        test.stopTest();
    }
   
}