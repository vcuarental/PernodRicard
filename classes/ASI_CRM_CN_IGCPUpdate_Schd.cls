global without sharing class ASI_CRM_CN_IGCPUpdate_Schd implements Schedulable{
	global void execute(SchedulableContext sc) {
        database.executebatch(new ASI_CRM_CN_IGCPUpdate_Batch());
    }
}