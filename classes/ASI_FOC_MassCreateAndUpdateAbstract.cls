public interface ASI_FOC_MassCreateAndUpdateAbstract extends ASI_FOC_PageInterface {
	
	List<ASI_FOC_MassCreateAndUpdateController.PageBlockActionBtn> mcau_initPageBlockActionButtonList();
	PageReference mcau_triggerPageBlockAction(ASI_FOC_MassCreateAndUpdateController controller, String actionKey);
	void mcau_triggerActionForSObject(ASI_FOC_MassCreateAndUpdateController controller, String actionKey, sObject sObj);
}