@isTest
public class ASI_MFM_TW_AccrualPOGenerationBatch_Test {
	
    public static testMethod void ASI_CRM_TW_AccrualPOGenerationBatch_Test() {
		user u = [select userRole.developerName from user where id = :userInfo.getUserId()]; 
        u.ASI_MFM_Country__c ='TW';
        update u;
        ASI_MFM_Settings__c settings = new ASI_MFM_Settings__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Settings__cASI_MFM_TW_Setting'),
                                                               ASI_MFM_TW_Accrual_PO_Generation_Day__c = System.Today().day(),
                                                               ASI_MFM_TW_Post_G_L_Date__c = System.Today());
        insert settings;
        System.runAs(u) {
            List<asi_mfm_prefix__c> l_prefix = new List<asi_mfm_prefix__c>();
            l_prefix.add( new asi_mfm_prefix__c(
                ASI_MFM_Inactive__c = false, 
                asi_mfm_module__c = 'Plan',
                ASI_MFM_Fiscal_year__c = 'FY1718',
                Plan_Type__c = 'Trade A&P and A&D Plan'
				)
            );
            l_prefix.add( new asi_mfm_prefix__c(
                ASI_MFM_Inactive__c = false, 
                asi_mfm_module__c = 'Accrual PO',
                ASI_MFM_Fiscal_year__c = 'FY1718',
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prefix__cASI_MFM_TW_Prefix'),
                ASI_MFM_Next_Number__c =1
				)
            );             
            insert l_prefix;
            
            List<asi_mfm_role_prefix_relationship__c> l_pefixRelationship = new List<asi_mfm_role_prefix_relationship__c>();
            l_pefixRelationship.add( new asi_mfm_role_prefix_relationship__c(
                asi_mfm_role_name__c = u.userRole.developerName,
                ASI_MFM_Prefix__c = l_prefix[0].id
                )
            );
            l_pefixRelationship.add( new asi_mfm_role_prefix_relationship__c(
                asi_mfm_role_name__c = 'ESN',
                ASI_MFM_Prefix__c = l_prefix[1].id
                )
            );
            insert l_pefixRelationship;
            
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
            
            List<Account> listAccounts = new List<Account>();
            listAccounts.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
                Name='Test Outlet', 
                ownerid = u.id , 
                ASI_TH_CRM_Region__c ='North')
            );  
            insert listAccounts;
            
            listAccounts.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
                Name='Test Outlet 1', 
                ParentId = listAccounts[0].id, 
                ownerid = u.id , 
                ASI_TH_CRM_Region__c ='North')
            );     
            listAccounts.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), 
                Name='Test Outlet 2', 
                ParentId = listAccounts[0].id, 
                ownerid = u.id , 
                ASI_TH_CRM_Region__c ='North')
            );   
            
            listAccounts.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), 
                Name='HBR North_TW_99970100', 
                ASI_MFM_Customer_Supplier_Name__c ='HBR North_TW',
                ASI_MFM_Customer_Supplier_Number__c  ='99970100',
                ownerid = u.id , 
                Channel__c ='HBR',
                ASI_MFM_Outlet__c ='HBR_N',
                ASI_TH_CRM_Region__c ='North')
            );
            
            listAccounts.add(new Account(
                RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), 
                Name='Dummy Supplier (99999)', 
                ASI_MFM_Customer_Supplier_Name__c ='Dummy Supplier',
                ASI_MFM_Customer_Supplier_Number__c  ='99999',
                ownerid = u.id , 
                ASI_MFM_Payment_Terms__c ='No Payment Term N',
                ASI_MFM_Site_Code__c ='TW'
            	)
            );
            
            upsert listAccounts;
            
            List<ASI_CRM_AccountsAdditionalField__c> listAccountAdditionalField = new List<ASI_CRM_AccountsAdditionalField__c>();
            listAccountAdditionalField.add(new ASI_CRM_AccountsAdditionalField__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                Name = 'Test Outlet', 
                ASI_CRM_Account__c = listAccounts[0].id, 
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
                ASI_CRM_Account__c = listAccounts[1].id, 
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
                ASI_CRM_Account__c = listAccounts[2].id, 
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
            
            List<ASI_CRM_MY_SKUPriceCost__c> listSKUpc = new List<ASI_CRM_MY_SKUPriceCost__c>();
            listSKUpc.add(new ASI_CRM_MY_SKUPriceCost__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_TW_SKU_Price_Cost'),
                ASI_CRM_Item_Group__c = listItemGp[0].id,
                ASI_CRM_Fiscal_Year__c = '1718',
                ASI_CRM_EffectiveDate__c = Date.newInstance(2017, 07, 01),
                ASI_CRM_Type__c = 'A&D FOC Unit Cost',
                ASI_CRM_Cost__c = 100,
                ASI_CRM_Applied_To__c = 'TOT')
            );
            insert listSKUpc;
            
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
                ASI_HK_CRM_PAF_Customer__c = listAccounts[0].id,
                ASI_HK_CRM_PAF_Start_Date__c = Date.newInstance(2017, 07, 01),
                ASI_HK_CRM_PAF_End_Date__c = Date.newInstance(2018, 06, 30),
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
                ASI_HK_CRM_Target_Volume_Qty__c = 80,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'Cash',
                ASI_CRM_Cash_Per_Bottle_w_VAT__c = 4000, 
				ASI_CRM_Target_Volume_Qty_P1__c  =20,ASI_CRM_Target_Volume_Qty_P2__c  =20, ASI_CRM_Target_Volume_Qty_P3__c  =20, ASI_CRM_Target_Volume_Qty_P4__c  =20 
            	)
            );
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Variable_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_CRM_Contracted_Item__c = listItemGp[0].id,
                ASI_HK_CRM_Target_Volume_Qty__c = 80,
                ASI_CRM_AD_or_AP__c = 'A&D',
                ASI_CRM_Cash_or_FOC__c = 'FOC',
                ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c = 10,
                ASI_HK_CRM_FOC_Free_Bottle_Option_1__c = 1,
				ASI_CRM_Target_Volume_Qty_P1__c  =20,ASI_CRM_Target_Volume_Qty_P2__c  =20, ASI_CRM_Target_Volume_Qty_P3__c  =20, ASI_CRM_Target_Volume_Qty_P4__c  =20 
            	)
            );
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_HK_CRM_Mechanic__c = listPAFMechanic[0].id,
                ASI_CRM_Mechanic_Detail__c = 'detail',
                ASI_CRM_Expenses_Product__c = listItemGp[0].id,
                ASI_CRM_AD_or_AP__c = 'Trade A&P',
                ASI_CRM_Cash_or_FOC__c = 'Cash',
                ASI_CRM_Cash_Amounts_w_VAT_P1__c =1000, ASI_CRM_Cash_Amounts_w_VAT_P2__c =1000, ASI_CRM_Cash_Amounts_w_VAT_P3__c =1000, ASI_CRM_Cash_Amounts_w_VAT_P4__c =1000,
                ASI_CRM_Cash_Amounts_w_VAT__c  = 4000)
            );
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Conditional_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_HK_CRM_Mechanic__c = listPAFMechanic[0].id,
                ASI_CRM_Mechanic_Detail__c = 'detail',
                ASI_CRM_Expenses_Product__c = listItemGp[0].id,
                ASI_CRM_AD_or_AP__c = 'Trade A&P',
                ASI_CRM_Cash_or_FOC__c = 'FOC',
                ASI_CRM_FOC_Volume__c =160, ASI_CRM_FOC_Volume_P1__c =40, ASI_CRM_FOC_Volume_P2__c =40, ASI_CRM_FOC_Volume_P3__c =40, ASI_CRM_FOC_Volume_P4__c =40
            	)
            );
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_HK_CRM_Mechanic__c = listPAFMechanic[2].id,
                ASI_CRM_Mechanic_Detail__c = 'Test auto-accrual',
                ASI_CRM_Expenses_Product__c = listItemGp[0].id,
                ASI_CRM_AD_or_AP__c = 'Trade A&P',
                ASI_CRM_Cash_or_FOC__c = 'FOC',
                ASI_CRM_FOC_Volume__c =160, ASI_CRM_FOC_Volume_P1__c =40, ASI_CRM_FOC_Volume_P2__c =40, ASI_CRM_FOC_Volume_P3__c =40, ASI_CRM_FOC_Volume_P4__c =40)
            );
            listPAFItem.add(new ASI_HK_CRM_Pre_Approval_Form_Item__c(
                RecordTypeid = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form_Item__cASI_CRM_TW_Fixed_Investment'),
                ASI_HK_CRM_Pre_Approval_Form_Lookup__c = listPAF[0].id,
                ASI_HK_CRM_Mechanic__c = listPAFMechanic[2].id,
                ASI_CRM_Mechanic_Detail__c = 'detail2',
                ASI_CRM_Expenses_Product__c = listItemGp[0].id,
                ASI_CRM_AD_or_AP__c = 'Trade A&P',
                ASI_CRM_Cash_or_FOC__c = 'Cash',
                ASI_CRM_Cash_Amounts_w_VAT_P1__c =1000, ASI_CRM_Cash_Amounts_w_VAT_P2__c =1000, ASI_CRM_Cash_Amounts_w_VAT_P3__c =1000, ASI_CRM_Cash_Amounts_w_VAT_P4__c =1000,
                ASI_CRM_Cash_Amounts_w_VAT__c  = 4000)
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
            
            //Custom Setting:
            User SOAUser = [SELECT Id,UserRoleId, UserRole.DeveloperName  FROM User WHERE UserRole.DeveloperName= 'ESN' AND (FirstName Like '%SOA%' or LastName Like '%SOA%') LIMIT 1];
            ASI_MFM_Setting__c mfmSettings = new ASI_MFM_Setting__c (ASI_MFM_TW_Accrual_PO_Generation_Day__c =1,ASI_MFM_TW_Today__c =Date.newInstance(2017, 08, 01), ASI_MFM_TW_Accrual_PO_Owner_ID__c =SOAUser.Id);
            insert mfmSettings;
            
            //For Plan created directly:
            List<ASI_MFM_Plan__c> l_plans = new List<ASI_MFM_Plan__c>();
            l_plans.add( new ASI_MFM_Plan__c(
                ASI_MFM_Plan_Name__c  ='Test Accrual- Direct Plan', ASI_MFM_Plan_Description__c ='Direct Plan',ASI_MFM_Start_Date__c =Date.newInstance(2017, 07, 01),
                ASI_MFM_End_Date__c =Date.newInstance(2018, 6, 30),CurrencyIsoCode = 'TWD', Name ='TEST001', ASI_MFM_Status__c ='Final', RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan_Read_Only'),
				ASI_MFM_Fiscal_year__c = 'FY1718', ASI_MFM_Account__c=listAccounts[1].id, ASI_MFM_Prefix__c = l_prefix[0].id
            	)
            );
            insert l_plans;
            
            List<ASI_MFM_Plan_Line_Item__c>  l_planLines = new List<ASI_MFM_Plan_Line_Item__c>();
            l_planLines.add( new ASI_MFM_Plan_Line_Item__c(
				RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'),ASI_MFM_Plan__c =l_plans[0].Id, 
                CurrencyIsoCode ='TWD', ASI_MFM_A_C_Code__c =listAC[0].Id, ASI_MFM_Sub_brand_Code__c =listSubBrand[0].Id, ASI_MFM_Total_Cost__c =12000,
                ASI_MFM_Month_1_Cost__c=1000, ASI_MFM_Month_2_Cost__c=1000, ASI_MFM_Month_3_Cost__c=1000, ASI_MFM_Month_4_Cost__c=1000, ASI_MFM_Month_5_Cost__c=1000, ASI_MFM_Month_6_Cost__c =1000,
                ASI_MFM_Month_7_Cost__c=1000, ASI_MFM_Month_8_Cost__c=1000, ASI_MFM_Month_9_Cost__c=1000, ASI_MFM_Month_10_Cost__c=1000, ASI_MFM_Month_11_Cost__c=1000, ASI_MFM_Month_12_Cost__c =1000,
            	ASI_MFM_Expected_Volume__c =500, ASI_MFM_Size__c  = '700ml', ASI_MFM_Customer_Name__c = listAccounts[3].id, ASI_MFM_List_Item_Description__c='A&D Cash'
            	)
            );
            
            l_planLines.add( new ASI_MFM_Plan_Line_Item__c(
				RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'),ASI_MFM_Plan__c =l_plans[0].Id, 
                CurrencyIsoCode ='TWD', ASI_MFM_A_C_Code__c =listAC[0].Id, ASI_MFM_Sub_brand_Code__c =listSubBrand[0].Id, ASI_MFM_Quantity__c =6,
                ASI_MFM_Unit_Cost__c =8000, ASI_MFM_Total_Cost__c =24000,
                ASI_MFM_Month_1_Cost__c=2000, ASI_MFM_Month_2_Cost__c=2000, ASI_MFM_Month_3_Cost__c=2000, ASI_MFM_Month_4_Cost__c=2000, ASI_MFM_Month_5_Cost__c=2000, ASI_MFM_Month_6_Cost__c =2000,
                ASI_MFM_Month_7_Cost__c=2000, ASI_MFM_Month_8_Cost__c=2000, ASI_MFM_Month_9_Cost__c=2000, ASI_MFM_Month_10_Cost__c=2000, ASI_MFM_Month_11_Cost__c=2000, ASI_MFM_Month_12_Cost__c =2000,
            	ASI_MFM_Expected_Volume__c =100, ASI_MFM_Size__c  = '700ml', ASI_MFM_FOC_Size__c ='700ml', ASI_MFM_Customer_Name__c = listAccounts[3].id, ASI_MFM_List_Item_Description__c='B21-FOC'
            	)
            );
            
            insert l_planLines;
            
            //For Plan coverted from PAF:
            List<ASI_MFM_Plan__c> l_PAFPlans = new List<ASI_MFM_Plan__c>();
            l_PAFPlans.add( new ASI_MFM_Plan__c(
                ASI_MFM_Plan_Name__c  ='Test Accrual- PAF Plan', ASI_MFM_Plan_Description__c ='PAF Plan',ASI_MFM_Start_Date__c =Date.newInstance(2017, 07, 01),
                ASI_MFM_End_Date__c =Date.newInstance(2018, 6, 30),CurrencyIsoCode = 'TWD', Name ='TEST001', ASI_MFM_Status__c ='Final', RecordTypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan_Read_Only'),
				ASI_MFM_Fiscal_year__c = 'FY1718', ASI_MFM_Account__c=listAccounts[1].id, ASI_MFM_Prefix__c = l_prefix[0].id, ASI_MFM_TW_Related_PAF__c =listPAF[0].Id
            	)
            );
            insert l_PAFPlans;
            
            List<ASI_MFM_Plan_Line_Item__c>  l_PAF_planLines = new List<ASI_MFM_Plan_Line_Item__c>();
            //Cash Line (varibale PAF item):
            l_PAF_planLines.add( new ASI_MFM_Plan_Line_Item__c(
				RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'),ASI_MFM_Plan__c =l_PAFPlans[0].Id, 
                CurrencyIsoCode ='TWD', ASI_MFM_A_C_Code__c =listAC[1].Id, ASI_MFM_Sub_brand_Code__c =listSubBrand[0].Id, ASI_MFM_Total_Cost__c =12000, ASI_MFM_TW_Related_PAF_Item__c =listPAFItem[0].Id,
                ASI_MFM_Month_1_Cost__c=1000, ASI_MFM_Month_2_Cost__c=1000, ASI_MFM_Month_3_Cost__c=1000, ASI_MFM_Month_4_Cost__c=1000, ASI_MFM_Month_5_Cost__c=1000, ASI_MFM_Month_6_Cost__c =1000,
                ASI_MFM_Month_7_Cost__c=1000, ASI_MFM_Month_8_Cost__c=1000, ASI_MFM_Month_9_Cost__c=1000, ASI_MFM_Month_10_Cost__c=1000, ASI_MFM_Month_11_Cost__c=1000, ASI_MFM_Month_12_Cost__c =1000,
            	ASI_MFM_Expected_Volume__c =300, ASI_MFM_Size__c  = '700ml', ASI_MFM_Customer_Name__c = listAccounts[3].id, ASI_MFM_List_Item_Description__c='Cash'
            	)
            );
            
            //FOC Line (varibale PAF item):
            l_PAF_planLines.add( new ASI_MFM_Plan_Line_Item__c(
				RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'),ASI_MFM_Plan__c =l_PAFPlans[0].Id, 
                CurrencyIsoCode ='TWD', ASI_MFM_A_C_Code__c =listAC[0].Id, ASI_MFM_Sub_brand_Code__c =listSubBrand[0].Id, ASI_MFM_Quantity__c =6,ASI_MFM_TW_Related_PAF_Item__c =listPAFItem[1].Id,
                ASI_MFM_Unit_Cost__c =1659, ASI_MFM_Total_Cost__c =24000,
                ASI_MFM_Month_1_Cost__c=2000, ASI_MFM_Month_2_Cost__c=2000, ASI_MFM_Month_3_Cost__c=2000, ASI_MFM_Month_4_Cost__c=2000, ASI_MFM_Month_5_Cost__c=2000, ASI_MFM_Month_6_Cost__c =2000,
                ASI_MFM_Month_7_Cost__c=2000, ASI_MFM_Month_8_Cost__c=2000, ASI_MFM_Month_9_Cost__c=2000, ASI_MFM_Month_10_Cost__c=2000, ASI_MFM_Month_11_Cost__c=2000, ASI_MFM_Month_12_Cost__c =2000,
            	ASI_MFM_Expected_Volume__c =600, ASI_MFM_Size__c  = '700ml', ASI_MFM_FOC_Size__c ='700ml', ASI_MFM_Customer_Name__c = listAccounts[3].id, ASI_MFM_List_Item_Description__c='ABL-FOC'
            	)
            );
            
            //Cash Line (conditional PAF item):
            l_PAF_planLines.add( new ASI_MFM_Plan_Line_Item__c(
				RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'),ASI_MFM_Plan__c =l_PAFPlans[0].Id, 
                CurrencyIsoCode ='TWD', ASI_MFM_A_C_Code__c =listAC[1].Id, ASI_MFM_Sub_brand_Code__c =listSubBrand[0].Id, ASI_MFM_Total_Cost__c =26000, ASI_MFM_TW_Related_PAF_Item__c =listPAFItem[2].Id,
                ASI_MFM_Month_1_Cost__c=1000, ASI_MFM_Month_2_Cost__c=1000, ASI_MFM_Month_3_Cost__c=1000, ASI_MFM_Month_4_Cost__c=1000, ASI_MFM_Month_5_Cost__c=1000, ASI_MFM_Month_6_Cost__c =1000,
                ASI_MFM_Month_7_Cost__c=1000, ASI_MFM_Month_8_Cost__c=1000, ASI_MFM_Month_9_Cost__c=1000, ASI_MFM_Month_10_Cost__c=1000, ASI_MFM_Month_11_Cost__c=1000, ASI_MFM_Month_12_Cost__c =1000,
            	ASI_MFM_Expected_Volume__c =300, ASI_MFM_Size__c  = '700ml', ASI_MFM_Customer_Name__c = listAccounts[3].id, ASI_MFM_List_Item_Description__c='Cash-test q1'
            	)
            );
            
            //FOC Line (conditional PAF item):
            l_PAF_planLines.add( new ASI_MFM_Plan_Line_Item__c(
				RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'),ASI_MFM_Plan__c =l_PAFPlans[0].Id, 
                CurrencyIsoCode ='TWD', ASI_MFM_A_C_Code__c =listAC[0].Id, ASI_MFM_Sub_brand_Code__c =listSubBrand[0].Id, ASI_MFM_Quantity__c =6,ASI_MFM_TW_Related_PAF_Item__c =listPAFItem[3].Id,
                ASI_MFM_Unit_Cost__c =874, ASI_MFM_Total_Cost__c =24000,
                ASI_MFM_Month_1_Cost__c=2000, ASI_MFM_Month_2_Cost__c=2000, ASI_MFM_Month_3_Cost__c=2000, ASI_MFM_Month_4_Cost__c=2000, ASI_MFM_Month_5_Cost__c=2000, ASI_MFM_Month_6_Cost__c =2000,
                ASI_MFM_Month_7_Cost__c=2000, ASI_MFM_Month_8_Cost__c=2000, ASI_MFM_Month_9_Cost__c=2000, ASI_MFM_Month_10_Cost__c=2000, ASI_MFM_Month_11_Cost__c=2000, ASI_MFM_Month_12_Cost__c =2000,
            	ASI_MFM_Expected_Volume__c =600, ASI_MFM_Size__c  = '700ml', ASI_MFM_FOC_Size__c ='700ml', ASI_MFM_Customer_Name__c = listAccounts[3].id, ASI_MFM_List_Item_Description__c='ABL-FOC-Test auto-accrual'
            	)
            );
            
            
            //Cash Line (fixed PAF item):
            l_PAF_planLines.add( new ASI_MFM_Plan_Line_Item__c(
				RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'),ASI_MFM_Plan__c =l_PAFPlans[0].Id, 
                CurrencyIsoCode ='TWD', ASI_MFM_A_C_Code__c =listAC[1].Id, ASI_MFM_Sub_brand_Code__c =listSubBrand[0].Id, ASI_MFM_Total_Cost__c =26000, ASI_MFM_TW_Related_PAF_Item__c =listPAFItem[4].Id,
                ASI_MFM_Month_1_Cost__c=1000, ASI_MFM_Month_2_Cost__c=1000, ASI_MFM_Month_3_Cost__c=1000, ASI_MFM_Month_4_Cost__c=1000, ASI_MFM_Month_5_Cost__c=1000, ASI_MFM_Month_6_Cost__c =1000,
                ASI_MFM_Month_7_Cost__c=1000, ASI_MFM_Month_8_Cost__c=1000, ASI_MFM_Month_9_Cost__c=1000, ASI_MFM_Month_10_Cost__c=1000, ASI_MFM_Month_11_Cost__c=1000, ASI_MFM_Month_12_Cost__c =1000,
            	ASI_MFM_Expected_Volume__c =300, ASI_MFM_Size__c  = '700ml', ASI_MFM_Customer_Name__c = listAccounts[3].id, ASI_MFM_List_Item_Description__c='Cash-test q1'
            	)
            );
            
            //FOC Line (fixed PAF item):
            l_PAF_planLines.add( new ASI_MFM_Plan_Line_Item__c(
				RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'),ASI_MFM_Plan__c =l_PAFPlans[0].Id, 
                CurrencyIsoCode ='TWD', ASI_MFM_A_C_Code__c =listAC[0].Id, ASI_MFM_Sub_brand_Code__c =listSubBrand[0].Id, ASI_MFM_Quantity__c =6,ASI_MFM_TW_Related_PAF_Item__c =listPAFItem[5].Id,
                ASI_MFM_Unit_Cost__c =874, ASI_MFM_Total_Cost__c =24000,
                ASI_MFM_Month_1_Cost__c=2000, ASI_MFM_Month_2_Cost__c=2000, ASI_MFM_Month_3_Cost__c=2000, ASI_MFM_Month_4_Cost__c=2000, ASI_MFM_Month_5_Cost__c=2000, ASI_MFM_Month_6_Cost__c =2000,
                ASI_MFM_Month_7_Cost__c=2000, ASI_MFM_Month_8_Cost__c=2000, ASI_MFM_Month_9_Cost__c=2000, ASI_MFM_Month_10_Cost__c=2000, ASI_MFM_Month_11_Cost__c=2000, ASI_MFM_Month_12_Cost__c =2000,
            	ASI_MFM_Expected_Volume__c =600, ASI_MFM_Size__c  = '700ml', ASI_MFM_FOC_Size__c ='700ml', ASI_MFM_Customer_Name__c = listAccounts[3].id, ASI_MFM_List_Item_Description__c='ABL-FOC-Test auto-accrual'
            	)
            );
            
            
            
            Test.startTest();
            
            Id batchJobId = Database.executeBatch(new ASI_MFM_TW_AccrualPOGeneration_Batch(), 200);
            insert l_PAF_planLines;
            
            Id batchJobId2 = Database.executeBatch(new ASI_MFM_TW_AccrualPOGeneration_Batch(), 200);
            
    
			//Test Schedule:
			// This test runs a scheduled job at midnight Sept. 3rd. 2022
			String CRON_EXP = '0 0 0 3 9 ? 2022';
			// Schedule the test job
			String jobId = System.schedule('ASI_MFM_TW_AccrualPOGeneration_SchdTest', CRON_EXP, new ASI_MFM_TW_AccrualPOGeneration_Schd());
      		
            
            //Test BA Verify Page:
            PageReference pageRef = Page.ASI_MFM_TW_BAVerify;
            Test.setCurrentPage(pageRef);
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(new ASI_MFM_PO_Line_Item__c());
            ASI_MFM_TW_BAVerifyController controller = new ASI_MFM_TW_BAVerifyController(stdController);
            controller.refresh();
            //controller.lineItem[0].ASI_MFM_SG_BA_verify__c =true;
            controller.toggleSort();
            controller.nextPage();
            controller.prevPage ();
            controller.lastPage();
            controller.firstPage();
            controller.gotopage();
            
            controller.save();
            controller.Plan_Num ='Test123';
            controller.PO_Num ='Test123';
            controller.PO_Line_Num  ='Test123';
            controller.Suppliers_Num ='9999';
            controller.Suppl ='Dummy';
            controller.SB_Code  ='Test123';
            controller.AC_Code ='Test123';
            controller.gl_fromDate.ASI_MFM_G_L_Date__c  =Date.newInstance(2017, 07, 01);
            controller.gl_toDate.ASI_MFM_G_L_Date__c  = Date.newInstance(2018, 06, 30);
            controller.runSearch();
            Test.stopTest();
        }
    }
}