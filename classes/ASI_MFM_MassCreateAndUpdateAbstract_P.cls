public interface ASI_MFM_MassCreateAndUpdateAbstract_P extends ASI_MFM_PageInterface {
    
    List<ASI_MFM_MassCreateAndUpdateController_P.PageBlockActionBtn> mcau_initPageBlockActionButtonList(); 
    PageReference mcau_triggerPageBlockAction(ASI_MFM_MassCreateAndUpdateController_P controller, String actionKey);
    void mcau_triggerActionForSObject(ASI_MFM_MassCreateAndUpdateController_P controller, String actionKey, sObject sObj);
}