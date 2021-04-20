/**
* @Author: Bilal El Aly
* Test Class: RIC_updateTasksAfterButtonClick_Test
* Code Coverage from RIC_updateTasksAfterButtonClick_Test.testApprovalSuccess(): 95%
*/
public class RIC_AP01_Milestone1Project {
    
    public static void updateRelatedTasks(Map<Id,Milestone1_Project__c> oldMap, Map<Id,Milestone1_Project__c> newMap) {
        
        Set<Id> myId = new Set<Id>();
        List<Milestone1_Task__c> listTasksToUpdate = new List<Milestone1_Task__c>();
        Map<Id, Milestone1_Project__c> projectsMap = new Map<Id, Milestone1_Project__c>();
        
        for(Milestone1_Project__c pr : newMap.values()){
            if(pr.RIC_Task_Status__c == 'Sent' || (oldMap.containsKey(pr.Id) && oldMap.get(pr.Id).RIC_Status__c != pr.RIC_Status__c && 'Annulé'.equalsIgnoreCase(pr.RIC_Status__c))) {
                projectsMap.put(pr.Id, pr);
            }
        }
        
        //Update the related tasks according to the Project status
        if(projectsMap.size() > 0) {
            List<Milestone1_Task__c> allTasksForProjects = [SELECT id, RIC_Task_Sent__c, RIC_Status__c, RIC_IsPickVal__c, Project_Milestone__r.Project__c
                                                            FROM Milestone1_Task__c 
                                                            WHERE Milestone1_Task__c.Project_Milestone__r.Project__c IN :projectsMap.keySet()];
            
            Map<String, List<Milestone1_Task__c>> mapProjectAndTasks = new Map<String, List<Milestone1_Task__c>>();
            if(allTasksForProjects != null && allTasksForProjects.size() > 0) {
                for(Milestone1_Task__c cTask : allTasksForProjects) {
                    if(mapProjectAndTasks.containsKey(cTask.Project_Milestone__r.Project__c))
                        mapProjectAndTasks.get(cTask.Project_Milestone__r.Project__c).add(cTask);
                    else
                        mapProjectAndTasks.put(cTask.Project_Milestone__r.Project__c, new List<Milestone1_Task__c> {cTask});
                }
                
                for(Milestone1_Project__c pr : projectsMap.values()){
                    List<Milestone1_Task__c> listProjectTasks = mapProjectAndTasks.get(pr.Id);
                    if(listProjectTasks != null && listProjectTasks.size() > 0) {
                        for(Milestone1_Task__c cTask : listProjectTasks) {
                            boolean updateTask = false;
                            if('True'.equalsIgnoreCase(cTask.RIC_IsPickVal__c) && pr.RIC_Task_Status__c == 'Sent'){
                                cTask.RIC_Task_Sent__c = 'Yes';
                                updateTask = true;
                            }
                            if(!'Annulé'.equalsIgnoreCase(cTask.RIC_Status__c) && 'Annulé'.equalsIgnoreCase(pr.RIC_Status__c) && !'Réalisé'.equalsIgnoreCase(cTask.RIC_Status__c)){
                                cTask.RIC_Status__c = 'Annulé';
                                updateTask = true;
                            }
                            if(updateTask)
                                listTasksToUpdate.add(cTask);
                        }
                    }
                }
                
                if(listTasksToUpdate.size() > 0) {
                    update listTasksToUpdate; 
                }                      
            }
        }
    }
    
    public static void checkProjectEditPermission(Map<Id,Milestone1_Project__c> oldMap, List<Milestone1_Project__c> newProjects){
        
        String userId = UserInfo.getUserId();
        for(Milestone1_Project__c pr : newProjects) {
            String coordinatorId = pr.RIC_Coordinateur__c;
            if(oldMap.containsKey(pr.Id) && oldMap.get(pr.Id).RIC_Status__c != pr.RIC_Status__c && 'Annulé'.equalsIgnoreCase(pr.RIC_Status__c) && !userId.equals(coordinatorId) 
               && !UserInfo.getUserEmail().equals('nicolas.renault@pernod-ricard.com')) {
                pr.addError(Label.RIC_Error_AnnulationProjet);
            }
        }
    }
    
