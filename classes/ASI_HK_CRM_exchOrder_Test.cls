@isTest
public class ASI_HK_CRM_exchOrder_Test {
    static testMethod void test_exOEdirPage(){
        
        ASI_HK_CRM_TestUtils.CommonData cmData;
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        
        Account acctCredit = cmData.acctDAParent;
        
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_JDE_Order_No__c = 'Test JDE';
        update so;
        
        Test.startTest();
        
        ASI_HK_CRM_Sales_Order_History__c soh = new ASI_HK_CRM_Sales_Order_History__c();
        soh.ASI_HK_CRM_Account_PA__c = acctCredit.Id;
        soh.ASI_HK_CRM_Order_No__c = 'Test JDE';
        soh.ASI_HK_CRM_Order_Date__c = Date.today().addMonths(-1);
        insert soh;
        
        ASI_HK_CRM_Sales_Order_History_Detail__c sohi = new ASI_HK_CRM_Sales_Order_History_Detail__c();
        sohi.ASI_HK_CRM_Sales_Order_History__c = soh.Id;
        sohi.ASI_HK_CRM_Quantity_in_Bottles__c = 1;
        sohi.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Sales_Order_History_Detail__cASI_HK_CRM_Sales_Order_History_Detail');
        insert sohi;
        
        ASI_HK_CRM_Sales_Order_History_Detail__c sohi2 = new ASI_HK_CRM_Sales_Order_History_Detail__c();
        sohi2.ASI_HK_CRM_Sales_Order_History__c = soh.Id;
        sohi2.ASI_HK_CRM_Quantity_in_Bottles__c = 1;
        sohi2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Sales_Order_History_Detail__cASI_HK_CRM_Sales_Order_History_Detail');
        insert sohi2;
        
        ASI_CRM_Exchange_Order__c exO = new ASI_CRM_Exchange_Order__c();
        exO.ASI_CRM_Collection_Date__c = Date.today();
        exO.ASI_CRM_Collection_Time__c = '08:00';
        exO.ASI_CRM_Customer__c = acctCredit.Id;
        exO.ASI_CRM_Reasons__c = 'Test Reason';
        exO.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Exchange_Order__cASI_CRM_HK_Exchange_Order');
        insert exO;
        
        ASI_CRM_Exchange_Order_Item__c exOline = new ASI_CRM_Exchange_Order_Item__c();
        exOline.ASI_CRM_Sales_Order_History_Detail__c = sohi.Id;
        exOline.ASI_CRM_Exchange_Order__c = exO.Id;
        exOline.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Exchange_Order_Item__cASI_CRM_HK_Exchange_Order_Item');
        insert exOline;
        
        ApexPages.StandardController stdSetController = new ApexPages.StandardController(exO);
        
        PageReference testPage = Page.ASI_CRM_HK_ExchangeOrderEditPage;
        Map<String, String> pageParams = testPage.getParameters();
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_ExchangeOrderEditController testController = new ASI_CRM_HK_ExchangeOrderEditController(stdSetController);
        testController.init();
        testController.search();
        ASI_CRM_HK_ExchangeOrderEditController.findSObjects('ASI_MFM_SKU_Code__c','ASI_HK_CRM_SKU');
        pageParams.put('PARAM_PORLine_ID', sohi.Id);
        testController.removeLine();
        pageParams.put('PARAM_POLINE_SOURCE_ITEM_ID', sohi.Id);
        testController.addLineItem();
        pageParams.put('PARAM_PORLine_ID', sohi.Id);
        testController.RemoveSelectedLinetems();
        pageParams.put('PARAM_POLINE_SOURCE_ITEM_ID', sohi.Id);
        testController.AddSelectedLinetems();
        testController.RemoveAllLinetems();
        testController.AddAllLinetems();
        testController.saveLinetems();
        testController.cancel();
        Test.stopTest();
    }
    
    static testMethod void test_exOpdf(){
        
        Test.startTest();
        
        ASI_CRM_Exchange_Order__c exO = new ASI_CRM_Exchange_Order__c();
        exO.ASI_CRM_Collection_Date__c = Date.today();
        exO.ASI_CRM_Collection_Time__c = '08:00';
        exO.ASI_CRM_Reasons__c = 'Test Reason';
        exO.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Exchange_Order__cASI_CRM_HK_Exchange_Order');
        insert exO;
        
        ASI_CRM_Exchange_Order_Item__c exOline = new ASI_CRM_Exchange_Order_Item__c();
        exOline.ASI_CRM_Exchange_Order__c = exO.Id;
        exOline.ASI_CRM_Type__c = 'Return';
        exOline.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Exchange_Order_Item__cASI_CRM_HK_Exchange_Order_Item');
        insert exOline;
        
        ASI_CRM_Exchange_Order_Item__c exOline2 = new ASI_CRM_Exchange_Order_Item__c();
        exOline2.ASI_CRM_Exchange_Order__c = exO.Id;
        exOline2.ASI_CRM_Type__c = 'Exchange';
        exOline2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Exchange_Order_Item__cASI_CRM_HK_Exchange_Order_Item');
        insert exOline2;
        
        ApexPages.StandardController stdSetController = new ApexPages.StandardController(exO);
        
        PageReference testPage = Page.ASI_CRM_HK_exchangeOrderPDF;
        Map<String, String> pageParams = testPage.getParameters();
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_exchangeOrderPDFController testController = new ASI_CRM_HK_exchangeOrderPDFController(stdSetController);
        testController.currentHeaderId = exO.Id;
        testController.init();
        Test.stopTest();
    }
    
