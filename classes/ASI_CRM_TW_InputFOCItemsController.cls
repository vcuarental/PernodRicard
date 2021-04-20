public without sharing class ASI_CRM_TW_InputFOCItemsController {
    public ASI_FOC_Free_Goods_Request__c FOC {get; private set;}
    public boolean boolOPTEAM {get; set;}
   
    public ASI_CRM_TW_InputFOCItemsController(ApexPages.StandardController controller) {
        boolOPTEAM = false;
        
        //get current user permission sets
        List<PermissionSetAssignment> listCurrentUserPerSet = [SELECT Id FROM PermissionSetAssignment
                                                               WHERE AssigneeId = :Userinfo.getUserId() AND 
                                                               PermissionSet.Name = 'ASI_CRM_TW_OP_Team'];
                                                               
        if(listCurrentUserPerSet != null && listCurrentUserPerSet.size() > 0)
            boolOPTEAM = true;
                                                               
        id focid = apexpages.currentPage().getParameters().get('id');
        FOC = database.query(ASI_MFM_function.buildQuery('ASI_FOC_Free_Goods_Request__c',null) + ' where id = :focid');
    }
}