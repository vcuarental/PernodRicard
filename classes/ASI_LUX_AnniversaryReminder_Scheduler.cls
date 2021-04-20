global class ASI_LUX_AnniversaryReminder_Scheduler implements Schedulable {

    //test run
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';

    global void execute(SchedulableContext SC) {
        
        String Query = 'SELECT Name, ID, OwnerID, ASI_LUX_Preferred_Contact_Number__c, PersonMobilePhone, PersonHomePhone, ASI_LUX_LeCercle_Member_Since_Date__c ' + 
                        ' FROM Account WHERE RecordType.DeveloperName LIKE \'ASI_Luxury_Account_HK%\' OR RecordType.DeveloperName LIKE \'ASI_Luxury_Account_MY%\' ';
        
        ASI_LUX_AnniversaryReminder_Batch sendAnniversaryReminder = new ASI_LUX_AnniversaryReminder_Batch(Query);
        Database.executeBatch(sendAnniversaryReminder, 8);
    }

}