/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_ProsSegmentationExt Class.
  @Author:      IPC
  @History:     APR.28.2014 - Created
*/
@isTest (SeeAllData = false)
private class EUR_CRM_ProsSegmentationExt_Test {
    
//    private static EUR_CRM_Account__c account;
//    private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
//    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold;
//    private static EUR_CRM_Criteria_Set__c criteriaSet;
//    private static EUR_CRM_Criteria_Answer__c criteriaAnswer;
//    private static EUR_CRM_Group_Outlet_Type__c groupOutlet;
//    private static EUR_CRM_Outlet_Type__c outletType;
//    private static EUR_CRM_Image_Level__c imageLevel;
//    private static EUR_CRM_Image_Level_Threshold__c imageLvlThreshold;
//    private static EUR_CRM_Volume_Potential__c volumePotential;
//    private static EUR_CRM_Volume_Potential_Threshold__c volumePotentialThreshold;
//    private static EUR_CRM_Pros_Image_Level__c prosImageLevel;
//    private static EUR_CRM_Pros_Volume_Potential__c prosVolPotential;
//    private static EUR_CRM_Service_Pack__c servicePack;
//        private static EUR_CRM_Affiliate__c affiliate;
//    private static User user;
//
//    public static void dataInsert(){
//
//        account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'LT Direct - On Trade')[0];
//        account.EUR_CRM_Sub_Channel__c = 'Retail';
//        account.EUR_CRM_Channel__c = 'ON TRADE';
//        insert account;
//
//        criteriaSet = EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1, 'LT Image Level Criteria')[0];
//        insert criteriaSet;
//
//        criteriaThreshold = EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1, 'Picklist', criteriaSet.Id)[0];
//        criteriaThreshold.EUR_CRM_Weight__c = 100;
//        insert criteriaThreshold;
//
//        criteriaAnswer = EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1, 'Picklist', criteriaThreshold.Id)[0];
//        criteriaAnswer.EUR_CRM_Value__c = null;
//        criteriaAnswer.EUR_CRM_Weight__c = 90;
//        criteriaAnswer.EUR_CRM_Base_Currency__c = 50;
//        criteriaAnswer.EUR_CRM_Condition__c = 'Less Than or Equal (<=)';
//        insert criteriaAnswer;
//
//        groupOutlet = EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR LT Group Outlet', '', null, null)[0];
//        groupOutlet.EUR_CRM_Group_Outlet_Name__c = 'Nightclub';
//        insert groupOutlet;
//
//        outletType = EUR_CRM_TestClassUtilityHelper.createOutletType(1, 'EUR LT Outlet Type', '', groupOutlet.Id)[0];
//        insert outletType;
//
//        imageLevel = EUR_CRM_TestClassUtilityHelper.createImageLevel(1, 'LT Image Level', '', groupOutlet.Id, 'Nightclub')[0];
//        insert imageLevel;
//
//        imageLvlThreshold = EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1, groupOutlet.Id, imageLevel.Id)[0];
//        imageLvlThreshold.EUR_CRM_Min_Weight__c = 50;
//        insert imageLvlThreshold;
//
//        volumePotential = EUR_CRM_TestClassUtilityHelper.createvolumePotential(1, 'LT Volume Potential', '', groupOutlet.Id, 'Medium')[0];
//        insert volumePotential;
//
//        volumePotentialThreshold = EUR_CRM_TestClassUtilityHelper.createvolumePotentialThreshold(1, groupOutlet.Id, volumePotential.Id)[0];
//        volumePotentialThreshold.EUR_CRM_Min_Weight__c = 50;
//        insert volumePotentialThreshold;
//
//        prosSegmentation = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_EE_PROS_Segmentation', '', account.Id, groupOutlet.Id, null, imageLevel.Id, volumePotential.Id, null)[0];
//        insert prosSegmentation;
//
//        prosImageLevel = EUR_CRM_TestClassUtilityHelper.createProsImageLevel(1, '', prosSegmentation.Id, criteriaThreshold.Id)[0];
//        prosImageLevel.EUR_CRM_Weight__c = 98;
//        insert prosImageLevel;
//
//        prosVolPotential = EUR_CRM_TestClassUtilityHelper.createProsVolumePotential(1, 'EUR_PRT_ProsVolumePotential', '', prosSegmentation.Id, criteriaThreshold.Id)[0];
//        prosVolPotential.EUR_CRM_Weight__c = 98;
//        insert prosVolPotential;
//                     affiliate = EUR_CRM_TestClassHelper.createAffiliate();
//        insert affiliate;
//
//    }
//
//    static testMethod void proSegmentTestAT() {
//        dataInsert();
//     //    user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
//     //   System.runAs(user){
//        //    String companyName = ([select id,name from EUR_CRM_Affiliate__c where id =: affiliate.id]).name;
//        //    user.CompanyName = companyName;
//         //   update user;
//         //           servicePack = EUR_CRM_TestClassUtilityHelper.createServicePack(1, 'EUR_PRT_Service_Pack', 'Restaurant', 'Iconic')[0];
//       // servicePack.EUR_CRM_Outlet_Type__c = 'GroupType';
//       // insert servicePack;
//        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
//        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
//        rf.getParameters().put('id', prosSegmentation.id);
//        Test.setCurrentPage(rf);
//
//        List<EUR_CRM_Pros_Image_Level__c> pImageLvl = new List<EUR_CRM_Pros_Image_Level__c>();
//        pImageLvl.add(prosImageLevel);
//
//        List<EUR_CRM_Pros_Volume_Potential__c> pVolPotential = new List<EUR_CRM_Pros_Volume_Potential__c>();
//        pVolPotential.add(prosVolPotential);
//
//        EUR_CRM_ProsSegmentationExt controller = new EUR_CRM_ProsSegmentationExt(standardController);
//
//        controller.setProsImageLevel(pImageLvl);
//        controller.setProsVolumePotential(pVolPotential);
//        //controller.setServicePackId(servicePack.Id);
//
//        controller.getProsImageLevel();
//        controller.getProsVolumePotential();
//        //controller.getServicePackId();
//
//        controller.initProsSegmentationObj();
//        controller.getIsVolumeCardAvailable();
//        controller.getCustomForm();
//        controller.initSummary();
//        controller.processGroupOutletType();
//        controller.processImageLevel();
//        controller.processVolumePotential();
//        controller.processAccountPlan();
//
//      //  }
//    }
//
//    static testMethod void proSegmentTestLT() {
//         dataInsert();
//      /*   user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
//        System.runAs(user){
//            String companyName = ([select id,name from EUR_CRM_Affiliate__c where id =: affiliate.id]).name;
//            user.CompanyName = companyName;
//            update user;
//                    servicePack = EUR_CRM_TestClassUtilityHelper.createServicePack(1, 'EUR_PRT_Service_Pack', 'Restaurant', 'Iconic')[0];
//        servicePack.EUR_CRM_Outlet_Type__c = 'GroupType';
//        insert servicePack;*/
//        account.eur_crm_force_iconic_account__c = true;
//        update account;
//
//        //LT
//        Id recTypeIdLT = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Pros_Segmentation__c','EUR_LT_PROS_Segmentation');
//
//        prosSegmentation.RecordTypeId = recTypeIdLT;
//        update prosSegmentation;
//        Test.startTest();
//
//        ApexPages.Standardcontroller standardControllerLT = new Apexpages.Standardcontroller(prosSegmentation);
//        PageReference rfLT = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
//        rfLT.getParameters().put('id', prosSegmentation.id);
//        Test.setCurrentPage(rfLT);
//
//        EUR_CRM_ProsSegmentationExt controller = new EUR_CRM_ProsSegmentationExt(standardControllerLT);
//        controller.processGroupOutletType();
//        Test.stopTest();
//        //}
//    }
//
//    static testMethod void proSegmentTestLV() {
//         dataInsert();
//        /* user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
//        System.runAs(user){
//            String companyName = ([select id,name from EUR_CRM_Affiliate__c where id =: affiliate.id]).name;
//            user.CompanyName = companyName;
//            update user;
//                    servicePack = EUR_CRM_TestClassUtilityHelper.createServicePack(1, 'EUR_PRT_Service_Pack', 'Restaurant', 'Iconic')[0];
//        servicePack.EUR_CRM_Outlet_Type__c = 'GroupType';
//        insert servicePack;*/
//        //LV
//        Id recTypeIdLV = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Pros_Segmentation__c','EUR_LV_PROS_Segmentation');
//
//        prosSegmentation.RecordTypeId = recTypeIdLV;
//        update prosSegmentation;
//
//        Test.startTest();
//        ApexPages.Standardcontroller standardControllerLV = new Apexpages.Standardcontroller(prosSegmentation);
//        PageReference rfLV = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
//        rfLV.getParameters().put('id', prosSegmentation.id);
//        Test.setCurrentPage(rfLV);
//
//        EUR_CRM_ProsSegmentationExt controller = new EUR_CRM_ProsSegmentationExt(standardControllerLV);
//        test.stopTest();//}
//    }
//     /*
//    static testMethod void proSegmentTestPRT() {
//        dataInsert();
//        test.startTest();
//        //PRT
//        Id recTypeIdPRT = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Pros_Segmentation__c','EUR_PRT_PROS_Segmentation');
//
//        prosSegmentation.RecordTypeId = recTypeIdPRT;
//        update prosSegmentation;
//
//        ApexPages.Standardcontroller standardControllerPRT = new Apexpages.Standardcontroller(prosSegmentation);
//        PageReference rfPRT = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
//        rfPRT.getParameters().put('id', prosSegmentation.id);
//        Test.setCurrentPage(rfPRT);
//
//        EUR_CRM_ProsSegmentationExt controller = new EUR_CRM_ProsSegmentationExt(standardControllerPRT);
//        test.stopTest();
//    }
//
//    static testMethod void proSegmentTestGB() {
//        dataInsert();
//        test.startTest();
//        //GB
//        Id recTypeIdGB = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Pros_Segmentation__c','EUR_GB_PROS_Segmentation');
//
//        prosSegmentation.RecordTypeId = recTypeIdGB;
//        update prosSegmentation;
//
//        ApexPages.Standardcontroller standardControllerGB = new Apexpages.Standardcontroller(prosSegmentation);
//        PageReference rfGB = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
//        rfGB.getParameters().put('id', prosSegmentation.id);
//        Test.setCurrentPage(rfGB);
//
//        EUR_CRM_ProsSegmentationExt controller = new EUR_CRM_ProsSegmentationExt(standardControllerGB);
//        test.stopTest();
//    }*/
//    /*
//    static testMethod void proSegmentTestCZ() {
//        dataInsert();
//        test.startTest();
//        //CZ
//        Id recTypeIdCZ = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Pros_Segmentation__c','EUR_CZ_PROS_Segmentation');
//
//        prosSegmentation.RecordTypeId = recTypeIdCZ;
//        update prosSegmentation;
//
//        ApexPages.Standardcontroller standardControllerCZ = new Apexpages.Standardcontroller(prosSegmentation);
//        PageReference rfCZ = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
//        rfCZ.getParameters().put('id', prosSegmentation.id);
//        Test.setCurrentPage(rfCZ);
//
//        EUR_CRM_ProsSegmentationExt controller = new EUR_CRM_ProsSegmentationExt(standardControllerCZ);
//        test.stopTest();
//    }*/
//    /*
//    static testMethod void proSegmentTestSK() {
//        dataInsert();
//        test.startTest();
//        //SK
//        Id recTypeIdSK = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Pros_Segmentation__c','EUR_SK_PROS_Segmentation');
//
//        prosSegmentation.RecordTypeId = recTypeIdSK;
//        update prosSegmentation;
//
//        ApexPages.Standardcontroller standardControllerSK = new Apexpages.Standardcontroller(prosSegmentation);
//        PageReference rfSK = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
//        rfSK.getParameters().put('id', prosSegmentation.id);
//        Test.setCurrentPage(rfSK);
//
//        EUR_CRM_ProsSegmentationExt controller = new EUR_CRM_ProsSegmentationExt(standardControllerSK);
//        test.stopTest();
//    }
//    */
//    static testMethod void proSegmentTestEE() {
//         dataInsert();
//        /* user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
//        System.runAs(user){
//            String companyName = ([select id,name from EUR_CRM_Affiliate__c where id =: affiliate.id]).name;
//            user.CompanyName = companyName;
//            update user;
//                    servicePack = EUR_CRM_TestClassUtilityHelper.createServicePack(1, 'EUR_PRT_Service_Pack', 'Restaurant', 'Iconic')[0];
//        servicePack.EUR_CRM_Outlet_Type__c = 'GroupType';
//        insert servicePack;*/
//        test.startTest();
//        //EE
//        Id recTypeIdEE = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Pros_Segmentation__c','EUR_EE_PROS_Segmentation');
//
//        prosSegmentation.RecordTypeId = recTypeIdEE;
//        update prosSegmentation;
//
//        ApexPages.Standardcontroller standardControllerEE = new Apexpages.Standardcontroller(prosSegmentation);
//        PageReference rfEE = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
//        rfEE.getParameters().put('id', prosSegmentation.id);
//        Test.setCurrentPage(rfEE);
//
//        EUR_CRM_ProsSegmentationExt controller = new EUR_CRM_ProsSegmentationExt(standardControllerEE);
//        test.stopTest();
//       // }
//    }
    /*
    static testMethod void proSegmentTestDE() {
        dataInsert();
        test.startTest();
        //DE
        Id recTypeIdDE = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Pros_Segmentation__c','EUR_DE_PROS_Segmentation');
        
        prosSegmentation.RecordTypeId = recTypeIdDE;
        update prosSegmentation;
        
        ApexPages.Standardcontroller standardControllerDE = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rfDE = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rfDE.getParameters().put('id', prosSegmentation.id);
        Test.setCurrentPage(rfDE);
        
        EUR_CRM_ProsSegmentationExt controller = new EUR_CRM_ProsSegmentationExt(standardControllerDE);
        test.stopTest();
    }
    */
    /*
    static testMethod void proSegmentTestLT() {
        test.startTest();
        
        EUR_CRM_Pros_Segmentation__c proSegmentTestLT = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_LT_PROS_Segmentation', 'LT', null, null, null, null, null, null)[0];
        insert proSegmentTestLT;
        
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(proSegmentTestLT);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', proSegmentTestLT.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_ProsSegmentationExt controller = new EUR_CRM_ProsSegmentationExt(standardController);
        
        test.stopTest();
    }
    
    static testMethod void proSegmentTestLV() {
        test.startTest();
        
        EUR_CRM_Pros_Segmentation__c proSegmentTestLV = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_LV_PROS_Segmentation', 'LV', null, null, null, null, null, null)[0];
        insert proSegmentTestLV;
        
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(proSegmentTestLV);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', proSegmentTestLV.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_ProsSegmentationExt controller = new EUR_CRM_ProsSegmentationExt(standardController);
        
        test.stopTest();
    }
    */
    static testMethod void proSegmentTestPRT() {
        test.startTest();
        
        EUR_CRM_Pros_Segmentation__c proSegmentTestPRT = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_PRT_PROS_Segmentation', '', null, null, null, null, null, null)[0];
        insert proSegmentTestPRT;
        
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(proSegmentTestPRT);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', proSegmentTestPRT.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_ProsSegmentationExt controller = new EUR_CRM_ProsSegmentationExt(standardController);
        controller.initProsSegmentationObj();
        controller.getIsVolumeCardAvailable();
        controller.getProsImageLevel();
        controller.getProsVolumePotential();
        controller.getOutletTypeOptions();
//        controller.setServicePackId();
        controller.getCustomForm();
        controller.initSummary();
        controller.initImageVolumeFieldSet();
        controller.returnGroupOutlet();
        controller.processGroupOutletType();
        controller.processImageLevel();
        controller.processVolumePotential();
        controller.processAccountPlan();
        test.stopTest();
    }
    /*
    static testMethod void proSegmentTestGB() {
        test.startTest();
        
        EUR_CRM_Pros_Segmentation__c proSegmentTestGB = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_GB_PROS_Segmentation', 'GB', null, null, null, null, null, null)[0];
        insert proSegmentTestGB;
        
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(proSegmentTestGB);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', proSegmentTestGB.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_ProsSegmentationExt controller = new EUR_CRM_ProsSegmentationExt(standardController);
        
        test.stopTest();
    }
    */
}