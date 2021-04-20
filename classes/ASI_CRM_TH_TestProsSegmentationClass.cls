/*********************************************************************************
 * Name: ASI_CRM_TH_TestProsSegmentationClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_TestProsSegmentationClass
*********************************************************************************/
@isTest
public with sharing class ASI_CRM_TH_TestProsSegmentationClass{
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
    private static ASI_CRM_Volume_Potential__c highVolPotential;
    private static ASI_CRM_Volume_Potential__c mediumVolPotential;
    private static ASI_CRM_Volume_Potential__c lowVolPotential;
    private static ASI_CRM_Volume_Potential_Threshold__c highVolPotentialThreshold;
    private static ASI_CRM_Volume_Potential_Threshold__c mediumVolPotentialThreshold;
    private static ASI_CRM_Volume_Potential_Threshold__c lowVolPotentialThreshold;
    private static ASI_CRM_AccountsAdditionalField__c asiAccount;
    private static ASI_CRM_AccountsAdditionalField__c prtAccount;
    private static ASI_CRM_Pros_Segmentation__c prosSegmentation;
    private static ASI_CRM_ServicePack__c servicePack;
    private static ASI_CRM_DAMD_Threshold__c damdhigh;
    private static ASI_CRM_DAMD_Threshold__c damdlow;
    private static User user;
    
    public static void init(){
        //create user
        // user = ASI_CRM_TH_TestClassUtilityHelperPROS.createUser('System Administrator');
        // insert user;
        //create criteria set
        criteriaSetImage = (ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaSet(1,'ASI_CRM_TH_Image_Level_Criteria')).get(0);
        
        insert criteriaSetImage; 
        //create criteria threshold
        criteriaThresholdImage = (ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaThreshold(1,'ASI_CRM_TH_Text_Input',criteriaSetImage.id)).get(0);
        criteriaThresholdImage.ASI_CRM_SG_Question__c = 'Numero de marcas Super e Ultra Premium?';
        insert criteriaThresholdImage ; 
        //create criteria answer
        criteriaAnswerImage= (ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaAnswer(1,'ASI_CRM_TH_Text_Input',criteriaThresholdImage.id)).get(0);
        insert criteriaAnswerImage;
        //create volume criteria set
        criteriaSetVolume = (ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaSet(1,'ASI_CRM_TH_Volume_Potential_Criteria')).get(0);
             
        insert criteriaSetVolume ; 
        //create criteria threshold
        criteriaThresholdVolume = (ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaThreshold(1,'ASI_CRM_TH_Text_Input',criteriaSetVolume.id)).get(0);
        criteriaThresholdVolume.ASI_CRM_SG_Question__c = 'Potential Volume';
        insert criteriaThresholdVolume ; 
        //create criteria answer
        criteriaAnswerVolume= (ASI_CRM_TH_TestClassUtilityHelperPROS.createCriteriaAnswer(1,'ASI_CRM_TH_Text_Input',criteriaThresholdVolume.id)).get(0);
        insert criteriaAnswerVolume;         
        //create group outlet type
        
        
        groupOutletType = (ASI_CRM_TH_TestClassUtilityHelperPROS.createGroupOutletType(1,'ASI_CRM_TH_Group_Outlet_Type','THB',criteriaSetImage.id,criteriaSetVolume.id)).get(0);
        
        insert groupOutletType; 
         
        //create image level       
        iconicImageLevel = (ASI_CRM_TH_TestClassUtilityHelperPROS.createImageLevel(1,'ASI_CRM_TH_Image_Level','THB',groupOutletType.id,'Iconic')).get(0);
        insert iconicImageLevel;       
        leadingImageLevel = (ASI_CRM_TH_TestClassUtilityHelperPROS.createImageLevel(1,'ASI_CRM_TH_Image_Level','THB',groupOutletType.id,'Leading')).get(0);
        insert leadingImageLevel;       
        premiumImageLevel = (ASI_CRM_TH_TestClassUtilityHelperPROS.createImageLevel(1,'ASI_CRM_TH_Image_Level','THB',groupOutletType.id,'Premium')).get(0);
        insert premiumImageLevel;       
        mainstreamImageLevel = (ASI_CRM_TH_TestClassUtilityHelperPROS.createImageLevel(1,'ASI_CRM_TH_Image_Level','THB',groupOutletType.id,'Mainstream')).get(0);
        insert mainstreamImageLevel ;       
        
        iconicImageLevelThreshold = (ASI_CRM_TH_TestClassUtilityHelperPROS.createImageLevelThreshold(1,groupOutletType.id,iconicImageLevel.id,80)).get(0);
        insert iconicImageLevelThreshold;
        leadingImageLevelThreshold = (ASI_CRM_TH_TestClassUtilityHelperPROS.createImageLevelThreshold(1,groupOutletType.id,leadingImageLevel.id,60)).get(0);
        insert leadingImageLevelThreshold ; 
        premiumImageLevelThreshold = (ASI_CRM_TH_TestClassUtilityHelperPROS.createImageLevelThreshold(1,groupOutletType.id,premiumImageLevel.id,40)).get(0);
        insert premiumImageLevelThreshold ;  
        mainstreamImageLevelThreshold = (ASI_CRM_TH_TestClassUtilityHelperPROS.createImageLevelThreshold(1,groupOutletType.id,mainstreamImageLevel.id,20)).get(0);
        insert mainstreamImageLevelThreshold ;   
        
            highVolPotential = (ASI_CRM_TH_TestClassUtilityHelperPROS.createvolumePotential(1,'ASI_CRM_TH_Volume_Potential','THB',groupOutletType.id,'High')).get(0);
            mediumVolPotential = (ASI_CRM_TH_TestClassUtilityHelperPROS.createvolumePotential(1,'ASI_CRM_TH_Volume_Potential','THB',groupOutletType.id,'Medium')).get(0);
            lowVolPotential = (ASI_CRM_TH_TestClassUtilityHelperPROS.createvolumePotential(1,'ASI_CRM_TH_Volume_Potential','THB',groupOutletType.id,'Low')).get(0);
      
        insert highVolPotential ;        
        insert mediumVolPotential ;        
        insert lowVolPotential ;
        
        highVolPotentialThreshold = (ASI_CRM_TH_TestClassUtilityHelperPROS.createvolumePotentialThreshold(1,groupOutletType.id,highVolPotential.id,1500)).get(0);
        insert highVolPotentialThreshold ;
        mediumVolPotentialThreshold = (ASI_CRM_TH_TestClassUtilityHelperPROS.createvolumePotentialThreshold(1,groupOutletType.id,mediumVolPotential.id,1000)).get(0);
        insert mediumVolPotentialThreshold ;
        lowVolPotentialThreshold = (ASI_CRM_TH_TestClassUtilityHelperPROS.createvolumePotentialThreshold(1,groupOutletType.id,lowVolPotential.id,500)).get(0);
        insert lowVolPotentialThreshold ;
        
        //Added by Twinkle 20150511 - Avoid UNABLE_TO_LOCK_ROW Testclass Issue
        Id recordtypeId = Global_RecordTypeCache.getRTId('AccountASI_TH_CRM_Outlet');

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
               
        recordtypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_TH_CRM_Outlet');
        prtAccount = new ASI_CRM_AccountsAdditionalField__c(RecordTypeId = recordtypeId, Name = 'TestAccount', ASI_CRM_Account__c = acc.id, ASI_TH_CRM_OutletType__c = ot.id,
                                                            ASI_CRM_Region__c = 'Central', ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street',
                                                            ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12');
        //Added by Twinkle 20150511
        insert prtAccount;
        
        //Added by Twinkle LI @20150622
        recordtypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Segmentation__cASI_CRM_TH_Pros_Segmentation');
        prosSegmentation = new ASI_CRM_Pros_Segmentation__c(RecordTypeId = recordtypeId, ASI_CRM_SG_Customer__c = prtAccount.id);
        insert prosSegmentation;
        //End by Twinkle LI @20150622 
        
        prosSegmentation = [select id from ASI_CRM_Pros_Segmentation__c where ASI_CRM_SG_Customer__c =: prtAccount.id LIMIT 1];
            
       servicePack = ASI_CRM_TH_TestClassUtilityHelperPROS.createServicePack(1, 'ASI_CRM_TH_ServicePack', 'TEST NAME', 'Iconic')[0];
       servicePack.ASI_CRM_SG_Outlet_Type__c = 'TEST NAME';
       insert servicePack;
       
       damdhigh = ASI_CRM_TH_TestClassUtilityHelperPROS.createDAMD(1, 'ASI_CRM_TH_DAMD_Threshold', groupOutletType.Id, mediumVolPotential.Id, 'Attack', 'High', 0.01)[0];
       insert damdhigh;
       damdlow = ASI_CRM_TH_TestClassUtilityHelperPROS.createDAMD(1, 'ASI_CRM_TH_DAMD_Threshold', groupOutletType.Id, mediumVolPotential.Id, 'Defend', 'Low', 0.01)[0];
       insert damdlow;
    }
    
    
    static testMethod void testStaticMethods1(){
        
        init();
        //user = ASI_CRM_TH_TestClassHelperPROS.runAsStandardUserPortugal();
        user = [SELECT id, Managerid, userroleid from user 
        where profile.Name = 'System Administrator' and isactive = true and userroleid <> null limit 1];      
        
        prosSegmentation = (ASI_CRM_TH_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_TH_PROS_Segmentation', 'THB', prtAccount.id, (id)null,(id)null,(id)null,(id)null)).get(0);
        prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.ASI_CRM_SG_Customer__c = prtAccount.id;
        prosSegmentation.ASI_CRM_SG_Image_Level__c = iconicImageLevel.id; 
        insert prosSegmentation;
        prosSegmentation = [select id,ASI_CRM_SG_Customer__c, ASI_CRM_SG_Group_Outlet_Type__c , ASI_CRM_SG_Account__c,
        ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c from ASI_CRM_Pros_Segmentation__c where id =: prosSegmentation.id];
       
       // System.runAs(user){
        
          //  ASI_CRM_TH_ProsSegmentationClass.returnAffiliate();
            ASI_CRM_ID_Card__c idCard = new ASI_CRM_ID_Card__c( ASI_CRM_SG_Outlet__c = prtAccount.Id);
            insert idCard;
            ASI_CRM_TH_ProsSegmentationClass.returnSuperPremium(prtAccount.id);
            ASI_CRM_TH_ProsSegmentationClass.processCriteriaSheetModification(new Set<ID>{criteriaSetImage.id});
            ASI_CRM_TH_ProsSegmentationClass.returnIdCard(prtAccount.id);            
            ASI_CRM_TH_ProsSegmentationClass.returnIdCardMap(new Set<Id>{prtAccount.id});
            
       //  }   
    }
      static testMethod void testStaticMethods2(){
        
        init();
        //user = ASI_CRM_TH_TestClassHelperPROS.runAsStandardUserPortugal();
        user = [SELECT id, Managerid, userroleid from user 
        where profile.Name = 'System Administrator' and isactive = true and userroleid <> null limit 1]; 
        
        prosSegmentation = (ASI_CRM_TH_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_TH_PROS_Segmentation', 'THB', prtAccount.id, (id)null,(id)null,(id)null,(id)null)).get(0);
        prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.ASI_CRM_SG_Customer__c = prtAccount.id;
        prosSegmentation.ASI_CRM_SG_Image_Level__c = iconicImageLevel.id; 
        insert prosSegmentation;
        prosSegmentation = [select id,ASI_CRM_SG_Customer__c, ASI_CRM_SG_Group_Outlet_Type__c , ASI_CRM_SG_Account__c,
        ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c from ASI_CRM_Pros_Segmentation__c where id =: prosSegmentation.id];
       
      //  System.runAs(user){
        
            ASI_CRM_ID_Card__c idCard = new ASI_CRM_ID_Card__c( ASI_CRM_SG_Outlet__c = prtAccount.Id);
            insert idCard;
            ASI_CRM_TH_ProsSegmentationClass.retrieveGroupOutletTypes(new List<ASI_CRM_Pros_Segmentation__c >{prosSegmentation });
            ASI_CRM_TH_ProsSegmentationClass.retrieveImageLevelCriteria(new List<Id>{criteriaSetImage.id});
            ASI_CRM_TH_ProsSegmentationClass.retrieveVolumePotential( 100, new List<ASI_CRM_Volume_Potential_Threshold__c>{mediumVolPotentialThreshold} );
            ASI_CRM_TH_ProsSegmentationClass.retrieveImageLevel(100,new List<ASI_CRM_Image_Level_Threshold__c>{ iconicImageLevelThreshold});
            ASI_CRM_TH_ProsSegmentationClass.retrieveImageLevel(0,new List<ASI_CRM_Image_Level_Threshold__c>{ iconicImageLevelThreshold});
       //  }   
    }
    
    static testMethod void testStaticMethods3(){
        
        init();
        //user = ASI_CRM_TH_TestClassHelperPROS.runAsStandardUserPortugal();
        user = [SELECT id, Managerid, userroleid from user 
        where profile.Name = 'System Administrator' and isactive = true and userroleid <> null limit 1]; 
        
        prosSegmentation = (ASI_CRM_TH_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_TH_PROS_Segmentation', 'THB', prtAccount.id, (id)null,(id)null,(id)null,(id)null)).get(0);
        prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.ASI_CRM_SG_Customer__c = prtAccount.id;
        prosSegmentation.ASI_CRM_SG_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.ASI_CRM_SG_Volume_Potential__c = highVolPotential.Id;
        prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c = highVolPotentialThreshold.Id;
        insert prosSegmentation;
        prosSegmentation = [select id,ASI_CRM_SG_Customer__c, ASI_CRM_SG_Group_Outlet_Type__c , ASI_CRM_SG_Account__c, ASI_CRM_SG_Service_Pack__c, ASI_CRM_SG_Image_Level_Threshold__c, 
        ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c from ASI_CRM_Pros_Segmentation__c where id =: prosSegmentation.id];
            
        ASI_MFM_Brand__c brand = ASI_CRM_TH_TestClassUtilityHelperPROS.createBrand(1, 'ASI_TH_CRM_BRAND', 'Test Brand', '', null)[0];
        brand.ASI_CRM_CN_Competitor__c = false;
        insert brand;
        ASI_CRM_Quality__c qua = ASI_CRM_TH_TestClassUtilityHelperPROS.createBrandQuality(1, 'ASI_CRM_TH_Brand_Quality','TEST BQ', '', brand.Id)[0];
        qua.ASI_CRM_SG_Equivalent_Factor__c = 1;
        insert qua;
        ASI_CRM_ID_Card__c idCard = new ASI_CRM_ID_Card__c( ASI_CRM_SG_Outlet__c = prtAccount.Id);
        insert idCard;
        ASI_CRM_ID_Card_Volume__c idv = new ASI_CRM_ID_Card_Volume__c(ASI_CRM_SG_ID_Card__c = idCard.Id, ASI_CRM_SG_Annual_Volume__c = 1000, ASI_CRM_SG_Service_Mark__c = qua.Id);
        prosSegmentation = ASI_CRM_TH_ProsSegmentationClass.returnProsSegmentationviaId(prosSegmentation.id);
        
        ASI_CRM_TH_ProsSegmentationClass.retrieveGroupOutletTypes(new List<ASI_CRM_Pros_Segmentation__c >{prosSegmentation });
        ASI_CRM_TH_ProsSegmentationClass.retrieveImageLevel(100,new List<ASI_CRM_Image_Level_Threshold__c>{ iconicImageLevelThreshold, leadingImageLevelThreshold, premiumImageLevelThreshold, mainstreamImageLevelThreshold});
        ASI_CRM_TH_ProsSegmentationClass.retrieveImageLevelCriteria(new List<Id>{criteriaSetImage.id});
        ASI_CRM_TH_ProsSegmentationClass.retrieveVolumePotential( 1200, new List<ASI_CRM_Volume_Potential_Threshold__c>{highVolPotentialThreshold, mediumVolPotentialThreshold, lowVolPotentialThreshold} );
                   
        Map<Id, ASI_CRM_ID_Card__c> idCardsV = new Map<Id, ASI_CRM_ID_Card__c>{prosSegmentation.ASI_CRM_SG_Customer__c => idCard};            
        ASI_CRM_TH_ProsSegmentationClass.assignVolumePotential(new List<ASI_CRM_Pros_Segmentation__c>{prosSegmentation}, idCardsV);
        
        Map<Id, ASI_CRM_ID_Card__c> idCardsI = new Map<Id, ASI_CRM_ID_Card__c>();
        idCardsI.put(idCard.ASI_CRM_SG_Outlet__c, idCard);
        
        ASI_CRM_TH_ProsSegmentationClass.assignImageLevel(new Map<Id, ASI_CRM_Pros_Segmentation__c>{prosSegmentation.Id => prosSegmentation}, idCardsI);
        
        test.startTest();
        
        Map<Id, List<ASI_CRM_Criteria_Answer__c>> mapCriteriaAns = new Map<Id, List<ASI_CRM_Criteria_Answer__c>>();
        mapCriteriaAns.put(criteriaAnswerImage.id, new List<ASI_CRM_Criteria_Answer__c>{criteriaAnswerImage});       
        
        ASI_CRM_TH_ProsSegmentationClass.returnImageLevelLabels();
        ASI_CRM_TH_ProsSegmentationClass.returnVolumePotentialLabels();
        ASI_CRM_TH_ProsSegmentationClass.returnImageLevels((String)groupOutletType.id);
        ASI_CRM_TH_ProsSegmentationClass.returnVolumePotential((String)groupOutletType.id);
        ASI_CRM_TH_ProsSegmentationClass.returnImageVolumeMatrix(prosSegmentation);
        ASI_CRM_TH_ProsSegmentationClass.returnSuperPremium(prtAccount.id);
        ASI_CRM_TH_ProsSegmentationClass.processCriteriaSheetModification(new Set<ID>{criteriaSetImage.id});
        ASI_CRM_TH_ProsSegmentationClass.processPicklistCriteriaSheetModification(new Set<ID>{criteriaSetImage.id}, mapCriteriaAns);
        ASI_CRM_TH_ProsSegmentationClass.returnIdCard(prtAccount.id);            
        ASI_CRM_TH_ProsSegmentationClass.returnIdCardMap(new Set<Id>{prtAccount.id});
        ASI_CRM_TH_ProsSegmentationClass.returnMarketShareLabels();
        ASI_CRM_TH_ProsSegmentationClass.retrieveDAMDMatrix(idCard, prosSegmentation);
        ASI_CRM_TH_ProsSegmentationClass.returnServicePackId(prosSegmentation);
        ASI_CRM_TH_ProsSegmentationClass.resetServicePack(prosSegmentation);   
        ASI_CRM_TH_ProsSegmentationClass.resetProsSegmentation(prosSegmentation); 
        
        test.stopTest();                
    }
    static testMethod void testStaticMethods4(){
        
        init();
        //user = ASI_CRM_TH_TestClassHelperPROS.runAsStandardUserPortugal();
        user = [SELECT id, Managerid, userroleid from user 
        where profile.Name = 'System Administrator' and isactive = true and userroleid <> null limit 1]; 
        
        prosSegmentation = (ASI_CRM_TH_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_TH_PROS_Segmentation', 'THB', prtAccount.id, (id)null,(id)null,(id)null,(id)null)).get(0);
        prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.ASI_CRM_SG_Customer__c = prtAccount.id;
        prosSegmentation.ASI_CRM_SG_Image_Level__c = iconicImageLevel.id; 
        insert prosSegmentation;
        prosSegmentation = [select id,ASI_CRM_SG_Customer__c, ASI_CRM_SG_Group_Outlet_Type__c , ASI_CRM_SG_Account__c, ASI_CRM_SG_Service_Pack__c, ASI_CRM_SG_Image_Level_Threshold__c, 
        ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c from ASI_CRM_Pros_Segmentation__c where id =: prosSegmentation.id];
            
            ASI_MFM_Brand__c brand = ASI_CRM_TH_TestClassUtilityHelperPROS.createBrand(1, 'ASI_TH_CRM_BRAND', 'Test Brand', '', null)[0];
            brand.ASI_CRM_CN_Competitor__c = false;
            insert brand;
            ASI_CRM_Quality__c qua = ASI_CRM_TH_TestClassUtilityHelperPROS.createBrandQuality(1, 'ASI_CRM_TH_Brand_Quality','TEST BQ', '', brand.Id)[0];
            qua.ASI_CRM_SG_Equivalent_Factor__c = 1;
            insert qua;
            ASI_CRM_ID_Card__c idCard = new ASI_CRM_ID_Card__c( ASI_CRM_SG_Outlet__c = prtAccount.Id);
            insert idCard;
            ASI_CRM_ID_Card_Volume__c idv = new ASI_CRM_ID_Card_Volume__c(ASI_CRM_SG_ID_Card__c = idCard.Id, ASI_CRM_SG_Annual_Volume__c = 1000, ASI_CRM_SG_Service_Mark__c = qua.Id);
            prosSegmentation = ASI_CRM_TH_ProsSegmentationClass.returnProsSegmentationviaId(prosSegmentation.id);
            
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/ASI_CRM_TH_ProsSegmentationPage');
        rf.getParameters().put('id', prosSegmentation.id);
        Test.setCurrentPage(rf);

        ASI_CRM_TH_ProsSegmentationExt  controller = new ASI_CRM_TH_ProsSegmentationExt (standardController);
        controller.initSummary();
    }
    
}