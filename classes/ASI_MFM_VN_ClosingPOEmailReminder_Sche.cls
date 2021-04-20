/***************************************************************************************************************************
 * Name:        ASI_MFM_VN_ClosingPOEmailReminder_Sche
 * Description: Schedule job to send reminder to PO owner to close PO 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-2-11       Calvin Chiu (LAPUTA)     Cloned from ASI_MFM_PH_ClosingPOEmailReminder_Sche
 ****************************************************************************************************************************/
global with sharing class ASI_MFM_VN_ClosingPOEmailReminder_Sche implements Schedulable {
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
                
        database.executeBatch(new ASI_MFM_VN_ClosingPOEmailReminder_Batch());
    }
}