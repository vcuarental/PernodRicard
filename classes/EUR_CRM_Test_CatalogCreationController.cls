/* Test class for check catalog creation
 * logic
 * 
 */
@isTest
private class EUR_CRM_Test_CatalogCreationController {
    // region that the testing will be performed for
    
    // !! must have product mapping metadata setup properly  (EUR_CRM_CTM_Product_Catalog_Level__mdt)
    // !! must have product record types setup properly
    
    // will influence testing user region and product record types
    private static final String TEST_REGION     = 'NL';
    
    private static final String DIRECT_CAT_RT   = EUR_CRM_CatalogCreationService.CATALOG_DIRECT_RT_DEV_NAME;
    private static final String INDIRECT_CAT_RT = EUR_CRM_CatalogCreationService.CATALOG_INDIRECT_RT_DEV_NAME;
    private static final String POSM_CAT_RT     = EUR_CRM_CatalogCreationService.CATALOG_POSM_RT_DEV_NAME;
    
    private static final String SKU_REGION_RT   = 'EUR_'+TEST_REGION+'_SKU';
    private static final String POSM_REGION_RT  = 'EUR_'+TEST_REGION+'_POS_Material';
    private static final String BQS_REGION_RT   = 'EUR_'+TEST_REGION+'_Size';

    /* ========================================================
     *                  TEST DATA CREATION
     * 
     * ========================================================*/
    private static final Map<String,Map<String,Map<String,Map<String,String>>>> PROD_HIERCH = new Map<String,Map<String,Map<String,Map<String,String>>>> {
        'CHIVAS' => new Map<String,Map<String,Map<String,String>>>{
            '25Y' => new Map<String,Map<String,String>>{
                '0,5' => new Map<String,String>{'S' => 'S','N' => 'N'}
                ,'0,7' => new Map<String,String>{'S' => 'S','N' => 'N'}
            }
            ,'10Y' => new Map<String,Map<String,String>>{
                '0,5' => new Map<String,String>{'S' => 'S','N' => 'N'}
                ,'0,7' => new Map<String,String>{'S' => 'S','N' => 'N'}
            }
        }
        ,'JAMESON' => new Map<String,Map<String,Map<String,String>>>{
            '25Y' => new Map<String,Map<String,String>>{
                '0,5' => new Map<String,String>{'S' => 'S','N' => 'N'}
                ,'0,7' => new Map<String,String>{'S' => 'S','N' => 'N'}
            }
            ,'10Y' => new Map<String,Map<String,String>>{
                '0,5' => new Map<String,String>{'S' => 'S','N' => 'N'}
                ,'0,7' => new Map<String,String>{'S' => 'S','N' => 'N'}
            }
        }
        ,'GLENMORANGIE' => new Map<String,Map<String,Map<String,String>>>{
            '25Y' => new Map<String,Map<String,String>>{
                '0,5' => new Map<String,String>{'S' => 'S','N' => 'N'}
                ,'0,7' => new Map<String,String>{'S' => 'S','N' => 'N'}
            }
            ,'10Y' => new Map<String,Map<String,String>>{
                '0,5' => new Map<String,String>{'S' => 'S','N' => 'N'}
                ,'0,7' => new Map<String,String>{'S' => 'S','N' => 'N'}
            }
        }
    };
    /* Insert user for proper region
     * 
     * @return user - sysadmin user in proper region
     */
    private static User initUser() {
        // pull standard sys admin profile
        List<Profile> sysAdmins = new List<Profile>([SELECT Id FROM Profile WHERE Name = 'System Administrator' ORDER BY CreatedDate ASC LIMIT 1]);
        //User tester = new User(EUR_CRM_Country_Code__c = TEST_REGION);
        // TODO: check region setting
        User tester = new User();
        if(!sysAdmins.isEmpty()){
            tester.ProfileId = sysAdmins[0].Id;
        }
        tester = (User)EUR_CRM_TestDataFactory.createsObject(tester,false); // is inserted when running system.runAs
        return tester;
    }
    /* Insert test data, including product hierarchy structure
     * 
     * @param catRecType - record type of the catalog to insert
     */
    private static void init(String catRecType) {
        // DIRECT / INDIRECT : EUR_CRM_Brand__c => EUR_CRM_Quality__c => EUR_CRM_Size__c => EUR_CRM_SKU__c
        // POSM              : EUR_CRM_Brand__c => EUR_CRM_POS_Material__c
        List<RecordType> rts;
        if(!String.isEmpty(catRecType)){
            rts = new List<RecordType>([SELECT Id,Name FROM RecordType WHERE sObjectType = 'EUR_CRM_ProductCatalog__c' AND DeveloperName =:catRecType ]);
        }
        // sku rt for region
        List<RecordType> skuRegs = new List<RecordType>([SELECT Id FROM RecordType WHERE sObjectType='EUR_CRM_SKU__c' AND DeveloperName = :SKU_REGION_RT LIMIT 1]);
        // bqs rt for region
        List<RecordType> bqsRegs = new List<RecordType>([SELECT Id FROM RecordType WHERE sObjectType='EUR_CRM_Size__c' AND DeveloperName = :BQS_REGION_RT LIMIT 1]);
        // posm rt for region
        List<RecordType> posmRegs = new List<RecordType>([SELECT Id FROM RecordType WHERE sObjectType='EUR_CRM_POS_Material__c' AND DeveloperName = :POSM_REGION_RT LIMIT 1]);
        
        // build product structure
        ProductHierarchyTier top = new ProductHierarchyTier();
        ProductHierarchy node = new ProductHierarchy(null,null,null);
        top.sibs.add(node);

        for(String bName : PROD_HIERCH.keySet()){
            ProductHierarchy b = new ProductHierarchy(EUR_CRM_Brand__c.sObjectType,bName,(Schema.sObjectField)null);
            node.chlds.add(b);
            top.nextTier.sibs.add(b);
            
            for(String bqName : PROD_HIERCH.get(bName).keySet()){
                ProductHierarchy bq = new ProductHierarchy(EUR_CRM_Quality__c.sObjectType,bqName,EUR_CRM_Quality__c.EUR_CRM_Brand__c);
                b.chlds.add(bq);
                top.nextTier.nextTier.sibs.add(bq);
                
                for(String bqsName : PROD_HIERCH.get(bName).get(bqName).keySet()){
                    ProductHierarchy bqs = new ProductHierarchy(EUR_CRM_Size__c.sObjectType,bqsName,EUR_CRM_Size__c.EUR_CRM_Brand_Quality__c,bqsRegs[0].Id);
                    bq.chlds.add(bqs);
                    top.nextTier.nextTier.nextTier.sibs.add(bqs);
                    
                    for(String skuName : PROD_HIERCH.get(bName).get(bqName).get(bqsName).keySet()){
                        ProductHierarchy sku = new ProductHierarchy(EUR_CRM_SKU__c.sObjectType,skuName,EUR_CRM_SKU__c.EUR_CRM_Brand_Quality_Size__c,skuRegs[0].Id);
                        bqs.chlds.add(sku);
                        top.nextTier.nextTier.nextTier.nextTier.sibs.add(sku);
                    }
                }
            }
            
            for(String bqName : PROD_HIERCH.get(bName).keySet()){
                // add posms, separate iteration to reduce chunking
                ProductHierarchy posm = new ProductHierarchy(EUR_CRM_POS_Material__c.sObjectType,bqName,EUR_CRM_POS_Material__c.EUR_CRM_Brand__c,posmRegs[0].Id);
                b.chlds.add(posm);
                top.nextTier.sibs.add(posm);
            }
        }
        // insert product hierarchy
        top.doInsertChildTier();
        // insert standard pb
        EUR_CRM_ProductCatalog__c sCat = new EUR_CRM_ProductCatalog__c(
            Name = 'Standard Test Catalog'
            ,EUR_CRM_IsStandard__c = true
            ,EUR_CRM_IsManual__c = true
            ,EUR_CRM_Country__c = EUR_CRM_CatalogCreationService.CURRENT_USER_CC
        );
        
        /*
        if(rts != null && !rts.isEmpty()){
            sCat.RecordTypeId = rts[0].Id;
        }
        */
        sCat = (EUR_CRM_ProductCatalog__c)EUR_CRM_TestDataFactory.createSObject(sCat,true);
        
        List<EUR_CRM_SKU__c> skuPs = new List<EUR_CRM_SKU__c>([SELECT Id FROM EUR_CRM_SKU__c]);
        System.debug('\n skuPs.size() => ' + skuPs.size() + '\n');
        System.debug('\n skuPs => ' + JSON.serializePretty(skuPs) + '\n');
        // insert direct order standard catalog items       
        List<EUR_CRM_ProductCatalogItem__c> stdPcis = new List<EUR_CRM_ProductCatalogItem__c>();

        for(EUR_CRM_SKU__c skuP :skuPs){
            EUR_CRM_ProductCatalogItem__c pci = new EUR_CRM_ProductCatalogItem__c(EUR_CRM_PriceBookID__c = sCat.Id);
/* TODO: REMOVE COMMENT
            pci.EUR_CRM_EndDate__c = System.today().addYears(100);
            pci.EUR_CRM_StartDate__c = System.today().addDays(-2);
*/
            pci.EUR_CRM_SKU__c = skuP.Id;
            pci = (EUR_CRM_ProductCatalogItem__c)EUR_CRM_TestDataFactory.createSObject(pci,false);
            stdPcis.add(pci);
        }
        if(!stdPcis.isEmpty()){
            insert stdPcis;
        }
        
        //Account acc = (Account) EUR_CRM_TestDataFactory.createSObject(new Account(),true);
        EUR_CRM_Account__c acc = (EUR_CRM_Account__c)EUR_CRM_TestDataFactory.createSObject(new EUR_CRM_Account__c(),true);
        EUR_CRM_Account_Target_Group__c ag = (EUR_CRM_Account_Target_Group__c) EUR_CRM_TestDataFactory.createSObject(            
            new EUR_CRM_Account_Target_Group__c()
            ,true
        );
        //EUR_CRM_Account_in_Target_Group__c
        EUR_CRM_Account_in_Target_Group__c atg = (EUR_CRM_Account_in_Target_Group__c) EUR_CRM_TestDataFactory.createSObject(
             new EUR_CRM_Account_in_Target_Group__c( EUR_CRM_Account_Target_Group__c = ag.Id, EUR_CRM_Account__c = acc.Id)
            ,true
        );
    }
    /* ========================================================
     *                  TEST CASES
     * 
     * ========================================================*/
    @IsTest
    private static void getCatalogHeaderInfo() {
        Map<String, String> catalogHeaderInfo = EUR_CRM_CatalogCreationCmpController.getCatalogHeaderInfo();
        System.assert(catalogHeaderInfo.containsKey('catalogObjectLabel'));
        System.assert(catalogHeaderInfo.containsKey('catalogIconName'));
    }
    @IsTest
    private static void getProductListDirect() {

        System.runAs(initUser()){
            EUR_CRM_CatalogCreationService.CURRENT_USER_CC = TEST_REGION; // inject correct region
            init('');
            System.Test.startTest();
            
            List<EUR_CRM_CatalogCreationService.ProductWrapper> records = (List<EUR_CRM_CatalogCreationService.ProductWrapper>)System.JSON.deserialize(
                 EUR_CRM_CatalogCreationCmpController.getProductList(DIRECT_CAT_RT)
                 ,List<EUR_CRM_CatalogCreationService.ProductWrapper>.class
             );
            System.debug(records);
            System.Test.stopTest();
            System.assertNotEquals(true, records.isEmpty());
        }
        
    }
    @IsTest
    private static void getProductListIndirect() {

        System.runAs(initUser()){
            EUR_CRM_CatalogCreationService.CURRENT_USER_CC = TEST_REGION; // inject correct region
            init('');
            System.Test.startTest();
            
            List<EUR_CRM_CatalogCreationService.ProductWrapper> records = (List<EUR_CRM_CatalogCreationService.ProductWrapper>)System.JSON.deserialize(
                 EUR_CRM_CatalogCreationCmpController.getProductList(INDIRECT_CAT_RT)
                 ,List<EUR_CRM_CatalogCreationService.ProductWrapper>.class
             );
            System.debug(records);
            System.Test.stopTest();
            System.assertNotEquals(true, records.isEmpty());
        }
        
    }
    @IsTest
    private static void getProductListPOSM() {

        System.runAs(initUser()){
            EUR_CRM_CatalogCreationService.CURRENT_USER_CC = TEST_REGION; // inject correct region
            init('');
            System.Test.startTest();
            
            List<EUR_CRM_CatalogCreationService.ProductWrapper> records = (List<EUR_CRM_CatalogCreationService.ProductWrapper>)System.JSON.deserialize(
                 EUR_CRM_CatalogCreationCmpController.getProductList(POSM_CAT_RT)
                 ,List<EUR_CRM_CatalogCreationService.ProductWrapper>.class
             );
            
            System.Test.stopTest();
            System.assertNotEquals(true, records.isEmpty());
        }
        
    }
    @IsTest
    private static void getProductListBadRegion() {

        System.runAs(initUser()){
            EUR_CRM_CatalogCreationService.CURRENT_USER_CC = 'Doesnt exist'; // inject incorrect region
            //init('');
            System.Test.startTest();
            try{
                List<EUR_CRM_CatalogCreationService.ProductWrapper> records = (List<EUR_CRM_CatalogCreationService.ProductWrapper>)System.JSON.deserialize(
                    EUR_CRM_CatalogCreationCmpController.getProductList(POSM_CAT_RT)
                    ,List<EUR_CRM_CatalogCreationService.ProductWrapper>.class
                );
                System.assert(false,'Should throw exception, should not reach here');
            } catch(AuraHandledException ex){
                System.assert(true,'Should throw exception');
            }
            
            System.Test.stopTest();
        }
        
    }
    @IsTest
    private static void getOrderTypesDirect() {

        System.runAs(initUser()){
            EUR_CRM_CatalogCreationService.CURRENT_USER_CC = TEST_REGION; // inject correct region
            init('');
            System.Test.startTest();
            
            List<RecordType> rts = new List<RecordType>([SELECT Id,Name FROM RecordType WHERE sObjectType = 'EUR_CRM_ProductCatalog__c' AND DeveloperName =:DIRECT_CAT_RT ]);
            List<EUR_CRM_CatalogCreationCmpController.SelectOption> sos = EUR_CRM_CatalogCreationCmpController.getOrderTypes(rts[0].Id);
            EUR_CRM_CatalogCreationCmpController.SelectOption tuple = EUR_CRM_CatalogCreationCmpController.getRecTypeDevName(rts[0].Id);
            System.Test.stopTest();
            System.assertNotEquals(true, sos.isEmpty());
            System.assertEquals(DIRECT_CAT_RT, tuple.label,'Record type name should be the same');
        }
        
    }
    @IsTest
    private static void getCatalogFieldLabels() {
        Map<String, Map<String,String>> lbls = EUR_CRM_CatalogCreationCmpController.getCatalogFieldLabels();
        System.assert(!lbls.keySet().isEmpty(),'Should return labels for catalog and pbis');
    }
    
