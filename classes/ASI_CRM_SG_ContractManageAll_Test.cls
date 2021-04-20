/*
 *********************************************************************************
 * Name: ASI_CRM_SG_ContractManageAll_Test
 * Description: Test class for ASI_CRM_SG_ContractManageAll_Ctrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/11/2017       Jeffrey Cheung          Created, only calculateBackRebatesAmountTest has assertions
 * 17/06/2018       Wilken Lee              [WL 1.0] Phase 4.2 Gen Remaining achived back rebate payment
 * 03/07/2019       Wilson Chow             Increase coverage, add testSearchSKU(), testContructor(), testQuickSave(),
 *                                           testValidateAmountExceedRTMContract(), testRetrieveChildOutlet()
 * 03/11/2020       Wilken Lee              [WL 2.0] Fix test class error due to missing SKU Price/Cost record type
 */

@isTest
private class ASI_CRM_SG_ContractManageAll_Test {
    @TestSetup
    public static void setupTestData() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        ASI_CRM_SG_TestClassHelper.contractData contractC1 = new ASI_CRM_SG_TestClassHelper.contractData(false);
        // only approved contract can generateBackRebatesPayment
        contractC1.contract.ASI_TH_CRM_Contract_Status__c = 'Contract Approved';

        // 20190703 Wilson Chow
        contractC1.contract.ASI_TH_CRM_Start_Date__c = date.today();
        // 20190703 Wilson Chow

        insert contractC1.contract;

        // 20190703 Wilson Chow
        List<ASI_CRM_Contract_Outlets__c> contractOutletList = new List<ASI_CRM_Contract_Outlets__c>();

        ASI_CRM_Contract_Outlets__c contractOutletTemp1 =
                new ASI_CRM_Contract_Outlets__c (
                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Outlets__cASI_CRM_SG_Contract_Outlet'),
                    ASI_CRM_SG_Customer__c = contractC1.contract.ASI_CRM_CN_Outlet_WS__c,
                    ASI_CRM_SG_Contract__c = contractC1.contract.id
                );
        contractOutletList.add(contractOutletTemp1);

        ASI_CRM_Contract_Outlets__c contractOutletTemp2 =
                new ASI_CRM_Contract_Outlets__c (
                        recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Outlets__cASI_CRM_SG_Contract_Outlet'),
                        ASI_CRM_SG_Customer__c = contractC1.contract.ASI_CRM_CN_Outlet_WS__c,
                        ASI_CRM_SG_Contract__c = contractC1.contract.id
                );
        contractOutletList.add(contractOutletTemp2);

        insert contractOutletList;

        List<ASI_CRM_Payment_Schedule__c> paymentScheduleList = new List<ASI_CRM_Payment_Schedule__c>();

        ASI_CRM_Payment_Schedule__c paymentSchedule1 = new ASI_CRM_Payment_Schedule__c (
                recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule'),
                ASI_CRM_Percentof_achieved_Sales_Target__c = '0',
                ASI_CRM_Sponsorship__c = 100,
                ASI_CRM_Type__c = 'Cash Sponsorship',
                ASI_CRM_Contract__c = contractC1.contract.id
        );
        paymentScheduleList.add(paymentSchedule1);

        ASI_CRM_Payment_Schedule__c paymentSchedule2 = new ASI_CRM_Payment_Schedule__c (
                recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule'),
                ASI_CRM_Percentof_achieved_Sales_Target__c = '0',
                ASI_CRM_Sponsorship__c = 100,
                ASI_CRM_Type__c = 'Cash Sponsorship',
                ASI_CRM_Contract__c = contractC1.contract.id
        );
        paymentScheduleList.add(paymentSchedule2);

        insert paymentScheduleList;

