@isTest
public class ASI_CRM_VN_ProsSegButtonControllerTest{       
    @testSetup
    public static void setupTestData(){
        // DC - 05/02/2016 - Created Running Number Data
        ASI_HK_CRM_Running_Number__c testRunningNumber = ASI_CRM_VN_TestDataFactory.getRunningNumber(
            system.Label.ASI_CRM_VN_Customer_Code,
            1,
            'VN-{YYYY}',
            date.today().month() + 2,
            Date.today().year()
        );
        insert testRunningNumber;    
    }
    public static testMethod void saveTest1(){ 
        ASI_CRM_VN_ProsSegButtonControllerTest objTest = new ASI_CRM_VN_ProsSegButtonControllerTest();        
        
        //Create Test Account record
        /*Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;*/
        
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);        
        insert outletTypeList;
        
        //Create test Customer
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = objTest.createCustomer(1);
        ASI_CRM_AccountsAdditionalField__c customer = listCustomer[0];
        //customer.ASI_CRM_Account__c = testAccount.Id;
        customer.Name = 'test';
        customer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;  
        customer.ASI_TH_CRM_Contracted_With__c = 'PRVN';
        insert customer;
        
        //Create Group Outlet Type
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = objTest.createGroupOutlet(1);
        ASI_CRM_Group_Outlet_Type__c objGroupOutlet = listGroupOutlet[0];
        insert objGroupOutlet;        
        
        //Create Volume Potential Record
        ASI_CRM_Volume_Potential__c objVolume1 = new ASI_CRM_Volume_Potential__c();
        objVolume1.ASI_CRM_SG_External_ID__c = '1234';
        insert objVolume1;
        
        //Create Volume Potential Threshold records
        List<ASI_CRM_Volume_Potential_Threshold__c> volThresholdList = objTest.createVlmPtlThrshold(1);        
        ASI_CRM_Volume_Potential_Threshold__c objVolThreshold = volThresholdList[0];
        objVolThreshold.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        objVolThreshold.ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        objVolThreshold.ASI_CRM_Category__c = 'Spirit & Champagne';
        objVolThreshold.ASI_CRM_Volume__c = 5;
        insert objVolThreshold;        
        
        //Create Image Level Record
        ASI_CRM_Image_Level__c objImageLevel = new ASI_CRM_Image_Level__c();
        objImageLevel.ASI_CRM_SG_External_ID__c = '5678';
        objImageLevel.ASI_CRM_SG_Name__c = 'test';
        insert objImageLevel;
        
        //Create Image Potential Threshold records
        List<ASI_CRM_Image_Level_Threshold__c> imgLevelList = objTest.createImgLevelThrshold(1);
        ASI_CRM_Image_Level_Threshold__c objImageLevelTh = imgLevelList[0];
        objImageLevelTh.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        objImageLevelTh.ASI_CRM_SG_Image_Level__c = objImageLevel.Id;        
        insert objImageLevelTh;
        
