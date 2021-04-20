@isTest
private class MMPJ_XRM_BatchDeleteSocieteLies_S_Test {
    
    @isTest static void testMethod_batch_Delete () {
        test.starttest();
        
        MMPJ_XRM_BatchDeleteSocieteLies_Schedule sco = new MMPJ_XRM_BatchDeleteSocieteLies_Schedule();        
        String sch = '0 0 23 * * ?';        
        system.schedule('Batch', sch, sco);
        
        test.stopTest();
    }
}