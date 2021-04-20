@isTest
private class USA_BriSurvey_validation_trigger_TEST {
    static testMethod void testBriefSurveyCreate() {
    	List<USA_Survey__c> usList = new List<USA_Survey__c>();
        USA_Survey__c us1 = new USA_Survey__c(Name='TestSurvey',USA_MARKET__C='CA-N,CA-S,FL;');
        USA_Survey__c us2 = new USA_Survey__c(Name='TestSurvey',USA_MARKET__C='CA-N, CA-S,FL');
        USA_Survey__c us3 = new USA_Survey__c(Name='TestWhiteSpace',USA_MARKET__C='CA-N, ,CA-S,FL');
        USA_Survey__c us4 = new USA_Survey__c(Name='TestSurveNormal',USA_MARKET__C='CA-N,CA-S,FL');
        usList.add(us1);
        usList.add(us2);
        usList.add(us3);
        usList.add(us4);

        Test.startTest();
        Database.SaveResult[] result = Database.insert(usList,false);
        List<USA_Survey__c> uVerifyList = [select id,USA_MARKET__C from USA_Survey__c where Name ='TestSurvey'];
        Test.stopTest();
        system.debug(result[2].getErrors());//should be insert failed
        system.assertEquals(2,uVerifyList.size());
        system.assert(uVerifyList[0].USA_MARKET__C==uVerifyList[1].USA_MARKET__C);

    }
}