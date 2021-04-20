@istest

public class ASI_MFM_KR_PR_TriggerClass_Test {

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



    static testMethod void m1() {   //routineBeforeDelete
        
        String fiscalYear = getFiscalYear();
        
        userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName='test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName,ASI_KOR_User_Branch_Code__c from user where id = :userInfo.getUserId() limit 1]; 
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        update u;
        
        System.runAs(u){ 
            
            
            
            //-------------------------------------------------- Prefix  ----------------------------------------------------------//
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
            
            ASI_MFM_Role_Prefix_Relationship__c rel_PR = new ASI_MFM_Role_Prefix_Relationship__c
                (
                    ASI_MFM_Prefix__c = prefixPR.id,
                    ASI_MFM_Role_Name__c = Role_Test.DeveloperName
                );
            PrefixRole_List.add(rel_PR);
            
            insert PrefixRole_List;
            
            
            //-------------------------------------------------- Approval Process ----------------------------------------------------------//
            ASI_MFM_KR_approvalSetting__c ApprovalSettingTest = new ASI_MFM_KR_approvalSetting__c(Name = string.valueOf(Role_Test.id), ASI_KR_FAR_subCategory__c = 'XXXTrade Marketing');
            insert ApprovalSettingTest;
            
            //-------------------------------------------------- Project Code ----------------------------------------------------------//
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042', ASI_MFM_Fiscal_Year__c=fiscalyear);
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
            
            ASI_MFM_Sub_brand__c SubBrand = new ASI_MFM_Sub_brand__c(ASI_MFM_Brand__c=Brand.id,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_KR_Sub_Brand'), Name='TestSubBrand',ASI_MFM_Sub_brand_Code__c='Code');
            insert SubBrand;
            
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
            
            //-------------------------------------------------- Tax Code ----------------------------------------------------------//
            ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'Tax Code',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                                   ASI_MFM_VAT_Rate__c = 100);
            insert TaxCode;  
            //-------------------------------------------------- Customer----------------------------------------------------------//
            Account acc1 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Warehouse'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com',
                                       ASI_MFM_Address_Line_1__c = '1',
                                       ASI_MFM_Address_Line_2__c = '2');          
            insert acc1;
            
            //-------------------------------------------------- AP Code----------------------------------------------------------//
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
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
            
            
            //-------------------------------------------------- Supplier----------------------------------------------------------//
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1', ASI_LUX_Email_Business__c = 'TestingEmail@test.com');          
            insert acc2;
            
            //-------------------------------------------------- PO ----------------------------------------------------------//
            Test.startTest();        
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
    //        insert po;  
            
            delete PR_Header;
            
            test.stopTest();       
        }
    } //End of routineBeforeDelete testing
    
}