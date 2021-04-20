@isTest
public class EUR_CRM_DE_TestObjectivePromoPageCtrl{
    @isTest
    public static void testAll(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive_SKU_Bottles' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_2nd_PL_Carton' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Trade_Fair' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_ON_ALT_ON_PROS_TMKT_Promos' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            
            List<EUR_CRM_ObjPromo__c> ops = new List<EUR_CRM_ObjPromo__c>();

            EUR_CRM_ObjPromo__c salesDriveOP = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,'DE Off Trade Sales Drive SKU Bottles','test')[0];
            salesDriveOP.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            ops.add(salesDriveOP);
            //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            EUR_CRM_ObjPromo__c secondaryOP = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SECONDARY_PLACEMENT_CARTON ,'test')[0];
            secondaryOP.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
          //  objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
           ops.add(secondaryOP);
            EUR_CRM_ObjPromo__c tradefairOP = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_TRADE_FAIR ,'test')[0];
            tradefairOP.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            ops.add(tradefairOP);

            insert ops;
            List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> mappings = new List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c>();
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custmap1 = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custmap1.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy1.id;
            custmap1.EUR_CRM_ObjPromo__c = salesDriveOP.id;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custmap2 = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custmap2.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy1.id;
            custmap2.EUR_CRM_ObjPromo__c = secondaryOP.id;
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custmap3 = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custmap3.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy1.id;
            custmap3.EUR_CRM_ObjPromo__c = tradefairOP.id;
            mappings.add(custmap3);mappings.add(custmap2);mappings.add(custmap1);
            insert mappings;

            List<EUR_CRM_ObjPromo_Target__c> targets = new List<EUR_CRM_ObjPromo_Target__c>();
            EUR_CRM_ObjPromo_Target__c salesDriveTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'Objective Volume Target', salesDriveOP.Id, null)[0];
            salesDriveTarget.EUR_CRM_SKU__c = EUR_CRM_DE_TestClassUtilityHelper.sku.id;
            salesDriveTarget.EUR_CRM_SKU__r  = EUR_CRM_DE_TestClassUtilityHelper.sku; 

            EUR_CRM_ObjPromo_Target__c secondaryTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'Objective Volume Target', secondaryOP.Id, null)[0];
            salesDriveTarget.EUR_CRM_BQS__c = EUR_CRM_DE_TestClassUtilityHelper.bqs.id;
            salesDriveTarget.EUR_CRM_BQS__r  = EUR_CRM_DE_TestClassUtilityHelper.bqs;

            EUR_CRM_ObjPromo_Target__c tradefairTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(1, 'Objective Volume Target', tradefairOP.Id, null)[0];
            salesDriveTarget.EUR_CRM_BQS__c = EUR_CRM_DE_TestClassUtilityHelper.bqs.id;
            salesDriveTarget.EUR_CRM_BQS__r  = EUR_CRM_DE_TestClassUtilityHelper.bqs;

            targets.add(salesDriveTarget);targets.add(secondaryTarget);targets.add(tradefairTarget);
            insert targets;
            
              EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_ON_TRADE_PROS_TMKT_PROMO,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
           objPromo.EUR_CRM_PROS_Image_Level__c = 'Iconic';
            objPromo.EUR_CRM_PROS_Group_Outlet__c = 'Restaurant';
            insert objPromo;
            
              
             objPromo = [select RecordType.developername,EUR_CRM_PROS_Group_Outlet__c,
             EUR_CRM_Status__c,//EUR_CRM_Customer_Taxonomy__c,    
              EUR_CRM_PROS_Image_Level__c, ownerid,
             EUR_CRM_Region__c, EUR_CRM_Territory__c, EUR_CRM_Type__c,
             id from EUR_CRM_ObjPromo__c where id= : objPromo.id];
             
               salesDriveOP = [select id,EUR_CRM_Status__c, ownerid,RecordType.Developername, EUR_CRM_OP_Action_List_Template__c, EUR_CRM_ObjPromo_OnTrade_Variation__c
            from EUR_CRM_ObjPromo__c  where id =: salesDriveOP.id];
          
            Test.startTest();   
            //sales drive 
            PageReference aPage = Page.EUR_CRM_DE_ObjectivePromoPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(salesDriveOP);
            EUR_CRM_ObjectivePromoPageController exCon = new EUR_CRM_ObjectivePromoPageController(sc);
            //secondary
            Apexpages.StandardController sc2 = new Apexpages.standardController(secondaryOP);
            EUR_CRM_ObjectivePromoPageController exCon2 = new EUR_CRM_ObjectivePromoPageController(sc2);
            //tradefair
            Apexpages.StandardController sc3 = new Apexpages.standardController(tradefairOP);
            EUR_CRM_ObjectivePromoPageController exCon3 = new EUR_CRM_ObjectivePromoPageController(sc3);

            exCon.getActions(); 
            exCon.editTargets();
            exCon.saveTarget();
            exCon.cancel();
            exCon.getVariationDetails();
            exCon2.initBQS();
            exCon2.redirect();
            exCon3.initTradeFairTargets();
            exCon2.initSecondaryTargets();
            
            //PROS
            
          
             //Apexpages.StandardController sc4 = new Apexpages.standardController(objPromo );
            //EUR_CRM_ObjectivePromoPageController exCon4 = new EUR_CRM_ObjectivePromoPageController(sc4);
            Test.stopTest();   

        }
    }
    /*
    @isTest
    public static void testSalesDrive(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            

            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            
            insert objPromo;
               Test.startTest();           
            // START TEST ---
            objPromo = [select id,EUR_CRM_Status__c, ownerid,RecordType.Developername, EUR_CRM_OP_Action_List_Template__c, EUR_CRM_ObjPromo_OnTrade_Variation__c
            from EUR_CRM_ObjPromo__c  where id =: objPromo.id];
            PageReference aPage = Page.EUR_CRM_DE_ObjectivePromoPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_ObjectivePromoPageController exCon = new EUR_CRM_ObjectivePromoPageController(sc);
            exCon.getVariationDetails();
            system.assert(exCon.redirect() == null);
            system.assert(exCon.getActions()  != null);
            // STOP TEST ---            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testSecondaryTargets(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_2nd_PL_Carton' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SECONDARY_PLACEMENT_CARTON ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
          //  objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            
            insert objPromo;
               Test.startTest();           
            // START TEST ---
            objPromo = [select id, EUR_CRM_Status__c,ownerid, RecordType.Developername, EUR_CRM_OP_Action_List_Template__c, EUR_CRM_ObjPromo_OnTrade_Variation__c
            from EUR_CRM_ObjPromo__c  where id =: objPromo.id];
            PageReference aPage = Page.EUR_CRM_DE_ObjectivePromoPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_ObjectivePromoPageController exCon = new EUR_CRM_ObjectivePromoPageController(sc);
            
            system.assert(exCon.redirect() == null);
            system.assert(exCon.getActions()  != null);
            // STOP TEST ---            
            Test.stopTest();
        }
    }
     
    @isTest
    public static void testLeafletCampaign(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();            
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_LEAFLET_CAMPAIGN,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
          //  objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
               Test.startTest();           
            // START TEST ---
            objPromo = [select id, EUR_CRM_Status__c,ownerid,RecordType.Developername, EUR_CRM_OP_Action_List_Template__c, EUR_CRM_ObjPromo_OnTrade_Variation__c
            from EUR_CRM_ObjPromo__c  where id =: objPromo.id];
            
            PageReference aPage = Page.EUR_CRM_DE_ObjectivePromoPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_ObjectivePromoPageController exCon = new EUR_CRM_ObjectivePromoPageController(sc);
            
            system.assert(exCon.redirect() == null);
            system.assert(exCon.getActions()  != null);
            // STOP TEST ---            
            Test.stopTest();
        }
    }
   
    @isTest
    public static void testTradeFair(){
        EUR_CRM_DE_TestClassUtilityHelper.initUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.regionalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initData();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Trade_Fair' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
                   
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_TRADE_FAIR ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.newInstance(2014, 07,02);
            //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
               Test.startTest();           
            // START TEST ---
            objPromo = [select id, EUR_CRM_Status__c,ownerid, RecordType.Developername, EUR_CRM_OP_Action_List_Template__c, EUR_CRM_ObjPromo_OnTrade_Variation__c
            from EUR_CRM_ObjPromo__c  where id =: objPromo.id];
            PageReference aPage = Page.EUR_CRM_DE_ObjectivePromoPage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_ObjectivePromoPageController exCon = new EUR_CRM_ObjectivePromoPageController(sc);
            
            system.assert(exCon.redirect() == null);
            system.assert(exCon.getActions()  != null);    
            
            // STOP TEST ---            
            Test.stopTest();
        }
        }
    
   */
}