/*
@Company:     IP-Converge Data Services, Inc.
@Description: Test Class for EUR_CRM_ProsSegmentationExtCombined Class.
@Author:      IPC
@History:     JUN.10.2015 - Created
*/
@isTest (SeeAllData = false)
private class EUR_CRM_ProsSegmentationExtCombined_Test {
    
    /*private static EUR_CRM_Account__c account;
private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
private static EUR_CRM_Criteria_Threshold__c criteriaThreshold;
private static EUR_CRM_Criteria_Set__c criteriaSet;
private static EUR_CRM_Criteria_Answer__c criteriaAnswer;
private static EUR_CRM_Group_Outlet_Type__c groupOutlet;
private static EUR_CRM_Outlet_Type__c outletType;
private static EUR_CRM_Image_Level__c imageLevel;
private static EUR_CRM_Image_Level_Threshold__c imageLvlThreshold;
private static EUR_CRM_Volume_Potential__c volumePotential;
private static EUR_CRM_Volume_Potential_Threshold__c volumePotentialThreshold;
private static EUR_CRM_Pros_Image_Level__c prosImageLevel;
private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential;
private static EUR_CRM_Service_Pack__c servicePack;
private static EUR_CRM_Affiliate__c affiliate;
private static User user;*/
    
    
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
    
    /*public static void dataInsert(){

account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'LT Direct - On Trade')[0];
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

outletType = EUR_CRM_TestClassUtilityHelper.createOutletType(1, 'EUR LT Outlet Type', '', groupOutlet.Id)[0];
insert outletType;

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

prosSegmentation = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_EE_PROS_Segmentation', '', account.Id, groupOutlet.Id, null, imageLevel.Id, volumePotential.Id, null)[0];
insert prosSegmentation;

prosImageLevel = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, '', prosSegmentation.Id, criteriaThreshold.Id)[0];
prosImageLevel.EUR_CRM_Weight__c = 98;
insert prosImageLevel;

prosVolPotential = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', '', prosSegmentation.Id, criteriaThreshold.Id)[0];
prosVolPotential.EUR_CRM_Weight__c = 98;
insert prosVolPotential;
affiliate = EUR_CRM_TestClassHelper.createAffiliate();
insert affiliate;

}*/
    @testSetUp static void initData(){
        
        EUR_CRM_Account__c account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'LT Direct - On Trade')[0];
        account.EUR_CRM_Sub_Channel__c = 'Retail';
        insert account;
        
