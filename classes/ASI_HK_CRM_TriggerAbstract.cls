public abstract class ASI_HK_CRM_TriggerAbstract {
	
	public static final Map<String, Integer> keyToInitCountMap = new Map<String, Integer>();
	public enum TriggerAction {BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE
		, AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE, AFTER_UNDELETE}
	
	protected String initCountKey;
	protected Integer initCount;
	
	private static Set<String> bypassTriggers;
	private static ID bypassUserId;
	private String bypassTriggerKey;
	
	public ASI_HK_CRM_TriggerAbstract(String key) {
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
	
	protected virtual Boolean isBypassByCurrentUser() {
		if (this.bypassTriggerKey == null || this.bypassTriggerKey.trim() == '')
			return false;
		ID curUserId = UserInfo.getUserId();
		if (curUserId != bypassUserId || bypassTriggers == null) {
			bypassTriggers = new Set<String>();
			List<User> users = [SELECT Id, BypassTriggers__c FROM User WHERE Id = :curUserId];
			if (users.size() > 0 && users[0].BypassTriggers__c != null) {
				String bypassTriggerWholeStr = users[0].BypassTriggers__c;
				List<String> bypassTriggerStrs = bypassTriggerWholeStr.split(';', 0);
				for (String bypassTriggerStr : bypassTriggerStrs) {
					bypassTriggers.add(bypassTriggerStr.toLowerCase());
				}
			}
		}
		return bypassTriggers.contains(this.bypassTriggerKey.toLowerCase());
	}
}