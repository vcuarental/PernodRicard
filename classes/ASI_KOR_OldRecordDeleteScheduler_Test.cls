@isTest
public class ASI_KOR_OldRecordDeleteScheduler_Test{

  public static testMethod void test_main(){
    ASI_KOR_CustomSettingGenerator.initOldRecordDeletion();
    ASI_KOR_AccountGenerator acctGen = new ASI_KOR_AccountGenerator();
    Account ws = acctGen.generateAccount(ASI_KOR_AccountGenerator.RT_WS);
    insert ws;
    
    Test.startTest();
    
    String jobId = System.schedule('test_ASI_KOR_OldRecordDeleteScheduler', '0 0 1 * * ?', new ASI_KOR_OldRecordDeleteScheduler());
    
    Test.stopTest();
  }
}