public with sharing class ASI_MFM_EventNewController {
	public ASI_MFM_EventNewController(ApexPages.StandardController con){
		
	}
	public ASI_MFM_EventNewController(){
		
	}
	public pageReference redirect(){
		String Recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
		System.debug(ApexPages.currentPage().getParameters());
		Map<String, id> MplanRecType = ASI_MFM_function.getRecordTypeId('ASI_MFM_Plan__c');
		Boolean overRideplanID = false;
		System.debug(Recordtypeid + '/' + MplanRecType.get('ASI_MFM_CN_Plan'));
		overRideplanID = true;
		Set<id> SCNProf = new Set<id>();
		for(Profile p : [Select id from profile where name like 'ASI_MFM_CN%']){
			SCNProf.add(p.id);
		}
		System.debug(SCNProf);
		System.debug(UserInfo.getProfileId());
		Set<id> SProfID = new SEt<id>();
		for(Profile p : [Select id, name from Profile where name like 'ASI_MFM_CN' or name = 'System Administrator']){
			SProfID.add(p.id);
		}
		
		if(((String)MplanRecType.get('ASI_MFM_CN_Plan')).substring(0,15) == Recordtypeid || SProfID.contains(Userinfo.getProfileId())){
			overRideplanID = true;
		}
		
		string user_name = userinfo.getName();
		string selected_user = userinfo.getUserId();
		string obj_id = sObjectType.ASI_MFM_Event__c.getKeyPrefix();
		string field_id = ASI_MFM_Function.getFieldId('ASI_MFM_Event__c', 'ASI_MFM_Budget_Owner__c');
		String url = '/' + obj_id + '/e?retURL=%2F' + obj_id + '%2Fo&nooverride=1&CF' + field_id + '_lkid=' + selected_user + '&CF' + field_id + '=' + user_name;
		if(Recordtypeid != null && Recordtypeid != ''){
					url += '&RecordType=' + Recordtypeid;
				}
		
		
		pageReference p = new pageReference(url);
		p.setRedirect(true);
		return p;
	}
}