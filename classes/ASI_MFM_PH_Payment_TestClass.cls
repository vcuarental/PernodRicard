/***************************************************************************************************************************
 * Name:        ASI_MFM_PH_Payment_TestClass
 * Description: 
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-07-25       Wilken Lee              [WL 1.0] Increase coverage for ASI_MFM_PH_Payment_TriggerClass
 ****************************************************************************************************************************/
@isTest
private class ASI_MFM_PH_Payment_TestClass {
  //----------------------------------------------------------Fiscal Year---------------------------------------------------------------------------------------
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
    
    
    static testMethod void PaymentTest1()
    {
        // Test class: ASI_MFM_PaymentLineItem_TriggerClass;
        //           ASI_MFM_PH_InputPaymentItemsController  ; 
        //           ASI_MFM_PH_Payment_TriggerClass; ASI_MFM_Payment_TriggerClass
        //          ASI_MFM_PH_Payment_PDF_PageController
        //          ASI_MFM_PH_PORelatedPaymentsController
        //         ASI_MFM_PH_FV_Controller
        //
        //Prefix
        
        
         List<ASI_MFM_GL_Date_Setting__c> GLDateList  = new List<ASI_MFM_GL_Date_Setting__c>();
        ASI_MFM_GL_Date_Setting__c d1 = new ASI_MFM_GL_Date_Setting__c(name='1',ASI_MFM_Country__c='PH',ASI_MFM_Start_Date__c=Date.today(),ASI_MFM_End_Date__c=Date.today().addMonths(1),ASI_MFM_G_L_Date__c=Date.today(),ASI_MFM_Month__c=1);
        GLDateList.add(d1);
        ASI_MFM_GL_Date_Setting__c d2 = new ASI_MFM_GL_Date_Setting__c(name='2',ASI_MFM_Country__c='PH',ASI_MFM_Start_Date__c=Date.today().addMonths(1),ASI_MFM_End_Date__c=Date.today().addMonths(2),ASI_MFM_G_L_Date__c=Date.today(),ASI_MFM_Month__c=1);
        GLDateList.add(d2);
        
        insert GLDateList;
        
        
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
		//Route Type
		List<ASI_MFM_Route_Type__c> rtList = new List<ASI_MFM_Route_Type__c>();
		ASI_MFM_Route_Type__c planRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Plan', Name = 'Plan RT');
		ASI_MFM_Route_Type__c poRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'PO', Name = 'PO RT');
		ASI_MFM_Route_Type__c paymentRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Payment', Name = 'Payment RT');
		rtList.add(planRT);
		rtList.add(poRT);
		rtList.add(paymentRT);
		insert rtList;
		
		//Route Rule Details 
		List<ASI_MFM_Route_Rule_Detail__c> rrdList = new List<ASI_MFM_Route_Rule_Detail__c>();
		ASI_MFM_Route_Rule_Detail__c planRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c poRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		rrdList.add(planRRD);
		rrdList.add(poRRD);
		rrdList.add(paymentRRD);
		insert rrdList;
		
