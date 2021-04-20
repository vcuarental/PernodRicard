@isTest
public class ASI_CRM_JP_AccountAddressBatch_Test {
	
    
    static testMethod void ASI_CRM_JP_AccountAddressBatch_Test() {
        User userA = ASI_CRM_JP_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_JP_ContractTrigger';
        update userA;
        
        System.runAs(userA){
            
            Test.startTest();
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
            ASI_CRM_JP_TestClassHelper.createRunningNumbers();
            //ASI_TH_CRM_OutletType__c outletType = ASI_CRM_JP_TestClassHelper.createOutletType('Test1');
            //ASI_CRM_Postal_Code__c postalCode = ASI_CRM_JP_TestClassHelper.createPostalCode('1234567');
            //ASI_CRM_AccountsAdditionalField__c customer = ASI_CRM_JP_TestClassHelper.createCustomer();
            ASI_TH_CRM_OutletType__c outletType = ASI_CRM_JP_TestClassHelper.createOutletType('Test0');
            ASI_CRM_Postal_Code__c postalCode = ASI_CRM_JP_TestClassHelper.createPostalCode('0000000');
            ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
            customer.Name='Test0';
            customer.RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_JP_On_Trade_Outlet');
            customer.ASI_TH_CRM_OutletType__c = outletType.Id;
            customer.ASI_CRM_PostalCode__c = postalCode.Name;
            customer.ASI_CRM_Allow_Create__c = true;
            insert customer;
			customer.ASI_CRM_PostalCode__c = '0600806';
            customer.ASI_CRM_JP_Town__c = '北海道札幌市中央区南6条西4丁目';
            customer.ASI_CRM_Building_Floor_Number__c = 'ｼﾞｬｽﾏｯｸ6番館ﾋﾞﾙ9F';
            
            update customer;
            
            
            Test.stopTest();
            
            
            
            
        }
    }
    
    public class HTTPMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            string jsonResBody = '{"results":[{"address_components":[{"long_name":"Muir Lane","short_name":"Muir Ln","types":["route"]},{"long_name":"Torrey Pines","short_name":"Torrey Pines","types":["neighborhood","political"]},{"long_name":"San Diego","short_name":"San Diego","types":["locality","political"]},{"long_name":"San Diego County","short_name":"San Diego County","types":["administrative_area_level_2","political"]},{"long_name":"California","short_name":"CA","types":["administrative_area_level_1","political"]},{"long_name":"United States","short_name":"US","types":["country","political"]},{"long_name":"92161","short_name":"92161","types":["postal_code"]}],"formatted_address":"Muir Ln, San Diego, CA 92161, USA","geometry":{"location":{"lat":32.8790299,"lng":-117.2413533},"location_type":"GEOMETRIC_CENTER","viewport":{"northeast":{"lat":32.8803788802915,"lng":-117.2400043197085},"southwest":{"lat":32.8776809197085,"lng":-117.2427022802915}}},"place_id":"ChIJV1aG1sAG3IAR6EsgRezpoa0","plus_code":{"compound_code":"VQH5+JF San Diego, California, United States","global_code":"8544VQH5+JF"},"types":["establishment","point_of_interest","school"]}],"status":"OK"}';
            res.setBody(jsonResBody);
            return res;
        }
    }
    
    
}