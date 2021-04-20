global with sharing class ASI_MFM_PH_ClosingPOEmailReminder_Sche implements Schedulable {
/********************************
 * Created by: Linus @Introv    
 * Created Date: 2018-06-17
 * Objective: Schedule job to send reminder to PO owner to close PO 
 * Module: MFM PH
******************************/
    public void execute(SchedulableContext SC){
        system.debug('execute start');
        init();
        system.debug('execute end');
    }    
    
    public void init(){
        system.debug('Start Reminder Email scheduler');        
                
        database.executeBatch(new ASI_MFM_PH_ClosingPOEmailReminder_Batch());
    }
}