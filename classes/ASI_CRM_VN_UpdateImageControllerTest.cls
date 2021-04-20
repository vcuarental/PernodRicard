@isTest
public class ASI_CRM_VN_UpdateImageControllerTest {       
    
    public static testMethod void saveTest1(){                

        // William - 05/02/2016 - Created Running Number Data
        ASI_HK_CRM_Running_Number__c testRunningNumber = ASI_CRM_VN_TestDataFactory.getRunningNumber(
            system.Label.ASI_CRM_VN_Customer_Code,
            1,
            'VN-{YYYY}',
            date.today().month() + 2,
            Date.today().year()
        );
        insert testRunningNumber;


        ASI_CRM_VN_UpdateImageControllerTest objTest = new ASI_CRM_VN_UpdateImageControllerTest();        
        
        //Create Test Account record
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;
        
        List<ASI_CRM_Criteria_Set__c> criteriaSetList = objTest.createCriteriaSet(1);
        ASI_CRM_Criteria_Set__c criteriaSet = criteriaSetList[0];
        criteriaSet.ASI_CRM_SG_External_ID__c= 'ExtSet001';
        criteriaSet.ASI_CRM_SG_Name__c= 'Test Criteria Set';
        criteriaSet.RecordTypeId = getRecordTypeId('ASI_SG_Image_Level_Criteria', 'ASI_CRM_Criteria_Set__c');
        insert criteriaSet;
        
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);        
        insert outletTypeList;
        
        List<ASI_CRM_ServicePack__c> servicepackList = objTest.createServicePack(1);
        ASI_CRM_ServicePack__c servicePack = servicepackList[0];
        servicePack.RecordTypeId = getRecordTypeId('ASI_CRM_VN_ServicePack', 'ASI_CRM_ServicePack__c');
        servicePack.ASI_CRM_ServicePack_EXID__c = 'ExtSer001';
        servicePack.ASI_CRM_SG_Outlet_Type__c = outletTypeList[0].Id;
        servicePack.ASI_CRM_SG_Segmentation__c = 'Iconic';
        servicePack.ASI_CRM_SG_DAMD_Action__c = 'Drop';
        insert servicePack;
        
        //Create test Customer
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = objTest.createCustomer(1);
        ASI_CRM_AccountsAdditionalField__c customer = listCustomer[0];
        customer.ASI_CRM_Account__c = testAccount.Id;
        customer.Name = 'test';
        customer.ASI_CRM_VN_OutletType__c = outletTypeList[0].Id;
        customer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;
        customer.ASI_TH_CRM_Contracted_With__c = 'PRVN';
        insert customer;
        
        //Create Group Outlet Type
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = objTest.createGroupOutlet(1);
        ASI_CRM_Group_Outlet_Type__c objGroupOutlet = listGroupOutlet[0];
        objGroupOutlet.ASI_CRM_SG_Image_Criteria_Set__c = criteriaSet.Id;
        insert objGroupOutlet;        
        
        //Create Volume Potential Record
        ASI_CRM_Volume_Potential__c objVolume1 = new ASI_CRM_Volume_Potential__c();
        objVolume1.ASI_CRM_SG_External_ID__c = '1234';
        objvolume1.ASI_CRM_SG_Name__c = 'test';
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
        objImageLevel.ASI_CRM_SG_Name__c = 'Iconic';
        insert objImageLevel;
        
        //Create Image Potential Threshold records
        List<ASI_CRM_Image_Level_Threshold__c> imgLevelList = objTest.createImgLevelThrshold(1);
        ASI_CRM_Image_Level_Threshold__c objImageLevelTh = imgLevelList[0];
        objImageLevelTh.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        objImageLevelTh.ASI_CRM_SG_Image_Level__c = objImageLevel.Id;
        objImageLevelTh.ASI_CRM_Score__c = 100;
        insert objImageLevelTh;
        
        //Create DAMD Threshold records        
        List<ASI_CRM_DAMD_Threshold__c> damdThresholdList = objTest.createDamd(1);
        ASI_CRM_DAMD_Threshold__c damdThreshold = damdThresholdList[0];
        damdThreshold.ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        damdThreshold.ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        damdThreshold.ASI_CRM_Contract_Status__c = 'PRVN';  
        damdThreshold.ASI_CRM_Image_Level__c = objImageLevel.Id;
        damdThreshold.ASI_CRM_SG_Action__c = 'Drop';
        insert damdThreshold;        
        
