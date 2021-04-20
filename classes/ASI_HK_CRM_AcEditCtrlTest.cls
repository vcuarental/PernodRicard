@isTest
public class ASI_HK_CRM_AcEditCtrlTest
{
    //Added by Wilken 20160416, test account owner update
    static testMethod void test_acctOwnerChange()
    {
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        insert acctCredit;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='asi_hk_crm_account@pernod-ricard.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='asi_hk_crm_account@pernod-ricard.com');
        
        insert u;
        
        Test.startTest();
        acctCredit.ownerID = u.id;
        update acctCredit;
        Test.stopTest();
    }
    
    static testMethod void test_acEditPage()
    {
        Test.startTest();
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        
        Account acctPotential = acctGenerator.generateAccount('ASI_HK_CRM_Potential_Account');    //Credit Account
        insert acctPotential;
        
        ApexPages.StandardController stdSetController = new ApexPages.StandardController(acctPotential);
        
        PageReference testPage = Page.ASI_CRM_HK_AccountEditPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', acctPotential.id);
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_AccountEditController testController = new ASI_CRM_HK_AccountEditController(stdSetController);
        testController.save();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        insert acctCredit;
        
        ASI_CRM_AccountsAdditionalField__c customers 
            = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_Account__c = acctCredit.id, Name = acctCredit.Name
                                                     , ASI_CRM_CN_Phone_Number__c = '886', ASI_CRM_CN_Fax_Number__c = '888');
        customers.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_HK_Outlet');
        insert customers;
        
        ApexPages.StandardController stdSetController2 = new ApexPages.StandardController(acctCredit);
        
        PageReference testPage2 = Page.ASI_CRM_HK_AccountEditPage;
        Map<String, String> pageParams2 = testPage.getParameters();
        pageParams.put('id', acctCredit.id);
        Test.setCurrentPageReference(testPage2);
        
        ASI_CRM_HK_AccountEditController testController2 = new ASI_CRM_HK_AccountEditController(stdSetController2);
        testController2.save();
        
        Test.stopTest();
    }
    
    static testMethod void test_acPafEditPage()
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
        
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');        
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
        
        ApexPages.StandardController stdSetController = new ApexPages.StandardController(acctCredit);
        
        PageReference testPage = Page.ASI_CRM_HK_AccChannelPafRelatedListPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', acctCredit.id);
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_AccChannelRelatedListCtrl testController = new ASI_CRM_HK_AccChannelRelatedListCtrl(stdSetController);
        testController.newPAF();
        Test.stopTest();
    }
    
    static testMethod void test_acPoEditPage()
    {
        Test.startTest();
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
        
        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c(ASI_MFM_G_L_Date__c = date.today(),ASI_MFM_Base_Currency_Amount__c = 100000,ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,  ASI_MFM_Amount__c = 100,
                                                                     recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_HK_PO_Line_Item'));
        poLine.ASI_MFM_Customer_Name__c = acctCredit.Id;
        poLine.ASI_MFM_PO__c = po.Id;
        insert poLine;
        
        ApexPages.StandardController stdSetController = new ApexPages.StandardController(acctCredit);
        
        PageReference testPage = Page.ASI_CRM_HK_Account_RelatedListPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', acctCredit.id);
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_AccountRelatedListController testController = new ASI_CRM_HK_AccountRelatedListController(stdSetController);
        Test.stopTest();
    }
    
    private static ASI_HK_CRM_TestUtils.CommonData cmData;
    
    static {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
    }
    
    static testMethod void test_acSoEditPage()
    {
        Test.startTest();
        
        ASI_CRM_HK_FieldIdMapping__c settings = new ASI_CRM_HK_FieldIdMapping__c();
        settings.Name = 'ASI_CRM_HK_NewSOFields';
        insert settings;
        
        Account acctCredit = cmData.acctDAParent;
        
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Customer_DA__c = acctCredit.Id;
        
        ASI_HK_CRM_Sales_Order_Item__c soLine = new ASI_HK_CRM_Sales_Order_Item__c();
        soLine.ASI_HK_CRM_Sales_Order__c = so.Id;
        insert soLine;
        
        ApexPages.StandardController stdSetController = new ApexPages.StandardController(acctCredit);
        
        PageReference testPage = Page.ASI_CRM_HK_AccSalesOrderRelatedListPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', acctCredit.id);
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_HK_AccSalesOrderRelatedListCtrl testController = new ASI_CRM_HK_AccSalesOrderRelatedListCtrl(stdSetController);
        testController.NewSOHK();
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

}//end class