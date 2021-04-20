@isTest
public class EUR_CRM_DE_TestPublishObjectivePageCtrlr{

    static testMethod void testOffTrade(){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsersLite();
        
            system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSetLite();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Leaflet_Campaign' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
         /*
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_SALES_DRIVE,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
            //objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            objPromo.EUR_CRM_CustomerTaxonomy_Chain__c = 'All';
             
            
                
                
            try {
				insert objPromo; 
            } catch(DmlException e) {
				
                for(integer i = 0; i < e.getNumDML(); i++){
                  system.debug('***** The matching fields: ' + e.getDmlFieldNames(i));
                  system.debug('***** The error message ' + e.getDMLMessage(i));
                }
                
                throw e ;
            }*/
                
                       
            EUR_CRM_ObjPromo__c leafletOP = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,'DE Off Trade Leaflet Campaign' ,'test')[0];
            leafletOP.EUR_CRM_Active_Start_Date__c = Date.today();
            insert leafletOP;
                        
            //EUR_DE_Objective_Volume_Target
            EUR_CRM_ObjPromo_Target__c salesDriveTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(2, 'EUR_DE_Objective_Volume_Target', leafletOP.Id, null)[0];
            //EUR_CRM_ObjPromo_Target__c salesDriveTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(2, 'Objective Volume Target', leafletOP.Id, null)[0];
            salesDriveTarget.EUR_CRM_BQS__c = EUR_CRM_DE_TestClassUtilityHelper.bqs.id;
            salesDriveTarget.EUR_CRM_BQS__r  = EUR_CRM_DE_TestClassUtilityHelper.bqs; 
            insert salesDriveTarget; 
            
            System.Debug('@@@salesDriveTarget:'+ salesDriveTarget);
                
            EUR_CRM_ObjPromo_Target__c salesDriveRegionalTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(2, 'EUR_DE_Regional_Volume_Target', leafletOP.Id, salesDriveTarget.id)[0];
            //EUR_CRM_ObjPromo_Target__c salesDriveRegionalTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(2, 'Regional Volume Target', leafletOP.Id, salesDriveTarget.id)[0];
            salesDriveTarget.EUR_CRM_BQS__c = EUR_CRM_DE_TestClassUtilityHelper.bqs.id;
            salesDriveTarget.EUR_CRM_BQS__r  = EUR_CRM_DE_TestClassUtilityHelper.bqs; 
            insert salesDriveRegionalTarget;
            System.Debug('@@@salesDriveRegionalTarget:'+ salesDriveRegionalTarget);
            
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy1.id;
            custTax.EUR_CRM_ObjPromo__c = leafletOP.id;
            insert custTax ;

                
            List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> mappings = new List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c>();
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custmap = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custmap.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy1.id;
            custmap.EUR_CRM_ObjPromo__c = leafletOP.id; 
            mappings.add(custmap); 
            insert mappings;
            
            Test.startTest();           
                
            EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount1.EUR_JB_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy1.id;
            update EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount1;
                
