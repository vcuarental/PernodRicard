public without sharing class ASI_KOR_OldRecordDeleteScheduler implements Schedulable {
    
    public void execute(SchedulableContext ctx) {
        ASI_KOR_OldRecordDeleteScheduler.deleteOldRecords();
    }
    
    @future
    public static void deleteOldRecords() {
        Map<String, ASI_KOR_Old_Record_Deletion__c> deleteOldSettingMap = ASI_KOR_Old_Record_Deletion__c.getAll();
        if (deleteOldSettingMap != null && deleteOldSettingMap.size() > 0) {
            Set<String> relevantObjs = deleteOldSettingMap.keySet();
            for (String objAPIName : relevantObjs) {
                ASI_KOR_Old_Record_Deletion__c deleteOldSetting = deleteOldSettingMap.get(objAPIName);
                Decimal keepNumOfDays = deleteOldSetting.ASI_KOR_Keeping_Period__c;
                deleteOldRecordsOfObjectByDays(objAPIName, keepNumOfDays);
            }
        }
    }
    
    private static void deleteOldRecordsOfObjectByDays(String objAPIName, Decimal keepNumOfDays) {
        if (keepNumOfDays == null || keepNumOfDays < 0) {
            System.debug(String.format('Invalid number of days for obj {0}: {1}', new String[] {objAPIName, keepNumOfDays == null ? 'null' : String.valueOf(keepNumOfDays)}));
        }
        deleteOldRecordsOfObject(objAPIName, '< LAST_N_DAYS:' + keepNumOfDays.intValue());
    }
    
    private static void deleteOldRecordsOfObject(String objAPIName, String createDateCompStr) {
        try {
            for (List<sObject> sobjs : database.query(
                'SELECT Id, CreatedDate FROM ' + objAPIName + ' WHERE CreatedDate ' + createDateCompStr
                )) {
                if (sobjs.size() > 0) {
                    List<database.DeleteResult> deleteResults = database.delete(sobjs, false);
                    for (database.DeleteResult dr : deleteResults) {
                        if (!dr.isSuccess()) {
                            System.debug(dr);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e);
        }
    }
    
}