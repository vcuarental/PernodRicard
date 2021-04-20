@IsTest
private class LAT_CTY_B2B_PendingFiscalNotesCont_Test {
    private static String MINIMUM_PRICE = '45.0';
    @testSetup
    private static void setupTest(){
        
    }
    
    @IsTest
    private static void getMinimunPriceTest() {
        Double monto = LAT_CTY_B2B_PendingFiscalNotesCont.getMinimunPrice();
        System.assertEquals(0, monto);
   
        System.assertEquals('OK', LAT_CTY_B2B_PendingFiscalNotesCont.updateMinimunPrice(Double.valueOf(MINIMUM_PRICE))); 

        monto = LAT_CTY_B2B_PendingFiscalNotesCont.getMinimunPrice();
        System.assertEquals(Double.valueOf(MINIMUM_PRICE), monto);
    }

    @IsTest
    private static void getChartBlockedTest() {
        Boolean boolChartIsBlocked = null;
        List<LAT_CTY_B2B_Settings__c>  lstBlocks = null;
        DateTime datFrom = null;
        DateTime datTo = null;

        boolChartIsBlocked = LAT_CTY_B2B_PendingFiscalNotesCont.getChartBlocked();
        System.assertEquals(false,boolChartIsBlocked);

        lstBlocks = LAT_CTY_B2B_PendingFiscalNotesCont.listBlocks(null, null, null);
        System.assertEquals(0,lstBlocks.size());

        datFrom = DateTime.now().addDays(7);
        datTo = datFrom.addDays(7);

        LAT_CTY_B2B_PendingFiscalNotesCont.scheduleBlock(datFrom, datTo, 'test comments');

        boolChartIsBlocked = LAT_CTY_B2B_PendingFiscalNotesCont.getChartBlocked();
        System.assertEquals(false,boolChartIsBlocked);

        lstBlocks = LAT_CTY_B2B_PendingFiscalNotesCont.listBlocks(null, null, null);
        System.assertEquals(1,lstBlocks.size());

        datFrom = DateTime.now().addDays(-1);
        datTo = datFrom.addDays(7);


        lstBlocks = LAT_CTY_B2B_PendingFiscalNotesCont.listBlocks(null, null, null);
        System.assertEquals(1,lstBlocks.size());

        LAT_CTY_B2B_PendingFiscalNotesCont.bloquearCarrito('block');

    }

}