    @IsTest
    private static void saveCatalog() {
        Id metaUser = UserInfo.getUserId();
        System.runAs(initUser()){
            EUR_CRM_CatalogCreationService.CURRENT_USER_CC = TEST_REGION; // inject correct region
            init('');
            System.Test.startTest();
            
            EUR_CRM_ProductCatalog__c sCat = [SELECT Id FROM EUR_CRM_ProductCatalog__c WHERE EUR_CRM_IsStandard__c = true LIMIT 1];
            
            List<RecordType> rts = new List<RecordType>([SELECT Id,Name,DeveloperName FROM RecordType WHERE sObjectType = 'EUR_CRM_ProductCatalog__c' AND DeveloperName =:DIRECT_CAT_RT ]);
            List<EUR_CRM_CatalogCreationCmpController.SelectOption> sos = EUR_CRM_CatalogCreationCmpController.getOrderTypes(rts[0].Id);
            
            List<EUR_CRM_CatalogCreationService.ProductWrapper> prods = (List<EUR_CRM_CatalogCreationService.ProductWrapper>)System.JSON.deserialize(
                EUR_CRM_CatalogCreationCmpController.getProductList(DIRECT_CAT_RT)
                ,List<EUR_CRM_CatalogCreationService.ProductWrapper>.class
            );
            
            List<EUR_CRM_Account_Target_Group__c> ags = new List<EUR_CRM_Account_Target_Group__c>([SELECT Id FROM EUR_CRM_Account_Target_Group__c LIMIT 1]);
            
            EUR_CRM_CatalogCreationService.HierarchyBuilderWrapper catalogInfo = new EUR_CRM_CatalogCreationService.HierarchyBuilderWrapper();
            catalogInfo.catalogName = 'TestDirect';
            catalogInfo.groupId = ags[0].Id;
            //catalogInfo.groupInfo = new EUR_CRM_CatalogCreationService.AccountGroupInfoWrapper();
            //catalogInfo.groupInfo.groupId = groups[0].Id;
            catalogInfo.catalogOrderType = sos[0].value;
            catalogInfo.catalogReturnReason = null;
            catalogInfo.startDate = new String[] {'2020','1','1'};
            catalogInfo.endDate = new String[] {'2025','1','1'};
            catalogInfo.isDynamic = false;
            catalogInfo.availableForAll = false;
            catalogInfo.viewName1 = 'Test1';
            catalogInfo.viewName2 = 'Test2';
            catalogInfo.toConfigureItems = true;
            catalogInfo.sharing = new List<EUR_CRM_ProductCatalog__Share>();
            catalogInfo.sharing.add(new EUR_CRM_ProductCatalog__Share(  // share to meta user
                    AccessLevel = 'read',
                    RowCause = 'Manual',
                    UserOrGroupId = metaUser
            ));

            catalogInfo.productsInfo = new List<EUR_CRM_CatalogCreationService.ProductHierarchyInfoWrapper>();
            EUR_CRM_CatalogCreationService.ProductHierarchyInfoWrapper productData = new EUR_CRM_CatalogCreationService.ProductHierarchyInfoWrapper();
            
            productData.OrderView1 = '0';
            productData.multiplication_factor = '1';
            productData.View1Level1 = 'View Branch 1';
            productData.View1Level2 = null;
            productData.View1Level3 = null;
            productData.View1Level4 = null;
            productData.productId = prods[0].productId;
            productData.OrderView2 = '1';
            productData.View2Level1 = 'View Branch 2';
            productData.View2Level2 = null;
            productData.View2Level3 = null;
            productData.View2Level4 = null;
            productData.productId = prods[0].productId;
            catalogInfo.productsInfo.add(productData);
            
            // imitate aura input
            String catalogJSONInput = JSON.serialize(catalogInfo);
            
            // run save method in controller
            String msg = EUR_CRM_CatalogCreationCmpController.saveCatalog(catalogJSONInput);
            
            List<EUR_CRM_ProductCatalog__c> cats = new List<EUR_CRM_ProductCatalog__c>([
                SELECT Id
                       , Name
                       , EUR_CRM_OrderType__c
                       , EUR_CRM_IsStandard__c
                       , EUR_CRM_ParentProductCatalogID__c
                       , EUR_CRM_ValidFrom__c
                       , EUR_CRM_ValidTo__c
                       , EUR_CRM_ViewName1__c
                       , EUR_CRM_ViewName2__c
                       , EUR_CRM_AccountGroupId__c
                       , EUR_CRM_Country__c
               FROM EUR_CRM_ProductCatalog__c
               WHERE Name = 'TestDirect'
            ]);
            
            System.assertNotEquals(true,cats.isEmpty(),'New catalog should have been created');
            System.assertEquals(sCat.Id,cats[0].EUR_CRM_ParentProductCatalogID__c,'Should reference standard catalog');
            
            catalogInfo.catalogId = cats[0].Id;
            catalogInfo.catalogRecTypeDName = DIRECT_CAT_RT;
            catalogInfo.viewName2 = null;
            // imitate aura input
            catalogJSONInput = JSON.serialize(catalogInfo);
            // update catalog
            msg = EUR_CRM_CatalogCreationCmpController.saveCatalog(catalogJSONInput);
            
            System.Test.stopTest();

            
            List<EUR_CRM_ProductCatalogItem__c> pbis = new List<EUR_CRM_ProductCatalogItem__c>([
               SELECT Id
                      , Name
              FROM EUR_CRM_ProductCatalogItem__c
              WHERE EUR_CRM_PriceBookID__c = :cats[0].Id
           ]);
            
            System.assertNotEquals(true,pbis.isEmpty(),'PBIs should have been created');
            System.assertEquals(1,pbis.size(),'Single pbi containing data for both views should have been created');
            EUR_CRM_CatalogCreationService.updateSharedRecords(sCat.Id);
        }
    }
    
