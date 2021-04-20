/*********************************************************************************
 * Name: ASI_CRM_VN_VPDetailSetProductListing
 * Description: Class for auto retrieving product listing from latest record
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 19/05/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_VPDetailSetProductListing {
    
    //Field Map
	private final static Map<String, Schema.SObjectField> VISITATION_PLAN_DETAIL_FIELD_MAP = Schema.SObjectType.ASI_HK_CRM_Visitation_Plan_Detail__c.fields.getMap();
    
    private final static String OFF_TRADE_OUTLET_RECORD_TYPE = 'ASI_CRM_VN_OffTrade_Visitation_Plan_Detail';
    
    public ASI_CRM_VN_VPDetailSetProductListing(List<sObject> sObjectList) {
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList = filterVisitationPlanDetailList((List<ASI_HK_CRM_Visitation_Plan_Detail__c>) sObjectList);
        Boolean isSuccess = assignProductListing(visitationPlanDetailList);
    }
    
    private List<ASI_HK_CRM_Visitation_Plan_Detail__c> filterVisitationPlanDetailList(List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList) {
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> filteredVisitationPlanDetailList = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
        for(ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail : visitationPlanDetailList) {
            if(Global_RecordTypeCache.getRt(visitationPlanDetail.RecordTypeId).developerName == OFF_TRADE_OUTLET_RECORD_TYPE) {
            	filteredVisitationPlanDetailList.add(visitationPlanDetail);
            }
        }
        return filteredVisitationPlanDetailList;
    }
    
    private Boolean assignProductListing(List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList) {
    	Set<Id> customerIdSet = new Set<Id>();
        for(ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail : visitationPlanDetailList) {
        	customerIdSet.add(visitationPlanDetail.ASI_CRM_MY_Customer__c);
        }
        
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> existingVisitationPlanList = retrieveVisitationPlanDetailList(customerIdSet);
       	Map<Id, ASI_HK_CRM_Visitation_Plan_Detail__c> latestVisitationPlanMap = new Map<Id, ASI_HK_CRM_Visitation_Plan_Detail__c>();
        for(ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail : existingVisitationPlanList) {
            if(latestVisitationPlanMap.containsKey(visitationPlanDetail.ASI_CRM_MY_Customer__c)) {
            	continue;
            } else {
            	latestVisitationPlanMap.put(visitationPlanDetail.ASI_CRM_MY_Customer__c, visitationPlanDetail);
            }
        }
        
        System.debug('Debug : ' + latestVisitationPlanMap);
        
        for(ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail : visitationPlanDetailList) {
            System.debug('Debug : ' + visitationPlanDetail.ASI_CRM_MY_Customer__c);
        	if(latestVisitationPlanMap.containsKey(visitationPlanDetail.ASI_CRM_MY_Customer__c)) {
                visitationPlanDetail.ASI_CRM_VN_Product_Listing__c = latestVisitationPlanMap.get(visitationPlanDetail.ASI_CRM_MY_Customer__c).ASI_CRM_VN_Product_Listing__c;
            }
        }
        
        return true;
    }
    
    /***************
	Data Retrievement Function
	***************/
    private List<ASI_HK_CRM_Visitation_Plan_Detail__c> retrieveVisitationPlanDetailList(Set<Id> customerIdSet) {
        String query = 'SELECT ' + genQueryField(VISITATION_PLAN_DETAIL_FIELD_MAP) + 
		               ', RecordType.DeveloperName ' + 
		               'FROM ASI_HK_CRM_Visitation_Plan_Detail__c ' + 
		               'Where ASI_CRM_MY_Customer__c in :customerIdSet ' + 
                       'Order By ASI_HK_CRM_Visit_Date__c DESC';
		return (List<ASI_HK_CRM_Visitation_Plan_Detail__c>) Database.query(query);
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