@isTest//(SeeAllData=true)

public class GRP_CC_REST_ChainAccountServicesTest{

    static String createTestRecords(){
        
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
        GRP_CC_Contract_BQS_Link__c cbqs = new GRP_CC_Contract_BQS_Link__c();
        cbqs.GRP_CC_BrandQualitySize__c = bqs.Id;
        cbqs.GRP_CC_Contract__c = cont.Id;
        insert cbqs;
        GRP_CC_ContractChain__c cch = new GRP_CC_ContractChain__c();
        cch.GRP_CC_Chain__c = ch.Id;
        cch.GRP_CC_Contract__c = cont.Id;
        insert cch;
        GRP_CC_Contract_Regions_Link__c cr = new GRP_CC_Contract_Regions_Link__c();
        cr.GRP_CC_Contract__c = cont.Id;
        cr.GRP_CC_Region__c = r.Id;
        insert cr;
        
        return ca.Id;
    }
    
    static testMethod void testDoGet(){
 
     RestRequest req = new RestRequest(); 
     RestResponse res = new RestResponse();    

     String chainaccount = createTestRecords();
        
     String EncodeUrl = EncodingUtil.urlDecode('/services/apexrest/ChainAccount/'+chainaccount+'/Contract', 'UTF-8');
     req.requestURI = EncodeUrl; 
     req.addParameter('email', 'test@test.fr');
     req.httpMethod = 'GET';
    
     RestContext.request = req;
     RestContext.response = res; 
    
     GRP_CC_REST_ChainAccountServices.GetContractResponseWrapper results = GRP_CC_REST_ChainAccountServices.doGet();
     System.assertEquals('Success', results.status);

 }
}