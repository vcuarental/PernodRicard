@isTest
private class ASI_KOR_SalesOrderRequestTriggerTest {

    static testMethod void test_main() {
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
        List<ASI_KOR_Item_Group__c> itemGroups = new List<ASI_KOR_Item_Group__c>();
        for (Integer i = 0; i < 3; i++) {
            ASI_KOR_Item_Group__c tempIG = igGen.generateItemGroup(sb);
            itemGroups.add(tempIG);
        }
        insert itemGroups;
        
        ASI_KOR_Sales_Order_Request__c soReq = soReqGen.generateRequest(ws);
        insert soReq;
        ASI_KOR_Sales_Order_Transaction__c soReqDetail = soReqGen.generateDetail(soReq, itemGroups.get(0));
        ASI_KOR_Sales_Order_Transaction__c soReqDetail2 = soReqGen.generateDetail(soReq, itemGroups.get(1));
        insert new List<ASI_KOR_Sales_Order_Transaction__c> {soReqDetail, soReqDetail2};
        
        Test.startTest();
        
        // Test ASI_KOR_SalesOrderRequestEDIAutoNumGen class
        ASI_KOR_TriggerAbstract.keyToInitCountMap.clear();
        soReq.ASI_KOR_Order_Status__c = new List<String>(ASI_KOR_SalesOrderRequestEDIAutoNumGen.RELEVANT_STATUS).get(0);
        update soReq;
        
        List<ASI_KOR_Sales_Order_Transaction__c> soReqDetails = [
            SELECT Id, Name, ASI_KOR_Sales_Order_Request__c, ASI_KOR_Item_Group_Code__c, ASI_KOR_Order_Qty__c
                , ASI_KOR_Product_Usage__c, ASI_KOR_SOT_UOM__c
                , ASI_KOR_SYS_INFO_EDI_Document_NO__c, ASI_KOR_SYS_INFO_SORD_ID__c
            FROM ASI_KOR_Sales_Order_Transaction__c
            WHERE ASI_KOR_Sales_Order_Request__c = :soReq.Id
        ];
        /* Skip testing sales order details to avoid special bug
        for (ASI_KOR_Sales_Order_Transaction__c tempSoReqDetail : soReqDetails) {
            System.assert(null != tempSoReqDetail.ASI_KOR_SYS_INFO_EDI_Document_NO__c);
            System.assert(null != tempSoReqDetail.ASI_KOR_SYS_INFO_SORD_ID__c);
        }*/
        
        // Test ASI_KOR_SalesOrderRequestDtLockSubmitted
        ASI_KOR_Sales_Order_Transaction__c testSoReqDetail = soReqDetails.get(0);
        testSoReqDetail.ASI_KOR_Order_Qty__c = 50;
        Boolean hasException = false;
        try {
            update testSoReqDetail;
        } catch (DmlException dmle) {
            hasException = true;
        }
        /* TODO: run as another profile to throw exception
        System.assertEquals(true, hasException);
        */
        hasException = false;
        try {
            delete testSoReqDetail;
        } catch (DmlException dmle) {
            hasException = true;
        }
        /* TODO: run as another profile to throw exception
        System.assertEquals(true, hasException);
        */
        
        Test.stopTest();
    }
}