    @IsTest
    private static void getCatalogData() {
        System.runAs(initUser()){
            EUR_CRM_CatalogCreationService.CURRENT_USER_CC = TEST_REGION; // inject correct region
            init('');
            
            // insert standard pb
            Id rtId = Schema.SObjectType.EUR_CRM_ProductCatalog__c.getRecordTypeInfosByDeveloperName().get('EUR_Direct').getRecordTypeId();
            EUR_CRM_ProductCatalog__c cat = new EUR_CRM_ProductCatalog__c(
                Name = 'Test Catalog'
                ,EUR_CRM_IsStandard__c = false
                ,EUR_CRM_Country__c = EUR_CRM_CatalogCreationService.CURRENT_USER_CC
                ,EUR_CRM_ValidTo__c = System.today().addDays(5)
                ,EUR_CRM_ValidFrom__c = System.today().addDays(-2)
                ,RecordTypeId = rtId
            );
            
            cat = (EUR_CRM_ProductCatalog__c)EUR_CRM_TestDataFactory.createSObject(cat,true);
            
            List<EUR_CRM_SKU__c> skuPs = new List<EUR_CRM_SKU__c>([SELECT Id FROM EUR_CRM_SKU__c]);
            
            // insert direct order standard catalog items       
            List<EUR_CRM_ProductCatalogItem__c> pcis = new List<EUR_CRM_ProductCatalogItem__c>();
            for(EUR_CRM_SKU__c skuP :skuPs){
                EUR_CRM_ProductCatalogItem__c pci = new EUR_CRM_ProductCatalogItem__c(EUR_CRM_PriceBookID__c = cat.Id);
/* TODO: Remove comment
                pci.EUR_CRM_EndDate__c = System.today().addYears(100);
                pci.EUR_CRM_StartDate__c = System.today().addDays(-2);
*/
                pci.EUR_CRM_SKU__c = skuP.Id;
                pci = (EUR_CRM_ProductCatalogItem__c)EUR_CRM_TestDataFactory.createSObject(pci,false);
                pcis.add(pci);
            }
            System.debug('\n pcis.size() => ' + pcis.size() + '\n');
            System.debug('\n pcis => ' + JSON.serializePretty(pcis) + '\n');
            if(!pcis.isEmpty()){
                insert pcis;
            }
            System.Test.startTest();
            EUR_CRM_CatalogCreationService.HierarchyBuilderWrapper info = (EUR_CRM_CatalogCreationService.HierarchyBuilderWrapper)JSON.deserialize(
                    EUR_CRM_CatalogCreationCmpController.getCatalogData(cat.Id,null) ,EUR_CRM_CatalogCreationService.HierarchyBuilderWrapper.class
            );
            
            
            
            System.Test.stopTest();
            System.assertEquals(cat.Name, info.catalogName,'Should be same catalog');
            System.assertEquals(skuPs.size(), info.productsInfo.size(), 'Should contain all products');
        }
     }


