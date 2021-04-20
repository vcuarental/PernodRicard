/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*/
@isTest
private class LAT_Client_POP_Trigger_Test {
    
    @isTest static void clientePopTriggerTest() {
        LAT_ClientPOP__c cliPop = clientPopCreator();
        update cliPop;
    }
    @isTest static void clientePopTriggerTestB() {
        LAT_ClientPOP__c cliPop = clientPopCreator2();
        update cliPop;
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
        LAT_KAMPOP__c kamPOPT = [Select id, RegionalPOP__r.product__c,RegionalPOP__r.product__r.sku__c from LAT_KAMPOP__c where id=: kamPOP.id];
        clientePop.Material_POP__c = kamPOPT.RegionalPOP__r.product__c;
        clientePop.LAT_KAMPOP__c = kamPOPT.id;
        clientePop.lat_client__c = accountCreator().id;
        clientePop.LAT_Planned__c = Integer.valueOf('200');
        clientePop.Delivered__c = Integer.valueOf('200');
        clientePOP.Delivered_Date__c = null;

        insert clientePop;
        return clientePop;
    }

    public static LAT_ClientPOP__c clientPopCreator2(){
        LAT_ClientPOP__c clientePop = new LAT_ClientPOP__c();
        LAT_KAMPOP__c kamPOP = KamPOPCreator2();
        LAT_KAMPOP__c kamPOPT = [Select id, RegionalPOP__r.product__c,RegionalPOP__r.product__r.sku__c from LAT_KAMPOP__c where id=: kamPOP.id];
        clientePop.Material_POP__c = kamPOPT.RegionalPOP__r.product__c;
        clientePop.LAT_KAMPOP__c = kamPOPT.id;
        clientePop.lat_client__c = accountCreator().id;
        clientePop.LAT_Planned__c = Integer.valueOf('200');
        clientePop.Delivered__c = Integer.valueOf('200');
        clientePOP.Delivered_Date__c = null;

        insert clientePop;
        return clientePop;
    }
    
}