        List<ASI_CRM_Criteria_Threshold__c> criteriaThresholdList = objTest.createCriteriaTh(1);
        ASI_CRM_Criteria_Threshold__c criteriaThreshold = criteriaThresholdList[0];
        criteriaThreshold.ASI_CRM_Condition__c = 'Yes';
        criteriaThreshold.ASI_CRM_SG_Criteria_Order__c = 1000;
        criteriaThreshold.ASI_CRM_SG_Criteria_Set__c= criteriaSet.Id;  
        criteriaThreshold.ASI_CRM_External_ID__c = 'ExtThr001';
        criteriaThreshold.ASI_CRM_Max_Threshold__c = 5000;
        criteriaThreshold.ASI_CRM_Min_Threshold__c = 500;
        criteriaThreshold.ASI_CRM_Picklist_Value__c = 'foo, bar, test';
        criteriaThreshold.RecordTypeId = getRecordTypeId('ASI_CRM_VN_Picklist', 'ASI_CRM_Criteria_Threshold__c');
        insert criteriaThreshold;

        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = objTest.createProsSegmentList(1);        
        listProsSeg[0].ASI_CRM_SG_Customer__c = customer.Id;
        listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential_Threshold__c = objVolThreshold.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        listProsSeg[0].ASI_CRM_SG_Image_Level_Threshold__c = objImageLevelTh.Id;
        listProsSeg[0].ASI_CRM_Spirit_Champagne_Volume__c = 5;
        insert listProsSeg;
        
