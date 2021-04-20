public class ASI_MFM_TH_InputPlanItemsController {
    public ASI_MFM_Plan__c plan {get; private set;}
    
    public ASI_MFM_TH_InputPlanItemsController(apexpages.standardSetController sc) {
        id pid = apexpages.currentPage().getParameters().get('id');
        plan = database.query(ASI_MFM_function.buildQuery('ASI_MFM_Plan__c') + ' where id = :pid');
    }

}