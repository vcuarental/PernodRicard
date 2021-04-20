@isTest
private class USA_BriSet_validation_trigger_TEST {	
    static testMethod void testBriefCaseSettingCreate() {
    	List<USA_Briefcase_Admin_Settings__c> basList = new List<USA_Briefcase_Admin_Settings__c>();
        USA_Briefcase_Admin_Settings__c bas1 = new USA_Briefcase_Admin_Settings__c(name='testBriefCaseSetting',
        										MAP_REP_FILTERS__C='Aaron Gomez;005Dxxxxxxxxxxxxxxx,Abigail Bloomquist;Adam Berglund;005Dxxxxxxxxxxxxxxx',
        										GLOBAL_REPORT_IDS__C='00ODxxxxxxxxxxxx,00ODxxxxxxxxxxx,00ODxxxxxxxxxxx');

        USA_Briefcase_Admin_Settings__c bas2 = new USA_Briefcase_Admin_Settings__c(name='testBriefCaseSetting',
        										MAP_REP_FILTERS__C='Aaron Gomez;005Dxxxxxxxxxxxxxx,Abigail Bloomquist,Adam Berglund;005Dxxxxxxxxxxxxxx',
        										GLOBAL_REPORT_IDS__C='00ODxxxxxxxxxxx,00ODxxxxxxxxxx,00ODxxxxxxxxxx');
    	
    	USA_Briefcase_Admin_Settings__c bas3 = new USA_Briefcase_Admin_Settings__c(name='testBriefCaseSetting',
        										MAP_REP_FILTERS__C='005Dxxxxxxxxxxxxxx;005Dxxxxxxxxxxxxxx,Abigail Bloomquist;005Dxxxxxxxxxxxxxx,Adam Berglund;005Dxxxxxxxxxxxxxx ',
        										GLOBAL_REPORT_IDS__C='00ODxxxxxxxxxxx,00ODxxxxxxxxxx,00ODxxxxxxxxxx');

    	USA_Briefcase_Admin_Settings__c bas4 = new USA_Briefcase_Admin_Settings__c(name='testBriefCaseSetting',
        										MAP_REP_FILTERS__C='Aaron Gomez,Abigail Bloomquist;00Dxxxxxxxxxxxxxxx,Adam Berglund;005Dxxxxxxxxxxxxxx ',
        										GLOBAL_REPORT_IDS__C='00ODxxxxxxxxxxx,00ODxxxxxxxxxx,00Dxxxxxxxxxx');
    	basList.add(bas1);
    	basList.add(bas2);
    	basList.add(bas3);
    	basList.add(bas4);

    	Test.startTest();
    	Database.SaveResult[] result = Database.insert(basList,false);
    	Test.stopTest();
    	System.assert(!result[0].isSuccess());
    	System.assert(!result[1].isSuccess());
    }
}