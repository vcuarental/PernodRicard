global without sharing class ASI_eForm_KR_CCSchd implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        Integer CCRe1 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For CC Reminder').ASI_KR_numOfDays1__c);
        Integer CCRe2 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For CC Reminder').ASI_KR_numOfDays2__c);
        if(ASI_KR_Schd_Setting__c.getValues('For CC Reminder').ASI_KR_isActivate__c)
        	database.executebatch(new ASI_eForm_KR_CCRemind(CCRe1,CCRe2));
    }//end method: excute
}//end class