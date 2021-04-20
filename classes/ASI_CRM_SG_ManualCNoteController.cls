public with sharing class ASI_CRM_SG_ManualCNoteController {
    public ASI_CRM_Credit_Debit_Note__c cNote {get; private set;}
    
    public ASI_CRM_SG_ManualCNoteController(apexpages.standardSetController sc) {
        id cNoteId = apexpages.currentPage().getParameters().get('id');
        cNote = database.query(ASI_MFM_function.buildQuery('ASI_CRM_Credit_Debit_Note__c') + ' where id = :cNoteId');
    }
}