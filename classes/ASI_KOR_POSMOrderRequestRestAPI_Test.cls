@isTest
public class ASI_KOR_POSMOrderRequestRestAPI_Test{

static testMethod void test_main() {
    ASI_KOR_AccountGenerator acctGen = new ASI_KOR_AccountGenerator();
    ASI_KOR_POSMProductGenerator posmPdGen = new ASI_KOR_POSMProductGenerator();
    ASI_KOR_POSMOrderRequestGenerator posmReqGen = new ASI_KOR_POSMOrderRequestGenerator();
    
    Account venue = acctGen.generateAccount(ASI_KOR_AccountGenerator.RT_Venue);
    insert venue;
    
    ASI_KOR_POSM_Product_Brand__c brand = posmPdGen.generateBasicBrand();
    insert brand;
    ASI_KOR_POSM_Product_Sub_Brand__c sb = posmPdGen.generateBasicSubBrand(brand);
    insert sb;
    ASI_KOR_POSM_Product__c posmPd = posmPdGen.generateProduct(sb);
    insert posmPd;
    
    ASI_KOR_POSM_Order_Request__c posmReq = posmReqGen.generateRequest(venue);
    ASI_KOR_POSM_Order_Detail__c posmReqDetail = posmReqGen.generateDetail(posmReq, posmPd);
    
    RestRequest req = new RestRequest();
    RestContext.request = req;
    req.httpMethod = 'POST';
    
    Test.startTest();
    
    Map<String, String> result = ASI_KOR_POSMOrderRequestRestAPI.submitChanges(posmReq, null, new List<ASI_KOR_POSM_Order_Detail__c> {posmReqDetail});
    
    Test.stopTest();
    
    System.assertEquals('true', result.get('success'));
    String posmReqId = result.get('id');
    List<ASI_KOR_POSM_Order_Request__c> posmReqs = [SELECT Id, (SELECT Id FROM ASI_KOR_POSM_Order_Details__r) FROM ASI_KOR_POSM_Order_Request__c WHERE Id = :posmReqId];
    System.assertEquals(1, posmReqs.size());
    System.assertEquals(1, posmReqs.get(0).ASI_KOR_POSM_Order_Details__r.size());
  }

}