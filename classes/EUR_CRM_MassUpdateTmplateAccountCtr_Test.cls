/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_MassUpdateTmplateAccountCtr Class.
  @Author:      IPC
  @History:     MAY.30.2014 - Created
*/
@isTest (SeeAllData=true)
private with sharing class EUR_CRM_MassUpdateTmplateAccountCtr_Test {
    
    public static void dataInsert1(){
    
    }
    
    static testMethod void testMassUpdate1(){
        dataInsert1();
        
        test.startTest();
            EUR_CRM_MassUpdateTmplateAccountCtr ctr = new EUR_CRM_MassUpdateTmplateAccountCtr();
            
            ctr.processBatchUpdate();
            ctr.getBatchJobs();
        test.stopTest();
    }
}