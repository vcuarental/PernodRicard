/**
 * Created by Xiaomi on 4/27/2020.
 */

public with sharing class EUR_CRM_AccGroupUserSharingService {

    @TestVisible
    private static final String NEW_STATUS = 'New';
    @TestVisible
    private static final String TO_DELETE_STATUS = 'To Delete';

    private static final String RECORD_SHARED = 'Record shared';

    private static final String APEX_SHARING_REASON = 'EUR_CRM_Account_Group_User__c';

    private List<EUR_CRM_AccountGroupUser__c> accountGroupUsers;
    private List<EUR_CRM_AccountGroupUser__c> accountGroupUsersNew;
    private List<EUR_CRM_AccountGroupUser__c> accountGroupUsersShared;
    private List<EUR_CRM_AccountGroupUser__c> accountGroupUsersToDelete;

    private Map<Id, Map<Id, String>> accessLevelByUserIdByEUAccountId;
    private Map<String, Set<Id>> accountIdsByCountryCode;

    private Map<Id, Set<Id>> userIdsByEUAccountId;
    private Map<Id, Id> accountIdByEUAccountId;
    private Map<Id, Set<Id>> userIdsByAccountId;
    private Set<Id> userIdsToShare;

    private Map<Id, Set<Id>> objPromoIdsToShareByEUAccountId;

    private Map<Id, Map<Id, EUR_CRM_Account__Share>> existEUAccountShareByUserIdByParentId;
    private Map<Id, Map<Id, AccountShare>> existAccountShareByUserIdByParentId;

    private Map<Id, Map<Id, List<EUR_CRM_Competitor_Promo_Tracking__Share>>> existCompetitorPromoTrackingSharesByUserIdByParentId;
    private Map<Id, Map<Id, List<EUR_CRM_Competitor_Promo_Tracking__Share>>> existCompetitorPromoTrackingSharesByUserIdByEUAccountId;
    private Map<Id, Map<Id, List<EUR_CRM_Brand_Security_Infringement__Share>>> existBrandSecurityInfringementSharesByUserIdByParentId;
    private Map<Id, Map<Id, List<EUR_CRM_Brand_Security_Infringement__Share>>> existBrandSecurityInfringementSharesByUserIdByEUAccountId;
    private Map<Id, Map<Id, List<EUR_CRM_Visit__Share>>> existVisitSharesByUserIdByParentId;
    private Map<Id, Map<Id, List<EUR_CRM_Visit__Share>>> existVisitSharesByUserIdByEUAccountId;
    private Map<Id, Map<Id, List<EUR_CRM_ObjPromo__Share>>> existObjPromoSharesByUserIdByParentId;
    private Map<Id, Map<Id, List<EUR_CRM_ObjPromo__Share>>> existObjPromoSharesByUserIdByEUAccountId;
    private Map<Id, Map<Id, List<EUR_CRM_GB_Objective__Share>>> existObjectiveSharesByUserIdByParentId;
    private Map<Id, Map<Id, List<EUR_CRM_GB_Objective__Share>>> existObjectiveSharesByUserIdByEUAccountId;
    private Map<Id, Map<Id, List<EUR_CRM_Contract_Tracker__Share>>> existContractTrackerSharesByUserIdByParentId;
    private Map<Id, Map<Id, List<EUR_CRM_Contract_Tracker__Share>>> existContractTrackerSharesByUserIdByEUAccountId;

    private Map<Id, Map<Id, List<EUR_CRM_Contract_Audit__Share>>> existContractAuditSharesByUserIdByParentId;
    private Map<Id, Map<Id, List<EUR_CRM_Contract_Audit__Share>>> existContractAuditSharesByUserIdByEUAccountId;

    private Map<Id, Map<Id, List<EUR_CRM_Visit_Action__Share>>> existVisitActionSharesByUserIdByParentId;
    private Map<Id, Map<Id, List<EUR_CRM_Visit_Action__Share>>> existVisitActionSharesByUserIdByEUAccountId;

    private Set<Id> euAccountIdsToShare;
    private Set<Id> accountIdsToShare;
    private List<EUR_CRM_Account__Share> euAccountShareToInsert;
    private List<AccountShare> accountSharesToInsert;

    private Set<Id> euAccountIdsToDeleteShare;
    private Set<Id> accountIdsToDeleteShare;
    private List<EUR_CRM_Account__Share> euAccountSharesToDelete;
    private List<AccountShare> accountSharesToDelete;

    public EUR_CRM_AccGroupUserSharingService(List<EUR_CRM_AccountGroupUser__c> accountGroupUsers) {
        System.debug('\n\n accountGroupUsers => ' + JSON.serializePretty(accountGroupUsers) + '\n');
        this.accountGroupUsers = accountGroupUsers;
        this.sortAccountGroupUserByStatus();
        this.configureAccountIdsByCountyCode();
        this.configureAccessLevelByUserIdByAccountId();

        this.configureUserIdsByEUAccountIdToSharing();
        this.configureUserIdsByAccountIdToSharing();

        this.initializeExistsSharing();
    }

    public static Map<Id, EUR_CRM_Account__c> setVisibleToID(List<EUR_CRM_AccountGroupUser__c> agus) {
        Map<Id, Set<String>> toRemove = new Map<Id, Set<String>>();
        Map<Id, Set<String>> toAdd = new Map<Id, Set<String>>();
        Map<Id, EUR_CRM_Account__c> accs = new Map<Id, EUR_CRM_Account__c>();

        //17*15 = 255, but we need to consider the space for the comma
        //16 *15 = 240 + (16 - 1) for the commas = 255, so 16 should work
        //For safety we can put 15, we'll still be able to share with 30 users
        //It's more than enough
        Integer MAX = 15;
        String SEP = ',';

        for(EUR_CRM_AccountGroupUser__c agu : agus) {
            Id accId = agu.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c;

            String userStringId = (String) agu.EUR_CRM_User__c;

            userStringId = userStringId.subString(3);

            Set<String> adds = toAdd.get(accId);
            if(adds == null) {
                adds = new Set<String>();
            }
            Set<String> removes = toRemove.get(accId);
            if(removes == null) {
                removes = new Set<String>();
            }
            System.debug('BEFORE STATUS: ' + agu.EUR_CRM_Status__c);

            if(agu.EUR_CRM_Status__c.equalsIgnoreCase(NEW_STATUS)) {
                adds.add(userStringId);
            } else if(agu.EUR_CRM_Status__c.equalsIgnoreCase(TO_DELETE_STATUS)) {
                removes.add(userStringId);
            }

            toAdd.put(accId, adds);
            toRemove.put(accId, removes);
            //Put many times but it doesn't really matter since we always put the same values inside
            accs.put(accId, new EUR_CRM_Account__c(
                    Id = accId,
                    EUR_CRM_Visible_to_ID1__c = agu.EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Visible_to_ID1__c,
                    EUR_CRM_Visible_to_ID2__c = agu.EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Visible_to_ID2__c
            ));
        }
        System.debug('MAP toAdd:' + toAdd);
        System.debug('MAP toRemove:' + toRemove);
        System.debug('MAP accs:' + accs);
        for(Id accId : accs.keySet()) {
            EUR_CRM_Account__c acc = accs.get(accId);
            //Might need to add a null check in case field is empty
            String visibleToID1 = (acc.EUR_CRM_Visible_to_ID1__c == null ? '' : acc.EUR_CRM_Visible_to_ID1__c);
            String visibleTOID2 = (acc.EUR_CRM_Visible_to_ID2__c == null ? '' : acc.EUR_CRM_Visible_to_ID2__c);
            Set<String> currID1 = new Set<String>();
            Set<String> currID2 = new Set<String>();
            for(String s : visibleToID1.split(SEP)) {
                if(!String.isBlank(s)) {
                    currID1.add(s);
                }
            }
            for(String s : visibleToID2.split(SEP)) {
                if(!String.isBlank(s)) {
                    currID2.add(s);
                }
            }

            Set<String> removes = toRemove.get(accId);
            currID1.removeAll(removes);
            currID2.removeAll(removes);

            //Can't do addAll here since we need to check the size
            for(String a : toAdd.get(accId)) {
                if(currID1.size() <= MAX) {
                    //It is a set, so if ID already there it won't add it
                    currID1.add(a);
                } else if(currID2.size() <= MAX) {
                    //It is a set, so if ID already there it won't add it
                    currID2.add(a);
                } else {
                    //Error handling ?
                    System.debug('Too many IDs, it cannot be filled inside visible to ID1/Visible to ID2');
                }
            }
            System.debug('ID1 : ' + currID1);
            System.debug('ID2 : ' + currID2);
            //Re-write the values
            List<String> currListID1 = new List<String>();
            currListID1.addAll(currID1);
            List<String> currListID2 = new List<String>();
            currListID2.addAll(currID2);
            acc.EUR_CRM_Visible_to_ID1__c = String.join(currListID1, SEP);
            acc.EUR_CRM_Visible_to_ID2__c = String.join(currListID2, SEP);
        }

        return accs;
    }

    /* ========================================================= */
    /*     Interface (sharing to insert)
    /* ========================================================= */
    public List<EUR_CRM_Account__Share> getEUAccountSharesToInsert() {
        this.euAccountShareToInsert = this.makeEUAccountShares();
        System.debug('\n\n this.euAccountIdsToShare => ' + JSON.serializePretty(this.euAccountIdsToShare) + '\n');
        System.debug('\n\n this.euAccountShareToInsert => ' + JSON.serializePretty(this.euAccountShareToInsert) + '\n');
        return this.euAccountShareToInsert;
    }

    public List<AccountShare> getAccountSharesToInsert() {
        this.accountSharesToInsert = this.makeAccountShares();
        System.debug('\n\n this.accountIdsToShare => ' + JSON.serializePretty(this.accountIdsToShare) + '\n');
        System.debug('\n\n this.accountSharesToInsert => ' + JSON.serializePretty(this.accountSharesToInsert) + '\n');
        return this.accountSharesToInsert;
    }

    public Map<String, List<SObject>> getChildSharesToInsert() {
        Map<String, List<SObject>> sObjectsShares = new Map<String, List<SObject>>();
        List<SObject> visitShares = this.makeVisitShares();
        if (!visitShares.isEmpty()) {
            sObjectsShares.put('visitShares', visitShares);
        }
        List<SObject> objectiveShares = this.makeObjectiveShares();
        if (!objectiveShares.isEmpty()) {
            sObjectsShares.put('objectiveShares', objectiveShares);
        }
        List<SObject> competitorPTShares = this.makeCompetitorPromoTrackingShares();
        if (!competitorPTShares.isEmpty()) {
            sObjectsShares.put('competitorPTShares', competitorPTShares);
        }
        List<SObject> contractTrackerShares = this.makeContractTrackerShares();
        if (!contractTrackerShares.isEmpty()) {
            sObjectsShares.put('contractTrackerShares', contractTrackerShares);
        }
        List<SObject> brandSIShares = this.makeBrandSecurityInfringementShares();
        if (!brandSIShares.isEmpty()) {
            sObjectsShares.put('brandSIShares', brandSIShares);
        }
        List<SObject> contractAuditShares = this.makeContractAuditShares();
        if (!contractAuditShares.isEmpty()) {
            sObjectsShares.put('contractAuditShares', contractAuditShares);
        }
        List<SObject> visitActionShares = this.makeVisitActionShares();
        if (!visitActionShares.isEmpty()) {
            sObjectsShares.put('visitActionShares', visitActionShares);
        }
        return sObjectsShares;
    }

//    public List<EUR_CRM_Competitor_Promo_Tracking__Share> getCompetitorPromoTrackingSharesToInsert() {
//        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingSharesToInsert = this.makeCompetitorPromoTrackingShares();
//        System.debug('\n\n competitorPromoTrackingSharesToInsert.size() => ' + JSON.serializePretty(competitorPromoTrackingSharesToInsert.size()) + '\n');
//        System.debug('\n\n competitorPromoTrackingSharesToInsert => ' + JSON.serializePretty(competitorPromoTrackingSharesToInsert) + '\n');
//        return competitorPromoTrackingSharesToInsert;
//    }
//
//    public List<EUR_CRM_Brand_Security_Infringement__Share> getBrandSecurityInfringementSharesToInsert() {
//        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementSharesToInsert = this.makeBrandSecurityInfringementShares();
//        System.debug('\n\n brandSecurityInfringementSharesToInsert.size() => ' + JSON.serializePretty(brandSecurityInfringementSharesToInsert.size()) + '\n');
//        System.debug('\n\n brandSecurityInfringementSharesToInsert => ' + JSON.serializePretty(brandSecurityInfringementSharesToInsert) + '\n');
//        return brandSecurityInfringementSharesToInsert;
//    }
//
//    public List<EUR_CRM_Visit__Share> getVisitSharesToInsert() {
//        List<EUR_CRM_Visit__Share> visitSharesToInsert = this.makeVisitShares();
//        System.debug('\n\n visitSharesToInsert.size() => ' + JSON.serializePretty(visitSharesToInsert.size()) + '\n');
//        System.debug('\n\n visitSharesToInsert => ' + JSON.serializePretty(visitSharesToInsert) + '\n');
//        return visitSharesToInsert;
//    }
//
//    public List<EUR_CRM_ObjPromo__Share> getObjPromoSharesToInsert() {
//        List<EUR_CRM_ObjPromo__Share> objPromoSharesToInsert = this.makeObjPromoShares();
//        System.debug('\n\n objPromoSharesToInsert.size() => ' + JSON.serializePretty(objPromoSharesToInsert.size()) + '\n');
//        System.debug('\n\n objPromoSharesToInsert => ' + JSON.serializePretty(objPromoSharesToInsert) + '\n');
//        return objPromoSharesToInsert;
//    }
//
//    public List<EUR_CRM_GB_Objective__Share> getObjectiveSharesToInsert() {
//        List<EUR_CRM_GB_Objective__Share> objectiveSharesToInsert = this.makeObjectiveShares();
//        System.debug('\n\n objectiveSharesToInsert.size() => ' + JSON.serializePretty(objectiveSharesToInsert.size()) + '\n');
//        System.debug('\n\n objectiveSharesToInsert => ' + JSON.serializePretty(objectiveSharesToInsert) + '\n');
//        return objectiveSharesToInsert;
//    }
//
//    public List<EUR_CRM_Contract_Tracker__Share> getContractTrackerSharesToInsert() {
//        List<EUR_CRM_Contract_Tracker__Share> contractTrackerSharesToInsert = this.makeContractTrackerShares();
//        System.debug('\n\n contractTrackerSharesToInsert.size() => ' + JSON.serializePretty(contractTrackerSharesToInsert.size()) + '\n');
//        System.debug('\n\n contractTrackerSharesToInsert => ' + JSON.serializePretty(contractTrackerSharesToInsert) + '\n');
//        return contractTrackerSharesToInsert;
//    }


    /* ========================================================= */
    /*     Interface (sharing to delete)
    /* ========================================================= */
    public List<EUR_CRM_Account__Share> getEUAccountSharesToDelete() {
        this.euAccountIdsToDeleteShare = new Set<Id>();
        this.euAccountSharesToDelete = new List<EUR_CRM_Account__Share>();
        for (EUR_CRM_AccountGroupUser__c groupUser : this.accountGroupUsersToDelete) {
            Id euAccId = groupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c;
            Id uId = groupUser.EUR_CRM_User__c;
            if (this.existEUAccountShareByUserIdByParentId.containsKey(euAccId)) {
                Map<Id, EUR_CRM_Account__Share> shareByUserId = this.existEUAccountShareByUserIdByParentId.get(euAccId);
                if (shareByUserId.containsKey(uId) && shareByUserId.get(uId).Parent.OwnerId != uId) {
                    EUR_CRM_Account__Share share = shareByUserId.get(uId);
                    if (share.RowCause == 'Manual' || share.RowCause == APEX_SHARING_REASON) {
                        this.euAccountIdsToDeleteShare.add(euAccId);
                        this.euAccountSharesToDelete.add(share);
                    }
                }
            }
        }
        System.debug('\n\n this.euAccountIdsToDeleteShare => ' + JSON.serializePretty(this.euAccountIdsToDeleteShare) + '\n');
        System.debug('\n\n this.euAccountSharesToDelete => ' + JSON.serializePretty(this.euAccountSharesToDelete) + '\n');
        return this.euAccountSharesToDelete;
    }

    public List<AccountShare> getAccountSharesToDelete() {
        this.accountIdsToDeleteShare = new Set<Id>();
        this.accountSharesToDelete = new List<AccountShare>();
        for (EUR_CRM_AccountGroupUser__c groupUser : this.accountGroupUsersToDelete) {
            Id euAccId = groupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c;
            Id accId = this.accountIdByEUAccountId.get(euAccId);
            Id uId = groupUser.EUR_CRM_User__c;
            if (this.existAccountShareByUserIdByParentId.containsKey(accId)) {
                Map<Id, AccountShare> shareByUserId = this.existAccountShareByUserIdByParentId.get(accId);
                if (shareByUserId.containsKey(uId) && shareByUserId.get(uId).Account.OwnerId != uId) {
                    AccountShare share = shareByUserId.get(uId);
                    if (share.RowCause == 'Manual') {
                        this.accountIdsToDeleteShare.add(euAccId);
                        this.accountSharesToDelete.add(share);
                    }
                }
            }
        }
        System.debug('\n\n this.accountIdsToDeleteShare => ' + JSON.serializePretty(this.accountIdsToDeleteShare) + '\n');
        System.debug('\n\n this.accountSharesToDelete => ' + JSON.serializePretty(this.accountSharesToDelete) + '\n');
        return this.accountSharesToDelete;
    }

    public List<EUR_CRM_Competitor_Promo_Tracking__Share> getCompetitorPromoTrackingSharesToDelete() {
        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingSharesToDelete = new List<EUR_CRM_Competitor_Promo_Tracking__Share>();
        for (EUR_CRM_AccountGroupUser__c groupUser : this.accountGroupUsersToDelete) {
            Id euAccId = groupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c;
            Id uId = groupUser.EUR_CRM_User__c;
            if (this.existCompetitorPromoTrackingSharesByUserIdByEUAccountId.containsKey(euAccId)) {
                Map<Id, List<EUR_CRM_Competitor_Promo_Tracking__Share>> sharesByUserId = this.existCompetitorPromoTrackingSharesByUserIdByEUAccountId.get(euAccId);
                if (sharesByUserId.containsKey(uId)) {
                    List<EUR_CRM_Competitor_Promo_Tracking__Share> shares = sharesByUserId.get(uId);
                    for (EUR_CRM_Competitor_Promo_Tracking__Share share : shares) {
                        if (share.RowCause == 'Manual' && share.Parent.OwnerId != uId) {
                            competitorPromoTrackingSharesToDelete.add(share);
                        }
                    }
                }
            }
        }
        System.debug('\n\n competitorPromoTrackingSharesToDelete.size() => ' + JSON.serializePretty(competitorPromoTrackingSharesToDelete.size()) + '\n');
        System.debug('\n\n competitorPromoTrackingSharesToDelete => ' + JSON.serializePretty(competitorPromoTrackingSharesToDelete) + '\n');
        return competitorPromoTrackingSharesToDelete;
    }

    public List<EUR_CRM_Brand_Security_Infringement__Share> getBrandSecurityInfringementSharesToDelete() {
        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementSharesToDelete = new List<EUR_CRM_Brand_Security_Infringement__Share>();
        for (EUR_CRM_AccountGroupUser__c groupUser : this.accountGroupUsersToDelete) {
            Id euAccId = groupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c;
            Id uId = groupUser.EUR_CRM_User__c;
            if (this.existBrandSecurityInfringementSharesByUserIdByEUAccountId.containsKey(euAccId)) {
                Map<Id, List<EUR_CRM_Brand_Security_Infringement__Share>> sharesByUserId = this.existBrandSecurityInfringementSharesByUserIdByEUAccountId.get(euAccId);
                if (sharesByUserId.containsKey(uId)) {
                    List<EUR_CRM_Brand_Security_Infringement__Share> shares = sharesByUserId.get(uId);
                    for (EUR_CRM_Brand_Security_Infringement__Share share : shares) {
                        if (share.RowCause == 'Manual' && share.Parent.OwnerId != uId) {
                            brandSecurityInfringementSharesToDelete.add(share);
                        }
                    }
                }
            }
        }
        System.debug('\n\n brandSecurityInfringementSharesToDelete.size() => ' + JSON.serializePretty(brandSecurityInfringementSharesToDelete.size()) + '\n');
        System.debug('\n\n brandSecurityInfringementSharesToDelete => ' + JSON.serializePretty(brandSecurityInfringementSharesToDelete) + '\n');
        return brandSecurityInfringementSharesToDelete;
    }

    public List<EUR_CRM_Visit__Share> getVisitSharesToDelete() {
        List<EUR_CRM_Visit__Share> visitSharesToDelete = new List<EUR_CRM_Visit__Share>();
        for (EUR_CRM_AccountGroupUser__c groupUser : this.accountGroupUsersToDelete) {
            Id euAccId = groupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c;
            Id uId = groupUser.EUR_CRM_User__c;
            if (this.existVisitSharesByUserIdByEUAccountId.containsKey(euAccId)) {
                Map<Id, List<EUR_CRM_Visit__Share>> sharesByUserId = this.existVisitSharesByUserIdByEUAccountId.get(euAccId);
                if (sharesByUserId.containsKey(uId)) {
                    List<EUR_CRM_Visit__Share> shares = sharesByUserId.get(uId);
                    for (EUR_CRM_Visit__Share share : shares) {
                        if (share.RowCause == 'Manual' && share.Parent.OwnerId != uId) {
                            visitSharesToDelete.add(share);
                        }
                    }
                }
            }
        }
        System.debug('\n\n visitSharesToDelete.size() => ' + JSON.serializePretty(visitSharesToDelete.size()) + '\n');
        System.debug('\n\n visitSharesToDelete => ' + JSON.serializePretty(visitSharesToDelete) + '\n');
        return visitSharesToDelete;
    }

    public List<EUR_CRM_ObjPromo__Share> getObjPromoSharesToDelete() {
        List<EUR_CRM_ObjPromo__Share> objPromoSharesToDelete = new List<EUR_CRM_ObjPromo__Share>();
        for (EUR_CRM_AccountGroupUser__c groupUser : this.accountGroupUsersToDelete) {
            Id euAccId = groupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c;
            Id uId = groupUser.EUR_CRM_User__c;
            if (this.existObjPromoSharesByUserIdByEUAccountId.containsKey(euAccId)) {
                Map<Id, List<EUR_CRM_ObjPromo__Share>> sharesByUserId = this.existObjPromoSharesByUserIdByEUAccountId.get(euAccId);
                if (sharesByUserId.containsKey(uId)) {
                    List<EUR_CRM_ObjPromo__Share> shares = sharesByUserId.get(uId);
                    for (EUR_CRM_ObjPromo__Share share : shares) {
                        if (share.RowCause == 'Manual' && share.Parent.OwnerId != uId) {
                            objPromoSharesToDelete.add(share);
                        }
                    }
                }
            }
        }
        System.debug('\n\n objPromoSharesToDelete.size() => ' + JSON.serializePretty(objPromoSharesToDelete.size()) + '\n');
        System.debug('\n\n objPromoSharesToDelete => ' + JSON.serializePretty(objPromoSharesToDelete) + '\n');
        return objPromoSharesToDelete;
    }

    public List<EUR_CRM_GB_Objective__Share> getObjectiveSharesToDelete() {
        List<EUR_CRM_GB_Objective__Share> objectiveSharesToDelete = new List<EUR_CRM_GB_Objective__Share>();
        for (EUR_CRM_AccountGroupUser__c groupUser : this.accountGroupUsersToDelete) {
            Id euAccId = groupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c;
            Id uId = groupUser.EUR_CRM_User__c;
            if (this.existObjectiveSharesByUserIdByEUAccountId.containsKey(euAccId)) {
                Map<Id, List<EUR_CRM_GB_Objective__Share>> sharesByUserId = this.existObjectiveSharesByUserIdByEUAccountId.get(euAccId);
                if (sharesByUserId.containsKey(uId)) {
                    List<EUR_CRM_GB_Objective__Share> shares = sharesByUserId.get(uId);
                    for (EUR_CRM_GB_Objective__Share share : shares) {
                        if (share.RowCause == 'Manual' && share.Parent.OwnerId != uId) {
                            objectiveSharesToDelete.add(share);
                        }
                    }
                }
            }
        }
        System.debug('\n\n objectiveSharesToDelete.size() => ' + JSON.serializePretty(objectiveSharesToDelete.size()) + '\n');
        System.debug('\n\n objectiveSharesToDelete => ' + JSON.serializePretty(objectiveSharesToDelete) + '\n');
        return objectiveSharesToDelete;
    }

    public List<EUR_CRM_Contract_Tracker__Share> getContractTrackerSharesToDelete() {
        List<EUR_CRM_Contract_Tracker__Share> contractTrackerSharesToDelete = new List<EUR_CRM_Contract_Tracker__Share>();
        for (EUR_CRM_AccountGroupUser__c groupUser : this.accountGroupUsersToDelete) {
            Id euAccId = groupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c;
            Id uId = groupUser.EUR_CRM_User__c;
            if (this.existContractTrackerSharesByUserIdByEUAccountId.containsKey(euAccId)) {
                Map<Id, List<EUR_CRM_Contract_Tracker__Share>> sharesByUserId = this.existContractTrackerSharesByUserIdByEUAccountId.get(euAccId);
                if (sharesByUserId.containsKey(uId)) {
                    List<EUR_CRM_Contract_Tracker__Share> shares = sharesByUserId.get(uId);
                    for (EUR_CRM_Contract_Tracker__Share share : shares) {
                        if (share.RowCause == 'Manual' && share.Parent.OwnerId != uId) {
                            contractTrackerSharesToDelete.add(share);
                        }
                    }
                }
            }
        }
        System.debug('\n\n contractTrackerSharesToDelete.size() => ' + JSON.serializePretty(contractTrackerSharesToDelete.size()) + '\n');
        System.debug('\n\n contractTrackerSharesToDelete => ' + JSON.serializePretty(contractTrackerSharesToDelete) + '\n');
        return contractTrackerSharesToDelete;
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void sortAccountGroupUserByStatus() {
        this.accountGroupUsersNew = new List<EUR_CRM_AccountGroupUser__c>();
        this.accountGroupUsersToDelete = new List<EUR_CRM_AccountGroupUser__c>();
        this.accountGroupUsersShared = new List<EUR_CRM_AccountGroupUser__c>();

        for (EUR_CRM_AccountGroupUser__c groupUser : this.accountGroupUsers) {
            if (groupUser.EUR_CRM_Status__c.equalsIgnoreCase(NEW_STATUS)) {
                this.accountGroupUsersNew.add(groupUser);
            } else if (groupUser.EUR_CRM_Status__c.equalsIgnoreCase(TO_DELETE_STATUS)) {
                this.accountGroupUsersToDelete.add(groupUser);
            } else if (groupUser.EUR_CRM_Status__c.equalsIgnoreCase(RECORD_SHARED)) {
                this.accountGroupUsersShared.add(groupUser);
            }
        }
    }

    /* ========================================================= */
    /*     Configuration
    /* ========================================================= */
    private void configureAccessLevelByUserIdByAccountId() {
        this.accessLevelByUserIdByEUAccountId = new Map<Id, Map<Id, String>>();
        if (!this.accountGroupUsersNew.isEmpty()) {
            configureAccessLevelByUserIdByAccountId(this.accountGroupUsersNew);
        } else if (!this.accountGroupUsersShared.isEmpty()) {
            configureAccessLevelByUserIdByAccountId(this.accountGroupUsersShared);
        }
        System.debug('\n this.accessLevelByUserIdByEUAccountId.size() => ' + this.accessLevelByUserIdByEUAccountId.size() + '\n');
        System.debug('\n this.accessLevelByUserIdByEUAccountId => ' + JSON.serializePretty(this.accessLevelByUserIdByEUAccountId) + '\n');
    }

    private void configureAccessLevelByUserIdByAccountId(List<EUR_CRM_AccountGroupUser__c> accountGroupUsers) {
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : accountGroupUsers) {
            Id accountId = accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c;
            Id userId = accountGroupUser.EUR_CRM_User__c;

            if (this.accessLevelByUserIdByEUAccountId.containsKey(accountId)) {
                this.accessLevelByUserIdByEUAccountId.get(accountId).put(userId, accountGroupUser.EUR_CRM_AccessLevel__c);
            } else {
                this.accessLevelByUserIdByEUAccountId.put(accountId, new Map<Id, String>{
                        userId => accountGroupUser.EUR_CRM_AccessLevel__c
                });
            }
        }
    }

    private void configureUserIdsByEUAccountIdToSharing() {
        this.userIdsByEUAccountId = new Map<Id, Set<Id>>();
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : this.accountGroupUsers) {
            if (this.userIdsByEUAccountId.containsKey(accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c)) {
                this.userIdsByEUAccountId.get(accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c).add(accountGroupUser.EUR_CRM_User__c);
            } else {
                this.userIdsByEUAccountId.put(accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c, new Set<Id>{
                        accountGroupUser.EUR_CRM_User__c
                });
            }
        }
        System.debug('\n\n this.userIdsByEUAccountId => ' + JSON.serializePretty(this.userIdsByEUAccountId) + '\n');

        this.userIdsToShare = this.collectUserIdToShare(this.userIdsByEUAccountId);
        System.debug('\n\n this.userIdsToShare => ' + JSON.serializePretty(this.userIdsToShare) + '\n');
    }

    private void configureUserIdsByAccountIdToSharing() {
        this.accountIdByEUAccountId = this.configureAccountIdByEUAccountId();
        System.debug('\n\n accountIdByEUAccountId => ' + JSON.serializePretty(accountIdByEUAccountId) + '\n');

        this.userIdsByAccountId = new Map<Id, Set<Id>>();
        for (EUR_CRM_AccountGroupUser__c accountGroupUser : this.accountGroupUsers) {
            if (this.accountIdByEUAccountId.containsKey(accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c)) {
                Id accId = this.accountIdByEUAccountId.get(accountGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c);
                if (this.userIdsByAccountId.containsKey(accId)) {
                    this.userIdsByAccountId.get(accId).add(accountGroupUser.EUR_CRM_User__c);
                } else {
                    this.userIdsByAccountId.put(accId, new Set<Id>{
                            accountGroupUser.EUR_CRM_User__c
                    });
                }
            }
        }
        System.debug('\n\n this.userIdsByAccountId => ' + JSON.serializePretty(this.userIdsByAccountId) + '\n');
    }

    private Map<Id, Id> configureAccountIdByEUAccountId() {
        List<EUR_CRM_Account_Link__c> accountLinks = selectAccountLinks();
        Map<Id, Id> accountIdBuEUAccountId = new Map<Id, Id>();
        for (EUR_CRM_Account_Link__c link : accountLinks) {
            accountIdBuEUAccountId.put(link.EUR_CRM_EU_Account__c, link.EUR_CRM_Standard_Account__c);
        }
        return accountIdBuEUAccountId;
    }

    private void configureAccountIdsByCountyCode() {
        accountIdsByCountryCode = new Map<String, Set<Id>>();
        for (EUR_CRM_AccountGroupUser__c accGroupUser : accountGroupUsers) {
            String countryCode = accGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Country_Code__c;
            if (accountIdsByCountryCode.containsKey(countryCode)) {
                accountIdsByCountryCode.get(countryCode).add(accGroupUser.EUR_CRM_AccountGroup__r.EUR_CRM_Account__c);
            } else if (countryCode != null) {
                accountIdsByCountryCode.put(countryCode, new Set<Id>{
                        accGroupUser.EUR_CRM_AccountGroup__r
                                .EUR_CRM_Account__c
                });
            }
        }
        System.debug('\n\n accountIdsByCountryCode => ' + JSON.serializePretty(accountIdsByCountryCode) + '\n');
    }


    /* ========================================================= */
    /*     Initialization of exist data
    /* ========================================================= */
    private void initializeExistsSharing() {
        this.initExistEUAccountShareByUserIdByParentId();
        this.initExistAccountShareByUserIdByAccountId();

        this.initExistVisitShareByUserIdByParentId();
        this.initExistObjectiveShareByUserIdByParentId();
        this.initExistCompetitorPromoTrackingShareByUserIdByParentId();
        this.initExistContractTrackerShareByUserIdByParentId();
        this.initExistBrandSecurityInfringementShareByUserIdByParentId();
        this.initExistContractAuditShareByUserIdByParentId();
        this.initExistVisitActionShareByUserIdByParentId();

        this.initExistObjPromoShareByUserIdByParentId();
    }

    private void initExistEUAccountShareByUserIdByParentId() {
        List<EUR_CRM_Account__Share> existEUAccountShares = this.selectEUAccountShares();
        System.debug('\n\n existEUAccountShares => ' + JSON.serializePretty(existEUAccountShares) + '\n');

        this.existEUAccountShareByUserIdByParentId = new Map<Id, Map<Id, EUR_CRM_Account__Share>>();
        for (EUR_CRM_Account__Share share : existEUAccountShares) {
            if (this.existEUAccountShareByUserIdByParentId.containsKey(share.ParentId)) {
                this.existEUAccountShareByUserIdByParentId.get(share.ParentId).put(share.UserOrGroupId, share);
            } else {
                this.existEUAccountShareByUserIdByParentId.put(share.ParentId, new Map<Id, EUR_CRM_Account__Share>{
                        share.UserOrGroupId => share
                });
            }
        }
        System.debug('\n\n this.existEUAccountShareByUserIdByParentId => ' + JSON.serializePretty(this.existEUAccountShareByUserIdByParentId) + '\n');
    }

    private void initExistAccountShareByUserIdByAccountId() {
        List<AccountShare> existAccountShares = this.selectAccountShares();
        System.debug('\n\n existAccountShares => ' + JSON.serializePretty(existAccountShares) + '\n');

        this.existAccountShareByUserIdByParentId = new Map<Id, Map<Id, AccountShare>>();
        for (AccountShare share : existAccountShares) {
            if (this.existAccountShareByUserIdByParentId.containsKey(share.AccountId)) {
                this.existAccountShareByUserIdByParentId.get(share.AccountId).put(share.UserOrGroupId, share);
            } else {
                this.existAccountShareByUserIdByParentId.put(share.AccountId, new Map<Id, AccountShare>{
                        share.UserOrGroupId => share
                });
            }
        }
        System.debug('\n\n this.existAccountShareByUserIdByParentId => ' + JSON.serializePretty(this.existAccountShareByUserIdByParentId) + '\n');
    }

    private void initExistContractAuditShareByUserIdByParentId() {
        List<EUR_CRM_Contract_Audit__Share> contractAuditShares = this.selectContractAuditShares();
        System.debug('\n\n contractAuditShares => ' + JSON.serializePretty(contractAuditShares) + '\n');

        this.existContractAuditSharesByUserIdByParentId = new Map<Id, Map<Id, List<EUR_CRM_Contract_Audit__Share>>>();
        this.existContractAuditSharesByUserIdByEUAccountId = new Map<Id, Map<Id, List<EUR_CRM_Contract_Audit__Share>>>();
        for (EUR_CRM_Contract_Audit__Share share : contractAuditShares) {
            Id pId = share.ParentId;
            Id uId = share.UserOrGroupId;
            Id accId = share.Parent.EUR_CRM_Contract__r.EUR_CRM_Account__c;
            if (this.existContractAuditSharesByUserIdByParentId.containsKey(pId)) {
                if (this.existContractAuditSharesByUserIdByParentId.get(pId).containsKey(uId)) {
                    this.existContractAuditSharesByUserIdByParentId.get(pId).get(uId).add(share);
                } else {
                    this.existContractAuditSharesByUserIdByParentId.get(pId).put(uId, new List<EUR_CRM_Contract_Audit__Share>{
                            share
                    });
                }
            } else {
                this.existContractAuditSharesByUserIdByParentId.put(pId, new Map<Id, List<EUR_CRM_Contract_Audit__Share>>{
                        uId => new List<EUR_CRM_Contract_Audit__Share>{
                                share
                        }
                });
            }

            if (this.existContractAuditSharesByUserIdByEUAccountId.containsKey(accId)) {
                if (this.existContractAuditSharesByUserIdByEUAccountId.get(accId).containsKey(uId)) {
                    this.existContractAuditSharesByUserIdByEUAccountId.get(accId).get(uId).add(share);
                } else {
                    this.existContractAuditSharesByUserIdByEUAccountId.get(accId).put(uId, new List<EUR_CRM_Contract_Audit__Share>{
                            share
                    });
                }
            } else {
                this.existContractAuditSharesByUserIdByEUAccountId.put(accId, new Map<Id, List<EUR_CRM_Contract_Audit__Share>>{
                        uId => new List<EUR_CRM_Contract_Audit__Share>{
                                share
                        }
                });
            }
        }
        System.debug('\n\n this.existContractAuditSharesByUserIdByParentId => ' + JSON.serializePretty(this
                .existContractAuditSharesByUserIdByParentId) + '\n');
        System.debug('\n\n this.existContractAuditSharesByUserIdByEUAccountId => ' + JSON.serializePretty(this
                .existContractAuditSharesByUserIdByEUAccountId) + '\n');
    }

    private void initExistVisitActionShareByUserIdByParentId() {
        List<EUR_CRM_Visit_Action__Share> visitActionShares = this.selectVisitActionShares();
        System.debug('\n\n visitActionShares => ' + JSON.serializePretty(visitActionShares) + '\n');

        this.existVisitActionSharesByUserIdByParentId = new Map<Id, Map<Id, List<EUR_CRM_Visit_Action__Share>>>();
        this.existVisitActionSharesByUserIdByEUAccountId = new Map<Id, Map<Id, List<EUR_CRM_Visit_Action__Share>>>();
        for (EUR_CRM_Visit_Action__Share share : visitActionShares) {
            Id pId = share.ParentId;
            Id uId = share.UserOrGroupId;
            Id accId = share.Parent.EUR_CRM_Account__c;
            if (this.existVisitActionSharesByUserIdByParentId.containsKey(pId)) {
                if (this.existVisitActionSharesByUserIdByParentId.get(pId).containsKey(uId)) {
                    this.existVisitActionSharesByUserIdByParentId.get(pId).get(uId).add(share);
                } else {
                    this.existVisitActionSharesByUserIdByParentId.get(pId).put(uId, new List<EUR_CRM_Visit_Action__Share>{
                            share
                    });
                }
            } else {
                this.existVisitActionSharesByUserIdByParentId.put(pId, new Map<Id, List<EUR_CRM_Visit_Action__Share>>{
                        uId => new List<EUR_CRM_Visit_Action__Share>{
                                share
                        }
                });
            }

            if (this.existVisitActionSharesByUserIdByEUAccountId.containsKey(accId)) {
                if (this.existVisitActionSharesByUserIdByEUAccountId.get(accId).containsKey(uId)) {
                    this.existVisitActionSharesByUserIdByEUAccountId.get(accId).get(uId).add(share);
                } else {
                    this.existVisitActionSharesByUserIdByEUAccountId.get(accId).put(uId, new List<EUR_CRM_Visit_Action__Share>{
                            share
                    });
                }
            } else {
                this.existVisitActionSharesByUserIdByEUAccountId.put(accId, new Map<Id, List<EUR_CRM_Visit_Action__Share>>{
                        uId => new List<EUR_CRM_Visit_Action__Share>{
                                share
                        }
                });
            }
        }
        System.debug('\n\n this.existVisitActionSharesByUserIdByParentId => ' + JSON.serializePretty(this
                .existVisitActionSharesByUserIdByParentId) + '\n');
        System.debug('\n\n this.existVisitActionSharesByUserIdByEUAccountId => ' + JSON.serializePretty(this
                .existVisitActionSharesByUserIdByEUAccountId) + '\n');
    }


    private void initExistCompetitorPromoTrackingShareByUserIdByParentId() {
        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = this.selectCompetitorPromoTrackingShares();
        System.debug('\n\n competitorPromoTrackingShares => ' + JSON.serializePretty(competitorPromoTrackingShares) + '\n');

        this.existCompetitorPromoTrackingSharesByUserIdByParentId = new Map<Id, Map<Id, List<EUR_CRM_Competitor_Promo_Tracking__Share>>>();
        this.existCompetitorPromoTrackingSharesByUserIdByEUAccountId = new Map<Id, Map<Id, List<EUR_CRM_Competitor_Promo_Tracking__Share>>>();
        for (EUR_CRM_Competitor_Promo_Tracking__Share share : competitorPromoTrackingShares) {
            Id pId = share.ParentId;
            Id uId = share.UserOrGroupId;
            Id accId = share.Parent.EUR_CRM_Account_Name__c;
            if (this.existCompetitorPromoTrackingSharesByUserIdByParentId.containsKey(pId)) {
                if (this.existCompetitorPromoTrackingSharesByUserIdByParentId.get(pId).containsKey(uId)) {
                    this.existCompetitorPromoTrackingSharesByUserIdByParentId.get(pId).get(uId).add(share);
                } else {
                    this.existCompetitorPromoTrackingSharesByUserIdByParentId.get(pId).put(uId, new List<EUR_CRM_Competitor_Promo_Tracking__Share>{
                            share
                    });
                }
            } else {
                this.existCompetitorPromoTrackingSharesByUserIdByParentId.put(pId, new Map<Id, List<EUR_CRM_Competitor_Promo_Tracking__Share>>{
                        uId => new List<EUR_CRM_Competitor_Promo_Tracking__Share>{
                                share
                        }
                });
            }

            if (this.existCompetitorPromoTrackingSharesByUserIdByEUAccountId.containsKey(accId)) {
                if (this.existCompetitorPromoTrackingSharesByUserIdByEUAccountId.get(accId).containsKey(uId)) {
                    this.existCompetitorPromoTrackingSharesByUserIdByEUAccountId.get(accId).get(uId).add(share);
                } else {
                    this.existCompetitorPromoTrackingSharesByUserIdByEUAccountId.get(accId).put(uId, new List<EUR_CRM_Competitor_Promo_Tracking__Share>{
                            share
                    });
                }
            } else {
                this.existCompetitorPromoTrackingSharesByUserIdByEUAccountId.put(accId, new Map<Id, List<EUR_CRM_Competitor_Promo_Tracking__Share>>{
                        uId => new List<EUR_CRM_Competitor_Promo_Tracking__Share>{
                                share
                        }
                });
            }
        }
        System.debug('\n\n this.existCompetitorPromoTrackingSharesByUserIdByParentId => ' + JSON.serializePretty(this.existCompetitorPromoTrackingSharesByUserIdByParentId) + '\n');
        System.debug('\n\n this.existCompetitorPromoTrackingSharesByUserIdByEUAccountId => ' + JSON.serializePretty(this.existCompetitorPromoTrackingSharesByUserIdByEUAccountId) + '\n');
    }

    private void initExistBrandSecurityInfringementShareByUserIdByParentId() {
        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = this.selectBrandSecurityInfringementShares();
        System.debug('\n\n brandSecurityInfringementShares => ' + JSON.serializePretty(brandSecurityInfringementShares) + '\n');

        this.existBrandSecurityInfringementSharesByUserIdByParentId = new Map<Id, Map<Id, List<EUR_CRM_Brand_Security_Infringement__Share>>>();
        this.existBrandSecurityInfringementSharesByUserIdByEUAccountId = new Map<Id, Map<Id, List<EUR_CRM_Brand_Security_Infringement__Share>>>();
        for (EUR_CRM_Brand_Security_Infringement__Share share : brandSecurityInfringementShares) {
            Id pId = share.ParentId;
            Id uId = share.UserOrGroupId;
            Id accId = share.Parent.EUR_CRM_Outlet_Name__c;
            if (this.existBrandSecurityInfringementSharesByUserIdByParentId.containsKey(pId)) {
                if (this.existBrandSecurityInfringementSharesByUserIdByParentId.get(pId).containsKey(uId)) {
                    this.existBrandSecurityInfringementSharesByUserIdByParentId.get(pId).get(uId).add(share);
                } else {
                    this.existBrandSecurityInfringementSharesByUserIdByParentId.get(pId).put(uId, new List<EUR_CRM_Brand_Security_Infringement__Share>{
                            share
                    });
                }
            } else {
                this.existBrandSecurityInfringementSharesByUserIdByParentId.put(pId, new Map<Id, List<EUR_CRM_Brand_Security_Infringement__Share>>{
                        uId => new List<EUR_CRM_Brand_Security_Infringement__Share>{
                                share
                        }
                });
            }

            if (this.existBrandSecurityInfringementSharesByUserIdByEUAccountId.containsKey(accId)) {
                if (this.existBrandSecurityInfringementSharesByUserIdByEUAccountId.get(accId).containsKey(uId)) {
                    this.existBrandSecurityInfringementSharesByUserIdByEUAccountId.get(accId).get(uId).add(share);
                } else {
                    this.existBrandSecurityInfringementSharesByUserIdByEUAccountId.get(accId).put(uId, new List<EUR_CRM_Brand_Security_Infringement__Share>{
                            share
                    });
                }
            } else {
                this.existBrandSecurityInfringementSharesByUserIdByEUAccountId.put(accId, new Map<Id, List<EUR_CRM_Brand_Security_Infringement__Share>>{
                        uId => new List<EUR_CRM_Brand_Security_Infringement__Share>{
                                share
                        }
                });
            }
        }
        System.debug('\n\n this.existBrandSecurityInfringementSharesByUserIdByParentId => ' + JSON.serializePretty(this.existBrandSecurityInfringementSharesByUserIdByParentId) + '\n');
        System.debug('\n\n this.existBrandSecurityInfringementSharesByUserIdByEUAccountId => ' + JSON.serializePretty(this.existBrandSecurityInfringementSharesByUserIdByEUAccountId) + '\n');
    }

    private void initExistVisitShareByUserIdByParentId() {
        List<EUR_CRM_Visit__Share> visitShares = this.selectVisitShares();
        System.debug('\n\n visitShares => ' + JSON.serializePretty(visitShares) + '\n');

        this.existVisitSharesByUserIdByParentId = new Map<Id, Map<Id, List<EUR_CRM_Visit__Share>>>();
        this.existVisitSharesByUserIdByEUAccountId = new Map<Id, Map<Id, List<EUR_CRM_Visit__Share>>>();
        for (EUR_CRM_Visit__Share share : visitShares) {
            Id pId = share.ParentId;
            Id uId = share.UserOrGroupId;
            Id accId = share.Parent.EUR_CRM_Account__c;
            if (this.existVisitSharesByUserIdByParentId.containsKey(pId)) {
                if (this.existVisitSharesByUserIdByParentId.get(pId).containsKey(uId)) {
                    this.existVisitSharesByUserIdByParentId.get(pId).get(uId).add(share);
                } else {
                    this.existVisitSharesByUserIdByParentId.get(pId).put(uId, new List<EUR_CRM_Visit__Share>{
                            share
                    });
                }

            } else {
                this.existVisitSharesByUserIdByParentId.put(pId, new Map<Id, List<EUR_CRM_Visit__Share>>{
                        uId => new List<EUR_CRM_Visit__Share>{
                                share
                        }
                });
            }

            if (this.existVisitSharesByUserIdByEUAccountId.containsKey(accId)) {
                if (this.existVisitSharesByUserIdByEUAccountId.get(accId).containsKey(uId)) {
                    this.existVisitSharesByUserIdByEUAccountId.get(accId).get(uId).add(share);
                } else {
                    this.existVisitSharesByUserIdByEUAccountId.get(accId).put(uId, new List<EUR_CRM_Visit__Share>{
                            share
                    });
                }
            } else {
                this.existVisitSharesByUserIdByEUAccountId.put(accId, new Map<Id, List<EUR_CRM_Visit__Share>>{
                        uId => new List<EUR_CRM_Visit__Share>{
                                share
                        }
                });
            }
        }
        System.debug('\n\n this.existVisitSharesByUserIdByParentId => ' + JSON.serializePretty(this.existVisitSharesByUserIdByParentId) + '\n');
        System.debug('\n\n this.existVisitSharesByUserIdByEUAccountId => ' + JSON.serializePretty(this.existVisitSharesByUserIdByEUAccountId) + '\n');
    }

    private void initExistObjPromoShareByUserIdByParentId() {
        List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappings = this.selectObjPromoAccountMappings();
        System.debug('\n\n objPromoAccountMappings => ' + JSON.serializePretty(objPromoAccountMappings) + '\n');

        this.objPromoIdsToShareByEUAccountId = this.getObjPromoIdsByAccountId(objPromoAccountMappings);
        System.debug('\n\n this.objPromoIdsToShareByEUAccountId => ' + JSON.serializePretty(this.objPromoIdsToShareByEUAccountId) + '\n');

        List<EUR_CRM_ObjPromo__Share> objPromoShares = this.selectObjPromoShares(this.collectObjPromoIds());
        System.debug('\n\n objPromoShares => ' + JSON.serializePretty(objPromoShares) + '\n');

        this.existObjPromoSharesByUserIdByParentId = new Map<Id, Map<Id, List<EUR_CRM_ObjPromo__Share>>>();
        this.existObjPromoSharesByUserIdByEUAccountId = new Map<Id, Map<Id, List<EUR_CRM_ObjPromo__Share>>>();
        for (EUR_CRM_ObjPromo__Share share : objPromoShares) {
            Id pId = share.ParentId;
            Id uId = share.UserOrGroupId;
            if (this.existObjPromoSharesByUserIdByParentId.containsKey(pId)) {
                if (this.existObjPromoSharesByUserIdByParentId.get(pId).containsKey(uId)) {
                    this.existObjPromoSharesByUserIdByParentId.get(pId).get(uId).add(share);
                } else {
                    this.existObjPromoSharesByUserIdByParentId.get(pId).put(uId, new List<EUR_CRM_ObjPromo__Share>{
                            share
                    });
                }
            } else {
                this.existObjPromoSharesByUserIdByParentId.put(pId, new Map<Id, List<EUR_CRM_ObjPromo__Share>>{
                        uId => new List<EUR_CRM_ObjPromo__Share>{
                                share
                        }
                });
            }
        }

        for (Id accId : this.objPromoIdsToShareByEUAccountId.keySet()) {
            for (Id objPromoId : this.objPromoIdsToShareByEUAccountId.get(accId)) {
                if (this.existObjPromoSharesByUserIdByParentId.containsKey(objPromoId)) {
                    for (List<EUR_CRM_ObjPromo__Share> shares : this.existObjPromoSharesByUserIdByParentId.get(objPromoId).values()) {
                        for (EUR_CRM_ObjPromo__Share share : shares) {
                            Id uId = share.UserOrGroupId;
                            if (this.existObjPromoSharesByUserIdByEUAccountId.containsKey(accId)) {
                                if (this.existObjPromoSharesByUserIdByEUAccountId.get(accId).containsKey(uId)) {
                                    this.existObjPromoSharesByUserIdByEUAccountId.get(accId).get(uId).add(share);
                                } else {
                                    this.existObjPromoSharesByUserIdByEUAccountId.get(accId).put(uId, new List<EUR_CRM_ObjPromo__Share>{
                                            share
                                    });
                                }
                            } else {
                                this.existObjPromoSharesByUserIdByEUAccountId.put(accId, new Map<Id, List<EUR_CRM_ObjPromo__Share>>{
                                        uId => new List<EUR_CRM_ObjPromo__Share>{
                                                share
                                        }
                                });
                            }
                        }
                    }
                }
            }
        }

        System.debug('\n\n this.existObjPromoSharesByUserIdByParentId => ' + JSON.serializePretty(this.existObjPromoSharesByUserIdByParentId) + '\n');
        System.debug('\n\n this.existObjPromoSharesByUserIdByEUAccountId => ' + JSON.serializePretty(this.existObjPromoSharesByUserIdByEUAccountId) + '\n');
    }

    private void initExistObjectiveShareByUserIdByParentId() {
        List<EUR_CRM_GB_Objective__Share> objectiveShares = this.selectObjectiveShares();
        System.debug('\n\n objectiveShares => ' + JSON.serializePretty(objectiveShares) + '\n');

        this.existObjectiveSharesByUserIdByParentId = new Map<Id, Map<Id, List<EUR_CRM_GB_Objective__Share>>>();
        this.existObjectiveSharesByUserIdByEUAccountId = new Map<Id, Map<Id, List<EUR_CRM_GB_Objective__Share>>>();
        for (EUR_CRM_GB_Objective__Share share : objectiveShares) {
            Id pId = share.ParentId;
            Id uId = share.UserOrGroupId;
            Id accId = share.Parent.EUR_CRM_Account__c;
            if (this.existObjectiveSharesByUserIdByParentId.containsKey(pId)) {
                if (this.existObjectiveSharesByUserIdByParentId.get(pId).containsKey(uId)) {
                    this.existObjectiveSharesByUserIdByParentId.get(pId).get(uId).add(share);
                } else {
                    this.existObjectiveSharesByUserIdByParentId.get(pId).put(uId, new List<EUR_CRM_GB_Objective__Share>{
                            share
                    });
                }
            } else {
                this.existObjectiveSharesByUserIdByParentId.put(pId, new Map<Id, List<EUR_CRM_GB_Objective__Share>>{
                        uId => new List<EUR_CRM_GB_Objective__Share>{
                                share
                        }
                });
            }

            if (this.existObjectiveSharesByUserIdByEUAccountId.containsKey(accId)) {
                if (this.existObjectiveSharesByUserIdByEUAccountId.get(accId).containsKey(uId)) {
                    this.existObjectiveSharesByUserIdByEUAccountId.get(accId).get(uId).add(share);
                } else {
                    this.existObjectiveSharesByUserIdByEUAccountId.get(accId).put(uId, new List<EUR_CRM_GB_Objective__Share>{
                            share
                    });
                }
            } else {
                this.existObjectiveSharesByUserIdByEUAccountId.put(accId, new Map<Id, List<EUR_CRM_GB_Objective__Share>>{
                        uId => new List<EUR_CRM_GB_Objective__Share>{
                                share
                        }
                });
            }
        }
        System.debug('\n\n this.existObjectiveSharesByUserIdByParentId => ' + JSON.serializePretty(this.existObjectiveSharesByUserIdByParentId) + '\n');
        System.debug('\n\n this.existObjectiveSharesByUserIdByEUAccountId => ' + JSON.serializePretty(this.existObjectiveSharesByUserIdByParentId) + '\n');
    }

    private void initExistContractTrackerShareByUserIdByParentId() {
        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = this.selectContractTrackerShares();
        System.debug('\n\n contractTrackerShares => ' + JSON.serializePretty(contractTrackerShares) + '\n');

        this.existContractTrackerSharesByUserIdByParentId = new Map<Id, Map<Id, List<EUR_CRM_Contract_Tracker__Share>>>();
        this.existContractTrackerSharesByUserIdByEUAccountId = new Map<Id, Map<Id, List<EUR_CRM_Contract_Tracker__Share>>>();
        for (EUR_CRM_Contract_Tracker__Share share : contractTrackerShares) {
            Id pId = share.ParentId;
            Id uId = share.UserOrGroupId;
            Id accId = share.Parent.EUR_CRM_Account__c;
            if (this.existContractTrackerSharesByUserIdByParentId.containsKey(pId)) {
                if (this.existContractTrackerSharesByUserIdByParentId.get(pId).containsKey(uId)) {
                    this.existContractTrackerSharesByUserIdByParentId.get(pId).get(uId).add(share);
                } else {
                    this.existContractTrackerSharesByUserIdByParentId.get(pId).put(uId, new List<EUR_CRM_Contract_Tracker__Share>{
                            share
                    });
                }
            } else {
                this.existContractTrackerSharesByUserIdByParentId.put(pId, new Map<Id, List<EUR_CRM_Contract_Tracker__Share>>{
                        uId => new List<EUR_CRM_Contract_Tracker__Share>{
                                share
                        }
                });
            }

            if (this.existContractTrackerSharesByUserIdByEUAccountId.containsKey(accId)) {
                if (this.existContractTrackerSharesByUserIdByEUAccountId.get(accId).containsKey(uId)) {
                    this.existContractTrackerSharesByUserIdByEUAccountId.get(accId).get(uId).add(share);
                } else {
                    this.existContractTrackerSharesByUserIdByEUAccountId.get(accId).put(uId, new List<EUR_CRM_Contract_Tracker__Share>{
                            share
                    });
                }
            } else {
                this.existContractTrackerSharesByUserIdByEUAccountId.put(accId, new Map<Id, List<EUR_CRM_Contract_Tracker__Share>>{
                        uId => new List<EUR_CRM_Contract_Tracker__Share>{
                                share
                        }
                });
            }
        }
        System.debug('\n\n this.existContractTrackerSharesByUserIdByParentId => ' + JSON.serializePretty(this.existContractTrackerSharesByUserIdByParentId) + '\n');
        System.debug('\n\n this.existContractTrackerSharesByUserIdByEUAccountId => ' + JSON.serializePretty(this.existContractTrackerSharesByUserIdByEUAccountId) + '\n');
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private Map<Id, Set<Id>> getUserIdsBySharedEUAccountId() {
        Map<Id, Set<Id>> userIdsBySharedEUAccountId = new Map<Id, Set<Id>>();
        for (Id euAccId : this.existEUAccountShareByUserIdByParentId.keySet()) {
            for (EUR_CRM_Account__Share share : this.existEUAccountShareByUserIdByParentId.get(euAccId).values()) {
                if (userIdsBySharedEUAccountId.containsKey(share.ParentId)) {
                    userIdsBySharedEUAccountId.get(share.ParentId).add(share.UserOrGroupId);
                } else {
                    userIdsBySharedEUAccountId.put(share.ParentId, new Set<Id>{
                            share.UserOrGroupId
                    });
                }
            }
        }
        return userIdsBySharedEUAccountId;
    }

    private Map<Id, Set<Id>> getUserIdsBySharedAccountId() {
        Map<Id, Set<Id>> userIdsBySharedAccountId = new Map<Id, Set<Id>>();
        for (Id AccId : this.existAccountShareByUserIdByParentId.keySet()) {
            for (AccountShare share : this.existAccountShareByUserIdByParentId.get(AccId).values()) {
                if (userIdsBySharedAccountId.containsKey(share.AccountId)) {
                    userIdsBySharedAccountId.get(share.AccountId).add(share.UserOrGroupId);
                } else {
                    userIdsBySharedAccountId.put(share.AccountId, new Set<Id>{
                            share.UserOrGroupId
                    });
                }
            }
        }

        return userIdsBySharedAccountId;
    }

    private Map<Id, Set<Id>> getObjPromoIdsByAccountId(List<EUR_CRM_ObjPromo_Account_Mapping__c> objPromoAccountMappings) {
        Map<Id, Set<Id>> objPromoIdsByAccountId = new Map<Id, Set<Id>>();
        for (EUR_CRM_ObjPromo_Account_Mapping__c mapping : objPromoAccountMappings) {
            if (objPromoIdsByAccountId.containsKey(mapping.EUR_CRM_Account__c)) {
                objPromoIdsByAccountId.get(mapping.EUR_CRM_Account__c).add(mapping.EUR_CRM_ObjPromo__c);
            } else {
                objPromoIdsByAccountId.put(mapping.EUR_CRM_Account__c, new Set<Id>{
                        mapping.EUR_CRM_ObjPromo__c
                });
            }
        }
        return objPromoIdsByAccountId;
    }


    /* ========================================================= */
    /*     High Level Makers (sharing)
    /* ========================================================= */
    private List<EUR_CRM_Account__Share> makeEUAccountShares() {
        Map<Id, Set<Id>> userIdsBySharedEUAccountId = this.getUserIdsBySharedEUAccountId();
        System.debug('\n\n userIdsBySharedEUAccountId => ' + JSON.serializePretty(userIdsBySharedEUAccountId) + '\n');

        this.euAccountIdsToShare = new Set<Id>();
        List<EUR_CRM_Account__Share> euAccountShares = new List<EUR_CRM_Account__Share>();
        for (Id accId : this.userIdsByEUAccountId.keySet()) {
            for (Id userId : this.userIdsByEUAccountId.get(accId)) {
                if (!userIdsBySharedEUAccountId.containsKey(accId) || !userIdsBySharedEUAccountId.get(accId).contains(userId)) {
                    EUR_CRM_Account__Share share = this.makeEUAccountShare(accId, userId);
                    if (share.AccessLevel == null) {
                        continue;
                    }
                    this.euAccountIdsToShare.add(accId);
                    euAccountShares.add(share);
                }
            }
        }
        return euAccountShares;
    }

    private List<AccountShare> makeAccountShares() {
        Map<Id, Set<Id>> userIdsBySharedAccountId = this.getUserIdsBySharedAccountId();
        System.debug('\n\n userIdsBySharedAccountId => ' + JSON.serializePretty(userIdsBySharedAccountId) + '\n');

        this.accountIdsToShare = new Set<Id>();
        List<AccountShare> accountShares = new List<AccountShare>();
        for (Id euAccId : this.accountIdByEUAccountId.keySet()) {
            for (Id userId : this.userIdsByEUAccountId.get(euAccId)) {
                Id accId = this.accountIdByEUAccountId.get(euAccId);
                if (!userIdsBySharedAccountId.containsKey(accId) || !userIdsBySharedAccountId.get(accId).contains(userId)) {
                    AccountShare share = this.makeAccountShare(euAccId, accId, userId);
                    if (share.AccountAccessLevel == null) {
                        continue;
                    }
                    this.accountIdsToShare.add(accId);
                    accountShares.add(share);
                }
            }
        }
        return accountShares;
    }

    private List<EUR_CRM_Competitor_Promo_Tracking__Share> makeCompetitorPromoTrackingShares() {
        List<EUR_CRM_Competitor_Promo_Tracking__c> competitorPromoTracking = this.getCompetitorPromoTrackingsWithFilter();
        System.debug('\n\n competitorPromoTracking => ' + JSON.serializePretty(competitorPromoTracking) + '\n');

        List<EUR_CRM_Competitor_Promo_Tracking__Share> competitorPromoTrackingShares = new List<EUR_CRM_Competitor_Promo_Tracking__Share>();
        for (EUR_CRM_Competitor_Promo_Tracking__c tracking : competitorPromoTracking) {
            for (Id userId : this.userIdsToShare) {
                if (!this.existCompetitorPromoTrackingSharesByUserIdByParentId.containsKey(tracking.Id) || !this.existCompetitorPromoTrackingSharesByUserIdByParentId.get(tracking.Id).containsKey(userId)) {
                    EUR_CRM_Competitor_Promo_Tracking__Share share = this.makeCompetitorPromoTrackingShare(tracking
                            .Id, userId, tracking.EUR_CRM_Account_Name__c);
                    if (share.AccessLevel == null) {
                        continue;
                    }
                    competitorPromoTrackingShares.add(share);
                }
            }
        }
        System.debug('\n\n competitorPromoTrackingShares size => ' + JSON.serializePretty(competitorPromoTrackingShares.size()) + '\n');
        System.debug('\n\n competitorPromoTrackingShares => ' + JSON.serializePretty(competitorPromoTrackingShares) + '\n');
        return competitorPromoTrackingShares;
    }

    private List<EUR_CRM_Brand_Security_Infringement__Share> makeBrandSecurityInfringementShares() {
        List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityInfringements = this.getBrandSecurityInfringementsWithFilter();
        System.debug('\n\n brandSecurityInfringements => ' + JSON.serializePretty(brandSecurityInfringements) + '\n');

        List<EUR_CRM_Brand_Security_Infringement__Share> brandSecurityInfringementShares = new List<EUR_CRM_Brand_Security_Infringement__Share>();
        for (EUR_CRM_Brand_Security_Infringement__c infringement : brandSecurityInfringements) {
            for (Id userId : this.userIdsToShare) {
                if (!this.existBrandSecurityInfringementSharesByUserIdByParentId.containsKey(infringement.Id) || !this.existBrandSecurityInfringementSharesByUserIdByParentId.get(infringement.Id).containsKey(userId)) {
                    EUR_CRM_Brand_Security_Infringement__Share share = this.makeBrandSecurityInfringementShare(infringement.Id, userId, infringement.EUR_CRM_Outlet_Name__c);
                    if (share.AccessLevel == null) {
                        continue;
                    }
                    brandSecurityInfringementShares.add(share);
                }
            }
        }
        System.debug('\n\n brandSecurityInfringementShares size => ' + JSON.serializePretty(brandSecurityInfringementShares.size()) + '\n');
        System.debug('\n\n brandSecurityInfringementShares => ' + JSON.serializePretty(brandSecurityInfringementShares) + '\n');
        return brandSecurityInfringementShares;
    }

    private List<EUR_CRM_Visit__Share> makeVisitShares() {
        List<EUR_CRM_Visit__c> visits = this.getVisitsWithFilter();
        System.debug('\n\n visits => ' + JSON.serializePretty(visits) + '\n');

        List<EUR_CRM_Visit__Share> visitShares = new List<EUR_CRM_Visit__Share>();
        for (EUR_CRM_Visit__c visit : visits) {
            for (Id userId : this.userIdsToShare) {
                if (!this.existVisitSharesByUserIdByParentId.containsKey(visit.Id) || !this.existVisitSharesByUserIdByParentId.get(visit.Id).containsKey(userId)) {
                    EUR_CRM_Visit__Share share = this.makeVisitShare(visit.Id, userId, visit.EUR_CRM_Account__c);
                    if (share.AccessLevel == null) {
                        continue;
                    }
                    visitShares.add(share);
                }
            }
        }
        System.debug('\n\n visitsShares size => ' + JSON.serializePretty(visitShares.size()) + '\n');
        System.debug('\n\n visitsShares => ' + JSON.serializePretty(visitShares) + '\n');
        return visitShares;
    }
//
//    private List<EUR_CRM_ObjPromo__Share> makeObjPromoShares() {
//        List<EUR_CRM_ObjPromo__Share> objPromoShares = new List<EUR_CRM_ObjPromo__Share>();
//        for (Id accId : this.objPromoIdsToShareByEUAccountId.keySet()) {
//            for (Id objPromoId : this.objPromoIdsToShareByEUAccountId.get(accId)) {
//                if (this.accessLevelByUserIdByEUAccountId.containsKey(accId)) {
//                    Map<Id, String> accessLevelByUserId = this.accessLevelByUserIdByEUAccountId.get(accId);
//                    for (Id userId : accessLevelByUserId.keySet()) {
//                        String accessLevel = accessLevelByUserId.get(userId);
//                        if ( ! this.existObjPromoSharesByUserIdByParentId.containsKey(objPromoId) || ! this.existObjPromoSharesByUserIdByParentId.get(objPromoId).containsKey(userId)) {
//                            objPromoShares.add(this.makeObjPromoShare(objPromoId, userId, accessLevel));
//                        }
//                    }
//                }
//            }
//        }
//        return objPromoShares;
//    }
//
    private List<EUR_CRM_GB_Objective__Share> makeObjectiveShares() {
        List<EUR_CRM_GB_Objective__c> objectives = this.getObjectivesWithFilter();
        System.debug('\n\n objectives => ' + JSON.serializePretty(objectives) + '\n');

        List<EUR_CRM_GB_Objective__Share> objectiveShares = new List<EUR_CRM_GB_Objective__Share>();
        for (EUR_CRM_GB_Objective__c objective : objectives) {
            for (Id userId : this.userIdsToShare) {
                if (!this.existObjectiveSharesByUserIdByParentId.containsKey(objective.Id) || !this.existObjectiveSharesByUserIdByParentId.get(objective.Id).containsKey(userId)) {
                    EUR_CRM_GB_Objective__Share share = this.makeObjectiveShare(objective.Id, userId, objective
                            .EUR_CRM_Account__c);
                    if (share.AccessLevel == null) {
                        continue;
                    }
                    objectiveShares.add(share);
                }
            }
        }
        System.debug('\n\n objectiveShares size => ' + JSON.serializePretty(objectiveShares.size()) + '\n');
        System.debug('\n\n objectiveShares => ' + JSON.serializePretty(objectiveShares) + '\n');
        return objectiveShares;
    }

    private List<EUR_CRM_Contract_Tracker__Share> makeContractTrackerShares() {
        List<EUR_CRM_Contract_Tracker__c> contractTrackers = this.getContractTrackersWithFilter();
        System.debug('\n\n contractTrackers => ' + JSON.serializePretty(contractTrackers) + '\n');

        List<EUR_CRM_Contract_Tracker__Share> contractTrackerShares = new List<EUR_CRM_Contract_Tracker__Share>();
        for (EUR_CRM_Contract_Tracker__c tracker : contractTrackers) {
            for (Id userId : this.userIdsToShare) {
                if (!this.existContractTrackerSharesByUserIdByParentId.containsKey(tracker.Id) || !this.existContractTrackerSharesByUserIdByParentId.get(tracker.Id).containsKey(userId)) {
                    EUR_CRM_Contract_Tracker__Share share = this.makeContractTrackerShare(tracker.Id, userId, tracker
                            .EUR_CRM_Account__c);
                    if (share.AccessLevel == null) {
                        continue;
                    }
                    contractTrackerShares.add(share);
                }
            }
        }
        System.debug('\n\n contractTrackerShares size => ' + JSON.serializePretty(contractTrackerShares.size()) + '\n');
        System.debug('\n\n contractTrackerShares => ' + JSON.serializePretty(contractTrackerShares) + '\n');
        return contractTrackerShares;
    }

    private List<EUR_CRM_Contract_Audit__Share> makeContractAuditShares() {
        List<EUR_CRM_Contract_Audit__c> contractAudits = this.getContractAuditsWithFilter();
        System.debug('\n\n contractAudits => ' + JSON.serializePretty(contractAudits) + '\n');

        List<EUR_CRM_Contract_Audit__Share> contractAuditShares = new List<EUR_CRM_Contract_Audit__Share>();
        for (EUR_CRM_Contract_Audit__c audit : contractAudits) {
            for (Id userId : this.userIdsToShare) {
                if (!this.existContractAuditSharesByUserIdByParentId.containsKey(audit.Id) || !this
                        .existContractAuditSharesByUserIdByParentId.get(audit.Id).containsKey(userId)) {
                    EUR_CRM_Contract_Audit__Share share = this.makeContractAuditShare(audit.Id, userId, audit
                            .EUR_CRM_Contract__r.EUR_CRM_Account__c);
                    if (share.AccessLevel == null) {
                        continue;
                    }
                    contractAuditShares.add(share);
                }
            }
        }
        System.debug('\n\n contractAuditShares size => ' + JSON.serializePretty(contractAuditShares.size()) + '\n');
        System.debug('\n\n contractAuditShares => ' + JSON.serializePretty(contractAuditShares) + '\n');
        return contractAuditShares;
    }

    private List<EUR_CRM_Visit_Action__Share> makeVisitActionShares() {
        List<EUR_CRM_Visit_Action__c> visitActions = this.getVisitActionsWithFilter();
        System.debug('\n\n visitActions => ' + JSON.serializePretty(visitActions) + '\n');

        List<EUR_CRM_Visit_Action__Share> visitActionShares = new List<EUR_CRM_Visit_Action__Share>();
        for (EUR_CRM_Visit_Action__c action : visitActions) {
            for (Id userId : this.userIdsToShare) {
                if (!this.existVisitActionSharesByUserIdByParentId.containsKey(action.Id) || !this
                        .existVisitActionSharesByUserIdByParentId.get(action.Id).containsKey(userId)) {
                    EUR_CRM_Visit_Action__Share share = this.makeVisitActionShare(action.Id, userId, action
                            .EUR_CRM_Account__c);
                    if (share.AccessLevel == null) {
                        continue;
                    }
                    visitActionShares.add(share);
                }
            }
        }
        System.debug('\n\n visitActionShares size => ' + JSON.serializePretty(visitActionShares.size()) + '\n');
        System.debug('\n\n visitActionShares => ' + JSON.serializePretty(visitActionShares) + '\n');
        return visitActionShares;
    }

    /* ========================================================= */
    /*     Helpers with filter for SObject
    /* ========================================================= */
    private List<EUR_CRM_Visit_Action__c> getVisitActionsWithFilter() {
        List<EUR_CRM_Visit_Action__c> visitActionsResult = new List<EUR_CRM_Visit_Action__c>();
        List<CTM_Child_Objects_Filters__mdt> visitFilters = selectMdtFiltersForSObject('EUR_CRM_Visit_Action__c');
        for (String countryCode : accountIdsByCountryCode.keySet()) {
            if (haveFilterForCountry(countryCode, visitFilters)) {
                visitActionsResult.addAll(selectVisitActionsWithFilter(accountIdsByCountryCode.get(countryCode), countryCode));
            } else {
                visitActionsResult.addAll(selectVisitActionByAccountIds(accountIdsByCountryCode.get(countryCode)));
            }
        }
        return visitActionsResult;
    }

    private List<EUR_CRM_Visit__c> getVisitsWithFilter() {
        List<EUR_CRM_Visit__c> visitResult = new List<EUR_CRM_Visit__c>();
        List<CTM_Child_Objects_Filters__mdt> visitFilters = selectMdtFiltersForSObject('EUR_CRM_Visit__c');
        for (String countryCode : accountIdsByCountryCode.keySet()) {
            if (haveFilterForCountry(countryCode, visitFilters)) {
                visitResult.addAll(selectVisitsWithFilter(accountIdsByCountryCode.get(countryCode), countryCode));
            } else {
                visitResult.addAll(selectVisitsByAccountIds(accountIdsByCountryCode.get(countryCode)));
            }
        }
        return visitResult;
    }

    private List<EUR_CRM_GB_Objective__c> getObjectivesWithFilter() {
        List<EUR_CRM_GB_Objective__c> objectivesResult = new List<EUR_CRM_GB_Objective__c>();
        List<CTM_Child_Objects_Filters__mdt> objectiveFilters = selectMdtFiltersForSObject('EUR_CRM_GB_Objective__c');
        for (String countryCode : accountIdsByCountryCode.keySet()) {
            if (haveFilterForCountry(countryCode, objectiveFilters)) {
                objectivesResult.addAll(selectObjectivesWithFilter(accountIdsByCountryCode.get(countryCode), countryCode));
            } else {
                objectivesResult.addAll(selectObjectivesByAccountIds(accountIdsByCountryCode.get(countryCode)));
            }
        }
        return objectivesResult;
    }

    private List<EUR_CRM_Competitor_Promo_Tracking__c> getCompetitorPromoTrackingsWithFilter() {
        List<EUR_CRM_Competitor_Promo_Tracking__c> promoTrackingResult = new List<EUR_CRM_Competitor_Promo_Tracking__c>();
        List<CTM_Child_Objects_Filters__mdt> competitorFilters = selectMdtFiltersForSObject
                ('EUR_CRM_Competitor_Promo_Tracking__c');
        for (String countryCode : accountIdsByCountryCode.keySet()) {
            if (haveFilterForCountry(countryCode, competitorFilters)) {
                promoTrackingResult.addAll(selectCompetitorsWithFilter(accountIdsByCountryCode.get(countryCode), countryCode));
            } else {
                promoTrackingResult.addAll(selectCompetitorPromoTrackingsByAccountIds(accountIdsByCountryCode.get(countryCode)));
            }
        }
        return promoTrackingResult;
    }

    private List<EUR_CRM_Contract_Tracker__c> getContractTrackersWithFilter() {
        List<EUR_CRM_Contract_Tracker__c> contractTrackerResult = new List<EUR_CRM_Contract_Tracker__c>();
        List<CTM_Child_Objects_Filters__mdt> competitorFilters = selectMdtFiltersForSObject('EUR_CRM_Contract_Tracker__c');
        for (String countryCode : accountIdsByCountryCode.keySet()) {
            if (haveFilterForCountry(countryCode, competitorFilters)) {
                contractTrackerResult.addAll(selectContractTrackersWithFilter(accountIdsByCountryCode.get(countryCode), countryCode));
            } else {
                contractTrackerResult.addAll(selectContractTrackersByAccountIds(accountIdsByCountryCode.get(countryCode)));
            }
        }
        return contractTrackerResult;
    }

    private List<EUR_CRM_Brand_Security_Infringement__c> getBrandSecurityInfringementsWithFilter() {
        List<EUR_CRM_Brand_Security_Infringement__c> brandSecurityResult = new List<EUR_CRM_Brand_Security_Infringement__c>();
        List<CTM_Child_Objects_Filters__mdt> brandFilters = selectMdtFiltersForSObject
                ('EUR_CRM_Brand_Security_Infringement__c');
        for (String countryCode : accountIdsByCountryCode.keySet()) {
            if (haveFilterForCountry(countryCode, brandFilters)) {
                brandSecurityResult.addAll(selectBrandSecurityWithFilter(accountIdsByCountryCode.get(countryCode), countryCode));
            } else {
                brandSecurityResult.addAll(selectBrandSecurityByAccountIds(accountIdsByCountryCode.get(countryCode)));
            }
        }
        return brandSecurityResult;
    }

    private List<EUR_CRM_Contract_Audit__c> getContractAuditsWithFilter() {
        List<EUR_CRM_Contract_Audit__c> contractAuditResult = new List<EUR_CRM_Contract_Audit__c>();
        List<CTM_Child_Objects_Filters__mdt> auditFilters = selectMdtFiltersForSObject('EUR_CRM_Contract_Audit__c');
        for (String countryCode : accountIdsByCountryCode.keySet()) {
            if (haveFilterForCountry(countryCode, auditFilters)) {
                contractAuditResult.addAll(selectContractAuditsWithFilter(accountIdsByCountryCode.get(countryCode), countryCode));
            } else {
                contractAuditResult.addAll(selectContractAuditsByAccountIds(accountIdsByCountryCode.get(countryCode)));
            }
        }
        return contractAuditResult;
    }

    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Set<Id> collectUserIdToShare(Map<Id, Set<Id>> userIdsByAccountId) {
        Set<Id> userIds = new Set<Id>();
        for (Id accId : userIdsByAccountId.keySet()) {
            userIds.addAll(userIdsByAccountId.get(accId));
        }
        return userIds;
    }

    private Set<Id> collectObjPromoIds() {
        Set<Id> objPromoIds = new Set<Id>();
        for (Id accId : this.objPromoIdsToShareByEUAccountId.keySet()) {
            objPromoIds.addAll(this.objPromoIdsToShareByEUAccountId.get(accId));
        }
        return objPromoIds;
    }

    private Boolean haveFilterForCountry(String countryCode, List<CTM_Child_Objects_Filters__mdt> objList) {
        for (CTM_Child_Objects_Filters__mdt filer : objList) {
            if (filer.EUR_CRM_Country_Code__c == countryCode) {
                return true;
            }
        }
        return false;
    }

    /* ========================================================= */
    /*     Low Level Makers (sharing)
    /* ========================================================= */
    private EUR_CRM_Account__Share makeEUAccountShare(Id accId, Id userId) {
        String accessLevel = this.accessLevelByUserIdByEUAccountId.containsKey(accId) ? this.accessLevelByUserIdByEUAccountId.get(accId).get(userId) : null;
        return new EUR_CRM_Account__Share(
                ParentId = accId
                , UserOrGroupId = userId
                , RowCause = APEX_SHARING_REASON
                , AccessLevel = accessLevel
        );
    }

    private AccountShare makeAccountShare(Id euAccId, Id accId, Id userId) {
        String accessLevel = this.accessLevelByUserIdByEUAccountId.containsKey(euAccId) ? this.accessLevelByUserIdByEUAccountId.get(euAccId).get(userId) : null;
        return new AccountShare(
                AccountId = accId
                , UserOrGroupId = userId
                , RowCause = 'Manual'
                , AccountAccessLevel = accessLevel
                , OpportunityAccessLevel = accessLevel
        );
    }

    private EUR_CRM_Competitor_Promo_Tracking__Share makeCompetitorPromoTrackingShare(Id parentId, Id userId, Id euAccId) {
        String accessLevel = this.accessLevelByUserIdByEUAccountId.containsKey(euAccId) ? this.accessLevelByUserIdByEUAccountId.get(euAccId).get(userId) : null;
        return new EUR_CRM_Competitor_Promo_Tracking__Share(
                ParentId = parentId
                , UserOrGroupId = userId
                , RowCause = 'Manual'
                , AccessLevel = accessLevel
        );
    }

    private EUR_CRM_Brand_Security_Infringement__Share makeBrandSecurityInfringementShare(Id parentId, Id userId, Id euAccId) {
        String accessLevel = this.accessLevelByUserIdByEUAccountId.containsKey(euAccId) ? this.accessLevelByUserIdByEUAccountId.get(euAccId).get(userId) : null;
        return new EUR_CRM_Brand_Security_Infringement__Share(
                ParentId = parentId
                , UserOrGroupId = userId
                , RowCause = 'Manual'
                , AccessLevel = accessLevel
        );
    }

    private EUR_CRM_Visit__Share makeVisitShare(Id parentId, Id userId, Id euAccId) {
        String accessLevel = this.accessLevelByUserIdByEUAccountId.containsKey(euAccId) ? this.accessLevelByUserIdByEUAccountId.get(euAccId).get(userId) : null;
        return new EUR_CRM_Visit__Share(
                ParentId = parentId
                , UserOrGroupId = userId
                , RowCause = 'Manual'
                , AccessLevel = accessLevel
        );
    }
//
//    private EUR_CRM_ObjPromo__Share makeObjPromoShare(Id parentId, Id userId, String accessLevel) {
//        return new EUR_CRM_ObjPromo__Share(
//            ParentId = parentId
//        ,   UserOrGroupId = userId
//        ,   RowCause = 'Manual'
//        ,   AccessLevel = accessLevel
//        );
//    }
//
    private EUR_CRM_GB_Objective__Share makeObjectiveShare(Id parentId, Id userId, Id euAccId) {
        String accessLevel = this.accessLevelByUserIdByEUAccountId.containsKey(euAccId) ? this.accessLevelByUserIdByEUAccountId.get(euAccId).get(userId) : null;
        return new EUR_CRM_GB_Objective__Share(
                ParentId = parentId
                , UserOrGroupId = userId
                , RowCause = 'Manual'
                , AccessLevel = accessLevel
        );
    }

    private EUR_CRM_Contract_Tracker__Share makeContractTrackerShare(Id parentId, Id userId, Id euAccId) {
        String accessLevel = this.accessLevelByUserIdByEUAccountId.containsKey(euAccId) ? this.accessLevelByUserIdByEUAccountId.get(euAccId).get(userId) : null;
        return new EUR_CRM_Contract_Tracker__Share(
                ParentId = parentId
                , UserOrGroupId = userId
                , RowCause = 'Manual'
                , AccessLevel = accessLevel
        );
    }

    private EUR_CRM_Contract_Audit__Share makeContractAuditShare(Id parentId, Id userId, Id euAccId) {
        String accessLevel = this.accessLevelByUserIdByEUAccountId.containsKey(euAccId) ? this.accessLevelByUserIdByEUAccountId.get(euAccId).get(userId) : null;
        return new EUR_CRM_Contract_Audit__Share(
                ParentId = parentId
                , UserOrGroupId = userId
                , RowCause = 'Manual'
                , AccessLevel = accessLevel
        );
    }

    private EUR_CRM_Visit_Action__Share makeVisitActionShare(Id parentId, Id userId, Id euAccId) {
        String accessLevel = this.accessLevelByUserIdByEUAccountId.containsKey(euAccId) ? this.accessLevelByUserIdByEUAccountId.get(euAccId).get(userId) : null;
        return new EUR_CRM_Visit_Action__Share(
                ParentId = parentId
                , UserOrGroupId = userId
                , RowCause = 'Manual'
                , AccessLevel = accessLevel
        );
    }

    /* ========================================================= */
    /*     SOQL Selectors (sObjects)
    /* ========================================================= */
    private List<EUR_CRM_Account_Link__c> selectAccountLinks() {
        return [
                SELECT Id
                        , EUR_CRM_Standard_Account__c
                        , EUR_CRM_EU_Account__c
                FROM EUR_CRM_Account_Link__c
                WHERE EUR_CRM_EU_Account__c IN :this.userIdsByEUAccountId.keySet()
        ];
    }

//    private List<EUR_CRM_Competitor_Promo_Tracking__c> selectCompetitorPromoTracking() {
//        return [
//                SELECT Id
//                        , EUR_CRM_Account_Name__c
//                FROM EUR_CRM_Competitor_Promo_Tracking__c
//                WHERE EUR_CRM_Account_Name__c = :this.userIdsByEUAccountId.keySet()
//        ];
//    }

//    private List<EUR_CRM_Brand_Security_Infringement__c> selectBrandSecurityInfringements() {
//        return [
//                SELECT Id
//                        , EUR_CRM_Outlet_Name__c
//                FROM EUR_CRM_Brand_Security_Infringement__c
//                WHERE EUR_CRM_Outlet_Name__c = :this.userIdsByEUAccountId.keySet()
//        ];
//    }
//
//    private List<EUR_CRM_Visit__c> selectVisits() {
//        return [
//                SELECT Id
//                        , EUR_CRM_Account__c
//                FROM EUR_CRM_Visit__c
//                WHERE EUR_CRM_Account__c = :this.userIdsByEUAccountId.keySet()
//        ];
//    }

    private List<EUR_CRM_ObjPromo_Account_Mapping__c> selectObjPromoAccountMappings() {
        return [
                SELECT Id
                        , EUR_CRM_ObjPromo__c
                        , EUR_CRM_Account__c
                FROM EUR_CRM_ObjPromo_Account_Mapping__c
                WHERE EUR_CRM_Account__c = :this.userIdsByEUAccountId.keySet()
        ];
    }

//    private List<EUR_CRM_GB_Objective__c> selectObjectives() {
//        return [
//                SELECT Id
//                        , EUR_CRM_Account__c
//                FROM EUR_CRM_GB_Objective__c
//                WHERE EUR_CRM_Account__c = :this.userIdsByEUAccountId.keySet()
//        ];
//    }
//
//    private List<EUR_CRM_Contract_Tracker__c> selectContractTrackers() {
//        return [
//                SELECT Id
//                        , EUR_CRM_Account__c
//                FROM EUR_CRM_Contract_Tracker__c
//                WHERE EUR_CRM_Account__c = :this.userIdsByEUAccountId.keySet()
//        ];
//    }
//
//    private List<EUR_CRM_Contract_Audit__c> selectContractAudits() {
//        return [
//                SELECT Id
//                        , EUR_CRM_Contract__r.EUR_CRM_Account__c
//                FROM EUR_CRM_Contract_Audit__c
//                WHERE EUR_CRM_Contract__r.EUR_CRM_Account__c = :this.userIdsByEUAccountId.keySet()
//        ];
//    }

//    private List<EUR_CRM_Visit_Action__c> selectVisitActions() {
//        return [
//                SELECT Id
//                        , EUR_CRM_Account__c
//                FROM EUR_CRM_Visit_Action__c
//                WHERE EUR_CRM_Account__c = :this.userIdsByEUAccountId.keySet()
//        ];
//    }

    private List<EUR_CRM_Visit_Action__c> selectVisitActionByAccountIds(Set<Id> accIds) {
        return [
                SELECT Id
                        , EUR_CRM_Account__c
                FROM EUR_CRM_Visit_Action__c
                WHERE EUR_CRM_Account__c = :accIds
        ];
    }

    private List<EUR_CRM_Visit__c> selectVisitsByAccountIds(Set<Id> accIds) {
        return [
                SELECT Id
                        , EUR_CRM_Account__c
                FROM EUR_CRM_Visit__c
                WHERE EUR_CRM_Account__c = :accIds
        ];
    }

    private List<EUR_CRM_GB_Objective__c> selectObjectivesByAccountIds(Set<Id> accIds) {
        return [
                SELECT Id
                        , EUR_CRM_Account__c
                FROM EUR_CRM_GB_Objective__c
                WHERE EUR_CRM_Account__c = :accIds
        ];
    }


    private List<EUR_CRM_Competitor_Promo_Tracking__c> selectCompetitorPromoTrackingsByAccountIds(Set<Id> accIds) {
        return [
                SELECT Id
                        , EUR_CRM_Account_Name__c
                FROM EUR_CRM_Competitor_Promo_Tracking__c
                WHERE EUR_CRM_Account_Name__c = :accIds
        ];
    }

    private List<EUR_CRM_Contract_Tracker__c> selectContractTrackersByAccountIds(Set<Id> accIds) {
        return [
                SELECT Id
                        , EUR_CRM_Account__c
                FROM EUR_CRM_Contract_Tracker__c
                WHERE EUR_CRM_Account__c = :accIds
        ];
    }

    private List<EUR_CRM_Brand_Security_Infringement__c> selectBrandSecurityByAccountIds(Set<Id> accIds) {
        return [
                SELECT Id
                        , EUR_CRM_Outlet_Name__c
                FROM EUR_CRM_Brand_Security_Infringement__c
                WHERE EUR_CRM_Outlet_Name__c = :accIds
        ];
    }

    private List<EUR_CRM_Contract_Audit__c> selectContractAuditsByAccountIds(Set<Id> accIds) {
        return [
                SELECT Id
                        , EUR_CRM_Contract__r.EUR_CRM_Account__c
                FROM EUR_CRM_Contract_Audit__c
                WHERE EUR_CRM_Contract__r.EUR_CRM_Account__c = :accIds
        ];
    }

    private List<EUR_CRM_Visit_Action__c> selectVisitActionsWithFilter(Set<Id> accIds, String countryCode) {
        String filter = selectFilterByObjectAndCountyCode(countryCode, 'EUR_CRM_Visit_Action__c').EUR_CRM_Filter__c;
        return (List<EUR_CRM_Visit_Action__c>) Database.query('SELECT Id, EUR_CRM_Account__c FROM ' +
                'EUR_CRM_Visit_Action__c ' + filter +
                ' AND EUR_CRM_Account__c = :accIds');
    }

    private List<EUR_CRM_Visit__c> selectVisitsWithFilter(Set<Id> accIds, String countryCode) {
        String filter = selectFilterByObjectAndCountyCode(countryCode, 'EUR_CRM_Visit__c').EUR_CRM_Filter__c;
        return (List<EUR_CRM_Visit__c>) Database.query('SELECT Id, EUR_CRM_Account__c FROM ' +
                'EUR_CRM_Visit__c ' + filter +
                ' AND EUR_CRM_Account__c = :accIds');
    }

    private List<EUR_CRM_GB_Objective__c> selectObjectivesWithFilter(Set<Id> accIds, String countryCode) {
        String filter = selectFilterByObjectAndCountyCode(countryCode, 'EUR_CRM_GB_Objective__c').EUR_CRM_Filter__c;
        return (List<EUR_CRM_GB_Objective__c>) Database.query('SELECT Id, EUR_CRM_Account__c FROM ' +
                'EUR_CRM_GB_Objective__c ' + filter +
                ' AND EUR_CRM_Account__c = :accIds');
    }

    private List<EUR_CRM_Competitor_Promo_Tracking__c> selectCompetitorsWithFilter(Set<Id> accIds, String countryCode) {
        String filter = selectFilterByObjectAndCountyCode(countryCode, 'EUR_CRM_Competitor_Promo_Tracking__c').EUR_CRM_Filter__c;
        return (List<EUR_CRM_Competitor_Promo_Tracking__c>) Database.query('SELECT Id, EUR_CRM_Account_Name__c FROM ' +
                'EUR_CRM_Competitor_Promo_Tracking__c ' + filter +
                ' AND EUR_CRM_Account_Name__c = :accIds');
    }

    private List<EUR_CRM_Contract_Tracker__c> selectContractTrackersWithFilter(Set<Id> accIds, String countryCode) {
        String filter = selectFilterByObjectAndCountyCode(countryCode, 'EUR_CRM_Contract_Tracker__c').EUR_CRM_Filter__c;
        return (List<EUR_CRM_Contract_Tracker__c>) Database.query('SELECT Id, EUR_CRM_Account__c FROM ' +
                'EUR_CRM_Contract_Tracker__c ' + filter +
                ' AND EUR_CRM_Account__c = :accIds');
    }

    private List<EUR_CRM_Brand_Security_Infringement__c> selectBrandSecurityWithFilter(Set<Id> accIds, String
            countryCode) {
        String filter = selectFilterByObjectAndCountyCode(countryCode, 'EUR_CRM_Brand_Security_Infringement__c').EUR_CRM_Filter__c;
        return (List<EUR_CRM_Brand_Security_Infringement__c>) Database.query('SELECT Id, EUR_CRM_Outlet_Name__c FROM ' +
                'EUR_CRM_Brand_Security_Infringement__c ' + filter +
                ' AND EUR_CRM_Outlet_Name__c = :accIds');
    }

    private List<EUR_CRM_Contract_Audit__c> selectContractAuditsWithFilter(Set<Id> accIds, String
            countryCode) {
        String filter = selectFilterByObjectAndCountyCode(countryCode, 'EUR_CRM_Contract_Audit__c').EUR_CRM_Filter__c;
        return (List<EUR_CRM_Contract_Audit__c>) Database.query('SELECT Id, EUR_CRM_Contract__r.EUR_CRM_Account__c FROM ' +
                'EUR_CRM_Contract_Audit__c ' + filter +
                ' AND EUR_CRM_Contract__r.EUR_CRM_Account__c = :accIds');
    }

    /* ========================================================= */
    /*     SOQL Selectors (sharing)
    /* ========================================================= */
    private List<EUR_CRM_Account__Share> selectEUAccountShares() {
        return [
                SELECT Id
                        , ParentId
                        , UserOrGroupId
                        , Parent.OwnerId
                        , RowCause
                FROM EUR_CRM_Account__Share
                WHERE ParentId IN :this.userIdsByEUAccountId.keySet()
                AND UserOrGroupId IN :this.userIdsToShare
        ];
    }

    private List<AccountShare> selectAccountShares() {
        return [
                SELECT Id
                        , AccountId
                        , UserOrGroupId
                        , Account.OwnerId
                        , RowCause
                FROM AccountShare
                WHERE AccountId IN :this.userIdsByAccountId.keySet()
                AND UserOrGroupId IN :this.userIdsToShare
        ];
    }

    private List<EUR_CRM_Competitor_Promo_Tracking__Share> selectCompetitorPromoTrackingShares() {
        return [
                SELECT Id
                        , ParentId
                        , UserOrGroupId
                        , RowCause
                        , Parent.OwnerId
                        , Parent.EUR_CRM_Account_Name__c
                FROM EUR_CRM_Competitor_Promo_Tracking__Share
                WHERE Parent.EUR_CRM_Account_Name__c = :this.userIdsByEUAccountId.keySet()
                AND UserOrGroupId = :this.userIdsToShare
        ];
    }

    private List<EUR_CRM_Brand_Security_Infringement__Share> selectBrandSecurityInfringementShares() {
        return [
                SELECT Id
                        , ParentId
                        , UserOrGroupId
                        , RowCause
                        , Parent.OwnerId
                        , Parent.EUR_CRM_Outlet_Name__c
                FROM EUR_CRM_Brand_Security_Infringement__Share
                WHERE Parent.EUR_CRM_Outlet_Name__c = :this.userIdsByEUAccountId.keySet()
                AND UserOrGroupId = :this.userIdsToShare
        ];
    }

    private List<EUR_CRM_Visit__Share> selectVisitShares() {
        return [
                SELECT Id
                        , ParentId
                        , UserOrGroupId
                        , RowCause
                        , Parent.OwnerId
                        , Parent.EUR_CRM_Account__c
                FROM EUR_CRM_Visit__Share
                WHERE Parent.EUR_CRM_Account__c = :this.userIdsByEUAccountId.keySet()
                AND UserOrGroupId = :this.userIdsToShare
        ];
    }

    private List<EUR_CRM_ObjPromo__Share> selectObjPromoShares(Set<Id> objPromoIds) {
        return [
                SELECT Id
                        , ParentId
                        , UserOrGroupId
                        , RowCause
                        , Parent.OwnerId
                FROM EUR_CRM_ObjPromo__Share
                WHERE ParentId = :objPromoIds
                AND UserOrGroupId = :this.userIdsToShare
        ];
    }

    private List<EUR_CRM_GB_Objective__Share> selectObjectiveShares() {
        return [
                SELECT Id
                        , ParentId
                        , UserOrGroupId
                        , RowCause
                        , Parent.OwnerId
                        , Parent.EUR_CRM_Account__c
                FROM EUR_CRM_GB_Objective__Share
                WHERE Parent.EUR_CRM_Account__c = :this.userIdsByEUAccountId.keySet()
                AND UserOrGroupId = :this.userIdsToShare
        ];
    }

    private List<EUR_CRM_Contract_Tracker__Share> selectContractTrackerShares() {
        return [
                SELECT Id
                        , ParentId
                        , UserOrGroupId
                        , RowCause
                        , Parent.OwnerId
                        , Parent.EUR_CRM_Account__c
                FROM EUR_CRM_Contract_Tracker__Share
                WHERE Parent.EUR_CRM_Account__c = :this.userIdsByEUAccountId.keySet()
                AND UserOrGroupId = :this.userIdsToShare
        ];
    }

    private List<EUR_CRM_Contract_Audit__Share> selectContractAuditShares() {
        return [
                SELECT Id
                        , ParentId
                        , UserOrGroupId
                        , RowCause
                        , Parent.OwnerId
                        , Parent.EUR_CRM_Contract__r.EUR_CRM_Account__c
                FROM EUR_CRM_Contract_Audit__Share
                WHERE Parent.EUR_CRM_Contract__r.EUR_CRM_Account__c = :this.userIdsByEUAccountId.keySet()
                AND UserOrGroupId = :this.userIdsToShare
        ];
    }

    private List<EUR_CRM_Visit_Action__Share> selectVisitActionShares() {
        return [
                SELECT Id
                        , ParentId
                        , UserOrGroupId
                        , RowCause
                        , Parent.OwnerId
                        , Parent.EUR_CRM_Account__c
                FROM EUR_CRM_Visit_Action__Share
                WHERE Parent.EUR_CRM_Account__c = :this.userIdsByEUAccountId.keySet()
                AND UserOrGroupId = :this.userIdsToShare
        ];
    }

    /* ========================================================= */
    /*     SOQL Selectors Metadata
    /* ========================================================= */

    private List<CTM_Child_Objects_Filters__mdt> selectMdtFiltersForSObject(String apiName) {
        return [
                SELECT EUR_CRM_Country_Code__c,
                        EUR_CRM_Object_API_Name__c,
                        EUR_CRM_Filter__c
                FROM CTM_Child_Objects_Filters__mdt
                WHERE EUR_CRM_Object_API_Name__c = :apiName
        ];
    }

    private CTM_Child_Objects_Filters__mdt selectFilterByObjectAndCountyCode(String countryCode, String apiName) {
        return [
                SELECT EUR_CRM_Filter__c
                FROM CTM_Child_Objects_Filters__mdt
                WHERE EUR_CRM_Country_Code__c = :countryCode AND
                EUR_CRM_Object_API_Name__c = :apiName
        ];
    }
}