@isTest
public with sharing class MMPJ_XRM_SMSStatusBatchSchedule_Test {
    
    @isTest
    public static void testSchedule(){
        Test.startTest();
        MMPJ_XRM_SMSStatusBatchSchedule sch = new MMPJ_XRM_SMSStatusBatchSchedule();
        System.schedule('test', '20 30 8 10 2 ?', sch);
        Test.stopTest();
    }
}