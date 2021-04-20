global class EUR_CRM_AccGroupUserSharingBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>, Schedulable, Database.Stateful {

//    Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(), 200);

//    String cronExpression = '0 0 3 * * ?'; // Runs every day at 3 AM
//    EUR_CRM_AccGroupUserSharingBatch scheduledJob = new EUR_CRM_AccGroupUserSharingBatch();
//    System.schedule('Account Group User Sharing Scheduled Job', cronExpression, scheduledJob);

    @TestVisible
    private static final String NEW_STATUS = 'New';
    @TestVisible
    private static final String RECORD_SHARED = 'Record shared';
    @TestVisible
    private static final String TO_DELETE_STATUS = 'To Delete';

    private Set<String> statuses = new Set<String>();
    private Set<Id> aguIds;
    private Set<Id> accountGroupIds;
    private Boolean updateSharedRecords = false;

    //Fire the batch normally
    global EUR_CRM_AccGroupUserSharingBatch() {
        this.aguIds = null;
        this.accountGroupIds = new Set<Id>();
    }

    //I don't understand this part, fire the batch from where?? For child objects only?
    global EUR_CRM_AccGroupUserSharingBatch(Set<Id> accIds, Boolean updateSharedRecords) {
        this.accountGroupIds = new Set<Id>();
        Set<Id> agIdsToSelectAGUs = new Map<Id, EUR_CRM_AccountGroup__c>(this.selectAGsWhereAccIds(accIds)).keySet();
        this.aguIds = new Map<Id, EUR_CRM_AccountGroupUser__c>(this.selectAGUsWhereAGs(agIdsToSelectAGUs)).keySet();
        this.updateSharedRecords = updateSharedRecords;
    }
    // Fire the batch from a specific account group user
    global EUR_CRM_AccGroupUserSharingBatch(Id aguId) {
        this.aguIds = new Set<Id> { aguId };
        this.accountGroupIds = new Set<Id>();
    }

    //Fire the batch from an account group
    global EUR_CRM_AccGroupUserSharingBatch(Set<Id> aguIds) {
        this.aguIds = aguIds;
        this.accountGroupIds = new Set<Id>();
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(), 200);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        List<EUR_CRM_AccountGroupUser__c> agus = new List<EUR_CRM_AccountGroupUser__c>();
        //Repeat existing logic, not sure why we want the record shared here
        if (this.updateSharedRecords) {
            statuses.add(RECORD_SHARED);
            agus = [
                SELECT EUR_CRM_AccountGroup__r.EUR_CRM_Account__c FROM EUR_CRM_AccountGroupUser__c 
                WHERE EUR_CRM_Status__c IN :statuses AND Id IN :this.aguIds
            ];
        } else {
            statuses.add(NEW_STATUS);
            statuses.add(TO_DELETE_STATUS);
            
            if (this.aguIds != null) {
                agus = [
                    SELECT EUR_CRM_AccountGroup__r.EUR_CRM_Account__c FROM EUR_CRM_AccountGroupUser__c 
                    WHERE EUR_CRM_Status__c IN :statuses AND Id IN :this.aguIds
                ];
            } else {
                agus = [
                    SELECT EUR_CRM_AccountGroup__r.EUR_CRM_Account__c FROM EUR_CRM_AccountGroupUser__c 
                    WHERE EUR_CRM_Status__c IN :statuses
                ];
            }
        }
        System.debug('Number of AGUS: ' + agus.size());

        Set<Id> accId = new Set<Id>();
        for(EUR_CRM_AccountGroupUser__c agu : agus) {
            accId.add(agu.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c);
        }
        System.debug('Number of accounts: ' + accId.size());
        return Database.getQueryLocator([
            SELECT Id, EUR_CRM_Visible_To_ID1__c, EUR_CRM_Visible_To_ID2__c 
            FROM EUR_CRM_Account__c 
            WHERE Id IN :accId
        ]);
    }
    
    private List<EUR_CRM_AccountGroupUser__c> getAGUS(Set<Id> accIds) {
        if(this.aguIds == null) {
            return [
                SELECT Id
                ,   EUR_CRM_AccountGroup__r.EUR_CRM_Status__c
                ,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__c
                ,   EUR_CRM_AccountGroup__r.EUR_CRM_Country_Code__c
                ,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Visible_to_ID1__c
                ,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Visible_to_ID2__c
                ,   EUR_CRM_User__c
                ,   EUR_CRM_Status__c
                ,   EUR_CRM_AccessLevel__c
                FROM EUR_CRM_AccountGroupUser__c
                WHERE EUR_CRM_Status__c IN :this.statuses AND EUR_CRM_AccountGroup__r.EUR_CRM_Account__c IN :accIds
            ];
        } else {
            return [
                SELECT Id
                ,   EUR_CRM_AccountGroup__r.EUR_CRM_Status__c
                ,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__c
                ,   EUR_CRM_AccountGroup__r.EUR_CRM_Country_Code__c
                ,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Visible_to_ID1__c
                ,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Visible_to_ID2__c
                ,   EUR_CRM_User__c
                ,   EUR_CRM_Status__c
                ,   EUR_CRM_AccessLevel__c
                FROM EUR_CRM_AccountGroupUser__c
                WHERE EUR_CRM_Status__c IN :this.statuses AND Id IN :this.aguIds AND EUR_CRM_AccountGroup__r.EUR_CRM_Account__c IN :accIds
            ];
        }
    }
    global void execute(Database.BatchableContext BC, List<EUR_CRM_Account__c> accountsBatch) {
        //First change, since we start the batch from the account, 
        //we need to know retrieve here the AGU we used to retrieve in the start method
        //It will add one SOQL but it should be fine
        Set<Id> accountIdsBatch = new Set<Id>();
        for(EUR_CRM_Account__c a : accountsBatch) {
            accountIdsBatch.add(a.Id);
        }
        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = getAGUS(accountIdsBatch);
        //Operation must be done at the beginning, if we do it after all AGU will have the status record shared
        //And we won't know which ID to remove/add
        Map<Id, EUR_CRM_Account__c> accToUpdate = EUR_CRM_AccGroupUserSharingService.setVisibleToID(accountGroupUsers);
        System.debug('Visible to ID:' + accToUpdate);

        //And the we follow the current code

        System.debug('\n\n accountGroupUsers => ' + JSON.serializePretty(accountGroupUsers) + '\n');
        EUR_CRM_AccGroupUserSharingService sharingService = new EUR_CRM_AccGroupUserSharingService(accountGroupUsers);

        

        //edited 02/02/2020 to fix 'First error: Cannot have more than 10 chunks in a single operation.'
//        List<SObject> sObjectsToInsert = new List<SObject>();
//        sObjectsToInsert.addAll((List<SObject>)sharingService.getEUAccountSharesToInsert());
//        sObjectsToInsert.addAll((List<SObject>)sharingService.getAccountSharesToInsert());

        List<EUR_CRM_Account__Share> euAccSharesToInsert = sharingService.getEUAccountSharesToInsert();
        List<AccountShare> accSharesToInsert = sharingService.getAccountSharesToInsert();
        Map<String, List<SObject>> childSharesToInsertMap = sharingService.getChildSharesToInsert();
        //22/01/20 done as directed by Alona Glebova
//        sObjectsToInsert.addAll((List<SObject>)sharingService.getCompetitorPromoTrackingSharesToInsert());
//        sObjectsToInsert.addAll((List<SObject>)sharingService.getBrandSecurityInfringementSharesToInsert());
//        sObjectsToInsert.addAll((List<SObject>)sharingService.getVisitSharesToInsert());
//        sObjectsToInsert.addAll((List<SObject>)sharingService.getObjPromoSharesToInsert());
//        sObjectsToInsert.addAll((List<SObject>)sharingService.getObjectiveSharesToInsert());
//        sObjectsToInsert.addAll((List<SObject>)sharingService.getContractTrackerSharesToInsert());
        System.debug('\n euAccSharesToInsert.size() => ' + euAccSharesToInsert.size() + '\n');
        System.debug('\n euAccSharesToInsert => ' + JSON.serializePretty(euAccSharesToInsert) + '\n');
        System.debug('\n accSharesToInsert.size() => ' + accSharesToInsert.size() + '\n');
        System.debug('\n accSharesToInsert => ' + JSON.serializePretty(accSharesToInsert) + '\n');
        System.debug('\n\n childSharesToInsertMap.size() => ' + JSON.serializePretty(childSharesToInsertMap.size()) + '\n');
        System.debug('\n\n childSharesToInsertMap => ' + JSON.serializePretty(childSharesToInsertMap) + '\n');

//        if( ! sObjectsToInsert.isEmpty()) {
//            this.insertRecords(sObjectsToInsert);
        if ( ! euAccSharesToInsert.isEmpty() || ! accSharesToInsert.isEmpty()) {
            this.insertRecords(euAccSharesToInsert);
            this.insertRecords(accSharesToInsert);

            List<EUR_CRM_AccountGroupUser__c> accountGroupUsersToUpdate = this.getAccountGroupUsersWhereStatus(accountGroupUsers, NEW_STATUS);
            System.debug('\n\n accountGroupUsersToUpdate => ' + JSON.serializePretty(accountGroupUsersToUpdate) + '\n');
            accountGroupUsersToUpdate = this.updateStatus(accountGroupUsersToUpdate);
            System.debug('\n\n accountGroupUsersToUpdate => ' + JSON.serializePretty(accountGroupUsersToUpdate) + '\n');
            if( ! accountGroupUsersToUpdate.isEmpty()) {
                this.upsertRecords(accountGroupUsersToUpdate);
            }

            if( ! childSharesToInsertMap.values().isEmpty()) {
                for (List<SObject> childList: childSharesToInsertMap.values()) {
                    //Insert in loop to fix "Cannot have more than 10 chunks in a single operation" error in
                    // production org
                    this.insertRecords(childList);
                }
                //this.insertRecords(childSharesToInsertMap);
            }
        }

        List<SObject> sObjectsToDelete = new List<SObject>();
        sObjectsToDelete.addAll((List<SObject>)sharingService.getEUAccountSharesToDelete());
        sObjectsToDelete.addAll((List<SObject>)sharingService.getAccountSharesToDelete());

        //need to delete because of historical data
        sObjectsToDelete.addAll((List<SObject>)sharingService.getCompetitorPromoTrackingSharesToDelete());
        sObjectsToDelete.addAll((List<SObject>)sharingService.getBrandSecurityInfringementSharesToDelete());
        sObjectsToDelete.addAll((List<SObject>)sharingService.getVisitSharesToDelete());
        sObjectsToDelete.addAll((List<SObject>)sharingService.getObjPromoSharesToDelete());
        sObjectsToDelete.addAll((List<SObject>)sharingService.getObjectiveSharesToDelete());
        sObjectsToDelete.addAll((List<SObject>)sharingService.getContractTrackerSharesToDelete());
        System.debug('\n\n sObjectsToDelete.size() => ' + JSON.serializePretty(sObjectsToDelete.size()) + '\n');
        System.debug('\n\n sObjectsToDelete => ' + JSON.serializePretty(sObjectsToDelete) + '\n');

        if( ! sObjectsToDelete.isEmpty()) {
            this.deleteRecords(sObjectsToDelete);

            /* @edited 18.03.19 to fix account owner account group user deletion
             * 
            List<EUR_CRM_AccountGroupUser__c> accountGroupUsersToDelete = this.getAccountGroupUsersWhereStatus(accountGroupUsers, TO_DELETE_STATUS);
            System.debug('\n\n accountGroupUsersToDelete => ' + JSON.serializePretty(accountGroupUsersToDelete) + '\n');
            accountGroupUsersToDelete = this.updateAllowDeletion(accountGroupUsersToDelete);
            System.debug('\n\n accountGroupUsersToDelete => ' + JSON.serializePretty(accountGroupUsersToDelete) + '\n');
            if( ! accountGroupUsersToDelete.isEmpty()) {
                this.upsertRecords(accountGroupUsersToDelete);
                this.deleteRecords(accountGroupUsersToDelete);

                for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsersToDelete) {
                    if (accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Status__c == TO_DELETE_STATUS) {
                        this.accountGroupIds.add(accountGroupUser.EUR_CRM_AccountGroup__c);
                    }
                }
            }
			*/
        }

        // @edited 18.03.19 to fix account owner account group user deletion
        List<EUR_CRM_AccountGroupUser__c> accountGroupUsersToDelete = this.getAccountGroupUsersWhereStatus(accountGroupUsers, TO_DELETE_STATUS);
        if( ! accountGroupUsersToDelete.isEmpty()){
            accountGroupUsersToDelete = this.updateAllowDeletion(accountGroupUsersToDelete);
            if( ! accountGroupUsersToDelete.isEmpty()) {
                this.upsertRecords(accountGroupUsersToDelete);
                this.deleteRecords(accountGroupUsersToDelete);
                for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsersToDelete) {
                    if (accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Status__c == TO_DELETE_STATUS) {
                        this.accountGroupIds.add(accountGroupUser.EUR_CRM_AccountGroup__c);
                    }
                }
            }
        }

        
        
        //We could add a bypass to the triggers here
        //Partial success allow, we don't want to rollback all changes if one record is not correct
        Database.update(accToUpdate.values(), false);

    }

    global override void finish(Database.BatchableContext BC) {
        this.sendEmailReport(BC);

        System.debug('\n\n this.accountGroupIds.size() => ' + JSON.serializePretty(this.accountGroupIds.size()) + '\n');
        System.debug('\n\n this.accountGroupIds => ' + JSON.serializePretty(this.accountGroupIds) + '\n');
        if( ! this.accountGroupIds.isEmpty()) {
            Database.executeBatch(new EUR_CRM_AccountGroupDeletionBatch(this.accountGroupIds), 200);
        }
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private List<EUR_CRM_AccountGroupUser__c> getAccountGroupUsersWhereStatus(List<EUR_CRM_AccountGroupUser__c> accountGroupUsers, String status) {
        List<EUR_CRM_AccountGroupUser__c> resultAccountGroupUsersList = new List<EUR_CRM_AccountGroupUser__c>();
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            if (accountGroupUser.EUR_CRM_Status__c.equalsIgnoreCase(status)) {
                resultAccountGroupUsersList.add(accountGroupUser);
            }
        }
        return resultAccountGroupUsersList;
    }

    private List<EUR_CRM_AccountGroupUser__c> updateStatus(List<EUR_CRM_AccountGroupUser__c> accountGroupUsers) {
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            accountGroupUser.EUR_CRM_Status__c = RECORD_SHARED;
        }
        return accountGroupUsers;
    }

    private List<EUR_CRM_AccountGroupUser__c> updateAllowDeletion(List<EUR_CRM_AccountGroupUser__c> accountGroupUsers) {
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            accountGroupUser.EUR_CRM_AllowDeletion__c = true;
        }
        return accountGroupUsers;
    }

    private List<EUR_CRM_AccountGroup__c> selectAGsWhereAccIds(Set<Id> accIds) {
        return [
            SELECT Id
            FROM EUR_CRM_AccountGroup__c
            WHERE EUR_CRM_Account__c IN :accIds
        ];
    }

    private List<EUR_CRM_AccountGroupUser__c> selectAGUsWhereAGs(Set<Id> agIds) {
        return [
            SELECT Id
            FROM EUR_CRM_AccountGroupUser__c
            WHERE EUR_CRM_AccountGroup__c IN :agIds
        ];
    }


}