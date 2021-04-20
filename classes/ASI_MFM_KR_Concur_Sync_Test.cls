@istest

public class ASI_MFM_KR_Concur_Sync_Test {

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

    static testMethod void m1()
    {
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
            insert Prefix_List;
            
            //-------------------------------------------------- Warehouse & Venue ----------------------------------------------------------//
            ASI_CRM_AccountsAdditionalField__c CustomerTest = new ASI_CRM_AccountsAdditionalField__c(Name = string.valueOf(Role_Test.id), 
            																						   ASI_CRM_CN_Address__c = 'XXXTrade Marketing',
                                                                                                           recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Wholesaler'));
            ASI_CRM_AccountsAdditionalField__c CustomerTest2 = new ASI_CRM_AccountsAdditionalField__c(Name = string.valueOf(Role_Test.id), 
                                                                                                        ASI_CRM_CN_Address__c = 'XXXTrade Marketing',
                                                                                                            recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert CustomerTest;
            insert CustomerTest2;
            
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
            ASI_MFM_Plan__c plan1 = new ASI_MFM_Plan__c( Name = 'Test Plan 1',
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
            
            //-------------------------------------------------- PO ----------------------------------------------------------//
            Test.startTest();

                ASI_MFM_KR_WS_Sync_Batch batch = new ASI_MFM_KR_WS_Sync_Batch();
                Database.executeBatch(batch, 60);
            
            Test.stopTest();
        }
    }

    static testMethod void m2() {   //Delete record
        Test.setMock(HttpCalloutMock.class, new ASI_MFM_KR_MockHttpResponseGenerator());

        ASI_MFM_KR_Concur_Sync_Setting__c setting = new ASI_MFM_KR_Concur_Sync_Setting__c(
            ASI_MFM_End_Point__c = '123',
            ASI_MFM_API_End_Point__c = '123',
            ASI_MFM_Client_ID__c = '123',
            ASI_MFM_Client_Secret__c = '123',
            ASI_MFM_Username__c = '123',
            ASI_MFM_Password__c = '123',
            ASI_MFM_Wholesaler_List_ID__c = '123',
            ASI_MFM_Venue_List_ID__c = '123',
            ASI_MFM_Plan_List_ID__c = '123',
            ASI_MFM_Sub_Brand_List_ID__c = '123'
        );
        
        insert setting;

        Test.startTest();

            ASI_MFM_KR_ConcurAPICls concurapi = new ASI_MFM_KR_ConcurAPICls();

            String retID = concurapi.POSTItemListXML('<?xml version="1.0"?><ListItem><Level1Code >Level1Code</Level1Code><ListID>ListID</ListID><Name>Name</Name></ListItem>');
            concurapi.PUTItemListXML('ListItemID', '<?xml version="1.0"?><ListItem><Level1Code >Level1Code</Level1Code><ListID>ListID</ListID><Name>Name</Name></ListItem>');
            concurapi.DeleteItemListXML('ListItemID', 'ListID'); 

        Test.stopTest();        
    }

}