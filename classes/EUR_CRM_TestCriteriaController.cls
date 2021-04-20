/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_CriteriaController Class.
  @Author:      IPC
  @History:     APR.19.2014 - Created
                APR.24.2014 - modified methods and test data creation.
                APR.24.2014 - Added testMethods - testCriteria0 (validateSheet = false) and testCriteria3 (handle catch/error)
*/
@isTest (SeeAllData=true)
public with sharing class EUR_CRM_TestCriteriaController {
    private static User user;
    private static EUR_CRM_Account__c account;
    private static EUR_CRM_Affiliate__c affiliate;
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold;
    private static EUR_CRM_Criteria_Set__c criteriaSet;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer;
    private static EUR_CRM_Group_Outlet_Type__c groupOutlet;
    private static EUR_CRM_Image_Level__c imageLevel;
    private static EUR_CRM_Image_Level_Threshold__c imageLvlThreshold;
    private static EUR_CRM_Volume_Potential__c volumePotential;
    private static EUR_CRM_Volume_Potential_Threshold__c volumePotentialThreshold;
    private static EUR_CRM_Pros_Image_Level__c prosImageLevel;
    private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential;
    
    public static void dataInsert(){
        
        account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'LT Direct - On Trade')[0];
        account.EUR_CRM_Sub_Channel__c = 'Retail';
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
        
        imageLevel = EUR_CRM_TestClassUtilityHelper.createImageLevel(1, 'LT Image Level', '', groupOutlet.Id, 'Nightclub')[0];
        insert imageLevel;
        
        imageLvlThreshold = EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1, groupOutlet.Id, imageLevel.Id)[0];
        imageLvlThreshold.EUR_CRM_Min_Weight__c = 50;
        insert imageLvlThreshold;
        
        volumePotential = EUR_CRM_TestClassUtilityHelper.createvolumePotential(1, 'LT Volume Potential', '', groupOutlet.Id, 'Medium')[0];
        insert volumePotential;
        
        volumePotentialThreshold = EUR_CRM_TestClassUtilityHelper.createvolumePotentialThreshold(1, groupOutlet.Id, volumePotential.Id)[0];
        volumePotentialThreshold.EUR_CRM_Min_Weight__c = 50;
        insert volumePotentialThreshold;
        
        prosSegmentation = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_LT_PROS_Segmentation', '', account.Id, groupOutlet.Id, null, imageLevel.Id, volumePotential.Id, null)[0];
        insert prosSegmentation;
        
        prosImageLevel = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, '', prosSegmentation.Id, criteriaThreshold.Id)[0];
        prosImageLevel.EUR_CRM_Weight__c = 98;
        insert prosImageLevel;
        
        prosVolPotential = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', '', prosSegmentation.Id, criteriaThreshold.Id)[0];
        prosVolPotential.EUR_CRM_Weight__c = 98;
        insert prosVolPotential;
    }
    
    static testMethod void testCriteria0(){
        dataInsert();
        
        test.startTest();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_CriteriaSheet');
        rf.getParameters().put('id', prosSegmentation.id);
        //Criteria type 1 = IMAGE_LEVEL
        rf.getParameters().put('type','1');
        Test.setCurrentPage(rf);
        
        EUR_CRM_CriteriaController controller = new EUR_CRM_CriteriaController(standardController);
        
        imageLvlThreshold.EUR_CRM_Min_Weight__c = null;
        update imageLvlThreshold;
        
        prosImageLevel.EUR_CRM_Weight__c = null;
        update prosImageLevel;
        
        Map<Id, String> ansMap = new Map<Id, String>();
        ansMap.put(criteriaThreshold.Id, '');
        controller.answerSheet = ansMap;
        
        controller.returnAnswerSheet();
        controller.saveCriteriaSheet();
        test.stopTest();
    }
    
    static testMethod void testCriteria1(){
        dataInsert();
        test.startTest();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_CriteriaSheet');
        rf.getParameters().put('id', prosSegmentation.id);
        //Criteria type 1 = IMAGE_LEVEL
        rf.getParameters().put('type','1');
        Test.setCurrentPage(rf);
        
        Map<Id, EUR_CRM_Criteria_Threshold__c> criteriaThreshold_Map = new Map<Id, EUR_CRM_Criteria_Threshold__c>();
        criteriaThreshold_Map.put(criteriaThreshold.Id, criteriaThreshold);
        
        Map<Id, List<EUR_CRM_Criteria_Answer__c>> criteriaAnswer_Map = new Map<Id, List<EUR_CRM_Criteria_Answer__c>>();
        List<EUR_CRM_Criteria_Answer__c> criteriaAns = new List<EUR_CRM_Criteria_Answer__c>();
        criteriaAns.add(criteriaAnswer); 
        criteriaAnswer_Map.put(criteriaAnswer.Id, criteriaAns);
        
        List<EUR_CRM_Image_Level_Threshold__c> imageLvl = new List<EUR_CRM_Image_Level_Threshold__c>();
        imageLvl.add(imageLvlThreshold); 
        
        List<EUR_CRM_Volume_Potential_Threshold__c> volPotential = new List<EUR_CRM_Volume_Potential_Threshold__c>();
        volPotential.add(volumePotentialThreshold); 
                
        EUR_CRM_CriteriaController controller = new EUR_CRM_CriteriaController(standardController);
        EUR_CRM_CriteriaManager criteriaManager = new EUR_CRM_CriteriaManager();
        EUR_CRM_CriteriaFactory criteriaFactory = new EUR_CRM_CriteriaFactory();
        
        controller.setCriteriaSetInfo(criteriaSet);
        controller.setCriteriaThreshold(criteriaThreshold_Map);
        controller.setCriteriaAnswers(criteriaAnswer_Map);
        controller.setAnswers(criteriaAns);
        controller.setImageLevelThresholds(imageLvl); 
        controller.setVolumePotentialThresholds(volPotential);
           
        controller.getCriteriaThresholds();
        controller.getAnswers();
        controller.getCriteriaAnswers();
        //controller.returnAnswerSheet();
        
        controller.getImageLevelThresholds(groupOutlet.Id);
        controller.getVolumePotentialThresholds(groupOutlet.Id);
        //controller.getCustomForm();
        controller.saveCriteriaSheet();
        controller.addRequiredMessage();
        test.stopTest();
    }
    
    static testMethod void testCriteria2(){
        dataInsert();
        test.startTest();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_CriteriaSheet');
        rf.getParameters().put('id', prosSegmentation.id);
        //Criteria type 1 = VOLUME_POTENTIAL
        rf.getParameters().put('type','2');
        Test.setCurrentPage(rf);
        
        Map<Id, EUR_CRM_Criteria_Threshold__c> criteriaThreshold_Map = new Map<Id, EUR_CRM_Criteria_Threshold__c>();
        criteriaThreshold_Map.put(criteriaThreshold.Id, criteriaThreshold);
        
        Map<Id, List<EUR_CRM_Criteria_Answer__c>> criteriaAnswer_Map = new Map<Id, List<EUR_CRM_Criteria_Answer__c>>();
        List<EUR_CRM_Criteria_Answer__c> criteriaAns = new List<EUR_CRM_Criteria_Answer__c>();
        criteriaAns.add(criteriaAnswer); 
        criteriaAnswer_Map.put(criteriaAnswer.Id, criteriaAns);
        
        List<EUR_CRM_Image_Level_Threshold__c> imageLvl = new List<EUR_CRM_Image_Level_Threshold__c>();
        imageLvl.add(imageLvlThreshold); 
        
        List<EUR_CRM_Volume_Potential_Threshold__c> volPotential = new List<EUR_CRM_Volume_Potential_Threshold__c>();
        volPotential.add(volumePotentialThreshold); 
                
        EUR_CRM_CriteriaController controller = new EUR_CRM_CriteriaController(standardController);
        //EUR_CRM_CriteriaManager criteriaManager = new EUR_CRM_CriteriaManager();
        controller.setCriteriaSetInfo(criteriaSet);
        controller.setCriteriaThreshold(criteriaThreshold_Map);
        controller.setCriteriaAnswers(criteriaAnswer_Map);
        controller.setAnswers(criteriaAns);
        controller.setImageLevelThresholds(imageLvl); 
        controller.setVolumePotentialThresholds(volPotential);
        
        controller.getCriteriaThresholds();
        controller.getAnswers();
        controller.getCriteriaAnswers();
        //controller.returnAnswerSheet();
        
        controller.getImageLevelThresholds(groupOutlet.Id);
        controller.getVolumePotentialThresholds(groupOutlet.Id);
        controller.getCustomForm();
        controller.saveCriteriaSheet();
        controller.addRequiredMessage();
        test.stopTest();
    }
    
    static testMethod void testCriteria3(){
        dataInsert();
        
        test.startTest();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_CriteriaSheet');
        rf.getParameters().put('id', prosSegmentation.id);
        //Criteria type 1 = IMAGE_LEVEL
        rf.getParameters().put('type','1');
        Test.setCurrentPage(rf);
        
        Map<Id, EUR_CRM_Criteria_Threshold__c> criteriaThreshold_Map = new Map<Id, EUR_CRM_Criteria_Threshold__c>();
        criteriaThreshold_Map.put(criteriaThreshold.Id, criteriaThreshold);
        
        Map<Id, List<EUR_CRM_Criteria_Answer__c>> criteriaAnswer_Map = new Map<Id, List<EUR_CRM_Criteria_Answer__c>>();
        List<EUR_CRM_Criteria_Answer__c> criteriaAns = new List<EUR_CRM_Criteria_Answer__c>();
        criteriaAns.add(criteriaAnswer); 
        criteriaAnswer_Map.put(criteriaAnswer.Id, criteriaAns);
        
        List<EUR_CRM_Image_Level_Threshold__c> imageLvl = new List<EUR_CRM_Image_Level_Threshold__c>();
        imageLvl.add(imageLvlThreshold); 
        
        List<EUR_CRM_Volume_Potential_Threshold__c> volPotential = new List<EUR_CRM_Volume_Potential_Threshold__c>();
        volPotential.add(volumePotentialThreshold); 
                
        EUR_CRM_CriteriaController controller = new EUR_CRM_CriteriaController(standardController);
        EUR_CRM_CriteriaManager criteriaManager = new EUR_CRM_CriteriaManager();
        EUR_CRM_CriteriaFactory criteriaFactory = new EUR_CRM_CriteriaFactory();
        
        imageLvlThreshold.EUR_CRM_Min_Weight__c = null;
        update imageLvlThreshold;
        
        prosImageLevel.EUR_CRM_Weight__c = null;
        update prosImageLevel;
        
        controller.setCriteriaSetInfo(criteriaSet);
        controller.setCriteriaThreshold(criteriaThreshold_Map);
        controller.setCriteriaAnswers(criteriaAnswer_Map);
        controller.setAnswers(criteriaAns);
        controller.setImageLevelThresholds(imageLvl); 
        controller.setVolumePotentialThresholds(volPotential);
           
        controller.getCriteriaThresholds();
        controller.getAnswers();
        controller.getCriteriaAnswers();
        
        controller.getImageLevelThresholds(groupOutlet.Id);
        controller.getVolumePotentialThresholds(groupOutlet.Id);
        controller.saveCriteriaSheet();
        controller.addRequiredMessage();
        test.stopTest();
    }
}