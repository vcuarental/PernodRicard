@isTest
private class MMPJ_XRM_CompteContratBatchSchedule_Test {
    
    @isTest static void testMethod_batch_CompteContrat () {
        test.starttest();
        
        MMPJ_XRM_CompteContrat_BatchSchedule sco = new MMPJ_XRM_CompteContrat_BatchSchedule();        
        String sch = '0 0 23 * * ?';        
        system.schedule('Batch', sch, sco);
        
        test.stopTest();
    }
}