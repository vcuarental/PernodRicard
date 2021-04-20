public class RIC_Projet_Share_Controller {
	
	private final Milestone1_Project__c ricProject;
    private final String ricProjetId;
    public String errorMessage {get; set;}
    
    public RIC_Projet_Share_Controller(ApexPages.StandardController stdController) {
        this.ricProjetId = (String) stdController.getId();
        ricProject = [SELECT Id, CreatedById, RIC_Coordinateur__c FROM Milestone1_Project__c WHERE Id = :ricProjetId];
    }
    
    public PageReference redirectToSharingPage() {
        if(ricProject != null) {
            String currentUserId = UserInfo.getUserId();
            if(!currentUserId.equals(ricProject.CreatedById) && !currentUserId.equals(ricProject.RIC_Coordinateur__c)) {
                errorMessage = Label.RIC_Project_Share_Error;
            }
            else {
                PageReference pageRef = new PageReference('/p/share/CustomObjectSharingDetail?parentId=' + ricProjetId);
                pageRef.setRedirect(true);
                return pageRef;
            }
        }
        return null;
    }
    
    public PageReference retour() {
        PageReference pageRef = new PageReference('/' + ricProjetId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}