@isTest
public class ASI_CRM_VN_AccountProsSegControllerTest {
    @testSetup
    static void setupTestData(){
        ASI_HK_CRM_Running_Number__c testRunningNumber = ASI_CRM_VN_TestDataFactory.getRunningNumber(
            system.Label.ASI_CRM_VN_Customer_Code,
            1,
            'VN-{YYYY}',
            date.today().month() + 2,
            Date.today().year()
        );
        insert testRunningNumber;
    }
    public static testMethod void saveTest1() {  
        //Create Test Account record
        Account testAccount = new Account(RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_VN_Supplier'));
        testAccount.Name = 'testAccount';
        insert testAccount;
        
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);        
        insert outletTypeList;
        
        //Create test Customer
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = ASI_CRM_VN_TestDataFactory.createCustomer(1);
        ASI_CRM_AccountsAdditionalField__c customer = listCustomer[0];
        customer.ASI_CRM_Account__c = testAccount.Id;
        customer.Name = 'test';
        customer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;  
        customer.ASI_TH_CRM_Contracted_With__c = 'PRVN';
        insert customer;
        
        //Create Group Outlet Type
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = ASI_CRM_VN_TestDataFactory.createGroupOutlet(1);
        ASI_CRM_Group_Outlet_Type__c objGroupOutlet = listGroupOutlet[0];
        insert objGroupOutlet;        
        
        //Create Volume Potential Record
        ASI_CRM_Volume_Potential__c objVolume1 = new ASI_CRM_Volume_Potential__c();
        objVolume1.ASI_CRM_SG_External_ID__c = '1234';
        objVolume1.ASI_CRM_SG_Name__c = 'Low';
        insert objVolume1;
        
        //Create Volume Potential Threshold records
        List<ASI_CRM_Volume_Potential_Threshold__c> volThresholdList = ASI_CRM_VN_TestDataFactory.createVlmPtlThrshold(1);        
        ASI_CRM_Volume_Potential_Threshold__c objVolThreshold = volThresholdList[0];
        objVolThreshold.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        objVolThreshold.ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        objVolThreshold.ASI_CRM_Category__c = 'Spirit & Champagne';
        objVolThreshold.ASI_CRM_Volume__c = 5;
        insert objVolThreshold;        
        System.debug('--- objVolThreshold ---' + objVolThreshold);
        //Create Image Level Record
        ASI_CRM_Image_Level__c objImageLevel = new ASI_CRM_Image_Level__c();
        objImageLevel.ASI_CRM_SG_External_ID__c = '5678';
        objImageLevel.ASI_CRM_SG_Name__c = 'test';
        insert objImageLevel;
        
        //Create Image Potential Threshold records
        List<ASI_CRM_Image_Level_Threshold__c> imgLevelList = ASI_CRM_VN_TestDataFactory.createImgLevelThrshold(1);
        ASI_CRM_Image_Level_Threshold__c objImageLevelTh = imgLevelList[0];
        objImageLevelTh.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        objImageLevelTh.ASI_CRM_SG_Image_Level__c = objImageLevel.Id;        
        insert objImageLevelTh;
        System.debug('--- objImageLevelTh---' + objImageLevelTh);
        //Create DAMD Threshold records        
        List<ASI_CRM_DAMD_Threshold__c> damdThresholdList = ASI_CRM_VN_TestDataFactory.createDamd(1);
        ASI_CRM_DAMD_Threshold__c damdThreshold = damdThresholdList[0];
        damdThreshold.ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        damdThreshold.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        damdThreshold.ASI_CRM_Contract_Status__c = 'PRVN';  
        damdThreshold.ASI_CRM_Image_Level__c = objImageLevel.Id;
        insert damdThreshold;        
        
        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = new List<ASI_CRM_Pros_Segmentation__c>();
        listProsSeg.add(new ASI_CRM_Pros_Segmentation__c()); 
        listProsSeg[0].recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Pros_Segmentation__cASI_CRM_VN_PROS_Segmentation');     
        listProsSeg[0].ASI_CRM_SG_Customer__c = customer.Id;
        listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential_Threshold__c = objVolThreshold.Id;
        listProsSeg[0].ASI_CRM_SG_Image_Level_Threshold__c = objImageLevelTh.Id;
        listProsSeg[0].ASI_CRM_Spirit_Champagne_Volume__c = 5;  
        insert listProsSeg;        
        System.debug('--- listProsSeg---' + listProsSeg);
        ApexPages.StandardController sc = new ApexPages.StandardController(customer);
        /*List<ASI_CRM_Pros_Segmentation__c>*/ listProsSeg = [select Id from ASI_CRM_Pros_Segmentation__c where ASI_CRM_SG_Customer__c =: customer.Id];
        // listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential_Threshold__c = objVolThreshold.Id;
        listProsSeg[0].ASI_CRM_SG_Image_Level_Threshold__c = objImageLevelTh.Id;
        
        System.debug(' --- listProsSeg --- ' + listProsSeg);
        update listProsSeg;
        test.startTest();
            ASI_CRM_VN_AccountProsSegController accProsSegController = new ASI_CRM_VN_AccountProsSegController(sc);
            PageReference accPlanRef = accProsSegController.openAccountPlan();
            PageReference prosSegmentationRef = accProsSegController.openProsSegmentation();
            List<String> msLabels = ASI_CRM_VN_AccountProsSegController.returnMarketShareLabels();
            Component.Apex.CommandButton cLink = accProsSegController.getCustomLink();
            PageReference prosSegRef = accProsSegController.openProsSeg();
            PageReference updateImgRef = accProsSegController.updateImage();
        test.stopTest();

    }
    
