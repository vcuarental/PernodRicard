/**
Test Class for the following classes:
    EUR_CRM_MassUpdateImageLevelThreshold
    EUR_CRM_MassUpdateVolumeLevelThreshold
    EUR_CRM_VolumeLevelThresholdMassUpdate
    EUR_CRM_ImageLevelThresholdMassUpdate 

Date Created : Dec.16.2014
*/
@isTest
public class EUR_CRM_TestMassUpdateThresholds{

    static final String COUNTRY_CODE = 'LT';
    private static EUR_CRM_Account__c account;
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold;
    private static EUR_CRM_Criteria_Set__c criteriaSet;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer;
    private static EUR_CRM_Group_Outlet_Type__c groupOutlet;
    private static EUR_CRM_Outlet_Type__c outletType;
    private static EUR_CRM_Image_Level__c imageLevel;
    private static EUR_CRM_Image_Level_Threshold__c imageLvlThreshold;
    private static EUR_CRM_Volume_Potential__c volumePotential;
    private static EUR_CRM_Volume_Potential_Threshold__c volumePotentialThreshold;
    private static EUR_CRM_Pros_Image_Level__c prosImageLevel;
    private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential;
    private static EUR_CRM_Service_Pack__c servicePack;
    private static EUR_CRM_Affiliate__c affiliate;
    private static User user;

    public static void dataInsert(){

        account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'LT Direct - On Trade')[0];
        insert account;

        criteriaSet = EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1, 'LT Image Level Criteria')[0];
        insert criteriaSet;

        criteriaThreshold = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Picklist', criteriaSet.Id)[0];
        criteriaThreshold.EUR_CRM_Weight__c = 100;
        insert criteriaThreshold;

        criteriaAnswer = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Picklist', criteriaThreshold.Id)[0];
        criteriaAnswer.EUR_CRM_Value__c = null;
        criteriaAnswer.EUR_CRM_Weight__c = 90;
        criteriaAnswer.EUR_CRM_Base_Currency__c = 50;
        criteriaAnswer.EUR_CRM_Condition__c = 'Less Than or Equal (<=)';
        insert criteriaAnswer;

        groupOutlet = EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR LT Group Outlet', '', null, null)[0];
        groupOutlet.EUR_CRM_Group_Outlet_Name__c = 'Nightclub';
        insert groupOutlet;

        outletType = EUR_CRM_TestClassUtilityHelper.createOutletType(1, 'EUR LT Outlet Type', '', groupOutlet.Id)[0];
        insert outletType;

        imageLevel = EUR_CRM_TestClassUtilityHelper.createImageLevel(1, 'LT Image Level', '', groupOutlet.Id, 'Nightclub')[0];
        insert imageLevel;

        imageLvlThreshold = EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1, groupOutlet.Id, imageLevel.Id)[0];
        imageLvlThreshold.EUR_CRM_Min_Weight__c = 50;
        imageLvlThreshold.EUR_CRM_Is_Weight_Changed__c = true;
        insert imageLvlThreshold;

        volumePotential = EUR_CRM_TestClassUtilityHelper.createvolumePotential(1, 'LT Volume Potential', '', groupOutlet.Id, 'Medium')[0];
        insert volumePotential;

        volumePotentialThreshold = EUR_CRM_TestClassUtilityHelper.createvolumePotentialThreshold(1, groupOutlet.Id, volumePotential.Id)[0];
        volumePotentialThreshold.EUR_CRM_Min_Weight__c = 50;
        volumePotentialThreshold.EUR_CRM_Is_Weight_Changed__c = true;
        insert volumePotentialThreshold;

        prosSegmentation = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_' + COUNTRY_CODE + '_PROS_Segmentation', '', account.Id, groupOutlet.Id, null, imageLevel.Id, volumePotential.Id, null)[0];
        insert prosSegmentation;

        prosImageLevel = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, '', prosSegmentation.Id, criteriaThreshold.Id)[0];
        prosImageLevel.EUR_CRM_Weight__c = 98;
        insert prosImageLevel;

        prosVolPotential = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', '', prosSegmentation.Id, criteriaThreshold.Id)[0];
        prosVolPotential.EUR_CRM_Weight__c = 98;
        insert prosVolPotential;


    }
    @isTest
    static void testMassUpdateImageLevelThreshold() {
        dataInsert();
        Test.startTest();
        EUR_CRM_MassUpdateImageLevelThreshold theBatchJob = new EUR_CRM_MassUpdateImageLevelThreshold();
        theBatchJob.countryCodeStr = COUNTRY_CODE;
        theBatchJob.runBatchJob();
        Test.stopTest();
        System.assertNotEquals(0,ApexPages.getMessages().size());
    }
    @isTest
    static void testMassUpdateVolumuteLevelThreshold() {
        dataInsert();
        Test.startTest();
        EUR_CRM_MassUpdateVolumeLevelThreshold theBatchJob = new EUR_CRM_MassUpdateVolumeLevelThreshold();
        theBatchJob.countryCodeStr = COUNTRY_CODE;
        theBatchJob.runBatchJob();
        Test.stopTest();
        System.assertNotEquals(0,ApexPages.getMessages().size());
    }
}