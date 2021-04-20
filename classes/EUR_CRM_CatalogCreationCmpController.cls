/* Controller class for catalog generator
 * Used for wrapping queried data for products, catalog and its pbis.
 * 
 * 
 * @version 1.0
 */
public with sharing class EUR_CRM_CatalogCreationCmpController {

    @AuraEnabled
    public static Map<String, String> getCatalogHeaderInfo() {
        Map<String, String> catalogHeaderInfo = new Map<String, String>();
        catalogHeaderInfo.put('catalogObjectLabel', SObjectType.EUR_CRM_ProductCatalog__c.getLabel());
        // put default icon
        catalogHeaderInfo.put('catalogIconName', 'custom1');
        for(Schema.DescribeTabSetResult tsr : Schema.describeTabs()) {
            if(tsr.isSelected()) {
                for(Schema.DescribeTabResult tabResult : tsr.getTabs()) {
                    for(Schema.DescribeIconResult iconResult : tabResult.getIcons()) {
                        String iconUrl = iconResult.getUrl();
                        if(iconUrl.endsWith('.svg') && tabResult.getSobjectName() == 'EUR_CRM_ProductCatalog__c'){
                            catalogHeaderInfo.put('catalogIconName', iconUrl.substringAfterLast('/').substringBefore('.svg'));
                            break;
                        }
                    }
                }
                break;
            }
        }
        return catalogHeaderInfo;
    }

    /* Method to form a map of labels
     * for necessary objects
     * 
     */

    @AuraEnabled
    public static Map<String, Map<String,String>> getCatalogFieldLabels() {
        Map<String, Map<String,String>> toReturn = new Map<String, Map<String,String>>();
        Set<Schema.sObjectType> toFetchLbls = new Set<Schema.sObjectType>{EUR_CRM_ProductCatalog__c.sObjectType,EUR_CRM_ProductCatalogItem__c.sObjectType};
        
        
        for(Schema.sObjectType sot :toFetchLbls){
            if(!toReturn.containsKey(String.valueOf(sot))){
                toReturn.put(String.valueOf(sot),new Map<String,String>());
            }
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(String.valueOf(sot)).getDescribe().fields.getMap();

            Map<String,String> fldLbls = toReturn.get(String.valueOf(sot));
            
            for(Schema.SObjectField sfield : fieldMap.Values()) {
                Schema.DescribeFieldResult dfield = sfield.getDescribe();
                fldLbls.put(dfield.getName(), dfield.getlabel());
            }
        }
        
        return toReturn;
    }
    
    @AuraEnabled
    public static List<EUR_CRM_ProductCatalog__Share> getCloneSharing(Id parentId) {
        return String.isNotEmpty(parentId)
                ? Database.query(EUR_CRM_ManualSharingLightningController.getShareRecordsQuery(parentId))
                : new List<EUR_CRM_ProductCatalog__Share>();
    }
    
    /* Reworked method to pull different product objects depending on
     * catalog record type
     * Passed in record type name is the desired rt, meaning that if a record type
     * switch is requested, it will be the new recordtype name
     *
     * @param  catalogRecordTypeDevName     - developer name of the related catalog record type
     * @return String                       - serialized list of product wrappers
     */
    @AuraEnabled
    public static String getProductList(String catalogRecordTypeDevName) {
        
        // types of objects to query when forming allowed products
        Set<Schema.sObjectType> pTypes = EUR_CRM_CatalogCreationService.getProductTypesForCatalogRecordType(catalogRecordTypeDevName);
        List<sObject> prods = queryProducts(pTypes);
        List<EUR_CRM_CatalogCreationService.ProductWrapper> productWrappers = wrapProducts(prods, catalogRecordTypeDevName);
        
        return JSON.serialize(productWrappers);
        
    }

    private static List<EUR_CRM_CatalogCreationService.ProductWrapper> wrapProducts(List<sObject> prods,String catalogRecordTypeDevName) {
        List<EUR_CRM_CatalogCreationService.ProductWrapper> wraps = new List<EUR_CRM_CatalogCreationService.ProductWrapper>();
        List<String> pbiDynamicFields = EUR_CRM_CatalogCreationService.getPBIDynamicFields(catalogRecordTypeDevName);
        System.debug('\n prods.size() => ' + prods.size() + '\n');
        System.debug('\n prods => ' + JSON.serializePretty(prods) + '\n');
        List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> pbiDynamicFieldsWrappers = EUR_CRM_OP_DynamicFieldService.getFields('EUR_CRM_ProductCatalogItem__c', pbiDynamicFields);

        for(sObject prod :prods){

            EUR_CRM_CatalogCreationService.ProductWrapper wrap = new EUR_CRM_CatalogCreationService.ProductWrapper();
            wrap.dynamicfields = pbiDynamicFieldsWrappers;

            if(prod instanceOf EUR_CRM_SKU__c){
                EUR_CRM_SKU__c pr = (EUR_CRM_SKU__c)prod;

                wrap.productId                  = pr.Id;
                wrap.Name                       = pr.Name;
                wrap.ProductSAPcode             = pr.EUR_CRM_External_ID__c;
                wrap.rtName                     = pr.RecordType.DeveloperName;
                wrap.isActive                   = pr.EUR_CRM_Active__c;
                
                // hierarchy population below
                wrap.ProductLevel1              = pr.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.Id;
                wrap.ProductLevel1Description   = pr.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.Name;
                wrap.ProductLevel2              = pr.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.Id;
                wrap.ProductLevel2Description   = pr.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.Name;
                wrap.ProductLevel3              = pr.EUR_CRM_Brand_Quality_Size__r.Id;
                wrap.ProductLevel3Description   = pr.EUR_CRM_Brand_Quality_Size__r.Name;
                
                wraps.add(wrap);
            } else if (prod instanceOf EUR_CRM_Size__c){
                EUR_CRM_Size__c pr = (EUR_CRM_Size__c)prod;

                wrap.productId                  = pr.Id;
                wrap.Name                       = pr.Name;
                wrap.ProductSAPcode             = pr.EUR_CRM_External_ID__c;
                wrap.rtName                     = pr.RecordType.DeveloperName;
                wrap.isActive                   = pr.EUR_CRM_Active__c;
                
                // hierarchy population below
                wrap.ProductLevel1              = pr.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.Id;
                wrap.ProductLevel1Description   = pr.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.Name;
                wrap.ProductLevel2              = pr.EUR_CRM_Brand_Quality__r.Id;
                wrap.ProductLevel2Description   = pr.EUR_CRM_Brand_Quality__r.Name;
                
                wraps.add(wrap);
            } else if (prod instanceOf EUR_CRM_POS_Material__c){
                EUR_CRM_POS_Material__c pr = (EUR_CRM_POS_Material__c)prod;

                wrap.productId                  = pr.Id;
                wrap.Name                       = pr.Name;
                wrap.ProductSAPcode             = pr.EUR_CRM_External_ID__c;
                wrap.rtName                     = pr.RecordType.DeveloperName;
                wrap.isActive                   = pr.EUR_CRM_Active__c;
                
                // hierarchy population below
                wrap.ProductLevel1              = pr.EUR_CRM_Brand__r.Id;
                wrap.ProductLevel1Description   = pr.EUR_CRM_Brand__r.Name;
                
                wraps.add(wrap);
            } else {
                AuraHandledException e = new AuraHandledException('Tried wrapping not supported product type: ' + prod.getSobjectType());
                e.setMessage('Tried wrapping not supported product type: ' + prod.getSobjectType());
                throw e;
            }
        }
        return wraps;
    }
    /* Selector method to query necessary fields for various
     * types of Product objects
     * 
     * @param pTypes         - list of product types to query
     * @return List<sObject> - queried records
     */
    private static List<sObject> queryProducts(Set<Schema.sObjectType> pTypes) {
        List<sObject> prods = new List<sObject>();
        for(Schema.sObjectType pType :pTypes){
            // SOQL query in a loop, but this is necessary since we are querying different sObject types
            if (pType == EUR_CRM_SKU__c.sObjectType) {
                
                    List<EUR_CRM_SKU__c> skus = new List<EUR_CRM_SKU__c>([
                        SELECT Id                       // productId in wrapper
                            , Name                      // Name in wrapper
                            , EUR_CRM_External_ID__c    // ProductSAPcode in wrapper
                            , RecordType.DeveloperName  // rtName
                            , EUR_CRM_Active__c         // isActive
                            
                            // missing NationalCode
                            // missing EAN
                            
                            // hierarchy below (three sections)
                            , EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.Id // ProductLevel1
                            , EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.Name // ProductLevel1Description
                            , EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.Id // ProductLevel2
                            , EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.Name // ProductLevel2Description
                            , EUR_CRM_Brand_Quality_Size__r.Id  // ProductLevel3
                            , EUR_CRM_Brand_Quality_Size__r.Name // ProductLevel3Description
                            
                            // TODO: check if lower level needed
                            
                        FROM EUR_CRM_SKU__c
                        WHERE EUR_CRM_Country__c = :EUR_CRM_CatalogCreationService.CURRENT_USER_CC
                            AND EUR_CRM_Active__c = true
                            AND EUR_CRM_Is_Competitor__c = false
                            AND EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__c != null
                    ]);
                	//System.debug('Returning skus '+skus);
                    prods.addAll((List<sObject>)skus);
                } else if (pType == EUR_CRM_Size__c.sObjectType){
                    // fetch brand quality sizes
                    List<EUR_CRM_Size__c> szs = new List<EUR_CRM_Size__c>([
                        SELECT Id  // productId in wrapper
                            , Name  // Name in wrapper
                            , EUR_CRM_External_ID__c  // ProductSAPcode in wrapper
                            , RecordType.DeveloperName  // rtName in wrapper
                            , EUR_CRM_Active__c         // isActive
                            
                            // missing NationalCode
                            // missing EAN
                            
                            // hierarchy below (two sections)
                            , EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.Id // ProductLevel1
                            , EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.Name // ProductLevel1Description
                            , EUR_CRM_Brand_Quality__r.Id // ProductLevel2
                            , EUR_CRM_Brand_Quality__r.Name // ProductLevel2Description
                           
                            
                        FROM EUR_CRM_Size__c
                        WHERE EUR_CRM_Country__c = :EUR_CRM_CatalogCreationService.CURRENT_USER_CC
                            AND EUR_CRM_Active__c = true
                            AND EUR_CRM_BrandQualitySize_Is_Competitor__c = false
                            AND EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__c != null
                    ]);
                    prods.addAll((List<sObject>)szs);
                } else if(pType == EUR_CRM_POS_Material__c.sObjectType){
                    // fetch posm-s
                    List<EUR_CRM_POS_Material__c> posms = new List<EUR_CRM_POS_Material__c>([
                        SELECT Id  // productId in wrapper
                            , Name  // Name in wrapper
                            , EUR_CRM_External_ID__c  // ProductSAPcode in wrapper
                            , RecordType.DeveloperName  // rtName in wrapper
                            , EUR_CRM_Active__c         // isActive
                            
                            // missing NationalCode
                            // missing EAN
                            
                            // hierarchy below (two sections)
                            , EUR_CRM_Brand__r.Id // ProductLevel1
                            , EUR_CRM_Brand__r.Name // ProductLevel1Description
                            
                        FROM EUR_CRM_POS_Material__c
                        WHERE 
                            EUR_CRM_Country__c = :EUR_CRM_CatalogCreationService.CURRENT_USER_CC
                            AND EUR_CRM_Active__c = true
                            AND EUR_CRM_Brand__c != null
                    ]);
                    
                    prods.addAll((List<sObject>)posms);
                    
                }
            
                else {
                    AuraHandledException e = new AuraHandledException('Unknown product type requested: ' + pType);
                    e.setMessage('Unknown product type requested: ' + pType);
                    throw e;
                }
                
            
        }
        return prods;
    }

    
    @AuraEnabled
    public static SelectOption getRecTypeDevName(Id rtId) {
        SelectOption tuple = new SelectOption(null,null);
        
        if(!String.isEmpty(rtId)){
            // find rt by chosen id
            List<RecordType> rts = new List<RecordType>([SELECT Id,DeveloperName,Name FROM RecordType WHERE sObjectType = 'EUR_CRM_ProductCatalog__c' AND Id =:rtId AND isActive = true LIMIT 1]);
        
            if(rts != null && !rts.isEmpty()){
                tuple = new SelectOption(rts[0].DeveloperName,rtId);
                return tuple;
            }
        } else {
            // fall back to default rt
            Schema.DescribeSObjectResult dsr = EUR_CRM_ProductCatalog__c.SObjectType.getDescribe();
            Schema.RecordTypeInfo defaultRecordType;
            for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
                if(rti.isDefaultRecordTypeMapping()) {
                    defaultRecordType = rti;
                    break;
                }
            }
            if(defaultRecordType != null){
                tuple = new SelectOption(defaultRecordType.getDeveloperName(),defaultRecordType.getRecordTypeId());
                return tuple;
            }
        }
        
        return tuple;
    }
    
    /* Method to fetch catalog data by id
     * and RecordType selected
     * 
     * @param catalogId     - id of the catalog to fetch
     * @param recordTypeId  - id of the record type to pull catalog data for
     * @return String       - status of the request
     */


    @AuraEnabled
    public static String getCatalogData(Id catalogId,Id recordTypeId) {

        EUR_CRM_CatalogCreationService.HierarchyBuilderWrapper catalogInfo = new EUR_CRM_CatalogCreationService.HierarchyBuilderWrapper();

        EUR_CRM_ProductCatalog__c catalog = [SELECT Id
                , Name
                , RecordTypeId
                , RecordType.DeveloperName
                , EUR_CRM_OrderType__c
                , EUR_CRM_IsStandard__c
                //, EUR_CRM_IsDynamic__c
                , EUR_CRM_ParentProductCatalogID__c
                , EUR_CRM_ValidFrom__c
                , EUR_CRM_ValidTo__c
                , EUR_CRM_ViewName1__c
                , EUR_CRM_ViewName2__c
                , EUR_CRM_AccountGroupId__c
                , EUR_CRM_ReturnReason__c
                , EUR_CRM_Wholesaler__c
        /*
        , EUR_CRM_AvailableForAll__c
        , EUR_CRM_MininmumDeliveryDelay__c
        , EUR_CRM_PricingSchemaSAP__c
        , EUR_CRM_TemplateDeliveryDates__c
        , EUR_CRM_FuturePricingDate__c
        */
        FROM EUR_CRM_ProductCatalog__c
        WHERE Id = :catalogId];

        catalogInfo.catalogName = catalog.Name;
        catalogInfo.catalogRecTypeId = catalog.RecordTypeId;
        catalogInfo.catalogRecTypeDName = catalog.RecordType.DeveloperName;

        catalogInfo.catalogOrderType = catalog.EUR_CRM_OrderType__c;
        // should never be dynamic
        catalogInfo.isDynamic = false;
        catalogInfo.isStandard = catalog.EUR_CRM_IsStandard__c;
        // should never be asvailable for all
        catalogInfo.availableForAll = false;
        catalogInfo.isTemplate = false;
        catalogInfo.hasBegun = false;
        catalogInfo.today = Datetime.now().dateGMT();
        //catalogInfo.pricingDate = catalog.EUR_CRM_FuturePricingDate__c;
        catalogInfo.wholesalerId = catalog.EUR_CRM_Wholesaler__c;
        catalogInfo.catalogReturnReason = catalog.EUR_CRM_ReturnReason__c;
        catalogInfo.templDelDates = new List<String>();

        if(catalog.EUR_CRM_ValidFrom__c != null) {
            catalogInfo.startDate = new List<String>();
            catalogInfo.startDate.add(String.valueOf(catalog.EUR_CRM_ValidFrom__c.year()));
            catalogInfo.startDate.add(String.valueOf(catalog.EUR_CRM_ValidFrom__c.month()));
            catalogInfo.startDate.add(String.valueOf(catalog.EUR_CRM_ValidFrom__c.day()));
            // check if active
            if(catalog.EUR_CRM_ValidFrom__c <= Datetime.now().dateGMT()){
                // compate gmt dates
                catalogInfo.hasBegun = true;
            }
        }
        if(catalog.EUR_CRM_ValidTo__c != null) {
            catalogInfo.endDate = new List<String>();
            catalogInfo.endDate.add(String.valueOf(catalog.EUR_CRM_ValidTo__c.year()));
            catalogInfo.endDate.add(String.valueOf(catalog.EUR_CRM_ValidTo__c.month()));
            catalogInfo.endDate.add(String.valueOf(catalog.EUR_CRM_ValidTo__c.day()));
        }

        catalogInfo.viewName1 = catalog.EUR_CRM_ViewName1__c;
        catalogInfo.viewName2 = catalog.EUR_CRM_ViewName2__c;
        catalogInfo.groupId = catalog.EUR_CRM_AccountGroupId__c;

        //System.debug(catalogInfo);

        catalogInfo.productsInfo = new List<EUR_CRM_CatalogCreationService.ProductHierarchyInfoWrapper>();

        Map<Id,EUR_CRM_CatalogCreationService.ProductHierarchyInfoWrapper> pbisByProduct = new Map<Id,EUR_CRM_CatalogCreationService.ProductHierarchyInfoWrapper>();
        List<String> pbiDynamicFields = EUR_CRM_CatalogCreationService.getPBIDynamicFields(catalog.RecordType.DeveloperName);
        Set<String> pbiFields = new Set<String>{
                'Id',
                'EUR_CRM_SKU__c',
                'EUR_CRM_Brand_Quality_Size__c',
                'EUR_CRM_POS_Material__c',
                'EUR_CRM_View1Level1__c',
                'EUR_CRM_View1Level2__c',
                'EUR_CRM_View1Level3__c',
                'EUR_CRM_View1Level4__c',
                'EUR_CRM_View2Level1__c',
                'EUR_CRM_View2Level2__c',
                'EUR_CRM_View2Level3__c',
                'EUR_CRM_View2Level4__c',
                'EUR_CRM_OrderView1__c',
                'EUR_CRM_OrderView2__c'
        };
        pbiFields.addAll(pbiDynamicFields);
        String pbiQuery =
                'SELECT ' + String.join(new List<String>(pbiFields), ', ') + ' ' +
                        'FROM EUR_CRM_ProductCatalogItem__c ' +
                        'WHERE EUR_CRM_PriceBookID__c = :catalogId'
        ;
        List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> pbiDynamicFieldsWrappers = EUR_CRM_OP_DynamicFieldService.getFields('EUR_CRM_ProductCatalogItem__c', pbiDynamicFields);
        System.debug('\n pbiDynamicFieldsWrappers.size() => ' + pbiDynamicFieldsWrappers.size() + '\n');
        System.debug('\n pbiDynamicFieldsWrappers => ' + JSON.serializePretty(pbiDynamicFieldsWrappers) + '\n');
        for(EUR_CRM_ProductCatalogItem__c pbi : Database.query(pbiQuery)) {

            EUR_CRM_CatalogCreationService.ProductHierarchyInfoWrapper productWrapped = new EUR_CRM_CatalogCreationService.ProductHierarchyInfoWrapper();
            for (EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper dynamicField : pbiDynamicFieldsWrappers) {
                productWrapped.dynamicfields.add(new EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper(dynamicField));
            }
            // populate product id from populated lookup
            if (pbi.EUR_CRM_SKU__c != null){

                productWrapped.productId = pbi.EUR_CRM_SKU__c;

            } else if (pbi.EUR_CRM_Brand_Quality_Size__c != null){

                productWrapped.productId = pbi.EUR_CRM_Brand_Quality_Size__c;

            } else if (pbi.EUR_CRM_POS_Material__c != null){

                productWrapped.productId = pbi.EUR_CRM_POS_Material__c;

            }

            productWrapped.View1Level1 = pbi.EUR_CRM_View1Level1__c != null ? pbi.EUR_CRM_View1Level1__c : null;
            productWrapped.View1Level2 = pbi.EUR_CRM_View1Level2__c != null ? pbi.EUR_CRM_View1Level2__c : null;
            productWrapped.View1Level3 = pbi.EUR_CRM_View1Level3__c != null ? pbi.EUR_CRM_View1Level3__c : null;
            productWrapped.View1Level4 = pbi.EUR_CRM_View1Level4__c != null ? pbi.EUR_CRM_View1Level4__c : null;
            productWrapped.View2Level1 = pbi.EUR_CRM_View2Level1__c != null ? pbi.EUR_CRM_View2Level1__c : null;
            productWrapped.View2Level2 = pbi.EUR_CRM_View2Level2__c != null ? pbi.EUR_CRM_View2Level2__c : null;
            productWrapped.View2Level3 = pbi.EUR_CRM_View2Level3__c != null ? pbi.EUR_CRM_View2Level3__c : null;
            productWrapped.View2Level4 = pbi.EUR_CRM_View2Level4__c != null ? pbi.EUR_CRM_View2Level4__c : null;

            //productWrapped.ProductLevel1 = pbi.EUR_CRM_ProductLevel1__c;
            //productWrapped.ProductLevel2 = pbi.EUR_CRM_ProductLevel2__c;
            //productWrapped.ProductLevel3 = pbi.EUR_CRM_ProductLevel3__c;
            //productWrapped.ProductLevel4 = pbi.EUR_CRM_ProductLevel4__c;
            //productWrapped.ProductLevel5 = pbi.EUR_CRM_ProductLevel5__c;

            //productWrapped.MarketingLevel1 = pbi.EUR_CRM_MarketingLevel1__c;
            //productWrapped.MarketingLevel2 = pbi.EUR_CRM_MarketingLevel2__c;
            //productWrapped.MarketingLevel3 = pbi.EUR_CRM_MarketingLevel3__c;
            //productWrapped.MarketingLevel4 = pbi.EUR_CRM_MarketingLevel4__c;

            productWrapped.OrderView1 = String.valueOf(pbi.EUR_CRM_OrderView1__c);
            productWrapped.OrderView2 = String.valueOf(pbi.EUR_CRM_OrderView2__c);
            //productWrapped.multiplication_factor = String.valueOf(pbi.EUR_CRM_MultiplicationFactor__c);

            for(EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper fieldsWrapper : productWrapped.dynamicfields) {
                fieldsWrapper.value = pbi.get(fieldsWrapper.fieldApiName);
            }
            productWrapped.pbi = pbi;

            if(productWrapped.productId != null){
                pbisByProduct.put(productWrapped.productId,productWrapped);
            }

            //System.debug('==> Returning wrapped Price book item '+productWrapped);
            catalogInfo.productsInfo.add(productWrapped);
        }
//        System.debug('\n catalogInfo.productsInfo.size() => ' + catalogInfo.productsInfo.size() + '\n');
//        System.debug('\n catalogInfo.productsInfo => ' + JSON.serializePretty(catalogInfo.productsInfo) + '\n');
        return JSON.serialize(catalogInfo);
    }

    @AuraEnabled
    public static String saveCatalog(String settings) {
        System.debug('\n settings => ' + settings + '\n');
        EUR_CRM_CatalogCreationService.HierarchyBuilderWrapper buildingSettings = (EUR_CRM_CatalogCreationService.HierarchyBuilderWrapper)JSON.deserialize(settings, EUR_CRM_CatalogCreationService.HierarchyBuilderWrapper.class);
        System.debug('\n buildingSettings => ' + JSON.serializePretty(buildingSettings) + '\n');
        Savepoint sp;
        if(!Test.isRunningTest()) {
            sp = Database.setSavepoint();
        }
        try {

            Set<Id> agIds = new Set<Id>();
            //List<EUR_CRM_Account_Target_Group__c> newAgs = new List<EUR_CRM_Account_Target_Group__c>();
            if(!String.isEmpty(buildingSettings.groupId)){
                agIds.add(buildingSettings.groupId);
            }

            // new catalog/updated catalog
            EUR_CRM_ProductCatalog__c catalog = EUR_CRM_CatalogCreationService.createCatalog(buildingSettings, agIds);
            // insert new shares for the catalog
            EUR_CRM_CatalogCreationService.createSharing(catalog.Id, buildingSettings.sharing);

            // insert new shares for customer groups
            List<EUR_CRM_ProductCatalog__Share> pcShares = new List<EUR_CRM_ProductCatalog__Share>(
                [SELECT
                    Id
                    ,UserOrGroupId
                    ,AccessLevel
                    ,ParentId
                    ,RowCause
                 FROM EUR_CRM_ProductCatalog__Share
                     WHERE ParentId =:catalog.Id]
            );
            System.debug('\n pcShares.size() => ' + pcShares.size() + '\n');
            System.debug('\n pcShares => ' + JSON.serializePretty(pcShares) + '\n');
            // auto share group to the users that this catalog has been shared to
            EUR_CRM_CatalogCreationService.createGroupSharing(agIds,pcShares);

            if(buildingSettings.toConfigureItems) {
                // on edit all catalog items were substituted with new ones
                // now existing catalog items should be updated instead
                System.debug('Before createCatalogItems() ');
                EUR_CRM_CatalogCreationService.createCatalogItems(catalog, buildingSettings);

            }
            return '{"success": true, "record": { "Id": "' + catalog.Id + '"}}';

        } catch(Exception e) {

            System.debug(e);
            if(!Test.isRunningTest()) {
                Database.rollback(sp);
            }

            Map<String,Object> result = new Map<String,Object>{
                'success' => false
                , 'message' => e.getMessage()+ ': Line ' + e.getLineNumber()
            };

            return JSON.serialize(result);
        }
        //return '{"success": false, "message": "UnexpectedException"}';
    }


    @AuraEnabled
    public static List<SelectOption> getOrderTypes(String rtId){
        
        String escaped = String.escapeSingleQuotes(rtId);
        List<RecordType> rts;
        if(!String.isEmpty(escaped)){
            rts = new List<RecordType>([SELECT Id,DeveloperName FROM RecordType WHERE Id = :rtId]);
        }
        Set<String> allowed;
        if(rts != null && !rts.isEmpty()){
            allowed = EUR_CRM_CatalogCreationService.CAT_RT_OT_MAPPING.get(rts[0].DeveloperName);
        }
        
         List<SelectOption> ples = new List<SelectOption>();
         Schema.DescribeFieldResult fieldResult = EUR_CRM_ProductCatalog__c.EUR_CRM_OrderType__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
             if(allowed != null && !allowed.isEmpty()){
                 if(allowed.contains(pickListVal.getValue())){
                     ples.add(new SelectOption(pickListVal.getLabel(),pickListVal.getValue()));
                 }
             } else {
                 ples.add(new SelectOption(pickListVal.getLabel(),pickListVal.getValue()));
             }
         }     
         return ples;
     }
    
    /* ====================================================
     *                  INNER CLASSES
     * 
     * ====================================================*/
    public class SelectOption{
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
        
        public SelectOption(String lbl, String val) {
            this.label = lbl;
            this.value = val;
        }
        
    }
    /* ====================================================
     *                  EXCEPTIONS
     * 
     * ====================================================*/
    public class CatalogNotImplementedException extends Exception{}
}