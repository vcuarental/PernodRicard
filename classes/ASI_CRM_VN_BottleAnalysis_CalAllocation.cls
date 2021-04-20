/*********************************************************************************
 * Name: ASI_CRM_VN_BottleAnalysis_CalAllocation
 * Description: Calculate the allocation of bottle analysis record
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 14/07/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_BottleAnalysis_CalAllocation {
    
    private final static Map<String, Schema.SObjectField> BOTTLE_ANALYSIS_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Bottle_Analysis__c.fields.getMap();
    
    public ASI_CRM_VN_BottleAnalysis_CalAllocation() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList = (List<ASI_CRM_VN_Bottle_Analysis__c>) newList;
        Map<Id, ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisMap = (Map<Id, ASI_CRM_VN_Bottle_Analysis__c>) oldMap;
        
        List<ASI_CRM_VN_Bottle_Analysis__c> filteredBottleAnalysisList = filterBottleAnalysis(bottleAnalysisList, bottleAnalysisMap);
        calculateAllocation(filteredBottleAnalysisList);
    }
    
    private List<ASI_CRM_VN_Bottle_Analysis__c> filterBottleAnalysis(List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList, Map<Id, ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisMap) {
    	if(bottleAnalysisMap == null) {
            return bottleAnalysisList;
        }
        
        List<ASI_CRM_VN_Bottle_Analysis__c> filteredBottleAnalysisList = new List<ASI_CRM_VN_Bottle_Analysis__c>();
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            if(bottleAnalysis.ASI_CRM_Target_Per_Month__c != bottleAnalysisMap.get(bottleAnalysis.Id).ASI_CRM_Target_Per_Month__c) {
                filteredBottleAnalysisList.add(bottleAnalysis);
            }
        }
        return filteredBottleAnalysisList;
    }
	
    private void calculateAllocation(List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList) {
    	Set<Id> contractIdSet       = new Set<Id>();
        Set<Id> bottleAnalysisIdSet = new Set<Id>();
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            contractIdSet.add(bottleAnalysis.ASI_CRM_VN_Contract__c);
            if(String.isNotBlank(bottleAnalysis.Id)) {
            	bottleAnalysisIdSet.add(bottleAnalysis.Id);
            }
        }
        
        List<ASI_CRM_VN_Bottle_Analysis__c> existingBottleAnalysisList = retrieveBottleAnalysisList(contractIdSet, bottleAnalysisIdSet);
        Map<Id, Decimal> contractTotalBottleMap = new Map<Id, Decimal>();
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : existingBottleAnalysisList) {
            Decimal totalBottle = 0;
            if(contractTotalBottleMap.containsKey(bottleAnalysis.ASI_CRM_VN_Contract__c)) {
            	totalBottle = contractTotalBottleMap.get(bottleAnalysis.ASI_CRM_VN_Contract__c);
            }
            totalBottle += bottleAnalysis.ASI_CRM_Target_Per_Month__c == null ? 0 : bottleAnalysis.ASI_CRM_Target_Per_Month__c;
            contractTotalBottleMap.put(bottleAnalysis.ASI_CRM_VN_Contract__c, totalBottle);
        }
        
        Set<Id> upsertBottleAnalysisIdSet = new Set<Id>();
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            upsertBottleAnalysisIdSet.add(bottleAnalysis.Id);
            Decimal totalBottle = 0;
            if(contractTotalBottleMap.containsKey(bottleAnalysis.ASI_CRM_VN_Contract__c)) {
            	totalBottle = contractTotalBottleMap.get(bottleAnalysis.ASI_CRM_VN_Contract__c);
            }
            totalBottle += bottleAnalysis.ASI_CRM_Target_Per_Month__c == null ? 0 : bottleAnalysis.ASI_CRM_Target_Per_Month__c;
            contractTotalBottleMap.put(bottleAnalysis.ASI_CRM_VN_Contract__c, totalBottle);
        }
        
       	List<ASI_CRM_VN_Bottle_Analysis__c> updatedBottleAnalysisList = new List<ASI_CRM_VN_Bottle_Analysis__c>();
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : existingBottleAnalysisList) {
            if(upsertBottleAnalysisIdSet.contains(bottleAnalysis.Id)) {
            	continue;
            }
            Decimal totalBottle = contractTotalBottleMap.get(bottleAnalysis.ASI_CRM_VN_Contract__c);
            bottleAnalysis.ASI_CRM_VN_Allocation_Percentage__c = (bottleAnalysis.ASI_CRM_Target_Per_Month__c == null ? 1 : bottleAnalysis.ASI_CRM_Target_Per_Month__c)
                                                               / totalBottle
                                                               * 100; 
            updatedBottleAnalysisList.add(bottleAnalysis);
        }
        
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            Decimal totalBottle = contractTotalBottleMap.get(bottleAnalysis.ASI_CRM_VN_Contract__c);
            bottleAnalysis.ASI_CRM_VN_Allocation_Percentage__c = (bottleAnalysis.ASI_CRM_Target_Per_Month__c == null ? 1 : bottleAnalysis.ASI_CRM_Target_Per_Month__c)
                                                               / totalBottle
                                                               * 100; 
        }
        
        if(updatedBottleAnalysisList.size() > 0) {
        	update updatedBottleAnalysisList;
        }
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_CRM_VN_Bottle_Analysis__c> retrieveBottleAnalysisList(Set<Id> contractIdSet, Set<Id> bottleAnalysisIdSet) {
    	String query = 'SELECT ' + genQueryField(BOTTLE_ANALYSIS_FIELD_MAP) + ' ' + 
                       'FROM ASI_CRM_VN_Bottle_Analysis__c ' + 
                       'Where ASI_CRM_VN_Contract__c in :contractIdSet ' + 
                       'AND Id not in :bottleAnalysisIdSet';
        
    	return (List<ASI_CRM_VN_Bottle_Analysis__c>) Database.query(query);
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