/*********************************************************************************
 * Name: ASI_CRM_TW_TestCriteriaAnswerTrigger
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 05/05/2015       Laputa: Alvin           Cloned from ASI_CRM_TestCriteriaAnswerTrigger
*********************************************************************************/
@isTest
public with sharing class ASI_CRM_TW_TestCriteriaAnswerTrigger {
    private static ASI_CRM_Group_Outlet_Type__c groupOutletType;
    private static ASI_CRM_Criteria_Threshold__c criteriaThresholdImage;
    private static ASI_CRM_Criteria_Set__c criteriaSetImage;
    private static ASI_CRM_Criteria_Answer__c criteriaAnswerImage;
    private static ASI_CRM_Criteria_Threshold__c criteriaThresholdVolume;
    private static ASI_CRM_Criteria_Set__c criteriaSetVolume;
    private static ASI_CRM_Criteria_Answer__c criteriaAnswerVolume;
    private static String groupOutletName;
    private static ASI_CRM_Image_Level__c iconicImageLevel;
    private static ASI_CRM_Image_Level__c leadingImageLevel;
    private static ASI_CRM_Image_Level__c premiumImageLevel;
    private static ASI_CRM_Image_Level__c mainstreamImageLevel;
    private static ASI_CRM_Image_Level_Threshold__c iconicImageLevelThreshold;
    private static ASI_CRM_Image_Level_Threshold__c leadingImageLevelThreshold;
    private static ASI_CRM_Image_Level_Threshold__c PremiumImageLevelThreshold;
    private static ASI_CRM_Image_Level_Threshold__c mainstreamImageLevelThreshold;
    private static ASI_CRM_Volume_Potential__c highVolPontential;
    private static ASI_CRM_Volume_Potential__c mediumVolPontential;
    private static ASI_CRM_Volume_Potential__c lowVolPontential;
    private static ASI_CRM_Volume_Potential_Threshold__c highVolPontentialThreshold;
    private static ASI_CRM_Volume_Potential_Threshold__c mediumVolPontentialThreshold;
    private static ASI_CRM_Volume_Potential_Threshold__c lowVolPontentialThreshold;
    private static ASI_CRM_AccountsAdditionalField__c asiAccount;
    private static ASI_CRM_AccountsAdditionalField__c prtAccount;
    private static ASI_CRM_Pros_Segmentation__c prosSegmentation;
    
    public static void init(){
        //create criteria set
        criteriaSetImage = (ASI_CRM_TW_TestClassUtilityHelperPROS.createCriteriaSet(1,'ASI_CRM_TW_Image_Level_Criteria')).get(0);
        insert criteriaSetImage; 
        //create criteria threshold
        criteriaThresholdImage = (ASI_CRM_TW_TestClassUtilityHelperPROS.createCriteriaThreshold(1,'ASI_CRM_TW_Text_Input',criteriaSetImage.id)).get(0);
        insert criteriaThresholdImage ; 
        //create criteria answer
        criteriaAnswerImage= (ASI_CRM_TW_TestClassUtilityHelperPROS.createCriteriaAnswer(1,'ASI_CRM_TW_Text_Input',criteriaThresholdImage.id)).get(0);
        insert criteriaAnswerImage;
        //create volume criteria set
        criteriaSetVolume = (ASI_CRM_TW_TestClassUtilityHelperPROS.createCriteriaSet(1,'ASI_CRM_TW_Volume_Potential_Criteria')).get(0);
        insert criteriaSetVolume ; 
        //create criteria threshold
        criteriaThresholdVolume = (ASI_CRM_TW_TestClassUtilityHelperPROS.createCriteriaThreshold(1,'ASI_CRM_TW_Text_Input',criteriaSetVolume.id)).get(0);
        insert criteriaThresholdVolume ; 
        //create criteria answer
        criteriaAnswerVolume= (ASI_CRM_TW_TestClassUtilityHelperPROS.createCriteriaAnswer(1,'ASI_CRM_TW_Text_Input',criteriaThresholdVolume.id)).get(0);
        insert criteriaAnswerVolume;         
        //create group outlet type
        groupOutletType = (ASI_CRM_TW_TestClassUtilityHelperPROS.createGroupOutletType(1,'ASI_CRM_TW_Group_Outlet_Type','TWD',criteriaSetImage.id,criteriaSetVolume.id)).get(0);
        insert groupOutletType;  
        //create image level       
        iconicImageLevel = (ASI_CRM_TW_TestClassUtilityHelperPROS.createImageLevel(1,'ASI_CRM_TW_Image_Level','TWD',groupOutletType.id,'Iconic')).get(0);
        insert iconicImageLevel;       
        leadingImageLevel = (ASI_CRM_TW_TestClassUtilityHelperPROS.createImageLevel(1,'ASI_CRM_TW_Image_Level','TWD',groupOutletType.id,'Leading')).get(0);
        insert leadingImageLevel;       
        premiumImageLevel = (ASI_CRM_TW_TestClassUtilityHelperPROS.createImageLevel(1,'ASI_CRM_TW_Image_Level','TWD',groupOutletType.id,'Premium')).get(0);
        insert premiumImageLevel;       
        mainstreamImageLevel = (ASI_CRM_TW_TestClassUtilityHelperPROS.createImageLevel(1,'ASI_CRM_TW_Image_Level','TWD',groupOutletType.id,'Mainstream')).get(0);
        insert mainstreamImageLevel ;
        
        iconicImageLevelThreshold = (ASI_CRM_TW_TestClassUtilityHelperPROS.createImageLevelThreshold(1,groupOutletType.id,iconicImageLevel.id,80)).get(0);
        insert iconicImageLevelThreshold;
        leadingImageLevelThreshold = (ASI_CRM_TW_TestClassUtilityHelperPROS.createImageLevelThreshold(1,groupOutletType.id,leadingImageLevel.id,60)).get(0);
        insert leadingImageLevelThreshold ; 
        premiumImageLevelThreshold = (ASI_CRM_TW_TestClassUtilityHelperPROS.createImageLevelThreshold(1,groupOutletType.id,premiumImageLevel.id,40)).get(0);
        insert premiumImageLevelThreshold ;  
        mainstreamImageLevelThreshold = (ASI_CRM_TW_TestClassUtilityHelperPROS.createImageLevelThreshold(1,groupOutletType.id,mainstreamImageLevel.id,20)).get(0);
        insert mainstreamImageLevelThreshold ;   
        
        highVolPontential = (ASI_CRM_TW_TestClassUtilityHelperPROS.createvolumePotential(1,'ASI_CRM_TW_Volume_Potential','TWD',groupOutletType.id,'High')).get(0);
        mediumVolPontential = (ASI_CRM_TW_TestClassUtilityHelperPROS.createvolumePotential(1,'ASI_CRM_TW_Volume_Potential','TWD',groupOutletType.id,'Medium')).get(0);
        lowVolPontential = (ASI_CRM_TW_TestClassUtilityHelperPROS.createvolumePotential(1,'ASI_CRM_TW_Volume_Potential','TWD',groupOutletType.id,'Low')).get(0);
      
        insert highVolPontential ;        
        insert mediumVolPontential ;        
        insert lowVolPontential ;
        
        highVolPontentialThreshold = (ASI_CRM_TW_TestClassUtilityHelperPROS.createvolumePotentialThreshold(1,groupOutletType.id,highVolPontential.id,1500)).get(0);
        insert highVolPontentialThreshold ;
        mediumVolPontentialThreshold = (ASI_CRM_TW_TestClassUtilityHelperPROS.createvolumePotentialThreshold(1,groupOutletType.id,highVolPontential.id,1000)).get(0);
        insert mediumVolPontentialThreshold ;
        lowVolPontentialThreshold = (ASI_CRM_TW_TestClassUtilityHelperPROS.createvolumePotentialThreshold(1,groupOutletType.id,highVolPontential.id,500)).get(0);
        insert lowVolPontentialThreshold ;  
        
        //Added by Twinkle 20150511 - Avoid UNABLE_TO_LOCK_ROW Testclass Issue
        Id recordtypeId = Global_RecordTypeCache.getRTId('AccountASI_CRM_TW_Outlet');

        Account acc = new Account();
        acc.RecordTypeId = recordtypeId;
        acc.Name = 'TestAccount';       
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
               
        recordtypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet');
        asiAccount = new ASI_CRM_AccountsAdditionalField__c(RecordTypeId = recordtypeId, Name = 'TestAccount', ASI_CRM_Account__c = acc.id, ASI_TH_CRM_OutletType__c = ot.id,
                                                            ASI_CRM_Region__c = 'South', ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street',
                                                            ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12');
        //Added by Twinkle 20150511
        insert asiAccount;
        
        //Added by Twinkle LI @20150622
        recordtypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Segmentation__cASI_CRM_TW_Pros_Segmentation');
        prosSegmentation = new ASI_CRM_Pros_Segmentation__c(RecordTypeId = recordtypeId, ASI_CRM_SG_Customer__c = asiAccount.id);
        insert prosSegmentation;
        //End by Twinkle LI @20150622 
        
        prosSegmentation = [select id from ASI_CRM_Pros_Segmentation__c where ASI_CRM_SG_Customer__c =: asiAccount.id LIMIT 1];
    }
    
    static testMethod void testCriteriaAnswerDelete(){
        init();
    
        delete criteriaAnswerImage;
        ASI_CRM_Pros_Segmentation__c newProsSegmentation = retrieveProsSegmentation(prosSegmentation.Id);
        
        System.assertEquals(newProsSegmentation.ASI_CRM_SG_Is_Image_Level_Modified__c, false);
    }
    
    static testMethod void testCriteriaAnswerUpdate(){
        init();
        
        criteriaAnswerImage.ASI_CRM_SG_Value__c='NewTestValue';
        update criteriaAnswerImage;
        
        ASI_CRM_Pros_Segmentation__c newProsSegmentation = retrieveProsSegmentation(prosSegmentation.Id);
        System.assertEquals(newProsSegmentation.ASI_CRM_SG_Is_Image_Level_Modified__c, false);
    }
    
    private static ASI_CRM_Pros_Segmentation__c retrieveProsSegmentation(Id prosId){
        ASI_CRM_Pros_Segmentation__c newProsSegmentation = [SELECT Id, ASI_CRM_SG_Group_Outlet_Type__c,
                            ASI_CRM_SG_Is_Image_Level_Modified__c, ASI_CRM_SG_Is_Volume_Potential_Modified__c
                            FROM ASI_CRM_Pros_Segmentation__c
                            WHERE Id =: prosId];
                            
        return newProsSegmentation;
    }   
}