        Attachment lAtt = new Attachment();
        lAtt.ParentId = contractC1.contract.id;
        lAtt.name = 'Teste';
        lAtt.Body = Blob.valueof( 'asdasd' );
        insert lAtt;
        // 21907013 Wilson Chow

        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC1.contract, skuList.get(1));
        contractTargetC1.contractTarget.ASI_CRM_Entitle_Back_Rebates__c = true;
        // for fields in ASI_CRM_Bottle_Incentive_Total__c 
        contractTargetC1.contractTarget.ASI_CRM_Bottle_Incentive__c = 10;
        contractTargetC1.contractTarget.ASI_CRM_SG_Btls_Per_Case__c = 2;
        contractTargetC1.contractTarget.ASI_CRM_TargetCase__c = 50;
        contractTargetC1.contractTarget.ASI_CRM_Back_Rebates_Issued_Bottle__c = 0;
        // for fields in ASI_CRM_Till_Date_Sales_Percent_Bottle__c = ASI_CRM_Till_Date_Sales_Bottle__c / ASI_CRM_Target_Bottle__c
        contractTargetC1.contractTarget.ASI_CRM_Till_Date_Sales_Bottle__c = 100;
        // for fields in ASI_CRM_Back_Rebates_Issued_Percent__c
        contractTargetC1.contractTarget.ASI_CRM_Back_Rebates_Issued_Total__c = 0;
        contractTargetC1.contractTarget.ASI_CRM_SG_Cash__c = 10;
        
        insert contractTargetC1.contractTarget;
        
        List<ASI_TH_CRM_Actual_Offtake__c> list_a = new List<ASI_TH_CRM_Actual_Offtake__c>();
         ASI_CRM_SG_TestClassHelper.offtakeData offtake1 = new ASI_CRM_SG_TestClassHelper.offtakeData(false, 'ASI_CRM_SG_Actual_offtake', contractC1.contract.Id, contractC1.contract.ASI_CRM_CN_Outlet_WS__c, skuList.get(1).Id);
        offtake1.offtake.ASI_CRM_Open_Outlet_Price__c = 100;
        offtake1.offtake.ASI_CRM_Incentive_Price__c = 50;
        offtake1.offtake.ASI_TH_CRM_Quantity__c = 30;
        offtake1.offtake.ASI_TH_CRM_Offtake_G_L_Date__c = system.today().addDays(-10);
         ASI_CRM_SG_TestClassHelper.offtakeData offtake2 = new ASI_CRM_SG_TestClassHelper.offtakeData(false, 'ASI_CRM_SG_Actual_offtake', contractC1.contract.Id, contractC1.contract.ASI_CRM_CN_Outlet_WS__c, skuList.get(1).Id);
        offtake2.offtake.ASI_CRM_Open_Outlet_Price__c = 100;
        offtake2.offtake.ASI_CRM_Incentive_Price__c = 70;
        offtake2.offtake.ASI_TH_CRM_Quantity__c = 70;
        offtake2.offtake.ASI_TH_CRM_Offtake_G_L_Date__c = system.today().addDays(-9);
         ASI_CRM_SG_TestClassHelper.offtakeData offtake3 = new ASI_CRM_SG_TestClassHelper.offtakeData(false, 'ASI_CRM_SG_Actual_offtake', contractC1.contract.Id, contractC1.contract.ASI_CRM_CN_Outlet_WS__c, skuList.get(1).Id);
        offtake3.offtake.ASI_CRM_Open_Outlet_Price__c = 100;
        offtake3.offtake.ASI_CRM_Incentive_Price__c = 50;
        offtake3.offtake.ASI_TH_CRM_Quantity__c = -10;
        offtake3.offtake.ASI_TH_CRM_Offtake_G_L_Date__c = system.today().addDays(-8);
         ASI_CRM_SG_TestClassHelper.offtakeData offtake4 = new ASI_CRM_SG_TestClassHelper.offtakeData(false, 'ASI_CRM_SG_Actual_offtake', contractC1.contract.Id, contractC1.contract.ASI_CRM_CN_Outlet_WS__c, skuList.get(1).Id);
        offtake4.offtake.ASI_CRM_Open_Outlet_Price__c = 100;
        offtake4.offtake.ASI_CRM_Incentive_Price__c = 50;
        offtake4.offtake.ASI_TH_CRM_Quantity__c = 75;
        offtake4.offtake.ASI_TH_CRM_Offtake_G_L_Date__c = system.today().addDays(-7);
         ASI_CRM_SG_TestClassHelper.offtakeData offtake5 = new ASI_CRM_SG_TestClassHelper.offtakeData(false, 'ASI_CRM_SG_Actual_offtake', contractC1.contract.Id, contractC1.contract.ASI_CRM_CN_Outlet_WS__c, skuList.get(1).Id);
        offtake5.offtake.ASI_CRM_Open_Outlet_Price__c = 100;
        offtake5.offtake.ASI_CRM_Incentive_Price__c = 50;
        offtake5.offtake.ASI_TH_CRM_Quantity__c = 1275;
        offtake5.offtake.ASI_TH_CRM_Offtake_G_L_Date__c = system.today().addDays(-7);
        list_a.add(offtake1.offtake);
        list_a.add(offtake2.offtake);
        list_a.add(offtake3.offtake);
        list_a.add(offtake4.offtake);
        list_a.add(offtake5.offtake);
        
        insert list_a;

        ApexPages.StandardController sc = new ApexPages.StandardController(contractC1.contract);
        ASI_CRM_SG_ContractManageAll_Ctrl cmac = new ASI_CRM_SG_ContractManageAll_Ctrl(sc);
    }
    
    public static testMethod void testController() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];
        
        PageReference pageRef = Page.ASI_CRM_SG_ContractManageAll_Page;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        ApexPages.currentPage().getParameters().put('Id', contract.id);
        ASI_CRM_SG_ContractManageAll_Ctrl cmac = new ASI_CRM_SG_ContractManageAll_Ctrl(sc);
        
        //Get JSON String
        String contractTargetListJson          = cmac.contractTargetListJson;
        String cashPaymentScheduleListJson     = cmac.cashPaymentScheduleListJson;
        String skuPriceWrapperListJson         = cmac.skuPriceWrapperListJson;
        String exceptionListJson               = cmac.exceptionListJson;
        
        Test.startTest();
        
        List<ASI_CRM_ContractTarget__c>  contractTargetList = (List<ASI_CRM_ContractTarget__c>) jsonStringToObject(contractTargetListJson, List<ASI_CRM_ContractTarget__c>.class);
        Set<Id> skuIdSet = new Set<Id>();
        // 20190703 Wilson Chow
        /*
        for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
            skuIdSet.add(contractTarget.ASI_CRM_SKU__c);
        }
        */
        ASI_MFM_SKU_Code__c sku = [select id from ASI_MFM_SKU_Code__c limit 1];
        skuIdSet.add(sku.id);

        List<ASI_CRM_Contract_Outlets__c> outletList = [select id from ASI_CRM_Contract_Outlets__c];
        List<ASI_CRM_Payment_Schedule__c> paymentScheduleList = [select id from ASI_CRM_Payment_Schedule__c];
        // 20190703 Wilson Chow
        
        ApexPages.currentPage().getParameters().put('skuName', 'Test Sku 2');
        ApexPages.currentPage().getParameters().put('filterOutSKUIdListJson', objectToJsonString(skuIdSet));
        cmac.searchSKU();

        ApexPages.currentPage().getParameters().put('contractTargetListJson', contractTargetListJson);
        cmac.calculateROI();
        
        ApexPages.currentPage().getParameters().put('updateContractTargetListJson', contractTargetListJson);
        ApexPages.currentPage().getParameters().put('deleteContractTargetListJson', objectToJsonString(new List<Id>()));
        // 20190703 Wilson Chow
        /*
        ApexPages.currentPage().getParameters().put('updatePaymentScheduleListJson', objectToJsonString(new List<ASI_CRM_Payment_Schedule__c>()));
        ApexPages.currentPage().getParameters().put('deletePaymentScheduleListJson', objectToJsonString(new List<Id>()));
        ApexPages.currentPage().getParameters().put('updateContractOutletListJson', objectToJsonString(new List<ASI_CRM_Contract_Outlets__c>()));
        ApexPages.currentPage().getParameters().put('deleteContractOutletListJson', objectToJsonString(new List<Id>()));
        */
        List<ASI_CRM_Payment_Schedule__c> updatedPaymentScheduleList = new List<ASI_CRM_Payment_Schedule__c>();
        updatedPaymentScheduleList.add(paymentScheduleList[0]);
        List<Id> removePaymentScheduleList = new List<Id>();
        removePaymentScheduleList.add(paymentScheduleList[1].Id);

        ApexPages.currentPage().getParameters().put('updatePaymentScheduleListJson', objectToJsonString(updatedPaymentScheduleList));
        ApexPages.currentPage().getParameters().put('deletePaymentScheduleListJson', objectToJsonString(removePaymentScheduleList));

        List<ASI_CRM_Contract_Outlets__c> updatedOutletList = new List<ASI_CRM_Contract_Outlets__c>();
        updatedOutletList.add(outletList[0]);
        List<Id> removeOutletList = new List<Id>();
        removeOutletList.add(outletList[1].Id);

        ApexPages.currentPage().getParameters().put('updateContractOutletListJson', objectToJsonString(updatedOutletList));
        ApexPages.currentPage().getParameters().put('deleteContractOutletListJson', objectToJsonString(removeOutletList));
        // 20190703 Wilson Chow

        cmac.reviseContract();
        cmac.deleteSimulation();
        cmac.getInflationRate();
        cmac.getDistributionRate();
        cmac.saveRecord();
        cmac.cancel();
        String a1 = cmac.contractTargetRecordTypeId;
        String a2 = cmac.paymentSponsorshipRecordTypeId;
        String a3 = cmac.paymentSponsorshipSimulationRecordTypeId;
        String a4 = cmac.contractOutletRecordTypeId;
        String a5 = cmac.contractOutletSimulationRecordTypeId;
        String a6 = cmac.contractContractOutletListJson;
        String a7 = cmac.childOutletListJson;
        
        Test.stopTest();
    }

    
    private static testMethod void generateBackRebatesPaymentTest() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        ASI_CRM_SG_ContractManageAll_Ctrl cmac = new ASI_CRM_SG_ContractManageAll_Ctrl(sc);
        cmac.generateBackRebatesPayment();
        
        Test.startTest();
        ASI_CRM_ContractTarget__c ct = [select id from ASI_CRM_ContractTarget__c limit 1];
        ct.ASI_CRM_Till_Date_Sales_Bottle__c = 1165;
        update ct;
        cmac.generateBackRebatesPayment();
        delete [select id from ASI_TH_CRM_PaymentRequest__c order by id desc limit 1];
        
        /*[WL 1.0] BEGIN*/
        cmac.generateBackRebatesPaymentRemain();
        /*[WL 1.0] END*/
        Test.stopTest();
    }
    
    private static testMethod void generatePaymentTest() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];
        List<ASI_CRM_Payment_Schedule__c> paymentScheduleList = ASI_CRM_SG_TestClassHelper.createPaymentSchedule(contract);
        
        PageReference pageRef = Page.ASI_CRM_SG_ContractManageAll_Page;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        ApexPages.currentPage().getParameters().put('Id', contract.id);
        ASI_CRM_SG_ContractManageAll_Ctrl cmac = new ASI_CRM_SG_ContractManageAll_Ctrl(sc);
        
        ApexPages.currentPage().getParameters().put('scheduleId', paymentScheduleList.get(0).Id);
        cmac.requestPayment();
    }
    
    private static testMethod void calculateBackRebatesAmountTest() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        ASI_CRM_SG_ContractManageAll_Ctrl cmac = new ASI_CRM_SG_ContractManageAll_Ctrl(sc);
        
        Decimal result;

        // These cases are from 4.1 powerpoint
        result = cmac.calculateBackRebatesAmount(1000, 80, 0);
        System.assertEquals(750, result);
        result = cmac.calculateBackRebatesAmount(1000, 80, 50);
        System.assertEquals(250, result);
        result = cmac.calculateBackRebatesAmount(1000, 115, 0);
        System.assertEquals(1150, result);
        result = cmac.calculateBackRebatesAmount(1000, 115, 110);
        System.assertEquals(50, result);
        result = cmac.calculateBackRebatesAmount(1000, 10, 0);
        System.assertEquals(0, result);
    }
    
    
    private static String objectToJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }

    private static Object jsonStringToObject(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return System.JSON.deserialize(jsonString, apexType);
    }

    
    public static testMethod void testControllerSimulation() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];
        
        PageReference pageRef = Page.ASI_CRM_SG_ContractManageAll_Page;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        ApexPages.currentPage().getParameters().put('Id', contract.id);
        ApexPages.currentPage().getParameters().put('isSimulation', 'true');
        ASI_CRM_SG_ContractManageAll_Ctrl cmac = new ASI_CRM_SG_ContractManageAll_Ctrl(sc);
    }

    // 20190703 Wilson Chow
    @isTest
    static void testSearchSKU() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];

        PageReference pageRef = Page.ASI_CRM_SG_ContractManageAll_Page;
        Test.setCurrentPage(pageRef);

        Set<String> skuIdSet = new Set<String>();
        ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c (
                name='20190703',
                ASI_MFM_SKU_Code__c = '20190703',
                recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'),
                ASI_HK_CRM_Std_Bottle_Size__c = 8,
                ASI_HK_CRM_Packaging_Size__c = 9,
                ASI_HK_CRM_Available_Quantity__c = 10,
                ASI_HK_CRM_UOM1__c = 'UOM1',
                ASI_HK_CRM_Active__c = true,
                ASI_HK_CRM_IsPOSProduct__c = false
        );
        insert sku;
        skuIdSet.add(String.valueOf(sku.id));

        ASI_CRM_MY_SKUPriceCost__c skuPriceCost =
            [select Id, ASI_CRM_EffectiveDate__c, ASI_CRM_SKU__c from ASI_CRM_MY_SKUPriceCost__c limit 1];
        ASI_CRM_MY_SKUPriceCost__c cloneSkuPriceCost = skuPriceCost.clone(false, false, false, false);
        cloneSkuPriceCost.ASI_CRM_EffectiveDate__c = date.today().addDays(14);
        cloneSkuPriceCost.ASI_CRM_SKU__c = sku.id;
        cloneSkuPriceCost.recordTypeID = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle');//WL 2.0
        insert cloneSkuPriceCost;

        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        ApexPages.currentPage().getParameters().put('Id', contract.id);
        ApexPages.currentPage().getParameters().put('filterOutSKUIdListJson', objectToJsonString(skuIdSet));

        ASI_CRM_SG_ContractManageAll_Ctrl cmac = new ASI_CRM_SG_ContractManageAll_Ctrl(sc);
        cmac.searchSKU();

        cmac.generateBackRebatesPymtSpecificTarget(String.valueOf(contract.Id), String.valueOf(sku.id));
    }

    @isTest
    static void testContructor() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];

        PageReference pageRef = Page.ASI_CRM_SG_ContractManageAll_Page;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        ApexPages.currentPage().getParameters().put('Id', contract.id);

        ASI_CRM_SG_ContractManageAll_Ctrl cmac = new ASI_CRM_SG_ContractManageAll_Ctrl(sc);

        String REQUESTEDPAYMENTID_VFString = cmac.REQUESTEDPAYMENTID_VF;
        ASI_CRM_SG_ContractManageAll_Ctrl tmpSc = new ASI_CRM_SG_ContractManageAll_Ctrl();
    }

    @isTest
    static void testQuickSave() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];

        PageReference pageRef = Page.ASI_CRM_SG_ContractManageAll_Page;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        ApexPages.currentPage().getParameters().put('Id', contract.id);

        ASI_CRM_SG_ContractManageAll_Ctrl cmac = new ASI_CRM_SG_ContractManageAll_Ctrl(sc);

        ApexPages.currentPage().getParameters().put('updateContractTargetListJson', cmac.contractTargetListJson);
        ApexPages.currentPage().getParameters().put('deleteContractTargetListJson', objectToJsonString(new List<Id>()));
        ApexPages.currentPage().getParameters().put('updatePaymentScheduleListJson', objectToJsonString(new List<ASI_CRM_Payment_Schedule__c>()));
        ApexPages.currentPage().getParameters().put('deletePaymentScheduleListJson', objectToJsonString(new List<Id>()));
        ApexPages.currentPage().getParameters().put('updateContractOutletListJson', objectToJsonString(new List<ASI_CRM_Contract_Outlets__c>()));
        ApexPages.currentPage().getParameters().put('IS_QUICK_SAVE', 'true');

        cmac.saveRecord();
    }

    @isTest
    static void testValidateAmountExceedRTMContract() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];
        try {
            ASI_CRM_SG_ContractManageAll_Ctrl.validateAmountExceedRTMContract(contract.Id, true);
        }
        catch(Exception e) {

        }
    }

    @isTest
    static void testRetrieveChildOutlet() {
        ASI_TH_CRM_Contract__c contract = [SELECT Id FROM ASI_TH_CRM_Contract__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        ApexPages.currentPage().getParameters().put('Id', contract.id);
        ASI_CRM_SG_ContractManageAll_Ctrl cmac = new ASI_CRM_SG_ContractManageAll_Ctrl(sc);
        cmac.retrieveChildOutlet(null);
    }
}