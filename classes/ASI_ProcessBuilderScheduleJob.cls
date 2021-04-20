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

public class ASI_ProcessBuilderScheduleJob implements Schedulable {
    // id of the process builder schedule record that controls this job
    private ID recordId { get; set; }

    public ASI_ProcessBuilderScheduleJob( ID recordId ) {
        this.recordId = recordId;
    }

    public void execute( SchedulableContext context ) {

        Boolean abortJob = false;

        List<ASI_Process_Builder_Schedule__c> records = new List<ASI_Process_Builder_Schedule__c>([
            SELECT
                Id, Name, ASI_Active__c, ASI_Cron_Expression__c , ASI_Job_Name__c , ASI_Process_API_Name__c , ASI_Times_Triggered__c, ASI_Batch_Job_API_Name__c , ASI_Batch_Job_Id__c
            FROM
                ASI_Process_Builder_Schedule__c
            WHERE
                id = :this.recordId
            LIMIT 1
        ]);

        if ( records.size() > 0 ) {

            ASI_Process_Builder_Schedule__c record = records[0];

            if ( record.ASI_Active__c ) {

                System.debug( 'Updating record to fire process builder: ' + record );

                record.ASI_Times_Triggered__c ++;
                
                //if the Batch Job API Name field is filled, the batch job should be executed
                if(record.ASI_Batch_Job_API_Name__c!=null){
                            
                            Type t = Type.forName(record.ASI_Batch_Job_API_Name__c);
                
                            if(t!=null){
                                
                                try{
                                    
                                    Object s = t.newInstance();
                                    ID batchprocessid = Database.executeBatch((Database.Batchable<sObject>)s);
                                    record.ASI_Batch_Job_Id__c = batchprocessid;
                                
                                    
                                }catch(exception ex){
                                    
                                    system.debug('Batch Job issue: '+ ex.getMessage());
                                }
                            }   
                            
                }
                

                update record;

            } else {

                System.debug( 'Record is inactive: ' + record );

                abortJob = true;

            }

        } else {

            System.debug( 'No record found by id: ' + this.recordId );

            abortJob = true;

        }

        if ( abortJob ) {

            System.debug( 'Aborting job: recordId=' + this.recordId + ', jobId=' + context.getTriggerId() );

            System.abortJob( context.getTriggerId() );

        }

    }

}