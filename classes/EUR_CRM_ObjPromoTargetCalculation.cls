public with sharing class EUR_CRM_ObjPromoTargetCalculation {

    public static Boolean runLogic = true;

    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void calculate(List<EUR_CRM_ObjPromo_Target__c> objPromoTargets, Map<Id, EUR_CRM_ObjPromo_Target__c> oldObjPromoTargetsByIds) {
        if (runLogic == false) { return ; }

        Map<Id, EUR_CRM_ObjPromo_Target__c> promoTargetsToHandleById = new Map<Id, EUR_CRM_ObjPromo_Target__c>();

        for (EUR_CRM_ObjPromo_Target__c promoTarget : objPromoTargets) {
            if (hasParentObjectiveTargetLevel(promoTarget) && (this.isActualVolumeBottlesChanged(promoTarget, oldObjPromoTargetsByIds) || this.isActualVolumeDisplayChanged(promoTarget, oldObjPromoTargetsByIds))) {
                promoTargetsToHandleById.put(promoTarget.Id, promoTarget);
            }
        }
        if (promoTargetsToHandleById.isEmpty()) { return ; }
        System.debug('\n\n promoTargetsToHandleById => ' + JSON.serializePretty(promoTargetsToHandleById) + '\n');

        List<EUR_CRM_ObjPromo_Target__c> childrenWithParent = this.selectChildrenWithParent(promoTargetsToHandleById.keySet());

        Map<Id, EUR_CRM_ObjPromo_Target__c> parentTargetsToUpdateById = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
        for (EUR_CRM_ObjPromo_Target__c childTarget : childrenWithParent) {
            EUR_CRM_ObjPromo_Target__c childWithActualData = promoTargetsToHandleById.get(childTarget.Id);

            if (this.isActualVolumeBottlesChanged(childWithActualData, oldObjPromoTargetsByIds)) {
                Decimal shift = childWithActualData.EUR_CRM_Actual_Volume_Bottles__c != null ? childWithActualData.EUR_CRM_Actual_Volume_Bottles__c : 0;
                if (oldObjPromoTargetsByIds.get(childWithActualData.Id).EUR_CRM_Actual_Volume_Bottles__c != null) {
                    shift -= oldObjPromoTargetsByIds.get(childWithActualData.Id).EUR_CRM_Actual_Volume_Bottles__c;
                }

                if (parentTargetsToUpdateById.containsKey(childTarget.EUR_CRM_O_P_Target__c)) {
                    EUR_CRM_ObjPromo_Target__c parent = parentTargetsToUpdateById.get(childTarget.EUR_CRM_O_P_Target__c);

                    Decimal oldValueOnParent = parent.EUR_CRM_Actual_Volume_Bottles__c;
                    if (oldValueOnParent == null) { oldValueOnParent = 0;}

                    parent.EUR_CRM_Actual_Volume_Bottles__c = oldValueOnParent += shift;

                    parentTargetsToUpdateById.put(parent.Id, parent);
                } else {
                    Decimal oldValueOnParent = childTarget.EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Volume_Bottles__c;
                    if (oldValueOnParent == null) { oldValueOnParent = 0;}

                    parentTargetsToUpdateById.put(childTarget.EUR_CRM_O_P_Target__c, new EUR_CRM_ObjPromo_Target__c(
                        Id = childTarget.EUR_CRM_O_P_Target__c
                    ,   EUR_CRM_Actual_Volume_Bottles__c = oldValueOnParent += shift
                    ,   EUR_CRM_Actual_Volume_Displays__c = childTarget.EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Volume_Displays__c
                    ));
                }
            }

            if (this.isActualVolumeDisplayChanged(childWithActualData, oldObjPromoTargetsByIds)) {
                Decimal shift = childWithActualData.EUR_CRM_Actual_Volume_Displays__c;
                if (oldObjPromoTargetsByIds.get(childWithActualData.Id).EUR_CRM_Actual_Volume_Displays__c != null) {
                    shift -= oldObjPromoTargetsByIds.get(childWithActualData.Id).EUR_CRM_Actual_Volume_Displays__c;
                }

                if (parentTargetsToUpdateById.containsKey(childTarget.EUR_CRM_O_P_Target__c)) {
                    EUR_CRM_ObjPromo_Target__c parent = parentTargetsToUpdateById.get(childTarget.EUR_CRM_O_P_Target__c);

                    Decimal oldValueOnParent = parent.EUR_CRM_Actual_Volume_Displays__c;
                    if (oldValueOnParent == null) { oldValueOnParent = 0;}

                    parent.EUR_CRM_Actual_Volume_Displays__c = oldValueOnParent += shift;

                    parentTargetsToUpdateById.put(parent.Id, parent);
                } else {
                    Decimal oldValueOnParent = childTarget.EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Volume_Displays__c;
                    if (oldValueOnParent == null) { oldValueOnParent = 0;}

                    parentTargetsToUpdateById.put(childTarget.EUR_CRM_O_P_Target__c, new EUR_CRM_ObjPromo_Target__c(
                        Id = childTarget.EUR_CRM_O_P_Target__c
                    ,   EUR_CRM_Actual_Volume_Displays__c = oldValueOnParent += shift
                    ,   EUR_CRM_Actual_Volume_Bottles__c = childTarget.EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Volume_Bottles__c
                    ));
                }
            }
        }

        System.debug('\n\n parentTargetsToUpdateById => ' + JSON.serializePretty(parentTargetsToUpdateById) + '\n');
        update parentTargetsToUpdateById.values();
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean hasParentObjectiveTargetLevel(EUR_CRM_ObjPromo_Target__c promoTarget) {
        return promoTarget.EUR_CRM_O_P_Target__c != null
            && this.isSalesRepType(promoTarget)
        ;
    }

    private Boolean isSalesRepType(EUR_CRM_ObjPromo_Target__c promoTarget) {
        return promoTarget.EUR_CRM_Target_Level__c != null
            && promoTarget.EUR_CRM_Target_Level__c.equalsIgnoreCase('Sales Rep')
        ;
    }

    private Boolean isActualVolumeBottlesChanged(EUR_CRM_ObjPromo_Target__c promoTarget, Map<Id, EUR_CRM_ObjPromo_Target__c> oldObjPromoTargetsByIds) {
        System.debug('### ActualVolumeBottlesChanged: '+promoTarget.EUR_CRM_Actual_Volume_Bottles__c != null
                && promoTarget.EUR_CRM_Actual_Volume_Bottles__c != oldObjPromoTargetsByIds.get(promoTarget.Id).EUR_CRM_Actual_Volume_Bottles__c);
        return promoTarget.EUR_CRM_Actual_Volume_Bottles__c != null
            && promoTarget.EUR_CRM_Actual_Volume_Bottles__c != oldObjPromoTargetsByIds.get(promoTarget.Id).EUR_CRM_Actual_Volume_Bottles__c
        ;
    }

    private Boolean isActualVolumeDisplayChanged(EUR_CRM_ObjPromo_Target__c promoTarget, Map<Id, EUR_CRM_ObjPromo_Target__c> oldObjPromoTargetsByIds) {
        System.debug('### ActualVolumeDisplayChanged:'+promoTarget.EUR_CRM_Actual_Volume_Displays__c != null
                && promoTarget.EUR_CRM_Actual_Volume_Displays__c != oldObjPromoTargetsByIds.get(promoTarget.Id).EUR_CRM_Actual_Volume_Displays__c);
        return promoTarget.EUR_CRM_Actual_Volume_Displays__c != null
            && promoTarget.EUR_CRM_Actual_Volume_Displays__c != oldObjPromoTargetsByIds.get(promoTarget.Id).EUR_CRM_Actual_Volume_Displays__c
        ;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_ObjPromo_Target__c> selectChildrenWithParent(Set<Id> ids) {
        return [
            SELECT Id
            ,   EUR_CRM_O_P_Target__c
            ,   EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Volume_Bottles__c
            ,   EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Volume_Displays__c
            FROM EUR_CRM_ObjPromo_Target__c
            WHERE Id IN :ids
        ];
    }


}