/*********************************************************************************
 * Name: ASI_KOR_SRClonePlanningDetail
 * Description: Controller class for ASI_KOR_SRClonePlanningDetail
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-07-18       Vincent Lam             Created          
*/
public class ASI_KOR_SRClonePlanningDetail{
	
	public Id headerId = ApexPages.currentPage().getParameters().get('id');
	
	public ASI_KOR_SRClonePlanningDetail(ApexPages.StandardController controller) {
        
    }
	
	public pageReference cloneDetails() {
		
		ASI_KOR_SR_Proposal_Header__c headerObject = retrieveHeader(headerId);
		List<string> list_venueID = retrieveVenueID(headerObject.ownerid);
		map<string, string> map_brand_byBrand = retrieveByBrand(headerId);
		List<ASI_KOR_SR_Proposal_Detail__c> list_detailToDelete = retrieveDetails_thisMonth(headerId);
		map<string, ASI_KOR_SR_Proposal_Detail__c> map_detailFromPrepayment = retrieveDetails_thisMonthPrepayment(headerId);
		List<ASI_KOR_SR_Proposal_Detail__c> list_detailToInsert = new List<ASI_KOR_SR_Proposal_Detail__c>();
		List<ASI_KOR_SR_Proposal_Detail__c> list_detailToUpdate = new List<ASI_KOR_SR_Proposal_Detail__c>();
		
		for (ASI_KOR_SR_Proposal_Detail__c d : retrieveDetails_lastMonth(headerObject.ASI_KOR_Year__c, headerObject.ASI_KOR_Month__c, list_venueID)){
			string key = d.ASI_KOR_Venue__c + '_' + d.ASI_KOR_Brand__c;
			if (map_detailFromPrepayment.containsKey(key)){
				ASI_KOR_SR_Proposal_Detail__c existingDetail = map_detailFromPrepayment.get(key);
				existingDetail.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = d.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c;
				existingDetail.ASI_KOR_Target_Volume__c = d.ASI_KOR_Target_Volume__c;
				list_detailToUpdate.add(existingDetail);
			} else {
				ASI_KOR_SR_Proposal_Detail__c newDetail = new ASI_KOR_SR_Proposal_Detail__c(
					ASI_KOR_Venue__c = d.ASI_KOR_Venue__c,
					ASI_KOR_Brand__c = d.ASI_KOR_Brand__c,
					ASI_KOR_Proposal_Unit_Cost_Basic_CA__c = d.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c,
					ASI_KOR_Target_Volume__c = d.ASI_KOR_Target_Volume__c,
                    ASI_KOR_Business_Rationale__c = d.ASI_KOR_Business_Rationale__c,
					ASI_KOR_SR_Proposal_ID__c = headerId,
					ASI_KOR_SR_Proposal_By_Brand__c = map_brand_byBrand.get(d.ASI_KOR_Brand__c)
				);
				list_detailToInsert.add(newDetail);
			}
		}
		
		if (list_detailToDelete.size()>0) delete list_detailToDelete;
		if (list_detailToInsert.size()>0) insert list_detailToInsert;
		if (list_detailToUpdate.size()>0) update list_detailToUpdate;
		
		return new PageReference('/'+headerId);
	}
	
	private ASI_KOR_SR_Proposal_Header__c retrieveHeader(string headerId){
		return [select id, ASI_KOR_Month__c, ASI_KOR_Year__c, ownerid from ASI_KOR_SR_Proposal_Header__c where id = :headerId limit 1];
	}
	
	private List<string> retrieveVenueID(string ownerid){
		List<string> list_venueID = new List<string>();
		for(account a : [
			select id from account 
			where ASI_KOR_Venue_Status__c = 'Active'
            and ownerid = :ownerid
            and recordtype.developername = 'ASI_KOR_Venue'
		]){
			list_venueID.add(a.id);
		}
		return list_venueID;
	}
	
	private map<string, string> retrieveByBrand(string headerId){
		map<string, string> map_brand_byBrand = new map<string, string>();
		for(ASI_KOR_SR_Proposal_By_Brand__c b : [select id, ASI_KOR_Brand__c from ASI_KOR_SR_Proposal_By_Brand__c where ASI_KOR_SR_Proposal_Header__c = :headerId]){
			map_brand_byBrand.put(b.ASI_KOR_Brand__c, b.id);
		}
		return map_brand_byBrand;
	}
	
	private List<ASI_KOR_SR_Proposal_Detail__c> retrieveDetails_thisMonth(string headerId){
		return [
			select id
			from ASI_KOR_SR_Proposal_Detail__c
			where ASI_KOR_SR_Proposal_ID__c = :headerId
			and ASI_KOR_Is_Pre_payment__c = false
		];
	}
	
	private map<string, ASI_KOR_SR_Proposal_Detail__c> retrieveDetails_thisMonthPrepayment(string headerId){
		map<string, ASI_KOR_SR_Proposal_Detail__c> map_detailFromPrepayment = new map<string, ASI_KOR_SR_Proposal_Detail__c>();
		for (ASI_KOR_SR_Proposal_Detail__c sr : [
			select id, ASI_KOR_Brand__c, ASI_KOR_Venue__c
			from ASI_KOR_SR_Proposal_Detail__c
			where ASI_KOR_SR_Proposal_ID__c = :headerId
			and ASI_KOR_Is_Pre_payment__c = true
		]){
			string key = sr.ASI_KOR_Venue__c + '_' + sr.ASI_KOR_Brand__c;
			map_detailFromPrepayment.put(key, sr);
		}
		return map_detailFromPrepayment;
	}
	
	private List<ASI_KOR_SR_Proposal_Detail__c> retrieveDetails_lastMonth(string yearStr, string monthStr, List<string> list_venueID){
		Date thisProposalDate = Date.newInstance(integer.valueOf(yearStr), integer.valueOf(monthStr), 1);
		Date lastDate = thisProposalDate.addMonths(-1);
		Datetime lastDateTime = Datetime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));
		string lastYear = lastDateTime.format('yyyy');
		string lastMonth = lastDateTime.format('M');
		return [
			select ASI_KOR_Venue__c, ASI_KOR_Brand__c, ASI_KOR_Proposal_Unit_Cost_Basic_CA__c, ASI_KOR_Target_Volume__c, ASI_KOR_Business_Rationale__c
			from ASI_KOR_SR_Proposal_Detail__c
			where ASI_KOR_Venue__c in :list_venueID
			and ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Year__c = :lastYear
			and ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Month__c = :lastMonth
			and ASI_KOR_System_Generated__c = false
		];
	}
}