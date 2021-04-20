/**
* 2/12/2020 - Separate WeeklyTaskEmail and WeeklyTaskEmail_Opp schedulers
*/
global class RIC_WeeklyTaskEmail_Opp implements Database.Batchable<SObject> {
    
    @TestVisible
    private static final Integer EMAIL_CNT = 200;
    public set<Id> userIdsOpp=new Set<Id>();  
        
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
        
        List<Id> actionsIdsOpp=new List<Id>(); 
        if(scope != null) 
        {
            for(SObject sObj : scope){
                Milestone1_Task__c milestone1Task = (Milestone1_Task__c) sObj;
                if (milestone1Task.Project_Milestone__r.Project__r.RecordType.DeveloperName==Label.RIC_PRF_OPP_ou_Kit_OPP )
                {
                    if(!userIdsOpp.contains(milestone1Task.Assigned_To__c))
                    {
                        userIdsOpp.add(milestone1Task.Assigned_To__c);
                    }
                    actionsIdsOpp.add(milestone1Task.Id);
                }
            }
            // TMA Ricard plann'R 149 Paul end
        }
        List<RIC_Acteur__c> listOfActeursOpp = [SELECT Id, RIC_Acteur_User__c, RIC_Action__c 
                                             FROM RIC_Acteur__c 
                                             WHERE RIC_Action__c IN :actionsIdsOpp]; 
        if(listOfActeursOpp != null){
            for(RIC_Acteur__c acteur : listOfActeursOpp) {
                if(!userIdsOpp.contains(acteur.RIC_Acteur_User__c)) {
                    userIdsOpp.add(acteur.RIC_Acteur_User__c);
                }
            }   
        }
        // TMA Ricard plann'R 149 Paul end
        List<user> listOfuser = new list<user>();
        Set<Id> allUserIdsOpp=new Set<Id>(userIdsOpp);
        for(Id userId : allUserIdsOpp){
            user u = new user();
            u.id=userId;
            if(allUserIdsOpp.contains(u.id))
            {
                u.RIC_SendEmailOpp__c=true;
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
                              where RIC_SendEmailOpp__c=true];
        List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();
        for(user userId : userIds){
            Messaging.SingleEmailMessage email2 = new Messaging.SingleEmailMessage();   
            system.debug('userId '+userId);
            if(userId.RIC_SendEmailOpp__c==true)
            {
                 system.debug('test1###');
                email2.setTemplateId(Label.RIC_WeeklyTaskEmailOpp_ID);
                email2.setSaveAsActivity(false);            
                email2.setTargetObjectId(userId.id);
                listEmails.add(email2);
                userId.RIC_SendEmailOpp__c=false;
            }
        }
        Messaging.sendEmail(listEmails);
        update userIds;
        
    } 
}