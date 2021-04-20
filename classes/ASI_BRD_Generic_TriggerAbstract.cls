/*********************************************************************************
 * Name:ASI_BRD_Generic_TriggerAbstract
 * Description: Trigger Abstract required for trigger logic. BRD Generic Specific
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 14/09/2015       Laputa: Conrad          Created
*********************************************************************************/
public abstract class ASI_BRD_Generic_TriggerAbstract{
  
  public static final Map<String, Integer> keyToInitCountMap = new Map<String, Integer>();
  public enum TriggerAction {BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE
    , AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE, AFTER_UNDELETE}
  
  protected String initCountKey;
  protected Integer initCount;
  
  private static Set<String> bypassTriggers;
  private static ID bypassUserId;
  private String bypassTriggerKey;
  
  public ASI_BRD_Generic_TriggerAbstract(String key) {
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