        EUR_CRM_Criteria_Set__c criteriaSet = EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1, 'LT Image Level Criteria')[0];
        insert criteriaSet;
        
        EUR_CRM_Criteria_Threshold__c criteriaThreshold = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Picklist', criteriaSet.Id)[0];
        criteriaThreshold.EUR_CRM_Weight__c = 100;
        insert criteriaThreshold;
        
        EUR_CRM_Criteria_Answer__c criteriaAnswer = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Picklist', criteriaThreshold.Id)[0];
        criteriaAnswer.EUR_CRM_Value__c = null;
        criteriaAnswer.EUR_CRM_Weight__c = 90;
        criteriaAnswer.EUR_CRM_Base_Currency__c = 50;
        criteriaAnswer.EUR_CRM_Condition__c = 'Less Than or Equal (<=)';
        insert criteriaAnswer;
        
        EUR_CRM_Group_Outlet_Type__c groupOutlet = EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR LT Group Outlet', '', null, null)[0];
        groupOutlet.EUR_CRM_Group_Outlet_Name__c = 'Nightclub';
        insert groupOutlet;
        
        EUR_CRM_Outlet_Type__c outletType = EUR_CRM_TestClassUtilityHelper.createOutletType(1, 'EUR LT Outlet Type', '', groupOutlet.Id)[0];
        insert outletType;
        
        EUR_CRM_Image_Level__c imageLevel = EUR_CRM_TestClassUtilityHelper.createImageLevel(1, 'LT Image Level', '', groupOutlet.Id, 'Nightclub')[0];
        insert imageLevel;
        
        EUR_CRM_Image_Level_Threshold__c imageLvlThreshold = EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1, groupOutlet.Id, imageLevel.Id)[0];
        imageLvlThreshold.EUR_CRM_Min_Weight__c = 50;
        insert imageLvlThreshold;
        
        EUR_CRM_Volume_Potential__c volumePotential = EUR_CRM_TestClassUtilityHelper.createvolumePotential(1, 'LT Volume Potential', '', groupOutlet.Id, 'Medium')[0];
        insert volumePotential;
        
        EUR_CRM_Volume_Potential_Threshold__c volumePotentialThreshold = EUR_CRM_TestClassUtilityHelper.createvolumePotentialThreshold(1, groupOutlet.Id, volumePotential.Id)[0];
        volumePotentialThreshold.EUR_CRM_Min_Weight__c = 50;
        insert volumePotentialThreshold;
        
        EUR_CRM_Pros_Segmentation__c prosSegmentation = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_EE_PROS_Segmentation', '', account.Id, groupOutlet.Id, null, imageLevel.Id, volumePotential.Id, null)[0];
        insert prosSegmentation;
        
        EUR_CRM_Pros_Image_Level__c prosImageLevel = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, '', prosSegmentation.Id, criteriaThreshold.Id)[0];
        prosImageLevel.EUR_CRM_Weight__c = 98;
        insert prosImageLevel;
        
        EUR_CRM_Pros_Volume_Potential__c prosVolPotential = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', '', prosSegmentation.Id, criteriaThreshold.Id)[0];
        prosVolPotential.EUR_CRM_Weight__c = 98;
        insert prosVolPotential;
        
        EUR_CRM_Wine_Spirits__c wineSpirits = EUR_CRM_TestClassUtilityHelper.createWineSpirits(1,'EUR DE Wine/Spirits', 'TEST-0001', 'SPIRITS')[0];
        insert wineSpirits;
        
        EUR_CRM_Category__c category = EUR_CRM_TestClassUtilityHelper.createCategory(1, 'EUR DE Category', 'TEST-0001', wineSpirits.Id)[0];
        insert category;

        EUR_CRM_Brand__c  brand = EUR_CRM_TestClassUtilityHelper.createBrand(1, 'EUR_DE_Brand', 'VODKA', 'TEST-0001', category.Id)[0];
        insert brand;
        
        EUR_CRM_Quality__c  brandQuality = EUR_CRM_TestClassUtilityHelper.createBrandQuality(1, 'EUR_DE_Quality', 'Cocktail', 'TEST-0001', brand.Id)[0];
        insert brandQuality;
        
        //EUR_CRM_Affiliate__c affiliate = EUR_CRM_TestClassHelper.createAffiliate();
        //insert affiliate;
        
    }
    
    static testMethod void proSegmentTestAT() {
        //dataInsert();
        //    user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //   System.runAs(user){
        //    String companyName = ([select id,name from EUR_CRM_Affiliate__c where id =: affiliate.id]).name;
        //    user.CompanyName = companyName;
        //   update user;
        //           servicePack = EUR_CRM_TestClassUtilityHelper.createServicePack(1, 'EUR_PRT_Service_Pack', 'Restaurant', 'Iconic')[0];
        // servicePack.EUR_CRM_Outlet_Type__c = 'GroupType';
        // insert servicePack;
        EUR_CRM_Pros_Segmentation__c prosSegmentation2 = [select id,RecordTypeId,EUR_CRM_Account__c,EUR_CRM_Standard_Account__c,EUR_CRM_Group_Outlet_Type__c,EUR_CRM_Image_Level__c,EUR_CRM_Outlet_Type__c,EUR_CRM_Volume_Potential__c from EUR_CRM_Pros_Segmentation__c where recordType.developerName ='EUR_EE_PROS_Segmentation' limit 1];
        EUR_CRM_Pros_Image_Level__c prosImageLevel2 = [select id from EUR_CRM_Pros_Image_Level__c where EUR_CRM_Weight__c = 98 limit 1];
        EUR_CRM_Pros_Volume_Potential__c prosVolPotential2 = [select id from EUR_CRM_Pros_Volume_Potential__c where EUR_CRM_Weight__c = 98 limit 1];
        
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation2);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', prosSegmentation2.id);
        Test.setCurrentPage(rf);
        
        List<EUR_CRM_Pros_Image_Level__c> pImageLvl = new List<EUR_CRM_Pros_Image_Level__c>();
        pImageLvl.add(prosImageLevel2); 
        
        List<EUR_CRM_Pros_Volume_Potential__c> pVolPotential = new List<EUR_CRM_Pros_Volume_Potential__c>();
        pVolPotential.add(prosVolPotential2); 
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardController);
        
        controller.setProsImageLevel(pImageLvl);
        controller.setProsVolumePotential(pVolPotential);
        //controller.setServicePackId(servicePack.Id);
        
        controller.getProsImageLevel();
        controller.getProsVolumePotential();
        //controller.getServicePackId();
        
        controller.initProsSegmentationObj();
        controller.getIsVolumeCardAvailable();
        controller.getCustomForm();
        controller.initSummary();
        controller.processGroupOutletType();
        controller.processImageLevel();
        controller.processVolumePotential();
        controller.processAccountPlan();
        controller.getOutletTypeOptions();
        controller.initImageVolumeFieldSet();
        
        //  }
    }
    
    static testMethod void proSegmentTestLT() {
        //dataInsert();
        EUR_CRM_Pros_Segmentation__c prosSegmentation2 = [select id,RecordTypeId,
                                                          EUR_CRM_Account__c,EUR_CRM_Standard_Account__c,
                                                          EUR_CRM_Group_Outlet_Type__c,EUR_CRM_Image_Level__c,
                                                          EUR_CRM_Outlet_Type__c,EUR_CRM_Volume_Potential__c from EUR_CRM_Pros_Segmentation__c where recordType.developerName ='EUR_EE_PROS_Segmentation' limit 1];
        EUR_CRM_Account__c account2 = [select Id, eur_crm_force_iconic_account__c from EUR_CRM_Account__c where Name ='TestAccount' limit 1];
        
        account2.eur_crm_force_iconic_account__c = true;
        update account2;
        
        //LT
        Id recTypeIdLT = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Pros_Segmentation__c','EUR_LT_PROS_Segmentation');
        
        prosSegmentation2.RecordTypeId = recTypeIdLT;
        update prosSegmentation2;
        Test.startTest();
        
        ApexPages.Standardcontroller standardControllerLT = new Apexpages.Standardcontroller(prosSegmentation2);
        PageReference rfLT = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rfLT.getParameters().put('id', prosSegmentation2.id);
        Test.setCurrentPage(rfLT);
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardControllerLT);
        controller.processGroupOutletType();
        Test.stopTest();
        //}
    }
    
    
    static testMethod void proSegmentTestLV() {
        //dataInsert();
        // user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
        //String companyName = ([select id,name from EUR_CRM_Affiliate__c where id =: affiliate.id]).name;
        //user.CompanyName = companyName;
        //update user;
        //servicePack = EUR_CRM_TestClassUtilityHelper.createServicePack(1, 'EUR_PRT_Service_Pack', 'Restaurant', 'Iconic')[0];
        //servicePack.EUR_CRM_Outlet_Type__c = 'GroupType';
        //insert servicePack; 
        //LV
                EUR_CRM_Pros_Segmentation__c prosSegmentation2 = [select id,RecordTypeId,
                                                          EUR_CRM_Account__c,EUR_CRM_Standard_Account__c,
                                                          EUR_CRM_Group_Outlet_Type__c,EUR_CRM_Image_Level__c,
                                                          EUR_CRM_Outlet_Type__c,EUR_CRM_Volume_Potential__c from EUR_CRM_Pros_Segmentation__c where recordType.developerName ='EUR_EE_PROS_Segmentation' limit 1];
        Id recTypeIdLV = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Pros_Segmentation__c','EUR_LV_PROS_Segmentation');
        
        prosSegmentation2.RecordTypeId = recTypeIdLV;
        update prosSegmentation2;
        
        Test.startTest();
        ApexPages.Standardcontroller standardControllerLV = new Apexpages.Standardcontroller(prosSegmentation2);
        PageReference rfLV = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rfLV.getParameters().put('id', prosSegmentation2.id);
        Test.setCurrentPage(rfLV);
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardControllerLV);
        test.stopTest();
        //}
    }
    
    static testMethod void proSegmentTestEE() {
        //dataInsert();
        //user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
        //String companyName = ([select id,name from EUR_CRM_Affiliate__c where id =: affiliate.id]).name;
        //user.CompanyName = companyName;
        //update user;
        //servicePack = EUR_CRM_TestClassUtilityHelper.createServicePack(1, 'EUR_PRT_Service_Pack', 'Restaurant', 'Iconic')[0];
        //servicePack.EUR_CRM_Outlet_Type__c = 'GroupType';
        //insert servicePack;
        test.startTest();
        //EE
                EUR_CRM_Pros_Segmentation__c prosSegmentation2 = [select id,RecordTypeId,
                                                          EUR_CRM_Account__c,EUR_CRM_Standard_Account__c,
                                                          EUR_CRM_Group_Outlet_Type__c,EUR_CRM_Image_Level__c,
                                                          EUR_CRM_Outlet_Type__c,EUR_CRM_Volume_Potential__c from EUR_CRM_Pros_Segmentation__c where recordType.developerName ='EUR_EE_PROS_Segmentation' limit 1];        Id recTypeIdEE = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Pros_Segmentation__c','EUR_EE_PROS_Segmentation');
        
        prosSegmentation2.RecordTypeId = recTypeIdEE;
        update prosSegmentation2;
        
        ApexPages.Standardcontroller standardControllerEE = new Apexpages.Standardcontroller(prosSegmentation2);
        PageReference rfEE = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rfEE.getParameters().put('id', prosSegmentation2.id);
        Test.setCurrentPage(rfEE);
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardControllerEE);
        test.stopTest();
        // }
    }
    
    static testMethod void proSegmentTestPRT() {
        test.startTest();
        
        prtAccount = (EUR_CRM_TestClassUtilityHelper.createAccounts(1, 'On Trade (EUR-PRT)')).get(0);
        insert prtAccount;
        
        EUR_CRM_Pros_Segmentation__c proSegmentTestPRT = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', '', null, null, null, null, null, prtAccount.Id)[0];
        insert proSegmentTestPRT;
        
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(proSegmentTestPRT);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', proSegmentTestPRT.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardController);
        
        test.stopTest();
    }
    
    
    
    public static void init(){
        //create user
        // user = EUR_CRM_TestClassUtilityHelper.createUser('System Administrator');
        // insert user;
        //create criteria set
        //
        
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
            //prosSegmentation = [select id from EUR_CRM_Pros_Segmentation__c where EUR_CRM_Account__c =: euAccount.id];
            
            
        }
        //affiliate = EUR_CRM_TestClassHelper.createAffiliate();
        //insert affiliate;   
        
        //EUR_CRM_Pros_Segmentation__c prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        //prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        //prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
        //prosSegmentation.EUR_CRM_Service_Pack__c = null;
        //prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        //insert prosSegmentation;
    }
    
    
    //public static void init()
    //{   //user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
    //    countryCode = 'PRT';
    //   init2();
    //   prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
    //  prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
    //  prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
    // prosSegmentation.EUR_CRM_Service_Pack__c = null;
    // prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
    // insert prosSegmentation;
    //}
    static testMethod void testInitVolCard()
    {
        init();
        
        EUR_CRM_Pros_Segmentation__c prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.EUR_CRM_Service_Pack__c = null;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        insert prosSegmentation;
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', prosSegmentation.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardController);
        //new EUR_CRM_ProsSegmentationExtCombined();
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
        
         EUR_CRM_Pros_Segmentation__c prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.EUR_CRM_Service_Pack__c = null;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        insert prosSegmentation;
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', prosSegmentation.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardController);
        //new EUR_CRM_ProsSegmentationExtCombined();
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
        Map <String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper>();
        Integer counter=0;
        for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
            EUR_CRM_ProsSegmentationExtCombined.volumesWrapper volumeWrapper = new EUR_CRM_ProsSegmentationExtCombined.volumesWrapper();
            volumeWrapper.vol_IDCardVolumes = volCard;
            volumeWrapper.categoryName = 'Category'+counter;
            volumeWrapper.vol_listMarcas = new List<SelectOption>{new SelectOption('1','1'), new SelectOption('2','2'), new SelectOption('3','3')};
                
                counter++;
            mapVolWrapper.put(volCard.EUR_CRM_Category__c, volumeWrapper);
        }
        
        controller.mapVolWrapper = mapVolWrapper;
        
        controller.saveP();
    }
    
    static testMethod void testSaveP2()
    {
        init();
        
         EUR_CRM_Pros_Segmentation__c prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.EUR_CRM_Service_Pack__c = null;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        insert prosSegmentation;
        
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', prosSegmentation.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardController);
        
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
        Map <String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper>();
        Integer counter=0;
        for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
            EUR_CRM_ProsSegmentationExtCombined.volumesWrapper volumeWrapper = new EUR_CRM_ProsSegmentationExtCombined.volumesWrapper();
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
        
         EUR_CRM_Pros_Segmentation__c prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.EUR_CRM_Service_Pack__c = null;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        insert prosSegmentation;
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', prosSegmentation.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardController);
        
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
        Map <String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper>();
        Integer counter=0;
        for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
            EUR_CRM_ProsSegmentationExtCombined.volumesWrapper volumeWrapper = new EUR_CRM_ProsSegmentationExtCombined.volumesWrapper();
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
        
         EUR_CRM_Pros_Segmentation__c prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.EUR_CRM_Service_Pack__c = null;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        insert prosSegmentation;
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', prosSegmentation.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardController);
        
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
        Map <String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper>();
        Integer counter=0;
        for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
            EUR_CRM_ProsSegmentationExtCombined.volumesWrapper volumeWrapper = new EUR_CRM_ProsSegmentationExtCombined.volumesWrapper();
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
        EUR_CRM_Quality__c qu = new EUR_CRM_Quality__c(Name='qatest',EUR_CRM_Brand__c = br.id,recordtypeid = qrType.id);
        insert qu;
        controller.mapVolWrapper = mapVolWrapper;
        
        controller.getData(idCard);
    }
    
    static testMethod void testGetMapMarcasSize(){
        init();
        
         EUR_CRM_Pros_Segmentation__c prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.EUR_CRM_Service_Pack__c = null;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        insert prosSegmentation;
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', prosSegmentation.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardController);
        controller.initVolCard();
        
        Integer size = controller.getMapMarcasSize();
        
        System.assertEquals(size, 0);
    }
    
    static testMethod void testGetMapMarcasSize2()
    {
        init();
        
         EUR_CRM_Pros_Segmentation__c prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.EUR_CRM_Service_Pack__c = null;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        insert prosSegmentation;
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        EUR_CRM_Category__c catId = [SELECT Id FROM EUR_CRM_Category__c Limit 1];
        rf.getParameters().put('id', prosSegmentation.id);
        rf.getParameters().put('Classificacao',  'Premium');
        rf.getParameters().put('CategoriaId', String.valueOf(catId.Id));
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardController);
        
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
        Map <String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper>();
        Integer counter=0;
        for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
            EUR_CRM_ProsSegmentationExtCombined.volumesWrapper volumeWrapper = new EUR_CRM_ProsSegmentationExtCombined.volumesWrapper();
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
        
         EUR_CRM_Pros_Segmentation__c prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.EUR_CRM_Service_Pack__c = null;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        insert prosSegmentation;
        
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        EUR_CRM_Quality__c bq = [SELECT Id FROM EUR_CRM_Quality__c Limit 1];
        rf.getParameters().put('id', prosSegmentation.id);
        rf.getParameters().put('Str',  String.ValueOf(bq.Id));
        rf.getParameters().put('Str2', String.ValueOf(bq.Id));
        // rf.getParameters().put('Str', 'Elyx,Chivas,Absolut');
        Apexpages.currentPage().getParameters().put('Str', String.ValueOf(bq.Id));
        Test.setCurrentPage(rf);
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardController);
        // Trigger Exception Handling
        controller.saveMarcasPremium();
        
        controller.cla='Premium';
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
        Map <String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper>();
        Integer counter=0;
        for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
            EUR_CRM_ProsSegmentationExtCombined.volumesWrapper volumeWrapper = new EUR_CRM_ProsSegmentationExtCombined.volumesWrapper();
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
        controller.cla = 'Ultra Premium';  
        controller.saveMarcasPremium();
        
        controller.saveP();
        
    } 
    
    static testMethod void testGetIdCardVolumes()
    {
        init();
        
         EUR_CRM_Pros_Segmentation__c prosSegmentation = (EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', 'EUR', (id)null, (id)null,(id)null,(id)null,(id)null, prtAccount.id)).get(0);
        prosSegmentation.EUR_CRM_Group_Outlet_Type__c = groupOutletType.id;
        prosSegmentation.EUR_CRM_Image_Level__c = iconicImageLevel.id;
        prosSegmentation.EUR_CRM_Service_Pack__c = null;
        prosSegmentation.EUR_CRM_Standard_Account__c = prtAccount.id;
        insert prosSegmentation;
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', prosSegmentation.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_ProsSegmentationExtCombined controller = new EUR_CRM_ProsSegmentationExtCombined(standardController);
        
        controller.initVolCard();
        controller.selectedOutlet = 'Restaurant';
        controller.displayOutletType = true;
        controller.listTabs = new List<String>();
        controller.mapMarcasSize = 1;
        controller.tab = 'tab';
        
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
        // Set productRapper
        EUR_CRM_ProsSegmentationExtCombined.ProductWrapper pWrapper = new EUR_CRM_ProsSegmentationExtCombined.ProductWrapper(false, null);
        
        //Set mapVolWrapper
        Map <String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper> mapVolWrapper = new Map<String, EUR_CRM_ProsSegmentationExtCombined.volumesWrapper>();
        Integer counter=0;
        for (EUR_CRM_ID_Card_Volume__c volCard: idCardVolumeList){
            EUR_CRM_ProsSegmentationExtCombined.volumesWrapper volumeWrapper = new EUR_CRM_ProsSegmentationExtCombined.volumesWrapper();
            volumeWrapper.vol_IDCardVolumes = volCard;
            volumeWrapper.categoryName = 'Category'+counter;
            volumeWrapper.vol_listMarcas = new List<SelectOption>{new SelectOption('1','1'), new SelectOption('2','2'), new SelectOption('3','3')};
                volumeWrapper.vol_IDCardVolume = volCard.Id;
            volumeWrapper.vol_Categoria = 'VolCategory';
            volumeWrapper.vol_volumesAnuais = 100;
            volumeWrapper.vol_doseServico = 10;
            volumeWrapper.vol_marcaServico = 'premium';
            Integer vol_nuPrem = volumeWrapper.vol_nuPrem;
            Integer vol_nuSuperPrem = volumeWrapper.vol_nuSuperPrem;
            Integer vol_nuUltraPrem = volumeWrapper.vol_nuUltraPrem;
            volumeWrapper.bqName = 'Absolut';
            volumeWrapper.isCompetitor = false;
            volumeWrapper.categoryContributiveMargin = 1.0;
            counter++;
            mapVolWrapper.put(volCard.EUR_CRM_Category__c, volumeWrapper);
        }
        
        controller.mapVolWrapper = mapVolWrapper;
        List<EUR_CRM_ProsSegmentationExtCombined.volumesWrapper> wrappers = controller.listVolWrapper;
        controller.getData(idCard);
        controller.getIdCardVolumes();
    }
}