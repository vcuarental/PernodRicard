/*
*    PH MFM
*    Help Create PH Data
*    Call Class
*/
@isTest
public class ASI_MFM_PH_TestClassHelper {

   
   
   
   
   
   
   
    //
    public static void createMFMDefaultValues(){
        ASI_MFM_Default_Value__c defaultVal = new ASI_MFM_Default_Value__c(Name = 'PH_DF_Customer_Name__c',ASI_MFM_Value__c = createDFAccount()[1].id,Country__c = 'PH');
        insert defaultVal;

        
    }

    
    
    
    
    
    //----------------------------------------------------------Fiscal Year---------------------------------------------------------------------------------------
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
    
    //--------------------------------------Create A/C code------------------------------------------
    public static ASI_MFM_A_C_Code__c createACPHDPCode()
    {
        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_PH_DP_A_C_Code')
        );
        insert acCode;
        return acCode;
    }
    
    public static ASI_MFM_A_C_Code__c createACPHDFCode()
    {
        ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
            Name='testAcCode',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_PH_DF_A_C_Code')
        );
        insert acCode;
        return acCode;
    }
    
    //------------------------------------------------------Create Sub-Brand ------------------------------------------------------------------------------------------------------------------------
    
    public static ASI_MFM_Sub_brand__c CreateDPSBrand(){
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_MFM_PH_DP_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode');
        insert subBrand1;
        return subBrand1;
    }
    
     public static ASI_MFM_Sub_brand__c CreateDFSBrand(){
        
        Map<string, id> subBrandCode_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');  
        ASI_MFM_Sub_brand__c subBrand1 = new ASI_MFM_Sub_brand__c(Name='subBrand1',recordTypeId=subBrandCode_map.get('ASI_MFM_PH_DF_Sub_brand'), ASI_MFM_Sub_brand_Code__c = 'testcode');
        insert subBrand1;
        return subBrand1;
    }
    
    
      //--------------------------------------Create  Prefix-----------------------------------------
      //Plan Prefix
    public static ASI_MFM_Prefix__c createPHDFPrefixPlan ()
    {
        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        ASI_MFM_Prefix__c prefixPHDP = new ASI_MFM_Prefix__c
            (
                Name = 'PHTest',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_PH_DF_Prefix'),
                ASI_MFM_Module__c = 'Plan',
                ASI_MFM_Fiscal_year__c = getFiscalYear()
            );
        insert prefixPHDP;
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
            (
                ASI_MFM_Prefix__c = prefixPHDP.id,
                ASI_MFM_Role_Name__c = r.DeveloperName
            );
        insert rel;
        return prefixPHDP;
    }
    
    
    
    public static ASI_MFM_Prefix__c createPHDPPrefixPlan ()
    {
        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        ASI_MFM_Prefix__c prefixPHDF = new ASI_MFM_Prefix__c
            (
                Name = 'PHTest',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_PH_DP_Prefix'),
                ASI_MFM_Module__c = 'Plan',
                ASI_MFM_Fiscal_year__c = getFiscalYear()
            );
        insert prefixPHDF;
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
            (
                ASI_MFM_Prefix__c = prefixPHDF.id,
                ASI_MFM_Role_Name__c = r.DeveloperName
            );
        insert rel;
        return prefixPHDF;
    }
    
    
     public static ASI_MFM_Prefix__c createPHDFMultiPrefixPlan ()
    {
        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        list<ASI_MFM_Prefix__c> prelist =new list<ASI_MFM_Prefix__c>();    
        ASI_MFM_Prefix__c prefixPHDF = new ASI_MFM_Prefix__c
            (
                Name = 'PHTest',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_PH_DF_Prefix'),
                ASI_MFM_Module__c = 'Plan',
                ASI_MFM_Fiscal_year__c = getFiscalYear()
            );
        prelist.add(prefixPHDF);    
        ASI_MFM_Prefix__c prefixPHDF2 = new ASI_MFM_Prefix__c
            (
                Name = 'PHTest2',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_PH_DF_Prefix'),
                ASI_MFM_Module__c = 'Plan',
                ASI_MFM_Fiscal_year__c = getFiscalYear()
            );    
        prelist.add(prefixPHDF2); 
        insert prelist;
        
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        list<ASI_MFM_Role_Prefix_Relationship__c> rel_list =new list<ASI_MFM_Role_Prefix_Relationship__c>(); 
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
            (
                ASI_MFM_Prefix__c = prefixPHDF.id,
                ASI_MFM_Role_Name__c = r.DeveloperName
            );
        rel_list.add(rel);    
        ASI_MFM_Role_Prefix_Relationship__c rel2 = new ASI_MFM_Role_Prefix_Relationship__c
            (
                ASI_MFM_Prefix__c = prefixPHDF2.id,
                ASI_MFM_Role_Name__c = r.DeveloperName
            );
        rel_list.add(rel2);      
        insert rel_list;
        return prefixPHDF;
    }
    
    	
     public static ASI_MFM_Prefix__c createPHDPMultiPrefixPlan ()
    {
        user u = [SELECT ID, ASI_MFM_Country__c FROM user WHERE ID = : userinfo.getUserID()];
        u.ASI_MFM_Country__c = 'PH';
        update u;
        list<ASI_MFM_Prefix__c> prelist =new list<ASI_MFM_Prefix__c>();    
        ASI_MFM_Prefix__c prefixPHDP = new ASI_MFM_Prefix__c
            (
                Name = 'DPTest',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_PH_DP_Prefix'),
                ASI_MFM_Module__c = 'Plan',
                ASI_MFM_Fiscal_year__c = getFiscalYear()
            );
        prelist.add(prefixPHDP);    
        ASI_MFM_Prefix__c prefixPHDP2 = new ASI_MFM_Prefix__c
            (
                Name = 'PHTest2',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_PH_DP_Prefix'),
                ASI_MFM_Module__c = 'Plan',
                ASI_MFM_Fiscal_year__c = getFiscalYear()
            );    
        prelist.add(prefixPHDP2); 
        insert prelist;
        
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        list<ASI_MFM_Role_Prefix_Relationship__c> rel_list =new list<ASI_MFM_Role_Prefix_Relationship__c>(); 
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
            (
                ASI_MFM_Prefix__c = prefixPHDP.id,
                ASI_MFM_Role_Name__c = r.DeveloperName
            );
        rel_list.add(rel);    
        ASI_MFM_Role_Prefix_Relationship__c rel2 = new ASI_MFM_Role_Prefix_Relationship__c
            (
                ASI_MFM_Prefix__c = prefixPHDP2.id,
                ASI_MFM_Role_Name__c = r.DeveloperName
            );
        rel_list.add(rel2);      
        insert rel_list;
        return prefixPHDP;
    }
    
    
    
    
    //PO Prefix 
    public static ASI_MFM_Prefix__c createDFPrefixPO ()
    {
        ASI_MFM_Prefix__c prefixPHDF = new ASI_MFM_Prefix__c
        (
            Name = 'DFTest',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_PH_DF_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert prefixPHDF;
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixPHDF.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;
        return prefixPHDF;
    }
    
    
      public static ASI_MFM_Prefix__c createDPPrefixPO ()
    {
        ASI_MFM_Prefix__c prefixPHDP = new ASI_MFM_Prefix__c
        (
            Name = 'PHTest1',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_PH_DP_Prefix'),
            ASI_MFM_Module__c = 'PO',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert prefixPHDP;
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixPHDP.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;
        return prefixPHDP;
    }
    
    
        //Payment Prefix    
    public static ASI_MFM_Prefix__c createPrefixDFPayment ()
    {
        ASI_MFM_Prefix__c prefixPHDF = new ASI_MFM_Prefix__c
        (
            Name = 'PHTest1',
            recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_PH_DP_Prefix'),
            ASI_MFM_Module__c = 'Payment',
            ASI_MFM_Fiscal_year__c = getFiscalYear()
        );
        insert prefixPHDF;
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE ID = : userinfo.getUserRoleId() ];
        ASI_MFM_Role_Prefix_Relationship__c rel = new ASI_MFM_Role_Prefix_Relationship__c
        (
            ASI_MFM_Prefix__c = prefixPHDF.id,
            ASI_MFM_Role_Name__c = r.DeveloperName
        );
        insert rel;
        return prefixPHDF;
    }
    
    
    //------------------------------------------------------------------Create Supplier------------------------------------------------------
     public static Account createPHSupplier ()
    {
        Account acc = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_PH_Supplier'), Name='Name3');
        insert acc;
        return acc;
    }
    
    
      //------------------------------------------------------------------Create DP Account------------------------------------------------------
     public static List<Account> createDPAccount()
    {
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_PH_Supplier'),Name='Name2');  
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_PH_DP_Customer'),Name='Name3');          
        accList.add(acc2);
        
        insert accList;
        return accList;
    }
    
      public static List<Account> createDFAccount()
    {
        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(recordTypeId=rt_map.get('ASI_MFM_PH_Supplier'),Name='Name2');  
        accList.add(acc1);
        
        Account acc2 = new Account(recordTypeId=rt_map.get('ASI_MFM_PH_DF_Customer'),Name='Name3');          
        accList.add(acc2);
        
        insert accList;
        return accList;
    }
    
    
     //------------------------------------------------------------------Create Plan------------------------------------------------------
    
    public static ASI_MFM_Plan__c createPHDPPlan()
    {
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
            (
                Name = 'Test Plan1',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DP_Plan'),
                ASI_MFM_Start_Date__c = date.today().adddays(1),
                ASI_MFM_End_Date__c = date.today().adddays(1),
                ASI_MFM_Prefix__c = createPHDPPrefixPlan().id
            );
        
        insert plan;
        return plan;
    }
    
     public static ASI_MFM_Plan__c createPHDPPlanReadOnly()
    {
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
            (
                Name = 'Test Plan1',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DP_Plan_Read_Only'),
                ASI_MFM_Plan_Name__c='Test',
                ASI_MFM_Start_Date__c = date.today().adddays(1),
                ASI_MFM_End_Date__c = date.today().adddays(1),
                ASI_MFM_Status__c='Final',
                ASI_MFM_Prefix__c = createPHDPPrefixPlan().id
            );
        
        insert plan;
        return plan;
    }
    
        public static ASI_MFM_Plan__c createPHDFPlan()
    {
        ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
            (
                Name = 'Test Plan2',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan'),
                ASI_MFM_Start_Date__c = date.today().adddays(1),
                ASI_MFM_End_Date__c = date.today().adddays(1),
                ASI_MFM_Prefix__c = createPHDFPrefixPlan().id
            );
        
        insert plan;
        return plan;
    }
    
    
    
    
       //--------------------------------------Create Plan Line ----------------------------------------
    public static ASI_MFM_Plan_Line_Item__c createPHPlanLines1(ASI_MFM_Plan__c plan)
    {
        ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
            (
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_PH_Plan_Line_Item'),
                ASI_MFM_List_Item_Description__c = 'test description',
                ASI_MFM_Total_Cost__c = 1234,
                ASI_MFM_Plan__c = plan.id,
                ASI_MFM_Sub_brand_Code__c=CreateDPSBrand().id,
                ASI_MFM_A_C_Code__c=createACPHDPCode().id,
                ASI_MFM_Customer_Name__c=createDPAccount()[1].id
            );
        insert planLine;
        return planLine;
    }
    
    //For Failed Case
        public static ASI_MFM_Plan_Line_Item__c createPHPlanLines2(ASI_MFM_Plan__c plan)
    {
        ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
            (
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_PH_Plan_Line_Item'),
                ASI_MFM_List_Item_Description__c = 'test description',
                ASI_MFM_Plan__c = plan.id
               
            );
        insert planLine;
        return planLine;
    }
    
    
    
    
    
    //-----------------------------------------------Create PO-------------------------------------------------------------------------
    
    
     public static ASI_MFM_PO__c createPHDPPO(ASI_MFM_Plan__c plan)
    {
        ASI_MFM_PO__c po = new ASI_MFM_PO__c
            (
                Name = 'Test po',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DP_PO'),
                ASI_MFM_PO_Start_Date__c = date.today().adddays(1),
                ASI_MFM_PO_End_Date__c = date.today().adddays(1),
                ASI_MFM_Prefix__c = createDPPrefixPO().id,
                ASI_MFM_Tax_Rate__c='0%',
                ASI_MFM_Plan__c = plan.id
            );
        
        insert po;
        return po;
    }
    
    
    
     public static ASI_MFM_PO__c createPHDPPO2(ASI_MFM_Plan__c plan)
    {
        ASI_MFM_PO__c po = new ASI_MFM_PO__c
            (
                Name = 'Test po',
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_PH_DP_PO'),
                ASI_MFM_PO_Start_Date__c = date.today().adddays(1),
                ASI_MFM_PO_End_Date__c = date.today().adddays(1),
                ASI_MFM_Prefix__c = ASI_MFM_PH_TestClassHelper.createDPPrefixPO().id,
                ASI_MFM_Tax_Rate__c='0%',
                ASI_MFM_Plan__c = plan.id,
                ASI_MFM_Status__c='Final'
            );
        
        insert po;
        return po;
    }
    
    
     //-----------------------------------------------Create PO Line-------------------------------------------------------------------------
     public static ASI_MFM_PO_Line_Item__c createPHPOLines1(ASI_MFM_PO__c po)
    {
        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
            (
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'),
                ASI_MFM_List_Item_Description__c = 'test description',
                ASI_MFM_Amount__c = 124,
                ASI_MFM_G_L_Date__c=date.today().adddays(1),
                ASI_MFM_PO__c = po.id,
                ASI_MFM_Sub_brand_Code__c=CreateDPSBrand().id,
                ASI_MFM_A_C_Code__c=createACPHDPCode().id,
                ASI_MFM_Customer_Name__c=createDPAccount()[1].id
            );
        insert poLine;
        return poLine;
    }
    
     public static ASI_MFM_PO_Line_Item__c createPHPOLines2(ASI_MFM_PO__c po)
    {
        ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c
            (
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item'),
                ASI_MFM_List_Item_Description__c = 'test description',
                ASI_MFM_Amount__c = 124,
                ASI_MFM_G_L_Date__c=date.today(),
                ASI_MFM_PO__c = po.id,
                ASI_MFM_Sub_brand_Code__c=CreateDPSBrand().id,
                ASI_MFM_A_C_Code__c=createACPHDPCode().id,
                ASI_MFM_Customer_Name__c=createDPAccount()[1].id
            );
        insert poLine;
        return poLine;
    }
    
    //-----------------------------------------------Create Payment-------------------------------------------------------------------------
    
    
    
    public static ASI_MFM_Payment__c createDFPayment()
    {
        ASI_MFM_Payment__c payment = new ASI_MFM_Payment__c
        (
            ASI_MFM_Currency__c = 'PHP',
            ASI_MFM_Prefix__c= createPrefixDFPayment().id,
            ASI_MFM_Supplier_Name__c =createDPAccount()[0].id,
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_PH_DF_Payment'),
            ASI_MFM_Status__c = 'Draft',
            ASI_MFM_Invoice_Date__c = date.today(),
            ASI_MFM_Invoice_Number__c = '123Test'
        );
        insert payment;
        return payment;
    }
    
    
    
    
    
    
    
    
    
    
    //-----------------------------------------------Create Payment Line-------------------------------------------------------------------------
    
    
    
    
    
      public static ASI_MFM_Payment_Line_Item__c createPaymentLines(ASI_MFM_Payment__c payment, ASI_MFM_PO_Line_Item__c poi)
    {
        ASI_MFM_Payment_Line_Item__c pyi = new ASI_MFM_Payment_Line_Item__c
        (
        recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_PH_Payment_Line_Item'),
        ASI_MFM_Payment__c=payment.id, 
        ASI_MFM_Payment_Amount__c=10, 
        ASI_MFM_PO_Line_Item__c=poi.id, 
        ASI_MFM_Invoice_Date__c = date.today(), 
        ASI_MFM_Invoice_Number__c = '123456'
        );                       
        insert pyi;
        return pyi;
    }
    
    
    
    
    
    
    
    
}