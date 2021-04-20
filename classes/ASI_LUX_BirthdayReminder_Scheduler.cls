global class ASI_LUX_BirthdayReminder_Scheduler implements Schedulable {

    //test run
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';

    global void execute(SchedulableContext SC) {

        String Month = String.valueOf (datetime.now().month());
        String Day = String.valueOf (datetime.now().day());
        
        Map<String, String> monthNumTOmonth = new Map<String, String>();
        monthNumTOmonth.put('1', 'January');
        monthNumTOmonth.put('2', 'February');
        monthNumTOmonth.put('3', 'March');
        monthNumTOmonth.put('4', 'Aprl');
        monthNumTOmonth.put('5', 'May');
        monthNumTOmonth.put('6', 'June');
        monthNumTOmonth.put('7', 'July');
        monthNumTOmonth.put('8', 'August');
        monthNumTOmonth.put('9', 'September');
        monthNumTOmonth.put('10', 'October');
        monthNumTOmonth.put('11', 'November');
        monthNumTOmonth.put('12', 'December');
        
        String Query = 'SELECT Name, ID, OwnerID, ASI_LUX_Preferred_Contact_Number__c, PersonMobilePhone, PersonHomePhone' + 
                        ' FROM Account WHERE (RecordType.DeveloperName LIKE \'ASI_Luxury_Account_HK%\' OR RecordType.DeveloperName LIKE \'ASI_Luxury_Account_MY%\') ' + 
                        ' AND ASI_LUX_Birthday_Day__c = \'' + Day + '\' AND ASI_LUX_Birthday_Month__c = \''+ monthNumTOmonth.get(Month) +'\' ';
        
        ASI_LUX_BirthdayReminder_Batch sendBirthDayReminder = new ASI_LUX_BirthdayReminder_Batch(Query);
        Database.executeBatch(sendBirthDayReminder, 8);
    }

}