        List<ASI_CRM_Pros_Image_Level__c> listProsImgLvl = objTest.createProsImgLvl(1);        
        listProsImgLvl[0].ASI_CRM_SG_Pros_Segmentation__c = listProsSeg[0].Id;
        listProsImgLvl[0].ASI_CRM_Score__c = 100;
        listProsImgLvl[0].ASI_CRM_External_ID__c = 'ExtImg001';
        listProsImgLvl[0].RecordTypeId = getRecordTypeId('ASI_CRM_SG_ProsImageLevel', 'ASI_CRM_Pros_Image_Level__c');
        insert listProsImgLvl;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listProsSeg[0]);
        test.startTest();
            ASI_CRM_VN_UpdateImageController updateImgController= new ASI_CRM_VN_UpdateImageController(sc);
            for(ASI_CRM_VN_UpdateImageController.Question q : updateImgController.questionList) {
                q.qAnswer = '1150';
            }
            PageReference updateImgRef = updateImgController.updateImage();
            List<SelectOption> listSelOptions = updateImgController.getItems();
            String thresholdLevel = updateImgController.maxThreshold('High','Medium');
            PageReference cancelImgRef = updateImgController.cancel();
            System.assertEquals(2,listSelOptions.size());
            System.assertNotEquals(Null, updateImgRef);
            System.assertNotEquals(Null, cancelImgRef);
            System.assertEquals('High',thresholdLevel);
        test.stopTest();
    }

    public static testMethod void saveTest2() {                
        // William - 05/02/2016 - Created Running Number Data
        ASI_HK_CRM_Running_Number__c testRunningNumber = ASI_CRM_VN_TestDataFactory.getRunningNumber(
            system.Label.ASI_CRM_VN_Customer_Code,
            1,
            'VN-{YYYY}',
            date.today().month() + 2,
            Date.today().year()
        );
        insert testRunningNumber;

        ASI_CRM_VN_UpdateImageControllerTest objTest = new ASI_CRM_VN_UpdateImageControllerTest();        
        
        //Create Test Account record
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;
        
        List<ASI_CRM_Criteria_Set__c> criteriaSetList = objTest.createCriteriaSet(1);
        ASI_CRM_Criteria_Set__c criteriaSet = criteriaSetList[0];
        criteriaSet.ASI_CRM_SG_External_ID__c= 'ExtSet001';
        criteriaSet.ASI_CRM_SG_Name__c= 'Test Criteria Set';
        criteriaSet.RecordTypeId = getRecordTypeId('ASI_SG_Image_Level_Criteria', 'ASI_CRM_Criteria_Set__c');
        insert criteriaSet;
        
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);        
        insert outletTypeList;
        
        //Create test Customer
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = objTest.createCustomer(1);
        ASI_CRM_AccountsAdditionalField__c customer = listCustomer[0];
        customer.ASI_CRM_Account__c = testAccount.Id;
        customer.Name = 'test';
        customer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;  
        customer.ASI_TH_CRM_Contracted_With__c = 'PRVN';
        insert customer;
        
        //Create Group Outlet Type
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = objTest.createGroupOutlet(1);
        ASI_CRM_Group_Outlet_Type__c objGroupOutlet = listGroupOutlet[0];
        objGroupOutlet.ASI_CRM_SG_Image_Criteria_Set__c = criteriaSet.Id;
        objGroupOutlet.ASI_CRM_SG_Group_Outlet_Name__c = 'RES';
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
        damdThreshold.ASI_CRM_Contract_Status__c = 'Others';  
        damdThreshold.ASI_CRM_Image_Level__c = objImageLevel.Id;
        insert damdThreshold;        
        
        List<ASI_CRM_Criteria_Threshold__c> criteriaThresholdList = objTest.createCriteriaTh(1);
        ASI_CRM_Criteria_Threshold__c criteriaThreshold = criteriaThresholdList[0];
        criteriaThreshold.ASI_CRM_Condition__c = 'Yes';
        criteriaThreshold.ASI_CRM_SG_Criteria_Order__c = 1000;
        criteriaThreshold.ASI_CRM_SG_Criteria_Set__c= criteriaSet.Id;  
        criteriaThreshold.ASI_CRM_External_ID__c = 'ExtThr001';
        criteriaThreshold.ASI_CRM_Max_Threshold__c = 5000;
        criteriaThreshold.ASI_CRM_Min_Threshold__c = 500;
        insert criteriaThreshold;

        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = new List<ASI_CRM_Pros_Segmentation__c>();
        listProsSeg.add(new ASI_CRM_Pros_Segmentation__c()); 
        listProsSeg[0].recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Pros_Segmentation__cASI_CRM_VN_PROS_Segmentation');     
        listProsSeg[0].ASI_CRM_SG_Customer__c = customer.Id;
        listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential_Threshold__c = objVolThreshold.Id;
        listProsSeg[0].ASI_CRM_SG_Image_Level_Threshold__c = objImageLevelTh.Id;
        listProsSeg[0].ASI_CRM_Spirit_Champagne_Volume__c = 5;  
        insert listProsSeg;        
        
        /*List<ASI_CRM_Pros_Segmentation__c>*/ listProsSeg = [select Id from ASI_CRM_Pros_Segmentation__c where ASI_CRM_SG_Customer__c =: customer.Id];
        listProsSeg[0].ASI_CRM_SG_Customer__c = customer.Id;
        listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential_Threshold__c = objVolThreshold.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        listProsSeg[0].ASI_CRM_SG_Image_Level_Threshold__c = objImageLevelTh.Id;
        listProsSeg[0].ASI_CRM_Spirit_Champagne_Volume__c = 5;
        System.debug(' --- listProsSeg --- ' + listProsSeg);
        update listProsSeg;
        ApexPages.StandardController sc = new ApexPages.StandardController(listProsSeg[0]);
        test.startTest();
            ASI_CRM_VN_UpdateImageController updateImgController= new ASI_CRM_VN_UpdateImageController(sc);
            PageReference updateImgRef = updateImgController.updateImage();
            String thresholdLevel = updateImgController.maxThreshold('Low','Medium');
            System.assertEquals('Medium',thresholdLevel);
            System.assertNotEquals(Null, updateImgRef);        
        test.stopTest();
    }

    public static testMethod void saveTest3(){                

        // William - 05/02/2016 - Created Running Number Data
        ASI_HK_CRM_Running_Number__c testRunningNumber = ASI_CRM_VN_TestDataFactory.getRunningNumber(
            system.Label.ASI_CRM_VN_Customer_Code,
            1,
            'VN-{YYYY}',
            date.today().month() + 2,
            Date.today().year()
        );
        insert testRunningNumber;

        ASI_CRM_VN_UpdateImageControllerTest objTest = new ASI_CRM_VN_UpdateImageControllerTest();        
        
        //Create Test Account record
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;
        
        List<ASI_CRM_Criteria_Set__c> criteriaSetList = objTest.createCriteriaSet(1);
        ASI_CRM_Criteria_Set__c criteriaSet = criteriaSetList[0];
        criteriaSet.ASI_CRM_SG_External_ID__c= 'ExtSet001';
        criteriaSet.ASI_CRM_SG_Name__c= 'Test Criteria Set';
        criteriaSet.RecordTypeId = getRecordTypeId('ASI_SG_Image_Level_Criteria', 'ASI_CRM_Criteria_Set__c');
        insert criteriaSet;
        
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);        
        insert outletTypeList;
        
        //Create test Customer
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = objTest.createCustomer(1);
        ASI_CRM_AccountsAdditionalField__c customer = listCustomer[0];
        customer.ASI_CRM_Account__c = testAccount.Id;
        customer.Name = 'test';
        customer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;  
        customer.ASI_TH_CRM_Contracted_With__c = 'Others';
        insert customer;
        
        //Create Group Outlet Type
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = objTest.createGroupOutlet(1);
        ASI_CRM_Group_Outlet_Type__c objGroupOutlet = listGroupOutlet[0];
        objGroupOutlet.ASI_CRM_SG_Image_Criteria_Set__c = criteriaSet.Id;
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
        
        List<ASI_CRM_Criteria_Threshold__c> criteriaThresholdList = objTest.createCriteriaTh(1);
        ASI_CRM_Criteria_Threshold__c criteriaThreshold = criteriaThresholdList[0];
        criteriaThreshold.ASI_CRM_Condition__c = 'Yes';
        criteriaThreshold.ASI_CRM_SG_Criteria_Order__c = 1000;
        criteriaThreshold.ASI_CRM_SG_Criteria_Set__c= criteriaSet.Id;  
        criteriaThreshold.ASI_CRM_External_ID__c = 'ExtThr001';
        criteriaThreshold.ASI_CRM_Max_Threshold__c = 5000;
        criteriaThreshold.ASI_CRM_Min_Threshold__c = 500;
        criteriaThreshold.ASI_CRM_Picklist_Value__c = 'foo, bar, test';
        criteriaThreshold.RecordTypeId = getRecordTypeId('ASI_CRM_VN_Yes_No', 'ASI_CRM_Criteria_Threshold__c');
        insert criteriaThreshold;

        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = objTest.createProsSegmentList(1);        
        listProsSeg[0].ASI_CRM_SG_Customer__c = customer.Id;
        listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential_Threshold__c = objVolThreshold.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        listProsSeg[0].ASI_CRM_SG_Image_Level_Threshold__c = objImageLevelTh.Id;
        listProsSeg[0].ASI_CRM_Spirit_Champagne_Volume__c = 5;
        insert listProsSeg;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listProsSeg[0]);
        test.startTest();
            ASI_CRM_VN_UpdateImageController updateImgController= new ASI_CRM_VN_UpdateImageController(sc);
            for(ASI_CRM_VN_UpdateImageController.Question q : updateImgController.questionList) {
                q.qAnswer = 'Yes';
            }
            PageReference updateImgRef = updateImgController.updateImage();
            System.assertNotEquals(Null, updateImgRef);
            String thresholdLevel = updateImgController.maxThreshold('Low','ABCDEF');
            System.assertEquals('Low',thresholdLevel);        
        test.stopTest();
    }

    public static testMethod void saveTest4() {                

        // William - 05/02/2016 - Created Running Number Data
        ASI_HK_CRM_Running_Number__c testRunningNumber = ASI_CRM_VN_TestDataFactory.getRunningNumber(
            system.Label.ASI_CRM_VN_Customer_Code,
            1,
            'VN-{YYYY}',
            date.today().month() + 2,
            Date.today().year()
        );
        insert testRunningNumber;

        ASI_CRM_VN_UpdateImageControllerTest objTest = new ASI_CRM_VN_UpdateImageControllerTest();        
        
        //Create Test Account record
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;
        
        List<ASI_CRM_Criteria_Set__c> criteriaSetList = objTest.createCriteriaSet(1);
        ASI_CRM_Criteria_Set__c criteriaSet = criteriaSetList[0];
        criteriaSet.ASI_CRM_SG_External_ID__c= 'ExtSet001';
        criteriaSet.ASI_CRM_SG_Name__c= 'Test Criteria Set';
        criteriaSet.RecordTypeId = getRecordTypeId('ASI_SG_Image_Level_Criteria', 'ASI_CRM_Criteria_Set__c');
        insert criteriaSet;
        
        List<ASI_TH_CRM_OutletType__c> outletTypeList = ASI_CRM_VN_VisitationPlanDetailGenTest.createTestOutletType(1);        
        insert outletTypeList;
        
        //Create test Customer
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = objTest.createCustomer(1);
        ASI_CRM_AccountsAdditionalField__c customer = listCustomer[0];
        customer.ASI_CRM_Account__c = testAccount.Id;
        customer.Name = 'test';
        customer.ASI_TH_CRM_OutletType__c = outletTypeList[0].Id;  
        customer.ASI_TH_CRM_Contracted_With__c = 'Others';
        insert customer;
        
        //Create Group Outlet Type
        List<ASI_CRM_Group_Outlet_Type__c> listGroupOutlet = objTest.createGroupOutlet(1);
        ASI_CRM_Group_Outlet_Type__c objGroupOutlet = listGroupOutlet[0];
        objGroupOutlet.ASI_CRM_SG_Image_Criteria_Set__c = criteriaSet.Id;
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
        // damdThreshold.ASI_CRM_Contract_Status__c = 'PRVN';  
        damdThreshold.ASI_CRM_Image_Level__c = objImageLevel.Id;
        insert damdThreshold;        
        
        List<ASI_CRM_Criteria_Threshold__c> criteriaThresholdList = objTest.createCriteriaTh(1);
        ASI_CRM_Criteria_Threshold__c criteriaThreshold = criteriaThresholdList[0];
        criteriaThreshold.ASI_CRM_Condition__c = 'Yes';
        criteriaThreshold.ASI_CRM_SG_Criteria_Order__c = 1000;
        criteriaThreshold.ASI_CRM_SG_Criteria_Set__c= criteriaSet.Id;  
        criteriaThreshold.ASI_CRM_External_ID__c = 'ExtThr001';
        criteriaThreshold.ASI_CRM_Max_Threshold__c = 5000;
        criteriaThreshold.ASI_CRM_Min_Threshold__c = 500;
        criteriaThreshold.ASI_CRM_Picklist_Value__c = 'foo, bar, test';
        criteriaThreshold.RecordTypeId = getRecordTypeId('ASI_CRM_VN_Yes_No', 'ASI_CRM_Criteria_Threshold__c');
        insert criteriaThreshold;

        List<ASI_CRM_Pros_Segmentation__c> listProsSeg = objTest.createProsSegmentList(1);        
        listProsSeg[0].ASI_CRM_SG_Customer__c = customer.Id;
        listProsSeg[0].ASI_CRM_SG_Group_Outlet_Type__c = objGroupOutlet.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential_Threshold__c = objVolThreshold.Id;
        listProsSeg[0].ASI_CRM_SG_Volume_Potential__c = objVolume1.Id;
        listProsSeg[0].ASI_CRM_SG_Image_Level_Threshold__c = objImageLevelTh.Id;
        listProsSeg[0].ASI_CRM_Spirit_Champagne_Volume__c = 5;
        insert listProsSeg;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listProsSeg[0]);
        test.startTest();
            ASI_CRM_VN_UpdateImageController updateImgController= new ASI_CRM_VN_UpdateImageController(sc);
            for(ASI_CRM_VN_UpdateImageController.Question q : updateImgController.questionList) {
                q.qAnswer = 'Yes';
            }
            PageReference updateImgRef = updateImgController.updateImage();
            System.assertNotEquals(Null, updateImgRef);
            String thresholdLevel = updateImgController.maxThreshold('Low','ABCDEF');
            System.assertEquals('Low',thresholdLevel);        
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
                listCustomer.add(new ASI_CRM_AccountsAdditionalField__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_VN_Outlet')));
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

    //Create Criteria Threshold
    public List<ASI_CRM_Criteria_Threshold__c> createCriteriaTh(Integer pNumber){
        List<ASI_CRM_Criteria_Threshold__c> listcriteriaTh = new List<ASI_CRM_Criteria_Threshold__c>();
            for(Integer i = 0; i < pNumber; i++){
                listcriteriaTh.add(new ASI_CRM_Criteria_Threshold__c());
            }
        return listcriteriaTh;                
    }

    //Create Criteria Set
    public List<ASI_CRM_Criteria_Set__c> createCriteriaSet(Integer pNumber){
        List<ASI_CRM_Criteria_Set__c> listcriteriaSet = new List<ASI_CRM_Criteria_Set__c>();
            for(Integer i = 0; i < pNumber; i++){
                listcriteriaSet.add(new ASI_CRM_Criteria_Set__c());
            }
        return listcriteriaSet;                
    }

    public List<ASI_CRM_Pros_Image_Level__c> createProsImgLvl(Integer pNumber){
        List<ASI_CRM_Pros_Image_Level__c> listProsImgLvl = new List<ASI_CRM_Pros_Image_Level__c>();
            for(Integer i = 0; i < pNumber; i++){
                listProsImgLvl.add(new ASI_CRM_Pros_Image_Level__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Pros_Image_Level__cASI_CRM_VN_ProsImageLevel')));
            }
        return listProsImgLvl;                
    }

    private static Id getRecordTypeId(String Developername,String SobjectType) {
        Id RecordTypeId;
        if(RecordTypeId==null)
            RecordTypeId = [Select Id from RecordType where Developername=:Developername and SobjectType=:SobjectType LIMIT 1].Id;  
        return RecordTypeId;
    }
}