public with sharing class EUR_CRM_AccountGroupComplexBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>{

    private static final String RECORD_SHARED_STATUS = 'Record shared';
    private static final String NEW_STATUS = 'New';
    private static final String TO_DELETE_STATUS = 'To Delete';

    private static Set<String> ROLLOUT_COUNTRY_CODES = new Set<String>();
    static {
        for(EUR_CRM_Rollout_Country__mdt setting :[SELECT DeveloperName FROM EUR_CRM_Rollout_Country__mdt]) {
            ROLLOUT_COUNTRY_CODES.add(setting.DeveloperName);
        }
    }

    private static Boolean deleteAllNewStatuses = false;

    //Run first
    public static void deleteAGsNotInRolloutCountries() {
        Database.executeBatch(new EUR_CRM_AccountGroupComplexBatch(Process.DELETE_ACCOUNT_GROUPS));
    }

    public static void deleteAGsNotInRolloutCountries(Integer chunkSize) {
        Database.executeBatch(new EUR_CRM_AccountGroupComplexBatch(Process.DELETE_ACCOUNT_GROUPS), chunkSize);
    }

    //Run second
    public static void deleteUnnecessaryAGUs() {
        Database.executeBatch(new EUR_CRM_AccountGroupComplexBatch(Process.DELETE_ACCOUNT_GROUP_USERS));
    }

    public static void deleteUnnecessaryAGUs(Integer chunkSize) {
        Database.executeBatch(new EUR_CRM_AccountGroupComplexBatch(Process.DELETE_ACCOUNT_GROUP_USERS), chunkSize);
    }

    public static void deleteUnnecessaryAGUs(Integer chunkSize, Boolean deleteAllWithNewStatuses) {
        deleteAllNewStatuses = deleteAllWithNewStatuses;
        Database.executeBatch(new EUR_CRM_AccountGroupComplexBatch(Process.DELETE_ACCOUNT_GROUP_USERS), chunkSize);
    }

    //Run third
    public static void mergeAGsInRolloutCountries() {
        Database.executeBatch(new EUR_CRM_AccountGroupComplexBatch(Process.MERGE_ACCOUNT_GROUPS));
    }

    public static void mergeAGsInRolloutCountries(Integer chunkSize) {
        Database.executeBatch(new EUR_CRM_AccountGroupComplexBatch(Process.MERGE_ACCOUNT_GROUPS), chunkSize);
    }

    public enum Process{ MERGE_ACCOUNT_GROUPS, DELETE_ACCOUNT_GROUPS, DELETE_ACCOUNT_GROUP_USERS }
    private Process proc;

    private EUR_CRM_AccountGroupComplexBatch(Process proc) {
        this.proc = proc;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        if (this.proc == Process.DELETE_ACCOUNT_GROUPS) {
            return Database.getQueryLocator([
                SELECT Id
                ,   EUR_CRM_Status__c
                ,   EUR_CRM_AllowDeletion__c
                FROM EUR_CRM_AccountGroup__c
                WHERE EUR_CRM_Account__r.EUR_CRM_Country_Code__c
                    NOT IN  :ROLLOUT_COUNTRY_CODES
            ]);
        }
        if (this.proc == Process.MERGE_ACCOUNT_GROUPS) {
            return Database.getQueryLocator([
                SELECT Id
                ,   EUR_CRM_Country_Code__c
                ,   EUR_CRM_External_ID__c
                    , (
                    SELECT Id
                    ,   EUR_CRM_Status__c
                    ,   EUR_CRM_AllowDeletion__c
                    ,   EUR_CRM_Country_Code__c
                    ,   EUR_CRM_External_ID__c
                    ,   EUR_CRM_Account__r.EUR_CRM_Country_Code__c
                    ,   EUR_CRM_Account__r.EUR_CRM_External_ID__c
                    FROM EUR_CRM_AccountGroups__r
                )
                FROM EUR_CRM_Account__c
                WHERE Id IN (
                    SELECT EUR_CRM_Account__c
                    FROM EUR_CRM_AccountGroup__c
                )
                AND EUR_CRM_Country_Code__c IN :ROLLOUT_COUNTRY_CODES
            ]);
        }
        if (this.proc == Process.DELETE_ACCOUNT_GROUP_USERS) {
            return Database.getQueryLocator([
                SELECT Id
                ,   EUR_CRM_User__c
                ,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Country_Code__c
                ,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.OwnerId
                ,   EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.CreatedById
                ,   EUR_CRM_Status__c
                FROM EUR_CRM_AccountGroupUser__c
                WHERE EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Country_Code__c IN :ROLLOUT_COUNTRY_CODES
                AND EUR_CRM_Status__c = :NEW_STATUS
            ]);
        }
        return null;
    }

    public void execute(Database.BatchableContext bc, List<SObject> sObjects) {
        EUR_CRM_AccountGroupComplexSelector selector = new EUR_CRM_AccountGroupComplexSelector();
        Service service = new Service(selector);
        if (this.proc == Process.DELETE_ACCOUNT_GROUPS) {
            service.deleteAGs((List<EUR_CRM_AccountGroup__c>) sObjects);
        }
        if (this.proc == Process.MERGE_ACCOUNT_GROUPS) {
//          Service service = new Service(selector);
            service.updateAGs((List<EUR_CRM_Account__c>) sObjects);
        }
        if (this.proc == Process.DELETE_ACCOUNT_GROUP_USERS) {
            service.deleteUnnecessaryAGUs((List<EUR_CRM_AccountGroupUser__c>) sObjects);
        }
    }


    public class Service {

        @TestVisible private Map<Id, EUR_CRM_Account__c> accWithManyOldAGsByAccId = new Map<Id, EUR_CRM_Account__c>();
        @TestVisible private Map<Id, EUR_CRM_AccountGroup__c> agToUpdateByAccId = new Map<Id, EUR_CRM_AccountGroup__c>();
        @TestVisible private Map<Id, List<EUR_CRM_AccountGroup__c>> agsToDeleteByAccId = new Map<Id, List<EUR_CRM_AccountGroup__c>>();
        @TestVisible private Map<Id, EUR_CRM_AccountGroup__c> agToInsertByAccId = new Map<Id, EUR_CRM_AccountGroup__c>();
        @TestVisible private Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> aguToInsertByUserIdByAccId = new Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>>();

        private EUR_CRM_AccountGroupComplexSelector selector;

        public Service() {}
        public Service(EUR_CRM_AccountGroupComplexSelector selector) {
            this.selector = selector;
        }

        // Delete AGs that not included in the EUR_CRM_Rollout_Country__mdt
        public void deleteAGs(List<EUR_CRM_AccountGroup__c> ags) {
            List<EUR_CRM_AccountGroup__c> agsToDelete = this.updateAGsFieldsToDelete(ags);
            System.debug('\n agsToDelete.size() => ' + agsToDelete.size() + '\n');
            System.debug('\n agsToDelete => ' + JSON.serializePretty(agsToDelete) + '\n');
            Database.update(agsToDelete, false);

            Database.delete(agsToDelete, false);

        }

        // Update AGs that included in the EUR_CRM_Rollout_Country__mdt
        // 1. IF Account contains only 1 AG than will be updated AG.EUR_CRM_Country_Code__c, AG.EUR_CRM_External_ID__c
        // 2. IF Account contains many AGs than will be created the new one AG and the new AGUs from old AGUs. Old AGs will be deleted with related AGUs.
        public void updateAGs(List<EUR_CRM_Account__c> accounts) {

            this.determineAccsByAGsCount(accounts);

            List<EUR_CRM_AccountGroup__c> agsWithUpdatedFields = this.populateAGsFields(this.agToUpdateByAccId);
            System.debug('\n agsWithUpdatedFields.size() => ' + agsWithUpdatedFields.size() + '\n');
            System.debug('\n agsWithUpdatedFields => ' + JSON.serializePretty(agsWithUpdatedFields) + '\n');
            Database.update(agsWithUpdatedFields, false);

            if (this.accWithManyOldAGsByAccId.isEmpty()) { return; }

            List<EUR_CRM_AccountGroupUser__c> oldAGUs = this.selector.selectAGUsWhereAccIds(this.accWithManyOldAGsByAccId.keySet());
            System.debug('\n oldAGUs.size() => ' + oldAGUs.size() + '\n');
            System.debug('\n oldAGUs => ' + JSON.serializePretty(oldAGUs) + '\n');

            Map<Id, List<EUR_CRM_AccountGroupUser__c>> oldAGUsByAccId = this.getAGUsByAccId(oldAGUs);
            System.debug('\n oldAGUsByAccId.size() => ' + oldAGUsByAccId.size() + '\n');
            System.debug('\n oldAGUsByAccId => ' + JSON.serializePretty(oldAGUsByAccId) + '\n');

            // create new ags
            this.agToInsertByAccId = this.makeAGByAccId(this.accWithManyOldAGsByAccId);
            System.debug('\n this.agByAccIdToInsert.size() => ' + this.agToInsertByAccId.size() + '\n');
            System.debug('\n this.agByAccIdToInsert => ' + JSON.serializePretty(this.agToInsertByAccId) + '\n');
            Database.insert(this.agToInsertByAccId.values(), false);

            //create new agus
            this.aguToInsertByUserIdByAccId = this.makeAGUByUserIdByAccId(this.agToInsertByAccId, oldAGUsByAccId);
            List<EUR_CRM_AccountGroupUser__c> agusToInsert = this.getAGUsFromMap(aguToInsertByUserIdByAccId);

            //delete old ags before insert the new agus
            this.deleteAGs(this.getAGsFromMap(this.agsToDeleteByAccId));

            //insert new agus
            System.debug('\n agusToInsert.size() => ' + agusToInsert.size() + '\n');
            System.debug('\n agusToInsert => ' + JSON.serializePretty(agusToInsert) + '\n');
            Database.insert(agusToInsert, false);
        }

        //Delete AGUs if
        // 1. AGU.EUR_CRM_Status__c = 'New'
        // 2. AGU.EUR_CRM_User__c == AGU.AG.A.OwnerId || AGU.EUR_CRM_User__c == AGU.AG.A.CreatedById
        private void deleteUnnecessaryAGUs(List<EUR_CRM_AccountGroupUser__c> agus) {
            List<EUR_CRM_AccountGroupUser__c> agusToUpdateFieldsToDelete = this.getAGUsToDelete(agus);
            List<EUR_CRM_AccountGroupUser__c> agusToDelete = this.updateAGUsFieldsToDelete(agusToUpdateFieldsToDelete);
            System.debug('\n agusToDelete.size() => ' + agusToDelete.size() + '\n');
            System.debug('\n agusToDelete => ' + JSON.serializePretty(agusToDelete) + '\n');
            Database.update(agusToDelete, false);

            agusToDelete = selector.selectAGUsWhereIds(agusToDelete);
            EUR_CRM_AccGroupUserSharingService sharingService = new EUR_CRM_AccGroupUserSharingService(agusToDelete);

            List<EUR_CRM_Account__Share> euAccSharesToDelete = new List<EUR_CRM_Account__Share>(sharingService.getEUAccountSharesToDelete());
            List<AccountShare> accSharesToDelete = new List<AccountShare>(sharingService.getAccountSharesToDelete());

            List<EUR_CRM_Competitor_Promo_Tracking__Share> compPromoTrackSharesToDelete = new List<EUR_CRM_Competitor_Promo_Tracking__Share>(sharingService.getCompetitorPromoTrackingSharesToDelete());
            List<EUR_CRM_Brand_Security_Infringement__Share> brandSecInfringSharesToDelete = new List<EUR_CRM_Brand_Security_Infringement__Share>(sharingService.getBrandSecurityInfringementSharesToDelete());
            List<EUR_CRM_Visit__Share> visitSharesToDelete = new List<EUR_CRM_Visit__Share>(sharingService.getVisitSharesToDelete());
            List<EUR_CRM_ObjPromo__Share> objPromoSharesToDelete = new List<EUR_CRM_ObjPromo__Share>(sharingService.getObjPromoSharesToDelete());
            List<EUR_CRM_GB_Objective__Share> objectiveSharesToDelete = new List<EUR_CRM_GB_Objective__Share>(sharingService.getObjectiveSharesToDelete());
            List<EUR_CRM_Contract_Tracker__Share> contractTrackerSharesToDelete = new List<EUR_CRM_Contract_Tracker__Share>(sharingService.getContractTrackerSharesToDelete());

            System.debug('\n euAccSharesToDelete.size() => ' + euAccSharesToDelete.size() + '\n');
            //System.debug('\n euAccSharesToDelete => ' + JSON.serializePretty(euAccSharesToDelete) + '\n');
            System.debug('\n accSharesToDelete.size() => ' + accSharesToDelete.size() + '\n');
            //System.debug('\n accSharesToDelete => ' + JSON.serializePretty(accSharesToDelete) + '\n');
            System.debug('\n compPromoTrackSharesToDelete.size() => ' + compPromoTrackSharesToDelete.size() + '\n');
            //System.debug('\n compPromoTrackSharesToDelete => ' + JSON.serializePretty(compPromoTrackSharesToDelete) + '\n');
            System.debug('\n brandSecInfringSharesToDelete.size() => ' + brandSecInfringSharesToDelete.size() + '\n');
            //System.debug('\n brandSecInfringSharesToDelete => ' + JSON.serializePretty(brandSecInfringSharesToDelete) + '\n');
            System.debug('\n visitSharesToDelete.size() => ' + visitSharesToDelete.size() + '\n');
            //System.debug('\n visitSharesToDelete => ' + JSON.serializePretty(visitSharesToDelete) + '\n');
            System.debug('\n objPromoSharesToDelete.size() => ' + objPromoSharesToDelete.size() + '\n');
            //System.debug('\n objPromoSharesToDelete => ' + JSON.serializePretty(objPromoSharesToDelete) + '\n');
            System.debug('\n objectiveSharesToDelete.size() => ' + objectiveSharesToDelete.size() + '\n');
            //System.debug('\n objectiveSharesToDelete => ' + JSON.serializePretty(objectiveSharesToDelete) + '\n');
            System.debug('\n contractTrackerSharesToDelete.size() => ' + contractTrackerSharesToDelete.size() + '\n');
            //System.debug('\n contractTrackerSharesToDelete => ' + JSON.serializePretty(contractTrackerSharesToDelete) + '\n');

            List<SObject> euAccShareIdsToDelete = getUniqueSObjListFromList(euAccSharesToDelete);
            List<SObject> accShareIdsToDelete = getUniqueSObjListFromList(accSharesToDelete);
            List<SObject> compPromoTrackShareIdsToDelete = getUniqueSObjListFromList(compPromoTrackSharesToDelete);
            List<SObject> brandSecInfringShareIdsToDelete = getUniqueSObjListFromList(brandSecInfringSharesToDelete);
            List<SObject> visitShareIdsToDelete = getUniqueSObjListFromList(visitSharesToDelete);
            List<SObject> objPromoShareIdsToDelete = getUniqueSObjListFromList(objPromoSharesToDelete);
            List<SObject> objectiveShareIdsToDelete = getUniqueSObjListFromList(objectiveSharesToDelete);
            List<SObject> contractTrackerShareIdsToDelete = getUniqueSObjListFromList(contractTrackerSharesToDelete);

            Database.delete(euAccShareIdsToDelete, false);
            Database.delete(accShareIdsToDelete, false);
            Database.delete(compPromoTrackShareIdsToDelete, false);
            Database.delete(brandSecInfringShareIdsToDelete, false);
            Database.delete(visitShareIdsToDelete, false);
            Database.delete(objPromoShareIdsToDelete, false);
            Database.delete(objectiveShareIdsToDelete, false);
            Database.delete(contractTrackerShareIdsToDelete, false);

            Database.delete(agusToDelete, false);

        }


        // private methods
        private List<SObject> getUniqueSObjListFromList(List<SObject> sobjs) {
            Set<SObject> sobjSet = new Set<SObject>();
            List<SObject> sobjList = new List<SObject>();
            sobjSet.addAll(sobjs);
            sobjList.addAll(sobjSet);

            return sobjList;

        }

        private List<EUR_CRM_AccountGroupUser__c> getAGUsToDelete(List<EUR_CRM_AccountGroupUser__c> agus) {
            List<EUR_CRM_AccountGroupUser__c> agusToDelete = new List<EUR_CRM_AccountGroupUser__c>();

            for (EUR_CRM_AccountGroupUser__c agu : agus) {
                if ( ! this.isNeedToDelete(agu)) { continue; }
                agusToDelete.add(agu);
            }
            return agusToDelete;
        }

        private void determineAccsByAGsCount(List<EUR_CRM_Account__c> accounts) {
            for (EUR_CRM_Account__c acc : accounts) {
                if (acc.EUR_CRM_AccountGroups__r.size() == 1) {
                    this.agToUpdateByAccId.put(acc.Id, acc.EUR_CRM_AccountGroups__r);
                } else {
                    this.accWithManyOldAGsByAccId.put(acc.Id, acc);
                    this.agsToDeleteByAccId.put(acc.Id, acc.EUR_CRM_AccountGroups__r);
                }
            }
        }

        private List<EUR_CRM_AccountGroup__c> populateAGsFields(Map<Id, EUR_CRM_AccountGroup__c> agByAccId) {
            List<EUR_CRM_AccountGroup__c> agsWithUpdatedFields = new List<EUR_CRM_AccountGroup__c>();
            for (EUR_CRM_AccountGroup__c ag : agByAccId.values()) {
                if ( ! this.isNeedToUpdate(ag)) { continue; }
                agsWithUpdatedFields.add(this.populateAG(ag));
            }
            return agsWithUpdatedFields;
        }

        private List<EUR_CRM_AccountGroup__c> updateAGsFieldsToDelete(List<EUR_CRM_AccountGroup__c> ags) {
            List<EUR_CRM_AccountGroup__c> agsToUpdate = new List<EUR_CRM_AccountGroup__c>();
            for (EUR_CRM_AccountGroup__c ag : ags) {
                agsToUpdate.add(this.updateAGFieldsToDelete(ag));
            }
            return agsToUpdate;
        }

        private List<EUR_CRM_AccountGroupUser__c> updateAGUsFieldsToDelete(List<EUR_CRM_AccountGroupUser__c> agus) {
            List<EUR_CRM_AccountGroupUser__c> agusToUpdate = new List<EUR_CRM_AccountGroupUser__c>();
            for (EUR_CRM_AccountGroupUser__c agu : agus) {
                agusToUpdate.add(this.updateAGUFieldsToDelete(agu));
            }
            return agusToUpdate;
        }

        private Map<Id, List<EUR_CRM_AccountGroupUser__c>> getAGUsByAccId(List<EUR_CRM_AccountGroupUser__c> agus) {
            Map<Id, List<EUR_CRM_AccountGroupUser__c>> agusByAccId = new Map<Id, List<EUR_CRM_AccountGroupUser__c>>();
            Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> aguByUserIdByAccId = new Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>>();
            Map<Id, Map<Id, Map<String, EUR_CRM_AccountGroupUser__c>>> aguByStatusByUserIdByAccId = new Map<Id, Map<Id, Map<String, EUR_CRM_AccountGroupUser__c>>>();
            for (EUR_CRM_AccountGroupUser__c agu : agus) {
                Id accId = agu.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c;
                if (aguByStatusByUserIdByAccId.containsKey(accId)) {
                    if (aguByStatusByUserIdByAccId.get(accId).containsKey(agu.EUR_CRM_User__c)) {
                        aguByStatusByUserIdByAccId.get(accId).get(agu.EUR_CRM_User__c).put(agu.EUR_CRM_Status__c, agu);
                    } else {
                        aguByStatusByUserIdByAccId.get(accId).put(agu.EUR_CRM_User__c, new Map<String, EUR_CRM_AccountGroupUser__c>{ agu.EUR_CRM_Status__c => agu });
                    }
                } else {
                    aguByStatusByUserIdByAccId.put(accId,
                        new Map<Id, Map<String, EUR_CRM_AccountGroupUser__c>>{ agu.EUR_CRM_User__c => new Map<String, EUR_CRM_AccountGroupUser__c>{ agu.EUR_CRM_Status__c => agu }});
                }
            }
            return this.getAGUsByAccId(aguByStatusByUserIdByAccId);
        }

        private Map<Id, List<EUR_CRM_AccountGroupUser__c>> getAGUsByAccId(Map<Id, Map<Id, Map<String, EUR_CRM_AccountGroupUser__c>>> aguByStatusByUserIdByAccId) {
            Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> aguByUserIdByAccId = this.getAGUByUserIdByAccId(aguByStatusByUserIdByAccId);
            Map<Id, List<EUR_CRM_AccountGroupUser__c>> agusByAccId = new Map<Id, List<EUR_CRM_AccountGroupUser__c>>();
            for (Id accId : aguByUserIdByAccId.keySet()) {
                for(EUR_CRM_AccountGroupUser__c agu : aguByUserIdByAccId.get(accId).values()) {
                    if (agusByAccId.containsKey(accId)) {
                        agusByAccId.get(accId).add(agu);
                    } else {
                        agusByAccId.put(accId, new List<EUR_CRM_AccountGroupUser__c>{ agu });
                    }
                }
            }
            return agusByAccId;
        }

        private Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> getAGUByUserIdByAccId(Map<Id, Map<Id, Map<String, EUR_CRM_AccountGroupUser__c>>> aguByStatusByUserIdByAccId) {
            Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> aguByUserIdByAccId = new Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>>();

            for (Id accId : aguByStatusByUserIdByAccId.keySet()) {
                Map<Id, Map<String, EUR_CRM_AccountGroupUser__c>> aguByStatusByUserId = aguByStatusByUserIdByAccId.get(accId);
                for (Id userId : aguByStatusByUserId.keySet()) {
                    Map<String, EUR_CRM_AccountGroupUser__c> aguByStatus = aguByStatusByUserId.get(userId);
                    //if only one agu per user per account exist
                    if (aguByStatus.size() == 1) {
                        this.populateAGUByUserIdByAccIdMap(aguByUserIdByAccId, accId, userId, aguByStatus.values()[0]);
                    } else {
                        //if many agu with different statuses per one user per account exists
                        if (aguByStatus.containsKey(RECORD_SHARED_STATUS)) {
                            this.populateAGUByUserIdByAccIdMap(aguByUserIdByAccId, accId, userId, aguByStatus.get(RECORD_SHARED_STATUS));
                            continue;
                        }
                        if (aguByStatus.containsKey(NEW_STATUS)) {
                            this.populateAGUByUserIdByAccIdMap(aguByUserIdByAccId, accId, userId, aguByStatus.get(NEW_STATUS));
                            continue;
                        }
                        if (aguByStatus.containsKey(TO_DELETE_STATUS)) {
                            this.populateAGUByUserIdByAccIdMap(aguByUserIdByAccId, accId, userId, aguByStatus.get(TO_DELETE_STATUS));
                            continue;
                        }
                    }
                }
            }
            return aguByUserIdByAccId;
        }

        private void populateAGUByUserIdByAccIdMap(Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> aguByUserIdByAccId, Id accId, Id userId, EUR_CRM_AccountGroupUser__c agu) {
            if (aguByUserIdByAccId.containsKey(accId)) {
                aguByUserIdByAccId.get(accId).put(userId, agu);
            } else {
                aguByUserIdByAccId.put(accId, new Map<Id, EUR_CRM_AccountGroupUser__c>{ userId => agu });
            }
        }

        private List<EUR_CRM_AccountGroup__c> getAGsFromMap(Map<Id, List<EUR_CRM_AccountGroup__c>> agsByaccId) {
            List<EUR_CRM_AccountGroup__c> agsToDelete = new List<EUR_CRM_AccountGroup__c>();
            for (List<EUR_CRM_AccountGroup__c> ags : agsByaccId.values()) {
                agsToDelete.addAll(ags);
            }
            return agsToDelete;
        }

        private List<EUR_CRM_AccountGroupUser__c> getAGUsFromMap(Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> aguToInsertByUserIdByAccId) {
            List<EUR_CRM_AccountGroupUser__c> agusToInsert = new List<EUR_CRM_AccountGroupUser__c>();
            for (Id accId : aguToInsertByUserIdByAccId.keySet()) {
                agusToInsert.addAll(aguToInsertByUserIdByAccId.get(accId).values());
            }
            return agusToInsert;
        }

        private Map<Id, EUR_CRM_AccountGroup__c> makeAGByAccId(Map<Id, EUR_CRM_Account__c> accById) {
            Map<Id, EUR_CRM_AccountGroup__c> agToInsertByAccId = new Map<Id, EUR_CRM_AccountGroup__c>();
            for (EUR_CRM_Account__c acc : accById.values()) {
                agToInsertByAccId.put(acc.Id, this.makeAG(acc));
            }
            return agToInsertByAccId;
        }

        private Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> makeAGUByUserIdByAccId(Map<Id, EUR_CRM_AccountGroup__c> agByAccId, Map<Id, List<EUR_CRM_AccountGroupUser__c>> oldAGUsByAccId) {
            Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> aguByUserIdByAccId = new Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>>();
            for (Id accId : oldAGUsByAccId.keySet()) {
                for (EUR_CRM_AccountGroupUser__c oldAGU : oldAGUsByAccId.get(accId)) {
                    EUR_CRM_AccountGroup__c newAG = agByAccId.get(oldAGU.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c);
                    if (newAG == null) { continue; }

                    if (aguByUserIdByAccId.containsKey(accId)) {
                        aguByUserIdByAccId.get(accId).put(oldAGU.EUR_CRM_User__c, this.makeAGU(newAG.Id, oldAGU));
                    } else {
                        aguByUserIdByAccId.put(accId, new Map<Id, EUR_CRM_AccountGroupUser__c>{ oldAGU.EUR_CRM_User__c => this.makeAGU(newAG.Id, oldAGU) });
                    }
                }
            }
            return aguByUserIdByAccId;
        }

        private Boolean isNeedToUpdate(EUR_CRM_AccountGroup__c ag) {
            return ag.EUR_CRM_Country_Code__c != ag.EUR_CRM_Account__r.EUR_CRM_Country_Code__c
                || ag.EUR_CRM_External_ID__c != ag.EUR_CRM_Account__r.EUR_CRM_External_ID__c;
        }

        private Boolean isNeedToDelete(EUR_CRM_AccountGroupUser__c agu) {
            if (deleteAllNewStatuses) { return agu.EUR_CRM_Status__c == NEW_STATUS; }
            return agu.EUR_CRM_Status__c == NEW_STATUS
                && this.isOwnerOrCreator(agu);
        }

        private Boolean isOwnerOrCreator(EUR_CRM_AccountGroupUser__c agu) {
            return (agu.EUR_CRM_User__c == agu.EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.OwnerId
                || agu.EUR_CRM_User__c == agu.EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.CreatedById);
        }

        private EUR_CRM_AccountGroupUser__c updateAGUFieldsToDelete(EUR_CRM_AccountGroupUser__c agu) {
            agu.EUR_CRM_Status__c = TO_DELETE_STATUS;
            agu.EUR_CRM_AllowDeletion__c = true;
            return agu;
        }

        private EUR_CRM_AccountGroup__c updateAGFieldsToDelete(EUR_CRM_AccountGroup__c ag) {
            ag.EUR_CRM_Status__c = TO_DELETE_STATUS;
            ag.EUR_CRM_AllowDeletion__c = true;
            return ag;
        }

        private EUR_CRM_AccountGroup__c populateAG(EUR_CRM_AccountGroup__c ag) {
            ag.EUR_CRM_Country_Code__c = ag.EUR_CRM_Account__r.EUR_CRM_Country_Code__c;
            ag.EUR_CRM_External_ID__c = ag.EUR_CRM_Account__r.EUR_CRM_External_ID__c;
            return ag;
        }

        // Makers
        private EUR_CRM_AccountGroup__c makeAG(EUR_CRM_Account__c acc) {
            return new EUR_CRM_AccountGroup__c(
                EUR_CRM_Account__c = acc.Id
            ,   EUR_CRM_Country_Code__c = acc.EUR_CRM_Country_Code__c
            ,   EUR_CRM_External_ID__c = acc.EUR_CRM_External_ID__c
            );
        }

        private EUR_CRM_AccountGroupUser__c makeAGU(Id agId, EUR_CRM_AccountGroupUser__c oldAGU) {
            return new EUR_CRM_AccountGroupUser__c(
                EUR_CRM_AccountGroup__c = agId
            ,   EUR_CRM_User__c = oldAGU.EUR_CRM_User__c
            ,   EUR_CRM_Status__c = oldAGU.EUR_CRM_Status__c
            ,   EUR_CRM_AllowDeletion__c = oldAGU.EUR_CRM_AllowDeletion__c
            );
        }
    }
}