    public static void sendStatusChangedNotification(Map<Id, Milestone1_Project__c> oldMap, List<Milestone1_Project__c> newProjects) {
        
        List<Id> projectsIdsToNotify = new List<Id>();
        for(Milestone1_Project__c newProject : newProjects) {
            if(oldMap.containsKey(newProject.Id) && oldMap.get(newProject.Id).RIC_Go_Achats__c != newProject.RIC_Go_Achats__c && newProject.RIC_Go_Achats__c.equals('GO achats confirmé')) {
                projectsIdsToNotify.add(newProject.Id);
            }
        }
        if(projectsIdsToNotify.size() > 0) {
            List<Milestone1_Project__c> selectedProducts = [SELECT Id, RIC_Brand__r.RIC_Acheteurs_OPP__c, RIC_Coordinateur__r.Email, CreatedBy.Email 
                                                            FROM Milestone1_Project__c 
                                                            WHERE Id in :projectsIdsToNotify];
            if(selectedProducts != null && selectedProducts.size() > 0) {
                String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
                List<Messaging.SingleEmailMessage> allmsgs = new List<Messaging.SingleEmailMessage>();
                Pattern MyPattern = Pattern.compile(emailRegex);
                Set<String> emailsToSend = new Set<String>();
                
                for(Milestone1_Project__c pr : selectedProducts) {
                    String stringOppEmails = pr.RIC_Brand__r.RIC_Acheteurs_OPP__c;
                    if(String.isNotBlank(stringOppEmails)) {
                        String[] listOfOppEmails = stringOppEmails.split(';');
                        if(listOfOppEmails != null) {
                            for(Integer i = 0; i < listOfOppEmails.size(); i++){
                                String email = listOfOppEmails[i];
                                if(String.isNotBlank(email)) {
                                    Matcher myMatcher = MyPattern.matcher(email);
                                    if(MyMatcher.matches())
                                        emailsToSend.add(email);
                                }
                            }
                        }
                        else{
                            Matcher myMatcher = MyPattern.matcher(stringOppEmails);
                            if(MyMatcher.matches())
                                emailsToSend.add(stringOppEmails);
                        }
                    }
                    if(String.isNotBlank(pr.RIC_Coordinateur__r.Email))
                        emailsToSend.add(pr.RIC_Coordinateur__r.Email);
                    if(String.isNotBlank(pr.CreatedBy.Email))
                        emailsToSend.add(pr.CreatedBy.Email);
                    
                    //Add Stéphanie Setti to the email sent
                    User stephanieUser = [SELECT Email FROM User WHERE Name = 'Stephanie Setti'];
                    if(stephanieUser != null) {
                        emailsToSend.add(stephanieUser.Email);
                    }
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setWhatId(pr.Id);
                    mail.setTargetObjectId(UserInfo.getUserId());
                    mail.setTreatTargetObjectAsRecipient(false);
                    mail.toAddresses = new List<String> (emailsToSend);
                    mail.setTemplateId(Label.RIC_Projet_Status_Change_TemplateId);
                    mail.setSaveAsActivity(false);
                    allmsgs.add(mail);
                }
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsgs);
            }
        }
    }
    
    /**
     *  Exigence 6 - Module Notification: Notify all assigned to Users and all actors of the 'RIC Action' when the project is 'Validé'
     *  and the 'Type d'action' on 'RIC Action' = 'Avec Notification'.
	 */
    public static void notifyAssignedToUsers(Map<Id, Milestone1_Project__c> oldMap, Map<Id, Milestone1_Project__c> newMap) {
        System.debug('### function initiated');
        Set<Id> myId = new Set<Id>();
        Map<Id, Milestone1_Project__c> projectsMap = new Map<Id, Milestone1_Project__c>();
        Set<Id> listOfUsers = new Set<Id>();
        List<RIC_Acteur__c> listActeurs = new List<RIC_Acteur__c>();
        Map<Id, List<Id>> mapActionListActeursEmails = new Map<Id, List<Id>>();
        List<Messaging.SingleEmailMessage> allmsgs = new List<Messaging.SingleEmailMessage>();
        
        for(Milestone1_Project__c pr : newMap.values()){
            if((oldMap.containsKey(pr.Id) && oldMap.get(pr.Id).RIC_Status__c != pr.RIC_Status__c && 'Validé'.equalsIgnoreCase(pr.RIC_Status__c))) {
                projectsMap.put(pr.Id, pr);
            }
        }
        
        if(projectsMap.size() > 0) {
            List<Milestone1_Task__c> listToNotifyTasks = [SELECT id, RIC_Task_Sent__c, RIC_Nom_du_projet__c, RIC_Marque__c, RIC_Status__c, Assigned_To__c, Project_Milestone__r.Project__c, 
                                                          RIC_Type_Action__c, Name, Due_Date__c, RIC_Date_MAD_previ__c, RIC_Phase_Value__c
                                                          FROM Milestone1_Task__c 
                                                          WHERE Milestone1_Task__c.Project_Milestone__r.Project__c IN :projectsMap.keySet() AND RIC_Type_Action__c = 'Avec Notification'];
            if(listToNotifyTasks != null) {
                listActeurs = [SELECT Id, RIC_Acteur_User__c, RIC_Action__c 
                               FROM RIC_Acteur__c 
                               WHERE RIC_Action__c in :listToNotifyTasks];
                
                for(RIC_Acteur__c acteur : listActeurs) {
                    if(mapActionListActeursEmails.containsKey(acteur.RIC_Action__c))
                        mapActionListActeursEmails.get(acteur.RIC_Action__c).add(acteur.RIC_Acteur_User__c);
                    else
                        mapActionListActeursEmails.put(acteur.RIC_Action__c, new List<String> {acteur.RIC_Acteur_User__c});
                }
                
                Map<String, String> mapUserAndProject = new Map<String, String>();
                for(Milestone1_Task__c ricTask : listToNotifyTasks) {
                    listOfUsers.add(ricTask.Assigned_To__c);
                    if(mapActionListActeursEmails.containsKey(ricTask.Id))
                        listOfUsers.addAll(mapActionListActeursEmails.get(ricTask.Id));
                    
                    if(listOfUsers.size() > 0) {
                        for(Id userId : listOfUsers) {
                            mapUserAndProject.put(userId, ricTask.Project_Milestone__r.Project__c);
                        }
                    }
                }
                
                for(String userId : mapUserAndProject.keySet()) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setWhatId(mapUserAndProject.get(userId));
                    mail.setTreatTargetObjectAsRecipient(true);
                    mail.setTargetObjectId(userId);
                    mail.setTemplateId(Label.RIC_ProjectValidatedActions_NotifyID);
                    mail.setSaveAsActivity(false);
                    allmsgs.add(mail);
                }
                Messaging.sendEmail(allmsgs, false);
            }
        }
    }
    
    public static void shareProjectWithCoordinator(Map<Id, Milestone1_Project__c> oldMap, Map<Id, Milestone1_Project__c> newMap, boolean isUpdate) {
        
        List<Milestone1_Project__c> listNewProjects = new List<Milestone1_Project__c>();
        Map<String, String> mapProjetOldCoordinateurs = new Map<String, String>();
        
        if(isUpdate) {
            for(Milestone1_Project__c project : newMap.values()) {
                if(oldMap.containsKey(project.Id) && oldMap.get(project.Id).RIC_Coordinateur__c != project.RIC_Coordinateur__c) {
                    listNewProjects.add(project);
                    mapProjetOldCoordinateurs.put(project.Id, oldMap.get(project.Id).RIC_Coordinateur__c);
                }
            }
            if(mapProjetOldCoordinateurs.size() > 0) {
                List<Milestone1_Project__Share> oldShares = [SELECT Id 
                                                             FROM Milestone1_Project__Share 
                                                             WHERE ParentId IN :mapProjetOldCoordinateurs.keySet() 
                                                             AND UserOrGroupId IN :mapProjetOldCoordinateurs.values()
                                                             AND RowCause = 'RIC_Coordinateur'];
                if(oldShares != null){
                    delete oldShares;
                } 
            }
        }
        else
            listNewProjects = newMap.values();
        
        if(listNewProjects != null && listNewProjects.size() > 0) {
            
            List<Milestone1_Project__Share> listProjectShare = new List<Milestone1_Project__Share>();
            for(Milestone1_Project__c project : listNewProjects) {
                if(!STring.isBlank(project.RIC_Coordinateur__c)) {
                    Milestone1_Project__Share projectShare  = new Milestone1_Project__Share();
                    projectShare.ParentId = project.Id;
                    projectShare.UserOrGroupId = project.RIC_Coordinateur__c;
                    projectShare.AccessLevel = 'Edit';
                    projectShare.RowCause = Schema.Milestone1_Project__Share.RowCause.RIC_Coordinateur__c;
                    listProjectShare.add(projectShare);   
                }
            }
            insert listProjectShare;
        }
    }
}