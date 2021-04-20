@isTest
private class USA_SurQuest_validation_trigger_TEST {
    static testMethod void testSurveyQuestionCreate() {
    	USA_Survey_Question__c sq1 = new USA_Survey_Question__c(name='testquestion',USA_POSSIBLE_VALUES__C='Top;Eye;Reach;Knee;Bottom;Lockbox');
    	USA_Survey_Question__c sq2 = new USA_Survey_Question__c(name='testquestion',USA_POSSIBLE_VALUES__C='Top;Eye;Reach;Knee; Bottom;Lockbox;');
    	USA_Survey_Question__c sq3 = new USA_Survey_Question__c(name='testquestion2',USA_POSSIBLE_VALUES__C='Top;Eye;Reach;;Bottom;Lockbox');
    	List<USA_Survey_Question__c> usaList = new List<USA_Survey_Question__c>();
    	usaList.add(sq1);
    	usaList.add(sq2);
    	usaList.add(sq3);

    	Test.startTest();
    	Database.SaveResult[] result = Database.insert(usaList,false);
    	Test.stopTest();
    	List<USA_Survey_Question__c> SearchResult = [Select id,USA_POSSIBLE_VALUES__C from USA_Survey_Question__c where name ='testquestion']; 
        system.assert(!result[2].isSuccess());
        system.assertEquals(2,SearchResult.size());
        system.debug(SearchResult[0].USA_POSSIBLE_VALUES__C+'--2:'+SearchResult[1].USA_POSSIBLE_VALUES__C);
        system.assert(SearchResult[0].USA_POSSIBLE_VALUES__C == SearchResult[1].USA_POSSIBLE_VALUES__C);
    }
}