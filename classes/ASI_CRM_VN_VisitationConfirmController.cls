public with sharing class ASI_CRM_VN_VisitationConfirmController {
    
    public ID visitId { get; private set; }
    public Boolean hasError { get; private set; }
    
    private ASI_HK_CRM_Visitation_Plan__c visitHeader;
    public ASI_CRM_VN_VisitationConfirmController(ApexPages.StandardController stdController) {
        this.visitId = stdController.getId();
        List<ASI_HK_CRM_Visitation_Plan__c> tempVisitHeaders = [SELECT Id, 
                                                                       ASI_HK_CRM_Confirmed__c,
                                                                       OwnerId       
                                                                       FROM ASI_HK_CRM_Visitation_Plan__c 
                                                                       WHERE Id = :visitId];
        if (tempVisitHeaders.size() > 0)
            this.visitHeader = tempVisitHeaders.get(0);
        this.hasError = false;
    }
    
    public PageReference initPage() {          
        if (visitId == null) {
            this.hasError = true;
            showPageError('Visitation ID is not specified');
        } else if (this.visitHeader.OwnerId == UserInfo.getUserId()){
        
            //Identify if the currently logged in user is the record owner himself
            //Throw Error
            this.hasError = true;
            showPageError(Label.ASI_VN_CRM_VF_VISIT_ERR_ContactManager);        
        }
        
        else if(this.visitHeader.ASI_HK_CRM_Confirmed__c) {
            this.hasError = true;
            showPageError(Label.ASI_HK_CRM_VF_VISIT_ERR_AlreadyConfirmed);
        } else {
            ASI_CRM_VN_VisitationConfirmProcess visitConfirmProcess = new ASI_CRM_VN_VisitationConfirmProcess(visitId);
            this.hasError = !visitConfirmProcess.processConfirmation();
        }
        return this.hasError ? null : new PageReference('/' + visitId);
    }
    
    private void showPageMessage(ApexPages.Severity severity, String msg) {
        ApexPages.addMessage(new ApexPages.Message(severity, msg));
    }
    
    private void showPageError(String msg) {
        showPageMessage(ApexPages.Severity.ERROR, msg);
    }
}