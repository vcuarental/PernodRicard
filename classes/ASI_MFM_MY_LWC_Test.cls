/*
 * TestClass for :
 * ASI_MFM_SelectPlanPrefixLWC_Cls
 * ASI_MFM_SelectPOPrefixLWC_Cls
 * ASI_MFM_SelectPaymentPrefixLWC_Cls
 * ASI_MFM_MY_Payment_SummaryLWC_Cls
 * ASI_MFM_MY_PO_SubmitForApprovalLWC_Cls
 * ASI_MFM_MY_POLineViewLWC_Cls
 * ASI_MFM_MY_PlanViewLWC_Cls
 * ASI_MFM_MY_SubmitForApprovalLWC_Cls
 * ASI_MFM_SG_Pay_SubmitForApprovalLWC_Cls
*/

@isTest
public class ASI_MFM_MY_LWC_Test {

    public static string getFiscalYear(){
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
    
    static testMethod void SelectPlanPrefixTest(){
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'MY';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Prefix__c px2 = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px2;
        
        ASI_MFM_Role_Prefix_Relationship__c pr2 = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px2.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr2;

        Map<String, id> MPlanRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Plan__c');        
        String recType=((String)MPlanRecType.get('ASI_MFM_MY_Plan')).substring(0,15);
        ASI_MFM_SelectPlanPrefixLWC_Cls.getPrefixes(recType);
    }
    
    static testMethod void SelectPOPrefixTest(){
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'MY';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
            
        ASI_MFM_Prefix__c plan_px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear());
        insert plan_px;
        
        ASI_MFM_Role_Prefix_Relationship__c plan_pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=plan_px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert plan_pr;
        
        ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Exchange_Rate__c=1, ASI_MFM_Application__c = 'MFM',ASI_MFM_Base_Currency__c='SGD',ASI_MFM_Counter_Currency__c='SGD',ASI_MFM_Country__c='MY');
    
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_MY_Plan'), name='test',  ASI_MFM_Prefix__c=plan_px.id, ASI_MFM_End_Date__c = Date.today(), ASI_MFM_Plan_Description__c = 'testDescription', ASI_MFM_Plan_Name__c = 'planName test', ASI_MFM_Start_Date__c = Date.today(), ASI_MFM_Status__c = 'Final');
        insert p;
        