        //Create DAMD Threshold records        
        List<ASI_CRM_DAMD_Threshold__c> damdThresholdList = objTest.createDamd(1);
        ASI_CRM_DAMD_Threshold__c damdThreshold = damdThresholdList[0];
        damdThreshold.ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        damdThreshold.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        damdThreshold.ASI_CRM_Contract_Status__c = 'PRVN';  
        damdThreshold.ASI_CRM_Image_Level__c = objImageLevel.Id;
        insert damdThreshold;        
        
        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = objTest.createProsSegmentList(1);        
        listProsSeg[0].ASI_CRM_SG_Customer__c = customer.Id;
        listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential_Threshold__c = objVolThreshold.Id;
        listProsSeg[0].ASI_CRM_SG_Image_Level_Threshold__c = objImageLevelTh.Id;
        listProsSeg[0].ASI_CRM_Spirit_Champagne_Volume__c = 5;        
        insert listProsSeg;        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listProsSeg[0]);
        test.startTest();
            ASI_CRM_VN_ProsSegButtonController psButtonController = new ASI_CRM_VN_ProsSegButtonController(sc);
            PageReference saveRef = psButtonController.save();
            System.assertNotEquals(Null, saveRef);        
        test.stopTest();
    }         
    
    public static testMethod void saveTest2(){ 
        ASI_CRM_VN_ProsSegButtonControllerTest objTest = new ASI_CRM_VN_ProsSegButtonControllerTest();        
        
        //Create Test Account record
        /*Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;*/
        
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);        
        insert outletTypeList;
        
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = objTest.createCustomer(1);
        ASI_CRM_AccountsAdditionalField__c customer = listCustomer[0];
        //customer.ASI_CRM_Account__c = testAccount.Id;
        customer.Name = 'test';
        customer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;
        customer.ASI_CRM_VN_OutletType__c = 'test';
        customer.ASI_TH_CRM_Contracted_With__c = 'test';
        insert customer;
        
        //Create Group Outlet Type
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = objTest.createGroupOutlet(1);
        ASI_CRM_Group_Outlet_Type__c objGroupOutlet = listGroupOutlet[0];
        insert objGroupOutlet;        
        
        //Create Volume Potential Record
        ASI_CRM_Volume_Potential__c objVolume1 = new ASI_CRM_Volume_Potential__c();
        objVolume1.ASI_CRM_SG_External_ID__c = '1234';
        insert objVolume1;
        
        //Create Volume Potential Threshold records
        List<ASI_CRM_Volume_Potential_Threshold__c> volThresholdList = objTest.createVlmPtlThrshold(1);        
        ASI_CRM_Volume_Potential_Threshold__c objVolThreshold = volThresholdList[0];
        objVolThreshold.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        objVolThreshold.ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        objVolThreshold.ASI_CRM_Category__c = 'Wine';
        objVolThreshold.ASI_CRM_Volume__c = 5;
        insert objVolThreshold;
        
        //Create Image Level Record
        ASI_CRM_Image_Level__c objImageLevel = new ASI_CRM_Image_Level__c();
        objImageLevel.ASI_CRM_SG_External_ID__c = '5678';
        objImageLevel.ASI_CRM_SG_Name__c = 'test';
        insert objImageLevel;
        
        //Create Image Potential Threshold records
        List<ASI_CRM_Image_Level_Threshold__c> imgLevelList = objTest.createImgLevelThrshold(1);
        ASI_CRM_Image_Level_Threshold__c objImageLevelTh = imgLevelList[0];
        objImageLevelTh.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        objImageLevelTh.ASI_CRM_SG_Image_Level__c = objImageLevel.Id;       
        insert objImageLevelTh;
        
        //Create test data for Service Pack
        ASI_CRM_ServicePack__c testServicePack = new ASI_CRM_ServicePack__c();
        testServicePack.ASI_CRM_SG_Outlet_Type__c = 'test';
        //testServicePack.ASI_CRM_SG_Sub_Outlet_Type__c = 'test';
        testServicePack.ASI_CRM_SG_Segmentation__c = 'test';
        testServicePack.ASI_CRM_SG_DAMD_Action__c = 'Drop';
        insert testServicePack;
        
        //Create DAMD Threshold records        
        List<ASI_CRM_DAMD_Threshold__c> damdThresholdList = objTest.createDamd(1);
        ASI_CRM_DAMD_Threshold__c damdThreshold = damdThresholdList[0];
        damdThreshold.ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        damdThreshold.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        damdThreshold.ASI_CRM_Contract_Status__c = '';  
        damdThreshold.ASI_CRM_Image_Level__c = objImageLevel.Id;
        insert damdThreshold;       
        
        //Create test data for Pros Segmentation
        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = objTest.createProsSegmentList(1);        
        listProsSeg[0].ASI_CRM_SG_Customer__c = customer.Id;
        listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential_Threshold__c = objVolThreshold.Id;
        listProsSeg[0].ASI_CRM_SG_Image_Level_Threshold__c = objImageLevelTh.Id;
        listProsSeg[0].ASI_CRM_Wine_Volume__c = 5;        
        insert listProsSeg;        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listProsSeg[0]);
        test.startTest();
            ASI_CRM_VN_ProsSegButtonController psButtonController = new ASI_CRM_VN_ProsSegButtonController(sc);
            PageReference saveRef = psButtonController.save();            
            System.assertEquals('High', psButtonController.maxThreshold('High', 'High'));
            System.assertEquals('Medium', psButtonController.maxThreshold('Medium', 'Medium'));
            System.assertEquals('Low', psButtonController.maxThreshold('Test', 'Test'));        
            System.assertNotEquals(Null, saveRef);        
        test.stopTest();
    }    
    
    public static testMethod void saveTest3(){ 
        ASI_CRM_VN_ProsSegButtonControllerTest objTest = new ASI_CRM_VN_ProsSegButtonControllerTest();        
        
        //Create Test Account record
        /*Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;*/
        
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);        
        insert outletTypeList;
        
        //Create test Customer
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = objTest.createCustomer(1);
        ASI_CRM_AccountsAdditionalField__c customer = listCustomer[0];
        //customer.ASI_CRM_Account__c = testAccount.Id;
        customer.Name = 'test';
        customer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;  
        customer.ASI_TH_CRM_Contracted_With__c = 'PRVN';
        customer.ASI_CRM_VN_OutletType__c = 'RES';
        insert customer;
        
        //Create Group Outlet Type
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = objTest.createGroupOutlet(1);
        ASI_CRM_Group_Outlet_Type__c objGroupOutlet = listGroupOutlet[0];
        insert objGroupOutlet;        
        
        //Create Volume Potential Record
        ASI_CRM_Volume_Potential__c objVolume1 = new ASI_CRM_Volume_Potential__c();
        objVolume1.ASI_CRM_SG_External_ID__c = '1234';
        insert objVolume1;
        
        //Create Volume Potential Threshold records
        List<ASI_CRM_Volume_Potential_Threshold__c> volThresholdList = objTest.createVlmPtlThrshold(1);        
        ASI_CRM_Volume_Potential_Threshold__c objVolThreshold = volThresholdList[0];
        objVolThreshold.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        objVolThreshold.ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        objVolThreshold.ASI_CRM_Category__c = 'Spirit & Champagne';
        objVolThreshold.ASI_CRM_Volume__c = 5;
        insert objVolThreshold;        
        
        //Create Image Level Record
        ASI_CRM_Image_Level__c objImageLevel = new ASI_CRM_Image_Level__c();
        objImageLevel.ASI_CRM_SG_External_ID__c = '5678';
        objImageLevel.ASI_CRM_SG_Name__c = 'test';
        insert objImageLevel;
        
        //Create Image Potential Threshold records
        List<ASI_CRM_Image_Level_Threshold__c> imgLevelList = objTest.createImgLevelThrshold(1);
        ASI_CRM_Image_Level_Threshold__c objImageLevelTh = imgLevelList[0];
        objImageLevelTh.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        objImageLevelTh.ASI_CRM_SG_Image_Level__c = objImageLevel.Id;        
        insert objImageLevelTh;
        
        //Create DAMD Threshold records        
        List<ASI_CRM_DAMD_Threshold__c> damdThresholdList = objTest.createDamd(1);
        ASI_CRM_DAMD_Threshold__c damdThreshold = damdThresholdList[0];
        damdThreshold.ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        damdThreshold.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        damdThreshold.ASI_CRM_Contract_Status__c = 'PRVN';  
        damdThreshold.ASI_CRM_Image_Level__c = objImageLevel.Id;
        insert damdThreshold;        
        
        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = objTest.createProsSegmentList(1);        
        listProsSeg[0].ASI_CRM_SG_Customer__c = customer.Id;
        listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential_Threshold__c = objVolThreshold.Id;
        listProsSeg[0].ASI_CRM_SG_Image_Level_Threshold__c = objImageLevelTh.Id;
        listProsSeg[0].ASI_CRM_Spirit_Champagne_Volume__c = 5;        
        insert listProsSeg;        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listProsSeg[0]);
        test.startTest();
            ASI_CRM_VN_ProsSegButtonController psButtonController = new ASI_CRM_VN_ProsSegButtonController(sc);
            PageReference saveRef = psButtonController.save();
            System.assertNotEquals(Null, saveRef);        
        test.stopTest();
    }    
    
    public static testMethod void saveTest4(){  
        ASI_CRM_VN_ProsSegButtonControllerTest objTest = new ASI_CRM_VN_ProsSegButtonControllerTest();        
        
        //Create Test Account record
        /*Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;*/
        
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);        
        insert outletTypeList;
        
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = objTest.createCustomer(1);
        ASI_CRM_AccountsAdditionalField__c customer = listCustomer[0];
        //customer.ASI_CRM_Account__c = testAccount.Id;
        customer.Name = 'test';
        customer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;
        customer.ASI_CRM_VN_OutletType__c = 'test';
        customer.ASI_TH_CRM_Contracted_With__c = 'test';
        customer.ASI_CRM_VN_OutletType__c = 'RES';
        insert customer;
        
        //Create Group Outlet Type
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = objTest.createGroupOutlet(1);
        ASI_CRM_Group_Outlet_Type__c objGroupOutlet = listGroupOutlet[0];
        insert objGroupOutlet;        
        
        //Create Volume Potential Record
        ASI_CRM_Volume_Potential__c objVolume1 = new ASI_CRM_Volume_Potential__c();
        objVolume1.ASI_CRM_SG_External_ID__c = '1234';
        insert objVolume1;
        
        //Create Volume Potential Threshold records
        List<ASI_CRM_Volume_Potential_Threshold__c> volThresholdList = objTest.createVlmPtlThrshold(1);        
        ASI_CRM_Volume_Potential_Threshold__c objVolThreshold = volThresholdList[0];
        objVolThreshold.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        objVolThreshold.ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        objVolThreshold.ASI_CRM_Category__c = 'Wine';
        objVolThreshold.ASI_CRM_Volume__c = 5;
        insert objVolThreshold;
        
        //Create Image Level Record
        ASI_CRM_Image_Level__c objImageLevel = new ASI_CRM_Image_Level__c();
        objImageLevel.ASI_CRM_SG_External_ID__c = '5678';
        objImageLevel.ASI_CRM_SG_Name__c = 'test';
        insert objImageLevel;
        
        //Create Image Potential Threshold records
        List<ASI_CRM_Image_Level_Threshold__c> imgLevelList = objTest.createImgLevelThrshold(1);
        ASI_CRM_Image_Level_Threshold__c objImageLevelTh = imgLevelList[0];
        objImageLevelTh.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        objImageLevelTh.ASI_CRM_SG_Image_Level__c = objImageLevel.Id;       
        insert objImageLevelTh;
        
        //Create test data for Service Pack
        ASI_CRM_ServicePack__c testServicePack = new ASI_CRM_ServicePack__c();
        testServicePack.ASI_CRM_SG_Outlet_Type__c = 'test';
        //testServicePack.ASI_CRM_SG_Sub_Outlet_Type__c = 'test';
        testServicePack.ASI_CRM_SG_Segmentation__c = 'test';
        testServicePack.ASI_CRM_SG_DAMD_Action__c = 'Drop';
        insert testServicePack;
        
        //Create DAMD Threshold records        
        List<ASI_CRM_DAMD_Threshold__c> damdThresholdList = objTest.createDamd(1);
        ASI_CRM_DAMD_Threshold__c damdThreshold = damdThresholdList[0];
        damdThreshold.ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        damdThreshold.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        damdThreshold.ASI_CRM_Contract_Status__c = '';  
        damdThreshold.ASI_CRM_Image_Level__c = objImageLevel.Id;
        insert damdThreshold;       
        
        //Create test data for Pros Segmentation
        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = objTest.createProsSegmentList(1);        
        listProsSeg[0].ASI_CRM_SG_Customer__c = customer.Id;
        listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential_Threshold__c = objVolThreshold.Id;
        listProsSeg[0].ASI_CRM_SG_Image_Level_Threshold__c = objImageLevelTh.Id;
        listProsSeg[0].ASI_CRM_Wine_Volume__c = 5;        
        insert listProsSeg;        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listProsSeg[0]);
        test.startTest();
            ASI_CRM_VN_ProsSegButtonController psButtonController = new ASI_CRM_VN_ProsSegButtonController(sc);
            PageReference saveRef = psButtonController.save();            
            System.assertEquals('High', psButtonController.maxThreshold('High', 'High'));
            System.assertEquals('Medium', psButtonController.maxThreshold('Medium', 'Medium'));
            System.assertEquals('Low', psButtonController.maxThreshold('Test', 'Test'));        
            System.assertNotEquals(Null, saveRef);        
        test.stopTest();
    }   
    
    public static testMethod void cancelTest(){ 
        ASI_CRM_VN_ProsSegButtonControllerTest objTest = new ASI_CRM_VN_ProsSegButtonControllerTest();        
        
        //Create Test Account record
        /*Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;*/
        
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);        
        insert outletTypeList;
        
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = objTest.createCustomer(1);
        ASI_CRM_AccountsAdditionalField__c customer = listCustomer[0];
        //customer.ASI_CRM_Account__c = testAccount.Id;
        customer.Name = 'test';
        customer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;
        insert customer;
        
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = objTest.createGroupOutlet(1);
        ASI_CRM_Group_Outlet_Type__c objGroupOutlet = listGroupOutlet[0];
        insert objGroupOutlet;
        
        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = objTest.createProsSegmentList(1);        
        listProsSeg[0].ASI_CRM_SG_Customer__c = customer.Id;
        listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        insert listProsSeg;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listProsSeg[0]);
        test.startTest();
            ASI_CRM_VN_ProsSegButtonController psButtonController = new ASI_CRM_VN_ProsSegButtonController(sc);
            PageReference cancelPgRef = psButtonController.cancel();
            System.assertNotEquals(Null, cancelPgRef);        
        test.stopTest();
    }    
    
    public static testMethod void openAccountPlanTest(){ 
        ASI_CRM_VN_ProsSegButtonControllerTest objTest = new ASI_CRM_VN_ProsSegButtonControllerTest();        
        
        //Create Test Account record
        /*Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;*/
        
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);        
        insert outletTypeList;
        
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = objTest.createCustomer(1);
        ASI_CRM_AccountsAdditionalField__c customer = listCustomer[0];
        //customer.ASI_CRM_Account__c = testAccount.Id;
        customer.Name = 'test';
        customer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;
        insert customer;
        
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = objTest.createGroupOutlet(1);
        ASI_CRM_Group_Outlet_Type__c objGroupOutlet = listGroupOutlet[0];
        insert objGroupOutlet;
        
        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = objTest.createProsSegmentList(1);        
        listProsSeg[0].ASI_CRM_SG_Customer__c = customer.Id;
        listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        insert listProsSeg;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listProsSeg[0]);
        test.startTest();
            ASI_CRM_VN_ProsSegButtonController psButtonController = new ASI_CRM_VN_ProsSegButtonController(sc);
            PageReference openAccPgRef = psButtonController.openAccountPlan();
            System.assertEquals(Null, openAccPgRef);        
        test.stopTest();
    }

    public static testMethod void updateImageTest(){ 
        ASI_CRM_VN_ProsSegButtonControllerTest objTest = new ASI_CRM_VN_ProsSegButtonControllerTest();        
        
        //Create Test Account record
        /*Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;*/
        
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);        
        insert outletTypeList;
        
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = objTest.createCustomer(1);
        ASI_CRM_AccountsAdditionalField__c customer = listCustomer[0];
        //customer.ASI_CRM_Account__c = testAccount.Id;
        customer.Name = 'test';
        customer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;
        insert customer;
        
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = objTest.createGroupOutlet(1);
        ASI_CRM_Group_Outlet_Type__c objGroupOutlet = listGroupOutlet[0];
        insert objGroupOutlet;
        
        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = objTest.createProsSegmentList(1);        
        listProsSeg[0].ASI_CRM_SG_Customer__c = customer.Id;
        listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        insert listProsSeg;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listProsSeg[0]);
        test.startTest();
            ASI_CRM_VN_ProsSegButtonController psButtonController = new ASI_CRM_VN_ProsSegButtonController(sc);
            PageReference updateImagePgRef = psButtonController.updateImage();
            System.assertNotEquals(Null, updateImagePgRef);        
        test.stopTest();
    }   
    
    //Create Test Record for ASI_CRM_Pros_Segmentation__c
    public List<ASI_CRM_Pros_Segmentation__c> createProsSegmentList(Integer pNumber){
    
        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = new List<ASI_CRM_Pros_Segmentation__c>();
            for(Integer i = 0; i < pNumber; i++){
                listProsSeg.add(new ASI_CRM_Pros_Segmentation__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Pros_Segmentation__cASI_CRM_VN_PROS_Segmentation')));
            }
        return listProsSeg;
    }    
    
    //Create customer test record
    public List<ASI_CRM_AccountsAdditionalField__c> createCustomer(Integer pNumber){
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
            for(Integer i = 0; i < pNumber; i++){
                listCustomer.add(new ASI_CRM_AccountsAdditionalField__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_VN_Outlet_Inactive')));
            }
        return listCustomer;        
    }
    
    //Create Group Outlet Type
    public List<ASI_CRM_Group_Outlet_Type__c> createGroupOutlet(Integer pNumber){
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = new List<ASI_CRM_Group_Outlet_Type__c>();
            for(Integer i = 0; i < pNumber; i++){
                listGroupOutlet.add(new ASI_CRM_Group_Outlet_Type__c());
            }
        return listGroupOutlet;                
    }  
    
    //Create Service Pack
    public List<ASI_CRM_ServicePack__c> createServicePack(Integer pNumber){        
        List<ASI_CRM_ServicePack__c> listServicePack = new List<ASI_CRM_ServicePack__c>();
            for(Integer i = 0; i < pNumber; i++){
                listServicePack.add(new ASI_CRM_ServicePack__c());
            }
        return listServicePack;               
    }
    
    //Create Volume Potential Threshold
    public List<ASI_CRM_Volume_Potential_Threshold__c> createVlmPtlThrshold(Integer pNumber){
        List<ASI_CRM_Volume_Potential_Threshold__c> listVlmPtlThrshold = new List<ASI_CRM_Volume_Potential_Threshold__c>();
            for(Integer i = 0; i < pNumber; i++){
                listVlmPtlThrshold.add(new ASI_CRM_Volume_Potential_Threshold__c());
            }
        return listVlmPtlThrshold;        
    }
    
    //Create Image LevelThreshold
    public List<ASI_CRM_Image_Level_Threshold__c> createImgLevelThrshold(Integer pNumber){
        List<ASI_CRM_Image_Level_Threshold__c> listImgLevelThrshold = new List<ASI_CRM_Image_Level_Threshold__c>();
            for(Integer i = 0; i < pNumber; i++){
                listImgLevelThrshold.add(new ASI_CRM_Image_Level_Threshold__c());
            }
        return listImgLevelThrshold;                
    }
    
    //Create DAMD Threshold
    public List<ASI_CRM_DAMD_Threshold__c> createDamd(Integer pNumber){
        List<ASI_CRM_DAMD_Threshold__c> listDamd = new List<ASI_CRM_DAMD_Threshold__c>();
            for(Integer i = 0; i < pNumber; i++){
                listDamd.add(new ASI_CRM_DAMD_Threshold__c());
            }
        return listDamd;                
    }    
}