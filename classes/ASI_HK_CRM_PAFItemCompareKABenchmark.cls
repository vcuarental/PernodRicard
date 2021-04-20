public with sharing class ASI_HK_CRM_PAFItemCompareKABenchmark extends ASI_HK_CRM_TriggerAbstract {
    
    private static final Set<String> RELEVANT_PAF_ITEM_FIELDS = new Set<String>{
        	'ASI_HK_CRM_Pre_Approval_Form_Lookup__c'
        	, 'ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name'
            , 'ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c'
            , 'ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Type__c'
            , 'ASI_HK_CRM_NNP__c'
            , 'ASI_HK_CRM_SKU_Lookup__c'
            , 'ASI_HK_CRM_SKU_Lookup__r.Name'
            , 'ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c'
            , 'ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c'
    };
                
    private static final String BENCHMARK_PAF_QUERY_FILTER = 'ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_HK_Is_Benchmark__c  = TRUE'
                + ' AND ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_HK_Active__c = TRUE';
    
    private static final Map<String, String> CHANNEL_PAF_CUST_TYPE_ACCOUNT_NAME_MAPPING = new Map<String, String>{
        'OUTLET_9CC Convenience Store (9901924128)' => '9CC'
         ,'OUTLET_9SM Supermarket (9901924130)'  => '9SM'
         ,'OUTLET_9TD Japanese Store (9901924131)'  => '9TD'
         ,'OUTLET_9WS Prestige Off (KA) (9901924132)' => '9WS'
    };
        
    private Set<Id> setChannelPAFAcc;
                
    public ASI_HK_CRM_PAFItemCompareKABenchmark() {
         super('ASI_HK_CRM_PAFItemCompareKABenchmark');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | Start');
        
        List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listPAFItem = (List<ASI_HK_CRM_Pre_Approval_Form_Item__c>)sObjList;
        Map<Id, ASI_HK_CRM_Pre_Approval_Form_Item__c> mapKAPAFItem = new Map<Id, ASI_HK_CRM_Pre_Approval_Form_Item__c>();
        
        Set<Id> setKAPAF = new Set<Id>();
        Set<Id> setPAFCust = new Set<Id>();
        Set<Id> setPAFSKU = new Set<Id>();
        Map<Id, List<ASI_HK_CRM_Pre_Approval_Form_Item__c>> mapPAFItemHeaderId = new Map<Id, List<ASI_HK_CRM_Pre_Approval_Form_Item__c>>();
		
        for(ASI_HK_CRM_Pre_Approval_Form_Item__c pafi : listPAFItem){
            if(!setKAPAF.contains(pafi.ASI_HK_CRM_Pre_Approval_Form_Lookup__c)){
                setKAPAF.add(pafi.ASI_HK_CRM_Pre_Approval_Form_Lookup__c);
            }
        }
        
        System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | setKAPAF.size() : ' + setKAPAF.size());
        
        Map<Id, ASI_HK_CRM_Pre_Approval_Form__c> mapKAPAF = new Map<Id, ASI_HK_CRM_Pre_Approval_Form__c>([SELECT Id, ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Type__c, ASI_HK_CRM_PAF_Customer__c, ASI_HK_CRM_Adjusted_Start_Date__c
                                                                                                          FROM ASI_HK_CRM_Pre_Approval_Form__c 
                                                                                                          WHERE Id IN :setKAPAF AND ASI_CRM_HK_Is_Benchmark__c = FALSE AND ASI_CRM_HK_Is_Channel_PAF__c = FALSE]);
        
        System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | mapKAPAF.size() : ' + mapKAPAF.size());
        
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : mapKAPAF.values()){
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c pafi : listPAFItem){
                if(pafi.ASI_HK_CRM_Pre_Approval_Form_Lookup__c == paf.Id){
                    if(paf.ASI_HK_CRM_PAF_Customer__c != NULL && paf.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Type__c != NULL 
                       && paf.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Type__c.startsWith('9') && pafi.ASI_HK_CRM_NNP__c != NULL){
                           mapKAPAFItem.put(pafi.Id, pafi);
                           setPAFCust.add(Id.valueOf(paf.ASI_HK_CRM_PAF_Customer__c));
                           setPAFSKU.add(pafi.ASI_HK_CRM_SKU_Lookup__c);
                       }
                }
            }
        }
        
        System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | mapKAPAFItem.size() : ' + mapKAPAFItem.size());
        System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | setPAFCust : ' + setPAFCust);
        System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | setPAFSKU : ' + setPAFSKU);
        
        if(mapKAPAFItem.size() > 0){
            initChannelPAFAcc();
            System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | After initChannelPAFAcc | setChannelPAFAcc : ' + setChannelPAFAcc);
            
            
            Set<String> queryFields = RELEVANT_PAF_ITEM_FIELDS.clone();
            String queryCustBMStr = ASI_HK_CRM_CommonUtils.genQueryString(queryFields, 'ASI_HK_CRM_Pre_Approval_Form_Item__c', 'ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c IN :setPAFCust'
                                                                          + ' AND ASI_HK_CRM_SKU_Lookup__c IN :setPAFSKU AND ' + BENCHMARK_PAF_QUERY_FILTER);
            List< ASI_HK_CRM_Pre_Approval_Form_Item__c> listKAPAFItemBM = (List<ASI_HK_CRM_Pre_Approval_Form_Item__c>)database.query(queryCustBMStr);
            
            String queryChannelBMStr = ASI_HK_CRM_CommonUtils.genQueryString(queryFields, 'ASI_HK_CRM_Pre_Approval_Form_Item__c', 'ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_CRM_HK_Is_Channel_PAF__c = TRUE'
                                                                             + ' AND ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c IN :setChannelPAFAcc'
                                                                             + ' AND ASI_HK_CRM_SKU_Lookup__c IN :setPAFSKU AND ' + BENCHMARK_PAF_QUERY_FILTER);
            List<ASI_HK_CRM_Pre_Approval_Form_Item__c> listKAPAFItemChannelBM = (List<ASI_HK_CRM_Pre_Approval_Form_Item__c>)database.query(queryChannelBMStr);
            
            System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | listKAPAFItemBM.size() : ' + listKAPAFItemBM.size());
            System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | listKAPAFItemChannelBM.size() : ' + listKAPAFItemChannelBM.size());
            
            Map<Id, ASI_MFM_SKU_Code__c> mapSKU = new Map<Id, ASI_MFM_SKU_Code__c>([select Id, Name from ASI_MFM_SKU_Code__c where Id IN :setPAFSKU]);                
            
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c pafi : mapKAPAFItem.values()){
                Boolean bFound = false;
                Id benchmarkPAFId = null;
                Boolean bMultipleBM = false;
                ASI_HK_CRM_Pre_Approval_Form__c paf = mapKAPAF.get(pafi.ASI_HK_CRM_Pre_Approval_Form_Lookup__c);
                
                System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | pafi: ' + pafi);
                System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | paf : ' + paf);
                System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | paf.ASI_HK_CRM_Adjusted_Start_Date__c : ' + paf.ASI_HK_CRM_Adjusted_Start_Date__c);
                
                for(ASI_HK_CRM_Pre_Approval_Form_Item__c pafibm : listKAPAFItemBM){
                    System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | pafibm : ' + pafibm);
                    System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | pafibm.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c : ' + pafibm.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c);
                    System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | pafibm.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c : ' + pafibm.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c);
                    
                    if(paf.ASI_HK_CRM_PAF_Customer__c == pafibm.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c 
                       && pafi.ASI_HK_CRM_SKU_Lookup__c == pafibm.ASI_HK_CRM_SKU_Lookup__c
                       && paf.ASI_HK_CRM_Adjusted_Start_Date__c >= pafibm.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c 
                       && paf.ASI_HK_CRM_Adjusted_Start_Date__c <= pafibm.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c){
                           if(!bFound){
                               System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | Customer PAF Benchmark found.');
                               pafi.ASI_HK_CRM_Pricing_Issue__c = compareNNP(pafi, pafibm);
                               bFound = true;
                               benchmarkPAFId = pafibm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c;
                           }else if(pafibm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c != benchmarkPAFId){
                               System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | Multiple Customer PAF Benchmark for SKU (' + mapSKU.get(pafi.ASI_HK_CRM_SKU_Lookup__c).Name + ') have been found!');
                               pafi.addError('Multiple Customer PAF Benchmark for SKU (' + mapSKU.get(pafi.ASI_HK_CRM_SKU_Lookup__c).Name + ') have been found!');
                               bMultipleBM = true;
                               break;
                           }
                       }
                }
                
                if(!bFound && !bMultipleBM){
                    if(paf.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Type__c.subString(0,3) == '9CS'){ //if(mapPAFCustType.get(pafi.Id) == '9CS'){ //No Channel PAF Benchmark for Cash Sales KA
                        pafi.addError('No Customer PAF Benchmark for SKU (' + mapSKU.get(pafi.ASI_HK_CRM_SKU_Lookup__c).Name + ') can be found!');
                    }else{
                        for(ASI_HK_CRM_Pre_Approval_Form_Item__c paficbm : listKAPAFItemChannelBM){
                            if(CHANNEL_PAF_CUST_TYPE_ACCOUNT_NAME_MAPPING.get(paficbm.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__r.Name) == paf.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Type__c.subString(0,3)//mapPAFCustType.get(pafi.Id)
                              && pafi.ASI_HK_CRM_SKU_Lookup__c == paficbm.ASI_HK_CRM_SKU_Lookup__c
                              && paf.ASI_HK_CRM_Adjusted_Start_Date__c >= paficbm.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_Start_Date__c 
                       	      && paf.ASI_HK_CRM_Adjusted_Start_Date__c <= paficbm.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c){
                                if(!bFound){
                                    System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | Channel PAF Benchmark found.');
                                    pafi.ASI_HK_CRM_Pricing_Issue__c = compareNNP(pafi, paficbm);
                            		bFound = true;
                                    benchmarkPAFId = paficbm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c;
                                }else if(paficbm.ASI_HK_CRM_Pre_Approval_Form_Lookup__c != benchmarkPAFId){
                                    System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | Multiple Channel PAF Benchmark for SKU (' + mapSKU.get(pafi.ASI_HK_CRM_SKU_Lookup__c).Name + ') on Channel ( ' + paf.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Type__c.subString(0,3) + ') have been found!');
                                    pafi.addError('Multiple Channel PAF Benchmark for SKU (' + mapSKU.get(pafi.ASI_HK_CRM_SKU_Lookup__c).Name + ') on Channel ( ' + paf.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Type__c.subString(0,3) /*mapPAFCustType.get(pafi.Id)*/ + ') have been found!');
                            		bMultipleBM = true;
                            		break;
                                }
                            }
                        }
                        
                        if(!bFound && !bMultipleBM){
                            System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | No Customer or Channel PAF Benchmark for SKU (' + mapSKU.get(pafi.ASI_HK_CRM_SKU_Lookup__c).Name + ') can be found!');
                            pafi.addError('No Customer or Channel PAF Benchmark for SKU (' + mapSKU.get(pafi.ASI_HK_CRM_SKU_Lookup__c).Name + ') can be found!');
                        }
                    }
                }
            }
        }
        
        System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | executeTriggerAction | End');
    }
    
    private void initChannelPAFAcc(){
        setChannelPAFAcc = new Set<Id>();
        
        for(Account acc : [SELECT Id, Name, ASI_HK_CRM_Customer_Type__c FROM Account WHERE Name IN :CHANNEL_PAF_CUST_TYPE_ACCOUNT_NAME_MAPPING.keySet()]){
            if(!setChannelPAFAcc.contains(acc.Id)){
                setChannelPAFAcc.add(acc.Id);
            }
        }
    }
    
    private Boolean compareNNP(ASI_HK_CRM_Pre_Approval_Form_Item__c item, ASI_HK_CRM_Pre_Approval_Form_Item__c benchmark){
        System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | compareNNP | Start');
        System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | Item NNP : ' + item.ASI_HK_CRM_NNP__c);
        System.debug('ASI_HK_CRM_PAFItemCompareKABenchmark | Benchmark NNP : ' + benchmark.ASI_HK_CRM_NNP__c);
        return (item.ASI_HK_CRM_NNP__c < benchmark.ASI_HK_CRM_NNP__c);
    }
}