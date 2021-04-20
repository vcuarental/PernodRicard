trigger ASI_CRM_CN_IssueZone_AfterUpsert_Trigger on ASI_CRM_Issue_Zone__c (after insert, after update) {

/* 2014-02-11
    Old Name: ASI_CRM_CN_AddShareChatterFollower 
   Created by Stella Sing
   Goal: Add followers & Sharings to newly created record
*/	
	//set<string> strDevName = new set<string>();
	//strDevName.add('ASI_CRM_CN');
	//set<id> RTSetid = Global_RecordTypeCache.getRtIdSet('ASI_CRM_Issue_Zone__c', strDevName);

    set<id> RTSetid = getRTIdset('ASI_CRM_Issue_Zone__c', 'ASI_CRM_CN%');
    
	List<ASI_CRM_Issue_Zone__c> IZList = new List<ASI_CRM_Issue_Zone__c>();
	for (ASI_CRM_Issue_Zone__c a : trigger.new){
		if (RTSetId.size() > 0)
			if (RTSetid.contains(a.RecordTypeId))
				IZList.add(a);
	}	
	if (IZList.size() > 0){
	    ASI_CRM_CN_ChatterSharing cs = new ASI_CRM_CN_ChatterSharing();
	    if (Trigger.isInsert){
	        cs.ASI_CRM_CN_AddShare(IZList);
	    }
        //20160224 Ben @ Elufa
        if(Trigger.isUpdate ){
            List<ASI_CRM_Issue_Zone__c> IZList2 = new List<ASI_CRM_Issue_Zone__c>();
            for(ASI_CRM_Issue_Zone__c obj : trigger.new){
                if(obj.ASI_CRM_CN_Reclassification__c != trigger.oldMap.get(obj.id).ASI_CRM_CN_Reclassification__c)
                	IZList2.add(obj);
            }
            cs.ASI_CRM_CN_AddShare(IZList2);
        }
        //20160224 End
	}
	public set<id> getRTIdset (string strsobjectName, string strDevName){
		set<id> RTidSet = new set<id>();
		list<recordType> RTList = [SELECT id FROM RecordType WHERE sObjectType = :strsobjectName AND DeveloperName LIKE :strDevName];
		if (RTList.size() > 0)
			for (RecordType a : RTList){
				RTidSet.add(a.id);
			}
		return RTidSet;
	}
		
}