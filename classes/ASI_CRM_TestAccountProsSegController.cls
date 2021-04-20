@isTest
public with sharing class ASI_CRM_TestAccountProsSegController {
    private static ASI_CRM_AccountsAdditionalField__c asiAccount;
    private static User user;
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
    private static ASI_CRM_DAMD_Threshold__c damd;
    
    static void init(){
        user = ASI_CRM_TestClassHelperPROS.runAsStandardUserPortugal();

    }
    
    static void createCommon(){
        asiAccount= (ASI_CRM_TestClassUtilityHelperPROS.createAccountsASI(1,'ASI_CRM_SG_Outlet')).get(0);   
        insert asiAccount;
        
    }
    
    static void createCommon2(){
        asiAccount = ASI_CRM_TestClassUtilityHelperPROS.createAccountsASI(1, 'ASI_CRM_SG_Outlet')[0];
        insert asiAccount;
           
        criteriaSet = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaSet(1, 'ASI_SG_Image_Level_Criteria')[0];
        insert criteriaSet;
        
        criteriaThreshold = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaThreshold(1, 'ASI_CRM_SG_Picklist', criteriaSet.Id)[0];
        criteriaThreshold.ASI_CRM_SG_Weight__c = 100;
        insert criteriaThreshold;
        
        criteriaAnswer = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaAnswer(1, 'ASI_CRM_SG_Picklist', criteriaThreshold.Id)[0];
        criteriaAnswer.ASI_CRM_SG_Value__c = null;
        criteriaAnswer.ASI_CRM_SG_Weight__c = 90;
        criteriaAnswer.ASI_CRM_SG_Base_Currency__c = 50;
        criteriaAnswer.ASI_CRM_SG_Condition__c = 'Less Than or Equal (<=)';
        insert criteriaAnswer;
                
        groupOutlet = ASI_CRM_TestClassUtilityHelperPROS.createGroupOutletType(1, 'ASI_CRM_SG_Group_Outlet_Type', '', null, null)[0];
        groupOutlet.ASI_CRM_SG_Group_Outlet_Name__c = 'Nightclub';
        insert groupOutlet;
        
        outletType = ASI_CRM_TestClassUtilityHelperPROS.createOutletType(1, 'ASI_CRM_SG_Outlet_Type', '', groupOutlet.Id)[0];
        insert outletType;
        
        imageLevel = ASI_CRM_TestClassUtilityHelperPROS.createImageLevel(1, 'ASI_CRM_SG_Image_Level', '', groupOutlet.Id, 'Nightclub')[0];
        insert imageLevel;
        
        imageLvlThreshold = ASI_CRM_TestClassUtilityHelperPROS.createImageLevelThreshold(1, groupOutlet.Id, imageLevel.Id)[0];
        imageLvlThreshold.ASI_CRM_SG_Min_Weight__c = 50;
        insert imageLvlThreshold;
        
        volumePotential = ASI_CRM_TestClassUtilityHelperPROS.createvolumePotential(1, 'ASI_CRM_SG_Volume_Potential', '', groupOutlet.Id, 'Medium')[0];
        insert volumePotential;
        
        volumePotentialThreshold = ASI_CRM_TestClassUtilityHelperPROS.createvolumePotentialThreshold(1, groupOutlet.Id, volumePotential.Id)[0];
        volumePotentialThreshold.ASI_CRM_SG_Min_Weight__c = 50;
        insert volumePotentialThreshold;
        
        prosSegmentation = ASI_CRM_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_SG_PROS_Segmentation', '', asiAccount.Id, groupOutlet.Id, null, imageLevel.Id, volumePotential.Id)[0];
        prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c = imageLvlThreshold.Id;
        prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c = volumePotentialThreshold.Id;
        insert prosSegmentation;
        
        prosImageLevel = ASI_CRM_TestClassUtilityHelperPROS.createProsImageLevel(1, 'ASI_CRM_SG_ProsImageLevel', '', prosSegmentation.Id, criteriaThreshold.Id)[0];
        prosImageLevel.ASI_CRM_SG_Weight__c = 98;
        insert prosImageLevel;
        
        prosVolPotential = ASI_CRM_TestClassUtilityHelperPROS.createProsVolumePotential(1, 'ASI_CRM_SG_ProsVolumePotential', '', prosSegmentation.Id, criteriaThreshold.Id)[0];
        prosVolPotential.ASI_CRM_SG_Weight__c = 98;
        insert prosVolPotential;
        
        damd = ASI_CRM_TestClassUtilityHelperPROS.createDAMD(1, 'ASI_CRM_SG_DAMD_Threshold', groupOutlet.Id, volumePotential.Id, 'Attack', 'Low', 0.1)[0];
        insert damd;
        
    }
    
    @TestSetup
    public static void setupTestData() {
        createCommon2();
    }

    static testMethod void testCreateProsSegmentation(){
        //init();
        //ASI_CRM_TestClassHelperPROS.runAsStandardUserPortugal();
        //System.runAs(user){
            asiAccount = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c LIMIT 1];

            ApexPages.StandardController standardController = new ApexPages.StandardController(asiAccount);
            
            PageReference ref = new PageReference('/apex/ASI_CRM_Account_ProsSegSectionPageCntry');
            ref.getParameters().put('id', asiAccount.id);
            Test.setCurrentPage(ref);
            
            ASI_CRM_AccountProsSegController controller = new ASI_CRM_AccountProsSegController(standardController);
            controller.createProsSegmentation();
            controller.getCustomLink(); 
            controller.openProsSeg(); 
            controller.openAccountPlan();
            //System.assertNotEquals(controller.url, null);
            //controller.openProsSeg();
        //}
    }
    
    static testMethod void testCreateProsSegmentation2(){
        //init();
        //Create ID Card
            asiAccount = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c LIMIT 1];

            ASI_CRM_ID_Card__c idCard = new ASI_CRM_ID_Card__c(ASI_CRM_SG_Outlet__c = asiAccount.Id);
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
            
            ApexPages.StandardController standardController = new ApexPages.StandardController(asiAccount);
            
            PageReference ref = new PageReference('/apex/ASI_CRM_Account_ProsSegSectionPageCntry');
            ref.getParameters().put('id', asiAccount.id);
            Test.setCurrentPage(ref);
            
            ASI_CRM_AccountProsSegController controller = new ASI_CRM_AccountProsSegController(standardController);
            
        
    }
    
    static testMethod void testCreateProsSegmentation3(){
        //init();
            
            asiAccount = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c LIMIT 1];

            asiAccount.id=null;
            ApexPages.StandardController standardController = new ApexPages.StandardController(asiAccount);
            
            PageReference ref = new PageReference('/apex/ASI_CRM_Account_ProsSegSectionPageCntry');
            ref.getParameters().put('id', asiAccount.id);
            Test.setCurrentPage(ref);
            
            ASI_CRM_AccountProsSegController controller = new ASI_CRM_AccountProsSegController(standardController);
           
    }
    
    static testMethod void testUpdateProsSegmentation(){
        groupOutlet = [SELECT Id FROM ASI_CRM_Group_Outlet_Type__c LIMIT 1];
        prosSegmentation = [SELECT Id, ASI_CRM_SG_Group_Outlet_Type__c, ASI_CRM_SG_Outlet_Type__c FROM ASI_CRM_Pros_Segmentation__c LIMIT 1];

        ASI_CRM_Group_Outlet_Type__c  groupOutlet2 = ASI_CRM_TestClassUtilityHelperPROS.createGroupOutletType(1, 'ASI_CRM_SG_Group_Outlet_Type', '', null, null)[0];
        groupOutlet2.ASI_CRM_SG_Group_Outlet_Name__c = 'Restaurant';
        insert groupOutlet2;
        
        ASI_CRM_Outlet_Type__c  outletType2 = ASI_CRM_TestClassUtilityHelperPROS.createOutletType(1, 'ASI_CRM_SG_Outlet_Type', '', groupOutlet.Id)[0];
        insert outletType2;   
        
        prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c = groupOutlet2.Id;
        prosSegmentation.ASI_CRM_SG_Outlet_Type__c = outletType2.Id;
        
        update prosSegmentation;
           
    }
    
    
    
}