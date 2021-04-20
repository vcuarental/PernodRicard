public with sharing class ASI_MFM_EventSubChannel_TriggerClass {
	public static void routineBeforeUpsert(list<ASI_MFM_Event_Sub_Channel__c> trigger_new, map<id, ASI_MFM_Event_Sub_Channel__c> trigger_oldMap) {
		//Added by Michael (Introv) 11Apr2014 to deduplicate for event sub channel record under event
		Set<id> SEventID = new Set<id>();
		Set<id> SSBID = new Set<id>();
		for(ASI_MFM_Event_Sub_Channel__c sb : trigger_new){
			SEventID.add(sb.ASI_MFM_Event__c);
			if(sb.id != null){
				SSBID.add(sb.id);
			}
		}
		List<ASI_MFM_Event_Sub_Channel__c> LEventSB = [Select ASI_MFM_Event__c, ASI_MFM_Sub_Channel__c 
			from ASI_MFM_Event_Sub_Channel__c 
			where id NOT IN :SSBID and ASI_MFM_Event__c IN :SEventID];
		if(LEventSB.size()>0){
			Set<String> SEventSBKey = new Set<String>();
			for(ASI_MFM_Event_Sub_Channel__c SB : LEventSB){
				String key = String.valueof(SB.ASI_MFM_Event__c) + String.valueof(SB.ASI_MFM_Sub_Channel__c);
				SEventSBKey.add(key);
			}
			for(ASI_MFM_Event_Sub_Channel__c sb : trigger_new){
				if(SEventSBKey.contains(String.valueof(SB.ASI_MFM_Event__c) + String.valueof(SB.ASI_MFM_Sub_Channel__c))){
					sb.addError('Duplicate Event Sub-Channel Found!');
				}
			}
		}
	}
}