/**********************************************************************************
 * Name : ASI_MFM_CAP_EditSmallAmtPayment_CtrlTest
 * Created : DC @01/19/2016 8:28 AM
 * Revision History:
 * 1. 01/19/2016 - [DC 1.0] Created
 * 1. 01/27/2016 - [DC 1.1] Changed references to renamed class "ASI_MFM_CAP_EditSmallAmountPayment_Ctrl"
 * 1. 02/22/2016 - [DC 1.2] Changed test data creation to avoid Too Many SOQL exception.
 **********************************************************************************/

@isTest
private class ASI_MFM_CAP_EditSmallAmtPayment_CtrlTest {
    
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

    private static TestMethod void testConstructorAndInit() {

        user u = [SELECT userRole.developerName,
                         ASI_MFM_Country__c 
                    FROM user 
                   WHERE id = :userInfo.getUserId()];
        
        u.ASI_MFM_Country__c = 'HK';
        update u;
        
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(
            name='Plantest',
            ASI_MFM_Module__c='Plan',
            Plan_Type__c='CAPEX',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxp;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(
            name='POtest',
            ASI_MFM_Module__c='PO',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxo;
        
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(
            name='Paymenttest',
            ASI_MFM_Module__c='Payment',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxy;

        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxp.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr;
        
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxo.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr2;
        
        ASI_MFM_Role_Prefix_Relationship__c pr3 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxy.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr3;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), 
            ASI_MFM_Plan_Description__c='testPlanDescription',
            ASI_MFM_Plan_Name__c='testPlan',
            ASI_MFM_Start_Date__c=Date.today(),
            ASI_MFM_Status__c = 'Final',
            ASI_MFM_Prefix__c=pxp.id
        );
        insert p;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAC');
        insert ap;

        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
            name='testSubBrand',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand')
        );
        insert sub;
        
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),
            Name='Name3'
        );           
        acctList.add(acc1);
        
        Account acc2 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),
            Name='Name2'
        );           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Application__c='MFM',
            ASI_MFM_Base_Currency__c='USD',
            ASI_MFM_Counter_Currency__c='EUR',
            ASI_MFM_Country__c='HK', ASI_MFM_Effective_Date__c=date.today(),
            ASI_MFM_Exchange_Rate__c=1.34
        );
        insert xr;         
        
        
        ASI_MFM_Approval_Setting__c setting = new ASI_MFM_Approval_Setting__c(
            Name='HK', 
            ASI_MFM_Direct_Payment_Max_Allowed_Amt__c=1000, 
            ASI_MFM_Payment_Min_Approval_Amt__c=5000,
            ASI_MFM_Payment_Tolerance_Percent__c=10, 
            ASI_MFM_Payment_Tolerance_Amt__c=5000
        );
        insert setting;

        ASI_MFM_Default_Value__c mfmDefault = new ASI_MFM_Default_Value__c(
            Name = 'CAP_AP_Consulting_Code__c',
            ASI_MFM_Value__c = ap.Id,
            Country__c = 'HK'
        );
        insert mfmDefault;

        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl controllerInstance = 
            new ASI_MFM_CAP_EditSmallAmountPayment_Ctrl(); // DC 1.1

    }

    private static TestMethod void testConstructorAndInitWithoutPrefixes() {

        user u = [SELECT userRole.developerName,
                         ASI_MFM_Country__c 
                    FROM user 
                   WHERE id = :userInfo.getUserId()];
        
        u.ASI_MFM_Country__c = 'HK';
        update u;
        
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(
            name='Plantest',
            ASI_MFM_Module__c='Plan',
            Plan_Type__c='CAPEX',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxp;
        
        /*ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(
            name='POtest',
            ASI_MFM_Module__c='PO',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxo;
        
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(
            name='Paymenttest',
            ASI_MFM_Module__c='Payment',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxy;*/

        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxp.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr;
        
        /*ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxo.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr2;
        
        ASI_MFM_Role_Prefix_Relationship__c pr3 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxy.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr3;*/
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), 
            ASI_MFM_Plan_Description__c='testPlanDescription',
            ASI_MFM_Plan_Name__c='testPlan',
            ASI_MFM_Start_Date__c=Date.today(),
            ASI_MFM_Status__c = 'Final',
            ASI_MFM_Prefix__c=pxp.id
        );
        insert p;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAC');
        insert ap;

        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
            name='testSubBrand',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand')
        );
        insert sub;
        
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),
            Name='Name3'
        );           
        acctList.add(acc1);
        
        Account acc2 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),
            Name='Name2'
        );           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Application__c='MFM',
            ASI_MFM_Base_Currency__c='USD',
            ASI_MFM_Counter_Currency__c='EUR',
            ASI_MFM_Country__c='HK', ASI_MFM_Effective_Date__c=date.today(),
            ASI_MFM_Exchange_Rate__c=1.34
        );
        insert xr;         
        
        
        ASI_MFM_Approval_Setting__c setting = new ASI_MFM_Approval_Setting__c(
            Name='HK', 
            ASI_MFM_Direct_Payment_Max_Allowed_Amt__c=1000, 
            ASI_MFM_Payment_Min_Approval_Amt__c=5000,
            ASI_MFM_Payment_Tolerance_Percent__c=10, 
            ASI_MFM_Payment_Tolerance_Amt__c=5000
        );
        insert setting;

        ASI_MFM_Default_Value__c mfmDefault = new ASI_MFM_Default_Value__c(
            Name = 'CAP_AP_Consulting_Code__c',
            ASI_MFM_Value__c = ap.Id,
            Country__c = 'HK'
        );
        insert mfmDefault;

        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl controllerInstance = 
            new ASI_MFM_CAP_EditSmallAmountPayment_Ctrl(); // DC 1.1

    }

    private static TestMethod void testConstructorAndInitWithoutUserData() {

        user u = [SELECT userRole.developerName,
                         ASI_MFM_Country__c 
                    FROM user 
                   WHERE id = :userInfo.getUserId()];
        
        u.ASI_MFM_Country__c = NULL;
        update u;
        
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(
            name='Plantest',
            ASI_MFM_Module__c='Plan',
            Plan_Type__c='CAPEX',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxp;
        
        /*ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(
            name='POtest',
            ASI_MFM_Module__c='PO',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxo;
        
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(
            name='Paymenttest',
            ASI_MFM_Module__c='Payment',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxy;*/

        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxp.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr;
        
        /*ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxo.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr2;
        
        ASI_MFM_Role_Prefix_Relationship__c pr3 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxy.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr3;*/
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), 
            ASI_MFM_Plan_Description__c='testPlanDescription',
            ASI_MFM_Plan_Name__c='testPlan',
            ASI_MFM_Start_Date__c=Date.today(),
            ASI_MFM_Status__c = 'Final',
            ASI_MFM_Prefix__c=pxp.id
        );
        insert p;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAC');
        insert ap;

        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
            name='testSubBrand',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand')
        );
        insert sub;
        
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),
            Name='Name3'
        );           
        acctList.add(acc1);
        
        Account acc2 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),
            Name='Name2'
        );           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Application__c='MFM',
            ASI_MFM_Base_Currency__c='USD',
            ASI_MFM_Counter_Currency__c='EUR',
            ASI_MFM_Country__c='HK', ASI_MFM_Effective_Date__c=date.today(),
            ASI_MFM_Exchange_Rate__c=1.34
        );
        insert xr;         
        
        
        ASI_MFM_Approval_Setting__c setting = new ASI_MFM_Approval_Setting__c(
            Name='HK', 
            ASI_MFM_Direct_Payment_Max_Allowed_Amt__c=1000, 
            ASI_MFM_Payment_Min_Approval_Amt__c=5000,
            ASI_MFM_Payment_Tolerance_Percent__c=10, 
            ASI_MFM_Payment_Tolerance_Amt__c=5000
        );
        insert setting;

        ASI_MFM_Default_Value__c mfmDefault = new ASI_MFM_Default_Value__c(
            Name = 'CAP_AP_Consulting_Code__c',
            ASI_MFM_Value__c = ap.Id,
            Country__c = 'HK'
        );
        insert mfmDefault;

        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl controllerInstance = 
            new ASI_MFM_CAP_EditSmallAmountPayment_Ctrl(); // DC 1.1

    }

    private static TestMethod void testCreationMethodsNegative() {

        user u = [SELECT userRole.developerName,
                         ASI_MFM_Country__c 
                    FROM user 
                   WHERE id = :userInfo.getUserId()];
        
        u.ASI_MFM_Country__c = 'HK';
        update u;
        
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(
            name='Plantest',
            ASI_MFM_Module__c='Plan',
            Plan_Type__c='CAPEX',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxp;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(
            name='POtest',
            ASI_MFM_Module__c='PO',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxo;
        
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(
            name='Paymenttest',
            ASI_MFM_Module__c='Payment',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxy;

        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxp.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr;
        
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxo.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr2;
        
        ASI_MFM_Role_Prefix_Relationship__c pr3 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxy.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr3;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), 
            ASI_MFM_Plan_Description__c='testPlanDescription',
            ASI_MFM_Plan_Name__c='testPlan',
            ASI_MFM_Start_Date__c=Date.today(),
            ASI_MFM_Status__c = 'Final',
            ASI_MFM_Prefix__c=pxp.id,
            ASI_MFM_Plan_Type__c = 'CAPEX'
        );
        insert p;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAC');
        insert ap;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU'),
            ASI_MFM_OPEX__c = true
        );
        insert buCode;

        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
            name='testSubBrand',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand')
        );
        insert sub;
        
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),
            Name='Name3'
        );           
        acctList.add(acc1);
        
        Account acc2 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),
            Name='Name2'
        );           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Application__c='MFM',
            ASI_MFM_Base_Currency__c='USD',
            ASI_MFM_Counter_Currency__c='EUR',
            ASI_MFM_Country__c='HK', ASI_MFM_Effective_Date__c=date.today(),
            ASI_MFM_Exchange_Rate__c=1.34
        );
        insert xr;         
        
        
        ASI_MFM_Approval_Setting__c setting = new ASI_MFM_Approval_Setting__c(
            Name='HK', 
            ASI_MFM_Direct_Payment_Max_Allowed_Amt__c=1000, 
            ASI_MFM_Payment_Min_Approval_Amt__c=5000,
            ASI_MFM_Payment_Tolerance_Percent__c=10, 
            ASI_MFM_Payment_Tolerance_Amt__c=5000
        );
        insert setting;

        ASI_MFM_Default_Value__c mfmDefault = new ASI_MFM_Default_Value__c(
            Name = 'CAP_AP_Consulting_Code__c',
            ASI_MFM_Value__c = ap.Id,
            Country__c = 'HK'
        );
        insert mfmDefault;

        ASI_MFM_Country_Recordtype_Mapping__c recordMap = new ASI_MFM_Country_Recordtype_Mapping__c(
            Name = 'HK',
            Currency__c = 'HKD',
            ASI_MFM_Payment_LI_RT__c = 'CAP TW Payment Line Item',
            ASI_MFM_Payment_RT__c = 'CAP TW Payment',
            ASI_MFM_Plan_LI_RT__c = 'CAP TW Plan Line Item',
            ASI_MFM_Plan_RT__c = 'CAP TW Plan',
            PO_LI_RT__c = 'CAP TW PO Line Item',
            ASI_MFM_PO_RT__c = 'CAP TW PO',
            User_Country__c = 'HK'
        );
        insert recordMap;

        
        Test.setCurrentPage(Page.ASI_MFM_CAP_EditSmallAmountPayment_Page);

        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl controllerInstance = 
            new ASI_MFM_CAP_EditSmallAmountPayment_Ctrl(); // DC 1.1

        controllerInstance.getTypeItems();
        controllerInstance.getselectedType();
        controllerInstance.setselectedType(new List<String>{'CAPEX'});

        controllerInstance.LSAPHeader[0].po.ASI_MFM_Plan__c = p.id;
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Prefix__c = pxo.id;
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Supplier_Name__c = acc2.id ;
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Currency__c = 'EUR';
        controllerInstance.LSAPHeader[0].po.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO_Read_Only');
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Status__c = 'Final';
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Remarks__c = 'Auto created from direct payment';
        controllerInstance.LSAPHeader[0].po.ASI_MFM_PO_Start_Date__c = Date.today();
        controllerInstance.LSAPHeader[0].po.ASI_MFM_PO_End_Date__c = Date.today().addMonths(1);
        controllerInstance.LSAPHeader[0].type = 'CAPEX';
        
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Prefix__c = pxy.id;
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Plan__c = p.id;
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c = acc2.id  ;
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Currency__c = 'EUR';
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c = '12345';
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c = Date.today();
        controllerInstance.LSAPHeader[0].pay.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment_Read_Only');
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Status__c = 'Final';
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Remarks__c = 'Auto created from direct payment';
        controllerInstance.LSAPHeader[0].isTnE = false;
        
        controllerInstance.AddNew_SAPL();
        
        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl.SAPLineObj sapl_Clone = controllerInstance.SAPL_Item_Map.get(0); // DC 1.1
        sapl_Clone.pl = new ASI_MFM_Payment_Line_Item__c();
        sapl_Clone.pl.ASI_MFM_Payment_List_Item_Description__c = 'abcd';
        sapl_Clone.pl.ASI_MFM_Payment_Date__c = Date.today() ;
        sapl_Clone.pl.ASI_MFM_Payment_Amount__c = 50;
        
        sapl_Clone.pol= new ASI_MFM_PO_Line_Item__c();
        sapl_Clone.pol.ASI_MFM_Sub_brand_Code__c = sub.id ;
        //sapl_Clone.pol.ASI_MFM_Sub_brand_Allocation_Type__c = '';
        sapl_Clone.pol.ASI_MFM_AP_Code__c=ap.id;
        sapl_Clone.pol.ASI_MFM_BU_Code__c=buCode.id;
        sapl_Clone.pol.ASI_MFM_Customer_Name__c = acc1.id;
 //     controllerInstance.SAPL_Item_Map.put(0, sapl_Clone);
        
        controllerInstance.rowidSAPL = 0;
        controllerInstance.Clone_SAPL();
        controllerInstance.rowidSAPL = 1;
        controllerInstance.RemoveRow_SAPL();
        Test.StartTest();
        controllerInstance.SaveRecord();
        System.Test.stopTest();

    }

    private static TestMethod void testCreationMethodsPositive() {

        /* DC 1.2 start */
        user u = [SELECT userRole.developerName,
                         ASI_MFM_Country__c 
                    FROM user 
                   WHERE id = :userInfo.getUserId()];
        
        u.ASI_MFM_Country__c = 'HK';
        update u;
        
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(
            name='Plantest',
            ASI_MFM_Module__c='Plan',
            Plan_Type__c='CAPEX',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxp;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(
            name='POtest',
            ASI_MFM_Module__c='PO',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxo;
        
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(
            name='Paymenttest',
            ASI_MFM_Module__c='Payment',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxy;

        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxp.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr;
        
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxo.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr2;
        
        ASI_MFM_Role_Prefix_Relationship__c pr3 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxy.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr3;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), 
            ASI_MFM_Plan_Description__c='testPlanDescription',
            ASI_MFM_Plan_Name__c='testPlan',
            ASI_MFM_Start_Date__c=Date.today(),
            ASI_MFM_Status__c = 'Final',
            ASI_MFM_Prefix__c=pxp.id,
            ASI_MFM_Plan_Type__c = 'CAPEX'
        );
        insert p;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAC');
        insert ap;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU'),
            ASI_MFM_OPEX__c = true
        );
        insert buCode;

        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
            name='testSubBrand',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand')
        );
        insert sub;
        
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),
            Name='Name3'
        );           
        acctList.add(acc1);
        
        Account acc2 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),
            Name='Name2'
        );           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Application__c='MFM',
            ASI_MFM_Base_Currency__c='USD',
            ASI_MFM_Counter_Currency__c='EUR',
            ASI_MFM_Country__c='HK', ASI_MFM_Effective_Date__c=date.today(),
            ASI_MFM_Exchange_Rate__c=1.34
        );
        insert xr;         
        
        
        ASI_MFM_Approval_Setting__c setting = new ASI_MFM_Approval_Setting__c(
            Name='HK', 
            ASI_MFM_Direct_Payment_Max_Allowed_Amt__c=1000, 
            ASI_MFM_Payment_Min_Approval_Amt__c=5000,
            ASI_MFM_Payment_Tolerance_Percent__c=10, 
            ASI_MFM_Payment_Tolerance_Amt__c=5000
        );
        insert setting;

        ASI_MFM_Default_Value__c mfmDefault = new ASI_MFM_Default_Value__c(
            Name = 'CAP_AP_Consulting_Code__c',
            ASI_MFM_Value__c = ap.Id,
            Country__c = 'HK'
        );
        insert mfmDefault;

        ASI_MFM_Country_Recordtype_Mapping__c recordMap = new ASI_MFM_Country_Recordtype_Mapping__c(
            Name = 'HK',
            Currency__c = 'HKD',
            ASI_MFM_Payment_LI_RT__c = 'CAP TW Payment Line Item',
            ASI_MFM_Payment_RT__c = 'CAP TW Payment',
            ASI_MFM_Plan_LI_RT__c = 'CAP TW Plan Line Item',
            ASI_MFM_Plan_RT__c = 'CAP TW Plan',
            PO_LI_RT__c = 'CAP TW PO Line Item',
            ASI_MFM_PO_RT__c = 'CAP TW PO',
            User_Country__c = 'HK'
        );
        insert recordMap;
        /* DC 1.2 end */
        
        Test.setCurrentPage(Page.ASI_MFM_CAP_EditSmallAmountPayment_Page);

        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl controllerInstance = 
            new ASI_MFM_CAP_EditSmallAmountPayment_Ctrl(); // DC 1.1

        controllerInstance.getTypeItems();
        controllerInstance.getselectedType();
        controllerInstance.setselectedType(new List<String>{'CAPEX'});

        controllerInstance.LSAPHeader[0].po.ASI_MFM_Plan__c = p.id;
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Prefix__c = pxo.id;
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Supplier_Name__c = acc2.id ;
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Currency__c = 'EUR';
        controllerInstance.LSAPHeader[0].po.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO_Read_Only');
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Status__c = 'Final';
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Remarks__c = 'Auto created from direct payment';
        controllerInstance.LSAPHeader[0].po.ASI_MFM_PO_Start_Date__c = Date.today();
        controllerInstance.LSAPHeader[0].po.ASI_MFM_PO_End_Date__c = Date.today().addMonths(1);
        controllerInstance.LSAPHeader[0].type = 'CAPEX';
        
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Prefix__c = pxy.id;
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Plan__c = p.id;
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c = acc2.id  ;
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Currency__c = 'EUR';
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c = '12345';
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c = Date.today();
        controllerInstance.LSAPHeader[0].pay.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment_Read_Only');
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Status__c = 'Final';
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Remarks__c = 'Auto created from direct payment';
        controllerInstance.LSAPHeader[0].isTnE = false;
        
        controllerInstance.AddNew_SAPL();
        
        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl.SAPLineObj sapl_Clone = controllerInstance.SAPL_Item_Map.get(0); // DC 1.1
        sapl_Clone.pl = new ASI_MFM_Payment_Line_Item__c();
        sapl_Clone.pl.ASI_MFM_Payment_List_Item_Description__c = 'abcd';
        sapl_Clone.pl.ASI_MFM_Payment_Date__c = Date.today() ;
        sapl_Clone.pl.ASI_MFM_Payment_Amount__c = 50;
        
        sapl_Clone.pol= new ASI_MFM_PO_Line_Item__c();
        sapl_Clone.pol.ASI_MFM_Sub_brand_Code__c = sub.id ;
        //sapl_Clone.pol.ASI_MFM_Sub_brand_Allocation_Type__c = '';
        sapl_Clone.pol.ASI_MFM_AP_Code__c=ap.id;
        sapl_Clone.pol.ASI_MFM_BU_Code__c=buCode.id;
        sapl_Clone.pol.ASI_MFM_Customer_Name__c = acc1.id;
 //     controllerInstance.SAPL_Item_Map.put(0, sapl_Clone);
        
        controllerInstance.rowidSAPL = 0;
        controllerInstance.Clone_SAPL();
        controllerInstance.rowidSAPL = 1;
        controllerInstance.RemoveRow_SAPL();
        System.Test.StartTest();
        controllerInstance.SaveRecord();
        System.Test.stopTest();

    }

    private static TestMethod void testFindMethods() {

        user u = [SELECT userRole.developerName,
                         ASI_MFM_Country__c 
                    FROM user 
                   WHERE id = :userInfo.getUserId()];
        
        u.ASI_MFM_Country__c = 'HK';
        update u;
        
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(
            name='Plantest',
            ASI_MFM_Module__c='Plan',
            Plan_Type__c='CAPEX',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxp;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(
            name='POtest',
            ASI_MFM_Module__c='PO',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxo;
        
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(
            name='Paymenttest',
            ASI_MFM_Module__c='Payment',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxy;

        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxp.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr;
        
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxo.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr2;
        
        ASI_MFM_Role_Prefix_Relationship__c pr3 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxy.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr3;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), 
            ASI_MFM_Plan_Description__c='testPlanDescription',
            ASI_MFM_Plan_Name__c='testPlan',
            ASI_MFM_Start_Date__c=Date.today(),
            ASI_MFM_Status__c = 'Final',
            ASI_MFM_Prefix__c=pxp.id
        );
        insert p;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAC');
        insert ap;

        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
            name='testSubBrand',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand')
        );
        insert sub;
        
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),
            Name='Name3'
        );           
        acctList.add(acc1);
        
        Account acc2 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),
            Name='Name2'
        );           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Application__c='MFM',
            ASI_MFM_Base_Currency__c='USD',
            ASI_MFM_Counter_Currency__c='EUR',
            ASI_MFM_Country__c='HK', ASI_MFM_Effective_Date__c=date.today(),
            ASI_MFM_Exchange_Rate__c=1.34
        );
        insert xr;         
        
        
        ASI_MFM_Approval_Setting__c setting = new ASI_MFM_Approval_Setting__c(
            Name='HK', 
            ASI_MFM_Direct_Payment_Max_Allowed_Amt__c=1000, 
            ASI_MFM_Payment_Min_Approval_Amt__c=5000,
            ASI_MFM_Payment_Tolerance_Percent__c=10, 
            ASI_MFM_Payment_Tolerance_Amt__c=5000
        );
        insert setting;

        ASI_MFM_Default_Value__c mfmDefault = new ASI_MFM_Default_Value__c(
            Name = 'CAP_AP_Consulting_Code__c',
            ASI_MFM_Value__c = ap.Id,
            Country__c = 'HK'
        );
        insert mfmDefault;

        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl controllerInstance = 
            new ASI_MFM_CAP_EditSmallAmountPayment_Ctrl(); // DC 1.1

        Test.setCurrentPage(Page.ASI_MFM_CAP_EditSmallAmountPayment_Page);
        ApexPages.currentPage().getHeaders().put('Referer','https://test.url.com');

        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl.findSObjects('ASI_MFM_Plan__c', ''); // DC 1.1
        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl.findCustSObjects('account', 'ASI_GF_Customer'); // DC 1.1

        controllerInstance.cancel();

    }

    private static TestMethod void testCreationMethodsNonFinalPlan() {

        user u = [SELECT userRole.developerName,
                         ASI_MFM_Country__c 
                    FROM user 
                   WHERE id = :userInfo.getUserId()];
        
        u.ASI_MFM_Country__c = 'HK';
        update u;
        
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(
            name='Plantest',
            ASI_MFM_Module__c='Plan',
            Plan_Type__c='CAPEX',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxp;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(
            name='POtest',
            ASI_MFM_Module__c='PO',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxo;
        
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(
            name='Paymenttest',
            ASI_MFM_Module__c='Payment',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert pxy;

        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxp.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr;
        
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxo.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr2;
        
        ASI_MFM_Role_Prefix_Relationship__c pr3 = new ASI_MFM_Role_Prefix_Relationship__c(
            ASI_MFM_Prefix__c=pxy.id,
            ASI_MFM_Role_Name__c=u.userRole.developerName
        );
        insert pr3;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
            name='test',
            ASI_MFM_End_Date__c=Date.today().addMonths(1), 
            ASI_MFM_Plan_Description__c='testPlanDescription',
            ASI_MFM_Plan_Name__c='testPlan',
            ASI_MFM_Start_Date__c=Date.today(),
            ASI_MFM_Status__c = 'Draft',
            ASI_MFM_Prefix__c=pxp.id,
            ASI_MFM_Plan_Type__c = 'CAPEX'
        );
        insert p;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAC');
        insert ap;

        ASI_MFM_BU__c buCode = new ASI_MFM_BU__c(
            Name='testBUCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_CAP_BU')
        );
        insert buCode;

        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
            name='testSubBrand',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_HK_CRM_Sub_brand')
        );
        insert sub;
        
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),
            Name='Name3'
        );           
        acctList.add(acc1);
        
        Account acc2 = new Account(
            recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),
            Name='Name2'
        );           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(
            ASI_MFM_Application__c='MFM',
            ASI_MFM_Base_Currency__c='USD',
            ASI_MFM_Counter_Currency__c='EUR',
            ASI_MFM_Country__c='HK', ASI_MFM_Effective_Date__c=date.today(),
            ASI_MFM_Exchange_Rate__c=1.34
        );
        insert xr;         
        
        
        ASI_MFM_Approval_Setting__c setting = new ASI_MFM_Approval_Setting__c(
            Name='HK', 
            ASI_MFM_Direct_Payment_Max_Allowed_Amt__c=1000, 
            ASI_MFM_Payment_Min_Approval_Amt__c=5000,
            ASI_MFM_Payment_Tolerance_Percent__c=10, 
            ASI_MFM_Payment_Tolerance_Amt__c=5000
        );
        insert setting;

        ASI_MFM_Default_Value__c mfmDefault = new ASI_MFM_Default_Value__c(
            Name = 'CAP_AP_Consulting_Code__c',
            ASI_MFM_Value__c = ap.Id,
            Country__c = 'HK'
        );
        insert mfmDefault;

        ASI_MFM_Country_Recordtype_Mapping__c recordMap = new ASI_MFM_Country_Recordtype_Mapping__c(
            Name = 'HK',
            Currency__c = 'HKD',
            ASI_MFM_Payment_LI_RT__c = 'CAP TW Payment Line Item',
            ASI_MFM_Payment_RT__c = 'CAP TW Payment',
            ASI_MFM_Plan_LI_RT__c = 'CAP TW Plan Line Item',
            ASI_MFM_Plan_RT__c = 'CAP TW Plan',
            PO_LI_RT__c = 'CAP TW PO Line Item',
            ASI_MFM_PO_RT__c = 'CAP TW PO',
            User_Country__c = 'HK'
        );
        insert recordMap;

        
        Test.setCurrentPage(Page.ASI_MFM_CAP_EditSmallAmountPayment_Page);

        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl controllerInstance = 
            new ASI_MFM_CAP_EditSmallAmountPayment_Ctrl(); // DC 1.1

        controllerInstance.getTypeItems();
        controllerInstance.getselectedType();
        controllerInstance.setselectedType(new List<String>{'CAPEX'});

        controllerInstance.LSAPHeader[0].po.ASI_MFM_Plan__c = p.id;
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Prefix__c = pxo.id;
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Supplier_Name__c = acc2.id ;
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Currency__c = 'EUR';
        controllerInstance.LSAPHeader[0].po.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO_Read_Only');
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Status__c = 'Final';
        controllerInstance.LSAPHeader[0].po.ASI_MFM_Remarks__c = 'Auto created from direct payment';
        controllerInstance.LSAPHeader[0].po.ASI_MFM_PO_Start_Date__c = Date.today();
        controllerInstance.LSAPHeader[0].po.ASI_MFM_PO_End_Date__c = Date.today().addMonths(1);
        controllerInstance.LSAPHeader[0].type = 'CAPEX';
        
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Prefix__c = pxy.id;
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Plan__c = p.id;
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c = acc2.id  ;
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Currency__c = 'EUR';
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c = '12345';
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c = Date.today();
        controllerInstance.LSAPHeader[0].pay.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment_Read_Only');
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Status__c = 'Final';
        controllerInstance.LSAPHeader[0].pay.ASI_MFM_Remarks__c = 'Auto created from direct payment';
        controllerInstance.LSAPHeader[0].isTnE = false;
        
        controllerInstance.AddNew_SAPL();
        
        ASI_MFM_CAP_EditSmallAmountPayment_Ctrl.SAPLineObj sapl_Clone = controllerInstance.SAPL_Item_Map.get(0); // DC 1.1
        sapl_Clone.pl = new ASI_MFM_Payment_Line_Item__c();
        sapl_Clone.pl.ASI_MFM_Payment_List_Item_Description__c = 'abcd';
        sapl_Clone.pl.ASI_MFM_Payment_Date__c = Date.today() ;
        sapl_Clone.pl.ASI_MFM_Payment_Amount__c = 50;
        
        sapl_Clone.pol= new ASI_MFM_PO_Line_Item__c();
        sapl_Clone.pol.ASI_MFM_Sub_brand_Code__c = sub.id ;
        //sapl_Clone.pol.ASI_MFM_Sub_brand_Allocation_Type__c = '';
        sapl_Clone.pol.ASI_MFM_AP_Code__c=ap.id;
        sapl_Clone.pol.ASI_MFM_BU_Code__c=buCode.id;
        sapl_Clone.pol.ASI_MFM_Customer_Name__c = acc1.id;
 //     controllerInstance.SAPL_Item_Map.put(0, sapl_Clone);
        
        controllerInstance.rowidSAPL = 0;
        controllerInstance.Clone_SAPL();
        controllerInstance.rowidSAPL = 1;
        controllerInstance.RemoveRow_SAPL();
        Test.StartTest();
        controllerInstance.SaveRecord();
        System.Test.stopTest();

    }
}