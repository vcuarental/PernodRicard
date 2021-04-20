@isTest
public class LAT_CLIENTPOP_Test {
    
    @isTest static void executeEntregaTest() {
        Test.startTest();
        LAT_ClientPOP__c clientPop = clientPopCreator();
        Date a = clientPop.Delivered_Date__c;
        clientPop.Delivered_Date__c = DATE.today().addMonths(-2);
        update clientPop; 
        System.assertNotEquals(a,clientPop.Delivered_Date__c);
        Test.stopTest();
    }
    @isTest static void executeEntregaTestB() {
        Test.startTest();
        LAT_ClientPOP__c clientPop = clientPopCreator2();
        Date a = clientPop.Delivered_Date__c;
        clientPop.Delivered_Date__c = DATE.today().addMonths(-2);
        update clientPop; 
        System.assertNotEquals(a,clientPop.Delivered_Date__c);
        Test.stopTest();
    }
    
    @isTest static void coletaEvidenciaTestB() {
        Test.startTest();
        LAT_ClientPOP__c clientPop = clientPopCreator();
        update clientPop; 
        Test.stopTest();
    }

    @isTest static void coletaEvidenciaTest() {
        Test.startTest();
        LAT_ClientPOP__c clientPop = clientPopCreator2();
        update clientPop; 
        Test.stopTest();
    }

    @isTest static void automaticInventoryTest() {
        Test.startTest();
        LAT_ClientPOP__c clientPop = clientPopCreator();
        clientPop.Delivered_Date__c = Date.today().addMonths(-2);
        update clientPop;
        LAT_CLIENTPOP.automaticInventory();
        Test.stopTest();
    }

    @isTest static void automaticInventoryTestB() {
        Test.startTest();
        LAT_ClientPOP__c clientPop = clientPopCreator2();
        clientPop.Delivered_Date__c = Date.today().addMonths(-2);
        update clientPop;
        LAT_CLIENTPOP.automaticInventory();
        Test.stopTest();
    }

    @isTest static void  updateDetailsTest(){
        Test.startTest();
        LAT_ClientPOP__c clientPop = clientPopCreator();
        LAT_ClientPOP__c clientePopB = LAT_CLIENTPOP.updateDetails(clientPop);
        Test.stopTest();
    }

    @isTest static void  updateDetailsTestB(){
        Test.startTest();
        LAT_ClientPOP__c clientPop = clientPopCreator2();
        clientPop.Delivered__c = 0;
        LAT_ClientPOP__c clientePopB = LAT_CLIENTPOP.updateDetails(clientPop);
        Test.stopTest();
    }

    @isTest static void  testDelivered(){
        Test.startTest();
        LAT_ClientPOP__c clientPop = clientPopCreator2();
        clientPop.Delivered__c = 3;
        clientPop.Delivered_Date__c = Date.today();
        LAT_ClientPOP__c clientePopB = LAT_CLIENTPOP.updateDetails(clientPop);
        Test.stopTest();
    }

    @isTest static void constructorTest(){
        Test.startTest();
        LAT_CLIENTPOP clientePOP = new LAT_CLIENTPOP();
        Test.stopTest(); 
    }

    public static LAT_Produto_POP__c productoPOPCreator(){
        
        LAT_Produto_POP__c prod = new LAT_Produto_POP__c();
        prod.Sku__c = '12';
        prod.name = 'ABC';
        prod.Evidence__c = true;
        prod.Parent_Product__c = 'ABC';
        prod.Inventory__c = false;
        insert prod;
        return prod;
    }

    public static LAT_KAMPOP__c KamPOPCreator(){
        
        LAT_RegionalPOP__c reg = new LAT_RegionalPOP__c();
        reg.product__c = productoPOPCreator().id;
        reg.Amount__c = Integer.valueOf('5000');
        insert reg;
        LAT_KAMPOP__c kamPop = new LAT_KAMPOP__c();
        User manager = TestFactory.createUserWithProfile('manager', 'LAT_MX_System Administrator');
        insert manager;
        User a = TestFactory.createUserWithProfile('admin', 'LAT_MX_System Administrator');
        a.managerId  = manager.id;
        insert a;
        kamPop.KAM__c = UserInfo.getUserId();
        kamPop.Amount__c = Integer.valueOf('300');
        kamPop.RegionalPOP__c = reg.id;
        insert kamPop;
        return kamPOP;
    }

    public static LAT_KAMPOP__c KamPOPCreator2(){
        
        LAT_RegionalPOP__c reg = new LAT_RegionalPOP__c();
        reg.product__c = productoPOPCreator().id;
        reg.Amount__c = Integer.valueOf('5000');
        insert reg;
        LAT_KAMPOP__c kamPop = new LAT_KAMPOP__c();
        User manager = TestFactory.createUserWithProfile('manager', 'LAT_SystemAdministrator');
        insert manager;
        User a = TestFactory.createUserWithProfile('admin', 'LAT_SystemAdministrator');
        a.managerId  = manager.id;
        insert a;
        kamPop.KAM__c = UserInfo.getUserId();
        kamPop.Amount__c = Integer.valueOf('300');
        kamPop.RegionalPOP__c = reg.id;
        insert kamPop;
        return kamPOP;
    }

    public static Account accountCreator(){
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        return Acc;
    }

    public static LAT_ClientPOP__c clientPopCreator(){
        
        LAT_ClientPOP__c clientePop = new LAT_ClientPOP__c();
        LAT_KAMPOP__c kamPOP = KamPOPCreator();
        LAT_KAMPOP__c kamPOPT = [Select id,RegionalPOP__r.product__c from LAT_KAMPOP__c where id=: kamPOP.id];
        clientePop.Material_POP__c = kamPOPT.RegionalPOP__r.product__c;
        clientePop.LAT_KAMPOP__c = kamPOPT.id;
        clientePop.LAT_Planned__c = Integer.valueOf('200');
        clientePop.Delivered__c = Integer.valueOf('200');
        clientePOP.Delivered_Date__c = null;
        clientePOP.LAT_CLient__c = accountCreator().id;

        insert clientePop;
        return clientePop;
    }
    public static LAT_ClientPOP__c clientPopCreator2(){
        
        LAT_ClientPOP__c clientePop = new LAT_ClientPOP__c();
        LAT_KAMPOP__c kamPOP = KamPOPCreator2();
        LAT_KAMPOP__c kamPOPT = [Select id,RegionalPOP__r.product__c from LAT_KAMPOP__c where id=: kamPOP.id];
        clientePop.Material_POP__c = kamPOPT.RegionalPOP__r.product__c;
        clientePop.LAT_KAMPOP__c = kamPOPT.id;
        clientePop.LAT_Planned__c = Integer.valueOf('200');
        clientePop.Planned_Date__c = Date.today().addMonths(-2);
        clientePop.Delivered__c = Integer.valueOf('200');
        clientePOP.Delivered_Date__c = Date.today();
        clientePOP.LAT_CLient__c = accountCreator().id;

        insert clientePop;
        return clientePop;
    }

    
    

}