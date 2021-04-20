@isTest
public class ASI_CRM_TW_PAFPDF_Test {
    
    public static testMethod void ASI_CRM_TW_PAFPDF_Test() {
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
		user u = [select id, userRole.developerName from user where id = :userInfo.getUserId()];
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
                ASI_CRM_PDF_Type__c = 'ON Trade',
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
                ASI_CRM_TW_Floor__c = '12')
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
                ASI_CRM_TW_Floor__c = '12')
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
                ASI_CRM_TW_Floor__c = '12')
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
            
            
		
            List<ASI_MFM_Sub_brand__c> listSubBrand = new List<ASI_MFM_Sub_brand__c>();
            listSubBrand.add(new ASI_MFM_Sub_brand__c(
                name = 'testSubBrand',
                ASI_CRM_TW_Company__c = 'PRT', 
                ASI_CRM_Active__c = TRUE, 
                ASI_TH_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand_Code__c = 'SBC1',
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'),
                ASI_HK_CRM_Product_Category__c =listProductC[0].id)
            );
                             
            listSubBrand.add(new ASI_MFM_Sub_brand__c(
                name = 'testSubBrand1',
                ASI_CRM_TW_Company__c = 'PRT', 
                ASI_CRM_Active__c = TRUE, 
                ASI_TH_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand_Code__c = 'SBC2',
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'),
                ASI_HK_CRM_Product_Category__c =listProductC[1].id)
            );
            insert listSubBrand;
            
            List<ASI_MFM_Item_Group__c> listItemGp = new List<ASI_MFM_Item_Group__c>();
            listItemGp.add(new ASI_MFM_Item_Group__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group'),
                Name = 'Item Gp 1',
                ASI_MFM_Sub_brand__c = listSubBrand[0].Id,
                ASI_CRM_Active__c = TRUE,
                ASI_CRM_Applied_To__c = 'TOT')
            );
            listItemGp.add(new ASI_MFM_Item_Group__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group'),
                Name = 'Item Gp 2',
                ASI_MFM_Sub_brand__c = listSubBrand[1].Id,
                ASI_CRM_Active__c = TRUE,
                ASI_CRM_Applied_To__c = 'TOT')
            );
            insert listItemGp;
            
            Id oSKUPriceRecordId = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_TW_SKU_Price_Cost');
            List<ASI_CRM_MY_SKUPriceCost__c> listSKUpc = new List<ASI_CRM_MY_SKUPriceCost__c>();
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = oSKUPriceRecordId,
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_Fiscal_Year__c = (date.today().month() > 6 ? '' + ( date.today().year() - 2000) + (date.today().year() - 1999) : '' + (date.today().year() - 2001) + (date.today().year() - 2000)),
                ASI_CRM_EffectiveDate__c = Date.today(),
                ASI_CRM_Type__c = 'A&D FOC Unit Cost',
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'TOT')
            );
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = oSKUPriceRecordId,
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_Fiscal_Year__c = (date.today().month() > 6 ? '' + ( date.today().year() - 2000) + (date.today().year() - 1999) : '' + (date.today().year() - 2001) + (date.today().year() - 2000)),
                ASI_CRM_EffectiveDate__c = Date.today(),
                ASI_CRM_Type__c = 'Pocket Price',
                ASI_CRM_Price__c = 10,
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'TOT')
            );
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = oSKUPriceRecordId,
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_Fiscal_Year__c = (date.today().month() > 6 ? '' + ( date.today().year() - 2000) + (date.today().year() - 1999) : '' + (date.today().year() - 2001) + (date.today().year() - 2000)),
                ASI_CRM_EffectiveDate__c = Date.today(),
                ASI_CRM_Type__c = 'Product Selection',
                ASI_CRM_Key_Limited_SKU__c = 'Key SKU',
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'TOT')
            );
            insert listSKUpc;
            Update listSKUpc;
            
            List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> listPAFMechanic = new List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c>();
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 1',
                ASI_CRM_Mechanic_Class__c ='1達成獎勵及各項贊助 (年度/半年度/季度)',
                ASI_CRM_A_C_Code__c = listAC[0].id)
            );
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 2',
                ASI_CRM_Mechanic_Class__c ='1達成獎勵及各項贊助 (年度/半年度/季度)',
                ASI_CRM_A_C_Code__c = listAC[1].id)
            );
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 3',
                ASI_CRM_Mechanic_Class__c ='2廣告陳列及品牌消費者活動',
                ASI_CRM_A_C_Code__c = listAC[2].id)
            );
            insert listPAFMechanic;
            
            List<ASI_HK_CRM_Pre_Approval_Form__c> listPAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
            listPAF.add(new ASI_HK_CRM_Pre_Approval_Form__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form__cASI_CRM_TW_Pre_Approval_Form'),
                ASI_HK_CRM_PAF_Customer__c = listOutlet[0].id,
                ASI_HK_CRM_PAF_Start_Date__c = system.Today(),
                ASI_HK_CRM_PAF_End_Date__c = system.Today().addMonths(11),
                ASI_CRM_Channel__c = channel.id,
                ASI_HK_CRM_PAF_Status__c = 'Final')
            );
            insert listPAF;
            
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
      
            insert listPAFItem;
            system.debug('PAF Items: '+listPAFItem);
            
            List<ASI_CRM_Terms__c > listTerms = new List< ASI_CRM_Terms__c >();
            listTerms.add(new ASI_CRM_Terms__c(
            	RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms__cASI_CRM_TW_Terms'),
                ASI_TW_Apply_To__c ='PAF',
                ASI_CRM_Inactive__c =FALSE,
                ASI_CRM_Section__c =1,
                ASI_CRM_Section_Title__c ='1.title',
                ASI_CRM_Terms_Details__c  ='1.details',
                ASI_CRM_Type__c ='Fixed',
                ASI_CRM_Terms_Details_Sequence__c =1
            )    
            );
            listTerms.add(new ASI_CRM_Terms__c(
            	RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms__cASI_CRM_TW_Terms'),
                ASI_TW_Apply_To__c ='PAF',
                ASI_CRM_Inactive__c =FALSE,
                ASI_CRM_Section__c =1,
                ASI_CRM_Section_Title__c ='1.title',
                ASI_CRM_Terms_Details__c  ='2.details',
                ASI_CRM_Type__c ='Fixed',
                ASI_CRM_Terms_Details_Sequence__c =2
            )    
            );
			listTerms.add(new ASI_CRM_Terms__c(
            	RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms__cASI_CRM_TW_Terms'),
                ASI_TW_Apply_To__c ='PAF',
                ASI_CRM_Inactive__c =FALSE,
                ASI_CRM_Section__c =2,
                ASI_CRM_Section_Title__c ='2.title',
                ASI_CRM_Terms_Details__c  ='details1',
                ASI_CRM_Type__c ='Variable',
                ASI_CRM_Terms_Details_Sequence__c =1
            )    
            );
            listTerms.add(new ASI_CRM_Terms__c(
            	RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms__cASI_CRM_TW_Terms'),
                ASI_TW_Apply_To__c ='PAF',
                ASI_CRM_Inactive__c =FALSE,
                ASI_CRM_Section__c =2,
                ASI_CRM_Section_Title__c ='2.title',
                ASI_CRM_Terms_Details__c  ='details2',
                ASI_CRM_Type__c ='Variable',
                ASI_CRM_Terms_Details_Sequence__c =2
            )    
            );
            listTerms.add(new ASI_CRM_Terms__c(
            	RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms__cASI_CRM_TW_Terms'),
                ASI_TW_Apply_To__c ='PAF',
                ASI_CRM_Inactive__c =FALSE,
                ASI_CRM_Section__c =3,
                ASI_CRM_Section_Title__c ='3.title',
                ASI_CRM_Terms_Details__c  ='',
                ASI_CRM_Type__c ='Variable',
                ASI_CRM_Terms_Details_Sequence__c =1
            )    
            );
            listTerms.add(new ASI_CRM_Terms__c(
            	RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms__cASI_CRM_TW_Terms'),
                ASI_TW_Apply_To__c ='PAF',
                ASI_CRM_Inactive__c =FALSE,
                ASI_CRM_Section__c =4,
                ASI_CRM_Section_Title__c ='4.title',
                ASI_CRM_Terms_Details__c  ='',
                ASI_CRM_Type__c ='Fixed',
                ASI_CRM_Terms_Details_Sequence__c =1
            )    
            );
            insert listTerms;
            
            
            List< ASI_CRM_Terms_Application__c > listTermsApp = new List< ASI_CRM_Terms_Application__c >();
            listTermsApp.add(new ASI_CRM_Terms_Application__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms_Application__cASI_CRM_TW_Terms_Application'),
            	ASI_CRM_Pre_Approval_Form__c = listPAF[0].id,
                ASI_CRM_Terms__c =listTerms[2].Id,
                ASI_CRM_Variable_Terms_Sequence__c =1
            )
            );
            listTermsApp.add(new ASI_CRM_Terms_Application__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms_Application__cASI_CRM_TW_Terms_Application'),
            	ASI_CRM_Pre_Approval_Form__c = listPAF[0].id,
                ASI_CRM_Terms__c =listTerms[3].Id,
                ASI_CRM_Variable_Terms_Sequence__c =2
            )
            );
            listTermsApp.add(new ASI_CRM_Terms_Application__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms_Application__cASI_CRM_TW_Terms_Application'),
            	ASI_CRM_Pre_Approval_Form__c = listPAF[0].id,
                ASI_CRM_Terms__c =listTerms[4].Id,
                ASI_CRM_Variable_Terms_Sequence__c =3
            )
            );
            insert listTermsApp;
            
            
            Test.starttest();
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listPAF[0]);
            
            //Missing PAF Id Case:
            ASI_CRM_TW_PAFPDF_Ctrl controller0 = new ASI_CRM_TW_PAFPDF_Ctrl(stdController);
            
            ApexPages.currentPage().getParameters().put('id', listPAF[0].id);  
            ASI_CRM_TW_PAFPDF_Ctrl controller = new ASI_CRM_TW_PAFPDF_Ctrl(stdController);
            
            Test.stoptest();
        }
    }
    
    public static testMethod void ASI_CRM_TW_PAFPDF_LS_Test() {
        Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
		user u = [select id, userRole.developerName from user where id = :userInfo.getUserId()];
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
                Name = 'LS (酒店)',
                ASI_CRM_PDF_Type__c = 'LS',
                ASI_CRM_CN_Channel_Code__c = 'LS');
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
                ASI_CRM_TW_Floor__c = '12')
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
                ASI_CRM_TW_Floor__c = '12')
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
                ASI_CRM_TW_Floor__c = '12')
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
            
            
		
            List<ASI_MFM_Sub_brand__c> listSubBrand = new List<ASI_MFM_Sub_brand__c>();
            listSubBrand.add(new ASI_MFM_Sub_brand__c(
                name = 'testSubBrand',
                ASI_CRM_TW_Company__c = 'PRT', 
                ASI_CRM_Active__c = TRUE, 
                ASI_TH_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand_Code__c = 'SBC1',
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'),
                ASI_HK_CRM_Product_Category__c =listProductC[0].id)
            );
                             
            listSubBrand.add(new ASI_MFM_Sub_brand__c(
                name = 'testSubBrand1',
                ASI_CRM_TW_Company__c = 'PRT', 
                ASI_CRM_Active__c = TRUE, 
                ASI_TH_CRM_Active__c = TRUE,
                ASI_MFM_Sub_brand_Code__c = 'SBC2',
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'),
                ASI_HK_CRM_Product_Category__c =listProductC[1].id)
            );
            insert listSubBrand;
            
            List<ASI_MFM_Item_Group__c> listItemGp = new List<ASI_MFM_Item_Group__c>();
            listItemGp.add(new ASI_MFM_Item_Group__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group'),
                Name = 'Item Gp 1',
                ASI_MFM_Sub_brand__c = listSubBrand[0].Id,
                ASI_CRM_Active__c = TRUE,
                ASI_CRM_Applied_To__c = 'LS')
            );
            listItemGp.add(new ASI_MFM_Item_Group__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_TW_Item_Group'),
                Name = 'Item Gp 2',
                ASI_MFM_Sub_brand__c = listSubBrand[1].Id,
                ASI_CRM_Active__c = TRUE,
                ASI_CRM_Applied_To__c = 'LS')
            );
            insert listItemGp;
            
            Id oSKUPriceRecordId = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_TW_SKU_Price_Cost');
            List<ASI_CRM_MY_SKUPriceCost__c> listSKUpc = new List<ASI_CRM_MY_SKUPriceCost__c>();
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = oSKUPriceRecordId,
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_Fiscal_Year__c = (date.today().month() > 6 ? '' + ( date.today().year() - 2000) + (date.today().year() - 1999) : '' + (date.today().year() - 2001) + (date.today().year() - 2000)),
                ASI_CRM_EffectiveDate__c = Date.today(),
                ASI_CRM_Type__c = 'A&D FOC Unit Cost',
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'LS')
            );
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = oSKUPriceRecordId,
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_Fiscal_Year__c = (date.today().month() > 6 ? '' + ( date.today().year() - 2000) + (date.today().year() - 1999) : '' + (date.today().year() - 2001) + (date.today().year() - 2000)),
                ASI_CRM_EffectiveDate__c = Date.today(),
                ASI_CRM_Type__c = 'Pocket Price',
                ASI_CRM_Price__c = 10,
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'LS')
            );
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = oSKUPriceRecordId,
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_Fiscal_Year__c = (date.today().month() > 6 ? '' + ( date.today().year() - 2000) + (date.today().year() - 1999) : '' + (date.today().year() - 2001) + (date.today().year() - 2000)),
                ASI_CRM_EffectiveDate__c = Date.today(),
                ASI_CRM_Type__c = 'Product Selection',
                ASI_CRM_Key_Limited_SKU__c = 'Key SKU',
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'LS')
            );
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = oSKUPriceRecordId,
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_Fiscal_Year__c = (date.today().month() > 6 ? '' + ( date.today().year() - 2000) + (date.today().year() - 1999) : '' + (date.today().year() - 2001) + (date.today().year() - 2000)),
                ASI_CRM_EffectiveDate__c = system.Today().addMonths(-1),
                ASI_CRM_Type__c = 'Pocket Price',
                ASI_CRM_Price__c = 10,
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'LS')
            );
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = oSKUPriceRecordId,
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_Fiscal_Year__c = (date.today().month() > 6 ? '' + ( date.today().year() - 2000) + (date.today().year() - 1999) : '' + (date.today().year() - 2001) + (date.today().year() - 2000)),
                ASI_CRM_EffectiveDate__c = system.Today().addMonths(-1),
                ASI_CRM_Type__c = 'Product Selection',
                ASI_CRM_Key_Limited_SKU__c = 'Key SKU',
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'LS')
            );
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = oSKUPriceRecordId,
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_Fiscal_Year__c = (date.today().month() > 6 ? '' + ( date.today().year() - 2000) + (date.today().year() - 1999) : '' + (date.today().year() - 2001) + (date.today().year() - 2000)),
                ASI_CRM_EffectiveDate__c = system.Today().addMonths(1),
                ASI_CRM_Type__c = 'Pocket Price',
                ASI_CRM_Price__c = 10,
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'LS')
            );
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = oSKUPriceRecordId,
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_Fiscal_Year__c = (date.today().month() > 6 ? '' + ( date.today().year() - 2000) + (date.today().year() - 1999) : '' + (date.today().year() - 2001) + (date.today().year() - 2000)),
                ASI_CRM_EffectiveDate__c = system.Today().addMonths(1),
                ASI_CRM_Type__c = 'Product Selection',
                ASI_CRM_Key_Limited_SKU__c = 'Key SKU',
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'LS')
            );
            insert listSKUpc;
            //Update listSKUpc;
            
            List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> listPAFMechanic = new List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c>();
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 1',
                ASI_CRM_Mechanic_Class__c ='1達成獎勵及各項贊助 (年度/半年度/季度)',
                ASI_CRM_A_C_Code__c = listAC[0].id)
            );
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 2',
                ASI_CRM_Mechanic_Class__c ='1達成獎勵及各項贊助 (年度/半年度/季度)',
                ASI_CRM_A_C_Code__c = listAC[1].id)
            );
            listPAFMechanic.add(new ASI_HK_CRM_Pre_Approval_Form_Mechanic__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Mechanic__cASI_CRM_TW_Pre_Approval_Mechanics'),
                Name = 'PAF Mechanic 3',
                ASI_CRM_Mechanic_Class__c ='2廣告陳列及品牌消費者活動',
                ASI_CRM_A_C_Code__c = listAC[2].id)
            );
            insert listPAFMechanic;
            
            List<ASI_HK_CRM_Pre_Approval_Form__c> listPAF = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
            listPAF.add(new ASI_HK_CRM_Pre_Approval_Form__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form__cASI_CRM_TW_Pre_Approval_Form'),
                ASI_HK_CRM_PAF_Customer__c = listOutlet[0].id,
                ASI_HK_CRM_PAF_Start_Date__c = system.Today(),
                ASI_HK_CRM_PAF_End_Date__c = system.Today().addMonths(11),
                ASI_CRM_Channel__c = channel.id,
                ASI_HK_CRM_PAF_Status__c = 'Final')
            );
            insert listPAF;
            
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
      
            insert listPAFItem;
            system.debug('PAF Items: '+listPAFItem);
            
            List<ASI_CRM_Terms__c > listTerms = new List< ASI_CRM_Terms__c >();
            listTerms.add(new ASI_CRM_Terms__c(
            	RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms__cASI_CRM_TW_Terms'),
                ASI_TW_Apply_To__c ='PAF',
                ASI_CRM_Inactive__c =FALSE,
                ASI_CRM_Section__c =1,
                ASI_CRM_Section_Title__c ='1.title',
                ASI_CRM_Terms_Details__c  ='1.details',
                ASI_CRM_Type__c ='Fixed',
                ASI_CRM_Terms_Details_Sequence__c =1
            )    
            );
            listTerms.add(new ASI_CRM_Terms__c(
            	RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms__cASI_CRM_TW_Terms'),
                ASI_TW_Apply_To__c ='PAF',
                ASI_CRM_Inactive__c =FALSE,
                ASI_CRM_Section__c =1,
                ASI_CRM_Section_Title__c ='1.title',
                ASI_CRM_Terms_Details__c  ='2.details',
                ASI_CRM_Type__c ='Fixed',
                ASI_CRM_Terms_Details_Sequence__c =2
            )    
            );
			listTerms.add(new ASI_CRM_Terms__c(
            	RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms__cASI_CRM_TW_Terms'),
                ASI_TW_Apply_To__c ='PAF',
                ASI_CRM_Inactive__c =FALSE,
                ASI_CRM_Section__c =2,
                ASI_CRM_Section_Title__c ='2.title',
                ASI_CRM_Terms_Details__c  ='details1',
                ASI_CRM_Type__c ='Variable',
                ASI_CRM_Terms_Details_Sequence__c =1
            )    
            );
            listTerms.add(new ASI_CRM_Terms__c(
            	RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms__cASI_CRM_TW_Terms'),
                ASI_TW_Apply_To__c ='PAF',
                ASI_CRM_Inactive__c =FALSE,
                ASI_CRM_Section__c =2,
                ASI_CRM_Section_Title__c ='2.title',
                ASI_CRM_Terms_Details__c  ='details2',
                ASI_CRM_Type__c ='Variable',
                ASI_CRM_Terms_Details_Sequence__c =2
            )    
            );
            listTerms.add(new ASI_CRM_Terms__c(
            	RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms__cASI_CRM_TW_Terms'),
                ASI_TW_Apply_To__c ='PAF',
                ASI_CRM_Inactive__c =FALSE,
                ASI_CRM_Section__c =3,
                ASI_CRM_Section_Title__c ='3.title',
                ASI_CRM_Terms_Details__c  ='',
                ASI_CRM_Type__c ='Variable',
                ASI_CRM_Terms_Details_Sequence__c =1
            )    
            );
            listTerms.add(new ASI_CRM_Terms__c(
            	RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms__cASI_CRM_TW_Terms'),
                ASI_TW_Apply_To__c ='PAF',
                ASI_CRM_Inactive__c =FALSE,
                ASI_CRM_Section__c =4,
                ASI_CRM_Section_Title__c ='4.title',
                ASI_CRM_Terms_Details__c  ='',
                ASI_CRM_Type__c ='Fixed',
                ASI_CRM_Terms_Details_Sequence__c =1
            )    
            );
            insert listTerms;
            
            
            List< ASI_CRM_Terms_Application__c > listTermsApp = new List< ASI_CRM_Terms_Application__c >();
            listTermsApp.add(new ASI_CRM_Terms_Application__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms_Application__cASI_CRM_TW_Terms_Application'),
            	ASI_CRM_Pre_Approval_Form__c = listPAF[0].id,
                ASI_CRM_Terms__c =listTerms[2].Id,
                ASI_CRM_Variable_Terms_Sequence__c =1
            )
            );
            listTermsApp.add(new ASI_CRM_Terms_Application__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms_Application__cASI_CRM_TW_Terms_Application'),
            	ASI_CRM_Pre_Approval_Form__c = listPAF[0].id,
                ASI_CRM_Terms__c =listTerms[3].Id,
                ASI_CRM_Variable_Terms_Sequence__c =2
            )
            );
            listTermsApp.add(new ASI_CRM_Terms_Application__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Terms_Application__cASI_CRM_TW_Terms_Application'),
            	ASI_CRM_Pre_Approval_Form__c = listPAF[0].id,
                ASI_CRM_Terms__c =listTerms[4].Id,
                ASI_CRM_Variable_Terms_Sequence__c =3
            )
            );
            insert listTermsApp;
            
            
            Test.starttest();
            
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(listPAF[0]);
            
            //Missing PAF Id Case:
            ASI_CRM_TW_PAFPDF_Ctrl controller0 = new ASI_CRM_TW_PAFPDF_Ctrl(stdController);
            
            ApexPages.currentPage().getParameters().put('id', listPAF[0].id);  
            ASI_CRM_TW_PAFPDF_Ctrl controller = new ASI_CRM_TW_PAFPDF_Ctrl(stdController);
            
            Test.stoptest();
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