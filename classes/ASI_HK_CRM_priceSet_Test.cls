@isTest
public class ASI_HK_CRM_priceSet_Test {
    
    static testMethod void test_genPriceSet_2()
    {
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit.ASI_HK_CRM_Channel__c = 'Test Channel';
        insert acctCredit;
        
        Account acctCredit2 = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit2.parentId = acctCredit.Id;
        insert acctCredit2;
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');
        paf.ASI_HK_CRM_Adjusted_Start_Date__c = Date.today().addDays(+1);
        paf.ASI_HK_CRM_Adjusted_End_Date__c = Date.today().addDays(+2);
        paf.ASI_CRM_Approved_Date__c = Date.today().addDays(-5);
        Insert paf;
        
        ASI_MFM_Item_Group__c ig = new ASI_MFM_Item_Group__c();
        ig.Name = 'Test IG';
        ig.ASI_MFM_Item_Group_Code__c = 'Test Code';
        insert ig;
        
        ASI_MFM_SKU_Code__c sku = skuGenerator.generateBasicSKU(true);
        sku.ASI_MFM_Item_Group__c = ig.Id;
        sku.ASI_HK_CRM_Active__c = TRUE;
        sku.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU');
        sku.ASI_MFM_SKU_Code__c = 'Test Code';
        Insert sku;
        
        ASI_MFM_SKU_Code__c sku1 = skuGenerator.generateBasicSKU(true);
        sku1.ASI_MFM_Item_Group__c = ig.Id;
        sku1.ASI_HK_CRM_Active__c = TRUE;
        sku1.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU');
        Insert sku1;
        
        ASI_MFM_SKU_Code__c sku2 = skuGenerator.generateBasicSKU(true);
        sku2.ASI_MFM_Item_Group__c = ig.Id;
        sku2.ASI_HK_CRM_Active__c = TRUE;
        sku2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU');
        Insert sku2;
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech1 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech1.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC';
        Insert mech1;
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech2 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech2.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - Fixed Amount';
        Insert mech2;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku);
        pafline.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline.ASI_HK_CRM_Price__c = 200;
        pafline.ASI_HK_CRM_Mechanic__c = mech1.Id;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 12;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c = 10;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c = 1;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c = 8;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_3__c = 1;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c = 6;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_4__c = 1;
        pafline.ASI_HK_CRM_Investment_Value__c = 10;
        pafline.ASI_HK_CRM_Pre_Approval_Form_Lookup__c = paf.Id;
        pafline.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_FOC');
        insert pafline;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline2 = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku);
        pafline2.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline2.ASI_HK_CRM_Price__c = 200;
        pafline2.ASI_HK_CRM_Mechanic__c = mech2.Id;
        pafline2.ASI_HK_CRM_Fixed_Amount__c = 10;
        pafline2.ASI_HK_CRM_Investment_Value__c = 10;
        pafline2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_Fixed_Amount');
        insert pafline2;
        


        
        Test.startTest();
        
        ApexPages.CurrentPage().getparameters().put('id', paf.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(paf);
        ASI_CRM_HK_GenPriceSetController testGenPriceSet = new ASI_CRM_HK_GenPriceSetController(sc);
        testGenPriceSet.GenPriceSetForONEPAF();
        testGenPriceSet.ReturnPage();
        
        PageReference testPage = Page.ASI_CRM_HK_GenPriceSetPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('Referer','');
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_GenPriceSetController testController = new ASI_CRM_HK_GenPriceSetController();
        testController.init();

        testController.clearSearchResult();
        testController.clearSKUForm();
testController.GenPriceSet();
        testController.urgentBox = FALSE;
        testController.freeText = 'TEST';
        testController.selected_channel = 'Test Channel';
        testController.searchPAFObj.ASI_HK_CRM_PAF_Customer__c = acctCredit.Id;
        testController.searchPAFObj.ASI_CRM_HK_PAF_no__c = paf.Id;
        testController.searchPAFObj.ASI_HK_CRM_Adjusted_Start_Date__c = Date.today().addDays(+1);
        testController.searchPAFObj.ASI_HK_CRM_Adjusted_End_Date__c = Date.today().addDays(+2);
        testController.searchPAFObj.ASI_HK_CRM_SYS_Sales_Director_Approver__c = userinfo.getuserid();
        testController.searchPAF();
        ASI_CRM_HK_GenPriceSetController.ResultSet rs = new ASI_CRM_HK_GenPriceSetController.ResultSet();
        rs.PAF = paf;
        rs.checked = TRUE;
        testController.resultPAF.add(rs);
        testController.lineItemMethod();
        pafline.ASI_CRM_HK_Free_SKU__c = sku1.Id;
        update pafline;
        testController.GenPriceSet();
        testController.lineItemMethod();
        ASI_CRM_HK_GenPriceSetController.lineItemClass lic = new ASI_CRM_HK_GenPriceSetController.lineItemClass();
        lic.id = pafline.Id;
        lic.FreeSKU = pafline.ASI_CRM_HK_Free_SKU__c;
        lic.inventory = '10';
        List<ASI_CRM_HK_GenPriceSetController.lineItemClass> licList = new List<ASI_CRM_HK_GenPriceSetController.lineItemClass>();
        licList.add(lic);
        ASI_CRM_HK_GenPriceSetController.saveResult(licList);
        ASI_CRM_HK_GenPriceSetController.findCustSObjects('Account', 'ASI_HK_CRM_Outlet');
        ASI_CRM_HK_GenPriceSetController.findCustSObjects2('ASI_MFM_SKU_Code__c', 'ASI_HK_CRM_SKU');
        //testController.Cancel();
        
        Test.stopTest();
    }
    
    
    
    
    
    
    
    
    
    static testMethod void test_genPriceSet()
    {
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit.ASI_HK_CRM_Channel__c = 'Test Channel';
        insert acctCredit;
        
        Account acctCredit2 = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit2.parentId = acctCredit.Id;
        insert acctCredit2;
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');
        paf.ASI_HK_CRM_Adjusted_Start_Date__c = Date.today().addDays(+1);
        paf.ASI_HK_CRM_Adjusted_End_Date__c = Date.today().addDays(+2);
        paf.ASI_CRM_Approved_Date__c = Date.today().addDays(-5);
        Insert paf;
        
        ASI_MFM_Item_Group__c ig = new ASI_MFM_Item_Group__c();
        ig.Name = 'Test IG';
        insert ig;
        
        ASI_MFM_SKU_Code__c sku = skuGenerator.generateBasicSKU(true);
        sku.ASI_MFM_Item_Group__c = ig.Id;
        sku.ASI_HK_CRM_Active__c = TRUE;
        sku.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU');
        Insert sku;
        
        ASI_MFM_SKU_Code__c sku1 = skuGenerator.generateBasicSKU(true);
        sku1.ASI_MFM_Item_Group__c = ig.Id;
        sku1.ASI_HK_CRM_Active__c = TRUE;
        sku1.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU');
        Insert sku1;
        
        ASI_MFM_SKU_Code__c sku2 = skuGenerator.generateBasicSKU(true);
        sku2.ASI_MFM_Item_Group__c = ig.Id;
        sku2.ASI_HK_CRM_Active__c = TRUE;
        sku2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU');
        Insert sku2;
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech1 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech1.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC';
        Insert mech1;
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech2 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech2.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - Fixed Amount';
        Insert mech2;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku);
        pafline.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline.ASI_HK_CRM_Price__c = 200;
        pafline.ASI_HK_CRM_Mechanic__c = mech1.Id;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 12;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c = 10;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c = 1;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c = 8;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_3__c = 1;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c = 6;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_4__c = 1;
        pafline.ASI_HK_CRM_Investment_Value__c = 10;
        pafline.ASI_HK_CRM_Pre_Approval_Form_Lookup__c = paf.Id;
        pafline.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_FOC');
        insert pafline;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline2 = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku);
        pafline2.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline2.ASI_HK_CRM_Price__c = 200;
        pafline2.ASI_HK_CRM_Mechanic__c = mech2.Id;
        pafline2.ASI_HK_CRM_Fixed_Amount__c = 10;
        pafline2.ASI_HK_CRM_Investment_Value__c = 10;
        pafline2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_Fixed_Amount');
        insert pafline2;
        
        Test.startTest();
        
        ApexPages.CurrentPage().getparameters().put('id', paf.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(paf);
        ASI_CRM_HK_GenPriceSetController testGenPriceSet = new ASI_CRM_HK_GenPriceSetController(sc);
        testGenPriceSet.GenPriceSetForONEPAF();
        testGenPriceSet.ReturnPage();
        
        PageReference testPage = Page.ASI_CRM_HK_GenPriceSetPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('Referer','');
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_GenPriceSetController testController = new ASI_CRM_HK_GenPriceSetController();
        testController.init();
        testController.clearSearchResult();
        testController.clearSKUForm();
        testController.urgentBox = FALSE;
        testController.freeText = 'TEST';
        testController.selected_channel = 'Test Channel';
        testController.searchPAFObj.ASI_HK_CRM_PAF_Customer__c = acctCredit.Id;
        testController.searchPAFObj.ASI_CRM_HK_PAF_no__c = paf.Id;
        testController.searchPAFObj.ASI_HK_CRM_Adjusted_Start_Date__c = Date.today().addDays(+1);
        testController.searchPAFObj.ASI_HK_CRM_Adjusted_End_Date__c = Date.today().addDays(+2);
        testController.searchPAFObj.ASI_HK_CRM_SYS_Sales_Director_Approver__c = userinfo.getuserid();
        testController.searchPAF();
        ASI_CRM_HK_GenPriceSetController.ResultSet rs = new ASI_CRM_HK_GenPriceSetController.ResultSet();
        rs.PAF = paf;
        rs.checked = TRUE;
        testController.resultPAF.add(rs);
        testController.lineItemMethod();
        pafline.ASI_CRM_HK_Free_SKU__c = sku1.Id;
        update pafline;
        testController.GenPriceSet();
        ASI_CRM_HK_GenPriceSetController.lineItemClass lic = new ASI_CRM_HK_GenPriceSetController.lineItemClass();
        lic.id = pafline.Id;
        lic.FreeSKU = pafline.ASI_CRM_HK_Free_SKU__c;
        lic.inventory = '10';
        List<ASI_CRM_HK_GenPriceSetController.lineItemClass> licList = new List<ASI_CRM_HK_GenPriceSetController.lineItemClass>();
        licList.add(lic);
        ASI_CRM_HK_GenPriceSetController.saveResult(licList);
        ASI_CRM_HK_GenPriceSetController.findCustSObjects('Account', 'ASI_HK_CRM_Outlet');
        ASI_CRM_HK_GenPriceSetController.findCustSObjects2('ASI_MFM_SKU_Code__c', 'ASI_HK_CRM_SKU');
        //testController.Cancel();
        
        Test.stopTest();
    }
    
    static testMethod void test_exportCSV()
    {
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit.ASI_HK_CRM_Channel__c = 'Test Channel';
        acctCredit.Name = 'OUTLET_G';
        insert acctCredit;
        
        Account acctCredit2 = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit2.parentId = acctCredit.Id;
        insert acctCredit2;
        
        ASI_HK_CRM_Channel_Local_Channel_Map__c channel 
            = new ASI_HK_CRM_Channel_Local_Channel_Map__c(ASI_HK_CRM_Channel__c = 'Test Channel'
                                                          , ASI_HK_CRM_Local_Channel__c = 'F12 - Japanese Store'
                                                          , ASI_HK_CRM_Pricing_Channel__c = '1DL'
                                                          , ASI_CRM_Channel_Admin1__c = userInfo.getUserId());
        insert channel;
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');
        paf.ASI_HK_CRM_Adjusted_Start_Date__c = Date.today().addDays(+1);
        paf.ASI_HK_CRM_Adjusted_End_Date__c = Date.today().addDays(+2);
        paf.ASI_CRM_Short_Term_Promotion__c = TRUE;
        Insert paf;
        
        ASI_MFM_Item_Group__c ig = new ASI_MFM_Item_Group__c();
        ig.Name = 'Test IG';
        ig.ASI_MFM_Item_Group_Code__c = 'Test Code';
        insert ig;
        
        ASI_MFM_SKU_Code__c sku = skuGenerator.generateBasicSKU(true);
        sku.ASI_MFM_Item_Group__c = ig.Id;
        sku.ASI_HK_CRM_Active__c = TRUE;
        sku.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU');
        sku.ASI_MFM_SKU_Code__c = 'Test Code';
        Insert sku;
        
        ASI_MFM_SKU_Code__c sku1 = skuGenerator.generateBasicSKU(true);
        sku1.ASI_MFM_Item_Group__c = ig.Id;
        sku1.ASI_HK_CRM_Active__c = TRUE;
        sku1.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU');
        sku1.ASI_MFM_SKU_Code__c = 'Test Code1';
        Insert sku1;
        
        ASI_MFM_SKU_Code__c sku2 = skuGenerator.generateBasicSKU(true);
        sku2.ASI_MFM_Item_Group__c = ig.Id;
        sku2.ASI_HK_CRM_Active__c = TRUE;
        sku2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU');
        Insert sku2;
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech1 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech1.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC';
        mech1.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c = 'ABC';
        Insert mech1;
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech2 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech2.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - Fixed Amount';
        mech2.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c = 'ABC';
        Insert mech2;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku);
        pafline.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline.ASI_HK_CRM_Price__c = 200;
        pafline.ASI_HK_CRM_Mechanic__c = mech1.Id;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 2;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c = 2;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c = 1;
        pafline.ASI_HK_CRM_Investment_Value__c = 10;
        pafline.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_FOC');
        insert pafline;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline2 = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku1);
        pafline2.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline2.ASI_HK_CRM_Price__c = 200;
        pafline2.ASI_HK_CRM_Mechanic__c = mech1.Id;
        pafline2.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 2;
        pafline2.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1;
        pafline2.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c = 2;
        pafline2.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c = 1;
        pafline2.ASI_HK_CRM_Investment_Value__c = 10;
        pafline2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_FOC');
        insert pafline2;
        
        ASI_CRM_HK_Pre_Approval_Form_Customer__c pafCus = new ASI_CRM_HK_Pre_Approval_Form_Customer__c();
        pafCus.ASI_CRM_HK_Customer__c = acctCredit2.id;
        pafCus.ASI_CRM_HK_Pre_Approval_Form__c = paf.Id;
        pafCus.ASI_CRM_Generate_Price_Set__c = true;
        insert pafCus;
        
        ASI_CRM_Price_Set_Generation_Log__c ps = new ASI_CRM_Price_Set_Generation_Log__c();
        ps.ASI_CRM_Status__c = 'Draft';
        ps.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_Set_Generation_Log__cASI_CRM_HK_Price_Set');
        ps.ASI_CRM_Submission_Date__c = date.today();
        insert ps;
        
        ASI_CRM_Price_Set_Generation_Log_Detail__c psli = new ASI_CRM_Price_Set_Generation_Log_Detail__c();
        psli.ASI_CRM_Price_Set_Generation_Log__c = ps.Id;
        psli.ASI_CRM_Pre_Approval_Form__c = paf.Id;
        psli.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_Set_Generation_Log_Detail__cASI_CRM_HK_Price_Set_Item');
        insert psli;
        
        Test.startTest();
        
        ///PageReference testPage = Page.ASI_CRM_HK_exportCSVPage;
        ///Map<String, String> pageParams = testPage.getParameters();
        //Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_ExportCSVController testController = new ASI_CRM_HK_ExportCSVController();
        paf.ASI_HK_CRM_Adjusted_Start_Date__c = Date.today();
        paf.ASI_HK_CRM_Adjusted_End_Date__c = Date.today().addDays(+1);
        update paf;
        ASI_CRM_HK_ExportCSVController.PSLId = ps.Id;
        ASI_CRM_HK_ExportCSVController.BasePriceBySKU();
        ASI_CRM_HK_ExportCSVController.BasePriceByItemGP();
        ASI_CRM_HK_ExportCSVController.AdvPriceBySKU();
        ASI_CRM_HK_ExportCSVController.AdvPriceByItemGP();
        ASI_CRM_HK_ExportCSVController.PSSummaryByPAF();
        Test.stopTest();
    }
    
    static testMethod void test_exportCSV2()
    {
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit.ASI_HK_CRM_Channel__c = 'Test Channel';
        acctCredit.Name = 'OUTLET_G';
        insert acctCredit;
        
        Account acctCredit2 = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit2.parentId = acctCredit.Id;
        insert acctCredit2;
        
        ASI_HK_CRM_Channel_Local_Channel_Map__c channel 
            = new ASI_HK_CRM_Channel_Local_Channel_Map__c(ASI_HK_CRM_Channel__c = 'Test Channel'
                                                          , ASI_HK_CRM_Local_Channel__c = 'F12 - Japanese Store'
                                                          , ASI_HK_CRM_Pricing_Channel__c = '1DL'
                                                          , ASI_CRM_Channel_Admin1__c = userInfo.getUserId());
        insert channel;
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');
        paf.ASI_HK_CRM_Adjusted_Start_Date__c = Date.today().addDays(+1);
        paf.ASI_HK_CRM_Adjusted_End_Date__c = Date.today().addDays(+2);
        //paf.ASI_CRM_Short_Term_Promotion__c = TRUE;
        Insert paf;
        
        ASI_MFM_Item_Group__c ig = new ASI_MFM_Item_Group__c();
        ig.Name = 'Test IG';
        ig.ASI_MFM_Item_Group_Code__c = 'Test Code';
        insert ig;
        
        ASI_MFM_SKU_Code__c sku = skuGenerator.generateBasicSKU(true);
        sku.ASI_MFM_Item_Group__c = ig.Id;
        sku.ASI_HK_CRM_Active__c = TRUE;
        sku.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU');
        sku.ASI_MFM_SKU_Code__c = 'Test Code';
        Insert sku;
        
        ASI_MFM_SKU_Code__c sku1 = skuGenerator.generateBasicSKU(true);
        sku1.ASI_MFM_Item_Group__c = ig.Id;
        sku1.ASI_HK_CRM_Active__c = TRUE;
        sku1.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU');
        sku1.ASI_MFM_SKU_Code__c = 'Test Code1';
        Insert sku1;
        
        ASI_MFM_SKU_Code__c sku2 = skuGenerator.generateBasicSKU(true);
        sku2.ASI_MFM_Item_Group__c = ig.Id;
        sku2.ASI_HK_CRM_Active__c = TRUE;
        sku2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU');
        Insert sku2;
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech1 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech1.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC';
        mech1.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c = 'ABC';
        Insert mech1;
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech2 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech2.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - Fixed Amount';
        mech2.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c = 'ABC';
        Insert mech2;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku);
        pafline.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline.ASI_HK_CRM_Price__c = 200;
        pafline.ASI_HK_CRM_Mechanic__c = mech1.Id;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 2;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c = 2;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c = 1;
        pafline.ASI_HK_CRM_Investment_Value__c = 10;
        pafline.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_FOC');
        insert pafline;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline2 = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku1);
        pafline2.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline2.ASI_HK_CRM_Price__c = 200;
        pafline2.ASI_HK_CRM_Mechanic__c = mech1.Id;
        pafline2.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 2;
        pafline2.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1;
        pafline2.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c = 2;
        pafline2.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c = 1;
        pafline2.ASI_HK_CRM_Investment_Value__c = 10;
        pafline2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_FOC');
        insert pafline2;
        
        //ASI_CRM_HK_Pre_Approval_Form_Customer__c pafCus = new ASI_CRM_HK_Pre_Approval_Form_Customer__c();
        //pafCus.ASI_CRM_HK_Customer__c = acctCredit2.id;
        //pafCus.ASI_CRM_HK_Pre_Approval_Form__c = paf.Id;
        //pafCus.ASI_CRM_Generate_Price_Set__c = true;
        //insert pafCus;
        
        ASI_CRM_Price_Set_Generation_Log__c ps = new ASI_CRM_Price_Set_Generation_Log__c();
        ps.ASI_CRM_Status__c = 'Draft';
        ps.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_Set_Generation_Log__cASI_CRM_HK_Price_Set');
        ps.ASI_CRM_Submission_Date__c = date.today();
        insert ps;
        
        ASI_CRM_Price_Set_Generation_Log_Detail__c psli = new ASI_CRM_Price_Set_Generation_Log_Detail__c();
        psli.ASI_CRM_Price_Set_Generation_Log__c = ps.Id;
        psli.ASI_CRM_Pre_Approval_Form__c = paf.Id;
        psli.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_Set_Generation_Log_Detail__cASI_CRM_HK_Price_Set_Item');
        insert psli;
        
        Test.startTest();
        
        ///PageReference testPage = Page.ASI_CRM_HK_exportCSVPage;
        ///Map<String, String> pageParams = testPage.getParameters();
        //Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_ExportCSVController testController = new ASI_CRM_HK_ExportCSVController();
        paf.ASI_HK_CRM_Adjusted_Start_Date__c = Date.today();
        paf.ASI_HK_CRM_Adjusted_End_Date__c = Date.today().addDays(+1);
        update paf;
        ASI_CRM_HK_ExportCSVController.PSLId = ps.Id;
        ASI_CRM_HK_ExportCSVController.BasePriceBySKU();
        ASI_CRM_HK_ExportCSVController.BasePriceByItemGP();
        ASI_CRM_HK_ExportCSVController.AdvPriceBySKU();
        ASI_CRM_HK_ExportCSVController.AdvPriceByItemGP();
        ASI_CRM_HK_ExportCSVController.PSSummaryByPAF();
        Test.stopTest();
    }
    
    
    
    
    
    
    
    
    
    
    
    static testMethod void test_psTrigger()
    {
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit.ASI_HK_CRM_Channel__c = 'Test Channel';
        acctCredit.Name = 'OUTLET_G';
        insert acctCredit;
        
        ASI_HK_CRM_Channel_Local_Channel_Map__c channel 
            = new ASI_HK_CRM_Channel_Local_Channel_Map__c(ASI_HK_CRM_Channel__c = 'Test Channel'
                                                          , ASI_HK_CRM_Local_Channel__c = 'F12 - Japanese Store'
                                                          , ASI_HK_CRM_Pricing_Channel__c = '1DL'
                                                          , ASI_CRM_Channel_Admin1__c = userInfo.getUserId());
        insert channel;
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');
        paf.ASI_HK_CRM_Adjusted_Start_Date__c = Date.today().addDays(+1);
        paf.ASI_HK_CRM_Adjusted_End_Date__c = Date.today().addDays(+2);
        Insert paf;
        
        ASI_MFM_Item_Group__c ig = new ASI_MFM_Item_Group__c();
        ig.Name = 'Test IG';
        ig.ASI_MFM_Item_Group_Code__c = 'Test Code';
        insert ig;
        
        ASI_MFM_SKU_Code__c sku = skuGenerator.generateBasicSKU(true);
        sku.ASI_MFM_Item_Group__c = ig.Id;
        sku.ASI_HK_CRM_Active__c = TRUE;
        sku.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_HK_CRM_SKU');
        sku.ASI_MFM_SKU_Code__c = 'Test Code';
        Insert sku;
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech1 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech1.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - FOC';
        mech1.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c = 'ABC';
        Insert mech1;
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech2 = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech2.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - Fixed Amount';
        mech2.ASI_CRM_HK_Adjustment_Name_for_Cust_PAF__c = 'ABC';
        Insert mech2;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku);
        pafline.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline.ASI_HK_CRM_Price__c = 200;
        pafline.ASI_HK_CRM_Mechanic__c = mech1.Id;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 2;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1;
        pafline.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c = 2;
        pafline.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c = 1;
        pafline.ASI_HK_CRM_Investment_Value__c = 10;
        pafline.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_FOC');
        insert pafline;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline2 = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku);
        pafline2.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline2.ASI_HK_CRM_Price__c = 200;
        pafline2.ASI_HK_CRM_Mechanic__c = mech1.Id;
        pafline2.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 2;
        pafline2.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1;
        pafline2.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c = 2;
        pafline2.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c = 1;
        pafline2.ASI_HK_CRM_Investment_Value__c = 10;
        pafline2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_FOC');
        insert pafline2;
        
        ASI_CRM_Price_Set_Generation_Log__c ps = new ASI_CRM_Price_Set_Generation_Log__c();
        ps.ASI_CRM_Status__c = 'Draft';
        ps.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_Set_Generation_Log__cASI_CRM_HK_Price_Set');
        insert ps;
        
        ASI_CRM_Price_Set_Generation_Log__c ps2 = new ASI_CRM_Price_Set_Generation_Log__c();
        ps2.ASI_CRM_Status__c = 'Submitted';
        ps2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_Set_Generation_Log__cASI_CRM_HK_Price_Set');
        insert ps2;
        
        ASI_CRM_Price_Set_Generation_Log__c ps3 = new ASI_CRM_Price_Set_Generation_Log__c();
        ps3.ASI_CRM_Status__c = 'Approved';
        ps3.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_Set_Generation_Log__cASI_CRM_HK_Price_Set');
        insert ps3;
        
        ASI_CRM_Price_Set_Generation_Log_Detail__c psli = new ASI_CRM_Price_Set_Generation_Log_Detail__c();
        psli.ASI_CRM_Price_Set_Generation_Log__c = ps.Id;
        psli.ASI_CRM_Pre_Approval_Form__c = paf.Id;
        psli.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_Set_Generation_Log_Detail__cASI_CRM_HK_Price_Set_Item');
        insert psli;
        
        ASI_CRM_Price_Set_Generation_Log_Detail__c psli2 = new ASI_CRM_Price_Set_Generation_Log_Detail__c();
        psli2.ASI_CRM_Price_Set_Generation_Log__c = ps2.Id;
        psli2.ASI_CRM_Pre_Approval_Form__c = paf.Id;
        psli2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_Set_Generation_Log_Detail__cASI_CRM_HK_Price_Set_Item');
        insert psli2;
        
        ASI_CRM_Price_Set_Generation_Log_Detail__c psli3 = new ASI_CRM_Price_Set_Generation_Log_Detail__c();
        psli3.ASI_CRM_Price_Set_Generation_Log__c = ps3.Id;
        psli3.ASI_CRM_Pre_Approval_Form__c = paf.Id;
        psli3.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_Set_Generation_Log_Detail__cASI_CRM_HK_Price_Set_Item');
        insert psli3;
        
        Test.startTest();
        update psli;
        ps.ASI_CRM_Status__c = 'Submitted';
        update ps;
        ps.ASI_CRM_Status__c = 'Approved';
        update ps;
        ps.ASI_CRM_Status__c = 'Completed';
        update ps;
        ps2.ASI_CRM_Status__c = 'SA Rejected';
        update ps2;
        ps3.ASI_CRM_Status__c = 'Hub Rejected';
        update ps3;
        
        Test.stopTest();
    }
}