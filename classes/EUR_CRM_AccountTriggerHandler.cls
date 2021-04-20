public with sharing class EUR_CRM_AccountTriggerHandler {

    public void onBeforeInsert(List<EUR_CRM_Account__c> accounts) {
        List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>{
                // Assign auto number to name
                // TODO: needs to refactor (waiting for response from customer side)
                new EUR_CRM_AccountAssignAutoNumber(),
                new EUR_CRM_TemplateAssignmentHandler(),
                new EUR_CRM_AccountOwnerManagerHandler()
        };

        //Record Type Filtering
        Set<String> recordTypes = new Set<String>();
        for (EUR_CRM_Account__c acc : accounts) {
            String objectRecordtypeDevName = Global_RecordTypeCache.getRt((String) acc.get('RecordTypeID')).DeveloperName;
            recordTypes.add(objectRecordtypeDevName);
        }


        new EUR_CRM_AccountTerrAssignmentService().onBeforeInsert(accounts);

        triggerClasses.add(new EUR_CRM_AssignAccountCustomerTaxonomy());

        new EUR_CRM_AccountListingTemplateHandler().onBeforeInsert(accounts);

        if (recordTypeValidation(EUR_CRM_Account_City_PostalCode_Handler.TargetRecordSet, recordTypes)) {
            // TODO: needs to refactor
            System.debug('Trigger:EUR_CRM_Account_City_PostalCode_Handler');
            triggerClasses.add(new EUR_CRM_Account_City_PostalCode_Handler());
        }

        if (recordTypeValidation(EUR_CRM_DE_TerritoryAccountHandler.TargetRecordSet, recordTypes)) {
            // TODO: needs to refactor
            System.debug('Trigger:EUR_CRM_DE_TerritoryAccountHandler');
            triggerClasses.add(new EUR_CRM_DE_TerritoryAccountHandler());
        }

        if (recordTypeValidation(EUR_CRM_AccountVisitFrequencyHandler.TargetRecordSet, recordTypes)) {
            // TODO: needs to refactor
            System.debug('Trigger:EUR_CRM_AccountVisitFrequencyHandler');
            triggerClasses.add(new EUR_CRM_AccountVisitFrequencyHandler());
        }


        if (recordTypeValidation(EUR_CRM_ListingTemplateAssignmentHandler.TargetRecordSet, recordTypes)) {
            System.debug('Trigger:EUR_CRM_ListingTemplateAssignmentHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_ListingTemplateAssignmentHandler());
        }

        new EUR_CRM_PRS_ListingTplAssignmentHandler().onBeforeInsert(accounts);

        if (recordTypeValidation(EUR_CRM_ListingTemplateHandler.TargetRecordSet, recordTypes)) {
            System.debug('Trigger:EUR_CRM_ListingTemplateHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_ListingTemplateHandler());
        }

        new EUR_CRM_AccountVisitFrequencyService().updateVisitFrequency(accounts);

        if (recordTypeValidation(EUR_CRM_DE_ListingTemplateHandler.TargetRecordSet, recordTypes)) {
            System.debug('Trigger:EUR_CRM_DE_ListingTemplateHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_DE_ListingTemplateHandler());
        }

        for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_INSERT, accounts, null, null);
            System.debug('Resources:' + String.valueOf(triggerClass).split(':')[0] + 'Queries:[' + Limits.getQueries() + ']|' + 'Rows:[' + Limits.getDmlRows() + '|Statements:[' + Limits.getDmlStatements() + ']');
        }

        EUR_CRM_AccountGeolocationBatch.updateLocationOnbeforeInsert(accounts);
//       Database.executeBatch(new EUR_CRM_AccountGeolocationBatch(), 100);
    }

    public void onAfterInsert(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> newAccountById) {
        List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>{
                new EUR_CRM_EUAccountLinkHandler(),
                // TODO: needs to refactor
                new EUR_CRM_EUAccountCreatePRSegHandler(),
                new EUR_CRM_ShareEUAccountHandler()
        };

        Set<String> RecordTypes = new Set<String>();
        for (EUR_CRM_Account__c acc : accounts) {
            String objectRecordtypeDevName = Global_RecordTypeCache.getRt((String) acc.get('RecordTypeID')).DeveloperName;
            RecordTypes.add(objectRecordtypeDevName);
        }

        if (recordTypeValidation(EUR_CRM_NG_ShareEUAccountHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Tigger:EUR_CRM_NG_ShareEUAccountHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_NG_ShareEUAccountHandler());
        }

        if (recordTypeValidation(EUR_CRM_DE_AccountHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Tigger:EUR_CRM_DE_AccountHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_DE_AccountHandler());
        }
        if (recordTypeValidation(EUR_CRM_DE_PrestigeAccountHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Tigger:EUR_CRM_DE_PrestigeAccountHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_DE_PrestigeAccountHandler());
        }
        if (recordTypeValidation(EUR_CRM_DE_SalesAgencyAccountHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Tigger:EUR_CRM_DE_SalesAgencyAccountHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_DE_SalesAgencyAccountHandler());
        }

//        if (recordTypeValidation(EUR_CRM_FI_ContractAccountHandler.TargetRecordSet,RecordTypes)) {
//            System.debug('Tigger:EUR_CRM_FI_ContractAccountHandler');
//            // TODO: needs to refactor
//            triggerClasses.add(new EUR_CRM_FI_ContractAccountHandler());
//        }
        if (recordTypeValidation(EUR_CRM_FI_OPAccountHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Tigger:EUR_CRM_FI_OPAccountHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_FI_OPAccountHandler());
        }

        if (recordTypeValidation(EUR_CRM_ZA_CreateVolumeTrackerHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Tigger:EUR_CRM_ZA_CreateVolumeTrackerHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_ZA_CreateVolumeTrackerHandler());
        }


        for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_INSERT, accounts, newAccountById, null);
            System.debug('Resources:' + String.valueOf(triggerClass).split(':')[0] + 'Queries:[' + Limits.getQueries() + ']|' + 'Rows:[' + Limits.getDmlRows() + '|Statements:[' + Limits.getDmlStatements() + ']');
        }

        // TODO: needs to refactor
        /*Deactivated by Martin
        EUR_CRM_EU_AccountCreateProsSegHandler handler = new EUR_CRM_EU_AccountCreateProsSegHandler();
        handler.createProsSegRecord(accounts);
		*/
        // TODO: needs to refactor
        new PRH_Account_To_Luxury_Account().executeTriggerAction(PRH_TriggerAbstract.TriggerAction.AFTER_INSERT, accounts, newAccountById, null);

        EUR_CRM_DynamicGroupService.updateDynamicGroups(accounts);
        new EUR_CRM_AccountContractMapHandler().handleAccounts(accounts);
        new EUR_CRM_AccountGroupUserHandler.Service().calculateSharingForParentAccountOwner(Trigger.new);
        EUR_CRM_AccountApprovalProcess.submitForApproval(accounts, null);
    }

    public void onBeforeUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> newAccountById, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>{
                new EUR_CRM_TemplateAssignmentHandler(),
                new EUR_CRM_AccountOwnerManagerHandler()
        };

        Set<String> RecordTypes = new Set<String>();
        for (EUR_CRM_Account__c acc : accounts) {
            String objectRecordtypeDevName = Global_RecordTypeCache.getRt((String) acc.get('RecordTypeID')).DeveloperName;
            RecordTypes.add(objectRecordtypeDevName);
        }

        new EUR_CRM_AccountTerrAssignmentService().onBeforeUpdate(accounts, oldAccountById);

        new EUR_CRM_AccountListingTemplateHandler().onBeforeUpdate(accounts, oldAccountById);

        if (recordTypeValidation(EUR_CRM_Account_City_PostalCode_Handler.TargetRecordSet, recordTypes)) {
            // TODO: needs to refactor
            System.debug('Trigger:EUR_CRM_Account_City_PostalCode_Handler');
            triggerClasses.add(new EUR_CRM_Account_City_PostalCode_Handler());
        }

        if (recordTypeValidation(EUR_CRM_DE_TerritoryAccountHandler.TargetRecordSet, recordTypes)) {
            // TODO: needs to refactor
            System.debug('Trigger:EUR_CRM_DE_TerritoryAccountHandler');
            triggerClasses.add(new EUR_CRM_DE_TerritoryAccountHandler());
        }

        if (recordTypeValidation(EUR_CRM_ForceIconicAccountHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_ForceIconicAccountHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_ForceIconicAccountHandler());
        }

        if (recordTypeValidation(EUR_CRM_PRS_ForceImageLevelHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_PRS_ForceImageLevelHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_PRS_ForceImageLevelHandler());
        }

        if (recordTypeValidation(EUR_CRM_ForceImageLevelHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_ForceImageLevelHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_ForceImageLevelHandler());
        }

        if (recordTypeValidation(EUR_CRM_ForcePRSegDimensionsHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_ForcePRSegDimensionsHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_ForcePRSegDimensionsHandler());
        }

        if (recordTypeValidation(EUR_CRM_AccountVisitFrequencyHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_AccountVisitFrequencyHandler');
            triggerClasses.add(new EUR_CRM_AccountVisitFrequencyHandler());
        }

        if (recordTypeValidation(EUR_CRM_ListingTemplateAssignmentHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_ListingTemplateAssignmentHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_ListingTemplateAssignmentHandler());
        }

        if (recordTypeValidation(EUR_CRM_ListingTemplateHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_ListingTemplateHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_ListingTemplateHandler());
        }



        if (recordTypeValidation(EUR_CRM_DE_ListingTemplateHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_DE_ListingTemplateHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_DE_ListingTemplateHandler());
        }

        new EUR_CRM_AccountVisitFrequencyService().updateVisitFrequency(accounts, oldAccountById);

        for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_UPDATE, accounts, newAccountById, oldAccountById);
            System.debug('Resources:' + String.valueOf(triggerClass).split(':')[0] + 'Queries:[' + Limits.getQueries() + ']|' + 'Rows:[' + Limits.getDmlRows() + '|Statements:[' + Limits.getDmlStatements() + ']');
        }

        new EUR_CRM_PRS_ListingTplAssignmentHandler().onBeforeUpdate(accounts, oldAccountById);

        EUR_CRM_AccountGeolocationBatch.updateLocationOnbeforeUpdate(accounts, oldAccountById);
    }

    public void onAfterUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> newAccountById, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>{
                new EUR_CRM_EUAccountLinkHandler(),
                new EUR_CRM_EventCleanUpHandler(),
                new EUR_CRM_ShareEUAccountHandler()
        };
        Set<String> RecordTypes = new Set<String>();
        for (EUR_CRM_Account__c acc : accounts) {
            String objectRecordtypeDevName = Global_RecordTypeCache.getRt((String) acc.get('RecordTypeID')).DeveloperName;
            RecordTypes.add(objectRecordtypeDevName);
        }

        if (recordTypeValidation(EUR_CRM_OutletToSupplierHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_OutletToSupplierHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_OutletToSupplierHandler());
        }
        /*Deactivated by Martin
        if (recordTypeValidation(EUR_CRM_DE_AccountHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_DE_AccountHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_DE_AccountHandler());
        }
        */

        if (recordTypeValidation(EUR_CRM_DE_PrestigeAccountHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_DE_PrestigeAccountHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_DE_PrestigeAccountHandler());
        }
        if (recordTypeValidation(EUR_CRM_DE_SalesAgencyAccountHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_DE_SalesAgencyAccountHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_DE_SalesAgencyAccountHandler());
        }
        System.debug('Trigger:EUR_CRM_DE_ContactAccountHandler');
        // TODO: needs to refactor
        triggerClasses.add(new EUR_CRM_DE_ContactAccountHandler());

        if (recordTypeValidation(EUR_CRM_FI_OPAccountHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_FI_OPAccountHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_FI_OPAccountHandler());
        }
        if (recordTypeValidation(EUR_CRM_FI_ContractAccountHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_FI_ContractAccountHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_FI_ContractAccountHandler());
        }

        if (recordTypeValidation(EUR_CRM_NG_ShareEUAccountHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_NG_ShareEUAccountHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_NG_ShareEUAccountHandler());
        }
