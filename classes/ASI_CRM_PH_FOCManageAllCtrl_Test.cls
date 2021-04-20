/***************************************************************************************************************************
 * Name:        ASI_CRM_PH_FOCManageAllCtrl_Test
 * Description: Contains the test methods for ASI_CRM_PH_FOCManageAll_Ctrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-01-28       Calvin Chiu (LAPUTA)    Created
 ****************************************************************************************************************************/
@isTest
public class ASI_CRM_PH_FOCManageAllCtrl_Test {
    @testSetup
    public static void testSetup(){
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
            
        User u = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'last',
             Email = 'puser000@amamama.com',
             Username = 'puser000@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             UserRoleId = r.Id
        );       
        insert u;
    }    
    
    private static void testSetupContract(){
        ASI_MFM_Exchange_Rate__c exRate = ASI_CRM_PH_Testfactory.createExchangeRate(Date.newInstance(Date.today().Year() - 1, 9, 1));
        insert exRate;
        
        ASI_HK_CRM_Running_Number__c runningNumber = ASI_CRM_PH_Testfactory.createRunningNumber(Date.today().year() -1);        
        insert runningNumber;
        
        List<ASI_CRM_AccountsAdditionalField__c> customerList = ASI_CRM_PH_Testfactory.createCustomers('MODERN OFF TRADE', true, true, 1);
        insert customerList;        
        
        List<ASI_TH_CRM_Contract__c> contractList = ASI_CRM_PH_Testfactory.createContracts(customerList[0].Id, Date.newInstance(Date.today().Year() - 1, 7, 1), Date.newInstance(Date.today().Year(), 6, 30), 1);
        contractList[0].ASI_CRM_Contract_Fund_Amount__c = 100;	 
        contractList[0].ASI_CRM_Marketing_Support_Fund_Amount__c = 100;	 	 
        contractList[0].ASI_CRM_Activation_Fund_Amount__c = 100;	 	 
        contractList[0].ASI_CRM_Merchandise_Amount__c = 100;	 	 
        contractList[0].ASI_CRM_Purchase_Incentive_Amount__c = 100;	 	 
        contractList[0].ASI_CRM_Staff_Incentive_Amount__c = 100;	 	 
        contractList[0].ASI_CRM_Bottle_Rebate_Amount__c = 100;
        contractList[0].ASI_CRM_Sales_Revenue_Target_Outlet__c = 100;
        contractList[0].ASI_CRM_SG_Net_Sales__c = 1000;
        insert contractList; 
        
        List<ASI_FOC_Free_Goods_Request__c> focList = new List<ASI_FOC_Free_Goods_Request__c>();
        ASI_FOC_Free_Goods_Request__c foc1 = ASI_CRM_PH_Testfactory.createFOCRequest(contractList[0].Id, Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_PH_Contract_FOC_POSM_Request'));
        foc1.ASI_CRM_Outlet__c = customerList[0].Id;
        foc1.ASI_FOC_Request_Type__c = 'FOC';
        foc1.ASI_FOC_Receiptor_Name__c = 'TEST0';
        focList.add(foc1);
        
        ASI_FOC_Free_Goods_Request__c foc2 = ASI_CRM_PH_Testfactory.createFOCRequest(contractList[0].Id, Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_PH_Contract_FOC_POSM_Request'));
        foc2.ASI_CRM_Outlet__c = customerList[0].Id;
        foc2.ASI_FOC_Request_Type__c = 'FOC';
        foc2.ASI_FOC_Receiptor_Name__c = 'TEST';
        focList.add(foc2);
        insert focList;

		ASI_MFM_Sub_brand__c subbrand = ASI_CRM_PH_Testfactory.createSubBrand();
        insert subbrand;
        
        List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
        ASI_MFM_SKU_Code__c sku1 = ASI_CRM_PH_Testfactory.createSKU(subbrand.Id);
        sku1.recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_PH_DF_SKU');
        sku1.ASI_FOC_Active__c = true;
        sku1.ASI_CRM_Duty_Free__c = true;
        skuList.add(sku1);
        
        ASI_MFM_SKU_Code__c sku2 = ASI_CRM_PH_Testfactory.createSKU(subbrand.Id);
        sku2.recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_PH_DF_SKU');
        sku2.Name = 'Test SKU 2';
        sku2.ASI_FOC_Active__c = true;
        sku2.ASI_CRM_Duty_Free__c = true;
        skuList.add(sku2);        
        insert skuList;
        
        ASI_CRM_MY_SKUPriceCost__c priceCost = ASI_CRM_PH_Testfactory.createSKUPriceCost(skuList[1].Id, customerList[0].Id);
        insert priceCost;
        
        List<ASI_FOC_Request_Item__c> focItemList = new List<ASI_FOC_Request_Item__c>();
        ASI_FOC_Request_Item__c focItem1 = ASI_CRM_PH_Testfactory.createFocItem(focList[0].Id, Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_PH_FOC_POSM_Request_Item'));
        focItem1.ASI_FOC_SKU__c = skuList[0].Id;
        focItem1.ASI_FOC_Request_Quantity_Bottle__c = 10;
        focItem1.ASI_FOC_Unit_Cost_PC_BT__c = 10;
        focItemList.add(focItem1);
        
        ASI_FOC_Request_Item__c focItem2 = ASI_CRM_PH_Testfactory.createFocItem(focList[1].Id, Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_PH_FOC_POSM_Request_Item'));
        focItem2.ASI_FOC_SKU__c = skuList[1].Id;
        focItem2.ASI_FOC_Request_Quantity_Bottle__c = 10;
        focItem2.ASI_FOC_Unit_Cost_PC_BT__c = 10;
        focItemList.add(focItem2);
        
        insert focItemList;
        
        ASI_CRM_ContractTarget__c contractTarget = ASI_CRM_PH_Testfactory.createContractTarget(contractList[0].Id, skuList[1].id);
        insert contractTarget;
    }
    
    @isTest
    public static void testContractFOC(){
        testSetupContract();
        ASI_FOC_Free_Goods_Request__c foc = [select id from ASI_FOC_Free_Goods_Request__c where ASI_FOC_Receiptor_Name__c = 'TEST0' Limit 1];
        
        PageReference pageRef = Page.ASI_CRM_PH_FOCManageAll_Page;
        pageRef.getParameters().put('id', foc.Id);
        
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(foc);
        ASI_CRM_PH_FOCManageAll_Ctrl focCtrl = new ASI_CRM_PH_FOCManageAll_Ctrl(sc);
        pageRef.getParameters().put('isQuickSave', 'true');
        
        ASI_FOC_Request_Item__c focItem = ASI_CRM_PH_Testfactory.createFocItem(foc.Id, Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_PH_FOC_POSM_Request_Item'));
        focItem.ASI_FOC_SKU__c = [select id from ASI_MFM_SKU_Code__c where Name = 'Test SKU 2'].Id;
        focItem.ASI_FOC_Request_Quantity_Bottle__c = 10;
        
        List<String> deleteFocItemIdList = new List<String>();
        for(ASI_FOC_Request_Item__c item: [select id from ASI_FOC_Request_Item__c where ASI_FOC_Request_Order__c =: foc.id]){
            deleteFocItemIdList.add(item.id);
        }
        String deleteFocItemJSON = JSON.serialize(deleteFocItemIdList);        
        String focItemJSON = JSON.serialize(new List<ASI_FOC_Request_Item__c>{focItem});
        
        pageRef.getParameters().put('deleteFocItemIdListJson', deleteFocItemJSON);
        pageRef.getParameters().put('upsertFocListJson', focItemJSON);        
        
		focCtrl.saveFocItem();
        
        List<ASI_FOC_Request_Item__c> focItemTest = [select id from ASI_FOC_Request_Item__c];
        System.assertEquals(focItemTest.size(), 2);
    }   
        
    @isTest
    public static void testFOCPO(){
        User u = [select id from User where lastName = 'last' limit 1]; 
        system.runAs(u){     
            // set up data
            List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
            ASI_MFM_Prefix__c prefix1 = new ASI_MFM_Prefix__c();
            prefix1.ASI_MFM_Module__c = 'PO';      
            prefixList.add(prefix1);
            
            ASI_MFM_Prefix__c prefix2 = new ASI_MFM_Prefix__c();
            prefix2.ASI_MFM_Module__c = 'Plan';
            prefixList.add(prefix2);
            
            insert prefixList;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> roleRelList = new List<ASI_MFM_Role_Prefix_Relationship__c>();
            
            ASI_MFM_Role_Prefix_Relationship__c roleRel1 = new ASI_MFM_Role_Prefix_Relationship__c();
            roleRel1.ASI_MFM_Prefix__c = prefixList[0].id;
            roleRel1.ASI_MFM_Role_Name__c = 'MyCustomRole';
            roleRelList.add(roleRel1);
            
            ASI_MFM_Role_Prefix_Relationship__c roleRel2 = new ASI_MFM_Role_Prefix_Relationship__c();
            roleRel2.ASI_MFM_Prefix__c = prefixList[1].id;
            roleRel2.ASI_MFM_Role_Name__c = 'MyCustomRole';
            roleRelList.add(roleRel2);
            
            insert roleRelList;
            
            Account account = new Account();
            account.Name = 'TEST';
            account.RecordTypeId = Global_RecordTypeCache.getRTId('AccountASI_MFM_PH_Supplier');
            insert account;  
    
            ASI_MFM_Sub_brand__c subbrand = ASI_CRM_PH_Testfactory.createSubBrand();
            insert subbrand;         
            
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c();
            plan.recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan__cASI_MFM_PH_DF_Plan');
            plan.ASI_MFM_Prefix__c = prefixList[1].id;
            plan.ASI_MFM_Status__c = 'Final';
            insert plan;
            
            ASI_MFM_PO__c po = ASI_CRM_PH_Testfactory.createPO();
            po.recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_PH_DF_PO');
            po.ASI_MFM_Prefix__c = prefixList[0].id;
            po.ASI_MFM_Supplier_Name__c = account.Id;
            po.ASI_MFM_Plan__c = plan.Id;
            po.ASI_MFM_PO_Start_Date__c = Date.today().addDays(1);
            po.ASI_MFM_PO_End_Date__c = Date.today().addDays(7);
            insert po;
            
			ASI_MFM_PO_Line_Item__c poItem = new ASI_MFM_PO_Line_Item__c();
			poItem.ASI_MFM_PO__c = po.Id;
            poItem.ASI_MFM_Amount__c = 1000;
            poItem.ASI_MFM_Exchange_Rate__c = 1;
            poItem.ASI_MFM_Sub_brand_Code__c = subbrand.Id;
            poItem.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item');
            insert poItem;
            
            system.debug([select ASI_MFM_Base_Currency_Amount__c from ASI_MFM_PO_Line_Item__c where Id =: poItem.Id]);
            system.debug([select ASI_MFM_Base_Currency_Amount__c from ASI_MFM_PO__c where id =: po.Id]);
            
            ASI_FOC_Free_Goods_Request__c foc = ASI_CRM_PH_Testfactory.createFOCRequest(null, Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_MFM_PH_PO_FOC_POSM_Request'));
            foc.ASI_FOC_MFM_Consumer_AP_PO_Number__c = po.Id;
            insert foc;
            
            List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
            ASI_MFM_SKU_Code__c sku1 = ASI_CRM_PH_Testfactory.createSKU(subbrand.Id);
            skuList.add(sku1);
            
            ASI_MFM_SKU_Code__c sku2 = ASI_CRM_PH_Testfactory.createSKU(subbrand.Id);
            skuList.add(sku2);
            insert skuList;
            
            List<ASI_CRM_MY_SKUPriceCost__c> priceCostList = new List<ASI_CRM_MY_SKUPriceCost__c>();
            ASI_CRM_MY_SKUPriceCost__c priceCost1 = new ASI_CRM_MY_SKUPriceCost__c();
            priceCost1.ASI_CRM_SKU__c = skuList[0].Id;
            priceCost1.ASI_CRM_Price__c = 10;
            priceCost1.ASI_CRM_EffectiveDate__c = Date.today();
            priceCost1.recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_List_Price');  
            priceCostList.add(priceCost1);
            
            ASI_CRM_MY_SKUPriceCost__c priceCost2 = new ASI_CRM_MY_SKUPriceCost__c();
            priceCost2.ASI_CRM_SKU__c = skuList[1].Id;
            priceCost2.ASI_CRM_Price__c = 10;
            priceCost2.ASI_CRM_EffectiveDate__c = Date.today();
            priceCost2.recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_List_Price');  
            priceCostList.add(priceCost2);
            insert priceCostList;
            
            ASI_FOC_Request_Item__c focItem = ASI_CRM_PH_Testfactory.createFocItem(foc.Id, Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_PH_FOC_POSM_Request_Item'));
            focItem.ASI_FOC_SKU__c = skuList[0].Id;
            focItem.ASI_FOC_Request_Quantity_Bottle__c = 10;
            focItem.ASI_FOC_Unit_Cost_PC_BT__c = 10;
            insert focItem;
            
            // test controller
            
            PageReference pageRef = Page.ASI_CRM_PH_FOCManageAll_Page;
            pageRef.getParameters().put('id', foc.Id);
            
            Test.setCurrentPage(pageRef);
    
            ApexPages.StandardController sc = new ApexPages.StandardController(foc);
            ASI_CRM_PH_FOCManageAll_Ctrl focCtrl = new ASI_CRM_PH_FOCManageAll_Ctrl(sc);
            pageRef.getParameters().put('isQuickSave', 'true');
            
            List<ASI_FOC_Request_Item__c> focItemList = new List<ASI_FOC_Request_Item__c>();
            ASI_FOC_Request_Item__c focItem2 = ASI_CRM_PH_Testfactory.createFocItem(foc.Id, Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_PH_FOC_POSM_Request_Item'));
            focItem2.ASI_FOC_SKU__c = skuList[0].Id;
            focItem2.ASI_FOC_Request_Quantity_Bottle__c = 10;
            focItem2.ASI_FOC_Unit_Cost_PC_BT__c = 10;
            focItemList.add(focItem2);
            
            ASI_FOC_Request_Item__c focItem3 = ASI_CRM_PH_Testfactory.createFocItem(foc.Id, Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_PH_FOC_POSM_Request_Item'));
            focItem3.ASI_FOC_SKU__c = skuList[1].Id;
            focItem3.ASI_FOC_Request_Quantity_Bottle__c = 10;
            focItem3.ASI_FOC_Unit_Cost_PC_BT__c = 10;
            focItemList.add(focItem3);
            
            String focItemJSON = JSON.serialize(focItemList);
            
            pageRef.getParameters().put('upsertFocListJson', focItemJSON);        
        
			focCtrl.saveFocItem();
            
        }
    }
}