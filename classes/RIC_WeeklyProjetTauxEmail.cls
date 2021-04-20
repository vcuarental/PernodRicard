/*
Description: Cette classe envoie un mail au coordinateur contenant la liste des projets avec un taux d'avancement <100%
Author: Joyce Saidy
Date: 06/05/2019
version 1.0
Test class: RIC_WeeklyProjetTauxEmail_Test
*/
global class RIC_WeeklyProjetTauxEmail implements Database.Batchable<SObject> {
    private final List<Milestone1_Project__c> listMilestone1project;
    public Set<Id> userIds = new Set<Id>(); 
    global Iterable<SObject> start(Database.BatchableContext info){  
        List<Milestone1_Project__c > listMilestone1project = [select id,RIC_Coordinateur__c from Milestone1_Project__c where RIC_ClosingRate__c <100 and RIC_Status__c='En cours' ]; 
        return listMilestone1project;
    }
    
    /**
     * Send emails to users
     * @param info Batch job
     * @param scope List whom send email
     */
    global void execute(Database.BatchableContext info, List<SObject> scope){
        
        List<Id> ProjectIds = new List<Id>();
        if(scope != null) {
            for(SObject sObj : scope){
                Milestone1_Project__c Milestone1project = (Milestone1_Project__c) sObj;
                if(!userIds.contains(Milestone1project.RIC_Coordinateur__c)) {
                    userIds.add(Milestone1project.RIC_Coordinateur__c);
                }
                ProjectIds.add(Milestone1project.Id);
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
            system.debug('listOfuser####'+listOfuser);
            update listOfuser;
        }
    }
    
    /**
     * Required batch finish method to send email
     * @param info Batch job
     */ 
    global void finish(Database.BatchableContext info){
        List<user> userIds = [Select id,RIC_SendEmail__c
                              from user
                              where RIC_SendEmail__c=true];
        emailTemplate emailTemp= [select id from emailtemplate where name =:Label.RIC_Weekly_Taux_Projet];
        List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();
        for(user userId : userIds){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();            
            email.setTemplateId(emailTemp.id);
            email.setSaveAsActivity(false);            
            email.setTargetObjectId(userId.id);
            listEmails.add(email);
            userId.RIC_SendEmail__c=false;
        }
        Messaging.sendEmail(listEmails);
        update userIds;
        
    } 
    
}