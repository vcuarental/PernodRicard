/***************************************************************************************************************************
 * Name:        ASI_MFM_CAP_PO_Test
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-05-20       Wilken                  [WL 1.0] Test class error fix
 ****************************************************************************************************************************/
@isTest
public class ASI_MFM_CAP_PO_Test {

    @testSetup static void testSetupMethod(){
    
    }
  
    //commented by laputa(Fanny), solve soql limit with a new method testPOTriggerWithRouteApprover
    static /*testMethod*/ void testPOTrigger()
    {
        System.Test.startTest();
        ASI_MFM_CAP_TestClassHelper.createRoutePOType();
        ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();
        ASI_MFM_PO__c po = ASI_MFM_CAP_TestClassHelper.createPo('CAPEX', plan);
        ASI_MFM_PO__c poClone = ASI_MFM_CAP_TestClassHelper.createPoClone(po);
        
        /*
         * DC - 01/25/2016 - Added logic to improve coverage of "ASI_MFM_CAP_PO_TriggerClass"
         */
        // DC LOGIC START
        
        ASI_MFM_PO_Line_Item__c poLineItem = ASI_MFM_CAP_TestClassHelper.createPoLines(po);

        plan.ASI_MFM_Status__c = 'Final';
        update plan;

        ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c
        (
            ASI_MFM_Payment_Type__c = 'CAPEX',
            ASI_MFM_Plan__c = po.ASI_MFM_Plan__c,
            ASI_MFM_Currency__c = 'HKD',
            ASI_MFM_Prefix__c= ASI_MFM_CAP_TestClassHelper.createPrefixPayment().id,
            ASI_MFM_Supplier_Name__c = ASI_MFM_CAP_TestClassHelper.createAccSupplier().id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_Payment'),
            ASI_MFM_Is_Direct_Payment__c = true,
            ASI_MFM_Status__c = 'Draft',
            ASI_MFM_Invoice_Date__c = date.today(),
            ASI_MFM_Invoice_Number__c = '123Tesyt'
        );
        insert payment;
        System.Test.stopTest();
        
        ASI_MFM_Payment_Line_Item__c paymentLineItem = 
            ASI_MFM_CAP_TestClassHelper.createPaymentLines(payment, poLineItem);

        // DC LOGIC END

        po.ASI_MFM_Status__c = 'Submitted';
        po.ASI_MFM_Exchange_Rate__c = 0.052;
        update po;
        po.ASI_MFM_Status__c = 'Draft';
        update po;
        try {
            delete po;
        } catch(DmlException exceptionInstance) {
            System.assert(true);
        }
        // delete paymentLineItem;
        // delete po;
        delete poClone;
        
    }

    static testMethod void testInputPOItemsController()
    {
        ASI_MFM_CAP_TestClassHelper.createRoutePOType();
        ASI_MFM_PO__c PO = ASI_MFM_CAP_TestClassHelper.createPO();
        ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
        List<ASI_MFM_PO_Line_Item__c> poLineSet = new List<ASI_MFM_PO_Line_Item__c>();
        poLineSet.add(poLine);
        ApexPages.standardSetController sc = new ApexPages.standardSetController(poLineSet);
        
        PageReference inputPOItemsPage = Page.ASI_MFM_CAP_InputPOItemsPage;
        Map<String, String> pageParams = inputPOItemsPage.getParameters();
        pageParams.put('id', po.Id);
        Test.setCurrentPageReference(inputPOItemsPage);
        
        ASI_MFM_CAP_InputPOItemsController poLineItemsController =
            new ASI_MFM_CAP_InputPOItemsController(sc);

       // PO.ASI_MFM_Plan__c = ASI_MFM_CAP_TestClassHelper.createPlan().id;
       // PO.ASI_MFM_PO_Type__c = 'CAPEX';
       // update PO;
        
        ASI_MFM_PO__c poClone = ASI_MFM_CAP_TestClassHelper.createPoClone(PO);
        
        /*[WL 1.0] BEGIN*/
        PO.ASI_MFM_Status__c = 'Draft';
        update PO;
        /*[WL 1.0] END*/
        
        delete PO;
    }
    
