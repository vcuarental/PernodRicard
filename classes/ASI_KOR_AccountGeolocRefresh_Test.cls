@isTest
public class ASI_KOR_AccountGeolocRefresh_Test{
     
    static testMethod void test_main() {
        ASI_KOR_AccountGenerator acctGen = new ASI_KOR_AccountGenerator();
        Account ws = acctGen.generateAccount(ASI_KOR_AccountGenerator.RT_WS);
        ws.ASI_KOR_SYS_NeedRefreshGeolocation__c = true;
        insert ws;
        
        Test.startTest();
        
        String jobId = System.schedule('test_ASI_KOR_AccountGeolocRefreshScheduler', '0 0 1 * * ?', new ASI_KOR_AccountGeolocRefreshScheduler());
        
        Test.stopTest();
    }
}