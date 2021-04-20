public with sharing class EUR_CRM_ObjPromoTargetMngmntCtrl {

    @TestVisible private static final String BRAND = 'EUR_CRM_Brand__c';
    @TestVisible private static final String BRAND_QUALITY = 'EUR_CRM_Quality__c';
    @TestVisible private static final String BRAND_QUALITY_SIZE = 'EUR_CRM_Size__c';
    @TestVisible private static final String SKU = 'EUR_CRM_SKU__c';
    @TestVisible private static final String POS_MATERIAL = 'EUR_CRM_POS_Material__c';
    @TestVisible private static final String PRODUCT_TOOLKIT = 'EUR_CRM_Product_Toolkit__c';

    @TestVisible private static final String SUCCESS_RESULT = 'OK';
    @TestVisible private static final String DEFAULT_SECTION_TO_DISPLAY = 'Sales Representative Level';
    @TestVisible private static final String GENERAL_LEVEL = 'General Level';
    @TestVisible private static final String MANAGER_LEVEL = 'Manager Level';

    @TestVisible private static Map<String, String> productFieldApiOnOPPRoductByProductApiName = new Map<String, String> {
        BRAND => 'EUR_CRM_Brand__c'
    ,   BRAND_QUALITY => 'EUR_CRM_Brand_Quality__c'
    ,   BRAND_QUALITY_SIZE => 'EUR_CRM_Brand_Quality_Size__c'
    ,   SKU => 'EUR_CRM_SKU_EU__c'
    ,   POS_MATERIAL => 'EUR_CRM_POS_Material__c'
    ,   PRODUCT_TOOLKIT => 'EUR_CRM_Product_Toolkit__c'
    };

    private static final Set<String> SALES_REP_AND_MANAGER_TARGET_FIELDS_TO_SUM = new Set<String> {
        'EUR_CRM_Target_No_of_Display__c'
    ,   'EUR_CRM_Target_No_of_Events__c'
    ,   'EUR_CRM_Target_Quantity_Facings__c'
    ,   'EUR_CRM_Target_Quantity_Listing__c'
    ,   'EUR_CRM_Target_Quantity_People__c'
    ,   'EUR_CRM_Target_Quantity_Promo_Kits__c'
    ,   'EUR_CRM_Target_Quantity_Spyders__c'
    ,   'EUR_CRM_Target_Sell_in_Amount_Bottle__c'
    ,   'EUR_CRM_Target_Sell_in_Amount_Carton__c'
    ,   'EUR_CRM_Target_Sell_in_Amount_Display__c'
    ,   'EUR_CRM_Target_Sell_in_Volume_Pallet__c'
    ,   'EUR_CRM_Target_Sell_in_Volume_SKU__c'
    };



    /* ========================================================= */
    /*     Interface (Getters)
    /* ========================================================= */
    @AuraEnabled
    public static String getSectionsToDisplay(String recordId) {
        String sectionsToShow = selectSectionsToShow(recordId);
        return String.isBlank(sectionsToShow) ? DEFAULT_SECTION_TO_DISPLAY : sectionsToShow;
    }

    @AuraEnabled
    public static List<ProductWrapper> getInitialTargets(String recordId) {
        List<String> targetFieldsToShow = getListOfFieldsToShow(recordId);
        /*if (targetFieldsToShow.isEmpty()) {
            System.debug('\n\n Issue: There are no fields to show on the Target Management Section! \n');
            return new List<ProductWrapper>();
        }*/
        System.debug('\n targetFieldsToShow => \n' + JSON.serializePretty(targetFieldsToShow) + '\n');

        List<ManagerUserWrapper> managerUserWrappers = getManagersWithSalesRepsForOP(recordId);

        Map<String, String> dependedFieldsByMainFieldToShow = getDependedFieldsByMainFieldToShow(targetFieldsToShow);
        List<String> listOfDependedFields = getListOfDependedFields(dependedFieldsByMainFieldToShow);

        String existQuery = getInitialQuery(recordId, targetFieldsToShow, listOfDependedFields);
        System.debug(existQuery);
        List<EUR_CRM_OP_Target_REP__c> targetReps = (List<EUR_CRM_OP_Target_REP__c>)Database.query(existQuery);
        if (targetReps.isEmpty()) { return new List<ProductWrapper>(); }

        List<ProductWrapper> productWrappers = convertToProductWrappers(targetReps);
        if( ! managerUserWrappers.isEmpty()) {
            productWrappers = addAllManagersWithSalesReps(productWrappers, managerUserWrappers);
        }
        return populateColumnWrappers(productWrappers, targetFieldsToShow, dependedFieldsByMainFieldToShow);
    }

    @AuraEnabled
    public static List<ProductWrapper> getProductsWithManagersAndSalesReps(String productWrapperAsJSON, String productIdsJSON, String recordId, String accountIdsAsJSON) {
        Set<String> productIds = (Set<String>)System.JSON.deserializeStrict(productIdsJSON, Set<String>.class);
        if (productIds.isEmpty()) { return new List<ProductWrapper>(); }

        Map<String, Set<String>> productIdsByProductApiName = getProductIdsByProductApiName(productIds);
        if (productIdsByProductApiName.isEmpty()) {
            System.debug('\n\n Issue: Wrong products! \n');
            return new List<ProductWrapper>();
        }

        List<String> targetFieldsToShow = getListOfFieldsToShow(recordId);
//        if (targetFieldsToShow.isEmpty()) {
//            System.debug('\n\n Issue: There are no fields to show on the Target Management Section! \n');
//            return new List<ProductWrapper>();
//        }

        List<ManagerUserWrapper> managerUserWrappers = new List<ManagerUserWrapper>();
        Set<Id> accountIds = (Set<Id>)System.JSON.deserializeStrict(accountIdsAsJSON, Set<Id>.class);
        if (! accountIds.isEmpty()) {
            managerUserWrappers = getManagersWithSalesRepsForAccounts(accountIds);
        } else {
            managerUserWrappers = getManagersWithSalesRepsForOP(recordId);
        }
        if (managerUserWrappers.isEmpty()) {
            System.debug('\n\n Issue: There are no managers! \n');
            return new List<ProductWrapper>();
        }

        List<ProductWrapper> productWrappers = new List<ProductWrapper>();
        for (String productApiName : productIdsByProductApiName.keySet()) {
            String query = 'SELECT Id, Name FROM {0} WHERE Id IN ({1}) ORDER BY Name';
            Set<String> currentProductIds = productIdsByProductApiName.get(productApiName);
            query = query.replace('{0}', productApiName);
            String listOfIds = '\'' + String.join(new List<String>(currentProductIds), '\', \'') + '\'';
            query = query.replace('{1}', listOfIds);
            List<SObject> products = Database.query(query);

            for (SObject product : products) {
                EUR_CRM_OP_Product__c opProduct = new EUR_CRM_OP_Product__c(EUR_CRM_Objectives_Promotions__c = recordId);
                opProduct.put(productFieldApiOnOPPRoductByProductApiName.get(productApiName), product.Id);
                productWrappers.add(new ProductWrapper(opProduct, product, managerUserWrappers));
            }
        }
        Map<String, String> dependedFieldsByMainFieldToShow = getDependedFieldsByMainFieldToShow(targetFieldsToShow);
        productWrappers = populateColumnWrappers(productWrappers, targetFieldsToShow, dependedFieldsByMainFieldToShow);

        List<ProductWrapper> resultList = new List<ProductWrapper>();
        if ( ! String.isBlank(productWrapperAsJSON)) {
            List<ProductWrapper> existProductWrappers = (List<ProductWrapper>)JSON.deserialize(productWrapperAsJSON, List<ProductWrapper>.class);
            resultList.addAll(existProductWrappers);
        }
        resultList.addAll(productWrappers);
        return resultList;
    }

    @AuraEnabled
    public static List<ProductWrapper> updateFormulaFields(String productWrapperAsJSON) {
        List<ProductWrapper> productWrappers = (List<ProductWrapper>)JSON.deserialize(productWrapperAsJSON, List<ProductWrapper>.class);

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = new List<EUR_CRM_OP_Promo_Target__c>();
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = new List<EUR_CRM_OP_Target_Manager__c>();
        List<EUR_CRM_OP_Target_REP__c> targetReps = new List<EUR_CRM_OP_Target_REP__c>();
        for (ProductWrapper pw : productWrappers) {
            promoTargets.add(extractPromoTarget(pw));

            for (ManagerWrapper mw : pw.managers) {
                targetManagers.add(extractTargetManager(mw));

                for (SalesRepWrapper sw : mw.salesReps) {
                    targetReps.add(extractTargetRep(sw));
                }
            }
        }

        recalculateFormulas(promoTargets);
        recalculateFormulas(targetManagers);
        recalculateFormulas(targetReps);

        copyFormulaFieldsToProductWrappers(productWrappers, promoTargets, targetManagers, targetReps);

        return productWrappers;
    }

    @AuraEnabled
    public static String createTargets(String productWrapperAsJSON, String recordId) {
        List<ProductWrapper> productWrappers = (List<ProductWrapper>)JSON.deserialize(productWrapperAsJSON, List<ProductWrapper>.class);
        System.debug('\n\n productWrappers.size() => ' + JSON.serializePretty(productWrappers.size()) + '\n');
        System.debug('\n\n productWrappers => ' + JSON.serializePretty(productWrappers) + '\n');

        List<EUR_CRM_OP_Product__c> opProducts = new List<EUR_CRM_OP_Product__c>();
        List<EUR_CRM_OP_Promo_Target__c> promoTargets = new List<EUR_CRM_OP_Promo_Target__c>();
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = new List<EUR_CRM_OP_Target_Manager__c>();
        List<EUR_CRM_OP_Target_REP__c> targetReps = new List<EUR_CRM_OP_Target_REP__c>();
        Map<ProductWrapper, Map<EUR_CRM_OP_Promo_Target__c, List<EUR_CRM_OP_Target_Manager__c>>> targetManagersByPromoTargetByProductWrapper = new Map<ProductWrapper, Map<EUR_CRM_OP_Promo_Target__c, List<EUR_CRM_OP_Target_Manager__c>>>();
        Map<ManagerWrapper, Map<EUR_CRM_OP_Target_Manager__c, List<EUR_CRM_OP_Target_REP__c>>> targetRepsByTargetManagerByManagerWrapper = new Map<ManagerWrapper, Map<EUR_CRM_OP_Target_Manager__c, List<EUR_CRM_OP_Target_REP__c>>>();

        for (ProductWrapper pw : productWrappers) {
            opProducts.add(pw.product);
            EUR_CRM_OP_Promo_Target__c promoTarget = extractPromoTarget(pw);
            promoTargets.add(promoTarget);

            List<EUR_CRM_OP_Target_Manager__c> tempTargetManagers = new List<EUR_CRM_OP_Target_Manager__c>();
            for (ManagerWrapper mw : pw.managers) {
                EUR_CRM_OP_Target_Manager__c targetManager = extractTargetManager(mw);
                targetManagers.add(targetManager);
                tempTargetManagers.add(targetManager);

                List<EUR_CRM_OP_Target_REP__c> tempTargetReps = new List<EUR_CRM_OP_Target_REP__c>();
                for (SalesRepWrapper sw : mw.salesReps) {
                    EUR_CRM_OP_Target_REP__c targetRep = extractTargetRep(sw);
                    targetReps.add(targetRep);
                    tempTargetReps.add(targetRep);
                }
                Map<EUR_CRM_OP_Target_Manager__c, List<EUR_CRM_OP_Target_REP__c>> targetRepsByTargetManager = getTargetRepsByTargetManagerMap(targetManager, tempTargetReps);
                targetRepsByTargetManagerByManagerWrapper.put(mw, targetRepsByTargetManager);
            }
            Map<EUR_CRM_OP_Promo_Target__c, List<EUR_CRM_OP_Target_Manager__c>> targetManagersByPromoTarget = getTargetManagersByPromoTargetMap(promoTarget, tempTargetManagers);
            targetManagersByPromoTargetByProductWrapper.put(pw, targetManagersByPromoTarget);
        }

        System.debug('\n targetRepsByTargetManagerByManagerWrapper.size() => ' + targetRepsByTargetManagerByManagerWrapper.size() + '\n');
        System.debug('\n targetRepsByTargetManagerByManagerWrapper => ' + JSON.serializePretty(targetRepsByTargetManagerByManagerWrapper) + '\n');
        System.debug('\n targetManagersByPromoTargetByProductWrapper.size() => ' + targetManagersByPromoTargetByProductWrapper.size() + '\n');
        System.debug('\n targetManagersByPromoTargetByProductWrapper => ' + JSON.serializePretty(targetManagersByPromoTargetByProductWrapper) + '\n');
        System.debug('\n\n init opProducts.size() => ' + JSON.serializePretty(opProducts.size()) + '\n');
        System.debug('\n\n init opProducts => ' + JSON.serializePretty(opProducts) + '\n');
        System.debug('\n\n init promoTargets.size() => ' + JSON.serializePretty(promoTargets.size()) + '\n');
        System.debug('\n\n init promoTargets => ' + JSON.serializePretty(promoTargets) + '\n');
        System.debug('\n\n init targetManagers.size() => ' + JSON.serializePretty(targetManagers.size()) + '\n');
        System.debug('\n\n init targetManagers => ' + JSON.serializePretty(targetManagers) + '\n');
        System.debug('\n\n init targetReps.size() => ' + JSON.serializePretty(targetReps.size()) + '\n');
        System.debug('\n\n init targetReps => ' + JSON.serializePretty(targetReps) + '\n');

        opProducts = populateWithExistOPProductIds(opProducts, recordId);
        System.debug('\n\n opProducts.size() => ' + JSON.serializePretty(opProducts.size()) + '\n');
        System.debug('\n\n opProducts => ' + JSON.serializePretty(opProducts) + '\n');

        Set<Id> productIdsToDelete = getProductsToDelete(opProducts, recordId);
        System.debug('\n productsToDelete.size() => ' + productIdsToDelete.size() + '\n');
        System.debug('\n productsToDelete => ' + JSON.serializePretty(productIdsToDelete) + '\n');

        Database.delete(new List<Id>(productIdsToDelete));
        upsert opProducts;

        promoTargets = populateParentLinkOnPromoTargets(promoTargets, recordId, opProducts);
        System.debug('\n\n promoTargets.size() => ' + JSON.serializePretty(promoTargets.size()) + '\n');
        System.debug('\n\n promoTargets => ' + JSON.serializePretty(promoTargets) + '\n');
        upsert promoTargets;

        targetManagers = populateParentLinkOnTargetManagers(targetManagers, productWrappers, recordId, opProducts, promoTargets);
        EUR_CRM_Objectives_Promotions__c op = getObjectivesPromotionsWhereId(recordId);

        Boolean needToCreateFakeTargets = isNeedToCreateFakeTargets(op);
        Boolean needToPopulateManagerLevel = isNeedToPopulateManagerLevel(op);
        Boolean needToPopulateGeneralLevel = isNeedToPopulateGeneralLevel(op);
        System.debug('\n\n needToCreateFakeTargets => ' + JSON.serializePretty(needToCreateFakeTargets) + '\n');
        System.debug('\n needToPopulateManagerLevel => ' + JSON.serializePretty(needToPopulateManagerLevel) + '\n');
        System.debug('\n needToPopulateGeneralLevel => ' + JSON.serializePretty(needToPopulateGeneralLevel) + '\n');

        if( ! needToCreateFakeTargets && needToPopulateManagerLevel) {
            populateTargetManagers(targetRepsByTargetManagerByManagerWrapper);
        }

        if ( ! needToCreateFakeTargets && needToPopulateGeneralLevel) {
            List<EUR_CRM_OP_Promo_Target__c> promoTargetsToUpdate = populateAndGetPromoTargetsToUpdate(targetManagersByPromoTargetByProductWrapper);
            System.debug('\n promoTargetsToUpdate.size() => ' + promoTargetsToUpdate.size() + '\n');
            System.debug('\n promoTargetsToUpdate => ' + JSON.serializePretty(promoTargetsToUpdate) + '\n');
            update promoTargetsToUpdate;
        }

        if(needToCreateFakeTargets) {
//            targetManagers = selectTargetManagers(targetManagers);
            targetManagers = makeNewFakeTargetManagers(promoTargets, targetManagers);
        }
        System.debug('\n\n targetManagers.size() => ' + JSON.serializePretty(targetManagers.size()) + '\n');
        System.debug('\n\n targetManagers => ' + JSON.serializePretty(targetManagers) + '\n');
        upsert targetManagers;

        targetReps = populateParentLinkOnTargetReps(targetReps, productWrappers, recordId, opProducts, targetManagers);
        if(needToCreateFakeTargets) {
//            targetReps = selectTargetReps(targetManagers);
            targetReps = makeNewFakeTargetReps(targetManagers, targetReps);
        }
        System.debug('\n\n targetReps.size() => ' + JSON.serializePretty(targetReps.size()) + '\n');
        System.debug('\n\n targetReps => ' + JSON.serializePretty(targetReps) + '\n');
        upsert targetReps;

        return SUCCESS_RESULT;
    }

    private static Set<Id> getProductsToDelete(List<EUR_CRM_OP_Product__c> opProducts, String recordId) {
        Set<Id> productIdsToDelete = new Set<Id>();
        Map<Id, EUR_CRM_OP_Product__c> productsToUpdate = new Map<Id, EUR_CRM_OP_Product__c>();
        for (EUR_CRM_OP_Product__c prod : opProducts) {
            productsToUpdate.put(prod.Id, prod);
        }
        Map<Id, EUR_CRM_OP_Product__c> existOPProductById = new Map<Id, EUR_CRM_OP_Product__c>(selectOPProductsWhereOPId(recordId));
        for (Id productId : existOPProductById.keySet()) {
            if (productsToUpdate.containsKey(productId)) { continue; }
            productIdsToDelete.add(productId);
        }
        return productIdsToDelete;
    }

    @AuraEnabled
    public static String deletePromoTargets(String promoTargetId, String recordId) {
        List<EUR_CRM_OP_Promo_Target__c> promoTargets = selectPromoTargetsWhereId(recordId, promoTargetId);
        Id opProductId = promoTargets[0].EUR_CRM_OP_Product__c;
        delete promoTargets;

        List<EUR_CRM_OP_Product__c> opProducts = selectOPProductWhereId(recordId, opProductId);
        if (hasOPProductNoPromoTargets(opProducts)) {
            delete opProducts;
        }

        return SUCCESS_RESULT;
    }

    @AuraEnabled
    public static String deleteTargetManagers(String targetManagerId, String recordId) {
        List<EUR_CRM_OP_Target_Manager__c> targetManagers = selectTargetManagersWhereId(recordId, targetManagerId);

        Id promoTargetId = targetManagers[0].EUR_CRM_OP_Promo_Target__c;
        Id opProductId = targetManagers[0].EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__c;
        delete targetManagers;

        List<EUR_CRM_OP_Promo_Target__c> promoTargets = selectPromoTargetsWhereId(recordId, promoTargetId);
        if (hasPromoTargetNoManagers(promoTargets)) {
            delete promoTargets;

            List<EUR_CRM_OP_Product__c> opProducts = selectOPProductWhereId(recordId, opProductId);
            if (hasOPProductNoPromoTargets(opProducts)) {
                delete opProducts;
            }
        }

        return SUCCESS_RESULT;
    }

    @AuraEnabled
    public static String deleteTargetReps(String targetRepId, String recordId) {
        List<EUR_CRM_OP_Target_REP__c> targetReps = selectTargetRepsWhereId(recordId, targetRepId);

        Id targetManagerId = targetReps[0].EUR_CRM_OP_Target_Manager__c;
        Id promoTargetId = targetReps[0].EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__c;
        Id opProductId = targetReps[0].EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__c;
        delete targetReps;

        List<EUR_CRM_OP_Target_Manager__c> targetManagers = selectTargetManagersWhereId(recordId, targetManagerId);
        if (hasTargetManagerNoSalesReps(targetManagers)) {
            delete targetManagers;

            List<EUR_CRM_OP_Promo_Target__c> promoTargets = selectPromoTargetsWhereId(recordId, promoTargetId);
            if (hasPromoTargetNoManagers(promoTargets)) {
                delete promoTargets;

                List<EUR_CRM_OP_Product__c> opProducts = selectOPProductWhereId(recordId, opProductId);
                if (hasOPProductNoPromoTargets(opProducts)) {
                    delete opProducts;
                }
            }
        }

        return SUCCESS_RESULT;
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private static List<ProductWrapper> convertToProductWrappers(List<EUR_CRM_OP_Target_REP__c> targetReps) {
        List<ProductWrapper> productWrappers = new List<ProductWrapper>();

        for (EUR_CRM_OP_Target_REP__c targetRep : targetReps) {
            ProductWrapper pw = new ProductWrapper(targetRep);
            ManagerWrapper mw = new ManagerWrapper(targetRep);
            SalesRepWrapper srw = new SalesRepWrapper(targetRep);

            Boolean isProductExist = false;
            for (ProductWrapper wrapper : productWrappers) {
                if (wrapper.product.Id == pw.product.Id) {
                    pw = wrapper;

                    Boolean isManagerExist = false;
                    for (ManagerWrapper managerWrapper : pw.managers) {
                        if (managerWrapper.targetManager.Id == mw.targetManager.Id) {
                            mw = managerWrapper;
                            isManagerExist = true;
                            break;
                        }
                    }
                    mw.addSalesRepWrapper(srw);
                    if ( ! isManagerExist) {
                        pw.addManagerWrapper(mw);
                    }

                    isProductExist = true;
                    break;
                }
            }

            if ( ! isProductExist) {
                mw.addSalesRepWrapper(srw);
                pw.addManagerWrapper(mw);
                productWrappers.add(pw);
            }
        }

        return productWrappers;
    }

    private static List<ProductWrapper> addAllManagersWithSalesReps(List<ProductWrapper> productWrappers, List<ManagerUserWrapper> managerUserWrappers) {
        for (ManagerUserWrapper managerUserWrapper : managerUserWrappers) {
            for (ProductWrapper productWrapper : productWrappers) {
                productWrapper.addManagerUser(managerUserWrapper);
            }
        }
        return productWrappers;
    }

    private static List<ProductWrapper> populateColumnWrappers(List<ProductWrapper> productWrappers, List<String> targetFieldsToShow, Map<String, String> dependedFieldsByMainFieldToShow) {
        List<ColumnWrapper> promoTargetColumnMetadata = getColumnWrappers('EUR_CRM_OP_Promo_Target__c', targetFieldsToShow, dependedFieldsByMainFieldToShow);
        List<ColumnWrapper> targetManagerColumnMetadata = getColumnWrappers('EUR_CRM_OP_Target_Manager__c', targetFieldsToShow, dependedFieldsByMainFieldToShow);
        List<ColumnWrapper> salesRepColumnMetadata = getColumnWrappers('EUR_CRM_OP_Target_REP__c', targetFieldsToShow, dependedFieldsByMainFieldToShow);

        for (ProductWrapper productWrapper : productWrappers) {
            for (ColumnWrapper cw : promoTargetColumnMetadata) {
                productWrapper.columnWrappers.add(new ColumnWrapper(cw.fieldLabel, cw.fieldName, String.valueOf(cw.data), cw.editable, cw.infoField));
            }

            for (ManagerWrapper manager : productWrapper.managers) {
                for (ColumnWrapper cw : targetManagerColumnMetadata) {
                    manager.columnWrappers.add(new ColumnWrapper(cw.fieldLabel, cw.fieldName, String.valueOf(cw.data), cw.editable, cw.infoField));
                }

                for (SalesRepWrapper salesRep : manager.salesReps) {
                    for (ColumnWrapper cw : salesRepColumnMetadata) {
                        salesRep.columnWrappers.add(new ColumnWrapper(cw.fieldLabel, cw.fieldName, String.valueOf(cw.data), cw.editable, cw.infoField));
                    }

                    salesRep.extractData();
                }

                manager.extractData();
            }

            productWrapper.extractData();
        }
        return productWrappers;
    }

    private static Map<String, Set<String>> getProductIdsByProductApiName(Set<String> productIds) {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        Map<String, Set<String>> productIdsByProductApiName = new Map<String, Set<String>>();
        for (String productId : productIds) {
            String keyCode  = productId.substring(0,3);

            for(Schema.SObjectType objectInstance : globalDescribe.values()) {
                String prefix = objectInstance.getDescribe().getKeyPrefix();
                String sobjectAPI = objectInstance.getDescribe().getName();
                if(prefix != null && prefix.equals(keyCode)) {
                    if (productIdsByProductApiName.containsKey(sobjectAPI)) {
                        productIdsByProductApiName.get(sobjectAPI).add(productId);
                    } else {
                        productIdsByProductApiName.put(sobjectAPI, new Set<String> { productId });
                    }
                    break;
                }
            }
        }
        return productIdsByProductApiName;
    }

    public static List<ManagerUserWrapper> getManagersWithSalesRepsForOP(Id opId) {
        Id atgId = selectAccountTargetGroupIdOfOP(opId);
        if (atgId == null) { return new List<ManagerUserWrapper>(); }

        List<EUR_CRM_Account__c> accounts = selectAccountsWithOwnerAndRegionOwner(atgId);
        if (accounts.isEmpty()) { return new List<ManagerUserWrapper>(); }

        List<ManagerUserWrapper> managerUserWrappers = getManagerUserWrappers(accounts);
        return managerUserWrappers;
    }

    public static List<ManagerUserWrapper> getManagersWithSalesRepsForAccounts(Set<Id> accIds) {
        List<EUR_CRM_Account__c> accounts = selectAccountsWithOwnerAndRegionOwner(accIds);
        if (accounts.isEmpty()) { return new List<ManagerUserWrapper>(); }

        List<ManagerUserWrapper> managerUserWrappers = getManagerUserWrappers(accounts);
        return managerUserWrappers;
    }

    private static List<EUR_CRM_OP_Target_Manager__c> makeNewFakeTargetManagers(List<EUR_CRM_OP_Promo_Target__c> promoTargets, List<EUR_CRM_OP_Target_Manager__c> targetManagers){
        Map<Id, EUR_CRM_OP_Target_Manager__c> existingTargetManagersByPromoTargetIds = new Map<Id, EUR_CRM_OP_Target_Manager__c>();
        for (EUR_CRM_OP_Target_Manager__c tManager : targetManagers) {
            existingTargetManagersByPromoTargetIds.put(tManager.EUR_CRM_OP_Promo_Target__c, tManager);
        }

        List<EUR_CRM_OP_Target_Manager__c> fakeTargetManagers = new List<EUR_CRM_OP_Target_Manager__c>();
        for(EUR_CRM_OP_Promo_Target__c promoTarget : promoTargets) {
            if ( !existingTargetManagersByPromoTargetIds.containsKey(promoTarget.Id)) {
                EUR_CRM_OP_Target_Manager__c newManager = new EUR_CRM_OP_Target_Manager__c(
                    EUR_CRM_OP_Promo_Target__c = promoTarget.Id
                ,   EUR_CRM_OP_Product__c = promoTarget.EUR_CRM_OP_Product__c
                ,   EUR_CRM_Objectives_Promotions__c = promoTarget.EUR_CRM_Objectives_Promotions__c
                );
                fakeTargetManagers.add(newManager);
            }
        }
        return fakeTargetManagers;
    }

    private static List<EUR_CRM_OP_Target_REP__c> makeNewFakeTargetReps(List<EUR_CRM_OP_Target_Manager__c> targetManagers, List<EUR_CRM_OP_Target_REP__c> targetReps) {
        Map<Id, EUR_CRM_OP_Target_REP__c> existingTargetRepsByTargetManagerIds = new Map<Id, EUR_CRM_OP_Target_REP__c>();
        for(EUR_CRM_OP_Target_REP__c targetRep : targetReps) {
            existingTargetRepsByTargetManagerIds.put(targetRep.EUR_CRM_OP_Target_Manager__c, targetRep);
        }

        List<EUR_CRM_OP_Target_REP__c> fakeTargetReps = new List<EUR_CRM_OP_Target_REP__c>();
        for(EUR_CRM_OP_Target_Manager__c targetManager : targetManagers) {
            if ( !existingTargetRepsByTargetManagerIds.containsKey(targetManager.Id)) {
                EUR_CRM_OP_Target_REP__c newREP = new EUR_CRM_OP_Target_REP__c(
                    EUR_CRM_OP_Product__c = targetManager.EUR_CRM_OP_Product__c
                ,   EUR_CRM_OP_Target_Manager__c = targetManager.Id
                ,   EUR_CRM_Objectives_Promotions__c = targetManager.EUR_CRM_Objectives_Promotions__c
                );
                fakeTargetReps.add(newREP);
            }
        }
        return fakeTargetReps;
    }

    private static void populateTargetManagers(Map<ManagerWrapper, Map<EUR_CRM_OP_Target_Manager__c, List<EUR_CRM_OP_Target_REP__c>>> targetRepsByTargetManagerByManagerWrapper) {
        for (Map<EUR_CRM_OP_Target_Manager__c, List<EUR_CRM_OP_Target_REP__c>>  targetRepsByTargetManager: targetRepsByTargetManagerByManagerWrapper.values()) {
            Map<String, Decimal> targetRepFieldValSumByName = new Map<String, Decimal>();

            for (List<EUR_CRM_OP_Target_REP__c> targetRepsByOneManager : targetRepsByTargetManager.values()) {
                for (EUR_CRM_OP_Target_REP__c targetRep : targetRepsByOneManager) {
                    for (String fieldName : SALES_REP_AND_MANAGER_TARGET_FIELDS_TO_SUM) {
                        Decimal tarRepFieldVal = (Decimal) targetRep.get(fieldName);
                        if (tarRepFieldVal == null) { continue; }
                        targetRepFieldValSumByName = populateTargetSumFieldValueByNameMap(targetRepFieldValSumByName, fieldName, tarRepFieldVal);
                    }
                }

                for (EUR_CRM_OP_Target_Manager__c tarManager : targetRepsByTargetManager.keySet()) {
                    for (String fieldName : targetRepFieldValSumByName.keySet()) {
                        Decimal fieldValue = targetRepFieldValSumByName.get(fieldName);
                        tarManager.put(fieldName, fieldValue);
                    }
                }
            }
        }
    }

    private static List<EUR_CRM_OP_Promo_Target__c> populateAndGetPromoTargetsToUpdate(Map<ProductWrapper, Map<EUR_CRM_OP_Promo_Target__c, List<EUR_CRM_OP_Target_Manager__c>>> targetManagersByPromoTargetByProductWrapper) {
        List<EUR_CRM_OP_Promo_Target__c> promoTargetsToUpdate = new List<EUR_CRM_OP_Promo_Target__c>();
        for (Map<EUR_CRM_OP_Promo_Target__c, List<EUR_CRM_OP_Target_Manager__c>> targetManagersByPromoTarget : targetManagersByPromoTargetByProductWrapper.values()) {
            System.debug('\n targetManagersByPromoTarget.size() => ' + targetManagersByPromoTarget.size() + '\n');
            System.debug('\n targetManagersByPromoTarget => ' + JSON.serializePretty(targetManagersByPromoTarget) + '\n');
            Map<String, Decimal> targetManagerFieldValSumByName = new Map<String, Decimal>();
            for (List<EUR_CRM_OP_Target_Manager__c> targetManagerByOnePromo : targetManagersByPromoTarget.values()) {
                for (EUR_CRM_OP_Target_Manager__c targetManager : targetManagerByOnePromo) {
                    for (String fieldName : SALES_REP_AND_MANAGER_TARGET_FIELDS_TO_SUM) {
                        Decimal tarManFieldVal = (Decimal) targetManager.get(fieldName);
                        if (tarManFieldVal == null) {
                            continue;
                        }
                        targetManagerFieldValSumByName = populateTargetSumFieldValueByNameMap(targetManagerFieldValSumByName, fieldName, tarManFieldVal);
                    }
                }
            }

            for (EUR_CRM_OP_Promo_Target__c promoTarget : targetManagersByPromoTarget.keySet()) {
                for (String fieldName : targetManagerFieldValSumByName.keySet()) {
                    Decimal fieldValue = targetManagerFieldValSumByName.get(fieldName);
                    promoTarget.put(fieldName, fieldValue);
                }
            }
            promoTargetsToUpdate.addAll(targetManagersByPromoTarget.keySet());
        }
        return promoTargetsToUpdate;
    }

    private static Map<EUR_CRM_OP_Target_Manager__c, List<EUR_CRM_OP_Target_REP__c>> getTargetRepsByTargetManagerMap(
            EUR_CRM_OP_Target_Manager__c targetManager
        ,   List<EUR_CRM_OP_Target_REP__c> tempTargetReps) {

        Map<EUR_CRM_OP_Target_Manager__c, List<EUR_CRM_OP_Target_REP__c>> targetRepsByTargetManager = new Map<EUR_CRM_OP_Target_Manager__c, List<EUR_CRM_OP_Target_REP__c>>();
        if (targetRepsByTargetManager.containsKey(targetManager)) {
            targetRepsByTargetManager.get(targetManager).addAll(tempTargetReps);
        } else {
            targetRepsByTargetManager.put(targetManager, tempTargetReps);
        }
        return targetRepsByTargetManager;
    }

    private static Map<EUR_CRM_OP_Promo_Target__c, List<EUR_CRM_OP_Target_Manager__c>> getTargetManagersByPromoTargetMap(
            EUR_CRM_OP_Promo_Target__c promoTarget
        ,   List<EUR_CRM_OP_Target_Manager__c> tempTargetManagers) {

        Map<EUR_CRM_OP_Promo_Target__c, List<EUR_CRM_OP_Target_Manager__c>> targetManagersByPromoTarget = new Map<EUR_CRM_OP_Promo_Target__c, List<EUR_CRM_OP_Target_Manager__c>>();
        if (targetManagersByPromoTarget.containsKey(promoTarget)) {
            targetManagersByPromoTarget.get(promoTarget).addAll(tempTargetManagers);
        } else {
            targetManagersByPromoTarget.put(promoTarget, tempTargetManagers);
        }
        return targetManagersByPromoTarget;
    }

    private static Map<String, Decimal> populateTargetSumFieldValueByNameMap(Map<String, Decimal> targetRepSumFieldValByName, String fieldName, Decimal fieldValue) {

        if (targetRepSumFieldValByName.containsKey(fieldName)) {
            Decimal tempVal = targetRepSumFieldValByName.get(fieldName) + fieldValue;
            targetRepSumFieldValByName.put(fieldName, tempVal);
        } else {
            targetRepSumFieldValByName.put(fieldName, fieldValue);
        }
        return targetRepSumFieldValByName;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private static List<String> getListOfFieldsToShow(String recordId) {
//        EUR_CRM_Objectives_Promotions__c op = [SELECT Id, EUR_CRM_OP_Template__c From EUR_CRM_Objectives_Promotions__c WHERE Id = :recordId];
//        List<EUR_CRM_OP_Template__c> templates = [SELECT Id, EUR_CRM_Has_Target__c FROM EUR_CRM_OP_Template__c WHERE Id = :op.EUR_CRM_OP_Template__c LIMIT 1];
        List<EUR_CRM_OP_Action__c> opActions = selectOPActionsForTemplateRelatedToOP(recordId);

        Set<String> fieldSet = new Set<String>();
        List<String> fieldList = new List<String>();
        for (EUR_CRM_OP_Action__c opAction : opActions) {
            System.debug(opAction);
            if (opAction.EUR_CRM_MultiPLOpTarget__c == null) {
//                if ( !hasTemplateTarget(templates)) {
//                    fieldList.add('EUR_CRM_Target_Sell_in_Amount_Display__c');
//                    fieldSet.add('EUR_CRM_Target_Sell_in_Amount_Display__c');
//                }
                continue;
            }

            for (String fieldApiName : opAction.EUR_CRM_MultiPLOpTarget__c.split(',')) {
                if ( ! fieldSet.contains(fieldApiName)) {
                    fieldSet.add(fieldApiName);
                    fieldList.add(fieldApiName);
                }
            }
        }

        Map<String, Boolean> isValidFieldByFieldNameForPromoTarget = getIsValidFieldByFieldNameMap(fieldList, 'EUR_CRM_OP_Promo_Target__c');
        Map<String, Boolean> isValidFieldByFieldNameForTargetManager = getIsValidFieldByFieldNameMap(fieldList, 'EUR_CRM_OP_Target_Manager__c');
        Map<String, Boolean> isValidFieldByFieldNameForTargetRep = getIsValidFieldByFieldNameMap(fieldList, 'EUR_CRM_OP_Target_REP__c');

        List<String> resultFieldList = new List<String>();
        for (String fieldName : fieldList) {
            if (
//                !hasTemplateTarget(templates) ||
                isValidFieldByFieldNameForPromoTarget.get(fieldName) == true &&
                isValidFieldByFieldNameForTargetManager.get(fieldName) == true &&
                isValidFieldByFieldNameForTargetRep.get(fieldName) == true) {
                resultFieldList.add(fieldName);
            }
        }
        return resultFieldList;
    }

    private static List<ManagerUserWrapper> getManagerUserWrappers(List<EUR_CRM_Account__c> accounts) {
        Set<Id> addedManagers = new Set<Id>();
        List<ManagerUserWrapper> managerUserWrappers = new List<ManagerUserWrapper>();
        for (EUR_CRM_Account__c account : accounts) {
            if (addedManagers.contains(account.EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c)) {
                for (ManagerUserWrapper managerUserWrapper : managerUserWrappers) {
                    if (managerUserWrapper.manager.Id == account.EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c) {
                        managerUserWrapper.addSalesRep(account);
                        break;
                    }
                }
            } else {
                ManagerUserWrapper managerUserWrapper = new ManagerUserWrapper(account);
                managerUserWrapper.addSalesRep(account);
                managerUserWrappers.add(managerUserWrapper);
                addedManagers.add(account.EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c);
            }
        }
        return managerUserWrappers;
    }

    private static Map<String, String> getDependedFieldsByMainFieldToShow(List<String> fieldList) {
        List<EUR_CRM_OP_Target_Confirmation_Fields__mdt> dependedFields = selectDependedFieldsRelatedTo(fieldList);

        Map<String, String> dependedFieldsByMainField = new Map<String, String>();
        for (EUR_CRM_OP_Target_Confirmation_Fields__mdt fields : dependedFields) {
            dependedFieldsByMainField.put(fields.EUR_CRM_Main_Target_API_Name_Field__c, fields.EUR_CRM_Dependent_Target_API_Name_Fields__c);
        }
        return dependedFieldsByMainField;
    }

    private static List<String> getListOfDependedFields(Map<String, String> relatedFieldsByMainField) {
        if (relatedFieldsByMainField.isEmpty()) { return new List<String>(); }

        Set<String> dependedFields = new Set<String>();
        for (String fieldNamesSeparatedByComa : relatedFieldsByMainField.values()) {
            dependedFields.addAll(fieldNamesSeparatedByComa.split(','));
        }
        return new List<String>(dependedFields);
    }

    private static Map<String, Boolean> getIsValidFieldByFieldNameMap(List<String> fieldList, String sObjectName) {
        Map<String, Boolean> isValidFieldByFieldName = new Map<String, Boolean>();
        for (String fieldName : fieldList) {
            isValidFieldByFieldName.put(fieldName, true);
        }

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        for (String fieldName : fieldList) {
            Boolean isValidField = isValidFieldByFieldName.get(fieldName);
            if (isValidField == false) { continue; }

            if (fieldMap.containsKey(fieldName)) {
                Schema.DisplayType fieldType = fieldMap.get(fieldName).getDescribe().getType();
                if (fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.INTEGER) {
                    isValidField = true;
                }
            } else {
                isValidField = false;
            }

            isValidFieldByFieldName.put(fieldName, isValidField);
        }
        return isValidFieldByFieldName;
    }

    private static String getInitialQuery(String recordId, List<String> targetFieldsToShow, List<String> listOfDependedFields) {
        String existQuery = 'SELECT Id'
            + ', EUR_CRM_Target_Owner__c'
            + ', EUR_CRM_Target_Owner__r.Name'
            + ', EUR_CRM_Objectives_Promotions__c'
            + ', EUR_CRM_OP_Product__c'
            + ', EUR_CRM_OP_Product__r.EUR_CRM_Objectives_Promotions__c'
            + ', EUR_CRM_OP_Product__r.EUR_CRM_Brand__c'
            + ', EUR_CRM_OP_Product__r.EUR_CRM_Brand__r.Name'
            + ', EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality__c'
            + ', EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality__r.Name'
            + ', EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality_Size__c'
            + ', EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality_Size__r.Name'
            + ', EUR_CRM_OP_Product__r.EUR_CRM_SKU_EU__c'
            + ', EUR_CRM_OP_Product__r.EUR_CRM_SKU_EU__r.Name'
            + ', EUR_CRM_OP_Product__r.EUR_CRM_POS_Material__c'
            + ', EUR_CRM_OP_Product__r.EUR_CRM_POS_Material__r.Name'
            + ', EUR_CRM_OP_Product__r.EUR_CRM_Product_Toolkit__c'
            + ', EUR_CRM_OP_Product__r.EUR_CRM_Product_Toolkit__r.Name'
            + '{0}'
            + ', EUR_CRM_OP_Target_Manager__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_Target_Owner__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_Target_Owner__r.Name'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__r.EUR_CRM_Objectives_Promotions__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand__r.Name'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality__r.Name'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality_Size__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality_Size__r.Name'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__r.EUR_CRM_SKU_EU__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__r.EUR_CRM_SKU_EU__r.Name'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__r.EUR_CRM_POS_Material__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__r.EUR_CRM_POS_Material__r.Name'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__r.EUR_CRM_Product_Toolkit__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Product__r.EUR_CRM_Product_Toolkit__r.Name'
            +  '{1}'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Objectives_Promotions__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand__r.Name'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality__r.Name'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality_Size__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality_Size__r.Name'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_SKU_EU__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_SKU_EU__r.Name'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_POS_Material__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_POS_Material__r.Name'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Product_Toolkit__c'
            + ', EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Product_Toolkit__r.Name'
            + '{2}'
            + ' FROM EUR_CRM_OP_Target_REP__c '
            + 'WHERE EUR_CRM_Objectives_Promotions__c = \'' + recordId + '\' '
            + 'ORDER BY EUR_CRM_OP_Product__r.Name';

        Set<String> targetFieldsWithDependedFieldsToShow = new Set<String>();
        targetFieldsWithDependedFieldsToShow.addAll(targetFieldsToShow);
        targetFieldsWithDependedFieldsToShow.addAll(listOfDependedFields);

        String salesRepsFieldsToShow = String.join(new List<String>(targetFieldsWithDependedFieldsToShow), ', ');
        if (salesRepsFieldsToShow != '') {
            salesRepsFieldsToShow = ', ' + salesRepsFieldsToShow;
        }
        existQuery = existQuery.replace('{0}', salesRepsFieldsToShow);

        List<String> managerFieldsToShow = new List<String>();
        for (String fieldApiName : targetFieldsWithDependedFieldsToShow) {
            managerFieldsToShow.add('EUR_CRM_OP_Target_Manager__r.' + fieldApiName);
        }
        if ( !managerFieldsToShow.isEmpty()) {
            managerFieldsToShow.add(0, '');
        }
        existQuery = existQuery.replace('{1}', String.join(managerFieldsToShow, ', '));

        List<String> promoFieldsToShow = new List<String>();
        for (String fieldApiName : targetFieldsWithDependedFieldsToShow) {
            promoFieldsToShow.add('EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.' + fieldApiName);
        }
        if ( !promoFieldsToShow.isEmpty()) {
            promoFieldsToShow.add(0, '');
        }
        existQuery = existQuery.replace('{2}', String.join(promoFieldsToShow, ', '));

        return existQuery;
    }

    private static List<ColumnWrapper> getColumnWrappers(String sobjectApi, List<String> targetFieldsToShow, Map<String, String> dependedFieldsByMainFieldToShow) {
        List<ColumnWrapper> columnWrappers = new List<ColumnWrapper>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sobjectApi).getDescribe().fields.getMap();
        for (String field : targetFieldsToShow) {
            if ( ! fieldMap.containsKey(field.toLowerCase())) { continue; }

            Schema.DescribeFieldResult fd = fieldMap.get(field).getDescribe();
            columnWrappers.add(new ColumnWrapper(fd.getLabel(), fd.getName(), String.valueOf(0), fd.isUpdateable(), false));

            if ( ! dependedFieldsByMainFieldToShow.containsKey(field)) { continue; }

            List<String> dependedFields = dependedFieldsByMainFieldToShow.get(field).split(',');
            for (String dependedFieldName : dependedFields) {
                if ( ! fieldMap.containsKey(dependedFieldName.toLowerCase())) { continue; }

                fd = fieldMap.get(dependedFieldName).getDescribe();
                columnWrappers.add(new ColumnWrapper(fd.getLabel(), fd.getName(), String.valueOf(0), false, true));
            }
        }
        return columnWrappers;
    }

    private static void copyFormulaFieldsToProductWrappers(
        List<ProductWrapper> productWrappers
        ,   List<EUR_CRM_OP_Promo_Target__c> promoTargets
        ,   List<EUR_CRM_OP_Target_Manager__c> targetManagers
        ,   List<EUR_CRM_OP_Target_REP__c> targetReps) {

        Integer currentPromoNumber = 0;
        Integer currentManagerNumber = 0;
        Integer currentSalesRepNumber = 0;
        for (Integer i = 0; i < productWrappers.size(); i++) {
            for (ColumnWrapper cw : productWrappers[i].columnWrappers) {
                if ( ! cw.editable && ! cw.infoField) {
                    cw.data = String.valueOf(promoTargets[currentPromoNumber++].get(cw.fieldName));
                }
            }

            for (Integer j = 0; j < productWrappers[i].managers.size(); j++) {
                for (ColumnWrapper cw : productWrappers[i].managers[j].columnWrappers) {
                    if ( ! cw.editable && ! cw.infoField) {
                        cw.data = String.valueOf(targetManagers[currentManagerNumber++].get(cw.fieldName));
                    }
                }

                for (Integer k = 0; k < productWrappers[i].managers[j].salesReps.size(); k++) {
                    for (ColumnWrapper cw : productWrappers[i].managers[j].salesReps[k].columnWrappers) {
                        if ( ! cw.editable && ! cw.infoField) {
                            cw.data = String.valueOf(targetReps[currentSalesRepNumber++].get(cw.fieldName));
                        }
                    }
                }
            }
        }
    }

    private static List<EUR_CRM_OP_Product__c> populateWithExistOPProductIds(List<EUR_CRM_OP_Product__c> opProducts, String recordId) {
        Map<Id, Id> opProductIdByProductId = getOPProductIdByProductId(recordId);
        if (opProductIdByProductId.isEmpty()) { return opProducts; }

        for (EUR_CRM_OP_Product__c opProduct : opProducts) {
            if (opProduct.EUR_CRM_Brand__c != null && opProductIdByProductId.containsKey(opProduct.EUR_CRM_Brand__c)) {
                opProduct.Id = opProductIdByProductId.get(opProduct.EUR_CRM_Brand__c);
            } else if (opProduct.EUR_CRM_Brand_Quality__c != null && opProductIdByProductId.containsKey(opProduct.EUR_CRM_Brand_Quality__c)) {
                opProduct.Id = opProductIdByProductId.get(opProduct.EUR_CRM_Brand_Quality__c);
            } else if (opProduct.EUR_CRM_Brand_Quality_Size__c != null && opProductIdByProductId.containsKey(opProduct.EUR_CRM_Brand_Quality_Size__c)) {
                opProduct.Id = opProductIdByProductId.get(opProduct.EUR_CRM_Brand_Quality_Size__c);
            } else if (opProduct.EUR_CRM_SKU_EU__c != null && opProductIdByProductId.containsKey(opProduct.EUR_CRM_SKU_EU__c)) {
                opProduct.Id = opProductIdByProductId.get(opProduct.EUR_CRM_SKU_EU__c);
            } else if (opProduct.EUR_CRM_POS_Material__c != null && opProductIdByProductId.containsKey(opProduct.EUR_CRM_POS_Material__c)) {
                opProduct.Id = opProductIdByProductId.get(opProduct.EUR_CRM_POS_Material__c);
            } else if (opProduct.EUR_CRM_Product_Toolkit__c != null && opProductIdByProductId.containsKey(opProduct.EUR_CRM_Product_Toolkit__c)) {
                opProduct.Id = opProductIdByProductId.get(opProduct.EUR_CRM_Product_Toolkit__c);
            }
        }
        return opProducts;
    }

    private static Map<Id, Id> getOPProductIdByProductId(String opId) {
        List<EUR_CRM_OP_Product__c> opProducts = selectOPProductsWhereOPId(opId);
        if (opProducts.isEmpty()) { return new Map<Id, Id>(); }

        Map<Id, Id> opProductIdByProductId = new Map<Id, Id>();
        for (EUR_CRM_OP_Product__c opProduct : opProducts) {
            if (opProduct.EUR_CRM_Brand__c != null) {
                opProductIdByProductId.put(opProduct.EUR_CRM_Brand__c, opProduct.Id);
            } else if (opProduct.EUR_CRM_Brand_Quality__c != null) {
                opProductIdByProductId.put(opProduct.EUR_CRM_Brand_Quality__c, opProduct.Id);
            } else if (opProduct.EUR_CRM_Brand_Quality_Size__c != null) {
                opProductIdByProductId.put(opProduct.EUR_CRM_Brand_Quality_Size__c, opProduct.Id);
            } else if (opProduct.EUR_CRM_SKU_EU__c != null) {
                opProductIdByProductId.put(opProduct.EUR_CRM_SKU_EU__c, opProduct.Id);
            } else if (opProduct.EUR_CRM_POS_Material__c != null) {
                opProductIdByProductId.put(opProduct.EUR_CRM_POS_Material__c, opProduct.Id);
            } else if (opProduct.EUR_CRM_Product_Toolkit__c != null) {
                opProductIdByProductId.put(opProduct.EUR_CRM_Product_Toolkit__c, opProduct.Id);
            }
        }
        return opProductIdByProductId;
    }

    private static List<EUR_CRM_OP_Promo_Target__c> populateParentLinkOnPromoTargets(
        List<EUR_CRM_OP_Promo_Target__c> promoTargets, String opId, List<EUR_CRM_OP_Product__c> products) {

        for (Integer i = 0; i < products.size(); i++) {
            promoTargets[i].EUR_CRM_Objectives_Promotions__c = opId;
            promoTargets[i].EUR_CRM_OP_Product__c = products[i].Id;
        }
        return promoTargets;
    }

    private static List<EUR_CRM_OP_Target_Manager__c> populateParentLinkOnTargetManagers(
        List<EUR_CRM_OP_Target_Manager__c> targetManagers
        , List<ProductWrapper> productWrappers
        , String opId
        , List<EUR_CRM_OP_Product__c> products
        , List<EUR_CRM_OP_Promo_Target__c> promoTargets) {

        Integer currentProductNumber = 0;
        Integer currentPromoNumber = 0;
        Integer currentManagerNumber = 0;
        for (Integer i = 0; i < productWrappers.size(); i++) {
            for (Integer j = 0; j < productWrappers[i].managers.size(); j++) {
                if (targetManagers[currentManagerNumber].get('Id') == null) {
                    targetManagers[currentManagerNumber].EUR_CRM_Target_Owner__c = productWrappers[i].managers[j].Id;
                    targetManagers[currentManagerNumber].EUR_CRM_Objectives_Promotions__c = opId;
                    targetManagers[currentManagerNumber].EUR_CRM_OP_Product__c = products[currentProductNumber].Id;
                    targetManagers[currentManagerNumber].EUR_CRM_OP_Promo_Target__c = promoTargets[currentPromoNumber].Id;
                }
                currentManagerNumber++;
            }
            currentProductNumber++;
            currentPromoNumber++;
        }
        return targetManagers;
    }

    private static List<EUR_CRM_OP_Target_REP__c> populateParentLinkOnTargetReps(
        List<EUR_CRM_OP_Target_REP__c> targetReps
        , List<ProductWrapper> productWrappers
        , String opId
        , List<EUR_CRM_OP_Product__c> products
        , List<EUR_CRM_OP_Target_Manager__c> targetManagers) {

        Integer currentProductNumber = 0;
        Integer currentManagerNumber = 0;
        Integer currentSalesRepNumber = 0;
        for (Integer i = 0; i < productWrappers.size(); i++) {
            for (Integer j = 0; j < productWrappers[i].managers.size(); j++) {
                for (Integer k = 0; k < productWrappers[i].managers[j].salesReps.size(); k++) {
                    if (targetReps[currentSalesRepNumber].get('Id') == null) {
                        targetReps[currentSalesRepNumber].EUR_CRM_Target_Owner__c = productWrappers[i].managers[j].salesReps[k].Id;
                        targetReps[currentSalesRepNumber].EUR_CRM_Objectives_Promotions__c = opId;
                        targetReps[currentSalesRepNumber].EUR_CRM_OP_Product__c = products[currentProductNumber].Id;
                        targetReps[currentSalesRepNumber].EUR_CRM_OP_Target_Manager__c = targetManagers[currentManagerNumber].Id;
                    }
                    currentSalesRepNumber++;
                }
                currentManagerNumber++;
            }
            currentProductNumber++;
        }
        return targetReps;
    }

    public static SObject safeRecalculationFormulas(SObject record) {
        SObject clone = record.getSObjectType().newSObject(record.Id);
        Map<String, Schema.SObjectField> fields = record.getSObjectType().getDescribe().fields.getMap();
        Map<String, Object> populatedFields = record.getPopulatedFieldsAsMap();
        Map<String, Object> nonEditableFields = new Map<String, Object>();

        for (String key:populatedFields.keySet()) {
            if (fields.get(key).getDescribe().isUpdateable()) {
                clone.put(key, populatedFields.get(key));
            } else if (!fields.get(key).getDescribe().isCalculated()) {
                nonEditableFields.put(key, populatedFields.get(key));
            }
        }
        clone.recalculateFormulas(); // safe recalc

        Map<String, Object> untypedClone = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(clone));
        for (String key: nonEditableFields.keySet()) {
            untypedClone.put(key, nonEditableFields.get(key));
        }
        record = (SObject)JSON.deserialize(JSON.serialize(untypedClone), Type.forName(record.getSObjectType().getDescribe().getName()));
        return record;
    }

    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private static void recalculateFormulas(List<EUR_CRM_OP_Promo_Target__c> promoTargets) {
        for (EUR_CRM_OP_Promo_Target__c promoTarget : promoTargets) {
            promoTarget.recalculateFormulas();
        }
    }

    private static void recalculateFormulas(List<EUR_CRM_OP_Target_Manager__c> targetManagers) {
        List<EUR_CRM_OP_Target_Manager__c> clonedRecalculatedTMs = new List<EUR_CRM_OP_Target_Manager__c>();
        for (EUR_CRM_OP_Target_Manager__c targetManager : targetManagers) {
            clonedRecalculatedTMs.add((EUR_CRM_OP_Target_Manager__c) safeRecalculationFormulas(targetManager));
        }
        targetManagers = clonedRecalculatedTMs;
    }

    private static void recalculateFormulas(List<EUR_CRM_OP_Target_REP__c> targetReps) {
        for (EUR_CRM_OP_Target_REP__c targetRep : targetReps) {
            targetRep.recalculateFormulas();
        }
    }

    private static EUR_CRM_OP_Promo_Target__c extractPromoTarget(ProductWrapper pw) {
        EUR_CRM_OP_Promo_Target__c promoTarget = new EUR_CRM_OP_Promo_Target__c(Id = (Id)pw.promoTarget.get('Id'));
        for (ColumnWrapper cw : pw.columnWrappers) {
            if (cw.editable && String.isNotBlank(cw.data)) {
                promoTarget.put(cw.fieldName, Decimal.valueOf(cw.data));
            }
        }
        return promoTarget;
    }

    private static EUR_CRM_OP_Target_Manager__c extractTargetManager(ManagerWrapper mw) {
        EUR_CRM_OP_Target_Manager__c targetManager = new EUR_CRM_OP_Target_Manager__c(Id = (Id)mw.targetManager.get('Id'), EUR_CRM_OP_Promo_Target__c = mw.targetManager.EUR_CRM_OP_Promo_Target__c);
        for (ColumnWrapper cw : mw.columnWrappers) {
            if (cw.editable && String.isNotBlank(cw.data)) {
                targetManager.put(cw.fieldName, Decimal.valueOf(cw.data));
            }
        }
        return targetManager;
    }

    private static EUR_CRM_OP_Target_REP__c extractTargetRep(SalesRepWrapper sw) {
        EUR_CRM_OP_Target_REP__c targetRep = new EUR_CRM_OP_Target_REP__c(Id = (Id)sw.targetSalesRep.get('Id'));
        for (ColumnWrapper cw : sw.columnWrappers) {
            if (cw.editable && String.isNotBlank(cw.data)) {
                targetRep.put(cw.fieldName, Decimal.valueOf(cw.data));
            }
        }
        return targetRep;
    }

    private static String extractTargetQuotaLevels(EUR_CRM_Objectives_Promotions__c op) {
        if (op.EUR_CRM_OP_Template__c == null) { return ''; }
        return op.EUR_CRM_OP_Template__r.EUR_CRM_Target_Quota_Levels__c;
    }

    private static Boolean hasOPProductNoPromoTargets(List<EUR_CRM_OP_Product__c> opProducts) {
        return opProducts.size() == 1
            && opProducts[0].EUR_CRM_OP_PromoTargets__r.isEmpty()
        ;
    }

    private static Boolean hasPromoTargetNoManagers(List<EUR_CRM_OP_Promo_Target__c> promoTargets) {
        return promoTargets.size() == 1
            && promoTargets[0].EUR_CRM_OP_TargetManagers__r.isEmpty()
        ;
    }

    private static Boolean hasTargetManagerNoSalesReps(List<EUR_CRM_OP_Target_Manager__c> targetManagers) {
        return targetManagers.size() == 1
            && targetManagers[0].EUR_CRM_OP_TargetSalesReps__r.isEmpty()
        ;
    }

//    private static Boolean hasTemplateTarget(List<EUR_CRM_OP_Template__c> templateList) {
//        return !templateList.isEmpty()
//            && templateList[0].EUR_CRM_Has_Target__c;
//    }

    private static Boolean isNeedToCreateFakeTargets(EUR_CRM_Objectives_Promotions__c op) {
//        EUR_CRM_Objectives_Promotions__c op = getObjectivesPromotionsWhereId(opId);
        if (isOPTemplateHasNoTargetAndQuota(op)) {
            return true;
        }
        return false;
    }

    private static Boolean isNeedToPopulateManagerLevel(EUR_CRM_Objectives_Promotions__c op) {
        String targetQuotaLevels = extractTargetQuotaLevels(op);
        if (String.isNotBlank(targetQuotaLevels) && ( ! targetQuotaLevels.containsIgnoreCase(MANAGER_LEVEL))) {
            return true;
        }
        return false;
    }

    private static Boolean isNeedToPopulateGeneralLevel(EUR_CRM_Objectives_Promotions__c op) {
        String targetQuotaLevels = extractTargetQuotaLevels(op);
        if (String.isNotBlank(targetQuotaLevels) && ( ! targetQuotaLevels.containsIgnoreCase(GENERAL_LEVEL))) {
            return true;
        }
        return false;
    }

    private static Boolean isOPTemplateHasNoTargetAndQuota(EUR_CRM_Objectives_Promotions__c op) {
        return op.EUR_CRM_OP_Template__c != null
            && op.EUR_CRM_OP_Template__r.EUR_CRM_Has_Target__c == false
            && op.EUR_CRM_OP_Template__r.EUR_CRM_Has_Quota__c == false
        ;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static Id selectAccountTargetGroupIdOfOP(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_Account_Target_Group__c
            FROM EUR_CRM_Objectives_Promotions__c
            WHERE Id = :opId
        ][0].EUR_CRM_Account_Target_Group__c;
    }

    private static List<EUR_CRM_Account__c> selectAccountsWithOwnerAndRegionOwner(Id atgId) {
        return [
            SELECT Id
            ,   Name
            ,   OwnerId
            ,   Owner.Name
            ,   EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c
            ,   EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.Name
            FROM EUR_CRM_Account__c
            WHERE Id IN (
                SELECT EUR_CRM_Account__c
                FROM EUR_CRM_Account_in_Target_Group__c
                WHERE EUR_CRM_Account_Target_Group__c = :atgId
            )
                AND EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c != NULL
            ORDER BY EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.Name
        ];
    }

    private static List<EUR_CRM_Account__c> selectAccountsWithOwnerAndRegionOwner(Set<Id> accIds) {
        return [
            SELECT Id
            ,   Name
            ,   OwnerId
            ,   Owner.Name
            ,   EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c
            ,   EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.Name
            FROM EUR_CRM_Account__c
            WHERE Id IN :accIds
                AND EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c != NULL
            ORDER BY EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.Name
        ];
    }

    private static List<EUR_CRM_OP_Product__c> selectOPProductWhereId(String opId, Id opProductId) {
        return [
            SELECT Id
            ,   (
                SELECT Id
                FROM EUR_CRM_OP_PromoTargets__r
            )
            FROM EUR_CRM_OP_Product__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
                AND Id = :opProductId
        ];
    }

    private static List<EUR_CRM_OP_Promo_Target__c> selectPromoTargetsWhereId(String opId, Id promoTargetId) {
        return [
            SELECT Id
            ,   EUR_CRM_OP_Product__c
            ,   (
                SELECT Id
                FROM EUR_CRM_OP_TargetManagers__r
            )
            FROM EUR_CRM_OP_Promo_Target__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
                AND Id = :promoTargetId
        ];
    }

    private static List<EUR_CRM_OP_Target_Manager__c> selectTargetManagersWhereId(String opId, String targetManagerId) {
        return [
            SELECT Id
            ,   EUR_CRM_OP_Promo_Target__c
            ,   EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__c
            ,   (
                SELECT Id
                FROM EUR_CRM_OP_TargetSalesReps__r
            )
            FROM EUR_CRM_OP_Target_Manager__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
                AND Id = :targetManagerId
        ];
    }

    private static List<EUR_CRM_OP_Target_REP__c> selectTargetRepsWhereId(String opId, String targetRepId) {
        return [
            SELECT Id
            ,   EUR_CRM_OP_Target_Manager__c
            ,   EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__c
            ,   EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__c
            FROM EUR_CRM_OP_Target_REP__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
                AND Id = :targetRepId
        ];
    }

    private static String selectSectionsToShow(String opId) {
        return [
            SELECT Id
            ,   EUR_CRM_OP_Template__r.EUR_CRM_Target_Quota_Levels__c
            FROM EUR_CRM_Objectives_Promotions__c
            WHERE Id = :opId
            LIMIT 1
        ][0].EUR_CRM_OP_Template__r.EUR_CRM_Target_Quota_Levels__c;
    }

    private static List<EUR_CRM_OP_Action__c> selectOPActionsForTemplateRelatedToOP(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_MultiPLOpTarget__c
            FROM EUR_CRM_OP_Action__c
            WHERE EUR_CRM_OP_Template__c IN (
                SELECT EUR_CRM_OP_Template__c
                FROM EUR_CRM_Objectives_Promotions__c
                WHERE Id = :opId
            )
            ORDER BY Id
        ];
    }

    private static List<EUR_CRM_OP_Target_Confirmation_Fields__mdt> selectDependedFieldsRelatedTo(List<String> resultFieldList) {
        return [
            SELECT Id
            ,   EUR_CRM_Main_Target_API_Name_Field__c
            ,   EUR_CRM_Dependent_Target_API_Name_Fields__c
            FROM EUR_CRM_OP_Target_Confirmation_Fields__mdt
            WHERE EUR_CRM_Main_Target_API_Name_Field__c IN :resultFieldList
        ];
    }

    private static List<EUR_CRM_OP_Product__c> selectOPProductsWhereOPId(String opId) {
        return [
            SELECT Id
            ,   EUR_CRM_Brand__c
            ,   EUR_CRM_Brand_Quality__c
            ,   EUR_CRM_Brand_Quality_Size__c
            ,   EUR_CRM_SKU_EU__c
            ,   EUR_CRM_POS_Material__c
            ,   EUR_CRM_Product_Toolkit__c
            FROM EUR_CRM_OP_Product__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
        ];
    }

    private static List<EUR_CRM_OP_Target_Manager__c> selectTargetManagers(List<EUR_CRM_OP_Target_Manager__c> targetManagers) {
        Map<Id, EUR_CRM_OP_Target_Manager__c> targetManagersByIds = new Map<Id, EUR_CRM_OP_Target_Manager__c>(targetManagers);
        return [
            SELECT Id
            ,   EUR_CRM_OP_Promo_Target__c
            ,   EUR_CRM_OP_Product__c
            ,   EUR_CRM_Objectives_Promotions__c
            FROM EUR_CRM_OP_Target_Manager__c
            WHERE Id IN :targetManagersByIds.keySet()
        ];
    }

    private static List<EUR_CRM_OP_Target_REP__c> selectTargetReps(List<EUR_CRM_OP_Target_Manager__c> targetManagers) {
        Map<Id, EUR_CRM_OP_Target_Manager__c> targetManagersByIds = new Map<Id, EUR_CRM_OP_Target_Manager__c>(targetManagers);
        return [
            SELECT Id
            ,   EUR_CRM_OP_Product__c
            ,   EUR_CRM_Objectives_Promotions__c
            ,   EUR_CRM_OP_Target_Manager__c
            FROM EUR_CRM_OP_Target_REP__c
            WHERE EUR_CRM_OP_Target_Manager__c IN :targetManagersByIds.keySet()
        ];
    }

    private static EUR_CRM_Objectives_Promotions__c getObjectivesPromotionsWhereId(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_OP_Template__c
            ,   EUR_CRM_OP_Template__r.EUR_CRM_Has_Target__c
            ,   EUR_CRM_OP_Template__r.EUR_CRM_Has_Quota__c
            ,   EUR_CRM_OP_Template__r.EUR_CRM_Target_Quota_Levels__c
            FROM EUR_CRM_Objectives_Promotions__c
            WHERE Id = :opId
        ];
    }


    /* ========================================================= */
    /*     Class Wrappers
    /* ========================================================= */
    public class ManagerUserWrapper {
        public User manager;
        public List<User> salesReps;

        public ManagerUserWrapper(EUR_CRM_Account__c account) {
            this.manager = new User(
                Id = account.EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__c
            ,   Username = account.EUR_CRM_Territory__r.EUR_CRM_Region__r.EUR_CRM_Region_Owner__r.Name
            );

            this.salesReps = new List<User>();
        }

        public void addSalesRep(EUR_CRM_Account__c account) {
            Boolean exist = false;
            for (User salesRep : this.salesReps) {
                if (salesRep.Id == account.OwnerId) {
                    exist = true;
                    break;
                }
            }
            if (exist) { return; }

            this.salesReps.add(new User(
                Id = account.OwnerId
            ,   Username = account.Owner.Name
            ));
        }
    }

    public class ProductWrapper {
        @AuraEnabled public EUR_CRM_OP_Target_REP__c targetSalesRep { get; set; }
        @AuraEnabled public EUR_CRM_OP_Product__c product { get; set; }
        @AuraEnabled public EUR_CRM_OP_Promo_Target__c promoTarget { get; set; }
        @AuraEnabled public String productId { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public List<ManagerWrapper> managers { get; set; }
        @AuraEnabled public List<ColumnWrapper> columnWrappers { get; set; }

        public ProductWrapper(EUR_CRM_OP_Product__c product, SObject obj, List<ManagerUserWrapper> managerUserWrappers) {
            this.targetSalesRep = new EUR_CRM_OP_Target_REP__c();
            this.promoTarget = new EUR_CRM_OP_Promo_Target__c();
            this.product = product;
            this.productId = (String)obj.get('Id');
            this.productName = (String)obj.get('Name');
            this.managers = new List<ManagerWrapper>();
            for (ManagerUserWrapper managerUserWrapper : managerUserWrappers) {
                this.managers.add(new ManagerWrapper(managerUserWrapper));
            }
            this.columnWrappers = new List<ColumnWrapper>();
        }

        public ProductWrapper(EUR_CRM_OP_Target_REP__c targetRep) {
            this.targetSalesRep = targetRep;
            this.product = new EUR_CRM_OP_Product__c(Id = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__c);
            this.promoTarget = new EUR_CRM_OP_Promo_Target__c(Id = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__c);

            this.product.EUR_CRM_Objectives_Promotions__c = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Objectives_Promotions__c;

            if (targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand__c != null) {
                this.productId = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand__c;
                this.productName = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand__r.Name;
                this.product.EUR_CRM_Brand__c = this.productId;
            } else if (targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality__c != null) {
                this.productId = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality__c;
                this.productName = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality__r.Name;
                this.product.EUR_CRM_Brand_Quality__c = this.productId;
            } else if (targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality_Size__c != null) {
                this.productId = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality_Size__c;
                this.productName = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Brand_Quality_Size__r.Name;
                this.product.EUR_CRM_Brand_Quality_Size__c = this.productId;
            } else if (targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_SKU_EU__c != null) {
                this.productId = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_SKU_EU__c;
                this.productName = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_SKU_EU__r.Name;
                this.product.EUR_CRM_SKU_EU__c = this.productId;
            } else if (targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_POS_Material__c != null) {
                this.productId = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_POS_Material__c;
                this.productName = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_POS_Material__r.Name;
                this.product.EUR_CRM_POS_Material__c = this.productId;
            } else if (targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Product_Toolkit__c != null) {
                this.productId = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Product_Toolkit__c;
                this.productName = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__r.EUR_CRM_OP_Product__r.EUR_CRM_Product_Toolkit__r.Name;
                this.product.EUR_CRM_Product_Toolkit__c = this.productId;
            }

            this.managers = new List<ManagerWrapper>();
            this.columnWrappers = new List<ColumnWrapper>();
        }

        public void addManagerWrapper(ManagerWrapper mw) {
            Boolean exist = false;
            for (ManagerWrapper wrapper : this.managers) {
                if (wrapper.targetManager.Id == mw.targetManager.Id) {
                    exist = true;
                    break;
                }
            }
            if (exist) { return; }
            this.managers.add(mw);
        }

        public void addManagerUser(ManagerUserWrapper managerUserWrapper) {
            Boolean exist = false;
            for (ManagerWrapper wrapper : this.managers) {
                if (wrapper.Id == managerUserWrapper.manager.Id) {
                    exist = true;
                    for (User salesRep : managerUserWrapper.salesReps) {
                        wrapper.addSalesRepUser(salesRep);
                    }
                    break;
                }
            }
            if (exist) { return; }
            this.managers.add(new ManagerWrapper(managerUserWrapper));
        }

        private void extractData() {
            for (ColumnWrapper columnWrapper : columnWrappers) {
                if (this.targetSalesRep.getSObject('EUR_CRM_OP_Target_Manager__r') != null) {
                    columnWrapper.data = String.valueOf(this.targetSalesRep.getSObject('EUR_CRM_OP_Target_Manager__r').getSObject('EUR_CRM_OP_Promo_Target__r').get(columnWrapper.fieldName));
                }
            }
        }
    }

    public class ManagerWrapper {
        @AuraEnabled public EUR_CRM_OP_Target_REP__c targetSalesRep { get; set; }
        @AuraEnabled public EUR_CRM_OP_Target_Manager__c targetManager { get; set; }
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public List<SalesRepWrapper> salesReps { get; set; }
        @AuraEnabled public List<ColumnWrapper> columnWrappers { get; set; }

        public ManagerWrapper(ManagerUserWrapper managerUserWrapper) {
            this.targetSalesRep = new EUR_CRM_OP_Target_REP__c();
            this.targetManager = new EUR_CRM_OP_Target_Manager__c();
            this.Id = managerUserWrapper.manager.Id;
            this.Name = managerUserWrapper.manager.Username;
            this.salesReps = new List<SalesRepWrapper>();
            for (User salesRep : managerUserWrapper.salesReps) {
                this.salesReps.add(new SalesRepWrapper(salesRep));
            }
            this.columnWrappers = new List<ColumnWrapper>();
        }

        public ManagerWrapper(EUR_CRM_OP_Target_REP__c targetRep) {
            this.targetSalesRep = targetRep;
            this.targetManager = new EUR_CRM_OP_Target_Manager__c(Id = targetRep.EUR_CRM_OP_Target_Manager__c, EUR_CRM_OP_Promo_Target__c = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_OP_Promo_Target__c);
            this.Id = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_Target_Owner__c;
            this.Name = targetRep.EUR_CRM_OP_Target_Manager__r.EUR_CRM_Target_Owner__r.Name;
            this.salesReps = new List<SalesRepWrapper>();
            this.columnWrappers = new List<ColumnWrapper>();
        }

        public void addSalesRepWrapper(SalesRepWrapper srw) {
            Boolean exist = false;
            for (SalesRepWrapper wrapper : this.salesReps) {
                if (wrapper.targetSalesRep.Id == srw.targetSalesRep.Id) {
                    exist = true;
                    break;
                }
            }
            if (exist) { return; }
            this.salesReps.add(srw);
        }

        public void addSalesRepUser(User salesRep) {
            Boolean exist = false;
            for (SalesRepWrapper wrapper : this.salesReps) {
                if (wrapper.Id == salesRep.Id) {
                    exist = true;
                    break;
                }
            }
            if (exist) { return; }
            this.salesReps.add(new SalesRepWrapper(salesRep));
        }

        private void extractData() {
            for (ColumnWrapper columnWrapper : columnWrappers) {
                if (this.targetSalesRep.getSObject('EUR_CRM_OP_Target_Manager__r') != null) {
                    String data = String.valueOf(this.targetSalesRep.getSObject('EUR_CRM_OP_Target_Manager__r').get(columnWrapper.fieldName));
                    columnWrapper.data = String.isBlank(data) ? '0' : data;
                }
            }
        }
    }

    public class SalesRepWrapper {
        @AuraEnabled public EUR_CRM_OP_Target_REP__c targetSalesRep { get; set; }
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public List<ColumnWrapper> columnWrappers { get; set; }

        public SalesRepWrapper(User salesRep) {
            this.targetSalesRep = new EUR_CRM_OP_Target_REP__c();
            this.Id = salesRep.Id;
            this.Name = salesRep.Username;
            this.columnWrappers = new List<ColumnWrapper>();
        }

        public SalesRepWrapper(EUR_CRM_OP_Target_REP__c tr) {
            this.targetSalesRep = tr;
            this.Id = this.targetSalesRep.EUR_CRM_Target_Owner__c;
            this.Name = this.targetSalesRep.EUR_CRM_Target_Owner__r.Name;
            this.columnWrappers = new List<ColumnWrapper>();
        }

        private void extractData() {
            for (ColumnWrapper columnWrapper : columnWrappers) {
                if (this.targetSalesRep.get(columnWrapper.fieldName) != null) {
                    String data = String.valueOf(this.targetSalesRep.get(columnWrapper.fieldName));
                    columnWrapper.data = String.isBlank(data) ? '0' : data;
                }
            }
        }
    }

    public class ColumnWrapper {
        @AuraEnabled public String fieldLabel { get; set; }
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public String data { get; set; }
        @AuraEnabled public Boolean editable { get; set; }
        @AuraEnabled public Boolean infoField { get; set; }

        public ColumnWrapper(String fieldLabel, String fieldName, String data, Boolean editable, Boolean infoField) {
            this.fieldLabel = fieldLabel;
            this.fieldName = fieldName;
            this.data = data;
            this.editable = editable;
            this.infoField = infoField;
        }
    }

}