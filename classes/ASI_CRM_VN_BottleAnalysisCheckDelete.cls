/*********************************************************************************
 * Name: ASI_CRM_VN_BottleAnalysisCheckDelete
 * Description: Check can bottle analysis record be deleted
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 31/07/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_BottleAnalysisCheckDelete {
    
    private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP     = Schema.SObjectType.ASI_CRM_VN_Contract__c.fields.getMap();
	private final static String CONTRACT_STATUS_ALLOW_DELETE = 'Draft'; 
    
    public ASI_CRM_VN_BottleAnalysisCheckDelete() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList = (List<ASI_CRM_VN_Bottle_Analysis__c>) newList;
        Map<Id, ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisMap = (Map<Id, ASI_CRM_VN_Bottle_Analysis__c>) oldMap;
        
        List<ASI_CRM_VN_Bottle_Analysis__c> filteredBottleAnalysisList = filterBottleAnalysis(bottleAnalysisList, bottleAnalysisMap);
        checkDelete(filteredBottleAnalysisList);
    }
    
    private List<ASI_CRM_VN_Bottle_Analysis__c> filterBottleAnalysis(List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList, Map<Id, ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisMap) {
        return bottleAnalysisMap.values();
    }
    
    private void checkDelete(List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList) {
        Set<Id> contractIdSet = new Set<Id>();
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            contractIdSet.add(bottleAnalysis.ASI_CRM_VN_Contract__c);
        }
        
        Map<Id, ASI_CRM_VN_Contract__c> contractIdMap = new Map<Id, ASI_CRM_VN_Contract__c>(retrieveContractList(contractIdSet));
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            ASI_CRM_VN_Contract__c tempContract = contractIdMap.get(bottleAnalysis.ASI_CRM_VN_Contract__c);
            if(tempContract.ASI_CRM_Contract_Status__c == CONTRACT_STATUS_ALLOW_DELETE) {
            	continue;
            } else {
            	bottleAnalysis.addError(Label.ASI_CRM_VN_Bottle_Analysis_Cannot_Be_Deleted);
            }
        }
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_CRM_VN_Contract__c> retrieveContractList(Set<Id> contractIdSet) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract__c ' + 
                       'Where Id in :contractIdSet';
        
    	return (List<ASI_CRM_VN_Contract__c>) Database.query(query);
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