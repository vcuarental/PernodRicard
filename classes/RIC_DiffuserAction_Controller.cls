public class RIC_DiffuserAction_Controller {
	
    public Milestone1_Task__c ricTask {get; set;}
    public List<RIC_Acteur__c> listActeurs;
    public List<String> usersIdsToNotify = new List<String>();
    public String errorMsg {get; private set;}
    
    public RIC_DiffuserAction_Controller(ApexPages.StandardController std) {
        ricTask = [SELECT Id, Name, Project_Milestone__r.Project__r.RIC_Coordinateur__c, Assigned_To__c,
                   RIC_Nom_du_projet__c, RIC_Marque__c, RIC_Date_MAD_previ__c, RIC_Phase_Value__c,
                   Due_Date__c, Project_Milestone__r.Project__r.RIC_Status__c, Project_Milestone__r.Project__c
                   FROM Milestone1_Task__c 
                   WHERE Id = :std.getId()];
        
        String currentUserId = UserInfo.getUserId();
        if(!currentUserId.equals(ricTask.Project_Milestone__r.Project__r.RIC_Coordinateur__c)){
            errorMsg = Label.RIC_DiffuserAction_CoordinateurError;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
            ApexPages.addMessage(msg);
        }
        else if(!'Validé'.equals(ricTask.Project_Milestone__r.Project__r.RIC_Status__c) && !'En cours'.equals(ricTask.Project_Milestone__r.Project__r.RIC_Status__c)) {
            errorMsg = Label.RIC_DiffuserAction_StatusError;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
            ApexPages.addMessage(msg);
        }
    }
    
    public void diffuserAction() {
        usersIdsToNotify = getUsersToNotify();
        sendEmailMessages(usersIdsToNotify);
    }
    
    public List<String> getUsersToNotify() {
        
        List<String> usersToNotify = new List<String>();
        listActeurs = [SELECT Id, RIC_Acteur_User__c 
                       FROM RIC_Acteur__c 
                       WHERE RIC_Action__c = :ricTask.Id];
        
        for(RIC_Acteur__c acteur : listActeurs) {
			usersToNotify.add(acteur.RIC_Acteur_User__c); 
        }
        usersToNotify.add(ricTask.Assigned_To__c);
        
        return usersToNotify;
    }
    
    public PageReference sendEmailMessages(List<String> usersIds) {
        
        EmailTemplate vfEmailTemplate = [Select id 
                                         FROM EmailTemplate 
                                         WHERE Name = 'RIC_Action_Diffusee_Notif' LIMIT 1];
        
        List<Messaging.SingleEmailMessage> allmsgs = new List<Messaging.SingleEmailMessage>();
        if(vfEmailTemplate != null) {
            for(String userId : usersIds) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setWhatId(ricTask.Id);
                mail.setTreatTargetObjectAsRecipient(true);
                mail.setTargetObjectId(userId);
                mail.setTemplateId(vfEmailTemplate.Id);
                mail.setSaveAsActivity(false);
                allmsgs.add(mail);
            }
        }        
        try{
            Messaging.sendEmail(allmsgs, false);
            
            //Pass the Project status to 'En Cours'
            ricTask.RIC_Status__c = 'En cours';
            update ricTask;
            
            //Milestone1_Project__c projectToUpdate = new Milestone1_Project__c();
            //projectToUpdate.Id = ricTask.Project_Milestone__r.Project__c;
            //projectToUpdate.RIC_Status__c = 'En cours';
            //update projectToUpdate;
            
            errorMsg = Label.RIC_DiffuserAction_Success;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Confirm, errorMsg);
            ApexPages.addMessage(msg);
        }
        catch(Exception e) {
            System.debug('### EXCEPTION: ' + e.getMessage());
            errorMsg = e.getMessage();
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
            ApexPages.addMessage(msg);
        }
        return null;
    }
    
    public PageReference annuler() {
        PageReference pageRef = new PageReference('/' + ricTask.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
}