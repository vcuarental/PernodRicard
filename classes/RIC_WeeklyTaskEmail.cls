/**
* 22/05/2015 Vitaly Borysenko - Transform Schedulable job into Batch
*/
global class RIC_WeeklyTaskEmail implements Database.Batchable<SObject> {
    
    @TestVisible
    private static final Integer EMAIL_CNT = 200;
    public Set<Id> userIds = new Set<Id>();
    // TMA Ricard plann'R 149 Paul start
    
    
        /**
    * Prepare data
    * @param info Batch job
    * @return res
    */
    global Iterable<SObject> start(Database.BatchableContext info){
        
        Set<String> overallStatuses = new Set<String>{'Late None', 'Late In Progress'};
            DateTime expired = System.now().addYears(-1);
        List<Milestone1_Task__c> listMilestone1Tasks = [SELECT Id, Assigned_To__c, Overall_Status__c ,Project_Milestone__r.Project__r.RecordType.DeveloperName
                                                        FROM Milestone1_Task__c 
                                                        WHERE LastModifiedDate > :expired AND (Overall_Status__c = 'Late None' OR Overall_Status__c = 'Late In Progress')
                                                        AND RIC_Status__c = 'En Cours' ]; //Ticket 150 AHA
        return listMilestone1Tasks;
    }
    
        /**
    * Send emails to users
    * @param info Batch job
    * @param scope List whom send email
    */
    global void execute(Database.BatchableContext info, List<SObject> scope){
        
        List<Id> actionsIds = new List<Id>();
        // TMA Ricard plann'R 149 Paul start
        if(scope != null) 
        {
            // Les lignes de codes suivantes ont été mise en commmentaire afin de garder un backup pour utilisation ulterieure
            /*for(SObject sObj : scope)
            {
                Milestone1_Task__c milestone1Task = (Milestone1_Task__c) sObj;
                if(!userIds.contains(milestone1Task.Assigned_To__c)) 
                {
                    userIds.add(milestone1Task.Assigned_To__c);
                }
                actionsIds.add(milestone1Task.Id);
            }*/
            // TMA Ricard plann'R 149 Paul start
            for(SObject sObj : scope){
                Milestone1_Task__c milestone1Task = (Milestone1_Task__c) sObj;
                if (milestone1Task.Project_Milestone__r.Project__r.RecordType.DeveloperName!=Label.RIC_PRF_OPP_ou_Kit_OPP )
                {
                    if(!userIds.contains(milestone1Task.Assigned_To__c))
                    {
                        userIds.add(milestone1Task.Assigned_To__c);
                    }
                    actionsIds.add(milestone1Task.Id);
                }
            }
            // TMA Ricard plann'R 149 Paul end
        }
        
        List<RIC_Acteur__c> listOfActeurs = [SELECT Id, RIC_Acteur_User__c, RIC_Action__c 
                                             FROM RIC_Acteur__c 
                                             WHERE RIC_Action__c IN :actionsIds];
        // TMA Ricard plann'R 149 Paul start
        if(listOfActeurs != null){
            for(RIC_Acteur__c acteur : listOfActeurs) {
                if(!userIds.contains(acteur.RIC_Acteur_User__c)) {
                    userIds.add(acteur.RIC_Acteur_User__c);
                }
            }   
        }
        // TMA Ricard plann'R 149 Paul end
        List<user> listOfuser = new list<user>();
        // TMA Ricard plann'R 149 Paul start
        Set<Id> allUserIds=new Set<Id>(userIds);
        for(Id userId : allUserIds){
            user u = new user();
            u.id=userId;
            if(allUserIds.contains(u.id))
            {
                u.RIC_SendEmail__c=true;
            }
            listOfuser.add(u);
        }
        // TMA Ricard plann'R 149 Paul start
        if(listOfuser!=null && listOfuser.size()>0){
            update listOfuser;
        }
    }
    
    /**
    * Required batch finish method
    * @param info Batch job
    */ 
    // TMA Ricard plann'R 149 Paul start
    global void finish(Database.BatchableContext info){
        List<user> userIds = [Select id,RIC_SendEmail__c,RIC_SendEmailOpp__c
                              from user
                              where RIC_SendEmail__c=true];
        List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();
        for(user userId : userIds){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();   
            system.debug('userId '+userId);
            if(userId.RIC_SendEmail__c==true)
            {
                system.debug('test1###');
                email.setTemplateId(Label.RIC_WeeklyTaskEmail_ID);
                email.setSaveAsActivity(false);            
                email.setTargetObjectId(userId.id);
                listEmails.add(email);
                userId.RIC_SendEmail__c=false;
            }
        }
        // TMA Ricard plann'R 149 Paul end
        Messaging.sendEmail(listEmails);
        update userIds;
        
    }   
}