		//Brand RT Map
		List<ASI_MFM_Brand_Route_Type_Map__c> brtList = new List<ASI_MFM_Brand_Route_Type_Map__c>();
		ASI_MFM_Brand_Route_Type_Map__c planBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = px.Id);
		ASI_MFM_Brand_Route_Type_Map__c poBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxo.Id);
		ASI_MFM_Brand_Route_Type_Map__c paymentBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxa.Id);
        brtList.add(planBRT);
		brtList.add(poBRT);
		brtList.add(paymentBRT);
		insert brtList;
		
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_PH_TestClassHelper.createACPHDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_PH_TestClassHelper.CreateDFSBrand();
        
        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),ASI_MFM_Currency__c='SGD',
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
   
        // Create PO
          
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;
        
        
        
        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(poi);                                                          
        ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(pol);
        insert poLineList;
  
        
        // Create Payment  
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = accList[0].id,ASI_MFM_Status__c='Submitted');  
        insert py;
        
        
        Test.startTest(); // start the test
        System.debug(Limits.getDMLRows());
        
        //Paymet line item
        List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id,ASI_MFM_Complete_POL__c = true); 
        payLineList.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id); 
        payLineList.add(pyi2);
        insert payLineList;
        
        //Finished
        
        List<ASI_MFM_Payment_Line_Item__c> payLineSet = new List<ASI_MFM_Payment_Line_Item__c>();
        payLineSet.add(pyi);
        
        ApexPages.standardSetController sc = new ApexPages.standardSetController(payLineSet);
        
        PageReference inputPaymmentItemsPage = Page.ASI_MFM_PH_InputPaymentItemsPage;
        Map<String, String> pageParams = inputPaymmentItemsPage.getParameters();
        
        
        pageParams.put('id', py.Id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(py);
        ASI_MFM_PH_InputPaymentItemsController PaymentMagAllCtler = new ASI_MFM_PH_InputPaymentItemsController(stdController);
        
        
        //Test function
        
        
        PaymentMagAllCtler.init();

        System.currentPageReference().getParameters().put('IS_QUICK_SAVE', 'Yes');
        PaymentMagAllCtler.SaveItems();
        PaymentMagAllCtler.saveLinetems();
        
        System.currentPageReference().getParameters().put('PARAM_POLINE_SOURCE_ITEM_ID', (String)pol.id);
        PaymentMagAllCtler.addLineItem();
        

        System.currentPageReference().getParameters().put('PARAM_PAYLine_ID', 'z0');// (String)pyi.id
        PaymentMagAllCtler.removePaymentLine();
        
        System.currentPageReference().getParameters().put('IS_QUICK_SAVE', 'Yes');
        PaymentMagAllCtler.SaveItems();
         
        PaymentMagAllCtler.cancel();
        
        //  TriggerClass
        py.ASI_MFM_Status__c = 'Final';
        update py;
        
        // Test PDF
        ASI_MFM_PH_Payment_PDF_PageController ext = new ASI_MFM_PH_Payment_PDF_PageController(new ApexPages.StandardController(py));
        
        ext.paymentID= py.Id; 
        ext.dummyVar = false;
        boolean extflag=ext.init();
        
        
        // PORelatedPaymentsController
        ASI_MFM_PH_PORelatedPaymentsController ext1 = new ASI_MFM_PH_PORelatedPaymentsController(new ApexPages.StandardController(po));
        
        
        
        ASI_MFM_PH_FV_Controller ext2 = new ASI_MFM_PH_FV_Controller();
        ext2.initDF();
        ext2.save();
        ext2.FinVerify='Checked';
        ext2.Payee='t';
        ext2.InvoiceNumber='1';
        ext2.POline_ID='t';
        ext2.PO_ID='t';
        ext2.Fiscalyear=getFiscalYear();
        ext2.Payment_ID='t';
        ext2.PayLine_ID='t';
        ext2.runSearch();
        
        List<Account> remo= ASI_MFM_PH_FV_Controller.findSObjects('Account','WHERE RecordType.DeveloperName = ASI_MFM_PH_DF_Customer');
        
        test.stopTest(); 
        
        
        
    }
    
    
    static testMethod void PaymentTrigger(){
          // Test ASI_MFM_PH_Payment_TriggerClass
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
		//Route Type
		List<ASI_MFM_Route_Type__c> rtList = new List<ASI_MFM_Route_Type__c>();
		ASI_MFM_Route_Type__c planRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Plan', Name = 'Plan RT');
		ASI_MFM_Route_Type__c poRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'PO', Name = 'PO RT');
		ASI_MFM_Route_Type__c paymentRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Payment', Name = 'Payment RT');
		rtList.add(planRT);
		rtList.add(poRT);
		rtList.add(paymentRT);
		insert rtList;
		
		//Route Rule Details 
		List<ASI_MFM_Route_Rule_Detail__c> rrdList = new List<ASI_MFM_Route_Rule_Detail__c>();
		ASI_MFM_Route_Rule_Detail__c planRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c poRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		
		/*[WL 1.0] BEGIN*/
		ASI_MFM_Route_Rule_Detail__c paymentRRD1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);	
		ASI_MFM_Route_Rule_Detail__c paymentRRD10 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);	
		
		rrdList.add(paymentRRD1);
		rrdList.add(paymentRRD2);
		rrdList.add(paymentRRD3);
		rrdList.add(paymentRRD4);
		rrdList.add(paymentRRD5);
		rrdList.add(paymentRRD6);
		rrdList.add(paymentRRD7);
		rrdList.add(paymentRRD8);
		rrdList.add(paymentRRD9);
		rrdList.add(paymentRRD10);
		/*[WL 1.0] END*/
		
		rrdList.add(planRRD);
		rrdList.add(poRRD);
		
		insert rrdList;
		
		//Brand RT Map
		List<ASI_MFM_Brand_Route_Type_Map__c> brtList = new List<ASI_MFM_Brand_Route_Type_Map__c>();
		ASI_MFM_Brand_Route_Type_Map__c planBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = px.Id);
		ASI_MFM_Brand_Route_Type_Map__c poBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxo.Id);
		ASI_MFM_Brand_Route_Type_Map__c paymentBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxa.Id);
        brtList.add(planBRT);
		brtList.add(poBRT);
		brtList.add(paymentBRT);
		insert brtList;
        
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_PH_TestClassHelper.createACPHDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_PH_TestClassHelper.CreateDFSBrand();
        
        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),ASI_MFM_Currency__c='SGD',
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
   
        // Create PO
          
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;
        
        
        
        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(poi);                                                          
        ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(pol);
        insert poLineList;
  
        
        // Create Payment  
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = accList[0].id,ASI_MFM_Status__c='Submitted');  
        insert py;
        
        
        Test.startTest(); // start the test
        System.debug(Limits.getDMLRows());
        
        //Paymet line item
        List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id,ASI_MFM_Complete_POL__c = true); 
        payLineList.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id); 
        payLineList.add(pyi2);
        insert payLineList;
        
        py.ASI_MFM_Status__c='Final';
        update py;

         PageReference pageRef5 = new Pagereference('/apex/ASI_MFM_PaymentDetailPage');
        Test.setCurrentPage(pageRef5);
        // Haved Complete PO Case
        ApexPages.currentPage().getParameters().put('status', 'Draft');   // change status as draft
        ASI_MFM_SetPaymentStatusController ext5 = new ASI_MFM_SetPaymentStatusController(new ApexPages.StandardController(py));
        ext5.setStatus();//System.debug('new_statusTEST:'+ext.new_status);
        
        
        test.stopTest(); 
    }
    
   static testMethod void  ASI_MFM_PH_PaymentSetStatusTest(){
      // Test ASI_MFM_PH_Payment_TriggerClass
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
        //Route Type
		List<ASI_MFM_Route_Type__c> rtList = new List<ASI_MFM_Route_Type__c>();
		ASI_MFM_Route_Type__c planRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Plan', Name = 'Plan RT');
		ASI_MFM_Route_Type__c poRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'PO', Name = 'PO RT');
		ASI_MFM_Route_Type__c paymentRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Payment', Name = 'Payment RT');
		rtList.add(planRT);
		rtList.add(poRT);
		rtList.add(paymentRT);
		insert rtList;
		
		//Route Rule Details 
		List<ASI_MFM_Route_Rule_Detail__c> rrdList = new List<ASI_MFM_Route_Rule_Detail__c>();
		ASI_MFM_Route_Rule_Detail__c planRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c poRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		rrdList.add(planRRD);
		rrdList.add(poRRD);
		rrdList.add(paymentRRD);
		insert rrdList;
		
		//Brand RT Map
		List<ASI_MFM_Brand_Route_Type_Map__c> brtList = new List<ASI_MFM_Brand_Route_Type_Map__c>();
		ASI_MFM_Brand_Route_Type_Map__c planBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = px.Id);
		ASI_MFM_Brand_Route_Type_Map__c poBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxo.Id);
		ASI_MFM_Brand_Route_Type_Map__c paymentBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxa.Id);
        brtList.add(planBRT);
		brtList.add(poBRT);
		brtList.add(paymentBRT);
		insert brtList;
		
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_PH_TestClassHelper.createACPHDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_PH_TestClassHelper.CreateDFSBrand();
        
        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),ASI_MFM_Currency__c='SGD',
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
   
        // Create PO
          
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;
        
        
        
        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(poi);                                                          
        ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(pol);
        insert poLineList;
  
        
        // Create Payment  
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = accList[0].id,ASI_MFM_Status__c='Final');  
        insert py;
        
        
        Test.startTest(); // start the test
        System.debug(Limits.getDMLRows());
        
        //Paymet line item
        List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id); 
        payLineList.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id); 
        payLineList.add(pyi2);
        insert payLineList;
        

         PageReference pageRef5 = new Pagereference('/apex/ASI_MFM_PaymentDetailPage');
        Test.setCurrentPage(pageRef5);
        
        ApexPages.currentPage().getParameters().put('status', 'Draft');   // change status as draft
        ASI_MFM_SetPaymentStatusController ext5 = new ASI_MFM_SetPaymentStatusController(new ApexPages.StandardController(py));
        ext5.setStatus();
        
        
        test.stopTest(); 
    
       
   }
    	
    
   static testMethod void  PaymentSetStatusVoucherCreatedTest(){
      // Test ASI_MFM_PH_Payment_TriggerClass
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
        //Route Type
		List<ASI_MFM_Route_Type__c> rtList = new List<ASI_MFM_Route_Type__c>();
		ASI_MFM_Route_Type__c planRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Plan', Name = 'Plan RT');
		ASI_MFM_Route_Type__c poRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'PO', Name = 'PO RT');
		ASI_MFM_Route_Type__c paymentRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Payment', Name = 'Payment RT');
		rtList.add(planRT);
		rtList.add(poRT);
		rtList.add(paymentRT);
		insert rtList;
		
		//Route Rule Details 
		List<ASI_MFM_Route_Rule_Detail__c> rrdList = new List<ASI_MFM_Route_Rule_Detail__c>();
		ASI_MFM_Route_Rule_Detail__c planRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c poRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		rrdList.add(planRRD);
		rrdList.add(poRRD);
		rrdList.add(paymentRRD);
		insert rrdList;
		
		//Brand RT Map
		List<ASI_MFM_Brand_Route_Type_Map__c> brtList = new List<ASI_MFM_Brand_Route_Type_Map__c>();
		ASI_MFM_Brand_Route_Type_Map__c planBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = px.Id);
		ASI_MFM_Brand_Route_Type_Map__c poBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxo.Id);
		ASI_MFM_Brand_Route_Type_Map__c paymentBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxa.Id);
        brtList.add(planBRT);
		brtList.add(poBRT);
		brtList.add(paymentBRT);
		insert brtList;
		
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_PH_TestClassHelper.createACPHDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_PH_TestClassHelper.CreateDFSBrand();
        
        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),ASI_MFM_Currency__c='SGD',
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
   
        // Create PO
          
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;
        
        
        
        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(poi);                                                          
        ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(pol);
        insert poLineList;
  
        
        // Create Payment  
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = accList[0].id,ASI_MFM_Status__c='Final');  
        insert py;
        
        
        Test.startTest(); // start the test
        System.debug(Limits.getDMLRows());
        
        //Paymet line item
        List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id,ASI_MFM_Voucher_Created__c=true); 
        payLineList.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id); 
        payLineList.add(pyi2);
        insert payLineList;
        

         PageReference pageRef5 = new Pagereference('/apex/ASI_MFM_PaymentDetailPage');
        Test.setCurrentPage(pageRef5);
        //Voucher created case
        ApexPages.currentPage().getParameters().put('status', 'Draft'); 
        ASI_MFM_SetPaymentStatusController ext5 = new ASI_MFM_SetPaymentStatusController(new ApexPages.StandardController(py));
        ext5.setStatus();
        
        PageReference PaymentPrefixPage = Page.ASI_MFM_SelectPaymentPrefixPage;
        Test.setCurrentPage(PaymentPrefixPage);
        ApexPages.currentPage().getParameters().put('RecordType', String.valueof(py.recordtypeid).substring(0,15));
        ApexPages.currentPage().getParameters().put('id', py.id);
        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(py);        
        ASI_MFM_SelectPaymentPrefixController SelectPaymentPrefixController = new ASI_MFM_SelectPaymentPrefixController(stdController);
        
        SelectPaymentPrefixController.getPrefixes();
       
        
        test.stopTest(); 
    
       
   }
    	
    
    
       
   static testMethod void  PaymentRerunETLTest2(){
      //
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
        //Route Type
		List<ASI_MFM_Route_Type__c> rtList = new List<ASI_MFM_Route_Type__c>();
		ASI_MFM_Route_Type__c planRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Plan', Name = 'Plan RT');
		ASI_MFM_Route_Type__c poRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'PO', Name = 'PO RT');
		ASI_MFM_Route_Type__c paymentRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Payment', Name = 'Payment RT');
		rtList.add(planRT);
		rtList.add(poRT);
		rtList.add(paymentRT);
		insert rtList;
		
		//Route Rule Details 
		List<ASI_MFM_Route_Rule_Detail__c> rrdList = new List<ASI_MFM_Route_Rule_Detail__c>();
		ASI_MFM_Route_Rule_Detail__c planRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c poRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		rrdList.add(planRRD);
		rrdList.add(poRRD);
		rrdList.add(paymentRRD);
		insert rrdList;
		
		//Brand RT Map
		List<ASI_MFM_Brand_Route_Type_Map__c> brtList = new List<ASI_MFM_Brand_Route_Type_Map__c>();
		ASI_MFM_Brand_Route_Type_Map__c planBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = px.Id);
		ASI_MFM_Brand_Route_Type_Map__c poBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxo.Id);
		ASI_MFM_Brand_Route_Type_Map__c paymentBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxa.Id);
        brtList.add(planBRT);
		brtList.add(poBRT);
		brtList.add(paymentBRT);
		insert brtList;
		
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_PH_TestClassHelper.createACPHDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_PH_TestClassHelper.CreateDFSBrand();
        
        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),ASI_MFM_Currency__c='SGD',
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
   
        // Create PO
          
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;
        
        
        
        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(poi);                                                          
        ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(pol);
        insert poLineList;
  
        	
        // Create Payment  
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = accList[0].id,ASI_MFM_Status__c='Final');  
        insert py;
        
        
        Test.startTest(); // start the test
        System.debug(Limits.getDMLRows());
        
        //Paymet line item
        List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id,ASI_MFM_Voucher_Created__c=true); 
        payLineList.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id); 
        payLineList.add(pyi2);
        insert payLineList;
        

         PageReference pageRef5 = new Pagereference('/apex/ASI_MFM_RerunETLPage');
        Test.setCurrentPage(pageRef5);
        ApexPages.currentPage().getParameters().put('status', 'Draft'); 
        ASI_MFM_RerunETLController ext5 = new ASI_MFM_RerunETLController(new ApexPages.StandardController(py));
        ext5.setStatus();
        

        test.stopTest(); 
    
       
   }
    	
           
   static testMethod void  PaymentRerunETLTest3(){
      //
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
		//Route Type
		List<ASI_MFM_Route_Type__c> rtList = new List<ASI_MFM_Route_Type__c>();
		ASI_MFM_Route_Type__c planRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Plan', Name = 'Plan RT');
		ASI_MFM_Route_Type__c poRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'PO', Name = 'PO RT');
		ASI_MFM_Route_Type__c paymentRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Payment', Name = 'Payment RT');
		rtList.add(planRT);
		rtList.add(poRT);
		rtList.add(paymentRT);
		insert rtList;
		
		//Route Rule Details 
		List<ASI_MFM_Route_Rule_Detail__c> rrdList = new List<ASI_MFM_Route_Rule_Detail__c>();
		ASI_MFM_Route_Rule_Detail__c planRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c poRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		rrdList.add(planRRD);
		rrdList.add(poRRD);
		rrdList.add(paymentRRD);
		insert rrdList;
		
		//Brand RT Map
		List<ASI_MFM_Brand_Route_Type_Map__c> brtList = new List<ASI_MFM_Brand_Route_Type_Map__c>();
		ASI_MFM_Brand_Route_Type_Map__c planBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = px.Id);
		ASI_MFM_Brand_Route_Type_Map__c poBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxo.Id);
		ASI_MFM_Brand_Route_Type_Map__c paymentBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxa.Id);
        brtList.add(planBRT);
		brtList.add(poBRT);
		brtList.add(paymentBRT);
		insert brtList;
        
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_PH_TestClassHelper.createACPHDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_PH_TestClassHelper.CreateDFSBrand();
        
        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),ASI_MFM_Currency__c='SGD',
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
   
        // Create PO
          
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;
        
        
        
        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(poi);                                                          
        ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(pol);
        insert poLineList;
  
        	
        // Create Payment  
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = accList[0].id,ASI_MFM_Status__c='Final');  
        insert py;
        
        
        Test.startTest(); // start the test
        System.debug(Limits.getDMLRows());
        
        //Paymet line item
        List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id,ASI_MFM_Complete_POL__c=true); 
        payLineList.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id); 
        payLineList.add(pyi2);
        insert payLineList;
        

         PageReference pageRef5 = new Pagereference('/apex/ASI_MFM_RerunETLPage');
        Test.setCurrentPage(pageRef5);
        ApexPages.currentPage().getParameters().put('status', 'Draft'); 
        ASI_MFM_RerunETLController ext5 = new ASI_MFM_RerunETLController(new ApexPages.StandardController(py));
        ext5.setStatus();
        

        test.stopTest(); 
    
       
   }
    
       
   static testMethod void  PaymentRerunETLTest1(){
      //
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear());
        prefixList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='testpo', ASI_MFM_Module__c='PO');
        prefixList.add(pxo);
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='testpayment', ASI_MFM_Module__c='Payment');
        prefixList.add(pxa);
        insert prefixList;
        
        //User
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        
        // Role Prefix Relationship
        List<ASI_MFM_Role_Prefix_Relationship__c> RPList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pro);
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        RPList.add(pra);
        insert RPList;
        
		//Route Type
		List<ASI_MFM_Route_Type__c> rtList = new List<ASI_MFM_Route_Type__c>();
		ASI_MFM_Route_Type__c planRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Plan', Name = 'Plan RT');
		ASI_MFM_Route_Type__c poRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'PO', Name = 'PO RT');
		ASI_MFM_Route_Type__c paymentRT = new ASI_MFM_Route_Type__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_PH_Route_Type'), ASI_MFM_Module__c = 'Payment', Name = 'Payment RT');
		rtList.add(planRT);
		rtList.add(poRT);
		rtList.add(paymentRT);
		insert rtList;
		
		//Route Rule Details 
		List<ASI_MFM_Route_Rule_Detail__c> rrdList = new List<ASI_MFM_Route_Rule_Detail__c>();
		ASI_MFM_Route_Rule_Detail__c planRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c poRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		ASI_MFM_Route_Rule_Detail__c paymentRRD = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c = u.Id);
		rrdList.add(planRRD);
		rrdList.add(poRRD);
		rrdList.add(paymentRRD);
		insert rrdList;
		
		//Brand RT Map
		List<ASI_MFM_Brand_Route_Type_Map__c> brtList = new List<ASI_MFM_Brand_Route_Type_Map__c>();
		ASI_MFM_Brand_Route_Type_Map__c planBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = planRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = px.Id);
		ASI_MFM_Brand_Route_Type_Map__c poBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = poRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxo.Id);
		ASI_MFM_Brand_Route_Type_Map__c paymentBRT = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c = paymentRT.Id, ASI_MFM_Active__c = true, ASI_MFM_Prefix__c = pxa.Id);
        brtList.add(planBRT);
		brtList.add(poBRT);
		brtList.add(paymentBRT);
		insert brtList;
        
        List<Account> accList = ASI_MFM_PH_TestClassHelper.createDFAccount();
       
        ASI_MFM_A_C_Code__c ac = ASI_MFM_PH_TestClassHelper.createACPHDFCode();
        ASI_MFM_Sub_brand__c sub =ASI_MFM_PH_TestClassHelper.CreateDFSBrand();
        
        // Create Plan 
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),ASI_MFM_Currency__c='SGD',
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
   
        // Create PO
          
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DF_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = accList[0].id, ASI_MFM_Status__c = 'Final');
        insert po;
        
        
        
        // Create PO line Items
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(poi);                                                          
        ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=10000,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=accList[1].id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        poLineList.add(pol);
        insert poLineList;
  
        	
        // Create Payment  
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = accList[0].id,ASI_MFM_Status__c='Final');  
        insert py;
        
        
        Test.startTest(); // start the test
        System.debug(Limits.getDMLRows());
        
        //Paymet line item
        List<ASI_MFM_Payment_Line_Item__c> payLineList = new List<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id); 
        payLineList.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=accList[0].id); 
        payLineList.add(pyi2);
        insert payLineList;
        

         PageReference pageRef5 = new Pagereference('/apex/ASI_MFM_RerunETLPage');
        Test.setCurrentPage(pageRef5);
        ApexPages.currentPage().getParameters().put('status', 'Draft'); 
        ASI_MFM_RerunETLController ext5 = new ASI_MFM_RerunETLController(new ApexPages.StandardController(py));
        ext5.setStatus();
        

        test.stopTest(); 
    
       
   }
    	
    
    
    
    static testMethod void  ASI_MFM_PH_GLDateSettingTest(){
        List<ASI_MFM_GL_Date_Setting__c> GLDateList  = new List<ASI_MFM_GL_Date_Setting__c>();
        ASI_MFM_GL_Date_Setting__c d1 = new ASI_MFM_GL_Date_Setting__c(name='1',ASI_MFM_Country__c='PH',ASI_MFM_Start_Date__c=Date.today(),ASI_MFM_End_Date__c=Date.today().addMonths(1),ASI_MFM_G_L_Date__c=Date.today(),ASI_MFM_Month__c=1);
        GLDateList.add(d1);
        ASI_MFM_GL_Date_Setting__c d2 = new ASI_MFM_GL_Date_Setting__c(name='2',ASI_MFM_Country__c='PH',ASI_MFM_Start_Date__c=Date.today().addMonths(1),ASI_MFM_End_Date__c=Date.today().addMonths(2),ASI_MFM_G_L_Date__c=Date.today(),ASI_MFM_Month__c=1);
        GLDateList.add(d2);
        
        insert GLDateList;
        
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        PageReference pageRef = new Pagereference('/apex/ASI_MFM_PH_GLDate_SettingPage');
        Test.setCurrentPage(pageRef);
        ASI_MFM_PH_GLDate_SettingController ext = new ASI_MFM_PH_GLDate_SettingController();
        
        ext.init();
        //ext.save();
        ext.refresh();
        test.stopTest();
    }
    
    
    
}