/*
 *Test class ASI_MFM_KR_MassUploadProcess 
			 ASI_MFM_KR_CashOutPaymentCtler
 * */

@isTest
public class ASI_MFM_KR_MassUploadCtrl_TestClass {
    
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
    
    
    
    
    static testMethod void ASI_MFM_MassUploadBudgetPLTest(){
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
            ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
            insert uploadLog;
            
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPR);
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c(Name = 'PRK',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Payment',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPayment);
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c(Name = 'PRK',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Direct PO',ASI_MFM_Fiscal_year__c = FiscalYear);
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
            
            List<ASI_MFM_Sub_brand__c> SBList = new List<ASI_MFM_Sub_brand__c>();
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Company_Code__c='222', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            SBList.add(SubBrand);
            ASI_MFM_Sub_brand__c SubBrand2 = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand3',ASI_MFM_Sub_brand_Code__c='Code3');
            SBList.add(SubBrand2);
            insert SBList;
            
            ASI_MFM_Setting__c setting = new ASI_MFM_Setting__c (ASI_MFM_KR_POReceiptClosing_DataVersion__c = 'V1',ASI_MFM_KR_PORC_Data_Last_Cal_Time__c=system.now(), ASI_MFM_KR_PO_Level1_Amount__c=1 , ASI_MFM_KR_PO_Level1_Checking__c=1 ,  ASI_MFM_KR_PO_Level2_Amount__c=1  , ASI_MFM_KR_PO_Level2_Percent__c=0.01 ,ASI_MFM_KR_PR_Level1_Amount__c=1, ASI_MFM_KR_PR_Level1_Checking__c=1, ASI_MFM_KR_PR_Level2_Amount__c=1 ,ASI_MFM_KR_PR_Level2_Percent__c=1);
            insert setting;
            //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'MA-00011',name = 'AP Code Test',ASI_MFM_AP_Category__c='AP Category',ASI_MFM_AP_Type__c='AP Type',ASI_MFM_PRPO_Needed__c=true,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_MFM_A_C_Code__c AC_Code = new ASI_MFM_A_C_Code__c (ASI_MFM_A_C_Code__c = 'Code', Name = 'Test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_KR_A_C_Code'));
            insert AC_Code;
            
            ASI_MFM_AP_AC_Code_Map__c  APACCodeMap = new ASI_MFM_AP_AC_Code_Map__c(ASI_MFM_A_C_Code__c=AC_Code.Id,ASI_MFM_AP_Code__c=AP_Code.Id);
            insert APACCodeMap;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Ven1',ASI_CRM_MY_CustomerCode__c='8112794',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            ASI_TnE_Branch_Channel__c BranchChannel = new ASI_TnE_Branch_Channel__c(Name='1300000',ASI_TnE_Branch_Channel_Desc__c='Test1',ASI_TnE_Branch_Default__c=true);
            insert BranchChannel;
            
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com', ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1',ASI_MFM_Site_Code__c='J10', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            
             ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'J10',ASI_MFM_Tax_Expl_Code__c='Test Tax',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode; 
                       
            
            Attachment att = new Attachment(ParentId = uploadLog.Id, name = 'FileName.csv', body=blob.valueOf('Fiscal Year,Type(Original Budget/Budget/LE1/LE2/LE3/LE4),Subbrand,AP Type (A&D/Media A&P/Other A&P/Trade A&P),Project Code,Budget Type(NORM/DISC),Jul,Aug,Sep,Oct,Nov,Dec,Jan,Feb,Mar,Apr,May,Jun,Fiscal Total,Budget External ID\r'+fiscalYear+',Budget,Code3,A&D,1042,NORM,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,120000,'+fiscalYear+'BudgetCode3A&D1042NORM'), ContentType ='text/plain; charset=UTF-8'); 
            insert att;
            
            
            
            test.startTest();
           
        Database.executebatch(new ASI_MFM_KR_MassUploadProcess('ASI_MFM_Budget__c', null,null, 'ASI_MFM_Fiscal_Year__c,ASI_MFM_Type__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_KR_AP_Type__c,ASI_MFM_Code__c,ASI_MFM_Budget_Type__c,ASI_MFM_P1_Amount__c,ASI_MFM_P2_Amount__c,ASI_MFM_P3_Amount__c,ASI_MFM_P4_Amount__c,ASI_MFM_P5_Amount__c,ASI_MFM_P6_Amount__c,ASI_MFM_P7_Amount__c,ASI_MFM_P8_Amount__c,ASI_MFM_P9_Amount__c,ASI_MFM_P10_Amount__c,ASI_MFM_P11_Amount__c,ASI_MFM_P12_Amount__c,ASI_MFM_Budget_External_ID_Upload__c', 'Fiscal Year,Type(Original Budget/Budget/LE1/LE2/LE3/LE4),Subbrand,AP Type (A&D/Media A&P/Other A&P/Trade A&P),Project Code,Budget Type(NORM/DISC),Jul,Aug,Sep,Oct,Nov,Dec,Jan,Feb,Mar,Apr,May,Jun,Budget External ID', 'ASI_MFM_Plan_Line_Item__c/ASI_MFM_Plan_Line_Item__c:Plan Line Item&Name,Plan Line Item RecordType&Recordtypeid; ASI_MFM_AP_Code__c/ASI_MFM_AP_Code__c:AP Code&ASI_MFM_AP_Code__c,AP Recordtype&recordtypeid; ASI_CRM_AccountsAdditionalField__c/ASI_MFM_Where_Customer__c:Where Customer&ASI_CRM_MY_CustomerCode__c,Where Customer Recordtype&recordtypeid; ASI_CRM_AccountsAdditionalField__c/ASI_MFM_Beneficiary_Customer__c:Beneficiary Customer&ASI_CRM_MY_CustomerCode__c,Beneficiary Customer Recordtype&recordtypeid; ASI_TnE_Branch_Channel__c/ASI_MFM_KR_subLedger__c:Subledger&Name,Subledger Recordtype&recordtypeid;', 'KR Budget', 
                                                                   'ASI_MFM_Project_Code__c/ASI_MFM_Code__c:Project Code&ASI_MFM_Code__c; ASI_MFM_Sub_brand__c/ASI_MFM_Sub_brand_Code__c:Sub-Brand Recordtype&RecordTypeid,Subbrand&ASI_MFM_Sub_brand_Code__c;', '', att.id, 'Payment Line Item External ID', 'ASI_MFM_Budget_External_ID_Upload__c', 'ASI_MFM_Mass_Upload_Log__c', 'ASI_MFM_Error_Message__c',
                                                                   true, true, true,fiscalYear+'LE1',''),1);
          
            test.stopTest();
            
        }
        
    }
    
    
     
    
    static testMethod void ASI_MFM_MassUploadDPTest(){
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
            ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
            insert uploadLog;
            
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPR);
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c(Name = 'PRK',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Payment',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPayment);
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c(Name = 'PRK',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Direct PO',ASI_MFM_Fiscal_year__c = FiscalYear);
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
            
            List<ASI_MFM_Sub_brand__c> SBList = new List<ASI_MFM_Sub_brand__c>();
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Company_Code__c='222', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            SBList.add(SubBrand);
            ASI_MFM_Sub_brand__c SubBrand2 = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand3',ASI_MFM_Sub_brand_Code__c='Code3');
            SBList.add(SubBrand2);
            insert SBList;
            
            ASI_MFM_Setting__c setting = new ASI_MFM_Setting__c (ASI_MFM_KR_POReceiptClosing_DataVersion__c = 'V1',ASI_MFM_KR_PORC_Data_Last_Cal_Time__c=system.now(), ASI_MFM_KR_PO_Level1_Amount__c=1 , ASI_MFM_KR_PO_Level1_Checking__c=1 ,  ASI_MFM_KR_PO_Level2_Amount__c=1  , ASI_MFM_KR_PO_Level2_Percent__c=0.01 ,ASI_MFM_KR_PR_Level1_Amount__c=1, ASI_MFM_KR_PR_Level1_Checking__c=1, ASI_MFM_KR_PR_Level2_Amount__c=1 ,ASI_MFM_KR_PR_Level2_Percent__c=1);
            insert setting;
            //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'MA-00011',name = 'AP Code Test',ASI_MFM_AP_Category__c='AP Category',ASI_MFM_AP_Type__c='AP Type',ASI_MFM_PRPO_Needed__c=true,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_MFM_A_C_Code__c AC_Code = new ASI_MFM_A_C_Code__c (ASI_MFM_A_C_Code__c = 'Code', Name = 'Test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_KR_A_C_Code'));
            insert AC_Code;
            
            ASI_MFM_AP_AC_Code_Map__c  APACCodeMap = new ASI_MFM_AP_AC_Code_Map__c(ASI_MFM_A_C_Code__c=AC_Code.Id,ASI_MFM_AP_Code__c=AP_Code.Id);
            insert APACCodeMap;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Ven1',ASI_CRM_MY_CustomerCode__c='8112794',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            ASI_TnE_Branch_Channel__c BranchChannel = new ASI_TnE_Branch_Channel__c(Name='1300000',ASI_TnE_Branch_Channel_Desc__c='Test1',ASI_TnE_Branch_Default__c=true);
            insert BranchChannel;
            
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com', ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1',ASI_MFM_Site_Code__c='J10', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            
             ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'J10',ASI_MFM_Tax_Expl_Code__c='Test Tax',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode; 
            
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( ASI_MFM_Fiscal_year__c=fiscalYear,ASI_MFM_Promotion_Code__c='Plan1',ASI_MFM_Project_Code__c=pjCode.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = prefixKR_PLAN.id, ASI_MFM_Status__c='Approved', ASI_MFM_Budget_Type__c = 'NORM',OwnerId =u.id);
            insert plan1;
            
            
            List<ASI_MFM_Plan_Line_Item__c> PlanList= new List<ASI_MFM_Plan_Line_Item__c> ();
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100,ASI_MFM_Month_3_Cost__c = 100,   ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR', ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine1);
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100,ASI_MFM_Month_10_Cost__c = 100, ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200,ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000,ASI_MFM_Sub_brand_Code__c = SubBrand2.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine2);
            ASI_MFM_Plan_Line_Item__c planLine3 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id, ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,    ASI_MFM_Month_4_Cost__c = 100, ASI_MFM_Month_5_Cost__c = 100, ASI_MFM_Month_6_Cost__c = 100, ASI_MFM_Month_7_Cost__c = 100, ASI_MFM_Month_8_Cost__c = 100, ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand2.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine3);
            insert PlanList;
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),ASI_MFM_Comment__c = 'comment',ASI_MFM_PR_Name__c='PR Name',ASI_MFM_Company_Code__c = 'PRK',ASI_MFM_PR_Date__c = date.today(),ASI_MFM_Plan__c = plan1.id,ASI_MFM_Service_Item_POSM__c = 'POSM',ASI_MFM_Ship_To__c = acc1.ID,ASI_MFM_Status__c = 'Approved',ASI_MFM_Prefix__c = prefixPR.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            Attachment att = new Attachment(ParentId = uploadLog.Id, name = 'FileName.csv', body=blob.valueOf('Plan Line Item,Payee,Company,Currency,Exchange Rate,Invoice Number,Invoice Date,Subledger,AP Code,Sub Brand Code,Total Payment Amount (Including VAT),Where Customer,Beneficiary Customer,Payment Amount,AP Remark\r'+planLine1.Name+','+acc2.Id+',PRK,KRW,1,dsfds,2/23/2017,1300000,MA-00011,Code3,123,,,20,yy'), ContentType ='text/plain; charset=UTF-8'); //8112794
            insert att;
            
            
              
            List<ASI_MFM_Payment_Line_Item__c> PaymentLineList= new List<ASI_MFM_Payment_Line_Item__c>();
            
            ASI_MFM_Payment_Line_Item__c PaymentLine1 = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),ASI_MFM_Company__c='PRK',ASI_MFM_Where_Customer__c=customer1.Id,ASI_MFM_KR_subLedger__c=BranchChannel.Id,ASI_MFM_Beneficiary_Customer__c=customer1.Id,
                                                                                          ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Invoice_Date__c=system.today(),  ASI_MFM_Invoice_Number__c='t1234',ASI_MFM_BC_Code__c='1.0000',ASI_MFM_Payee__c=acc2.Id,ASI_MFM_Currency_Sys__c='KRW',ASI_MFM_GST_Amount__c=100);
            PaymentLineList.add(PaymentLine1);
           
            
            
            
            test.startTest();
           
            
            Database.executebatch(new ASI_MFM_KR_MassUploadProcess('ASI_MFM_Payment_Line_Item__c', null,null, 'ASI_MFM_Plan_Line_Item__c,ASI_MFM_Payee__c,ASI_MFM_Company__c,ASI_MFM_Currency_Sys__c,ASI_MFM_BC_Code__c,ASI_MFM_Invoice_Number__c,ASI_MFM_Invoice_Date__c,ASI_MFM_KR_subLedger__c,ASI_MFM_AP_Code__c,ASI_MFM_GST_Amount__c,ASI_MFM_Where_Customer__c,ASI_MFM_Beneficiary_Customer__c,ASI_MFM_Payment_Amount__c,ASI_MFM_AP_Remark__c', 'Plan Line Item,Payee,Company,Currency,Exchange Rate,Invoice Number,Invoice Date,Subledger,AP Code,Total Payment Amount (Including VAT),Where Customer,Beneficiary Customer,Payment Amount,AP Remark', 'ASI_MFM_Plan_Line_Item__c/ASI_MFM_Plan_Line_Item__c:Plan Line Item&Name,Plan Line Item RecordType&Recordtypeid; ASI_MFM_AP_Code__c/ASI_MFM_AP_Code__c:AP Code&ASI_MFM_AP_Code__c,AP Recordtype&recordtypeid; ASI_CRM_AccountsAdditionalField__c/ASI_MFM_Where_Customer__c:Where Customer&ASI_CRM_MY_CustomerCode__c,Where Customer Recordtype&recordtypeid; ASI_CRM_AccountsAdditionalField__c/ASI_MFM_Beneficiary_Customer__c:Beneficiary Customer&ASI_CRM_MY_CustomerCode__c,Beneficiary Customer Recordtype&recordtypeid; ASI_TnE_Branch_Channel__c/ASI_MFM_KR_subLedger__c:Subledger&Name,Subledger Recordtype&recordtypeid;', 'KR Payment Line Item', 
                                                                   'Plan Line Item RecordType:KR Plan Line Item;Subledger Recordtype:KR Branch+Channel;AP Recordtype:KR AP Code;Beneficiary Customer Recordtype:Wholesaler (KR); Where Customer Recordtype:Venue (KR);', '', att.id, 'Payment Line Item External ID', 'ASI_MFM_Payment_Line_Item_External_ID__c', 'ASI_MFM_Mass_Upload_Log__c', 'ASI_MFM_Error_Message__c',
                                                                   true, true, true,'',''),1);
          
          
            test.stopTest();
            
        }
        
    }
    
    
    
    
    static testMethod void ASI_MFM_MassUploadMapACCodePLTest(){
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
            ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
            insert uploadLog;
            
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            //PR Prefix:
            ASI_MFM_Prefix__c prefixPR = new ASI_MFM_Prefix__c(Name = 'Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'PR',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPR);
            //Payment PREFIX:
            ASI_MFM_Prefix__c prefixPayment = new ASI_MFM_Prefix__c(Name = 'PRK',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Payment',ASI_MFM_Fiscal_year__c = FiscalYear);
            Prefix_List.add(prefixPayment);
            //PO PREFIX:
            ASI_MFM_Prefix__c prefixPO = new ASI_MFM_Prefix__c(Name = 'PRK',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Direct PO',ASI_MFM_Fiscal_year__c = FiscalYear);
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
            
            List<ASI_MFM_Sub_brand__c> SBList = new List<ASI_MFM_Sub_brand__c>();
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Company_Code__c='222', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            SBList.add(SubBrand);
            ASI_MFM_Sub_brand__c SubBrand2 = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand3',ASI_MFM_Sub_brand_Code__c='Code3');
            SBList.add(SubBrand2);
            insert SBList;
            
            ASI_MFM_Setting__c setting = new ASI_MFM_Setting__c (ASI_MFM_KR_POReceiptClosing_DataVersion__c = 'V1',ASI_MFM_KR_PORC_Data_Last_Cal_Time__c=system.now(), ASI_MFM_KR_PO_Level1_Amount__c=1 , ASI_MFM_KR_PO_Level1_Checking__c=1 ,  ASI_MFM_KR_PO_Level2_Amount__c=1  , ASI_MFM_KR_PO_Level2_Percent__c=0.01 ,ASI_MFM_KR_PR_Level1_Amount__c=1, ASI_MFM_KR_PR_Level1_Checking__c=1, ASI_MFM_KR_PR_Level2_Amount__c=1 ,ASI_MFM_KR_PR_Level2_Percent__c=1);
            insert setting;
            //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'MA-00011',name = 'AP Code Test',ASI_MFM_AP_Category__c='AP Category',ASI_MFM_AP_Type__c='AP Type',ASI_MFM_PRPO_Needed__c=true,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_MFM_A_C_Code__c AC_Code = new ASI_MFM_A_C_Code__c (ASI_MFM_A_C_Code__c = 'Code', Name = 'Test', recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_KR_A_C_Code'));
            insert AC_Code;
            
            ASI_MFM_AP_AC_Code_Map__c  APACCodeMap = new ASI_MFM_AP_AC_Code_Map__c(ASI_MFM_A_C_Code__c=AC_Code.Id,ASI_MFM_AP_Code__c=AP_Code.Id);
            insert APACCodeMap;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Ven1',ASI_CRM_MY_CustomerCode__c='8112794',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            ASI_TnE_Branch_Channel__c BranchChannel = new ASI_TnE_Branch_Channel__c(Name='1300000',ASI_TnE_Branch_Channel_Desc__c='Test1',ASI_TnE_Branch_Default__c=true);
            insert BranchChannel;
            
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com', ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1',ASI_MFM_Site_Code__c='J10', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            
             ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'J10',ASI_MFM_Tax_Expl_Code__c='Test Tax',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode; 
            
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( ASI_MFM_Fiscal_year__c=fiscalYear,ASI_MFM_Promotion_Code__c='Plan1',ASI_MFM_Project_Code__c=pjCode.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = prefixKR_PLAN.id, ASI_MFM_Status__c='Approved', ASI_MFM_Budget_Type__c = 'NORM',OwnerId =u.id);
            insert plan1;
            
            
            List<ASI_MFM_Plan_Line_Item__c> PlanList= new List<ASI_MFM_Plan_Line_Item__c> ();
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100,ASI_MFM_Month_3_Cost__c = 100,   ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR', ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine1);
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100,ASI_MFM_Month_10_Cost__c = 100, ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200,ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000,ASI_MFM_Sub_brand_Code__c = SubBrand2.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine2);
            ASI_MFM_Plan_Line_Item__c planLine3 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id, ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,    ASI_MFM_Month_4_Cost__c = 100, ASI_MFM_Month_5_Cost__c = 100, ASI_MFM_Month_6_Cost__c = 100, ASI_MFM_Month_7_Cost__c = 100, ASI_MFM_Month_8_Cost__c = 100, ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand2.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine3);
            insert PlanList;
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),ASI_MFM_Comment__c = 'comment',ASI_MFM_PR_Name__c='PR Name',ASI_MFM_Company_Code__c = 'PRK',ASI_MFM_PR_Date__c = date.today(),ASI_MFM_Plan__c = plan1.id,ASI_MFM_Service_Item_POSM__c = 'POSM',ASI_MFM_Ship_To__c = acc1.ID,ASI_MFM_Status__c = 'Approved',ASI_MFM_Prefix__c = prefixPR.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            Attachment att = new Attachment(ParentId = uploadLog.Id, name = 'FileName.csv', body=blob.valueOf('Plan Line Item,Payee,Company,Currency,Exchange Rate,Invoice Number,Invoice Date,Subledger,AP Code,Sub Brand Code,Total Payment Amount (Including VAT),Where Customer,Beneficiary Customer,Payment Amount,AP Remark\r'+planLine1.Name+','+acc2.Id+',PRK,KRW,1,dsfds,2/23/2017,1300000,MA-00011,Code3,123,,,20,yy'), ContentType ='text/plain; charset=UTF-8'); //8112794
            insert att;
            
            
              
            List<ASI_MFM_Payment_Line_Item__c> PaymentLineList= new List<ASI_MFM_Payment_Line_Item__c>();
            
            ASI_MFM_Payment_Line_Item__c PaymentLine1 = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),ASI_MFM_Company__c='PRK',ASI_MFM_Where_Customer__c=customer1.Id,ASI_MFM_KR_subLedger__c=BranchChannel.Id,ASI_MFM_Beneficiary_Customer__c=customer1.Id,
                                                                                          ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Invoice_Date__c=system.today(),  ASI_MFM_Invoice_Number__c='t1234',ASI_MFM_BC_Code__c='1.0000',ASI_MFM_Payee__c=acc2.Id,ASI_MFM_Currency_Sys__c='KRW',ASI_MFM_GST_Amount__c=100);
            PaymentLineList.add(PaymentLine1);
           
            
            
            
            test.startTest();
            set<id> PlanIDSet= new set<id>();
            for(ASI_MFM_Plan_Line_Item__c pl:PlanList){
                PlanIDSet.add(pl.Id);
            }
            
            
            set<id> APCodeIDSet= new set<id>();
            APCodeIDSet.add(AP_Code.Id);
            
            Set<String> APCodeSet = new Set<String>();
            APCodeSet.add(AP_Code.Id);
            ASI_MFM_KR_MassUploadProcess con =new ASI_MFM_KR_MassUploadProcess('ASI_MFM_Payment_Line_Item__c', null,null, 'ASI_MFM_Plan_Line_Item__c,ASI_MFM_Payee__c,ASI_MFM_Company__c,ASI_MFM_Currency_Sys__c,ASI_MFM_BC_Code__c,ASI_MFM_Invoice_Number__c,ASI_MFM_Invoice_Date__c,ASI_MFM_KR_subLedger__c,ASI_MFM_AP_Code__c,ASI_MFM_GST_Amount__c,ASI_MFM_Where_Customer__c,ASI_MFM_Beneficiary_Customer__c,ASI_MFM_Payment_Amount__c,ASI_MFM_AP_Remark__c', 'Plan Line Item,Payee,Company,Currency,Exchange Rate,Invoice Number,Invoice Date,Subledger,AP Code,Total Payment Amount (Including VAT),Where Customer,Beneficiary Customer,Payment Amount,AP Remark', 'ASI_MFM_Plan_Line_Item__c/ASI_MFM_Plan_Line_Item__c:Plan Line Item&Name,Plan Line Item RecordType&Recordtypeid; ASI_MFM_AP_Code__c/ASI_MFM_AP_Code__c:AP Code&ASI_MFM_AP_Code__c,AP Recordtype&recordtypeid; ASI_CRM_AccountsAdditionalField__c/ASI_MFM_Where_Customer__c:Where Customer&ASI_CRM_MY_CustomerCode__c,Where Customer Recordtype&recordtypeid; ASI_CRM_AccountsAdditionalField__c/ASI_MFM_Beneficiary_Customer__c:Beneficiary Customer&ASI_CRM_MY_CustomerCode__c,Beneficiary Customer Recordtype&recordtypeid; ASI_TnE_Branch_Channel__c/ASI_MFM_KR_subLedger__c:Subledger&Name,Subledger Recordtype&recordtypeid;', 'KR Payment Line Item', 
                                                                   'Plan Line Item RecordType:KR Plan Line Item;Subledger Recordtype:KR Branch+Channel;AP Recordtype:KR AP Code;Beneficiary Customer Recordtype:Wholesaler (KR); Where Customer Recordtype:Venue (KR);', '', att.id, 'Payment Line Item External ID', 'ASI_MFM_Payment_Line_Item_External_ID__c', 'ASI_MFM_Mass_Upload_Log__c', 'ASI_MFM_Error_Message__c',
                                                                   true, true, true,'','');
            List<ASI_MFM_Plan_Line_Item__c>  tempList=con.MapACCodePL(PlanList,APCodeSet);                                                  
            con.DirectPaymentProcess(PaymentLineList,PlanIDSet,APCodeIDSet);
            test.stopTest();
            
        }
        
    }
    
    
    
      
    static testMethod void ASI_MFM_MassUploadPlanLineTest(){
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
            ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
            insert uploadLog;
            
            
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
            
            List<ASI_MFM_Sub_brand__c> SBList = new List<ASI_MFM_Sub_brand__c>();
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Company_Code__c='222', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            SBList.add(SubBrand);
            ASI_MFM_Sub_brand__c SubBrand2 = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand3',ASI_MFM_Sub_brand_Code__c='Code3');
            SBList.add(SubBrand2);
            insert SBList;
            
            ASI_MFM_Setting__c setting = new ASI_MFM_Setting__c (ASI_MFM_KR_POReceiptClosing_DataVersion__c = 'V1',ASI_MFM_KR_PORC_Data_Last_Cal_Time__c=system.now(), ASI_MFM_KR_PO_Level1_Amount__c=1 , ASI_MFM_KR_PO_Level1_Checking__c=1 ,  ASI_MFM_KR_PO_Level2_Amount__c=1  , ASI_MFM_KR_PO_Level2_Percent__c=0.01 ,ASI_MFM_KR_PR_Level1_Amount__c=1, ASI_MFM_KR_PR_Level1_Checking__c=1, ASI_MFM_KR_PR_Level2_Amount__c=1 ,ASI_MFM_KR_PR_Level2_Percent__c=1);
            insert setting;
            //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'MA-00011',name = 'AP Code Test',ASI_MFM_PRPO_Needed__c=true,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Ven1',ASI_CRM_MY_CustomerCode__c='8112794',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            ASI_TnE_Branch_Channel__c BranchChannel = new ASI_TnE_Branch_Channel__c(Name='1300000',ASI_TnE_Branch_Channel_Desc__c='Test1',ASI_TnE_Branch_Default__c=true);
            insert BranchChannel;
            
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com', ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            
            
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( ASI_MFM_Fiscal_year__c=fiscalYear,ASI_MFM_Promotion_Code__c='Plan1',ASI_MFM_Project_Code__c=pjCode.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = prefixKR_PLAN.id, ASI_MFM_Status__c='Approved', ASI_MFM_Budget_Type__c = 'NORM',OwnerId =u.id);
            insert plan1;
            
            
            List<ASI_MFM_Plan_Line_Item__c> PlanList= new List<ASI_MFM_Plan_Line_Item__c> ();
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100,ASI_MFM_Month_3_Cost__c = 100,   ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR', ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine1);
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100,ASI_MFM_Month_10_Cost__c = 100, ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200,ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000,ASI_MFM_Sub_brand_Code__c = SubBrand2.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine2);
            ASI_MFM_Plan_Line_Item__c planLine3 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id, ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,    ASI_MFM_Month_4_Cost__c = 100, ASI_MFM_Month_5_Cost__c = 100, ASI_MFM_Month_6_Cost__c = 100, ASI_MFM_Month_7_Cost__c = 100, ASI_MFM_Month_8_Cost__c = 100, ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand2.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine3);
            insert PlanList;
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),ASI_MFM_Comment__c = 'comment',ASI_MFM_PR_Name__c='PR Name',ASI_MFM_Company_Code__c = 'PRK',ASI_MFM_PR_Date__c = date.today(),ASI_MFM_Plan__c = plan1.id,ASI_MFM_Service_Item_POSM__c = 'POSM',ASI_MFM_Ship_To__c = acc1.ID,ASI_MFM_Status__c = 'Approved',ASI_MFM_Prefix__c = prefixPR.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            Attachment att = new Attachment(ParentId = uploadLog.Id, name = 'FileName.csv', body=blob.valueOf('Plan External ID,Sub-brand Code,Subledger,AP Code,Customer,Venue(Where),List Item Description,Plan Line Amount,Plan Line Item External ID (Upload)\r,Code3,1300000,MA-00011,,,direct payment AP code,10000,'), ContentType ='text/plain; charset=UTF-8'); //8112794
            insert att;
            
            
            
            
            test.startTest();
            
            Database.executebatch(new ASI_MFM_KR_MassUploadProcess('ASI_MFM_Plan_Line_Item__c', null,null, 'ASI_MFM_Plan__c,ASI_MFM_Sub_brand_Code__c,ASI_MFM_KR_subLedger__c,ASI_MFM_AP_Code__c,ASI_MFM_AccountsAdditionalField__c,ASI_MFM_Venue_Where__c,ASI_MFM_List_Item_Description__c,ASI_MFM_Total_Cost__c,ASI_MFM_Plan_Line_Item_External_IDUpload__c', 'Plan External ID,Sub-Brand Code,Subledger,AP Code,Customer,Venue(Where),List Item Description,Plan Line Amount,Plan Line Item External ID (Upload)', 'ASI_MFM_Plan__c/ASI_MFM_Plan__c:Plan External ID&ASI_MFM_Promotion_Code__c; ASI_MFM_Sub_brand__c/ASI_MFM_Sub_brand_Code__c:Sub-Brand Recordtype&RecordTypeid,Sub-Brand Code&ASI_MFM_Sub_brand_Code__c; ASI_MFM_AP_Code__c/ASI_MFM_AP_Code__c:AP Code&ASI_MFM_AP_Code__c,AP Recordtype&recordtypeid; ASI_CRM_AccountsAdditionalField__c/ASI_MFM_AccountsAdditionalField__c:Customer&ASI_CRM_MY_CustomerCode__c,Customer Recordtype&recordtypeid; ASI_CRM_AccountsAdditionalField__c/ASI_MFM_Venue_Where__c:Venue(Where)&ASI_CRM_MY_CustomerCode__c,Venue(Where) Recordtype&recordtypeid; ASI_TnE_Branch_Channel__c/ASI_MFM_KR_subLedger__c:Subledger&Name,Subledger Recordtype&recordtypeid;', 'KR Plan Line Item', 
                                                                   'Sub-Brand Recordtype:KR MFM Sub-Brand;Subledger Recordtype:KR Branch+Channel;AP Recordtype:KR AP Code;Customer Recordtype:Wholesaler (KR); Venue(Where) Recordtype:Venue (KR);', '', att.id, 'Plan Line Item External ID(Upload)', 'ASI_MFM_Plan_Line_Item_External_IDUpload__c', 'ASI_MFM_Mass_Upload_Log__c', 'ASI_MFM_Error_Message__c',
                                                                   true, true, true,'',''),1);
            
            test.stopTest();
            
        }
        
    }
    
    
    static testMethod void ASI_MFM_MassUploadByBatchPlanTest(){
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
            ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
            insert uploadLog;
            
            Attachment att = new Attachment(ParentId = uploadLog.Id, name = 'FileName.csv', body=blob.valueOf('Project Codes,Plan Name,Budget Type,Fiscal year,Plan External ID,Plan Raise Date,Start Date,End Date,Mechanics,Objectives\r1042,Mass Upload Plan 1,NORM,FY1617,,2016-05-05,2016-09-01,2017-06-30,Reference 1,Reference 2'), ContentType ='text/plain; charset=UTF-8'); 
            insert att;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefixKR_PLAN = new ASI_MFM_Prefix__c(Name = 'KR_Test',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_KR_Prefix'),ASI_MFM_Module__c = 'Plan');
            Prefix_List.add(prefixKR_PLAN);
            insert Prefix_List;
            
            //-------------------------------------------------- Prefix Relationship ----------------------------------------------------------//
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            ASI_MFM_Role_Prefix_Relationship__c rel_Plan = new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c = prefixKR_PLAN.id,ASI_MFM_Role_Name__c = Role_Test.DeveloperName);
            PrefixRole_List.add(rel_Plan); 
            insert PrefixRole_List;
            
            
            //-------------------------------------------------- Project Code ----------------------------------------------------------//
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            test.startTest();
            
            Database.executebatch(new ASI_MFM_KR_MassUploadProcess('ASI_MFM_plan__c', null,null, 'ASI_MFM_Project_Code__c,ASI_MFM_Plan_Name__c,ASI_MFM_Budget_Type__c,ASI_MFM_Fiscal_year__c,ASI_MFM_Plan_Raised_Date__c,ASI_MFM_Start_Date__c,ASI_MFM_End_Date__c,ASI_MFM_Status__c,ASI_MFM_Currency__c,ASI_MFM_Mechanics__c,ASI_MFM_Objectives__c', 'Project Codes,Plan Name,Budget Type,Fiscal year,Plan Raise Date,Start Date,End Date,Status,Currency,Mechanics,Objectives', 'ASI_MFM_Project_Code__c/ASI_MFM_Project_Code__c:Project Codes&ASI_MFM_Code__c,Project Codes RecordType&Recordtypeid;', 'KR Plan', 
                                                                   'Status:Draft;Project Codes RecordType:KR Project Code;Mass Uploaded Plan:true', '', att.id, 'Plan External ID', 'ASI_MFM_Promotion_Code__c', 'ASI_MFM_Mass_Upload_Log__c', 'ASI_MFM_Error_Message__c',
                                                                   true, true, true,'',''),1);
            
            test.stopTest();
            
        }
    }
    
    
    static testMethod void ASI_MFM_MassUploadByBatch_Test1(){
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
            ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
            insert uploadLog;
            
            
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
            
            List<ASI_MFM_Sub_brand__c> SBList = new List<ASI_MFM_Sub_brand__c>();
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Company_Code__c='222', recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            SBList.add(SubBrand);
            ASI_MFM_Sub_brand__c SubBrand2 = new ASI_MFM_Sub_brand__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand3',ASI_MFM_Sub_brand_Code__c='Code3');
            SBList.add(SubBrand2);
            insert SBList;
            
            ASI_MFM_Setting__c setting = new ASI_MFM_Setting__c (ASI_MFM_KR_POReceiptClosing_DataVersion__c = 'V1',ASI_MFM_KR_PORC_Data_Last_Cal_Time__c=system.now(), ASI_MFM_KR_PO_Level1_Amount__c=1 , ASI_MFM_KR_PO_Level1_Checking__c=1 ,  ASI_MFM_KR_PO_Level2_Amount__c=1  , ASI_MFM_KR_PO_Level2_Percent__c=0.01 ,ASI_MFM_KR_PR_Level1_Amount__c=1, ASI_MFM_KR_PR_Level1_Checking__c=1, ASI_MFM_KR_PR_Level2_Amount__c=1 ,ASI_MFM_KR_PR_Level2_Percent__c=1);
            insert setting;
            //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c	AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code',name = 'AP Code Test',ASI_MFM_PRPO_Needed__c=true,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            
            List<Account> AccountList = new List<Account>();
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com', ASI_MFM_Address_Line_1__c = '1',ASI_MFM_Address_Line_2__c = '2');          
            AccountList.add(acc1);
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            AccountList.add(acc2);
            
            insert AccountList;
            
            
            //-------------------------------------------------- Plan ----------------------------------------------------------//
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',ASI_MFM_Fiscal_year__c=fiscalYear,ASI_MFM_Project_Code__c=pjCode.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),ASI_MFM_Start_Date__c = date.today().adddays(1),ASI_MFM_End_Date__c = date.today().adddays(1),ASI_MFM_Prefix__c = prefixKR_PLAN.id, ASI_MFM_Status__c='Approved', ASI_MFM_Budget_Type__c = 'NORM',OwnerId =u.id);
            insert plan1;
            
            List<ASI_MFM_Plan_Line_Item__c> PlanList= new List<ASI_MFM_Plan_Line_Item__c> ();
            ASI_MFM_Plan_Line_Item__c planLine1 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100,ASI_MFM_Month_3_Cost__c = 100,   ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR', ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine1);
            ASI_MFM_Plan_Line_Item__c planLine2 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id,ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,ASI_MFM_Month_4_Cost__c = 100,ASI_MFM_Month_5_Cost__c = 100,ASI_MFM_Month_6_Cost__c = 100,ASI_MFM_Month_7_Cost__c = 100,ASI_MFM_Month_8_Cost__c = 100,ASI_MFM_Month_9_Cost__c = 100,ASI_MFM_Month_10_Cost__c = 100, ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200,ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000,ASI_MFM_Sub_brand_Code__c = SubBrand2.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine2);
            ASI_MFM_Plan_Line_Item__c planLine3 = new ASI_MFM_Plan_Line_Item__c (ASI_MFM_Plan__c = plan1.Id, ASI_MFM_AP_Code__c=AP_Code.Id,ASI_MFM_Month_1_Cost__c = 100,ASI_MFM_Month_2_Cost__c = 100, ASI_MFM_Month_3_Cost__c = 100,    ASI_MFM_Month_4_Cost__c = 100, ASI_MFM_Month_5_Cost__c = 100, ASI_MFM_Month_6_Cost__c = 100, ASI_MFM_Month_7_Cost__c = 100, ASI_MFM_Month_8_Cost__c = 100, ASI_MFM_Month_9_Cost__c = 100, ASI_MFM_Month_10_Cost__c = 100,ASI_MFM_Month_11_Cost__c = 100,ASI_MFM_Month_12_Cost__c = 200, ASI_MFM_TH_Region__c = 'KR',ASI_MFM_Total_Cost__c = 10000, ASI_MFM_Sub_brand_Code__c = SubBrand2.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            PlanList.add(planLine3);
            insert PlanList;
            
            ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),ASI_MFM_Comment__c = 'comment',ASI_MFM_PR_Name__c='PR Name',ASI_MFM_Company_Code__c = 'PRK',ASI_MFM_PR_Date__c = date.today(),ASI_MFM_Plan__c = plan1.id,ASI_MFM_Service_Item_POSM__c = 'POSM',ASI_MFM_Ship_To__c = acc1.ID,ASI_MFM_Status__c = 'Approved',ASI_MFM_Prefix__c = prefixPR.id,recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header;    
            
            Attachment att = new Attachment(ParentId = uploadLog.Id, name = 'FileName.csv', body=blob.valueOf('Plan Line Item,Customer,Sub Ledger,Sub-brand,Description,Basic POSM,AP Code,AP Description,Plan Amount,Quantity,UOM,Estimated PR Budget,Delivery Date,Purchase Requests Line External ID\r'+planLine2.Name+',44444444,1508100,OAC,,,TA-00023,Test,20000,1,EA,1,2/17/2017'), ContentType ='text/plain; charset=UTF-8'); 
            insert att;
            
            test.startTest();
            
            Database.executebatch(new ASI_MFM_KR_MassUploadProcess('ASI_MFM_Purchase_Request_Line__c', null,null, 'ASI_MFM_Plan_Line_Item__c,ASI_MFM_Description__c,ASI_MFM_Basic_POSM__c,ASI_MFM_AP_Code__c,ASI_MFM_Quantity__c,ASI_MFM_UOM__c,ASI_MFM_Estimated_PR_budget__c,ASI_MFM_Delivery_Date__c,ASI_MFM_PurchaseRequests_Line_ExternalID__c', 'Plan Line Item,Description,Basic POSM,AP Code,Quantity,UOM,Estimated PR Budget,Delivery Date,Purchase Requests Line External ID', 'ASI_MFM_Plan_Line_Item__c/ASI_MFM_Plan_Line_Item__c:Plan Line Item&Name,Plan Line Item RecordType&Recordtypeid; ASI_MFM_AP_Code__c/ASI_MFM_AP_Code__c:AP Code&ASI_MFM_AP_Code__c,AP Recordtype&recordtypeid; ASI_MFM_SKU_Code__c/ASI_MFM_Basic_POSM__c:Basic POSM&Name,SKU Recordtype&recordtypeid;', 'KR Purchase Request Line', 
                                                                   'Status:Draft;Plan Line Item RecordType:KR Plan Line Item;AP Recordtype:KR AP Code;SKU Recordtype:KR MFM SKU', '', att.id, 'Purchase Requests Line External ID', 'ASI_MFM_PurchaseRequests_Line_ExternalID__c', 'ASI_MFM_Mass_Upload_Log__c', 'ASI_MFM_Error_Message__c',
                                                                   true, true, true,'',PR_Header.Id),1);
            
            test.stopTest();
            
        }
        
    }
    
    
    
    static testMethod void ASI_MFM_MassUploadByBatch_Test(){
        Account a = new Account(name='test', recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'));
        insert a;
        Contact c = new Contact(accountid=a.id,firstname='James',lastname='test', recordTypeId = Global_RecordTypeCache.getRtId('ContactASI_HK_CRM_Wholesalers_Outlets'));
        insert c;
        
        
        test.startTest();
        ASI_MFM_KR_MassUploadByBatchController controller = new ASI_MFM_KR_MassUploadByBatchController();
        controller.emailNotification = true;
        controller.ObjAPIName = 'Contact';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'AccountID';  
        controller.recordtypeName = 'contactType1';
        controller.fields = 'firstname,lastname,description,reportstoid,DoNotCall,Birthdate,reportstoid';
        controller.fieldsLabel = 'firstname,lastname,description,reportsto,DoNotCall,Birthdate,reportsto';
        controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = 'birthdate:2013-01-01';
        controller.upsertMode = false;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        
        controller.init();
        controller.filesize = 2000;
        controller.namefile = 'test.csv';
        controller.contentFile = blob.valueOf('firstname,lastname,description,DoNotCall,Birthdate,reportsto\rJohn,Test,desc,Y,2013-08-01,test\rJohn,Test,desc,N,2013-08-01,test');
        controller.uploadCSVByBatch();
        
        
        controller.ObjAPIName = 'Account';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'ParentId';
        controller.recordtypeName = '';
        //controller.fields = 'name,NumberOfEmployees,AnnualRevenue,PersonDoNotCall,PersonBirthdate,PersonMobilePhone';
        controller.fields = 'PersonDoNotCall,PersonBirthdate,PersonMobilePhone';
        controller.fieldsLabel = 'DoNotCall,Birthdate,mobile';
        controller.lookupEXID = 'account/ParentId:ParentId-par';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.upsertMode = false;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        controller.contentFile = blob.valueOf('True,,NumberOfEmployeesAnnualRevenue\rJohn,1,3');
        controller.emailNotification = true;
        controller.uploadCSVByBatch();
        
        controller.uploadCSV();
        controller.refreshPage();
        controller.refreshPage2();
        
        controller.ObjAPIName = 'Account';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'ParentId';
        controller.recordtypeName = '';
        controller.fields = 'name,NumberOfEmployees,AnnualRevenue';
        controller.fieldsLabel = 'name,NumberOfEmployees,AnnualRevenue';
        controller.lookupEXID = 'account/ParentId:ParentId-par';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.upsertMode = true;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        controller.contentFile = blob.valueOf('name,,NumberOfEmployeesAnnualRevenue\rJohn,1,3');
        controller.emailNotification = true;
        controller.uploadCSVByBatch();
        
        controller.uploadCSV();
        controller.refreshPage();
        controller.refreshPage2();
        
        //Kammy starts:
        controller.ObjAPIName = 'Account';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'ParentId';
        controller.recordtypeName = '';
        controller.fields = 'PersonDoNotCall,PersonBirthdate,PersonMobilePhone';
        controller.fieldsLabel = 'DoNotCall,Birthdate,mobile';
        controller.lookupEXID = 'account/ParentId:ParentId-par';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.upsertMode = false;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        controller.contentFile = blob.valueOf('True,NumberOfEmployeesAnnualRevenue\rJohn,1,3');
        controller.emailNotification = true;
        controller.uploadCSVByBatch();
        
        controller.uploadCSV();
        controller.refreshPage();
        controller.refreshPage2();
        
        //Kammy starts:
        controller.ObjAPIName = 'Account';
        controller.parentID = String.valueof(a.id);
        controller.parentField = 'ParentId';
        controller.recordtypeName = '';
        controller.fields = 'PersonDoNotCall,AnnualRevenue,PersonMobilePhone,ASI_KOR_Venue_PR_Market_Share__c';
        controller.fieldsLabel = 'DoNotCall,Annual Revenue,mobile,PRK_MS';
        controller.lookupEXID = 'account/ParentId:ParentId-par';
        controller.template = 'ASI_MFM_PlanLineItemTemplate';
        controller.currentPageURL = String.valueof(a.id);
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.upsertMode = false;
        controller.parentObjectAPIName = 'Account';
        controller.ParentObjectUploadMsg = 'Description';
        controller.contentFile = blob.valueOf('1,19,3,10');
        controller.emailNotification = true;
        controller.uploadCSVByBatch();
        
        controller.uploadCSV();
        controller.refreshPage();
        controller.refreshPage2();
        
        //Kammy starts:  KR Budget 
        controller.emailNotification = true;
        controller.ObjAPIName = 'ASI_MFM_Budget__c';
        controller.recordtypeName = 'KR Budget';
        controller.fields = 'asi_mfm_type__c,ASI_MFM_P10_Amount__c,ASI_MFM_Total_Amount__c,ASI_MFM_Fiscal_Year__c';       //API Name
        controller.fieldsLabel = 'Type,P10 Amount,Total Amount,Fiscal Year';  //Label 
        controller.template = 'ASI_KR_Budget_Tempalte';
        controller.inlineVF = true;
        controller.DefaultValues = '';
        controller.upsertMode = false;
        controller.contentFile = blob.valueOf('LE10,100,100,FY1516');
        controller.uploadCSVByBatch();
        
        controller.uploadCSV();
        controller.refreshPage();
        controller.refreshPage2();
        
        string[] TempList=controller.statusMsgs;
        
        test.stopTest();
    }
    
    static testMethod void ASI_MFM_MassUploadByBatch_Test_2(){
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        update u;
        
        System.runAs(u){ 
            
            Account a = new Account(name='test', recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_GF_Customer'));
            insert a;
            Contact c = new Contact(accountid=a.id,firstname='James',lastname='test', recordTypeId = Global_RecordTypeCache.getRtId('ContactASI_HK_CRM_Wholesalers_Outlets'));
            insert c;
            
            Account b = new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_KOR_Venue'),name = 'Venue');
            insert b;
            
            ASI_MFM_KR_MassUploadByBatchController controller = new ASI_MFM_KR_MassUploadByBatchController();
            controller.emailNotification = true;
            controller.batchMode = false;
            controller.ObjAPIName = 'Contact';
            controller.parentID = String.valueof(a.id);
            controller.parentField = 'AccountID';  
            controller.recordtypeName = 'contactType1';
            controller.fields = 'firstname,lastname,description,reportstoid,DoNotCall,Birthdate,reportstoid';
            controller.fieldsLabel = 'firstname,lastname,description,reportsto,DoNotCall,Birthdate,reportsto';
            controller.lookupEXID = 'contact/reportstoid:reportsto-lastname';
            controller.template = 'ASI_MFM_PlanLineItemTemplate';
            controller.currentPageURL = String.valueof(a.id);
            controller.inlineVF = true;
            controller.DefaultValues = 'birthdate:2013-01-01';
            controller.upsertMode = false;
            controller.parentObjectAPIName = 'Account';
            controller.ParentObjectUploadMsg = 'Description';
            
            controller.init();
            controller.filesize = 2000;
            controller.namefile = 'test.csv';
            controller.contentFile = blob.valueOf('firstname,lastname,description,DoNotCall,Birthdate,reportsto\rJohn,Test,desc,Y,2013-08-01,test\rJohn,Test,desc,N,2013-08-01,test');
            controller.uploadCSVByBatch();
            
            //Kammy starts:  POSM
            controller.currentPageURLOutput = '12';
            //controller.template2 = 'string';
            controller.report = 'report';
            controller.batchMode = true;
            controller.dummyVar = true;
            controller.objName = 'ObjectName';
            controller.emailNotification = false;
            controller.ObjAPIName = 'ASI_KOR_POSM_Order_Request__c';
            controller.recordtypeName = 'New POSM Request';
            controller.fields = 'ASI_MFM_KR_POSM_Order_Request_Name__c,ASI_MFM_Total_Amount__c,ASI_MFM_KR_EmailSentTime__c';       //API Name
            controller.fieldsLabel = 'POSM Order Request Name,Total Amount,Email Sent Time';  //Label 
            controller.template = 'ASI_KR_POSM_Tempalte';
            controller.inlineVF = true;
            controller.DefaultValues = '';
            controller.upsertMode = false;
            controller.recEXID = 'POSM Order Request Name';
            controller.recEXIDcol = 'ASI_MFM_KR_POSM_Order_Request_Name__c';
            controller.contentFile = blob.valueOf('1234500000000067,100,2015-08-01:T08:00:00');
            controller.uploadCSVByBatch();
            
            
            controller.uploadCSV();
            controller.refreshPage();
            controller.refreshPage2();
            
            //Kammy starts:  POSM attachment size
            controller.emailNotification = false;
            controller.ObjAPIName = 'ASI_KOR_POSM_Order_Request__c';
            controller.recordtypeName = 'New POSM Request';
            controller.fields = 'ASI_MFM_KR_POSM_Order_Request_Name__c,ASI_MFM_Total_Amount__c';       //API Name
            controller.fieldsLabel = 'POSM Order Request Name,Total Amount';  //Label 
            controller.template = 'ASI_KR_POSM_Tempalte';
            controller.inlineVF = true;
            controller.DefaultValues = '';
            controller.upsertMode = false;
            controller.recEXIDcol = 'ASI_MFM_KR_POSM_Order_Request_Name__c';
            controller.filesize = 5242881;
            controller.namefile = 'test.csv';
            controller.contentFile = blob.valueOf('"1234567",100');
            controller.currentPageURL ='';
            controller.uploadCSVByBatch();
            
            controller.uploadCSV();
            controller.refreshPage();
            controller.refreshPage2();
            
            test.startTest();     
            
            //Kammy starts:  POSM lookupEXID
            
            //Kammy starts:  POSM attachment is excel
            controller.emailNotification = false;
            controller.ObjAPIName = 'ASI_KOR_POSM_Order_Request__c';
            controller.recordtypeName = 'New POSM Request';
            controller.fields = 'ASI_MFM_KR_POSM_Order_Request_Name__c,ASI_MFM_Total_Amount__c,ASI_MFM_PO_External_ID1__c';       //API Name
            controller.fieldsLabel = 'POSM Order Request Name,Total Amount,PO External ID';  //Label 
            controller.template = 'ASI_KR_POSM_Tempalte';
            controller.lookupEXID = 'ASI_MFM_PO__c/ASI_MFM_PO_External_ID1__c:PO External ID&ASI_MFM_PO_External_ID__c';
            controller.inlineVF = true;
            controller.DefaultValues = '';
            controller.upsertMode = false;  
            controller.recEXIDcol = 'ASI_MFM_KR_POSM_Order_Request_Name__c';
            controller.filesize = 100;
            controller.namefile = 'test.doc';
            controller.contentFile = blob.valueOf('1234567,100');
            controller.currentPageURL ='';
            controller.uploadCSVByBatch();
            
            controller.uploadCSV();
            controller.refreshPage();
            controller.refreshPage2();
            
            
            test.stopTest();
        } 
    }
    
    static testMethod void ASI_MFM_MassUploadByBatch_Test_3(){
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        update u;
        
        System.runAs(u){ 
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc1;
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name2',ASI_KOR_Customer_Code__c ='6028513');          
            insert acc2;
            
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
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042',ASI_MFM_Offset__c=true);
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
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
            
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            //Prefix Relationship
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
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            ASI_TnE_Branch_Channel__c tempBraCha1 = new ASI_TnE_Branch_Channel__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel'),
                                                                              Name = '1311000',
                                                                              ASI_TnE_Branch_Default__c = true);
            
            insert tempBraCha1;
            
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_Offset_Payment__c=true,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_KR_A_C_Code'));
	        insert ac;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',  
                                                        OwnerId =u.id);
            insert plan1;
            
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
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Approved',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment_Read_Only'),
                                                                      ASI_MFM_Supplier_Name__c = acc1.id,
                                                                      //ASI_MFM_PO__c = po.id,
                                                                      ASI_MFM_Company_Code__c = '222',
                                                                      ASI_MFM_Currency__c = 'KRW',
                                                                      //ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_Payment_Amount__c = 1000,
                                                                      ASI_MFM_Cash_Out_Payment__c = true);  
            
            insert PaymentHeader;
            
            ASI_MFM_Payment__c PaymentHeader1 = [select id, name from ASI_MFM_Payment__c where id = :PaymentHeader.Id];
            ASI_MFM_Plan__c plan2 = [select id, name from ASI_MFM_Plan__c where id = :plan1.Id]; 
            
            ASI_MFM_KR_MassUploadByBatchController controller = new ASI_MFM_KR_MassUploadByBatchController();
            controller.emailNotification = true;
            controller.batchMode = false;
            controller.ObjAPIName = 'ASI_MFM_Payment_Line_Item__c';
            //controller.parentID = String.valueof(plan1.id);
            //controller.parentField = 'ASI_MFM_Plan_Number__c';  
            controller.recordtypeName = 'KR Payment Line Item';
            controller.fields = 'ASI_MFM_Promotion_Month__c,ASI_MFM_Plan_Number__c,ASI_MFM_Cashout_Payment_Number__c,ASI_MFM_Payment_List_Item_Description__c,ASI_MFM_KR_subLedger__c,ASI_MFM_Sub_brand__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Company__c,ASI_MFM_Type__c';
            controller.fieldsLabel = 'PM(YYYYMM),Promotion Code,Cash Out Payment ID,Description,Subledger,SubBrand Code,Offset Amount,Company,Type(Normal/Adjustment/Default Provision/Write-off)';
            controller.lookupEXID = 'ASI_MFM_Plan__c/ASI_MFM_Plan_Number__c:Promotion Code&Name,Plan RecordType&Recordtypeid;ASI_TnE_Branch_Channel__c/ASI_MFM_KR_subLedger__c:Subledger&Name,Subledger Recordtype&recordtypeid;ASI_MFM_Payment__c/ASI_MFM_Cashout_Payment_Number__c:Cash Out Payment ID&Name,Cash Out Payment recordType&recordtypeid;ASI_MFM_Sub_brand__c/ASI_MFM_Sub_brand__c:SubBrand Code&ASI_MFM_Sub_brand_Code__c,SubBrand RecordType&recordtypeid;';
            controller.template = 'ASI_MFM_KR_PlanTemplate';
            controller.currentPageURL = String.valueof(plan1.id);
            controller.inlineVF = true;
            controller.DefaultValues = 'SubBrand RecordType:KR MFM Sub-Brand;Cash Out Payment recordType:KR Payment Read-Only;Plan Line Item RecordType:KR Plan Line Item;Subledger Recordtype:KR Branch+Channel;Plan RecordType:KR Plan Read-Only;';
            controller.upsertMode = true;
            controller.parentObjectAPIName = 'ASI_MFM_Mass_Upload_Log__c';
            controller.ParentObjectUploadMsg = 'ASI_MFM_Error_Message__c';
            controller.offsetPayment = true;
            controller.opt_allOrNone = true;
            controller.recEXID = 'Payment Line Item External ID';
            controller.recEXIDCol = 'ASI_MFM_Payment_Line_Item_External_ID__c';

            test.startTest();            
            controller.init();
            controller.filesize = 2000;
            controller.namefile = 'test.csv';
            controller.contentFile = blob.valueOf('PM(YYYYMM),Promotion Code,Cash Out Payment ID,Description,Subledger,SubBrand Code,Offset Amount,Company,Type(Normal/Adjustment/Default Provision/Write-off)\r"201801",'+plan2.Name+',"'+PaymentHeader1.Name+'","UAT Test","'+tempBraCha1.Name+'","Code","100000000","PRK","Normal"');
            controller.uploadCSVByBatch();
            
            test.stopTest();
            
        } 
    }
    
    static testMethod void ASI_MFM_Cashout_Ctr_Test(){
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        u.ASI_KOR_User_Branch_Code__c ='505'; 
        update u;
        
        System.runAs(u){ 
            
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc1;
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name2',ASI_KOR_Customer_Code__c ='6028513');          
            insert acc2;
            
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
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code', ASI_MFM_Company_Code__c='286');
            insert SubBrand;
            
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042',ASI_MFM_Offset__c=false, ASI_MFM_Cash_Out__c=true);
            insert pjCode;
            
            //ASI_MFM_Prefix__c px = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Inactive__c = true, ASI_MFM_Module__c='PR', Plan_Type__c='test' ,ASI_MFM_Fiscal_year__c=getFiscalYear());
            //insert px;
            
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_PRPO_Needed__c = false,
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            List<ASI_MFM_Prefix__c> Prefix_List = new List<ASI_MFM_Prefix__c>();
            
            //Plan Prefix:
            
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
            
            List<ASI_MFM_Role_Prefix_Relationship__c> PrefixRole_List = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            //Prefix Relationship
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
            //insert rel_PR;
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            ASI_TnE_Branch_Channel__c tempBraCha1 = new ASI_TnE_Branch_Channel__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TnE_Branch_Channel__cASI_TnE_KR_Branch_Channel'),
                                                                              Name = '1505000',
                                                                              ASI_TnE_Branch_Default__c = true);
            
            insert tempBraCha1;
            
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(name='testAC', ASI_MFM_Offset_Payment__c=true,RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_KR_A_C_Code'));
	        insert ac;
            
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan2',
                                                        ASI_MFM_Project_Code__c=pjCode.id,
                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                                                        ASI_MFM_Start_Date__c =date.today(),
                                                        ASI_MFM_End_Date__c = date.today(),
                                                        ASI_MFM_Prefix__c = prefixKR_PLAN.id, 
                                                        ASI_MFM_Status__c='Approved',   
                                                        ASI_MFM_Budget_Type__c = 'NORM',
                                                        OwnerId =u.id);
            insert plan1;
            
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
                                                                                 ASI_MFM_Total_Cost__c = 10000,
                                                                                 ASI_MFM_Sub_brand_Code__c = SubBrand.id,
                                                                                 ASI_MFM_AP_Code__c = AP_Code.id,
                                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'));
            insert planLine1;
            
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Approved',
                                                                      recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment_Read_Only'),
                                                                      ASI_MFM_Supplier_Name__c = acc1.id,
                                                                      //ASI_MFM_PO__c = po.id,
                                                                      ASI_MFM_Company_Code__c = '222',
                                                                      ASI_MFM_Currency__c = 'KRW',
                                                                      //ASI_MFM_Send_Approval_Email__c=true,
                                                                      ASI_MFM_Payment_Amount__c = 1000,
                                                                      ASI_MFM_Cash_Out_Payment__c = true);  
            
            insert PaymentHeader;
            
            ASI_MFM_Payment__c PaymentHeader1 = [select id, name from ASI_MFM_Payment__c where id = :PaymentHeader.Id];
            ASI_MFM_Plan__c plan2 = [select id, name from ASI_MFM_Plan__c where id = :plan1.Id]; 
            /*
            ASI_MFM_KR_MassUploadByBatchController controller = new ASI_MFM_KR_MassUploadByBatchController();
            controller.emailNotification = true;
            controller.batchMode = false;
            controller.ObjAPIName = 'ASI_MFM_Payment_Line_Item__c';
            //controller.parentID = String.valueof(plan1.id);
            //controller.parentField = 'ASI_MFM_Plan_Number__c';  
            controller.recordtypeName = 'KR Payment Line Item';
            controller.fields = 'ASI_MFM_Promotion_Month__c,ASI_MFM_Plan_Number__c,ASI_MFM_Cashout_Payment_Number__c,ASI_MFM_Payment_List_Item_Description__c,ASI_MFM_KR_subLedger__c,ASI_MFM_Sub_brand__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Company__c,ASI_MFM_Type__c';
            controller.fieldsLabel = 'PM(YYYYMM),Promotion Code,Cash Out Payment ID,Description,Subledger,SubBrand Code,Offset Amount,Company,Type(Normal/Adjustment/Default Provision/Write-off)';
            controller.lookupEXID = 'ASI_MFM_Plan__c/ASI_MFM_Plan_Number__c:Promotion Code&Name,Plan RecordType&Recordtypeid;ASI_TnE_Branch_Channel__c/ASI_MFM_KR_subLedger__c:Subledger&Name,Subledger Recordtype&recordtypeid;ASI_MFM_Payment__c/ASI_MFM_Cashout_Payment_Number__c:Cash Out Payment ID&Name,Cash Out Payment recordType&recordtypeid;ASI_MFM_Sub_brand__c/ASI_MFM_Sub_brand__c:SubBrand Code&ASI_MFM_Sub_brand_Code__c,SubBrand RecordType&recordtypeid;';
            controller.template = 'ASI_MFM_KR_PlanTemplate';
            controller.currentPageURL = String.valueof(plan1.id);
            controller.inlineVF = true;
            controller.DefaultValues = 'SubBrand RecordType:KR MFM Sub-Brand;Cash Out Payment recordType:KR Payment Read-Only;Plan Line Item RecordType:KR Plan Line Item;Subledger Recordtype:KR Branch+Channel;Plan RecordType:KR Plan Read-Only;';
            controller.upsertMode = true;
            controller.parentObjectAPIName = 'ASI_MFM_Mass_Upload_Log__c';
            controller.ParentObjectUploadMsg = 'ASI_MFM_Error_Message__c';
            controller.offsetPayment = true;
            controller.opt_allOrNone = true;
            controller.recEXID = 'Payment Line Item External ID';
            controller.recEXIDCol = 'ASI_MFM_Payment_Line_Item_External_ID__c';

            test.startTest();            
            controller.init();
            controller.filesize = 2000;
            controller.namefile = 'test.csv';
            controller.contentFile = blob.valueOf('PM(YYYYMM),Promotion Code,Cash Out Payment ID,Description,Subledger,SubBrand Code,Offset Amount,Company,Type(Normal/Adjustment/Default Provision/Write-off)\r"201801",'+plan2.Name+',"'+PaymentHeader1.Name+'","UAT Test","'+tempBraCha1.Name+'","Code","100000000","PRK","Normal"');
            controller.uploadCSVByBatch();
            */
            
            test.startTest(); 
            PageReference PlanCashOut = Page.ASI_MFM_KR_CashOutPayment_Page;
            Test.setCurrentPage(PlanCashOut);
            ApexPages.currentPage().getParameters().put('pId', plan1.id);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan1);        
            ASI_MFM_KR_CashOutPaymentCtler Controller1 = new ASI_MFM_KR_CashOutPaymentCtler();
			Controller1.po_prefixes = prefixPO;
            Controller1.payment_prefixes = prefixPayment;
            Controller1.Header.pay.ASI_MFM_Contract_Start_Date__c = System.today();
            Controller1.Header.pay.ASI_MFM_Contract_End_Date__c = System.today();

            ASI_MFM_KR_CashOutPaymentCtler.HeaderObj obj1 = new ASI_MFM_KR_CashOutPaymentCtler.HeaderObj();
            String id1 = obj1.id;       
            ASI_MFM_KR_CashOutPaymentCtler.LineObj obj2 = new ASI_MFM_KR_CashOutPaymentCtler.LineObj();
            String id2 = obj2.id;
            
            Controller1.Refresh();
            Controller1.CopyFromPlan();
            
            Controller1.SaveRecord();
            Controller1.onCommitted((Double)1.0);
			//Controller1.Reset();

            ApexPages.currentpage().getParameters().put('PARAM_clone_ID','0'); 
			Controller1.cloneLine();
            
            ApexPages.currentpage().getParameters().put('PARAM_RLine_ID','1'); 
			Controller1.removeLine();
            
            try{Controller1.Reset();}catch(Exception e){}
            
            ASI_MFM_KR_CashOutPaymentCtler.retrieveExchangeRate();
            
            test.stopTest();

			try{List<Account> remo= ASI_MFM_KR_CashOutPaymentCtler.findList('Account','Name','WHERE RecordType.DeveloperName = ASI_MFM_KR_Customer');}catch(Exception e){}            
            try{List<Account> remo1= ASI_MFM_KR_CashOutPaymentCtler.findCustomers('Account','WHERE RecordType.DeveloperName = ASI_MFM_KR_Customer');}catch(Exception e){}            
			try{List<Account> remo2= ASI_MFM_KR_CashOutPaymentCtler.findAccounts('Account','WHERE RecordType.DeveloperName = ASI_MFM_KR_Customer');}catch(Exception e){}            
			try{List<Account> remo3= ASI_MFM_KR_CashOutPaymentCtler.findSObjects('Account','WHERE RecordType.DeveloperName = ASI_MFM_KR_Customer');}catch(Exception e){}            
            
        } 
    }
    
    static testMethod void ASI_MFM_Budget_TriggerTest(){
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        update u;
        
        System.runAs(u){
             //-------------------------------------------------- Project Code ----------------------------------------------------------//
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_AP_Type__c='A&D');
            insert pjCode;
            
            ASI_MFM_Budget__c budget = new ASI_MFM_Budget__c(recordtypeid=Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_KR_Budget'), ASI_MFM_Code__c=pjCode.id);
            insert budget;
        }
    }
    
}