//
//        if (recordTypeValidation(EUR_CRM_ZA_OPAccountFlowHandler.TargetRecordSet, RecordTypes)) {
//            System.debug('Trigger:EUR_CRM_ZA_OPAccountFlowHandler');
//            // TODO: needs to refactor
//            triggerClasses.add(new EUR_CRM_ZA_OPAccountFlowHandler());
//        }
//        if (recordTypeValidation(EUR_CRM_ZA_UpdatePOSMWarehouseMngrHandlr.TargetRecordSet, RecordTypes)) {
//            System.debug('Trigger:EUR_CRM_ZA_UpdatePOSMWarehouseMngrHandlr');
//            // TODO: needs to refactor
//            triggerClasses.add(new EUR_CRM_ZA_UpdatePOSMWarehouseMngrHandlr());
//        }
        if (recordTypeValidation(EUR_CRM_ZA_UpdateMngrsOnContractHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger:EUR_CRM_ZA_UpdateMngrsOnContractHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_ZA_UpdateMngrsOnContractHandler());
        }

        if (recordTypeValidation(EUR_CRM_PRS_ForceImageLevelHandler.TargetRecordSet, RecordTypes)) {
            System.debug('Trigger afger update:EUR_CRM_PRS_ForceImageLevelHandler');
            // TODO: needs to refactor
            triggerClasses.add(new EUR_CRM_PRS_ForceImageLevelHandler());
        }


        for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, accounts, newAccountById, oldAccountById);
            //Debug remove by Martin
            //System.debug('Resources:' + String.valueOf(triggerClass).split(':')[0] + 'Queries:[' + Limits.getQueries() + ']|' + 'Rows:[' + Limits.getDmlRows() + '|Statements:[' + Limits.getDmlStatements() + ']');
        }
        /*Deactivated by Martin
        if (trigger.isUpdate) {
            EUR_CRM_EU_AccountCreateProsSegHandler handler = new EUR_CRM_EU_AccountCreateProsSegHandler();
            handler.createProsSegRecord(accounts);
        }
        */
