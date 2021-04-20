/**
Name: EUR_CRM_DE_TestSKUTargetMgmtCtrlr
 
Description: Test Class for EUR_CRM_SKUTargetManagementController 
   
Author/Company:    IP Converge Data Services,Inc.
History:      
JUL.03.2014        IPC     Created 
NOV.07.2014        IPC     Updated 
    
*/
@isTest
public class EUR_CRM_DE_TestSKUTargetMgmtCtrlr{
 
    @isTest
    public static void testEmptyCustomerTaxonomy(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
            //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c noAccountCustTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            noAccountCustTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy6.id;
            noAccountCustTax.EUR_CRM_ObjPromo__c = objPromo.id;
            //insert noAccountCustTax;
            
            Test.startTest();           
            // START TEST ---
            
            PageReference aPage = Page.EUR_CRM_SKUTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_SKUTargetManagementController exCon = new EUR_CRM_SKUTargetManagementController(sc);
            system.assert(!exCon.renderPage);
            // STOP TEST ---            
            Test.stopTest();
        }
    }
   /*
    @isTest
    public static void testCustomerTaxonomy(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy3.id;
            custTax.EUR_CRM_ObjPromo__c = objPromo.id;
            insert custTax ;
            
            Test.startTest();           
            // START TEST ---
            
            PageReference aPage = Page.EUR_CRM_SKUTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_SKUTargetManagementController exCon = new EUR_CRM_SKUTargetManagementController(sc);
            system.assert(exCon.renderPage);
            // STOP TEST ---            
            Test.stopTest();
        }
    }
    @isTest
    public static void testAddSKU(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy3.id;
            custTax.EUR_CRM_ObjPromo__c = objPromo.id;
            insert custTax ;
            
            Test.startTest();           
            // START TEST ---
            
            PageReference aPage = Page.EUR_CRM_SKUTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_SKUTargetManagementController exCon = new EUR_CRM_SKUTargetManagementController(sc);
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.sku.id);
            exCon.add();
            aPage.getParameters().put('rowIndex', '1');
            exCon.removeSKU();
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.sku.id);
            exCon.add();
            exCon.save();
            system.assert(exCon.getRegionalManagerOptions().size() > 0);
            // STOP TEST ---            
            Test.stopTest();
        }
    } 
    */
    @isTest
    public static void testGetTargets(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager ){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet(); 
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
            //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy3.id;
            custTax.EUR_CRM_ObjPromo__c = objPromo.id;
            insert custTax ;  
            
            Test.startTest(); 
            EUR_CRM_Account__c salesAgentAccountEU = EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount3 ;
                salesAgentAccountEU.EUR_CRM_Status_of_Customer__c= 'Agency Managed';
            	salesAgentAccountEU.EUR_CRM_Territory__c = EUR_CRM_DE_TestClassUtilityHelper.offTradeTerritory1.id;
                update salesAgentAccountEU;
                      
            // START TEST ---
            
            PageReference aPage = Page.EUR_CRM_SKUTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_SKUTargetManagementController exCon = new EUR_CRM_SKUTargetManagementController(sc);
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.sku.id);
            exCon.add();
            aPage.getParameters().put('rowIndex', '1');
            //exCon.removeSKU();
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.sku.id);
            exCon.add();
            exCon.regionalTargets = new List<EUR_CRM_ObjPromo_Target__c>();
            exCon.regionalTargets.add(EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'Regional Volume Target', objPromo.Id, null)[0]);
       //     sku.
            EUR_CRM_DE_TestClassUtilityHelper.sku.EUR_CRM_Unit_Type__c = 'Display';
            update EUR_CRM_DE_TestClassUtilityHelper.sku;
            exCon.regionalTargets.get(0).EUR_CRM_SKU__c = EUR_CRM_DE_TestClassUtilityHelper.sku.id;
            exCon.regionalTargets.get(0).EUR_CRM_SKU__r = EUR_CRM_DE_TestClassUtilityHelper.sku;
            exCon.save();
            excon.getRegionalTargetWraps(); 
            excon.getSRTargetWraps();
            excon.getSalesAgencyTargetWraps();
            excon.getRegionalAndSalesAgencyTargetWraps();
            excon.getRegionalManagerOptions();
            Boolean a = excon.isKAM;
             a = excon.isRegional;
             excon.getSalesRepAndSalesAgencyTargetWraps();
            // STOP TEST ---
            EUR_CRM_DE_TestClassUtilityHelper.sku.EUR_CRM_Unit_Type__c =  'Display';
            update EUR_CRM_DE_TestClassUtilityHelper.sku;
            List<EUR_CRM_ObjPromo_Target__c> srTargets = new List<EUR_CRM_ObjPromo_Target__c>();
            srTargets.add(new EUR_CRM_ObjPromo_Target__c(EUR_CRM_ObjPromo__c = objPromo.id,EUR_CRM_SKU__c = EUR_CRM_DE_TestClassUtilityHelper.sku.id, EUR_CRM_SKU__r = EUR_CRM_DE_TestClassUtilityHelper.sku));        
            excon.srTargets = srTargets;
            excon.quickSaveSRTargets();
            excon.quickSave();
            excon.regionManager = null; 
            excon.getSRTargetWraps();
            excon.getSalesAgencyTargetWraps();
            excon.getSalesRepAndSalesAgencyTargetWraps();
            id regionmanager = null;
            excon.getSalesAgencyTargetWrapsByRegion(regionmanager);
            delete custTax;
            sc = new Apexpages.standardController(objPromo);
            exCon = new EUR_CRM_SKUTargetManagementController(sc);
            Test.stopTest();
        }
    }
    @isTest    
    public static void testSalesDrive(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager ){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet(); 
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
            //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy3.id;
            custTax.EUR_CRM_ObjPromo__c = objPromo.id;
            insert custTax ;  
            
            Test.startTest(); 
            EUR_CRM_Account__c salesAgentAccountEU = EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount3 ;
                salesAgentAccountEU.EUR_CRM_Status_of_Customer__c= 'Agency Managed';
            	salesAgentAccountEU.EUR_CRM_Territory__c = EUR_CRM_DE_TestClassUtilityHelper.offTradeTerritory1.id;
                update salesAgentAccountEU;
                      
            // START TEST ---
            
            PageReference aPage = Page.EUR_CRM_DE_SKUTargetMgt_SalesDrive;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_DE_SKUTargetMgt_SalesDriveCtrllr exCon = new EUR_CRM_DE_SKUTargetMgt_SalesDriveCtrllr(sc);
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.sku.id);
            exCon.add();
            aPage.getParameters().put('rowIndex', '1');
            //exCon.removeSKU();
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.sku.id);
            exCon.add();
            exCon.regionalTargets = new List<EUR_CRM_ObjPromo_Target__c>();
            exCon.regionalTargets.add(EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'Regional Volume Target', objPromo.Id, null)[0]);
       //     sku.
            EUR_CRM_DE_TestClassUtilityHelper.sku.EUR_CRM_Unit_Type__c = 'Display';
            update EUR_CRM_DE_TestClassUtilityHelper.sku;
            exCon.regionalTargets.get(0).EUR_CRM_SKU__c = EUR_CRM_DE_TestClassUtilityHelper.sku.id;
            exCon.regionalTargets.get(0).EUR_CRM_SKU__r = EUR_CRM_DE_TestClassUtilityHelper.sku;
            exCon.save();
            excon.getRegionalTargetWraps(); 
            excon.getSRTargetWraps();
            excon.getSalesAgencyTargetWraps();
            excon.getRegionalAndSalesAgencyTargetWraps();
            excon.getRegionalManagerOptions();
            Boolean a = excon.isKAM;
             a = excon.isRegional;
             excon.getSalesRepAndSalesAgencyTargetWraps();
            // STOP TEST ---
            EUR_CRM_DE_TestClassUtilityHelper.sku.EUR_CRM_Unit_Type__c =  'Display';
            update EUR_CRM_DE_TestClassUtilityHelper.sku;
            List<EUR_CRM_ObjPromo_Target__c> srTargets = new List<EUR_CRM_ObjPromo_Target__c>();
            srTargets.add(new EUR_CRM_ObjPromo_Target__c(EUR_CRM_ObjPromo__c = objPromo.id,EUR_CRM_SKU__c = EUR_CRM_DE_TestClassUtilityHelper.sku.id, EUR_CRM_SKU__r = EUR_CRM_DE_TestClassUtilityHelper.sku));        
            excon.srTargets = srTargets;
            excon.quickSaveSRTargets();
            excon.quickSave();
            excon.regionManager = null; 
            excon.getSRTargetWraps();
            excon.getSalesAgencyTargetWraps();
            excon.getSalesRepAndSalesAgencyTargetWraps();
            id regionmanager = null;
            excon.getSalesAgencyTargetWrapsByRegion(regionmanager);
            delete custTax;
            excon.removeSKU();
            sc = new Apexpages.standardController(objPromo);
            exCon = new EUR_CRM_DE_SKUTargetMgt_SalesDriveCtrllr(sc);
            Test.stopTest();
        }
    }
    /*
    @isTest
    public static void testEmptyCustomerTaxonomy(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
                   
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
            
            
            
            Test.startTest();
            
            PageReference aPage = Page.EUR_CRM_SKUTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_SKUTargetManagementController exCon = new EUR_CRM_SKUTargetManagementController(sc);
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.sku.id);
            exCon.add();
            aPage.getParameters().put('rowIndex', '1');
            exCon.removeSKU();
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.sku.id);
            exCon.add();
            excon.getRegionalTargetWraps();
            exCon.save();
        Test.stopTest();
            //excon.getSalesAgencyTargetWraps();
            //excon.getSRTargetWraps();
        }
    }
    @isTest
    public static void test2(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
                   
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
            Test.startTest();
            PageReference aPage = Page.EUR_CRM_BQSTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_SKUTargetManagementController exCon = new EUR_CRM_SKUTargetManagementController(sc);
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.sku.id);
            exCon.add();
            aPage.getParameters().put('rowIndex', '1');
            exCon.removeSKU();
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.sku.id); 
            excon.getRegionalTargetWraps(); 
            excon.getSRTargetWraps();
            Test.stopTest();
        }
    }
    @isTest
    public static void test3(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
                   
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
            
            PageReference aPage = Page.EUR_CRM_BQSTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_SKUTargetManagementController exCon = new EUR_CRM_SKUTargetManagementController(sc);
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.sku.id);
            exCon.add();
            aPage.getParameters().put('rowIndex', '1');
            exCon.removeSKU();
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.sku.id);  
            excon.getSalesAgencyTargetWraps(); 
            excon.getRegionalManagerOptions();
        }
    }
    */
}