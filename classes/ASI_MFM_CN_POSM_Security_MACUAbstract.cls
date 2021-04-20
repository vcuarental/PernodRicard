public interface ASI_MFM_CN_POSM_Security_MACUAbstract extends ASI_FOC_PageInterface {
	List<ASI_MFM_CN_POSM_Security_MACUController.PageBlockActionBtn> mcau_initPageBlockActionButtonList();
	PageReference mcau_triggerPageBlockAction(ASI_MFM_CN_POSM_Security_MACUController controller, String actionKey);
	void mcau_triggerActionForSObject(ASI_MFM_CN_POSM_Security_MACUController controller, String actionKey, sObject sObj);
}