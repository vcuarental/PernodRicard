@isTest
public with sharing class EUR_CRM_TestProsSegmentationClass {
private static EUR_CRM_Group_Outlet_Type__c groupOutletType;
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
    private static EUR_CRM_Affiliate__c affiliate;
    private static User user;
     public static void init(){
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
        if(countryCode =='PRT' && ( criteriaSetVolume.RecordTypeId == null || criteriaSetVolume.RecordTypeId == ''))        
         criteriaSetVolume = (EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1,'Volume Potential Criteria (PRT)')).get(0);
             
        insert criteriaSetVolume ; 
        //create criteria threshold
        criteriaThresholdVolume = (EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1,'Text Input',criteriaSetVolume.id)).get(0);
        criteriaThresholdVolume.EUR_CRM_Question__c = 'Potential Volume';
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
            insert affiliate;
    }
     
    static testMethod void testReturnProsSegmentationviaId(){ 
        countryCode ='EE';
        init();
        Test.startTest();
        EUR_CRM_ProsSegmentationClass.returnProsSegmentationviaId(prosSegmentation.id);
        Test.stopTest();
    }
    static testMethod void testReturnProsSegmentationviaIdIsPRT(){ 
        countryCode = 'PRT';
        init();
        Test.startTest();
        prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        insert prosSegmentation;
        EUR_CRM_ProsSegmentationClass.returnProsSegmentationviaId(prosSegmentation.id);
        Test.stopTest();
    }

    static testMethod void testReturnImageLevelLabels(){
        EUR_CRM_ProsSegmentationClass.returnImageLevelLabels();
        EUR_CRM_ProsSegmentationClass.returnImageLevelLabels('UK');
        EUR_CRM_ProsSegmentationClass.returnImageLevelLabels('EE');
    }
    static testMethod void testReturnVolumePotentialLabels(){
        EUR_CRM_ProsSegmentationClass.returnVolumePotentialLabels();
    }
   	
    static testMethod void testReturnImageVolumeMatrix(){
        countryCode ='EE';
        init();
        prosSegmentation.EUR_CRM_Image_Level_Threshold__c =  premiumImageLevelThreshold.id; 
        prosSegmentation.EUR_CRM_Volume_Potential_Threshold__c = highVolPontentialThreshold.id; 
        Test.startTest(); // Edited By Jay 20160927
        update prosSegmentation;
        Test.stopTest(); // Edited By Jay 20160927
        EUR_CRM_ProsSegmentationClass.returnImageVolumeMatrix(prosSegmentation);
        
    }
    static testMethod void testReturnImageLevels(){
        countryCode ='EE';
        init();
        EUR_CRM_ProsSegmentationClass.returnImageLevels((String)groupOutletType.id);
        EUR_CRM_ProsSegmentationClass.returnVolumePotential((String)groupOutletType.id);
    }
    static testMethod void testReturnServicePackId(){
        countryCode = 'PRT';
        init();
        prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.EUR_CRM_Service_Pack__c = null;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        insert prosSegmentation;
        EUR_CRM_ProsSegmentationClass.returnServicePackId(prosSegmentation);
        EUR_CRM_ProsSegmentationClass.resetProsSegmentation(prosSegmentation);  
        EUR_CRM_ProsSegmentationClass.resetProsSegmentation(prosSegmentation); 
        
    }
    static testMethod void testReturnServicePackId2(){
        countryCode = 'PRT';
        init();
        prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.EUR_CRM_Service_Pack__c = null;
        insert prosSegmentation;
        EUR_CRM_ProsSegmentationClass.resetServicePack(prosSegmentation);   
        
    }
     
    static testMethod void testAssignImageLevel2(){
        countryCode = 'PRT';
        init();
        prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id; 
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        insert prosSegmentation;
        EUR_CRM_Pros_Image_Level__c prosImage = (EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1,'EUR',prosSegmentation.id, criteriaThresholdImage.id)).get(0);
        insert prosImage;
        prosSegmentation = [select id,EUR_CRM_Total_Image_Level_Weight__c,EUR_CRM_Country_Code__c,EUR_CRM_Standard_Account__c, EUR_CRM_Group_Outlet_Type__c , EUR_CRM_Account__c,
        EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Image_Criteria_Set__c from EUR_CRM_Pros_Segmentation__c where id =: prosSegmentation.id];
        user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
      //  System.runAs(user){

          
            //Create Pros Segmentation
            
           
            update prosSegmentation;
            List<EUR_CRM_Pros_Segmentation__c> prosSegmentations = new List<EUR_CRM_Pros_Segmentation__c>{prosSegmentation};
            
            //Create ID Card
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c( EUR_CRM_Outlet__c = prtAccount.Id);
            insert idCard;
            Map<Id, EUR_CRM_ID_Card__c> idCards = new Map<Id, EUR_CRM_ID_Card__c>();
             idCards.put(idCard.EUR_CRM_Outlet__c, idCard);
            
            Map<Id, EUR_CRM_Pros_Segmentation__c> prosMap = new Map<Id, EUR_CRM_Pros_Segmentation__c>();
            prosMap.put(prosSegmentation.Id, prosSegmentation);
            
            EUR_CRM_ProsSegmentationClass.assignImageLevel(prosMap, idCards);
      //  }
    }
 
    static testMethod void testAssignVolumePotential(){
        countryCode = 'PRT';
        init();
        Test.startTest();
        prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id; 
        insert prosSegmentation;
        EUR_CRM_Pros_Volume_Potential__c prosVolPot = (EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1,'EUR_PRT_ProsVolumePotential','EUR',prosSegmentation.id, criteriaThresholdVolume.id)).get(0);
        insert prosVolPot;
        prosSegmentation = [select id,EUR_CRM_Country_Code__c,EUR_CRM_Standard_Account__c, EUR_CRM_Group_Outlet_Type__c , EUR_CRM_Account__c,
        EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Image_Criteria_Set__c from EUR_CRM_Pros_Segmentation__c where id =: prosSegmentation.id];
        user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
      //  System.runAs(user){
            List<EUR_CRM_Pros_Segmentation__c> prosSegmentations = new List<EUR_CRM_Pros_Segmentation__c>{prosSegmentation};
            
            //Create ID Card
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c( EUR_CRM_Outlet__c = prtAccount.Id);
            insert idCard;
            Map<Id, EUR_CRM_ID_Card__c> idCards = new Map<Id, EUR_CRM_ID_Card__c>{prosSegmentation.EUR_CRM_Standard_Account__c=>idCard};
            
            EUR_CRM_ProsSegmentationClass.assignVolumePotential(prosSegmentations, idCards);
       // }
       
       test.stopTest();
    }
    
    static testMethod void testStaticMethods1(){
        countryCode = 'PRT';
        init();
        user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        
        String companyName = ([select id,name from EUR_CRM_Affiliate__c where id =: affiliate.id]).name;
        user.CompanyName = companyName;
        update user;
        prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id; 
        insert prosSegmentation;
         prosSegmentation = [select id,EUR_CRM_Country_Code__c,EUR_CRM_Standard_Account__c, EUR_CRM_Group_Outlet_Type__c , EUR_CRM_Account__c,
        EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Image_Criteria_Set__c,EUR_CRM_Affiliate__c from EUR_CRM_Pros_Segmentation__c where id =: prosSegmentation.id];
       
       // System.runAs(user){
        
          //  EUR_CRM_ProsSegmentationClass.returnAffiliate();
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c( EUR_CRM_Outlet__c = prtAccount.Id);
            insert idCard;
            EUR_CRM_ProsSegmentationClass.returnSuperPremium(prtAccount.id);
            EUR_CRM_ProsSegmentationClass.processCriteriaSheetModification(new Set<ID>{criteriaSetImage.id});
            EUR_CRM_ProsSegmentationClass.returnIdCard(prtAccount.id);            
            EUR_CRM_ProsSegmentationClass.returnIdCardMap(new Set<Id>{prtAccount.id});
            EUR_CRM_ProsSegmentationClass.retrieveAffiliates(); 
        System.runAs(user){
        	EUR_CRM_ProsSegmentationClass.returnAffiliate();
        }
       //  }   
    }
      static testMethod void testStaticMethods2(){
        countryCode = 'PRT';
        init();
        user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        
        String companyName = ([select id,name from EUR_CRM_Affiliate__c where id =: affiliate.id]).name;
        user.CompanyName = companyName;
        update user;
        prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id; 
        insert prosSegmentation;
         prosSegmentation = [select id,EUR_CRM_Country_Code__c,EUR_CRM_Standard_Account__c, EUR_CRM_Group_Outlet_Type__c , EUR_CRM_Account__c,
        EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Image_Criteria_Set__c,EUR_CRM_Affiliate__c from EUR_CRM_Pros_Segmentation__c where id =: prosSegmentation.id];
       
      //  System.runAs(user){
        
           // EUR_CRM_ProsSegmentationClass.returnAffiliate();
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c( EUR_CRM_Outlet__c = prtAccount.Id);
            insert idCard; 
            EUR_CRM_ProsSegmentationClass.retrieveGroupOutletTypes(new List<EUR_CRM_Pros_Segmentation__c >{prosSegmentation });
            EUR_CRM_ProsSegmentationClass.retrieveImageLevelCriteria(new List<Id>{criteriaSetImage.id});
            EUR_CRM_ProsSegmentationClass.retrieveVolumePotential( 100, new List<EUR_CRM_Volume_Potential_Threshold__c>{mediumVolPontentialThreshold} );
            EUR_CRM_ProsSegmentationClass.retrieveImageLevel(100,new List<EUR_CRM_Image_Level_Threshold__c>{ iconicImageLevelThreshold});
            EUR_CRM_ProsSegmentationClass.retrieveImageLevel(0,new List<EUR_CRM_Image_Level_Threshold__c>{ iconicImageLevelThreshold});
       //  }   
    }
