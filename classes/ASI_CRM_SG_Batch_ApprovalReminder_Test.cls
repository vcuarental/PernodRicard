/***************************************************************************************************************************
 * Name:		ASI_CRM_SG_Batch_ApprovalReminder_Test
 * Description:	
 *
 * Version History
 * Date				Developer				Comments
 * ---------------	--------------------	--------------------------------------------------------------------------------
 * 2017-11-XX		Jeffrey Cheung          Created				
 ****************************************************************************************************************************/
@isTest(SeeAllData=false)
private class ASI_CRM_SG_Batch_ApprovalReminder_Test {
    @isTest
	private static void testContract() {
	    // create record here...
	   // ASI_CRM_SG_TestClassHelper.createDataSettings();
        // new ASI_CRM_SG_TestClassHelper.contractData().contract;
        
         ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.contractData cd = new ASI_CRM_SG_TestClassHelper.contractData(false, 'Draft');
        // meet Entry Criteria
        cd.contract.ASI_CRM_Sys_Allow_Submit_Approval__c = true;
        // set manager
        User u = ASI_CRM_SG_TestClassHelper.createUser();
        User manager = ASI_CRM_SG_TestClassHelper.createUser('manager');
        u.ManagerId = manager.Id;
        update u;
        // set owner
        cd.contract.OwnerId = u.Id;
        insert cd.contract;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(cd.contract.id);
                req1.setSubmitterId(u.id);
                Approval.ProcessResult result = Approval.process(req1);
        
        Test.startTest();

            DataBase.executeBatch(new ASI_CRM_SG_Batch_ApprovalReminder('Contract',0)); 
            
        Test.stopTest();

	}
    
    static testMethod void TestSchedulableClass() {

      Test.startTest(); // Start Test
          // Schedule the test job
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
        String jobId = System.schedule('My batch Job',
                         CRON_EXP, 
                         new ASI_CRM_SG_Scheduler_ApprovalReminder());
        
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
}