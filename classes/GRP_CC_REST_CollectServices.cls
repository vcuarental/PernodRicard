@RestResource(urlMapping='/ChainAccount/*/Collect/*')
global with sharing class GRP_CC_REST_CollectServices {
  
    @HttpGet
    global static GetCollectResponseWrapper doGet() {
  /******************************************************************************************
  * Description: Project Connected Customers - This method returns the collects associated
  *                  to a given chainAccount 
  *                  and Start and/or End date collect (if there are present)
  *              URL should be encoded in UTF-8.
  * Author: Soazig Bars
  * Creation date: 1st of June 2015
  * Modifications:
  *  - 07/07/2016 : add the field GRP_CC_Last_modification_by_email__c in the query
  *  - 23/09/2016 : add the field GRP_CC_Collect_info__c in the query, get the fields GRP_CC_Unknown__c and GRP_CC_No_volume__c from the CollectBQ
  *  - 07/09/2018 : add the field GRP_CC_All_Collect_infos__c in the query
  *
  * ex: services/apexrest/ChainAccount/aJIL00000000001/Collect?PeriodStart=2015-01-15&PeriodEnd=2011-12-17
  *     services/apexrest/ChainAccount/aJIL00000000001/Collect?State=New,Processing&Status=New
  *
  *******************************************************************************************/
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        GetCollectResponseWrapper response = new GetCollectResponseWrapper();
        
        String DecodedUrl = EncodingUtil.urlDecode(req.requestURI, 'UTF-8');
        String chainAccountId = DecodedUrl.substringBetween('ChainAccount/', '/Collect');
        String PeriodStart = req.params.get('PeriodStart');
        String PeriodEnd = req.params.get('PeriodEnd');
        String state = req.params.get('State');
        String status = req.params.get('Status');
        
        if(chainAccountId != null && chainAccountId != '') 
        {
            List<GRP_CC_ChainAccount__c> chainAccountList = [
                            SELECT Id
                            FROM GRP_CC_ChainAccount__c 
                            WHERE Id = :chainAccountId
                            ];
            if (chainAccountList != null && chainAccountList .size() > 0) 
            {
                String chainId = chainAccountList[0].Id; 
                List<GRP_CC_Collect__c> collectList =  new List<GRP_CC_Collect__c>();
                
                String q = 'SELECT GRP_CC_Full_collect_infos__c, GRP_CC_Primary_spirit_suppliers_1__c, GRP_CC_Primary_spirit_suppliers_2__c, GRP_CC_Primary_spirit_suppliers_3__c, GRP_CC_PeriodStart__c, GRP_CC_PeriodEnd__c, GRP_CC_Contract__c,';
                q += 'c.GRP_CC_Contract__r.GRP_CC_Category__c, GRP_CC_Status__c, GRP_CC_State__c, GRP_CC_Comment__c, GRP_CC_Last_modification_by_email__c, GRP_CC_Collect_info__c ';
                q += 'FROM GRP_CC_Collect__c c ';
                q += 'WHERE GRP_CC_ChainAccount__c = :chainId';
                
                if( PeriodStart != null && PeriodStart != '') {
                    Date dStart = date.valueOf(PeriodStart);                    
                    q += ' AND GRP_CC_PeriodStart__c >= :dStart';
                }

                if( PeriodEnd != null && PeriodEnd != '') {
                    Date dEnd = date.valueOf(PeriodEnd);                    
                    q += ' AND GRP_CC_PeriodEnd__c <= :dEnd';
                }

                if( status != null && status != '') {
                    String[] statuslist = status.split(',', 0);
                    q += ' AND GRP_CC_Status__c = :statuslist';
                }

                if( state != null && state != '') {
                    String[] statelist = state.split(',', 0);
                    q += ' AND GRP_CC_State__c in :statelist';
                }

                System.debug('GetCollectResponseWrapper doGet() q:'+ q);
                collectList = Database.query(q);
        
                //----------------------------------------------------------
                // 22/02/2016 : correction anomalie WS (Too many SOQL query)
                // Request 1
                Set<Id> collectId = new Set<Id>();
                for(GRP_CC_Collect__c tmpCollect : collectList){
                    collectId.add(tmpCollect.Id);
                }
                
                List<GRP_CC_CollectBQ__c> allCollBQRecord = [
                    SELECT GRP_CC_BrandQuality__c,
                    cBQ.GRP_CC_BrandQuality__r.Name,
                    cBQ.GRP_CC_BrandQuality__r.CORE_Brand__r.Name,
                    //GRP_CC_isBackBar__c,  CCS-4171
                    GRP_CC_isPouring__c,
                    GRP_CC_isOnMenu__c,
                    GRP_CC_isPremium__c,
                    GRP_CC_IsRoomsMinibar__c,
                    GRP_CC_IsOptionalAdditions__c,
                    GRP_CC_IsMeetingsEvents__c,
					//GRP_CC_isSuperPremium__c, CCS-4171
                    GRP_CC_Unknown__c,
                    GRP_CC_No_volume__c,
                    GRP_CC_Collect__r.Id
                    FROM GRP_CC_CollectBQ__c cBQ
                    WHERE GRP_CC_Collect__c in : collectId
                ];
                
                Map<Id,List<GRP_CC_CollectBQ__c>> collectBQByCollect = new Map<Id,List<GRP_CC_CollectBQ__c>>();
                for(GRP_CC_CollectBQ__c tmpCollectBQ : allCollBQRecord){
                    Id key = tmpCollectBQ.GRP_CC_Collect__r.Id;
                    if(collectBQByCollect.containsKey(key)){
                        List<GRP_CC_CollectBQ__c> tmpListCollectBQ = collectBQByCollect.get(key);
                        tmpListCollectBQ.add(tmpCollectBQ);
                        collectBQByCollect.put(key, tmpListCollectBQ);
                    }
                    else{
                        List<GRP_CC_CollectBQ__c> newListCollectBQ = new List<GRP_CC_CollectBQ__c>();
                        newListCollectBQ.add(tmpCollectBQ);
                        collectBQByCollect.put(key, newListCollectBQ);
                    }
                }
                
                // Request 2
                List<GRP_CC_CollectBQs__c> allCollBQsRecord = [
                            SELECT GRP_CC_BrandQualitySize__c,
                                cBQs.GRP_CC_BrandQualitySize__r.CORE_Size__r.CORE_Value__c,
                                cBQs.GRP_CC_BrandQualitySize__r.CORE_BrandQuality__r.Name,
                                cBQs.GRP_CC_BrandQualitySize__r.CORE_BrandQuality__r.CORE_Brand__r.Name,
                                GRP_CC_Quantity__c,
                          GRP_CC_Collect__r.Id
                            FROM GRP_CC_CollectBQs__c cBQs
                            WHERE GRP_CC_Collect__c in : collectId
                        ];
                
                Map<Id,List<GRP_CC_CollectBQs__c>> collectBQsByCollect = new Map<Id,List<GRP_CC_CollectBQs__c>>();
                for(GRP_CC_CollectBQs__c tmpCollectBQs : allCollBQsRecord){
                    Id key = tmpCollectBQs.GRP_CC_Collect__r.Id;
                    if(collectBQsByCollect.containsKey(key)){
                        List<GRP_CC_CollectBQs__c> tmpListCollectBQs = collectBQsByCollect.get(key);
                        tmpListCollectBQs.add(tmpCollectBQs);
                        collectBQsByCollect.put(key, tmpListCollectBQs);
                    }
                    else{
                        List<GRP_CC_CollectBQs__c> newListCollectBQs = new List<GRP_CC_CollectBQs__c>();
                        newListCollectBQs.add(tmpCollectBQs);
                        collectBQsByCollect.put(key, newListCollectBQs);
                    }
                }
                //----------------------------------------------------------
                
                for ( GRP_CC_Collect__c collecte : collectList ) {
                    //Collect                       
                    if (Collecte != null) {   
                        CollectItem collItem = new CollectItem();
                        collItem.coll= collecte;
                        // Collect BQ                          
                        //----------------------------------------------------------
                // 22/02/2016 : correction anomalie WS (Too many SOQL query)
                // Request 1
                        /*List<GRP_CC_CollectBQ__c> collBQRecord = [
                            SELECT GRP_CC_BrandQuality__c,
                                cBQ.GRP_CC_BrandQuality__r.Name,
                                cBQ.GRP_CC_BrandQuality__r.CORE_Brand__r.Name,
                                GRP_CC_isBackBar__c,
                                GRP_CC_isPouring__c,
                                GRP_CC_isOnMenu__c,
                                GRP_CC_isPremium__c
                            FROM GRP_CC_CollectBQ__c cBQ
                            WHERE GRP_CC_Collect__c = : collecte.Id
                        ];*/
                        
                        List<GRP_CC_CollectBQ__c> collBQRecord = collectBQByCollect.get(collecte.Id);
                        //----------------------------------------------------------
                        if (collBQRecord != null && collBQRecord .size() > 0) {  
                            collItem.collectBQList = collBQRecord ;
                        }                                  
                        // Collect BQs
                        //----------------------------------------------------------
                // 22/02/2016 : correction anomalie WS (Too many SOQL query)
                // Request 2
                        /*List<GRP_CC_CollectBQs__c> collBQsRecord = [
                            SELECT GRP_CC_BrandQualitySize__c,
                                cBQs.GRP_CC_BrandQualitySize__r.CORE_Size__r.CORE_Value__c,
                                cBQs.GRP_CC_BrandQualitySize__r.CORE_BrandQuality__r.Name,
                                cBQs.GRP_CC_BrandQualitySize__r.CORE_BrandQuality__r.CORE_Brand__r.Name,
                                GRP_CC_Quantity__c
                            FROM GRP_CC_CollectBQs__c cBQs
                            WHERE GRP_CC_Collect__c =: collecte.Id
                        ];*/
                        List<GRP_CC_CollectBQs__c> collBQsRecord = collectBQsByCollect.get(collecte.Id);
                        //----------------------------------------------------------
                        if (collBQsRecord != null && collBQsRecord .size() > 0) {                             
                            collItem.collectBQsList = collBQsRecord ;                                    
                        } 
                                
                        response.itemList.add(collItem);                                   
                    }
                }
                response.status = 'Success';
                response.message = 'There are the collects corresponding to the ChainAccount: '+ChainAccountId+'.';
            } else {
                response.status = 'Error';
                response.message = 'The given ChainAccount : '+ChainAccountId+' does not exist!';    
            }       
        } else {
            response.status = 'Error';
            response.message = 'The parameter ChainAccountId cannot be null';
        }        
        System.debug(response.itemList);
        return response;
    }

    global class CollectItem {
        GRP_CC_Collect__c coll;
        List<GRP_CC_CollectBQ__c> collectBQList;
        List<GRP_CC_CollectBQS__c> collectBQsList;
        
        public CollectItem() {
             coll = new GRP_CC_Collect__c();  
             collectBQList = new List<GRP_CC_CollectBQ__c>();
             collectBQsList = new List<GRP_CC_CollectBQS__c>();
             
        }
    }    
    
    global class GetCollectResponseWrapper {
        public List<CollectItem> itemList; 
        public String status;
        String message;
    
        public getCollectResponseWrapper() {
            itemList = new List<CollectItem>();
        }
    }
                    
                                
    
    @httpPost
    global static PostCollectResponseWrapper doPost(RequestWrapper CC_collect) {
      /******************************************************************************************
    * Description: Project connected Customers - This method inserts a collect for a given
    *                  chainAccount 
    * Author: Soazig Bars
    * Creation Date: 5th of  May 2015
    * Modifications:
    *  - 25/05/2016 : add the field LastModifiedByEmail
    *  - 23/09/2016 : add the fields CollectInfo, GRP_CC_Unknown__c (CollectBQ) and GRP_CC_No_volume__c (CollectBQ)
    *
    * Example of a request body:
    {
    "CC_collect" :
        {
        "periodStart" : "2015-01-15",
        "periodEnd" : "2015-06-15",
        "contract" : "aJLL00000000006OAA",
        "Status" : "Waiting for approval",
        "State" : "Processing",
        "CollectInfo" : "Volumes",
        "FullCollectInfos" : "aJIL00000004CMqOAM aJLL00000000001 2015-01-15 2015-06-15",
        "LastModificationByEmail" : "unknown@unknown.com",
        "Comment" : "blablabla",
        "collBQList" : [
                {
                "GRP_CC_BrandQuality__c" : "aJHL00000004CJCOA2",
                "GRP_CC_isBackBar__c" : true,
                "GRP_CC_isPouring__c" : false,
                "GRP_CC_isOnMenu__c" : true,
                "GRP_CC_isPremium__c" : false,
                "GRP_CC_Unknown__c" : false,
                "GRP_CC_No_volume__c" : false
                }
        ],
        "collBQSList" : [ 
                {
                "GRP_CC_BrandQualitySize__c" : "aJKL00000004CJFOA2",
                "GRP_CC_Quantity__c" : "10"
                },
                {
                "GRP_CC_BrandQualitySize__c" : "aJKL00000004CRYOA2",
                "GRP_CC_Quantity__c" : "20"
                }
        ]
        }
    }
    *
     ******************************************************************************************/
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        PostCollectResponseWrapper response = new PostCollectResponseWrapper();
        
        String DecodedUrl = EncodingUtil.urlDecode(req.requestURI, 'UTF-8');
        String chainAccountId = DecodedUrl.substringBetween('ChainAccount/', '/Collect');
        List<GRP_CC_ChainAccount__c> aList = [SELECT Id, Name FROM GRP_CC_ChainAccount__c WHERE Id = :chainAccountId];    
        List<GRP_CC_Contract__c> cList = [SELECT Id FROM GRP_CC_Contract__c WHERE Id = :CC_collect.contract];

        if (aList != null && aList.size() > 0) {
            Savepoint sp = Database.setSavepoint();
            try {
                GRP_CC_ChainAccount__c ca = aList[0];
                GRP_CC_Collect__c c = new GRP_CC_Collect__c();
                c.GRP_CC_ChainAccount__c = ca.Id;
                c.GRP_CC_Contract__c = cList[0].Id;
                c.GRP_CC_PeriodStart__c = date.valueOf(CC_collect.periodStart);
                c.GRP_CC_PeriodEnd__c = date.valueOf(CC_collect.periodEnd);
                c.GRP_CC_Status__c = CC_collect.status;
                c.GRP_CC_State__c = CC_collect.state;
                c.GRP_CC_Collect_info__c = CC_collect.CollectInfo;
                c.GRP_CC_Full_collect_infos__c = CC_collect.FullCollectInfos;
                c.GRP_CC_Primary_spirit_suppliers_1__c = CC_collect.Primary_spirit_suppliers_1;
                c.GRP_CC_Primary_spirit_suppliers_2__c = CC_collect.Primary_spirit_suppliers_2;
                c.GRP_CC_Primary_spirit_suppliers_3__c = CC_collect.Primary_spirit_suppliers_3;
                c.GRP_CC_Last_modification_by_email__c = CC_collect.LastModificationByEmail;
                c.GRP_CC_Comment__c = CC_collect.comment;
                insert c;
                
                //----------------------------------------------------------
                // 01/03/2016 : correction anomalie WS (Too many DML Statement)
                List<GRP_CC_CollectBQS__c> allNewCbqs = new List<GRP_CC_CollectBQS__c>();
                List<GRP_CC_CollectBQ__c> allNewCbq = new List<GRP_CC_CollectBQ__c>();
                //----------------------------------------------------------
                for (GRP_CC_CollectBQS__c cbqs : CC_collect.collBQSList) {
                    cbqs.GRP_CC_Collect__c = c.Id;
                    //----------------------------------------------------------
                  // 01/03/2016 : correction anomalie WS (Too many DML Statement)
                    allNewCbqs.add(cbqs);
                    //insert cbqs;
                }
                if(allNewCbqs.size() > 0){
                    insert allNewCbqs;
                }
                //----------------------------------------------------------
                for (GRP_CC_CollectBQ__c cbq : CC_collect.collBQList) {
                    cbq.GRP_CC_Collect__c = c.Id;
                    //----------------------------------------------------------
                  // 01/03/2016 : correction anomalie WS (Too many DML Statement)
                    allNewCbq.add(cbq);
                    //insert cbq;
                }
                if(allNewCbq.size() > 0){
                    insert allNewCbq;
                }
         //----------------------------------------------------------
         
                response.coll = c;
                response.status = 'Success';
                response.message = 'votre  collecte a bien été créée';
            }
            catch (Exception e) {
                Database.rollback(sp);
                res.StatusCode = 500;
                response.status = 'Error';
                response.message = 'Your request failed with the following error: ' + e.getMessage();
                System.debug(response.message);
            }
          }
          else {
           response.status = 'Error';
           response.message = 'impossible de retrouver cet account';           
          }
         
        return response;
    }  
    

   global class PostCollectResponseWrapper {
      public GRP_CC_Collect__c coll;
      public String status;
      String message;
      
      public PostCollectResponseWrapper() {
        coll = new GRP_CC_Collect__c();
      }
    }
    
    global class RequestWrapper {
      public String contract;
      public List<GRP_CC_CollectBQ__c> collBQList;
      public List<GRP_CC_CollectBQS__c> collBQSList;
      public String periodStart;
      public String periodEnd;
      public String Status;
      public String State;
      public String CollectInfo;
      public String FullCollectInfos;
      public String Primary_spirit_suppliers_1;
      public String Primary_spirit_suppliers_2;
      public String Primary_spirit_suppliers_3;
      public String LastModificationByEmail;
      public String Comment;
    }
    
    
    @httpPatch
    global static PatchCollectResponseWrapper doPatch(PatchRequestWrapper CC_collect) {
      /******************************************************************************************
    * Description: Project connected Customers - This method updates a collect for a given
    *                  chainAccount 
    *              Can be updated: PeriodStart, periodEnd, Status, LastModificationByEmail, BQS details, BQ details
    * Author: Soazig Bars
    * Creation Date: 5th of  May 2015
    * Modifications:
    *  - 25/05/2016 : add the possibility to update the field LastModificationByEmail
    *  - 23/09/2016 : add the fields CollectInfo, GRP_CC_Unknown__c (CollectBQ) and GRP_CC_No_volume__c (CollectBQ)
    *
    * Example of a request body:
    {
    "CC_collect" :
        {
        "Status" : "Approved",
        "collBQList" : [ {
            "GRP_CC_BrandQuality__c" : "aJHL00000000001",
            "GRP_CC_isBackBar__c" : true,
            "GRP_CC_isPouring__c" : false
            } ],
        "collBQSList" : [ {
            "GRP_CC_BrandQualitySize__c" : "aJKL0000000000B",
            "GRP_CC_Quantity__c" : "50"
            } ]
        }
    }
    *
     ******************************************************************************************/
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        PatchCollectResponseWrapper response = new PatchCollectResponseWrapper();
        
        String DecodedUrl = EncodingUtil.urlDecode(req.requestURI, 'UTF-8');
        String chainAccountId = DecodedUrl.substringBetween('ChainAccount/', '/Collect');
        String collectId = DecodedUrl.substring(DecodedUrl.lastIndexOf('/')+1);
        List<GRP_CC_ChainAccount__c> aList = [SELECT Id, Name FROM GRP_CC_ChainAccount__c WHERE Id = :chainAccountId ];
        List<GRP_CC_Collect__c> cList = [SELECT Id, Name FROM GRP_CC_Collect__c WHERE Id = :collectId ];
        if (aList != null && aList.size() > 0) {
            if (cList != null && cList.size() > 0) {
                Savepoint sp = Database.setSavepoint();
                try {
                    GRP_CC_ChainAccount__c ca = aList[0];
                    GRP_CC_Collect__c c = cList[0];
                    if ( CC_collect.periodStart != null ) {
                        c.GRP_CC_PeriodStart__c = date.valueOf(CC_collect.periodStart);
                    }
                    if ( CC_collect.periodEnd != null ) {
                        c.GRP_CC_PeriodEnd__c = date.valueOf(CC_collect.periodEnd);
                    }
                    if ( CC_collect.status != null ) {
                        c.GRP_CC_Status__c = CC_collect.status;
                    }
                    if ( CC_collect.CollectInfo != null ) {
                        c.GRP_CC_Collect_info__c = CC_collect.CollectInfo;
                    }
                    if ( CC_collect.FullCollectInfos != null ) {
                        c.GRP_CC_Full_collect_infos__c = CC_collect.FullCollectInfos;
                    }
                    if ( CC_collect.Primary_spirit_suppliers_1 != null ) {
                        c.GRP_CC_Primary_spirit_suppliers_1__c = CC_collect.Primary_spirit_suppliers_1;
                    }
                    if ( CC_collect.Primary_spirit_suppliers_2 != null ) {
                        c.GRP_CC_Primary_spirit_suppliers_2__c = CC_collect.Primary_spirit_suppliers_2;
                    }
                    if ( CC_collect.Primary_spirit_suppliers_3 != null ) {
                        c.GRP_CC_Primary_spirit_suppliers_3__c = CC_collect.Primary_spirit_suppliers_3;
                    }
                    if ( CC_collect.LastModificationByEmail != null ){
                        c.GRP_CC_Last_modification_by_email__c = CC_collect.LastModificationByEmail;
                    }
                    if ( CC_collect.comment != null ) {
                        c.GRP_CC_Comment__c = CC_collect.comment;
                    }
                    update c;
                    
                    if (CC_collect.collBQSList != null) {
                        //----------------------------------------------------------
                        // 22/02/2016 : correction anomalie WS (Too many SOQL query)
                        List<GRP_CC_CollectBQS__c> allExistingCbqs = [   SELECT Id, GRP_CC_BrandQualitySize__r.Id
                                                                      FROM GRP_CC_CollectBQS__c 
                                                                      WHERE GRP_CC_Collect__r.Id = :c.Id
                                                                      //AND GRP_CC_BrandQualitySize__r.Id = :cbqs.GRP_CC_BrandQualitySize__c
                                                                     ];
                        
                        Map<Id,List<GRP_CC_CollectBQs__c>> collectBQsByBrandQualitySize = new Map<Id,List<GRP_CC_CollectBQs__c>>();
                        for(GRP_CC_CollectBQs__c tmpCollectBQs : allExistingCbqs){
                            Id key = tmpCollectBQs.GRP_CC_BrandQualitySize__r.Id;
                            if(collectBQsByBrandQualitySize.containsKey(key)){
                                List<GRP_CC_CollectBQs__c> tmpListCollectBQs = collectBQsByBrandQualitySize.get(key);
                                tmpListCollectBQs.add(tmpCollectBQs);
                                collectBQsByBrandQualitySize.put(key, tmpListCollectBQs);
                            }
                            else{
                                List<GRP_CC_CollectBQs__c> newListCollectBQs = new List<GRP_CC_CollectBQs__c>();
                                newListCollectBQs.add(tmpCollectBQs);
                                collectBQsByBrandQualitySize.put(key, newListCollectBQs);
                            }
                        }
                        //----------------------------------------------------------
                        //----------------------------------------------------------
                    // 01/03/2016 : correction anomalie WS (Too many DML Statement)
                    List<GRP_CC_CollectBQS__c> cbqsToUpdate = new List<GRP_CC_CollectBQS__c>();
                    //----------------------------------------------------------
                        for (GRP_CC_CollectBQS__c cbqs : CC_collect.collBQSList) {
                            //----------------------------------------------------------
                  // 22/02/2016 : correction anomalie WS (Too many SOQL query)
                            /*List<GRP_CC_CollectBQS__c> existingCbqs = new List<GRP_CC_CollectBQS__c>();
                            existingCbqs = [
                                    SELECT Id 
                                    FROM GRP_CC_CollectBQS__c 
                                    WHERE GRP_CC_Collect__r.Id = :c.Id
                                        AND GRP_CC_BrandQualitySize__r.Id = :cbqs.GRP_CC_BrandQualitySize__c
                                    ];*/
                            List<GRP_CC_CollectBQS__c> existingCbqs = collectBQsByBrandQualitySize.get(cbqs.GRP_CC_BrandQualitySize__c);
                            //if (existingCbqs.size() > 0 ) {
                            if (existingCbqs != null && existingCbqs.size() > 0) {
                            //----------------------------------------------------------
                                if (cbqs.GRP_CC_BrandQualitySize__c != null) {
                                    existingCbqs[0].GRP_CC_BrandQualitySize__c = cbqs.GRP_CC_BrandQualitySize__c ;
                                }
                                if (cbqs.GRP_CC_Quantity__c != null ) {
                                    existingCbqs[0].GRP_CC_Quantity__c = cbqs.GRP_CC_Quantity__c ;
                                }
                                //----------------------------------------------------------
                                // 01/03/2016 : correction anomalie WS (Too many DML Statement)
                                //update existingCbqs[0];
                                cbqsToUpdate.add(existingCbqs[0]);
                                //----------------------------------------------------------
                            }   
                        }
                        //----------------------------------------------------------
                        // 01/03/2016 : correction anomalie WS (Too many DML Statement)
                        //update existingCbqs[0];
                        if(cbqsToUpdate.size() > 0){
                            update cbqsToUpdate;
                        }
                        //----------------------------------------------------------
                    }
                    
                    if (CC_collect.collBQList != null) {
                        //----------------------------------------------------------
                        // 22/02/2016 : correction anomalie WS (Too many SOQL query)
                        List<GRP_CC_CollectBQ__c> allExistingCbq = [  SELECT Id, GRP_CC_BrandQuality__r.Id
                                                                    FROM GRP_CC_CollectBQ__c 
                                                                    WHERE GRP_CC_Collect__r.Id = :c.Id
                                                                    //AND GRP_CC_BrandQuality__r.Id = :cbq.GRP_CC_BrandQuality__c
                                                                   ];
                        
                        Map<Id,List<GRP_CC_CollectBQ__c>> collectBQByBrandQuality = new Map<Id,List<GRP_CC_CollectBQ__c>>();
                        for(GRP_CC_CollectBQ__c tmpCollectBQ : allExistingCbq){
                            Id key = tmpCollectBQ.GRP_CC_BrandQuality__r.Id;
                            if(collectBQByBrandQuality.containsKey(key)){
                                List<GRP_CC_CollectBQ__c> tmpListCollectBQ = collectBQByBrandQuality.get(key);
                                tmpListCollectBQ.add(tmpCollectBQ);
                                collectBQByBrandQuality.put(key, tmpListCollectBQ);
                            }
                            else{
                                List<GRP_CC_CollectBQ__c> newListCollectBQ = new List<GRP_CC_CollectBQ__c>();
                                newListCollectBQ.add(tmpCollectBQ);
                                collectBQByBrandQuality.put(key, newListCollectBQ);
                            }
                        }
                        //----------------------------------------------------------
                        //----------------------------------------------------------
                    // 01/03/2016 : correction anomalie WS (Too many DML Statement)
                    List<GRP_CC_CollectBQ__c> cbqToUpdate = new List<GRP_CC_CollectBQ__c>();
                    //----------------------------------------------------------
                        for (GRP_CC_CollectBQ__c cbq : CC_collect.collBQList) {
                            //----------------------------------------------------------
                  // 22/02/2016 : correction anomalie WS (Too many SOQL query)
                            /*List<GRP_CC_CollectBQ__c> existingCbq = new List<GRP_CC_CollectBQ__c>();
                            existingCbq = [
                                    SELECT Id 
                                    FROM GRP_CC_CollectBQ__c 
                                    WHERE GRP_CC_Collect__r.Id = :c.Id
                                        AND GRP_CC_BrandQuality__r.Id = :cbq.GRP_CC_BrandQuality__c
                                    ];*/
                            List<GRP_CC_CollectBQ__c> existingCbq = collectBQByBrandQuality.get(cbq.GRP_CC_BrandQuality__c);
                            //if (existingCbq.size() > 0) {
                            if (existingCbq != null && existingCbq.size() > 0) {
                            //----------------------------------------------------------
                                //CCS-4171 if (cbq.GRP_CC_isBackBar__c != null) {
                                //    existingCbq[0].GRP_CC_isBackBar__c = cbq.GRP_CC_isBackBar__c;
                                //}
                                if (cbq.GRP_CC_isPouring__c!= null) {
                                    existingCbq[0].GRP_CC_isPouring__c= cbq.GRP_CC_isPouring__c;
                                }
                                if (cbq.GRP_CC_isOnMenu__c!= null) {
                                    existingCbq[0].GRP_CC_isOnMenu__c= cbq.GRP_CC_isOnMenu__c;
                                }
                                if (cbq.GRP_CC_isPremium__c!= null) {
                                    existingCbq[0].GRP_CC_isPremium__c= cbq.GRP_CC_isPremium__c;
                                }
                                if (cbq.GRP_CC_IsRoomsMinibar__c!= null) {
                                    existingCbq[0].GRP_CC_IsRoomsMinibar__c= cbq.GRP_CC_IsRoomsMinibar__c;
                                }
                                if (cbq.GRP_CC_IsOptionalAdditions__c!= null) {
                                    existingCbq[0].GRP_CC_IsOptionalAdditions__c= cbq.GRP_CC_IsOptionalAdditions__c;
                                }
                                if (cbq.GRP_CC_IsMeetingsEvents__c!= null) {
                                    existingCbq[0].GRP_CC_IsMeetingsEvents__c= cbq.GRP_CC_IsMeetingsEvents__c;
                                }
								//CCS-4171 if (cbq.GRP_CC_isSuperPremium__c!= null) {
                                //    existingCbq[0].GRP_CC_isSuperPremium__c= cbq.GRP_CC_isSuperPremium__c;
                                //}
                                if (cbq.GRP_CC_Unknown__c != null) {
                                    existingCbq[0].GRP_CC_Unknown__c= cbq.GRP_CC_Unknown__c;
                                }
                                if (cbq.GRP_CC_No_volume__c != null) {
                                    existingCbq[0].GRP_CC_No_volume__c= cbq.GRP_CC_No_volume__c;
                                }
                                //----------------------------------------------------------
                                // 01/03/2016 : correction anomalie WS (Too many DML Statement)
                                //update existingCbq[0];
                                cbqToUpdate.add(existingCbq[0]);
                                //----------------------------------------------------------
                                
                            }
                        }
                        //----------------------------------------------------------
                        // 01/03/2016 : correction anomalie WS (Too many DML Statement)
                        //update existingCbqs[0];
                        if(cbqToUpdate.size() > 0){
                            update cbqToUpdate;
                        }
                        //----------------------------------------------------------
                    }
                    response.coll = c;
                    response.status = 'Success';
                    response.message = 'The collect was updated';
                }
                catch (Exception e) {
                    Database.rollback(sp);
                    res.StatusCode = 500;
                    response.status = 'Error';
                    response.message = 'Your request failed with the following error: ' + e.getMessage();
                }
            }
            else {
                response.status = 'Error';
                response.message = 'Cannot find the specified collect!';           
            }
        }
        else {
            response.status = 'Error';
            response.message = 'Cannot find the specified Chain Account!';           
        }
         
        return response;
    }  

    global class PatchCollectResponseWrapper {
        public GRP_CC_Collect__c coll;
        public String status;
        String message;

        public PatchCollectResponseWrapper() {
            coll = new GRP_CC_Collect__c();
        }
    }
    
    global class PatchRequestWrapper {
        public List<GRP_CC_CollectBQ__c> collBQList;
        public List<GRP_CC_CollectBQS__c> collBQSList;
        public String periodStart;
        public String periodEnd;
        public String Status;
        public String State;
        public String CollectInfo;
        public String FullCollectInfos;
        public String Primary_spirit_suppliers_1;
        public String Primary_spirit_suppliers_2;
        public String Primary_spirit_suppliers_3;
        public String LastModificationByEmail;
        public String Comment;
    }

}