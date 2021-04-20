/*********************************************************************************
 * Name:ASI_HK_CRM_PAF_Test
 * Description: Test class for PAF
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
  * 20180918       	Wilken	         		[WL 1.0] Added code for coverage of ASI_HK_CRM_PreApprovalFormAssignApprover default date
*********************************************************************************/
@isTest
public class ASI_HK_CRM_PAF_Test
{
    static testMethod void test_pafPDF()
    {
        Test.startTest();
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        ASI_CRM_HK_FieldIdMapping__c setting 
            = new ASI_CRM_HK_FieldIdMapping__c(Name='ASI_CRM_HK_NewPAFFields'
                                               , ASI_CRM_Object_Short__c=''
                                               , ASI_CRM_Customer_Field_Id__c=''
                                               , ASI_CRM_RecordTypeId__c='');
        insert setting;
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        insert acctCredit;
        
        Account acctCredit2 = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit2.parentId = acctCredit.Id;
        insert acctCredit2;
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');
        paf.ASI_CRM_Short_Term_Promotion__c = TRUE;
		/*[WL 1.0] BEGIN*/
		paf.ASI_CRM_Ref_Start_Date__c = System.Today();
		paf.ASI_CRM_Ref_End_Date__c = System.Today();
		/*[WL 1.0] END*/
        Insert paf;
        
        ASI_MFM_SKU_Code__c sku = skuGenerator.generateBasicSKU(true);
        Insert sku;
        
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
        
        ASI_CRM_HK_PAF_Signature__c setting1 
            = new ASI_CRM_HK_PAF_Signature__c(Name='Signature person', ASI_CRM_HK_Signature_PersonId__c=userinfo.getuserid());
        insert setting1;
        
        ASI_CRM_HK_Pre_Approval_Form_Customer__c pafCus = new ASI_CRM_HK_Pre_Approval_Form_Customer__c();
        pafCus.ASI_CRM_HK_Customer__c = acctCredit2.id;
        pafCus.ASI_CRM_HK_Pre_Approval_Form__c = paf.Id;
        pafCus.ASI_CRM_HK_Download_Flag__c = TRUE;
        insert pafCus;
        
        ApexPages.StandardController stdSetController = new ApexPages.StandardController(paf);
        
        PageReference testPage = Page.ASI_CRM_HK_PAFContractPDF;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('paf_id', paf.id);
        pageParams.put('cus_id', acctCredit.id);
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_ContractPDFController testController = new ASI_CRM_HK_ContractPDFController(stdSetController);
        testController.PAFID = paf.id;
        testController.CusID = acctCredit.id;
        testController.init();
        Test.stopTest();
    }
    
    static testMethod void test_multiDLpaf()
    {
        Test.startTest();
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        insert acctCredit;
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');
        Insert paf;
        
        ASI_CRM_HK_Pre_Approval_Form_Customer__c pafCus = new ASI_CRM_HK_Pre_Approval_Form_Customer__c();
        pafCus.ASI_CRM_HK_Pre_Approval_Form__c = paf.Id;
        insert pafCus;
        
        ApexPages.StandardController stdSetController = new ApexPages.StandardController(paf);
        
        PageReference testPage = Page.ASI_CRM_HK_MultiPDFDownloadPage;
        Map<String, String> pageParams = testPage.getParameters();
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_MultiDownloadController testController = new ASI_CRM_HK_MultiDownloadController(stdSetController);
        testController.multiDownload();
        testController.multiDownloadBtn();
        testController.Cancel();
        Test.stopTest();
    }
    
