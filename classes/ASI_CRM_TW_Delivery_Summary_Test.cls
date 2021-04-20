/*Created by Twinkle Li @introv 14/03/2017
*
* Testclass for:
* ASI_CRM_TW_Order_Status_TriggerCls
* ASI_CRM_TW_DeliverySummary_Ctrl
* ASI_CRM_TW_DeliverySummaryPDF_Ctrl
*/

@isTest
public class ASI_CRM_TW_Delivery_Summary_Test {
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
    
    public static testMethod void ASI_CRM_TW_Delivery_Summary_Test() {
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
        Profile adminP = [select id from Profile where name = 'System Administrator'];
        //userrole Role_Test= new userrole(Name='TW PR',developerName='ASI_MFM_TW_PR');
        userrole Role = [select id from userrole where developerName = 'ASI_TH_CRM_I_T_Admin'];
        //insert Role_Test;
        List<User> listUser = new List<User>();
        User admin = new User(Alias = 'standt', Email='dev.pra@introv.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = adminP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='dev.pra@introv.com', userroleid = Role.id);
        listUser.add(admin);
        insert listUser;
        listUser[0].ASI_MFM_Country__c ='TW';
        update listUser[0];
        
        System.runAs(listUser[0]) {
            List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
            ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = getFiscalYear());
            prList.add(pxp);
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = getFiscalYear());
            prList.add(pxo);
            ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = getFiscalYear());
            prList.add(pxy);
            insert prList;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c='ASI_TH_CRM_I_T_Admin'));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c='ASI_TH_CRM_I_T_Admin'));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c='ASI_TH_CRM_I_T_Admin'));
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
            
            List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
            listPL.add(new ASI_MFM_Plan_Line_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), 
                ASI_MFM_List_Item_Description__c = 'testing1',
                ASI_MFM_Customer_Name__c = listAcc[1].id,
                ASI_MFM_Plan__c = listPlan[0].id, 
                ASI_MFM_A_C_Code__c = ac.id, 
                ASI_MFM_Total_Cost__c = 1000)
            );
            listPL.add(new ASI_MFM_Plan_Line_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), 
                ASI_MFM_List_Item_Description__c = 'testing2',
                ASI_MFM_Customer_Name__c = listAcc[1].id,
                ASI_MFM_Plan__c = listPlan[0].id, 
                ASI_MFM_A_C_Code__c = ac.id,
                ASI_MFM_Total_Cost__c = 2000)
            );
            insert listPL;
            
            List<ASI_MFM_Sub_brand__c> listSubBrand = new List<ASI_MFM_Sub_brand__c>();
            listSubBrand.add(new ASI_MFM_Sub_brand__c(    
                name = 'Sub-Brand 1',
                ASI_CRM_TW_Company__c = 'PRT', 
                ASI_TH_CRM_Active__c = TRUE,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'))
            );
            insert listSubBrand;
            
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
                ASI_CRM_Applied_To__c = 'TOT')
            );
            insert listItemGp;
            test.startTest();
            List<ASI_CRM_MY_SKUPriceCost__c> listSKUpc = new List<ASI_CRM_MY_SKUPriceCost__c>();
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_TW_SKU_Price_Cost'),
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_EffectiveDate__c = Date.today(),
                ASI_CRM_Type__c = 'A&D FOC Unit Cost',
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'TOT')
            );
            insert listSKUpc;
            
            List<ASI_MFM_SKU_Code__c> listSKU = new List<ASI_MFM_SKU_Code__c>();
            listSKU.add(new ASI_MFM_SKU_Code__c(
                name = 'FOC SKU',
                ASI_HK_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand__c = listSubBrand[0].id,
                ASI_MFM_Item_Group__c = listItemGp[0].id,
                ASI_HK_CRM_IsPOSProduct__c = FALSE,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code'))
            );
            listSKU.add(new ASI_MFM_SKU_Code__c(
                name = 'POSM SKU',
                ASI_HK_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand__c = listSubBrand[0].id,
                ASI_MFM_Item_Group__c = listItemGp[0].id,
                ASI_HK_CRM_IsPOSProduct__c = TRUE,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code'))
            );
            insert listSKU;
            
            List<ASI_FOC_Route_Type__c> listFOCRT = new List<ASI_FOC_Route_Type__c>();
            listFOCRT.add(new ASI_FOC_Route_Type__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Route_Type__cASI_CRM_TW_FOC_Route_Type'))
            );
            listFOCRT.add(new ASI_FOC_Route_Type__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Route_Type__cASI_CRM_TW_POSM_Route_Type'))
            );
            insert listFOCRT;
                
            List<ASI_FOC_Free_Goods_Request__c> listFGR = new List<ASI_FOC_Free_Goods_Request__c>();
            //FOC
            listFGR.add(new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_FOC_Request'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,
                ASI_CRM_Receiver__c = 'Mary',
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose',
                ASI_CRM_Plan__c = listPlan[0].Id)
            );
            //POSM
            listFGR.add(new ASI_FOC_Free_Goods_Request__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_TW_POSM_Request'),
                ASI_CRM_Target_Outlet__c = listAcc[0].Id,
                ASI_CRM_Receiver__c = 'Mary',
                ASI_CRM_SG_Order_Date__c = date.today(),
                ASI_CRM_Purpose__c = 'purpose')
            );
            insert listFGR;
            
            List<ASI_FOC_Request_Item__c> listItems = new List<ASI_FOC_Request_Item__c>();
            //FOC
            listItems.add(new ASI_FOC_Request_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_TW_FOC_Request_Item'),
                ASI_FOC_Request_Order__c = listFGR[0].Id,
                ASI_CRM_Plan_Line_Item__c = listPL[0].Id,
                ASI_FOC_SKU__c = listSKU[0].id,
                ASI_FOC_Request_Quantity_Bottle__c = 10)
            );
            //POSM
            listItems.add(new ASI_FOC_Request_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_TW_POSM_Request_Item'),
                ASI_FOC_Request_Order__c = listFGR[1].Id,
                ASI_FOC_SKU__c = listSKU[1].id,
                ASI_FOC_Request_Quantity_Bottle__c = 10)
            );
            insert listItems;
            
            
            
            List<ASI_CRM_Order_Status__c> listOS = new List<ASI_CRM_Order_Status__c>();
            listOS.add(new ASI_CRM_Order_Status__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Order_Status__cASI_CRM_TW_Order_Status'),
                ASI_CRM_FOC_POSM_Line_No__c = listItems[0].id,
                ASI_CRM_Order_Date__c = date.today(),
                ASI_CRM_Reference_No__c = '00000001',
                //ASI_CRM_JDE_Status__c = 'Complete',
                ASI_CRM_Request_Qty__c = 10,
                ASI_CRM_Shipped_Qty__c = 10)
            );
            listOS.add(new ASI_CRM_Order_Status__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Order_Status__cASI_CRM_TW_Order_Status'),
                ASI_CRM_FOC_POSM_Line_No__c = listItems[1].id,
                ASI_CRM_Order_Date__c = date.today(),
                ASI_CRM_Reference_No__c = '00000002',
                //ASI_CRM_JDE_Status__c = 'Complete',
                ASI_CRM_Request_Qty__c = 10,
                ASI_CRM_Shipped_Qty__c = 10)
            );
            insert listOS;
            update listOS;
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listOS[0]);
            ASI_CRM_TW_DeliverySummary_Ctrl controller = new ASI_CRM_TW_DeliverySummary_Ctrl(stdController); 
            controller.orderDate = date.today();
            controller.search();
            
            // controller.refNoFrom = '00000001';
            // controller.refNoTo = '00000002';
            controller.selectedType = 'FOC';
            controller.orderDate = system.today();
            controller.search();
            
            controller.generate_PDF();
            controller.download_EXCEL();
            controller.Reset();
            
            String strOrderDate = String.ValueOf(date.today());
            ApexPages.currentPage().getParameters().put('type', 'FOC');  
            ApexPages.currentPage().getParameters().put('date', strOrderDate);  
            ApexPages.currentPage().getParameters().put('rnF', '00000001');  
            ApexPages.currentPage().getParameters().put('rnT', '00000002');  
            ASI_CRM_TW_DeliverySummaryPDF_Ctrl controller1 = new ASI_CRM_TW_DeliverySummaryPDF_Ctrl(stdController); 
            
            ApexPages.currentPage().getParameters().put('type', 'POSM');  
            ApexPages.currentPage().getParameters().put('date', strOrderDate);  
            ApexPages.currentPage().getParameters().put('rnF', '00000001');  
            ApexPages.currentPage().getParameters().put('rnT', '00000002');  
            controller1 = new ASI_CRM_TW_DeliverySummaryPDF_Ctrl(stdController); 

            list<SelectOption> aaa = controller1.getTypeOptions();

            
            
            delete listOS[0];
            
            test.stopTest();
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