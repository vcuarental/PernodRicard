/****************************************************
* Dev: Waldemar Mayo  		Consulting: Valuenet	*
****************************************************/

@isTest
public with sharing class LAT_DebugUtil_TEST {
	
	static testmethod void unitTest(){
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
        Name = 'ACCOUNT_NOTIFY_ERROR_MAIL',
 		LAT_Value__c = 'test@test.com');
 		insert cfg;
		BasicData();
		LAT_DebugUtil debugTest = new LAT_DebugUtil();
		debugTest.setOrigin('Test_Class');
		debugTest.addTitle('title');
		debugTest.addSubTitle('subTitle');
		debugTest.addData('label', 'textData');
		debugTest.addData('textData');
		debugTest.setResult('result');
		debugTest.insertDebug();
		debugTest.notifyAccountError('it is a test');
		
		debugTest.getDebugInfo();
		LAT_DebugUtil.clearAllDebugLogs();
		LAT_DebugUtil.insertDebug('origen', 'destino', 'error');
		try {
			Integer l = 1/0;
		} catch (Exception e) {
			LAT_DebugUtil.addException('prueba', e, 'result');
		}
		
	}

	static void BasicData() {
        // Insert an email to deliver
        LAT_Info__c info = new LAT_Info__c(
            Name = 'Settings',
            Auth_Password__c = 'Test1',
            Auth_User__c = 'Test1',
            Debug_Logs__c = false);
        insert info;
    }
	
}