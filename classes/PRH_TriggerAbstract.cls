public abstract class PRH_TriggerAbstract{
    
    public static final Map<String, Integer> keyToInitCountMap = new Map<String, Integer>();
    public enum TriggerAction {BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE
        , AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE, AFTER_UNDELETE}
    
    protected String initCountKey;
    protected Integer initCount;
    
    public PRH_TriggerAbstract(String key) {
        if (key != null) {
            this.initCountKey = key;
            Integer tempInitCount = keyToInitCountMap.get(key);
            if (tempInitCount == null) tempInitCount = 0;
            this.initCount = tempInitCount + 1;
            keyToInitCountMap.put(key, this.initCount);
        }
    }
    
    public abstract void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap);

}