/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*********************************************************************************/
@isTest
private class LAT_KAMPOP_Test { 

    @isTest static void kamNotificationTest(){
        LAT_KAMPOP__c KamPOP = KamPOPCreator();
    }

    @isTest static void kamNotificationTestB(){
        LAT_KAMPOP__c KamPOP = KamPOPCreator2();
    }
    @isTest static void shareRecordsTest(){
        
        LAT_KAMPOP__c KamPOP = KamPOPCreator();
        List<LAT_RegionalPOP__Share> regPopShare = [SELECT ID from LAT_RegionalPOP__Share where ParentId =: KamPOP.RegionalPOP__c];
    }
    @isTest static void shareRecordsTestB(){
        
        LAT_KAMPOP__c KamPOP = KamPOPCreator2();
        List<LAT_RegionalPOP__Share> regPopShare = [SELECT ID from LAT_RegionalPOP__Share where ParentId =: KamPOP.RegionalPOP__c];
    }

    @isTest static void checkKAMPOPTest(){
        
        LAT_KAMPOP__c KamPOP = KamPOPCreator();
    }

    @isTest static void checkKAMPOPTestB(){
        
        LAT_KAMPOP__c KamPOP = KamPOPCreator2();
    }
    @isTest static void runInventoryTest(){
        
        LAT_ClientPOP__c cli = clientPopCreator();      
        LAT_InventoryPOP__c inv = new LAT_InventoryPOP__c();
        inv.Client__c = cli.LAT_KAMPOP__r.KAM__c;
        insert inv;
        LAT_KAMPOP.runInventory();
    }

    @isTest static void runInventoryTestB(){
        
        LAT_ClientPOP__c cli = clientPopCreator2();      
        LAT_InventoryPOP__c inv = new LAT_InventoryPOP__c();
        inv.Client__c = cli.LAT_KAMPOP__r.KAM__c;
        insert inv;
        LAT_KAMPOP.runInventory();
    }
    @isTest static void runInventoryTestCliNull(){
        
        LAT_ClientPOP__c cli = clientPopCreator();  
        cli.LAT_Client__c = null;
        update cli; 
        LAT_InventoryPOP__c inv = new LAT_InventoryPOP__c();
        insert inv;
        LAT_KAMPOP.runInventory();
    }

    @isTest static void runInventoryTestCliNullB(){
        
        LAT_ClientPOP__c cli = clientPopCreator2();  
        cli.LAT_Client__c = null;
        update cli; 
        LAT_InventoryPOP__c inv = new LAT_InventoryPOP__c();
        insert inv;
        LAT_KAMPOP.runInventory();
    }

    @isTest static void constructorTest(){
        
        LAT_KAMPOP kamPOP = new LAT_KAMPOP();
    }


    @isTest static void checkNegativeAmountTest(){
        
        LAT_KAMPOP__c KamPOPOld = KamPOPCreator();
        update KamPOPOld;
    }


    @isTest static void checkNegativeAmountTestB(){
        
        LAT_KAMPOP__c KamPOPOld = KamPOPCreator2();
        update KamPOPOld;
    }

  public static LAT_Produto_POP__c productoPOPCreator(){
        
        LAT_Produto_POP__c prod = new LAT_Produto_POP__c();
        prod.Sku__c = '12';
        prod.name = 'ABC';
        prod.Evidence__c = true;
        prod.Parent_Product__c = 'ABC';
        prod.Inventory__c = true;
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
        clientePop.Delivered__c = Integer.valueOf('200');
        clientePOP.Delivered_Date__c = null;
        clientePOP.LAT_CLient__c = accountCreator().id;

        insert clientePop;
        return clientePop;
    }

}