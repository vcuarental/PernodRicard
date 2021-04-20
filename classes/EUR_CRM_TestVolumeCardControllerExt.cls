@isTest
public with sharing class EUR_CRM_TestVolumeCardControllerExt { 

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
     public static void init2(){
        //create user
        // user = EUR_CRM_TestClassUtilityHelper.createUser('System Administrator');
        // insert user;
        //create criteria set
        
        countryCode='PRT';
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
            insert affiliate;   
    }
    public static void init()
    {   //user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        countryCode = 'PRT';
        init2();
        prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.EUR_CRM_Service_Pack__c = null;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        insert prosSegmentation;
    }
    static testMethod void testInitVolCard()
    {
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
            PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
            rf.getParameters().put('id', prosSegmentation.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_VolumeCardControllerExt controller = new EUR_CRM_VolumeCardControllerExt(standardController);
            new EUR_CRM_VolumeCardControllerExt();
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c(EUR_CRM_Outlet__c = prtAccount.Id);
            insert idCard;
            controller.mapMarcas = new Map <ID, EUR_CRM_Quality__c>();
            controller.getMapMarcasSize();
            controller.IdCard = idCard;
            controller.initVolCard();
     }
    static testMethod void testSaveP()
    {
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
            PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
            rf.getParameters().put('id', prosSegmentation.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_VolumeCardControllerExt controller = new EUR_CRM_VolumeCardControllerExt(standardController);
            new EUR_CRM_VolumeCardControllerExt();
            //Added By Laputa Hugo Cheung 28/9/2016
            integer count = controller.listVolWrapper.size();
            controller.setAccountId(prtAccount.id);
            controller.getAccountId();
            controller.initVolCard();
            
            //Create ID Card
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c(EUR_CRM_Outlet__c = prtAccount.Id);
            insert idCard;
            controller.IdCard = idCard;
            //Create ID Card Volumes
            List<EUR_CRM_ID_Card_Volume__c> idCardVolumeList = new List<EUR_CRM_ID_Card_Volume__c>();
            for(Integer i=0; i<10; i++){
                EUR_CRM_Category__c cat = new EUR_CRM_Category__c(EUR_CRM_Category_Code__c='Category' + i);
                insert cat;
                
                EUR_CRM_ID_Card_Volume__c IDCardVol = new EUR_CRM_ID_Card_Volume__c(EUR_CRM_ID_Card__c = idCard.id, 
                                                        EUR_CRM_Category__c = cat.Id,
                                                        EUR_CRM_Service_Mark__c = null,
                                                        EUR_CRM_No_Premium_Brands__c=i,
                                                        EUR_CRM_No_SuperPremium_Brands__c=i,
                                                        EUR_CRM_No_UltraPremium_Brands__c=i);  
               idCardVolumeList.add(IDCardVol);
            }
            insert idCardVolumeList;
            
            //Set mapVolWrapper
            Map <String, EUR_CRM_VolumeCardControllerExt.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_VolumeCardControllerExt.volumesWrapper>();
            Integer counter=0;
            for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
                EUR_CRM_VolumeCardControllerExt.volumesWrapper volumeWrapper = new EUR_CRM_VolumeCardControllerExt.volumesWrapper();
                volumeWrapper.vol_IDCardVolumes = volCard;
                volumeWrapper.categoryName = 'Category'+counter;
                volumeWrapper.vol_listMarcas = new List<SelectOption>{new SelectOption('1','1'), new SelectOption('2','2'), new SelectOption('3','3')};
                
                counter++;
                mapVolWrapper.put(volCard.EUR_CRM_Category__c, volumeWrapper);
            }
            
            controller.mapVolWrapper = mapVolWrapper;
            
            /*
            volW = new volumesWrapper();
            IDCardVol = new EUR_CRM_ID_Card_Volume__c(EUR_CRM_ID_Card__c = IdCard.id, 
                                                        EUR_CRM_Category__c = famObj.EUR_CRM_Brand_EUR__r.EUR_CRM_Category__r.Id,
                                                        EUR_CRM_Service_Mark__c = null,
                                                        EUR_CRM_No_Premium_Brands__c=0,
                                                        EUR_CRM_No_SuperPremium_Brands__c=0,
                                                        EUR_CRM_No_UltraPremium_Brands__c=0);        
            volW.vol_IDCardVolumes = IDCardVol;
            volW.categoryName = famObj.EUR_CRM_Brand_EUR__r.EUR_CRM_Category__r.Name;
            volW.vol_listMarcas = mapCategorias.get(famObj.EUR_CRM_Brand_EUR__r.EUR_CRM_Category__r.Id);
            */
            
            controller.saveP();
        //}
    }

    static testMethod void testSaveP2()
    {
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
            PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
            rf.getParameters().put('id', prosSegmentation.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_VolumeCardControllerExt controller = new EUR_CRM_VolumeCardControllerExt(standardController);
            
            controller.initVolCard();
            
            //Create ID Card
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c(EUR_CRM_Outlet__c = prtAccount.Id);
            insert idCard;
            
            //Create ID Card Volumes
            List<EUR_CRM_ID_Card_Volume__c> idCardVolumeList = new List<EUR_CRM_ID_Card_Volume__c>();
            for(Integer i=0; i<1; i++){
                EUR_CRM_Category__c cat = new EUR_CRM_Category__c(EUR_CRM_Category_Code__c='Category' + i);
                insert cat;
                
                EUR_CRM_ID_Card_Volume__c IDCardVol = new EUR_CRM_ID_Card_Volume__c(EUR_CRM_ID_Card__c = idCard.id, 
                                                        EUR_CRM_Category__c = cat.Id,
                                                        EUR_CRM_Service_Mark__c = null,
                                                        EUR_CRM_No_Premium_Brands__c=i,
                                                        EUR_CRM_No_SuperPremium_Brands__c=i,
                                                        EUR_CRM_No_UltraPremium_Brands__c=i);  
               idCardVolumeList.add(IDCardVol);
            }
            insert idCardVolumeList;
            
            //Set mapVolWrapper
            Map <String, EUR_CRM_VolumeCardControllerExt.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_VolumeCardControllerExt.volumesWrapper>();
            Integer counter=0;
            for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
                EUR_CRM_VolumeCardControllerExt.volumesWrapper volumeWrapper = new EUR_CRM_VolumeCardControllerExt.volumesWrapper();
                volumeWrapper.vol_IDCardVolumes = volCard;
                volumeWrapper.categoryName = 'Category'+counter;
                volumeWrapper.vol_listMarcas = new List<SelectOption>{new SelectOption('1','1'), new SelectOption('2','2'), new SelectOption('3','3')};
                
                counter++;
                mapVolWrapper.put(volCard.EUR_CRM_Category__c, volumeWrapper);
            }
            
            controller.mapVolWrapper = mapVolWrapper;

            controller.saveP();
        //}
    }
        
    static testMethod void testGetMarcasPremium()
    {
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
            PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
            rf.getParameters().put('id', prosSegmentation.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_VolumeCardControllerExt controller = new EUR_CRM_VolumeCardControllerExt(standardController);
            
            controller.initVolCard();
            
            //Create ID Card
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c(EUR_CRM_Outlet__c = prtAccount.Id);
            insert idCard;
            EUR_CRM_ID_Card_Volume__c idCardVolume = new EUR_CRM_ID_Card_Volume__c(EUR_CRM_ID_Card__c = idCard.id, EUR_CRM_Annual_Volume__c =100);
            insert idCardVolume;
            //Create ID Card Volumes
            List<EUR_CRM_ID_Card_Volume__c> idCardVolumeList = new List<EUR_CRM_ID_Card_Volume__c>();
            for(Integer i=0; i<10; i++){
                EUR_CRM_Category__c cat = new EUR_CRM_Category__c(EUR_CRM_Category_Code__c='Category' + i);
                insert cat;
                
                EUR_CRM_ID_Card_Volume__c IDCardVol = new EUR_CRM_ID_Card_Volume__c(EUR_CRM_ID_Card__c = idCard.id, 
                                                        EUR_CRM_Category__c = cat.Id,
                                                        EUR_CRM_Service_Mark__c = null,
                                                        EUR_CRM_No_Premium_Brands__c=i,
                                                        EUR_CRM_No_SuperPremium_Brands__c=i,
                                                        EUR_CRM_No_UltraPremium_Brands__c=i);  
               idCardVolumeList.add(IDCardVol);
            }
            insert idCardVolumeList;
            
            //Set mapVolWrapper
            Map <String, EUR_CRM_VolumeCardControllerExt.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_VolumeCardControllerExt.volumesWrapper>();
            Integer counter=0;
            for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
                EUR_CRM_VolumeCardControllerExt.volumesWrapper volumeWrapper = new EUR_CRM_VolumeCardControllerExt.volumesWrapper();
                volumeWrapper.vol_IDCardVolumes = volCard;
                volumeWrapper.categoryName = 'Category'+counter;
                volumeWrapper.vol_listMarcas = new List<SelectOption>{new SelectOption('1','1'), new SelectOption('2','2'), new SelectOption('3','3')};
                
                counter++;
                mapVolWrapper.put(volCard.EUR_CRM_Category__c, volumeWrapper);
            }
            
            controller.mapVolWrapper = mapVolWrapper;
            
            controller.getMarcasPremium();
    }
    
    static testMethod void testGetData()
    {
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            
            
            //Create ID Card
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c(EUR_CRM_Outlet__c = prtAccount.Id);
            insert idCard;
            
            //Create ID Card Volumes
            List<EUR_CRM_ID_Card_Volume__c> idCardVolumeList = new List<EUR_CRM_ID_Card_Volume__c>();
            for(Integer i=0; i<10; i++){
                EUR_CRM_Category__c cat = new EUR_CRM_Category__c(EUR_CRM_Category_Code__c='Category' + i);
                insert cat;
                
                EUR_CRM_ID_Card_Volume__c IDCardVol = new EUR_CRM_ID_Card_Volume__c(EUR_CRM_ID_Card__c = idCard.id, 
                                                        EUR_CRM_Category__c = cat.Id,
                                                        EUR_CRM_Service_Mark__c = null,
                                                        EUR_CRM_No_Premium_Brands__c=i,
                                                        EUR_CRM_No_SuperPremium_Brands__c=i,
                                                        EUR_CRM_No_UltraPremium_Brands__c=i);  
               idCardVolumeList.add(IDCardVol);
            }
            insert idCardVolumeList;
            
            //Set mapVolWrapper
            Map <String, EUR_CRM_VolumeCardControllerExt.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_VolumeCardControllerExt.volumesWrapper>();
            Integer counter=0;
            for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
                EUR_CRM_VolumeCardControllerExt.volumesWrapper volumeWrapper = new EUR_CRM_VolumeCardControllerExt.volumesWrapper();
                volumeWrapper.vol_IDCardVolumes = volCard;
                volumeWrapper.categoryName = 'Category'+counter;
                volumeWrapper.vol_listMarcas = new List<SelectOption>{new SelectOption('1','1'), new SelectOption('2','2'), new SelectOption('3','3')};
                
                counter++;
                mapVolWrapper.put(volCard.EUR_CRM_Category__c, volumeWrapper);
            }
            RecordType crType = [select id from RecordType where SObjectType = 'EUR_CRM_Category__c' and developername = 'EUR_PRT_Categories'];
            EUR_CRM_Category__c cat = new EUR_CRM_Category__c(name='test', recordtypeid = crType.id);
            insert cat;
            RecordType brType = [select id from RecordType where SObjectType = 'EUR_CRM_Brand__c' and developername = 'EUR_PRT_Brand'];
            EUR_CRM_Brand__c br = new EUR_CRM_Brand__c(name='testbrand',EUR_CRM_Category__c = cat.id,recordtypeid = brType.id);
            insert br;
            RecordType qrType = [select id from RecordType where SObjectType = 'EUR_CRM_Quality__c' and developername = 'EUR_PRT_Quality'];
            EUR_CRM_Quality__c qu = new EUR_CRM_Quality__c(Name='qatest',EUR_CRM_Brand__c = br.id,recordtypeid = qrType.id, EUR_CRM_House_Pour__c = true);
            insert qu;
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
            PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
            rf.getParameters().put('Str', qu.Id);
            rf.getParameters().put('id', prosSegmentation.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_VolumeCardControllerExt controller = new EUR_CRM_VolumeCardControllerExt(standardController);
            
            
            controller.initVolCard();
            controller.mapVolWrapper = mapVolWrapper;
            
            controller.getData(idCard);
            controller.cla = 'Ultra Premium';
            controller.saveMarcasPremium();
            controller.saveP();
    }
    
    static testMethod void testGetMapMarcasSize(){
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
            PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
            rf.getParameters().put('id', prosSegmentation.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_VolumeCardControllerExt controller = new EUR_CRM_VolumeCardControllerExt(standardController);
            controller.initVolCard();
            
            Integer size = controller.getMapMarcasSize();
            
            System.assertEquals(size, 0);
    }
    
    static testMethod void testGetMapMarcasSize2()
    {
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
            PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
            rf.getParameters().put('id', prosSegmentation.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_VolumeCardControllerExt controller = new EUR_CRM_VolumeCardControllerExt(standardController);
            
            controller.initVolCard();
            
            //Create ID Card
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c(EUR_CRM_Outlet__c = prtAccount.Id);
            insert idCard;
            
            //Create ID Card Volumes
            List<EUR_CRM_ID_Card_Volume__c> idCardVolumeList = new List<EUR_CRM_ID_Card_Volume__c>();
            for(Integer i=0; i<10; i++){
                EUR_CRM_Category__c cat = new EUR_CRM_Category__c(EUR_CRM_Category_Code__c='Category' + i);
                insert cat;
                
                EUR_CRM_ID_Card_Volume__c IDCardVol = new EUR_CRM_ID_Card_Volume__c(EUR_CRM_ID_Card__c = idCard.id, 
                                                        EUR_CRM_Category__c = cat.Id,
                                                        EUR_CRM_Service_Mark__c = null,
                                                        EUR_CRM_No_Premium_Brands__c=i,
                                                        EUR_CRM_No_SuperPremium_Brands__c=i,
                                                        EUR_CRM_No_UltraPremium_Brands__c=i);  
               idCardVolumeList.add(IDCardVol);
            }
            insert idCardVolumeList;
            
            //Set mapVolWrapper
            Map <String, EUR_CRM_VolumeCardControllerExt.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_VolumeCardControllerExt.volumesWrapper>();
            Integer counter=0;
            for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
                EUR_CRM_VolumeCardControllerExt.volumesWrapper volumeWrapper = new EUR_CRM_VolumeCardControllerExt.volumesWrapper();
                volumeWrapper.vol_IDCardVolumes = volCard;
                volumeWrapper.categoryName = 'Category'+counter;
                volumeWrapper.vol_listMarcas = new List<SelectOption>{new SelectOption('1','1'), new SelectOption('2','2'), new SelectOption('3','3')};
                
                counter++;
                mapVolWrapper.put(volCard.EUR_CRM_Category__c, volumeWrapper);
            }
            
            controller.mapVolWrapper = mapVolWrapper;
            
            Integer size = controller.getMapMarcasSize();

    }
    

    static testMethod void testSaveMarcasPremium(){
        init();
        

        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', prosSegmentation.id);
        //rf.getParameters().put('Str', 'Elyx');
       // rf.getParameters().put('Str', 'Elyx,Chivas,Absolut');
        //Apexpages.currentPage().getParameters().put('Str', 'Elyx');
        Apexpages.currentPage().getParameters().put('Str', '');
        Test.setCurrentPage(rf);
        
        EUR_CRM_VolumeCardControllerExt controller = new EUR_CRM_VolumeCardControllerExt(standardController);
        
        controller.initVolCard();
        
        //Create ID Card
        EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c(EUR_CRM_Outlet__c = prtAccount.Id);
        insert idCard;
        controller.idCard = idCard;
        //Create ID Card Volumes
        List<EUR_CRM_ID_Card_Volume__c> idCardVolumeList = new List<EUR_CRM_ID_Card_Volume__c>();
        for(Integer i=0; i<10; i++){
            EUR_CRM_Category__c cat = new EUR_CRM_Category__c(EUR_CRM_Category_Code__c='Category' + i);
            insert cat;
            
            EUR_CRM_ID_Card_Volume__c IDCardVol = new EUR_CRM_ID_Card_Volume__c(EUR_CRM_ID_Card__c = idCard.id, 
                                                    EUR_CRM_Category__c = cat.Id,
                                                    EUR_CRM_Service_Mark__c = null,
                                                    EUR_CRM_No_Premium_Brands__c=i,
                                                    EUR_CRM_No_SuperPremium_Brands__c=i,
                                                    EUR_CRM_No_UltraPremium_Brands__c=i);  
           idCardVolumeList.add(IDCardVol);
        }
        insert idCardVolumeList;
        
        //Set mapVolWrapper
        Map <String, EUR_CRM_VolumeCardControllerExt.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_VolumeCardControllerExt.volumesWrapper>();
        Integer counter=0;
        for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
            EUR_CRM_VolumeCardControllerExt.volumesWrapper volumeWrapper = new EUR_CRM_VolumeCardControllerExt.volumesWrapper();
            volumeWrapper.vol_IDCardVolumes = volCard;
            volumeWrapper.categoryName = 'Category'+counter;
            volumeWrapper.vol_listMarcas = new List<SelectOption>{new SelectOption('1','1'), new SelectOption('2','2'), new SelectOption('3','3')};
            
            counter++;
            mapVolWrapper.put(volCard.EUR_CRM_Category__c, volumeWrapper);
        }
        
        controller.mapVolWrapper = mapVolWrapper;
        
        controller.saveMarcasPremium();
        controller.cla = 'Super Premium';
        controller.saveMarcasPremium();
    } 
    
    static testMethod void testGetIdCardVolumes()
    {
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
            PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
            rf.getParameters().put('id', prosSegmentation.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_VolumeCardControllerExt controller = new EUR_CRM_VolumeCardControllerExt(standardController);
            
            controller.initVolCard();
            
            //Create ID Card
            EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c(EUR_CRM_Outlet__c = prtAccount.Id);
            insert idCard;
            controller.idCard=idCard;
            //Create ID Card Volumes
            List<EUR_CRM_ID_Card_Volume__c> idCardVolumeList = new List<EUR_CRM_ID_Card_Volume__c>();
            for(Integer i=0; i<10; i++){
                EUR_CRM_Category__c cat = new EUR_CRM_Category__c(EUR_CRM_Category_Code__c='Category' + i);
                insert cat;
                
                EUR_CRM_ID_Card_Volume__c IDCardVol = new EUR_CRM_ID_Card_Volume__c(EUR_CRM_ID_Card__c = idCard.id, 
                                                        EUR_CRM_Category__c = cat.Id,
                                                        EUR_CRM_Service_Mark__c = null,
                                                        EUR_CRM_No_Premium_Brands__c=i,
                                                        EUR_CRM_No_SuperPremium_Brands__c=i,
                                                        EUR_CRM_No_UltraPremium_Brands__c=i);  
               idCardVolumeList.add(IDCardVol);
            }
            insert idCardVolumeList;
            
            //Set mapVolWrapper
            Map <String, EUR_CRM_VolumeCardControllerExt.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_VolumeCardControllerExt.volumesWrapper>();
            Integer counter=0;
            for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
                EUR_CRM_VolumeCardControllerExt.volumesWrapper volumeWrapper = new EUR_CRM_VolumeCardControllerExt.volumesWrapper();
                volumeWrapper.vol_IDCardVolumes = volCard;
                volumeWrapper.categoryName = 'Category'+counter;
                volumeWrapper.vol_listMarcas = new List<SelectOption>{new SelectOption('1','1'), new SelectOption('2','2'), new SelectOption('3','3')};
                
                counter++;
                mapVolWrapper.put(volCard.EUR_CRM_Category__c, volumeWrapper);
            }
            
            controller.mapVolWrapper = mapVolWrapper;
            
            controller.getData(idCard);
            controller.getIdCardVolumes();
    }
    
 
}