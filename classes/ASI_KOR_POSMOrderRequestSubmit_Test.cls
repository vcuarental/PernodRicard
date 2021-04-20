@isTest
public class ASI_KOR_POSMOrderRequestSubmit_Test{

public static testMethod void test_main() {
    String CHANGE_TO_STATUS = 'Requested';
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
    insert posmReq;
    ASI_KOR_POSM_Order_Detail__c posmReqDetail = posmReqGen.generateDetail(posmReq, posmPd);
    insert posmReqDetail;
    
    posmReq = [SELECT Id, Name, ASI_KOR_Request_Status__c FROM ASI_KOR_POSM_Order_Request__c WHERE Id = :posmReq.Id];
    
    ApexPages.StandardController stdCon = new ApexPages.StandardController(posmReq);
    
    Test.startTest();
    
    PageReference testPage = Page.ASI_KOR_POSMOrderRequestSubmit;
    Test.setCurrentPageReference(testPage);
    ASI_KOR_POSMOrderRequestSubmitController testCon = new ASI_KOR_POSMOrderRequestSubmitController(stdCon);
    
    PageReference redirectPage = testCon.submitPOSMOrderRequest();
    
    System.assertEquals('/' + posmReq.Id, redirectPage.getUrl());
    posmReq = [SELECT Id, Name, ASI_KOR_Request_Status__c FROM ASI_KOR_POSM_Order_Request__c WHERE Id = :posmReq.Id];
    System.assertEquals(CHANGE_TO_STATUS, posmReq.ASI_KOR_Request_Status__c);
    
    Test.stopTest();
  }

}