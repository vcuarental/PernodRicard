@isTest
public with sharing class EUR_DOC_Tests {
    // See testSetup below
    
    @isTest
    public static void testLookups() {
        List<Id> idAllowedSOSL = new List<Id>();
        
        idAllowedSOSL.add(UserInfo.getUserId());
        for(Attachment a : [SELECT ParentId FROM Attachment WHERE Name = 'fake_attachment.txt']) {
            idAllowedSOSL.add(a.ParentId);
        }
        Test.setFixedSearchResults(idAllowedSOSL);
        //EUR_DOC_Tests.runAllCreation();
        
        
        List<EUR_DOC_LookupSearchResult> liste = EUR_DOC_SampleLookupController.searchAccounts('martin', null);
        for(EUR_DOC_LookupSearchResult l : liste) {
            l.getId();
            l.getSObjectType();
            l.getIcon();
            l.getTitle();
            l.getSubtitle();
            l.getOther();
        }
        String userEmail = UserInfo.getUserEmail().split('@')[0];
        EUR_DOC_SampleLookupController.searchUsers(userEmail.split('-')[0], null);
        EUR_DOC_SampleLookupController.searchTaxonomy('Tax', null);
        EUR_DOC_SampleLookupController.searchTerritory('DE TERR', null);
        EUR_DOC_SampleLookupController.searchRegion('DE REG', null);
        

        EUR_DOC_SampleLookupController.searchObjectivePromotion('OP', null);
        EUR_DOC_SampleLookupController.searchPOSM('MAT', null);
        EUR_DOC_SampleLookupController.searchB('Absol', null);
        EUR_DOC_SampleLookupController.searchBQ('Absolut', null);
        EUR_DOC_SampleLookupController.searchBQS('75cl', null);
        EUR_DOC_SampleLookupController.searchSKU('Absolut', null);
        EUR_DOC_SampleLookupController.searchToolkit('Pernod', null);

        Profile pf = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = EUR_Doc_Factory.newUser('user222@user.fr',pf.Id,'DE');
        insert u;
        //User u = [SELECT Id, Profile.Name FROM User WHERE isActive = true AND (NOT Profile.Name LIKE '%admin%') LIMIT 1];
        System.runAs(u) {
            EUR_DOC_SampleLookupController.getCountryCode();
        }
    }

    @isTest
    public static void testSearchOP() {
        //EUR_DOC_Tests.runAllCreation();

        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'OP';
        filters.op = [SELECT Id FROM EUR_CRM_Objectives_Promotions__c LIMIT 1].Id;

        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        
        Map<Id, Attachment> atts = new Map<Id, Attachment>([SELECT id, parentId FROM Attachment]);

        System.assertEquals(1, result.records.size(), 'Wrong total of records');
        System.assertEquals(
            (Id) [SELECT Id FROM EUR_CRM_OP_Visit_Action__c LIMIT 1].Id, 
            atts.get(((EUR_DOC_CompoundObject)result.records[0]).PictureUrl).ParentId , 
            'Wrong record returned'
        );
    }

    @isTest
    public static void testSearchPO() {
        //EUR_DOC_Tests.runAllCreation();

        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'PO';
        filters.account = [SELECT Id FROM EUR_CRM_Account__c LIMIT 1].Id;
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        

        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        System.assertEquals(1, result.records.size(), 'Wrong total of records');
        
        Map<Id, Attachment> atts = new Map<Id, Attachment>([SELECT id, parentId FROM Attachment]);

        EUR_CRM_GB_Objective__c po = [SELECT Id FROM EUR_CRM_GB_Objective__c WHERE EUR_CRM_Account__c = :filters.account];
        
        EUR_DOC_CompoundObject obj = (EUR_DOC_CompoundObject)result.records[0];
        System.assertEquals(po.Id, atts.get(obj.PictureUrl).ParentId, 'Wrong parent');
        
    }

    @isTest
    public static void testSearchPOSM() {
        //EUR_DOC_Tests.runAllCreation();

        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'POSM';
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        filters.posm = [SELECT Id FROM EUR_CRM_POS_Material__c LIMIT 1].Id;

        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        
        System.assertEquals(1, result.records.size(), 'Wrong number of records');
        Map<Id, Attachment> atts = new Map<Id, Attachment>([SELECT id, parentId FROM Attachment]);

        EUR_CRM_POSM_Audit_Item__c posm = [SELECT Id FROM EUR_CRM_POSM_Audit_Item__c WHERE EUR_CRM_POS_Material__c = :filters.posm];
        
        EUR_DOC_CompoundObject obj = (EUR_DOC_CompoundObject)result.records[0];
        System.assertEquals(posm.Id, atts.get(obj.PictureUrl).ParentId, 'Wrong parent');
    }


    @isTest
    public static void testSearchCPTOnbq() {
        //EUR_DOC_Tests.runAllCreation();
        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'CPT'; 
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        filters.bq = [SELECT Id FROM EUR_CRM_Quality__c LIMIT 1].Id;

        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        
        List<EUR_CRM_Competitor_Promo_Tracking_Item__c> items = [SELECT Id, EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality_Size__c, 
        EUR_CRM_Competitor_Promo_Tracking__R.EUR_CRM_Account_Name__r.EUR_CRM_Channel__c FROM EUR_CRM_Competitor_Promo_Tracking_Item__c];

        
        System.debug('------------' + items);
        System.assertEquals(1, result.records.size(), 'Wrong number of records returrned');
        
        EUR_DOC_CompoundObject obj1 = (EUR_DOC_CompoundObject)result.records[0];
        Map<Id, Attachment> atts = new Map<Id, Attachment>([SELECT id, parentId FROM Attachment]);

        
        Integer i=0;
        for(EUR_CRM_Competitor_Promo_Tracking_Item__c item : items) {
            if(item.id == atts.get(obj1.PictureUrl).ParentId) {
                i++;
            }
        }
        System.assertEquals(1, i, 'Wrong number of matches');
    }

    @isTest
    public static void testSearchCPTOnbqs() {
        //EUR_DOC_Tests.runAllCreation();
        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'CPT'; 
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        filters.bqs = [SELECT Id FROM EUR_CRM_Size__c LIMIT 1].Id;

        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        
        List<EUR_CRM_Competitor_Promo_Tracking_Item__c> items = [SELECT Id, EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality_Size__c, 
        EUR_CRM_Competitor_Promo_Tracking__R.EUR_CRM_Account_Name__r.EUR_CRM_Channel__c FROM EUR_CRM_Competitor_Promo_Tracking_Item__c];

        
        System.debug('------------' + items);
        System.assertEquals(1, result.records.size(), 'Wrong number of records returrned');
        
        EUR_DOC_CompoundObject obj1 = (EUR_DOC_CompoundObject)result.records[0];
        Map<Id, Attachment> atts = new Map<Id, Attachment>([SELECT id, parentId FROM Attachment]);

        
        Integer i=0;
        for(EUR_CRM_Competitor_Promo_Tracking_Item__c item : items) {
            if(item.id == atts.get(obj1.PictureUrl).ParentId) {
                i++;
            }
        }
        System.assertEquals(1, i, 'Wrong number of matches');
    }

    @isTest
    public static void testSearchALL() {
        //EUR_DOC_Tests.runAllCreation();

        Group gr = EUR_DOC_Factory.newPublicGroup('EUR_DOC_Sales_Order_Allowed');
        if(gr.Id == null){
            insert gr;
        }        
        GroupMember grm = EUR_DOC_Factory.newGroupMember(gr.id,UserInfo.getUserId());
        if(grm.Id == null){
            insert grm;
        }
        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'ALL';
        filters.isOnTrade = true;
        filters.account = [SELECT Id FROM EUR_CRM_Account__c WHERE EUR_CRM_Channel__c = 'ON TRADE' LIMIT 1].Id;

        System.debug('-------- FILTER ID :' + filters.account);
        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);

        //+9 with the visit action module
        System.assertEquals(6+9, result.records.size(), 'Wrong number of records');
    }

    @isTest
    public static void testSearchNoFilter() {
        //EUR_DOC_Tests.runAllCreation();

        Group gr = EUR_DOC_Factory.newPublicGroup('EUR_DOC_Sales_Order_Allowed');
        if(gr.Id == null){
            insert gr;
        }        
        GroupMember grm = EUR_DOC_Factory.newGroupMember(gr.id,UserInfo.getUserId());
        if(grm.Id == null){
            insert grm;
        }

        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        
        //should be + 9 as well but it is not... weird !! Because only 15 records per page !!
        System.assertEquals(11+4, result.records.size(), 'Wrong number of records');
    }
    @isTest
    public static void testSearchNoFilterPage2() {
        //EUR_DOC_Tests.runAllCreation();

        Group gr = EUR_DOC_Factory.newPublicGroup('EUR_DOC_Sales_Order_Allowed');
        if(gr.Id == null){
            insert gr;
        }        
        GroupMember grm = EUR_DOC_Factory.newGroupMember(gr.id,UserInfo.getUserId());
        if(grm.Id == null){
            insert grm;
        }

        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        EUR_DOC_PagedResult result2 = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 2);
        
        System.assertEquals(7, result2.records.size(), 'Wrong number of records');
    }
    @isTest
    public static void testRussianAndFinland() {
        EUR_DOC_DocServerController.initModulesPicklist();

        System.debug('NUMBER=' + Limits.getAggregateQueries());
        Profile pf = [SELECT Id FROM Profile WHERE Name='Standard User'];
        System.debug('NUMBER=' + Limits.getAggregateQueries());
        User u = EUR_Doc_Factory.newUser('user222@user.fr',pf.Id,'RU');
        insert u;
        System.debug('NUMBER=' + Limits.getAggregateQueries());
        //User u = [SELECT Id FROM User WHERE isActive = true AND EUR_CRM_Country_Code__c LIKE '%RU%' AND (NOT Profile.Name LIKE '%admin%') LIMIT 1];
        System.runAs(u) {
            System.assert(EUR_DOC_DocServerController.checkIfUserIsRussian());
        }

        System.debug('NUMBER=' + Limits.getAggregateQueries());
        User u2 = EUR_Doc_Factory.newUser('user333@user.fr',pf.Id,'FI');
        insert u2;
        System.debug('NUMBER=' + Limits.getAggregateQueries());
        System.runAs(u2) {
            System.assert(EUR_DOC_DocServerController.checkIfUserIsFinland());
        }
        System.debug('NUMBER=' + Limits.getAggregateQueries());
    }
    @isTest
    public static void coverGetPictureBody() {
        List<String> ids = new List<String>();
        for(Attachment a : [SELECT Id FROM Attachment]) {
            ids.add(a.Id);
        }
        EUR_DOC_DocServerController.getPictureBody(ids);
    }
    @isTest
    public static void coverSpecificPartOfTheCode() {
        //EUR_DOC_Tests.runAllCreation();
        

        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();
        filters.user = UserInfo.getUserId();
        filters.isOnTrade = false;
        filters.isOffTrade = true;
        filters.taxonomy = [SELECT Id FROM EUR_CRM_Customer_Taxonomy__c LIMIT 1].Id;
        filters.territory = [SELECT Id FROM EUR_CRM_Territory__c LIMIT 1].Id;
        filters.region = [SELECT Id FROM EUR_CRM_Region__c LIMIT 1].Id;
        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);

        

    }
    @isTest
    public static void testSearchVA_bq() {
        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        
        filters.module = 'VA'; 
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        filters.bq = [SELECT Id FROM EUR_CRM_Quality__c].Id;
        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        System.assertEquals(3, result.records.size(), 'Wrong number of records returned');
    }
    @isTest
    public static void testSearchVA_bqs() {
        //EUR_DOC_Tests.runAllCreation();
        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'VA'; 
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        filters.bqs = [SELECT Id FROM EUR_CRM_Size__c].Id;

        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        System.assertEquals(3, result.records.size(), 'Wrong number of records returned');
    }
    @isTest
    public static void testMenuFeatureNoFilter() {
        //EUR_DOC_Tests.runAllCreation();
        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'MENU'; 
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        
        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        System.assertEquals(2, result.records.size(), 'Wrong number of records returned');
    }
    @isTest
    public static void testMenuFeatureBrand() {
        //EUR_DOC_Tests.runAllCreation();
        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'MENU'; 
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        filters.b = [SELECT Id FROM EUR_CRM_Brand__c LIMIT 1].Id;
        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        System.assertEquals(1, result.records.size(), 'Wrong number of records returned');
    }
    @isTest
    public static void testMenuFeatureBQ() {
        //EUR_DOC_Tests.runAllCreation();
        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'MENU'; 
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        filters.bq = [SELECT Id FROM EUR_CRM_Quality__c LIMIT 1].Id;
        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        System.assertEquals(1, result.records.size(), 'Wrong number of records returned');
    }
    @isTest
    public static void testSearchVA_brand() {
        //EUR_DOC_Tests.runAllCreation();
        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();
        EUR_CRM_Visit_Sub_Action__c[] vsas = [SELECT Id, EUR_CRM_Brand__c, (SELECT Id, Name, CreatedDate, ParentId FROM Attachments) FROM EUR_CRM_Visit_Sub_Action__c];
        System.debug('ATTS');
        for(EUR_CRM_Visit_Sub_Action__c v : vsas) {
            System.debug(v.EUR_CRM_Brand__c);
            for(Attachment a : v.Attachments) {
                System.debug(a.Name + ' ' + a.createdDate + ' ' + a.ParentId);
            }
        }
        filters.module = 'VA'; 
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        filters.b = [SELECT Id FROM EUR_CRM_Brand__c].Id;

        System.debug('Brand ID: ' + filters.b);
        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        System.assertEquals(3, result.records.size(), 'Wrong number of records returned');
    }

    @isTest
    public static void testSearchVA_sku() {
        //EUR_DOC_Tests.runAllCreation();
        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'VA'; 
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        filters.sku = [SELECT Id FROM EUR_CRM_SKU__c].Id;

        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        System.assertEquals(3, result.records.size(), 'Wrong number of records returned');
    }
    @isTest
    public static void testSearchVA_toolkit() {
        //EUR_DOC_Tests.runAllCreation();
        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'VA'; 
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        filters.toolkit = [SELECT Id FROM EUR_CRM_Product_Toolkit__c].Id;

        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);
        System.assertEquals(5, result.records.size(), 'Wrong number of records returned');
    }

    @isTest
    public static void testSearchBS() {
        //EUR_DOC_Tests.runAllCreation();
        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'BS'; 
        filters.isOnTrade = true;
        filters.isOffTrade = true;
        filters.bsbq = '100 PIPERS';

        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);

        System.assertEquals(1, result.records.size(), 'Wrong number of records returned');
    }

    @isTest
    public static void testSearchSO() {
        //EUR_DOC_Tests.runAllCreation();

        Group gr = EUR_DOC_Factory.newPublicGroup('EUR_DOC_Sales_Order_Allowed');
        if(gr.Id == null){
            insert gr;
        }        
        GroupMember grm = EUR_DOC_Factory.newGroupMember(gr.id,UserInfo.getUserId());
        if(grm.Id == null){
            insert grm;
        }
        
        EUR_DOC_DocServerController.Filters filters = getDefaultFilters();

        filters.module = 'SO'; 
        filters.isOnTrade = true;
        filters.isOffTrade = true;

        EUR_DOC_PagedResult result = EUR_DOC_DocServerController.triggerSearch(System.JSON.serialize(filters), 1);

        System.assertEquals(1, result.records.size(), 'Wrong number of records returned');
    }

    static EUR_DOC_DocServerController.Filters getDefaultFilters() {
        EUR_DOC_DocServerController.Filters filters = new EUR_DOC_DocServerController.Filters();
        filters.timestamp = Datetime.now();
        filters.earlierDate = Date.today().addDays(-3);
        filters.laterDate = Date.today().addDays(3);
        filters.account = '';
        filters.user = '';
        filters.taxonomychain = '';
        filters.taxonomy = '';
        filters.territory = '';
        filters.region = '';
        filters.epicenter = false;
        filters.module = 'ALL';
        filters.posm = '';
        filters.opcode = '';
        filters.op = '';
        filters.isOnTrade = true;
        filters.isOffTrade = false;
        filters.isDistributor = false;
        filters.isOther = false;
        filters.b = '';
        filters.bq = '';
        filters.bqs = '';
        filters.bsbq = '';
        filters.sku = '';
        filters.toolkit = '';

        return filters;
    }

    @testSetup static void runAllCreation() 
    {
        

        /*
        * GLOBAL DATA
        */
        EUR_CRM_Visit_Frequency__c visitFreq = EUR_DOC_Factory.newVisitFrequency();
        insert visitFreq;
        
        EUR_CRM_Region__c region = EUR_DOC_Factory.newRegion('DE REGION');
        insert region;
        
        EUR_CRM_Territory__c terr = EUR_DOC_Factory.newTerritory('DE TERRITORY', region.id);
        insert terr;
        
        EUR_CRM_Customer_Taxonomy__c taxo = EUR_DOC_Factory.newTaxonomy('Tax Account 34');
        insert taxo;

        
        EUR_CRM_Account__c accOnTrade = EUR_DOC_Factory.newAccountOnTrade('Martin ON TRADE', visitFreq.Id, terr.id, taxo.id);
        EUR_CRM_Account__c accOffTrade = EUR_DOC_Factory.newAccountOffTrade('Martin OFF TRADE', visitFreq.Id, terr.id, taxo.id);
        insert new List<EUR_CRM_Account__c> {accOnTrade, accOffTrade};
        

        /*
        * PERSONAL OBJECTIVE DATA
        */
        EUR_CRM_GB_Objective__c obj1 = EUR_DOC_Factory.newObjective('Objective 1', accOffTrade.Id);
        EUR_CRM_GB_Objective__c obj2 = EUR_DOC_Factory.newObjective('Objective 2', accOnTrade.Id);
        insert new List<EUR_CRM_GB_Objective__c> {
            obj1,
            obj2
        };
        
        /*
        * OBJECTIVE PROMOTION DATA
        */
        EUR_CRM_Visit__c visit = EUR_DOC_Factory.newVisit(accOnTrade.id);
        insert visit;
        
        EUR_CRM_Objectives_Promotions__c objPromo = EUR_DOC_Factory.newObjectivePromotion('OP 1');
        insert objPromo;
        
        EUR_CRM_Account_in_Promo__c accInPromo = EUR_DOC_Factory.newPromoAccount(accOnTrade.id, objPromo.id, visit.id);
        insert accInPromo;
       
        EUR_CRM_OP_Visit_Action__c OPVisit = EUR_DOC_Factory.newOPVisit(accInPromo.id, visit.id);
        insert OPVisit;
        

        /*
        * Element necessary for POSM/CPT
        */
        EUR_CRM_Wine_Spirits__c wine = EUR_DOC_Factory.newWineAndSpirit('EUR DE Spirits');
        insert wine;
        EUR_CRM_Category__c categVodka = EUR_DOC_Factory.newCategorie('Vodka', wine.id);
        insert categVodka;
        EUR_CRM_Brand__c brand = EUR_DOC_Factory.newBrand('Absolut', categVodka.id);
        insert brand;
        EUR_CRM_Quality__c quality = EUR_DOC_Factory.newQuality('Absolut Citron', brand.id);
        insert quality;
        
        EUR_CRM_Size__c size = EUR_DOC_Factory.newSize('Absolut Citron 75cl', quality.id);
        insert size;
        EUR_CRM_SKU__c sku = EUR_DOC_Factory.newSKU('Absolut Citron 6X75CL', size.id);
        insert sku;

        EUR_CRM_Product_Toolkit__c toolkit = EUR_DOC_Factory.newToolkit('Pernod Ricard Bottle + Glasses');
        insert toolkit;
        /*
        *   FOR CPT
        */
        EUR_CRM_Competitor_Promo_Tracking__c promoTracking1 = EUR_DOC_Factory.newPromoTracking('Promo Tracking 1', accOnTrade.id);
        EUR_CRM_Competitor_Promo_Tracking__c promoTracking2 = EUR_DOC_Factory.newPromoTracking('Promo Tracking 2', accOffTrade.id);
        insert new List<EUR_CRM_Competitor_Promo_Tracking__c> { promoTracking1, promoTracking2 };
        
        EUR_CRM_Competitor_Promo_Tracking_Item__c promoTrackingItem1 = EUR_DOC_Factory.newPromoTrackingItem(promoTracking1.id, quality.id, null);
        EUR_CRM_Competitor_Promo_Tracking_Item__c promoTrackingItem2 = EUR_DOC_Factory.newPromoTrackingItem(promoTracking2.id, null, size.id);
        insert new List<EUR_CRM_Competitor_Promo_Tracking_Item__c> {
            promoTrackingItem1, promoTrackingItem2
        };

        /*
        *   FOR POSM
        */
        EUR_CRM_POS_Material__c mat1 = EUR_DOC_Factory.newMaterial('MAT 1');
        EUR_CRM_POS_Material__c mat2 = EUR_DOC_Factory.newMaterial('MAT 2');
        insert new List<EUR_CRM_POS_Material__c> {mat1, mat2};
        
        EUR_CRM_POSM_Audit__c posm = EUR_DOC_Factory.newPOSMAudit(accOffTrade.id, visit.id);
        insert posm;
        EUR_CRM_POSM_Audit_Item__c posmItem1 = EUR_DOC_Factory.newPOSMAuditItem(posm.id, mat1.id);
        EUR_CRM_POSM_Audit_Item__c posmItem2 = EUR_DOC_Factory.newPOSMAuditItem(posm.id, mat2.id);
        insert new List<EUR_CRM_POSM_Audit_Item__c> {posmItem1, posmItem2};
        
        /*
        *   FOR SA
        */
        
        EUR_CRM_Store_Audit__c audit = EUR_DOC_Factory.newStoreAudit(accOffTrade.id, visit.id);
        insert audit;
        EUR_CRM_Store_Audit_Item__c auditItem1 = EUR_DOC_Factory.newStoreAuditItem(audit.id, accOffTrade.id, size.id, mat1.id);
        EUR_CRM_Store_Audit_Item__c auditItem2 = EUR_DOC_Factory.newStoreAuditItem(audit.id, accOffTrade.id, size.id, mat2.id);
        insert new List<EUR_CRM_Store_Audit_Item__c> {auditItem1, auditItem2};

        /*
        *   FOR BS
        */
        
        EUR_CRM_Brand_Security_Infringement__c bs = EUR_DOC_Factory.newBS(visit.id);
        insert bs;     
        
        /*
        *   FOR SO
        */
        EUR_CRM_Sales_Order__c so = EUR_DOC_Factory.newSO(accOnTrade.id);
        insert so;    
        
        /*For menu feature*/
        EUR_CRM_Menu_Feature__c menu1 = EUR_DOC_Factory.newMenu(accOnTrade.Id);
        EUR_CRM_Menu_Feature__c menu2 = EUR_DOC_Factory.newMenu(accOnTrade.Id);
        

        insert new List<EUR_CRM_Menu_Feature__c> {menu1, menu2};
        EUR_CRM_Menu_Feature_Items__c menuItem1 = EUR_DOC_Factory.newMenuItem(menu1.Id, quality.Id);
        insert menuItem1;
        /*
        * FOR Vist Action
        */
        EUR_CRM_Visit_Action__c vaBQ = EUR_DOC_Factory.newVisitAction(accOnTrade.Id, quality.id, visit.id);
        EUR_CRM_Visit_Action__c vaBQS = EUR_DOC_Factory.newVisitAction(accOnTrade.Id, size.id, visit.id);
        EUR_CRM_Visit_Action__c vaSKU = EUR_DOC_Factory.newVisitAction(accOnTrade.Id, sku.id, visit.id);
        EUR_CRM_Visit_Action__c vaB = EUR_DOC_Factory.newVisitAction(accOnTrade.Id, brand.id, visit.id);
        EUR_CRM_Visit_Action__c vaToolkit = EUR_DOC_Factory.newVisitAction(accOnTrade.Id, toolkit.id, visit.id);
        insert new List<EUR_CRM_Visit_Action__c>{vaBQ, vaBQS, vaSKU, vaToolkit, vaB};
        EUR_CRM_Visit_Sub_Action__c vsaBQ = EUR_DOC_Factory.newVisitSubAction(vaToolkit.Id, quality.Id);
        EUR_CRM_Visit_Sub_Action__c vsaBQS = EUR_DOC_Factory.newVisitSubAction(vaToolkit.Id, size.id);
        EUR_CRM_Visit_Sub_Action__c vsaSKU = EUR_DOC_Factory.newVisitSubAction(vaToolkit.Id, sku.id);
        EUR_CRM_Visit_Sub_Action__c vsaB = EUR_DOC_Factory.newVisitSubAction(vaToolkit.Id, brand.id);
        insert new List<EUR_CRM_Visit_Sub_Action__c> {vsaBQ, vsaBQS, vsaSKU, vsaB};
        /*
        * At the end add all attachments in one shot
        */

        Attachment a1 = EUR_DOC_Factory.newAttachment(accOnTrade.id);
        Attachment a2 = EUR_DOC_Factory.newAttachment(accOffTrade.id);
        insert new List<Attachment> {
            a1,
            a2,

            EUR_DOC_Factory.newAttachment(obj1.id),
            EUR_DOC_Factory.newAttachment(obj2.id),

            EUR_DOC_Factory.newAttachment(OPVisit.id),

            EUR_DOC_Factory.newAttachment(promoTrackingItem1.id),
            EUR_DOC_Factory.newAttachment(promoTrackingItem2.id),

            EUR_DOC_Factory.newAttachment(posmItem1.id),
            EUR_DOC_Factory.newAttachment(posmItem2.id),

            EUR_DOC_Factory.newAttachment(auditItem1.id),
            EUR_DOC_Factory.newAttachment(auditItem2.id),

            EUR_DOC_Factory.newAttachment(bs.id),
            EUR_DOC_Factory.newAttachment(vaBQ.Id),
            EUR_DOC_Factory.newAttachment(vaBQS.Id),
            EUR_DOC_Factory.newAttachment(vaSKU.Id),
            EUR_DOC_Factory.newAttachment(vaB.Id),
            EUR_DOC_Factory.newAttachment(vaToolkit.id),
            EUR_DOC_Factory.newAttachment(vsaBQ.Id),
            EUR_DOC_Factory.newAttachment(vsaBQS.Id),
            EUR_DOC_Factory.newAttachment(vsaSKU.Id),
            EUR_DOC_Factory.newAttachment(vsaB.Id),
            EUR_DOC_Factory.newAttachment(menu1.Id),
            EUR_DOC_Factory.newAttachment(menu2.Id),

            EUR_DOC_Factory.newAttachmentpdf(so.id),
            

            //Bidouille pour récupérer les ID des SOSL rapidement ==> Voir lookup test fonction
            EUR_DOC_Factory.newAttachmentSOSL(region.id),
            EUR_DOC_Factory.newAttachmentSOSL(terr.id),
            EUR_DOC_Factory.newAttachmentSOSL(taxo.id),
            EUR_DOC_Factory.newAttachmentSOSL(accOnTrade.id),
            EUR_DOC_Factory.newAttachmentSOSL(accOffTrade.id),
            EUR_DOC_Factory.newAttachmentSOSL(brand.id),
            EUR_DOC_Factory.newAttachmentSOSL(quality.id),
            EUR_DOC_Factory.newAttachmentSOSL(size.id),
            EUR_DOC_Factory.newAttachmentSOSL(sku.id),
            EUR_DOC_Factory.newAttachmentSOSL(toolkit.id),
            EUR_DOC_Factory.newAttachmentSOSL(mat1.id),
            EUR_DOC_Factory.newAttachmentSOSL(mat2.id),
            EUR_DOC_Factory.newAttachmentSOSL(objPromo.id),
            EUR_DOC_Factory.newAttachmentSOSL(bs.id),
            EUR_DOC_Factory.newAttachmentSOSL(so.id)
        };
        
        //If not all attachment has the same date and we don't cover the is sup/inf 
        Test.setCreatedDate(a1.id, Datetime.now().addDays(-1));
        Test.setCreatedDate(a2.id, Datetime.now().addDays(1));
        
    }

    
}