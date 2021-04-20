public with sharing class ASI_TH_CRM_SITDetailOTFinalInitCtrl {
    public ASI_TH_CRM_SITDetailOTFinalInitCtrl(ApexPages.StandardController controller) {       
    }
    
    @RemoteAction
    public static void initOfftakeTotal() {
        database.executeBatch(new ASI_TH_CRM_SITDetailOTFinalInitBatch()); 
    } 
}