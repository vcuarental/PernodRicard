global without sharing class ASI_eForm_KR_CTSchd implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        Integer CTRe1 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For CT Reminder').ASI_KR_numOfDays1__c);
        Integer CTRe2 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For CT Reminder').ASI_KR_numOfDays2__c);
        if(ASI_KR_Schd_Setting__c.getValues('For CT Reminder').ASI_KR_isActivate__c)
        	database.executebatch(new ASI_eForm_KR_CTRemind(CTRe1,CTRe2));
    }//end method: excute
}//end class