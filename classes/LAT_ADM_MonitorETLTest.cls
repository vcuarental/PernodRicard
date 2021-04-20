@isTest
private class LAT_ADM_MonitorETLTest {
	
	@isTest static void testGetKey() {
		LAT_ADM_MonitorETL m = new LAT_ADM_MonitorETL();
		System.assertEquals('1-Product2', m.getKey('1', m.PRODUCTS));
	}
	

	@isTest static void testDoMonitor() {
		setUp();

		LAT_ADM_MonitorETL m = new LAT_ADM_MonitorETL();
		Map<String, LAT_ADM_MonitorETL.LoadInfo> data = m.doMonitor();

		// test with BR
		System.assertEquals(LAT_ADM_MonitorETL.WarningLevel.OK, data.get('1-UDC__c').getStatus());
		System.assertEquals(LAT_ADM_MonitorETL.WarningLevel.OK, data.get('1-Titulos__c').getStatus());
		System.assertEquals(LAT_ADM_MonitorETL.WarningLevel.CRITICAL, data.get('1-Product2').getStatus());
		System.assertEquals(LAT_ADM_MonitorETL.WarningLevel.CRITICAL, data.get('1-LAT_Account_product_payment__c').getStatus());
		System.assertEquals(null, data.get('1-LAT_Account_product_payment__c').getLastDate());

		// TODO: Test Warning levels when LastModifiedDate can be modified in SFDC
	}

	@isTest static void testMonitorETLEmail() {
		setUp();

		LAT_ADM_MonitorETLEmail em = new LAT_ADM_MonitorETLEmail();
		em.sendStatusEmail();
	}

	@isTest static void testMonitorETLSchedule() {
		setUp();

		LAT_ADM_MonitorETLSchedule em = new LAT_ADM_MonitorETLSchedule();
		em.execute(null);
	}

	public static void setUp() {
		// UDC for BR
		UDC__c udcBr = new UDC__c(
			RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard'),
			CodProd__c = '01',
			CodUs__c = '01',
			CodDefUsuario__c = 'C1',
			Internal_Id__c = '1-C1-01-01');
		insert udcBr;

		// An Account for BR
		Account accBr = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
		insert accBr;

		// Create a Titulos__c for BR
		Titulos__c titulo = new Titulos__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'BRA_Standard'),
            NetSRReceipts_AR__c = 200,
            Internal_id_pk__c = 'TEST',
            Cliente__c = accBr.id,
            codigoCia__c = 'TEST',
            dataEmissao__c = date.today(),
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            numeroDocumento__c = 1,
            parcela__c = 'T',
            valorOriginalTitulo__c = 10,
            valorSaldo__c = 10
        );
        insert titulo;


        // Insert an email to deliver
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
        	Name = 'MONITOR_ETL_RECEIPT',
        	LAT_Value__c = 'diego.salido@pernod-ricard.com');
        insert cfg;
	}

}