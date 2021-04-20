public with sharing class ASI_MFM_GF_InputPOItemsController {
    public ASI_MFM_PO__c PO {get; private set;}
    public Boolean isNormal {get; set;}
    public Boolean isVAPBO {get; set;}
    public Boolean isVAPFOC {get; set;}
    public Boolean isEventFOC {get; set;}
    
    public ASI_MFM_GF_InputPOItemsController(apexpages.standardSetController sc) {
        id pid = apexpages.currentPage().getParameters().get('id');
        PO = database.query(ASI_MFM_function.buildQuery('ASI_MFM_PO__c', 'ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c, ASI_MFM_Plan__r.ASI_MFM_Plan_Description__c, ASI_MFM_Plan__r.ownerId') + ' where id = :pid');
        
        //Reset boolean values
        isNormal = false;
        isVAPBO = false;
        isVAPFOC = false;
        isEventFOC = false;
        
        if (PO.ASI_MFM_PO_Type__c == 'Normal')
            isNormal = true;
        else if (PO.ASI_MFM_PO_Type__c == 'VAP Brand Owner')
            isVAPBO = true;
        else if (PO.ASI_MFM_PO_Type__c == 'VAP FOC')
            isVAPFOC = true;
        else if (PO.ASI_MFM_PO_Type__c == 'Event FOC')
            isEventFOC = true;
    }
}