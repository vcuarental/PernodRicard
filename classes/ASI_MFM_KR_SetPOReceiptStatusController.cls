public without sharing  class ASI_MFM_KR_SetPOReceiptStatusController {
    public string new_status;
    ASI_MFM_PO_Receipt__c p = new ASI_MFM_PO_Receipt__c();
    
      public ASI_MFM_KR_SetPOReceiptStatusController(apexpages.standardController sc) {
        new_status = apexpages.currentPage().getParameters().get('status');
        p = [select id,ASI_MFM_Status__c, recordTypeId from ASI_MFM_PO_Receipt__c where id = :sc.getId()];
    }
    
     public pageReference setStatus() {
         p.ASI_MFM_Status__c = new_status;
         
         try {
             update p;
             return new pageReference('/' + p.id);
         }
         catch (exception ex) {
             apexpages.addMessages(ex);
             return null;
         }
         
     }
}