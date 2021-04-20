public class RIC_Delete_Milestones_Controller {
    
    public List<Milestone1_Milestone__c> listSelected {get; set;}
    public String errorMessage {get; set;}
    public String currentRecordId {get; set;}    
    
    public RIC_Delete_Milestones_Controller(ApexPages.StandardSetController ssc) {
        listSelected = ssc.getSelected();
        currentRecordId = ApexPages.CurrentPage().getparameters().get('id');
    }
    
    public PageReference deleteMilestones() {
        listSelected = [SELECT Id 
                        FROM Milestone1_Milestone__c 
                        WHERE Id in :listSelected];
        
        Milestone1_Project__c project = [SELECT Id, RIC_Coordinateur__r.Id 
                                         FROM Milestone1_Project__c 
                                         WHERE Id = :currentRecordId];
        if(project != null && listSelected != null && UserInfo.getUserId().equals(project.RIC_Coordinateur__r.Id)) {
            //RIC_Delete_Project_Controller.updateMilestonesOwner(listSelected, true);
            delete listSelected;
            return retour();
        }
        else {
            errorMessage = 'Seul le coordinateur du projet est autorisé à supprimer le planning';
        }
        return null;
    }
    
    public PageReference retour() {
        return new PageReference('/' + currentRecordId);
    }
    
    /*
    public static void updateMilestonesOwner(List<Milestone1_Milestone__c> milestones, boolean deleteList) {
        List<Milestone1_Milestone__c> milestonesToUpdate = new List<Milestone1_Milestone__c>();
        if(milestones != null) {
            for(Milestone1_Milestone__c milestone : milestones) {
                if(!milestone.ownerId.equals(UserInfo.getUserId())) {
                    //As the current permissions settings don't allow all users to delete a Milestone, we update the ownerId of the records
                    //to the coordinateur Id so he will be able to delete all related Milestones after deleting the project
                    milestone.ownerId = UserInfo.getUserId();
                    milestonesToUpdate.add(milestone);
                }
            }
            if(milestonesToUpdate.size() > 0) {
                update milestonesToUpdate;
            }
            
            if(deleteList) {
                delete milestones;
            }
        }
    }*/
    
}