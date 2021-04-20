/**
* @description 
* this class is used to manage Contract BQS for one Contract
*/

global class GRP_CC_ContractsBQS_Controller {
	
    public GRP_CC_ContractsBQS_Controller(ApexPages.StandardController controller) {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.GRP_CC_Warning_ContractBQS));
    }
    
    /**
	* @description 
	* get all brand quality sizes assosiated to the brand qualities included to the Contracts BQ assosiated to the current Contract
	* @return
	* list of BrandQualitySizes
	*/
    @RemoteAction
    global static CORE_BrandQualitySize__c[] getBrandQualitySizeToAssosiate(String ContractId){
      
        CORE_BrandQualitySize__c[] bqs = [Select Id, Name 
                                          from CORE_BrandQualitySize__c 
                                          where id not in 
                                          		(select GRP_CC_BrandQualitySize__c 
                                                 from GRP_CC_Contract_BQS_Link__c 
                                                 where GRP_CC_Contract__c=:ContractId)
                                          and CORE_BrandQuality__c in 
                                         		(select GRP_CC_BrandQuality__c 
                                                 from GRP_CC_ContractBQ__c
                                                 where GRP_CC_Contract__c=:ContractId)
                                          order by Name
                                         ];
        return bqs;
    }
    
    /**
	* @description 
	* get all brand quality sizes included to the Contracts BQS assosiated to the current Contract
	* @return
	* list of BrandQualitySizes
	*/
	@RemoteAction
    global static CORE_BrandQualitySize__c[] getBrandQualitySizeAssosiated(String ContractId){
      
        CORE_BrandQualitySize__c[] bqs = [Select Id, Name 
                                          from CORE_BrandQualitySize__c 
                                          where id in 
                                          		(select GRP_CC_BrandQualitySize__c 
                                                 from GRP_CC_Contract_BQS_Link__c 
                                                 where GRP_CC_Contract__c=:ContractId)
                                          order by Name
                                         ];
        return bqs;
    }
    
    /**
	* @description 
	* create a new Contracts BQS for the current Contract from the list of chosen brand qualities sizes
	* @return
	* ok or error message
	*/
    @RemoteAction
    global static String insertBrandQualitySizeToContract(String ContractId, String BQSidArray){
        List<String> BQS_ids = BQSidArray.split(';');
        List<GRP_CC_Contract_BQS_Link__c> contractsBQSinsert = new List<GRP_CC_Contract_BQS_Link__c>();
        if (BQS_ids.size()>0){
            for (Integer i=0; i<BQS_ids.size(); i++){
                GRP_CC_Contract_BQS_Link__c contract_bqs = new GRP_CC_Contract_BQS_Link__c(GRP_CC_Contract__c=ContractId, GRP_CC_BrandQualitySize__c=BQS_ids.get(i));
                contractsBQSinsert.add(contract_bqs);
            }
            try{
                insert contractsBQSinsert;
                return 'ok';
            }catch(exception e){
                return e.getMessage();
            }
        }
        return 'ok';
    }
    
    /**
	* @description 
	* delete the list of Contracts BQS
	* @return
	* ok or error message
	*/
    @RemoteAction
    global static String deleteBrandQualitySizeFromContract(String ContractId, String BQSidArray){
        List<String> BQS_ids = BQSidArray.split(';');
        Set<String> setBQS_ids = new Set<String>(BQS_ids);
        List<GRP_CC_Contract_BQS_Link__c> contractsBQSdelete = [Select id 
                                                               from GRP_CC_Contract_BQS_Link__c
                                                               where GRP_CC_Contract__c=:ContractId
                                                               and GRP_CC_BrandQualitySize__c in :setBQS_ids];
        try{
            delete contractsBQSdelete;
            return 'ok';
        }catch(exception e){
            return e.getMessage();
        }
    }
    
}