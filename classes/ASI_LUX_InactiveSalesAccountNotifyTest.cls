@istest 
class ASI_LUX_InactiveSalesAccountNotifyTest {

    static testmethod void testScheduler()
    {
        Test.startTest();
        map<string, id> rt_mapAcc = getRecordTypeId('Account');

        List<ASI_HK_CRM_Running_Number__c> runInsert = new List<ASI_HK_CRM_Running_Number__c>();
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_HK';
        runInsert.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Running_Number__c = 0;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num';
        runInsert.add(runnNumTest2);
        
        ASI_HK_CRM_Running_Number__c runnNumTest3 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest3.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest3.ASI_HK_CRM_Object_Name__c = 'ASI_HK_CRM_Sales_Order__c';
        runInsert.add(runnNumTest3);
        
        insert runInsert;

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
        Insert testAcc;
        
        Date todayIndeductMonths = date.today().addMonths(- 4);
        
        ASI_HK_CRM_Sales_Order_History__c testsoHist = new ASI_HK_CRM_Sales_Order_History__c();
        testsoHist.ASI_HK_CRM_Account_PA__c = testAcc.id;
        testsoHist.ASI_HK_CRM_Order_Date__c = todayIndeductMonths;
        Insert testsoHist;
        
        ASI_LUX_AccountInactivity__c customTest = new ASI_LUX_AccountInactivity__c();
        customTest.name = 'test';
        customTest.ASI_LUX_AccountInactivityTime_Inactivity__c = 3;
        Insert customTest;
        
        String jobId = System.schedule('testScheduledApex',
        ASI_LUX_InactiveSalesAccountNotify.CRON_EXP, 
        new ASI_LUX_InactiveSalesAccountNotify());
        
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