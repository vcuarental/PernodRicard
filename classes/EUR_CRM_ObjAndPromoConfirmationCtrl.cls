public with sharing class EUR_CRM_ObjAndPromoConfirmationCtrl {

    @TestVisible private static final String SUCCESS_RESULT = 'OK';

    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    @AuraEnabled
    public static EUR_CRM_OP_Template__c getOPTemplateWithOPActions(String recordId) {
        List<EUR_CRM_OP_Template__c> opTemplateWithOPActions = selectOPTemplateWithOPActions(recordId);
        System.debug('\n\n opTemplateWithOPActions => ' + JSON.serializePretty(opTemplateWithOPActions) + '\n');
        if (opTemplateWithOPActions.isEmpty()) { return null; }

        return opTemplateWithOPActions[0];
    }

    @AuraEnabled
    public static EUR_CRM_ObjPromoToAccAssignAuraCtrl.AccountTargetGroupWrapper getAccountTargetGroupWithRelatedAccounts(String recordId) {
        List<EUR_CRM_Account_Target_Group__c> accountTargetGroups = selectAccountTargetGroups(recordId);
        System.debug('\n\n accountTargetGroups => ' + JSON.serializePretty(accountTargetGroups) + '\n');
        if (accountTargetGroups.isEmpty()) { return null; }

        List<EUR_CRM_Account_in_Target_Group__c> accountInTargetGroups = selectAccountInTargetGroupsWhereAccountTargetGroupId(accountTargetGroups[0].Id);

        EUR_CRM_ObjPromoToAccAssignAuraCtrl.AccountTargetGroupWrapper accountTargetGroupWrapper =
            new EUR_CRM_ObjPromoToAccAssignAuraCtrl.AccountTargetGroupWrapper(accountTargetGroups[0], accountInTargetGroups);
        System.debug('\n\n accountTargetGroupWrapper => ' + JSON.serializePretty(accountTargetGroupWrapper) + '\n');

        return accountTargetGroupWrapper;
    }

    @AuraEnabled
    public static String deleteProductWithRelated(String productId, String opId) {
        List<EUR_CRM_OP_Product__c> productsToDelete = selectProductsToDelete(productId, opId);
        if (productsToDelete.isEmpty()) { return SUCCESS_RESULT; }
        
        EUR_CRM_OP_Product__c productToDelete = productsToDelete[0];
        delete [SELECT Id From EUR_CRM_OP_Promo_Target__c Where EUR_CRM_OP_Product__c = :productToDelete.Id];
        delete productToDelete;
        return SUCCESS_RESULT;
    }



    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_OP_Product__c> selectProductsToDelete(String productId, String opId) {
        return [SELECT Id
        FROM EUR_CRM_OP_Product__c
        WHERE (
            EUR_CRM_Brand__c = :productId
        OR EUR_CRM_Brand_Quality__c =:productId
        OR EUR_CRM_Brand_Quality_Size__c =:productId
        OR EUR_CRM_SKU_EU__c =:productId
        OR EUR_CRM_POS_Material__c =:productId
        OR EUR_CRM_Product_Toolkit__c =:productId
        )
        AND EUR_CRM_Objectives_Promotions__c = :opId
        LIMIT 1];
    }

    private static List<EUR_CRM_OP_Template__c> selectOPTemplateWithOPActions(Id opId) {
        return [
            SELECT Id
            ,   Name
            ,   (
                SELECT Id
                ,   Name
                ,   EUR_CRM_Stage__c
                ,   EUR_CRM_Step_Order__c
                ,   EUR_CRM_Reoccuring_Type__c
                FROM OP_Actions_EU__r
                ORDER BY EUR_CRM_Step_Order__c
            )
            FROM EUR_CRM_OP_Template__c
            WHERE Id IN (
                SELECT EUR_CRM_OP_Template__c
                FROM EUR_CRM_Objectives_Promotions__c
                WHERE Id = :opId
            )
        ];
    }

    private static List<EUR_CRM_Account_Target_Group__c> selectAccountTargetGroups(Id opId) {
        return [
            SELECT Id
            ,   Name
            ,   EUR_CRM_IsDynamic__c
            FROM EUR_CRM_Account_Target_Group__c
            WHERE Id IN (
                SELECT EUR_CRM_Account_Target_Group__c
                FROM EUR_CRM_Objectives_Promotions__c
                WHERE Id = :opId
            )
        ];
    }

    private static List<EUR_CRM_Account_in_Target_Group__c> selectAccountInTargetGroupsWhereAccountTargetGroupId(Id atgId) {
        return [
            SELECT Id
            ,   EUR_CRM_Account__c
            ,   EUR_CRM_Account__r.Name
            FROM EUR_CRM_Account_in_Target_Group__c
            WHERE EUR_CRM_Account_Target_Group__c = :atgId
            ORDER BY EUR_CRM_Account__r.Name ASC
            LIMIT 2000
        ];
    }

}