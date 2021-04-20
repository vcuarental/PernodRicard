@RestResource(urlMapping='/ChainAccount/*/Contract')
global with sharing class GRP_CC_REST_ChainAccountServices {
  
    @HttpGet
    global static GetContractResponseWrapper doGet() {
    /******************************************************************************************
    * Description: Project Connected Customers - This method returns the BQS contractualized
    *                  for a given chainAccount
    *              URL should be encoded in UTF-8.
    *              Email of the chainAccount responsible (login in Drupal) should be passed as 
    *                  a mandatory parameter.
    * Author: Soazig Bars
    * Creation date: 1st of June 2015
    * Modifications:
    *******************************************************************************************/
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        GetContractResponseWrapper response = new GetContractResponseWrapper();
        
        String DecodedUrl = EncodingUtil.urlDecode(req.requestURI, 'UTF-8');
        String chainAccountId = DecodedUrl.substringBetween('ChainAccount/', '/Contract');
        String email = req.params.get('email');
        
      
        if(chainAccountId != null && chainAccountId != '') {
            List<GRP_CC_ChainAccount__c> chainAccountList = [
                            SELECT Id, Name, GRP_CC_Chain__r.Id, GRP_CC_Region__r.Id, GRP_CC_ChainAccountResponsible__c 
                            FROM GRP_CC_ChainAccount__c 
                            WHERE Id= :chainAccountId
                            ];
                            
            if (chainAccountList != null && chainAccountList.size() > 0) {

                if (chainAccountList[0].GRP_CC_ChainAccountResponsible__c.equalsIgnoreCase(email)) {
                    date today = date.today();              
    
                    List<GRP_CC_Contract_BQS_Link__c> c = new List<GRP_CC_Contract_BQS_Link__c>();
                    c = [SELECT GRP_CC_Contract__r.Id,
                                GRP_CC_Contract__r.GRP_CC_Start_Date__c,     
                                GRP_CC_Contract__r.GRP_CC_EndCollectOneDate__c, 
                                GRP_CC_Contract__r.GRP_CC_End_Date__c,  
                                GRP_CC_Contract__r.GRP_CC_Category__c,  
                                GRP_CC_BrandQualitySize__r.Id,
                                GRP_CC_BrandQualitySize__r.CORE_BrandQuality__r.Id,
                                GRP_CC_BrandQualitySize__r.CORE_BrandQuality__r.CORE_Brand__r.Id,
                                GRP_CC_BrandQualitySize__r.CORE_Size__r.Id
                            FROM GRP_CC_Contract_BQS_Link__c
                            WHERE GRP_CC_Contract__r.GRP_CC_Start_Date__c < :today
                                AND GRP_CC_Contract__r.GRP_CC_End_Date__c > :today
                        ];
                    
                    //----------------------------------------------------------
                    // 22/02/2016 : correction anomalie WS (Too many SOQL query)
                    // Request 1
                    Set<Id> allContratId = new Set<Id>();
                    for(GRP_CC_Contract_BQS_Link__c contratBQSLink : c){
                        allContratId.add(contratBQSLink.GRP_CC_Contract__r.Id);
                    }

                    //Get all ContractRegionLink for Chain
                    List<GRP_CC_Contract_Regions_Link__c> allContractRegion = [
                        SELECT Id, GRP_CC_Contract__r.Id
                        FROM GRP_CC_Contract_Regions_Link__c
                        WHERE GRP_CC_Contract__r.Id in :allContratId
                        AND GRP_CC_Region__r.id = :chainAccountList[0].GRP_CC_Region__r.Id
                    ];
                    
                    Map<Id,List<GRP_CC_Contract_Regions_Link__c>> contratRegionLinkByContrat = new Map<Id,List<GRP_CC_Contract_Regions_Link__c>>();
                    for(GRP_CC_Contract_Regions_Link__c contratRegionLink : allContractRegion){
                        Id key = contratRegionLink.GRP_CC_Contract__r.Id;
                        if(contratRegionLinkByContrat.containsKey(key)){
                            List<GRP_CC_Contract_Regions_Link__c> tmpContractRegionLink = contratRegionLinkByContrat.get(key);
                            tmpContractRegionLink.add(contratRegionLink);
                            contratRegionLinkByContrat.put(key, tmpContractRegionLink);
                        }
                        else{
                            List<GRP_CC_Contract_Regions_Link__c> newContractRegionLink = new List<GRP_CC_Contract_Regions_Link__c>();
                            newContractRegionLink.add(contratRegionLink);
                            contratRegionLinkByContrat.put(key, newContractRegionLink);
                        }
                    }
                    
                    // Request 2
                    //Get all ContractChain for Chain
                    List<GRP_CC_ContractChain__c> allContractChain = [
                        SELECT GRP_CC_Chain__r.Id, GRP_CC_Contract__r.Id
                        FROM GRP_CC_ContractChain__c
                        WHERE GRP_CC_Contract__r.Id in :allContratId
                        AND GRP_CC_Chain__r.Id = :chainAccountList[0].GRP_CC_Chain__r.Id
                    ];
                    
                    Map<Id,List<GRP_CC_ContractChain__c>> contratChainByContrat = new Map<Id,List<GRP_CC_ContractChain__c>>();
                    for(GRP_CC_ContractChain__c contractChain : allContractChain){
                        Id key = contractChain.GRP_CC_Contract__r.Id;
                        if(contratChainByContrat.containsKey(key)){
                            List<GRP_CC_ContractChain__c> tmpContractChain = contratChainByContrat.get(key);
                            tmpContractChain.add(contractChain);
                            contratChainByContrat.put(key, tmpContractChain);
                        }
                        else{
                            List<GRP_CC_ContractChain__c> newContractCHain = new List<GRP_CC_ContractChain__c>();
                            newContractCHain.add(contractChain);
                            contratChainByContrat.put(key, newContractCHain);
                        }
                    }

                    // Request 3
                    Map<Id,CORE_BrandQuality__c> allBrandQuality = new Map<Id,CORE_BrandQuality__c>([
                        SELECT Id, Name, CORE_DAMAssetId__c 
                        FROM CORE_BrandQuality__c
                    ]);
                    // Request 4
                    Map<Id,CORE_Brand__c> allBrand = new Map<Id,CORE_Brand__c>([
                        SELECT Id, Name, CORE_DAMAssetId__c 
                        FROM CORE_Brand__c
                    ]);
                    // Request 5
                    Map<Id,CORE_Size__c> allSize = new Map<Id,CORE_Size__c>([
                        SELECT Id, CORE_Value__c
                        FROM CORE_Size__c
                    ]);
                    // Request 6
                    Map<Id,CORE_BrandQualitySize__c> allBrandQualitySize = new Map<Id,CORE_BrandQualitySize__c>([
                        SELECT Id, Name, CORE_DAMAssetId__c 
                        FROM CORE_BrandQualitySize__c
                    ]);
                    
                    // Request 7
                    List<Attachment> allAttachment = [
                        SELECT Id, parent.Id
                        FROM Attachment 
                        WHERE parent.Id in :allContratId
                    ];
                    Map<Id,List<Attachment>> attachmentByContrat = new Map<Id,List<Attachment>>();
                    for(Attachment attachment : allAttachment){
                        Id key = attachment.parent.Id;
                        if(attachmentByContrat.containsKey(key)){
                            List<Attachment> tmpAttachment = attachmentByContrat.get(key);
                            tmpAttachment.add(attachment);
                            attachmentByContrat.put(key, tmpAttachment);
                        }
                        else{
                            List<Attachment> newAttachment = new List<Attachment>();
                            newAttachment.add(attachment);
                            attachmentByContrat.put(key, newAttachment);
                        }
                    }
                    //----------------------------------------------------------
                        
                    Map<String, categorytmp> catMap = new Map<String, categorytmp>();
                    for (GRP_CC_Contract_BQS_Link__c contbqs : c) {
                        //----------------------------------------------------------
                    	// 22/02/2016 : correction anomalie WS (Too many SOQL query)
                        // Request 1
                        /*List<GRP_CC_Contract_Regions_Link__c> ContractRegion = [
                                                SELECT Id
                                                FROM GRP_CC_Contract_Regions_Link__c
                                                WHERE GRP_CC_Contract__r.Id = :contbqs.GRP_CC_Contract__r.Id
                                                    AND GRP_CC_Region__r.id = :chainAccountList[0].GRP_CC_Region__r.Id
                                                ];*/
                        List<GRP_CC_Contract_Regions_Link__c> ContractRegion = contratRegionLinkByContrat.get(contbqs.GRP_CC_Contract__r.Id);
                        
                        // Request 2   
                        /*List<GRP_CC_ContractChain__c> ContractChain = [
                                                SELECT GRP_CC_Chain__r.Id
                                                FROM GRP_CC_ContractChain__c
                                                WHERE GRP_CC_Contract__r.Id = :contbqs.GRP_CC_Contract__r.Id
                                                    AND GRP_CC_Chain__r.Id = :chainAccountList[0].GRP_CC_Chain__r.Id
                                                ];*/
                        List<GRP_CC_ContractChain__c> ContractChain = contratChainByContrat.get(contbqs.GRP_CC_Contract__r.Id);
                        
                        //if (ContractRegion.size() > 0 && ContractChain.size() > 0) {
                        if (ContractRegion != null && ContractChain != null && ContractRegion.size() > 0 && ContractChain.size() > 0) {
                            // Request 3
                            /*CORE_BrandQuality__c bq = [
                                                SELECT Id, Name, CORE_DAMAssetId__c 
                                                FROM CORE_BrandQuality__c 
                                                WHERE Id = :contbqs.GRP_CC_BrandQualitySize__r.CORE_BrandQuality__r.Id
                                                ];*/
                            CORE_BrandQuality__c bq = allBrandQuality.get(contbqs.GRP_CC_BrandQualitySize__r.CORE_BrandQuality__r.Id);
                            // Request 4
                            /*CORE_Brand__c br = [
                                                SELECT Id, Name, CORE_DAMAssetId__c 
                                                FROM CORE_Brand__c 
                                                WHERE Id = :contbqs.GRP_CC_BrandQualitySize__r.CORE_BrandQuality__r.CORE_Brand__r.Id
                                                ];*/
                            CORE_Brand__c br = allBrand.get(contbqs.GRP_CC_BrandQualitySize__r.CORE_BrandQuality__r.CORE_Brand__r.Id);
                            // Request 5
                            /*CORE_Size__c s = [
                                                SELECT Id, CORE_Value__c
                                                FROM CORE_Size__c
                                                WHERE Id = :contbqs.GRP_CC_BrandQualitySize__r.CORE_Size__r.Id
                                                ];*/
                            CORE_Size__c s = allSize.get(contbqs.GRP_CC_BrandQualitySize__r.CORE_Size__r.Id);
                            // Request 6
                            /*CORE_BrandQualitySize__c bqstmp = [
                                                SELECT Id, Name, CORE_DAMAssetId__c 
                                                FROM CORE_BrandQualitySize__c
                                                WHERE Id = :contbqs.GRP_CC_BrandQualitySize__r.Id
                                                ];*/
                            CORE_BrandQualitySize__c bqstmp = allBrandQualitySize.get(contbqs.GRP_CC_BrandQualitySize__r.Id);
                            //----------------------------------------------------------
                            BQSItem bqs = new BQSItem();
                            bqs.BQS = bqstmp;
                            bqs.Brand = br;
                            bqs.BQ = bq;
                            bqs.Size = s;
                            List<BQSItem> bqslist = new List<BQSItem>();
                            if (catMap.containsKey(contbqs.GRP_CC_Contract__r.GRP_CC_Category__c)) {
                                categorytmp cattmp = catMap.get(contbqs.GRP_CC_Contract__r.GRP_CC_Category__c);
                                bqslist = cattmp.bqsList;
                                bqsList.add(bqs);
                                cattmp.bqsList = bqsList;
                                catMap.put(contbqs.GRP_CC_Contract__r.GRP_CC_Category__c, cattmp);
                            } else {
                                categorytmp cati = new categorytmp();
                                cati.startDate = contbqs.GRP_CC_Contract__r.GRP_CC_Start_Date__c;
                                cati.endDate = contbqs.GRP_CC_Contract__r.GRP_CC_End_Date__c;
                                cati.EndCollectOneDate = contbqs.GRP_CC_Contract__r.GRP_CC_EndCollectOneDate__c;
                                bqsList.add(bqs);
                                cati.bqsList = bqsList;
                                //----------------------------------------------------------
                                // 22/02/2016 : correction anomalie WS (Too many SOQL query)
                                // Request 7
                                /*List<Attachment> a = new List<Attachment>();
                                a = [
                                    SELECT Id 
                                    FROM Attachment 
                                    WHERE parent.Id = :contbqs.GRP_CC_Contract__r.Id
                                    ];*/
                                List<Attachment> a = attachmentByContrat.get(contbqs.GRP_CC_Contract__r.Id);
                                //if (a.size() > 0) {
                                if (a != null && a.size() > 0) {
                                //----------------------------------------------------------
                                    cati.contractFileId = a[0].Id;
                                }
                                catMap.put(contbqs.GRP_CC_Contract__r.GRP_CC_Category__c, cati);
                            }
                        }
                        
                    }
                    for (String cat : catMap.keySet()) {
                        categoryItem catitem = new categoryItem();
                        catitem.category = cat;
                        catitem.startDate = catMap.get(cat).startDate;
                        catitem.endDate = catMap.get(cat).endDate;
                        catitem.EndCollectOneDate = catMap.get(cat).EndCollectOneDate;
                        catitem.contractFileId = catMap.get(cat).contractFileId;
                        catitem.bqsList = catMap.get(cat).bqsList;
                        response.catList.add(catitem);
                    }
                    response.status = 'Success';
                    response.message = 'Your request was executed with success!';
                } 
                else {
                    response.status = 'Error';
                    response.message = 'The email does not match the configured chain account responsible email !';
                }
            }
            else {
                response.status = 'Error';
                response.message = 'The given ChainAccount : '+ChainAccountId+' does not exist!';          
            }
        }

        else {
            response.status = 'Error';
            response.message = 'The parameter ChainAccountName cannot be null';
        }
        system.debug(response);
        return response;
    }
   
    global class BQSItem {
        CORE_Brand__c Brand;
        CORE_BrandQuality__c BQ;
        CORE_BrandQualitySize__c BQS;
        CORE_Size__c Size;
                
        public BQSItem() {  
        }
    }

    global class categorytmp {
        String contractFileId;
        Date startDate;
        Date EndDate;
        Date EndCollectOneDate;        
        List<BQSItem> bqsList;               

        public categorytmp () {
            bqsList = new List<BQSItem>();
        }
   }

    global class categoryItem {
        String category;
        String contractFileId;
        Date startDate;
        Date EndDate;
        Date EndCollectOneDate;        
        List<BQSItem> bqsList;       
    }
    
    global class GetContractResponseWrapper {
        List<categoryItem > catList;
        public String status;
        String message;
    
        public getContractResponseWrapper() {
            catList = new List<categoryItem>();
        }
    }
}