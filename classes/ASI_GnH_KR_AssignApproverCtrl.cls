/*************************************************************************************
 * Name: ASI_GnH_KR_AssignApproverCtrl
 * Description: Controller class for KR reassign approver controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------
 * 16/05/2017       Kevin Choi             Created          
*************************************************************************************/
public class ASI_GnH_KR_AssignApproverCtrl{
    private final static Map<String, Schema.SObjectField> GNH_FIELD_MAP = Schema.SObjectType.ASI_GnH_Request__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> ROUTE_TYPE_FIELD_MAP = Schema.SObjectType.ASI_GnH_Route_Type__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> ROUTE_TYPE_DETAIL_FIELD_MAP = Schema.SObjectType.ASI_GnH_Route_Rule_Detail__c.fields.getMap();

    private static final List<String> APPROVER_FIELD_API_NAME_LIST = new String[] {
        'ASI_GnH_Sys_Approver_1__c',
        'ASI_GnH_Sys_Approver_2__c',
        'ASI_GnH_Sys_Approver_3__c',
        'ASI_GnH_Sys_Approver_4__c',
        'ASI_GnH_Sys_Approver_5__c'
    };

    private static final String APPROVER_TYPE_LINE_MANAGER         = 'Line Manager';
    private static final String APPROVER_TYPE_USER                 = 'User';

    private static final String REQUEST_TYPE_OFFER                 = 'Offer';
    private static final String REQUEST_TYPE_RECEIVE                = 'Receive';
    public ASI_GnH_KR_AssignApproverCtrl(){
    }

    public PageReference reAssignApprover(){
        String gnhId = apexpages.currentpage().getparameters().get('id');
        ASI_GnH_Request__c gnhRequest = retrieveGnH(gnhId);
        gnhRequest = clearApprover(gnhRequest);

        Set<Id> userIdSet = new Set<Id>();
        Map<String,ASI_GnH_Route_Type__c > gnhRouteTypeMap = new Map<String,ASI_GnH_Route_Type__c>();

        for (ASI_GnH_Route_Type__c routeType : retrieveRouteTypeWithDetailList()){
            String key = '';

            String companyName = String.isBlank(routeType.ASI_GnH_Company__c)? '': String.valueOf(routeType.ASI_GnH_Company__c);
            String departmentName = String.isBlank(routeType.ASI_GnH_Department__c)? '': String.valueOf(routeType.ASI_GnH_Department__c);
            String applicant = String.isBlank(routeType.ASI_GnH_User__c) ?  '': String.valueOf(routeType.ASI_GnH_User__c);
            String gnhType = String.isBlank(routeType.ASI_GnH_GnH_Type__c) ? '': String.valueOf(routeType.ASI_GnH_GnH_Type__c);
            String externalParty = String.isBlank(routeType.ASI_GnH_External_Party_Type__c) ? '': String.valueOf(routeType.ASI_GnH_External_Party_Type__c);
            String routeRecordtype = String.isBlank(routeType.ASI_GnH_Type__c) ? '': String.valueOf(routeType.ASI_GnH_Type__c);

            String routeTypeMapKey = companyName + ':' + departmentName + ':' + routeRecordtype + ':' + gnhType + ':' + externalParty + ':' + applicant;
            gnhRouteTypeMap.put(routeTypeMapKey,routeType);

            for (ASI_GnH_Route_Rule_Detail__c routeDetail : routeType.ASI_GnH_Route_Rule_Details__r){
                if(String.isNotBlank(routeDetail.ASI_GnH_Approver_Name__c)){
                    userIdSet.add(routeDetail.ASI_GnH_Approver_Name__c);
                }
            }
        }

        Map<Id, User> userMap = new Map<Id, User>(retrieveUserList(userIdSet));
        gnhRequest = assignApprover(gnhRequest,gnhRouteTypeMap,userMap);
        return null;
    }


    private ASI_GnH_Request__c clearApprover(ASI_GnH_Request__c gnhRequest){
        for(Integer i = 1; i <= APPROVER_FIELD_API_NAME_LIST.size(); i++) {
            gnhRequest.put(APPROVER_FIELD_API_NAME_LIST[i-1],null);       
        }
        return gnhRequest; 
    }


