public class LAT_BR_VFP30_MobileOverride {
    private final visitas__c visit;
    private final string userID;
    public final string thePlanningName{get;set;}
    public final string thePlanningID{get;set;}
    public final string retUrl{get;set;}
   
     public LAT_BR_VFP30_MobileOverride (ApexPages.StandardController stdController) {
        this.visit = (visitas__c)stdController.getRecord();
        userID = Userinfo.getUserID();
        retUrl = ApexPages.currentPage().getParameters().get('returl');
        thePlanningName =ApexPages.currentPage().getParameters().get('CF00ND0000005SKkM');
        thePlanningId =ApexPages.currentPage().getParameters().get('CF00ND0000005SKkM_lkid');
        
        
    }
    
    public pageReference authorized (){
        if(Utils.isPartOfMobileCRM(userID)){
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, label.LAT_VFP30_Mobile_Permissions_Visit);
            ApexPages.addMessage(myMsg);
            return null;   
            
        }
        pageReference page = new PageReference('/a51/e?CF00ND0000005SKkM='+ thePlanningName +'&CF00ND0000005SKkM_lkid=' + thePlanningID + '&retUrl=' + retUrl + '&nooverride=1');
        page.setRedirect(true);
        return page;
        //return null;
    }


}