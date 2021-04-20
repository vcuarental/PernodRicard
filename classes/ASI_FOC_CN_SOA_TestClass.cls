@isTest
private class ASI_FOC_CN_SOA_TestClass {
    @isTest static void testCallout() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new ASI_FOC_CN_SOA_CallOutMock());

        // Call the method that invokes a callout
        ASI_FOC_Free_Goods_Request__c req = new ASI_FOC_Free_Goods_Request__c();
        req.ASI_FOC_Request_Status__c = 'Submitted';
        req.recordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Request_and_Items_Read_Only');
        insert req;

        req.ASI_FOC_Request_Status__c = 'Approved by Logistic';
        update req;

        ASI_SOA_Setting__c setting = new ASI_SOA_Setting__c(Name='ASI_FOC_CN_EnableSOAInterface', ASI_SOA_Enable__c=true, ASI_SOA_URL__c = 'http://test.com');
        insert setting;
		
		ASI_SOA_Setting__c setting2 = new ASI_SOA_Setting__c(Name='ASI_FOC_CN_Interface_URL', ASI_SOA_Enable__c=true, ASI_SOA_URL__c = 'http://test.com');
        insert setting2;
        
		ASI_FOC_CN_Invoke_SOA.invokeChinaFOCSOA(req.Id);

		ASI_FOC_CN_SOA_BSSVTypes.detail_element bssvDetail = new ASI_FOC_CN_SOA_BSSVTypes.detail_element();
		ASI_FOC_CN_SOA_BSSVTypes.OrderDetail_element bssvOrderDetail = new ASI_FOC_CN_SOA_BSSVTypes.OrderDetail_element();
		ASI_FOC_CN_SOA_BSSVTypes.header_element bssvHeaderElement = new ASI_FOC_CN_SOA_BSSVTypes.header_element();
		

		ASI_FOC_CN_SOA_WSSecurity.UsernameToken_element wsSecurityUserName = new ASI_FOC_CN_SOA_WSSecurity.UsernameToken_element();
		ASI_FOC_CN_SOA_WSSecurity.HeaderSecurityType wsSecurityType = new ASI_FOC_CN_SOA_WSSecurity.HeaderSecurityType();

		ASI_FOC_CN_SOA_OrderHeader.header_element headerElement = new ASI_FOC_CN_SOA_OrderHeader.header_element();
		ASI_FOC_CN_SOA_OrderHeader.OrderHeader_element orderHeaderElement = new ASI_FOC_CN_SOA_OrderHeader.OrderHeader_element();

		//Test coverage for callout mock
		ASI_FOC_CN_SOA_FOCIntegrationProcess.processResponse_element obj = new ASI_FOC_CN_SOA_FOCIntegrationProcess.processResponse_element();
		ASI_FOC_CN_SOA_FOCIntegrationProcess.process_element obj2 = new ASI_FOC_CN_SOA_FOCIntegrationProcess.process_element();
		ASI_FOC_CN_SOA_FOCIntegrationProcess.FOCIntegrationProcess_pt obj3 = new ASI_FOC_CN_SOA_FOCIntegrationProcess.FOCIntegrationProcess_pt();
		
		Map<String, Object> responseMap = new Map<String, Object>();
		responseMap.put('Test', obj);

		/*ASI_FOC_CN_SOA_CallOutMock mock = new ASI_FOC_CN_SOA_CallOutMock();
		mock.doInvoke(obj,
           obj,
           responseMap,
           'test',
           'test',
           'test',
           'test',
           'test',
           'test');*/
    }
	
	@isTest static void testRegeneration() {              
        // Call the method that invokes a callout
        ASI_FOC_Free_Goods_Request__c req = new ASI_FOC_Free_Goods_Request__c();
        req.ASI_FOC_Request_Status__c = 'Approved by Logistic';
        req.recordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Request_and_Items_Read_Only');
        insert req;

        ASI_SOA_Setting__c setting = new ASI_SOA_Setting__c(Name='ASI_FOC_CN_EnableSOAInterface', ASI_SOA_Enable__c=true, ASI_SOA_URL__c = 'http://test.com');
        insert setting;
		
		ASI_SOA_Setting__c setting2 = new ASI_SOA_Setting__c(Name='ASI_FOC_CN_Interface_URL', ASI_SOA_Enable__c=true, ASI_SOA_URL__c = 'http://test.com');
        insert setting2;
        
		ASI_FOC_Request_Item__c requestItem = new ASI_FOC_Request_Item__c();		
		
		ApexPages.StandardController stdController = new ApexPages.StandardController(requestItem);
		
		ASI_FOC_CN_SOA_RegenerateFOCCtrl ctrl = new ASI_FOC_CN_SOA_RegenerateFOCCtrl(stdController);
		
		requestItem.ASI_FOC_Request_Order__c = req.Id;
		
		ctrl.focItem = requestItem;
		PageReference pageRef = ctrl.submit();
		
		req.ASI_FOC_Request_Status__c = 'Draft';
		update req;
		
		pageRef = ctrl.submit();		
    }
}