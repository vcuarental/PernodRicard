@isTest
private class MMPJ_XRM_BatchSuppAnnuContratSCH_TEST {
    Public static testmethod void MMPJ_XRM_BatchSuppAnnuContratSCH_TEST () {
        test.starttest();
        MMPJ_XRM_BatchSuppAnnuelleContratSCH sco = new MMPJ_XRM_BatchSuppAnnuelleContratSCH();        
        String sch = '0 0 23 * * ?';        
        system.schedule('Batch', sch, sco);
        MMPJ_XRM_BatchSuppAnnuelleContratSCH.createPlanif();
        test.stopTest();
    }
}