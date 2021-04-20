@isTest
public class ASI_CRM_TW_PAFReporttest 
{
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

    static testMethod void ASI_CRM_TW_PAFReporttest1()
    {

        ASI_HK_CRM_Pre_Approval_Form__c AF = new ASI_HK_CRM_Pre_Approval_Form__c();

        ASI_CRM_TW_PAFReport controller = new ASI_CRM_TW_PAFReport();
        controller.selectedStatus = new List<String>();
        controller.dummyPAF = AF;
        controller.DownloadExcel();
        controller.selectedStatus.add('Complete');
        controller.DownloadExcel();
        controller.dummyPAF.ASI_HK_CRM_PAF_Start_Date__c = system.today();
        controller.dummyPAF.ASI_HK_CRM_PAF_End_Date__c = system.today() + 1;
        controller.DownloadExcel();
    }
    
    @future
    public static void insertUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        UserRole r = [SELECT Id FROM UserRole WHERE Name='COO'];
        User futureUser = new User(firstname = 'Future', lastname = 'User',
            alias = 'future', defaultgroupnotificationfrequency = 'N',
            digestfrequency = 'N', email = 'test@test.org',
            emailencodingkey = 'UTF-8', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey = 'America/Los_Angeles',
            username = 'futureuser@test.org',
            userpermissionsmarketinguser = false,
            userpermissionsofflineuser = false, userroleid = r.Id);
        insert(futureUser);
    }

    static testMethod void ASI_CRM_TW_PAFReport_ExportCSV()
    {
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='TW';
        update u;
        
        //PermissionSetAssignment();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ASI_CRM_TW_IT_Admin'];
        PermissionSetAssignment PSA = [select AssigneeId from PermissionSetAssignment where PermissionSetId =: ps.Id and Assignee.isactive = true and Assignee.profile.name like '%Admin%' limit 1];
        user runasu = [select id, userRole.developerName from user where id = : PSA.AssigneeId and isactive = true];
        system.debug('+++runasu: '+runasu.id);
        string rolename = runasu.userRole.developerName;
        
        System.runAs(runasu) {
        List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
        ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxp);
        ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxo);
        ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
        prList.add(pxy);
        insert prList;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=rolename));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=rolename));
        rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=rolename));
        insert rprList;
        
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                name='testAC',
                ASI_MFM_A_and_P_Tree__c='TOTAL A&P');
        insert ac;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), 
            name='testAP');
        insert ap;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_TW_Channel'), 
            Name = 'TOT (酒店)',
            ASI_CRM_CN_Channel_Code__c = 'TOT');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(
            Name = 'Piano Bar (PB)', 
            ASI_CRM_CN_Sub_Channel_Code__c = 'PB',
            ASI_CRM_CN_Channel__c = channel.id, 
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_Channel__cASI_CRM_TW_SubChannel'));
        insert subChannel;   
        
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_TW_Outlet_Type'),
            Name = 'PB (鋼琴酒吧)', 
            ASI_TH_CRM_Code__c = 'TW_PB',
            ASI_CRM_Sub_Channel__c = subChannel.id
        );
        insert outletType;
        
        List<Account> listAcc = new List<Account>();
        listAcc.add(new Account(
            RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
            Name='Test Outlet', 
            ASI_TH_CRM_Region__c ='North')
        );  
        listAcc.add(new Account(
            RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), 
            Name='Test Customer')
        );  
        insert listAcc;
        
        List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
        listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
            Name = 'Test Outlet', 
            ASI_CRM_Account__c = listAcc[0].id, 
            ASI_TH_CRM_OutletType__c = outletType.id, 
            ASI_CRM_Region__c = 'North',
            ASI_CRM_Channel__c = channel.id,
            ASI_CRM_CN_Sub_Channel__c = subChannel.id,
            ASI_CRM_City__c = 'Test City', 
            ASI_CRM_Town__c = 'Test Town', 
            ASI_CRM_TW_Street__c = 'Test Street', 
            ASI_CRM_TW_Number__c = '1', 
            ASI_CRM_TW_Floor__c = '12')
        );
        insert listAccountAdditionalField;
        
        
        List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
        listPlan.add(new ASI_MFM_Plan__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), 
            name='test', 
            ASI_MFM_End_Date__c=Date.today().addMonths(1), 
            ASI_MFM_Prefix__c=pxp.id,
            ASI_MFM_Plan_Description__c='testPlanDescription', 
            ASI_MFM_Plan_Name__c='testPlan', 
            ASI_MFM_Start_Date__c=Date.today(), 
            ASI_MFM_Status__c = 'Final')
        );
        listPlan.add(new ASI_MFM_Plan__c(
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), 
            name='test', 
            ASI_MFM_End_Date__c=Date.today().addMonths(1), 
            ASI_MFM_Prefix__c=pxp.id,
            ASI_MFM_Plan_Description__c='testPlanDescription', 
            ASI_MFM_Plan_Name__c='testPlan', 
            ASI_MFM_Start_Date__c=Date.today(), 
            ASI_MFM_Status__c = 'Final')
        );
        insert listPlan;      
        
        List<Account> listOutlet = new List<Account>();
        listOutlet.add(new Account(
            RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
            Name='Test Outlet', 
            ownerid = u.id , 
            ASI_TH_CRM_Region__c ='North')
        );  
        insert listOutlet;
        
        
        listOutlet.add(new Account(
            RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
            Name='Test Outlet 1', 
            ParentId = listOutlet[0].id, 
            ownerid = u.id , 
            ASI_TH_CRM_Region__c ='North')
        );     
        listOutlet.add(new Account(
            RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
            Name='Test Outlet 2', 
            ParentId = listOutlet[0].id, 
            ownerid = u.id , 
            ASI_TH_CRM_Region__c ='North')
        );                   
        upsert listOutlet;

        List<ASI_HK_CRM_Pre_Approval_Form__c> listPAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
        listPAF.add(new ASI_HK_CRM_Pre_Approval_Form__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form__cASI_CRM_TW_Pre_Approval_Form'),
            ASI_HK_CRM_PAF_Customer__c = listAcc[0].id,
            ASI_HK_CRM_PAF_Start_Date__c = system.Today(),
            ASI_CRM_Commitment_No__c =  listPlan[0].Id,
            ASI_HK_CRM_PAF_End_Date__c = system.Today().addMonths(3),
            ASI_HK_CRM_PAF_Status__c = 'Draft')
        );
        insert listPAF;


        ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
            name = 'testSubBrand',
            ASI_CRM_TW_Company__c = 'PRT', 
            ASI_CRM_Active__c = TRUE, 
            ASI_TH_CRM_Active__c = TRUE,
            ASI_MFM_Sub_brand_Code__c = 'SBC1',
            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand')
        );
        insert sub;

        List<ASI_MFM_Item_Group__c> listItemGp = new List<ASI_MFM_Item_Group__c>();
        listItemGp.add(new ASI_MFM_Item_Group__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group'),
            Name = 'Item Gp 1',
            ASI_CRM_Active__c = TRUE,
            ASI_CRM_Applied_To__c = 'TOT')
        );
        listItemGp.add(new ASI_MFM_Item_Group__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group'),
            Name = 'Item Gp 2',
            ASI_CRM_Active__c = TRUE,
            ASI_CRM_Applied_To__c = 'TOT',
            ASI_MFM_Sub_brand__c = sub.id)
        );
        insert listItemGp;

        List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> listPAFMechanic = new List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c>();
        listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
            Name = 'PAF Mechanic 1',
            ASI_CRM_Mechanic_Class__c = '1達成獎勵及各項贊助 (年度/半年度/季度)')
        );
        listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
            Name = 'PAF Mechanic 2',
            ASI_CRM_Mechanic_Class__c = '1達成獎勵及各項贊助 (年度/半年度/季度)')
        );
        listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
            Name = 'PAF Mechanic 3',
            ASI_CRM_Mechanic_Class__c = '1達成獎勵及各項贊助 (年度/半年度/季度)')
        );
        insert listPAFMechanic;

        Test.StartTest();

        List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listPAFItem = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment'),
            ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
            ASI_CRM_Contracted_Item__c = listItemGp[0].id,
            ASI_HK_CRM_Target_Volume_Qty__c = 100,
            ASI_HK_CRM_Mechanic__c = listPAFMechanic[0].id,
            ASI_CRM_AD_or_AP__c = 'A&D',
            ASI_CRM_Cash_or_FOC__c = 'Cash',
            ASI_CRM_Cash_Per_Bottle_w_VAT__c = 1000000)
        );
        listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment'),
            ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
            ASI_CRM_Contracted_Item__c = listItemGp[0].id,
            ASI_HK_CRM_Target_Volume_Qty__c = 100,
            ASI_HK_CRM_Mechanic__c = listPAFMechanic[0].id,
            ASI_CRM_AD_or_AP__c = 'A&D',
            ASI_CRM_Cash_or_FOC__c = 'FOC',
            ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 10,
            ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1)
        );
        listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment'),
            ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
            ASI_CRM_Contracted_Item__c = listItemGp[1].id,
            ASI_CRM_AD_or_AP__c = 'A&D',
            ASI_CRM_Cash_or_FOC__c = 'Cash & FOC',
            ASI_HK_CRM_Mechanic__c = listPAFMechanic[0].id,
            ASI_HK_CRM_Target_Volume_Qty__c = 100,
            ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 10,
            ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1,
            ASI_CRM_Cash_Per_Bottle_w_VAT__c = 1000000)
        );
        listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment'),
            ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
            ASI_HK_CRM_Mechanic__c = listPAFMechanic[0].id,
            ASI_CRM_Mechanic_Detail__c = 'detail',
            ASI_CRM_Expenses_Product__c = listItemGp[0].id,
            ASI_CRM_AD_or_AP__c = 'A&D',
            ASI_CRM_Cash_or_FOC__c = 'Cash',
            ASI_CRM_Cash_Amounts_w_VAT__c = 1000000)
        );
        listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment'),
            ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
            ASI_HK_CRM_Mechanic__c = listPAFMechanic[2].id,
            ASI_CRM_Mechanic_Detail__c = 'detail1',
            ASI_CRM_Expenses_Product__c = listItemGp[0].id,
            ASI_CRM_AD_or_AP__c = 'A&D',
            ASI_CRM_Cash_or_FOC__c = 'FOC',
            ASI_CRM_FOC_Volume__c = 100)
        );
        listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
            RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment'),
            ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
            ASI_CRM_Contracted_Item__c = listItemGp[0].id,
            ASI_HK_CRM_Target_Volume_Qty__c = 100,
            ASI_CRM_AD_or_AP__c = 'A&D',
            ASI_HK_CRM_Mechanic__c = listPAFMechanic[0].id,
            ASI_CRM_Cash_or_FOC__c = 'FOC',
            ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 10,
            ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1)
        );

        insert listPAFItem;

        List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
        listPL.add(new ASI_MFM_Plan_Line_Item__c(
            recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), 
            ASI_MFM_List_Item_Description__c = 'Cash',
            ASI_MFM_Customer_Name__c = listAcc[1].id,
            ASI_MFM_Plan__c = listPlan[0].id, 
            ASI_MFM_TW_Related_PAF_Item__c = listPAFItem[0].Id,
            ASI_MFM_A_C_Code__c = ac.id, 
            ASI_MFM_Total_Cost__c = 1000)
        );
        listPL.add(new ASI_MFM_Plan_Line_Item__c(
            recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), 
            ASI_MFM_List_Item_Description__c = 'Cash',
            ASI_MFM_Customer_Name__c = listAcc[1].id,
            ASI_MFM_Plan__c = listPlan[0].id, 
            ASI_MFM_TW_Related_PAF_Item__c = listPAFItem[1].Id,
            ASI_MFM_A_C_Code__c = ac.id,
            ASI_MFM_Total_Cost__c = 2000)
        );
        insert listPL;

        ApexPages.currentPage().getParameters().put('selectedStatus', 'Final');
        ApexPages.currentPage().getParameters().put('startDate', String.valueof(System.today().addYears(-1)));
        ApexPages.currentPage().getParameters().put('endDate', String.valueof(System.today().addYears(1)));
        ASI_CRM_TW_PAFReport_ExportCSV controller = new ASI_CRM_TW_PAFReport_ExportCSV();
        

        Test.stopTest();
        }
    }

    public class HTTPMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            string jsonResBody = '{"results":[{"address_components":[{"long_name":"Muir Lane","short_name":"Muir Ln","types":["route"]},{"long_name":"Torrey Pines","short_name":"Torrey Pines","types":["neighborhood","political"]},{"long_name":"San Diego","short_name":"San Diego","types":["locality","political"]},{"long_name":"San Diego County","short_name":"San Diego County","types":["administrative_area_level_2","political"]},{"long_name":"California","short_name":"CA","types":["administrative_area_level_1","political"]},{"long_name":"United States","short_name":"US","types":["country","political"]},{"long_name":"92161","short_name":"92161","types":["postal_code"]}],"formatted_address":"Muir Ln, San Diego, CA 92161, USA","geometry":{"location":{"lat":32.8790299,"lng":-117.2413533},"location_type":"GEOMETRIC_CENTER","viewport":{"northeast":{"lat":32.8803788802915,"lng":-117.2400043197085},"southwest":{"lat":32.8776809197085,"lng":-117.2427022802915}}},"place_id":"ChIJV1aG1sAG3IAR6EsgRezpoa0","plus_code":{"compound_code":"VQH5+JF San Diego, California, United States","global_code":"8544VQH5+JF"},"types":["establishment","point_of_interest","school"]}],"status":"OK"}';
            res.setBody(jsonResBody);
            return res;
        }
    }
}