@isTest
public with sharing class ASI_MFM_MY_BA_F_PO_TestClass {
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

    static testMethod void BAVerifyTest1()
    {  
        // Start Plan
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_MY_Prefix')); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;    
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
         u.ASI_MFM_Country__c = 'MY';
        update u;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan'), name='test', ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c=Date.today().addMonths(3), ASI_MFM_Plan_Description__c='testPlanDescription',ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Plan_Raised_Date__c=Date.today(), ASI_MFM_Status__c = 'Draft');
        insert p;
        
        ASI_MFM_Plan_Line_Item__c pL =new ASI_MFM_Plan_Line_Item__c(asi_mfm_plan__c=p.id,ASI_MFM_Total_Cost__c=100000,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_MY_Plan_Line_Item'));
        insert pL;
        
        delete pL;
        p.ASI_MFM_Status__c = 'Final';
        update p;
        
        // Start PO
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Customer'),Name='Name3');           
        insert acc2;
        
        Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Supplier'),Name='Name2');     //ASI_MFM_SG_Supplier            
        insert acc1;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_MY_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c = 'Final'); //    Final
        insert po;
        
        System.debug('limit: ' + Limits.getDMLRows());
        list<ASI_MFM_PO_Line_Item__c> poilist = new list<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Amount__c = 100,ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, ASI_MFM_G_L_Date__c = Date.today());
        poilist.add(poi);
        insert poilist;
        
        Test.startTest();

        ASI_MFM_MY_BAVerifyLWCController.getPlanLine(
            null, null, null, false, false, false, 
            null, null, null, null, null, null, null, null, null, null,
            null, null, null, 1, 30
        );

        ASI_MFM_MY_BAVerifyLWCController.getPlanLine(
            '1', '1', '1', true, true, true, 
            '1', '1', '1', '1', '1', '1', '1', '1', '1', System.today(), System.today(),
            '1', '1', 1, 30
        );

        // String planLinesStr = JSON.serialize(poilist);
        // List<String> poList = new List<String>();
        // poList.add(po.Name);
        
        // ASI_MFM_MY_BAVerifyLWCController.savePlanLine(planLinesStr, 'MY', 'MY_Cut_Off_Date', poList);

        test.stopTest();
    }

    static testMethod void BAVerifyTest2()
    {  
        // Start Plan
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_MY_Prefix')); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;    
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
         u.ASI_MFM_Country__c = 'MY';
        update u;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan'), name='test', ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c=Date.today().addMonths(3), ASI_MFM_Plan_Description__c='testPlanDescription',ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Plan_Raised_Date__c=Date.today(), ASI_MFM_Status__c = 'Draft');
        insert p;
        
        ASI_MFM_Plan_Line_Item__c pL =new ASI_MFM_Plan_Line_Item__c(asi_mfm_plan__c=p.id,ASI_MFM_Total_Cost__c=100000,recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_MY_Plan_Line_Item'));
        insert pL;
        
        delete pL;
        p.ASI_MFM_Status__c = 'Final';
        update p;
        
        // Start PO
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_MY_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Customer'),Name='Name3');           
        insert acc2;
        
        Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Supplier'),Name='Name2');     //ASI_MFM_SG_Supplier            
        insert acc1;
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_MY_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c = 'Submitted'); //    Final
        insert po;
        
        System.debug('limit: ' + Limits.getDMLRows());
        list<ASI_MFM_PO_Line_Item__c> poilist = new list<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Amount__c = 100,ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, ASI_MFM_G_L_Date__c = Date.today());
        poilist.add(poi);
        insert poilist;
        
        Test.startTest();

        // ASI_MFM_MY_BAVerifyLWCController.getPlanLine(
        //     null, null, null, false, false, false, 
        //     null, null, null, null, null, null, null, null, null, null,
        //     null, null, null, 1, 30
        // );

        String planLinesStr = JSON.serialize(poilist);
        List<String> poList = new List<String>();
        poList.add(po.Name);
        
        ASI_MFM_MY_BAVerifyLWCController.savePlanLine(planLinesStr, 'MY', 'MY_Cut_Off_Date', poList);

        test.stopTest();
    }

    static testMethod void  FVerifyTest1()
    {    
        // Start Plan
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        preList.add(px);
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        preList.add(pxo); 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        preList.add(pxa); 
        insert preList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'MY';
        update u;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRelationList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pro);   
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pra);
        insert PrefixRelationList;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        
        //Set PO 
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Supplier'),Name='Name2');      
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Customer'),Name='Name3');        
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Supplier'),Name='Name3');      
        accList.add(acc3);
        
        insert accList;
        
        System.debug('limit: ' + Limits.getDMLRows());
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
                
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;

        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;

        System.debug('limit: ' + Limits.getDMLRows());
        
        // Set Payment
        
        Test.startTest();

        list<ASI_MFM_Payment__c> Payments = new list<ASI_MFM_Payment__c>();
        map<Id, ASI_MFM_Payment__c> mapPayments = new map<Id, ASI_MFM_Payment__c>();
        list<ASI_MFM_Payment__c> Pay_LIst = new list<ASI_MFM_Payment__c>();
 
        System.debug('limit: ' + Limits.getDMLRows());
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MY_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Due_Date__c=date.today(),ASI_MFM_Invoice_Date__c=date.today(),ASI_MFM_Invoice_Number__c='Test',
                                                       ASI_MFM_Currency__c='MYR', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_ETL__c = false,ASI_MFM_Status__c='Final');   //acc3.id
        Pay_LIst.add(py);
        insert Pay_LIst;
        
        
        // Set Payment Line Items
        list<ASI_MFM_Payment_Line_Item__c> Payline = new list<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_MY_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id, ASI_MFM_Complete_POL__c=true,ASI_MFM_Status_Invalid__c=true);  
        Payline.add(pyi);
        insert Payline;

        ASI_MFM_MY_FVerifyLWCController.getPaymentLine(
            false, null, null, null, null, null, null, null, null, null, null,
            null, null, null, 1, 30);

        ASI_MFM_MY_FVerifyLWCController.getPaymentLine(
            false, '1', '1', '1', '1', '1', '1', '1', '1', '1', System.today(),
            System.today(), '1', '1', 1, 30);

        // String paymentLinesStr = JSON.serialize(Payline);
        // Map<ID, Boolean> paymentMap = new Map<ID, Boolean>();

        // ASI_MFM_MY_FVerifyLWCController.savePaymentLine (paymentLinesStr, paymentMap);

        ASI_MFM_MY_PORelatedPaymentLWCController.getPayment(po.ID);
        test.stopTest();    
    }

    static testMethod void  FVerifyTest2()
    {    
        // Start Plan
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        preList.add(px);
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        preList.add(pxo); 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        preList.add(pxa); 
        insert preList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'MY';
        update u;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRelationList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pro);   
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pra);
        insert PrefixRelationList;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        
        //Set PO 
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Supplier'),Name='Name2');      
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Customer'),Name='Name3');        
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Supplier'),Name='Name3');      
        accList.add(acc3);
        
        insert accList;
        
        System.debug('limit: ' + Limits.getDMLRows());
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
                
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;

        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;

        // Set Payment
        
        Test.startTest();

        System.debug('limit: ' + Limits.getDMLRows());
        
        list<ASI_MFM_Payment__c> Payments = new list<ASI_MFM_Payment__c>();
        map<Id, ASI_MFM_Payment__c> mapPayments = new map<Id, ASI_MFM_Payment__c>();
        list<ASI_MFM_Payment__c> Pay_LIst = new list<ASI_MFM_Payment__c>();
 
        System.debug('limit: ' + Limits.getDMLRows());
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MY_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Due_Date__c=date.today(),ASI_MFM_Invoice_Date__c=date.today(),ASI_MFM_Invoice_Number__c='Test',
                                                       ASI_MFM_Currency__c='MYR', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_ETL__c = false,ASI_MFM_Status__c='Final');   //acc3.id
        Pay_LIst.add(py);
        insert Pay_LIst;
        
        
        // Set Payment Line Items
        list<ASI_MFM_Payment_Line_Item__c> Payline = new list<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_MY_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id, ASI_MFM_Complete_POL__c=true,ASI_MFM_Status_Invalid__c=true,ASI_MFM_G_L_Date__c=system.today(),ASI_MFM_Payment_Line_Item_Finance_Verify__c=true);  
        Payline.add(pyi);
        insert Payline;

        // ASI_MFM_MY_FVerifyLWCController.getPaymentLine(
        //     false, null, null, null, null, null, null, null, null, null, null,
        //     null, null, null, 1, 30);

        String paymentLinesStr = JSON.serialize(Payline);
        Map<ID, Boolean> paymentMap = new Map<ID, Boolean>();

        ASI_MFM_MY_FVerifyLWCController.savePaymentLine (paymentLinesStr, paymentMap);

        // ASI_MFM_MY_PORelatedPaymentLWCController.getPayment(po.ID);
        test.stopTest();    
    }

    static testMethod void  FVerifyTest3()
    {    
        // Start Plan
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        preList.add(px);
        
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        preList.add(pxo); 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        preList.add(pxa); 
        insert preList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'MY';
        update u;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRelationList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pro);   
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        PrefixRelationList.add(pra);
        insert PrefixRelationList;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        
        //Set PO 
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Supplier'),Name='Name2');      
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Customer'),Name='Name3');        
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_MFM_MY_Supplier'),Name='Name3');      
        accList.add(acc3);
        
        insert accList;
        
        System.debug('limit: ' + Limits.getDMLRows());
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
                
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;

        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        // Set Payment
        
        Test.startTest();

        System.debug('limit: ' + Limits.getDMLRows());
        
        list<ASI_MFM_Payment__c> Payments = new list<ASI_MFM_Payment__c>();
        map<Id, ASI_MFM_Payment__c> mapPayments = new map<Id, ASI_MFM_Payment__c>();
        list<ASI_MFM_Payment__c> Pay_LIst = new list<ASI_MFM_Payment__c>();
 
        System.debug('limit: ' + Limits.getDMLRows());
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_MY_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Invoice_Due_Date__c=date.today(),ASI_MFM_Invoice_Number__c='Test',
                                                       ASI_MFM_Currency__c='MYR', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_ETL__c = false,ASI_MFM_Status__c='Final',ASI_MFM_Invoice_Date__c=date.today());   //acc3.id
        Pay_LIst.add(py);
        insert Pay_LIst;
        
        
        // Set Payment Line Items
        list<ASI_MFM_Payment_Line_Item__c> Payline = new list<ASI_MFM_Payment_Line_Item__c>();
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_MY_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_G_L_Date__c=system.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id, ASI_MFM_Complete_POL__c=true,ASI_MFM_Status_Invalid__c=true,ASI_MFM_Payment_Line_Item_Finance_Verify__c=true);
        Payline.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_MY_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO__c=po.id,ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_G_L_Date__c=system.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id, ASI_MFM_Complete_POL__c=true,ASI_MFM_Status_Invalid__c=true);  
        Payline.add(pyi2);
        insert Payline;

        // ASI_MFM_MY_FVerifyLWCController.getPaymentLine(
        //     false, null, null, null, null, null, null, null, null, null, null,
        //     null, null, null, 1, 30);

        Map<ID, Boolean> paymentMap = new Map<ID, Boolean>();
        String paymentLinesStr = JSON.serialize(Payline);
        ASI_MFM_MY_FVerifyLWCController.savePaymentLine (paymentLinesStr, paymentMap);

        pyi.ASI_MFM_G_L_Date__c=null;
        update Payline;
        ASI_MFM_MY_FVerifyLWCController.savePaymentLine (paymentLinesStr, paymentMap);

        Payline.remove(1);
        pyi.ASI_MFM_Invoice_Date__c=null;
        update Payline;
        paymentLinesStr = JSON.serialize(Payline);
        ASI_MFM_MY_FVerifyLWCController.savePaymentLine (paymentLinesStr, paymentMap);

        // ASI_MFM_MY_PORelatedPaymentLWCController.getPayment(po.ID);
        test.stopTest();    
    }
}