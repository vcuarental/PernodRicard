@isTest
private class ASI_KOR_AccountTriggerTest {
	
	private static ASI_KOR_AccountGenerator acctGen = new ASI_KOR_AccountGenerator();
	private static String RT_WS = ASI_KOR_AccountGenerator.RT_WS;
	private static String RT_VENUE = ASI_KOR_AccountGenerator.RT_Venue;
	
    static testMethod void test_AccountAddressHandler() {
        Account ws = acctGen.generateAccount(RT_WS);
        ws.ASI_KOR_Wholesaler_Addr_Building__c = 'Hong Kong Space Museum';
        ws.ASI_KOR_Addr_Street__c = '10 Salisbury Rd';
        ws.ASI_KOR_Addr_City__c = 'Hong Kong';
        ws.ASI_KOR_Addr_Province__c = 'Hong Kong';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ASI_KOR_GoogleAddressHttpMock());
        
        insert ws;
        
        ws.ASI_KOR_Wholesaler_Addr_Building__c = 'Hong Kong Space Museum 2';
        
        update ws;
        
        Test.stopTest();
        
        ws = [SELECT Id, ASI_KOR_Sys_Primary_Latitude__c, ASI_KOR_Sys_Primary_Longtitude__c FROM Account WHERE Id = :ws.Id];
        System.assertEquals(String.valueOf(ASI_KOR_GoogleAddressHttpMock.DEF_LAT), WS.ASI_KOR_Sys_Primary_Latitude__c);
        System.assertEquals(String.valueOf(ASI_KOR_GoogleAddressHttpMock.DEF_LNG), WS.ASI_KOR_Sys_Primary_Longtitude__c);
    }
}