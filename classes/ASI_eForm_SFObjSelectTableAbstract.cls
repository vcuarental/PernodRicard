public interface ASI_eForm_SFObjSelectTableAbstract extends ASI_MFM_PageInterface {
  
  List<ASI_eForm_SFObjSelectTableController.SFObjSelectTableActionBtn> sobjst_initActionButtonList();
  Map<ID, Map<String, Integer>> sobjst_initActionButtonStageMap();
  void sobjst_triggerActionForSObject(ASI_eForm_SFObjSelectTableController controller, String actionKey, sObject sObj);
}