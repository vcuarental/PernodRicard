@isTest
public class EUR_CRM_DE_TestCreateOPOnTradePageCtrl{

    @isTest
    public static void test1(){
//        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        createUser();
		System.debug('### SOQL Limits 1:'+Limits.getQueries());
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();
			System.debug('### SOQL Limits 2:'+Limits.getQueries());
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_ON_ALT_ON_PROS_TMKT_Promos' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
			System.debug('### SOQL Limits 3:'+Limits.getQueries());
            Test.startTest();
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_ON_TRADE_PROS_TMKT_PROMO,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
           // objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            /*
             insert objPromo;
			 System.debug('### SOQL Limits 4:'+Limits.getQueries());
             objPromo = [select RecordType.developername,EUR_CRM_PROS_Group_Outlet__c,
             EUR_CRM_Status__c,EUR_CRM_ObjPromo_OnTrade_Variation__c,EUR_CRM_Customer_Taxonomy__c,     EUR_CRM_PROS_Image_Level__c, EUR_CRM_Region__c, EUR_CRM_Territory__c, EUR_CRM_Type__c,
             id from EUR_CRM_ObjPromo__c where id= : objPromo.id];
             */
            PageReference aPage = Page.EUR_CRM_DE_CreateOPOnTradePage;
            String recordTypeOnTrade = [select id from RecordType where developername = 'EUR_DE_OnTrade_PROS_TMKT_Promo' limit 1].id;
            aPage.getParameters().put('RecordType', recordTypeOnTrade );
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo); 
            EUR_CRM_DE_CreateOPOnTradePageContrller exCon = new EUR_CRM_DE_CreateOPOnTradePageContrller(sc); 
			System.debug('### SOQL Limits 5:'+Limits.getQueries());
            exCon.getTerritoryOptions();
            exCon.redirect();
            exCon.handleSave();
            Test.stopTest();
        }
    } 
    @isTest
    public static void test2(){
//        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        createUser();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();   
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_ON_ALT_ON_PROS_TMKT_Promos' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );

            Test.startTest();
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_ON_TRADE_PROS_TMKT_PROMO,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
         //   objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
      
             insert objPromo;
             objPromo = [select RecordType.developername,EUR_CRM_PROS_Group_Outlet__c,
             EUR_CRM_Status__c,EUR_CRM_ObjPromo_OnTrade_Variation__c
           //  ,EUR_CRM_Customer_Taxonomy__c
             ,    
               EUR_CRM_PROS_Image_Level__c, 
             EUR_CRM_Region__c, EUR_CRM_Territory__c, EUR_CRM_Type__c,
             id from EUR_CRM_ObjPromo__c where id= : objPromo.id];
     
            PageReference aPage = Page.EUR_CRM_DE_CreateOPOnTradePage;
            String recordTypeOnTrade = [select id from RecordType where developername = 'EUR_DE_OnTrade_PROS_TMKT_Promo' limit 1].id;
            aPage.getParameters().put('RecordType', recordTypeOnTrade );
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo); 
            EUR_CRM_DE_CreateOPOnTradePageContrller exCon = new EUR_CRM_DE_CreateOPOnTradePageContrller(sc); 
            exCon.getTerritoryOptions();
            exCon.redirect();
            exCon.handleSave();
            Test.stopTest();
        }
    }
    @isTest
    public static void test3(){
//        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        createUser();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
             EUR_CRM_DE_TestClassUtilityHelper.initData();

            Test.startTest();
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_LEAFLET_CAMPAIGN,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
          //  objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
     
            PageReference aPage = Page.EUR_CRM_DE_CreateOPOnTradePage;
            String recordTypeOnTrade = [select id from RecordType where developername = 'EUR_DE_Off_Trade_Leaflet_Campaign' limit 1].id;
            aPage.getParameters().put('RecordType', recordTypeOnTrade );
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo); 
            EUR_CRM_DE_CreateOPOnTradePageContrller exCon = new EUR_CRM_DE_CreateOPOnTradePageContrller(sc); 
            exCon.getTerritoryOptions();
            exCon.redirect();
            exCon.handleSave();
            Test.stopTest();
        }
    }
    @isTest
    public static void test4(){
//        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        createUser();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
             EUR_CRM_DE_TestClassUtilityHelper.initData();

            Test.startTest();
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_LEAFLET_CAMPAIGN,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
          //  objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id; 
     
            PageReference aPage = Page.EUR_CRM_DE_CreateOPOnTradePage;
            String recordTypeOnTrade = [select id from RecordType where developername = 'EUR_DE_Off_Trade_Leaflet_Campaign' limit 1].id;
            aPage.getParameters().put('RecordType', recordTypeOnTrade );
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo); 
            EUR_CRM_DE_CreateOPOnTradePageContrller exCon = new EUR_CRM_DE_CreateOPOnTradePageContrller(sc); 
            exCon.getTerritoryOptions();
            exCon.redirect();
            exCon.handleSave();
            Test.stopTest();
        }
    }
    static void createUser() {
        EUR_CRM_DE_TestClassUtilityHelper.regionalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(EUR_CRM_DE_TestClassUtilityHelper.DE_ON_TRADE_USER_PROFILE,
                EUR_CRM_DE_TestClassUtilityHelper.REGIONAL_ON_TRADE_MANAGER_ROLE, 'testdezxc5@testemail.com', 'testdezxc5@testemail.com', 'testdezxc5');
        EUR_CRM_DE_TestClassUtilityHelper.salesRepUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(EUR_CRM_DE_TestClassUtilityHelper.DE_ON_TRADE_USER_PROFILE,
                EUR_CRM_DE_TestClassUtilityHelper.SR_ON_TRADE_ROLE,'testdezxc6@testemail.com', 'testdezxc6@testemail.com', 'testdezxc6');
    }
}