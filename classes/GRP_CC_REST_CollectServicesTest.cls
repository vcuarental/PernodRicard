@isTest
public class GRP_CC_REST_CollectServicesTest{

    static String createGetTestRecords(){
        
        CORE_Brand__c brand = new CORE_Brand__c();
        brand.Name='Brand Test';
        insert brand;
        CORE_BrandQuality__c bq = new CORE_BrandQuality__c();
        bq.Name='Bq Test';
        bq.CORE_Brand__c=brand.Id;
        insert bq;
        CORE_Size__c s = new CORE_Size__c();
        s.CORE_Value__c=3;
        insert s;
        CORE_BrandQualitySize__c bqs = new CORE_BrandQualitySize__c();
        bqs.Name='Bqs Test';
        bqs.CORE_Size__c=s.Id;
        bqs.CORE_BrandQuality__c=bq.Id;
        insert bqs;
        
        CORE_Region__c r = new CORE_Region__c();
        r.Name = 'Region test';
        insert r;
        GRP_CC_Group__c cg = new GRP_CC_Group__c();
        cg.GRP_CC_GroupeResponsible__c = 'test@pernod-ricard.com';
        cg.GRP_CC_Domain__c = 'fake_domain';
        insert cg;
        GRP_CC_Chain__c ch = new GRP_CC_Chain__c();
        ch.Name='Ch test';
        ch.GRP_CC_Group__c = cg.Id;
        insert ch;
        CORE_Country__c country = new CORE_Country__c();
        country.name = 'TestFrance';
        country.CORE_Region__c = r.Id;
        insert country;        
        GRP_CC_ChainAccount__c ca = new GRP_CC_ChainAccount__c();
        ca.GRP_CC_Chain__c=ch.Id;
        ca.GRP_CC_ChainAccountResponsible__c = 'test@test.fr';
        ca.GRP_CC_Region__c = r.Id;
        ca.GRP_CC_Country__c=country.Id;
        insert ca;
        
        GRP_CC_Contract__c cont = new GRP_CC_Contract__c();
        cont.GRP_CC_Start_Date__c = date.today()-10;
        cont.GRP_CC_End_Date__c = date.today()+10;
        cont.GRP_CC_Category__c='Champagne';
        cont.Days_to_1st_Reminder_Chain_Acct_Resp__c = 10;
        cont.Days_to_2nd_Reminder_Chain_Acct_Resp__c = 20;
        cont.GRP_CC_Cycle__c = 1;
        insert cont;

        GRP_CC_Collect__c coll = new GRP_CC_Collect__c();
        coll.GRP_CC_ChainAccount__c = ca.Id;
        coll.GRP_CC_Contract__c = cont.Id;
        coll.GRP_CC_PeriodEnd__c = date.today()+5;
        coll.GRP_CC_PeriodStart__c = date.today()-5;
        coll.GRP_CC_Status__c = 'New';
        coll.GRP_CC_State__c = 'Processing';
        coll.GRP_CC_Primary_spirit_suppliers_1__c = 'Supplier 1';
        coll.GRP_CC_Primary_spirit_suppliers_2__c = 'Supplier 2';
        coll.GRP_CC_Primary_spirit_suppliers_3__c = 'Supplier 3';
        coll.GRP_CC_Full_collect_infos__c = 'aJIL00000004CMqOAM aJLL00000000001 2018-01-15 2018-06-15';
        insert coll;
        
        GRP_CC_CollectBQS__c itemBQS1 = new GRP_CC_CollectBQS__c();
        itemBQS1.GRP_CC_BrandQualitySize__c=bqs.Id;
        itemBQS1.GRP_CC_Quantity__c=2;
        itemBQS1.GRP_CC_Collect__c = coll.Id;
        insert itemBQS1;
        
        GRP_CC_CollectBQ__c itemBQ = new GRP_CC_CollectBQ__c();
        itemBQ.GRP_CC_BrandQuality__c=bq.Id;
        //itemBQ.GRP_CC_isBackBar__c=true;
        itemBQ.GRP_CC_isPouring__c=false;
        itemBQ.GRP_CC_isOnMenu__c=true;
        itemBQ.GRP_CC_isPremium__c=false;
        itemBQ.GRP_CC_IsRoomsMinibar__c=false;
        itemBQ.GRP_CC_IsOptionalAdditions__c=false;
        itemBQ.GRP_CC_IsMeetingsEvents__c=false;
		//itemBQ.GRP_CC_isSuperPremium__c=false;
        itemBQ.GRP_CC_Collect__c = coll.Id;
        insert itemBQ;
        
        return ca.Id;
    }
    
