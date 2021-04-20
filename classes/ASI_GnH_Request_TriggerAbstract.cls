/*********************************************************************************
 * Name:ASI_GnH_Request_TriggerAbstract
 * Description: Trigger Abstract required for trigger logic. GnE Specific
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-06-22       Laputa: Hugo Cheung     Created
*********************************************************************************/
public abstract class ASI_GnH_Request_TriggerAbstract {
  
  public enum TriggerAction {
      BEFORE_INSERT, 
      BEFORE_UPDATE, 
      BEFORE_DELETE, 
      AFTER_INSERT, 
      AFTER_UPDATE, 
      AFTER_DELETE, 
      AFTER_UNDELETE
  }
  
  public abstract void executeTriggerAction(TriggerAction tAction, List<sObject> newList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap);
  
}