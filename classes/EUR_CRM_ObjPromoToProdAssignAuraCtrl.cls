public with sharing class EUR_CRM_ObjPromoToProdAssignAuraCtrl {


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    @AuraEnabled
    public static String getSelectedProductType(String recordId) {
        List<EUR_CRM_Objectives_Promotions__c> promotions = selectObjectivesPromotionsWhereId(recordId);
        if (promotions.isEmpty()) { return ''; }

        return promotions[0].EUR_CRM_OP_Template__r.EUR_CRM_Product_Level__c;
    }

    @AuraEnabled
    public static List<SelectOptionWrapper> getProductsOfBrand(String recordId) {
        List<EUR_CRM_Brand__c> brands = selectBrands();
        Map<Id, EUR_CRM_OP_Product__c> existsProductUnderCurrentOPByBrandId = getOPProductsWithBrandUnderCurrentOPByBrandId(recordId);

        List<SelectOptionWrapper> wrappers = new List<SelectOptionWrapper>();
        for (EUR_CRM_Brand__c brand : brands) {
            wrappers.add(new SelectOptionWrapper(brand, existsProductUnderCurrentOPByBrandId.get(brand.Id)));
        }
        return wrappers;
    }

    @AuraEnabled
    public static List<SelectOptionWrapper> getProductsOfBrandQuality(String recordId) {
        List<EUR_CRM_Quality__c> qualities = selectBrandQualities();
        Map<Id, EUR_CRM_OP_Product__c> existsProductUnderCurrentOPByQualityId = getOPProductsWithQualityUnderCurrentOPByQualityId(recordId);

        List<SelectOptionWrapper> wrappers = new List<SelectOptionWrapper>();
        for (EUR_CRM_Quality__c quality : qualities) {
            wrappers.add(new SelectOptionWrapper(quality, existsProductUnderCurrentOPByQualityId.get(quality.Id)));
        }
        return wrappers;
    }

    @AuraEnabled
    public static List<SelectOptionWrapper> getProductsOfBrandQualitySize(String recordId) {
        List<EUR_CRM_Size__c> sizes = selectBrandQualitySizes();
        Map<Id, EUR_CRM_OP_Product__c> existsProductUnderCurrentOPBySizeId = getOPProductsWithSizeUnderCurrentOPBySizeId(recordId);

        List<SelectOptionWrapper> wrappers = new List<SelectOptionWrapper>();
        for (EUR_CRM_Size__c size : sizes) {
            wrappers.add(new SelectOptionWrapper(size, existsProductUnderCurrentOPBySizeId.get(size.Id)));
        }
        return wrappers;
    }

    @AuraEnabled
    public static List<SelectOptionWrapper> getProductsOfSKU(String recordId) {
        List<EUR_CRM_SKU__c> skus = selectSKUs();
        Map<Id, EUR_CRM_OP_Product__c> existsProductUnderCurrentOPBySKUId = getOPProductsWithSKUUnderCurrentOPBySKUId(recordId);

        List<SelectOptionWrapper> wrappers = new List<SelectOptionWrapper>();
        for (EUR_CRM_SKU__c sku : skus) {
            wrappers.add(new SelectOptionWrapper(sku, existsProductUnderCurrentOPBySKUId.get(sku.Id)));
        }
        return wrappers;
    }

    @AuraEnabled
    public static List<SelectOptionWrapper> getProductsOfPOSMaterials(String recordId) {
        List<EUR_CRM_POS_Material__c> posMaterials = selectPOSMaterials();
        Map<Id, EUR_CRM_OP_Product__c> existsProductUnderCurrentOPByPOSMaterialId = getOPProductsWithPOSMaterialsUnderCurrentOPByPOSMaterialId(recordId);

        List<SelectOptionWrapper> wrappers = new List<SelectOptionWrapper>();
        for (EUR_CRM_POS_Material__c posMaterial : posMaterials) {
            wrappers.add(new SelectOptionWrapper(posMaterial, existsProductUnderCurrentOPByPOSMaterialId.get(posMaterial.Id)));
        }
        return wrappers;
    }

    @AuraEnabled
    public static List<SelectOptionWrapper> getProductsOfProductToolkit(String recordId) {
        List<EUR_CRM_Product_Toolkit__c> productToolkit = selectProductToolkit();
        Map<Id, EUR_CRM_OP_Product__c> existsProductUnderCurrentOPByByProductToolkitId = getOPProductsWithProductToolkitUnderCurrentOPByProductToolkitId(recordId);

        List<SelectOptionWrapper> wrappers = new List<SelectOptionWrapper>();
        for (EUR_CRM_Product_Toolkit__c pt : productToolkit) {
            wrappers.add(new SelectOptionWrapper(pt, existsProductUnderCurrentOPByByProductToolkitId.get(pt.Id)));
        }
        return wrappers;
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private static Map<Id, EUR_CRM_OP_Product__c> getOPProductsWithBrandUnderCurrentOPByBrandId(Id recordId) {
        List<EUR_CRM_OP_Product__c> existsOPProductsWithBrandUnderCurrentOP = selectOPProductsWithBrandUnderCurrentOP(recordId);

        Map<Id, EUR_CRM_OP_Product__c> existsProductUnderCurrentOPByBrandId = new Map<Id, EUR_CRM_OP_Product__c>();
        for (EUR_CRM_OP_Product__c opProduct : existsOPProductsWithBrandUnderCurrentOP) {
            existsProductUnderCurrentOPByBrandId.put(opProduct.EUR_CRM_Brand__c, opProduct);
        }

        return existsProductUnderCurrentOPByBrandId;
    }

    private static Map<Id, EUR_CRM_OP_Product__c> getOPProductsWithQualityUnderCurrentOPByQualityId(Id recordId) {
        List<EUR_CRM_OP_Product__c> existsOPProductsWithQualityUnderCurrentOP = selectOPProductsWithQualityUnderCurrentOP(recordId);

        Map<Id, EUR_CRM_OP_Product__c> existsProductUnderCurrentOPByQualityId = new Map<Id, EUR_CRM_OP_Product__c>();
        for (EUR_CRM_OP_Product__c opProduct : existsOPProductsWithQualityUnderCurrentOP) {
            existsProductUnderCurrentOPByQualityId.put(opProduct.EUR_CRM_Brand_Quality__c, opProduct);
        }

        return existsProductUnderCurrentOPByQualityId;
    }

    private static Map<Id, EUR_CRM_OP_Product__c> getOPProductsWithSizeUnderCurrentOPBySizeId(Id recordId) {
        List<EUR_CRM_OP_Product__c> existsOPProductsWithSizeUnderCurrentOP = selectOPProductsWithSizeUnderCurrentOP(recordId);

        Map<Id, EUR_CRM_OP_Product__c> existsProductUnderCurrentOPBySizeId = new Map<Id, EUR_CRM_OP_Product__c>();
        for (EUR_CRM_OP_Product__c opProduct : existsOPProductsWithSizeUnderCurrentOP) {
            existsProductUnderCurrentOPBySizeId.put(opProduct.EUR_CRM_Brand_Quality_Size__c, opProduct);
        }

        return existsProductUnderCurrentOPBySizeId;
    }

    private static Map<Id, EUR_CRM_OP_Product__c> getOPProductsWithSKUUnderCurrentOPBySKUId(Id recordId) {
        List<EUR_CRM_OP_Product__c> existsOPProductsWithSKUUnderCurrentOP = selectOPProductsWithSKUUnderCurrentOP(recordId);

        Map<Id, EUR_CRM_OP_Product__c> existsProductUnderCurrentOPBySKUId = new Map<Id, EUR_CRM_OP_Product__c>();
        for (EUR_CRM_OP_Product__c opProduct : existsOPProductsWithSKUUnderCurrentOP) {
            existsProductUnderCurrentOPBySKUId.put(opProduct.EUR_CRM_SKU_EU__c, opProduct);
        }

        return existsProductUnderCurrentOPBySKUId;
    }

    private static Map<Id, EUR_CRM_OP_Product__c> getOPProductsWithPOSMaterialsUnderCurrentOPByPOSMaterialId(Id recordId) {
        List<EUR_CRM_OP_Product__c> existsOPProductsPOSMaterialsUnderCurrentOP = selectOPProductsWithPOSMaterialsUnderCurrentOP(recordId);

        Map<Id, EUR_CRM_OP_Product__c> existsProductUnderCurrentOPByPOSMaterialId = new Map<Id, EUR_CRM_OP_Product__c>();
        for (EUR_CRM_OP_Product__c opProduct : existsOPProductsPOSMaterialsUnderCurrentOP) {
            existsProductUnderCurrentOPByPOSMaterialId.put(opProduct.EUR_CRM_POS_Material__c, opProduct);
        }

        return existsProductUnderCurrentOPByPOSMaterialId;
    }

    private static Map<Id, EUR_CRM_OP_Product__c> getOPProductsWithProductToolkitUnderCurrentOPByProductToolkitId(Id recordId) {
        List<EUR_CRM_OP_Product__c> existsOPProductsWithProductToolkitUnderCurrentOP = selectOPProductsWithProductToolkitUnderCurrentOP(recordId);

        Map<Id, EUR_CRM_OP_Product__c> existsProductUnderCurrentOPByProductToolkitId = new Map<Id, EUR_CRM_OP_Product__c>();
        for (EUR_CRM_OP_Product__c opProduct : existsOPProductsWithProductToolkitUnderCurrentOP) {
            existsProductUnderCurrentOPByProductToolkitId.put(opProduct.EUR_CRM_Product_Toolkit__c, opProduct);
        }

        return existsProductUnderCurrentOPByProductToolkitId;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Objectives_Promotions__c> selectObjectivesPromotionsWhereId(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_OP_Template__r.EUR_CRM_Product_Level__c
            FROM EUR_CRM_Objectives_Promotions__c
            WHERE Id = : opId
                AND EUR_CRM_OP_Template__r.EUR_CRM_Product_Level__c != null
            LIMIT 1
        ];
    }

    private static List<EUR_CRM_Brand__c> selectBrands() {
        return [
            SELECT Id
            ,   Name
            FROM EUR_CRM_Brand__c
            WHERE EUR_CRM_Is_Competitor__c = false
            AND EUR_CRM_Active__c = true
            ORDER BY Name
        ];
    }

    private static List<EUR_CRM_OP_Product__c> selectOPProductsWithBrandUnderCurrentOP(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_Brand__c
            ,   (SELECT Id FROM EUR_CRM_OP_TargetSalesReps__r)
            FROM EUR_CRM_OP_Product__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
                AND EUR_CRM_Brand__c != null
        ];
    }

    private static List<EUR_CRM_Quality__c> selectBrandQualities() {
        return [
            SELECT Id
            ,   Name
            FROM EUR_CRM_Quality__c
            WHERE EUR_CRM_Quality_Is_Competitor__c = false
            AND EUR_CRM_Active__c = true
            ORDER BY Name
        ];
    }

    private static List<EUR_CRM_OP_Product__c> selectOPProductsWithQualityUnderCurrentOP(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_Brand_Quality__c
            ,   (SELECT Id FROM EUR_CRM_OP_TargetSalesReps__r)
            FROM EUR_CRM_OP_Product__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
                AND EUR_CRM_Brand_Quality__c != null
        ];
    }

    private static List<EUR_CRM_Size__c> selectBrandQualitySizes() {
        return [
            SELECT Id
            ,   Name
            FROM EUR_CRM_Size__c
            WHERE EUR_CRM_BrandQualitySize_Is_Competitor__c = false
            AND EUR_CRM_Active__c = true
            ORDER BY Name
        ];
    }

    private static List<EUR_CRM_OP_Product__c> selectOPProductsWithSizeUnderCurrentOP(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_Brand_Quality_Size__c
            ,   (SELECT Id FROM EUR_CRM_OP_TargetSalesReps__r)
            FROM EUR_CRM_OP_Product__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
                AND EUR_CRM_Brand_Quality_Size__c != null
        ];
    }

    private static List<EUR_CRM_SKU__c> selectSKUs() {
        return [
            SELECT Id
            ,   Name
            ,   EUR_CRM_Article_no__c
            FROM EUR_CRM_SKU__c
            WHERE EUR_CRM_Is_Competitor__c = false
            AND EUR_CRM_Active__c = true
            AND EUR_CRM_Article_no__c != NULL
            ORDER BY Name
        ];
    }

    private static List<EUR_CRM_OP_Product__c> selectOPProductsWithSKUUnderCurrentOP(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_SKU_EU__c
            ,   (SELECT Id FROM EUR_CRM_OP_TargetSalesReps__r)
            FROM EUR_CRM_OP_Product__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
                AND EUR_CRM_SKU_EU__c != null
        ];
    }

    private static List<EUR_CRM_POS_Material__c> selectPOSMaterials() {
        return [
            SELECT Id
            ,   Name
            FROM EUR_CRM_POS_Material__c
            WHERE EUR_CRM_Active__c = true
            ORDER BY Name
        ];
    }

    private static List<EUR_CRM_OP_Product__c> selectOPProductsWithPOSMaterialsUnderCurrentOP(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_POS_Material__c
            ,   (SELECT Id FROM EUR_CRM_OP_TargetSalesReps__r)
            FROM EUR_CRM_OP_Product__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
                AND EUR_CRM_POS_Material__c != null
        ];
    }

    private static List<EUR_CRM_Product_Toolkit__c> selectProductToolkit() {
        return [
            SELECT Id
            ,   Name
            FROM EUR_CRM_Product_Toolkit__c
            WHERE EUR_CRM_Is_Active__c = true
            ORDER BY Name
        ];
    }

    private static List<EUR_CRM_OP_Product__c> selectOPProductsWithProductToolkitUnderCurrentOP(Id opId) {
        return [
            SELECT Id
            ,   EUR_CRM_Product_Toolkit__c
            ,   (SELECT Id FROM EUR_CRM_OP_TargetSalesReps__r)
            FROM EUR_CRM_OP_Product__c
            WHERE EUR_CRM_Objectives_Promotions__c = :opId
                AND EUR_CRM_Product_Toolkit__c != null
        ];
    }


    /* ========================================================= */
    /*     Class Wrappers
    /* ========================================================= */
    public class SelectOptionWrapper {
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Boolean isSelected { get; set; }
        @AuraEnabled public Boolean hasTargetReps { get; set; }

        public SelectOptionWrapper(EUR_CRM_Brand__c brand, EUR_CRM_OP_Product__c product) {
            this.value = brand.Id;
            this.label = brand.Name;
            this.isSelected = product != null;
            this.hasTargetReps = product != null ? ! product.EUR_CRM_OP_TargetSalesReps__r.isEmpty() : false;
        }

        public SelectOptionWrapper(EUR_CRM_Quality__c quality, EUR_CRM_OP_Product__c product) {
            this.value = quality.Id;
            this.label = quality.Name;
            this.isSelected = product != null;
            this.hasTargetReps = product != null ? ! product.EUR_CRM_OP_TargetSalesReps__r.isEmpty() : false;
        }

        public SelectOptionWrapper(EUR_CRM_Size__c size, EUR_CRM_OP_Product__c product) {
            this.value = size.Id;
            this.label = size.Name;
            this.isSelected = product != null;
            this.hasTargetReps = product != null ? ! product.EUR_CRM_OP_TargetSalesReps__r.isEmpty() : false;
        }

        public SelectOptionWrapper(EUR_CRM_SKU__c sku, EUR_CRM_OP_Product__c product) {
            this.value = sku.Id;
            this.label = sku.EUR_CRM_Article_no__c + ' (' + sku.Name + ' )';
            this.isSelected = product != null;
            this.hasTargetReps = product != null ? ! product.EUR_CRM_OP_TargetSalesReps__r.isEmpty() : false;
        }

        public SelectOptionWrapper(EUR_CRM_POS_Material__c posMaterial, EUR_CRM_OP_Product__c product) {
            this.value = posMaterial.Id;
            this.label = posMaterial.Name;
            this.isSelected = product != null;
            this.hasTargetReps = product != null ? ! product.EUR_CRM_OP_TargetSalesReps__r.isEmpty() : false;
        }

        public SelectOptionWrapper(EUR_CRM_Product_Toolkit__c productToolkit, EUR_CRM_OP_Product__c product) {
            this.value = productToolkit.Id;
            this.label = productToolkit.Name;
            this.isSelected = product != null;
            this.hasTargetReps = product != null ? ! product.EUR_CRM_OP_TargetSalesReps__r.isEmpty() : false;
        }
    }

}