@isTest
private class ASI_MFM_EditSmallAmountPayment_TestClass{
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
    
    static testMethod void testASI_MFM_EditSmallAmountPayment(){
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'GF';
        update u;
        
        System.debug('Current user Role Name: ' + u.userRole.developerName);
        
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxp;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxo;
        
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxy;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;
        ASI_MFM_Role_Prefix_Relationship__c pr3 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr3;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), 
            ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=pxp.id);
        insert p;
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='testAC');
        insert ap;
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert sub;
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='USD',
            ASI_MFM_Counter_Currency__c='EUR', ASI_MFM_Country__c='GF', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.34);
        insert xr;         
        
        
        ASI_MFM_Approval_Setting__c setting = new ASI_MFM_Approval_Setting__c(Name='GF', ASI_MFM_Direct_Payment_Max_Allowed_Amt__c=1000, ASI_MFM_Payment_Min_Approval_Amt__c=5000,ASI_MFM_Payment_Tolerance_Percent__c=10, ASI_MFM_Payment_Tolerance_Amt__c=5000);
        insert setting;
        
        Test.StartTest();
        Test.setCurrentPage(Page.ASI_MFM_GF_EditSmallAmountPayment_Page);
        
        ASI_MFM_EditSmallAmountPayment_Ctrl controller = new ASI_MFM_EditSmallAmountPayment_Ctrl(); 
        controller.init();
        
        controller.LSAPHeader[0].po.ASI_MFM_Plan__c = p.id;
        controller.LSAPHeader[0].po.ASI_MFM_Prefix__c = pxo.id;
        controller.LSAPHeader[0].po.ASI_MFM_Supplier_Name__c = acc2.id ;
        controller.LSAPHeader[0].po.ASI_MFM_Currency__c = 'EUR';
        controller.LSAPHeader[0].po.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO_Read_Only');
        controller.LSAPHeader[0].po.ASI_MFM_Status__c = 'Final';
        controller.LSAPHeader[0].po.ASI_MFM_PO_Type__c = 'Normal';
        controller.LSAPHeader[0].po.ASI_MFM_Remarks__c = 'Auto created from direct payment';
        controller.LSAPHeader[0].po.ASI_MFM_PO_Start_Date__c = Date.today();
        controller.LSAPHeader[0].po.ASI_MFM_PO_End_Date__c = Date.today().addMonths(1);
        
        controller.LSAPHeader[0].pay.ASI_MFM_Prefix__c = pxy.id;
        controller.LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c = acc2.id  ;
        controller.LSAPHeader[0].pay.ASI_MFM_Currency__c = 'EUR';
        controller.LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c = '12345';
        controller.LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c = Date.today();
        controller.LSAPHeader[0].pay.recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment_Read_Only');
        controller.LSAPHeader[0].pay.ASI_MFM_Status__c = 'Final';
        controller.LSAPHeader[0].pay.ASI_MFM_Remarks__c = 'Auto created from direct payment';
        
        
        controller.AddNew_SAPL();
        
        ASI_MFM_EditSmallAmountPayment_Ctrl.SAPLineObj sapl_Clone = controller.SAPL_Item_Map.get(0);
        sapl_Clone.pl = new ASI_MFM_Payment_Line_Item__c();
        sapl_Clone.pl.ASI_MFM_Payment_List_Item_Description__c = 'abcd';
        sapl_Clone.pl.ASI_MFM_Payment_Date__c = Date.today() ;
        sapl_Clone.pl.ASI_MFM_Payment_Amount__c = 50;
        
        sapl_Clone.pol= new ASI_MFM_PO_Line_Item__c();
        sapl_Clone.pol.ASI_MFM_Sub_brand_Code__c = sub.id ;
        //sapl_Clone.pol.ASI_MFM_Sub_brand_Allocation_Type__c = '';
        sapl_Clone.pol.ASI_MFM_AP_Code__c=ap.id;
        sapl_Clone.pol.ASI_MFM_Customer_Name__c = acc1.id;
 //     controller.SAPL_Item_Map.put(0, sapl_Clone);
        
        controller.rowidSAPL = 0;
        controller.Clone_SAPL();
        controller.rowidSAPL = 1;
        controller.RemoveRow_SAPL();
        
        ASI_MFM_EditSmallAmountPayment_Ctrl.findSObjects('ASI_MFM_Plan__c', '');
        ASI_MFM_EditSmallAmountPayment_Ctrl.findCustSObjects('account', 'ASI_GF_Customer');
        controller.SaveRecord();
        
        controller.MFMlog.ASI_MFM_Configuration__c='test1/test2';
        controller.MFMlog.ASI_MFM_Status__c='Success';
        update controller.MFMlog;
        string[] templist=controller.statusMsgs;
        Test.StopTest();
   }
   static testMethod void testASI_MFM_EditSmallAmountPayment2(){
   {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'GF';
        update u;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);

        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), 
            ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;  
                
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
         ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert sub;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        Test.startTest();        
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        insert pxa; 
        
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra;  
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Supplier_Name__c = acc2.id);
        insert py;
        
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item'),ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');                       
        insert pyi;

        list<ASI_MFM_Payment_Line_Item__c> pyi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        pyi_list.add(pyi);
        apexpages.currentPage().getParameters().put('paid', py.id); 
        apexpages.currentPage().getParameters().put('poid', po.id); 
        ASI_MFM_EditSmallAmountPaymentP2_Ctrl controller = new ASI_MFM_EditSmallAmountPaymentP2_Ctrl(); 
        
        controller.init();
        controller.ViewPayment();
       
     
       
        Test.StopTest();
    }
  }
}