/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Elufa PRA Support                                                                
+-----------------------+------------------------------------------------------------------------------------+
| Description           | Test Class For ASI_ASI_Process_Builder_Schedule__c                                                                         
|                       |                                                                                    
|     - Object(s)       |  * Purpose is to periodically update the Process Builder Schedule record
|                       |  * associated with this job instance. The update simply increments the times
|                       |  * triggered counter for no other reason than to cause Process Builder to
|                       |  * run on this record.                                                                         
|     - Description     |                           
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 20/1/2017                                                                      
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
*/
@isTest
private class ASI_ProcessBuilderScheduleJobTest {

    @isTest
    static void test_active() {
        
        Test.startTest();
            
        ASI_Process_Builder_Schedule__c record = new ASI_Process_Builder_Schedule__c(
            ASI_Process_Api_Name__c = 'MyProcess',
            ASI_Batch_Job_API_Name__c='ASI_MFM_KR_PORCProcess',
            ASI_Cron_Expression__c = '0 0 * * * ?',
            ASI_Active__c = true
        );
        
        insert record;
        
        ASI_ProcessBuilderScheduleInvocable.scheduleJobs(New id[]{record.Id} );
            
        Test.stopTest();
        
    }
    
    @isTest
    static void test_inactive() {

		Test.startTest();
        
        ASI_Process_Builder_Schedule__c record = new ASI_Process_Builder_Schedule__c(
            ASI_Process_Api_Name__c = 'MyProcess',
            ASI_Batch_Job_API_Name__c='ASI_MFM_KR_PORCProcess',
            ASI_Cron_Expression__c = '0 0 * * * ?',
            ASI_Active__c = true
        );
        
        insert record;
        
        record.ASI_Active__c = false;
        ASI_ProcessBuilderScheduleInvocable.scheduleJobs(New id[]{record.Id} );
        update record;
        ASI_ProcessBuilderScheduleAbortInvocable.abortJobs(New id[]{record.Id} );

        
        Test.stopTest();
        
    }
    
    @isTest
    static void test_reschedule() {

		Test.startTest();
        
        ASI_Process_Builder_Schedule__c record = new ASI_Process_Builder_Schedule__c(
            ASI_Process_Api_Name__c = 'MyProcess',
            ASI_Batch_Job_API_Name__c='ASI_MFM_KR_PORCProcess',
            ASI_Cron_Expression__c = '0 0 * * * ?',
            ASI_Active__c = true
        );
        
        insert record;
        ASI_ProcessBuilderScheduleInvocable.scheduleJobs(New id[]{record.Id} );
        record.ASI_Cron_Expression__c = '0 1 * * * ?';
        
        update record;
        ASI_ProcessBuilderRescheduleInvocable.rescheduleJobs(New id[]{record.Id} );
        Test.stopTest();
        
    }
    
    @isTest
    static void test_delete() {
        
		Test.startTest();
        
        ASI_Process_Builder_Schedule__c record = new ASI_Process_Builder_Schedule__c(
            ASI_Process_Api_Name__c = 'MyProcess',
            ASI_Batch_Job_API_Name__c='ASI_MFM_KR_PORCProcess',
            ASI_Cron_Expression__c = '0 0 * * * ?',
            ASI_Active__c = true
        );
        
        insert record;
        ASI_ProcessBuilderScheduleInvocable.scheduleJobs(New id[]{record.Id} );
        delete record;
        
        Test.stopTest();
        
    }

    @isTest
    static void test_batchjobSuccess() {
        
        Test.startTest();
        
        ASI_Process_Builder_Schedule__c record = new ASI_Process_Builder_Schedule__c(
            ASI_Process_Api_Name__c = 'MyProcess',
            ASI_Cron_Expression__c = '0 0 * * * ?',
            ASI_Active__c = true,
            ASI_Batch_Job_API_Name__c = 'ASI_MFM_KR_PORCProcess'
        );
        
        insert record;
        
        Test.stopTest();
        
    }

    @isTest
    static void test_batchjobFail() {
        
        Test.startTest();
        
        ASI_Process_Builder_Schedule__c record = new ASI_Process_Builder_Schedule__c(
            ASI_Process_Api_Name__c = 'MyProcess',
            ASI_Cron_Expression__c = '0 0 * * * ?',
            ASI_Active__c = true,
            ASI_Batch_Job_API_Name__c = 'MyBatchJob'
        );
        
        insert record;
        
        Test.stopTest();
        
    }    
}