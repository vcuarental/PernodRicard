/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/
@isTest (seeAllData=true)
private class LAT_ProcessesTaks_Test {
	private static Account a;
	private static LAT_Produto_POP__c pPop;
	private static LAT_KAMPOP__c kamPop;
	@isTest static void createTaskTest() {
		
		a = accountCreator();
		LAT_ClientPOP__c client1 = clientPopCreator();
		LAT_ClientPOP__c client2 = clientPopCreator();
		Test.startTest();
		User u = TestFactory.createUserWithProfile('admin', 'LAT_MX_System Administrator');
		u.username = 'test@code.coverage';
		insert u;
		String rec = Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction');
		Integer days = Integer.valueOf('3');
		Task t = LAT_ProcessesTaks.createTask(client1.id,u.id,'ABC','123',rec,days,'Coletar');
		upsert t;
		Task t2 = LAT_ProcessesTaks.createTask(client2.id,u.id,'ABC2','1232',rec,2,'Coletar');
		upsert t2;

		LAT_ProcessesTaks.checkClosedTasks(new List<Task>{t},new List<Task>{t2});
		Blob b = Blob.valueOf('Test Data');
        Attachment attach1 = new Attachment(
            ParentId = t.Id,
            Name = 'Form02-test',
            OwnerId = t.OwnerId,
            Body = b
        );  
          
        insert attach1;
		Blob b2 = Blob.valueOf('Test Data2');
        Attachment attach2 = new Attachment(
            ParentId = t2.Id,
            Name = 'Form03-test',
            OwnerId = t2.OwnerId,
            Body = b2
        );  
          
        insert attach2;
		LAT_ProcessesTaks.postEvidence(new List<String>{t.id,t2.Id});
		Test.stopTest();
	}

	@isTest static void createTaskTestB() {
		if (a==null) {
			a = accountCreator();
 		}
		User u = TestFactory.createUserWithProfile('admin', 'LAT_SystemAdministrator');
		insert u;
		String rec = Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction');
		Integer days = Integer.valueOf('3');
		Task t = LAT_ProcessesTaks.createTask(a.id,u.id,'ABC','123',rec,days,'Coletar');
	}
	
	@isTest static void constructorTest(){
		
		LAT_ProcessesTaks pt = new LAT_ProcessesTaks();
		LAT_FiscalYearHelper fh = new LAT_FiscalYearHelper();
		fh.getFiscalYearCode(Date.today());
	}
	
	@isTest static void isWeekendDayTest() {

		Date d = date.newInstance(2016, 1, 16);
		Boolean a2 = LAT_ProcessesTaks.isWeekendDay(d);
	}

	@isTest static void AddBusinessDaysTest(){

		Date d = Date.today();
		Integer days = Integer.ValueOf('3');
		Date d2 = LAT_ProcessesTaks.AddBusinessDays(d,days);
	}

	@isTest static void insertAndNotificateTest(){
		if (a == null) {
			a = accountCreator();
		}
		User u = TestFactory.createUserWithProfile('admin', 'LAT_MX_System Administrator');
		insert u;
		String rec = Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction');
		Integer days = Integer.valueOf('3');
		Task t = LAT_ProcessesTaks.createTask(a.id,u.id,'ABC','123',rec,days,'Coletar');
		List<Task> taskList = new List<Task>();
		taskList.add(t);
		LAT_ProcessesTaks.insertAndNotificate(taskList);
	}

	@isTest static void insertAndNotificateTestB(){
		if (a == null) {
			a = accountCreator();
		}
		User u = TestFactory.createUserWithProfile('admin', 'LAT_SystemAdministrator');
		insert u;
		String rec = Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction');
		Integer days = Integer.valueOf('3');
		Task t = LAT_ProcessesTaks.createTask(a.id,u.id,'ABC','123',rec,days,'Coletar');
		List<Task> taskList = new List<Task>();
		taskList.add(t);
		LAT_ProcessesTaks.insertAndNotificate(taskList);
	}

	public static Account accountCreator(){
  
      Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
  	  insert Acc;
  	  return Acc;
  }
  	public static LAT_ClientPOP__c clientPopCreator(){
        LAT_ClientPOP__c clientePop = new LAT_ClientPOP__c();
        kamPOP = KamPOPCreator();
        LAT_KAMPOP__c kamPOPT = [Select id, RegionalPOP__r.product__c,RegionalPOP__r.product__r.sku__c from LAT_KAMPOP__c where id=: kamPOP.id];
        clientePop.Material_POP__c = kamPOPT.RegionalPOP__r.product__c;
        clientePop.LAT_KAMPOP__c = kamPOPT.id;
        clientePop.lat_client__c = a.id;
        clientePop.LAT_Planned__c = Integer.valueOf('200');
        clientePop.Delivered__c = Integer.valueOf('200');
        clientePOP.Delivered_Date__c = null;

        insert clientePop;
        return clientePop;
    }
    public static LAT_KAMPOP__c KamPOPCreator(){
    	if (kamPop == null) {
	        LAT_RegionalPOP__c reg = new LAT_RegionalPOP__c();
	        reg.product__c = productoPOPCreator('ABC'+Datetime.now()).id;
	        reg.Amount__c = Integer.valueOf('5000');
	        insert reg;
	        kamPop = new LAT_KAMPOP__c();
	        User manager = TestFactory.createUserWithProfile('manager', 'LAT_MX_System Administrator');
	        insert manager;
	        User a1 = TestFactory.createUserWithProfile('admin', 'LAT_MX_System Administrator');
	        a1.managerId  = manager.id;
	        insert a1;
	        kamPop.KAM__c = UserInfo.getUserId();
	        kamPop.Amount__c = Integer.valueOf('300');
	        kamPop.RegionalPOP__c = reg.id;
	        insert kamPop;
	        
    	}
    	return kamPOP;

    }
  	public static LAT_Produto_POP__c productoPOPCreator(String nombre){
        if (pPop==null) {
	        LAT_Produto_POP__c prod = new LAT_Produto_POP__c();
	        prod.Sku__c = '12';
	        prod.name = nombre;
	        prod.Evidence__c = true;
	        prod.Parent_Product__c = 'ABC';
	        prod.Inventory__c = false;
	        insert prod;
	        pPop = prod;
        }

        return pPop;
    }
}