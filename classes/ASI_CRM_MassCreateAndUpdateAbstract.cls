public interface ASI_CRM_MassCreateAndUpdateAbstract extends ASI_CRM_PageInterface {    
    List<ASI_CRM_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList(); 
    PageReference mcau_triggerPageBlockAction(ASI_CRM_MassCreateAndUpdateController controller, String actionKey);
    void mcau_triggerActionForSObject(ASI_CRM_MassCreateAndUpdateController controller, String actionKey, sObject sObj);
}