    static testMethod void test_pafGenPO()
    {
        Test.startTest();
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        insert acctCredit;
        
        Account acctCredit2 = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit2.parentId = acctCredit.Id;
        insert acctCredit2;
        
        ASI_MFM_Prefix__c prefix = new ASI_MFM_Prefix__c();
        prefix.Name = 'Test prefix';
        prefix.ASI_MFM_Module__c = 'PO';
        prefix.ASI_MFM_Fiscal_year__c = getFiscalYear();
        insert prefix;
        
        ASI_MFM_Prefix__c prefix2 = new ASI_MFM_Prefix__c();
        prefix2.Name = 'Test prefix 2';
        prefix2.ASI_MFM_Module__c = 'PO';
        prefix2.ASI_MFM_Fiscal_year__c = getFiscalYear();
        insert prefix2;
        
        ASI_MFM_Role_Prefix_Relationship__c pxRelat = new ASI_MFM_Role_Prefix_Relationship__c();
        pxRelat.ASI_MFM_Prefix__c = prefix.Id;
        String roleName = [Select userRole.developerName From User Where Id =: userinfo.getuserid() limit 1].userRole.developerName;
        pxRelat.ASI_MFM_Role_Name__c = roleName;
        insert pxRelat;
        
        ASI_MFM_Role_Prefix_Relationship__c pxRelat2 = new ASI_MFM_Role_Prefix_Relationship__c();
        pxRelat2.ASI_MFM_Prefix__c = prefix2.Id;
        pxRelat2.ASI_MFM_Role_Name__c = roleName;
        insert pxRelat2;
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');
        paf.Name = 'Test PAF';
        paf.ASI_CRM_Short_Term_Promotion__c = TRUE;
        paf.ASI_HK_CRM_Adjusted_End_Date__c = Date.today().addDays(1);
        Insert paf;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c();
        po.ASI_MFM_Prefix__c = prefix.Id;
        po.ASI_MFM_PAF_Number__c = paf.Id;
        po.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_HK_PO');
        insert po;
        
        ASI_MFM_SKU_Code__c sku = skuGenerator.generateBasicSKU(true);
        Insert sku;
        
        ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech = new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c();
        mech.Name = 'Test mechanic';
        mech.ASI_HK_CRM_Mechanic_Type__c = 'PAF Item - Fixed Amount';
        Insert mech;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku);
        pafline.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline.ASI_HK_CRM_Price__c = 200;
        pafline.ASI_HK_CRM_Mechanic__c = mech.Id;
        pafline.ASI_HK_CRM_Fixed_Amount__c = 10;
        pafline.ASI_HK_CRM_Investment_Value__c = 10;
		pafline.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_Fixed_Amount');
        insert pafline;
        
        ASI_CRM_HK_Pre_Approval_Form_Customer__c pafCus = new ASI_CRM_HK_Pre_Approval_Form_Customer__c();
        pafCus.ASI_CRM_HK_Customer__c = acctCredit2.id;
        pafCus.ASI_CRM_HK_Pre_Approval_Form__c = paf.Id;
        insert pafCus;
        
        ApexPages.StandardController stdSetController = new ApexPages.StandardController(paf);
        
