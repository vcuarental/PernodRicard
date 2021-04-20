/**
 * @Author: Bilal El Aly
 * Test Class: RIC_AP01_Acteur_TEST
 * Code Coverage from RIC_AP01_Acteur_TEST: 92%
 */
public class RIC_AP01_Acteur {
    
    public static void checkDuplicateActeur(List<RIC_Acteur__c> listActeurs) {
        
        Map<String, Set<String>> mapActionListUtilisateur = fillActionsAndActeurs(listActeurs);
        
        Map<String, String> mapActionAssignedTo = new Map<String, String>();
        List<Milestone1_Task__c> listRICActions = [SELECT Id, Assigned_To__c 
                                                   FROM Milestone1_Task__c 
                                                   WHERE Id in :mapActionListUtilisateur.keySet()];
        for(Milestone1_Task__c action : listRICActions) {
            mapActionAssignedTo.put(action.Id, action.Assigned_To__c);
        }
        
        try{
            //Check if the Action has an 'Acteur' list already and the user is already assigned to it
            List<RIC_Acteur__c> listOfExistingActeurs = [SELECT Id, RIC_Action__c, RIC_Acteur_User__c 
                                                         FROM RIC_Acteur__c
                                                         WHERE RIC_Action__c in :mapActionListUtilisateur.keySet()];
            Map<String, Set<String>> mapActionExistingActeurs = fillActionsAndActeurs(listOfExistingActeurs);
            
            for(RIC_Acteur__c acteur : listActeurs) {
                if(mapActionAssignedTo.containsKey(acteur.RIC_Action__c) && mapActionAssignedTo.get(acteur.RIC_Action__c).equals(acteur.RIC_Acteur_User__c))
                    acteur.addError(Label.RIC_Error_UserAlreadyAssigned);
                else if(mapActionExistingActeurs.containsKey(acteur.RIC_Action__c) && mapActionExistingActeurs.get(acteur.RIC_Action__c).contains(acteur.RIC_Acteur_User__c))
                    acteur.addError(Label.RIC_Error_UserAlreadyAssigned);
            }
        }
        catch(Exception e) {
            System.debug('### EXCEPTION:' + e.getMessage());
        }
    }
    
    private static Map<String, Set<String>> fillActionsAndActeurs(List<RIC_Acteur__c> listOfActeurs) {
        Map<String, Set<String>> mapActionAndActeurs = new Map<String, Set<String>>();
        if(listOfActeurs != null && listOfActeurs.size() > 0) {
            for(RIC_Acteur__c acteur : listOfActeurs) {
                if(mapActionAndActeurs.containsKey(acteur.RIC_Action__c))
                    mapActionAndActeurs.get(acteur.RIC_Action__c).add(acteur.RIC_Acteur_User__c);
                else
                    mapActionAndActeurs.put(acteur.RIC_Action__c, new Set<String> {acteur.RIC_Acteur_User__c});
            }
        }
        
        return mapActionAndActeurs;
    }
	
    public static void deleteProjectShareFromActeur(List<RIC_Acteur__c> listDeletedActeurs){
		
        if(listDeletedActeurs.size() == 1) {
            String actionId = listDeletedActeurs.get(0).RIC_Action__c;
            String userId = listDeletedActeurs.get(0).RIC_Acteur_User__c;
            List<Milestone1_Task__c> action = [SELECT Id, ProjectId__c 
                                               FROM Milestone1_Task__c 
                                               WHERE Id = :actionId];
            
            if(action != null && action.size() > 0) {
                List<RIC_Acteur__c> otherActeursForUser = [SELECT ID 
                                                           FROM RIC_Acteur__c 
                                                           WHERE RIC_Acteur_User__c = :userId 
                                                           AND RIC_Action__r.ProjectId__c = :action.get(0).ProjectId__c];
                
                //The user is not an 'Acteur' for other actions of the project
                if(otherActeursForUser == null || otherActeursForUser.size() == 0) {
                    List<Milestone1_Project__Share> listSharedProjects = [SELECT Id, UserOrGroupId, ParentId
                                                                          FROM Milestone1_Project__Share 
                                                                          WHERE ParentId = :action.get(0).ProjectId__c
                                                                          AND UserOrGroupId = :userId
                                                                          AND RowCause = 'RIC_Coordinateur'];
                    
                    if(listSharedProjects != null && listSharedProjects.size() > 0) {
                        delete listSharedProjects;
                    }
                }
            }
        }
    }
    
    public static void shareProjectWithActeur(List<RIC_Acteur__c> listNewActeurs) {
        Map<String, Set<String>> mapActeurWithProject = new Map<String, Set<String>>();
        Set<String> listProjects = new Set<String>();
        
        List<RIC_Acteur__c> selectedActeurs = [SELECT Id, RIC_Acteur_User__c, RIC_Action__c, RIC_Action__r.ProjectId__c 
                                               FROM RIC_Acteur__c 
                                               WHERE Id in :listNewActeurs];
        
        for(RIC_Acteur__c acteur : selectedActeurs) {
            if(mapActeurWithProject.containsKey(acteur.RIC_Acteur_User__c))
                mapActeurWithProject.get(acteur.RIC_Acteur_User__c).add(acteur.RIC_Action__r.ProjectId__c);
            else
                mapActeurWithProject.put(acteur.RIC_Acteur_User__c, new Set<String> {acteur.RIC_Action__r.ProjectId__c});
            
            listProjects.add(acteur.RIC_Action__r.ProjectId__c);
        }
        
        if(mapActeurWithProject.size() > 0) {
            List<Milestone1_Project__Share> listSharedProjects = [SELECT Id, UserOrGroupId, ParentId
                                                                  FROM Milestone1_Project__Share 
                                                                  WHERE ParentId IN :listProjects
                                                                  AND UserOrGroupId IN :mapActeurWithProject.keySet()
                                                                  AND RowCause = 'RIC_Coordinateur'];
            
            Map<String, Set<String>> mapActeursListSharedProjects = new Map<String, Set<String>>();
            if(listSharedProjects != null && listSharedProjects.size() > 0) {
                for(Milestone1_Project__Share sharedProject : listSharedProjects) {
                    if(mapActeursListSharedProjects.containsKey(sharedProject.UserOrGroupId))
                        mapActeursListSharedProjects.get(sharedProject.UserOrGroupId).add(sharedProject.ParentId);
                    else
                        mapActeursListSharedProjects.put(sharedProject.UserOrGroupId, new Set<String> {sharedProject.ParentId});
                }
            }
            
            List<Milestone1_Project__Share> listProjectShare = new List<Milestone1_Project__Share>();
            for(String acteurId : mapActeurWithProject.keySet()){
                for(String projectId : mapActeurWithProject.get(acteurId)) {
                    if(!mapActeursListSharedProjects.containsKey(acteurId) || 
                       (mapActeursListSharedProjects.containsKey(acteurId) && !mapActeursListSharedProjects.get(acteurId).contains(projectId))) {
                        Milestone1_Project__Share projectShare  = new Milestone1_Project__Share();
                        projectShare.ParentId = projectId;
                        projectShare.UserOrGroupId = acteurId;
                        projectShare.AccessLevel = 'Edit';
                        projectShare.RowCause = Schema.Milestone1_Project__Share.RowCause.RIC_Coordinateur__c;
                        listProjectShare.add(projectShare);
                    }
                }
            }
            System.debug('### listProjectShare: ' + listProjectShare);
            insert listProjectShare;
        }
    }
}