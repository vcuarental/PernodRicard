public with sharing class EUR_CRM_AccountGroupUserHandler {
    /*
    Creates the new and delete the old ones AGU for OwnerId of EUR_CRM_Account__c.EUR_CRM_Parent_Account__c if
    EUR_CRM_Account__c.EUR_CRM_Parent_Account__r.OwnerId != EUR_CRM_Account__r.OwnerId

    */

    private static final String TO_DELETE_STATUS = 'To Delete';
    public static final Set<String> ROLLOUT_COUNTRY_CODES = new Set<String>();
    private static Boolean runOnceAfterUpdateChildAccountOwner = false;
    static {
        for (EUR_CRM_Rollout_Country__mdt cmt : [SELECT DeveloperName FROM EUR_CRM_Rollout_Country__mdt]) {
            ROLLOUT_COUNTRY_CODES.add(cmt.DeveloperName);
        }
    }

    public List<EUR_CRM_Account__c> selectAccountsWhereIds(Set<Id> accIds) {
        return [
                SELECT Id
                        , EUR_CRM_Parent_Account__r.OwnerId
                        , EUR_CRM_External_ID__c
                        , EUR_CRM_Country_Code__c
                        , OwnerId
                        , (
                        SELECT Id
                                , EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.OwnerId
                        FROM EUR_CRM_AccountGroups__r
                        LIMIT 1
                )
                FROM EUR_CRM_Account__c
                WHERE Id IN :accIds
        ];
    }

    public List<EUR_CRM_Account__c> selectChildAccountsWhereIds(Set<Id> accIds) {
        return [
                SELECT Id
                        , EUR_CRM_Parent_Account__r.OwnerId
                        , EUR_CRM_External_ID__c
                        , EUR_CRM_Country_Code__c
                        , OwnerId
                        , (
                        SELECT Id
                                , EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.OwnerId
                        FROM EUR_CRM_AccountGroups__r
                        LIMIT 1
                )
                FROM EUR_CRM_Account__c
                WHERE EUR_CRM_Parent_Account__c IN :accIds
        ];
    }

    public List<EUR_CRM_AccountGroup__c> selectAGsWhereIds(List<EUR_CRM_AccountGroup__c> ags) {
        return [
                SELECT Id
                        , EUR_CRM_Account__c
                        , EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.OwnerId
                FROM EUR_CRM_AccountGroup__c
                WHERE Id IN :ags
        ];
    }

    public List<EUR_CRM_AccountGroup__c> selectAGsWhereAccIds(Set<Id> accIds) {
        return [
                SELECT Id
                        , EUR_CRM_Account__c
                FROM EUR_CRM_AccountGroup__c
                WHERE EUR_CRM_Account__c IN :accIds
        ];
    }

    public List<EUR_CRM_AccountGroupUser__c> selectAGUsWhereAccIds(Set<Id> accIds) {
        return [
                SELECT Id
                        , EUR_CRM_User__c
                        , EUR_CRM_Status__c
                        , EUR_CRM_AccountGroup__c
                        , EUR_CRM_AccountGroup__r.EUR_CRM_Account__c
                        , EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.OwnerId
                FROM EUR_CRM_AccountGroupUser__c
                WHERE EUR_CRM_AccountGroup__r.EUR_CRM_Account__c IN :accIds
        ];
    }

    public class Service {
        @TestVisible private EUR_CRM_AccountGroupUserHandler parent = new EUR_CRM_AccountGroupUserHandler();

        @TestVisible private List<EUR_CRM_AccountGroup__c> agsToInsert = new List<EUR_CRM_AccountGroup__c>();
        @TestVisible private List<EUR_CRM_AccountGroupUser__c> agusToInsert = new List<EUR_CRM_AccountGroupUser__c>();
        @TestVisible private List<EUR_CRM_AccountGroupUser__c> agusToUpdate = new List<EUR_CRM_AccountGroupUser__c>();
        private Boolean runOnceAfterInsert = false;
        private Boolean runOnceAfterUpdate = false;


        /* ========================================================= */
        /*     Interface
        /* ========================================================= */
        public void calculateSharingForParentAccountOwner(List<EUR_CRM_Account__c> accs) {
            if (runOnceAfterInsert) {
                return;
            }
            List<EUR_CRM_Account__c> validAccs = this.getValidAccsByCountryCode(accs);
            if (validAccs.isEmpty()) {
                return;
            }
            Set<Id> aguIds = this.createAGUs(validAccs);
            if (aguIds.isEmpty()) {
                return;
            }

            Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(aguIds), 200);

            runOnceAfterInsert = true;
        }

        public void recalculateSharingForChildAccountOwner(List<EUR_CRM_Account__c> newAccs, Map<Id, EUR_CRM_Account__c> oldAccById) {

            if (runOnceAfterUpdateChildAccountOwner) {
                return;
            }

            Set<Id> validParentAccsIds = this.getValidOwnerAccs(newAccs, oldAccById);
            if (validParentAccsIds.isEmpty()) {
                return;
            }

            List<EUR_CRM_Account__c> validAccs = parent.selectChildAccountsWhereIds(validParentAccsIds);
            if (validAccs.isEmpty()) {
                return;
            }

            Set<Id> validAccIds = (new Map<Id, EUR_CRM_Account__c>(validAccs)).keySet();

            List<EUR_CRM_AccountGroup__c> validAGs = this.getAGsByAccs(validAccs) ;
            if (validAGs.isEmpty()) {
                return;
            }

            this.agusToInsert = this.makeAGUs(validAGs);

            this.configureOldAGUsStatusToDelete(validAccIds, validAccs, oldAccById);

            Database.insert(this.agusToInsert, false);
            Database.update(this.agusToUpdate, false);
            List<EUR_CRM_AccountGroupUser__c> allAGUs = new List<EUR_CRM_AccountGroupUser__c>();
            allAGUs.addAll(this.agusToInsert);
            allAGUs.addAll(this.agusToUpdate);

            Set<Id> aguIds = this.getAGUIds(allAGUs);
            if (aguIds.isEmpty()) {
                return;
            }
            System.enqueueJob(new EUR_CRM_AccGroupUserSharingQueueable(aguIds));
//            Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(aguIds), 200);

            runOnceAfterUpdateChildAccountOwner = true;
        }

        public void recalculateSharingForParentAccountOwner(List<EUR_CRM_Account__c> accs, Map<Id, EUR_CRM_Account__c> oldAccById) {
            if (runOnceAfterUpdate) {
                return;
            }
            List<EUR_CRM_Account__c> validAccs = this.getValidAccs(accs, oldAccById);
            if (validAccs.isEmpty()) {
                return;
            }

            Set<Id> aguIds = this.updateAGUs(validAccs, oldAccById);
            if (aguIds.isEmpty()) {
                return;
            }
//            System.enqueueJob(new EUR_CRM_AccGroupUserSharingQueueable(aguIds));
            Database.executeBatch(new EUR_CRM_AccGroupUserSharingBatch(aguIds), 200);

			runOnceAfterUpdate = true;
        }


        /* ========================================================= */
        /*      Delegate methods
        /* ========================================================= */
        private Set<Id> createAGUs(List<EUR_CRM_Account__c> validAccs) {
            List<EUR_CRM_Account__c> selectedAccs = parent.selectAccountsWhereIds(new Map<Id, EUR_CRM_Account__c>(validAccs).keySet());
            List<EUR_CRM_Account__c> accsToCreateAGs = this.getValidAccsToCreateAGs(selectedAccs);
            System.debug('accsToCreateAGs ' + accsToCreateAGs);
            if (accsToCreateAGs.isEmpty()) {
                return new Set<Id>();
            }

            this.agsToInsert = this.makeAGs(accsToCreateAGs);
            System.debug('this.agsToInsert' + this.agsToInsert);
            Database.insert(this.agsToInsert, false);
            System.debug('this.agsToInsert after --- ' + this.agsToInsert);

            List<EUR_CRM_Account__c> validAccsByParent = this.getValidAccsByParentAccount(validAccs);
            if (!validAccsByParent.isEmpty()) {

                List<EUR_CRM_AccountGroup__c> selectedAGs = parent.selectAGsWhereIds(agsToInsert);
                this.agusToInsert = this.makeAGUs(selectedAGs);
                System.debug('this.agusToInsert' + this.agusToInsert);

                Database.insert(this.agusToInsert, false);

                return this.getAGUIds(this.agusToInsert);

            }
            return this.getAGUIds(this.agusToInsert);
        }

        private Set<Id> updateAGUs(List<EUR_CRM_Account__c> newAccs, Map<Id, EUR_CRM_Account__c> oldAccById) {

            Map<Id, List<Id>> accIdsByOldParentAccId = this.getAccIdsByParentAccId(newAccs, oldAccById);
            Map<Id, List<Id>> accIdsByNewParentAccId = this.getAccIdsByParentAccId(newAccs, new Map<Id, EUR_CRM_Account__c>(newAccs));
            if (accIdsByOldParentAccId.isEmpty() && accIdsByNewParentAccId.isEmpty()) {
                return new Set<Id>();
            }
            Set<Id> allParentAccIds = new Set<Id>();
            allParentAccIds.addAll(accIdsByOldParentAccId.keySet());
            allParentAccIds.addAll(accIdsByNewParentAccId.keySet());
            allParentAccIds.addAll(oldAccById.keySet());

            Map<Id, EUR_CRM_Account__c> allAccSelectedById = new Map<Id, EUR_CRM_Account__c>(parent.selectAccountsWhereIds(allParentAccIds));

            Map<Id, Id> oldParentAccOwnerIdByAccId = this.getParentAccOwnerIdByAccId(allAccSelectedById, accIdsByOldParentAccId);
            Map<Id, Id> newParentAccOwnerIdByAccId = this.getParentAccOwnerIdByAccId(allAccSelectedById, accIdsByNewParentAccId);

            Set<Id> allAccountIds = new Set<Id>();
            allAccountIds.addAll(newParentAccOwnerIdByAccId.keySet());
            allAccountIds.addAll(oldParentAccOwnerIdByAccId.keySet());

            Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> existAguByUserIdByAccId = this.getExistedAguByUserIdByAccId(allAccountIds);

            this.configureAGUsStatusToDelete(existAguByUserIdByAccId, oldParentAccOwnerIdByAccId);

            this.configureAGsAndAGUsToInsert(allAccSelectedById, newParentAccOwnerIdByAccId, oldParentAccOwnerIdByAccId, existAguByUserIdByAccId);
            Database.insert(this.agsToInsert, false);
            Database.update(this.agusToUpdate, false);


            this.configureAGUsToInsertForInsertedAGs(newParentAccOwnerIdByAccId);

            Database.insert(this.agusToInsert, false);
            List<EUR_CRM_AccountGroupUser__c> allAGUs = new List<EUR_CRM_AccountGroupUser__c>();
            allAGUs.addAll(this.agusToInsert);
            allAGUs.addAll(this.agusToUpdate);

            return this.getAGUIds(allAGUs);
        }


        /* ========================================================= */
        /*      High Level Helpers
        /* ========================================================= */

        private void configureAGUsToInsertForInsertedAGs(Map<Id, Id> newParentAccOwnerIdByAccId) {
            for (EUR_CRM_AccountGroup__c ag : this.agsToInsert) {
                Id uId = newParentAccOwnerIdByAccId.get(ag.EUR_CRM_Account__c);
                if (uId == null) {
                    continue;
                }
                this.agusToInsert.add(this.makeAGU(ag.Id, uId, 'Edit'));
            }
        }

        private Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> getExistedAguByUserIdByAccId(Set<Id> allAccountIds) {
            List<EUR_CRM_AccountGroupUser__c> agus = parent.selectAGUsWhereAccIds(allAccountIds);
            Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> aguByUserIdByAccId = new Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>>();
            for (EUR_CRM_AccountGroupUser__c agu : agus) {
                if (aguByUserIdByAccId.containsKey(agu.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c)) {
                    aguByUserIdByAccId.get(agu.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c).put(agu.EUR_CRM_User__c, agu);
                } else {
                    aguByUserIdByAccId.put(agu.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c, new Map<Id, EUR_CRM_AccountGroupUser__c>{
                            agu.EUR_CRM_User__c => agu
                    });
                }
            }
            return aguByUserIdByAccId;
        }

        private void configureAGsAndAGUsToInsert(Map<Id, EUR_CRM_Account__c> allAccSelectedById, Map<Id, Id> newParentAccOwnerIdByAccId, Map<Id, Id> oldParentAccOwnerIdByAccId, Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> existAguByUserIdByAccId) {
            Map<Id, List<Id>> accIdsByOldParentAccOwnerId = this.getAccIdsByOldParentAccOwnerId(oldParentAccOwnerIdByAccId);
            for (Id accId : newParentAccOwnerIdByAccId.keySet()) {
                Id newParentAccOwnerId = newParentAccOwnerIdByAccId.get(accId);
                if (accIdsByOldParentAccOwnerId.containsKey(newParentAccOwnerId)
                        || !allAccSelectedById.containsKey(accId)) {
                    continue;
                }

                EUR_CRM_Account__c accSelected = allAccSelectedById.get(accId);
                if (newParentAccOwnerId == accSelected.OwnerId) {
                    continue;
                }
                if (accSelected.EUR_CRM_AccountGroups__r.isEmpty()) {
                    this.agsToInsert.add(this.makeAG(accSelected));
                } else {
                    EUR_CRM_AccountGroup__c ag = accSelected.EUR_CRM_AccountGroups__r[0];
                    if (existAguByUserIdByAccId.containsKey(accId) && existAguByUserIdByAccId.get(accId).containsKey(accSelected.EUR_CRM_Parent_Account__r.OwnerId)) {
                        continue;
                    }
                    this.agusToInsert.add(this.makeAGU(ag, 'Edit'));
                }
            }
        }
        private void configureOldAGUsStatusToDelete(Set<Id> validAccIds, List<EUR_CRM_Account__c> validAccs, Map<Id, EUR_CRM_Account__c> oldAccById){
            Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> existAguByUserIdByAccId = this.getExistedAguByUserIdByAccId(validAccIds);
            Map<Id, Id> oldParentAccOwnerIdByAccId = new Map<Id, Id>();
            for (EUR_CRM_Account__c acc : validAccs){
                oldParentAccOwnerIdByAccId.put(acc.Id, oldAccById.get(acc.EUR_CRM_Parent_Account__c).OwnerId);
            }

            this.configureAGUsStatusToDelete(existAguByUserIdByAccId, oldParentAccOwnerIdByAccId);
        }

        private void configureAGUsStatusToDelete(Map<Id, Map<Id, EUR_CRM_AccountGroupUser__c>> existedAgusByAgIdByAccId, Map<Id, Id> oldParentAccOwnerIdByAccId) {
            for (Id accId : existedAgusByAgIdByAccId.keySet()) {
                Map<Id, EUR_CRM_AccountGroupUser__c> aguByUserId = existedAgusByAgIdByAccId.get(accId);
                Id oldUid = oldParentAccOwnerIdByAccId.get(accId);
                if (aguByUserId.containsKey(oldUid)) {
                    EUR_CRM_AccountGroupUser__c agu = aguByUserId.get(oldUid);
                    agu.EUR_CRM_Status__c = TO_DELETE_STATUS;
                    this.agusToUpdate.add(agu);
                }

            }
        }

        private Map<Id, List<Id>> getAccIdsByOldParentAccOwnerId(Map<Id, Id> oldParentAccOwnerIdByAccId) {
            Map<Id, List<Id>> accIdsByOldParentAccOwnerId = new Map<Id, List<Id>>();
            for (Id accId : oldParentAccOwnerIdByAccId.keySet()) {
                Id oldParentAccOwnerId = oldParentAccOwnerIdByAccId.get(accId);
                if (accIdsByOldParentAccOwnerId.containsKey(oldParentAccOwnerId)) {
                    accIdsByOldParentAccOwnerId.get(oldParentAccOwnerId).add(accId);
                } else {
                    accIdsByOldParentAccOwnerId.put(oldParentAccOwnerId, new List<Id>{
                            accId
                    });
                }
            }
            return accIdsByOldParentAccOwnerId;
        }

        private Map<Id, Id> getParentAccOwnerIdByAccId(Map<Id, EUR_CRM_Account__c> accountWithOwnerById, Map<Id, List<Id>> accIdsByParentAccId) {
            Map<Id, Id> parentAccOwnerIdByAccId = new Map<Id, Id>();
            for (Id parentAccId : accIdsByParentAccId.keySet()) {
                List<Id> relatedToParentAccIds = accIdsByParentAccId.get(parentAccId);
                EUR_CRM_Account__c accWithOwner = accountWithOwnerById.get(parentAccId);
                if (accWithOwner == null) {
                    continue;
                }
                for (Id relatedToParentAccId : relatedToParentAccIds) {
                    parentAccOwnerIdByAccId.put(relatedToParentAccId, accWithOwner.OwnerId);
                }
            }
            return parentAccOwnerIdByAccId;
        }


        /* ========================================================= */
        /*      Middle Level Helpers
        /* ========================================================= */
        private List<EUR_CRM_Account__c> getValidAccsToCreateAGs(List<EUR_CRM_Account__c> selectedAccs) {
            List<EUR_CRM_Account__c> accsToCreateAGs = new List<EUR_CRM_Account__c>();
            for (EUR_CRM_Account__c acc : selectedAccs) {
                if (acc.EUR_CRM_Parent_Account__r.OwnerId == acc.OwnerId) {
                    continue;
                }
                accsToCreateAGs.add(acc);
            }
            return accsToCreateAGs;
        }

        private Set<Id> getAGUIds(List<EUR_CRM_AccountGroupUser__c> agus) {
            Set<Id> aguIds = new Set<Id>();
            for (EUR_CRM_AccountGroupUser__c agu : agus) {
                if (agu.Id == null) {
                    continue;
                }
                aguIds.add(agu.Id);
            }
            return aguIds;
        }

        private List<EUR_CRM_AccountGroup__c> getAGsByAccs(List<EUR_CRM_Account__c> accs){
            List<EUR_CRM_AccountGroup__c> ags = new List<EUR_CRM_AccountGroup__c>();
            for (EUR_CRM_Account__c acc : accs){
                if (acc.EUR_CRM_AccountGroups__r.isEmpty()) {
                    continue;
                }
                ags.add(acc.EUR_CRM_AccountGroups__r);
            }
            return ags;
        }

        private List<EUR_CRM_Account__c> getValidAccsByCountryCode(List<EUR_CRM_Account__c> accs) {
            List<EUR_CRM_Account__c> validAccs = new List<EUR_CRM_Account__c>();
            for (EUR_CRM_Account__c acc : accs) {
                if (!this.isAccountValidByCountryCodeOnInsert(acc)) {
                    continue;
                }
                validAccs.add(acc);
            }
            return validAccs;
        }

        private List<EUR_CRM_Account__c> getValidAccsByParentAccount(List<EUR_CRM_Account__c> accs) {
            List<EUR_CRM_Account__c> validAccs = new List<EUR_CRM_Account__c>();
            for (EUR_CRM_Account__c acc : accs) {
                if (!this.isAccountValidByParentAccountOnInsert(acc)) {
                    continue;
                }
                validAccs.add(acc);
            }
            return validAccs;
        }

        private Set<Id> getValidOwnerAccs(List<EUR_CRM_Account__c> accs, Map<Id, EUR_CRM_Account__c> olcAccById) {
            Set<Id> validAccs = new Set<Id>();
            for (EUR_CRM_Account__c acc : accs) {
                if (!this.isAccountOwnerValidOnUpdate(acc, olcAccById.get(acc.Id))) {
                    continue;
                }
                validAccs.add(acc.Id);
            }
            return validAccs;
        }

        private List<EUR_CRM_Account__c> getValidAccs(List<EUR_CRM_Account__c> accs, Map<Id, EUR_CRM_Account__c> olcAccById) {
            List<EUR_CRM_Account__c> validAccs = new List<EUR_CRM_Account__c>();
            for (EUR_CRM_Account__c acc : accs) {
                if (!this.isAccountValidOnUpdate(acc, olcAccById.get(acc.Id))) {
                    continue;
                }
                validAccs.add(acc);
            }
            return validAccs;
        }

        private Map<Id, List<Id>> getAccIdsByParentAccId(List<EUR_CRM_Account__c> validAccs, Map<Id, EUR_CRM_Account__c> oldAccById) {
            Map<Id, List<Id>> accIdsByOldParentAccId = new Map<Id, List<Id>>();
            for (EUR_CRM_Account__c acc : validAccs) {
                EUR_CRM_Account__c oldAcc = oldAccById.get(acc.Id);
                if (oldAcc == null || oldAcc.EUR_CRM_Parent_Account__c == null) {
                    continue;
                }
                if (accIdsByOldParentAccId.containsKey(oldAcc.EUR_CRM_Parent_Account__c)) {
                    accIdsByOldParentAccId.get(oldAcc.EUR_CRM_Parent_Account__c).add(oldAcc.Id);
                } else {
                    accIdsByOldParentAccId.put(oldAcc.EUR_CRM_Parent_Account__c, new List<Id>{
                            oldAcc.Id
                    });
                }

            }
            return accIdsByOldParentAccId;
        }

        /* ========================================================= */
        /*      Low Level Helpers
        /* ========================================================= */
        private Boolean isAccountValidByCountryCodeOnInsert(EUR_CRM_Account__c acc) {
            return this.isCountryCodeValid(acc);
        }

        private Boolean isAccountValidByParentAccountOnInsert(EUR_CRM_Account__c acc) {
            return this.isParentAccountExist(acc);

        }

        private Boolean isAccountValidOnUpdate(EUR_CRM_Account__c acc, EUR_CRM_Account__c oldAcc) {
            return this.isParentAccountChanged(acc, oldAcc)
                    && this.isCountryCodeValid(acc);
        }

        private Boolean isAccountOwnerValidOnUpdate(EUR_CRM_Account__c acc, EUR_CRM_Account__c oldAcc) {
            return this.isOwnerAccountChanged(acc, oldAcc)
                    && this.isCountryCodeValid(acc);
        }

        private Boolean isParentAccountExist(EUR_CRM_Account__c acc) {
            return acc.EUR_CRM_Parent_Account__c != null;
        }

        private Boolean isParentAccountChanged(EUR_CRM_Account__c acc, EUR_CRM_Account__c oldAcc) {
            return acc.EUR_CRM_Parent_Account__c != oldAcc.EUR_CRM_Parent_Account__c;
        }

        private Boolean isOwnerAccountChanged(EUR_CRM_Account__c acc, EUR_CRM_Account__c oldAcc) {
            return acc.OwnerId != oldAcc.OwnerId;
        }

        private Boolean isCountryCodeValid(EUR_CRM_Account__c acc) {
            return ROLLOUT_COUNTRY_CODES.contains(acc.EUR_CRM_Country_Code__c);
        }


        /* ========================================================= */
        /*     Makers
        /* ========================================================= */
        private List<EUR_CRM_AccountGroup__c> makeAGs(List<EUR_CRM_Account__c> accsToCreateAG) {
            List<EUR_CRM_AccountGroup__c> agsToInsert = new List<EUR_CRM_AccountGroup__c>();
            for (EUR_CRM_Account__c acc : accsToCreateAG) {
                agsToInsert.add(this.makeAG(acc));
            }
            return agsToInsert;
        }

        private EUR_CRM_AccountGroup__c makeAG(EUR_CRM_Account__c acc) {
            return new EUR_CRM_AccountGroup__c(
                    EUR_CRM_Account__c = acc.Id
                    , EUR_CRM_External_ID__c = acc.EUR_CRM_External_ID__c
                    , EUR_CRM_Country_Code__c = acc.EUR_CRM_Country_Code__c
            );
        }

        private List<EUR_CRM_AccountGroupUser__c> makeAGUs(List<EUR_CRM_AccountGroup__c> selectedAGs) {
            List<EUR_CRM_AccountGroupUser__c> agusToInsert = new List<EUR_CRM_AccountGroupUser__c>();
            for (EUR_CRM_AccountGroup__c ag : selectedAGs) {
                agusToInsert.add(this.makeAGU(ag, 'Edit'));
            }
            return agusToInsert;
        }

        private EUR_CRM_AccountGroupUser__c makeAGU(EUR_CRM_AccountGroup__c ag, String accessLevel) {
            return new EUR_CRM_AccountGroupUser__c(
                    EUR_CRM_AccountGroup__c = ag.Id
                    , EUR_CRM_User__c = ag.EUR_CRM_Account__r.EUR_CRM_Parent_Account__r.OwnerId
                    , EUR_CRM_AccessLevel__c = accessLevel
            );
        }


        private EUR_CRM_AccountGroupUser__c makeAGU(Id agId, Id uId, String accessLevel) {
            return new EUR_CRM_AccountGroupUser__c(
                    EUR_CRM_AccountGroup__c = agId
                    , EUR_CRM_User__c = uId
                    , EUR_CRM_AccessLevel__c = accessLevel
            );
        }
    }
}