/**
* @description 
* this class is used to manage Contract BQ for one Contract
*/

global class GRP_CC_ContractsBQ_Controller {
    
    public GRP_CC_ContractsBQ_Controller(ApexPages.StandardController controller) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.GRP_CC_Warning_ContractBQ));
    }
    
    
    /**
  * @description 
  * get all brand qualities not included to the Contracts BQ already assosiated
  * @return
  * list of BrandQuality
  */
    @RemoteAction
    global static CORE_BrandQuality__c[] getBrandQualityToAssosiate(String ContractId){
        CORE_BrandQuality__c[] bq = [Select Id, Name 
                                          from CORE_BrandQuality__c 
                                          where id not in 
                                              (select GRP_CC_BrandQuality__c 
                                                 from GRP_CC_ContractBQ__c 
                                                 where GRP_CC_Contract__c=:ContractId)
                                          order by Name
                                         ];
        return bq;
    }
    
    /**
  * @description 
  * get all brand qualities included to the Contracts BQ already assosiated
  * @return
  * list of BrandQuality
  */
    @RemoteAction
    global static CORE_BrandQuality__c[] getBrandQualityAssosiated(String ContractId){
        CORE_BrandQuality__c[] bq = [Select Id, Name 
                                          from CORE_BrandQuality__c 
                                          where id in 
                                              (select GRP_CC_BrandQuality__c 
                                                 from GRP_CC_ContractBQ__c 
                                                 where GRP_CC_Contract__c=:ContractId)
                                          order by Name
                                         ];
        return bq;
    }
    
    /**
  * @description 
  * get all Contracts BS with its fields included to the Contracts
  * @return
  * list of Contracts BQ
  */
    @RemoteAction
    global static GRP_CC_ContractBQ__c[] getContractsBrandQualityAssosiatedFull(String ContractId){
        GRP_CC_ContractBQ__c[] contractsBQ = [Select Id, GRP_CC_BrandQuality__c, GRP_CC_Negotiated_Rebate_To_Be_Paid_Per__c, GRP_CC_Negotiated_Rebate__c, 
                                           /*GRP_CC_BackBar__c, (CCS-4171) */ GRP_CC_OnMenu__c, GRP_CC_Premium__c, GRP_CC_Pouring__c, GRP_CC_Rooms_Minibar__c, GRP_CC_Optional_Additions__c, GRP_CC_Meetings_Events__c /*, GRP_CC_SuperPremium__c (CCS-4171) */
                                              from GRP_CC_ContractBQ__c 
                                              where GRP_CC_Contract__c=:ContractId
                                           ];
        return contractsBQ;
    }
    
    /**
  * @description 
  * create a new Contracts BQ for the current Contract from the list of chosen brand qualities
  * @return
  * ok or error message
  */
    @RemoteAction
    global static String insertBrandQualityToContract(String ContractId, String BQidArray){
        List<String> BQ_ids = BQidArray.split(';');
        List<GRP_CC_ContractBQ__c> contractsBQinsert = new List<GRP_CC_ContractBQ__c>();
        if (BQ_ids.size()>0){
            for (Integer i=0; i<BQ_ids.size(); i++){
                GRP_CC_ContractBQ__c contract_bq = new GRP_CC_ContractBQ__c(GRP_CC_Contract__c=ContractId, GRP_CC_BrandQuality__c=BQ_ids.get(i));
                contractsBQinsert.add(contract_bq);
            }
            try{
                insert contractsBQinsert;
                return 'ok';
            }catch(exception e){
                return e.getMessage();
            }
        }
        return 'ok';
    }
    
    /**
  * @description 
  * delete a list of chosen Contracts BQ and Contracts BQS assosiated to the previosly mentionned Contracts BQ
  * @return
  * ok or error message
  */
    @RemoteAction
    global static String deleteBrandQualitySizeFromContract(String ContractId, String BQidArray){
        List<String> BQ_ids = BQidArray.split(';');
        Set<String> setBQ_ids = new Set<String>(BQ_ids);
        List<GRP_CC_ContractBQ__c> contractsBQdelete = [Select id 
                                                               from GRP_CC_ContractBQ__c
                                                               where GRP_CC_Contract__c=:ContractId
                                                               and GRP_CC_BrandQuality__c in :setBQ_ids];
        List<GRP_CC_Contract_BQS_Link__c> contractsBQSdelete = [Select id 
                                                               from GRP_CC_Contract_BQS_Link__c
                                                               where GRP_CC_Contract__c=:ContractId
                                                               and GRP_CC_BrandQualitySize__c in 
                                                                  (Select id 
                                                              from CORE_BrandQualitySize__c 
                                                              where CORE_BrandQuality__c in :setBQ_ids)
                                                               ];
        try{
            delete contractsBQdelete;
            delete contractsBQSdelete;
            return 'ok';
        }catch(exception e){
            return e.getMessage();
        }
    }
    
    /**
  * @description 
  * get a list of values from GRP_CC_Negotiated_Rebate_To_Be_Paid_Per__c field picklist
  * @return
  * list of values
  */
    @RemoteAction
    global static List<String> getNegotiatedRebateToBePaidPerPickListValues(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = GRP_CC_ContractBQ__c.GRP_CC_Negotiated_Rebate_To_Be_Paid_Per__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(f.getValue());
            options.add(f.getLabel());
        }       
        return options;
    }
    
    /**
  * @description 
  * update a fields of Contract BQ
  * @return
  * ok or error message
  */
    @RemoteAction
    global static String updateContractBQ(String contractBQValues){
        List<String> cbq_values = contractBQValues.split('#');
        String cbq_id = cbq_values.get(0);
        GRP_CC_ContractBQ__c contractBQ = [Select Id, GRP_CC_Negotiated_Rebate_To_Be_Paid_Per__c, GRP_CC_Negotiated_Rebate__c, 
                                           /* GRP_CC_BackBar__c, (CCS-4171) */ GRP_CC_OnMenu__c, GRP_CC_Premium__c, GRP_CC_Pouring__c, GRP_CC_Rooms_Minibar__c, GRP_CC_Optional_Additions__c, GRP_CC_Meetings_Events__c /*, GRP_CC_SuperPremium__c (CCS-4171) */
                                              from GRP_CC_ContractBQ__c 
                                              where Id=:cbq_id
                                           ];
        contractBQ = updateCBQ(contractBQValues, contractBQ);
        try {
            update contractBQ;
            return (String)contractBQ.Id;
        } catch (exception e) {
            return e.getMessage();
        }
    }
    
    /**
  * @description 
  * update a fields of Contract BQ list
  * @return
  * ok or error message
  */
    @RemoteAction
    global static String updateAllContractsBQ(String contractBQIds, String contractBQValues){
        List<String> cbq_ids = contractBQIds.split('#');
        Set<String> set_cbq_ids = new Set<String>(cbq_ids);
        List<String> contracts_bq = contractBQValues.split('¤');
        
        List<GRP_CC_ContractBQ__c> list_contracts_BQ = [Select Id, GRP_CC_Negotiated_Rebate_To_Be_Paid_Per__c, GRP_CC_Negotiated_Rebate__c, 
                                           /* GRP_CC_BackBar__c, (CCS-4171)*/ GRP_CC_OnMenu__c, GRP_CC_Premium__c, GRP_CC_Pouring__c, GRP_CC_Rooms_Minibar__c, GRP_CC_Optional_Additions__c, GRP_CC_Meetings_Events__c /*, GRP_CC_SuperPremium__c (CCS-4171) */
                                              from GRP_CC_ContractBQ__c 
                                              where Id in :set_cbq_ids
                                           ];
        
        Map<String, GRP_CC_ContractBQ__c> map_contracts_BQ = new Map<String, GRP_CC_ContractBQ__c>();
        for (Integer i=0; i<list_contracts_BQ.size(); i++){
            map_contracts_BQ.put(list_contracts_BQ.get(i).Id, list_contracts_BQ.get(i));
        }
        
        List<GRP_CC_ContractBQ__c> list_contracts_BQ_to_update = new List<GRP_CC_ContractBQ__c>();
        
        for (Integer j=0; j<contracts_bq.size(); j++){
            List<String> cbq_values = contracts_bq.get(j).split('#');
          String cbq_id = cbq_values.get(0);
            if (map_contracts_BQ.containsKey(cbq_id)){
                list_contracts_BQ_to_update.add(updateCBQ(contracts_bq.get(j), map_contracts_BQ.get(cbq_id)));
            }
        }
        try {
            update list_contracts_BQ_to_update;
            return 'ok';
        } catch (exception e) {
            return e.getMessage();
        }
    }
    
    /**
  * @description 
  * initialise a update value for every field of Contract BQ
  * @return
  * Contract BQ
  */
    private static GRP_CC_ContractBQ__c updateCBQ(String contractBQValues, GRP_CC_ContractBQ__c contractBQ){
        List<String> cbq_values = contractBQValues.split('#');
        String cbq_id = cbq_values.get(0);
        String cbq_NRTBPP = cbq_values.get(1);
        Decimal cbq_NR = null;
        if (!String.isEmpty(cbq_values.get(2))){
            cbq_NR = decimal.valueOf(cbq_values.get(2)).setScale(2);
        }
        //Boolean cbq_BackBar;
        Boolean cbq_OnMenu;
        Boolean cbq_Premium;
        Boolean cbq_Pouring;
        Boolean cbq_Rooms_Minibar;
        Boolean cbq_Optional_Additions;
        Boolean cbq_Meetings_Events;
		    //Boolean cbq_SuperPremium;
        /* if (cbq_values.get(3)=='true'){ // CCS-4171
            cbq_BackBar = true;
        }else{
            cbq_BackBar = false;
        }*/
        if (cbq_values.get(3)=='true'){     // 4 -> 3
            cbq_OnMenu = true;
        }else{
            cbq_OnMenu = false;
        }
        if (cbq_values.get(4)=='true'){     // 5 -> 4
            cbq_Premium = true;
        }else{
            cbq_Premium = false;
        }
        if (cbq_values.get(5)=='true'){     // 6 -> 5
            cbq_Pouring = true;
        }else{
            cbq_Pouring = false;
        }
        if (cbq_values.get(6)=='true'){
            cbq_Rooms_Minibar = true;
        }else{
            cbq_Rooms_Minibar = false;
        }
        if (cbq_values.get(7)=='true'){
            cbq_Meetings_Events = true;
        }else{
            cbq_Meetings_Events = false;
        }
        if (cbq_values.get(8)=='true'){
            cbq_Optional_Additions = true;
        }else{
            cbq_Optional_Additions = false;
        }
		    /*if (cbq_values.get(7)=='true'){ // CCS-4171
            cbq_SuperPremium = true;
        }else{
            cbq_SuperPremium = false;
        }*/
        contractBQ.GRP_CC_Negotiated_Rebate_To_Be_Paid_Per__c = cbq_NRTBPP;
        contractBQ.GRP_CC_Negotiated_Rebate__c = cbq_NR;
        //contractBQ.GRP_CC_BackBar__c = cbq_BackBar;
        contractBQ.GRP_CC_OnMenu__c = cbq_OnMenu;
        contractBQ.GRP_CC_Premium__c = cbq_Premium;
        contractBQ.GRP_CC_Pouring__c = cbq_Pouring;
        contractBQ.GRP_CC_Rooms_Minibar__c = cbq_Rooms_Minibar;
        contractBQ.GRP_CC_Optional_Additions__c = cbq_Optional_Additions;
        contractBQ.GRP_CC_Meetings_Events__c = cbq_Meetings_Events;
		    //contractBQ.GRP_CC_SuperPremium__c = cbq_SuperPremium;
        return contractBQ;
    }
    
}