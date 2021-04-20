@isTest
public with sharing class EUR_CRM_TestProsSegmentationTrigger {
    private static EUR_CRM_Group_Outlet_Type__c groupOutletType;
    private static EUR_CRM_Affiliate__c affiliate;
    private static EUR_CRM_Criteria_Threshold__c criteriaThresholdImage;
    private static EUR_CRM_Criteria_Set__c criteriaSetImage;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswerImage;
    private static EUR_CRM_Criteria_Threshold__c criteriaThresholdVolume;
    private static EUR_CRM_Criteria_Set__c criteriaSetVolume;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswerVolume;
    private static String groupOutletName;
    private static EUR_CRM_Image_Level__c iconicImageLevel;
    private static EUR_CRM_Image_Level__c leadingImageLevel;
    private static EUR_CRM_Image_Level__c premiumImageLevel;
    private static EUR_CRM_Image_Level__c mainstreamImageLevel;
    private static EUR_CRM_Image_Level_Threshold__c iconicImageLevelThreshold;
    private static EUR_CRM_Image_Level_Threshold__c leadingImageLevelThreshold;
    private static EUR_CRM_Image_Level_Threshold__c PremiumImageLevelThreshold;
    private static EUR_CRM_Image_Level_Threshold__c mainstreamImageLevelThreshold;
    private static EUR_CRM_Volume_Potential__c highVolPontential;
    private static EUR_CRM_Volume_Potential__c mediumVolPontential;
    private static EUR_CRM_Volume_Potential__c lowVolPontential;
    private static EUR_CRM_Volume_Potential_Threshold__c highVolPontentialThreshold;
    private static EUR_CRM_Volume_Potential_Threshold__c mediumVolPontentialThreshold;
    private static EUR_CRM_Volume_Potential_Threshold__c lowVolPontentialThreshold;
    private static String countryCode = '';
    private static EUR_CRM_Account__c euAccount;
    private static Account prtAccount;
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
     public static void init(){
        //create user
        // user = EUR_CRM_TestClassUtilityHelper.createUser('System Administrator');
        // insert user;
        //create criteria set
         //create user
        // user = EUR_CRM_TestClassUtilityHelper.createUser('System Administrator');
        // insert user;
        //create criteria set
        criteriaSetImage = (EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1,countryCode +' Image Level Criteria')).get(0);
        if(countryCode =='PRT' && (criteriaSetImage.RecordTypeId == null ))       
         criteriaSetImage = (EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1,'Image Level Criteria (PRT)')).get(0);
     
        
        insert criteriaSetImage; 
        //create criteria threshold
        criteriaThresholdImage = (EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1,'Text Input',criteriaSetImage.id)).get(0);
        criteriaThresholdImage.EUR_CRM_Question__c = 'Numero de marcas Super e Ultra Premium?';
        insert criteriaThresholdImage ; 
        //create criteria answer
        criteriaAnswerImage= (EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1,'Text Input',criteriaThresholdImage.id)).get(0);
        insert criteriaAnswerImage;
        //create volume criteria set
        criteriaSetVolume = (EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1,countryCode +' Volume Potential Criteria')).get(0);
        if(countryCode =='PRT' && ( criteriaSetVolume.RecordTypeId == null ))        
         criteriaSetVolume = (EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1,'Volume Potential Criteria (PRT)')).get(0);
             
        insert criteriaSetVolume ; 
        //create criteria threshold
        criteriaThresholdVolume = (EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1,'Text Input',criteriaSetVolume.id)).get(0);
        criteriaThresholdImage.EUR_CRM_Question__c = 'Potential Volume';
        insert criteriaThresholdVolume ; 
        //create criteria answer
        criteriaAnswerVolume= (EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1,'Text Input',criteriaThresholdVolume.id)).get(0);
        insert criteriaAnswerVolume;         
        //create group outlet type
        
        
        groupOutletType = (EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1,'EUR '+countryCode+' Group Outlet','EUR',criteriaSetImage.id,criteriaSetVolume.id)).get(0);
         if(countryCode =='PRT' && ( groupOutletType.RecordTypeId == null ))        
                groupOutletType = (EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1,'EUR_PRT_GroupOutletType','EUR',criteriaSetImage.id,criteriaSetVolume.id)).get(0);
      
        
        insert groupOutletType; 
         if(countryCode == 'PRT'){ 
            //create image level       
            iconicImageLevel = (EUR_CRM_TestClassUtilityHelper.createImageLevel(1,'EUR_PRT_ImageLevel','EUR',groupOutletType.id,'Iconic')).get(0);
            insert iconicImageLevel;       
            leadingImageLevel = (EUR_CRM_TestClassUtilityHelper.createImageLevel(1,'EUR_PRT_ImageLevel','EUR',groupOutletType.id,'Leading')).get(0);
            insert leadingImageLevel;       
            premiumImageLevel = (EUR_CRM_TestClassUtilityHelper.createImageLevel(1,'EUR_PRT_ImageLevel','EUR',groupOutletType.id,'Premium')).get(0);
            insert premiumImageLevel;       
            mainstreamImageLevel = (EUR_CRM_TestClassUtilityHelper.createImageLevel(1,'EUR_PRT_ImageLevel','EUR',groupOutletType.id,'Mainstream')).get(0);
            insert mainstreamImageLevel ;
        
        
        }else{
             //create image level       
            iconicImageLevel = (EUR_CRM_TestClassUtilityHelper.createImageLevel(1,countryCode+' Image Level','EUR',groupOutletType.id,'Iconic')).get(0);
            insert iconicImageLevel;       
            leadingImageLevel = (EUR_CRM_TestClassUtilityHelper.createImageLevel(1,countryCode+' Image Level','EUR',groupOutletType.id,'Leading')).get(0);
            insert leadingImageLevel;       
            premiumImageLevel = (EUR_CRM_TestClassUtilityHelper.createImageLevel(1,countryCode+' Image Level','EUR',groupOutletType.id,'Premium')).get(0);
            insert premiumImageLevel;       
            mainstreamImageLevel = (EUR_CRM_TestClassUtilityHelper.createImageLevel(1,countryCode+' Image Level','EUR',groupOutletType.id,'Mainstream')).get(0);
            insert mainstreamImageLevel ;
        }
        iconicImageLevelThreshold = (EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1,groupOutletType.id,iconicImageLevel.id,80)).get(0);
        insert iconicImageLevelThreshold;
        leadingImageLevelThreshold = (EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1,groupOutletType.id,leadingImageLevel.id,60)).get(0);
        insert leadingImageLevelThreshold ; 
        premiumImageLevelThreshold = (EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1,groupOutletType.id,premiumImageLevel.id,40)).get(0);
        insert premiumImageLevelThreshold ;  
        mainstreamImageLevelThreshold = (EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1,groupOutletType.id,mainstreamImageLevel.id,20)).get(0);
        insert mainstreamImageLevelThreshold ;   
        
        
        if(countryCode == 'PRT'){
            highVolPontential = (EUR_CRM_TestClassUtilityHelper.createvolumePotential(1,'EUR_PRT_VolumePotential','EUR',groupOutletType.id,'High')).get(0);
            mediumVolPontential = (EUR_CRM_TestClassUtilityHelper.createvolumePotential(1,'EUR_PRT_VolumePotential','EUR',groupOutletType.id,'Medium')).get(0);
            lowVolPontential = (EUR_CRM_TestClassUtilityHelper.createvolumePotential(1,'EUR_PRT_VolumePotential','EUR',groupOutletType.id,'Low')).get(0);
      
        }else{
            highVolPontential = (EUR_CRM_TestClassUtilityHelper.createvolumePotential(1,countryCode+' Volume Potential','EUR',groupOutletType.id,'High')).get(0);
            mediumVolPontential = (EUR_CRM_TestClassUtilityHelper.createvolumePotential(1,countryCode+' Volume Potential','EUR',groupOutletType.id,'Medium')).get(0);
           lowVolPontential = (EUR_CRM_TestClassUtilityHelper.createvolumePotential(1,countryCode+' Volume Potential','EUR',groupOutletType.id,'Low')).get(0);
      
        }
        insert highVolPontential ;        
        insert mediumVolPontential ;        
        insert lowVolPontential ;
        
        highVolPontentialThreshold = (EUR_CRM_TestClassUtilityHelper.createvolumePotentialThreshold(1,groupOutletType.id,highVolPontential.id,1500)).get(0);
        insert highVolPontentialThreshold ;
        mediumVolPontentialThreshold = (EUR_CRM_TestClassUtilityHelper.createvolumePotentialThreshold(1,groupOutletType.id,highVolPontential.id,1000)).get(0);
        insert mediumVolPontentialThreshold ;
        lowVolPontentialThreshold = (EUR_CRM_TestClassUtilityHelper.createvolumePotentialThreshold(1,groupOutletType.id,highVolPontential.id,500)).get(0);
        insert lowVolPontentialThreshold ;
        if(countryCode == 'PRT'){ 
            prtAccount = (EUR_CRM_TestClassUtilityHelper.createAccounts(1, 'On Trade (EUR-PRT)')).get(0);
            insert prtAccount;
        }else{
            euAccount = (EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'EE Direct - On Trade')).get(0);
            insert euAccount;
            prosSegmentation = [select id from EUR_CRM_Pros_Segmentation__c where EUR_CRM_Account__c =: euAccount.id];
            

        }
                    affiliate = EUR_CRM_TestClassHelper.createAffiliate();
            insert affiliate;   }
    
    static testMethod void testNewPageEMEAAccount(){ 
        countryCode = 'EE';
        init();
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        update prosSegmentation; 
    }
    static testMethod void testNewPageEMEAAccount2(){ 
        countryCode = 'EE';
        init();
        prosSegmentation.EUR_CRM_Image_Level__c= iconicImageLevel.id;
        update prosSegmentation;
    }
    static testMethod void testNewPagePRTAccount(){ 
        countryCode = 'PRT';
        init();
        prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        insert prosSegmentation;
        update prosSegmentation;
    }

}