/*Created by Twinkle Li @introv 02/03/2017
*
* Testclass for:
* ASI_CRM_TW_PAF_TriggerCls
* ASI_CRM_TW_PAFItems_TriggerCls
* ASI_CRM_TW_PAF_Customer_TriggerCls
* ASI_CRM_TW_PAFAssignAutoNumber
* ASI_CRM_TW_PAFConvertToPlan_Ctrl <-- Cash & FOC
* ASI_CRM_PreAppForm_RedirectView_Ctrl
* ASI_CRM_TW_ClonePAF_Ctrl
* ASI_CRM_TW_PAF_EditDetail_Ctrl
* ASI_CRM_TW_CancelPlan_Ctrl
*/

@isTest
public class ASI_CRM_TW_PAF_Test {
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
    
    public static testMethod void ASI_CRM_TW_PAF_Test() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='TW';
        update u;
                
        System.runAs(u) {
            asi_mfm_prefix__c prefix = new asi_mfm_prefix__c(
                ASI_MFM_Inactive__c = false, 
                asi_mfm_module__c = 'Plan',
                ASI_MFM_Fiscal_year__c = 'FY1617',
                Plan_Type__c = 'Trade A&P and A&D Plan'
            );
            insert prefix;
            
            asi_mfm_role_prefix_relationship__c pefixRelationship = new asi_mfm_role_prefix_relationship__c(
                asi_mfm_role_name__c = u.userRole.developerName,
                ASI_MFM_Prefix__c = prefix.id
            );
            insert pefixRelationship;
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
                name = 'testSubBrand',
                ASI_CRM_TW_Company__c = 'PRT', 
                ASI_CRM_Active__c = TRUE, 
                ASI_TH_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand_Code__c = 'SBC1',
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand')
            );
            insert sub;
            
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
            
            List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet', 
                ASI_CRM_Account__c = listOutlet[0].id, 
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
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet 1', 
                ASI_CRM_Account__c = listOutlet[1].id, 
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
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet 2', 
                ASI_CRM_Account__c = listOutlet[2].id, 
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
            
