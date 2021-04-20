public without sharing class RIC_Delete_Project_Controller {
	
    public String projectId;
    public String errorMessage {get; set;}
    public Milestone1_Project__c project;
    
    public RIC_Delete_Project_Controller(ApexPages.StandardController std) {
        projectId = std.getId();
        project = [SELECT Id, RIC_Coordinateur__c, OwnerId, CreatedById FROM Milestone1_Project__c WHERE Id = :projectId];
    }
    
    public PageReference deleteProject() {
        if(project != null) {
            Schema.DescribeSObjectResult result = Milestone1_Project__c.SObjectType.getDescribe();
            String coordinateurId = project.RIC_Coordinateur__c;
            String nicolasRenaultId = '';
            User nicolasRenaultUser = [SELECT ID FROM User WHERE Name = 'Nicolas Renault'];
            if(nicolasRenaultUser != null) {
                nicolasRenaultId = nicolasRenaultUser.Id;
            }
            if(UserInfo.getUserId().equals(coordinateurId) || UserInfo.getUserId().equals(nicolasRenaultId)) {
                
                //As the current permissions settings don't allow all users to delete a project, we update the ownerId of the record
                //to the coordinateur Id so he will be able to delete the project
                if(!project.ownerId.equals(UserInfo.getUserId())) {
                    project.OwnerId = UserInfo.getUserId();
                    update project;    
                }
                
                project = [SELECT Id, RIC_Coordinateur__c, OwnerId, CreatedById FROM Milestone1_Project__c WHERE Id = :projectId];
               	delete project;
                
                PageReference pageRef = new PageReference('/' + result.getKeyPrefix() + '/o');
                pageRef.setRedirect(true);
                return pageRef;
            }
            else {
                errorMessage = Label.RIC_Project_Delete_Error;
            }
        }
        return null;
    }
    
    public PageReference retour() {
        return new PageReference('/' + projectId);
    }
}