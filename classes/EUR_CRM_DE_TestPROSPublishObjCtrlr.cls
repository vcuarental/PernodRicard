@isTest
public class EUR_CRM_DE_TestPROSPublishObjCtrlr{
    
    
    @isTest
    public static void testOffTrade(){
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
            Id targetRTId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c','EUR_DE_Objective_Volume_Target');
            EUR_CRM_ObjPromo_Target__c objTarget = new EUR_CRM_ObjPromo_Target__c(EUR_CRM_ObjPromo__c = objPromo.id, 
                                                                                  EUR_CRM_SKU__c = EUR_CRM_DE_TestClassUtilityHelper.sku.Id,
                                                                                  EUR_CRM_Qty_Sell_in_Amount_Bottle__c = 100,
                                                                                  RecordTypeId = targetRTId);
            insert objTarget;
            
            Test.startTest();           
            // START TEST ---
            PageReference aPage = Page.EUR_CRM_PublishObjectivePage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_PublishObjectivePageController exCon = new EUR_CRM_PublishObjectivePageController(sc);
            //exCon.euAccounts[1].isSelected = true;
            exCon.publish();
            exCon.unPublish();
            Integer q = exCon.pageNumber;
            exCon.getPageSize();
            exCon.getRecordSize();
            String s = exCon.contextItem;
            exCon.doSelectItem();
            exCon.getHasSelectedAccounts();
            exCon.doDeselectItem();
            exCon.selectAll();
            exCon.doDeselectItem();
            exCon.deSelectAll();
            // STOP TEST ---            
            Test.stopTest();
        }
    }
 
    @isTest
    public static void testTradeFair(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Trade_Fair' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
                1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_TRADE_FAIR ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today().addDays(7); 
            insert objPromo;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy3.id;
            custTax.EUR_CRM_ObjPromo__c = objPromo.id;
            insert custTax ;
            EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount3.EUR_CRM_Is_Trade_Fair_Location__c = true;
            update EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount3;
            
            
            
            Test.startTest();           
            // START TEST ---
            PageReference aPage = Page.EUR_CRM_PublishObjectivePage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_PublishObjectivePageController exCon = new EUR_CRM_PublishObjectivePageController(sc);
            exCon.euAccounts.get(0).isSelected = true;
            exCon.publish();
            exCon.unPublish();
            exCon.cancel();
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
            //EUR_CRM_OP_Action_List_Template__c actionListTemplate = EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test333','DE_OFF_ALT_Tasting' ,'DE O/P Action List Template');
            
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
                1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_TASTING_CAMPAIGN ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            // objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
            
            Test.startTest();
            
            PageReference aPage = Page.EUR_CRM_PublishObjectivePage;
            test.setCurrentPage(aPage);
            
            objPromo = [select RecordType.developername,EUR_CRM_PROS_Group_Outlet__c,
                        EUR_CRM_Status__c,//EUR_CRM_Customer_Taxonomy__c,  
                        EUR_CRM_PROS_Image_Level__c,
                        EUR_CRM_Region__c, EUR_CRM_Territory__c, EUR_CRM_Type__c,
                        id from EUR_CRM_ObjPromo__c where id= : objPromo.id];
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_PublishObjectivePageController exCon = new EUR_CRM_PublishObjectivePageController(sc);
            exCon.publish();
            exCon.unPublish();
            exCon.cancel();
            
            Test.stopTest();
      }
    }      
    */   
    @isTest
    public static void testPROS(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_ON_ALT_ON_PROS_TMKT_Promos' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            EUR_CRM_ObjPromo_OnTrade_Variation__c opVar = new EUR_CRM_ObjPromo_OnTrade_Variation__c(name='test', EUR_CRM_Is_Active__c=true);       
            insert opVar;
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
                1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_ON_TRADE_PROS_TMKT_PROMO,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            objPromo.EUR_CRM_PROS_Image_Level__c = 'Iconic';
            objPromo.EUR_CRM_PROS_Group_Outlet__c = 'Restaurant';
            objPromo.EUR_CRM_ObjPromo_OnTrade_Variation__c = opVar.id;
            insert objPromo;
            PageReference aPage = Page.EUR_CRM_PublishObjectivePage;
            test.setCurrentPage(aPage);
            Test.startTest();    
            objPromo = [select RecordType.developername,EUR_CRM_PROS_Group_Outlet__c,
                        EUR_CRM_Status__c,//EUR_CRM_Customer_Taxonomy__c,    
                        EUR_CRM_PROS_Image_Level__c, 
                        EUR_CRM_Region__c, EUR_CRM_Territory__c, EUR_CRM_Type__c,
                        id from EUR_CRM_ObjPromo__c where id= : objPromo.id];
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_PublishObjectivePageController exCon = new EUR_CRM_PublishObjectivePageController(sc);
            exCon.publish();
            exCon.unPublish();
            exCon.cancel();
            exCon.getWrapAccounts();         
            exCon.doNext();
            exCon.doPrevious();
            exCon.first();
            exCon.last();
            exCon.getHasPrevious();
            exCon.getHasNext();
            exCon.getPageNumber();
            exCon.getTotalPages();
            exCon.retrievePreparationDate();
            exCon.getPageSize();
            exCon.getRecordSize();
            exCon.doSelectItem();
            exCon.getHasSelectedAccounts();
            exCon.selectAll();
            exCon.deSelectAll();
            exCon.retrieveEuAccountsWrapperList();
            Test.stopTest();    
        }
    }
}