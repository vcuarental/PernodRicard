public with sharing class EUR_CRM_AccountLastVisitDateService {

//    private final Set<String> validVisitRecordTypes = new Set<String>{
//        'EUR_CH_Visit'
//    };
    private final String VISIT_FINISHED_STATUS = 'Finished';

    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void updateLastVisitDateOnAccount(List<EUR_CRM_Visit__c> visits) {
        Map<Id, Map<Id, EUR_CRM_Visit__c>> visitsByRecordTypeIdAccountId = this.getVisitsWithCorrectStartDateByAccountId(visits);
        if (visitsByRecordTypeIdAccountId.isEmpty()) { return ; }
        System.debug('\n\n visitsByRecordTypeIdAccountId => ' + JSON.serializePretty(visitsByRecordTypeIdAccountId) + '\n');

        this.updateLastVisitDate(visitsByRecordTypeIdAccountId);
    }

    public void updateLastVisitDateOnAccount(List<EUR_CRM_Visit__c> visits, Map<Id, EUR_CRM_Visit__c> oldVisitsById) {
        Map<Id, Map<Id, EUR_CRM_Visit__c>> visitsByRecordTypeIdAccountId = this.getVisitsWithChangedStartDateByAccountId(visits, oldVisitsById);
        System.debug('\n\n visitsByRecordTypeIdAccountId => ' + JSON.serializePretty(visitsByRecordTypeIdAccountId) + '\n');
        if (visitsByRecordTypeIdAccountId.isEmpty()) { return ; }

        this.updateLastVisitDate(visitsByRecordTypeIdAccountId);
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void updateLastVisitDate(Map<Id, Map<Id, EUR_CRM_Visit__c>> visitsByRecordTypeIdAccountId) {
//        visitsByRecordTypeIdAccountId = this.filterByValidRecordType(visitsByRecordTypeIdAccountId);
        if (visitsByRecordTypeIdAccountId.isEmpty()) { return ; }
        System.debug('\n\n visitsByRecordTypeIdAccountId => ' + JSON.serializePretty(visitsByRecordTypeIdAccountId) + '\n');

        List<EUR_CRM_Account__c> accounts = this.selectAccountsWhereIds(visitsByRecordTypeIdAccountId.keySet());
        System.debug('\n\n accounts => ' + JSON.serializePretty(accounts) + '\n');
        if (accounts.isEmpty()) { return ; }

        List<EUR_CRM_Account__c> accountsToUpdate = new List<EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c account : accounts) {
            Map<Id, EUR_CRM_Visit__c> visitByRecordType = visitsByRecordTypeIdAccountId.get(account.Id);
            for (Id rtId : visitByRecordType.keySet()) {
                EUR_CRM_Visit__c visit = visitByRecordType.get(rtId);
                if (account.EUR_CRM_Last_Visit_Date__c == null && this.isStartDateInPast(visit)) {
                    account.EUR_CRM_Last_Visit_Date__c = visit.EUR_CRM_Start_Datetime__c;
                    accountsToUpdate.add(account);
                } else if (account.EUR_CRM_Last_Visit_Date__c < visit.EUR_CRM_Start_Datetime__c && this.isStartDateInPast(visit)) {
                    account.EUR_CRM_Last_Visit_Date__c = visit.EUR_CRM_Start_Datetime__c;
                    accountsToUpdate.add(account);
                } else if ( ! account.Visits__r.isEmpty()) {
                    account.EUR_CRM_Last_Visit_Date__c = account.Visits__r[0].EUR_CRM_Start_Datetime__c;
                    accountsToUpdate.add(account);
                } else {
                    account.EUR_CRM_Last_Visit_Date__c = null;
                    accountsToUpdate.add(account);
                }
            }
        }
        System.debug('\n\n accountsToUpdate => ' + JSON.serializePretty(accountsToUpdate) + '\n');
        if (Schema.sObjectType.EUR_CRM_Account__c.fields.EUR_CRM_Last_Visit_Date__c.isUpdateable()) {
            update accountsToUpdate;
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
//    private Map<Id, Map<Id, EUR_CRM_Visit__c>> filterByValidRecordType(Map<Id, Map<Id, EUR_CRM_Visit__c>> visitsByRecordTypeIdAccountId) {
//        Set<Id> recordTypeIds = this.extractRecordTypeIds(visitsByRecordTypeIdAccountId.values());
//
//        Map<Id, RecordType> recordTypeById = this.selectRecordTypeByIdWhereIds(recordTypeIds);
//        System.debug('\n\n recordTypeById => ' + JSON.serializePretty(recordTypeById) + '\n');
//        if (recordTypeById.isEmpty()) { new Map<Id, Map<Id, EUR_CRM_Visit__c>>(); }
//
//        for (Id accId : visitsByRecordTypeIdAccountId.keySet()) {
//            Map<Id, EUR_CRM_Visit__c> visitByRecordType = visitsByRecordTypeIdAccountId.get(accId);
//            for (Id rtId : visitByRecordType.keySet()) {
//                if ( ! recordTypeById.containsKey(rtId)) {
//                    visitByRecordType.remove(rtId);
//                }
//            }
//        }
//        return visitsByRecordTypeIdAccountId;
//    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private Map<Id, Map<Id, EUR_CRM_Visit__c>> getVisitsWithCorrectStartDateByAccountId(List<EUR_CRM_Visit__c> visits) {
        Map<Id, Map<Id, EUR_CRM_Visit__c>> visitsByRecordTypeIdByAccountId = new Map<Id, Map<Id, EUR_CRM_Visit__c>>();
        for (EUR_CRM_Visit__c visit : visits) {
            if (this.isStartDateExist(visit) && this.isStartDateInPast(visit) && this.isLastFinishedVisit(visit)) {
                this.configureVisitsByRecordTypeIdByAccountId(visitsByRecordTypeIdByAccountId, visit);
            }
        }
        return visitsByRecordTypeIdByAccountId;
    }

    private Map<Id, Map<Id, EUR_CRM_Visit__c>> getVisitsWithChangedStartDateByAccountId(List<EUR_CRM_Visit__c> visits, Map<Id, EUR_CRM_Visit__c> oldVisitById) {
        Map<Id, Map<Id, EUR_CRM_Visit__c>> visitsByRecordTypeIdByAccountId = new Map<Id, Map<Id, EUR_CRM_Visit__c>>();
        for (EUR_CRM_Visit__c visit : visits) {
            if ((this.isStartDateChanged(visit, oldVisitById) && isLastFinishedVisit(visit)) || this
                    .isStatusChangedAndIsLast(visit, oldVisitById)) {
                this.configureVisitsByRecordTypeIdByAccountId(visitsByRecordTypeIdByAccountId, visit);
            }
        }
        return visitsByRecordTypeIdByAccountId;
    }

    private void configureVisitsByRecordTypeIdByAccountId(Map<Id, Map<Id, EUR_CRM_Visit__c>> visitsByRecordTypeIdByAccountId, EUR_CRM_Visit__c visit) {
        if (visitsByRecordTypeIdByAccountId.containsKey(visit.EUR_CRM_Account__c)) {
            Map<Id, EUR_CRM_Visit__c> visitsByRecordTypeId = visitsByRecordTypeIdByAccountId.get(visit.EUR_CRM_Account__c);
            if (visitsByRecordTypeId.containsKey(visit.RecordTypeId)) {
                EUR_CRM_Visit__c prevVisit = visitsByRecordTypeId.get(visit.RecordTypeId);
                if (prevVisit.EUR_CRM_Start_Datetime__c < visit.EUR_CRM_Start_Datetime__c) {
                    visitsByRecordTypeId.put(visit.RecordTypeId, visit);
                }
            } else {
                visitsByRecordTypeIdByAccountId.get(visit.EUR_CRM_Account__c).put(visit.RecordTypeId, visit);
            }
        } else {
            visitsByRecordTypeIdByAccountId.put(visit.EUR_CRM_Account__c, new Map<Id, EUR_CRM_Visit__c> { visit.RecordTypeId => visit });
        }
    }

//    private Set<Id> extractRecordTypeIds(List<Map<Id, EUR_CRM_Visit__c>> visitsByRecordTypes) {
//        Set<Id> rtIds = new Set<Id>();
//        for (Map<Id, EUR_CRM_Visit__c> visitByRecordType : visitsByRecordTypes) {
//            rtIds.addAll(visitByRecordType.keySet());
//        }
//        return rtIds;
//    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isStartDateExist(EUR_CRM_Visit__c visit) {
        return visit.EUR_CRM_Start_Datetime__c != null;
    }

    private Boolean isStartDateInPast(EUR_CRM_Visit__c visit) {
        return visit.EUR_CRM_Start_Datetime__c <= Datetime.now();
    }

    private Boolean isStartDateChanged(EUR_CRM_Visit__c visit, Map<Id, EUR_CRM_Visit__c> oldVisitByIds) {
        return visit.EUR_CRM_Start_Datetime__c != oldVisitByIds.get(visit.Id).EUR_CRM_Start_Datetime__c;
    }

    private Boolean isLastFinishedVisit(EUR_CRM_Visit__c visit) {
        return visit.EUR_CRM_Is_Latest__c && visit.EUR_CRM_Status__c == VISIT_FINISHED_STATUS;
    }

    private Boolean isStatusChangedAndIsLast(EUR_CRM_Visit__c visit, Map<Id, EUR_CRM_Visit__c> oldVisitByIds) {
        return visit.EUR_CRM_Is_Latest__c && visit.EUR_CRM_Status__c != oldVisitByIds.get(visit.Id)
                .EUR_CRM_Status__c && visit.EUR_CRM_Status__c == VISIT_FINISHED_STATUS;
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
//    private Map<Id, RecordType> selectRecordTypeByIdWhereIds(Set<Id> rtIds) {
//        return new Map<Id, RecordType>([
//            SELECT Id
//            ,   DeveloperName
//            FROM RecordType
//            WHERE Id IN :rtIds
//                AND DeveloperName IN :validVisitRecordTypes
//        ]);
//    }

    private List<EUR_CRM_Account__c> selectAccountsWhereIds(Set<Id> accIds) {
        return [
            SELECT Id
            ,   EUR_CRM_Last_Visit_Date__c
            ,   (
                SELECT Id
                ,   EUR_CRM_Start_Datetime__c
                FROM Visits__r
                WHERE EUR_CRM_Start_Datetime__c != NULL
                    AND EUR_CRM_Start_Datetime__c <= :Datetime.now()
                ORDER BY EUR_CRM_Start_Datetime__c DESC
                LIMIT 1
            )
            FROM EUR_CRM_Account__c
            WHERE Id IN :accIds
        ];
    }

}