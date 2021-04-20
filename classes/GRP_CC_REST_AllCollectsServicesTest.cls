@isTest

private class GRP_CC_REST_AllCollectsServicesTest {

    static void createGetTestRecords(){  
                
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
        ca.GRP_CC_Chain__c = ch.Id;
        ca.GRP_CC_Region__c = r.Id;
        ca.GRP_CC_ChainAccountResponsible__c = 'test@pernod-ricard.com';
        ca.GRP_CC_Country__c = country.Id;
        ca.GRP_CC_Active_Chain_Account__c = true;
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
        coll.GRP_CC_Primary_spirit_suppliers_1__c = 'Supplier 1';
        coll.GRP_CC_Primary_spirit_suppliers_2__c = 'Supplier 2';
        coll.GRP_CC_Primary_spirit_suppliers_3__c = 'Supplier 3';
        coll.GRP_CC_Full_collect_infos__c = 'aJIL00000004CMqOAM aJLL00000000001 2018-01-15 2018-06-15';
        coll.GRP_CC_State__c = 'Processing';
        insert coll;
        
        GRP_CC_ContractChain__c cc = new GRP_CC_ContractChain__c(); 
        //cc.Name = 'cc test';
        cc.GRP_CC_Chain__c=ch.Id;
        cc.GRP_CC_Contract__c = cont.Id;
        insert cc;
        
        GRP_CC_Contract_Regions_Link__c cr = new GRP_CC_Contract_Regions_Link__c();
        //cr.Name = 'cr test';
        cr.GRP_CC_Region__c = r.Id;
        cr.GRP_CC_Contract__c = cont.Id;
        insert cr;
    }
    
    static testMethod void testDoGet() {
        
     RestRequest req = new RestRequest(); 
     RestResponse res = new RestResponse();    
     createGetTestRecords();
        
     String EncodeUrl = EncodingUtil.urlDecode('/services/apexrest/Collects/', 'UTF-8');
     req.requestURI = EncodeUrl; 
     
     RestContext.request = req;
     RestContext.response = res; 
    
     GRP_CC_REST_AllCollectsServices.GetCollectResponseWrapper results = GRP_CC_REST_AllCollectsServices.doGet();
     System.assertEquals('Success', results.status);
     
    }
}