@isTest
public class ASI_CRM_MY_AccountAddressBatch_Test {
	
    
    static testMethod void ASI_CRM_MY_AccountAddressBatch_Test() {
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
         
        Group gp = [SELECT id FROM GROUP WHERE DeveloperName = 'ASI_CRM_MY_Offtake_Adjustment' LIMIT 1];
        
        List<GroupMember> GMlist = new List<GroupMember>();
        GroupMember GM = new GroupMember();
        GM.GroupId = gp.id;
        GM.UserOrGroupId = userA.Id;
        GMList.add(GM);
        insert GMList;
        
        System.runAs(userA){
            
            
            ASI_CRM_MY_TestClassHelper.createMYSetting();
            Test.setMock(HttpCalloutMock.class, new HTTPMockCallout());
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
			customer1.ASI_CRM_CN_Address__c = '418 Kwun Tong Rd, Kwun Tong';
            update customer1;
            
            Test.startTest();
            ApexPages.StandardController standardCtl = new ApexPages.StandardController(customer1);
            ApexPages.currentpage().getparameters().put('id', customer1.Id);
            ASI_CRM_MY_Map_Ctrl controller = new ASI_CRM_MY_Map_Ctrl(standardCtl);
            
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