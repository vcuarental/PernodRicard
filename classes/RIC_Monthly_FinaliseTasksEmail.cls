/*
Description: Cette classe Envoie le 1er de chaque mois un mail auprès d'un contributeur qui contient la liste des taches dont le statut est " à finaliser"
Author: Joyce Saidy
Date: 10/06/2019
version 1.0
Test class: RIC_Monthly_FinaliseTasksEmail_Test
*/
global class RIC_Monthly_FinaliseTasksEmail implements Database.Batchable<SObject> {
    
    public Set<Id> userIds = new Set<Id>(); 
    global Iterable<SObject> start(Database.BatchableContext info){  
        DateTime expired = System.now().addYears(-1);
        List<Milestone1_Task__c > listMilestone1Tasks = [select Id, Assigned_To__c  from Milestone1_Task__c where 
                                                         LastModifiedDate > :expired AND RIC_Status__c =: Label.RIC_Task_Finalise]; 
        return listMilestone1Tasks;
    }
    
    /**
* Send emails to users
* @param info Batch job
* @param scope List whom send email
*/
    global void execute(Database.BatchableContext info, List<SObject> scope){ 
        List<Id> actionsIds = new List<Id>();
        if(scope != null) {
            for(SObject sObj : scope){
                Milestone1_Task__c milestone1Task = (Milestone1_Task__c) sObj;
                if(!userIds.contains(milestone1Task.Assigned_To__c)) {
                    userIds.add(milestone1Task.Assigned_To__c);
                }
                actionsIds.add(milestone1Task.Id);
            }
        } 
        List<RIC_Acteur__c> listOfActeurs = [SELECT Id, RIC_Acteur_User__c, RIC_Action__c FROM RIC_Acteur__c WHERE RIC_Action__c IN :actionsIds];
        if(listOfActeurs != null){
            for(RIC_Acteur__c acteur : listOfActeurs) {
                if(!userIds.contains(acteur.RIC_Acteur_User__c)) {
                    userIds.add(acteur.RIC_Acteur_User__c);
                }
            }   
        } 
        List<user> listOfuser = new list<user>();
        for(Id userId : userIds){
            user u = new user();
            u.id=userId;
            u.RIC_SendEmail__c=true;
            listOfuser.add(u);
        }
        if(listOfuser!=null && listOfuser.size()>0){
            update listOfuser;
        } 
    }  
    global void finish(Database.BatchableContext info){    
        List<user> userIds = [Select id,RIC_SendEmail__c
                              from user
                              where RIC_SendEmail__c=true];  
        emailTemplate MonthlyemailTemp= [select id from emailtemplate where name =:Label.RIC_Monthly_Finalise_Tasks_Acteurs];
        List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();
        for(user userId : userIds){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();            
            email.setTemplateId(MonthlyemailTemp.id);
            email.setSaveAsActivity(false);            
            email.setTargetObjectId(userId.id);
            listEmails.add(email);
            userId.RIC_SendEmail__c=false;
        } 
        Messaging.sendEmail(listEmails); 
        update userIds;
    } 
    
}