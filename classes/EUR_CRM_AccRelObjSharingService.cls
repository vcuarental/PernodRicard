public without sharing class EUR_CRM_AccRelObjSharingService {

    private Map<Id, Map<Id, String>> accessLevelByUserIdByAccountId;
    @TestVisible
    private static final String SHARED_STATUS = 'Record shared';


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void createSharing(List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTrackings) {
        System.debug('\n\n competitorPromoTrackings.size() => ' + JSON.serializePretty(competitorPromoTrackings.size()) + '\n');
        System.debug('\n\n competitorPromoTrackings => ' + JSON.serializePretty(competitorPromoTrackings) + '\n');

        Set<Id> accountIds = this.getAccountIds(competitorPromoTrackings);
        System.debug('\n\n accountIds.size() => ' + JSON.serializePretty(accountIds.size()) + '\n');
        System.debug('\n\n accountIds => ' + JSON.serializePretty(accountIds) + '\n');

        this.configureAccessLevelByUserIdByAccountId(accountIds);

        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = this.makeCompetitorPromoTrackingShares(competitorPromoTrackings);
        System.debug('\n\n competitorPromoTrackingShares.size() => ' + JSON.serializePretty(competitorPromoTrackingShares.size()) + '\n');
        System.debug('\n\n competitorPromoTrackingShares => ' + JSON.serializePretty(competitorPromoTrackingShares) + '\n');

        if (competitorPromoTrackingShares.isEmpty()) { return ; }

        insert competitorPromoTrackingShares;
    }

    public void createSharing(List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements) {
        System.debug('\n\n brandSecurityInfringements.size() => ' + JSON.serializePretty(brandSecurityInfringements.size()) + '\n');
        System.debug('\n\n brandSecurityInfringements => ' + JSON.serializePretty(brandSecurityInfringements) + '\n');

        Set<Id> accountIds = this.getAccountIds(brandSecurityInfringements);
        System.debug('\n\n accountIds.size() => ' + JSON.serializePretty(accountIds.size()) + '\n');
        System.debug('\n\n accountIds => ' + JSON.serializePretty(accountIds) + '\n');

        this.configureAccessLevelByUserIdByAccountId(accountIds);

        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = this.makeBrandSecurityInfringementShares(brandSecurityInfringements);
        System.debug('\n\n brandSecurityInfringementShares.size() => ' + JSON.serializePretty(brandSecurityInfringementShares.size()) + '\n');
        System.debug('\n\n brandSecurityInfringementShares => ' + JSON.serializePretty(brandSecurityInfringementShares) + '\n');

        if (brandSecurityInfringementShares.isEmpty()) { return ; }

        insert brandSecurityInfringementShares;
    }

    public void createSharing(List<EUR_CRM_Visit__c> visits) {
        System.debug('\n\n visits.size() => ' + JSON.serializePretty(visits.size()) + '\n');
        System.debug('\n\n visits => ' + JSON.serializePretty(visits) + '\n');

        Set<Id> accountIds = this.getAccountIds(visits);
        System.debug('\n\n accountIds.size() => ' + JSON.serializePretty(accountIds.size()) + '\n');
        System.debug('\n\n accountIds => ' + JSON.serializePretty(accountIds) + '\n');

        this.configureAccessLevelByUserIdByAccountId(accountIds);

        List<EUR_CRM_Visit__Share> visitShares = this.makeVisitShares(visits);
        System.debug('\n\n visitShares.size() => ' + JSON.serializePretty(visitShares.size()) + '\n');
        System.debug('\n\n visitShares => ' + JSON.serializePretty(visitShares) + '\n');

        if (visitShares.isEmpty()) { return ; }

        insert visitShares;
    }

    public void createSharing(List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappings) {
        System.debug('\n\n objPromoAccountMappings.size() => ' + JSON.serializePretty(objPromoAccountMappings.size()) + '\n');
        System.debug('\n\n objPromoAccountMappings => ' + JSON.serializePretty(objPromoAccountMappings) + '\n');

        Set<Id> accountIds = this.getAccountIds(objPromoAccountMappings);
        System.debug('\n\n accountIds.size() => ' + JSON.serializePretty(accountIds.size()) + '\n');
        System.debug('\n\n accountIds => ' + JSON.serializePretty(accountIds) + '\n');

        this.configureAccessLevelByUserIdByAccountId(accountIds);

        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappingsWithObjPromoOwnerId = this.selectObjPromoAccountMapping(new Map<Id, EUR_CRM_ObjPromo_Account_Mapping__c>(objPromoAccountMappings).keySet());
        List<EUR_CRM_ObjPromo__Share> objPromoShares = this.makeObjPromoShares(objPromoAccountMappingsWithObjPromoOwnerId);
        System.debug('\n\n objPromoShares.size() => ' + JSON.serializePretty(objPromoShares.size()) + '\n');
        System.debug('\n\n objPromoShares => ' + JSON.serializePretty(objPromoShares) + '\n');

        if (objPromoShares.isEmpty()) { return ; }

        insert objPromoShares;
    }

    public void createSharing(List<EUR_CRM_GB_Objective__c> objectives) {
        System.debug('\n\n objectives.size() => ' + JSON.serializePretty(objectives.size()) + '\n');
        System.debug('\n\n objectives => ' + JSON.serializePretty(objectives) + '\n');

        Set<Id> accountIds = this.getAccountIds(objectives);
        System.debug('\n\n accountIds.size() => ' + JSON.serializePretty(accountIds.size()) + '\n');
        System.debug('\n\n accountIds => ' + JSON.serializePretty(accountIds) + '\n');

        this.configureAccessLevelByUserIdByAccountId(accountIds);

        List<EUR_CRM_GB_Objective__Share> objectiveShares = this.makeObjectiveShares(objectives);
        System.debug('\n\n objectiveShares.size() => ' + JSON.serializePretty(objectiveShares.size()) + '\n');
        System.debug('\n\n objectiveShares => ' + JSON.serializePretty(objectiveShares) + '\n');

        if (objectiveShares.isEmpty()) { return ; }

        insert objectiveShares;
    }

    public void createSharing(List<EUR_CRM_Contract_Tracker__c> contractTrackers) {
        System.debug('\n\n contractTrackers.size() => ' + JSON.serializePretty(contractTrackers.size()) + '\n');
        System.debug('\n\n contractTrackers => ' + JSON.serializePretty(contractTrackers) + '\n');

        Set<Id> accountIds = this.getAccountIds(contractTrackers);
        System.debug('\n\n accountIds.size() => ' + JSON.serializePretty(accountIds.size()) + '\n');
        System.debug('\n\n accountIds => ' + JSON.serializePretty(accountIds) + '\n');

        this.configureAccessLevelByUserIdByAccountId(accountIds);

        List<EUR_CRM_Contract_Tracker__Share> contractTracker = this.makeContractTrackerShares(contractTrackers);
        System.debug('\n\n contractTracker.size() => ' + JSON.serializePretty(contractTracker.size()) + '\n');
        System.debug('\n\n contractTracker => ' + JSON.serializePretty(contractTracker) + '\n');

        if (contractTracker.isEmpty()) { return ; }

        insert contractTracker;
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void configureAccessLevelByUserIdByAccountId(Set<Id> accountIds) {
        this.accessLevelByUserIdByAccountId = new Map<Id, Map<Id, String>>();

        accountIds.remove(null);
        if(accountIds.isEmpty()){ return; }

        List<EUR_CRM_AccountGroupUser__c> accountGroupUsers = this.selectAccountGroupUsersWhereAccountIds(accountIds);
        System.debug('\n\n accountGroupUsers.size() => ' + JSON.serializePretty(accountGroupUsers.size()) + '\n');
        System.debug('\n\n accountGroupUsers => ' + JSON.serializePretty(accountGroupUsers) + '\n');

        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            Id accountId = accountGroupUser.EUR_CRM_AccountOnGroup__c;//EUR_CRM_AccountGroup__r.EUR_CRM_Account__c;
            Id userId = accountGroupUser.EUR_CRM_User__c;

            if(accountGroupUser.EUR_CRM_IsUserActive__c == true){
                if (!this.accessLevelByUserIdByAccountId.containsKey(accountId)) {
                    this.accessLevelByUserIdByAccountId.put(accountId, new Map<Id, String>());
                }
                this.accessLevelByUserIdByAccountId.get(accountId).put(userId, accountGroupUser.EUR_CRM_AccessLevel__c);
            }
        }
        System.debug('\n\n this.accessLevelByUserIdByAccountId.size() => ' + JSON.serializePretty(this.accessLevelByUserIdByAccountId.size()) + '\n');
        System.debug('\n\n this.accessLevelByUserIdByAccountId => ' + JSON.serializePretty(this.accessLevelByUserIdByAccountId) + '\n');
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Competitor_Promo_Tracking__Share> makeCompetitorPromoTrackingShares(List<EUR_CRM_Competitor_Promo_Tracking__c> trackings) {
        List<EUR_CRM_Competitor_Promo_Tracking__Share> shares = new List<EUR_CRM_Competitor_Promo_Tracking__Share>();
        for (EUR_CRM_Competitor_Promo_Tracking__c tracking : trackings) {
            Id accId = tracking.EUR_CRM_Account_Name__c;
            if (this.accessLevelByUserIdByAccountId.containsKey(accId)) {
                for (Id userId : this.accessLevelByUserIdByAccountId.get(accId).keySet()) {
                    if (tracking.OwnerId != userId) {
                        String accessLevel = accessLevelByUserIdByAccountId.get(accId).get(userId);
                        shares.add(this.makeCompetitorPromoTrackingShare(tracking.Id, userId, accessLevel));
                    }
                }
            }
        }
        return shares;
    }

    private List<EUR_CRM_Brand_Security_Infringement__Share> makeBrandSecurityInfringementShares(List<EUR_CRM_Brand_Security_Infringement__c> infringements) {
        List<EUR_CRM_Brand_Security_Infringement__Share> shares = new List<EUR_CRM_Brand_Security_Infringement__Share>();
        for (EUR_CRM_Brand_Security_Infringement__c infringement : infringements) {
            Id accId = infringement.EUR_CRM_Outlet_Name__c;
            if (this.accessLevelByUserIdByAccountId.containsKey(accId)) {
                for (Id userId : this.accessLevelByUserIdByAccountId.get(accId).keySet()) {
                    if (infringement.OwnerId != userId) {
                        String accessLevel = accessLevelByUserIdByAccountId.get(accId).get(userId);
                        shares.add(this.makeBrandSecurityInfringementShare(infringement.Id, userId, accessLevel));
                    }
                }
            }
        }
        return shares;
    }

    private List<EUR_CRM_Visit__Share> makeVisitShares(List<EUR_CRM_Visit__c> visits) {
        List<EUR_CRM_Visit__Share> shares = new List<EUR_CRM_Visit__Share>();
        for (EUR_CRM_Visit__c visit : visits) {
            Id accId = visit.EUR_CRM_Account__c;
            if (this.accessLevelByUserIdByAccountId.containsKey(accId)) {
                for (Id userId : this.accessLevelByUserIdByAccountId.get(accId).keySet()) {
                    if (visit.OwnerId != userId) {
                        String accessLevel = accessLevelByUserIdByAccountId.get(accId).get(userId);
                        shares.add(this.makeVisitShare(visit.Id, userId, accessLevel));
                    }
                }
            }
        }
        return shares;
    }

    private List<EUR_CRM_ObjPromo__Share> makeObjPromoShares(List<EUR_CRM_ObjPromo_Account_Mapping__c> mappings) {
        List<EUR_CRM_ObjPromo__Share> shares = new List<EUR_CRM_ObjPromo__Share>();
        for (EUR_CRM_ObjPromo_Account_Mapping__c mapping : mappings) {
            Id accId = mapping.EUR_CRM_Account__c;
            if (this.accessLevelByUserIdByAccountId.containsKey(accId)) {
                for (Id userId : this.accessLevelByUserIdByAccountId.get(accId).keySet()) {
                    if (mapping.EUR_CRM_ObjPromo__r.OwnerId != userId) {
                        String accessLevel = accessLevelByUserIdByAccountId.get(accId).get(userId);
                        shares.add(this.makeObjPromoShare(mapping.EUR_CRM_ObjPromo__c, userId, accessLevel));
                    }
                }
            }
        }
        return shares;
    }

    private List<EUR_CRM_GB_Objective__Share> makeObjectiveShares(List<EUR_CRM_GB_Objective__c> objectives) {
        List<EUR_CRM_GB_Objective__Share> shares = new List<EUR_CRM_GB_Objective__Share>();
        for (EUR_CRM_GB_Objective__c objective : objectives) {
            Id accId = objective.EUR_CRM_Account__c;
            if (this.accessLevelByUserIdByAccountId.containsKey(accId)) {
                for (Id userId : this.accessLevelByUserIdByAccountId.get(accId).keySet()) {
                    if (objective.OwnerId != userId) {
                        String accessLevel = accessLevelByUserIdByAccountId.get(accId).get(userId);
                        shares.add(this.makeObjectiveShare(objective.Id, userId, accessLevel));
                    }
                }
            }
        }
        return shares;
    }

    private List<EUR_CRM_Contract_Tracker__Share> makeContractTrackerShares(List<EUR_CRM_Contract_Tracker__c> contractTrackers) {
        List<EUR_CRM_Contract_Tracker__Share> shares = new List<EUR_CRM_Contract_Tracker__Share>();
        for (EUR_CRM_Contract_Tracker__c tracker : contractTrackers) {
            Id accId = tracker.EUR_CRM_Account__c;
            if (this.accessLevelByUserIdByAccountId.containsKey(accId)) {
                for (Id userId : this.accessLevelByUserIdByAccountId.get(accId).keySet()) {
                    if (tracker.OwnerId != userId) {
                        String accessLevel = accessLevelByUserIdByAccountId.get(accId).get(userId);
                        shares.add(this.makeContractTrackerShare(tracker.Id, userId, accessLevel));
                    }
                }
            }
        }
        return shares;
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Set<Id> getAccountIds(List<EUR_CRM_Competitor_Promo_Tracking__c> promoTrackings) {
        Set<Id> accountIds = new Set<Id>();
        for (EUR_CRM_Competitor_Promo_Tracking__c tracking : promoTrackings) {
            accountIds.add(tracking.EUR_CRM_Account_Name__c);
        }
        return accountIds;
    }

    private Set<Id> getAccountIds(List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements) {
        Set<Id> accountIds = new Set<Id>();
        for (EUR_CRM_Brand_Security_Infringement__c infringement : brandSecurityInfringements) {
            accountIds.add(infringement.EUR_CRM_Outlet_Name__c);
        }
        return accountIds;
    }

    private Set<Id> getAccountIds(List<EUR_CRM_Visit__c> visits) {
        Set<Id> accountIds = new Set<Id>();
        for (EUR_CRM_Visit__c visit : visits) {
            accountIds.add(visit.EUR_CRM_Account__c);
        }
        return accountIds;
    }

    private Set<Id> getAccountIds(List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappings) {
        Set<Id> accountIds = new Set<Id>();
        for (EUR_CRM_ObjPromo_Account_Mapping__c mapping : objPromoAccountMappings) {
            accountIds.add(mapping.EUR_CRM_Account__c);
        }
        return accountIds;
    }

    private Set<Id> getAccountIds(List<EUR_CRM_GB_Objective__c> objectives) {
        Set<Id> accountIds = new Set<Id>();
        for (EUR_CRM_GB_Objective__c objective : objectives) {
            accountIds.add(objective.EUR_CRM_Account__c);
        }
        return accountIds;
    }

    private Set<Id> getAccountIds(List<EUR_CRM_Contract_Tracker__c> contractTrackers) {
        Set<Id> accountIds = new Set<Id>();
        for (EUR_CRM_Contract_Tracker__c tracker : contractTrackers) {
            accountIds.add(tracker.EUR_CRM_Account__c);
        }
        return accountIds;
    }


    /* ========================================================= */
    /*     Low Level Makers (sharing)
    /* ========================================================= */
    private EUR_CRM_Competitor_Promo_Tracking__Share makeCompetitorPromoTrackingShare(Id parentId, Id userId, String accessLevel) {
        return new EUR_CRM_Competitor_Promo_Tracking__Share(
            ParentId = parentId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = accessLevel
        );
    }

    private EUR_CRM_Brand_Security_Infringement__Share makeBrandSecurityInfringementShare(Id parentId, Id userId, String accessLevel) {
        return new EUR_CRM_Brand_Security_Infringement__Share(
            ParentId = parentId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = accessLevel
        );
    }

    private EUR_CRM_Visit__Share makeVisitShare(Id parentId, Id userId, String accessLevel) {
        return new EUR_CRM_Visit__Share(
            ParentId = parentId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = accessLevel
        );
    }

    private EUR_CRM_ObjPromo__Share makeObjPromoShare(Id parentId, Id userId, String accessLevel) {
        return new EUR_CRM_ObjPromo__Share(
            ParentId = parentId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = accessLevel
        );
    }

    private EUR_CRM_GB_Objective__Share makeObjectiveShare(Id parentId, Id userId, String accessLevel) {
        return new EUR_CRM_GB_Objective__Share(
            ParentId = parentId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = accessLevel
        );
    }

    private EUR_CRM_Contract_Tracker__Share makeContractTrackerShare(Id parentId, Id userId, String accessLevel) {
        return new EUR_CRM_Contract_Tracker__Share(
            ParentId = parentId
        ,   UserOrGroupId = userId
        ,   RowCause = 'Manual'
        ,   AccessLevel = accessLevel
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_AccountGroupUser__c> selectAccountGroupUsersWhereAccountIds(Set<Id> accountIds) {
        return [
            SELECT Id
            ,   EUR_CRM_AccountOnGroup__c
            ,   EUR_CRM_User__c
            ,   EUR_CRM_IsUserActive__c
            ,   EUR_CRM_AccessLevel__c
            FROM EUR_CRM_AccountGroupUser__c
            WHERE EUR_CRM_AccountOnGroup__c!=NULL AND EUR_CRM_Status__c =: SHARED_STATUS AND EUR_CRM_AccountOnGroup__c IN
                    :accountIds
                //EUR_CRM_AccountGroup__r.EUR_CRM_Account__c
        ];
    }

    private List<EUR_CRM_ObjPromo_Account_Mapping__c> selectObjPromoAccountMapping(Set<Id> ids) {
        return [
            SELECT Id
            ,   EUR_CRM_Account__c
            ,   EUR_CRM_ObjPromo__c
            ,   EUR_CRM_ObjPromo__r.OwnerId
            FROM EUR_CRM_ObjPromo_Account_Mapping__c
            WHERE Id IN :ids
        ];
    }

}