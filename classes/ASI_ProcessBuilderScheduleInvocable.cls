/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Elufa PRA Support                                                                
+-----------------------+------------------------------------------------------------------------------------+
| Description           | For ASI_Process_Builder_Schedule__c                                                                         
|                       |                                                                                    
|     - Object(s)       |  * Purpose is to periodically update the Process Builder Schedule record
|                       |  * associated with this job instance. The update simply increments the times
|                       |  * triggered counter for no other reason than to cause Process Builder to
|                       |  * run on this record.                                                                         
|     - Description     |                           
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 18/1/2017                                                                      
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    
+-----------------------+------------------------------------------------------------------------------------+
*/

public class ASI_ProcessBuilderScheduleInvocable {

    @InvocableMethod( label = 'Schedule Jobs' )
    public static List<String> scheduleJobs( List<ID> processBuilderScheduleIds ) {

        List<ASI_Process_Builder_Schedule__c> records = new List<ASI_Process_Builder_Schedule__c>([
            SELECT
                Id, Name, ASI_Active__c, ASI_Cron_Expression__c , ASI_Job_Name__c , ASI_Process_API_Name__c , ASI_Times_Triggered__c, ASI_Batch_Job_API_Name__c , ASI_Batch_Job_Id__c
            FROM
                ASI_Process_Builder_Schedule__c
            WHERE
                id IN :processBuilderScheduleIds
                AND
                ASI_Active__c = true
        ]);
        
        System.debug( 'Scheduling processes: ' + records );

        List<String> jobIds = new List<String>();

        if ( records.size() > 0 ) {

            // before schedule the job, look to see
            // if the job has already been scheduled
            
            Set<String> jobNames = new Set<String>();
            for ( ASI_Process_Builder_Schedule__c record : records ) {
                jobNames.add( record.ASI_Job_Name__c );
            }
            
            Set<String> cronJobNames = new Set<String>();
            for ( CronTrigger cronTrigger : [
				SELECT
                	id, state, cronJobDetail.name
               	FROM
                	CronTrigger
                WHERE
                	cronJobDetail.name IN :jobNames
            ]) {
                cronJobNames.add( cronTrigger.cronJobDetail.name );
            }
            
            for ( ASI_Process_Builder_Schedule__c record : records ) {

                // if job has not already been scheduled then schedule it
                if ( !cronJobNames.contains( record.ASI_Job_Name__c ) ) {
                
                    System.debug( 'Scheduling job: ' + record );
                    
                    String jobId = System.schedule(
                        record.ASI_Job_Name__c,
                        record.ASI_Cron_Expression__c,
                        new ASI_ProcessBuilderScheduleJob( record.id )
                    );
    
                    jobIds.add( jobId );
                    
                } else {
                    
                    System.debug( LoggingLevel.WARN, 'Job has already been scheduled: ' + record.ASI_Job_Name__c );
                    
                }

            }

        }

        return jobIds;
    }
    
}