public with sharing class EUR_CRM_OPPromTargDistToHandler {

    private static final String FIELD_API_MASK = 'EUR_CRM_Distance_to_go_';
    @TestVisible private static final String OP_COMPLETED_STATUS = 'Deactivated';
    private static final Set<String> OP_STATUS_SHOULD_NOT_BE_DEACTIVATED = new Set<String> {
        'Draft'
    ,   'Planned'
    };


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void handleDistanceToGoal(List<EUR_CRM_OP_Promo_Target__c> updatedPromoTargets, Map<Id, EUR_CRM_OP_Promo_Target__c> oldPromoTargetById) {

        Map<Id, List<EUR_CRM_OP_Promo_Target__c>> promoTargetsByOPId = this.getPromoTargetsByOPId(updatedPromoTargets);
        if (promoTargetsByOPId.isEmpty()) { return ; }
        System.debug('\n promoTargetsByOPId.size() => ' + promoTargetsByOPId.size() + '\n');
        System.debug('\n promoTargetsByOPId => ' + JSON.serializePretty(promoTargetsByOPId) + '\n');

        Map<Id, List<String>> mainFieldsFromOPActionByOPId = this.getMainFieldsFromOPActionByOPId(promoTargetsByOPId.keySet());
        if (mainFieldsFromOPActionByOPId.isEmpty()) { return ; }
        System.debug('\n mainFieldsFromOPActionByOPId.size() => ' + mainFieldsFromOPActionByOPId.size() + '\n');
        System.debug('\n mainFieldsFromOPActionByOPId => ' + JSON.serializePretty(mainFieldsFromOPActionByOPId) + '\n');

        Map<String, List<String>> dependedFieldsByMainField = this.getDependedFieldsByMainField(mainFieldsFromOPActionByOPId);
        if (dependedFieldsByMainField.isEmpty()) { return ; }
        System.debug('\n dependedFieldsByMainField.size() => ' + dependedFieldsByMainField.size() + '\n');
        System.debug('\n dependedFieldsByMainField => ' + JSON.serializePretty(dependedFieldsByMainField) + '\n');

        Map<Id, List<EUR_CRM_OP_Promo_Target__c>> completedInitialPromoTargetsByOPId = this.getCompletedPromoTargetsByOPId(promoTargetsByOPId, mainFieldsFromOPActionByOPId, dependedFieldsByMainField);
        if (completedInitialPromoTargetsByOPId.isEmpty()) { return ; }

        Set<Id> completedPromoTargetIds = this.extractPromoTargetIds(completedInitialPromoTargetsByOPId);
        List<EUR_CRM_OP_Promo_Target__c> siblingPromoTargets = this.getSiblingPromoTargets(completedInitialPromoTargetsByOPId.keySet(), completedPromoTargetIds, dependedFieldsByMainField);

        Map<Id, List<EUR_CRM_OP_Promo_Target__c>> siblingPromoTargetsByOPId = this.getPromoTargetsByOPId(siblingPromoTargets);
        Map<Id, List<EUR_CRM_OP_Promo_Target__c>> completedSiblingPromoTargetsByOPId = this.getCompletedPromoTargetsByOPId(siblingPromoTargetsByOPId, mainFieldsFromOPActionByOPId, dependedFieldsByMainField);

        Map<Id, EUR_CRM_Objectives_Promotions__c> objectivesPromotionsToCompleteById = new Map<Id, EUR_CRM_Objectives_Promotions__c>();
        for (Id opId : completedSiblingPromoTargetsByOPId.keySet()) {
            objectivesPromotionsToCompleteById.put(opId, this.makeOP(opId));
        }

        System.debug('\n completedInitialPromoTargetsByOPId.size() => ' + completedInitialPromoTargetsByOPId.size() + '\n');
        System.debug('\n completedInitialPromoTargetsByOPId => ' + JSON.serializePretty(completedInitialPromoTargetsByOPId) + '\n');

        System.debug('\n siblingPromoTargetsByOPId.size() => ' + siblingPromoTargetsByOPId.size() + '\n');
        System.debug('\n siblingPromoTargetsByOPId => ' + JSON.serializePretty(siblingPromoTargetsByOPId) + '\n');
        for (Id opId : completedInitialPromoTargetsByOPId.keySet()) {
            if (siblingPromoTargetsByOPId.containsKey(opId)) { continue; }
            objectivesPromotionsToCompleteById.put(opId, this.makeOP(opId));
        }

        upsert objectivesPromotionsToCompleteById.values();
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private Map<Id, List<String>> getMainFieldsFromOPActionByOPId(Set<Id> opIds) {
        List<EUR_CRM_Objectives_Promotions__c> objectivesPromotions = this.selectObjectivesPromotions(opIds);
        if (objectivesPromotions.isEmpty()) { return new Map<Id, List<String>>(); }

        Map<Id, EUR_CRM_OP_Template__c> templateById = this.getTemplateWithOPActionsById(objectivesPromotions);

        Map<Id, List<String>> mainFieldsFromOPActionByOPId = new Map<Id, List<String>>();
        for (EUR_CRM_Objectives_Promotions__c op : objectivesPromotions) {
            Set<String> fieldSet = new Set<String>();
            List<String> fieldList = new List<String>();
            for (EUR_CRM_OP_Action__c opAction : templateById.get(op.EUR_CRM_OP_Template__c).OP_Actions_EU__r) {
                if (opAction.EUR_CRM_MultiPLOpTarget__c == null) { continue; }

                for (String fieldApiName : opAction.EUR_CRM_MultiPLOpTarget__c.split(',')) {
                    if ( ! fieldSet.contains(fieldApiName)) {
                        fieldSet.add(fieldApiName);
                        fieldList.add(fieldApiName);
                    }
                }
            }
            if (fieldList.isEmpty()) { continue; }

            mainFieldsFromOPActionByOPId.put(op.Id, fieldList);
        }
        return mainFieldsFromOPActionByOPId;
    }

    private Map<String, List<String>> getDependedFieldsByMainField(Map<Id, List<String>> mainFieldsFromOPActionByOPId) {
        List<EUR_CRM_OP_Target_Confirmation_Fields__mdt> dependedFieldsCMT = this.getDependedFieldsRelatedTo(mainFieldsFromOPActionByOPId);

        Map<String, List<String>> dependedFieldsByMainField = new Map<String, List<String>>();
        for (EUR_CRM_OP_Target_Confirmation_Fields__mdt fields : dependedFieldsCMT) {
            List<String> dependedFields = new List<String>();
            for (String dependedField : fields.EUR_CRM_Dependent_Target_API_Name_Fields__c.split(',')) {
                if (dependedField.startsWithIgnoreCase(FIELD_API_MASK)) {
                    dependedFields.add(dependedField);
                }
            }
            if (dependedFields.isEmpty()) { continue; }

            dependedFieldsByMainField.put(fields.EUR_CRM_Main_Target_API_Name_Field__c, dependedFields);
        }
        return dependedFieldsByMainField;
    }

    private Map<Id, List<EUR_CRM_OP_Promo_Target__c>> getCompletedPromoTargetsByOPId(Map<Id, List<EUR_CRM_OP_Promo_Target__c>> promoTargetsByOPId, Map<Id, List<String>> mainFieldsFromOPActionByOPId, Map<String, List<String>> dependedFieldsByMainField) {
        Map<Id, List<EUR_CRM_OP_Promo_Target__c>> completedPromoTargetsByOPId = new Map<Id, List<EUR_CRM_OP_Promo_Target__c>>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('EUR_CRM_OP_Promo_Target__c').getDescribe().fields.getMap();
        for (Id opId : promoTargetsByOPId.keySet()) {
            Boolean isAtLeastOneFieldChecked = false;
            Boolean areAllPromoTargetsValid = true;

            for (EUR_CRM_OP_Promo_Target__c promoTarget : promoTargetsByOPId.get(opId)) {
                if ( ! mainFieldsFromOPActionByOPId.containsKey(opId)) { continue; }

                // validate fields specified on OP Action level
                for (String mainField : mainFieldsFromOPActionByOPId.get(opId)) {
                    if (this.isValidField(fieldMap, mainField)) {
                        isAtLeastOneFieldChecked = true;
                        if ( ! this.isValidValue(promoTarget, mainField)) {
                            areAllPromoTargetsValid = false;
                            break;
                        }
                    }

                    // validate depended fields specified on Custom Metadata Type
                    if (dependedFieldsByMainField.containsKey(mainField)) {
                        for (String dependedField : dependedFieldsByMainField.get(mainField)) {
                            if ( ! this.isValidField(fieldMap, dependedField)) { continue; }

                            isAtLeastOneFieldChecked = true;
                            if ( ! this.isValidValue(promoTarget, dependedField)) {
                                areAllPromoTargetsValid = false;
                                break;
                            }
                        }
                    }
                }
            }

            if ( ! isAtLeastOneFieldChecked || ! areAllPromoTargetsValid) { continue; }

            completedPromoTargetsByOPId.put(opId, promoTargetsByOPId.get(opId));
        }
        return completedPromoTargetsByOPId;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Map<Id, List<EUR_CRM_OP_Promo_Target__c>> getPromoTargetsByOPId(List<EUR_CRM_OP_Promo_Target__c> promoTargets) {
        Map<Id, List<EUR_CRM_OP_Promo_Target__c>> promoTargetsByOPId = new Map<Id, List<EUR_CRM_OP_Promo_Target__c>>();
        for (EUR_CRM_OP_Promo_Target__c promoTarget : promoTargets) {
            if (promoTarget.EUR_CRM_Objectives_Promotions__c == null) { continue; }

            if (promoTargetsByOPId.containsKey(promoTarget.EUR_CRM_Objectives_Promotions__c)) {
                promoTargetsByOPId.get(promoTarget.EUR_CRM_Objectives_Promotions__c).add(promoTarget);
            } else {
                promoTargetsByOPId.put(promoTarget.EUR_CRM_Objectives_Promotions__c, new List<EUR_CRM_OP_Promo_Target__c> { promoTarget });
            }
        }
        return promoTargetsByOPId;
    }

    private Map<Id, EUR_CRM_OP_Template__c> getTemplateWithOPActionsById(List<EUR_CRM_Objectives_Promotions__c> ops) {
        Set<Id> templateIds = this.extractTemplateIds(ops);
        return this.selectTemplateWithOPActionsById(templateIds);
    }

    private Set<Id> extractTemplateIds(List<EUR_CRM_Objectives_Promotions__c> objectivesPromotions) {
        Set<Id> templateIds = new Set<Id>();
        for (EUR_CRM_Objectives_Promotions__c op : objectivesPromotions) {
            templateIds.add(op.EUR_CRM_OP_Template__c);
        }
        return templateIds;
    }

    private List<EUR_CRM_OP_Target_Confirmation_Fields__mdt> getDependedFieldsRelatedTo(Map<Id, List<String>> mainFieldsFromOPActionByOPId) {
        Set<String> fields = this.extractFieldSet(mainFieldsFromOPActionByOPId);
        return this.selectDependedFieldsRelatedTo(fields);
    }

    private Set<String> extractFieldSet(Map<Id, List<String>> mainFieldsFromOPActionByOPId) {
        Set<String> fieldSet = new Set<String>();
        for (Id opId : mainFieldsFromOPActionByOPId.keySet()) {
            fieldSet.addAll(mainFieldsFromOPActionByOPId.get(opId));
        }
        return fieldSet;
    }

    private Set<Id> extractPromoTargetIds(Map<Id, List<EUR_CRM_OP_Promo_Target__c>> promoTargetsByOPId) {
        Set<Id> promoTargetIds = new Set<Id>();
        for (Id opId : promoTargetsByOPId.keySet()) {
            for (EUR_CRM_OP_Promo_Target__c promoTarget : promoTargetsByOPId.get(opId)) {
                promoTargetIds.add(promoTarget.Id);
            }
        }
        return promoTargetIds;
    }

    private List<EUR_CRM_OP_Promo_Target__c> getSiblingPromoTargets(Set<Id> opIds, Set<Id> promoTargetIds, Map<String, List<String>> dependedFieldsByMainField) {
        String query = '' +
            'SELECT Id' +
            ',  EUR_CRM_Objectives_Promotions__c' +
            ' {1} ' +
            'FROM EUR_CRM_OP_Promo_Target__c ' +
            'WHERE EUR_CRM_Objectives_Promotions__c IN :opIds ' +
            'AND Id NOT IN :promoTargetIds'
        ;
        query = this.insertAdditionalFieldsToQuery(query, dependedFieldsByMainField);
        return (List<EUR_CRM_OP_Promo_Target__c>)Database.query(query);
    }

    private String insertAdditionalFieldsToQuery(String query, Map<String, List<String>> dependedFieldsByMainField) {
        Set<String> fieldSetToQuery = this.getFieldSetToQuery(dependedFieldsByMainField);
        if(fieldSetToQuery.isEmpty()) { return query.replace('{1}', ''); }

        return query.replace('{1}', ',' + String.join(new List<String>(fieldSetToQuery), ', '));
    }

    private Set<String> getFieldSetToQuery(Map<String, List<String>> dependedFieldsByMainField) {
        Set<String> fieldSetToQuery = new Set<String>();
        for (String mainField : dependedFieldsByMainField.keySet()) {
            fieldSetToQuery.add(mainField);
            fieldSetToQuery.addAll(dependedFieldsByMainField.get(mainField));
        }
        return fieldSetToQuery;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isValidField(Map<String, Schema.SObjectField> fieldMap, String fieldName) {
        return fieldName.startsWithIgnoreCase(FIELD_API_MASK) && fieldMap.containsKey(fieldName);
    }

    private Boolean isValidValue(EUR_CRM_OP_Promo_Target__c promoTarget, String fieldName) {
        return (Decimal)promoTarget.get(fieldName) == 0;
    }

    private EUR_CRM_Objectives_Promotions__c makeOP(Id opId) {
        return new EUR_CRM_Objectives_Promotions__c(
            Id = opId
        ,   EUR_CRM_Status__c = OP_COMPLETED_STATUS
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Objectives_Promotions__c> selectObjectivesPromotions(Set<Id> opIds) {
        return [
            SELECT Id
            ,   EUR_CRM_OP_Template__c
            FROM EUR_CRM_Objectives_Promotions__c
            WHERE Id IN :opIds
                AND EUR_CRM_OP_Template__r.EUR_CRM_Has_Quota__c = TRUE
                AND EUR_CRM_Status__c NOT IN :OP_STATUS_SHOULD_NOT_BE_DEACTIVATED
        ];
    }

    private Map<Id, EUR_CRM_OP_Template__c> selectTemplateWithOPActionsById(Set<Id> templateIds) {
        return new Map<Id, EUR_CRM_OP_Template__c>([
            SELECT Id
            ,   (
                SELECT Id
                ,   EUR_CRM_MultiPLOpTarget__c
                FROM OP_Actions_EU__r
            )
            FROM EUR_CRM_OP_Template__c
            WHERE Id IN :templateIds
        ]);
    }

    private List<EUR_CRM_OP_Target_Confirmation_Fields__mdt> selectDependedFieldsRelatedTo(Set<String> fields) {
        return [
            SELECT Id
            ,   EUR_CRM_Main_Target_API_Name_Field__c
            ,   EUR_CRM_Dependent_Target_API_Name_Fields__c
            FROM EUR_CRM_OP_Target_Confirmation_Fields__mdt
            WHERE EUR_CRM_Main_Target_API_Name_Field__c IN :fields
        ];
    }

}