    public static testMethod void saveTest2() {  
        //Create Test Account record
        Account testAccount = new Account(RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_VN_Supplier'));
        testAccount.Name = 'testAccount';
        insert testAccount;
        
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);        
        insert outletTypeList;
        
        //Create test Customer
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = ASI_CRM_VN_TestDataFactory.createCustomer(1);
        ASI_CRM_AccountsAdditionalField__c customer = listCustomer[0];
        customer.ASI_CRM_Account__c = testAccount.Id;
        customer.Name = 'test';
        customer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;  
        customer.ASI_TH_CRM_Contracted_With__c = 'PRVN';
        insert customer;
        
        //Create Group Outlet Type
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = ASI_CRM_VN_TestDataFactory.createGroupOutlet(1);
        ASI_CRM_Group_Outlet_Type__c objGroupOutlet = listGroupOutlet[0];
        insert objGroupOutlet;        
        
        //Create Volume Potential Record
        ASI_CRM_Volume_Potential__c objVolume1 = new ASI_CRM_Volume_Potential__c();
        objVolume1.ASI_CRM_SG_External_ID__c = '1234';
        objVolume1.ASI_CRM_SG_Name__c = 'Low';
        insert objVolume1;
        
        //Create Volume Potential Threshold records
        List<ASI_CRM_Volume_Potential_Threshold__c> volThresholdList = ASI_CRM_VN_TestDataFactory.createVlmPtlThrshold(1);        
        ASI_CRM_Volume_Potential_Threshold__c objVolThreshold = volThresholdList[0];
        objVolThreshold.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        objVolThreshold.ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        objVolThreshold.ASI_CRM_Category__c = 'Spirit & Champagne';
        objVolThreshold.ASI_CRM_Volume__c = 5;
        insert objVolThreshold;        
        System.debug('--- objVolThreshold ---' + objVolThreshold);
        //Create Image Level Record
        ASI_CRM_Image_Level__c objImageLevel = new ASI_CRM_Image_Level__c();
        objImageLevel.ASI_CRM_SG_External_ID__c = '5678';
        objImageLevel.ASI_CRM_SG_Name__c = 'test';
        insert objImageLevel;
        
        //Create Image Potential Threshold records
        List<ASI_CRM_Image_Level_Threshold__c> imgLevelList = ASI_CRM_VN_TestDataFactory.createImgLevelThrshold(1);
        ASI_CRM_Image_Level_Threshold__c objImageLevelTh = imgLevelList[0];
        objImageLevelTh.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        objImageLevelTh.ASI_CRM_SG_Image_Level__c = objImageLevel.Id;        
        insert objImageLevelTh;
        System.debug('--- objImageLevelTh---' + objImageLevelTh);
        //Create DAMD Threshold records        
        List<ASI_CRM_DAMD_Threshold__c> damdThresholdList = ASI_CRM_VN_TestDataFactory.createDamd(1);
        ASI_CRM_DAMD_Threshold__c damdThreshold = damdThresholdList[0];
        damdThreshold.ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        damdThreshold.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        damdThreshold.ASI_CRM_Contract_Status__c = 'PRVN';  
        damdThreshold.ASI_CRM_Image_Level__c = objImageLevel.Id;
        insert damdThreshold;        
        ApexPages.StandardController sc = new ApexPages.StandardController(customer);
        test.startTest();
            ASI_CRM_VN_AccountProsSegController accProsSegController = new ASI_CRM_VN_AccountProsSegController(sc);
            accProsSegController.prosSegmentation = NULL;
            PageReference accPlanRef = accProsSegController.openAccountPlan();
            // PageReference prosSegmentationRef = accProsSegController.openProsSegmentation();
            List<String> msLabels = ASI_CRM_VN_AccountProsSegController.returnMarketShareLabels();
            Component.Apex.CommandButton cLink = accProsSegController.getCustomLink();
            PageReference prosSegRef = accProsSegController.openProsSeg();
            PageReference updateImgRef = accProsSegController.updateImage();
        test.stopTest();
    }
}