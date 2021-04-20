global without sharing class ASI_TnE_KR_remindTnE implements Database.Batchable<sObject> ,Database.Stateful
{
	Set<Id> headerId = new Set<Id>();
    Date todayDate;
    Date before15Days;
    Date before30Days;
    global ASI_TnE_KR_remindTnE(Integer day1, Integer day2)
    {
        todayDate = date.today();
        before15Days = todayDate.addDays(day1);
        before30Days = todayDate.addDays(day2);
    }//end method
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<ASI_TnE_ClaimHeader__c> pendingTnE = new List<ASI_TnE_ClaimHeader__c>
            ([SELECT Id FROM ASI_TnE_ClaimHeader__c 
              WHERE ASI_TnE_Status__c like 'Submitted' 
              AND (RecordType.DeveloperName like 'ASI_TnE_KR_TnE' OR RecordType.DeveloperName like 'ASI_TnE_KR_Cash')]);
        for(ASI_TnE_ClaimHeader__c obj : pendingTnE)
            headerId.add(obj.Id);
        return Database.getQueryLocator([SELECT Actor.Email,
                                         CreatedDate,
                                         ProcessInstance.TargetObjectId
                                         FROM ProcessInstanceWorkitem 
                                         WHERE ProcessInstance.TargetObjectId IN: headerId
                                         AND ProcessInstance.Status like 'Pending'
                                         Order By CreatedDate ASC]);
    }//end method
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<ProcessInstanceWorkitem> approvalList = (List<ProcessInstanceWorkitem>)scope;
        Map<Id,String> objectMapEmail = new Map<Id,String>();
        Map<Id,Id> objectMapUser = new Map<Id,Id>();
        for (ProcessInstanceWorkitem p:approvalList)
        {
            Date checkDate = Date.NewInstance(p.CreatedDate.year(), p.CreatedDate.month(), p.CreatedDate.day());
            if((checkDate == before15Days || checkDate == before30Days)
               && !objectMapEmail.containsKey(p.ProcessInstance.TargetObjectId))
            {
                objectMapEmail.put(p.ProcessInstance.TargetObjectId,p.Actor.Email);
                objectMapUser.put(p.ProcessInstance.TargetObjectId,p.Actor.Id);
            }//end if
        }//end for
        EmailTemplate template = [SELECT id FROM EmailTemplate WHERE developername = 'ASI_TnE_KR_TnE_Approval_Reminder'];
        OrgWideEmailAddress owe = [SELECT ID FROM OrgWideEmailAddress WHERE DisplayName like 'IT Service Desk'];
        
        Messaging.SingleEmailMessage[] mailList = new Messaging.SingleEmailMessage[]{};
        for(Id objId : objectMapEmail.keySet())
        {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setOrgWideEmailAddressId(owe.Id);
            message.setToAddresses(new String[] {objectMapEmail.get(objId)});
            message.setTargetObjectId(objectMapUser.get(objId));
            message.setWhatId(objId);
            message.setTemplateId(template.id);
            message.setSaveAsActivity(false);
            mailList.add(message);
        }//end for
        Messaging.sendEmail(mailList);
    }//end method
    
    global void finish(Database.BatchableContext BC)
    {}//end method: finish
}