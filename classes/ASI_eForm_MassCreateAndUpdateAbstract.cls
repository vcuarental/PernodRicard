public interface ASI_eForm_MassCreateAndUpdateAbstract extends ASI_MFM_PageInterface {
    
    List<ASI_eForm_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList(); 
    PageReference mcau_triggerPageBlockAction(ASI_eForm_MassCreateAndUpdateController controller, String actionKey);
    void mcau_triggerActionForSObject(ASI_eForm_MassCreateAndUpdateController controller, String actionKey, sObject sObj);
}