@isTest
public class EUR_CRM_DE_WholesalerOPMgtPageCtrlTest {
    @testSetUp static void setUpData(){ 
        EUR_CRM_DE_TestClassUtilityHelper.initOffTradeUsers();
        system.runAs(EUR_CRM_DE_TestClassUtilityHelper.offTradeNationalManager){
            //EUR_CRM_DE_TestClassUtilityHelper.initOffTradeDataSet();  
            
            EUR_CRM_Region__c testRegion = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region 1', UserInfo.getUserId(),'DE Region');
            
            EUR_CRM_Territory__c onTradeTerritory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('onTradeTerritory' , UserInfo.getUserId(), testRegion.id, 'DE Territory');
            
            EUR_CRM_Territory__c offTradeTerritory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('offTradeTerritory' , UserInfo.getUserId(), testRegion.id, 'DE Territory');
            EUR_CRM_Postal_Code_Territory_Mapping__c offTradeTerritoryMapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('offTradeTerritoryMapping', '12345' , onTradeTerritory.id, 'DE Off Trade Postal Code - Territory Mapping');
            
            EUR_CRM_Postal_Code_Territory_Mapping__c onTradeTerritoryMapping = EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('offTradeTerritoryMapping', '12345' , onTradeTerritory.id, 'DE On Trade Postal Code - Territory Mapping');
            
            EUR_CRM_Postal_Code_City_Mapping__c postalCodeMapping = New EUR_CRM_Postal_Code_City_Mapping__c(Name = 'CityName', EUR_CRM_Postal_Code__c = '12345',EUR_CRM_City__c = 'CityName', RecordTypeId = [SELECT Id FROM RecordType WHere DeveloperName = 'EUR_DE_Postal_Code_City_Mapping'].id  );
            insert postalCodeMapping;
            //System.debug('### EUR_CRM_DE_WholesalerOPMgtPageCtrlTest SOQL Limits 1:'+Limits.getQueries());
            
            EUR_CRM_Customer_Taxonomy__c custTaxonomy = EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('test taxonomy', UserInfo.getUserId(), 'DE Customer Taxonomy');
            system.assertNotEquals(custTaxonomy, null);
            
            EUR_CRM_Customer_Taxonomy__c custTaxonomy2 = EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('test taxonomy2', UserInfo.getUserId(), 'DE Customer Taxonomy');
            
            //}
            EUR_CRM_DE_TestClassUtilityHelper.creaActionListTemplate('testDE_OFF_ALT_Leaflet_Campaign','DE_OFF_ALT_Leaflet_Campaign' ,EUR_CRM_DE_TestClassUtilityHelper.DE_ACTION_LIST_TEMPLATE_RECORD_TYPE);
            
            EUR_CRM_ObjPromo__c objPromo = EUR_CRM_DE_TestClassUtilityHelper.createObjPromo(1,EUR_CRM_DE_TestClassUtilityHelper.OP_DE_LEAFLET_CAMPAIGN,'test object promo')[0];
            objPromo.EUR_CRM_Status__c = 'Draft';
            insert objPromo;
            //System.debug('### EUR_CRM_DE_WholesalerOPMgtPageCtrlTest SOQL Limits 2:'+Limits.getQueries());
            
            EUR_CRM_SKU__c sku = EUR_CRM_DE_TestClassUtilityHelper.createSKU('test', '23',EUR_CRM_DE_TestClassUtilityHelper.DE_SKU);
            sku.EUR_CRM_Unit_Type__c = 'Display';
            update sku;
            //System.debug('### EUR_CRM_DE_WholesalerOPMgtPageCtrlTest SOQL Limits 3:'+Limits.getQueries());
            
            EUR_CRM_Size__c bqs = EUR_CRM_DE_TestClassUtilityHelper.createSIZE('test',EUR_CRM_DE_TestClassUtilityHelper.DE_SIZE);
            
            List<EUR_CRM_ObjPromo_Target__c> opTargetList = EUR_CRM_DE_TestClassUtilityHelper.createOPTarget(10, 'Objective Volume Target', objPromo.Id, null);
            for (EUR_CRM_ObjPromo_Target__c opTarget:opTargetList){
                opTarget.EUR_CRM_BQS__c = bqs.Id;
                opTarget.EUR_CRM_SKU__c = sku.Id;
            }
            
            insert opTargetList;
        }
        
    }
    
