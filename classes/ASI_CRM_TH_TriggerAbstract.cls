/*********************************************************************************
 * Name:ASI_CRM_TH_TriggerAbstract
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 25/11/2014       Laputa: Conrad          Created
 * 05/03/2015       Introv: Twinkle LI      Cloned from ASI_CRM_TW_TriggerAbstract
*********************************************************************************/
public abstract class ASI_CRM_TH_TriggerAbstract {
  
  public static final Map<String, Integer> keyToInitCountMap = new Map<String, Integer>();
  public enum TriggerAction {BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE
    , AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE, AFTER_UNDELETE}
  
  protected String initCountKey;
  protected Integer initCount;
  
  private static Set<String> bypassTriggers;
  private static ID bypassUserId;
  private String bypassTriggerKey;
  
  public ASI_CRM_TH_TriggerAbstract (String key) {
    if (key != null) {
      this.initCountKey = key;
      Integer tempInitCount = keyToInitCountMap.get(key);
      if (tempInitCount == null) tempInitCount = 0;
      this.initCount = tempInitCount + 1;
      keyToInitCountMap.put(key, this.initCount);
      this.bypassTriggerKey = key;
    }
  }
  
  public abstract void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap);
  
}