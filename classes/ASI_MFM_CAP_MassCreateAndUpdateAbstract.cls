public interface ASI_MFM_CAP_MassCreateAndUpdateAbstract extends ASI_MFM_PageInterface {
    
    List<ASI_MFM_CAP_MassCreateUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList(); 
    PageReference mcau_triggerPageBlockAction(ASI_MFM_CAP_MassCreateUpdateController controller, String actionKey);
    void mcau_triggerActionForSObject(ASI_MFM_CAP_MassCreateUpdateController controller, String actionKey, sObject sObj);
}