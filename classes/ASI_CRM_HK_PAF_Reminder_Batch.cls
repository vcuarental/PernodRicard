global without sharing class ASI_CRM_HK_PAF_Reminder_Batch implements Database.Batchable<sObject>, Database.Stateful{   
    private Set<ID> ids = new Set<ID>();
    private String body;
    
    private static Integer reminderDaysAfter = 7;
    private static String objectName = 'ASI_HK_CRM_Pre_Approval_Form__c';
    private static String piStatus = 'Pending';
    
    public ASI_CRM_HK_PAF_Reminder_Batch(){
        // this.ids = ids;
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query;
        query = 'SELECT id,ActorId,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.ProcessDefinition.TableEnumOrId = :objectName AND ProcessInstance.Status = :piStatus AND ElapsedTimeInDays >= :reminderDaysAfter';
        if (Test.isRunningTest()){
            query = 'SELECT id,ActorId,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.ProcessDefinition.TableEnumOrId = :objectName AND ProcessInstance.Status = :piStatus AND ElapsedTimeInDays >= 0';
        }        
        return Database.getQueryLocator(query);
    }
    
    //Subject You have a new PAF approval request: {!ASI_HK_CRM_Pre_Approval_Form__c.Name} - {!ASI_HK_CRM_Pre_Approval_Form__c.ASI_HK_CRM_PAF_Customer__c}
    
    global void execute(Database.BatchableContext BC, List<ProcessInstanceWorkitem> scope)
    {
        
        List<User> HKUsersIDs = [SELECT id from User WHERE CompanyName LIKE '%Hong Kong%'];
        Set<ID> ActualApproversID = new Set<ID>();
        Set<ID> pafIds = new Set<ID>();
        
        //scope = PendingApprovals
        for (ProcessInstanceWorkitem piwi : scope){
            for (User u : HKUsersIDs){
                if (u.id == piwi.ActorId){
                    ActualApproversID.add(piwi.ActorId);
                    pafIds.add(piwi.ProcessInstance.TargetObjectId);
                }
            }
        }
        
        
        for (ID approverID : ActualApproversID){
            body = '';
            system.debug('Current Approver: '+approverID);
            body = 'You have a pending pre-approval form approval request, click the link to see the detail:\n';
            
            for (ProcessInstanceWorkitem piwi : scope){
                if (approverID == piwi.ActorId){
                    body = body + URL.getSalesforceBaseUrl().toExternalForm()+'/'+ String.valueof(piwi.ProcessInstance.TargetObjectId)+'\n' ;
                    //system.debug(body);
                }
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            //email.setToAddresses()
            email.toAddresses = new String[] {approverID};
                email.setSaveAsActivity(false);
            email.setSenderDisplayName('Salesforce Support');
            email.setSubject('You have a pending PAF approval request(s) ');
            
            if (Test.isRunningTest()){
                email.setPlainTextBody('Testing');
            }else{
                email.setPlainTextBody(body);
            }
            if (!Test.isRunningTest()){
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                
            }
            
        }
        
        
        
    }
    
    global void finish(Database.BatchableContext BC)
    { }
}