    private ASI_GnH_Request__c assignApprover(ASI_GnH_Request__c gnhRequest, Map<String,ASI_GnH_Route_Type__c> gnhRouteTypeMap, Map<Id, User> userIdMap){

        String requestRt = Global_RecordTypeCache.getRt(gnhRequest.recordTypeId).developerName;
        String routeRtType;
        if (requestRt.contains(REQUEST_TYPE_OFFER)){
            routeRtType  = REQUEST_TYPE_OFFER;
        }
        else if(requestRt.contains(REQUEST_TYPE_RECEIVE)){
            routeRtType = REQUEST_TYPE_RECEIVE;
        } 

        String company = String.isNotBlank(gnhRequest.ASI_GnH_Company__c) ? String.valueOf(gnhRequest.ASI_GnH_Company__c) : '';
        String department = String.isNotBlank(gnhRequest.ASI_GnH_Department__c) ? String.valueOf(gnhRequest.ASI_GnH_Department__c) : '';
        String applicant = String.isNotBlank(gnhRequest.ASI_GnH_Applicant__c) ? String.valueOf(gnhRequest.ASI_GnH_Applicant__c) : '';
        String gnhType = String.isNotBlank(gnhRequest.ASI_GnH_Type__c) ? String.valueOf(gnhRequest.ASI_GnH_Type__c) : '';
        String externalParty = String.isNotBlank(gnhRequest.ASI_GnH_Recipient_Type__c) ? String.valueOf(gnhRequest.ASI_GnH_Recipient_Type__c) : '';

        String routeTypeMapKeyWithUser = company + ':' + department + ':' + routeRtType + ':' + gnhType + ':' + externalParty + ':' + applicant;
        String routeTypeMapKeyWithoutUser = company + ':' + department + ':' + routeRtType + ':' + gnhType + ':' + externalParty + ':' + '';

        List<ASI_GnH_Route_Rule_Detail__c> routeDetailList;

        if(gnhRouteTypeMap.get(routeTypeMapKeyWithUser) != null) {
            routeDetailList = gnhRouteTypeMap.get(routeTypeMapKeyWithUser).ASI_GnH_Route_Rule_Details__r;
        } else if(gnhRouteTypeMap.get(routeTypeMapKeyWithoutUser) != null) {
            routeDetailList = gnhRouteTypeMap.get(routeTypeMapKeyWithoutUser).ASI_GnH_Route_Rule_Details__r;
        }

        if(routeDetailList != null) {
            for(ASI_GnH_Route_Rule_Detail__c routeDetail : routeDetailList) {
                //Define the threshold value of this route detail
                Decimal thresholdAmount = routeDetail.ASI_GnH_Threshold_Amount__c;

                if(routeDetail.ASI_GnH_Approver_Type__c.endsWithIgnoreCase(APPROVER_TYPE_LINE_MANAGER)) {
                    if(userIdMap.get(gnhRequest.ASI_GnH_Applicant__c) != null) {
                        checkApprover(gnhRequest, userIdMap.get(gnhRequest.ASI_GnH_Applicant__c).ManagerId, thresholdAmount);
                    }
                } else if(routeDetail.ASI_GnH_Approver_Type__c.endsWithIgnoreCase(APPROVER_TYPE_USER)) {
                    checkApprover(gnhRequest, routeDetail.ASI_GnH_Approver_Name__c, thresholdAmount);
                }
            }
        }
        return gnhRequest; 
    }
    
    	private void checkApprover(ASI_GnH_Request__c request, Id approverId, Decimal thresholdAmount) {        
		for(Integer i = 1; i <= APPROVER_FIELD_API_NAME_LIST.size() ; i++) {			
			if(request.get(APPROVER_FIELD_API_NAME_LIST[i - 1]) == approverId) {
				for(Integer j = i ; j < APPROVER_FIELD_API_NAME_LIST.size() ; j++) {
					request.put(APPROVER_FIELD_API_NAME_LIST[j], null);
				}
				return;
			}
		}
		assignNextApprover(request, approverId,thresholdAmount);		
	}

	private void assignNextApprover(ASI_GnH_Request__c request, Id approverId, Decimal thresholdAmount) {		
		for(String approverFieldAPIName : APPROVER_FIELD_API_NAME_LIST) {            
			if(String.isBlank((String)request.get(approverFieldAPIName))) {
                //Check if the request amount is above threshold.
                if(request.ASI_GnH_Amount_per_Recipient__c > thresholdAmount){
					request.put(approverFieldAPIName, approverId);
					return;
                }              
			}
		} 
	}
    /***************
    Data Retrievement Function
    ***************/   
    private ASI_GnH_Request__c retrieveGnH(Id gnhId) {
        String query = 'SELECT ' + genQueryFIeld(GNH_FIELD_MAP) + 
            ', RecordType.DeveloperName ' +  
            'FROM ASI_GnH_Request__c ' + 
            'WHERE Id = :gnhId';
        List<ASI_GnH_Request__c> gnhList = (List<ASI_GnH_Request__c>) Database.query(query);
        return gnhList.size() > 0 ? gnhList.get(0) : null;
    }

    private List<ASI_GnH_Route_Type__c> retrieveRouteTypeWithDetailList() {
        String query = 'SELECT ' + genQueryFIeld(ROUTE_TYPE_FIELD_MAP) +
            ', (SELECT ' + genQueryFIeld(ROUTE_TYPE_DETAIL_FIELD_MAP) + ' FROM ASI_GnH_Route_Rule_Details__r Order By Name ASC) ' + 
            'FROM ASI_GnH_Route_Type__c ' + 
            'WHERE RecordType.DeveloperName = \'ASI_GnH_KR_Route_Type\'';
        return (List<ASI_GnH_Route_Type__c>) Database.query(query);
    }

    private List<User> retrieveUserList(Set<Id> userIdSet) {
        String query = 'SELECT Id, Name, ManagerId, Manager.ManagerId, CompanyName, Department, ASI_Company_Name__c, ASI_Department__c ' + 
            'FROM User ' + 
            'WHERE Id in :userIdSet';
        return (List<User>) Database.query(query);
    }
    /***************
    Tools Function
    ***************/    
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
}