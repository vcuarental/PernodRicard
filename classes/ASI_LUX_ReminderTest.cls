@istest 
class ASI_LUX_ReminderTest {
	
	static testmethod void testAnniversaryScheduler()
	{
		Test.startTest();
		map<string, id> rt_mapAcc = getRecordTypeId('Account');

        List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Running_Number__c = 2315;
        runnNumTest.ASI_HK_CRM_Format__c = 'SO-{YY}{000000}';
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_HK';
        testRunningNumList.add(runnNumTest2);
        
        Insert testRunningNumList;
		
		Account testAcc = new Account();
		testAcc.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact');
		testAcc.FirstName = 'testFirst';
		testAcc.LastName = 'testLast';
		testAcc.ASI_LUX_Gender__c = 'Male';
		testAcc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
		testAcc.ASI_LUX_Preferred_Language_1__c = 'English';
		testAcc.ASI_HK_CRM_Grade__c = 'D';
		testAcc.ASI_LUX_Membership_Category__c = 'Affluent';
		testAcc.ASI_LUX_Le_Cercle_Member__c = true;
		testAcc.ASI_LUX_Le_Cercle_Member_Number__c = '13012268';
		testAcc.ASI_LUX_LeCercle_Member_Since_Date__c = Date.today();
		Insert testAcc;

      	String jobId = System.schedule('testScheduledApex',
     	ASI_LUX_AnniversaryReminder_Scheduler.CRON_EXP, 
        new ASI_LUX_AnniversaryReminder_Scheduler());
		
		Test.StopTest();

	}
	
	static testmethod void testBirthdayScheduler()
	{
		
		Test.startTest();
		map<string, id> rt_mapAcc = getRecordTypeId('Account');

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

        List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Running_Number__c = 2315;
        runnNumTest.ASI_HK_CRM_Format__c = 'SO-{YY}{000000}';
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_HK';
        testRunningNumList.add(runnNumTest2);
        
        Insert testRunningNumList;
		
		Account testAcc = new Account();
		testAcc.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact');
		testAcc.FirstName = 'testFirst';
		testAcc.LastName = 'testLast';
		testAcc.ASI_LUX_Gender__c = 'Male';
		testAcc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
		testAcc.ASI_LUX_Preferred_Language_1__c = 'English';
		testAcc.ASI_HK_CRM_Grade__c = 'D';
		testAcc.ASI_LUX_Membership_Category__c = 'Affluent';
		testAcc.ASI_LUX_Le_Cercle_Member__c = true;
		testAcc.ASI_LUX_Le_Cercle_Member_Number__c = '13012268';
		testAcc.ASI_LUX_Birthday_Day__c = String.valueof(date.today().day());
		testAcc.ASI_LUX_Birthday_Month__c = monthNumTOmonth.get(String.valueof(date.today().month()));
		Insert testAcc;
		
      	String jobId = System.schedule('testScheduledApex',
     	ASI_LUX_BirthdayReminder_Scheduler.CRON_EXP, 
        new ASI_LUX_BirthdayReminder_Scheduler());
		
		Test.StopTest();
		
	}


     public static map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }

}