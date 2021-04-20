public interface ASI_CRM_CN_MassCreateAndUpdateAbstract extends ASI_CRM_CN_PageInterface {
    
    List<ASI_CRM_CN_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList(); 
    PageReference mcau_triggerPageBlockAction(ASI_CRM_CN_MassCreateAndUpdateController controller, String actionKey);
    void mcau_triggerActionForSObject(ASI_CRM_CN_MassCreateAndUpdateController controller, String actionKey, sObject sObj);
}