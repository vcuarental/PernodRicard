/*********************************************************************************
 * Name:ASI_GnH_Request_PopulateApprover
 * Description: Auto assign the approver to GnH records
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2016-06-22       Laputa: Hugo Cheung     Created
*********************************************************************************/
public without sharing class ASI_GnH_Request_PopulateApprover extends ASI_GnH_Request_TriggerAbstract {

	private static final String ROUTE_TYPE_RECORD_TYPE             = 'ASI_GnH_TW_Route_Type';

	private static final String APPROVER_TYPE_LINE_MANAGER         = 'Line Manager';
	private static final String APPROVER_TYPE_USER                 = 'User';

	private static final List<String> APPROVER_FIELD_API_NAME_LIST = new String[] {
		'ASI_GnH_Sys_Approver_1__c',
		'ASI_GnH_Sys_Approver_2__c',
		'ASI_GnH_Sys_Approver_3__c',
		'ASI_GnH_Sys_Approver_4__c',
		'ASI_GnH_Sys_Approver_5__c'
	};

	public override void executeTriggerAction(TriggerAction tAction, List<sObject> newList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		
        System.debug('Debug Message Running');
        
		//Get the G&H Request Records which requested to assign approver
		/* Code Begin */
		List<ASI_GnH_Request__c> requestList = (List<ASI_GnH_Request__c>) newList;
		
		if(tAction == ASI_GnH_Request_TriggerAbstract.TriggerAction.BEFORE_UPDATE) {

			requestList = new List<ASI_GnH_Request__c>();
			Map<Id, ASI_GnH_Request__c> oldRequestIdMap = (Map<Id, ASI_GnH_Request__c>) oldMap;

			for(ASI_GnH_Request__c request : (List<ASI_GnH_Request__c>) newList) {

				if(request.ASI_GnH_Applicant__c != oldRequestIdMap.get(request.Id).ASI_GnH_Applicant__c || 
				   request.ASI_GnH_Company__c != oldRequestIdMap.get(request.Id).ASI_GnH_Company__c || 
				   request.ASI_GnH_Department__c != oldRequestIdMap.get(request.Id).ASI_GnH_Department__c) {
					requestList.add(request);
				}

			}	

		}
		/* Code End */

		//Get the Route Type Records which related to the company and department of G&H Request Records 
		//Get the User Records which related to the applicant of G&H Request Records
		/* Code Begin */
		List<String> companyList = new List<String>();
		List<String> departmentList = new List<String>();
		List<String> applicantList = new List<String>();

		for(ASI_GnH_Request__c request : requestList) {

			if(String.isNotBlank(request.ASI_GnH_Company__c)) {
				companyList.add(request.ASI_GnH_Company__c);
			}

			if(String.isNotBlank(request.ASI_GnH_Department__c)) {
				departmentList.add(request.ASI_GnH_Department__c);
			}

			if(String.isNotBlank(request.ASI_GnH_Applicant__c)) {
				applicantList.add(request.ASI_GnH_Applicant__c);
			}

		}

		List<ASI_GnH_Route_Type__c> routeTypeList = [SELECT ASI_GnH_Company__c, ASI_GnH_Department__c, ASI_GnH_User__c, 
		                                                    (SELECT ASI_GnH_Approver_Name__c, ASI_GnH_Approver_Type__c 
		                                                    	FROM ASI_GnH_Route_Rule_Details__r
		                                                    		ORDER BY Name ASC)
		                                            	FROM ASI_GnH_Route_Type__c
		                                            		WHERE RecordType.DeveloperName = :ROUTE_TYPE_RECORD_TYPE
		                                            			AND ASI_GnH_Company__c in :companyList
		                                            			AND ASI_GnH_Department__c in :departmentList];

		Map<Id, User> userIdMap = new Map<Id, User>([SELECT Id, Name, ManagerId, Manager.ManagerId
														FROM User
															WHERE Id in :applicantList]);                                            			

		/* Code End */

		//Put the Route Type Records into to a map. The structure of map is <[Company Name]:[Department Name]:[User Name], Route Type Record>
		/* Code Begin */                                             			
		Map<String, ASI_GnH_Route_Type__c> routeTypeMap = new Map<String, ASI_GnH_Route_Type__c>();

		for(ASI_GnH_Route_Type__c routeType : routeTypeList) {

			String company = String.isNotBlank(routeType.ASI_GnH_Company__c) ? String.valueOf(routeType.ASI_GnH_Company__c) : '--';
			String department = String.isNotBlank(routeType.ASI_GnH_Department__c) ? String.valueOf(routeType.ASI_GnH_Department__c) : '--';
			String applicant = String.isNotBlank(routeType.ASI_GnH_User__c) ? String.valueOf(routeType.ASI_GnH_User__c) : '--';
			String routeTypeMapKey = company + ':' + department + ':' + applicant;

			routeTypeMap.put(routeTypeMapKey, routeType);

		}
		/* Code End */

		//Assign approver to G&H Request records
		//Remark : There contains two types(User is specified or not) of Route Type Record.
		/* Code Begin */
		for(ASI_GnH_Request__c request : requestList) {

			clearApprover(request);

			String company = String.isNotBlank(request.ASI_GnH_Company__c) ? String.valueOf(request.ASI_GnH_Company__c) : '--';
			String department = String.isNotBlank(request.ASI_GnH_Department__c) ? String.valueOf(request.ASI_GnH_Department__c) : '--';
			String applicant = String.isNotBlank(request.ASI_GnH_Applicant__c) ? String.valueOf(request.ASI_GnH_Applicant__c) : '--';
			String routeTypeMapKeyWithUser = company + ':' + department + ':' + applicant;
			String routeTypeMapKeyWithoutUser = company + ':' + department + ':' + '--';

			List<ASI_GnH_Route_Rule_Detail__c> routeDetailList;
	
			if(routeTypeMap.get(routeTypeMapKeyWithUser) != null) {

				routeDetailList = routeTypeMap.get(routeTypeMapKeyWithUser).ASI_GnH_Route_Rule_Details__r;

			} else if(routeTypeMap.get(routeTypeMapKeyWithoutUser) != null) {

				routeDetailList = routeTypeMap.get(routeTypeMapKeyWithoutUser).ASI_GnH_Route_Rule_Details__r;

			}
			
			if(routeDetailList != null) {

				for(ASI_GnH_Route_Rule_Detail__c routeDetail : routeDetailList) {

					if(routeDetail.ASI_GnH_Approver_Type__c.endsWithIgnoreCase(APPROVER_TYPE_LINE_MANAGER)) {

						if(userIdMap.get(applicant) != null) {

							checkApprover(request, userIdMap.get(applicant).ManagerId);

						}

					} else if(routeDetail.ASI_GnH_Approver_Type__c.endsWithIgnoreCase(APPROVER_TYPE_USER)) {

						checkApprover(request, routeDetail.ASI_GnH_Approver_Name__c);

					}

				}

			}

		}
		/* Code End */

	}

	private void clearApprover(ASI_GnH_Request__c request) {

		for(String approverFieldAPIName : APPROVER_FIELD_API_NAME_LIST) {

			request.put(approverFieldAPIName, null);

		}

	}

	private void checkApprover(ASI_GnH_Request__c request, Id approverId) {
        
		for(Integer i = 1; i <= APPROVER_FIELD_API_NAME_LIST.size() ; i++) {
			
			if(request.get(APPROVER_FIELD_API_NAME_LIST[i - 1]) == approverId) {

				for(Integer j = i ; j < APPROVER_FIELD_API_NAME_LIST.size() ; j++) {

					request.put(APPROVER_FIELD_API_NAME_LIST[j], null);

				}
				return;

			}

		}

		assignNextApprover(request, approverId);
		
	}

	private void assignNextApprover(ASI_GnH_Request__c request, Id approverId) {
		
		for(String approverFieldAPIName : APPROVER_FIELD_API_NAME_LIST) {
            
			if(String.isBlank((String)request.get(approverFieldAPIName))) {

				request.put(approverFieldAPIName, approverId);
				return;
                
			}

		} 

	}

}