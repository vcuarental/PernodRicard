/*********************************************************************************
 * Name: ASI_CRM_TH_TestProsSegmentationExt
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_TestProsSegmentationExt
*********************************************************************************/
@isTest (SeeAllData = true)
private class ASI_CRM_TH_TestProsSegmentationExt{
    
    private static ASI_CRM_AccountsAdditionalField__c account;
    private static ASI_CRM_Pros_Segmentation__c prosSegmentation;
    private static ASI_CRM_Criteria_Threshold__c criteriaThreshold;
    private static ASI_CRM_Criteria_Set__c criteriaSet;
    private static ASI_CRM_Criteria_Answer__c criteriaAnswer;
    private static ASI_CRM_Group_Outlet_Type__c groupOutlet;
    private static ASI_CRM_Outlet_Type__c outletType;
    private static ASI_CRM_Image_Level__c imageLevel;
    private static ASI_CRM_Image_Level_Threshold__c imageLvlThreshold;
    private static ASI_CRM_Volume_Potential__c volumePotential;
    private static ASI_CRM_Volume_Potential_Threshold__c volumePotentialThreshold;
    private static ASI_CRM_Pros_Image_Level__c prosImageLevel;
    private static ASI_CRM_Pros_Volume_Potential__c prosVolPotential;
    private static ASI_CRM_ServicePack__c servicePack;
    private static User user;
    private static ASI_CRM_DAMD_Threshold__c damd;
    
    public static void dataInsert(){
        
        account = ASI_CRM_TH_TestClassUtilityHelperPROS.createAccountsASI(1, 'ASI_TH_CRM_Outlet')[0];
        account.ASI_CRM_Region__c = 'Central';
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
        
        outletType = ASI_CRM_TH_TestClassUtilityHelperPROS.createOutletType(1, 'ASI_CRM_TH_Outlet_Type', '', groupOutlet.Id)[0];
        insert outletType;
        
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
        prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c = imageLvlThreshold.Id;
        prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c = volumePotentialThreshold.Id;
        insert prosSegmentation;
        
        prosImageLevel = ASI_CRM_TH_TestClassUtilityHelperPROS.createProsImageLevel(1, 'ASI_CRM_TH_Pros_Image_Level', '', prosSegmentation.Id, criteriaThreshold.Id)[0];
        prosImageLevel.ASI_CRM_SG_Weight__c = 98;
        insert prosImageLevel;
        
        prosVolPotential = ASI_CRM_TH_TestClassUtilityHelperPROS.createProsVolumePotential(1, 'ASI_CRM_TH_Pros_Volume_Potential', '', prosSegmentation.Id, criteriaThreshold.Id)[0];
        prosVolPotential.ASI_CRM_SG_Weight__c = 98;
        insert prosVolPotential;
        
        damd = ASI_CRM_TH_TestClassUtilityHelperPROS.createDAMD(1, 'ASI_CRM_TH_DAMD_Threshold', groupOutlet.Id, volumePotential.Id, 'Attack', 'Low', 0.1)[0];
        insert damd;
    }
    
    static testMethod void proSegmentTestAT() {
        dataInsert();
        
        //Create ID Card
        ASI_CRM_ID_Card__c idCard = new ASI_CRM_ID_Card__c(ASI_CRM_SG_Outlet__c = account.Id);
        insert idCard;
        
        //Create ID Card Volumes
        List<ASI_CRM_ID_Card_Volume__c> idCardVolumeList = new List<ASI_CRM_ID_Card_Volume__c>();
        for(Integer i=0; i<1; i++){
            ASI_HK_CRM_Product_Category__c cat = new ASI_HK_CRM_Product_Category__c(ASI_HK_CRM_Category_Code__c='CAT'+i);
            insert cat;
            
            ASI_CRM_ID_Card_Volume__c IDCardVol = new ASI_CRM_ID_Card_Volume__c(ASI_CRM_SG_ID_Card__c = idCard.id, 
                                                    ASI_CRM_SG_Service_Mark__c = null,
                                                    ASI_CRM_SG_No_Premium_Brands__c=i,
                                                    ASI_CRM_SG_No_SuperPremium_Brands__c=i,
                                                    ASI_CRM_SG_No_UltraPremium_Brands__c=i);  
           idCardVolumeList.add(IDCardVol);
        }
        insert idCardVolumeList;
     
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/ASI_CRM_TH_ProsSegmentationPage');
        rf.getParameters().put('id', prosSegmentation.id);
        Test.setCurrentPage(rf);
        
        List<ASI_CRM_Pros_Image_Level__c> pImageLvl = new List<ASI_CRM_Pros_Image_Level__c>();
        pImageLvl.add(prosImageLevel); 
        
        List<ASI_CRM_Pros_Volume_Potential__c> pVolPotential = new List<ASI_CRM_Pros_Volume_Potential__c>();
        pVolPotential.add(prosVolPotential); 
        
        ASI_CRM_TH_ProsSegmentationExt  controller = new ASI_CRM_TH_ProsSegmentationExt (standardController);
        
        test.startTest();
        
        controller.initSummary();
        controller.processGroupOutletType();
        controller.processImageLevel();
        controller.processVolumePotential();
        controller.processAccountPlan();
        controller.processResetImageLevel();
        
         test.stopTest();          
    }
    
    static testMethod void proSegmentTestPRT() {
        test.startTest();
        
        ASI_CRM_Pros_Segmentation__c proSegmentTestPRT = ASI_CRM_TH_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_TH_PROS_Segmentation', '', null, null, null, null, null)[0];
        insert proSegmentTestPRT;
        
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(proSegmentTestPRT);
        PageReference rf = new Pagereference('/apex/ASI_CRM_TH_ProsSegmentationPage');
        rf.getParameters().put('id', proSegmentTestPRT.id);
        Test.setCurrentPage(rf);
        
        ASI_CRM_TH_ProsSegmentationExt  controller = new ASI_CRM_TH_ProsSegmentationExt (standardController);
        
        test.stopTest();
    }
    
}