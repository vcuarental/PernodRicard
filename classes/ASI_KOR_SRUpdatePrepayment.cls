/*********************************************************************************************************************************************************
* Name : ASI_KOR_SRUpdatePrepayment 
* Created : Vincent Lam
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2017-08-01       Laputa: Vincent         Created
*********************************************************************************************************************************************************/
public Class ASI_KOR_SRUpdatePrepayment extends ASI_KOR_TriggerAbstract{
    
    
    public ASI_KOR_SRUpdatePrepayment() {
        super('ASI_KOR_SRUpdatePrepayment');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if (tAction == TriggerAction.BEFORE_INSERT) {
            
            List<ASI_KOR_SR_Proposal_Detail__c> srDetails = (List<ASI_KOR_SR_Proposal_Detail__c>) sObjList;
			Set<string> list_headerID = getHeaderID(srDetails);
			map<string, ASI_KOR_SR_Proposal_Detail__c> map_existingDetails = getExistingDetails(list_headerID);
			
			List<ASI_KOR_SR_Proposal_Detail__c> list_detailsToUpdate = new List<ASI_KOR_SR_Proposal_Detail__c>();
			for (ASI_KOR_SR_Proposal_Detail__c sr : srDetails){
				string key = sr.ASI_KOR_SR_Proposal_ID__c + '_' + sr.ASI_KOR_Venue__c + '_' + sr.ASI_KOR_Brand__c;
				if (map_existingDetails.containsKey(key)){
					ASI_KOR_SR_Proposal_Detail__c existingDetail = map_existingDetails.get(key);
					existingDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = sr.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c;
					existingDetail.ASI_KOR_Target_Volume__c = sr.ASI_KOR_Target_Volume__c;
					sr.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = 0;
					sr.ASI_KOR_Target_Volume__c = 0;
					list_detailsToUpdate.add(existingDetail);
				}
			}
			
			if (list_detailsToUpdate.size()>0) update list_detailsToUpdate;
			
        }
    }
	
	public Set<string> getHeaderID(List<ASI_KOR_SR_Proposal_Detail__c> srDetails){
		Set<string> list_headerID = new Set<string>();
		for (ASI_KOR_SR_Proposal_Detail__c sr : srDetails){
			list_headerID.add(sr.ASI_KOR_SR_Proposal_ID__c);
		}
		return list_headerID;
	}
	
	public map<string, ASI_KOR_SR_Proposal_Detail__c> getExistingDetails(Set<string> list_headerID){
		map<string, ASI_KOR_SR_Proposal_Detail__c> map_existingDetails = new map<string, ASI_KOR_SR_Proposal_Detail__c>();
		for (ASI_KOR_SR_Proposal_Detail__c sr : [
			select id, ASI_KOR_SR_Proposal_ID__c, ASI_KOR_Venue__c, ASI_KOR_Brand__c
			from ASI_KOR_SR_Proposal_Detail__c 
			where ASI_KOR_SR_Proposal_ID__c in :list_headerID
			and ASI_KOR_Is_Pre_payment__c = true
		]){
			string key = sr.ASI_KOR_SR_Proposal_ID__c + '_' + sr.ASI_KOR_Venue__c + '_' + sr.ASI_KOR_Brand__c;
			map_existingDetails.put(key, sr);
		}
		return map_existingDetails;
	}
	
}