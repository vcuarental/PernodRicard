public interface ASI_FOC_SFObjSelectTableAbstract extends ASI_FOC_PageInterface {
	
	List<ASI_FOC_SFObjSelectTableController.SFObjSelectTableActionBtn> sobjst_initActionButtonList();
	Map<ID, Map<String, Integer>> sobjst_initActionButtonStageMap();
	void sobjst_triggerActionForSObject(ASI_FOC_SFObjSelectTableController controller, String actionKey, sObject sObj);
}