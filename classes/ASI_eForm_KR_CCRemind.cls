global without sharing class ASI_eForm_KR_CCRemind implements Database.Batchable<sObject> ,Database.Stateful
{
    Set<Id> ccId = new Set<Id>();
    Date todayDate;
    Date before5Days;
    Date before10Days;
    global ASI_eForm_KR_CCRemind(Integer day1, Integer day2)
    {
        todayDate = date.today();
        before5Days = todayDate.addDays(day1);
        before10Days = todayDate.addDays(day2);
    }//end method
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<ASI_eForm_CC_Request__c> pendingLeave = new List<ASI_eForm_CC_Request__c>
            ([SELECT Id FROM ASI_eForm_CC_Request__c WHERE ASI_eForm_Status__c like 'Submitted']);
        for(ASI_eForm_CC_Request__c leave : pendingLeave)
            ccId.add(leave.Id);
        
        return Database.getQueryLocator([SELECT Actor.Email,
                                         CreatedDate,
                                         ProcessInstance.TargetObjectId
                                         FROM ProcessInstanceWorkitem 
                                         WHERE ProcessInstance.TargetObjectId IN: ccId
                                         AND ProcessInstance.Status like 'Pending'
                                         Order By CreatedDate ASC]);
    }//end method
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<ProcessInstanceWorkitem> approvalList = (List<ProcessInstanceWorkitem>)scope;
        Map<Id,String> objectMapEmail = new Map<Id,String>();
        for (ProcessInstanceWorkitem p:approvalList)
        {
            Date checkDate = Date.NewInstance(p.CreatedDate.year(), p.CreatedDate.month(), p.CreatedDate.day());
            if(checkDate == before5Days || checkDate == before10Days)
            {
                if(!objectMapEmail.containsKey(p.ProcessInstance.TargetObjectId))
                {
                    objectMapEmail.put(p.ProcessInstance.TargetObjectId,p.Actor.Email);
                }
            }
        }
        
        Map<Id,ASI_eForm_CC_Request__c> header = new Map<Id,ASI_eForm_CC_Request__c>
            ([SELECT Name FROM ASI_eForm_CC_Request__c WHERE Id IN: objectMapEmail.keySet()]);
        
        OrgWideEmailAddress owe = [SELECT ID FROM OrgWideEmailAddress WHERE DisplayName like 'IT Service Desk'];
        
        Messaging.SingleEmailMessage[] mailList = new Messaging.SingleEmailMessage[]{};
        
        for(Id objId : objectMapEmail.keySet())
        {
            String URLLink = URL.getSalesforceBaseUrl().toExternalForm()   + '/' + objId;
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setsubject('Congratulatory & Condolatory Request Pending for Approval');
            message.setOrgWideEmailAddressId(owe.Id);
            String msgBody = 'Please note that a Congratulatory & Condolatory Request Request is pending for your approval: ';
            msgBody+='<br/><p>안녕하세요. 귀하는 아직 해당 요청서 를 승인하지 않았습니다.  신속히 승인을 진행하여 주시기 바랍니다:<br/>';
            msgBody+='<br/>Congratulatory & Condolatory Request: '+header.get(objId).Name;
            msgBody+='<br/><p>Please click the following URL for action:<br/>';
            msgBody+='<a href=\"'+URLLink+'\">'+URLLink+'</a>' + '\n' ;
            message.sethtmlBody(msgBody);
            if(objectMapEmail.get(objId) != NULL && objectMapEmail.get(objId) != ''){
            	message.setToAddresses(new String[] {objectMapEmail.get(objId)});
            	mailList.add(message);
            }
        }//end for
        Messaging.sendEmail(mailList);
    }//end method
    
    global void finish(Database.BatchableContext BC)
    {}//end method: finish
}//end class