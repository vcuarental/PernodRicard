/**
 * Created by Andrii Leshchuk on 01.03.2019.
 */
@isTest
public with sharing class EUR_CRM_ProductCatalogServiceForTests {

    public static final String STANDARD_CATALOG_EXTERNAL_ID = '1234';

    public static final String DIRECT_CATALOG_RECORD_TYPE_NAME = 'Direct';
    public static final String INDIRECT_CATALOG_RECORD_TYPE_NAME = 'Indirect';
    public static final String POSM_CATALOG_RECORD_TYPE_NAME = 'POSM';

    private static final String TEST_REGION = 'NL';

    private static final String STANDARD_CATALOG_RECORD_TYPE_NAME = 'Direct';

    private static final String SKU_REGION_RT = 'EUR_' + TEST_REGION + '_SKU';
    private static final String POSM_REGION_RT = 'EUR_' + TEST_REGION + '_POS_Material';
    private static final String BQS_REGION_RT = 'EUR_' + TEST_REGION + '_Size';

    private Map<String, Id> productCatalogRecordTypeMap;

    public EUR_CRM_ProductCatalogServiceForTests() {
        this.initProductCatalogRecordTypeMap();
    }

    private static final Map<String, Map<String, Map<String, Map<String, String>>>> PROD_HIERCH = new Map<String, Map<String, Map<String, Map<String, String>>>>{
            'CHIVAS' => new Map<String, Map<String, Map<String, String>>>{
                    '25Y' => new Map<String, Map<String, String>>{
                            '0,5' => new Map<String, String>{
                                    'S' => 'S', 'N' => 'N'
                            }
                            , '0,7' => new Map<String, String>{
                                    'S' => 'S', 'N' => 'N'
                            }
                    }
                    , '10Y' => new Map<String, Map<String, String>>{
                            '0,5' => new Map<String, String>{
                                    'S' => 'S', 'N' => 'N'
                            }
                            , '0,7' => new Map<String, String>{
                                    'S' => 'S', 'N' => 'N'
                            }
                    }
            }
            , 'JAMESON' => new Map<String, Map<String, Map<String, String>>>{
                    '25Y' => new Map<String, Map<String, String>>{
                            '0,5' => new Map<String, String>{
                                    'S' => 'S', 'N' => 'N'
                            }
                            , '0,7' => new Map<String, String>{
                                    'S' => 'S', 'N' => 'N'
                            }
                    }
                    , '10Y' => new Map<String, Map<String, String>>{
                            '0,5' => new Map<String, String>{
                                    'S' => 'S', 'N' => 'N'
                            }
                            , '0,7' => new Map<String, String>{
                                    'S' => 'S', 'N' => 'N'
                            }
                    }
            }
            , 'GLENMORANGIE' => new Map<String, Map<String, Map<String, String>>>{
                    '25Y' => new Map<String, Map<String, String>>{
                            '0,5' => new Map<String, String>{
                                    'S' => 'S', 'N' => 'N'
                            }
                            , '0,7' => new Map<String, String>{
                                    'S' => 'S', 'N' => 'N'
                            }
                    }
                    , '10Y' => new Map<String, Map<String, String>>{
                            '0,5' => new Map<String, String>{
                                    'S' => 'S', 'N' => 'N'
                            }
                            , '0,7' => new Map<String, String>{
                                    'S' => 'S', 'N' => 'N'
                            }
                    }
            }
    };

    /* Insert user for proper region
     *
     * @return user - sysadmin user in proper region
     */

    public static User initUser() {
        // pull standard sys admin profile
        List<Profile> sysAdmins = new List<Profile>([SELECT Id FROM Profile WHERE Name = 'System Administrator' ORDER BY CreatedDate ASC LIMIT 1]);
        //User tester = new User(EUR_CRM_Country_Code__c = TEST_REGION);
        // TODO: check region setting
        User tester = new User();
        if (!sysAdmins.isEmpty()) {
            tester.ProfileId = sysAdmins[0].Id;
        }
        EUR_CRM_CatalogCreationService.CURRENT_USER_CC = TEST_REGION;
        tester = (User) EUR_CRM_TestDataFactory.createsObject(tester, false); // is inserted when running system.runAs
        return tester;
    }

    /* Insert product hierarchy structure */

    public static void initProducts() {
        List<RecordType> skuRegs = new List<RecordType>([SELECT Id FROM RecordType WHERE sObjectType='EUR_CRM_SKU__c' AND DeveloperName = :SKU_REGION_RT LIMIT 1]);
        // bqs rt for region
        List<RecordType> bqsRegs = new List<RecordType>([SELECT Id FROM RecordType WHERE sObjectType='EUR_CRM_Size__c' AND DeveloperName = :BQS_REGION_RT LIMIT 1]);
        // posm rt for region
        List<RecordType> posmRegs = new List<RecordType>([SELECT Id FROM RecordType WHERE sObjectType='EUR_CRM_POS_Material__c' AND DeveloperName = :POSM_REGION_RT LIMIT 1]);

        ProductHierarchyTier top = new ProductHierarchyTier();
        ProductHierarchy node = new ProductHierarchy(null, null, null);
        top.sibs.add(node);

        for (String bName : PROD_HIERCH.keySet()) {
            ProductHierarchy b = new ProductHierarchy(EUR_CRM_Brand__c.sObjectType, bName, (Schema.sObjectField) null);
            node.chlds.add(b);
            top.nextTier.sibs.add(b);

            for (String bqName : PROD_HIERCH.get(bName).keySet()) {
                ProductHierarchy bq = new ProductHierarchy(EUR_CRM_Quality__c.sObjectType, bqName, EUR_CRM_Quality__c.EUR_CRM_Brand__c);
                b.chlds.add(bq);
                top.nextTier.nextTier.sibs.add(bq);

                for (String bqsName : PROD_HIERCH.get(bName).get(bqName).keySet()) {
                    ProductHierarchy bqs = new ProductHierarchy(EUR_CRM_Size__c.sObjectType, bqsName, EUR_CRM_Size__c.EUR_CRM_Brand_Quality__c, bqsRegs[0].Id);
                    bq.chlds.add(bqs);
                    top.nextTier.nextTier.nextTier.sibs.add(bqs);

                    for (String skuName : PROD_HIERCH.get(bName).get(bqName).get(bqsName).keySet()) {
                        ProductHierarchy sku = new ProductHierarchy(EUR_CRM_SKU__c.sObjectType, skuName, EUR_CRM_SKU__c.EUR_CRM_Brand_Quality_Size__c, skuRegs[0].Id);
                        bqs.chlds.add(sku);
                        top.nextTier.nextTier.nextTier.nextTier.sibs.add(sku);
                    }
                }
            }

            for (String bqName : PROD_HIERCH.get(bName).keySet()) {
                // add posms, separate iteration to reduce chunking
                ProductHierarchy posm = new ProductHierarchy(EUR_CRM_POS_Material__c.sObjectType, bqName, EUR_CRM_POS_Material__c.EUR_CRM_Brand__c, posmRegs[0].Id);
                b.chlds.add(posm);
                top.nextTier.sibs.add(posm);
            }
        }
        // insert product hierarchy
        top.doInsertChildTier();
    }

    public EUR_CRM_ProductCatalog__c createStandardCatalog(Boolean isInsert) {
        EUR_CRM_ProductCatalog__c sCat = new EUR_CRM_ProductCatalog__c(
                Name = 'Standard Test Catalog'
                , EUR_CRM_IsStandard__c = true
                , EUR_CRM_IsManual__c = true
                , RecordTypeId = this.productCatalogRecordTypeMap.get(STANDARD_CATALOG_RECORD_TYPE_NAME)
                , EUR_CRM_Country__c = EUR_CRM_CatalogCreationService.CURRENT_USER_CC
                , EUR_CRM_ValidTo__c = System.today().addDays(5)
                , EUR_CRM_ValidFrom__c = System.today().addDays(-2)
        );
        return (EUR_CRM_ProductCatalog__c) EUR_CRM_TestDataFactory.createSObject(sCat, isInsert);
    }

    public EUR_CRM_ProductCatalog__c generateCatalog(EUR_CRM_ProductCatalog__c parentCatalog, String name, String catalogRecordTypeName) {
        String parentCatalogId;
        if (parentCatalog != null) {
            parentCatalogId = parentCatalog.Id;
        }
        return new EUR_CRM_ProductCatalog__c(
                Name = name
                , RecordTypeId = this.productCatalogRecordTypeMap.get(catalogRecordTypeName)
                , EUR_CRM_ParentProductCatalogID__c = parentCatalogId
                , EUR_CRM_Country__c = EUR_CRM_CatalogCreationService.CURRENT_USER_CC
        );
    }

    public EUR_CRM_ProductCatalogItem__c generateProductCatalogItem(EUR_CRM_ProductCatalog__c productCatalog, EUR_CRM_SKU__c sku) {
        return new EUR_CRM_ProductCatalogItem__c(EUR_CRM_PriceBookID__c = productCatalog.Id
                /* TODO: REMOVE COMMENT
                      ,EUR_CRM_EndDate__c = System.today().addYears(100)
                      ,EUR_CRM_StartDate__c = System.today().addDays(-2)
                */
                , EUR_CRM_SKU__c = sku.Id
        );
    }


    private class ProductHierarchyTier {
        // siblings ob this tier
        public List<ProductHierarchy> sibs = new List<ProductHierarchy>();
        /* Property to contain reference to next tier node
         *
         */
        public ProductHierarchyTier nextTier {
            public get {
                if (this.nextTier == null) {
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
        public void doInsertChildTier() {

            List<sObject> toInsert = new List<sObject>();

            for (ProductHierarchy ph : sibs) {

                List<sObject> chlds = ph.getChildren();
                //System.debug('Processing '+chlds);
                if (chlds != null) {
                    toInsert.addAll(chlds);
                }
            }
            if (!toInsert.isEmpty()) {
                insert toInsert;
            }
            if (nextTier != null && !nextTier.sibs.isEmpty()) {
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
        public void doInsertChildren() {
            List<sObject> chldrn = this.getChildren();
            if (chldrn != null && !chldrn.isEmpty()) {
                insert chldrn;

                for (ProductHierarchy chld : this.chlds) {
                    chld.doInsertChildren();
                }
            }
        }

        /* Method forms valid list of children with populated lookups
         * to parent
         *
         */
        private List<sObject> getChildren() {
            if (this.chlds.isEmpty()) {
                return null;
            } else {
                List<sObject> chldrn = new List<sObject>();
                for (ProductHierarchy pht : chlds) {
                    //sObject temp = pht.so.clone(false,true,false,false);
                    sObject temp = pht.so;
                    if (pht.lkup != null && this.so != null && this.so.Id != null) {
                        temp.put(pht.lkup, this.so.Id);
                    }
                    chldrn.add(temp);
                }
                return chldrn;
            }

        }
        public ProductHierarchy(Schema.sObjectType sot, String name, Schema.sObjectField lkup) {
            this(sot, name, lkup, null);
        }
        public ProductHierarchy(Schema.sObjectType sot, String name, Schema.sObjectField lkup, Id rtId) {
            this.sot = sot;
            this.lkup = lkup;
            if (sot != null) {
                this.so = sot.newSObject();
                so.put('Name', name);
                this.so = EUR_CRM_TestDataFactory.createSObject(so, false);
                if (rtId != null) {
                    this.so.put('RecordTypeId', rtId);
                }
            }
        }
    }

    private void initProductCatalogRecordTypeMap() {
        this.productCatalogRecordTypeMap = new Map<String, Id>();

        Map<String, Schema.RecordTypeInfo> recordTypeInfoByNameMap = Schema.SObjectType.EUR_CRM_ProductCatalog__c.getRecordTypeInfosByName();

        this.putPairByRecordTypeName(recordTypeInfoByNameMap, 'Direct');
        this.putPairByRecordTypeName(recordTypeInfoByNameMap, 'Indirect');
        this.putPairByRecordTypeName(recordTypeInfoByNameMap, 'POSM');
    }

    private void putPairByRecordTypeName(Map<String, Schema.RecordTypeInfo> recordTypeInfoByNameMap, String recordTypeName) {
        Id recordTypeId = recordTypeInfoByNameMap.get(recordTypeName).getRecordTypeId();
        this.productCatalogRecordTypeMap.put(recordTypeName, recordTypeId);
    }
}