            List<ASI_MFM_A_C_Code__c> listAC = new List<ASI_MFM_A_C_Code__c>();
            listAC.add(new ASI_MFM_A_C_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                name='testAC 1',
                ASI_MFM_A_and_P_Tree__c='Total A&D',
                ASI_MFM_GL_Class__c = 'GL Class',
                ASI_CRM_Default_For__c = 'FOC')
            );
            listAC.add(new ASI_MFM_A_C_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                name='testAC 2',
                ASI_MFM_A_and_P_Tree__c = 'Total A&P',
                ASI_MFM_Reporting_Category__c = 'Consumer',
                ASI_MFM_GL_Class__c = 'GL Class',
                ASI_CRM_Default_For__c = 'Cash')
            );
            listAC.add(new ASI_MFM_A_C_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                name='testAC 3',
                ASI_MFM_A_and_P_Tree__c = 'Total A&P',
                ASI_MFM_GL_Class__c = 'GL Class',
                ASI_MFM_Reporting_Category__c = 'Trade')
            );
            insert listAC;
            
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
            
            List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> listPAFMechanic = new List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c>();
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 1',
                ASI_CRM_A_C_Code__c = listAC[0].id)
            );
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 2',
                ASI_CRM_A_C_Code__c = listAC[1].id)
            );
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 3',
                ASI_CRM_A_C_Code__c = listAC[2].id)
            );
            insert listPAFMechanic;
            
            List<ASI_HK_CRM_Pre_Approval_Form__c> listPAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
            listPAF.add(new ASI_HK_CRM_Pre_Approval_Form__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form__cASI_CRM_TW_Pre_Approval_Form'),
                ASI_HK_CRM_PAF_Customer__c = listOutlet[0].id,
                ASI_HK_CRM_PAF_Start_Date__c = system.Today(),
                ASI_HK_CRM_PAF_End_Date__c = system.Today().addMonths(3),
                ASI_HK_CRM_PAF_Status__c = 'Final')
            );
            insert listPAF;
            
            List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listPAFItem = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Contracted_Item__c = listItemGp[0].id,
                ASI_HK_CRM_Target_Volume_Qty__c = 100,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'Cash',
                ASI_CRM_Cash_Per_Bottle_w_VAT__c = 1000000)
            );
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Contracted_Item__c = listItemGp[0].id,
                ASI_HK_CRM_Target_Volume_Qty__c = 100,
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
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_HK_CRM_Mechanic__c = listPAFMechanic[2].id,
                ASI_CRM_Mechanic_Detail__c = 'detail1',
                ASI_CRM_Expenses_Product__c = listItemGp[0].id,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'FOC',
                ASI_CRM_FOC_Volume__c = 100)
            );
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment_Global_Promotion'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Contracted_Item__c = listItemGp[0].id,
                ASI_HK_CRM_Target_Volume_Qty__c = 100,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'FOC',
                ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 10,
                ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1)
            );
            /*listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_PG_Costs'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Q1_hrs__c = 10)
            );*/
            insert listPAFItem;
            system.debug('PAF Items: '+listPAFItem);
            
            List<ASI_HK_CRM_Product_Category__c> listProductC = new List<ASI_HK_CRM_Product_Category__c>();
            listProductC.add(new ASI_HK_CRM_Product_Category__c(
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Product_Category__cASI_CRM_TW_Product_Category'),
                Name = 'Product Category',
                ASI_CRM_For_PAF__c = TRUE,
                ASI_HK_CRM_Sequence__c = 1)
            );
            listProductC.add(new ASI_HK_CRM_Product_Category__c(
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Product_Category__cASI_CRM_TW_Product_Category'),
                Name = 'Product Category 2',
                ASI_CRM_For_PAF__c = TRUE,
                ASI_HK_CRM_Sequence__c = 2)
            );
            insert listProductC;
            
            List<ASI_CRM_CalculatedSalesVolume__c> listCSV = new List<ASI_CRM_CalculatedSalesVolume__c>();
            listCSV.add(new ASI_CRM_CalculatedSalesVolume__c(
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CalculatedSalesVolume__cASI_CRM_TW_Capacity'),
                ASI_CRM_Competitor__c = 'Others',
                ASI_CRM_Company__c = 'Competitor',
                ASI_CRM_ProductCategory__c = listProductC[0].id,
                ASI_CRM_Pre_Approval_Form__c = listPAF[0].id,
                ASI_CRM_Bottle__c = 10)
            );
            insert listCSV;
            
            Test.starttest();
            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> listPAFCustomer = [SELECT id FROM ASI_CRM_HK_Pre_Approval_Form_Customer__c WHERE ASI_CRM_HK_Pre_Approval_Form__c =: listPAF[0].id];
            update listPAFCustomer;
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listPAF[0]);
            ASI_CRM_PreAppForm_RedirectView_Ctrl controller = new ASI_CRM_PreAppForm_RedirectView_Ctrl(stdController); 
            controller.redirect();
            
            ApexPages.currentPage().getParameters().put('id', listPAF[0].Id);
            ASI_CRM_TW_PAFConvertToPlan_Ctrl controller1 = new ASI_CRM_TW_PAFConvertToPlan_Ctrl(stdController); 
            controller1.getPrefixes();
            //controller1.proceed();
            
            ASI_CRM_TW_ClonePAF_Ctrl controller2 = new ASI_CRM_TW_ClonePAF_Ctrl(stdController); 
            controller2.clonePAF();
            
            //listPAF[0].ASI_HK_CRM_PAF_Customer__c = listOutlet[1].id;
            listPAF[0].ASI_HK_CRM_PAF_Status__c = 'Draft';
            update listPAF;
            
            controller1 = new ASI_CRM_TW_PAFConvertToPlan_Ctrl(stdController); 
            delete listPAF[0];
            
            Test.stoptest();
        }
    }

    public static testMethod void ASI_CRM_NoneTW_PAF_Test() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='HK';
        update u;
                
        System.runAs(u) {
            asi_mfm_prefix__c prefix = new asi_mfm_prefix__c(
                ASI_MFM_Inactive__c = false, 
                asi_mfm_module__c = 'Plan',
                ASI_MFM_Fiscal_year__c = 'FY1617',
                Plan_Type__c = 'Trade A&P and A&D Plan'
            );
            insert prefix;
            
            asi_mfm_role_prefix_relationship__c pefixRelationship = new asi_mfm_role_prefix_relationship__c(
                asi_mfm_role_name__c = u.userRole.developerName,
                ASI_MFM_Prefix__c = prefix.id
            );
            insert pefixRelationship;
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
                name = 'testSubBrand',
                ASI_CRM_TW_Company__c = 'PRT', 
                ASI_CRM_Active__c = TRUE, 
                ASI_TH_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand_Code__c = 'SBC1',
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand')
            );
            insert sub;
            
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
            
            List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet', 
                ASI_CRM_Account__c = listOutlet[0].id, 
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
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet 1', 
                ASI_CRM_Account__c = listOutlet[1].id, 
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
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet 2', 
                ASI_CRM_Account__c = listOutlet[2].id, 
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
            
            List<ASI_MFM_A_C_Code__c> listAC = new List<ASI_MFM_A_C_Code__c>();
            listAC.add(new ASI_MFM_A_C_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                name='testAC 1',
                ASI_MFM_A_and_P_Tree__c='Total A&D',
                ASI_MFM_GL_Class__c = 'GL Class',
                ASI_CRM_Default_For__c = 'FOC')
            );
            listAC.add(new ASI_MFM_A_C_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                name='testAC 2',
                ASI_MFM_A_and_P_Tree__c = 'Total A&P',
                ASI_MFM_Reporting_Category__c = 'Consumer',
                ASI_MFM_GL_Class__c = 'GL Class',
                ASI_CRM_Default_For__c = 'Cash')
            );
            listAC.add(new ASI_MFM_A_C_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                name='testAC 3',
                ASI_MFM_A_and_P_Tree__c = 'Total A&P',
                ASI_MFM_GL_Class__c = 'GL Class',
                ASI_MFM_Reporting_Category__c = 'Trade')
            );
            insert listAC;
            
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
            
            List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> listPAFMechanic = new List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c>();
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 1',
                ASI_CRM_A_C_Code__c = listAC[0].id)
            );
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 2',
                ASI_CRM_A_C_Code__c = listAC[1].id)
            );
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 3',
                ASI_CRM_A_C_Code__c = listAC[2].id)
            );
            insert listPAFMechanic;
            
            List<ASI_HK_CRM_Pre_Approval_Form__c> listPAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
            listPAF.add(new ASI_HK_CRM_Pre_Approval_Form__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form__cASI_CRM_TW_Pre_Approval_Form'),
                ASI_HK_CRM_PAF_Customer__c = listOutlet[0].id,
                ASI_HK_CRM_PAF_Start_Date__c = system.Today(),
                ASI_HK_CRM_PAF_End_Date__c = system.Today().addMonths(3),
                ASI_HK_CRM_PAF_Status__c = 'Final')
            );
            insert listPAF;
            
            List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listPAFItem = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Contracted_Item__c = listItemGp[0].id,
                ASI_HK_CRM_Target_Volume_Qty__c = 100,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'Cash',
                ASI_CRM_Cash_Per_Bottle_w_VAT__c = 1000000)
            );
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Contracted_Item__c = listItemGp[0].id,
                ASI_HK_CRM_Target_Volume_Qty__c = 100,
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
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_HK_CRM_Mechanic__c = listPAFMechanic[2].id,
                ASI_CRM_Mechanic_Detail__c = 'detail1',
                ASI_CRM_Expenses_Product__c = listItemGp[0].id,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'FOC',
                ASI_CRM_FOC_Volume__c = 100)
            );
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment_Global_Promotion'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Contracted_Item__c = listItemGp[0].id,
                ASI_HK_CRM_Target_Volume_Qty__c = 100,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'FOC',
                ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 10,
                ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1)
            );
            /*listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_PG_Costs'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Q1_hrs__c = 10)
            );*/
            insert listPAFItem;
            system.debug('PAF Items: '+listPAFItem);
            
            List<ASI_HK_CRM_Product_Category__c> listProductC = new List<ASI_HK_CRM_Product_Category__c>();
            listProductC.add(new ASI_HK_CRM_Product_Category__c(
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Product_Category__cASI_CRM_TW_Product_Category'),
                Name = 'Product Category',
                ASI_CRM_For_PAF__c = TRUE,
                ASI_HK_CRM_Sequence__c = 1)
            );
            listProductC.add(new ASI_HK_CRM_Product_Category__c(
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Product_Category__cASI_CRM_TW_Product_Category'),
                Name = 'Product Category 2',
                ASI_CRM_For_PAF__c = TRUE,
                ASI_HK_CRM_Sequence__c = 2)
            );
            insert listProductC;
            
            List<ASI_CRM_CalculatedSalesVolume__c> listCSV = new List<ASI_CRM_CalculatedSalesVolume__c>();
            listCSV.add(new ASI_CRM_CalculatedSalesVolume__c(
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CalculatedSalesVolume__cASI_CRM_TW_Capacity'),
                ASI_CRM_Competitor__c = 'Others',
                ASI_CRM_Company__c = 'Competitor',
                ASI_CRM_ProductCategory__c = listProductC[0].id,
                ASI_CRM_Pre_Approval_Form__c = listPAF[0].id,
                ASI_CRM_Bottle__c = 10)
            );
            insert listCSV;
            
            Test.starttest();
            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> listPAFCustomer = [SELECT id FROM ASI_CRM_HK_Pre_Approval_Form_Customer__c WHERE ASI_CRM_HK_Pre_Approval_Form__c =: listPAF[0].id];
            update listPAFCustomer;
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listPAF[0]);
            ASI_CRM_PreAppForm_RedirectView_Ctrl controller = new ASI_CRM_PreAppForm_RedirectView_Ctrl(stdController); 
            controller.redirect();
            
            ApexPages.currentPage().getParameters().put('id', listPAF[0].Id);
            ASI_CRM_TW_PAFConvertToPlan_Ctrl controller1 = new ASI_CRM_TW_PAFConvertToPlan_Ctrl(stdController); 
            controller1.getPrefixes();
            //controller1.proceed();
            
            ASI_CRM_TW_ClonePAF_Ctrl controller2 = new ASI_CRM_TW_ClonePAF_Ctrl(stdController); 
            controller2.clonePAF();
            
            //listPAF[0].ASI_HK_CRM_PAF_Customer__c = listOutlet[1].id;
            listPAF[0].ASI_HK_CRM_PAF_Status__c = 'Draft';
            update listPAF;
            
            controller1 = new ASI_CRM_TW_PAFConvertToPlan_Ctrl(stdController); 

            delete listPAF[0];
            
            Test.stoptest();
        }
    }

    public static testMethod void ASI_CRM_NoneTW_PAF_Test2() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='HK';
        update u;
                
        System.runAs(u) {
            asi_mfm_prefix__c prefix = new asi_mfm_prefix__c(
                ASI_MFM_Inactive__c = false, 
                asi_mfm_module__c = 'Plan',
                ASI_MFM_Fiscal_year__c = 'FY1617',
                Plan_Type__c = 'Trade A&P and A&D Plan'
            );
            insert prefix;

            asi_mfm_prefix__c prefix2 = new asi_mfm_prefix__c(
                ASI_MFM_Inactive__c = false, 
                asi_mfm_module__c = 'Plan',
                ASI_MFM_Fiscal_year__c = 'FY1617',
                Plan_Type__c = 'Trade A&P Plan'
            );
            insert prefix2;
            
            asi_mfm_role_prefix_relationship__c pefixRelationship = new asi_mfm_role_prefix_relationship__c(
                asi_mfm_role_name__c = u.userRole.developerName,
                ASI_MFM_Prefix__c = prefix.id
            );
            insert pefixRelationship;

            asi_mfm_role_prefix_relationship__c pefixRelationship2 = new asi_mfm_role_prefix_relationship__c(
                asi_mfm_role_name__c = u.userRole.developerName,
                ASI_MFM_Prefix__c = prefix2.id
            );
            insert pefixRelationship2;
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
                name = 'testSubBrand',
                ASI_CRM_TW_Company__c = 'PRT', 
                ASI_CRM_Active__c = TRUE, 
                ASI_TH_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand_Code__c = 'SBC1',
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand')
            );
            insert sub;
            
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
            
            List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet', 
                ASI_CRM_Account__c = listOutlet[0].id, 
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
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet 1', 
                ASI_CRM_Account__c = listOutlet[1].id, 
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
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet 2', 
                ASI_CRM_Account__c = listOutlet[2].id, 
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
            
            List<ASI_MFM_A_C_Code__c> listAC = new List<ASI_MFM_A_C_Code__c>();
            listAC.add(new ASI_MFM_A_C_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                name='testAC 1',
                ASI_MFM_A_and_P_Tree__c='Total A&D',
                ASI_MFM_GL_Class__c = 'GL Class',
                ASI_CRM_Default_For__c = 'FOC')
            );
            listAC.add(new ASI_MFM_A_C_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                name='testAC 2',
                ASI_MFM_A_and_P_Tree__c = 'Total A&P',
                ASI_MFM_Reporting_Category__c = 'Consumer',
                ASI_MFM_GL_Class__c = 'GL Class',
                ASI_CRM_Default_For__c = 'Cash')
            );
            listAC.add(new ASI_MFM_A_C_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                name='testAC 3',
                ASI_MFM_A_and_P_Tree__c = 'Total A&P',
                ASI_MFM_GL_Class__c = 'GL Class',
                ASI_MFM_Reporting_Category__c = 'Trade')
            );
            insert listAC;
            
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
            
            List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> listPAFMechanic = new List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c>();
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 1',
                ASI_CRM_A_C_Code__c = listAC[0].id)
            );
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 2',
                ASI_CRM_A_C_Code__c = listAC[1].id)
            );
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 3',
                ASI_CRM_A_C_Code__c = listAC[2].id)
            );
            insert listPAFMechanic;
            
            List<ASI_HK_CRM_Pre_Approval_Form__c> listPAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
            listPAF.add(new ASI_HK_CRM_Pre_Approval_Form__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form__cASI_CRM_TW_Pre_Approval_Form'),
                ASI_HK_CRM_PAF_Customer__c = listOutlet[0].id,
                ASI_HK_CRM_PAF_Start_Date__c = system.Today(),
                ASI_HK_CRM_PAF_End_Date__c = system.Today().addMonths(3),
                ASI_HK_CRM_PAF_Status__c = 'Final')
            );
            insert listPAF;
            
            List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listPAFItem = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Contracted_Item__c = listItemGp[0].id,
                ASI_HK_CRM_Target_Volume_Qty__c = 100,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'Cash',
                ASI_CRM_Cash_Per_Bottle_w_VAT__c = 1000000)
            );
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Contracted_Item__c = listItemGp[0].id,
                ASI_HK_CRM_Target_Volume_Qty__c = 100,
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
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_HK_CRM_Mechanic__c = listPAFMechanic[2].id,
                ASI_CRM_Mechanic_Detail__c = 'detail1',
                ASI_CRM_Expenses_Product__c = listItemGp[0].id,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'FOC',
                ASI_CRM_FOC_Volume__c = 100)
            );
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment_Global_Promotion'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Contracted_Item__c = listItemGp[0].id,
                ASI_HK_CRM_Target_Volume_Qty__c = 100,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'FOC',
                ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 10,
                ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1)
            );
            /*listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_PG_Costs'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Q1_hrs__c = 10)
            );*/
            insert listPAFItem;
            system.debug('PAF Items: '+listPAFItem);
            
            List<ASI_HK_CRM_Product_Category__c> listProductC = new List<ASI_HK_CRM_Product_Category__c>();
            listProductC.add(new ASI_HK_CRM_Product_Category__c(
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Product_Category__cASI_CRM_TW_Product_Category'),
                Name = 'Product Category',
                ASI_CRM_For_PAF__c = TRUE,
                ASI_HK_CRM_Sequence__c = 1)
            );
            listProductC.add(new ASI_HK_CRM_Product_Category__c(
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Product_Category__cASI_CRM_TW_Product_Category'),
                Name = 'Product Category 2',
                ASI_CRM_For_PAF__c = TRUE,
                ASI_HK_CRM_Sequence__c = 2)
            );
            insert listProductC;
            
            List<ASI_CRM_CalculatedSalesVolume__c> listCSV = new List<ASI_CRM_CalculatedSalesVolume__c>();
            listCSV.add(new ASI_CRM_CalculatedSalesVolume__c(
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CalculatedSalesVolume__cASI_CRM_TW_Capacity'),
                ASI_CRM_Competitor__c = 'Others',
                ASI_CRM_Company__c = 'Competitor',
                ASI_CRM_ProductCategory__c = listProductC[0].id,
                ASI_CRM_Pre_Approval_Form__c = listPAF[0].id,
                ASI_CRM_Bottle__c = 10)
            );
            insert listCSV;
            
            Test.starttest();
            List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> listPAFCustomer = [SELECT id FROM ASI_CRM_HK_Pre_Approval_Form_Customer__c WHERE ASI_CRM_HK_Pre_Approval_Form__c =: listPAF[0].id];
            update listPAFCustomer;
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listPAF[0]);
            ASI_CRM_PreAppForm_RedirectView_Ctrl controller = new ASI_CRM_PreAppForm_RedirectView_Ctrl(stdController); 
            controller.redirect();
            
            ApexPages.currentPage().getParameters().put('id', listPAF[0].Id);
            ASI_CRM_TW_PAFConvertToPlan_Ctrl controller1 = new ASI_CRM_TW_PAFConvertToPlan_Ctrl(stdController); 
            controller1.getPrefixes();
            //controller1.proceed();
            
            ASI_CRM_TW_ClonePAF_Ctrl controller2 = new ASI_CRM_TW_ClonePAF_Ctrl(stdController); 
            controller2.clonePAF();
            
            //listPAF[0].ASI_HK_CRM_PAF_Customer__c = listOutlet[1].id;
            listPAF[0].ASI_HK_CRM_PAF_Status__c = 'Draft';
            update listPAF;
            
            controller1 = new ASI_CRM_TW_PAFConvertToPlan_Ctrl(stdController); 

            delete listPAF[0];
            
            Test.stoptest();
        }
    }
    
    public static testMethod void ASI_CRM_TW_PAF_EditDetail_Test() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='TW';
        update u;
                
        System.runAs(u) {
            asi_mfm_prefix__c prefix = new asi_mfm_prefix__c(
                ASI_MFM_Inactive__c = false, 
                asi_mfm_module__c = 'Plan',
                ASI_MFM_Fiscal_year__c = 'FY1617',
                Plan_Type__c = 'Trade A&P and A&D Plan'
            );
            insert prefix;
            
            asi_mfm_role_prefix_relationship__c pefixRelationship = new asi_mfm_role_prefix_relationship__c(
                asi_mfm_role_name__c = u.userRole.developerName,
                ASI_MFM_Prefix__c = prefix.id
            );
            insert pefixRelationship;
            
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
            
            List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet', 
                ASI_CRM_Account__c = listOutlet[0].id, 
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
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet 1', 
                ASI_CRM_Account__c = listOutlet[1].id, 
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
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet 2', 
                ASI_CRM_Account__c = listOutlet[2].id, 
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
            
            List<ASI_MFM_A_C_Code__c> listAC = new List<ASI_MFM_A_C_Code__c>();
            listAC.add(new ASI_MFM_A_C_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                name='testAC 1',
                ASI_MFM_A_and_P_Tree__c='Total A&D',
                ASI_MFM_GL_Class__c = 'GL Class',
                ASI_CRM_Default_For__c = 'FOC')
            );
            listAC.add(new ASI_MFM_A_C_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                name='testAC 2',
                ASI_MFM_A_and_P_Tree__c = 'Total A&P',
                ASI_MFM_Reporting_Category__c = 'Consumer',
                ASI_MFM_GL_Class__c = 'GL Class',
                ASI_CRM_Default_For__c = 'Cash')
            );
            listAC.add(new ASI_MFM_A_C_Code__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), 
                name='testAC 3',
                ASI_MFM_A_and_P_Tree__c = 'Total A&P',
                ASI_MFM_GL_Class__c = 'GL Class',
                ASI_MFM_Reporting_Category__c = 'Trade')
            );
            insert listAC;
            
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
            
            List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> listPAFMechanic = new List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c>();
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 1',
                ASI_CRM_A_C_Code__c = listAC[0].id)
            );
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 2',
                ASI_CRM_A_C_Code__c = listAC[1].id)
            );
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 3',
                ASI_CRM_A_C_Code__c = listAC[2].id)
            );
            insert listPAFMechanic;
            
            List<ASI_HK_CRM_Pre_Approval_Form__c> listPAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
            listPAF.add(new ASI_HK_CRM_Pre_Approval_Form__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form__cASI_CRM_TW_Pre_Approval_Form'),
                ASI_HK_CRM_PAF_Customer__c = listOutlet[0].id,
                ASI_HK_CRM_PAF_Start_Date__c = system.Today(),
                ASI_HK_CRM_PAF_End_Date__c = system.Today().addMonths(3),
                ASI_HK_CRM_PAF_Status__c = 'Final')
            );
            insert listPAF;
            
            List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listPAFItem = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Contracted_Item__c = listItemGp[0].id,
                ASI_HK_CRM_Target_Volume_Qty__c = 100,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'Cash',
                ASI_CRM_Cash_Per_Bottle_w_VAT__c = 1000000)
            );
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Contracted_Item__c = listItemGp[0].id,
                ASI_HK_CRM_Target_Volume_Qty__c = 100,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'FOC',
                ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 10,
                ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1)
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
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment'),
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
                ASI_HK_CRM_Mechanic__c = listPAFMechanic[2].id,
                ASI_CRM_Mechanic_Detail__c = 'detail2',
                ASI_CRM_Expenses_Product__c = listItemGp[0].id,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'Cash & FOC',
                ASI_CRM_FOC_Item__c = listItemGp[0].id,
                ASI_CRM_FOC_Volume__c = 100,
                ASI_CRM_Cash_Amounts_w_VAT__c = 1000000)
            );
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment_Global_Promotion'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Contracted_Item__c = listItemGp[0].id,
                ASI_HK_CRM_Target_Volume_Qty__c = 100,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'FOC',
                ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 10,
                ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1)
            );
            /*listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_PG_Costs'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Q1_hrs__c = 10)
            );*/
            insert listPAFItem;
            
            List<ASI_HK_CRM_Product_Category__c> listProductC = new List<ASI_HK_CRM_Product_Category__c>();
            listProductC.add(new ASI_HK_CRM_Product_Category__c(
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Product_Category__cASI_CRM_TW_Product_Category'),
                Name = 'Product Category',
                ASI_CRM_For_PAF__c = TRUE,
                ASI_HK_CRM_Sequence__c = 1)
            );
            listProductC.add(new ASI_HK_CRM_Product_Category__c(
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Product_Category__cASI_CRM_TW_Product_Category'),
                Name = 'Product Category 2',
                ASI_CRM_For_PAF__c = TRUE,
                ASI_HK_CRM_Sequence__c = 2)
            );
            insert listProductC;
            
            List<ASI_CRM_CalculatedSalesVolume__c> listCSV = new List<ASI_CRM_CalculatedSalesVolume__c>();
            listCSV.add(new ASI_CRM_CalculatedSalesVolume__c(
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CalculatedSalesVolume__cASI_CRM_TW_Capacity'),
                ASI_CRM_Competitor__c = 'Others',
                ASI_CRM_Company__c = 'Competitor',
                ASI_CRM_ProductCategory__c = listProductC[0].id,
                ASI_CRM_Pre_Approval_Form__c = listPAF[0].id,
                ASI_CRM_Bottle__c = 10)
            );
            insert listCSV;
            
            Test.starttest();
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listPAF[0]);
            ApexPages.currentPage().getParameters().put('id', listPAF[0].id);  
            
            ASI_CRM_TW_PAF_EditDetail_Ctrl controller = new ASI_CRM_TW_PAF_EditDetail_Ctrl(stdController);
            controller.PAFItemType = 'variable';
            controller.addPAFItems();
            controller.PAFItemType = 'conditional';
            controller.addPAFItems();
            controller.PAFItemType = 'fixed';
            controller.addPAFItems();
            controller.PAFItemType = 'global_variable';
            controller.addPAFItems();
            
            controller.intRowid = 0;
            controller.PAFItemType = 'variable';
            controller.clonePAFItems();
            controller.PAFItemType = 'conditional';
            controller.clonePAFItems();
            controller.PAFItemType = 'fixed';
            controller.clonePAFItems();
            controller.PAFItemType = 'global_variable';
            controller.clonePAFItems();

            controller.clearTargetVolumeQty();
            controller.clearAllTargetVolumeQty();
            
            controller.QuickSave();
            
            controller.intRowid = 0;
            controller.PAFItemType = 'variable';
            controller.deletePAFItems();
            controller.PAFItemType = 'conditional';
            controller.deletePAFItems();
            controller.PAFItemType = 'fixed';
            controller.deletePAFItems();
            controller.PAFItemType = 'global_variable';
            controller.deletePAFItems();

            controller.selectedSupplier = new list<string>();
            controller.selectedSupplier.add(listAccountAdditionalField[0].ASI_CRM_Account__c);
            
            controller.Save();

            System.assertEquals(controller.SupplierList, new List<SelectOption>());
            
            Test.stoptest();
        }
    }
    
    public static testMethod void ASI_CRM_TW_CancelPlan_Test() {
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        u.ASI_MFM_Country__c ='TW';
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
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(
                name = 'testSubBrand',
                ASI_CRM_TW_Company__c = 'PRT', 
                ASI_CRM_Active__c = TRUE, 
                ASI_TH_CRM_Active__c = TRUE,
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand')
            );
            insert sub;
            
            List<Account> listAcc = new List<Account>();
            listAcc.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
                Name='Test Outlet', 
                ASI_TH_CRM_Region__c ='North')
            );  
            listAcc.add(new Account(
                recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), 
                Name='Name3')
            );       
            listAcc.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), 
                Name='Test Customer')
            );  
            insert listAcc;
            
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
                ASI_MFM_Customer_Name__c = listAcc[2].id,
                ASI_MFM_Plan__c = listPlan[0].id, 
                ASI_MFM_A_C_Code__c = ac.id, 
                ASI_MFM_Total_Cost__c = 1000)
            );
            listPL.add(new ASI_MFM_Plan_Line_Item__c(
                recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), 
                ASI_MFM_List_Item_Description__c = 'testing2',
                ASI_MFM_Customer_Name__c = listAcc[2].id,
                ASI_MFM_Plan__c = listPlan[0].id, 
                ASI_MFM_A_C_Code__c = ac.id,
                ASI_MFM_Total_Cost__c = 2000)
            );
            insert listPL;
            
            /*ASI_MFM_PO__c po = new ASI_MFM_PO__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TW_PO'), 
                ASI_MFM_Plan__c = listPlan[0].id,
                ASI_MFM_Supplier_Name__c = listAcc[1].id, 
                ASI_MFM_Prefix__c = pxo.id); 
            insert po;
            
            List<ASI_MFM_PO_Line_Item__c> poLinelist = new List<ASI_MFM_PO_Line_Item__c> ();
            poLinelist.add(new ASI_MFM_PO_Line_Item__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item'), 
                ASI_MFM_PO__c = po.id, 
                ASI_MFM_Quantity__c = 10, 
                ASI_MFM_Unit_Price__c = 10, 
                ASI_MFM_A_C_Code__c = ac.id, 
                ASI_MFM_Customer_Name__c = listAcc[2].id, 
                ASI_MFM_G_L_Date__c = Date.today(), 
                ASI_MFM_List_Item_Description__c = 'testDescription', 
                ASI_MFM_Sub_brand_Code__c = sub.id)
            );
            insert poLinelist;*/
            
            test.startTest();
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listPlan[0]);
            ApexPages.currentPage().getParameters().put('id', listPlan[0].Id);
            ASI_CRM_TW_CancelPlan_Ctrl controller = new ASI_CRM_TW_CancelPlan_Ctrl(stdController); 
            controller.cancelAction();
            controller.redirectPage();
            
            listPlan[1].ASI_MFM_Status__c = 'Cancel';
            update listPlan[1];
            ApexPages.currentPage().getParameters().put('id', listPlan[1].Id);
            controller = new ASI_CRM_TW_CancelPlan_Ctrl(stdController); 
            controller.cancelAction();
            
            test.stopTest();
        }
    }
}