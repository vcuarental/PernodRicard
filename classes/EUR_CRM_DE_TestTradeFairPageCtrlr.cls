@isTest
public class EUR_CRM_DE_TestTradeFairPageCtrlr{

    @isTest
    public static void testEmptyCustomerTaxonomy(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Trade_Fair' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
                   
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_TRADE_FAIR ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
             insert objPromo;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c noAccountCustTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            noAccountCustTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy6.id;
            noAccountCustTax.EUR_CRM_ObjPromo__c = objPromo.id;
           // insert noAccountCustTax;
             Test.startTest();  
             PageReference aPage = Page.EUR_CRM_TradeFairTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_TradeFairPageController exCon = new EUR_CRM_TradeFairPageController(sc);
             system.assert(!exCon.renderPage);
            Test.stopTest();
        }
    }
    @isTest
    public static void testCustomerTaxonomy(){
         EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Trade_Fair' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
                   
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_TRADE_FAIR ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
             insert objPromo;
             EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy3.id;
            custTax.EUR_CRM_ObjPromo__c = objPromo.id;
            insert custTax ;
            
            Test.startTest();           
            // START TEST ---
            
             PageReference aPage = Page.EUR_CRM_TradeFairTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_TradeFairPageController exCon = new EUR_CRM_TradeFairPageController(sc);
            system.assert(exCon.renderPage); 
            // STOP TEST ---            
            Test.stopTest();
        }
    }
     @isTest
    public static void testAddBQS(){
         EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Trade_Fair' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
                   
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_TRADE_FAIR ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
             insert objPromo;
             EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy3.id;
            custTax.EUR_CRM_ObjPromo__c = objPromo.id;
            insert custTax ;
            
            Test.startTest();           
            // START TEST ---
            
             PageReference aPage = Page.EUR_CRM_TradeFairTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_TradeFairPageController exCon = new EUR_CRM_TradeFairPageController(sc);
            system.assert(exCon.renderPage); 
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.bqs.id);
            exCon.add();
            aPage.getParameters().put('rowIndex', '1');
            exCon.removeBQS();
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.bqs.id);
            exCon.add();
            exCon.save();
            system.assert(exCon.getRegionalManagerOptions().size() > 0);
            exCon.removeSKU();
            // STOP TEST ---            
            Test.stopTest();
        }
    } @isTest
    public static void testGetTargets(){
          EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Trade_Fair' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
                   
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_TRADE_FAIR ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
             insert objPromo;
             EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy3.id;
            custTax.EUR_CRM_ObjPromo__c = objPromo.id;
            insert custTax ;
            
            Test.startTest();           
            // START TEST ---
            
             PageReference aPage = Page.EUR_CRM_TradeFairTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_TradeFairPageController exCon = new EUR_CRM_TradeFairPageController(sc);
            system.assert(exCon.renderPage); 
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.bqs.id);
            exCon.add();
            aPage.getParameters().put('rowIndex', '1'); 
            exCon.save();
            
            excon.getRegionalTargetWraps();
            excon.getRegionalManagerOptions();
            excon.removeBQS();
            // STOP TEST ---            
            Test.stopTest();
        }
    }
    /*
    @isTest
    public static void test2(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Trade_Fair' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
                   
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_TRADE_FAIR ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
            Test.startTest();
             PageReference aPage = Page.EUR_CRM_BQSTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_TradeFairPageController exCon = new EUR_CRM_TradeFairPageController(sc);
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.bqs.id);
            exCon.add();
            aPage.getParameters().put('rowIndex', '1'); 
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.bqs.id); 
            excon.getRegionalTargetWraps();  
            exCon.quickSaveRegionalTargets(); 
            Test.stopTest();
        }
    }
    @isTest
    public static void test3(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Trade_Fair' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
                   
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_TRADE_FAIR ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
            Test.startTest();
             PageReference aPage = Page.EUR_CRM_BQSTargetManagementPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_TradeFairPageController exCon = new EUR_CRM_TradeFairPageController(sc);
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.bqs.id);
            exCon.add();
            exCon.getRegionalManagerOptions();
            aPage.getParameters().put('rowIndex', '1'); 
            aPage.getParameters().put('p1', EUR_CRM_DE_TestClassUtilityHelper.bqs.id);  
            exCon.quickSaveParticipants();
            Test.stopTest();
        }
    }
    */
}