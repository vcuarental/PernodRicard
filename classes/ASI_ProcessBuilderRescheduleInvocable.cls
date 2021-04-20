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

public class ASI_ProcessBuilderRescheduleInvocable {

    @InvocableMethod( label = 'Reschedule Jobs' )
    public static List<String> rescheduleJobs( List<ID> processBuilderScheduleIds ) {

        System.debug( 'Rescheduling jobs: ' + processBuilderScheduleIds );
        
        ASI_ProcessBuilderScheduleAbortInvocable.abortJobs( processBuilderScheduleIds );

        List<String> jobIds = ASI_ProcessBuilderScheduleInvocable.scheduleJobs( processBuilderScheduleIds );
        
        System.debug( 'Rescheduled job ids: ' + jobIds );
        
        return jobIds;
    }
    
}