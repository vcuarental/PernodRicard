global without sharing class ASI_eForm_KR_LRSchd implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        Integer LRRe1 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For LR Reminder').ASI_KR_numOfDays1__c);
        Integer LRRe2 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For LR Reminder').ASI_KR_numOfDays2__c);
        if(ASI_KR_Schd_Setting__c.getValues('For LR Reminder').ASI_KR_isActivate__c)
        	database.executebatch(new ASI_eForm_KR_leaveRemind(LRRe1,LRRe2));
    }//end method: excute
}//end class