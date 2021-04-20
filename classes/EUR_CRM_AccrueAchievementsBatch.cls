global class EUR_CRM_AccrueAchievementsBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>, Schedulable {

//    Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);

//    String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
//    EUR_CRM_AccrueAchievementsBatch scheduledJob = new EUR_CRM_AccrueAchievementsBatch();
//    System.schedule('EUR_CRM_AccrueAchievementsBatch: Accrue Achievements Scheduled Job', cronExpression, scheduledJob);

    private final String WHATEVER = 'WHATEVER';

    private final Map<String, String> vaQuantityFieldsByVARTDevName = new Map<String, String>{
        'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty' => 'EUR_CRM_Sell_In_Volume_Bottles__c,EUR_CRM_Sell_In_Volume_Displays__c'
    ,   'EUR_BE_OFF_Secondary_Placement_ConfParticipation' => 'EUR_CRM_No_of_Spyder_Displays_Placed__c'
    ,   'EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty' => 'EUR_CRM_Sell_In_Volume_Bottles__c,EUR_CRM_Quantity_of_Kits__c'

    ,   'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Carton' => 'EUR_CRM_Sell_In_Volume_Bottles__c'
    ,   'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Gondola' => 'EUR_CRM_Sell_In_Volume_Bottles__c'
    ,   'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Promo_Display' => 'EUR_CRM_Sell_In_Volume_Bottles__c'
    ,   'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Standard' => 'EUR_CRM_Sell_In_Volume_Bottles__c'
    ,   'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Theme' => 'EUR_CRM_Sell_In_Volume_Bottles__c'
    ,   'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Bottles' => 'EUR_CRM_Sell_In_Volume_SKUs__c'
    ,   'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Cartons' => 'EUR_CRM_Sell_In_Volume_SKUs__c'
    ,   'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Displays' => 'EUR_CRM_Sell_In_Volume_SKUs__c'

    ,   'EUR_SE_ON_Listing_Agree_To_List' => 'EUR_CRM_Number_of_Listing__c'
    ,   'EUR_SE_ON_Volume_Campaign_Sell_In_Qty' => 'EUR_CRM_Sell_In_Volume_Bottles__c'
    ,   'EUR_SE_ON_Volume_Campaign_Bundles_Sell_In_Qty' => 'EUR_CRM_Sell_In_Volume_Pallets_Bundles__c'
    ,   'EUR_SE_ON_Slow_Moving_Sell_In_Qty' => 'EUR_CRM_Sell_In_Volume_Bottles__c'
    ,   'EUR_SE_ON_Events_Agree_To_Participate' => 'EUR_CRM_Number_of_People__c'
    ,   'EUR_SE_ON_Education_Nb_of_People' => 'EUR_CRM_Number_of_People__c'
    ,   'EUR_SE_ON_Staff_Communication_Nb_of_People' => 'EUR_CRM_Number_of_People__c'

    ,   'EUR_RU_ON_Enter_Promo_Kit_Quantity' => 'EUR_CRM_Promo_Kit_Quantity__c'
    ,   'EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement' => WHATEVER
    };

    private final Map<String, String> targetQuantityFieldsByVARTDevName = new Map<String, String>{
        'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Carton' => 'EUR_CRM_Actual_Volume_Bottles__c'
    ,   'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Gondola' => 'EUR_CRM_Actual_Volume_Bottles__c'
    ,   'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Promo_Display' => 'EUR_CRM_Actual_Volume_Bottles__c'
    ,   'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Standard' => 'EUR_CRM_Actual_Volume_Bottles__c'
    ,   'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Theme' => 'EUR_CRM_Actual_Volume_Bottles__c'
    ,   'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Bottles' => 'EUR_CRM_Actual_Volume_Bottles__c'
    ,   'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Cartons' => 'EUR_CRM_Actual_Volume_Bottles__c'
    ,   'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Displays' => 'EUR_CRM_Actual_Volume_Bottles__c'

    ,   'EUR_SE_ON_Listing_Agree_To_List' => 'EUR_CRM_Actual_Quantity_Listing__c'
    ,   'EUR_SE_ON_Volume_Campaign_Sell_In_Qty' => 'EUR_CRM_Actual_Volume_Bottles__c'
    ,   'EUR_SE_ON_Volume_Campaign_Bundles_Sell_In_Qty' => 'EUR_CRM_Actual_Volume_Bottles__c'
    ,   'EUR_SE_ON_Slow_Moving_Sell_In_Qty' => 'EUR_CRM_Actual_Volume_Bottles__c'
    ,   'EUR_SE_ON_Events_Agree_To_Participate' => 'EUR_CRM_Actual_Number_of_Commitments__c'
    ,   'EUR_SE_ON_Education_Nb_of_People' => 'EUR_CRM_Actual_Quantity_People__c'
    ,   'EUR_SE_ON_Staff_Communication_Nb_of_People' => 'EUR_CRM_Actual_Quantity_People__c'

    ,   'EUR_RU_ON_Enter_Promo_Kit_Quantity' => 'EUR_CRM_Actual_Quantity_Promo_Kits__c'
    ,   'EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement' => 'EUR_CRM_Actual_Volume_Bottles__c'
    };

    private final Map<String, String> targetQuantityFieldByVAQuantityField = new Map<String, String>{
        'EUR_CRM_Sell_In_Volume_Bottles__c' => 'EUR_CRM_Actual_Volume_Bottles__c'
    ,   'EUR_CRM_Sell_In_Volume_Displays__c' => 'EUR_CRM_Actual_Volume_Displays__c'
    ,   'EUR_CRM_No_of_Spyder_Displays_Placed__c' => 'EUR_CRM_Actual_Quantity_Spyder__c'
    ,   'EUR_CRM_Quantity_of_Kits__c' => 'EUR_CRM_Actual_Quantity_Promo_Kits__c'
    };

    private final Set<String> OP_TARGET_RT_DEV_NAMES = new Set<String> {
        'EUR_BE_SR_Volume_Target'
    ,   'EUR_DK_SR_Volume_Target'
    ,   'EUR_SE_Objective_Listing_Target'
    ,   'EUR_SE_Objective_Volume_Target'
    ,   'EUR_SE_Objective_Product'
    ,   'EUR_SE_Objective_People_Target'
    ,   'EUR_SE_SR_People_Target'
    ,   'EUR_RU_Manager_POSM_Target'
    ,   'EUR_RU_Objective_POSM_Target'
    ,   'EUR_RU_Objective_Product'
    ,   'EUR_RU_Sales_Rep_POSM_Target'
    };

    private Map<String, String> vaStatusByVARTDevName = new Map<String, String> {
        'EUR_SE_ON_Listing_Agree_To_List' => 'Yes'
    ,   'EUR_SE_ON_Events_Agree_To_Participate' => 'Participating'

    ,   'EUR_RU_ON_Enter_Promo_Kit_Quantity' => 'Yes'
    ,   'EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement' => 'Participating'
    };

    private Set<String> vaRTDevNames = vaQuantityFieldsByVARTDevName.keySet();

    private Map<Id, EUR_CRM_ObjPromo__c> objPromosToUpdateById;
    private Map<Id, EUR_CRM_ObjPromo_Target__c> promoTargetsToUpdateById;

    global EUR_CRM_AccrueAchievementsBatch() {
        this.objPromosToUpdateById = new Map<Id, EUR_CRM_ObjPromo__c>();
        this.promoTargetsToUpdateById = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EUR_CRM_AccrueAchievementsBatch(), 200);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id
            FROM EUR_CRM_Visit_Action__c
            WHERE RecordType.DeveloperName IN :this.vaRTDevNames
                AND EUR_CRM_Is_Accrued__c = FALSE
        ]);
    }

    global void execute(Database.BatchableContext BC, List<EUR_CRM_Visit_Action__c> visitActions) {
        visitActions = this.selectVisitActions(new Map<Id, EUR_CRM_Visit_Action__c>(visitActions).keySet());
        System.debug('\n\n visitActions.size() => ' + JSON.serializePretty(visitActions.size()) + '\n');
        System.debug('\n\n visitActions => ' + JSON.serializePretty(visitActions) + '\n');

        for (EUR_CRM_Visit_Action__c action : visitActions) {
            if (this.isValidStatus(action) || this.shouldUpdateStatusAnyway(action)) {
                action.EUR_CRM_Is_Accrued__c = true;
            }

            if (this.isParentOPTargetVolume(action) || this.shouldProceedAction(action)) {
                for (String vaQuantityField : this.vaQuantityFieldsByVARTDevName.get(action.RecordType.DeveloperName).split(',')) {
                    Decimal vaQuantityValue = vaQuantityField == WHATEVER ? 1 : this.getDecimalValue((action.get(vaQuantityField)));

                    if ((this.isValidQuantity(vaQuantityValue))
                        && this.isValidStatus(action)
                        && action.EUR_CRM_ObjPromo_Target__c != null
                        ) {
                        EUR_CRM_ObjPromo_Target__c target = this.updateFieldOnRelatedTargetRecord(action, vaQuantityField);

                        if(action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__c != null) {
                            EUR_CRM_ObjPromo_Target__c parentOfTarget = this.updateFieldOnRelatedParentTargetRecord(action, vaQuantityField);
                            this.promoTargetsToUpdateById.put(parentOfTarget.Id, parentOfTarget);

                            this.updateRelatedOPStatus(action);
                        }

                        if (vaQuantityField.equalsIgnoreCase('EUR_CRM_Sell_In_Volume_Displays__c')
                            && action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_SKU__c != null
                            && action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c != null
                            ) {
                            this.updateAdditionalRelatedTarget(action, target, vaQuantityValue);

                            if(action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__c != null) {
                                EUR_CRM_ObjPromo_Target__c parentOfTarget = updateAdditionalRelatedParentTarget(action, vaQuantityValue);
                                this.promoTargetsToUpdateById.put(parentOfTarget.Id, parentOfTarget);
                            }
                        }

                        this.promoTargetsToUpdateById.put(target.Id, target);

                        break;
                    }
                }
            }
        }

        EUR_CRM_ObjPromoTargetCalculation.runLogic = false;

        System.debug('\n\n visitActions.size() => ' + JSON.serializePretty(visitActions.size()) + '\n');
        System.debug('\n\n visitActions => ' + JSON.serializePretty(visitActions) + '\n');
        this.upsertRecords(visitActions);
        System.debug('\n\n this.objPromosToUpdateById.size() => ' + JSON.serializePretty(this.objPromosToUpdateById.size()) + '\n');
        System.debug('\n\n this.objPromosToUpdateById => ' + JSON.serializePretty(this.objPromosToUpdateById) + '\n');
        this.upsertRecords(this.objPromosToUpdateById.values());
        System.debug('\n\n this.promoTargetsToUpdateById.size() => ' + JSON.serializePretty(this.promoTargetsToUpdateById.size()) + '\n');
        System.debug('\n\n this.promoTargetsToUpdateById => ' + JSON.serializePretty(this.promoTargetsToUpdateById) + '\n');
        this.upsertRecords(this.promoTargetsToUpdateById.values());
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private EUR_CRM_ObjPromo_Target__c updateFieldOnRelatedTargetRecord(EUR_CRM_Visit_Action__c action, String vaQuantityField) {
        Decimal vaQuantityValue = vaQuantityField == WHATEVER ? 1 : this.getDecimalValue(action.get(vaQuantityField));
        String targetQuantityField = null;
        if (this.targetQuantityFieldsByVARTDevName.containsKey(action.RecordType.DeveloperName)) {
            targetQuantityField = this.targetQuantityFieldsByVARTDevName.get(action.RecordType.DeveloperName);
        } else {
            targetQuantityField = this.targetQuantityFieldByVAQuantityField.get(vaQuantityField);
        }

        EUR_CRM_ObjPromo_Target__c target = this.promoTargetsToUpdateById.get(action.EUR_CRM_ObjPromo_Target__c);
        Decimal currentTargetQuantity = null;
        if (target == null) {
            target = new EUR_CRM_ObjPromo_Target__c(
                Id = action.EUR_CRM_ObjPromo_Target__c
            );
            currentTargetQuantity = this.getDecimalValue(action.EUR_CRM_ObjPromo_Target__r.get(targetQuantityField));
        } else {
            currentTargetQuantity = this.getDecimalValue(target.get(targetQuantityField));
        }

        if (currentTargetQuantity == null) { currentTargetQuantity = 0; }
        target.put(targetQuantityField, currentTargetQuantity + vaQuantityValue);
        return target;
    }

    private EUR_CRM_ObjPromo_Target__c updateFieldOnRelatedParentTargetRecord(EUR_CRM_Visit_Action__c action, String vaQuantityField) {
        Decimal vaQuantityValue = vaQuantityField == WHATEVER ? 1 : this.getDecimalValue(action.get(vaQuantityField));
        String targetQuantityField = null;
        if (this.targetQuantityFieldsByVARTDevName.containsKey(action.RecordType.DeveloperName)) {
            targetQuantityField = this.targetQuantityFieldsByVARTDevName.get(action.RecordType.DeveloperName);
        } else {
            targetQuantityField = this.targetQuantityFieldByVAQuantityField.get(vaQuantityField);
        }

        EUR_CRM_ObjPromo_Target__c parentOfTarget = this.promoTargetsToUpdateById.get(action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__c);
        Decimal currentTargetQuantity = null;
        if (parentOfTarget == null) {
            parentOfTarget = new EUR_CRM_ObjPromo_Target__c(
                Id = action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__c
            );
            currentTargetQuantity = this.getDecimalValue(action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.get(targetQuantityField));
        } else {
            currentTargetQuantity = this.getDecimalValue(parentOfTarget.get(targetQuantityField));
        }
        if (currentTargetQuantity == null) { currentTargetQuantity = 0; }
        parentOfTarget.put(targetQuantityField, currentTargetQuantity + vaQuantityValue);
        return parentOfTarget;
    }

    private void updateRelatedOPStatus(EUR_CRM_Visit_Action__c action) {
        if (action.RecordType.DeveloperName.contains('EUR_BE_')
            && action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__c != null
            && action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_ObjPromo__c != null
            ) {
            Decimal actualValue = this.getDecimalValue(action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Quantity_Spyder__c);
            Decimal targetValue = this.getDecimalValue(action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_Target_Quantity_Spyders__c);
            if (actualValue >= targetValue) {
                Id objPromoId = action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_ObjPromo__c;
                this.objPromosToUpdateById.put(objPromoId, new EUR_CRM_ObjPromo__c(
                    Id = objPromoId
                ,   EUR_CRM_Status__c = 'Under Evaluation'
                ));
            }
        }
    }

    private void updateAdditionalRelatedTarget(EUR_CRM_Visit_Action__c action, EUR_CRM_ObjPromo_Target__c target, Decimal vaQuantityValue) {
        Decimal currentBottleQty = this.getDecimalValue(target.get('EUR_CRM_Actual_Volume_Bottles__c'));
        if (currentBottleQty == null) { currentBottleQty = 0; }

        target.put('EUR_CRM_Actual_Volume_Bottles__c', currentBottleQty + (vaQuantityValue * action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c));
    }

    private EUR_CRM_ObjPromo_Target__c updateAdditionalRelatedParentTarget(EUR_CRM_Visit_Action__c action, Decimal vaQuantityValue) {
        EUR_CRM_ObjPromo_Target__c parentOfTarget = this.promoTargetsToUpdateById.get(action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__c);
        Decimal currentBottleQty = null;
        if (parentOfTarget == null) {
            parentOfTarget = new EUR_CRM_ObjPromo_Target__c(
                Id = action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__c
            );
            currentBottleQty = this.getDecimalValue(action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.get('EUR_CRM_Actual_Volume_Bottles__c'));
        } else {
            currentBottleQty = this.getDecimalValue(parentOfTarget.get('EUR_CRM_Actual_Volume_Bottles__c'));
        }
        if (currentBottleQty == null) { currentBottleQty = 0; }

        parentOfTarget.put('EUR_CRM_Actual_Volume_Bottles__c', currentBottleQty + (vaQuantityValue * action.EUR_CRM_ObjPromo_Target__r.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c));
        return parentOfTarget;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isParentOPTargetVolume(EUR_CRM_Visit_Action__c action) {
        return action.EUR_CRM_ObjPromo_Target__c != null
            && OP_TARGET_RT_DEV_NAMES.contains(action.EUR_CRM_ObjPromo_Target__r.RecordType.DeveloperName)
        ;
    }

    private Boolean shouldProceedAction(EUR_CRM_Visit_Action__c action) {
        return action.RecordType.DeveloperName.contains('EUR_RU_');
    }

    private Boolean isValidQuantity(Decimal value) {
        return value != null && value > 0;
    }

    private Boolean isValidStatus(EUR_CRM_Visit_Action__c action) {
        if ( ! this.vaStatusByVARTDevName.containsKey(action.RecordType.DeveloperName)) {
            return true;
        }

        return action.EUR_CRM_Status__c.equalsIgnoreCase(this.vaStatusByVARTDevName.get(action.RecordType.DeveloperName));
    }

    private Boolean shouldUpdateStatusAnyway(EUR_CRM_Visit_Action__c action) {
        return action.RecordType.DeveloperName.contains('EUR_SE_');
    }

    private Decimal getDecimalValue(Object fieldValue) {
        return fieldValue == null ? null : Decimal.valueOf(String.valueOf(fieldValue));
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_Visit_Action__c> selectVisitActions(Set<Id> ids) {
        return [
            SELECT Id
            ,   Name
            ,   EUR_CRM_Status__c
            ,   EUR_CRM_Sell_In_Volume_Bottles__c
            ,   EUR_CRM_Sell_In_Volume_Displays__c
            ,   EUR_CRM_Sell_In_Volume_SKUs__c
            ,   EUR_CRM_No_of_Spyder_Displays_Placed__c
            ,   EUR_CRM_Quantity_of_Kits__c
            ,   EUR_CRM_Number_of_Listing__c
            ,   EUR_CRM_Sell_In_Volume_Pallets_Bundles__c
            ,   EUR_CRM_Promo_Kit_Quantity__c
            ,   EUR_CRM_Number_of_People__c
            ,   RecordType.DeveloperName

            ,   EUR_CRM_ObjPromo_Target__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Volume_Bottles__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Volume_Displays__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Quantity_Spyder__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Quantity_Promo_Kits__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_Target_Quantity_Spyders__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_ObjPromo__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_Target_Owner__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Quantity_Listing__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Number_of_Commitments__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Quantity_People__c
            ,   EUR_CRM_ObjPromo_Target__r.RecordType.DeveloperName

            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.Name
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_ObjPromo__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_Visit_Targets__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Volume_Bottles__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Volume_Displays__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Quantity_Spyder__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Quantity_Promo_Kits__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_Target_Quantity_Spyders__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Quantity_Listing__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Number_of_Commitments__c
            ,   EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__r.EUR_CRM_Actual_Quantity_People__c

            ,   EUR_CRM_SKU__c
            ,   EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c

            FROM EUR_CRM_Visit_Action__c
            WHERE Id IN :ids
        ];
    }

}