public interface ASI_MFM_POSM_SFObjSelectTableAbstract extends ASI_FOC_PageInterface {
	
	List<ASI_MFM_POSM_SFObjSelectTableController.SFObjSelectTableActionBtn> sobjst_initActionButtonList();
	Map<ID, Map<String, Integer>> sobjst_initActionButtonStageMap();
	void sobjst_triggerActionForSObject(ASI_MFM_POSM_SFObjSelectTableController controller, String actionKey, sObject sObj);
}