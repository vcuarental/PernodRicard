@RestResource(urlMapping='/Collects')
global with sharing class GRP_CC_REST_AllCollectsServices {
  
    @HttpGet
    global static GetCollectResponseWrapper doGet() {
  /******************************************************************************************
  * Description: Project Connected Customers - This method returns all chainAccounts, 
  *           in progress contracts (StartDate <= current date <= EndDate), 
  *           and the last associated collects
  *     ->ChainAccount 1
  *       ->Id
  *       ->Active_Chain_Account
  *       ->Contract 1 (in progress contracts only)
  *             ->Id
  *             ->Category
  *             ->StartDate
  *             ->EndDate
  *             ->EndCollectOneDate
  *             ->Cycle
  *             ->Collect (Last collect only)
  *                  ->PeriodStart
  *                  ->PeriodEnd
  *                  ->Status
  *                  ->State
  * 				 ->CollectInfo
  *                  ->FullCollectInfo
  *       ->Contract 2
  *             ->...
  *    ->ChainAccount 2
  *       ->...
  *              URL should be encoded in UTF-8.
  * Author: Soazig Bars
  * Creation date: 1st of June 2015
  * Modifications: 
  * 		- 18 of June 2015
  * 		- 23/09/2016 : Add the field CollectInfo on the response
  * 		- 21/11/2016 : Add the field Domain on the response
  * ex: services/apexrest/Collects
  *
    ******************************************************************************************/
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        GetCollectResponseWrapper response = new GetCollectResponseWrapper();
        
        String DecodedUrl = EncodingUtil.urlDecode(req.requestURI, 'UTF-8');
        date today = date.today();              
            
        List<GRP_CC_ChainAccount__c> calist = new List<GRP_CC_ChainAccount__c>();
        
        calist = [
            SELECT Id, GRP_CC_Active_Chain_Account__c, GRP_CC_Chain__r.Id, GRP_CC_Region__r.Id, GRP_CC_Domain__c
            FROM GRP_CC_ChainAccount__c 
            ];
        
        //----------------------------------------------------------
        // 22/02/2016 : correction anomalie WS (Too many SOQL query)
        // Request 1
        Set<Id> idChain = new Set<Id>();
        Set<Id>  idChainAccount = new Set<Id>();
        for(GRP_CC_ChainAccount__c chainAccount : calist){
            idChain.add(chainAccount.GRP_CC_Chain__r.Id);
            idChainAccount.add(chainAccount.Id);
        }
        
        Set<Id> idRegion = new Set<Id>();
        for(GRP_CC_ChainAccount__c chainAccount : calist){
            idRegion.add(chainAccount.GRP_CC_Region__r.Id);
        }
        
        List<GRP_CC_ContractChain__c> ContractChains = [
                SELECT Id, GRP_CC_Contract__r.Id, GRP_CC_Chain__r.id
                FROM GRP_CC_ContractChain__c
                WHERE GRP_CC_Chain__r.id in :idChain
                    AND GRP_CC_Contract__r.GRP_CC_Start_Date__c < :today
                    AND GRP_CC_Contract__r.GRP_CC_End_Date__c > :today

            ];
        
        Set<Id> idContract = new Set<Id>();
        for(GRP_CC_ContractChain__c contractChain : ContractChains){
            idContract.add(contractChain.GRP_CC_Contract__r.Id);
        }

        Map<Id,List<GRP_CC_ContractChain__c>> contractChainByChain = new Map<Id,List<GRP_CC_ContractChain__c>>();
        for(GRP_CC_ContractChain__c contractChain : ContractChains){
            if(contractChainByChain.containsKey(contractChain.GRP_CC_Chain__r.id)){
                List<GRP_CC_ContractChain__c> tmpContratChains = contractChainByChain.get(contractChain.GRP_CC_Chain__r.id);
                tmpContratChains.add(contractChain);
                contractChainByChain.put(contractChain.GRP_CC_Chain__r.id, tmpContratChains);
            }
            else{
                List<GRP_CC_ContractChain__c> newContratChains = new List<GRP_CC_ContractChain__c>();
                newContratChains.add(contractChain);
                contractChainByChain.put(contractChain.GRP_CC_Chain__r.id, newContratChains);
            }
        }
        
        // Request 2
        List<GRP_CC_Contract_Regions_Link__c> allContractRegion = [
                        SELECT GRP_CC_Contract__r.Id, GRP_CC_Region__r.Id
                        FROM GRP_CC_Contract_Regions_Link__c
                        WHERE GRP_CC_Contract__r.Id in :idContract
                            AND GRP_CC_Region__r.Id in :idRegion
                    ];
        
        Map<String,List<GRP_CC_Contract_Regions_Link__c>> contractRegionLinkByRegionByContract = new Map<String,List<GRP_CC_Contract_Regions_Link__c>>();
        for(GRP_CC_Contract_Regions_Link__c contractRegionLink : allContractRegion){
            String key = String.valueOf(contractRegionLink.GRP_CC_Contract__r.Id) + String.valueOf(contractRegionLink.GRP_CC_Region__r.Id);
            if(contractRegionLinkByRegionByContract.containsKey(key)){
                List<GRP_CC_Contract_Regions_Link__c> tmpContractRegion = contractRegionLinkByRegionByContract.get(key);
                tmpContractRegion.add(contractRegionLink);
                contractRegionLinkByRegionByContract.put(key, tmpContractRegion);
            }
            else{
                List<GRP_CC_Contract_Regions_Link__c> newContractRegion = new List<GRP_CC_Contract_Regions_Link__c>();
                newContractRegion.add(contractRegionLink);
                contractRegionLinkByRegionByContract.put(key, newContractRegion);
            }
        }
        
        // Request 3
        Set<Id> idContractOfRegion = new Set<Id>();
        for(GRP_CC_Contract_Regions_Link__c contractRegion : allContractRegion){
            idContractOfRegion.add(contractRegion.GRP_CC_Contract__r.Id);
        }
        
        Map<Id,GRP_CC_Contract__c> allContract = new Map<Id,GRP_CC_Contract__c>([
                            SELECT Id, GRP_CC_Category__c, GRP_CC_Start_Date__c, GRP_CC_End_Date__c, 
                                GRP_CC_EndCollectOneDate__c, GRP_CC_Cycle__c
                            FROM GRP_CC_Contract__c
                            WHERE Id in :idContractOfRegion
                        ]);
        
        // Request 4
        List<GRP_CC_Collect__c> allCollect = [
                            SELECT GRP_CC_PeriodStart__c, GRP_CC_PeriodEnd__c, GRP_CC_Status__c, GRP_CC_State__c, GRP_CC_Collect_info__c, GRP_CC_Full_collect_infos__c, 
                            GRP_CC_Primary_spirit_suppliers_1__c, GRP_CC_Primary_spirit_suppliers_2__c, GRP_CC_Primary_spirit_suppliers_3__c, 
                            GRP_CC_Contract__r.Id, GRP_CC_ChainAccount__r.Id
                            FROM GRP_CC_Collect__c
                            WHERE GRP_CC_Contract__r.Id in :allContract.keySet()
                            AND GRP_CC_ChainAccount__r.Id = :idChainAccount
                            ORDER BY GRP_CC_PeriodEnd__c DESC
                        ];
        
        Map<String,List<GRP_CC_Collect__c>> collectByContractAndChainAccount = new Map<String,List<GRP_CC_Collect__c>>();
        for(GRP_CC_Collect__c tmpCollect : allCollect){
            String key = String.valueOf(tmpCollect.GRP_CC_Contract__r.Id) + String.valueOf(tmpCollect.GRP_CC_ChainAccount__r.Id);
            if(collectByContractAndChainAccount.containsKey(key)){
                List<GRP_CC_Collect__c> tmpCollects = collectByContractAndChainAccount.get(key);
                tmpCollects.add(tmpCollect);
                collectByContractAndChainAccount.put(key, tmpCollects);
            }
            else{
                List<GRP_CC_Collect__c> newCollects = new List<GRP_CC_Collect__c>();
                newCollects.add(tmpCollect);
                collectByContractAndChainAccount.put(key, newCollects);
            }
        }
        //----------------------------------------------------------
     
        for (GRP_CC_ChainAccount__c ca:calist) {
            ChainAccountItem item = new ChainAccountItem();
            item.ca=ca;
            List<ContractItem> contractList = new List<ContractItem>();
            
            //----------------------------------------------------------
            // 22/02/2016 : correction anomalie WS (Too many SOQL query)
            // Request 1
            /*List<GRP_CC_ContractChain__c> ContractChain = [
                SELECT Id, GRP_CC_Contract__r.Id
                FROM GRP_CC_ContractChain__c
                WHERE GRP_CC_Chain__r.id = :ca.GRP_CC_Chain__r.Id
                    AND GRP_CC_Contract__r.GRP_CC_Start_Date__c < :today
                    AND GRP_CC_Contract__r.GRP_CC_End_Date__c > :today

            ];*/
            List<GRP_CC_ContractChain__c> ContractChain = contractChainByChain.get(ca.GRP_CC_Chain__r.Id);
            //----------------------------------------------------------
            
            //----------------------------------------------------------
            // 22/02/2016 : correction anomalie WS (Too many SOQL query)
            //if (ContractChain.size() > 0) {
            if (ContractChain != null && ContractChain.size() > 0) {
            //----------------------------------------------------------
                for (GRP_CC_ContractChain__c cc:ContractChain){
                    //----------------------------------------------------------
            		// 22/02/2016 : correction anomalie WS (Too many SOQL query)
            		// Request 2
                    /*List<GRP_CC_Contract_Regions_Link__c> ContractRegion = [
                        SELECT GRP_CC_Contract__r.Id
                        FROM GRP_CC_Contract_Regions_Link__c
                        WHERE GRP_CC_Contract__r.Id = :cc.GRP_CC_Contract__r.Id
                            AND GRP_CC_Region__r.Id = :ca.GRP_CC_Region__r.Id
                    ];*/
                    String key = String.valueOf(cc.GRP_CC_Contract__r.Id) + String.valueOf(ca.GRP_CC_Region__r.Id);
                    List<GRP_CC_Contract_Regions_Link__c> ContractRegion = contractRegionLinkByRegionByContract.get(key);
                    //----------------------------------------------------------
                    
                    //----------------------------------------------------------
                    // 22/02/2016 : correction anomalie WS (Too many SOQL query)
                    //if (ContractRegion.size() > 0) {
                    if (ContractRegion != null && ContractRegion.size() > 0) {
            			// Request 3
                        /*GRP_CC_Contract__c contract = new GRP_CC_Contract__c();
                        contract = [
                            SELECT Id, 
                                GRP_CC_Category__c, 
                                GRP_CC_Start_Date__c, 
                                GRP_CC_End_Date__c, 
                                GRP_CC_EndCollectOneDate__c, 
                                GRP_CC_Cycle__c
                            FROM GRP_CC_Contract__c
                            WHERE Id = :ContractRegion[0].GRP_CC_Contract__r.Id
                        ];*/
                        GRP_CC_Contract__c contract = allContract.get(ContractRegion[0].GRP_CC_Contract__r.Id);
                        //----------------------------------------------------------
                        ContractItem citem = new ContractItem();
                        citem.cont=contract;
                        //----------------------------------------------------------
            			// 22/02/2016 : correction anomalie WS (Too many SOQL query)
            			// Request 4
                        /*List<GRP_CC_Collect__c> colllist = [
                            SELECT GRP_CC_PeriodStart__c, GRP_CC_PeriodEnd__c, GRP_CC_Status__c, GRP_CC_State__c
                            FROM GRP_CC_Collect__c
                            WHERE GRP_CC_Contract__r.Id = :contract.Id
                            AND GRP_CC_ChainAccount__r.Id = :ca.Id
                            ORDER BY GRP_CC_PeriodEnd__c DESC
                        ];*/
                        String key2 = String.valueOf(contract.Id) + String.valueOf(ca.Id);
                        List<GRP_CC_Collect__c> colllist = collectByContractAndChainAccount.get(key2);
                        //if (colllist.size() > 0) {
                        if (colllist != null && colllist.size() > 0) {
                       	//----------------------------------------------------------
                            citem.coll=colllist[0];
                        }                       
                        contractList.add(citem);
                    }                                               
                }
                item.clist = contractList;   
            }
            response.itemList.add(item);    
            response.status = 'Success';
            response.message = 'Your request was executed with success!';
        }  

        return response;
    }

    global class ContractItem{
        GRP_CC_Contract__c cont;
        GRP_CC_Collect__c coll;

       public ContractItem() {
            cont = new GRP_CC_Contract__c();  
            coll = new GRP_CC_Collect__c(); 
        }
    }    
    
    global class ChainAccountItem{
        GRP_CC_ChainAccount__c ca;
        List<ContractItem> clist;

       public ChainAccountItem() {
            ca = new GRP_CC_ChainAccount__c();  
            clist = new List<ContractItem>(); 
        }
    }    
    
    global class GetCollectResponseWrapper {
        public List<ChainAccountItem> itemList; 
        public String status;
        String message;
    
        public getCollectResponseWrapper() {
            itemList = new List<ChainAccountItem>();
        }
    }                                                     
    
}