        Map<String, id> MPORecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_po__c');        
        String recType=((String)MPORecType.get('ASI_MFM_MY_PO')).substring(0,15);
        ASI_MFM_SelectPOPrefixLWC_Cls.getPrefixes(recType);
        ASI_MFM_SelectPOPrefixLWC_Cls.getInitParam(p.id);
    }
    
    static testMethod void SelectPaymentPrefixTest(){
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'MY';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c=getFiscalYear(),ASI_MFM_Inactive__c = false);
        insert px;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        Map<String, id> MPaymentRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Payment__c');        
        String recType=((String)MPaymentRecType.get('ASI_MFM_MY_Payment')).substring(0,15);
        ASI_MFM_SelectPaymentPrefixLWC_Cls.getPrefixes(recType);
        ASI_MFM_SelectPaymentPrefixLWC_Cls.getInitParam(recType);
    }
    
    static testMethod void PaymentSummaryTest(){
         //Prefix
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415');
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
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_MY_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        
        //Set PO 
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Supplier'),Name='Name2');      
        accList.add(acc1);
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');
        
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_MY_Customer'),Name='Name3');        
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Supplier'),Name='Name3');      
        accList.add(acc3);
        
        insert accList;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        
        
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10,ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        
        // Set Payment
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        
        
        
        list<ASI_MFM_Payment__c> Payments = new list<ASI_MFM_Payment__c>();
        map<Id, ASI_MFM_Payment__c> mapPayments = new map<Id, ASI_MFM_Payment__c>();
        list<ASI_MFM_Payment__c> Pay_LIst = new list<ASI_MFM_Payment__c>();
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c'); 
        System.debug(Limits.getDMLRows());
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_MY_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
                                                       ASI_MFM_Currency__c='MYR', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_ETL__c = false,ASI_MFM_Status__c='Final');   //acc3.id
        Pay_LIst.add(py);
        
        ASI_MFM_Payment__c py1 = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_MY_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),
                                                        ASI_MFM_Currency__c='MYR', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Invalid',ASI_MFM_ETL__c = false);   
        Pay_LIst.add(py1); 
        insert Pay_LIst;
        
        
        // Set Payment Line Items
        list<ASI_MFM_Payment_Line_Item__c> Payline = new list<ASI_MFM_Payment_Line_Item__c>();
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id, ASI_MFM_Complete_POL__c=true,ASI_MFM_Status_Invalid__c=true);  
        Payline.add(pyi);
        ASI_MFM_Payment_Line_Item__c pyi2 = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456',ASI_MFM_Payee__c=acc3.id, ASI_MFM_Complete_POL__c=false,ASI_MFM_Status_Invalid__c=false);  
        Payline.add(pyi2);
        insert Payline;
       // delete pyi2; // ASI_MFM_MY_PaymentLineItem_TriggerClass
        ASI_MFM_MY_Payment_SummaryLWC_Cls.ReturnValue testcase;
        string soql='select id, name,ASI_MFM_ETL__c,ASI_MFM_ETL_Date__c,ASI_MFM_Payment__r.ASI_MFM_Invoice_Number__c,ASI_MFM_AC_Remark__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Voucher_Created__c,ASI_MFM_G_L_Date__c,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__c,ASI_MFM_Complete_POL__c,ASI_MFM_Finance_Verify_Save_Date__c,ASI_MFM_A_C_Code__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c,ASI_MFM_ETL_Failed__c,ASI_MFM_Comments__c,ASI_MFM_Payment__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_Payment_Date__c,ASI_MFM_Invoice_Date__c, ASI_MFM_Paid_Amount_in_Base_Currency__c,ASI_MFM_Status_Invalid__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__c, ASI_MFM_Payment__c, ASI_MFM_Payee__c, ASI_MFM_Currency__c , ASI_MFM_PO_Line_Remaining_Amount__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Due_Date__c, ASI_MFM_Payment__r.ASI_MFM_Status__c,ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_Withholding_Tax__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\' ';
        string soqlSubbrand='select ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Payment_Amount__c) TPA, sum(ASI_MFM_Paid_Amount_in_Base_Currency__c) TPABC from ASI_MFM_Payment_Line_Item__c where (ASI_MFM_Due_Date__c >= TODAY OR ASI_MFM_Due_Date__c = NULL) AND  ASI_MFM_Payment__r.ASI_MFM_ETL__c = false AND ASI_MFM_Payment__r.ASI_MFM_Status__c != \'Draft\' AND  ASI_MFM_Payment__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_Payment%\'  ';
        testcase = ASI_MFM_MY_Payment_SummaryLWC_Cls.RunQuery(soql,soqlSubbrand,soql);
        Test.stopTest();

    }
    
    static testMethod void MY_PO_SubmitForApproval(){
        
        map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        List<ASI_MFM_Prefix__c> preList = new List<ASI_MFM_Prefix__c>();
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415', recordTypeId = pxrt_map.get('ASI_MFM_MY_Prefix')); // Insert Custom Fields & Relationships API Name   FY1415
        preList.add(px);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        preList.add(pxo);
        insert preList;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'MY';
        update u;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> preRList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        preRList.add(pr);
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        preRList.add(pro);
        insert preRList;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_MY_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Supplier'),Name='Name2');           
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Customer'),Name='Name3');           
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Supplier'),Name='Name3');           
        accList.add(acc3);
        
        insert accList;
        
        ASI_MFM_Route_Type__c rts = new ASI_MFM_Route_Type__c(name='test', ASI_MFM_Module__c='PO');
        insert rts;
        
        ASI_MFM_Brand_Route_Type_Map__c rtms = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rts.id, ASI_MFM_Prefix__c=pxo.id);
        insert rtms;
        
        // ASI MFM  PO Route Rule Details Set Approver 
        ASI_MFM_Route_Rule_Detail__c rrds = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=1);
        insert rrds;
        ASI_MFM_Route_Rule_Detail__c rrds2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=2, ASI_MFM_Route_Type__c=rts.id,ASI_MFM_Sequence__c=2);
        insert rrds2;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        List<ASI_MFM_PO__c> poList = new List<ASI_MFM_PO__c>();
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');
        poList.add(po);
        ASI_MFM_PO__c po1 = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                              ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');
        poList.add(po1);
        ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                              ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');
        poList.add(po2);
         ASI_MFM_PO__c po3= new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                              ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');
        poList.add(po3);
         ASI_MFM_PO__c po4 = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                              ASI_MFM_Currency__c='MYR', ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c='Draft');
        poList.add(po4);
        insert poList;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c'); 
        List<ASI_MFM_PO_Line_Item__c> polineList = new List<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Amount__c=50001,ASI_MFM_Base_Currency_Amount__c=50001,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        polineList.add(poi);// Base_Currency_Amount__c>50000,but don't include attachments
        ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po1.id,ASI_MFM_Base_Currency_Amount__c=10001,ASI_MFM_Amount__c=10001,
                                                                   ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        polineList.add(poi1);// _Base_Currency_Amount__c>10000,but include attachments
        ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po3.id,ASI_MFM_Base_Currency_Amount__c=100,ASI_MFM_Amount__c=100,
                                                                   ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        polineList.add(poi2);// PO without PO Line
        ASI_MFM_PO_Line_Item__c poi3 = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po4.id,ASI_MFM_Base_Currency_Amount__c=10001,ASI_MFM_Amount__c=10001,
                                                                   ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        polineList.add(poi3);//Base_Currency_Amount__c<10000
        insert polineList;
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        
        
        List<Attachment> attList = new List<Attachment>();
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=po1.id;
        attList.add(attach);
        
        Attachment attach1=new Attachment();    
        attach1.Name='Unit Test Attachment';
        Blob bodyBlob1=Blob.valueOf('Unit Test Attachment Body');
        attach1.body=bodyBlob1;
        attach1.parentId=po1.id;
        attList.add(attach1);
        
        insert attList;
        
        ASI_MFM_MY_PO_SubmitForApprovalLWC_Cls.InitParam TestInitParam;
        TestInitParam = ASI_MFM_MY_PO_SubmitForApprovalLWC_Cls.getInitParam(po.Id);
        TestInitParam = ASI_MFM_MY_PO_SubmitForApprovalLWC_Cls.getInitParam(po1.Id);
        TestInitParam = ASI_MFM_MY_PO_SubmitForApprovalLWC_Cls.getInitParam(po2.Id);
        TestInitParam = ASI_MFM_MY_PO_SubmitForApprovalLWC_Cls.getInitParam(po3.Id);
        TestInitParam = ASI_MFM_MY_PO_SubmitForApprovalLWC_Cls.getInitParam(po4.Id);
        Test.stopTest();
    }
     
    static testMethod void POLineViewTest(){
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c'); 
        map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        //Map<string, id> planlineItem_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan_Line_Item__c');
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1415', recordTypeId = pxrt_map.get('ASI_MFM_MY_Prefix')); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;    
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
         u.ASI_MFM_Country__c = 'MY';
        update u;
        
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_MY_Plan'), name='test', ASI_MFM_Prefix__c=px.id, ASI_MFM_End_Date__c=Date.today().addMonths(3), ASI_MFM_Plan_Description__c='testPlanDescription',ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Plan_Raised_Date__c=Date.today(), ASI_MFM_Status__c = 'Final');//Draft
        insert p;
        
        // Start PO
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_MFM_MY_Sub_brand'));
        insert subBrand1;
        
        map<string, id> rt_map2 = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        rt_map2 = ASI_MFM_Function.getRecordTypeId('Account');   
        Account acc2 = new Account(recordTypeId=rt_map2.get('ASI_MFM_MY_Customer'),Name='Name3');           
        insert acc2;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Supplier'),Name='Name2');     //ASI_MFM_SG_Supplier            
        insert acc1;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');             
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO'), name='test', ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acc1.id,ASI_MFM_Status__c = 'Submitted'); //    Final
        insert po;
        
        Test.startTest();
        System.debug(Limits.getDMLRows());
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c'); 
        list<ASI_MFM_PO_Line_Item__c> poilist = new list<ASI_MFM_PO_Line_Item__c>();
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Amount__c = 50000,ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, ASI_MFM_G_L_Date__c = Date.today());
        poilist.add(poi);
        ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_MY_PO_Line_Item'), ASI_MFM_PO__c=po.id,ASI_MFM_Spread_by_Months__c=true,ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=subBrand1.id, ASI_MFM_G_L_Date__c = Date.today());
        poilist.add(poi1);
        insert poilist;
        ASI_MFM_MY_POLineViewLWC_Cls.ReturnValue testcase;
        string soql='select id, name,RecordType.DeveloperName,ASI_MFM_Base_Currency_Amount__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Invoice_Number__c,ASI_MFM_PO__r.ASI_MFM_Status__c, ASI_MFM_PO__r.ASI_MFM_Exchange_Rate__c,ASI_MFM_Base_Currency_Remaining_Balance__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.name,ASI_MFM_PO__r.ASI_MFM_PO_Name__c,ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c,ASI_MFM_PO_Supplier_Number__c, ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_SG_BA_verify__c,ASI_MFM_PO__c,ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c,ASI_MFM_PO__r.ASI_MFM_PO_Amount__c,ASI_MFM_Amount__c,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_Currency__c,ASI_MFM_Remaining_Balance__c,ASI_MFM_G_L_Date__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        string soqlSubbrand='select ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Base_Currency_Amount__c) TotalOPO, sum(ASI_MFM_Base_Currency_Remaining_Balance__c) TotalRPO from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        string soqlpo='select id,name,Owner.name,ASI_MFM_Supplier_Name__r.name ,ASI_MFM_Plan__r.name,ASI_MFM_BU_Code__r.name,ASI_MFM_PO_Name__c,ASI_MFM_BU_Code__c,ASI_MFM_Plan__c,ASI_MFM_Sys_Plan_Amount__c,ASI_MFM_Plan_Balance__c,ASI_MFM_Sys_Plan_Name__c,ASI_MFM_Supplier_Name__c,ASI_MFM_Supplier_Number__c,ASI_MFM_Currency__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_PO_Raised_Date__c,ASI_MFM_Remarks__c,ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c,ASI_MFM_Status__c,ASI_MFM_PO_Amount__c,ASI_MFM_PO_Balance__c,ASI_MFM_Payment_Request_Amount__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_Base_Currency_Amount__c    from ASI_MFM_PO__c where ASI_MFM_PO_Amount__c>=0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_PO%\' ';
        testcase = ASI_MFM_MY_POLineViewLWC_Cls.RunQuery(soql,soqlSubbrand,soqlpo,soql);
        Test.stopTest();

    }
    
    static testMethod void PlanViewTest(){
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c='FY1314');
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
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_MFM_MY_Sub_brand'));
        insert subBrand1;
        
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_MY_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today().addMonths(1),
            ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName');
        insert p1;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_MY_Supplier'),Name='Name2');      
        insert acc2;
        
        ASI_MFM_Plan_Line_Item__c pi = new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_MY_Plan_Line_Item'), ASI_MFM_Plan__c=p1.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Cost__c=10
            														,ASI_MFM_Sub_brand_Code__c = subBrand1.id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_List_Item_Description__c='testDescription');
        insert pi;
        
        p1 = [select recordTypeId, ASI_MFM_Cloned_Plan_ID__c, ASI_MFM_Prefix__c,ASI_MFM_End_Date__c, ASI_MFM_Plan_Description__c, ASI_MFM_Plan_Name__c, ASI_MFM_Start_Date__c from ASI_MFM_Plan__c where id = :p1.id];
            
        Test.startTest();
        ASI_MFM_MY_SubmitForApprovalLWC_Cls.InitParam TestInitParam;
        TestInitParam = ASI_MFM_MY_SubmitForApprovalLWC_Cls.getInitParam(p1.Id);
       // delete pyi2; // ASI_MFM_MY_PaymentLineItem_TriggerClass
        ASI_MFM_MY_PlanViewLWC_Cls.ReturnValue testcase;
        String soqlSubbrandplan='select id, name,Owner.name,ASI_MFM_Plan_Name__c,ASI_MFM_Plan_Description__c,ASI_MFM_End_Date__c,ASI_MFM_Start_Date__c,ASI_MFM_Fiscal_year__c,ASI_MFM_Status__c,ASI_MFM_Plan_Raised_Date__c,ASI_MFM_Plan_Amount__c,ASI_MFM_Total_PO_Amount__c,ASI_MFM_Plan_Balance__c  from ASI_MFM_Plan__c where ASI_MFM_Plan_Amount__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        String soql='select id,name,ASI_MFM_Plan__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Total_PO_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c,ASI_MFM_Plan__r.name,ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c,ASI_MFM_Plan__r.ASI_MFM_Status__c,ASI_MFM_Plan_id_sys__c,ASI_MFM_Plan_Name_sys__c,ASI_MFM_Sub_brand_Code__r.name,ASI_MFM_List_Item_Description__c,ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.name,ASI_MFM_Customer_Name__c,ASI_MFM_Total_Cost__c,ASI_MFM_Number_of_Outlets__c,ASI_MFM_Expected_Volume__c,ASI_MFM_Size__c,ASI_MFM_BU_Code__c from ASI_MFM_Plan_Line_Item__c where  ASI_MFM_Total_Cost__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        String soqlSubbrand='select ASI_MFM_Sub_brand_Code__r.name Name, sum(ASI_MFM_Total_Cost__c) TotalPLI from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Total_Cost__c>0  AND RecordType.DeveloperName LIKE \'ASI_MFM_MY_Plan%\' ';
        testcase = ASI_MFM_MY_PlanViewLWC_Cls.RunQuery(soqlSubbrand,soql,soqlSubbrandplan,soql);
        Test.stopTest();

    }
    
    static testMethod void SG_Payment_SubmitForApproval(){ 
        //copy from ASI_MFM_PaymentSubmitControllerTest    
        map<string, id> pxrt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Prefix__c'); 
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c=getFiscalYear(), recordTypeId = pxrt_map.get('ASI_MFM_SG_Prefix'), ASI_MFM_Location__c = 'Singapore'); // Insert Custom Fields & Relationships API Name   FY1415
        insert px;
        
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c = 'SG';
        update u;
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Plan__c');       
        ASI_MFM_Plan__c p1 = new ASI_MFM_Plan__c(recordTypeId=rt_map.get('ASI_MFM_SG_Plan'), ASI_MFM_Prefix__c=px.id, ASI_MFM_Start_Date__c=date.today(), ASI_MFM_End_Date__c=date.today(),
                                                 ASI_MFM_Plan_Description__c='planDescription', ASI_MFM_Plan_Name__c='testplanName', ASI_MFM_Status__c = 'Final');
        insert p1;
        
        px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert px;
        
        ASI_MFM_Exchange_Rate__c ex = new ASI_MFM_Exchange_Rate__c(ASI_MFM_Exchange_Rate__c=1, ASI_MFM_Application__c = 'MFM',ASI_MFM_Base_Currency__c='SGD',ASI_MFM_Counter_Currency__c='SGD',ASI_MFM_Country__c='SG');
    
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name2');           
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Outlet'),Name='Name3');           
        accList.add(acc2);
        
        Account acc3 = new Account(recordTypeId=rt_map.get('ASI_CRM_SG_Supplier'),Name='Name3'); // ASI_CRM_SG_Supplier          
        accList.add(acc3);
        
        insert accList;
        
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO__c');         
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO');
        insert pxo;
        
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro; 
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO'), ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Plan__c=p1.id, ASI_MFM_PO_Raised_Date__c=date.today(),
                                             ASI_MFM_Currency__c='SGD', ASI_MFM_Supplier_Name__c = acc1.id);
        insert po;
        //--------------------Change-----------------------
        list<ASI_MFM_Payment__c> Payments = new list<ASI_MFM_Payment__c>();
        map<Id, ASI_MFM_Payment__c> mapPayments = new map<Id, ASI_MFM_Payment__c>();
        //--------------------Change End-----------------------
        
        
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC');
        insert ac;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand');
        insert sub;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');       
        ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c = 100,
                                                                  ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Customer_Name__c=acc2.id, ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id, ASI_MFM_G_L_Date__c = Date.today());
        insert poi;
        
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        
        insert pxa; 
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra;
        
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c'); 
        Test.startTest(); //20160901, updated on staging
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Draft');  //ASI_MFM_Payee__c    
        insert py;
        
        //ASI_MFM_Payment__c py1 = new ASI_MFM_Payment__c(recordTypeId=rt_map.get('ASI_MFM_SG_Payment'), ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Payment_Date__c=date.today(),ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=100,ASI_MFM_Supplier_Name__c = acc3.id,ASI_MFM_Status__c='Draft');  //ASI_MFM_Payee__c    
        //insert py1;
        //Test.startTest(); //20160901, updated on staging
        System.debug(Limits.getDMLRows());
        rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment_Line_Item__c');      
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c(recordTypeId=rt_map.get('ASI_MFM_SG_Payment_Line_Item'), ASI_MFM_Payment__c=py.id, ASI_MFM_Payment_Amount__c=10, ASI_MFM_PO_Line_Item__c=poi.id, ASI_MFM_Invoice_Date__c = date.today(), ASI_MFM_Invoice_Number__c = '123456');
        insert pyi;
        
        ASI_MFM_SG_Pay_SubmitForApprovalLWC_Cls.InitParam TestInitParam;
        TestInitParam = ASI_MFM_SG_Pay_SubmitForApprovalLWC_Cls.getInitParam(py.Id);
        
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=py.id;
        insert attach;
        
        //ASI_MFM_PaymentSubmitController ext1 = new ASI_MFM_PaymentSubmitController(new ApexPages.StandardController(py));
        //ext1.setStatus();
        //ext1.proceed();
        //ASI_MFM_SG_Pay_SubmitForApprovalLWC_Cls.InitParam TestInitParam;
        TestInitParam = ASI_MFM_SG_Pay_SubmitForApprovalLWC_Cls.getInitParam(py.Id);
        Test.stopTest();
        
    }
    
}