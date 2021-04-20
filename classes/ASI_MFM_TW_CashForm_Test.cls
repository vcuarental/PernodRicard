/*Created by Twinkle Li @introv 04/24/2015
*
* Testclass for:
* ASI_MFM_TW_CashForm_Ctrl
* ASI_MFM_TW_CashFormP2_Ctrl
*/

@isTest
public class ASI_MFM_TW_CashForm_Test {
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
    
    //Add By Elufa support 20160428
    public static testMethod void ASI_MFM_TW_CashForm_Ctrl_CheckingTest1(){
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        update u;
        
        List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxp);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxo);
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxy);
        insert prList;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        insert rprList;
        
         ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
        insert ac;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
        insert ap;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
        insert sub;
        
        List<Account> acctList = new List<Account>();     
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));       
        insert acctList;
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        insert listPlan;      
        
        List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=1000));
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_Total_Cost__c=2000));
        insert listPL;
        
         List<ASI_MFM_Exchange_Rate__c> listXR = new List<ASI_MFM_Exchange_Rate__c>();
        listXR.add(new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',
                                                ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1));                                  
        insert listXR;    
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TW_PO'), ASI_MFM_Plan__c=listPlan[0].id,ASI_MFM_Supplier_Name__c = acctList[1].id, ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        List<ASI_MFM_PO_Line_Item__c> poLinelist= new List<ASI_MFM_PO_Line_Item__c> ();
        ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acctList[2].id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
        poLinelist.add(poi1);
         ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acctList[2].id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
        poLinelist.add(poi2);
        insert poLinelist;
        
        ASI_MFM_Approval_Setting__c setting = new ASI_MFM_Approval_Setting__c(Name='TW', ASI_MFM_Direct_Payment_Max_Allowed_Amt__c=1000, ASI_MFM_Payment_Min_Approval_Amt__c=5000,ASI_MFM_Payment_Tolerance_Percent__c=10, ASI_MFM_Payment_Tolerance_Amt__c=5000);
        insert setting;
        
        Test.StartTest();
        Test.setCurrentPage(Page.ASI_MFM_TW_CashForm_Page);
        ApexPages.currentpage().getHeaders().put('Referer', listPlan[0].id);
        
        ASI_MFM_TW_CashForm_Ctrl controller = new ASI_MFM_TW_CashForm_Ctrl(); 
        controller.init();
        
        controller.LSAPHeader[0].pay.ASI_MFM_Plan__c = listPlan[0].id;
        controller.LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c = acctList[1].id;
        controller.LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c = '12345';
        controller.LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c = Date.today();
        controller.LSAPHeader[0].pay.ASI_MFM_Bank_Details__c='Test';
        controller.LSAPHeader[0].pay.ASI_MFM_Currency__c='USD';
        controller.CopyFromPlan();
        controller.SAPL_Item_Map.get(0).payl.ASI_MFM_Payment_Amount__c = 5000;
        controller.SAPL_Item_Map.get(1).payl.ASI_MFM_Payment_Amount__c = 5000;
        
        controller.SaveAction();
        
        controller.SAPL_Item_Map.get(1).payl.ASI_MFM_Payment_Amount__c = 100;
        
        controller.SaveAction();
        
        Test.StopTest();
    }
    
     public static testMethod void ASI_MFM_TW_CashForm_Ctrl_CheckingTest2(){
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        update u;
        
        List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxp);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxo);
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxy);
        insert prList;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
        insert rprList;
        
         ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC', ASI_MFM_A_And_P_Tree__c='Total A&P');
        insert ac;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
        insert ap;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
        insert sub;
        
        List<Account> acctList = new List<Account>();     
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));       
        insert acctList;
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        insert listPlan;      
        
        List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=100));
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =acctList[2].id,
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id,ASI_MFM_Total_Cost__c=200));
        insert listPL;
        
         List<ASI_MFM_Exchange_Rate__c> listXR = new List<ASI_MFM_Exchange_Rate__c>();
        listXR.add(new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',
                                                ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1));                                  
        insert listXR;    
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TW_PO'), ASI_MFM_Plan__c=listPlan[0].id,ASI_MFM_Supplier_Name__c = acctList[1].id, ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        List<ASI_MFM_PO_Line_Item__c> poLinelist= new List<ASI_MFM_PO_Line_Item__c> ();
        ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acctList[2].id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
        poLinelist.add(poi1);
         ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=acctList[2].id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
        poLinelist.add(poi2);
        insert poLinelist;
        
        ASI_MFM_Approval_Setting__c setting = new ASI_MFM_Approval_Setting__c(Name='TW', ASI_MFM_Direct_Payment_Max_Allowed_Amt__c=1000, ASI_MFM_Payment_Min_Approval_Amt__c=5000,ASI_MFM_Payment_Tolerance_Percent__c=10, ASI_MFM_Payment_Tolerance_Amt__c=5000);
        insert setting;
        
        Test.StartTest();
        Test.setCurrentPage(Page.ASI_MFM_TW_CashForm_Page);
        ApexPages.currentpage().getHeaders().put('Referer', listPlan[0].id);
        
        ASI_MFM_TW_CashForm_Ctrl controller = new ASI_MFM_TW_CashForm_Ctrl(); 
        controller.init();
        
        controller.LSAPHeader[0].pay.ASI_MFM_Plan__c = listPlan[0].id;
        controller.LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c = acctList[1].id;
        controller.LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c = '12345';
        controller.LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c = Date.today();
        controller.LSAPHeader[0].pay.ASI_MFM_Bank_Details__c='Test';
        controller.LSAPHeader[0].pay.ASI_MFM_Currency__c='USD';
        controller.CopyFromPlan();
        controller.SAPL_Item_Map.get(0).payl.ASI_MFM_Payment_Amount__c = 1000;
        controller.SAPL_Item_Map.get(1).payl.ASI_MFM_Payment_Amount__c = 1000;
        
         controller.SaveAction();
         controller.SAPL_Item_Map.get(0).payl.ASI_MFM_Payment_Amount__c = 10;
         controller.SAPL_Item_Map.get(1).payl.ASI_MFM_Payment_Amount__c = 20;
         
         controller.SaveAction();

        Test.StopTest();
    }
    
    
    /*For ASI_MFM_TW_CashForm_Ctrl*/
    public static testMethod void ASI_MFM_TW_CashForm_Ctrl_Test() {
        user u = [select userRole.developerName, ASI_MFM_Country__c from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        update u;
        
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan', ASI_MFM_Fiscal_year__c = getFiscalYear());
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
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC');
        insert ac;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
        insert ap;
        
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
        insert sub;
        
        List<Account> acctList = new List<Account>();     
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));           
        insert acctList;
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Draft'));
        listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
        insert listPlan;      
        
        List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=100));
        listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',
                                                 ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=100));
        insert listPL;
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_TW_Payment'), ASI_MFM_Prefix__c=pxy.id, name='test', 
                                                       ASI_MFM_Supplier_Name__c = acctList[1].id, ASI_MFM_Plan__c=listPlan[1].id, ASI_MFM_Payment_Amount__c=1000);
        insert py;
        
        List<ASI_MFM_Exchange_Rate__c> listXR = new List<ASI_MFM_Exchange_Rate__c>();
        listXR.add(new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',
                                                ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1));                                  
        insert listXR;                
        
        ASI_MFM_Approval_Setting__c setting = new ASI_MFM_Approval_Setting__c(Name='TW', ASI_MFM_Direct_Payment_Max_Allowed_Amt__c=1000, ASI_MFM_Payment_Min_Approval_Amt__c=5000,ASI_MFM_Payment_Tolerance_Percent__c=10, ASI_MFM_Payment_Tolerance_Amt__c=5000);
        insert setting;
        
        Test.StartTest();
        Test.setCurrentPage(Page.ASI_MFM_TW_CashForm_Page);
        ApexPages.currentpage().getHeaders().put('Referer', listPlan[0].id);
        
        ASI_MFM_TW_CashForm_Ctrl controller = new ASI_MFM_TW_CashForm_Ctrl(); 
        controller.init();
        
        controller.LSAPHeader[0].pay.ASI_MFM_Plan__c = listPlan[0].id;
        controller.LSAPHeader[0].pay.ASI_MFM_Supplier_Name__c = acctList[1].id;
        controller.LSAPHeader[0].pay.ASI_MFM_Invoice_Number__c = '12345';
        controller.LSAPHeader[0].pay.ASI_MFM_Invoice_Date__c = Date.today();
        controller.CopyFromPlan();
        controller.SAPL_Item_Map.get(0).boolSelected = true;
        controller.Refresh();
        
        controller.SAPL_Item_Map.get(0).payl.ASI_MFM_Payment_Amount__c = 1000;
        controller.SAPL_Item_Map.get(0).AnPTree = 'A&P';
        controller.SaveAction();
        //controller.ValidateRecord();
        controller.SaveRecord();
        controller.Reset();
        
        controller.rowidSAPL = 0;
        controller.Clone_SAPL();
        controller.rowidSAPL = 1;
        ASI_MFM_TW_CashForm_Ctrl.findSObjects('ASI_MFM_Plan__c', '');
        
        //Call Wrapper class
        ASI_MFM_TW_CashForm_Ctrl.SAPHeaderObj hobj = new ASI_MFM_TW_CashForm_Ctrl.SAPHeaderObj();
        String id = hobj.id;     
        hobj.id = '1';
        id = hobj.id;  
        ASI_MFM_TW_CashForm_Ctrl.SAPLineObj sapl_Clone = controller.SAPL_Item_Map.get(0);
        id = sapl_Clone.id;
        sapl_Clone.id = '1';
        id = sapl_Clone.id; 
        sapl_Clone.payl = new ASI_MFM_Payment_Line_Item__c();
        sapl_Clone.payl.ASI_MFM_Payment_List_Item_Description__c = 'abcd';
        sapl_Clone.payl.ASI_MFM_Payment_Date__c = Date.today();
        sapl_Clone.payl.ASI_MFM_Payment_Amount__c = 50;        
        sapl_Clone.pol= new ASI_MFM_PO_Line_Item__c();
        sapl_Clone.pol.ASI_MFM_Sub_brand_Code__c = sub.id;
        sapl_Clone.pol.ASI_MFM_AP_Code__c=ap.id;
        sapl_Clone.pol.ASI_MFM_Customer_Name__c = acctList[0].id;

        Test.StopTest();
    }
    
    /*For ASI_MFM_TW_CashFormP2_Ctrl*/
    public static testMethod void ASI_MFM_TW_CashFormP2_Ctrl_Test(){
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];  
        u.ASI_MFM_Country__c = 'TW';
        update u;
        
        ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Plan', Plan_Type__c='test', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert px;   
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        insert pxo; 
        ASI_MFM_Prefix__c pxa = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment');
        insert pxa; 
             
        ASI_MFM_Role_Prefix_Relationship__c pr = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=px.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pr;
        ASI_MFM_Role_Prefix_Relationship__c pro = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pro;
        ASI_MFM_Role_Prefix_Relationship__c pra = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxa.id, ASI_MFM_Role_Name__c=u.userRole.developerName);
        insert pra; 
        
        ASI_MFM_Plan__c p = new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), 
                                                ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final', 
                                                ASI_MFM_Prefix__c=px.id);
        insert p;
        
        List<Account> acctList = new List<Account>();        
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3'));           
        acctList.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));           
        insert acctList;
           
        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'), name='testSubBrand');
        insert sub;
        
        ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC');
        insert ac;
        
        ASI_MFM_PO__c po = new ASI_MFM_PO__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TW_PO'), ASI_MFM_Plan__c=p.id,ASI_MFM_Supplier_Name__c = acctList[1].id, ASI_MFM_Prefix__c=pxo.id); 
        insert po;
        
        ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_TW_Payment'), ASI_MFM_Prefix__c=pxa.id, name='test', ASI_MFM_Supplier_Name__c = acctList[1].id);
        insert py;
        
        Test.startTest();
        
        apexpages.currentPage().getParameters().put('paid', py.id); 
        apexpages.currentPage().getParameters().put('poid', po.id); 
        
        ASI_MFM_TW_CashFormP2_Ctrl controller = new ASI_MFM_TW_CashFormP2_Ctrl();        
        controller.ViewPayment();
        
        Test.StopTest();
    }
}