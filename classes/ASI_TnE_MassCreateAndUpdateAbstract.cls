public interface ASI_TnE_MassCreateAndUpdateAbstract extends ASI_TnE_PageInterface {
    
    List<ASI_TnE_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList(); 
    PageReference mcau_triggerPageBlockAction(ASI_TnE_MassCreateAndUpdateController controller, String actionKey);
    void mcau_triggerActionForSObject(ASI_TnE_MassCreateAndUpdateController controller, String actionKey, sObject sObj);
}