    static testMethod void testDoGet(){
 
     RestRequest req = new RestRequest(); 
     RestResponse res = new RestResponse();    

     String chainaccount = createGetTestRecords();
        
     String EncodeUrl = EncodingUtil.urlDecode('/services/apexrest/ChainAccount/'+chainaccount+'/Collect', 'UTF-8');
     req.requestURI = EncodeUrl; 
     req.httpMethod = 'GET';
    
     RestContext.request = req;
     RestContext.response = res; 
    
     GRP_CC_REST_CollectServices.GetCollectResponseWrapper results1 = GRP_CC_REST_CollectServices.doGet();
     System.assertEquals('Success', results1.status);
        
     req.addParameter('PeriodStart', '2015-01-01');
     GRP_CC_REST_CollectServices.GetCollectResponseWrapper results2 = GRP_CC_REST_CollectServices.doGet();
     System.assertEquals('Success', results2.status);
        
     req.addParameter('PeriodEnd', '2025-01-01');
     GRP_CC_REST_CollectServices.GetCollectResponseWrapper results3 = GRP_CC_REST_CollectServices.doGet();
     System.assertEquals('Success', results3.status);

     req.addParameter('Status', 'New');
     GRP_CC_REST_CollectServices.GetCollectResponseWrapper results4 = GRP_CC_REST_CollectServices.doGet();
     System.assertEquals('Success', results4.status);

     req.addParameter('State', 'New');
     GRP_CC_REST_CollectServices.GetCollectResponseWrapper results5 = GRP_CC_REST_CollectServices.doGet();
     System.assertEquals('Success', results5.status);

     EncodeUrl = EncodingUtil.urlDecode('/services/apexrest/ChainAccount/1234/Collect', 'UTF-8');
     req.requestURI = EncodeUrl; 
     GRP_CC_REST_CollectServices.GetCollectResponseWrapper results6 = GRP_CC_REST_CollectServices.doGet();
     System.assertEquals('Error', results6.status);

     EncodeUrl = EncodingUtil.urlDecode('/services/apexrest/ChainAccount//Collect', 'UTF-8');
     req.requestURI = EncodeUrl; 
     GRP_CC_REST_CollectServices.GetCollectResponseWrapper results7 = GRP_CC_REST_CollectServices.doGet();
     System.assertEquals('Error', results7.status);

}   
    
    
    static String createPostTestRecords(){
        
        CORE_Brand__c brand = new CORE_Brand__c();
        brand.Name='Brand Test';
        insert brand;
        CORE_BrandQuality__c bq = new CORE_BrandQuality__c();
        bq.Name='Bq Test';
        bq.CORE_Brand__c=brand.Id;
        insert bq;
        CORE_Size__c s = new CORE_Size__c();
        s.CORE_Value__c=3;
        insert s;
        CORE_BrandQualitySize__c bqs = new CORE_BrandQualitySize__c();
        bqs.Name='Bqs Test';
        bqs.CORE_Size__c=s.Id;
        bqs.CORE_BrandQuality__c=bq.Id;
        insert bqs;
        
        CORE_Region__c r = new CORE_Region__c();
        r.Name = 'Region test';
        insert r;
        GRP_CC_Group__c cg = new GRP_CC_Group__c();
        cg.GRP_CC_GroupeResponsible__c = 'test@pernod-ricard.com';
        cg.GRP_CC_Domain__c = 'fake_domain';
        insert cg;
        
        GRP_CC_Chain__c ch = new GRP_CC_Chain__c();
        ch.Name='Ch test';
        ch.GRP_CC_Group__c = cg.Id;
        insert ch;
        CORE_Country__c country = new CORE_Country__c();
        country.name = 'TestFrance';
        country.CORE_Region__c = r.Id;
        insert country;
        GRP_CC_ChainAccount__c ca = new GRP_CC_ChainAccount__c();
        ca.GRP_CC_Chain__c=ch.Id;
        ca.GRP_CC_ChainAccountResponsible__c = 'test@test.fr';
        ca.GRP_CC_Region__c = r.Id;
        ca.GRP_CC_Country__c=country.Id;
        insert ca;
        
        GRP_CC_Contract__c cont = new GRP_CC_Contract__c();
        cont.GRP_CC_Start_Date__c = date.today()-10;
        cont.GRP_CC_End_Date__c = date.today()+10;
        cont.GRP_CC_Category__c='Champagne';
        cont.Days_to_1st_Reminder_Chain_Acct_Resp__c = 10;
        cont.Days_to_2nd_Reminder_Chain_Acct_Resp__c = 20;
        cont.GRP_CC_Cycle__c = 1;
        insert cont;
        
        return ca.Id;
    }
    
 
    static testMethod void testDoPost(){
    
        String caId = createPostTestRecords();
        GRP_CC_REST_CollectServices.RequestWrapper rqst = new GRP_CC_REST_CollectServices.RequestWrapper();
        GRP_CC_Contract__c cObj = [
            SELECT Id
            FROM GRP_CC_Contract__c
            LIMIT 1
            ];
        rqst.contract = cObj.Id;
        rqst.periodStart = '2015-01-01';
        rqst.periodEnd = '2015-06-30';
        rqst.Status = 'New';
        rqst.State = 'Processing';
        
        List<GRP_CC_CollectBQS__c> cbqs= new List<GRP_CC_CollectBQS__c>();
        GRP_CC_CollectBQS__c itemBQS1 = new GRP_CC_CollectBQS__c();
        List<CORE_BrandQualitySize__c> bqsid = [
            SELECT Id
            FROM CORE_BrandQualitySize__c
        ];
        itemBQS1.GRP_CC_BrandQualitySize__c = bqsid[0].Id;
        itemBQS1.GRP_CC_Quantity__c=10;
        cbqs.add(itemBQS1);

        List<GRP_CC_CollectBQ__c> cbq= new List<GRP_CC_CollectBQ__c>();
        GRP_CC_CollectBQ__c itemBQ = new GRP_CC_CollectBQ__c();
        List<CORE_BrandQuality__c> bqid = [
            SELECT Id
            FROM CORE_BrandQuality__c
        ];
        itemBQ.GRP_CC_BrandQuality__c = bqid[0].Id;
        //itemBQ.GRP_CC_isBackBar__c=true;
        itemBQ.GRP_CC_isPouring__c=false;
        itemBQ.GRP_CC_isOnMenu__c=true;
        itemBQ.GRP_CC_isPremium__c=false;
        itemBQ.GRP_CC_IsRoomsMinibar__c=false;
        itemBQ.GRP_CC_IsOptionalAdditions__c=false;
        itemBQ.GRP_CC_IsMeetingsEvents__c=false;
		//itemBQ.GRP_CC_isSuperPremium__c=false;
        cbq.add(itemBQ);
     
        rqst.collBQSList=cbqs;
        rqst.collBQList=cbq;  
  
        String JsonMsg=JSON.serialize(rqst);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        String EncodeUrl = EncodingUtil.urlDecode('/services/apexrest/ChainAccount/'+caId+'/Collect','UTF-8');
        req.requestURI = EncodeUrl;  
        req.httpMethod = 'POST'; 
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
         
        GRP_CC_REST_CollectServices.PostCollectResponseWrapper results = GRP_CC_REST_CollectServices.doPost(rqst);  
        System.assertEquals('Success', results.status);
        
        EncodeUrl = EncodingUtil.urlDecode('/services/apexrest/ChainAccount/1234/Collect','UTF-8');
        req.requestURI = EncodeUrl;  
        GRP_CC_REST_CollectServices.PostCollectResponseWrapper results2 = GRP_CC_REST_CollectServices.doPost(rqst); 
        System.assertEquals('Error', results2.status);

    }

        
    static testMethod void testDoPatch(){
    
        String caId = createGetTestRecords();
        List<GRP_CC_Collect__c> cList = [SELECT Id, Name FROM GRP_CC_Collect__c];
        
        GRP_CC_Contract__c cont = new GRP_CC_Contract__c();
        cont.GRP_CC_Start_Date__c = date.today()-10;
        cont.GRP_CC_End_Date__c = date.today()+10;
        cont.GRP_CC_Category__c='Champagne';
        cont.Days_to_1st_Reminder_Chain_Acct_Resp__c = 10;
        cont.Days_to_2nd_Reminder_Chain_Acct_Resp__c = 20;
        cont.GRP_CC_Cycle__c = 1;
        insert cont;
        
        GRP_CC_Collect__c coll = new GRP_CC_Collect__c();
        coll.GRP_CC_ChainAccount__c = caId;
        coll.GRP_CC_PeriodEnd__c = date.today()+5;
        coll.GRP_CC_PeriodStart__c = date.today()-5;
        coll.GRP_CC_Status__c = 'New';
        coll.GRP_CC_State__c = 'Processing';
        coll.GRP_CC_Contract__c = cont.Id;
        insert coll;
        
        GRP_CC_REST_CollectServices.PatchRequestWrapper rqst = new GRP_CC_REST_CollectServices.PatchRequestWrapper();
        rqst.Status = 'Approved';
        rqst.State = 'Closed';
         
        String JsonMsg=JSON.serialize(rqst);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        String EncodeUrl = EncodingUtil.urlDecode('/services/apexrest/ChainAccount/'+caId+'/Collect/'+coll.Id,'UTF-8');
        req.requestURI = EncodeUrl;  
        req.httpMethod = 'PATCH'; 
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;
         
        GRP_CC_REST_CollectServices.PatchCollectResponseWrapper results = GRP_CC_REST_CollectServices.doPatch(rqst);    
        System.assertEquals('Success', results.status);
        
        
        GRP_CC_REST_CollectServices.PatchRequestWrapper rqst2 = new GRP_CC_REST_CollectServices.PatchRequestWrapper();
        List<GRP_CC_CollectBQ__c> cbq= new List<GRP_CC_CollectBQ__c>();
        GRP_CC_CollectBQ__c itemBQ = new GRP_CC_CollectBQ__c();
        List<CORE_BrandQuality__c> bqid = [
            SELECT Id
            FROM CORE_BrandQuality__c
        ];
        itemBQ.GRP_CC_BrandQuality__c = bqid[0].Id;
        //itemBQ.GRP_CC_isBackBar__c=true;
        itemBQ.GRP_CC_isPouring__c=false;
        itemBQ.GRP_CC_isOnMenu__c=true;
        itemBQ.GRP_CC_isPremium__c=false;
        itemBQ.GRP_CC_IsRoomsMinibar__c=false;
        itemBQ.GRP_CC_IsOptionalAdditions__c=false;
        itemBQ.GRP_CC_IsMeetingsEvents__c=false;
		//itemBQ.GRP_CC_isSuperPremium__c=false;
        cbq.add(itemBQ);
     
        rqst2.collBQList=cbq;  

         
        String JsonMsg2=JSON.serialize(rqst2);
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse(); 
        String EncodeUrl2 = EncodingUtil.urlDecode('/services/apexrest/ChainAccount/'+caId+'/Collect/'+cList[0].Id,'UTF-8');
        req2.requestURI = EncodeUrl2;  
        req2.httpMethod = 'PATCH'; 
        req.requestBody = Blob.valueof(JsonMsg2);
        RestContext.request = req2;
        RestContext.response = res2;
         
        GRP_CC_REST_CollectServices.PatchCollectResponseWrapper results2 = GRP_CC_REST_CollectServices.doPatch(rqst2);
    
        System.assertEquals('Success', results2.status);

    }

}