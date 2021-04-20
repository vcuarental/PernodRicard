/*------------------------------------------------------------
Author/Company:   IP Converge Data Services,Inc.
Description:      test class for 
                    EUR_CRM_DE_PrestigeAccountHandler
                    EUR_CRM_DE_TerritoryAccountHandler
                    EUR_CRM_DE_TerritoryUpdateController
History
01/08/2014      IPC     Created 
------------------------------------------------------------*/
@isTest
public class EUR_CRM_DE_Test2ndPlacementMgmtCtrlr{

    @isTest
    public static void testEmptyCustomerTaxonomy(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test34434','DE_OFF_ALT_2nd_PL_Carton' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
           
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SECONDARY_PLACEMENT_CARTON ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02); 
            insert objPromo;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c noAccountCustTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            noAccountCustTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy6.id;
            noAccountCustTax.EUR_CRM_ObjPromo__c = objPromo.id;
            insert noAccountCustTax;
             Test.startTest();           
            // START TEST ---
            
            PageReference aPage = Page.EUR_CRM_2ndPlacementTargetMgmtPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_2ndPlacementTargetMmgtController exCon = new EUR_CRM_2ndPlacementTargetMmgtController(sc);
            system.assert(!exCon.renderPage);
            // STOP TEST ---            
            Test.stopTest(); 
        }
    }

    @isTest
    public static void testCustomerTaxonomy(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test34434','DE_OFF_ALT_2nd_PL_Carton' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
           
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SECONDARY_PLACEMENT_CARTON ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02); 
            insert objPromo;
             EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy3.id;
            custTax.EUR_CRM_ObjPromo__c = objPromo.id;
            insert custTax ;
            
            Test.startTest();           
            // START TEST ---
            
             PageReference aPage = Page.EUR_CRM_2ndPlacementTargetMgmtPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_2ndPlacementTargetMmgtController exCon = new EUR_CRM_2ndPlacementTargetMmgtController(sc);
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
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test34434','DE_OFF_ALT_2nd_PL_Carton' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
           
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SECONDARY_PLACEMENT_CARTON ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02); 
            insert objPromo;
             EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy3.id;
            custTax.EUR_CRM_ObjPromo__c = objPromo.id;
            insert custTax ;
            
            Test.startTest();           
            // START TEST ---
            
             PageReference aPage = Page.EUR_CRM_2ndPlacementTargetMgmtPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_2ndPlacementTargetMmgtController exCon = new EUR_CRM_2ndPlacementTargetMmgtController(sc);
            system.assert(exCon.renderPage);
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.bqs.id);
            exCon.add();
            aPage.getParameters().put('rowIndex', '1');
            exCon.removeSKU();
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.bqs.id);
            exCon.add();
            exCon.save();
            system.assert(exCon.getRegionalManagerOptions().size() > 0);
            // STOP TEST ---            
            Test.stopTest();
        }
    } @isTest
    public static void testGetTargets(){
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
            
                PageReference aPage = Page.EUR_CRM_2ndPlacementTargetMgmtPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_2ndPlacementTargetMmgtController exCon = new EUR_CRM_2ndPlacementTargetMmgtController(sc);
            system.assert(exCon.renderPage); 
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.bqs.id);
            exCon.add();
            aPage.getParameters().put('rowIndex', '1'); 
            exCon.save();
            
            excon.getRegionalTargetWraps(); 
            excon.getSRTargetWraps(); 
            excon.getRegionalManagerOptions();
            // STOP TEST ---            
            Test.stopTest();
        }
    }
}