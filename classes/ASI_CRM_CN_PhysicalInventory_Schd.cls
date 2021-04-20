global without sharing class ASI_CRM_CN_PhysicalInventory_Schd implements Schedulable{
	global void execute(SchedulableContext sc) {
        database.executebatch(new ASI_CRM_CN_PhysicalInventory_Batch());
    }
}