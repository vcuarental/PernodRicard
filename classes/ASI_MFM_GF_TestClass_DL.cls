@isTest
private class ASI_MFM_GF_TestClass_DL {    
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
    
    static testMethod void testGFGenPOItemsController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert sub;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        acctList.add(acc2);
        
        insert acctList;
        
        test.startTest();
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
        ,ASI_MFM_Sub_brand_Code__c = sub.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription');   
        insert pi;  
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;  
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        apexpages.standardController sc = new apexpages.standardController(po);
        ASI_MFM_GF_GenPOItemsController cx= new ASI_MFM_GF_GenPOItemsController(sc);
        pageReference pg = page.ASI_MFM_GenPOItemsPage;
        test.setCurrentPage(pg);  
        apexpages.currentPage().getParameters().put('mode', 'Full'); 
        cx.genPOItems();    
        test.stopTest();
    }    

    static testMethod void testGFInputPlanItemsController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear(), ASI_MFM_TR_Rec_Type__c = 'Duty Paid');
        insert px; 
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        test.setCurrentPage(page.ASI_MFM_GF_InputPlanItemsPage);
        apexpages.currentPage().getParameters().put('id', p.id); 
        list<ASI_MFM_Plan__c> p_list = new list<ASI_MFM_Plan__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(p_list);  
        ASI_MFM_GF_InputPlanItemsController cx = new ASI_MFM_GF_InputPlanItemsController(sc); 
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_Plan_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Sub_brand_Allocation_Type__c&req=F&width=200px, ASI_MFM_Sub_brand_Code__c&req=F&width=200px, ASI_MFM_AP_Code__c&req=T&width=160px,  ASI_MFM_Customer_Name__c&req=T&width=320px, ASI_MFM_Area_of_Activation__c&req=F&width=240px, ASI_MFM_List_Item_Description__c&req=T&width=120px, ASI_MFM_Remarks__c&req=F&width=240px,ASI_MFM_Total_Cost__c&req=F&width=105px, ASI_MFM_Distributor_Amount__c&req=F&width=105px, ASI_MFM_GF_Total_Amount__c&req=F&width=105px,ASI_MFM_Month_1_Cost__c&req=F&width=80px, ASI_MFM_Month_2_Cost__c&req=F&width=80px, ASI_MFM_Month_3_Cost__c&req=F&width=80px, ASI_MFM_Month_4_Cost__c&req=F&width=80px,ASI_MFM_Month_5_Cost__c&req=F&width=80px, ASI_MFM_Month_6_Cost__c&req=F&width=80px, ASI_MFM_Month_7_Cost__c&req=F&width=80px, ASI_MFM_Month_8_Cost__c&req=F&width=80px,ASI_MFM_Month_9_Cost__c&req=F&width=80px, ASI_MFM_Month_10_Cost__c&req=F&width=80px, ASI_MFM_Month_11_Cost__c&req=F&width=80px, ASI_MFM_Month_12_Cost__c&req=F&width=80px';        
        mcauCon.fieldToURLParamStr = 'ASI_MFM_Plan__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_Plan__c = \'' + p.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + p.Id;
        mcauCon.cancelLink = '/' + p.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Sub_brand_Allocation_Type__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_Customer_Name__c';
        
        mcauCon.init();
        mcauCon.commitAll();
    }

    static testMethod void testGFInputPOItemsController() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear(), ASI_MFM_TR_Rec_Type__c = 'Duty Paid');
        insert px;   
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
                
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        insert acc1;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear(), ASI_MFM_TR_Rec_Type__c = 'Duty Paid');
        insert pxo; 
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id, ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        test.setCurrentPage(page.ASI_MFM_GF_InputPOItemsPage);
        apexpages.currentPage().getParameters().put('id', po.id); 
        list<ASI_MFM_PO__c> po_list = new list<ASI_MFM_PO__c>();
        apexpages.standardSetController sc = new apexpages.standardSetController(po_list);  
        ASI_MFM_GF_InputPOItemsController cx = new ASI_MFM_GF_InputPOItemsController(sc);         

        //Test VAP Brand Owner PO
        po.ASI_MFM_PO_Type__c = 'VAP Brand Owner';
        update po;
        cx = new ASI_MFM_GF_InputPOItemsController(sc);         
        
        //Test VAP FOC PO
        po.ASI_MFM_PO_Type__c = 'VAP FOC';
        update po;
        cx = new ASI_MFM_GF_InputPOItemsController(sc);         
        
        //Test VAP FOC PO
        po.ASI_MFM_PO_Type__c = 'Event FOC';
        update po;
        cx = new ASI_MFM_GF_InputPOItemsController(sc);
        ASI_MFM_MassCreateAndUpdateController mcauCon = new ASI_MFM_MassCreateAndUpdateController();
        
        // Assign component attributes
        mcauCon.isFastModeBool = false;
        mcauCon.sObjTypeStr = 'ASI_MFM_PO_Line_Item__c';
        mcauCon.displayFieldsStr = 'ASI_MFM_Spread_by_Months__c&req=F&width=40px, ASI_MFM_Sub_brand_Allocation_Type__c&req=F&width=140px, ASI_MFM_Sub_brand_Code__c&req=F&width=240px, ASI_MFM_AP_Code__c&req=T&width=160px, ASI_MFM_Customer_Name__c&req=T&width=320px, ASI_MFM_List_Item_Description__c&req=T&width=120px, ASI_MFM_Quantity__c&req=F&width=50px, ASI_MFM_Amount__c&req=T&width=80px, ASI_MFM_Distributor_Amount__c&req=F&width=80px, ASI_MFM_GF_PRG_Amount__c&req=F&width=80px, ASI_MFM_Recharge__c&req=F&width=35px, ASI_MFM_G_L_Date__c&req=T&width=75px';        
        mcauCon.fieldToURLParamStr = 'ASI_MFM_PO__c=>id';
        mcauCon.whereStatm = 'ASI_MFM_PO__c = \'' + po.Id + '\'';
        mcauCon.pageBlockTitleStr = 'Plan Line Items';
        mcauCon.successLink = '/' + po.Id;
        mcauCon.cancelLink = '/' + po.Id;
        mcauCon.mode = 'BOTH';
        mcauCon.isDefaultEditVal = true;
        mcauCon.ShowAllRT = true;
        mcauCon.ComponentKey = 'massCreateAndUpdate';
        mcauCon.lookupToPicklist = 'ASI_MFM_Channel__c,ASI_MFM_Sub_brand_Allocation_Type__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_AP_Code__c,ASI_MFM_Customer_Name__c';
        
        mcauCon.init();
        mcauCon.commitAll();
    }
  
    public static testMethod void ASI_MFM_GF_InputReceiptItemController_TEST() {        
            ASI_MFM_PO_Receipt__c Receipt = new ASI_MFM_PO_Receipt__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_GF_PO_Receipt'), ASI_MFM_Receipt_Date__c = date.today());
            
            insert Receipt;

            ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
            insert px;   
            
            user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
            ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
            insert pr;
            
            ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
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
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Status__c = 'Draft', ASI_MFM_PO_Type__c = 'Event FOC'); 
            insert po;
        
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='5651 Consumer Event', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_GF_A_C_Code'));
            insert ac;
        
            ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='Customer and Trade Event [Trade AP]', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_GF_AP_Code'), ASI_MFM_A_C_Code__c=ac.Id);
            insert ap;
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
            insert sub;
        
            ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(), ASI_MFM_Amount__c = 100);
            insert poi;
        
            po.ASI_MFM_Status__c = 'Final';
            update po;
            
            test.startTest();

            ApexPages.currentPage().getParameters().put('poid', po.id);
            ASI_MFM_SFObjSelectTableController selectTableCon = new ASI_MFM_SFObjSelectTableController();
            
            ASI_MFM_GF_InputReceiptItemsController con = new ASI_MFM_GF_InputReceiptItemsController(new ApexPages.StandardController(Receipt));            
            con.poid = po.id;
            con.createPOReceipt();
            con.updatePOReceipt();
            selectTableCon.sObjTypeStr = 'ASI_MFM_PO_line_Item__c';
            selectTableCon.displayFieldsStr = 'id,name';
            selectTableCon.init();
            con.setComponentController('selectTable', selectTableCon);
            con.addAll();
            con.FilterPOItems();
            
            con.sobjst_initActionButtonList();
            con.sobjst_initActionButtonStageMap();
            con.sobjst_triggerActionForSObject(null, 'add', poi);
            con.mcau_initPageBlockActionButtonList();
            con.mcau_triggerPageBlockAction(null, 'TEST');
            con.mcau_triggerActionForSObject(null, 'add', null);
            
            con.setComponentController(null);
            con.setComponentController('TEST', null);
            con.getComponentController();
            con.getComponentController('TEST');
            
            //Test delete PO Receipt Trigger
            Receipt.ASI_MFM_Status__c = 'Final';
            update Receipt;
            
            try {
                delete Receipt; 
            }
            catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Not allowed to delete because the PO Receipt is') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            } 

            
            test.stopTest();
   }
    
    static testMethod void testGFPlanTrigger1() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Plan');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
        insert rrd;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert sub;
        
        test.startTest();
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        insert acc1;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_GF_Plan_Line_Item'), ASI_MFM_Plan__c=p.id
            ,ASI_MFM_Sub_brand_Code__c = sub.id,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription',
                ASI_MFM_Month_1_Cost__c = 10, ASI_MFM_Month_2_Cost__c = 10, ASI_MFM_Month_3_Cost__c = 10, ASI_MFM_Month_4_Cost__c = 10, ASI_MFM_Month_5_Cost__c = 10, ASI_MFM_Month_6_Cost__c = 10, 
                    ASI_MFM_Month_7_Cost__c = 10, ASI_MFM_Month_8_Cost__c = 10, ASI_MFM_Month_9_Cost__c = 10, ASI_MFM_Month_10_Cost__c = 10, ASI_MFM_Month_11_Cost__c = 10, ASI_MFM_Month_12_Cost__c = 10);   
        insert pi;  
        
        test.stopTest();
    }
        
    static testMethod void testGFPOTrigger1() {
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'GF';
        update u;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='USD',
            ASI_MFM_Counter_Currency__c='EUR', ASI_MFM_Country__c='GF', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        //Prefix
        List<ASI_MFM_Prefix__c> pxList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        pxList.add(px);
        
        ASI_MFM_Prefix__c pxPO = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        pxList.add(pxPO);
        
        ASI_MFM_Prefix__c pxPayment = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        pxList.add(pxPayment);
        
        insert pxList;
        
        //Role Prefix
        List<ASI_MFM_Role_Prefix_Relationship__c> prList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prList.add(pr);
        
        ASI_MFM_Role_Prefix_Relationship__c prPO = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxPO.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prList.add(prPO);
        
        ASI_MFM_Role_Prefix_Relationship__c prPayment = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxPayment.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prList.add(prPayment);
        
        insert prList;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;       
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        //20170206 Wilken: Include 10 levels of approval for code coverage
        List<ASI_MFM_Route_Rule_Detail__c> rrdList = new List<ASI_MFM_Route_Rule_Detail__c>();
        for (Integer i=0;i<10;i++){
            ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
            rrdList.add(rrd);
        }
        insert rrdList;
        
        system.debug('Route Rule Detail size: ' + rrdList.size());
        
        // Added by 2018-03-26 Linus@introv
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_GF_BU'), name='test');
        insert bu;
        
        ASI_MFM_Route_Type__c rts = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rts;
        
        ASI_MFM_Brand_Route_Type_Map__c rtms = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rts.id, ASI_MFM_Prefix__c=pxPO.id);
        insert rtms;
        
        ASI_MFM_Route_Rule_Detail__c rrds = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=1,ASI_MFM_Region__c='UPC');
        insert rrds;
        ASI_MFM_Route_Rule_Detail__c rrds2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2,ASI_MFM_Region__c='STH');
        insert rrds2;
        
        test.startTest();
        
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxPO.id, ASI_MFM_Exchange_Rate__c=1.23,ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today(),ASI_MFM_Status__c='Submitted'); 
        insert po;
        
        system.debug('PO Amount: ' + po.ASI_MFM_PO_Amount__c + ' Ex Rate: ' + po.ASI_MFM_Exchange_Rate__c);
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_Amount__c=100,ASI_MFM_Distributor_Amount__c=10,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        /*delete poi;
        
        //Wilken 20170206 Add test case to cover PO Trigger Class VAP BO type
        po.ASI_MFM_PO_Type__c = 'VAP Brand Owner';
        po.ASI_MFM_Status__c = 'Final';
        */
        po.ASI_MFM_Status__c = 'Draft';
        update po;
        
        
        try {
            delete po;
        }
        catch (Exception e){
        }
        test.stopTest();
    }
    
    static testMethod void testGFPOTrigger2() {
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'GF';
        update u;
        
        ASI_MFM_Exchange_Rate__c xr = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='USD',
            ASI_MFM_Counter_Currency__c='EUR', ASI_MFM_Country__c='GF', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1.23);
        insert xr;         
        
        //Prefix
        List<ASI_MFM_Prefix__c> pxList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        pxList.add(px);
        
        ASI_MFM_Prefix__c pxPO = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        pxList.add(pxPO);
        
        ASI_MFM_Prefix__c pxPayment = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        pxList.add(pxPayment);
        
        insert pxList;
        
        //Role Prefix
        List<ASI_MFM_Role_Prefix_Relationship__c> prList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prList.add(pr);
        
        ASI_MFM_Role_Prefix_Relationship__c prPO = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxPO.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prList.add(prPO);
        
        ASI_MFM_Role_Prefix_Relationship__c prPayment = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxPayment.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prList.add(prPayment);
        
        insert prList;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;       
        
        ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id, ASI_MFM_Prefix__c=px.id);
        insert rtm;
        
        //20170206 Wilken: Include 10 levels of approval for code coverage
        List<ASI_MFM_Route_Rule_Detail__c> rrdList = new List<ASI_MFM_Route_Rule_Detail__c>();
        for (Integer i=0;i<10;i++){
            ASI_MFM_Route_Rule_Detail__c rrd = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id);
            rrdList.add(rrd);
        }
        insert rrdList;
        
        system.debug('Route Rule Detail size: ' + rrdList.size());
        
        // Added by 2018-03-26 Linus@introv
        ASI_MFM_BU__c bu = new ASI_MFM_BU__c(recordtypeId = Global_RecordTypeCache.getRtId('ASI_MFM_BU__cASI_MFM_GF_BU'), name='test');
        insert bu;
        
        ASI_MFM_Route_Type__c rts = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rts;
        
        ASI_MFM_Brand_Route_Type_Map__c rtms = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rts.id, ASI_MFM_Prefix__c=pxPO.id);
        insert rtms;
        
        ASI_MFM_Route_Rule_Detail__c rrds = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=1,ASI_MFM_Region__c='UPC');
        insert rrds;
        ASI_MFM_Route_Rule_Detail__c rrds2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2,ASI_MFM_Region__c='STH');
        insert rrds2;
        
        test.startTest();
        
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxPO.id, ASI_MFM_Exchange_Rate__c=1.23,ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today(),ASI_MFM_Status__c='Submitted'); 
        insert po;
        
        ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxPO.id, ASI_MFM_Exchange_Rate__c=1.23,ASI_MFM_PO_Start_Date__c=Date.today(),ASI_MFM_PO_End_Date__c=Date.today(),ASI_MFM_Status__c='Submitted'); 
        insert po1;
        
        system.debug('PO Amount: ' + po.ASI_MFM_PO_Amount__c + ' Ex Rate: ' + po.ASI_MFM_Exchange_Rate__c);
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, 
            ASI_MFM_Spread_by_Months__c=true,ASI_MFM_Amount__c=100,ASI_MFM_Distributor_Amount__c=10,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        //delete poi;
        
        //Wilken 20170206 Add test case to cover PO Trigger Class VAP BO type
        po1.ASI_MFM_PO_Type__c = 'VAP Brand Owner';
        po1.ASI_MFM_Status__c = 'Final';
        
        //po.ASI_MFM_Status__c = 'Draft';
        update po1;
        
        
        try {
            delete po;
        }
        catch (Exception e){
        }
        test.stopTest();
    }
    
    static testMethod void testGFPOReceiptTrigger1() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'GF';
        update u;
        
        //Prefix
        List<ASI_MFM_Prefix__c> pxList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear(), ASI_MFM_TR_Rec_Type__c = 'Duty Free');
        pxList.add(px);
        
        ASI_MFM_Prefix__c pxPO = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear(), ASI_MFM_TR_Rec_Type__c = 'Duty Free');
        pxList.add(pxPO);
        
        ASI_MFM_Prefix__c pxPayment = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear(), ASI_MFM_TR_Rec_Type__c = 'Duty Free');
        pxList.add(pxPayment);
        
        insert pxList;
        
        //Role Prefix
        List<ASI_MFM_Role_Prefix_Relationship__c> prList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prList.add(pr);
        
        ASI_MFM_Role_Prefix_Relationship__c prPO = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxPO.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prList.add(prPO);
        
        ASI_MFM_Role_Prefix_Relationship__c prPayment = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxPayment.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        prList.add(prPayment);
        
        insert prList;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
        insert p;       
               
        List<Account> acctList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'), Name='Name3');           
        acctList.add(acc1);
        
        Account acc2 = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Supplier'), Name='Name2');           
        acctList.add(acc2);
        
        insert acctList;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_GF_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Prefix__c=pxPO.id, ASI_MFM_Exchange_Rate__c=1.23, ASI_MFM_PO_Type__c = 'Event FOC', ASI_MFM_Status__c = 'Final'); 
        insert po;
        
        system.debug('PO Amount: ' + po.ASI_MFM_PO_Amount__c + ' Ex Rate: ' + po.ASI_MFM_Exchange_Rate__c);
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='5651 Consumer Event', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_GF_A_C_Code'));
        insert ac;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(name='Customer and Trade Event [Trade AP]', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_GF_AP_Code'), ASI_MFM_A_C_Code__c=ac.Id);
        insert ap;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_GF_Sub_brand'));
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c = 100,
            ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_AP_Code__c=ap.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        test.startTest();
        
        ASI_MFM_PO_Receipt__c Receipt = new ASI_MFM_PO_Receipt__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_GF_PO_Receipt'), ASI_MFM_Receipt_Date__c = date.today());
        insert Receipt;

        ASI_MFM_PO_Receipt_Item__c recItem = new ASI_MFM_PO_Receipt_Item__c(recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_GF_PO_Receipt_item'), ASI_MFM_PO_Line_Item__c=poi.Id, ASI_MFM_PO_Receipt__c=Receipt.Id, ASI_MFM_Amount__c=100, ASI_MFM_PO__c=po.Id);
        insert recItem;
                
        Receipt.ASI_MFM_Status__c = 'Final';
        update Receipt;
        
        po.ASI_MFM_Status__c = 'Complete';
        update po;
                
        test.stopTest();
    }
    
    static testMethod void testGFPaymentTrigger1() {
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_GF_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', ASI_MFM_Prefix__c=px.id);
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
        

        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;

        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_GF_PO_Line_Item'), ASI_MFM_PO__c=po.id,
        ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc1.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today(),
        ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_Amount__c = 100);
        insert poi;
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxa; 
        
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra; 
        
        ASI_MFM_Route_Type__c mrt = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='Payment');
        insert mrt;
        
        ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=mrt.id, ASI_MFM_Prefix__c=pxa.id);
        insert rtm;
        
        list<ASI_MFM_Route_Rule_Detail__c> rtd = new list<ASI_MFM_Route_Rule_Detail__c>();
        
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 0));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 1, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 1));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 2, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 2));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 3, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 3));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 4, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 4));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 5, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 5));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 6, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 6));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 7, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 7));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 8, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 8));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 9, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 9));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 10, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 10));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 10000, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 1));
        rtd.add(new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Route_Type__c = mrt.id, ASI_MFM_Minimum_Amount__c = 0, ASI_MFM_Approver__c=u.id, ASI_MFM_Sequence__c = 999));
        insert rtd;
        
        Test.startTest();
               
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
            ASI_MFM_Currency__c='USD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Status__c='Draft');
        insert py;
        
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');
        insert pyi;
        
        ASI_MFM_Payment__c py1 = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
            ASI_MFM_Currency__c='ABD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Status__c='Draft',ASI_MFM_Is_Direct_Payment__c=true);
        insert py1;
        
        ASI_MFM_Payment_Line_Item__c pyi1 = new ASI_MFM_Payment_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item'), ASI_MFM_Payment__c=py1.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '2234568');
        //insert pyi1;
        
        py.ASI_MFM_Status__c='Final';
        update py;
        
        py1.ASI_MFM_Status__c='Final';
        update py1;
    }
}