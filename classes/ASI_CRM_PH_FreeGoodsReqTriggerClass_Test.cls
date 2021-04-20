/***************************************************************************************************************************
 * Name:        ASI_CRM_PH_FreeGoodsReqTriggerClass_Test
 * Description: Contains the test methods for ASI_CRM_PH_FreeGoodsRequest_TriggerClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-01-27       Calvin Chiu (LAPUTA)    Created
 ****************************************************************************************************************************/
@isTest
public without sharing class ASI_CRM_PH_FreeGoodsReqTriggerClass_Test {	
    @testSetup
    private static void testSetup(){
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
    
    private static void customSetup(){
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
    }
    
    @isTest
    public static void testContractFOC(){
        customSetup();
        ASI_TH_CRM_Contract__c contract = [select id from ASI_TH_CRM_Contract__c Limit 1];
        
        ASI_FOC_Free_Goods_Request__c foc = ASI_CRM_PH_Testfactory.createFOCRequest(contract.Id, Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_PH_Contract_FOC_POSM_Request_Read_Only'));
        insert foc;

		ASI_MFM_Sub_brand__c subbrand = ASI_CRM_PH_Testfactory.createSubBrand();
        insert subbrand;
        
        ASI_MFM_SKU_Code__c sku = ASI_CRM_PH_Testfactory.createSKU(subbrand.Id);
        insert sku;
        
        ASI_FOC_Request_Item__c focItem = ASI_CRM_PH_Testfactory.createFocItem(foc.Id, Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_PH_FOC_POSM_Request_Item'));
        focItem.ASI_FOC_SKU__c = sku.Id;
        focItem.ASI_FOC_Request_Quantity_Bottle__c = 10;
        focItem.ASI_FOC_Unit_Cost_PC_BT__c = 10;
        insert focItem;
                
        foc.ASI_FOC_Request_Status__c = 'Submitted';
        update foc;
        
        ASI_MFM_SKU_Code__c updatedSKU = [select ASI_HK_CRM_Inventory__c from ASI_MFM_SKU_Code__c Limit 1];
        System.assertEquals(updatedSKU.ASI_HK_CRM_Inventory__c, 90);
        
		foc.ASI_FOC_Request_Status__c = 'Final';    
        update foc;
        
        ASI_TH_CRM_Contract__c updatedContract = [select ASI_CRM_Paid_Merchandise_Amount__c from ASI_TH_CRM_Contract__c Limit 1];
        system.assertEquals(updatedContract.ASI_CRM_Paid_Merchandise_Amount__c, 100);        
    }
    
    @isTest
    public static void testContractFOCRejected(){
        customSetup();
        ASI_TH_CRM_Contract__c contract = [select id from ASI_TH_CRM_Contract__c Limit 1];
        
        ASI_FOC_Free_Goods_Request__c foc = ASI_CRM_PH_Testfactory.createFOCRequest(contract.Id, Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_PH_Contract_FOC_POSM_Request_Read_Only'));
        insert foc;

		ASI_MFM_Sub_brand__c subbrand = ASI_CRM_PH_Testfactory.createSubBrand();
        insert subbrand;
        
        ASI_MFM_SKU_Code__c sku = ASI_CRM_PH_Testfactory.createSKU(subbrand.Id);
        insert sku;
        
        ASI_FOC_Request_Item__c focItem = ASI_CRM_PH_Testfactory.createFocItem(foc.Id, Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_PH_FOC_POSM_Request_Item'));
        focItem.ASI_FOC_SKU__c = sku.Id;
        focItem.ASI_FOC_Request_Quantity_Bottle__c = 10;
        focItem.ASI_FOC_Unit_Cost_PC_BT__c = 10;
        insert focItem;
                
        foc.ASI_FOC_Request_Status__c = 'Submitted';
        update foc;
        
        foc.ASI_FOC_Request_Status__c = 'Rejected';
        update foc;
        
        ASI_MFM_SKU_Code__c updatedSKU = [select ASI_HK_CRM_Inventory__c from ASI_MFM_SKU_Code__c limit 1];
        System.assertEquals(updatedSKU.ASI_HK_CRM_Inventory__c, 100);
    }
    
    @isTest
    public static void testPOFOC(){ 
        User u = [select id from User where lastName = 'last' limit 1];  
        customSetup();
        system.runAs(u){ 
            test.startTest();
            
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
            insert po;
            
			ASI_MFM_PO_Line_Item__c poItem = new ASI_MFM_PO_Line_Item__c();
			poItem.ASI_MFM_PO__c = po.Id;
            poItem.ASI_MFM_Amount__c = 1000;
            poItem.ASI_MFM_Exchange_Rate__c = 1;
            poItem.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_PH_PO_Line_Item');
            insert poItem;
            
            system.debug([select ASI_MFM_Base_Currency_Amount__c from ASI_MFM_PO_Line_Item__c where Id =: poItem.Id]);
            system.debug([select ASI_MFM_Base_Currency_Amount__c from ASI_MFM_PO__c where id =: po.Id]);
            
            ASI_FOC_Free_Goods_Request__c foc = ASI_CRM_PH_Testfactory.createFOCRequest(null, Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_MFM_PH_PO_FOC_POSM_Request_Read_Only'));
            foc.ASI_FOC_MFM_Consumer_AP_PO_Number__c = po.Id;
            insert foc;
    
            ASI_MFM_Sub_brand__c subbrand = ASI_CRM_PH_Testfactory.createSubBrand();
            insert subbrand;
            
            ASI_MFM_SKU_Code__c sku = ASI_CRM_PH_Testfactory.createSKU(subbrand.Id);
            insert sku;
            
            ASI_FOC_Request_Item__c focItem = ASI_CRM_PH_Testfactory.createFocItem(foc.Id, Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_PH_FOC_POSM_Request_Item'));
            focItem.ASI_FOC_SKU__c = sku.Id;
            focItem.ASI_FOC_Request_Quantity_Bottle__c = 10;
            focItem.ASI_FOC_Unit_Cost_PC_BT__c = 10;
            insert focItem;
            
            foc.ASI_FOC_Request_Status__c = 'Submitted';
            update foc;
            
            foc.ASI_FOC_Request_Status__c = 'Final';
            update foc;
            
        	test.stopTest();
        }        
    }
}