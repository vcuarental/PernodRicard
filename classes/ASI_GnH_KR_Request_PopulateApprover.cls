/******************************************************************************************
 * Name:ASI_KR_GnH_Request_PopulateApprover
 * Description: Auto assign the approver to GnH records
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------
 * 2017-05-04       Laputa: Kevin Choi      Created
 * 2017-11-28		Laputa: Kevin Choi		Add ASI_GnH_Recipient_Type__c as criteria
*******************************************************************************************/
public without sharing class ASI_GnH_KR_Request_PopulateApprover extends ASI_GnH_Request_TriggerAbstract{

    private static final String ROUTE_TYPE_RECORD_TYPE             = 'ASI_GnH_KR_Route_Type';

    private static final String APPROVER_TYPE_LINE_MANAGER         = 'Line Manager';
    private static final String APPROVER_TYPE_USER                 = 'User';

    private static final String REQUEST_TYPE_OFFER                 = 'Offer';
    private static final String REQUEST_TYPE_RECEIVE                = 'Receive';
    private static final List<String> APPROVER_FIELD_API_NAME_LIST = new String[] {
        'ASI_GnH_Sys_Approver_1__c',
        'ASI_GnH_Sys_Approver_2__c',
        'ASI_GnH_Sys_Approver_3__c',
        'ASI_GnH_Sys_Approver_4__c',
        'ASI_GnH_Sys_Approver_5__c'
    };

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> newList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {

        System.debug('KR Debug Message Running');

        //Get the G&H Request Records which requested to assign approver
        /* Code Begin */
        List<ASI_GnH_Request__c> requestList = (List<ASI_GnH_Request__c>) newList;

        if(tAction == ASI_GnH_Request_TriggerAbstract.TriggerAction.BEFORE_UPDATE) {

            requestList = new List<ASI_GnH_Request__c>();
            Map<Id, ASI_GnH_Request__c> oldRequestIdMap = (Map<Id, ASI_GnH_Request__c>) oldMap;

            for(ASI_GnH_Request__c request : (List<ASI_GnH_Request__c>) newList) {
                if(request.ASI_GnH_Applicant__c != oldRequestIdMap.get(request.Id).ASI_GnH_Applicant__c || 
                   request.ASI_GnH_Company__c != oldRequestIdMap.get(request.Id).ASI_GnH_Company__c || 
                   request.ASI_GnH_Department__c != oldRequestIdMap.get(request.Id).ASI_GnH_Department__c|| 
                   request.ASI_GnH_Amount_per_Recipient__c != oldRequestIdMap.get(request.Id).ASI_GnH_Amount_per_Recipient__c|| 
                   request.ASI_GnH_PAX__c != oldRequestIdMap.get(request.Id).ASI_GnH_PAX__c ||
                   request.ASI_GnH_Recipient_Type__c != oldRequestIdMap.get(request.Id).ASI_GnH_Recipient_Type__c) {
                    requestList.add(request);
                }

            }	

        }
        system.debug('Found Record :'+requestList);
        /* Code End */

        //Get the Route Type Records which related to the company and department of G&H Request Records 
        //Get the User Records which related to the applicant of G&H Request Records
        //Get the G&H Type which related to the  G&H Request Records
        //Get the Recipient Type Records which related to the External Party of G&H Request Records
        //Get the Request Record Type (Offer/Receive) which related to G&H Request Records
        /* Code Begin */
        List<String> companyList = new List<String>();
        List<String> departmentList = new List<String>();
        List<String> applicantList = new List<String>();
        List<String> requestRTList = new List<String>();
        List<String> gnhTypeList = new List<String>();
        List<String> RecipientTypeList = new List<String>();
        User ownerInfo = new User();

        for(ASI_GnH_Request__c request : requestList) {
            String requestRt = Global_RecordTypeCache.getRt(request.recordTypeId).developerName;
            system.debug('Request Record Type :'+requestRt + ' ' +requestRt.contains(REQUEST_TYPE_RECEIVE));
            if (String.isBlank(request.ASI_GnH_Company__c) && String.isBlank(request.ASI_GnH_Department__c)){
                ownerInfo = [select Id,ASI_GnH_Department__c, CompanyName from user where Id = : request.OwnerId];
                system.debug('No Company and Department found, soql from user: '+ownerInfo);
            }
            if(String.isNotBlank(request.ASI_GnH_Company__c)) {
                companyList.add(request.ASI_GnH_Company__c);
            }else{
                companyList.add(ownerInfo.CompanyName);
            }

            if(String.isNotBlank(request.ASI_GnH_Department__c)) {
                departmentList.add(request.ASI_GnH_Department__c);
            }else{
                departmentList.add(ownerInfo.ASI_GnH_Department__c);
            }

            if(String.isNotBlank(request.ASI_GnH_Applicant__c)) {
                applicantList.add(request.ASI_GnH_Applicant__c);
            }else{
                applicantList.add(request.OwnerId);
            }

            if(String.isNotBlank(request.ASI_GnH_Type__c)) {
                gnhTypeList.add(request.ASI_GnH_Type__c);
            }

            if(String.isNotBlank(request.ASI_GnH_Recipient_Type__c)) {
                RecipientTypeList.add(request.ASI_GnH_Recipient_Type__c);
            }

            if (requestRt.contains(REQUEST_TYPE_OFFER)){
                requestRTList.add(REQUEST_TYPE_OFFER);
            }
            else if(requestRt.contains(REQUEST_TYPE_RECEIVE)){
                requestRTList.add(REQUEST_TYPE_RECEIVE);
            }                
        }
        System.debug('Queery Param: '+ companyList+' '+departmentList+' '+applicantList+' '+gnhTypeList+' '+RecipientTypeList+' '+requestRTList);

        List<ASI_GnH_Route_Type__c> routeTypeList = [SELECT ASI_GnH_Company__c, ASI_GnH_Department__c, ASI_GnH_User__c,ASI_GnH_Type__c,ASI_GnH_GnH_Type__c,ASI_GnH_External_Party_Type__c,
                                                     (SELECT ASI_GnH_Approver_Name__c, ASI_GnH_Approver_Type__c, ASI_GnH_Threshold_Amount__c 
                                                      FROM ASI_GnH_Route_Rule_Details__r
                                                      ORDER BY Name ASC)
                                                     FROM ASI_GnH_Route_Type__c
                                                     WHERE RecordType.DeveloperName = :ROUTE_TYPE_RECORD_TYPE
                                                     AND ASI_GnH_Company__c in :companyList
                                                     AND ASI_GnH_Department__c in :departmentList
                                                     AND ASI_GnH_Type__c in :requestRTList
                                                     AND ASI_GnH_GnH_Type__c in :gnhTypeList
                                                     AND ASI_GnH_External_Party_Type__c in :RecipientTypeList];

        Map<Id, User> userIdMap = new Map<Id, User>([SELECT Id, Name, ManagerId, Manager.ManagerId
                                                     FROM User
                                                     WHERE Id in :applicantList]); 

        system.debug('Found Route Type List :'+routeTypeList);

        /* Code End */

        //Put the Route Type Records into to a map. The structure of map is <[Company Name]:[Department Name]:[Request Record Type(Offer/Receive)]:[GnH Type]:[External Party Type]:[User Name], Route Type Record>
        /* Code Begin */                                             			
        Map<String, ASI_GnH_Route_Type__c> routeTypeMap = new Map<String, ASI_GnH_Route_Type__c>();

        for(ASI_GnH_Route_Type__c routeType : routeTypeList) {

            String company = String.isNotBlank(routeType.ASI_GnH_Company__c) ? String.valueOf(routeType.ASI_GnH_Company__c) : '--';
            String department = String.isNotBlank(routeType.ASI_GnH_Department__c) ? String.valueOf(routeType.ASI_GnH_Department__c) : '--';
            String applicant = String.isNotBlank(routeType.ASI_GnH_User__c) ? String.valueOf(routeType.ASI_GnH_User__c) : '--';
            String routeRtType = String.isNotBlank(routeType.ASI_GnH_Type__c) ? String.valueOf(routeType.ASI_GnH_Type__c) : '--';
            String gnhType = String.isNotBlank(routeType.ASI_GnH_GnH_Type__c) ? String.valueOf(routeType.ASI_GnH_GnH_Type__c) : '--';
            String externalParty = String.isNotBlank(routeType.ASI_GnH_External_Party_Type__c) ? String.valueOf(routeType.ASI_GnH_External_Party_Type__c) : '--';
            String routeTypeMapKey = company + ':' + department + ':' + routeRtType + ':' + gnhType + ':' + externalParty + ':' + applicant;

            routeTypeMap.put(routeTypeMapKey, routeType);

        }
        /* Code End */

        //Assign approver to G&H Request records
        //Remark : There contains two types(User is specified or not) of Route Type Record.
        //			Only Assign the approver when the amount is above the threshold.
        /* Code Begin */
        for(ASI_GnH_Request__c request : requestList) {

            clearApprover(request);
            String requestRt = Global_RecordTypeCache.getRt(request.recordTypeId).developerName;
            String routeRtType;
            if (requestRt.contains(REQUEST_TYPE_OFFER)){
                routeRtType  = REQUEST_TYPE_OFFER;
            }
            else if(requestRt.contains(REQUEST_TYPE_RECEIVE)){
                routeRtType = REQUEST_TYPE_RECEIVE;
            }  
            //Create key to get route details from SOQL
            String company = String.isNotBlank(request.ASI_GnH_Company__c) ? String.valueOf(request.ASI_GnH_Company__c) :String.valueOf(ownerInfo.CompanyName);
            String department = String.isNotBlank(request.ASI_GnH_Department__c) ? String.valueOf(request.ASI_GnH_Department__c) : String.valueOf(ownerInfo.ASI_GnH_Department__c);
            String applicant = String.isNotBlank(request.ASI_GnH_Applicant__c) ? String.valueOf(request.ASI_GnH_Applicant__c) : '--';
            String gnhType = String.isNotBlank(request.ASI_GnH_Type__c) ? String.valueOf(request.ASI_GnH_Type__c) : '--';
            String externalParty = String.isNotBlank(request.ASI_GnH_Recipient_Type__c) ? String.valueOf(request.ASI_GnH_Recipient_Type__c) : '--';
            String routeTypeMapKeyWithUser = company + ':' + department + ':' + routeRtType + ':' + gnhType + ':' + externalParty + ':' + applicant;
            String routeTypeMapKeyWithoutUser = company + ':' + department + ':' + routeRtType + ':' + gnhType + ':' + externalParty + ':' + '--';

            List<ASI_GnH_Route_Rule_Detail__c> routeDetailList;

            if(routeTypeMap.get(routeTypeMapKeyWithUser) != null) {

                routeDetailList = routeTypeMap.get(routeTypeMapKeyWithUser).ASI_GnH_Route_Rule_Details__r;
                system.debug('With User: '+routeDetailList);

            } else if(routeTypeMap.get(routeTypeMapKeyWithoutUser) != null) {

                routeDetailList = routeTypeMap.get(routeTypeMapKeyWithoutUser).ASI_GnH_Route_Rule_Details__r;
                system.debug('Without User: '+routeDetailList);

            }

            if(routeDetailList != null) {

                for(ASI_GnH_Route_Rule_Detail__c routeDetail : routeDetailList) {

                    Decimal thresholdAmount;
                    //Define the threshold value of this route detail
                    if(routeDetail.ASI_GnH_Threshold_Amount__c != null){
                        thresholdAmount = routeDetail.ASI_GnH_Threshold_Amount__c;
                    }else{
                        thresholdAmount = 0;// if no threshold value, assign 0
                    }
                    if(routeDetail.ASI_GnH_Approver_Type__c.endsWithIgnoreCase(APPROVER_TYPE_LINE_MANAGER)) {

                        if(userIdMap.get(applicant) != null) {

                            checkApprover(request, userIdMap.get(applicant).ManagerId, thresholdAmount);

                        }

                    } else if(routeDetail.ASI_GnH_Approver_Type__c.endsWithIgnoreCase(APPROVER_TYPE_USER)) {

                        checkApprover(request, routeDetail.ASI_GnH_Approver_Name__c, thresholdAmount);

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
}