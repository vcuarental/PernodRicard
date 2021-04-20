@isTest(SeeAllData=false)
private class ASI_CRM_CN_PnD_NearEnd_Effective_Test {

    @isTest
    private static void TestData(){

        User tempU = [select id,ManagerID from user where CompanyName = 'Pernod Ricard China' and ManagerID !=null limit 1];

        ASI_CRM_AccountsAdditionalField__c c = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_JDE_Code__c = 'asd');
        insert c;

        Date testDate = date.today().addDays(2);

        ASI_CRM_Price_And_Discount__c pnd = new ASI_CRM_Price_And_Discount__c();
        pnd.ASI_CRM_Status__c = 'Completed';
        pnd.ASI_CRM_Effective_To__c = testDate;
        pnd.ASI_CRM_Customer__c = c.id;
        pnd.RecordTypeId  = Schema.SObjectType.ASI_CRM_Price_And_Discount__c.getRecordTypeInfosByDeveloperName().get('ASI_CRM_CN_Customer_Price_and_Discount_Request_RO').getRecordTypeId();
        pnd.ownerid = tempU.id;
        
        insert pnd;

        List<sObject> sList = new List<sObject>();
        sList.add(pnd);

        Test.startTest();

        ASI_CRM_CN_PnD_NearEnd_EffectiveDate cb = New ASI_CRM_CN_PnD_NearEnd_EffectiveDate();

        Database.QueryLocator ql = cb.start(null);
        cb.execute(null,sList);
        cb.Finish(null);

        //DataBase.executeBatch(ql);

        Test.stopTest();

    }

    /*
    static testMethod void TestSchedulableClass() {


        Test.startTest(); // Start Test
        // Schedule the test job
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        String jobId = System.schedule('My batch Job', CRON_EXP, new ASI_CRM_CN_PnD_Scheduler_NearEnd());

        // To track the progress of the scheduled job.
        CronTrigger ct = [SELECT TimesTriggered
                , NextFireTime
                , CronExpression
        FROM CronTrigger
        WHERE Id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,
                ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest(); // End Test
    }
    */

}