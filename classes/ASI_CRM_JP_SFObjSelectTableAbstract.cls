/*********************************************************************************
 * Name:ASI_CRM_JP_SFObjSelectTableAbstract
 * Description: Interface Class related to SFObjSelectTableController Class. Essential class. Code taken from MFM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Conrad          Created
*********************************************************************************/
public interface ASI_CRM_JP_SFObjSelectTableAbstract extends ASI_CRM_PageInterface {
  
  List<ASI_CRM_JP_SFObjSelectTableController.SFObjSelectTableActionBtn> sobjst_initActionButtonList();
  Map<ID, Map<String, Integer>> sobjst_initActionButtonStageMap();
  void sobjst_triggerActionForSObject(ASI_CRM_JP_SFObjSelectTableController controller, String actionKey, sObject sObj);
}