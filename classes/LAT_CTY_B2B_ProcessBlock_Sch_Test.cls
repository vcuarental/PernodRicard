@IsTest
private class LAT_CTY_B2B_ProcessBlock_Sch_Test {
    @IsTest
    private static void processBlockSchedulableTest() {
        Test.setMock(WebServiceMock.class, new LAT_CallOutMockTest());
        LAT_CTY_B2B_PendingFiscalNotesCont.OperationResult objResult = null;
        DateTime datFrom = null;
        DateTime datTo = null;
        String strComments = null;
		String srtCronJobName = null;
        datFrom = Datetime.now();
        datTo = datFrom.addDays(1);
        strComments = 'hola';

        Test.startTest();
        srtCronJobName = String.format('LAT_CTY_B2B_ProcessBlock_Schedulable_{0}', new String[] { datTo.format('yyyyMMddHHmm') } );

        System.assertEquals(false,LAT_CTY_B2B_PendingFiscalNotesCont.getChartBlocked() );
        System.assertEquals(0,LAT_CTY_B2B_PendingFiscalNotesCont.listBlocks(null, null, null).size() );
        System.assertEquals(0, [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :srtCronJobName].size());

        objResult = LAT_CTY_B2B_PendingFiscalNotesCont.scheduleBlock(datFrom, datTo, strComments);

        System.assertEquals(0, objResult.Code);
        System.assertEquals(true,LAT_CTY_B2B_PendingFiscalNotesCont.getChartBlocked() );
        System.assertEquals(1,LAT_CTY_B2B_PendingFiscalNotesCont.listBlocks(null, null, null).size() );

        //despues de bloquear el carrito, debiera crearse un schedulable para testear que jde esta activo al finalizar el bloqueo
        System.assertEquals(1, [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :srtCronJobName].size());

        objResult = LAT_CTY_B2B_PendingFiscalNotesCont.updateStatus(objResult.Id, false);
        System.assertEquals(0, objResult.Code);
        System.assertEquals(false,LAT_CTY_B2B_PendingFiscalNotesCont.getChartBlocked() );
        System.assertEquals(1,LAT_CTY_B2B_PendingFiscalNotesCont.listBlocks(null, null, null).size() );    
        
        Test.stopTest();        
    }    
    
    @IsTest
    private static void processBlockSchedulableOKTest() {
        Test.setMock(WebServiceMock.class, new LAT_CallOutMockTest());
        LAT_CTY_B2B_PendingFiscalNotesCont.OperationResult objResult = null;
        DateTime datFrom = null;
        DateTime datTo = null;
        String strComments = null;
		String srtCronJobName = null;
        datFrom = Datetime.now();
        datTo = datFrom.addDays(1);
        strComments = 'hola';

        Test.startTest();
        srtCronJobName = String.format('LAT_CTY_B2B_ProcessBlock_Schedulable_{0}', new String[] { datTo.format('yyyyMMddHHmm') } );

        System.assertEquals(false,LAT_CTY_B2B_PendingFiscalNotesCont.getChartBlocked() );
        System.assertEquals(0,LAT_CTY_B2B_PendingFiscalNotesCont.listBlocks(null, null, null).size() );
        System.assertEquals(0, [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :srtCronJobName].size());

        objResult = LAT_CTY_B2B_PendingFiscalNotesCont.scheduleBlock(datFrom, datTo, strComments);

        System.assertEquals(0, objResult.Code);
        System.assertEquals(true,LAT_CTY_B2B_PendingFiscalNotesCont.getChartBlocked() );
        System.assertEquals(1,LAT_CTY_B2B_PendingFiscalNotesCont.listBlocks(null, null, null).size() );
 		Test.stopTest();
        
        LAT_CTY_B2B_ProcessBlock_Schedulable.updateSiteStatus();                         
    }    
}