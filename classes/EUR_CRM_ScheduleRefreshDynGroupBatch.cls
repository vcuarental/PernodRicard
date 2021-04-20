global class EUR_CRM_ScheduleRefreshDynGroupBatch implements Schedulable {

    public static String CRON_EXP = '0 5 0 ? * *';

    global void execute(SchedulableContext SC) {
        List<EUR_CRM_Account_Target_Group__c> accountGroups = [
                SELECT Id
                FROM EUR_CRM_Account_Target_Group__c
                WHERE EUR_CRM_isDailyRecalculation__c = TRUE
                    AND EUR_CRM_IsDynamic__c = TRUE
                LIMIT 1
        ];
        if ( ! accountGroups.isEmpty()) {
            System.Type objType = Type.forName('EUR_CRM_RefreshDynGroupBatch');
            Database.Batchable<sObject> obj = (Database.Batchable<sObject>) objType.newInstance();
            Database.executeBatch(obj);
        }
    }

}