            // START TEST ---
			PageReference aPage = Page.EUR_CRM_PublishObjectivePage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(leafletOP);
            EUR_CRM_PublishObjectivePageController exCon = new EUR_CRM_PublishObjectivePageController(sc);
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
            Boolean e = exCon.isReady;
            // STOP TEST ---            
            Test.stopTest();
        }
    }
    
    static testMethod void testTradeFair(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsersLite();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSetLite();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Trade_Fair' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            
            Test.startTest();  
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_TRADE_FAIR ,'test')[0];
            
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today(); 
            System.Debug('@@Before Insert Obj Promo:'+objPromo);
            insert objPromo;
            System.Debug('@@After Insert Obj Promo:'+objPromo);
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy1.id;
            custTax.EUR_CRM_ObjPromo__c = objPromo.id;
            insert custTax ;
            
              
            EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount1.EUR_CRM_Is_Trade_Fair_Location__c = true;
            update EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount1;
            
            
            //Test.startTest();           
            // START TEST ---
            PageReference aPage = Page.EUR_CRM_PublishObjectivePage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_PublishObjectivePageController exCon = new EUR_CRM_PublishObjectivePageController(sc);
            exCon.euAccounts.get(0).isSelected = true;
            Test.stopTest();
            exCon.publish();
            exCon.unPublish();
            exCon.cancel();
            // STOP TEST ---            
            //Test.stopTest();           
            
        }
    }  
    
    
     static testMethod void testTasting(){
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsersLite();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSetLite();  
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Tasting' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
            
            Test.startTest();  
            
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_TASTING_CAMPAIGN ,'test')[0];
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today();
            objPromo.EUR_CRM_Active_End_Date__c = Date.today().addDays(10);
           // objPromo.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy.id;
            insert objPromo;
                         
            objPromo = [select RecordType.developername,EUR_CRM_PROS_Group_Outlet__c,
            EUR_CRM_Status__c,//EUR_CRM_Customer_Taxonomy__c,  
            EUR_CRM_PROS_Image_Level__c,
           	EUR_CRM_Region__c, EUR_CRM_Territory__c, EUR_CRM_Type__c,
            id from EUR_CRM_ObjPromo__c where id= : objPromo.id];
            
            PageReference aPage = Page.EUR_CRM_PublishObjectivePage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(objPromo);
            EUR_CRM_PublishObjectivePageController exCon = new EUR_CRM_PublishObjectivePageController(sc);
            //exCon.euAccounts.get(0).isSelected = true;
            Test.stopTest();
            
            excon.retrievePreparationDate();
            exCon.publish();
            exCon.unPublish();
            exCon.cancel();

        }
    }   
    
    
        static testMethod void testOffTradeSalesDrive(){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsersLite();
        
            system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSetLite();  
            EUR_CRM_OP_Action_List_Template__c ActionListTemp = EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('test323','DE_OFF_ALT_Sales_Drive_SKU_Bottles' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
                
            List<EUR_CRM_ObjPromo_Action__c>OpActionList = EUR_CRM_DE_TestClassUtilityHelper.createPromoAction(2,'EUR_DK_OFF_OP_Action',ActionListTemp.Id);
            insert OpActionList;

			system.debug('@@@OpActionList:' + ActionListTemp);
                
            EUR_CRM_ObjPromo__c leafletOP = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(
            1,'EUR_DE_Off_Trade_Sales_Drive_SKU_Bottles' ,'test')[0];
            leafletOP.EUR_CRM_Active_Start_Date__c = Date.today();
            leafletOp.EUR_CRM_OP_Action_List_Template__c = ActionListTemp.Id;
            insert leafletOP;
                        
            //EUR_DE_Objective_Volume_Target
            EUR_CRM_ObjPromo_Target__c salesDriveTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(2, 'EUR_DE_Objective_Volume_Target', leafletOP.Id, null)[0];
            //EUR_CRM_ObjPromo_Target__c salesDriveTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(2, 'Objective Volume Target', leafletOP.Id, null)[0];
            salesDriveTarget.EUR_CRM_SKU__c = EUR_CRM_DE_TestClassUtilityHelper.sku.id;
            salesDriveTarget.EUR_CRM_SKU__r  = EUR_CRM_DE_TestClassUtilityHelper.sku; 
            insert salesDriveTarget; 
            
            System.Debug('@@@salesDriveTarget:'+ salesDriveTarget);
                
            EUR_CRM_ObjPromo_Target__c salesDriveRegionalTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(2, 'EUR_DE_Regional_Volume_Target', leafletOP.Id, salesDriveTarget.id)[0];
            //EUR_CRM_ObjPromo_Target__c salesDriveRegionalTarget = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(2, 'Regional Volume Target', leafletOP.Id, salesDriveTarget.id)[0];
            salesDriveTarget.EUR_CRM_SKU__c = EUR_CRM_DE_TestClassUtilityHelper.sku.id;
            salesDriveTarget.EUR_CRM_SKU__r  = EUR_CRM_DE_TestClassUtilityHelper.sku; 
            insert salesDriveRegionalTarget;
            System.Debug('@@@salesDriveRegionalTarget:'+ salesDriveRegionalTarget);
            
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custTax = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custTax.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy1.id;
            custTax.EUR_CRM_ObjPromo__c = leafletOP.id;
            insert custTax ;
                
            List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> mappings = new List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c>();
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custmap = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custmap.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy1.id;
            custmap.EUR_CRM_ObjPromo__c = leafletOP.id; 
            mappings.add(custmap); 
            insert mappings;
            
            Test.startTest();           
                
            EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount1.EUR_JB_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.customerTaxonomy1.id;
            update EUR_CRM_DE_TestClassUtilityHelper.offTradeAccount1;
                
            // START TEST ---
			PageReference aPage = Page.EUR_CRM_PublishObjectivePage;
            test.setCurrentPage(aPage);
            Apexpages.StandardController sc = new Apexpages.standardController(leafletOP);
            EUR_CRM_PublishObjectivePageController exCon = new EUR_CRM_PublishObjectivePageController(sc);
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
            Boolean e = exCon.isReady;
            // STOP TEST ---            
            Test.stopTest();
        }
    }
    
    
    
    
     public static testmethod void testPROSObjPromoPageController() {
        EUR_CRM_DE_TestClassUtilityHelper.initUsersOntradeLite();
        
        
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.onTradeNationalUser){
            EUR_CRM_DE_TestClassUtilityHelper.initOnTradeDataSetLite();
            EUR_CRM_ObjPromo_OnTrade_Variation__c objPromoOnTradeVariation = EUR_CRM_DE_TestClassUtilityHelper.createPromoVariation(1, 'EUR_DE_ObjPromo_Promo_Variation', 'Testing')[0];
            insert objPromoOnTradeVariation;
             
            Id actionListTemplateRecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_OP_Action_List_Template__c', 'EUR_DE_OP_Action_List_Template');
            
            EUR_CRM_OP_Action_List_Template__c actionListTemplate = new EUR_CRM_OP_Action_List_Template__c();
            actionListTemplate.RecordTypeId = actionListTemplateRecordTypeId;
            actionListTemplate.Name = 'Testing';
            actionListTemplate.EUR_CRM_External_ID__c = 'DE_ON_ALT_ON_PROS_TMKT_Promos';
            insert actionListTemplate;
            
            EUR_CRM_ObjPromo__c objPromo1 = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(1, '', 'Testing')[0];
            objPromo1.RecordTypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo__c', 'EUR_DE_OnTrade_PROS_TMKT_Promo');
            objPromo1.EUR_CRM_OP_Action_List_Template__c = actionListTemplate.Id;
            objPromo1.EUR_CRM_PROS_Group_Outlet__c = 'Restaurant';
            objPromo1.EUR_CRM_PROS_Image_Level__c = 'Iconic';
            objPromo1.EUR_CRM_ObjPromo_OnTrade_Variation__c = objPromoOnTradeVariation.Id;
            objPromo1.EUR_CRM_Region__c = 'On Trade Prestige Region';
            objPromo1.EUR_CRM_Territory__c = 'On Trade Territory 9';
            List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();
            objPromoList.add(objPromo1);
            //objPromoList.add(objPromo2);
            insert objPromoList;
            objPromo1.RecordType = new RecordType(Id=objPromo1.RecordTypeId, Developername = 'EUR_DE_OnTrade_PROS_TMKT_Promo');
            
             
            List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> mappings = new List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c>();
            EUR_CRM_OP_Customer_Taxonomy_Mapping__c custmap = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
            custmap.EUR_CRM_Customer_Taxonomy__c = EUR_CRM_DE_TestClassUtilityHelper.ontrdcustomerTaxonomy.id;
            custmap.EUR_CRM_ObjPromo__c = objPromo1.id; 
            mappings.add(custmap); 
            insert mappings;
    

            
            Test.startTest();
                ApexPages.StandardController stdController = new ApexPages.StandardController(objPromo1);
                EUR_CRM_ObjectivePromoPageController controller = new EUR_CRM_ObjectivePromoPageController(stdController);
                controller.verifyMissingTargetInit();
                EUR_CRM_ObjectivePromoPageController.ProductUser testing = new EUR_CRM_ObjectivePromoPageController.ProductUser();
                User u = testing.targetOwner;
                EUR_CRM_SKU__c sku = testing.sku;
                EUR_CRM_Size__c size = testing.bqs;
                controller.getVariationDetails();
                controller.getActions();
                controller.redirect();
                controller.editTargets();
                controller.saveTarget();
                controller.saveObjPromoDetail();
                controller.cancel();
            
                PageReference aPage = Page.EUR_CRM_PublishObjectivePage;
                test.setCurrentPage(aPage);
                Apexpages.StandardController sc = new Apexpages.standardController(objPromo1);
                EUR_CRM_PublishObjectivePageController exCon = new EUR_CRM_PublishObjectivePageController(sc);
                exCon.verifyMissingTargets(objPromo1.id,false, EUR_CRM_OPTargetHelperClass.retrieveCustomerTaxonomySet(objPromo1.id));
                exCon.selectAll();
                exCon.deSelectAll();
                exCon.getHasSelectedAccounts();
                exCon.doSelectItem();
                exCon.doDeselectItem();
                exCon.getRecordSize();
                exCon.getPageSize();
                Integer i = exCon.pageNumber;
                exCon.getTotalPages();
                exCon.getPageNumber();
                exCon.getHasNext();
                exCon.getHasPrevious();
                exCon.first();
                exCon.last();
                exCon.doPrevious();
                exCon.doNext();
                exCon.publish();
         
       		Test.stopTest();
         }
    }
}