@isTest
private class LAT_MX_Planejamento_Scheduler_Test {
	
	private static void init() {
		UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Name = '12 Dias MX - Test',
            Internal_Id__c = '12-123-CRM-PT',
            CodUs__c = 'PT',
            CodProd__c = 'CRM',
            CodDefUsuario__c = 'test'
        );
        insert udc;

		Account a = LAT_Account_TestFactory.getAccountBase('LAT_MX_ACC_OffTrade');
				
		a.CNPJ__c = 'LOZM701213E52'; 
		a.Payment_Condition__c = udc.id; 
		a.LAT_MX_AvailableCreditLimit__c = 100.00;
		a.Client_country_AN8__c =  '12-1234';
		insert a;
	}

	public static Boolean runBatchs(){
	    List<AsyncApexJob> listAsyncApexJob = [SELECT id FROM AsyncApexJob 
	                                                   WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')];
	        //se chequea el limite de Salesforce, si hay cupo disponible se ejecuta el batch, sino se vuelve a hacer el schedule            
	        if (listAsyncApexJob == null || listAsyncApexJob != null && listAsyncApexJob.size() < 5){
	          return true;
	        }
	        return false;
	}

	@isTest static void test_method_one() {
		init();
		Test.startTest();
		LAT_MX_Planejamento_Scheduler sh1 = new LAT_MX_Planejamento_Scheduler();
		String sch = '0 0 2 * * ?';
		System.schedule('Test Planejamento Schedule', sch, sh1);

		//LAT_MX_Planejamento_Batch planBatch = new LAT_MX_Planejamento_Batch();
    	//if(runBatchs())Database.executeBatch(planBatch, 10);

		Test.stopTest();
	}
	
}