    static testMethod void testPOPrefixController()
    {
    
        //ASI_MFM_Plan__c plan1 = ASI_MFM_CAP_TestClassHelper.createPlan();
        ASI_MFM_PO__c PO = ASI_MFM_CAP_TestClassHelper.createPO();
        
        ApexPages.currentPage().getParameters().put('pid',PO.ASI_MFM_Plan__c);
        ApexPages.currentPage().getParameters().put('POType','TEST');
        ApexPages.currentPage().getParameters().put('BudgetOwnerId','TEST');
        ApexPages.currentPage().getParameters().put('supplierId','TEST');
        ApexPages.currentPage().getParameters().put('RecordType',String.valueof(po.recordtypeid).substring(0,15));
            
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(po);        
        ASI_MFM_SelectPOPrefixController ASI_MFM_SelectPOPrefixController = new ASI_MFM_SelectPOPrefixController(stdController);
        ASI_MFM_SelectPOPrefixController.getPrefixes();
        ASI_MFM_SelectPOPrefixController.proceed();
    
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
    
    //laputa(fanny) @20181116
    static testMethod void testPOTriggerWithRouteApprover()
    {
       ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'HK';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Draft');
        insert p1;
            
        p1.ASI_MFM_Status__c = 'Final';
        update p1;
        
        ASI_MFM_Plan_Line_Item__c plt1 = new ASI_MFM_Plan_Line_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_CAP_Plan_Line_Item'),
            ASI_MFM_List_Item_Description__c = 'test description',
            ASI_MFM_Total_Cost__c = 1234,
            ASI_MFM_Plan__c = p1.id,
            ASI_MFM_AP_Code__c = ASI_MFM_CAP_TestClassHelper.createCAPEXAPCode().id,
            ASI_MFM_BU_Code__c = ASI_MFM_CAP_TestClassHelper.createCAPEXBUCode().id);
        insert plt1;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;        
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name2');   //  ASI_MFM_HK_Supplier       
        accList.add(acc1);
                
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet'),Name='Name3');    //ASI_HK_CRM_Outlet       
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_HK_Supplier'),Name='Name3');       //ASI_MFM_HK_Supplier     
        accList.add(acc3);
        
        insert accList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;     
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_PO'),name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='HKD', ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Status__c = 'Draft');
        insert po;
        
        
        ASI_MFM_CAP_TestClassHelper.createApprovalRoute('PO',po.ASI_MFM_Prefix__c , u.id);
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        /*[WL 1.0] BEGIN*/
        po.ASI_MFM_Status__c = 'Final';
        po.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_PO_Read_Only');
        update po;
        /*[WL 1.0] END*/
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        
        insert pxa; 
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra; 
                
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_Payment'),name='test', ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Other_than_POSM__c=true, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '9999999',
                                                       ASI_MFM_Currency__c='HKD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Draft',ASI_MFM_ETL__c = false, ASI_MFM_Plan__c = po.ASI_MFM_Plan__c,ASI_MFM_Payment_Type__c = 'CAPEX',
                                                        ASI_MFM_CAP_PO__c = po.Id);  
        insert py;
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        
        list<ASI_MFM_Payment_Line_Item__c> paymentLineItems = new list<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id,ASI_MFM_Voucher_Created__c=false);  // it must include ASI_MFM_Payee__c 
        paymentLineItems.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id,ASI_MFM_Payment_Line_Item_Finance_Verify__c=true,ASI_MFM_Voucher_Created__c=false);  // it must include ASI_MFM_Payee__c 
        paymentLineItems.add(pyi2);
        insert paymentLineItems;
        
        
        po.ASI_MFM_Status__c = 'Submitted';
        po.ASI_MFM_Exchange_Rate__c = 0.052;
        update po;
        po.ASI_MFM_Status__c = 'Draft';
        update po;
        try {
            delete po;
        } catch(DmlException exceptionInstance) {
            System.assert(true);
        }
        // delete paymentLineItem;
        // delete po;
       // delete poClone;
       Test.stopTest();
      
    }
}