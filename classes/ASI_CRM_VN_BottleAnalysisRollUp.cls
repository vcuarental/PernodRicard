/*********************************************************************************
 * Name: ASI_CRM_VN_BottleAnalysisRollUp
 * Description: Roll up the sku to total sales target field
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 01/08/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_BottleAnalysisRollUp {
    
    private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP          = Schema.SObjectType.ASI_CRM_VN_Contract__c.fields.getMap();
	private final static Map<String, Schema.SObjectField> BOTTLE_ANALYSIS_FIELD_MAP   = Schema.SObjectType.ASI_CRM_VN_Bottle_Analysis__c.fields.getMap();
	private final static Map<String, Schema.SObjectField> SKU_FIELD_MAP               = Schema.SObjectType.ASI_MFM_SKU_Code__c.fields.getMap();
	private final static Map<String, Schema.SObjectField> CONVERSION_FACTOR_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Sub_Brand_Conversion_Factor__c.fields.getMap();
    
    public ASI_CRM_VN_BottleAnalysisRollUp() {
    }

	public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList = (List<ASI_CRM_VN_Bottle_Analysis__c>) newList;
        Map<Id, ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisMap = (Map<Id, ASI_CRM_VN_Bottle_Analysis__c>) oldMap;
        
        List<ASI_CRM_VN_Bottle_Analysis__c> filteredBottleAnalysisList = filterBottleAnalysis(bottleAnalysisList, bottleAnalysisMap);
        rollupToContract(filteredBottleAnalysisList);
    }
    
    private List<ASI_CRM_VN_Bottle_Analysis__c> filterBottleAnalysis(List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList, Map<Id, ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisMap) {
    	if(bottleAnalysisMap == null) {
            return bottleAnalysisList;
        }
        
        if(bottleAnalysisList == null) {
            return bottleAnalysisMap.values();
        }
        
        List<ASI_CRM_VN_Bottle_Analysis__c> filteredBottleAnalysisList = new List<ASI_CRM_VN_Bottle_Analysis__c>();
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            if(bottleAnalysis.ASI_CRM_Target_Per_Month__c != bottleAnalysisMap.get(bottleAnalysis.Id).ASI_CRM_Target_Per_Month__c) {
                filteredBottleAnalysisList.add(bottleAnalysis);
            }
        }
        return filteredBottleAnalysisList;
    }

	private void rollupToContract(List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList) {
        Set<Id> contractIdSet = new Set<Id>();
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            contractIdSet.add(bottleAnalysis.ASI_CRM_VN_Contract__c);
        }
        
        bottleAnalysisList = retrieveBottleAnalysisList(contractIdSet);
        Set<Id> skuIdSet = new Set<Id>();
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            skuIdSet.add(bottleAnalysis.ASI_CRM_VN_SKU__c);
        }
        
        Map<Id, ASI_CRM_VN_Contract__c> contractMap = new Map<Id, ASI_CRM_VN_Contract__c>(retrieveContractList(contractIdSet));
        Map<Id, ASI_MFM_SKU_Code__c> skuMap = new Map<Id, ASI_MFM_SKU_Code__c>(retrieveSKUList(skuIdSet));
        
        Set<Id> fromSubBrandIdSet     = new Set<Id>();
        Set<Id> toSubBrandIdSet       = new Set<Id>();
        for(ASI_CRM_VN_Contract__c contract : contractMap.values()) {
            toSubBrandIdSet.add(contract.ASI_CRM_Key_Brand__c);
        }
        
        for(ASI_MFM_SKU_Code__c sku : skuMap.values()) {
        	fromSubBrandIdSet.add(sku.ASI_MFM_Sub_brand__c);
        }
        
        Map<String, ASI_CRM_VN_Sub_Brand_Conversion_Factor__c> conversionFactorMap = new Map<String, ASI_CRM_VN_Sub_Brand_Conversion_Factor__c>();
        for(ASI_CRM_VN_Sub_Brand_Conversion_Factor__c conversionFactor : retrieveConversionFactorList(fromSubBrandIdSet, toSubBrandIdSet)) {
            conversionFactorMap.put(conversionFactor.ASI_CRM_VN_Sub_brand_From__c + '_' + conversionFactor.ASI_CRM_VN_Sub_brand_To__c, conversionFactor);
        }
        
        Map<Id, Decimal> contractTargetBottle = new Map<Id, Decimal>();
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            ASI_CRM_VN_Contract__c tempContract = contractMap.get(bottleAnalysis.ASI_CRM_VN_Contract__c);
            ASI_MFM_SKU_Code__c tempSKU = skuMap.get(bottleAnalysis.ASI_CRM_VN_SKU__c);
            
            Id subBrandId = tempSKU.ASI_MFM_Sub_brand__c;
            Id toSubBrandId = tempContract.ASI_CRM_Key_Brand__c;
            
            if(conversionFactorMap.containsKey(subBrandId + '_' + toSubBrandId) == false) {
            	continue;
          	}
            
            ASI_CRM_VN_Sub_Brand_Conversion_Factor__c conversionFactor = conversionFactorMap.get(subBrandId + '_' + toSubBrandId);
            Decimal targetBottle = bottleAnalysis.ASI_CRM_Total_Contract_Target__c 
                                 * conversionFactor.ASI_CRM_VN_Conversion_Factor__c
                                 * tempSKU.ASI_HK_CRM_Std_Bottle_Size__c 
                                 / tempSKU.ASI_MFM_Sub_brand__r.ASI_CRM_BottleSize__c;
            
            if(contractTargetBottle.containsKey(bottleAnalysis.ASI_CRM_VN_Contract__c)) {
            	targetBottle += contractTargetBottle.get(bottleAnalysis.ASI_CRM_VN_Contract__c);
            }
            
            contractTargetBottle.put(bottleAnalysis.ASI_CRM_VN_Contract__c, targetBottle);
        }
        
        for(ASI_CRM_VN_Contract__c contract : contractMap.values()) {
            Decimal totalSalesTarget = contractTargetBottle.get(contract.Id);
            contract.ASI_CRM_Converted_Total_Sales_Target__c = totalSalesTarget;
        }
        
        update contractMap.values();
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
    
    private List<ASI_CRM_VN_Bottle_Analysis__c> retrieveBottleAnalysisList(Set<Id> contractIdSet) {
        String query = 'SELECT ' + genQueryField(BOTTLE_ANALYSIS_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Bottle_Analysis__c ' + 
                       'Where ASI_CRM_VN_Contract__c in :contractIdSet ';
        
    	return (List<ASI_CRM_VN_Bottle_Analysis__c>) Database.query(query);
    }
    
    private List<ASI_MFM_SKU_Code__c> retrieveSKUList(Set<Id> skuIdSet) {
    	String query = 'SELECT ' + genQueryField(SKU_FIELD_MAP) + 
                       ', ASI_MFM_Sub_brand__r.ASI_CRM_BottleSize__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_MFM_SKU_Code__c ' + 
                       'Where Id in :skuIdSet ';
        
    	return (List<ASI_MFM_SKU_Code__c>) Database.query(query);
  	}
    
    private List<ASI_CRM_VN_Sub_Brand_Conversion_Factor__c> retrieveConversionFactorList(Set<Id> fromSubBrandIdSet, Set<Id> toSubBrandIdSet) {
        String query = 'SELECT ' + genQueryField(CONVERSION_FACTOR_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Sub_Brand_Conversion_Factor__c ' + 
                       'WHERE ASI_CRM_VN_Sub_brand_From__c in :fromSubBrandIdSet ' + 
                       'AND ASI_CRM_VN_Sub_brand_To__c in :toSubBrandIdSet ' + 
                       'AND ASI_CRM_VN_Active_Flag__c = true';
        
    	return (List<ASI_CRM_VN_Sub_Brand_Conversion_Factor__c>) Database.query(query);
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