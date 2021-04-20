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

public class ASI_ProcessBuilderScheduleAbortInvocable {

    @InvocableMethod( label = 'Abort Jobs' )
    public static void abortJobs( List<ID> processBuilderScheduleIds ) {
        
        List<ASI_Process_Builder_Schedule__c> records = new List<ASI_Process_Builder_Schedule__c>([
            SELECT
                Id, Name, ASI_Active__c, ASI_Cron_Expression__c , ASI_Job_Name__c , ASI_Process_API_Name__c , ASI_Times_Triggered__c, ASI_Batch_Job_API_Name__c , ASI_Batch_Job_Id__c
            FROM
                ASI_Process_Builder_Schedule__c
            WHERE
                id IN :processBuilderScheduleIds
        ]);
        
        System.debug( 'Aborting process schedules: ' + records );
        
        if ( records.size() > 0 ) {
            
            Set<String> jobNames = new Set<String>();
            for ( ASI_Process_Builder_Schedule__c record : records ) {
                jobNames.add( record.ASI_Job_Name__c );
                if(record.ASI_Batch_Job_Id__c!=null){
                    jobNames.add(record.ASI_Batch_Job_Id__c);
                }
            }
            
            for ( List<CronTrigger> cronTriggers : [
				SELECT
                	id, state, cronJobDetail.name
               	FROM
                	CronTrigger
                WHERE
                	cronJobDetail.name IN :jobNames
            ]) {
                
                System.debug( 'CronTriggers to abort: ' + cronTriggers );
                
                for ( CronTrigger cronTrigger : cronTriggers ) {
                    
                    try {
                        
                        System.debug( 'Aborting job: ' + cronTrigger );
                        System.abortJob( cronTrigger.id );
                        
                    } catch ( Exception e ) {
                        
                        System.debug( LoggingLevel.ERROR, 'Error trying to abort job: ' + cronTrigger + ': ' + e.getStackTraceString() );
                        
                    }
                    
                }
                
            }

        }
        
    }
    
}