    static testMethod void testSKU(){
        //System.debug('### EUR_CRM_DE_WholesalerOPMgtPageCtrlTest SOQL Limits 4:'+Limits.getQueries());
        EUR_CRM_ObjPromo__c objecPromo = [select Id, Name,EUR_CRM_Status__c, OwnerId from EUR_CRM_ObjPromo__c where Name = 'test object promo'];
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = [select Id,Name from EUR_CRM_Customer_Taxonomy__c where Name ='test taxonomy' limit 1];
        EUR_CRM_SKU__c sku = [select Id, Name from EUR_CRM_SKU__c where Name = 'test'];
        
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c','DE OFF STD');
        
        EUR_CRM_Account__c accountEU = new EUR_CRM_Account__c(
            EUR_CRM_Postal_Code__c = '12345 ',
            recordtypeid=recordtypeId,
            name = 'euAccount1 ',
            EUR_JB_Customer_Taxonomy__c =customerTaxonomy.Id,
            EUR_CRM_Status_of_Customer__c = 'Agency Managed', EUR_CRM_Owner_Role_API_Name__c = 'EMEA'
        );
        insert accountEU;
        //System.debug('### EUR_CRM_DE_WholesalerOPMgtPageCtrlTest SOQL Limits 5:'+Limits.getQueries());
        
        Id cusTaxRtId = Global_RecordTypeCache.getRtId('EUR_CRM_OP_Customer_Taxonomy_Mapping__c'+ 'EUR_DE_OP_Customer_Taxonomy_Mapping');
        List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> cusTaxList = new  List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c>(); 
        
        EUR_CRM_OP_Customer_Taxonomy_Mapping__c customerTaxonomyMap = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c
            (recordtypeid=cusTaxRtId,
             EUR_CRM_Customer_Taxonomy__c=customerTaxonomy.Id,
             EUR_CRM_ObjPromo__c = objecPromo.Id
            );
        
        insert customerTaxonomyMap;
        //System.debug('### EUR_CRM_DE_WholesalerOPMgtPageCtrlTest SOQL Limits 6:'+Limits.getQueries());
        
        List<EUR_CRM_ObjPromo_Target__c> opTargetList = [select Id, name,EUR_CRM_SKU__c, EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c,EUR_CRM_SKU__r.EUR_CRM_Number_of_Bottles__c,EUR_CRM_Qty_Sell_in_Amount_Bottle__c,EUR_CRM_Qty_Sell_in_Amount_Display__c from EUR_CRM_ObjPromo_Target__c];
        
        
        Test.startTest();
        
        PageReference aPage = Page.EUR_CRM_DE_WholesalerOPMgtPage;
        aPage.getParameters().put('p1',sku.Id);
        aPage.getParameters().put('rowIndex','0');
        test.setCurrentPage(aPage);
        Apexpages.StandardController sc = new Apexpages.StandardController(objecPromo);
        EUR_CRM_DE_WholesalerOPMgtPageCtrl con = new EUR_CRM_DE_WholesalerOPMgtPageCtrl(sc);
        con.getIsSelectByBQS();
        con.getIsSelectBySKU();
        con.getRegionalManagerOptions();
        con.add();
        con.removeSKU();
        con.getRegionalTargetWraps();
        con.getSalesAgencyTargetWraps();
        con.getSRTargetWraps();
        con.getRegionalAndSalesAgencyTargetWraps();
        con.getSalesRepAndSalesAgencyTargetWraps();
        con.srTargets = opTargetList;
        con.save();
        
        Boolean testIsNational = con.isNational;
        Boolean testIsRegional = con.isRegional;
        Boolean testIsKAM = con.isKAM;
        
        Test.stopTest();
    }
    
    
    static testMethod void testBQS(){
        EUR_CRM_ObjPromo__c objecPromo = [select Id, Name,EUR_CRM_Status__c, OwnerId from EUR_CRM_ObjPromo__c where Name = 'test object promo'];
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = [select Id,Name from EUR_CRM_Customer_Taxonomy__c where Name ='test taxonomy' limit 1];
        EUR_CRM_Size__c bqs = [select Id, Name from EUR_CRM_Size__c where Name = 'test'];
        
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c','DE OFF STD');
        
        EUR_CRM_Account__c accountEU = new EUR_CRM_Account__c(
            EUR_CRM_Postal_Code__c = '12345 ',
            recordtypeid=recordtypeId,
            name = 'euAccount1 ',
            EUR_JB_Customer_Taxonomy__c =customerTaxonomy.Id,
            EUR_CRM_Status_of_Customer__c = 'Agency Managed',EUR_CRM_Owner_Role_API_Name__c = 'EMEA'
        );
        insert accountEU;
        
        Id cusTaxRtId = Global_RecordTypeCache.getRtId('EUR_CRM_OP_Customer_Taxonomy_Mapping__c'+ 'EUR_DE_OP_Customer_Taxonomy_Mapping');
        List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c> cusTaxList = new  List<EUR_CRM_OP_Customer_Taxonomy_Mapping__c>(); 
        
        EUR_CRM_OP_Customer_Taxonomy_Mapping__c customerTaxonomyMap = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c
            (recordtypeid=cusTaxRtId,
             EUR_CRM_Customer_Taxonomy__c=customerTaxonomy.Id,
             EUR_CRM_ObjPromo__c = objecPromo.Id
            );
        
        insert customerTaxonomyMap;
        
        
        Test.startTest();
        
        PageReference aPage = Page.EUR_CRM_DE_WholesalerOPMgtPage;
        aPage.getParameters().put('p1',bqs.Id);
        aPage.getParameters().put('rowIndex','0');
        test.setCurrentPage(aPage);
        Apexpages.StandardController sc = new Apexpages.StandardController(objecPromo);
        EUR_CRM_DE_WholesalerOPMgtPageCtrl con = new EUR_CRM_DE_WholesalerOPMgtPageCtrl(sc);
        con.add();
        con.removeSKU();
        con.getRegionalTargetWraps();
        con.getSRTargetWraps();
        con.getRegionalAndSalesAgencyTargetWraps();
        con.getSalesRepAndSalesAgencyTargetWraps();
        //con.srTargets = opTargetList;
        con.save();
        
        Test.stopTest();
    }
    
}