        PageReference testPage = Page.ASI_CRM_HK_PAFGenPOPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', paf.Id);
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_PAFGenPOController testController = new ASI_CRM_HK_PAFGenPOController(stdSetController);
        ASI_CRM_HK_PAFGenPOController.CustomSKUMechanicDetail tempCMD = testController.CustomSKUMechanicDetailsList[0];
        tempCMD.checked = TRUE;
        testController.SaveRecord();
        testController.Cancel();
        testController.getInvestmentValue(10,1,12,10);
        ASI_CRM_HK_PAFGenPOController.findSObjects('ASI_MFM_Plan__c','');
        ASI_CRM_HK_PAFGenPOController.findCustSObjects('Account','ASI_HK_CRM_Outlet');
        Test.stopTest();
    }
    
    static testMethod void test_pafCustomerE()
    {
        Test.startTest();
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit.Name = 'GG\'WP';
        acctCredit.ASI_HK_CRM_Channel__c = 'Test Channel';
        acctCredit.ASI_HK_CRM_Status__c = 'Active';
        insert acctCredit;
        
        Account acctCredit2 = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        acctCredit2.ASI_HK_CRM_Channel__c = 'Test Channel';
        acctCredit2.ASI_HK_CRM_Status__c = 'Active';
        acctCredit2.parentId = acctCredit.Id;
        insert acctCredit2;
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');
        paf.Name = 'Test PAF';
        paf.ASI_CRM_Short_Term_Promotion__c = TRUE;
        paf.ASI_HK_CRM_Adjusted_End_Date__c = Date.today().addDays(1);
        paf.ASI_HK_CRM_PAF_Status__c = 'Draft';
        Insert paf;
        
        ASI_CRM_HK_Pre_Approval_Form_Customer__c pafCus = new ASI_CRM_HK_Pre_Approval_Form_Customer__c();
        pafCus.ASI_CRM_HK_Customer__c = acctCredit2.id;
        pafCus.ASI_CRM_HK_Pre_Approval_Form__c = paf.Id;
        insert pafCus;
        
        ApexPages.StandardController stdSetController = new ApexPages.StandardController(paf);
        
        PageReference testPage = Page.ASI_CRM_HK_PAFCustomerEditPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', paf.Id);
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_PAFCustomerEditController testController = new ASI_CRM_HK_PAFCustomerEditController(stdSetController);
        testController.init();
        pageParams.put('PARAM_PORLine_ID', acctCredit2.Id);
        testController.removeLine();
        pageParams.put('PARAM_POLINE_SOURCE_ITEM_ID', acctCredit2.Id);
        testController.addLineItem();
        pageParams.put('PARAM_PORLine_ID', acctCredit2.Id);
        testController.RemoveSelectedLinetems();
        pageParams.put('PARAM_POLINE_SOURCE_ITEM_ID', acctCredit2.Id);
        testController.AddSelectedLinetems();
        testController.RemoveAllLinetems();
        testController.AddAllLinetems();
        testController.saveLinetems();
        testController.cancel();
        Test.stopTest();
    }
    
    static testMethod void test_kapafCompareCustomerBenchmark()
    {
        System.debug('ASI_HK_CRM_PAF_Test| test_kapafCompareCustomerBenchmark | Start');
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        Account acct1 = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Customer Account
        acct1.Name = 'Testing Account';
        acct1.ASI_HK_CRM_Channel__c = 'Test Channel';
        acct1.ASI_HK_CRM_Status__c = 'Active';
        acct1.ASI_HK_CRM_Customer_Type__c = '9CC Convenience Store Sales';
        insert acct1;
        
        ASI_MFM_SKU_Code__c sku = skuGenerator.generateBasicSKU(true);
        Insert sku;
        
        ASI_MFM_SKU_Code__c sku2 = skuGenerator.generateBasicSKU(true);
        Insert sku2;
        
		//Customer Benchmark PAF 1
        ASI_HK_CRM_Pre_Approval_Form__c pafBM1 = pafGenerator.generatePreApprovalForm(acct1, 'ASI_HK_Pre_Approval_Form');
        pafBM1.ASI_CRM_HK_Active__c = TRUE;
        pafBM1.ASI_CRM_HK_Is_Benchmark__c = TRUE;
        pafBM1.ASI_HK_CRM_PAF_Start_Date__c = Date.newInstance(2018, 1, 1);
        pafBM1.ASI_HK_CRM_PAF_End_Date__c = Date.newInstance(2049, 1, 1);
        pafBM1.ASI_HK_CRM_Adjusted_Start_Date__c = Date.newInstance(2018, 1, 1);
        pafBM1.ASI_HK_CRM_Adjusted_End_Date__c = Date.newInstance(2049, 1, 1);
        Insert pafBM1;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafBM1line = paflineGenerator.generateBasicPreApprovalFormItem(pafBM1,sku);
        pafBM1line.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafBM1line.ASI_HK_CRM_Price__c = 200;
        pafBM1line.ASI_HK_CRM_Fixed_Amount__c = 10;
        pafBM1line.ASI_HK_CRM_Investment_Value__c = 10;
        pafBM1line.ASI_HK_CRM_NNP__c = 100;
        pafBM1line.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_Fixed_Amount');
        insert pafBM1line;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafBM11ine2 = paflineGenerator.generateBasicPreApprovalFormItem(pafBM1,sku2);
        pafBM11ine2.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafBM11ine2.ASI_HK_CRM_Price__c = 200;
        pafBM11ine2.ASI_HK_CRM_Fixed_Amount__c = 10;
        pafBM11ine2.ASI_HK_CRM_Investment_Value__c = 10;
        pafBM11ine2.ASI_HK_CRM_NNP__c = 90;
        pafBM11ine2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_Fixed_Amount');
        insert pafBM11ine2;
        //End of Benchmark PAF 1
        
        Test.startTest();
        
        //KA PAF
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acct1, 'ASI_HK_Pre_Approval_Form');
        paf.ASI_CRM_HK_Active__c = TRUE;
        paf.ASI_HK_CRM_PAF_Start_Date__c = Date.newInstance(2018, 9, 1);
        paf.ASI_HK_CRM_PAF_End_Date__c = Date.newInstance(2018, 10, 31);
        paf.ASI_HK_CRM_Adjusted_Start_Date__c = Date.newInstance(2018, 9, 1);
        paf.ASI_HK_CRM_Adjusted_End_Date__c = Date.newInstance(2018, 10, 31);
        Insert paf;
        
        try{
            ASI_HK_CRM_Pre_Approval_Form_Item__c pafline = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku);
            pafline.ASI_HK_CRM_Target_Volume_Qty__c = 50;
            pafline.ASI_HK_CRM_Price__c = 200;
            pafline.ASI_HK_CRM_Fixed_Amount__c = 10;
            pafline.ASI_HK_CRM_Investment_Value__c = 10;
            pafline.ASI_HK_CRM_NNP__c = 110;
            pafline.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_Fixed_Amount');
            insert pafline;
            
            ASI_HK_CRM_Pre_Approval_Form_Item__c pafline2 = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku2);
            pafline2.ASI_HK_CRM_Target_Volume_Qty__c = 50;
            pafline2.ASI_HK_CRM_Price__c = 200;
            pafline2.ASI_HK_CRM_Fixed_Amount__c = 10;
            pafline2.ASI_HK_CRM_Investment_Value__c = 10;
            pafline2.ASI_HK_CRM_NNP__c = 85;
            pafline2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_Fixed_Amount');
            insert pafline2;
        } catch(Exception ex){
            System.debug(ex);
        }
		//KA PAF

        Test.stopTest();        
        System.debug('ASI_HK_CRM_PAF_Test| test_kapafCompareCustomerBenchmark | End');
    }
    
    static testMethod void test_kapafMultipleCustomerBenchmark()
    {
        System.debug('ASI_HK_CRM_PAF_Test| test_kapafMultipleCustomerBenchmark | Start');
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        Account acct1 = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Customer Account
        acct1.Name = 'Testing Account';
        acct1.ASI_HK_CRM_Channel__c = 'Test Channel';
        acct1.ASI_HK_CRM_Status__c = 'Active';
        acct1.ASI_HK_CRM_Customer_Type__c = '9CC Convenience Store Sales';
        insert acct1;
        
        ASI_MFM_SKU_Code__c sku2 = skuGenerator.generateBasicSKU(true);
        Insert sku2;
        
		//Customer Benchmark PAF 1
        ASI_HK_CRM_Pre_Approval_Form__c pafBM1 = pafGenerator.generatePreApprovalForm(acct1, 'ASI_HK_Pre_Approval_Form');
        pafBM1.ASI_CRM_HK_Active__c = TRUE;
        pafBM1.ASI_CRM_HK_Is_Benchmark__c = TRUE;
        pafBM1.ASI_HK_CRM_PAF_Start_Date__c = Date.newInstance(2018, 1, 1);
        pafBM1.ASI_HK_CRM_PAF_End_Date__c = Date.newInstance(2049, 1, 1);
        pafBM1.ASI_HK_CRM_Adjusted_Start_Date__c = Date.newInstance(2018, 1, 1);
        pafBM1.ASI_HK_CRM_Adjusted_End_Date__c = Date.newInstance(2049, 1, 1);
        Insert pafBM1;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafBM11ine2 = paflineGenerator.generateBasicPreApprovalFormItem(pafBM1,sku2);
        pafBM11ine2.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafBM11ine2.ASI_HK_CRM_Price__c = 200;
        pafBM11ine2.ASI_HK_CRM_Fixed_Amount__c = 10;
        pafBM11ine2.ASI_HK_CRM_Investment_Value__c = 10;
        pafBM11ine2.ASI_HK_CRM_NNP__c = 90;
        pafBM11ine2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_Fixed_Amount');
        insert pafBM11ine2;
        //End of Benchmark PAF 1

        //Customer Benchmark PAF 2
        ASI_HK_CRM_Pre_Approval_Form__c pafBM2 = pafGenerator.generatePreApprovalForm(acct1, 'ASI_HK_Pre_Approval_Form');
        pafBM2.ASI_CRM_HK_Active__c = TRUE;
        pafBM2.ASI_CRM_HK_Is_Benchmark__c = TRUE;
        pafBM2.ASI_HK_CRM_PAF_Start_Date__c = Date.newInstance(2018, 1, 1);
        pafBM2.ASI_HK_CRM_PAF_End_Date__c = Date.newInstance(2049, 1, 1);
        pafBM2.ASI_HK_CRM_Adjusted_Start_Date__c = Date.newInstance(2018, 1, 1);
        pafBM2.ASI_HK_CRM_Adjusted_End_Date__c = Date.newInstance(2049, 1, 1);
        Insert pafBM2;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafBM21ine = paflineGenerator.generateBasicPreApprovalFormItem(pafBM2,sku2);
        pafBM21ine.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafBM21ine.ASI_HK_CRM_Price__c = 200;
        pafBM21ine.ASI_HK_CRM_Fixed_Amount__c = 10;
        pafBM21ine.ASI_HK_CRM_Investment_Value__c = 10;
        pafBM21ine.ASI_HK_CRM_NNP__c = 80;
        pafBM21ine.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_Fixed_Amount');
        insert pafBM21ine;
        //Benchmark PAF 2
        
        Test.startTest();
        
        //KA PAF
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acct1, 'ASI_HK_Pre_Approval_Form');
        paf.ASI_CRM_HK_Active__c = TRUE;
        paf.ASI_HK_CRM_PAF_Start_Date__c = Date.newInstance(2018, 9, 1);
        paf.ASI_HK_CRM_PAF_End_Date__c = Date.newInstance(2018, 10, 31);
        paf.ASI_HK_CRM_Adjusted_Start_Date__c = Date.newInstance(2018, 9, 1);
        paf.ASI_HK_CRM_Adjusted_End_Date__c = Date.newInstance(2018, 10, 31);
        Insert paf;
        
        try{
            ASI_HK_CRM_Pre_Approval_Form_Item__c pafline2 = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku2);
            pafline2.ASI_HK_CRM_Target_Volume_Qty__c = 50;
            pafline2.ASI_HK_CRM_Price__c = 200;
            pafline2.ASI_HK_CRM_Fixed_Amount__c = 10;
            pafline2.ASI_HK_CRM_Investment_Value__c = 10;
            pafline2.ASI_HK_CRM_NNP__c = 85;
            pafline2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_Fixed_Amount');
            insert pafline2;
        } catch(Exception ex){
            System.debug(ex);
        }
        //KA PAF

        Test.stopTest();
        System.debug('ASI_HK_CRM_PAF_Test| test_kapafMultipleCustomerBenchmark | End');
    }
    
    static testMethod void test_kapafCompareChannelBenchmark()
    {
        System.debug('ASI_HK_CRM_PAF_Test| test_kapafCompareChannelBenchmark | Start');
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        Account acct1 = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Customer Account
        acct1.Name = 'Testing Account';
        acct1.ASI_HK_CRM_Channel__c = 'Test Channel';
        acct1.ASI_HK_CRM_Status__c = 'Active';
        acct1.ASI_HK_CRM_Customer_Type__c = '9CC Convenience Store Sales';
        insert acct1;
        
        Account acctChannel = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Channel Account
        acctChannel.Name = 'OUTLET_9CC Convenience Store (9901924128)';
        acctChannel.ASI_HK_CRM_Status__c = 'Active';
        insert acctChannel;
        
        ASI_MFM_SKU_Code__c sku3 = skuGenerator.generateBasicSKU(true);
        Insert sku3;
        
        //Channel Benchmark PAF
        ASI_HK_CRM_Pre_Approval_Form__c pafBM3 = pafGenerator.generatePreApprovalForm(acctChannel, 'ASI_HK_Pre_Approval_Form');
        pafBM3.ASI_CRM_HK_Active__c = TRUE;
        pafBM3.ASI_CRM_HK_Is_Benchmark__c = TRUE;
        pafBM3.ASI_HK_CRM_PAF_Start_Date__c = Date.newInstance(2018, 1, 1);
        pafBM3.ASI_HK_CRM_PAF_End_Date__c = Date.newInstance(2049, 1, 1);
        pafBM3.ASI_HK_CRM_Adjusted_Start_Date__c = Date.newInstance(2018, 1, 1);
        pafBM3.ASI_HK_CRM_Adjusted_End_Date__c = Date.newInstance(2049, 1, 1);
        Insert pafBM3;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafBM3line = paflineGenerator.generateBasicPreApprovalFormItem(pafBM3,sku3);
        pafBM3line.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafBM3line.ASI_HK_CRM_Price__c = 200;
        pafBM3line.ASI_HK_CRM_Fixed_Amount__c = 10;
        pafBM3line.ASI_HK_CRM_Investment_Value__c = 10;
        pafBM3line.ASI_HK_CRM_NNP__c = 70;
        pafBM3line.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_Fixed_Amount');
        insert pafBM3line;
        //Channel Benchmark PAF
        
        Test.startTest();
        //KA PAF
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acct1, 'ASI_HK_Pre_Approval_Form');
        paf.ASI_CRM_HK_Active__c = TRUE;
        paf.ASI_HK_CRM_PAF_Start_Date__c = Date.newInstance(2018, 9, 1);
        paf.ASI_HK_CRM_PAF_End_Date__c = Date.newInstance(2018, 10, 31);
        paf.ASI_HK_CRM_Adjusted_Start_Date__c = Date.newInstance(2018, 9, 1);
        paf.ASI_HK_CRM_Adjusted_End_Date__c = Date.newInstance(2018, 10, 31);
        Insert paf;
        
        try{
            ASI_HK_CRM_Pre_Approval_Form_Item__c pafline3 = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku3);
            pafline3.ASI_HK_CRM_Target_Volume_Qty__c = 50;
            pafline3.ASI_HK_CRM_Price__c = 200;
            pafline3.ASI_HK_CRM_Fixed_Amount__c = 10;
            pafline3.ASI_HK_CRM_Investment_Value__c = 10;
            pafline3.ASI_HK_CRM_NNP__c = 60;
            pafline3.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_Fixed_Amount');
            insert pafline3;
        } catch(Exception ex){
            System.debug(ex);
        }
        //KA PAF
        
        Test.stopTest();
        System.debug('ASI_HK_CRM_PAF_Test| test_kapafCompareChannelBenchmark | Start');
    }
    
    static testMethod void test_pafCompareTTGuideline()
    {
        System.debug('ASI_HK_CRM_PAF_Test| test_pafCompareTTGuideline | Start');
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_PreApprovalFormItemGenerator paflineGenerator = new ASI_HK_CRM_PreApprovalFormItemGenerator();
        ASI_HK_CRM_SKUGenerator skuGenerator = new ASI_HK_CRM_SKUGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        ASI_HK_CRM_TT_Guidelines__c ttg1 = new ASI_HK_CRM_TT_Guidelines__c(Name = 'TTG1', ASI_HK_CRM_Channel__c = 'Test Channel', ASI_HK_CRM_Outlet_Image__c = 'Testing Outlet Image', ASI_HK_CRM_Guideline__c = 50);
        Insert ttg1;
        
        Account acct1 = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Customer Account
        acct1.Name = 'Testing Account';
        acct1.ASI_HK_CRM_Channel__c = 'Test Channel';
        acct1.ASI_HK_CRM_Status__c = 'Active';
        acct1.ASI_HK_CRM_Customer_Type__c = '1CC Convenience Store Sales';
        insert acct1;
        
        ASI_CRM_AccountsAdditionalField__c cust1 = new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_HK_Outlet'),
            ASI_CRM_Account__c = acct1.Id, 
            ASI_CRM_HK_Outlet_Image__c = 'Testing Outlet Image',
            ASI_CRM_MY_GeoConverStatus__c = 'Completed');
        insert cust1;
        
        ASI_MFM_SKU_Code__c sku = skuGenerator.generateBasicSKU(true);
        Insert sku;
        
        Test.startTest();
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acct1, 'ASI_HK_Pre_Approval_Form');
        paf.ASI_CRM_HK_Active__c = TRUE;
        paf.ASI_HK_CRM_PAF_Start_Date__c = Date.newInstance(2018, 9, 1);
        paf.ASI_HK_CRM_PAF_End_Date__c = Date.newInstance(2018, 10, 31);
        paf.ASI_HK_CRM_Adjusted_Start_Date__c = Date.newInstance(2018, 9, 1);
        paf.ASI_HK_CRM_Adjusted_End_Date__c = Date.newInstance(2018, 10, 31);
        Insert paf;
        
        ASI_HK_CRM_Pre_Approval_Form_Item__c pafline2 = paflineGenerator.generateBasicPreApprovalFormItem(paf,sku);
        pafline2.ASI_HK_CRM_Target_Volume_Qty__c = 50;
        pafline2.ASI_HK_CRM_Price__c = 200;
        pafline2.ASI_HK_CRM_Fixed_Amount__c = 10;
        pafline2.ASI_HK_CRM_Investment_Value__c = 10;
        pafline2.ASI_HK_CRM_NNP__c = 85;
        pafline2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_HK_CRM_PAF_Item_Fixed_Amount');
        insert pafline2;
        
        Test.stopTest();
        
        System.debug('ASI_HK_CRM_PAF_Test| test_pafCompareTTGuidelin | End');
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