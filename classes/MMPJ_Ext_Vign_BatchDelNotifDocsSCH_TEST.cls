@isTest
private class MMPJ_Ext_Vign_BatchDelNotifDocsSCH_TEST {
    
    @isTest static void MMPJ_Ext_Vign_BatchDelNotifDocsSCH_TEST () {
        test.starttest();
        
        MMPJ_Ext_Vign_BatchDelNotifDocsSCH sco = new MMPJ_Ext_Vign_BatchDelNotifDocsSCH();        
        String sch = '0 0 23 * * ?';        
        system.schedule('Batch', sch, sco);
        
        test.stopTest();
    }
}