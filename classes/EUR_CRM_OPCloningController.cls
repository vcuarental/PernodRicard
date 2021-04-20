public with sharing class EUR_CRM_OPCloningController {

    private static final String INITIAL_OP_STATUS = 'Draft';


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    @AuraEnabled
    public static EUR_CRM_Objectives_Promotions__c getRecordToClone(Id recordId) {
        EUR_CRM_Objectives_Promotions__c op = selectObjectivesPromotionWhereId(recordId);
        op.Name = op.Name + ' - Cloned';
        return op;
    }

    @AuraEnabled
    public static String cloneRecordWithRelatedLists(EUR_CRM_Objectives_Promotions__c record) {
        Set<String> opFieldsToSetToNull = new Set<String> {
            'Id'
        ,   'EUR_CRM_Active_Start_Date__c'
        ,   'EUR_CRM_Active_End_Date__c'
        ,   'EUR_CRM_Publish_Date__c'
        ,   'EUR_CRM_Preparation_Start_Date__c'
        ,   'EUR_CRM_Evaluation_End_Date__c'
        };

        Id opIDToClone = record.Id;
        setFieldsToNull(record, opFieldsToSetToNull);
        record.EUR_CRM_Status__c = INITIAL_OP_STATUS;
        insert record;

        cloneProducts(opIDToClone, record.Id);

        return record.Id;
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private static void cloneProducts(Id originalOPId, Id clonedOPId) {
        List<EUR_CRM_OP_Product__c> products = selectOpProductsWhereOPId(originalOPId);
        setFieldsToNull(products, new Set<String> { 'Id' });

        for (EUR_CRM_OP_Product__c product : products) {
            product.EUR_CRM_Objectives_Promotions__c = clonedOPId;
            product.OwnerId = UserInfo.getUserId();
        }
        insert products;
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private static void setFieldsToNull(EUR_CRM_Objectives_Promotions__c op, Set<String> fields) {
        for (String field : fields) {
            op.put(field, null);
        }
        op.OwnerId = UserInfo.getUserId();
    }

    private static void setFieldsToNull(List<EUR_CRM_OP_Product__c> products, Set<String> fields) {
        for (EUR_CRM_OP_Product__c product : products) {
            for (String field : fields) {
                product.put(field, null);
            }
            product.OwnerId = UserInfo.getUserId();
        }
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static EUR_CRM_Objectives_Promotions__c selectObjectivesPromotionWhereId(Id opId) {
        return ((List<EUR_CRM_Objectives_Promotions__c>) new EUR_CRM_QueryBuilder(EUR_CRM_Objectives_Promotions__c.class)
            .qbAllCreatableFields()
            .qbCondition()
            .add(new EUR_CRM_QueryBuilder.CompareCondition('Id').eq(opId))
            .endCondition()
            .toList())[0];
    }

    private static List<EUR_CRM_OP_Product__c> selectOpProductsWhereOPId(Id opId) {
        return (List<EUR_CRM_OP_Product__c>) new EUR_CRM_QueryBuilder(EUR_CRM_OP_Product__c.class)
            .qbAllCreatableFields()
            .qbCondition()
            .add(new EUR_CRM_QueryBuilder.CompareCondition('EUR_CRM_Objectives_Promotions__c').eq(opId))
            .endCondition()
            .toList();
    }

}