    /* ========================================================
     *                  INNER CLASSES
     * 
     * ========================================================*/
    /* Class to represent a grouping of products into a
     * tier in the product hierarchy
     * 
     */
    private class ProductHierarchyTier {
        // siblings ob this tier
        public List<ProductHierarchy> sibs = new List<ProductHierarchy>();
        /* Property to contain reference to next tier node
         * 
         */
        public ProductHierarchyTier nextTier {
            public get {
                if(this.nextTier == null){
                    this.nextTier = new ProductHierarchyTier();
                }
                return this.nextTier;
            }
            private set;
        }
        /* Method to insert
         * children of this tier 
         * (assumed there is an abstract root tier)
         */
        public void doInsertChildTier(){
            
            List<sObject> toInsert = new List<sObject>();
            
            for(ProductHierarchy ph :sibs){
                
                List<sObject> chlds = ph.getChildren();
                //System.debug('Processing '+chlds);
                if(chlds != null){
                    toInsert.addAll(chlds);
                }
            }
            if(!toInsert.isEmpty()){
                insert toInsert;
            }
            if(nextTier != null && !nextTier.sibs.isEmpty()){
                nextTier.doInsertChildTier();
            }
        }
    }
    /* Class to represent an object in the product hierarchy
     * 
     */
    private class ProductHierarchy {
        public Schema.sObjectType sot;
        public Schema.sObjectField lkup;
        // this object
        public sObject so;
        
