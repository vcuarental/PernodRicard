public without sharing class ASI_MFM_EventOutlet_TriggerClass {
	public static void routineBeforeInsert(list<ASI_MFM_Event_Outlet__c> trigger_new){
		// Added by Michael Yip (Introv) 4 Feb 2014 to mark event status to 'Proposal' if event outlet is no longer zero
		Map<String, id> MRecType = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Event_Outlet__c');
		string CNRecTypeID = MRecType.get('ASI_MFM_CN_Event_Outlet');
		Set<id> SEventID = new Set<id>();
		for(ASI_MFM_Event_Outlet__c e : trigger_new){
			System.debug(e.RecordtypeId);
			System.debug(CNRecTypeID);
			if(e.RecordTypeId == CNRecTypeID || e.RecordTypeId == null){
				SEventID.add(e.ASI_MFM_Event__c);
			}
		}
        Map<id,ASI_MFM_Event__c> Event_Map = new Map<id,ASI_MFM_Event__c>([Select id, ASI_MFM_Event_Type__c, ASI_MFM_Sub_Event_Type__c,ASI_MFM_Status__c from ASI_MFM_Event__c where id IN :SEventID]);
       	for(ASI_MFM_Event_Outlet__c e : trigger_new){
            if (e.RecordTypeId == CNRecTypeID){
                if(Event_Map.get(e.ASI_MFM_Event__c).ASI_MFM_Status__c == 'Cancel' || Event_Map.get(e.ASI_MFM_Event__c).ASI_MFM_Status__c == 'Complete')
                {
                    e.addError('Outlet cannot be uploaded/added if the event under cancel or complete status');
                }
                if(e.ASI_MFM_Event_Type__c != Event_Map.get(e.ASI_MFM_Event__c).ASI_MFM_Event_Type__c && e.ASI_MFM_Event_Type__c != Event_Map.get(e.ASI_MFM_Event__c).ASI_MFM_Sub_Event_Type__c)
                {
                    e.addError('Event Outlet Event Type not match with Key Event Type and Sub Event Type');
                }
            }
		}
		System.debug(SEventID);
		List<ASI_MFM_Event__c> LEventUpdate = new List<ASI_MFM_Event__c>();
		List<ASI_MFM_Event__c> LEvent = [Select id, name, ASI_MFM_Event_Outlet_Count__c  
			from ASI_MFM_Event__c where id IN :SEventID];    
		for(ASI_MFM_Event__c e : LEvent){
			System.debug(e.id +'/'+e.ASI_MFM_Event_Outlet_Count__c);
			if(e.ASI_MFM_Event_Outlet_Count__c == 0){
				e.ASI_MFM_Status__c = 'On Going';
				LEventUpdate.add(e);
			}
		}
		if(LEventUpdate.size()>0){
			update LEventUpdate;
		}     
		
	}
    
    public static void routineBeforeUpsert(list<ASI_MFM_Event_Outlet__c> trigger_new, map<id, ASI_MFM_Event_Outlet__c> trigger_oldMap) {
        Map<String, id> MRecType = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Event_Outlet__c');
		string CNRecTypeID = MRecType.get('ASI_MFM_CN_Event_Outlet');
        Set<id> CNOutletId = new Set<Id>();
        for(ASI_MFM_Event_Outlet__c e : trigger_new){
			if(e.RecordTypeId == CNRecTypeID || e.RecordTypeId == null){
				CNOutletId.add(e.ASI_MFM_Outlet__c);
			}
		}
        if (CNOutletId.size()>0){
            Map<id, id> CustomerMap = new Map<id, id>();
            for( ASI_CRM_AccountsAdditionalField__c c :[Select ASI_CRM_Account__c,id From ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN :CNOutletId]){
                CustomerMap.put(c.ASI_CRM_Account__c, c.id);
            }
            for(ASI_MFM_Event_Outlet__c e : trigger_new){
                e.ASI_MFM_CN_Customer__c = CustomerMap.get(e.ASI_MFM_Outlet__c);
            }
        }

    }
}