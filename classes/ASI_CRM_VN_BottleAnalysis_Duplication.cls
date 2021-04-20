/*********************************************************************************
 * Name: ASI_CRM_VN_BottleAnalysis_Duplication
 * Description: Prevent the duplcation records of Bottle Analysis
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 23/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_BottleAnalysis_Duplication {
    
    private final static Map<String, Schema.SObjectField> BOTTLE_ANALYSIS_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Bottle_Analysis__c.fields.getMap();
    
    public ASI_CRM_VN_BottleAnalysis_Duplication() {    
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList = (List<ASI_CRM_VN_Bottle_Analysis__c>) newList;
        Map<Id, ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisMap = (Map<Id, ASI_CRM_VN_Bottle_Analysis__c>) oldMap;
        
        List<ASI_CRM_VN_Bottle_Analysis__c> filteredBottleAnalysisList = filterBottleAnalysis(bottleAnalysisList, bottleAnalysisMap);
        checkDuplication(filteredBottleAnalysisList);
    }
    
    private List<ASI_CRM_VN_Bottle_Analysis__c> filterBottleAnalysis(List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList, Map<Id, ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisMap) {
    	if(bottleAnalysisMap == null) {
            return bottleAnalysisList;
        }
        
        List<ASI_CRM_VN_Bottle_Analysis__c> filteredBottleAnalysisList = new List<ASI_CRM_VN_Bottle_Analysis__c>();
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            if(bottleAnalysis.ASI_CRM_VN_SKU__c == bottleAnalysisMap.get(bottleAnalysis.Id).ASI_CRM_VN_SKU__c) {
                continue;
            } else {
            	filteredBottleAnalysisList.add(bottleAnalysis);
            }
        }
        
        return filteredBottleAnalysisList;
    }
    
    private void checkDuplication(List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList) {
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> bottleAnalysisIdSet = new Set<Id>();
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            contractIdSet.add(bottleAnalysis.ASI_CRM_VN_Contract__c);
            if(String.isNotBlank(bottleAnalysis.Id)) {
            	bottleAnalysisIdSet.add(bottleAnalysis.Id);
            }
        }
        
        Map<Id, List<ASI_CRM_VN_Bottle_Analysis__c>> existingContractBottleAnalysisMap = new Map<Id, List<ASI_CRM_VN_Bottle_Analysis__c>>();
        existingContractBottleAnalysisMap = mapContractAndBottleAnalysis(existingContractBottleAnalysisMap, retrieveBottleAnalysisList(contractIdSet, bottleAnalysisIdSet));
        
        Map<Id, List<ASI_CRM_VN_Bottle_Analysis__c>> newContractBottleAnalysisMap = new Map<Id, List<ASI_CRM_VN_Bottle_Analysis__c>>();
        newContractBottleAnalysisMap = mapContractAndBottleAnalysis(newContractBottleAnalysisMap, bottleAnalysisList);
        
       	for(Id contractId : newContractBottleAnalysisMap.keySet()) {
            List<ASI_CRM_VN_Bottle_Analysis__c> newBottleAnalysisList = newContractBottleAnalysisMap.get(contractId);
            List<ASI_CRM_VN_Bottle_Analysis__c> existingBottleAnalysisList = existingContractBottleAnalysisMap.get(contractId);
            
            for(Integer i = 0 ; i < newBottleAnalysisList.size() ; i++) {
                ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis = bottleAnalysisList.get(i);
                
                for(Integer compareIndex = i + 1; compareIndex < newBottleAnalysisList.size() ; compareIndex++) {
                	ASI_CRM_VN_Bottle_Analysis__c compareBottleAnalysis = bottleAnalysisList.get(compareIndex);
                    
                    if(bottleAnalysis.ASI_CRM_VN_SKU__c == compareBottleAnalysis.ASI_CRM_VN_SKU__c) {
                        showError(bottleAnalysis);
                    }
                }
                
                if(existingBottleAnalysisList == null) {
                    continue;
                }
                
                for(ASI_CRM_VN_Bottle_Analysis__c existingBottleAnalysis : existingBottleAnalysisList) {
                    if(bottleAnalysis.ASI_CRM_VN_SKU__c == existingBottleAnalysis.ASI_CRM_VN_SKU__c) {
                        showError(bottleAnalysis);
                    }
                }
            }
        }
    }
    
    private void showError(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis) {
        bottleAnalysis.addError(Label.ASI_CRM_VN_DuplicatedBottleAnalysis);
    }
    
    private Map<Id, List<ASI_CRM_VN_Bottle_Analysis__c>> mapContractAndBottleAnalysis(Map<Id, List<ASI_CRM_VN_Bottle_Analysis__c>> contractBottleAnalysisMap, List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList) {
    	for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            List<ASI_CRM_VN_Bottle_Analysis__c> tempBottleAnalysisList;
            if(contractBottleAnalysisMap.containsKey(bottleAnalysis.ASI_CRM_VN_Contract__c)) {
                tempBottleAnalysisList = contractBottleAnalysisMap.get(bottleAnalysis.ASI_CRM_VN_Contract__c);
            } else {
            	tempBottleAnalysisList = new List<ASI_CRM_VN_Bottle_Analysis__c>();
            }
            tempBottleAnalysisList.add(bottleAnalysis);
            
            contractBottleAnalysisMap.put(bottleAnalysis.ASI_CRM_VN_Contract__c, tempBottleAnalysisList);
        }
        return contractBottleAnalysisMap;
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_CRM_VN_Bottle_Analysis__c> retrieveBottleAnalysisList(Set<Id> contractIdSet, Set<Id> bottleAnalysisIdSet) {
    	String query = 'SELECT ' + genQueryField(BOTTLE_ANALYSIS_FIELD_MAP) + ' ' + 
                       'FROM ASI_CRM_VN_Bottle_Analysis__c ' + 
                       'WHERE ASI_CRM_VN_Contract__c in :contractIdSet ' + 
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