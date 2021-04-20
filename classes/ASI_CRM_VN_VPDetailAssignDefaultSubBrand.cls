/*********************************************************************************
 * Name: ASI_CRM_VN_VPDetailAssignDefaultSubBrand
 * Description: Class for auto retrieving default sub brand from custom setting ASI_CRM_VN_Settings__c
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 05/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_VPDetailAssignDefaultSubBrand {
    
    //Field Map
	private final static Map<String, Schema.SObjectField> CUSTOMER_SUB_BRAND_FIELD_MAP = Schema.SObjectType.ASI_CRM_Customer_Sub_Brand__c.fields.getMap();
        
    private final static String OFF_TRADE_OUTLET_RECORD_TYPE = 'ASI_CRM_VN_OffTrade_Visitation_Plan_Detail';
    
    public ASI_CRM_VN_VPDetailAssignDefaultSubBrand(List<sObject> sObjectList) {
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList = filterVisitationPlanDetailList((List<ASI_HK_CRM_Visitation_Plan_Detail__c>) sObjectList);
        
        //assignDefaultSubBrand(visitationPlanDetailList);
        assignKeyBrand(visitationPlanDetailList);
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
    
    /*
    private void assignDefaultSubBrand(List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList) {
        ASI_CRM_VN_Settings__c vnSetting = ASI_CRM_VN_Settings__c.getInstance();
        for(ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail : visitationPlanDetailList) {
            for(Integer i = 1 ; i < 11 ; i++) {
                Object subBrand = vnSetting.get('ASI_CRM_VN_Default_Visitation_Subbrand' + i + '__c');
                if(subBrand != null && String.isNotBlank(String.valueOf(subBrand))) {
                    visitationPlanDetail.put('ASI_CRM_VN_Stock_Balance_Sub_Brand' + i + '__c', subBrand);
                }
            }
        }
    }
    */
    
    private void assignKeyBrand(List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList) {
    	Set<Id> customerIdSet = new Set<Id>();
        for(ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail : visitationPlanDetailList) {
            customerIdSet.add(visitationPlanDetail.ASI_CRM_MY_Customer__c);
        }
        
        Map<Id, List<ASI_CRM_Customer_Sub_Brand__c>> praKeyBrandMap        = new Map<Id, List<ASI_CRM_Customer_Sub_Brand__c>>();
        Map<Id, List<ASI_CRM_Customer_Sub_Brand__c>> competitorKeyBrandMap = new Map<Id, List<ASI_CRM_Customer_Sub_Brand__c>>();
        
        for(ASI_CRM_Customer_Sub_Brand__c customerSubBrand : retrieveCustomerSubBrandList(customerIdSet)) {
        	if(customerSubBrand.RecordType.DeveloperName == 'ASI_CRM_PRA_Key_Brand') {
            	List<ASI_CRM_Customer_Sub_Brand__c> tempKeyBrandList;
            	if(praKeyBrandMap.containsKey(customerSubBrand.ASI_CRM_Customer_Key_Brand__c)) {
					tempKeyBrandList = praKeyBrandMap.get(customerSubBrand.ASI_CRM_Customer_Key_Brand__c);
                } else {
                    tempKeyBrandList = new List<ASI_CRM_Customer_Sub_Brand__c>();
                }
                tempKeyBrandList.add(customerSubBrand);
                praKeyBrandMap.put(customerSubBrand.ASI_CRM_Customer_Key_Brand__c, tempKeyBrandList);
            } else if(customerSubBrand.RecordType.DeveloperName == 'ASI_CRM_Competitor_Key_Brand') {
            	List<ASI_CRM_Customer_Sub_Brand__c> tempKeyBrandList;
            	if(competitorKeyBrandMap.containsKey(customerSubBrand.ASI_CRM_Customer_Competitor_Brand__c)) {
					tempKeyBrandList = competitorKeyBrandMap.get(customerSubBrand.ASI_CRM_Customer_Competitor_Brand__c);
                } else {
                    tempKeyBrandList = new List<ASI_CRM_Customer_Sub_Brand__c>();
                }
                tempKeyBrandList.add(customerSubBrand);
                competitorKeyBrandMap.put(customerSubBrand.ASI_CRM_Customer_Competitor_Brand__c, tempKeyBrandList);
            }
        }
        
        for(ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail : visitationPlanDetailList) {
           	if(praKeyBrandMap.containsKey(visitationPlanDetail.ASI_CRM_MY_Customer__c) == false &&
               competitorKeyBrandMap.containsKey(visitationPlanDetail.ASI_CRM_MY_Customer__c) == false) {
                visitationPlanDetail.addError(Label.ASI_CRM_VN_VPD_No_Key_Brand_found);
                continue;
            }
            
            List<ASI_CRM_Customer_Sub_Brand__c> praKeyBrandList        = praKeyBrandMap.get(visitationPlanDetail.ASI_CRM_MY_Customer__c);
            List<ASI_CRM_Customer_Sub_Brand__c> competitorKeyBrandList = competitorKeyBrandMap.get(visitationPlanDetail.ASI_CRM_MY_Customer__c);
            
            for(Integer praKeyBrandIndex = 0 ; praKeyBrandIndex < praKeyBrandList.size() ; praKeyBrandIndex++) {
                if(praKeyBrandIndex <= 9) {
                	visitationPlanDetail.put('ASI_CRM_Displayed_Sub_brand_' + (praKeyBrandIndex + 1) + '__c', praKeyBrandList.get(praKeyBrandIndex).ASI_CRM_Sub_Brand__c);
                    visitationPlanDetail.put('ASI_CRM_VN_Stock_Balance_Sub_Brand' + (praKeyBrandIndex + 1) + '__c', praKeyBrandList.get(praKeyBrandIndex).ASI_CRM_Sub_Brand__c);
                    visitationPlanDetail.put('ASI_CRM_VN_No_of_Facing_' + (praKeyBrandIndex + 1) + '__c', praKeyBrandList.get(praKeyBrandIndex).ASI_CRM_Facing_Target__c);
                } else {
                	continue;
                }
            }
            
            for(Integer competitorKeyBrandIndex = 0 ; competitorKeyBrandIndex < competitorKeyBrandList.size() ; competitorKeyBrandIndex ++) {
                if(competitorKeyBrandIndex <= 8) {
                	visitationPlanDetail.put('ASI_CRM_Displayed_Competitor_Sub_brand_' + (competitorKeyBrandIndex + 1) + '__c', competitorKeyBrandList.get(competitorKeyBrandIndex).ASI_CRM_Sub_Brand__c);         	
                } else if(competitorKeyBrandIndex == 9) {
                    visitationPlanDetail.put('ASI_CRM_Displayed_Competitor_Sub_brand' + (competitorKeyBrandIndex + 1) + '__c', competitorKeyBrandList.get(competitorKeyBrandIndex).ASI_CRM_Sub_Brand__c);
                } else {
                	continue;
                }
            }
        }
    }
    
    /***************
	Data Retrievement Function
	***************/
    private List<ASI_CRM_Customer_Sub_Brand__c> retrieveCustomerSubBrandList(Set<Id> customerIdSet) {
        String query = 'SELECT ' + genQueryField(CUSTOMER_SUB_BRAND_FIELD_MAP) + 
		               ', RecordType.DeveloperName ' + 
		               'FROM ASI_CRM_Customer_Sub_Brand__c ' + 
                       'WHERE ASI_CRM_Customer_Key_Brand__c in :customerIdSet ' + 
                       'OR ASI_CRM_Customer_Competitor_Brand__c in :customerIdSet ';
		return (List<ASI_CRM_Customer_Sub_Brand__c>) Database.query(query);
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