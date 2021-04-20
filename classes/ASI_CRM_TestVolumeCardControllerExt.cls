@isTest
public with sharing class ASI_CRM_TestVolumeCardControllerExt { 

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
    private static ASI_CRM_Pros_Segmentation__c prosSegmentation;
    private static User user;
    
    public static void init2(){
        //create user
        // user = ASI_CRM_TestClassUtilityHelperPROS.createUser('System Administrator');
        // insert user;
        //create criteria set
        
        
        criteriaSetImage = (ASI_CRM_TestClassUtilityHelperPROS.createCriteriaSet(1,'ASI_SG_Image_Level_Criteria')).get(0);
                
        insert criteriaSetImage; 
        //create criteria threshold
        criteriaThresholdImage = (ASI_CRM_TestClassUtilityHelperPROS.createCriteriaThreshold(1,'ASI_CRM_SG_Text_Input',criteriaSetImage.id)).get(0);
        criteriaThresholdImage.ASI_CRM_SG_Question__c = 'Numero de marcas Super e Ultra Premium?';
        insert criteriaThresholdImage ; 
        //create criteria answer
        criteriaAnswerImage= (ASI_CRM_TestClassUtilityHelperPROS.createCriteriaAnswer(1,'ASI_CRM_SG_Text_Input',criteriaThresholdImage.id)).get(0);
        insert criteriaAnswerImage;
        //create volume criteria set
        criteriaSetVolume = (ASI_CRM_TestClassUtilityHelperPROS.createCriteriaSet(1,'ASI_SG_Volume_Potential_Criteria')).get(0);
             
        insert criteriaSetVolume ; 
        //create criteria threshold
        criteriaThresholdVolume = (ASI_CRM_TestClassUtilityHelperPROS.createCriteriaThreshold(1,'ASI_CRM_SG_Text_Input',criteriaSetVolume.id)).get(0);
        criteriaThresholdImage.ASI_CRM_SG_Question__c = 'Potential Volume';
        insert criteriaThresholdVolume ; 
        //create criteria answer
        criteriaAnswerVolume= (ASI_CRM_TestClassUtilityHelperPROS.createCriteriaAnswer(1,'ASI_CRM_SG_Text_Input',criteriaThresholdVolume.id)).get(0);
        insert criteriaAnswerVolume;         
        //create group outlet type
        
        
        groupOutletType = (ASI_CRM_TestClassUtilityHelperPROS.createGroupOutletType(1,'ASI_CRM_SG_Group_Outlet_Type','SGD',criteriaSetImage.id,criteriaSetVolume.id)).get(0);
        insert groupOutletType; 
        
            //create image level       
            iconicImageLevel = (ASI_CRM_TestClassUtilityHelperPROS.createImageLevel(1,'ASI_CRM_SG_Image_Level','SGD',groupOutletType.id,'Iconic')).get(0);
            insert iconicImageLevel;       
            leadingImageLevel = (ASI_CRM_TestClassUtilityHelperPROS.createImageLevel(1,'ASI_CRM_SG_Image_Level','SGD',groupOutletType.id,'Leading')).get(0);
            insert leadingImageLevel;       
            premiumImageLevel = (ASI_CRM_TestClassUtilityHelperPROS.createImageLevel(1,'ASI_CRM_SG_Image_Level','SGD',groupOutletType.id,'Premium')).get(0);
            insert premiumImageLevel;       
            mainstreamImageLevel = (ASI_CRM_TestClassUtilityHelperPROS.createImageLevel(1,'ASI_CRM_SG_Image_Level','SGD',groupOutletType.id,'Mainstream')).get(0);
            insert mainstreamImageLevel ;
        
        iconicImageLevelThreshold = (ASI_CRM_TestClassUtilityHelperPROS.createImageLevelThreshold(1,groupOutletType.id,iconicImageLevel.id,80)).get(0);
        insert iconicImageLevelThreshold;
        leadingImageLevelThreshold = (ASI_CRM_TestClassUtilityHelperPROS.createImageLevelThreshold(1,groupOutletType.id,leadingImageLevel.id,60)).get(0);
        insert leadingImageLevelThreshold ; 
        premiumImageLevelThreshold = (ASI_CRM_TestClassUtilityHelperPROS.createImageLevelThreshold(1,groupOutletType.id,premiumImageLevel.id,40)).get(0);
        insert premiumImageLevelThreshold ;  
        mainstreamImageLevelThreshold = (ASI_CRM_TestClassUtilityHelperPROS.createImageLevelThreshold(1,groupOutletType.id,mainstreamImageLevel.id,20)).get(0);
        insert mainstreamImageLevelThreshold ;   
        
            highVolPontential = (ASI_CRM_TestClassUtilityHelperPROS.createvolumePotential(1,'ASI_CRM_SG_Volume_Potential','SGD',groupOutletType.id,'High')).get(0);
            mediumVolPontential = (ASI_CRM_TestClassUtilityHelperPROS.createvolumePotential(1,'ASI_CRM_SG_Volume_Potential','SGD',groupOutletType.id,'Medium')).get(0);
            lowVolPontential = (ASI_CRM_TestClassUtilityHelperPROS.createvolumePotential(1,'ASI_CRM_SG_Volume_Potential','SGD',groupOutletType.id,'Low')).get(0);
      
        insert highVolPontential ;        
        insert mediumVolPontential ;        
        insert lowVolPontential ;
        
        highVolPontentialThreshold = (ASI_CRM_TestClassUtilityHelperPROS.createvolumePotentialThreshold(1,groupOutletType.id,highVolPontential.id,1500)).get(0);
        insert highVolPontentialThreshold ;
        mediumVolPontentialThreshold = (ASI_CRM_TestClassUtilityHelperPROS.createvolumePotentialThreshold(1,groupOutletType.id,highVolPontential.id,1000)).get(0);
        insert mediumVolPontentialThreshold ;
        lowVolPontentialThreshold = (ASI_CRM_TestClassUtilityHelperPROS.createvolumePotentialThreshold(1,groupOutletType.id,highVolPontential.id,500)).get(0);
        insert lowVolPontentialThreshold ;
        
            asiAccount = (ASI_CRM_TestClassUtilityHelperPROS.createAccountsASI(1, 'ASI_CRM_SG_Outlet')).get(0);
            insert asiAccount;
            prosSegmentation = [select id from ASI_CRM_Pros_Segmentation__c where ASI_CRM_SG_Customer__c =: asiAccount.id];
            
    }
    
    public static void init()
    {   //user = ASI_CRM_TestClassHelper.runAsStandardUserPortugal();
        
        init2();
        prosSegmentation = (ASI_CRM_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_SG_PROS_Segmentation', 'SGD', asiAccount.id, (id)null,(id)null,(id)null,(id)null)).get(0);
        prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.ASI_CRM_SG_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.ASI_CRM_SG_Service_Pack__c = null;
        prosSegmentation.ASI_CRM_SG_Customer__c= asiAccount.id;
        insert prosSegmentation;
    }
    static testMethod void testInitVolCard()
    {
        init();
        
        //ASI_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
            PageReference rf = new Pagereference('/apex/ASI_CRM_ProsSegmentationPage');
            rf.getParameters().put('id', prosSegmentation.id);
            Test.setCurrentPage(rf);
            
            ASI_CRM_VolumeCardControllerExt controller = new ASI_CRM_VolumeCardControllerExt();
            ASI_CRM_ID_Card__c idCard = new ASI_CRM_ID_Card__c(ASI_CRM_SG_Outlet__c = asiAccount.Id);
            insert idCard;
                       
            controller.IdCard = idCard;
            controller.prosSegmentationObj = prosSegmentation;
            controller.initVolCard();
    }
    static testMethod void testSaveP()
    {
        init();
        
        //ASI_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
            PageReference rf = new Pagereference('/apex/ASI_CRM_ProsSegmentationPage');
            rf.getParameters().put('id', prosSegmentation.id);
            Test.setCurrentPage(rf);
            
            ASI_CRM_VolumeCardControllerExt controller = new ASI_CRM_VolumeCardControllerExt();
            //controller.setAccountId(asiAccount.id);
            controller.prosSegmentationObj = prosSegmentation;
            controller.initVolCard();
            
            //Create ID Card
            ASI_CRM_ID_Card__c idCard = new ASI_CRM_ID_Card__c(ASI_CRM_SG_Outlet__c = asiAccount.Id);
            insert idCard;
            controller.IdCard = idCard;
            //Create ID Card Volumes
            List<ASI_CRM_ID_Card_Volume__c> idCardVolumeList = new List<ASI_CRM_ID_Card_Volume__c>();
            for(Integer i=0; i<10; i++){
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
            
            //Set mapVolWrapper
            Map <String, ASI_CRM_VolumeCardControllerExt.volumesWrapper> mapVolWrapper = new Map<String, ASI_CRM_VolumeCardControllerExt.volumesWrapper>();
            Integer counter=0;
            for (ASI_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
                ASI_CRM_VolumeCardControllerExt.volumesWrapper volumeWrapper = new ASI_CRM_VolumeCardControllerExt.volumesWrapper();
                volumeWrapper.vol_IDCardVolumes = volCard;
                volumeWrapper.categoryName = 'Category'+counter;
                
                counter++;
                
            }
                                 
            controller.saveP();

    }
 
    static testMethod void testGetData()
    {
        init();
        
        //ASI_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
            PageReference rf = new Pagereference('/apex/ASI_CRM_ProsSegmentationPage');
            rf.getParameters().put('id', prosSegmentation.id);
            Test.setCurrentPage(rf);
            
            ASI_CRM_VolumeCardControllerExt controller = new ASI_CRM_VolumeCardControllerExt();
            
            controller.prosSegmentationObj = prosSegmentation;
            controller.initVolCard();
            
            //Create ID Card
            ASI_CRM_ID_Card__c idCard = new ASI_CRM_ID_Card__c(ASI_CRM_SG_Outlet__c = asiAccount.Id);
            insert idCard;
            
            //Create ID Card Volumes
            List<ASI_CRM_ID_Card_Volume__c> idCardVolumeList = new List<ASI_CRM_ID_Card_Volume__c>();
            for(Integer i=0; i<10; i++){
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
            
            //Set mapVolWrapper
            Map <String, ASI_CRM_VolumeCardControllerExt.volumesWrapper> mapVolWrapper = new Map<String, ASI_CRM_VolumeCardControllerExt.volumesWrapper>();
            Integer counter=0;
            for (ASI_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
                ASI_CRM_VolumeCardControllerExt.volumesWrapper volumeWrapper = new ASI_CRM_VolumeCardControllerExt.volumesWrapper();
                volumeWrapper.vol_IDCardVolumes = volCard;
                volumeWrapper.categoryName = 'Category'+counter;
                
                counter++;
                
            }
            RecordType crType = [select id from RecordType where SObjectType = 'ASI_HK_CRM_Product_Category__c' and developername = 'ASI_SG_CRM_Product_Category'];
            ASI_HK_CRM_Product_Category__c cat = new ASI_HK_CRM_Product_Category__c(name='test', recordtypeid = crType.id);
            insert cat;
            RecordType brType = [select id from RecordType where SObjectType = 'ASI_MFM_Brand__c' and developername = 'ASI_CRM_SG_Brand'];
            ASI_MFM_Brand__c br = new ASI_MFM_Brand__c(name='testbrand',ASI_HK_CRM_Product_Category__c = cat.id,recordtypeid = brType.id);
            insert br;
            RecordType qrType = [select id from RecordType where SObjectType = 'ASI_CRM_Quality__c' and developername = 'ASI_CRM_SG_Brand_Quality'];
            ASI_CRM_Quality__c qu = new ASI_CRM_Quality__c(Name='qatest',ASI_CRM_SG_Brand__c= br.id,recordtypeid = qrType.id);
            insert qu;
            
            controller.getData(idCard);
    }
    
    static testMethod void testGetIdCardVolumes()
    {
        init();
        
        //ASI_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
            PageReference rf = new Pagereference('/apex/ASI_CRM_ProsSegmentationPage');
            rf.getParameters().put('id', prosSegmentation.id);
            Test.setCurrentPage(rf);
            
            ASI_CRM_VolumeCardControllerExt controller = new ASI_CRM_VolumeCardControllerExt();
            
            controller.prosSegmentationObj = prosSegmentation;
            controller.initVolCard();
            
            //Create ID Card
            ASI_CRM_ID_Card__c idCard = new ASI_CRM_ID_Card__c(ASI_CRM_SG_Outlet__c = asiAccount.Id);
            insert idCard;
            controller.idCard=idCard;
            //Create ID Card Volumes
            List<ASI_CRM_ID_Card_Volume__c> idCardVolumeList = new List<ASI_CRM_ID_Card_Volume__c>();
            for(Integer i=0; i<10; i++){
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
            
            //Set mapVolWrapper
            Map <String, ASI_CRM_VolumeCardControllerExt.volumesWrapper> mapVolWrapper = new Map<String, ASI_CRM_VolumeCardControllerExt.volumesWrapper>();
            Integer counter=0;
            for (ASI_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
                ASI_CRM_VolumeCardControllerExt.volumesWrapper volumeWrapper = new ASI_CRM_VolumeCardControllerExt.volumesWrapper();
                volumeWrapper.vol_IDCardVolumes = volCard;
                volumeWrapper.categoryName = 'Category'+counter;
                
                counter++;
                
            }
            
            controller.getData(idCard);
            //controller.getIdCardVolumes();
    }
    
    static testMethod void testIdCardUpdate()
    {
        init();
                
            //Create ID Card
            ASI_CRM_ID_Card__c idCard = new ASI_CRM_ID_Card__c(ASI_CRM_SG_Outlet__c = asiAccount.Id);
            insert idCard;
            
            //Create ID Card Volumes
            List<ASI_CRM_ID_Card_Volume__c> idCardVolumeList = new List<ASI_CRM_ID_Card_Volume__c>();
            for(Integer i=0; i<10; i++){
                ASI_HK_CRM_Product_Category__c cat = new ASI_HK_CRM_Product_Category__c(ASI_HK_CRM_Category_Code__c='CAT'+i);
                insert cat;
                
                ASI_CRM_ID_Card_Volume__c IDCardVol = new ASI_CRM_ID_Card_Volume__c(ASI_CRM_SG_ID_Card__c = idCard.id,
                                                        ASI_CRM_SG_Service_Mark__c = null,
                                                        ASI_CRM_SG_No_Premium_Brands__c=i,
                                                        ASI_CRM_SG_No_SuperPremium_Brands__c=i,
                                                        ASI_CRM_SG_No_UltraPremium_Brands__c=i,
                                                        ASI_CRM_SG_Annual_Volume__c = i);  
               idCardVolumeList.add(IDCardVol);
            }
            insert idCardVolumeList;
            
            List<ASI_CRM_ID_Card_Volume__c> idvList = [SELECT ASI_CRM_SG_No_SuperPremium_Brands__c, ASI_CRM_SG_No_UltraPremium_Brands__c, ASI_CRM_SG_No_Super_Ultra_Premium_Brands__c, ASI_CRM_SG_Annual_Volume__c FROM ASI_CRM_ID_Card_Volume__c WHERE ASI_CRM_SG_ID_Card__c =: idCard.id];
            for(ASI_CRM_ID_Card_Volume__c idv : idvList){
                idv.ASI_CRM_SG_No_SuperPremium_Brands__c = 2;
                idv.ASI_CRM_SG_No_UltraPremium_Brands__c = 2;
            }
            
            update idvList;
            
            for(ASI_CRM_ID_Card_Volume__c idv : idvList){
                idv.ASI_CRM_SG_Annual_Volume__c  = 12;
            }
            
    }
 
}