public interface ASI_MFM_JP_MassCreateAndUpdateAbstract extends ASI_TnE_PageInterface {
    
    List<ASI_MFM_JP_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList(); 
    PageReference mcau_triggerPageBlockAction(ASI_MFM_JP_MassCreateAndUpdateController controller, String actionKey);
    void mcau_triggerActionForSObject(ASI_MFM_JP_MassCreateAndUpdateController controller, String actionKey, sObject sObj);
}