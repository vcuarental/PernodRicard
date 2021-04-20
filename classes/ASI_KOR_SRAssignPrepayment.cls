/*********************************************************************************************************************************************************
* Name : ASI_KOR_SRAssignPrepayment 
* Created : Vincent Lam
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2017-07-31       Laputa: Vincent         Created
*********************************************************************************************************************************************************/
public Class ASI_KOR_SRAssignPrepayment extends ASI_KOR_TriggerAbstract{
    
    
    public ASI_KOR_SRAssignPrepayment() {
        super('ASI_KOR_SRAssignPrepayment');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if (tAction == TriggerAction.AFTER_INSERT) {
            
            List<ASI_KOR_SR_Proposal_Header__c> srPropHeader = (List<ASI_KOR_SR_Proposal_Header__c>) sObjList;
			
            map<string, string> map_criteria_headerID = getCriteria(srPropHeader);
            map<string, id> map_srByBrand = getSRByBrand(srPropHeader);
			map<string, List<ASI_KOR_Prepayment_Master__c>> map_criteria_prepayment = getPrepayment(map_criteria_headerID.keySet());
			List<ASI_KOR_SR_Proposal_Detail__c> srDetailToInsert = generateSRDetail(map_criteria_headerID, map_criteria_prepayment, map_srByBrand);
			
            system.debug(map_criteria_prepayment);
            system.debug(srDetailToInsert);
            
			if (srDetailToInsert.size()>0) insert srDetailToInsert;
			
        }
    }
	
	public map<string, string> getCriteria(List<ASI_KOR_SR_Proposal_Header__c> srPropHeader){
		map<string, string> map_headerID_criteria = new map<string, string>();
		for (ASI_KOR_SR_Proposal_Header__c sr: srPropHeader){
			string criteria = sr.ASI_KOR_Year__c + '_' + sr.ASI_KOR_Month__c + '_' + sr.ownerid;
			map_headerID_criteria.put(criteria, sr.id);
        }
		return map_headerID_criteria;
	}
	
	public map<string, id> getSRByBrand(List<ASI_KOR_SR_Proposal_Header__c> srPropHeader){
		map<string, id> map_srByBrand = new map<string, id>();
		list<string> list_headerID = new list<string>();
		for (ASI_KOR_SR_Proposal_Header__c sr: srPropHeader){
			list_headerID.add(sr.id);
        }
		for (ASI_KOR_SR_Proposal_By_Brand__c sr: [
			select id, ASI_KOR_Brand__c, ASI_KOR_SR_Proposal_Header__c
			from ASI_KOR_SR_Proposal_By_Brand__c
			where ASI_KOR_SR_Proposal_Header__c in :list_headerID
		]){
			string byBrand = sr.ASI_KOR_SR_Proposal_Header__c + '_' + sr.ASI_KOR_Brand__c;
			map_srByBrand.put(byBrand, sr.id);
        }
		return map_srByBrand;
	}
	
	public map<string, List<ASI_KOR_Prepayment_Master__c>> getPrepayment(Set<string> list_criteria){
		map<string, List<ASI_KOR_Prepayment_Master__c>> map_criteria_prepayment = new map<string, List<ASI_KOR_Prepayment_Master__c>>();
		
		string query = 'select id, ' +
						'ASI_KOR_Brand__c, ' +
						'ASI_KOR_Promotion_Month__c, ' +
						'ASI_KOR_Promotion_Year__c, ' +
						'ASI_KOR_Remarks__c, ' +
						'ASI_KOR_Target_Unit_Cost__c, ' +
						'ASI_KOR_Venue__c, ' +
						'ASI_KOR_Venue__r.ownerid ' +
						'FROM ASI_KOR_Prepayment_Master__c ' +
						'WHERE (';
		for (string s : list_criteria){
			list<string> criteria = s.split('_');
			string q = '(';				
			q += 'ASI_KOR_Promotion_Year__c = \'' + criteria[0] + '\'' +
				'and ASI_KOR_Promotion_Month__c = \'' + criteria[1] + '\'' +
				'and ASI_KOR_Venue__r.ownerid = \'' + criteria[2] + '\'';
			q += ') or ';
			query += q;
		}
		query = query.subString(0,query.length()-4);
		query += ') ';		
		for (ASI_KOR_Prepayment_Master__c prepayment : (List<ASI_KOR_Prepayment_Master__c>)Database.query(query)){
			string key = prepayment.ASI_KOR_Promotion_Year__c + '_' + prepayment.ASI_KOR_Promotion_Month__c + '_' + prepayment.ASI_KOR_Venue__r.ownerid;
			List<ASI_KOR_Prepayment_Master__c> list_prepayment = map_criteria_prepayment.containsKey(key) ? map_criteria_prepayment.get(key) : new List<ASI_KOR_Prepayment_Master__c>();
			list_prepayment.add(prepayment);
			map_criteria_prepayment.put(key, list_prepayment);
		}
			
		return map_criteria_prepayment;
	}
	
	public List<ASI_KOR_SR_Proposal_Detail__c> generateSRDetail(map<string, string> map_criteria_headerID, map<string, List<ASI_KOR_Prepayment_Master__c>> map_criteria_prepayment,  map<string, id> map_srByBrand){
		List<ASI_KOR_SR_Proposal_Detail__c> srDetailToInsert = new List<ASI_KOR_SR_Proposal_Detail__c>();
		for (string key: map_criteria_prepayment.keySet()){
			string headerId = map_criteria_headerID.get(key);
			for (ASI_KOR_Prepayment_Master__c prepayment : map_criteria_prepayment.get(key)){
				string byBrand = headerId + '_' + prepayment.ASI_KOR_Brand__c;
				if (map_srByBrand.containsKey(byBrand)){
					ASI_KOR_SR_Proposal_Detail__c detail = new ASI_KOR_SR_Proposal_Detail__c(
						ASI_KOR_SR_Proposal_ID__c = headerId,
						ASI_KOR_SR_Proposal_By_Brand__c = map_srByBrand.get(byBrand),
						ASI_KOR_Brand__c = prepayment.ASI_KOR_Brand__c,
						ASI_KOR_Venue__c = prepayment.ASI_KOR_Venue__c,
						ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = prepayment.ASI_KOR_Target_Unit_Cost__c == null ? 0 : prepayment.ASI_KOR_Target_Unit_Cost__c,
                        ASI_KOR_Target_Volume__c = 0,
						ASI_KOR_Business_Rationale__c = prepayment.ASI_KOR_Remarks__c,
						ASI_KOR_Is_Pre_payment__c = true,
                        ASI_KOR_From_Prepayment_Master__c = true
					);
					srDetailToInsert.add(detail);
				}
			}
        }
		return srDetailToInsert;
	}
}