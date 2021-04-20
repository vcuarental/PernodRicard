public interface ASI_MFM_SFObjSelectTableAbstract extends ASI_MFM_PageInterface {
	
	List<ASI_MFM_SFObjSelectTableController.SFObjSelectTableActionBtn> sobjst_initActionButtonList();
	Map<ID, Map<String, Integer>> sobjst_initActionButtonStageMap();
	void sobjst_triggerActionForSObject(ASI_MFM_SFObjSelectTableController controller, String actionKey, sObject sObj);
}