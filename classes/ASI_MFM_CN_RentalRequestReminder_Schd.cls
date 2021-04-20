global without sharing class ASI_MFM_CN_RentalRequestReminder_Schd implements Schedulable{

    global void execute(SchedulableContext sc) {
        database.executebatch(new ASI_MFM_CN_RentalRequestReminder_Batch());
    }
}