//
//        // TODO: needs to refactor
        new PRH_Account_To_Luxury_Account().executeTriggerAction(PRH_TriggerAbstract.TriggerAction.AFTER_UPDATE, accounts, newAccountById, oldAccountById);
        System.debug('Review ERROR');
        System.debug('accounts - ' + accounts);
        System.debug('oldAccountById - ' + oldAccountById);
        EUR_CRM_DynamicGroupService.updateDynamicGroups(accounts, oldAccountById);

        new EUR_CRM_AccountOwnerHandler().handleOwnerChanging(accounts, oldAccountById);
        new EUR_CRM_AccountContractMapHandler().handleAccounts(accounts, oldAccountById);

        new EUR_CRM_AccountIsProsUpdateService().handleIsProsUpdateUncheck(Trigger.new, (Map<Id, EUR_CRM_Account__c>) Trigger.oldMap);

        //EUR_CRM_AccountChildrenSharingBatch.runForAccountsOwnerChanging(Trigger.new, (Map<Id, EUR_CRM_Account__c>)Trigger.oldMap);
        EUR_CRM_AccountApprovalProcess.submitForApproval(accounts, oldAccountById);
        new EUR_CRM_AccountGroupUserHandler.Service().recalculateSharingForParentAccountOwner(Trigger.new, (Map<Id, EUR_CRM_Account__c>) Trigger.oldMap);
        new EUR_CRM_AccountGroupUserHandler.Service().recalculateSharingForChildAccountOwner(Trigger.new, (Map<Id, EUR_CRM_Account__c>) Trigger.oldMap);

       // new EUR_CRM_PRS_ListingTplAssignmentHandler().assignListingTemplateAfterUpdate(Trigger.new, (Map<Id, EUR_CRM_Account__c>) Trigger.oldMap);
    }

    public void onBeforeDelete(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>{
                new EUR_CRM_EUAccountLinkHandler()
        };

        for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.BEFORE_DELETE, accounts, null, oldAccountById);
        }

        EUR_CRM_AccountGroupDeletionHandler.deleteAccountGroups(accounts, oldAccountById);
    }

    public void onAfterDelete(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract>{
                new EUR_CRM_EventCleanUpHandler(),
                // TODO: needs to refactor
                new EUR_CRM_ProsSegmentationCleanUpHandler()
        };

        for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
            triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_DELETE, accounts, null, oldAccountById);
        }
    }

    public void onAfterUndelete(List<EUR_CRM_Account__c> accounts) {
        EUR_CRM_DynamicGroupService.updateDynamicGroups(accounts);
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    public static Boolean recordTypeValidation(Set<String> targetRecordTypeName, Set<String> recordTypeName) {
        Integer orgSize = targetRecordTypeName.size();

        targetRecordTypeName.removeAll(recordTypeName);
        if (orgSize != targetRecordTypeName.size()) {
            return true;
        }
        return false;
    }

}