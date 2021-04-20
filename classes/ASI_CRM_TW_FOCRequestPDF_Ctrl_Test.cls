@isTest
public class ASI_CRM_TW_FOCRequestPDF_Ctrl_Test {

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
    
    public static testMethod void ASI_CRM_TW_FOC_RequestItems_Test() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='TW';
        u.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - NBD';
        update u;
        
        System.runAs(u) {
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

            contact ct = new contact(
                lastname='a', firstname='b', ASI_HK_CRM_Main_Contact__c = true, accountid = listAcc[0].id, recordtypeid = Global_RecordTypeCache.getRtId('ContactASI_CRM_TW_Contact')
            );

            insert ct;

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
                ASI_CRM_TW_Floor__c = '12',
                ASI_CRM_MY_GeoConverStatus__c = 'Completed')
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
                // ASI_MFM_Month_1_Cost__c = 1000,
                ASI_MFM_Total_Cost__c = 1000)
            );
            listPL.add(new ASI_MFM_Plan_Line_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), 
                ASI_MFM_List_Item_Description__c = 'testing2',
                ASI_MFM_Customer_Name__c = listAcc[1].id,
                ASI_MFM_Plan__c = listPlan[0].id, 
                ASI_MFM_A_C_Code__c = ac.id,
                // ASI_MFM_Month_1_Cost__c = 2000,
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
                ASI_MFM_SKU_Description__c='測試',
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code'))
            );
            listSKU.add(new ASI_MFM_SKU_Code__c(
                name = 'POSM SKU',
                ASI_HK_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand__c = listSubBrand[0].id,
                ASI_MFM_Item_Group__c = listItemGp[0].id,
                ASI_HK_CRM_IsPOSProduct__c = TRUE,
                ASI_MFM_SKU_Description__c='測試',
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
            insert listFGR;
            
            test.startTest();
            
            List<ASI_FOC_Request_Item__c> listItems = new List<ASI_FOC_Request_Item__c>();
            //FOC
            listItems.add(new ASI_FOC_Request_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_TW_FOC_Request_Item'),
                ASI_FOC_Request_Order__c = listFGR[0].Id,
                ASI_CRM_Plan_Line_Item__c = listPL[0].Id,
                ASI_FOC_SKU__c = listSKU[0].id,
                ASI_FOC_Request_Quantity_Bottle__c = 10)
            );
            insert listItems;
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listFGR[0]);
            ApexPages.currentPage().getParameters().put('id', listFGR[0].id);  
            ASI_CRM_TW_FOCRequestPDF_Ctrl controller = new ASI_CRM_TW_FOCRequestPDF_Ctrl(stdController); 
            
            ASI_CRM_TW_ItemGroup_UtilityCls controller2 = new ASI_CRM_TW_ItemGroup_UtilityCls();
            Set<Id> setItmGpId = new Set<Id>{listItemGp[0].Id};
            List<String> strType = new List<String>{'A&D FOC Unit Cost'};
            controller2.getAllSKUpc('TOT', setItmGpId, strType);
            
            test.stopTest();
        }
    }
}