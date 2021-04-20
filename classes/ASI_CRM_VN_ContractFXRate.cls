/*********************************************************************************
 * Name: ASI_CRM_VN_ContractFXRate
 * Description: Assign the FX rate to contract when currency is USD
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/06/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_ContractFXRate {
    
    private final static Map<String, Schema.SObjectField> EXCHANGE_RATE_FIELD_MAP = Schema.SObjectType.ASI_MFM_Exchange_Rate__c.fields.getMap();
    
    private final static String CURRENCY_USD = 'USD';
    private final static String CURRENCY_VND = 'VND';
    private final static String COUNTRY      = 'VN';
    
    public ASI_CRM_VN_ContractFXRate() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Contract__c> contractList   = (List<ASI_CRM_VN_Contract__c>) newList;
        Map<Id, ASI_CRM_VN_Contract__c> contractMap = (Map<Id, ASI_CRM_VN_Contract__c>) oldMap;
        
        List<ASI_CRM_VN_Contract__c> filteredContractList = filterContract(contractList, contractMap);
        assignFXRate(filteredContractList);
    }
    
    private List<ASI_CRM_VN_Contract__c> filterContract(List<ASI_CRM_VN_Contract__c> contractList, Map<Id, ASI_CRM_VN_Contract__c> contractMap) {
        return contractList;
    }
    
    private void assignFXRate(List<ASI_CRM_VN_Contract__c> contractList) {
        List<ASI_MFM_Exchange_Rate__c> exchangeRateList = retrieveExchangeRateList();
        
        Boolean isToVNDSet = false;
        Boolean isToUSDSet = false;
        
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            for(ASI_MFM_Exchange_Rate__c exchangeRate : exchangeRateList) {
                datetime createdDate = contract.createdDate;
                if(createdDate == null) {
                	createdDate = datetime.now();
                }
                
                if(createdDate >= exchangeRate.ASI_MFM_Effective_Date__c) {
                    if(exchangeRate.ASI_MFM_Base_Currency__c == CURRENCY_VND && 
                       exchangeRate.ASI_MFM_Counter_Currency__c == CURRENCY_USD) {
                    	contract.ASI_CRM_To_USD_Exchange_Rate__c = exchangeRate.ASI_MFM_Exchange_Rate__c;
                        isToUSDSet = true;
                    } 
                    
                    if(exchangeRate.ASI_MFM_Base_Currency__c == CURRENCY_USD && 
                       exchangeRate.ASI_MFM_Counter_Currency__c == CURRENCY_VND) {
                		contract.ASI_CRM_To_VND_Exchange_Rate__c = exchangeRate.ASI_MFM_Exchange_Rate__c;
                        isToVNDSet = true;
                    }
                }
                
                if(isToVNDSet && isToUSDSet) {
                	break;
                }
            }
        }
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private List<ASI_MFM_Exchange_Rate__c> retrieveExchangeRateList() {
    	String query = 'SELECT ' + genQueryField(EXCHANGE_RATE_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_MFM_Exchange_Rate__c ' + 
                       'WHERE ASI_MFM_Country__c = :COUNTRY ' + 
                       'ORDER BY ASI_MFM_Effective_Date__c DESC';
        
    	return (List<ASI_MFM_Exchange_Rate__c>) Database.query(query);
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