public with sharing class ASI_MFM_MY_InputPOItemsController {
    public ASI_MFM_PO__c PO {get; private set;}
    
    public ASI_MFM_MY_InputPOItemsController(apexpages.standardSetController sc) {
        id pid = apexpages.currentPage().getParameters().get('id');
        PO = database.query(ASI_MFM_function.buildQuery('ASI_MFM_PO__c', 'ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Description__c, ASI_MFM_Plan__r.ownerId') + ' where id = :pid');
    }
}