    static testMethod void test_soCloneBtn(){
        ASI_HK_CRM_TestUtils.CommonData cmData;
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        
        Account acctCredit = cmData.acctDAParent;
        
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        
        Test.startTest();
        ApexPages.StandardController stdSetController = new ApexPages.StandardController(so);
        
        PageReference testPage = Page.ASI_CRM_HK_SObtnPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', so.Id);
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_SOClonebtnController testController = new ASI_CRM_HK_SOClonebtnController(stdSetController);
        testController.cloneSO();
        Test.stopTest();
    }
    
    static testMethod void test_freeGds(){
        
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        insert acctCredit;
        
        ASI_MFM_Prefix__c prefix = new ASI_MFM_Prefix__c();
        prefix.Name = 'Test prefix';
        prefix.ASI_MFM_Module__c = 'PO';
        prefix.ASI_MFM_Fiscal_year__c = getFiscalYear();
        insert prefix;
        
        ASI_MFM_Role_Prefix_Relationship__c pxRelat = new ASI_MFM_Role_Prefix_Relationship__c();
        pxRelat.ASI_MFM_Prefix__c = prefix.Id;
        String roleName = [Select userRole.developerName From User Where Id =: userinfo.getuserid() limit 1].userRole.developerName;
        pxRelat.ASI_MFM_Role_Name__c = roleName;
        insert pxRelat;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c();
        po.ASI_MFM_Prefix__c = prefix.Id;
        po.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO');
        insert po;
        
        Test.startTest();
        
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
        customer.ASI_CRM_Account__c = acctCredit.Id;
        customer.ASI_CRM_CN_Phone_Number__c = '1';
        customer.ASI_CRM_CN_Fax_Number__c = '2';
        customer.ASI_HK_CRM_Delivery_Window_Instruction__c = 'Between';
        customer.ASI_HK_CRM_Delivery_Time_1__c = 'B';
        customer.ASI_HK_CRM_Delivery_Time_2__c = 'C';
        customer.ASI_HK_CRM_Instruction_txt__c = 'D';
        customer.ASI_HK_CRM_Attention__c = 'E';
        customer.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_HK_Outlet');
        insert customer;
        
        
        ASI_FOC_Free_Goods_Request__c foc = new ASI_FOC_Free_Goods_Request__c();
        foc.recordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Sales');
        foc.ASI_FOC_Date_of_Delivery__c = Date.today().addDays(+1);
        foc.ASI_FOC_MFM_Consumer_AP_PO_Number__c = po.Id;
        foc.ASI_FOC_Account_DA__c = acctCredit.Id;
        insert foc;
        
        ASI_FOC_Free_Goods_Request__c foc2 = new ASI_FOC_Free_Goods_Request__c();
        foc2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Sales_Admin');
        foc2.ASI_FOC_Date_of_Delivery__c = Date.today();
        foc2.ASI_FOC_Urgent_Order__c = TRUE;
        foc2.ASI_FOC_MFM_Consumer_AP_PO_Number__c = po.Id;
        foc2.ASI_FOC_Account_DA__c = acctCredit.Id;
        insert foc2;
        
        ASI_FOC_Free_Goods_Request__c foc3 = new ASI_FOC_Free_Goods_Request__c();
        foc3.recordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_HK_Free_Goods_Request_Approval');
        foc3.ASI_FOC_Date_of_Delivery__c = Date.today().addDays(+1);
        foc3.ASI_FOC_MFM_Consumer_AP_PO_Number__c = po.Id;
        foc3.ASI_FOC_Account_DA__c = acctCredit.Id;
        insert foc3;
        
        Test.stopTest();
    }
    
    private static string getFiscalYear(){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1;
        Integer yearA2 = Integer.valueOf(yearA1) +1;
        String Current_Fiscal_year;

        if(system.today()< orgFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }
        
        return Current_Fiscal_year;
    }
}