/* Service class for Catalog Creation
 * Used to unwrap Catalog and Catalog Items from view representation
 * Used for creating necessary shares for related Account Groups
 * 
 */
public without sharing class EUR_CRM_CatalogCreationService {
    // Context user info (i.e. country info)
    public static final User CURRENT_USER = [SELECT Country,EUR_CRM_Country_Code__c FROM User WHERE Id =: UserInfo.getUserId()];
    public static String CURRENT_USER_CC = CURRENT_USER.EUR_CRM_Country_Code__c != null ? CURRENT_USER.EUR_CRM_Country_Code__c.split(';')[0] : null;
    
    public static final String CATALOG_DIRECT_RT_DEV_NAME      = 'EUR_Direct';
    public static final String CATALOG_INDIRECT_RT_DEV_NAME    = 'EUR_Indirect';
    public static final String CATALOG_POSM_RT_DEV_NAME        = 'EUR_POSM';
    // TODO: check below unused?
    public static final String CATALOG_TEMPLATE_RT_DEV_NAME    = 'EUR_Template';
    public static final String CATALOG_RETURN_RT_DEV_NAME      = 'EUR_Credit_Note';
    
    // maping of allowed order type per catalog record type
    public static final Map<String,Set<String>> CAT_RT_OT_MAPPING = new Map<String,Set<String>>{
        CATALOG_DIRECT_RT_DEV_NAME     => new Set<String>{'EUR_Direct','EUR_Free_Goods_to_Customer','EUR_Free_Goods_to_Stock','EUR_Free_Goods_from_Stock'}
        ,CATALOG_INDIRECT_RT_DEV_NAME   => new Set<String>{'EUR_Indirect'}
        ,CATALOG_POSM_RT_DEV_NAME       => new Set<String>{'EUR_POSM'} 
        // TODO: check below unused?
        ,CATALOG_TEMPLATE_RT_DEV_NAME   => new Set<String>{'Presales'}       
        ,CATALOG_RETURN_RT_DEV_NAME      => new Set<String>{'EUR_Credit_Note'}
    };
    
    // product level mapping: abbreviation <=> product object API name
    private static final Map<String,Schema.sObjectType> PROD_LEVEL_MAPPING = new Map<String,Schema.sObjectType>{
        'SKU'    => EUR_CRM_SKU__c.sObjectType
        ,'POSM'  => EUR_CRM_POS_Material__c.sObjectType                   
        ,'BQS'   => EUR_CRM_Size__c.sObjectType 
    };
    
    // mapping of lookups by product type from PBIs
    private static final Map<Schema.sObjectType,Schema.sObjectField> PBI_PROD_LKUPS = new Map<Schema.sObjectType,Schema.sObjectField>{
        EUR_CRM_SKU__c.sObjectType              =>  EUR_CRM_ProductCatalogItem__c.EUR_CRM_SKU__c
        ,EUR_CRM_POS_Material__c.sObjectType    =>  EUR_CRM_ProductCatalogItem__c.EUR_CRM_POS_Material__c
        ,EUR_CRM_Size__c.sObjectType            =>  EUR_CRM_ProductCatalogItem__c.EUR_CRM_Brand_Quality_Size__c
    };

    public static List<String> getPBIDynamicFields(String catalogRecordTypeDevName) {
        Set<String> otsForRecType = CAT_RT_OT_MAPPING.get(catalogRecordTypeDevName);
        if(otsForRecType == null || otsForRecType.isEmpty()){
            throw new AuraHandledException('Unknown catalog record type by API name: '+catalogRecordTypeDevName);
        }

        List<EUR_CRM_CTM_Product_Catalog_Level__mdt> pcls = new List<EUR_CRM_CTM_Product_Catalog_Level__mdt>([
                SELECT EUR_CRM_Use_fields_on_PriceBookItem__c
                FROM EUR_CRM_CTM_Product_Catalog_Level__mdt
                WHERE EUR_CRM_Country__c =: EUR_CRM_CatalogCreationService.CURRENT_USER_CC  // pull setup info for context user country
                AND EUR_CRM_Order_Type__c IN: otsForRecType
        ]);
        if(pcls.isEmpty()){
            throw new AuraHandledException(
                    String.format(
                            'Could not locate setup data for Country: {0} and Order Types: {1}'
                            ,new List<String>{EUR_CRM_CatalogCreationService.CURRENT_USER_CC, String.join( new List<String>(otsForRecType), ', ')}
                    )
            );
        }
        String configFields = pcls[0].EUR_CRM_Use_fields_on_PriceBookItem__c;
        if(configFields == null) {
            return new List<String>();
        } else {
            return configFields.trim().split('\\s*[,;]\\s*');
        }
    }
    
    /* Service method to work with setup info and
     * return product object types referenced by this
     * catalog's record type
     * 
     * @param catalogRecordTypeDevName - developer name of the catalog's record type
     * @return Set<Schema.sObjectType> - set of product types
     */
    public static Set<Schema.sObjectType> getProductTypesForCatalogRecordType(String catalogRecordTypeDevName){
        Set<String> otsForRecType = CAT_RT_OT_MAPPING.get(catalogRecordTypeDevName);
        if(otsForRecType == null || otsForRecType.isEmpty()){
            throw new AuraHandledException('Unknown catalog record type by API name: '+catalogRecordTypeDevName);
        }
        
        List<EUR_CRM_CTM_Product_Catalog_Level__mdt> pcls = new List<EUR_CRM_CTM_Product_Catalog_Level__mdt>([
            SELECT 
                EUR_CRM_Product_Level__c
                ,EUR_CRM_Country__c
                ,EUR_CRM_Order_Type__c
            FROM EUR_CRM_CTM_Product_Catalog_Level__mdt
            WHERE EUR_CRM_Country__c =: EUR_CRM_CatalogCreationService.CURRENT_USER_CC  // pull setup info for context user country
                AND EUR_CRM_Order_Type__c IN: otsForRecType
        ]);
        
        if(pcls.isEmpty()){
            throw new AuraHandledException(
                    String.format(
                        'Could not locate setup data for Country: {0} and Order Types: {1}'
                        ,new List<String>{EUR_CRM_CatalogCreationService.CURRENT_USER_CC, String.join( new List<String>(otsForRecType), ', ')}
                    )
            );
        }
        
        // types of objects to query when forming allowed products
        Set<Schema.sObjectType> pTypes = new Set<Schema.sObjectType>();
        if(System.Test.isRunningTest() == true){
            pTypes.addAll(new List<Schema.sObjectType>{EUR_CRM_SKU__c.sObjectType,EUR_CRM_Size__c.sObjectType,EUR_CRM_POS_Material__c.sObjectType});  // during test pull all products
        }
        for(EUR_CRM_CTM_Product_Catalog_Level__mdt pcl : pcls){
            if(PROD_LEVEL_MAPPING.containsKey(pcl.EUR_CRM_Product_Level__c)){
                pTypes.add(PROD_LEVEL_MAPPING.get(pcl.EUR_CRM_Product_Level__c));
            }
        }
        
        if(pTypes.isEmpty()){
            throw new AuraHandledException(
                    String.format(
                        'Could not determine product type to query, check settings for Country: {0} and Order Types {1}'
                        ,new List<String>{EUR_CRM_CatalogCreationService.CURRENT_USER_CC, String.join( new List<String>(otsForRecType), ', ')}
                    )
            );
        }
        return pTypes;
    }

    
    public static void createSharing(Id catalogId, List<EUR_CRM_ProductCatalog__Share> sharing) {
        Database.SaveResult[] results;
        if (sharing != null && !sharing.isEmpty()) {
            for (EUR_CRM_ProductCatalog__Share share : sharing) {
                share.ParentId = catalogId;
            }
            if(!sharing.isEmpty()) {
                Database.insert(sharing, false);
            }
        }
    }
    
    public static void createGroupSharing(Set<Id> groupIds, List<EUR_CRM_ProductCatalog__Share> sharing) {
        Database.SaveResult[] results;
        if (sharing != null && !sharing.isEmpty() && groupIds != null && !groupIds.isEmpty()) {
            
            List<EUR_CRM_Account_Target_Group__Share> agss = new List<EUR_CRM_Account_Target_Group__Share>();
            //store relevant group ids
            Set<Id> grpIds = new Set<Id>();
            
            for (EUR_CRM_ProductCatalog__Share share : sharing) {
                if(share.RowCause == 'manual' || share.RowCause.endsWith('__c')){
                    for(Id groupId :groupIds){
                        EUR_CRM_Account_Target_Group__Share ags = new EUR_CRM_Account_Target_Group__Share();
                        ags.ParentId = groupId;
                        ags.UserOrGroupId = share.UserOrGroupId;
                        ags.AccessLevel = share.AccessLevel;
                        
                        agss.add(ags);
                        grpIds.add(groupId);
                    }
                }
            }
            if(!sharing.isEmpty()) {
                // allow partial success to avoid errors for owner, duplicate shares inserted
                System.debug('\n agss.size() => ' + agss.size() + '\n');
                System.debug('\n agss => ' + JSON.serializePretty(agss) + '\n');
                results = Database.insert(agss, false);
                
                if(!grpIds.isEmpty()){
                    /* TODO: check if needed 
                    List<EUR_CRM_Account_in_Target_Group__c> agps = new List<EUR_CRM_Account_in_Target_Group__c>([SELECT Id FROM EUR_CRM_Account_in_Target_Group__c WHERE EUR_CRM_AccountGroup__c IN :grpIds]);
                    if(!agps.isEmpty()){
                        update agps;
                    }
                    */
                }
                
            }
        }
    }
  
    // for proper sharing update on mobile device
    // make update catalog items to change their last modified date 
    public static void updateSharedRecords(Id catalogId) {
        update [SELECT Id FROM EUR_CRM_ProductCatalogItem__c WHERE EUR_CRM_PriceBookID__c = :catalogId];        
        update [SELECT Id FROM EUR_CRM_ProductCatalog__c WHERE Id = :catalogId];
        // @edit 02.03.18 added pricebook updating
        // removed, since no multiple groups per catalog
        //update [SELECT Id FROM EUR_CRM_AccountProductCatalog__c WHERE EUR_CRM_PriceBookID__c =:catalogId];
    }

    /* Method override to conform to logic of
     * possible multiple account groups per 
     * single product catalog
     * 
     * @edit   PZ - 30.01.18
     * @param  HierarchyBuilderWrapper - additional settings for account groups being tied in
     * @param  List<AccountGroup__c>   - account groups to be tied in
     * @return ProductCatalog__c       - created product catalogue
     */
    public static EUR_CRM_ProductCatalog__c createCatalog(HierarchyBuilderWrapper buildingSettings, Set<Id> accountGroups) {
        
        List<EUR_CRM_ProductCatalog__c> sCats = new List<EUR_CRM_ProductCatalog__c>([SELECT Id FROM EUR_CRM_ProductCatalog__c WHERE EUR_CRM_IsStandard__c = true AND EUR_CRM_Country__c = :EUR_CRM_CatalogCreationService.CURRENT_USER_CC ORDER BY CreatedDate DESC LIMIT 1 ]);
        
//        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_ProductCatalog__c' AND DeveloperName = 'EUR_Direct' LIMIT 1];
        Id directRTId = Schema.SObjectType.EUR_CRM_ProductCatalog__c.getRecordTypeInfosByDeveloperName().get('EUR_Direct').getRecordTypeId();

        Date validFrom = Date.newInstance(
                Integer.valueOf(buildingSettings.startDate[0]),
                Integer.valueOf(buildingSettings.startDate[1]),
                Integer.valueOf(buildingSettings.startDate[2])
        );
        Date validTo = Date.newInstance(
                Integer.valueOf(buildingSettings.endDate[0]),
                Integer.valueOf(buildingSettings.endDate[1]),
                Integer.valueOf(buildingSettings.endDate[2])
        );
        
        EUR_CRM_ProductCatalog__c newCatalog = new EUR_CRM_ProductCatalog__c(
                Name = buildingSettings.catalogName,
                EUR_CRM_Country__c = CURRENT_USER_CC,
                EUR_CRM_OrderType__c = buildingSettings.catalogOrderType,
                EUR_CRM_ReturnReason__c = buildingSettings.catalogReturnReason,
                EUR_CRM_IsStandard__c = false,
                EUR_CRM_ValidFrom__c = validFrom,
                EUR_CRM_ValidTo__c = validTo,
                EUR_CRM_ViewName1__c = buildingSettings.viewName1,
                EUR_CRM_ViewName2__c = buildingSettings.viewName2,
                EUR_CRM_AccountGroupId__c = buildingSettings.groupId
        );
        if(!sCats.isEmpty()){
            newCatalog.EUR_CRM_ParentProductCatalogID__c = sCats[0].Id;
        }
        if(buildingSettings.catalogId != null) {
            newCatalog.Id = buildingSettings.catalogId;
        }
        
        if(!String.isEmpty(buildingSettings.catalogRecTypeId)){
            newCatalog.RecordTypeId = buildingSettings.catalogRecTypeId;            
        } else {
            if(newCatalog.Id == null){
                // on insert default the rec type, if not supplied
                newCatalog.RecordTypeId = directRTId;
            }
        }

        upsert newCatalog;
        return newCatalog;
    }

    /* Method override to allow decoupling
     * from parent PBIs when creating transfer catalogs
     * 
     * @edit   PZ - 23.03.18
     * @param  catalog       - catalog to attach new pbis to
     * @param  catInfo       - details about the catalog
     */
    public static void createCatalogItems(EUR_CRM_ProductCatalog__c catalog, HierarchyBuilderWrapper catInfo) {
        
        // fetch standard catalog
        List<EUR_CRM_ProductCatalog__c> sCats = new List<EUR_CRM_ProductCatalog__c>([
            SELECT Id
                ,EUR_CRM_IsManual__c 
            FROM EUR_CRM_ProductCatalog__c 
            WHERE EUR_CRM_IsStandard__c = true 
                AND EUR_CRM_Country__c = :CURRENT_USER_CC 
                AND Id =:catalog.EUR_CRM_ParentProductCatalogID__c
            ORDER BY CreatedDate DESC LIMIT 1 
        ]);
        System.debug('\n sCats => ' + JSON.serializePretty(sCats) + '\n');
        EUR_CRM_ProductCatalog__c sCat;
        if(!sCats.isEmpty()){
            sCat = sCats[0];
        }
        
        //System.debug('Saving catalog with rt '+catInfo.catalogRecTypeDName);
        // map of PBIs to be inserted (id product <=> list of PBIs)
        Map<String, List<EUR_CRM_ProductCatalogItem__c>> productPBItoInsert = new Map<String, List<EUR_CRM_ProductCatalogItem__c>>();
        // set to be populated with values of brands used in PBIs in order to update the catalog with
        Set<String> catalogBrands = new Set<String>();
        
        // map to contain existing pbis for catalog  (id product <=> list of PBIs)
        Map<Id, List<EUR_CRM_ProductCatalogItem__c>> productToPBIOldMap = new Map<Id, List<EUR_CRM_ProductCatalogItem__c>>();
        
        // form map of existing pbis for context catalog
        System.debug('\n PRODUCT CATALOG ITEMS  => ' + JSON.serializePretty([SELECT Id,EUR_CRM_SKU__c,EUR_CRM_Brand_Quality_Size__c,EUR_CRM_POS_Material__c FROM EUR_CRM_ProductCatalogItem__c WHERE EUR_CRM_PriceBookID__c =: catalog.Id]) + '\n');
        if(!String.isEmpty(catalog.Id)){
            for(EUR_CRM_ProductCatalogItem__c pbi : [
                SELECT Id
                    //,EUR_CRM_ProductID__c
                    ,EUR_CRM_SKU__c // Direct
                    ,EUR_CRM_Brand_Quality_Size__c  // Indirect
                    ,EUR_CRM_POS_Material__c //POSM catalog
                    
                FROM EUR_CRM_ProductCatalogItem__c
                WHERE EUR_CRM_PriceBookID__c =: catalog.Id
            ]) {
                // pull all referenced products, they will be cleaned up 
                // by type during save
                if(pbi.EUR_CRM_SKU__c != null){
                    if(!productToPBIOldMap.containsKey(pbi.EUR_CRM_SKU__c)){
                        productToPBIOldMap.put(pbi.EUR_CRM_SKU__c,new List<EUR_CRM_ProductCatalogItem__c>());
                    }
                    productToPBIOldMap.get(pbi.EUR_CRM_SKU__c).add(pbi);
                } 
                if(pbi.EUR_CRM_Brand_Quality_Size__c != null){
                    if(!productToPBIOldMap.containsKey(pbi.EUR_CRM_Brand_Quality_Size__c)){
                        productToPBIOldMap.put(pbi.EUR_CRM_Brand_Quality_Size__c,new List<EUR_CRM_ProductCatalogItem__c>());
                    }
                    productToPBIOldMap.get(pbi.EUR_CRM_Brand_Quality_Size__c).add(pbi);
                }
                if(pbi.EUR_CRM_POS_Material__c != null){
                    if(!productToPBIOldMap.containsKey(pbi.EUR_CRM_POS_Material__c)){
                        productToPBIOldMap.put(pbi.EUR_CRM_POS_Material__c,new List<EUR_CRM_ProductCatalogItem__c>());
                    }
                    productToPBIOldMap.get(pbi.EUR_CRM_POS_Material__c).add(pbi);
                }
            }
        }
        



        // relevant pbis in related standard manual catalog
        // used to figure out which pbis should be inserted
        Map<Id,sObject> parents = new Map<Id,sObject>();
        
        if(catInfo.catalogRecTypeDName == CATALOG_DIRECT_RT_DEV_NAME && sCat != null && sCat.EUR_CRM_IsManual__c == true){
            
            
            for(EUR_CRM_ProductCatalogItem__c pbi : [
                  SELECT 
                     Id
                     ,EUR_CRM_SKU__c
                     ,EUR_CRM_Brand_Quality_Size__c
                     ,EUR_CRM_POS_Material__c
                  FROM EUR_CRM_ProductCatalogItem__c
                  WHERE EUR_CRM_PriceBookID__r.EUR_CRM_Country__c = :EUR_CRM_CatalogCreationService.CURRENT_USER_CC
                      AND EUR_CRM_SKU__r.EUR_CRM_Country__c = :EUR_CRM_CatalogCreationService.CURRENT_USER_CC
                      AND EUR_CRM_PriceBookID__r.EUR_CRM_IsStandard__c = true
                      AND EUR_CRM_PriceBookID__r.EUR_CRM_IsManual__c = true
                      AND EUR_CRM_SKU__c != null

                      AND EUR_CRM_StartDate__c <= TODAY
                      AND EUR_CRM_EndDate__c >= TODAY

                      //AND EUR_CRM_SKU__r.EUR_CRM_Brand__c != null
//                      AND EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand__c != null
                      AND EUR_CRM_PriceBookID__c =:sCat.Id
             ]) {
                // do not count multiple references on single pbi
                if(pbi.EUR_CRM_SKU__c != null) {
                    parents.put(pbi.EUR_CRM_SKU__c, pbi);
                 } else if(pbi.EUR_CRM_Brand_Quality_Size__c != null) {
                    parents.put(pbi.EUR_CRM_Brand_Quality_Size__c, pbi);
                 } else if(pbi.EUR_CRM_POS_Material__c != null) {
                    
                 }
             }
        }
        // new pbis for manual standard catalog to be inserted
        List<EUR_CRM_ProductCatalogItem__c> newParents = new List<EUR_CRM_ProductCatalogItem__c>();

        List<String> dynFieldsByCatalogRTDevName = getPBIDynamicFields(catInfo.catalogRecTypeDName);
		System.debug('\n dynFieldsByCatalogRTDevName.size() => ' + dynFieldsByCatalogRTDevName.size() + '\n');
		System.debug('\n dynFieldsByCatalogRTDevName => ' + JSON.serializePretty(dynFieldsByCatalogRTDevName) + '\n');

        // loop over inbound from lightning PBI wrappers
        for(EUR_CRM_CatalogCreationService.ProductHierarchyInfoWrapper hrBrand : catInfo.productsInfo) {
            
            if(!productPBItoInsert.containsKey(hrBrand.productId)) {
                
                EUR_CRM_ProductCatalogItem__c pbi = new EUR_CRM_ProductCatalogItem__c();

                if(hrBrand.pbi != null) {
                    for (String dynamicField : dynFieldsByCatalogRTDevName) {
                        pbi.put(dynamicField, hrBrand.pbi.get(dynamicField));
                    }
                }
                pbi.EUR_CRM_PriceBookID__c = catalog.Id;
                
                if(!String.isEmpty(hrBrand.productId)){
                    Id prodId;
                    try{
                        prodId = Id.valueOf(hrBrand.productId);
                    } catch(Exception ex){
                        // do nothing
                    }
                    if(prodId != null){
                        // update relevant lookup with lookup to correct parent
                        Schema.sObjectType prodType = prodId.getsObjectType();
                        if(prodType == EUR_CRM_SKU__c.sObjectType){
                            
                            pbi.EUR_CRM_SKU__c = prodId;
                            
                        } else if(prodType == EUR_CRM_Size__c.sObjectType){
                            
                            pbi.EUR_CRM_Brand_Quality_Size__c = prodId;
                                    
                        } else if(prodType == EUR_CRM_POS_Material__c.sObjectType){
                            // posm
                            pbi.EUR_CRM_POS_Material__c = prodId;
                            
                        } else {
                            throw new AuraHandledException('Unknown product type: '+prodType);
                        }
                    } else {
                        throw new AuraHandledException('Null product provided for PBI ');
                    }
                    
                    // inject existing pbi id to update it
                    if(productToPBIOldMap.containsKey(hrBrand.productId)){
                        List<EUR_CRM_ProductCatalogItem__c> thisProdPBIs = productToPBIOldMap.get(hrBrand.productId);
                        if(thisProdPBIs != null && !thisProdPBIs.isEmpty()){
                            EUR_CRM_ProductCatalogItem__c thisPBI = thisProdPBIs[0];
                            pbi.Id = thisPBI.Id;
                            thisProdPBIs.remove(0);
                        }
                    }
                    
                    
                }
                
                productPBItoInsert.put(hrBrand.productId, new List<EUR_CRM_ProductCatalogItem__c>{pbi});
            }
            
            
            List<EUR_CRM_ProductCatalogItem__c> pbis = productPBItoInsert.get(hrBrand.productId);
            
            if(pbis != null && !pbis.isEmpty()){
                
                EUR_CRM_ProductCatalogItem__c pbi = pbis[0];
                
                // check parent catalog pbi exists for certain types
                if(catInfo.catalogRecTypeDName == CATALOG_DIRECT_RT_DEV_NAME && sCat != null && sCat.EUR_CRM_IsManual__c == true){
                    sObject parent = parents.get(hrBrand.productId);
                    if(parent == null){
                        EUR_CRM_ProductCatalogItem__c newParent = pbi.clone(false,true,false,false);
                        
                        newParent.EUR_CRM_PriceBookID__c = sCat.Id;
/* REMOVE COMMENT
                        newParent.EUR_CRM_EndDate__c = System.today().addYears(100);
                        newParent.EUR_CRM_StartDate__c = System.today();
*/
                        
                        newParents.add(newParent);
                    }
                }
                
                // populate fields
                if(hrBrand.OrderView1 != null) pbi.EUR_CRM_OrderView1__c = Decimal.valueOf(hrBrand.OrderView1);
                
                //if(hrBrand.multiplication_factor != null) pbi.MultiplicationFactor__c = Decimal.valueOf(hrBrand.multiplication_factor);
                
                // @edit 30.04.18 - previously had checks on inbound null values, like:
                // if(hrBrand.View1Level2 != null) pbi.View1Level2__c = hrBrand.View1Level2;
                // but with upsert - should be able to update to null (i.e. remove from branch)
                
                if(hrBrand.OrderView1 != null){
                    // product infos duplicate per view, so view 1 should overwrite previous info
                    // for view 1
                    pbi.EUR_CRM_View1Level1__c = hrBrand.View1Level1;
                    pbi.EUR_CRM_View1Level2__c = hrBrand.View1Level2;
                    pbi.EUR_CRM_View1Level3__c = hrBrand.View1Level3;
                    pbi.EUR_CRM_View1Level4__c = hrBrand.View1Level4;
                } else {
                    if(hrBrand.OrderView2 != null) pbi.EUR_CRM_OrderView2__c = Decimal.valueOf(hrBrand.OrderView2);
                    pbi.EUR_CRM_View2Level1__c = hrBrand.View2Level1;
                    pbi.EUR_CRM_View2Level2__c = hrBrand.View2Level2;
                    pbi.EUR_CRM_View2Level3__c = hrBrand.View2Level3;
                    pbi.EUR_CRM_View2Level4__c = hrBrand.View2Level4;
                }
                // wipe data on second view, if the view was wiped
                if(String.isEmpty(catalog.EUR_CRM_ViewName2__c)){
                    pbi.EUR_CRM_OrderView2__c = null;
                    pbi.EUR_CRM_View2Level1__c = null;
                    pbi.EUR_CRM_View2Level2__c = null;
                    pbi.EUR_CRM_View2Level3__c = null;
                    pbi.EUR_CRM_View2Level4__c = null;
                }

            }
        }
        System.debug('\n newParents.size() => ' + newParents.size() + '\n');
        System.debug('\n newParents => ' + JSON.serializePretty(newParents) + '\n');
        if(!productPBItoInsert.isEmpty()){
            List<EUR_CRM_ProductCatalogItem__c> toUpsert = new List<EUR_CRM_ProductCatalogItem__c>();
            for(List<EUR_CRM_ProductCatalogItem__c> prodPBIs : productPBItoInsert.values()){
                if(prodPBIs != null && !prodPBIs.isEmpty()){
                    toUpsert.addAll(prodPBIs);
                }
            }
            if(!toUpsert.isEmpty()){
                System.debug('\n toUpsert.size() => ' + toUpsert.size() + '\n');
                System.debug('\n toUpsert => ' + JSON.serializePretty(toUpsert) + '\n');
                // upsert PBIs
                upsert toUpsert;
            }
            
        }
        if(!newParents.isEmpty()){
            // insert pbis into standard manual catalog
            // if no entries for this product existed
            //System.debug('Inserting new parents  '+newParents);
            insert newParents;
        }
        if(!catalogBrands.isEmpty()) {
            // update catalog with registered brands
            //updateCatalogBrand(catalog.Id, catalogBrands);
        }
        if(!productToPBIOldMap.isEmpty()){
            List<EUR_CRM_ProductCatalogItem__c> toDelete = new List<EUR_CRM_ProductCatalogItem__c>();
            
            for(List<EUR_CRM_ProductCatalogItem__c> prodPBIs : productToPBIOldMap.values()){
                if(prodPBIs != null && !prodPBIs.isEmpty()){
                    toDelete.addAll(prodPBIs);
                }
            }
            if(!toDelete.isEmpty()){
                System.debug('\n toDelete.size() => ' + toDelete.size() + '\n');
                System.debug('\n toDelete => ' + JSON.serializePretty(toDelete) + '\n');
                // remove pbis no longer referenced products
                delete toDelete;
            }
        }
    }

    public class ProductWrapper {
        public Id productId;
        public String Name;
        public String ProductSAPcode;
        public String NationalCode;
        public String EAN;
        public String rtName;
        public Boolean isActive;
        public String ProductLevel1;
        public String ProductLevel2;
        public String ProductLevel3;
        public String ProductLevel4;
        public String ProductLevel5;
        public String ProductLevel6;
        public String MarketingLevel1;
        public String MarketingLevel2;
        public String MarketingLevel3;
        public String MarketingLevel4;
        public String ProductLevel1Description;
        public String ProductLevel2Description;
        public String ProductLevel3Description;
        public String ProductLevel4Description;
        public String ProductLevel5Description;
        public String ProductLevel6Description;
        public String MarketingLevel1Description;
        public String MarketingLevel2Description;
        public String MarketingLevel3Description;
        public String MarketingLevel4Description;
        public Decimal order;
        public Decimal multiplication_factor;
        
        public Date ExpectAvailabiltyDate;
        // fields on layout
        public Date DelStart;
        public Date DelEnd;
        public Date OOSStart;
        public Date OOSEnd;
        public Date PrStart;
        public Date PrEnd;
        public Integer MinQty;
        public Integer MaxQty;
        public Integer Pckg;
        public Integer TemplQty;
        // placeholders
        public Integer MinQtyP;
        public Integer MaxQtyP;
        public Date DelStartP;
        public Date DelEndP;
        public Date OOSStartP;
        public Date OOSEndP;
        public Date PrStartP;
        public Date PrEndP;
        public Integer PckgP;
        public Integer TemplQtyP;
        
        public List<TemplatePBI> templPBIs = new List<TemplatePBI>();
        public List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> dynamicfields = new List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper>();
        public EUR_CRM_ProductCatalogItem__c pbi = new EUR_CRM_ProductCatalogItem__c();
    }
    /* Wrapper class for the Product Catalog
     * 
     */
    public class HierarchyBuilderWrapper {
        public String catalogId;
        public Id wholesalerId;
        public String catalogName;
        public Id groupId;
        // TODO: check group info deprecated
        public List<AccountGroupInfoWrapper> groupInfo;
        public String catalogOrderType;
        public String catalogRecTypeId;
        public String catalogRecTypeDName;
        public String catalogReturnReason;
        public List<String> startDate;
        public List<String> endDate;
        public Date pricingDate;
        public Boolean isDynamic;
        public Boolean isStandard;
        public Boolean availableForAll;
        public String viewName1;
        public String viewName2;
        public Boolean toConfigureItems;
        public Boolean isTemplate;
        public Boolean isTransfer;
        public Boolean hasBegun;
        public Date today;
        //public Integer minDelDelay;
        //public String sapPricing;
        public List<EUR_CRM_ProductCatalog__Share> sharing;
        public List<ProductHierarchyInfoWrapper> productsInfo;
        public List<String> templDelDates;

    }

    public class ProductHierarchyInfoWrapper {
        public List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper> dynamicfields = new List<EUR_CRM_OP_DynamicFieldService.OPObjectFieldsWrapper>();
        public EUR_CRM_ProductCatalogItem__c pbi = new EUR_CRM_ProductCatalogItem__c();

        public String View1Level1;
        public String View1Level2;
        public String View1Level3;
        public String View1Level4;
        public String View2Level1;
        public String View2Level2;
        public String View2Level3;
        public String View2Level4;
        public String ProductLevel1;
        public String ProductLevel2;
        public String ProductLevel3;
        public String ProductLevel4;
        public String ProductLevel5;
        public String MarketingLevel1;
        public String MarketingLevel2;
        public String MarketingLevel3;
        public String MarketingLevel4;
        public String OrderView1;
        public String OrderView2;
        public String multiplication_factor;
        public String productId;
        
        public Date ExpectAvailabiltyDate;
        public Date DelStart;
        public Date DelEnd;
        public Date OOSStart;
        public Date OOSEnd;
        public Date PrStart;
        public Date PrEnd;
        public Integer MinQty;
        public Integer MaxQty;
        public Integer Pckg; 
        public Integer TemplQty;
        public Decimal Price;
        
        public List<TemplatePBI> templPBIs = new List<TemplatePBI>();
    }

    public class AccountGroupInfoWrapper {
        public String groupId;
        public String groupName;
        public Boolean isDynamic;
        public String criteria;
        public List<Id> accIds;
    }
    
    public class TemplatePBI {
        @auraEnabled
        public Id pbiId;
        @auraEnabled
        public String delDate;
        @auraEnabled
        public Integer delQty;
    }
  
}