        public List<ProductHierarchy> chlds = new List<ProductHierarchy>();
        
        /* Method allows to inser all children of this product node
         * Deprecated for grouping by tier to avoid excessive DML operations
         * 
         */
        public void doInsertChildren(){
            List<sObject> chldrn = this.getChildren();
            if(chldrn != null && !chldrn.isEmpty()){
                insert chldrn;
                
                for(ProductHierarchy chld : this.chlds){
                    chld.doInsertChildren();
                }
            }
        }

        /* Method forms valid list of children with populated lookups
         * to parent
         * 
         */
        private List<sObject> getChildren(){
            if(this.chlds.isEmpty()){
                return null;
            } else {
                List<sObject> chldrn = new List<sObject>();
                for(ProductHierarchy pht :chlds){
                    //sObject temp = pht.so.clone(false,true,false,false);
                    sObject temp = pht.so;
                    if(pht.lkup != null && this.so != null && this.so.Id != null){
                        temp.put(pht.lkup,this.so.Id);
                    }
                    chldrn.add(temp);
                }
                return chldrn;
            }
            
        }
        public ProductHierarchy(Schema.sObjectType sot, String name, Schema.sObjectField lkup){
            this(sot,name,lkup,null);
        }
        public ProductHierarchy(Schema.sObjectType sot, String name, Schema.sObjectField lkup,Id rtId){
            this.sot = sot;
            this.lkup = lkup;
            if(sot != null){
                this.so = sot.newSObject();
                so.put('Name',name);
                this.so = EUR_CRM_TestDataFactory.createSObject(so,false);
                if(rtId != null){
                    this.so.put('RecordTypeId',rtId);
                }
            }
        }
    }
}