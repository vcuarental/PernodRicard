/*********************************************************************************
 * Name: ASI_CRM_TH_TestCriteriaController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_TestCriteriaController
*********************************************************************************/
@isTest (SeeAllData=true)
public with sharing class ASI_CRM_TH_TestCriteriaController{
    private static User user;
    private static ASI_CRM_AccountsAdditionalField__c account;
    private static ASI_CRM_Pros_Segmentation__c prosSegmentation;
    private static ASI_CRM_Criteria_Threshold__c criteriaThreshold;
    private static ASI_CRM_Criteria_Set__c criteriaSet;
    private static ASI_CRM_Criteria_Answer__c criteriaAnswer;
    private static ASI_CRM_Group_Outlet_Type__c groupOutlet;
    private static ASI_CRM_Image_Level__c imageLevel;
    private static ASI_CRM_Image_Level_Threshold__c imageLvlThreshold;
    private static ASI_CRM_Volume_Potential__c volumePotential;
    private static ASI_CRM_Volume_Potential_Threshold__c volumePotentialThreshold;
    private static ASI_CRM_Pros_Image_Level__c prosImageLevel;
    private static ASI_CRM_Pros_Volume_Potential__c prosVolPotential;
    
    public static void dataInsert(){
        Account acc = new Account(RecordTypeId = Global_RecordTypeCache.getRTId('AccountASI_TH_CRM_Outlet'), Name = 'TestAccount');
        insert acc;
        
        ASI_CRM_CN_Channel__c ch = new ASI_CRM_CN_Channel__c();
        ch.ASI_CRM_CN_Channel_Chi_Name__c = 'Channel';
        insert ch;
        
        ASI_MFM_Sub_Channel__c sc = new ASI_MFM_Sub_Channel__c();
        sc.ASI_CRM_CN_Channel__c = ch.id;
        insert sc;
        
        ASI_TH_CRM_OutletType__c ot = new ASI_TH_CRM_OutletType__c();
        ot.ASI_CRM_Sub_Channel__c = sc.id;
        insert ot;
          
        account = new ASI_CRM_AccountsAdditionalField__c(Name = 'Test', RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Outlet'),
                                                         ASI_CRM_Account__c = acc.id, ASI_TH_CRM_OutletType__c = ot.id, ASI_CRM_Region__c = 'South');
        insert account;
           
        criteriaSet = ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaSet(1, 'ASI_CRM_TH_Image_Level_Criteria')[0];
        insert criteriaSet;
        
        criteriaThreshold = ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaThreshold(1, 'ASI_CRM_TH_Picklist', criteriaSet.Id)[0];
        criteriaThreshold.ASI_CRM_SG_Weight__c = 100;
        insert criteriaThreshold;
        
        criteriaAnswer = ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaAnswer(1, 'ASI_CRM_TH_Picklist', criteriaThreshold.Id)[0];
        criteriaAnswer.ASI_CRM_SG_Value__c = null;
        criteriaAnswer.ASI_CRM_SG_Weight__c = 90;
        criteriaAnswer.ASI_CRM_SG_Base_Currency__c = 50;
        criteriaAnswer.ASI_CRM_SG_Condition__c = 'Less Than or Equal (<=)';
        insert criteriaAnswer;
                
        groupOutlet = ASI_CRM_TH_TestClassUtilityHelperPROS.createGroupOutletType(1, 'ASI_CRM_TH_Group_Outlet_Type', '', null, null)[0];
        groupOutlet.ASI_CRM_SG_Group_Outlet_Name__c = 'Nightclub';
        insert groupOutlet;
        
        imageLevel = ASI_CRM_TH_TestClassUtilityHelperPROS.createImageLevel(1, 'ASI_CRM_TH_Image_Level', '', groupOutlet.Id, 'Nightclub')[0];
        insert imageLevel;
        
        imageLvlThreshold = ASI_CRM_TH_TestClassUtilityHelperPROS.createImageLevelThreshold(1, groupOutlet.Id, imageLevel.Id)[0];
        imageLvlThreshold.ASI_CRM_SG_Min_Weight__c = 50;
        insert imageLvlThreshold;
        
        volumePotential = ASI_CRM_TH_TestClassUtilityHelperPROS.createvolumePotential(1, 'ASI_CRM_TH_Volume_Potential', '', groupOutlet.Id, 'Medium')[0];
        insert volumePotential;
        
        volumePotentialThreshold = ASI_CRM_TH_TestClassUtilityHelperPROS.createvolumePotentialThreshold(1, groupOutlet.Id, volumePotential.Id)[0];
        volumePotentialThreshold.ASI_CRM_SG_Min_Weight__c = 50;
        insert volumePotentialThreshold;
        
        prosSegmentation = ASI_CRM_TH_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_TH_PROS_Segmentation', '', account.Id, groupOutlet.Id, null, imageLevel.Id, volumePotential.Id)[0];
        insert prosSegmentation;
        
        prosImageLevel = ASI_CRM_TH_TestClassUtilityHelperPROS.createProsImageLevel(1, 'ASI_CRM_TH_Pros_Image_Level', '', prosSegmentation.Id, criteriaThreshold.Id)[0];
        prosImageLevel.ASI_CRM_SG_Weight__c = 98;
        insert prosImageLevel;
        
        prosVolPotential = ASI_CRM_TH_TestClassUtilityHelperPROS.createProsVolumePotential(1, 'ASI_CRM_TH_Pros_Volume_Potential', '', prosSegmentation.Id, criteriaThreshold.Id)[0];
        prosVolPotential.ASI_CRM_SG_Weight__c = 98;
        insert prosVolPotential;
    }
    
    static testMethod void testCriteria0(){
        dataInsert();
        
        test.startTest();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/ASI_CRM_TH_CriteriaSheet');
        rf.getParameters().put('id', prosSegmentation.id);
        //Criteria type 1 = IMAGE_LEVEL
        rf.getParameters().put('type','1');
        Test.setCurrentPage(rf);
        
        ASI_CRM_TH_CriteriaController controller = new ASI_CRM_TH_CriteriaController(standardController);
        
        List<ASI_CRM_Image_Level_Threshold__c> imageLvl = new List<ASI_CRM_Image_Level_Threshold__c>();
        imageLvl.add(imageLvlThreshold); 
        
        /*imageLvlThreshold.ASI_CRM_SG_Min_Weight__c = null;
        update imageLvlThreshold;*/
        
        prosImageLevel.ASI_CRM_SG_Weight__c = null;
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
        PageReference rf = new Pagereference('/apex/ASI_CRM_TH_CriteriaSheet');
        rf.getParameters().put('id', prosSegmentation.id);
        //Criteria type 1 = IMAGE_LEVEL
        rf.getParameters().put('type','1');
        Test.setCurrentPage(rf);
        
        Map<Id, ASI_CRM_Criteria_Threshold__c> criteriaThreshold_Map = new Map<Id, ASI_CRM_Criteria_Threshold__c>();
        criteriaThreshold_Map.put(criteriaThreshold.Id, criteriaThreshold);
        
        Map<Id, List<ASI_CRM_Criteria_Answer__c>> criteriaAnswer_Map = new Map<Id, List<ASI_CRM_Criteria_Answer__c>>();
        List<ASI_CRM_Criteria_Answer__c> criteriaAns = new List<ASI_CRM_Criteria_Answer__c>();
        criteriaAns.add(criteriaAnswer); 
        criteriaAnswer_Map.put(criteriaAnswer.Id, criteriaAns);
        
        List<ASI_CRM_Image_Level_Threshold__c> imageLvl = new List<ASI_CRM_Image_Level_Threshold__c>();
        imageLvl.add(imageLvlThreshold); 
        
        List<ASI_CRM_Volume_Potential_Threshold__c> volPotential = new List<ASI_CRM_Volume_Potential_Threshold__c>();
        volPotential.add(volumePotentialThreshold); 
                
        ASI_CRM_TH_CriteriaController controller = new ASI_CRM_TH_CriteriaController(standardController);
        ASI_CRM_TH_CriteriaManager  criteriaManager = new ASI_CRM_TH_CriteriaManager ();
        ASI_CRM_TH_CriteriaFactory criteriaFactory = new ASI_CRM_TH_CriteriaFactory();
        
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
        PageReference rf = new Pagereference('/apex/ASI_CRM_TH_CriteriaSheet');
        rf.getParameters().put('id', prosSegmentation.id);
        //Criteria type 1 = VOLUME_POTENTIAL
        rf.getParameters().put('type','2');
        Test.setCurrentPage(rf);
        
        Map<Id, ASI_CRM_Criteria_Threshold__c> criteriaThreshold_Map = new Map<Id, ASI_CRM_Criteria_Threshold__c>();
        criteriaThreshold_Map.put(criteriaThreshold.Id, criteriaThreshold);
        
        Map<Id, List<ASI_CRM_Criteria_Answer__c>> criteriaAnswer_Map = new Map<Id, List<ASI_CRM_Criteria_Answer__c>>();
        List<ASI_CRM_Criteria_Answer__c> criteriaAns = new List<ASI_CRM_Criteria_Answer__c>();
        criteriaAns.add(criteriaAnswer); 
        criteriaAnswer_Map.put(criteriaAnswer.Id, criteriaAns);
        
        List<ASI_CRM_Image_Level_Threshold__c> imageLvl = new List<ASI_CRM_Image_Level_Threshold__c>();
        imageLvl.add(imageLvlThreshold); 
        
        List<ASI_CRM_Volume_Potential_Threshold__c> volPotential = new List<ASI_CRM_Volume_Potential_Threshold__c>();
        volPotential.add(volumePotentialThreshold); 
                
        ASI_CRM_TH_CriteriaController controller = new ASI_CRM_TH_CriteriaController(standardController);
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
        PageReference rf = new Pagereference('/apex/ASI_CRM_TH_CriteriaSheet');
        rf.getParameters().put('id', prosSegmentation.id);
        //Criteria type 1 = IMAGE_LEVEL
        rf.getParameters().put('type','1');
        Test.setCurrentPage(rf);
        
        Map<Id, ASI_CRM_Criteria_Threshold__c> criteriaThreshold_Map = new Map<Id, ASI_CRM_Criteria_Threshold__c>();
        criteriaThreshold_Map.put(criteriaThreshold.Id, criteriaThreshold);
        
        Map<Id, List<ASI_CRM_Criteria_Answer__c>> criteriaAnswer_Map = new Map<Id, List<ASI_CRM_Criteria_Answer__c>>();
        List<ASI_CRM_Criteria_Answer__c> criteriaAns = new List<ASI_CRM_Criteria_Answer__c>();
        criteriaAns.add(criteriaAnswer); 
        criteriaAnswer_Map.put(criteriaAnswer.Id, criteriaAns);
        
        List<ASI_CRM_Image_Level_Threshold__c> imageLvl = new List<ASI_CRM_Image_Level_Threshold__c>();
        imageLvl.add(imageLvlThreshold); 
        
        List<ASI_CRM_Volume_Potential_Threshold__c> volPotential = new List<ASI_CRM_Volume_Potential_Threshold__c>();
        volPotential.add(volumePotentialThreshold); 
                
        ASI_CRM_TH_CriteriaController controller = new ASI_CRM_TH_CriteriaController(standardController);
        ASI_CRM_TH_CriteriaManager  criteriaManager = new ASI_CRM_TH_CriteriaManager ();
        ASI_CRM_TH_CriteriaFactory criteriaFactory = new ASI_CRM_TH_CriteriaFactory();
        
        /*imageLvlThreshold.ASI_CRM_SG_Min_Weight__c = null;
        update imageLvlThreshold;*/
        
        prosImageLevel.ASI_CRM_SG_Weight__c = null;
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