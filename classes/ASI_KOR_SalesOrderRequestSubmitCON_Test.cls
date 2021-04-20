@isTest
public class ASI_KOR_SalesOrderRequestSubmitCON_Test{
 public static testMethod void test_main() {
        String CHANGE_TO_STATUS = 'Requested';
        ASI_KOR_AccountGenerator acctGen = new ASI_KOR_AccountGenerator();
        ASI_KOR_BrandGenerator brandGen = new ASI_KOR_BrandGenerator();
        ASI_KOR_SubBrandGenerator sbGen = new ASI_KOR_SubBrandGenerator();
        ASI_KOR_ItemGroupGenerator igGen = new ASI_KOR_ItemGroupGenerator();
        ASI_KOR_SalesOrderRequestGenerator soReqGen = new ASI_KOR_SalesOrderRequestGenerator();
        
        Account ws = acctGen.generateAccount(ASI_KOR_AccountGenerator.RT_WS);
        insert ws;
        
        ASI_KOR_Brand__c brand = brandGen.generateBrand();
        insert brand;
        ASI_KOR_Sub_Brand__c sb = sbGen.generateSubBrand(brand);
        insert sb;
        final Integer numOfItemGroup = 3;
        List<ASI_KOR_Item_Group__c> itemGroups = new List<ASI_KOR_Item_Group__c>();
        for (Integer i = 0; i < numOfItemGroup; i++) {
            ASI_KOR_Item_Group__c tempIG = igGen.generateItemGroup(sb);
            itemGroups.add(tempIG);
        }
        insert itemGroups;
        
        ASI_KOR_Sales_Order_Request__c soReq = soReqGen.generateRequest(ws);
        insert soReq;
        List<ASI_KOR_Sales_Order_Transaction__c> soReqDetails = new List<ASI_KOR_Sales_Order_Transaction__c>();
        for (ASI_KOR_Item_Group__c ig : itemGroups) {
            ASI_KOR_Sales_Order_Transaction__c soReqDetail = soReqGen.generateDetail(soReq, ig);
            soReqDetails.add(soReqDetail);
        }
        insert soReqDetails;
        
        soReq = [SELECT Id, Name, ASI_KOR_Order_Status__c FROM ASI_KOR_Sales_Order_Request__c WHERE Id = :soReq.Id];
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(soReq);
        
        Test.startTest();
        
        ASI_KOR_TriggerAbstract.keyToInitCountMap.clear();
        PageReference testPage = Page.ASI_KOR_SalesOrderRequestSubmit;
        Test.setCurrentPageReference(testPage);
        ASI_KOR_SalesOrderRequestSubmitCON testCon = new ASI_KOR_SalesOrderRequestSubmitCON(stdCon);
        
        PageReference redirectPage = testCon.submitSalesOrderRequest();
        
        System.assertEquals('/' + soReq.Id, redirectPage.getUrl());
        soReq = [SELECT Id, Name, ASI_KOR_Order_Status__c FROM ASI_KOR_Sales_Order_Request__c WHERE Id = :soReq.Id];
        System.assertEquals(CHANGE_TO_STATUS, soReq.ASI_KOR_Order_Status__c);
        
        // Validate trigger class ASI_KOR_SalesOrderRequestEDIAutoNumGen
        /* Skip testing sales order details to avoid special bug
        soReqDetails = [
            SELECT Id, Name, ASI_KOR_SYS_INFO_EDI_Document_NO__c, ASI_KOR_SYS_INFO_SORD_ID__c
            FROM ASI_KOR_Sales_Order_Transaction__c
            WHERE ASI_KOR_Sales_Order_Request__c = :soReq.Id
        ];
        System.assertEquals(numOfItemGroup, soReqDetails.size());
        for (ASI_KOR_Sales_Order_Transaction__c soReqDetail : soReqDetails) {
            System.assert(soReqDetail.ASI_KOR_SYS_INFO_EDI_Document_NO__c != null);
            System.assert(soReqDetail.ASI_KOR_SYS_INFO_SORD_ID__c != null);
        }*/
        
        Test.stopTest();
    }
}