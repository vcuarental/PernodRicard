/**
 * Created by Ilarion Tokarskyi on 28.05.2020.
 */

public with sharing class EUR_CRM_POSM_AuditItemsDuplicateClean extends EUR_CRM_BatchVirtualClass implements Database.Batchable<SObject>, Schedulable {

    @TestVisible
    private static final String EUR_CRM_POSM_AUDIT_ITEMS_DUPLICATE_CLEAN = 'EUR_CRM_POSM_AuditItemsDuplicateClean';

    private Set<String> rtDevNames;
    private Datetime startDatetime;
    private Datetime endDatetime;
    private Integer batchSize = 200;


    //Schedule interfaces
    /*
    * Cron expression example:
    * Seconds Minutes Hours Day_of_month Month Day_of_week Optional_year
    * String cronExpr = '0 0 1 * * ?'; Class runs every day at 1 AM.
    */
    public static String scheduleCleanRecordsWhereRtDevNameAndDates(String cronExpression, Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
        return System.schedule(
                EUR_CRM_POSM_AUDIT_ITEMS_DUPLICATE_CLEAN + ' at ' + cronExpression,
                cronExpression,
                new EUR_CRM_POSM_AuditItemsDuplicateClean(rtDevNames, startDatetime, endDatetime, batchSize)
        );
    }

    public static void removeSchedules() {
        List<CronTrigger> cronTriggers = selectCronTriggers();
        for(CronTrigger ct : cronTriggers) {
            System.abortJob(ct.Id);
        }
    }


    //Batch Interfaces
    public static void cleanRecordsWhereRtDevName(Set<String> rtDevNames) {
        Database.executeBatch(new EUR_CRM_POSM_AuditItemsDuplicateClean(rtDevNames));
    }

    public static void cleanRecordsWhereRtDevName(Set<String> rtDevNames, Integer batchSize) {
        Database.executeBatch(new EUR_CRM_POSM_AuditItemsDuplicateClean(rtDevNames), batchSize);
    }

    public static void cleanRecordsWhereRtDevNameAndDates(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime) {
        Database.executeBatch(new EUR_CRM_POSM_AuditItemsDuplicateClean(rtDevNames, startDatetime, endDatetime));
    }

    public static void cleanRecordsWhereRtDevNameAndDates(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
        Database.executeBatch(new EUR_CRM_POSM_AuditItemsDuplicateClean(rtDevNames, startDatetime, endDatetime), batchSize);
    }



    //Constructors
    public EUR_CRM_POSM_AuditItemsDuplicateClean() {}

    public EUR_CRM_POSM_AuditItemsDuplicateClean(Set<String> rtDevNames) {
        this.rtDevNames = rtDevNames;
    }

    public EUR_CRM_POSM_AuditItemsDuplicateClean(Set<String> rtDevName, Datetime startDatetime, Datetime endDatetime) {
        this.rtDevNames = rtDevName;
        this.startDatetime = startDatetime;
        this.endDatetime = endDatetime;
    }

    public EUR_CRM_POSM_AuditItemsDuplicateClean(Set<String> rtDevName, Datetime startDatetime, Datetime endDatetime, Integer batchSize) {
        this.rtDevNames = rtDevName;
        this.startDatetime = startDatetime;
        this.endDatetime = endDatetime;
        this.batchSize = batchSize;
    }

    //Schedulable
    public void execute(SchedulableContext sc) {
        Database.executeBatch(
                this, this.batchSize
        );
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
                this.buildPaisQuery(this.rtDevNames, this.startDatetime, this.endDatetime)
        );
    }

    public void execute(Database.BatchableContext bc, List<EUR_CRM_POSM_Audit_Item__c> pais) {
        deletePaisDuplicates(pais);
    }


    //High level helpers
    public void deletePaisDuplicates(List<EUR_CRM_POSM_Audit_Item__c> pais) {
        System.debug('\n pais.size() => ' + pais.size() + '\n');
        System.debug('\n pais => ' + JSON.serializePretty(pais) + '\n');
        Map<Id, Map<String, List<EUR_CRM_POSM_Audit_Item__c>>> paisByMobileIdByPaId = this.getPaisByMobileIdByPaId(pais);
        System.debug('\n paisByMobileIdByPaId.size() => ' + paisByMobileIdByPaId.size() + '\n');
        System.debug('\n paisByMobileIdByPaId => ' + JSON.serializePretty(paisByMobileIdByPaId) + '\n');

        List<EUR_CRM_POSM_Audit_Item__c> paisToDelete = this.getPaisToDelete(paisByMobileIdByPaId);
        System.debug('\n this.paisToDelete.size() => ' + paisToDelete.size() + '\n');
        System.debug('\n this.paisToDelete => ' + JSON.serializePretty(paisToDelete) + '\n');
        Database.delete(paisToDelete, false);
    }

    private Map<Id, Map<String, List<EUR_CRM_POSM_Audit_Item__c>>> getPaisByMobileIdByPaId(List<EUR_CRM_POSM_Audit_Item__c> pais) {
        Map<Id, Map<String, List<EUR_CRM_POSM_Audit_Item__c>>> paisByMobileIdByPaId = new Map<Id, Map<String, List<EUR_CRM_POSM_Audit_Item__c>>>();
        for (EUR_CRM_POSM_Audit_Item__c pai : pais) {
            if (pai.EUR_CRM_Mobile_Id__c == null) { continue; }

            if (paisByMobileIdByPaId.containsKey(pai.EUR_CRM_POSM_Audit__c)) {
                if (paisByMobileIdByPaId.get(pai.EUR_CRM_POSM_Audit__c).containsKey(pai.EUR_CRM_Mobile_Id__c)) {
                    paisByMobileIdByPaId.get(pai.EUR_CRM_POSM_Audit__c).get(pai.EUR_CRM_Mobile_Id__c).add(pai);
                } else {
                    paisByMobileIdByPaId.get(pai.EUR_CRM_POSM_Audit__c).put(pai.EUR_CRM_Mobile_Id__c, new List<EUR_CRM_POSM_Audit_Item__c>{ pai });
                }
            } else {
                paisByMobileIdByPaId.put(pai.EUR_CRM_POSM_Audit__c, new Map<String, List<EUR_CRM_POSM_Audit_Item__c>>{
                        pai.EUR_CRM_Mobile_Id__c => new List<EUR_CRM_POSM_Audit_Item__c>{ pai }
                });
            }
        }
        return paisByMobileIdByPaId;
    }

    private List<EUR_CRM_POSM_Audit_Item__c> getPaisToDelete(Map<Id, Map<String, List<EUR_CRM_POSM_Audit_Item__c>>> paisByMobileIdByPaId) {
        List<EUR_CRM_POSM_Audit_Item__c> paisToDelete = new List<EUR_CRM_POSM_Audit_Item__c>();
        for (Id paId : paisByMobileIdByPaId.keySet()) {
            Map<String, List<EUR_CRM_POSM_Audit_Item__c>> paisByMobileId = paisByMobileIdByPaId.get(paId);
            for (String mobileId : paisByMobileId.keySet()) {
                List<EUR_CRM_POSM_Audit_Item__c> pais = paisByMobileId.get(mobileId);
                if (pais.size() > 1) {
                    paisToDelete.addAll(this.addPaisExceptOneElementToList(pais));
                }
            }
        }
        return paisToDelete;
    }

    private List<EUR_CRM_POSM_Audit_Item__c> addPaisExceptOneElementToList(List<EUR_CRM_POSM_Audit_Item__c> pais) {
        List<EUR_CRM_POSM_Audit_Item__c> paisToDelete = new List<EUR_CRM_POSM_Audit_Item__c>();
        for (Integer i = 0; i < pais.size() - 1; i++) {
            paisToDelete.add(pais.get(i));
        }
        return paisToDelete;
    }

    @TestVisible
    private String buildPaisQuery(Set<String> rtDevNames, Datetime startDatetime, Datetime endDatetime) {
        String query = 'SELECT Id, EUR_CRM_POSM_Audit__c, EUR_CRM_Mobile_ID__c ' +
                ' FROM EUR_CRM_POSM_Audit_Item__c ' +
                ' WHERE EUR_CRM_POSM_Audit__c IN ' +
                '(' +
                ' SELECT Id FROM EUR_CRM_POSM_Audit__c ' +
                (rtDevNames == null ? 'WHERE Id != NULL' : ' WHERE RecordType.DeveloperName IN :rtDevNames ') +
                (startDatetime == null ? '' : ' AND CreatedDate >= :startDatetime ') +
                (endDatetime == null ? '' : ' AND CreatedDate < :endDatetime ') +
                ' ) ' +
                ' AND EUR_CRM_Mobile_ID__c != NULL ' +
                ' ORDER BY EUR_CRM_POSM_Audit__c, EUR_CRM_Mobile_ID__c';
        System.debug('\n pais query => ' + query + '\n');
        return query;
    }

    private  static List<CronTrigger> selectCronTriggers() {
        return [
                SELECT Id
                        ,   CronJobDetail.Name
                        ,   CronExpression
                        ,   NextFireTime
                FROM CronTrigger
                WHERE CronJobDetail.Name LIKE :EUR_CRM_POSM_AUDIT_ITEMS_DUPLICATE_CLEAN + '%'
        ];
    }
}