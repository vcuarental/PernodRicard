public with sharing class LAT_BR_VFP30_PlanejamentoOverride {
	private final Planejamento__c planejamento;
    private final string userID;
    public final string retUrl{get;set;}
   
     public LAT_BR_VFP30_PlanejamentoOverride (ApexPages.StandardController stdController) {
        this.planejamento = (Planejamento__c)stdController.getRecord();
        userID = Userinfo.getUserID();
        retUrl = ApexPages.currentPage().getParameters().get('returl');
	}

    
    public pageReference authorized (){
        if(Utils.isPartOfMobileCRM(userID)){
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, label.LAT_VFP30_Mobile_Permissions_Planejamento);
            ApexPages.addMessage(myMsg);
            return null;   
            
        }
        pageReference page = new PageReference('/a4o/e?retUrl=' + retUrl + '&nooverride=1');
        page.setRedirect(true);
        return page;
    }


}