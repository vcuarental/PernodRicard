@isTest
private class LAT_ScheduleCTest {
	
	@isTest static void test_method_one() {
		LAT_ScheduleC__c sche = new LAT_ScheduleC__c();
        sche.ExternalId__c = 'AAA';
        sche.Key__c = 'BBB';
        sche.Active__c = true;
        sche.KeyBrand__c = theKeyBrand().id;
        insert sche;

        Test.StartTest();

        update sche;

        Test.StopTest();
	}
	
	 public static LAT_KeyBrand__c theKeyBrand(){
        LAT_KeyBrand__c kb = new LAT_KeyBrand__c();
        kb.ExternalId__c = 'AAA';
        kb.Key__c = 'BBB';
        kb.Active__c = true;
        insert kb;
        return kb;
    }
	
}