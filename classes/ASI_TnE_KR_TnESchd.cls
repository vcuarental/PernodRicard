global without sharing class ASI_TnE_KR_TnESchd implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        Integer TnERe1 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For TnE Reminder').ASI_KR_numOfDays1__c);
        Integer TnERe2 = Integer.valueOf(ASI_KR_Schd_Setting__c.getValues('For TnE Reminder').ASI_KR_numOfDays2__c);
        if(ASI_KR_Schd_Setting__c.getValues('For TnE Reminder').ASI_KR_isActivate__c)
        	database.executebatch(new ASI_TnE_KR_remindTnE(TnERe1,TnERe2));
    }//end method: excute
}//end class