/*
    private static User user;
    private static Account account;
    private static EUR_CRM_Affiliate__c affiliate;
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
    private static String groupOutlet;
    private static String imageLevel;
    
    private static EUR_CRM_Group_Outlet_Type__c groupOutletType;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold;
    private static EUR_CRM_Criteria_Set__c criteriaSet;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer;
    private static String groupOutletName;
    private static String value;
    
    private static String question;
    private static EUR_CRM_Group_Outlet_Type__c groupOutletObj;
    private static EUR_CRM_CriteriaManager mgr;// = new EUR_CRM_CriteriaManager();
    
    
    public static void setupUser(){
      user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
      user.BypassTriggers__c = 'ESN_User_AutojoinByAffiliates';
    }
    
    public static void init()
    {   
      System.debug('Using user:' + user.Username + '-' + user.CompanyName);
        
        //System.runAs(user){
          account = EUR_CRM_TestClassHelper.createAccount('Test');    
          insert account;
                  
          affiliate = EUR_CRM_TestClassHelper.createAffiliate();
          insert affiliate;
          
          groupOutlet = 'High Energy Bar';
          imageLevel = 'Iconic';
       // }
    }
    
    public static void initCriteria(){
        question = 'Sample question 1?';
        //System.runAs(user){
          mgr = new EUR_CRM_CriteriaManager();
          
          account = EUR_CRM_TestClassHelper.createAccount('Test');    
          insert account;
          
          affiliate = EUR_CRM_TestClassHelper.createAffiliate();
          insert affiliate;   
          //Create Criteria Set for Image Level
          criteriaSet = EUR_CRM_TestClassHelper.createCriteriaSet(EUR_CRM_TestClassHelper.volumeRecordType.Id);
          insert criteriaSet;   
        //}  
    }
    
    static void initIntegerCriteria(){
      setupUser();
      
      System.runAs(user){
          initCriteria();
          
          criteriaThreshold = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                              EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                              question, 100);
          insert criteriaThreshold;
          
          criteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id, 'Greater Than (>)', Integer.valueOf(0), 100);
          insert criteriaAnswer;
      }
    }
    
    static testMethod void testResetProsSegmentationSc1()
    {
        setupUser();
        
        System.runAs(user){
          init();
            //Create Service Pack
            EUR_CRM_Service_Pack__c servicePack = EUR_CRM_TestClassHelper.createServicePack(affiliate.Id, groupOutlet, imageLevel);
            insert servicePack;
            
            //Create Pros Segmentation
            prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id, servicePack.Id);
            prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutlet;
            prosSegmentation.EUR_CRM_Image_Level__c = 'Mainstream';
            prosSegmentation.EUR_CRM_Volume_Potential__c = 'High';
            insert prosSegmentation;
            
            initCriteria();
            EUR_CRM_Criteria_Threshold__c criteriaThreshold1 = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                            question, 10);
            insert criteriaThreshold1;
            EUR_CRM_Criteria_Threshold__c criteriaThreshold2 = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                            question, 20);
            insert criteriaThreshold2;
            EUR_CRM_Criteria_Threshold__c criteriaThreshold3 = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                            question, 30);
            insert criteriaThreshold3;
            EUR_CRM_Criteria_Threshold__c criteriaThreshold4 = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                            question, 40);
            insert criteriaThreshold4;
            
            //criteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id, 'Greater Than (>)', Integer.valueOf(0), 100);
            //insert criteriaAnswer;
            
            //Create Pros image Level
            List<EUR_CRM_Pros_Image_Level__c> prosImageLevels = new List<EUR_CRM_Pros_Image_Level__c>();
            prosImageLevels.add(EUR_CRM_TestClassHelper.createProsImageLevel(criteriaThreshold1.Id, prosSegmentation.Id, 'Test1', 10));
            prosImageLevels.add(EUR_CRM_TestClassHelper.createProsImageLevel(criteriaThreshold2.Id, prosSegmentation.Id, 'Test2', 20));
            prosImageLevels.add(EUR_CRM_TestClassHelper.createProsImageLevel(criteriaThreshold3.Id, prosSegmentation.Id, 'Test3', 30));
            prosImageLevels.add(EUR_CRM_TestClassHelper.createProsImageLevel(criteriaThreshold4.Id, prosSegmentation.Id, 'Test4', 40));
            insert prosImageLevels;
            
            //Create Pros Volume Potential
            List<EUR_CRM_Pros_Volume_Potential__c> prosVolumePotentials = new List<EUR_CRM_Pros_Volume_Potential__c>();
            prosVolumePotentials.add(EUR_CRM_TestClassHelper.createProsVolumePotential(criteriaThreshold1.Id, prosSegmentation.Id, 'Test1', 10));
            prosVolumePotentials.add(EUR_CRM_TestClassHelper.createProsVolumePotential(criteriaThreshold2.Id, prosSegmentation.Id, 'Test2', 20));
            prosVolumePotentials.add(EUR_CRM_TestClassHelper.createProsVolumePotential(criteriaThreshold3.Id, prosSegmentation.Id, 'Test3', 30));
            prosVolumePotentials.add(EUR_CRM_TestClassHelper.createProsVolumePotential(criteriaThreshold4.Id, prosSegmentation.Id, 'Test4', 40));
            insert prosVolumePotentials;
            
            EUR_CRM_ProsSegmentationClass.resetServicePack(prosSegmentation);
            
            List<EUR_CRM_Pros_Image_Level__c> prosImageLevelsAfter= [SELECT ID FROM EUR_CRM_Pros_Image_Level__c 
                                                    WHERE EUR_CRM_Pros_Segmentation__c =:prosSegmentation.Id];
            List<EUR_CRM_Pros_Volume_Potential__c> prosVolumePotentialsAfter= [SELECT ID FROM EUR_CRM_Pros_Volume_Potential__c 
                                                    WHERE EUR_CRM_Pros_Segmentation__c =:prosSegmentation.Id];
            
            System.assertEquals(prosSegmentation.EUR_CRM_Group_Outlet_Type__c, groupOutlet);
            //System.assertEquals(prosSegmentation.EUR_CRM_Image_Level__c, null);
            //System.assertEquals(prosSegmentation.EUR_CRM_Volume_Potential__c, null);
            //System.assertEquals(prosSegmentation.EUR_CRM_Service_Pack__c, null);
            
            //System.assertEquals(prosImageLevelsAfter.size(), 0);
            //System.assertEquals(prosVolumePotentialsAfter.size(), 0);
        }
    }
    
    static testMethod void testResetProsSegmentationSc2()
    {
        setupUser();
        
        System.runAs(user){
          init();
            //Create Service Pack
            EUR_CRM_Service_Pack__c servicePack = EUR_CRM_TestClassHelper.createServicePack(affiliate.Id, groupOutlet, imageLevel);
            insert servicePack;
            
            //Create Pros Segmentation
            prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id, servicePack.Id);
            prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutlet;
            prosSegmentation.EUR_CRM_Image_Level__c = imageLevel;
            prosSegmentation.EUR_CRM_Volume_Potential__c = 'Low';
            insert prosSegmentation;
            
            initCriteria();
            EUR_CRM_Criteria_Threshold__c criteriaThreshold1 = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                            question, 10);
            insert criteriaThreshold1;
            EUR_CRM_Criteria_Threshold__c criteriaThreshold2 = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                            question, 20);
            insert criteriaThreshold2;
            EUR_CRM_Criteria_Threshold__c criteriaThreshold3 = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                            question, 30);
            insert criteriaThreshold3;
            EUR_CRM_Criteria_Threshold__c criteriaThreshold4 = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                            question, 40);
            insert criteriaThreshold4;
            
            //criteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id, 'Greater Than (>)', Integer.valueOf(0), 100);
            //insert criteriaAnswer;
            
            //Create Pros image Level
            List<EUR_CRM_Pros_Image_Level__c> prosImageLevels = new List<EUR_CRM_Pros_Image_Level__c>();
            prosImageLevels.add(EUR_CRM_TestClassHelper.createProsImageLevel(criteriaThreshold1.Id, prosSegmentation.Id, 'Test1', 10));
            prosImageLevels.add(EUR_CRM_TestClassHelper.createProsImageLevel(criteriaThreshold2.Id, prosSegmentation.Id, 'Test2', 20));
            prosImageLevels.add(EUR_CRM_TestClassHelper.createProsImageLevel(criteriaThreshold3.Id, prosSegmentation.Id, 'Test3', 30));
            prosImageLevels.add(EUR_CRM_TestClassHelper.createProsImageLevel(criteriaThreshold4.Id, prosSegmentation.Id, 'Test4', 40));
            insert prosImageLevels;
            
            //Create Pros Volume Potential
            List<EUR_CRM_Pros_Volume_Potential__c> prosVolumePotentials = new List<EUR_CRM_Pros_Volume_Potential__c>();
            prosVolumePotentials.add(EUR_CRM_TestClassHelper.createProsVolumePotential(criteriaThreshold1.Id, prosSegmentation.Id, 'Test1', 10));
            prosVolumePotentials.add(EUR_CRM_TestClassHelper.createProsVolumePotential(criteriaThreshold2.Id, prosSegmentation.Id, 'Test2', 20));
            prosVolumePotentials.add(EUR_CRM_TestClassHelper.createProsVolumePotential(criteriaThreshold3.Id, prosSegmentation.Id, 'Test3', 30));
            prosVolumePotentials.add(EUR_CRM_TestClassHelper.createProsVolumePotential(criteriaThreshold4.Id, prosSegmentation.Id, 'Test4', 40));
            insert prosVolumePotentials;
            
            EUR_CRM_ProsSegmentationClass.resetServicePack(prosSegmentation);
            
            List<EUR_CRM_Pros_Image_Level__c> prosImageLevelsAfter= [SELECT ID FROM EUR_CRM_Pros_Image_Level__c 
                                                    WHERE EUR_CRM_Pros_Segmentation__c =:prosSegmentation.Id];
            List<EUR_CRM_Pros_Volume_Potential__c> prosVolumePotentialsAfter= [SELECT ID FROM EUR_CRM_Pros_Volume_Potential__c 
                                                    WHERE EUR_CRM_Pros_Segmentation__c =:prosSegmentation.Id];
            
            System.assertEquals(prosSegmentation.EUR_CRM_Group_Outlet_Type__c, groupOutlet);
            //System.assertEquals(prosSegmentation.EUR_CRM_Image_Level__c, null);
            //System.assertEquals(prosSegmentation.EUR_CRM_Volume_Potential__c, null);
            //System.assertEquals(prosSegmentation.EUR_CRM_Service_Pack__c, null);
            
            //System.assertEquals(prosImageLevelsAfter.size(), 0);
            //System.assertEquals(prosVolumePotentialsAfter.size(), 0);
        }
    }
    
    static testMethod void testResetProsSegmentationSc3()
    {
        setupUser();
        
        System.runAs(user){
          init();
            //Create Service Pack
            EUR_CRM_Service_Pack__c servicePack = EUR_CRM_TestClassHelper.createServicePack(affiliate.Id, groupOutlet, imageLevel);
            insert servicePack;
            
            //Create Pros Segmentation
            prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id, servicePack.Id);
            prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutlet;
            prosSegmentation.EUR_CRM_Image_Level__c = imageLevel;
            prosSegmentation.EUR_CRM_Volume_Potential__c = 'Medium';
            insert prosSegmentation;
            
            initCriteria();
            EUR_CRM_Criteria_Threshold__c criteriaThreshold1 = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                            question, 10);
            insert criteriaThreshold1;
            EUR_CRM_Criteria_Threshold__c criteriaThreshold2 = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                            question, 20);
            insert criteriaThreshold2;
            EUR_CRM_Criteria_Threshold__c criteriaThreshold3 = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                            question, 30);
            insert criteriaThreshold3;
            EUR_CRM_Criteria_Threshold__c criteriaThreshold4 = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                            question, 40);
            insert criteriaThreshold4;
            
            //criteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id, 'Greater Than (>)', Integer.valueOf(0), 100);
            //insert criteriaAnswer;
            
            //Create Pros image Level
            List<EUR_CRM_Pros_Image_Level__c> prosImageLevels = new List<EUR_CRM_Pros_Image_Level__c>();
            prosImageLevels.add(EUR_CRM_TestClassHelper.createProsImageLevel(criteriaThreshold1.Id, prosSegmentation.Id, 'Test1', 10));
            prosImageLevels.add(EUR_CRM_TestClassHelper.createProsImageLevel(criteriaThreshold2.Id, prosSegmentation.Id, 'Test2', 20));
            prosImageLevels.add(EUR_CRM_TestClassHelper.createProsImageLevel(criteriaThreshold3.Id, prosSegmentation.Id, 'Test3', 30));
            //prosImageLevels.add(EUR_CRM_TestClassHelper.createProsImageLevel(criteriaThreshold4.Id, prosSegmentation.Id, 'Test4', 40));
            insert prosImageLevels;
            
            //Create Pros Volume Potential
            List<EUR_CRM_Pros_Volume_Potential__c> prosVolumePotentials = new List<EUR_CRM_Pros_Volume_Potential__c>();
            prosVolumePotentials.add(EUR_CRM_TestClassHelper.createProsVolumePotential(criteriaThreshold1.Id, prosSegmentation.Id, 'Test1', 10));
            prosVolumePotentials.add(EUR_CRM_TestClassHelper.createProsVolumePotential(criteriaThreshold2.Id, prosSegmentation.Id, 'Test2', 20));
            prosVolumePotentials.add(EUR_CRM_TestClassHelper.createProsVolumePotential(criteriaThreshold3.Id, prosSegmentation.Id, 'Test3', 30));
            //prosVolumePotentials.add(EUR_CRM_TestClassHelper.createProsVolumePotential(criteriaThreshold4.Id, prosSegmentation.Id, 'Test4', 40));
            insert prosVolumePotentials;
            
            EUR_CRM_ProsSegmentationClass.resetServicePack(prosSegmentation);
            
            List<EUR_CRM_Pros_Image_Level__c> prosImageLevelsAfter= [SELECT ID FROM EUR_CRM_Pros_Image_Level__c 
                                                    WHERE EUR_CRM_Pros_Segmentation__c =:prosSegmentation.Id];
            List<EUR_CRM_Pros_Volume_Potential__c> prosVolumePotentialsAfter= [SELECT ID FROM EUR_CRM_Pros_Volume_Potential__c 
                                                    WHERE EUR_CRM_Pros_Segmentation__c =:prosSegmentation.Id];
            
            System.assertEquals(prosSegmentation.EUR_CRM_Group_Outlet_Type__c, groupOutlet);
            //System.assertEquals(prosSegmentation.EUR_CRM_Image_Level__c, null);
            //System.assertEquals(prosSegmentation.EUR_CRM_Volume_Potential__c, null);
            //System.assertEquals(prosSegmentation.EUR_CRM_Service_Pack__c, null);
            
            //System.assertEquals(prosImageLevelsAfter.size(), 0);
            //System.assertEquals(prosVolumePotentialsAfter.size(), 0);
        }
    }
    
    
    static testMethod void testResetServicePackSc1()
    {
         setupUser();
         
        System.runAs(user){
          init();
            //Create Pros Segmentation
            prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id);
            prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutlet;
            prosSegmentation.EUR_CRM_Image_Level__c = imageLevel;
            insert prosSegmentation;
            
            EUR_CRM_ProsSegmentationClass.resetServicePack(prosSegmentation);   
            
            System.assertEquals(prosSegmentation.EUR_CRM_Service_Pack__c, null);
        }
    }
    
    static testMethod void testResetServicePackSc2()
    {
        setupUser();
        
        System.runAs(user){
          init();
            //Create Service Pack
            EUR_CRM_Service_Pack__c servicePack = EUR_CRM_TestClassHelper.createServicePack(affiliate.Id, groupOutlet, imageLevel);
            insert servicePack;
            
            //Create Pros Segmentation
            prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id);
            prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutlet;
            prosSegmentation.EUR_CRM_Image_Level__c = imageLevel;
            insert prosSegmentation;
            
            EUR_CRM_ProsSegmentationClass.resetServicePack(prosSegmentation);   
            
            System.assertEquals(prosSegmentation.EUR_CRM_Service_Pack__c, servicePack.Id);
        }
    }
    
    static testMethod void testReturnProsSegmentationViaId(){
        setupUser();
        System.runAs(user){
          init();
          
            prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id);
            insert prosSegmentation;
            
            EUR_CRM_Pros_Segmentation__c resProsSeg = EUR_CRM_ProsSegmentationClass.returnProsSegmentationviaId(prosSegmentation.Id);
            System.assertEquals(prosSegmentation.id, resProsSeg.Id);
        }
    }
    
    static testMethod void testReturnImageLevelLabels(){
        setupUser();
    System.runAs(user){
      init();
      
          List<String> imageLevelLabels = new List<String>();
          
          imageLevelLabels= EUR_CRM_ProsSegmentationClass.returnImageLevelLabels();
          System.assertNotEquals(imageLevelLabels.size(), 0);
    }
    }
    
    static testMethod void testReturnVolumePotentialLabels(){
        setupUser();
        
        System.runAs(user){
          init();
          
          List<String> volumePotentialLabels = new List<String>();
          
          volumePotentialLabels= EUR_CRM_ProsSegmentationClass.returnVolumePotentialLabels();
          System.assertNotEquals(volumePotentialLabels.size(), 0);
        }
    }
    
    static testMethod void testReturnImageVolumeMatrix(){
        setupUser();
        
        System.runAs(user){
          init();
          
            prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id);
            insert prosSegmentation;
            
            Map<String, Boolean> resImageVolumeMatrix = new Map<String, Boolean>();
            resImageVolumeMatrix = EUR_CRM_ProsSegmentationClass.returnImageVolumeMatrix(prosSegmentation);
            System.assertNotEquals(resImageVolumeMatrix.size(), 0);
        }
    }
    
    static testMethod void testReturnImageLevels1(){
        setupUser();
        
        System.runAs(user){
          init();
          
          groupOutletName = 'Test'; 
              
          groupOutletType = EUR_CRM_TestClassHelper.createGroupOutlet(groupOutletName, affiliate.Id, null, null);
          insert groupOutletType;
          
          List<EUR_CRM_Image_Level_Threshold__c> imageLevels = new List<EUR_CRM_Image_Level_Threshold__c>();
          imageLevels = EUR_CRM_ProsSegmentationClass.returnImageLevels(groupOutletName);
          
          System.assertEquals(imageLevels.size(), 0);
        }
    }
    
    static testMethod void testReturnImageLevels2(){
        setupUser();
        
        System.runAs(user){
          init();
          
          initCriteria();
          
          groupOutletName = 'Test'; 
              
          groupOutletType = EUR_CRM_TestClassHelper.createGroupOutlet(groupOutletName, affiliate.Id, criteriaSet.Id, null);
          insert groupOutletType;
          
          List<EUR_CRM_Image_Level_Threshold__c> imageLevels = new List<EUR_CRM_Image_Level_Threshold__c>();
          imageLevels = EUR_CRM_ProsSegmentationClass.returnImageLevels(groupOutletName);
          
          System.assertEquals(imageLevels.size(), 0);
        }
    }
    
    static testMethod void testReturnVolumePotential(){
        setupUser();
        
        System.runAs(user){
          init();
          
          groupOutletName = 'Test'; 
              
          groupOutletType = EUR_CRM_TestClassHelper.createGroupOutlet(groupOutletName, affiliate.Id, null, null);
          insert groupOutletType;
          
          List<EUR_CRM_Volume_Potential_Threshold__c> volPotentials = new List<EUR_CRM_Volume_Potential_Threshold__c>();
          volPotentials = EUR_CRM_ProsSegmentationClass.returnVolumePotential(groupOutletName);
          
          System.assertEquals(volPotentials.size(), 0);
        }
    }
    
    static testMethod void testReturnServicePackId(){
        setupUser();
        
        System.runAs(user){
          init();
          
          //Create Pros Segmentation
          prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id, null);
          prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutlet;
          prosSegmentation.EUR_CRM_Image_Level__c = imageLevel;
          prosSegmentation.EUR_CRM_Volume_Potential__c = 'Test';
          insert prosSegmentation;
              
          Id servicePackId = EUR_CRM_ProsSegmentationClass.returnServicePackId(prosSegmentation);
          
          System.assertEquals(servicePackId, null);
        }
    }
    
    static testMethod void testReturnServicePackId2(){
        setupUser();
        
        System.runAs(user){
          init();
          
          //Create Pros Segmentation
          prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id, null);
          prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutlet;
          //prosSegmentation.EUR_CRM_Image_Level__c = imageLevel;
          prosSegmentation.EUR_CRM_Volume_Potential__c = 'Test';
          insert prosSegmentation;
              
          Id servicePackId = EUR_CRM_ProsSegmentationClass.returnServicePackId(prosSegmentation);
          
          System.assertEquals(servicePackId, null);
        }
    }
    
    static testMethod void testRetrieveServicePack(){
        setupUser();
        
        System.runAs(user){
          init();
          
          //Create Pros Segmentation
          prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id, null);
          prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutlet;
          prosSegmentation.EUR_CRM_Image_Level__c = imageLevel;
          prosSegmentation.EUR_CRM_Volume_Potential__c = 'Test';
          insert prosSegmentation;
          EUR_CRM_Service_Pack__c servicePack = EUR_CRM_ProsSegmentationClass.retrieveServicePack(prosSegmentation);
          
          System.assertEquals(servicePack, null);
        }
    }
    
    static testMethod void testRetrieveServicePack2(){
        setupUser();
        
        System.runAs(user){
          init();
          
          //Create Pros Segmentation
          prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id, null);
          prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutlet;
          prosSegmentation.EUR_CRM_Volume_Potential__c = 'Test';
          insert prosSegmentation;
          EUR_CRM_Service_Pack__c servicePack = EUR_CRM_ProsSegmentationClass.retrieveServicePack(prosSegmentation);
          
          System.assertEquals(servicePack, null);
        }
    }
    
    static testMethod void testRetrieveServicePack3(){
        setupUser();
        
        System.runAs(user){
          init();
          
          //Create Pros Segmentation
          prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id, null);
          //prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutlet;
          prosSegmentation.EUR_CRM_Volume_Potential__c = 'Test';
          insert prosSegmentation;
          EUR_CRM_Service_Pack__c servicePack = EUR_CRM_ProsSegmentationClass.retrieveServicePack(prosSegmentation);
          
          System.assertEquals(servicePack, null);
        }
    }
    
    static testMethod void testReturnSuperPremium(){
        setupUser();
        
        System.runAs(user){
          init();
          
          Integer resSuperPremium = EUR_CRM_ProsSegmentationClass.returnSuperPremium(account.Id);
          System.assertEquals(resSuperPremium, 0);
        }
    }
    
    static testMethod void testReturnIdCard(){
        setupUser();
        
        System.runAs(user){
          init();
          
          EUR_CRM_ID_Card__c resIdCard = EUR_CRM_ProsSegmentationClass.returnIdCard(account.Id);
          System.assertEquals(resIdCard, null);
        }
    }
    
    static testMethod void testReturnIdCardMap(){
        setupUser();
        
        System.runAs(user){
          init();
          
          Map<Id, EUR_CRM_ID_Card__c> idCardMap = new Map<Id, EUR_CRM_ID_Card__c>();
          
          idCardMap = EUR_CRM_ProsSegmentationClass.returnIdCardMap(new Set<Id>{account.Id});
          
          System.assertEquals(idCardMap.size(), 0);
        }
    }
    
    static testMethod void testAssignVolumePotential(){
        setupUser();
        
        System.runAs(user){
          init();
          
            //Create Pros Segmentation
            prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id);
            prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutlet;
            prosSegmentation.EUR_CRM_Image_Level__c = imageLevel;
            insert prosSegmentation;
            List<EUR_CRM_Pros_Segmentation__c> prosSegmentations = new List<EUR_CRM_Pros_Segmentation__c>{prosSegmentation};
            
            //Create ID Card
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c( EUR_CRM_Outlet__c = account.Id);
            insert idCard;
            Map<Id, EUR_CRM_ID_Card__c> idCards = new Map<Id, EUR_CRM_ID_Card__c>{prosSegmentation.EUR_CRM_Account__c=>idCard};
            
            EUR_CRM_ProsSegmentationClass.assignVolumePotential(prosSegmentations, idCards);
        }
    }
    
    static testMethod void testAssignVolumePotential2(){
        setupUser();
        
        System.runAs(user){
          init();
          
            //Create Pros Segmentation
            prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id);
            prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutlet;
            prosSegmentation.EUR_CRM_Image_Level__c = imageLevel;
            insert prosSegmentation;
            List<EUR_CRM_Pros_Segmentation__c> prosSegmentations = new List<EUR_CRM_Pros_Segmentation__c>();
            
            //Create ID Card
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c( EUR_CRM_Outlet__c = account.Id);
            insert idCard;
            Map<Id, EUR_CRM_ID_Card__c> idCards = new Map<Id, EUR_CRM_ID_Card__c>{prosSegmentation.EUR_CRM_Account__c=>idCard};
            
            EUR_CRM_ProsSegmentationClass.assignVolumePotential(prosSegmentations, idCards);
        }
    }
    
    
    static testMethod void testAssignVolumePotential3(){
        setupUser();
        
        System.runAs(user){
          init();
          
            //Create Pros Segmentation
            prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id);
            prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutlet;
            prosSegmentation.EUR_CRM_Image_Level__c = imageLevel;
            insert prosSegmentation;
            List<EUR_CRM_Pros_Segmentation__c> prosSegmentations = new List<EUR_CRM_Pros_Segmentation__c>();
            
            //Create ID Card
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c( EUR_CRM_Outlet__c = account.Id);
            insert idCard;
            Map<Id, EUR_CRM_ID_Card__c> idCards = new Map<Id, EUR_CRM_ID_Card__c>();
            
            EUR_CRM_ProsSegmentationClass.assignVolumePotential(prosSegmentations, idCards);
        }
    }
    
    static testMethod void testAssignImageLevel(){
        setupUser();
        
        System.runAs(user){
          init();
          
            //Create Pros Segmentation
            prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id);
            groupOutletType = EUR_CRM_TestClassHelper.createGroupOutlet(groupOutletName, affiliate.Id, null, null);
         
            prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
            //prosSegmentation.EUR_CRM_Image_Level__c = imageLevel;
            insert prosSegmentation;
            List<EUR_CRM_Pros_Segmentation__c> prosSegmentations = new List<EUR_CRM_Pros_Segmentation__c>{prosSegmentation};
            
            //Create ID Card
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c( EUR_CRM_Outlet__c = account.Id);
            insert idCard;
            Map<Id, EUR_CRM_ID_Card__c> idCards = new Map<Id, EUR_CRM_ID_Card__c>{prosSegmentation.EUR_CRM_Account__c=>idCard};
            
            Map<Id, EUR_CRM_Pros_Segmentation__c> prosMap = new Map<Id, EUR_CRM_Pros_Segmentation__c>();
            
            EUR_CRM_ProsSegmentationClass.assignImageLevel(prosMap, idCards);
      }
    }
    
    static testMethod void testAssignImageLevel2(){
        setupUser();
        
        System.runAs(user){
          init();
          
            //Create Pros Segmentation
            prosSegmentation = EUR_CRM_TestClassHelper.createProsSegmentation(account.Id, affiliate.Id);
            prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
            prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
            insert prosSegmentation;
            List<EUR_CRM_Pros_Segmentation__c> prosSegmentations = new List<EUR_CRM_Pros_Segmentation__c>{prosSegmentation};
            
            //Create ID Card
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c( EUR_CRM_Outlet__c = prtAccount.Id);
            insert idCard;
            Map<Id, EUR_CRM_ID_Card__c> idCards = new Map<Id, EUR_CRM_ID_Card__c>();
             idCards.put(idCard.EUR_CRM_Outlet__c, idCard);
            
            Map<Id, EUR_CRM_Pros_Segmentation__c> prosMap = new Map<Id, EUR_CRM_Pros_Segmentation__c>();
            prosMap.put(prtAccount.Id, prosSegmentation);
            
            EUR_CRM_ProsSegmentationClass.assignImageLevel(prosMap, idCards);
        }
    }
    */
    
}