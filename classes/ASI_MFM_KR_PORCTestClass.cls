/*
* Test : ASI_MFM_KR_PORCProcess
* ASI_MFM_KR_PORC_Controller3
ASI_MFM_KR_PORC_Controller2 * */



@istest

public class ASI_MFM_KR_PORCTestClass {
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
    
  
        static testMethod void PlanBudgetCheckingTest3() {
         String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c,ASI_MFM_Team__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        u.ASI_MFM_Team__c ='Brand Marketing';
        update u;
        System.runAs(u){ 
               
          
            
            
            //-------------------------------------------------- Prefix  ----------------------------------------------------------//
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPR);
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Payment',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPayment);
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PO',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPO);
            insert Prefix_List;
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPayment.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Payment);
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPO.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PO); 
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Plan); 
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPR.id, ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PR);
            insert PrefixRole_List;
            
            
            //-------------------------------------------------- Project Code ----------------------------------------------------------//
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //-------------------------------------------------- BrandGroup, Brand, SubBrand----------------------------------------------------------//
            ASI_CRM_CN_Brand_Group__c BrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Brand Group Name',
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_MFM_KR_Brand_Group'),
                                                                                 ASI_CRM_Brand_Group_Code__c = 'Code_123');
            insert BrandGroup;
            
            ASI_MFM_Brand__c Brand = new ASI_MFM_Brand__c(Name='Brand Name',
                                                          ASI_MFM_Reporting_Brand_Desc__c = 'Reporting Brand',
                                                          ASI_CRM_CN_Brand_Group_c__c = BrandGroup.id,
                                                          recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_KR_Brand'));
            insert Brand;
            
            
            
          
            List<ASI_MFM_Sub_brand__c> SBList = new List<ASI_MFM_Sub_brand__c>();
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,ASI_MFM_Company_Code__c='222', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            SBList.add(SubBrand);
            ASI_MFM_Sub_brand__c SubBrand2 = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand3',ASI_MFM_Sub_brand_Code__c='Code3');
            SBList.add(SubBrand2);
            insert SBList;
            
            ASI_MFM_Setting__c setting = new ASI_MFM_Setting__c (ASI_MFM_KR_POReceiptClosing_DataVersion__c = 'V1',ASI_MFM_KR_PORC_Data_Last_Cal_Time__c=system.now(), ASI_MFM_KR_PO_Level1_Amount__c=1 , ASI_MFM_KR_PO_Level1_Checking__c=1 ,  ASI_MFM_KR_PO_Level2_Amount__c=1  , ASI_MFM_KR_PO_Level2_Percent__c=0.01 ,ASI_MFM_KR_PR_Level1_Amount__c=1, ASI_MFM_KR_PR_Level1_Checking__c=1, ASI_MFM_KR_PR_Level2_Amount__c=1 ,ASI_MFM_KR_PR_Level2_Percent__c=1);
            insert setting;
             //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Type__c='Trade A&P',ASI_MFM_AP_Code__c = 'Code',name = 'AP Code Test',ASI_MFM_PRPO_Needed__c=true,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
    
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',ASI_MFM_Fiscal_year__c=fiscalYear,ASI_MFM_Project_Code__c=pjCode.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = prefixKR_PLAN.id, ASI_MFM_Status__c='Closed', ASI_MFM_Budget_Type__c = 'NORM',OwnerId =u.id);
            insert plan1;
            
            List<ASI_MFM_Plan_Line_Item__c> PlanList= new List<ASI_MFM_Plan_Line_Item__c> ();
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_AP_Type__c='Trade A&P',ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100,ASI_MFM_Month_3_Cost__c = 100,   ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR', ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine1);
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_AP_Type__c='Trade A&P',ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100,ASI_MFM_Month_10_Cost__c = 100, ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200,ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000,ASI_MFM_Sub_brand_Code__c = SubBrand.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine2);
            ASI_MFM_Plan_Line_Item__c planLine3 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_AP_Type__c='Trade A&P',ASI_MFM_Plan__c = plan1.Id, ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,    ASI_MFM_Month_4_Cost__c = 100, ASI_MFM_Month_5_Cost__c = 100, ASI_MFM_Month_6_Cost__c = 100, ASI_MFM_Month_7_Cost__c = 100, ASI_MFM_Month_8_Cost__c = 100, ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine3);
            insert PlanList;
            
            //-------------------------------------------------- Tax Code ----------------------------------------------------------//
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //-------------------------------------------------- Venue----------------------------------------------------------//
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com', ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            //------------------------------------------------------- Customer ----------------------------------------------------------// 
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
           
            //-------------------------------------------------- PR ----------------------------------------------------------//
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),ASI_MFM_Comment__c = 'comment',ASI_MFM_PR_Name__c='PR Name',ASI_MFM_Company_Code__c = 'PRK',ASI_MFM_PR_Date__c = date.today(),ASI_MFM_Plan__c = plan1.id,ASI_MFM_Service_Item_POSM__c = 'POSM',ASI_MFM_Ship_To__c = acc1.ID,ASI_MFM_Status__c = 'Approved',ASI_MFM_Prefix__c = prefixPR.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),ASI_MFM_Plan_Line_Item__c = planLine1.id,ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_AP_Code__c = AP_Code.ID,ASI_MFM_Quantity__c = 10,ASI_MFM_UOM__c = 'EA',ASI_MFM_Tax_Code__c = TaxCode.id,ASI_MFM_Estimated_PR_budget__c = 100,ASI_MFM_Delivery_Date__c= date.today(),ASI_MFM_Description__c = 'Description',ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            //-------------------------------------------------- PO ----------------------------------------------------------//
            List<ASI_MFM_PO__c> POList= new List<ASI_MFM_PO__c>();
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Expiration_Date__c=system.today(),ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_PO_Raised_Date__c = date.today(),  ASI_MFM_Status__c = 'Closed',ASI_MFM_Prefix__c = prefixPO.id, ASI_MFM_Plan__c = plan1.id,ASI_MFM_VAT__c = 10.00,ASI_MFM_Company_Code__c = '222',ASI_MFM_Warehouse__c = acc1.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            POList.add(po);  
            ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Expiration_Date__c=system.today(),ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_PO_Raised_Date__c = date.today(),  ASI_MFM_Status__c = 'Draft',ASI_MFM_Prefix__c = prefixPO.id, ASI_MFM_Plan__c = plan1.id,ASI_MFM_VAT__c = 10.00,ASI_MFM_Company_Code__c = '222',ASI_MFM_Warehouse__c = acc1.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            POList.add(po2); 
            ASI_MFM_PO__c po3 = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Is_Direct_Payment__c=true,ASI_MFM_Expiration_Date__c=system.today(),ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_PO_Raised_Date__c = date.today(),  ASI_MFM_Status__c = 'Draft',ASI_MFM_Prefix__c = prefixPO.id, ASI_MFM_Plan__c = plan1.id,ASI_MFM_VAT__c = 10.00,ASI_MFM_Company_Code__c = '222',ASI_MFM_Warehouse__c = acc1.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            POList.add(po3);
            
            insert POList;
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (ASI_MFM_Sub_brand_Code__c = SubBrand.id,ASI_MFM_AP_Code__c=AP_Code.Id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),ASI_MFM_PO__c = po.id,ASI_MFM_Plan_Line_Item__c = planLine1.id,ASI_MFM_Unit_Price__c = 1000,ASI_MFM_KR_Quantity__c = 100,  ASI_MFM_Amount__c = 100000,ASI_MFM_Delivery_Date__c =  date.today(),ASI_MFM_G_L_Date__c = date.today(),ASI_MFM_Purchase_Request_Line__c = PR_Line.id);
            
            insert po_line;
            Test.startTest();
            System.debug(Limits.getDMLRows());  
            
              ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,ASI_MFM_KR_AP_Type__c='Trade A&P',
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',ASI_MFM_Type__c='LE3',
                                                             ASI_MFM_Fiscal_Year__c = fiscalYear,
                                                             ASI_MFM_P3_Amount__c = 100,
                                                             recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget'));
            insert Budget;
            
              List<ASI_MFM_Budget_Setup__c> NewRecord = new List<ASI_MFM_Budget_Setup__c>();
            
            ASI_MFM_Budget_Setup__c Budget_Budget = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-50),ASI_MFM_Type__c = 'Budget',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE1 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-40),ASI_MFM_Type__c = 'LE1',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE2 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-30), ASI_MFM_Type__c = 'LE2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE3 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-20),ASI_MFM_Type__c = 'LE3',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE4 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-10),ASI_MFM_Type__c = 'LE4',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            NewRecord.add(Budget_Budget);
            NewRecord.add(Budget_LE1);
            NewRecord.add(Budget_LE2);
            NewRecord.add(Budget_LE3);
            NewRecord.add(Budget_LE4);
            insert NewRecord;
            
              ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan1);
            ASI_MFM_KR_PlanBudgetCheckingCtrl con  = new ASI_MFM_KR_PlanBudgetCheckingCtrl(stdController);
            ASI_MFM_KR_PlanBudgetCheckingCtrl.wrapperClass temp= ASI_MFM_KR_PlanBudgetCheckingCtrl.getresultSetByPlanId(plan1.Id);
            test.stopTest();       
        }
        
    }
    
    
    
    static testMethod void PlanBudgetCheckingTest4() {
         String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c,ASI_MFM_Team__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        u.ASI_MFM_Team__c ='Brand Marketing';
        update u;
        System.runAs(u){ 
               
          
            
            
            //-------------------------------------------------- Prefix  ----------------------------------------------------------//
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPR);
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Payment',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPayment);
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PO',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPO);
            insert Prefix_List;
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPayment.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Payment);
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPO.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PO); 
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Plan); 
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPR.id, ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PR);
            insert PrefixRole_List;
            
            
            //-------------------------------------------------- Project Code ----------------------------------------------------------//
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //-------------------------------------------------- BrandGroup, Brand, SubBrand----------------------------------------------------------//
            ASI_CRM_CN_Brand_Group__c BrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Brand Group Name',
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_MFM_KR_Brand_Group'),
                                                                                 ASI_CRM_Brand_Group_Code__c = 'Code_123');
            insert BrandGroup;
            
            ASI_MFM_Brand__c Brand = new ASI_MFM_Brand__c(Name='Brand Name',
                                                          ASI_MFM_Reporting_Brand_Desc__c = 'Reporting Brand',
                                                          ASI_CRM_CN_Brand_Group_c__c = BrandGroup.id,
                                                          recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_KR_Brand'));
            insert Brand;
            
            
            
          
            List<ASI_MFM_Sub_brand__c> SBList = new List<ASI_MFM_Sub_brand__c>();
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,ASI_MFM_Company_Code__c='222', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            SBList.add(SubBrand);
            ASI_MFM_Sub_brand__c SubBrand2 = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand3',ASI_MFM_Sub_brand_Code__c='Code3');
            SBList.add(SubBrand2);
            insert SBList;
            
            ASI_MFM_Setting__c setting = new ASI_MFM_Setting__c (ASI_MFM_KR_POReceiptClosing_DataVersion__c = 'V1',ASI_MFM_KR_PORC_Data_Last_Cal_Time__c=system.now(), ASI_MFM_KR_PO_Level1_Amount__c=1 , ASI_MFM_KR_PO_Level1_Checking__c=1 ,  ASI_MFM_KR_PO_Level2_Amount__c=1  , ASI_MFM_KR_PO_Level2_Percent__c=0.01 ,ASI_MFM_KR_PR_Level1_Amount__c=1, ASI_MFM_KR_PR_Level1_Checking__c=1, ASI_MFM_KR_PR_Level2_Amount__c=1 ,ASI_MFM_KR_PR_Level2_Percent__c=1);
            insert setting;
             //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Type__c='Trade A&P',ASI_MFM_AP_Code__c = 'Code',name = 'AP Code Test',ASI_MFM_PRPO_Needed__c=true,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
    
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',ASI_MFM_Fiscal_year__c=fiscalYear,ASI_MFM_Project_Code__c=pjCode.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = prefixKR_PLAN.id, ASI_MFM_Status__c='Approved', ASI_MFM_Budget_Type__c = 'NORM',OwnerId =u.id);
            insert plan1;
            
            List<ASI_MFM_Plan_Line_Item__c> PlanList= new List<ASI_MFM_Plan_Line_Item__c> ();
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_AP_Type__c='Trade A&P',ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100,ASI_MFM_Month_3_Cost__c = 100,   ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR', ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine1);
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_AP_Type__c='Trade A&P',ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100,ASI_MFM_Month_10_Cost__c = 100, ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200,ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000,ASI_MFM_Sub_brand_Code__c = SubBrand.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine2);
            ASI_MFM_Plan_Line_Item__c planLine3 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_AP_Type__c='Trade A&P',ASI_MFM_Plan__c = plan1.Id, ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,    ASI_MFM_Month_4_Cost__c = 100, ASI_MFM_Month_5_Cost__c = 100, ASI_MFM_Month_6_Cost__c = 100, ASI_MFM_Month_7_Cost__c = 100, ASI_MFM_Month_8_Cost__c = 100, ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine3);
            insert PlanList;
            
            //-------------------------------------------------- Tax Code ----------------------------------------------------------//
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //-------------------------------------------------- Venue----------------------------------------------------------//
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com', ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            //------------------------------------------------------- Customer ----------------------------------------------------------// 
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
           
            //-------------------------------------------------- PR ----------------------------------------------------------//
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),ASI_MFM_Comment__c = 'comment',ASI_MFM_PR_Name__c='PR Name',ASI_MFM_Company_Code__c = 'PRK',ASI_MFM_PR_Date__c = date.today(),ASI_MFM_Plan__c = plan1.id,ASI_MFM_Service_Item_POSM__c = 'POSM',ASI_MFM_Ship_To__c = acc1.ID,ASI_MFM_Status__c = 'Approved',ASI_MFM_Prefix__c = prefixPR.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),ASI_MFM_Plan_Line_Item__c = planLine1.id,ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_AP_Code__c = AP_Code.ID,ASI_MFM_Quantity__c = 10,ASI_MFM_UOM__c = 'EA',ASI_MFM_Tax_Code__c = TaxCode.id,ASI_MFM_Estimated_PR_budget__c = 100,ASI_MFM_Delivery_Date__c= date.today(),ASI_MFM_Description__c = 'Description',ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            //-------------------------------------------------- PO ----------------------------------------------------------//
            List<ASI_MFM_PO__c> POList= new List<ASI_MFM_PO__c>();
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Expiration_Date__c=system.today(),ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_PO_Raised_Date__c = date.today(),  ASI_MFM_Status__c = 'Closed',ASI_MFM_Prefix__c = prefixPO.id, ASI_MFM_Plan__c = plan1.id,ASI_MFM_VAT__c = 10.00,ASI_MFM_Company_Code__c = '222',ASI_MFM_Warehouse__c = acc1.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            POList.add(po);  
            ASI_MFM_PO__c po2 = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Expiration_Date__c=system.today(),ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_PO_Raised_Date__c = date.today(),  ASI_MFM_Status__c = 'Draft',ASI_MFM_Prefix__c = prefixPO.id, ASI_MFM_Plan__c = plan1.id,ASI_MFM_VAT__c = 10.00,ASI_MFM_Company_Code__c = '222',ASI_MFM_Warehouse__c = acc1.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            POList.add(po2); 
            ASI_MFM_PO__c po3 = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_Is_Direct_Payment__c=true,ASI_MFM_Expiration_Date__c=system.today(),ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_PO_Raised_Date__c = date.today(),  ASI_MFM_Status__c = 'Draft',ASI_MFM_Prefix__c = prefixPO.id, ASI_MFM_Plan__c = plan1.id,ASI_MFM_VAT__c = 10.00,ASI_MFM_Company_Code__c = '222',ASI_MFM_Warehouse__c = acc1.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            POList.add(po3);
            
            insert POList;
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (ASI_MFM_Sub_brand_Code__c = SubBrand.id,ASI_MFM_AP_Code__c=AP_Code.Id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),ASI_MFM_PO__c = po.id,ASI_MFM_Plan_Line_Item__c = planLine1.id,ASI_MFM_Unit_Price__c = 1000,ASI_MFM_KR_Quantity__c = 100,  ASI_MFM_Amount__c = 100000,ASI_MFM_Delivery_Date__c =  date.today(),ASI_MFM_G_L_Date__c = date.today(),ASI_MFM_Purchase_Request_Line__c = PR_Line.id);
            
            insert po_line;
            Test.startTest();
            System.debug(Limits.getDMLRows());  
            
              ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,ASI_MFM_KR_AP_Type__c='Trade A&P',
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',ASI_MFM_Type__c='LE3',
                                                             ASI_MFM_Fiscal_Year__c = fiscalYear,
                                                             ASI_MFM_P3_Amount__c = 100,
                                                             recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget'));
            insert Budget;
            
              List<ASI_MFM_Budget_Setup__c> NewRecord = new List<ASI_MFM_Budget_Setup__c>();
            
            ASI_MFM_Budget_Setup__c Budget_Budget = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-50),ASI_MFM_Type__c = 'Budget',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE1 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-40),ASI_MFM_Type__c = 'LE1',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE2 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-30), ASI_MFM_Type__c = 'LE2',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE3 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-20),ASI_MFM_Type__c = 'LE3',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            ASI_MFM_Budget_Setup__c Budget_LE4 = new ASI_MFM_Budget_Setup__c(ASI_MFM_Start_Date__c= (date.today()).adddays(-10),ASI_MFM_Type__c = 'LE4',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget_Setup__cASI_MFM_KR_Budget_Setup'),ASI_MFM_Fiscal_Year__c = fiscalYear);
            NewRecord.add(Budget_Budget);
            NewRecord.add(Budget_LE1);
            NewRecord.add(Budget_LE2);
            NewRecord.add(Budget_LE3);
            NewRecord.add(Budget_LE4);
            insert NewRecord;
            
              ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan1);
            ASI_MFM_KR_PlanBudgetCheckingCtrl con  = new ASI_MFM_KR_PlanBudgetCheckingCtrl(stdController);
            ASI_MFM_KR_PlanBudgetCheckingCtrl.wrapperClass temp= ASI_MFM_KR_PlanBudgetCheckingCtrl.getresultSetByPlanId(plan1.Id);
            test.stopTest();       
        }
        
    }
    
    
    static testMethod void ASI_MFM_KR_DirectPaymentCtler_Test_1() {
        // Test class for  ASI_MFM_KR_DirectPaymentCtler
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c = 'KR';
        u.ASI_KOR_User_Branch_Code__c = '555';
        u.ASI_OBIEE_Domain__c='Tset1';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
            ASI_MFM_A_C_Code__c AC_Code = new ASI_MFM_A_C_Code__c (ASI_MFM_A_C_Code__c = 'Code', Name = 'Test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_KR_A_C_Code'));
            insert AC_Code;   
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');          
            insert acc1;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            ASI_CRM_CN_Brand_Group__c BrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Brand Group Name',
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_MFM_KR_Brand_Group'),
                                                                                 ASI_CRM_Brand_Group_Code__c = 'Code_123');
            insert BrandGroup;
            
            ASI_MFM_Brand__c Brand = new ASI_MFM_Brand__c(Name='Brand Name',
                                                          ASI_MFM_Reporting_Brand_Desc__c = 'Reporting Brand',
                                                          ASI_CRM_CN_Brand_Group_c__c = BrandGroup.id,
                                                          recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_KR_Brand'));
            insert Brand;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Company_Code__c = '222', ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_AP_Type__c = 'testing',
                                                                 ASI_MFM_AP_Category__c = 'type',
                                                                 ASI_MFM_PRPO_Needed__c=false,
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixKR_PLAN);
            
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );  
            Prefix_List.add(prefixPR);
            
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'PRK',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear,
                    ASI_MFM_Inactive__c=false
                );
            Prefix_List.add(prefixPayment);
            
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c(Name = 'PRK',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Direct PO',ASI_MFM_Fiscal_year__c = FiscalYear,ASI_MFM_Inactive__c=false);
            Prefix_List.add(prefixPO);
            insert Prefix_List;
            
            
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPayment.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Payment);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPO.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PO); 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Plan); 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            
            ASI_TnE_Branch_Channel__c Branch = new ASI_TnE_Branch_Channel__c(Name = '55555',ASI_TnE_Branch_Default__c = TRUE, recordTypeid =Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel'));
            
            insert Branch;
            
            list<ASI_MFM_Plan__c> PlanList = new  list<ASI_MFM_Plan__c>();
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan1',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, ASI_MFM_Status__c='Approved',   ASI_MFM_Budget_Type__c = 'NORM', OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Plan__c plan2 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan2;
            PlanList.add(plan1);
            PlanList.add(plan2);
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
                                                                                 ASI_MFM_Month_1_Cost__c = 100,
                                                                                 ASI_MFM_Month_2_Cost__c = 100,
                                                                                 ASI_MFM_Month_3_Cost__c = 100,   
                                                                                 ASI_MFM_Month_4_Cost__c = 100,
                                                                                 ASI_MFM_Month_5_Cost__c = 100,
                                                                                 ASI_MFM_Month_6_Cost__c = 100,
                                                                                 ASI_MFM_Month_7_Cost__c = 100,
                                                                                 ASI_MFM_Month_8_Cost__c = 100,
                                                                                 ASI_MFM_Month_9_Cost__c = 100,
                                                                                 ASI_MFM_Month_10_Cost__c = 100,
                                                                                 ASI_MFM_Month_11_Cost__c = 100,
                                                                                 ASI_MFM_Month_12_Cost__c = 200,
                                                                                 ASI_MFM_TH_Region__c = 'KR',
                                                                                 ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                                                 ASI_MFM_AccountsAdditionalField__c = customer1.id, 
                                                                                 ASI_MFM_Venue_Where__c = customer1.id, 
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            
            
            ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,  
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',
                                                             ASI_MFM_Fiscal_Year__c = fiscalYear,
                                                             ASI_MFM_P3_Amount__c = 100,
                                                             recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget'));
            insert Budget;
            
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRKI',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            
            LIST<ASI_MFM_Purchase_Request_Line__c> pr_list = new LIST<ASI_MFM_Purchase_Request_Line__c>();
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            pr_list.add(PR_Line);
            
            ASI_MFM_Purchase_Request_Line__c PR_Line2 = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                              ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                              ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                              ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                              ASI_MFM_Quantity__c = 10,
                                                                                              ASI_MFM_UOM__c = 'EA',
                                                                                              ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                              ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                              ASI_MFM_Delivery_Date__c= date.today(),
                                                                                              ASI_MFM_Description__c = 'Description',
                                                                                              ASI_MFM_Unit_Cost__c = 100);
            pr_list.add(PR_Line2);
            insert pr_list;    
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_PO_Raised_Date__c = date.today(),   ASI_MFM_Status__c = 'Approved',  ASI_MFM_Prefix__c = prefixPO.id,  ASI_MFM_Plan__c = plan1.id, ASI_MFM_VAT__c = 10.00,ASI_MFM_Company_Code__c = '222',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),ASI_MFM_PO__c = po.id,ASI_MFM_Unit_Price__c = 1000, ASI_MFM_KR_Quantity__c = 100,ASI_MFM_Amount__c = 100000,ASI_MFM_Delivery_Date__c =  date.today(),ASI_MFM_G_L_Date__c = date.today(),ASI_MFM_Purchase_Request_Line__c = PR_Line.id);
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),  ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_PO__c = po.id,ASI_MFM_Company_Code__c = '222',ASI_MFM_Send_Approval_Email__c=true,ASI_MFM_Payment_Amount__c = 1000);  
            
            
            test.startTest();
            
            List <ASI_MFM_PO_Line_Item__c> POLINELIST = NEW List <ASI_MFM_PO_Line_Item__c>();
            POLINELIST.ADD(po_line);
            
            List<ASI_MFM_Payment__c> PaymentSet = new List<ASI_MFM_Payment__c>();
            PaymentSet.add(PaymentHeader);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(PaymentSet);
            
            PageReference ManageAllPage = Page.asi_mfm_kr_paymentmanageallpage;
            
            Test.setCurrentPageReference(ManageAllPage);
            
            ApexPages.currentpage().getHeaders().put('Referer', plan1.id);       
            
            ASI_MFM_KR_DirectPaymentCtler ManageAllController = new ASI_MFM_KR_DirectPaymentCtler();
            ManageAllController.init();
            
            //Test function
            ManageAllController.header.po.ASI_MFM_Plan__c = plan1.id;  
            ManageAllController.header.pay.ASI_MFM_Supplier_Name__c = acc2.id;  
            ManageAllController.header.pay.ASI_MFM_Invoice_Number__c = 'Invoice No.';  
            ManageAllController.header.pay.ASI_MFM_Invoice_Date__c = date.today();  
            ManageAllController.Company = 'PRK';
            ManageAllController.create_po = po;
            ManageAllController.Save_POItem = POLINELIST; 
            
            
            ManageAllController.checkPrefixes();   
            ManageAllController.CopyFromPlan();  
            
            
            ManageAllController.Refresh(); 
            
            ApexPages.currentpage().getParameters().put('PARAM_clone_ID', '1'); 
            ManageAllController.cloneLine();
            
            ApexPages.currentpage().getParameters().put('PARAM_clone_ID', '1'); 
            ManageAllController.cloneLine();
            
            ASI_MFM_KR_DirectPaymentCtler.HeaderObj Header = new  ASI_MFM_KR_DirectPaymentCtler.HeaderObj();
            String id = Header.id;
            Header.id = '1';
            id = Header.id;
            
            ASI_MFM_KR_DirectPaymentCtler.LineObj CloneLine = new  ASI_MFM_KR_DirectPaymentCtler.LineObj();
            id = CloneLine.id;
            CloneLine.id = '1';  
            id = CloneLine.id;   
            CloneLine.PlanLine = planLine1;   
            CloneLine.pl = new ASI_MFM_Payment_Line_Item__c();  
            CloneLine.pl.ASI_MFM_Payment_Amount__c = 1000;
            CloneLine.pl.ASI_MFM_AP_Remark__c = 'OriLine.pl.ASI_MFM_AP_Remark__c';
            CloneLine.pl.ASI_MFM_Invoice_Number__c='Invoice No.'; 
            CloneLine.pl.ASI_MFM_Invoice_Date__c= date.today();  
            CloneLine.pl.ASI_MFM_Beneficiary_Customer__c = customer1.id;
            CloneLine.pl.ASI_MFM_Payment_List_Item_Description__c = 'Description';
            
            CloneLine.pol= new ASI_MFM_PO_Line_Item__c();  
            CloneLine.pol.ASI_MFM_Tax_Code__c = taxcode.id;   
            CloneLine.pol.ASI_MFM_Sub_brand_Code__c = SubBrand.id;
            CloneLine.pol.ASI_MFM_Plan_Line_Item__c=planLine1.id;
            CloneLine.pol.ASI_MFM_A_C_Code__c = AC_Code.id;
            
            
            ApexPages.currentpage().getParameters().put('PARAM_RLine_ID','1'); 
            ManageAllController.removeLine(); 
            
            ManageAllController.CopyFromPlan();  
            ManageAllController.SaveRecord();
            
            ManageAllController.onCommitted(double.valueOf('2.00'));
            //ManageAllController.ValdationChecking();
            ManageAllController.Reset();  
            
            //Test RemoteAction  
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_DirectPaymentCtler.findList('ASI_MFM_AP_Code__c','ASI_MFM_AP_Code__c','WHERE RecordType.DeveloperName != null');  
            remo4= ASI_MFM_KR_DirectPaymentCtler.findList('ASI_MFM_AP_Code__c','ASI_MFM_AP_Code__c','');  
            List<ASI_CRM_AccountsAdditionalField__c> remo5= ASI_MFM_KR_DirectPaymentCtler.findCustomers('ASI_CRM_AccountsAdditionalField__c','WHERE RecordType.DeveloperName != null');
            remo5= ASI_MFM_KR_DirectPaymentCtler.findCustomers('ASI_CRM_AccountsAdditionalField__c','');
            
            List<ASI_CRM_AccountsAdditionalField__c> remo6= ASI_MFM_KR_DirectPaymentCtler.findSObjects('ASI_CRM_AccountsAdditionalField__c','WHERE RecordType.DeveloperName != null'); 
            remo6= ASI_MFM_KR_DirectPaymentCtler.findSObjects('ASI_CRM_AccountsAdditionalField__c',''); 
            Map<String, Decimal> remo7= ASI_MFM_KR_DirectPaymentCtler.retrieveExchangeRate(); 
            
            test.stopTest();
        }
    }
    
    
    
    
    
    
    static testMethod void ASI_MFM_KR_DirectPaymentCtler_Test_3() {
        // Test class for  ASI_MFM_KR_DirectPaymentCtler
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c = 'KR';
        u.ASI_KOR_User_Branch_Code__c = '555';
        update u;
        
        string fiscalYear = getFiscalYear();
        
        System.runAs(u){ 
            ASI_MFM_A_C_Code__c AC_Code = new ASI_MFM_A_C_Code__c (ASI_MFM_A_C_Code__c = 'Code', Name = 'Test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_KR_A_C_Code'));
            insert AC_Code;   
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1');          
            insert acc1;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            ASI_CRM_CN_Brand_Group__c BrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Brand Group Name',
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_MFM_KR_Brand_Group'),
                                                                                 ASI_CRM_Brand_Group_Code__c = 'Code_123');
            insert BrandGroup;
            
            ASI_MFM_Brand__c Brand = new ASI_MFM_Brand__c(Name='Brand Name',
                                                          ASI_MFM_Reporting_Brand_Desc__c = 'Reporting Brand',
                                                          ASI_CRM_CN_Brand_Group_c__c = BrandGroup.id,
                                                          recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_KR_Brand'));
            insert Brand;
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Company_Code__c = '222', ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_AP_Type__c = 'testing',
                                                                 ASI_MFM_AP_Category__c = 'type',
                                                                 ASI_MFM_PRPO_Needed__c=false,
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixKR_PLAN);
            
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );  
            Prefix_List.add(prefixPR);
            
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'PRK',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear,
                    ASI_MFM_Inactive__c=false
                );
            Prefix_List.add(prefixPayment);
            
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c(Name = 'PRK',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Direct PO',ASI_MFM_Fiscal_year__c = FiscalYear,ASI_MFM_Inactive__c=false);
            Prefix_List.add(prefixPO);
            insert Prefix_List;
            
            
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPayment.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Payment);
            
            
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPO.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PO); 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Plan); 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            
            ASI_TnE_Branch_Channel__c Branch = new ASI_TnE_Branch_Channel__c(Name = '55555',ASI_TnE_Branch_Default__c = TRUE, recordTypeid =Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel'));
            
            insert Branch;
            
            list<ASI_MFM_Plan__c> PlanList = new  list<ASI_MFM_Plan__c>();
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan1',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, ASI_MFM_Status__c='Approved',   ASI_MFM_Budget_Type__c = 'NORM', OwnerId =u.id);
            insert plan1;
            
            ASI_MFM_Plan__c plan2 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan2;
            PlanList.add(plan1);
            PlanList.add(plan2);
            
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
                                                                                 ASI_MFM_Month_1_Cost__c = 100,
                                                                                 ASI_MFM_Month_2_Cost__c = 100,
                                                                                 ASI_MFM_Month_3_Cost__c = 100,   
                                                                                 ASI_MFM_Month_4_Cost__c = 100,
                                                                                 ASI_MFM_Month_5_Cost__c = 100,
                                                                                 ASI_MFM_Month_6_Cost__c = 100,
                                                                                 ASI_MFM_Month_7_Cost__c = 100,
                                                                                 ASI_MFM_Month_8_Cost__c = 100,
                                                                                 ASI_MFM_Month_9_Cost__c = 100,
                                                                                 ASI_MFM_Month_10_Cost__c = 100,
                                                                                 ASI_MFM_Month_11_Cost__c = 100,
                                                                                 ASI_MFM_Month_12_Cost__c = 200,
                                                                                 ASI_MFM_TH_Region__c = 'KR',
                                                                                 ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                                                 ASI_MFM_AccountsAdditionalField__c = customer1.id, 
                                                                                 ASI_MFM_Venue_Where__c = customer1.id, 
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            
            
            ASI_MFM_Budget__c Budget = new ASI_MFM_Budget__c(ASI_MFM_Code__c=pjCode.id,  
                                                             ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                             ASI_MFM_Budget_Type__c ='NORM',
                                                             ASI_MFM_Fiscal_Year__c = fiscalYear,
                                                             ASI_MFM_P3_Amount__c = 100,
                                                             recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget'));
            insert Budget;
            
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            
            LIST<ASI_MFM_Purchase_Request_Line__c> pr_list = new LIST<ASI_MFM_Purchase_Request_Line__c>();
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            pr_list.add(PR_Line);
            
            ASI_MFM_Purchase_Request_Line__c PR_Line2 = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                              ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                              ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                              ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                              ASI_MFM_Quantity__c = 10,
                                                                                              ASI_MFM_UOM__c = 'EA',
                                                                                              ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                              ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                              ASI_MFM_Delivery_Date__c= date.today(),
                                                                                              ASI_MFM_Description__c = 'Description',
                                                                                              ASI_MFM_Unit_Cost__c = 100);
            pr_list.add(PR_Line2);
            insert pr_list;    
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id, ASI_MFM_Purchase_Request__c = PR_Header.id,ASI_MFM_PO_Raised_Date__c = date.today(),   ASI_MFM_Status__c = 'Approved',  ASI_MFM_Prefix__c = prefixPO.id,  ASI_MFM_Plan__c = plan1.id, ASI_MFM_VAT__c = 10.00,ASI_MFM_Company_Code__c = '222',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),ASI_MFM_PO__c = po.id,ASI_MFM_Unit_Price__c = 1000, ASI_MFM_KR_Quantity__c = 100,ASI_MFM_Amount__c = 100000,ASI_MFM_Delivery_Date__c =  date.today(),ASI_MFM_G_L_Date__c = date.today(),ASI_MFM_Purchase_Request_Line__c = PR_Line.id);
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Draft', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),  ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_PO__c = po.id,ASI_MFM_Company_Code__c = '222',ASI_MFM_Send_Approval_Email__c=true,ASI_MFM_Payment_Amount__c = 1000);  
            
            
            test.startTest();
            List <ASI_MFM_PO_Line_Item__c> POLINELIST = NEW List <ASI_MFM_PO_Line_Item__c>();
            POLINELIST.ADD(po_line);
            
            List<ASI_MFM_Payment__c> PaymentSet = new List<ASI_MFM_Payment__c>();
            PaymentSet.add(PaymentHeader);
            
            ApexPages.standardSetController sc = new ApexPages.standardSetController(PaymentSet);
            
            PageReference ManageAllPage = Page.asi_mfm_kr_paymentmanageallpage;
            
            Test.setCurrentPageReference(ManageAllPage);
            
            ApexPages.currentpage().getHeaders().put('Referer', plan1.id);       
            
            ASI_MFM_KR_DirectPaymentCtler ManageAllController = new ASI_MFM_KR_DirectPaymentCtler();
            ManageAllController.init();
            
            //Test function
            ManageAllController.header.po.ASI_MFM_Plan__c = plan1.id;  
            ManageAllController.header.pay.ASI_MFM_Supplier_Name__c = acc2.id;  
            ManageAllController.header.pay.ASI_MFM_Invoice_Number__c = 'Invoice No.';  
            ManageAllController.header.pay.ASI_MFM_Invoice_Date__c = date.today();  
            ManageAllController.Company = 'PRK';
            ManageAllController.create_po = po;
            ManageAllController.Save_POItem = POLINELIST; 
            
            ManageAllController.checkPrefixes();   
            ManageAllController.CopyFromPlan();  
            
            
            ManageAllController.Refresh(); 
            
            ApexPages.currentpage().getParameters().put('PARAM_clone_ID', '1'); 
            ManageAllController.cloneLine();
            
            ApexPages.currentpage().getParameters().put('PARAM_clone_ID', '1'); 
            ManageAllController.cloneLine();
            
            ASI_MFM_KR_DirectPaymentCtler.HeaderObj Header = new  ASI_MFM_KR_DirectPaymentCtler.HeaderObj();
            String id = Header.id;
            Header.id = '1';
            id = Header.id;
            
            ASI_MFM_KR_DirectPaymentCtler.LineObj CloneLine = new  ASI_MFM_KR_DirectPaymentCtler.LineObj();
            id = CloneLine.id;
            CloneLine.id = '1';  
            id = CloneLine.id;   
            CloneLine.PlanLine = planLine1;   
            CloneLine.pl = new ASI_MFM_Payment_Line_Item__c();  
            CloneLine.pl.ASI_MFM_Payment_Amount__c = 1000;
            CloneLine.pl.ASI_MFM_AP_Remark__c = 'OriLine.pl.ASI_MFM_AP_Remark__c';
            CloneLine.pl.ASI_MFM_Invoice_Number__c='Invoice No.'; 
            CloneLine.pl.ASI_MFM_Invoice_Date__c= date.today();  
            CloneLine.pl.ASI_MFM_Beneficiary_Customer__c = customer1.id;
            CloneLine.pl.ASI_MFM_Payment_List_Item_Description__c = 'Description';
            
            CloneLine.pol= new ASI_MFM_PO_Line_Item__c();  
            CloneLine.pol.ASI_MFM_Tax_Code__c = taxcode.id;   
            CloneLine.pol.ASI_MFM_Sub_brand_Code__c = SubBrand.id;
            CloneLine.pol.ASI_MFM_Plan_Line_Item__c=planLine1.id;
            CloneLine.pol.ASI_MFM_A_C_Code__c = AC_Code.id;
            
            
            ApexPages.currentpage().getParameters().put('PARAM_RLine_ID','1'); 
            ManageAllController.removeLine(); 
            
            ManageAllController.CopyFromPlan();  
            ManageAllController.SaveRecord();
            
            ManageAllController.onCommitted(double.valueOf('1.99'));
            //ManageAllController.ValdationChecking();
            ManageAllController.Reset();  
            
            //Test RemoteAction  
            List<ASI_MFM_AP_Code__c> remo4= ASI_MFM_KR_DirectPaymentCtler.findList('ASI_MFM_AP_Code__c','ASI_MFM_AP_Code__c','WHERE RecordType.DeveloperName != null');  
            List<ASI_CRM_AccountsAdditionalField__c> remo5= ASI_MFM_KR_DirectPaymentCtler.findCustomers('ASI_CRM_AccountsAdditionalField__c','WHERE RecordType.DeveloperName != null');  
            List<ASI_CRM_AccountsAdditionalField__c> remo6= ASI_MFM_KR_DirectPaymentCtler.findSObjects('ASI_CRM_AccountsAdditionalField__c','WHERE RecordType.DeveloperName != null'); 
            Map<String, Decimal> remo7= ASI_MFM_KR_DirectPaymentCtler.retrieveExchangeRate(); 
            
            test.stopTest();
        }
    }
    
    
    
    
    static testMethod void ASI_MFM_KR_PORC_Controller_Test_1() {
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c,ASI_MFM_Team__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        u.ASI_MFM_Team__c ='Brand Marketing';
        update u;
        
        System.runAs(u){ 
            //-------------------------------------------------- Prefix  ----------------------------------------------------------//
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixPR);
            
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixPayment);
            
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            //insert prefixPO;
            Prefix_List.add(prefixPO);
            
            insert Prefix_List;
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Payment);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_PO); 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Plan); 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_PR);
            
            
            
            
            insert PrefixRole_List;
            
            ASI_MFM_Setting__c setting = new ASI_MFM_Setting__c (ASI_MFM_KR_POReceiptClosing_DataVersion__c = 'V1',ASI_MFM_KR_PORC_List_No_Of_Row__c=1,ASI_MFM_KR_PORC_Data_Last_Cal_Time__c=system.now());
            insert setting;
            
            
            
            //-------------------------------------------------- Project Code ----------------------------------------------------------//
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //-------------------------------------------------- BrandGroup, Brand, SubBrand----------------------------------------------------------//
            ASI_CRM_CN_Brand_Group__c BrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Brand Group Name',
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_MFM_KR_Brand_Group'),
                                                                                 ASI_CRM_Brand_Group_Code__c = 'Code_123');
            insert BrandGroup;
            
            ASI_MFM_Brand__c Brand = new ASI_MFM_Brand__c(Name='Brand Name',
                                                          ASI_MFM_Reporting_Brand_Desc__c = 'Reporting Brand',
                                                          ASI_CRM_CN_Brand_Group_c__c = BrandGroup.id,
                                                          recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_KR_Brand'));
            insert Brand;
            
            
            List<ASI_MFM_Sub_brand__c> SBList = new List<ASI_MFM_Sub_brand__c>();
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,ASI_MFM_Company_Code__c='222',
                                                                     recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), 
                                                                     Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            SBList.add(SubBrand);
            ASI_MFM_Sub_brand__c SubBrand2 = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand3',ASI_MFM_Sub_brand_Code__c='Code3');
            SBList.add(SubBrand2);
            insert SBList;
            
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Fiscal_year__c=fiscalYear,
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                                                        ASI_MFM_End_Date__c = date.today().adddays(1),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            List<ASI_MFM_Plan_Line_Item__c> PlanList= new List<ASI_MFM_Plan_Line_Item__c> ();
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
                                                                                 ASI_MFM_Month_1_Cost__c = 100,
                                                                                 ASI_MFM_Month_2_Cost__c = 100,
                                                                                 ASI_MFM_Month_3_Cost__c = 100,   
                                                                                 ASI_MFM_Month_4_Cost__c = 100,
                                                                                 ASI_MFM_Month_5_Cost__c = 100,
                                                                                 ASI_MFM_Month_6_Cost__c = 100,
                                                                                 ASI_MFM_Month_7_Cost__c = 100,
                                                                                 ASI_MFM_Month_8_Cost__c = 100,
                                                                                 ASI_MFM_Month_9_Cost__c = 100,
                                                                                 ASI_MFM_Month_10_Cost__c = 100,
                                                                                 ASI_MFM_Month_11_Cost__c = 100,
                                                                                 ASI_MFM_Month_12_Cost__c = 200,
                                                                                 ASI_MFM_TH_Region__c = 'KR',
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine1);
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
                                                                                 ASI_MFM_Month_1_Cost__c = 100,
                                                                                 ASI_MFM_Month_2_Cost__c = 100,
                                                                                 ASI_MFM_Month_3_Cost__c = 100,   
                                                                                 ASI_MFM_Month_4_Cost__c = 100,
                                                                                 ASI_MFM_Month_5_Cost__c = 100,
                                                                                 ASI_MFM_Month_6_Cost__c = 100,
                                                                                 ASI_MFM_Month_7_Cost__c = 100,
                                                                                 ASI_MFM_Month_8_Cost__c = 100,
                                                                                 ASI_MFM_Month_9_Cost__c = 100,
                                                                                 ASI_MFM_Month_10_Cost__c = 100,
                                                                                 ASI_MFM_Month_11_Cost__c = 100,
                                                                                 ASI_MFM_Month_12_Cost__c = 200,
                                                                                 ASI_MFM_TH_Region__c = 'KR',
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand2.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            
            
            PlanList.add(planLine2);
            ASI_MFM_Plan_Line_Item__c planLine3 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
                                                                                 ASI_MFM_Month_1_Cost__c = 100,
                                                                                 ASI_MFM_Month_2_Cost__c = 100,
                                                                                 ASI_MFM_Month_3_Cost__c = 100,   
                                                                                 ASI_MFM_Month_4_Cost__c = 100,
                                                                                 ASI_MFM_Month_5_Cost__c = 100,
                                                                                 ASI_MFM_Month_6_Cost__c = 100,
                                                                                 ASI_MFM_Month_7_Cost__c = 100,
                                                                                 ASI_MFM_Month_8_Cost__c = 100,
                                                                                 ASI_MFM_Month_9_Cost__c = 100,
                                                                                 ASI_MFM_Month_10_Cost__c = 100,
                                                                                 ASI_MFM_Month_11_Cost__c = 100,
                                                                                 ASI_MFM_Month_12_Cost__c = 200,
                                                                                 ASI_MFM_TH_Region__c = 'KR',
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand2.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            
            
            PlanList.add(planLine3);
            
            insert PlanList;
            
            //-------------------------------------------------- Tax Code ----------------------------------------------------------//
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //-------------------------------------------------- Venue----------------------------------------------------------//
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            //------------------------------------------------------- Customer ----------------------------------------------------------// 
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code',Name = 'AP Code Test', ASI_MFM_PRPO_Needed__c=true,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            //-------------------------------------------------- PR ----------------------------------------------------------//
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            //-------------------------------------------------- PO ----------------------------------------------------------//
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Draft',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 ASI_MFM_Warehouse__c = acc1.id,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),ASI_MFM_PO__c = po.id,ASI_MFM_Plan_Line_Item__c = planLine1.id,ASI_MFM_Unit_Price__c = 1000,ASI_MFM_KR_Quantity__c = 100,ASI_MFM_Amount__c = 100000,ASI_MFM_Delivery_Date__c =  date.today(),ASI_MFM_G_L_Date__c = date.today(),ASI_MFM_Purchase_Request_Line__c = PR_Line.id);
            
            insert po_line;
            Test.startTest();        
            //-------------------------------------------------- PO Receipt ----------------------------------------------------------//
            
            ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,ASI_MFM_Status__c = 'Draft',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
            
            LIST<ASI_MFM_PO_Receipt_Item__c> PORList = NEW LIST<ASI_MFM_PO_Receipt_Item__c>();
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,ASI_MFM_PO_Line_Item__c = po_line.id, ASI_MFM_Quantity__c = 1,ASI_MFM_Receipt_Date__c=date.today(), ASI_MFM_Plan_Line_Item__c=planLine1.Id, ASI_MFM_PO__c = po.id,ASI_MFM_Paid__c= false,ASI_MFM_Amount__c = 1, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            PORList.ADD(POR_Line);
            
            ASI_MFM_PO_Receipt_Item__c POR_Line2 = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,ASI_MFM_PO_Line_Item__c = po_line.id,ASI_MFM_Quantity__c = 1, ASI_MFM_PO__c = po.id,ASI_MFM_Plan_Line_Item__c=planLine2.Id,ASI_MFM_Paid__c = false,ASI_MFM_Amount__c = 1,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            PORList.ADD(POR_Line2);
            INSERT PORList;
            List<string> POReceiptIdList = new List<string>();
            POReceiptIdList.add(POR_Line.id);
            
            list<ASI_MFM_Settings__c> TestDataList= new list<ASI_MFM_Settings__c> ();
            ASI_MFM_Settings__c datas= new ASI_MFM_Settings__c(ASI_MFM_A_P_Type__c='A&D',ASI_MFM_Plan__c=plan1.ID,ASI_MFM_Sub_brand__c=SubBrand.ID,ASI_MFM_PRPO_Needed__c=true,ASI_MFM_Version__c='V1',ASI_MFM_PO_Receipt_Line__c=String.valueOf(POR_Line2.ID),ASI_MFM_External_ID__c='Test1',ASI_MFM_PO_Line_ID__c=String.valueOf(po.ID),ASI_MFM_Plan_Line_ID__c=String.valueOf(plan1.ID),ASI_MFM_Month_10_Cost__c=1,ASI_MFM_Month_12_Cost__c=2);
            TestDataList.add(datas);
            ASI_MFM_Settings__c datas2= new ASI_MFM_Settings__c(ASI_MFM_A_P_Type__c='A&P',ASI_MFM_Plan__c=plan1.ID,ASI_MFM_Sub_brand__c=SubBrand.ID,ASI_MFM_PRPO_Needed__c=true,ASI_MFM_Version__c='V1',ASI_MFM_PO_Receipt_Line__c=String.valueOf(POR_Line2.ID),ASI_MFM_External_ID__c='Test2',ASI_MFM_PO_Line_ID__c=String.valueOf(po.ID),ASI_MFM_Plan_Line_ID__c=String.valueOf(plan1.ID),ASI_MFM_Month_10_Cost__c=1,ASI_MFM_Month_12_Cost__c=2);
            TestDataList.add(datas2);
            insert TestDataList;
            
            List<String> TempList = new List<String>();
            for(ASI_MFM_Settings__c item:TestDataList){
                TempList.add(item.Id);
            }
            
            
            ASI_MFM_KR_PORC_Controller2 ext = new ASI_MFM_KR_PORC_Controller2();
            ext.SelectStatus = 'Approved';
            ext.CompanyFilter='222';
            ext.Fiscal_Years=fiscalYear;
            ext.MinPORAmount='0';
            ext.MaxPORAmount='1';
            ext.MinPOBalance='0';
            ext.MaxPORAmount='2';
            ext.SBCode='Code';
            ext.runSearch();
            ext.toggleSort();
            ext.Previous();
            ext.Next();
            ext.End();
            
            Integer TempInt=ext.getTotalPages();
            
            
            
            
            string remo1=ASI_MFM_KR_PORC_Controller2.SendingEmail(POReceiptIdList,TempList,'3');  
            string remo2= ASI_MFM_KR_PORC_Controller2.poReceiptClose('2016','3','3');  
            
            remo2=ASI_MFM_KR_PORC_Controller2.SendingEmail(TempList,POReceiptIdList,'3');  
            
            
            for(ASI_MFM_Settings__c item:TestDataList){
                item.ASI_MFM_Email_Notification__c=true;
            }
            update TestDataList;
            
            remo2= ASI_MFM_KR_PORC_Controller2.uncheckallflag('');
            
            ASI_MFM_KR_PORC_Controller3 con = new ASI_MFM_KR_PORC_Controller3();
            con.RunJob();
            TempList=con.statusMsgs;
            test.stopTest();  
            
            
        }
    }
    
    
    
    
    static testMethod void ASI_MFM_PORCProcess1(){
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c,ASI_MFM_Team__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        u.ASI_MFM_Team__c ='Brand Marketing';
        update u;
        
        System.runAs(u){ 
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c
                (
                    Name = 'KR_Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Plan'
                    //ASI_MFM_Fiscal_year__c = getFiscalYear()
                );
            Prefix_List.add(prefixKR_PLAN);
            
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PR',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixPR);
            
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'Payment',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            Prefix_List.add(prefixPayment);
            
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c
                (
                    Name = 'Test',
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),
                    ASI_MFM_Module__c = 'PO',
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
            //insert prefixPO;
            Prefix_List.add(prefixPO);
            
            insert Prefix_List;
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Payment = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPayment.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Payment);
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PO = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPO.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_PO); 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixKR_PLAN.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_Plan); 
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixPR.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            ASI_MFM_Setting__c setting = new ASI_MFM_Setting__c (ASI_MFM_KR_POReceiptClosing_DataVersion__c = 'V1',ASI_MFM_KR_PORC_Data_Last_Cal_Time__c=system.now(), ASI_MFM_KR_PO_Level1_Amount__c=1 , ASI_MFM_KR_PO_Level1_Checking__c=1 ,  ASI_MFM_KR_PO_Level2_Amount__c=1  , ASI_MFM_KR_PO_Level2_Percent__c=0.01 ,ASI_MFM_KR_PR_Level1_Amount__c=1, ASI_MFM_KR_PR_Level1_Checking__c=1, ASI_MFM_KR_PR_Level2_Amount__c=1 ,ASI_MFM_KR_PR_Level2_Percent__c=1);
            insert setting;
            
            
            
            //-------------------------------------------------- Project Code ----------------------------------------------------------//
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            //-------------------------------------------------- BrandGroup, Brand, SubBrand----------------------------------------------------------//
            ASI_CRM_CN_Brand_Group__c BrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Brand Group Name',
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_MFM_KR_Brand_Group'),
                                                                                 ASI_CRM_Brand_Group_Code__c = 'Code_123');
            insert BrandGroup;
            
            ASI_MFM_Brand__c Brand = new ASI_MFM_Brand__c(Name='Brand Name',
                                                          ASI_MFM_Reporting_Brand_Desc__c = 'Reporting Brand',
                                                          ASI_CRM_CN_Brand_Group_c__c = BrandGroup.id,
                                                          recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_MFM_KR_Brand'));
            insert Brand;
            
            
            List<ASI_MFM_Sub_brand__c> SBList = new List<ASI_MFM_Sub_brand__c>();
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            SBList.add(SubBrand);
            ASI_MFM_Sub_brand__c SubBrand2 = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand3',ASI_MFM_Sub_brand_Code__c='Code3');
            SBList.add(SubBrand2);
            insert SBList;
            
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c = date.today().adddays(1),
                                                        ASI_MFM_End_Date__c = date.today().adddays(1),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
            List<ASI_MFM_Plan_Line_Item__c> PlanList= new List<ASI_MFM_Plan_Line_Item__c> ();
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
                                                                                 ASI_MFM_Month_1_Cost__c = 100,
                                                                                 ASI_MFM_Month_2_Cost__c = 100,
                                                                                 ASI_MFM_Month_3_Cost__c = 100,   
                                                                                 ASI_MFM_Month_4_Cost__c = 100,
                                                                                 ASI_MFM_Month_5_Cost__c = 100,
                                                                                 ASI_MFM_Month_6_Cost__c = 100,
                                                                                 ASI_MFM_Month_7_Cost__c = 100,
                                                                                 ASI_MFM_Month_8_Cost__c = 100,
                                                                                 ASI_MFM_Month_9_Cost__c = 100,
                                                                                 ASI_MFM_Month_10_Cost__c = 100,
                                                                                 ASI_MFM_Month_11_Cost__c = 100,
                                                                                 ASI_MFM_Month_12_Cost__c = 200,
                                                                                 ASI_MFM_TH_Region__c = 'KR',
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine1);
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
                                                                                 ASI_MFM_Month_1_Cost__c = 100,
                                                                                 ASI_MFM_Month_2_Cost__c = 100,
                                                                                 ASI_MFM_Month_3_Cost__c = 100,   
                                                                                 ASI_MFM_Month_4_Cost__c = 100,
                                                                                 ASI_MFM_Month_5_Cost__c = 100,
                                                                                 ASI_MFM_Month_6_Cost__c = 100,
                                                                                 ASI_MFM_Month_7_Cost__c = 100,
                                                                                 ASI_MFM_Month_8_Cost__c = 100,
                                                                                 ASI_MFM_Month_9_Cost__c = 100,
                                                                                 ASI_MFM_Month_10_Cost__c = 100,
                                                                                 ASI_MFM_Month_11_Cost__c = 100,
                                                                                 ASI_MFM_Month_12_Cost__c = 200,
                                                                                 ASI_MFM_TH_Region__c = 'KR',
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand2.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            
            
            PlanList.add(planLine2);
            ASI_MFM_Plan_Line_Item__c planLine3 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.ID,
                                                                                 ASI_MFM_Month_1_Cost__c = 100,
                                                                                 ASI_MFM_Month_2_Cost__c = 100,
                                                                                 ASI_MFM_Month_3_Cost__c = 100,   
                                                                                 ASI_MFM_Month_4_Cost__c = 100,
                                                                                 ASI_MFM_Month_5_Cost__c = 100,
                                                                                 ASI_MFM_Month_6_Cost__c = 100,
                                                                                 ASI_MFM_Month_7_Cost__c = 100,
                                                                                 ASI_MFM_Month_8_Cost__c = 100,
                                                                                 ASI_MFM_Month_9_Cost__c = 100,
                                                                                 ASI_MFM_Month_10_Cost__c = 100,
                                                                                 ASI_MFM_Month_11_Cost__c = 100,
                                                                                 ASI_MFM_Month_12_Cost__c = 200,
                                                                                 ASI_MFM_TH_Region__c = 'KR',
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand2.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            
            
            PlanList.add(planLine3);
            
            insert PlanList;
            
            //-------------------------------------------------- Tax Code ----------------------------------------------------------//
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            
            //-------------------------------------------------- Venue----------------------------------------------------------//
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',
                                       ASI_MFM_Address_Line_1__c = '1',
                                       ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            //------------------------------------------------------- Customer ----------------------------------------------------------// 
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_PRPO_Needed__c=true,
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            //-------------------------------------------------- PR ----------------------------------------------------------//
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(),
                                                                                     ASI_MFM_Plan__c = plan1.id,
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     ASI_MFM_Prefix__c = prefixPR.id,
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                             ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            
            
            
            
            //-------------------------------------------------- PO ----------------------------------------------------------//
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Draft',
                                                 ASI_MFM_Prefix__c = prefixPO.id,
                                                 ASI_MFM_Plan__c = plan1.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 ASI_MFM_Warehouse__c = acc1.id,
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po;  
            
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                           ASI_MFM_PO__c = po.id,
                                                                           ASI_MFM_Plan_Line_Item__c = planLine1.id,
                                                                           ASI_MFM_Unit_Price__c = 1000,  
                                                                           ASI_MFM_KR_Quantity__c = 100,    
                                                                           ASI_MFM_Amount__c = 100000,
                                                                           ASI_MFM_Delivery_Date__c =  date.today(),
                                                                           ASI_MFM_G_L_Date__c = date.today(),   
                                                                           ASI_MFM_Purchase_Request_Line__c = PR_Line.id
                                                                          );
            
            insert po_line;
            Test.startTest();        
            //-------------------------------------------------- PO Receipt ----------------------------------------------------------//
            
            ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                         ASI_MFM_Status__c = 'Draft',
                                                                         recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
            
            LIST<ASI_MFM_PO_Receipt_Item__c> PORList = NEW LIST<ASI_MFM_PO_Receipt_Item__c>();
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_Plan_Line_Item__c=planLine1.Id,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c= false,
                                                                                  ASI_MFM_Amount__c = 1,
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            PORList.ADD(POR_Line);
            
            ASI_MFM_PO_Receipt_Item__c POR_Line2 = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                   ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                   ASI_MFM_Quantity__c = 1,
                                                                                   ASI_MFM_PO__c = po.id,
                                                                                   ASI_MFM_Plan_Line_Item__c=planLine2.Id,
                                                                                   ASI_MFM_Paid__c = false,
                                                                                   ASI_MFM_Amount__c = 1,
                                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            PORList.ADD(POR_Line2);
            INSERT PORList;
            
            
            //------------------------------------------------------- Payment ----------------------------------------------------------//
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Submitted',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'), ASI_MFM_Supplier_Name__c = acc2.id,ASI_MFM_PO__c = po.id,ASI_MFM_Company_Code__c = '222',ASI_MFM_Send_Approval_Email__c=true, ASI_MFM_Is_Direct_Payment__c = true,ASI_MFM_Invoice_Number__c = 'OLD INVOICE NUMBER');  
            
            insert PaymentHeader;
            
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                         ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                         ASI_MFM_Plan_Line_Item__c=planLine2.Id,  ASI_MFM_Payment_Amount__c = 1,ASI_MFM_Invoice_Number__c = 'Invoice Number',ASI_MFM_PO_Line_Item__c = po_line.id,ASI_MFM_Beneficiary_Customer__c = customer1.id);
            //ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            insert PaymentLine;
            
            database.executebatch(new ASI_MFM_KR_PORCProcess(),200);
            
            test.stopTest();       
        }
    }
    
}