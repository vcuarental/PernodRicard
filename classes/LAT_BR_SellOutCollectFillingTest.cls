/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
@isTest
private class LAT_BR_SellOutCollectFillingTest {
    


    @isTest static void testConstructor() {
            LAT_BR_VFC29_SellOutCollectFilling socf = new LAT_BR_VFC29_SellOutCollectFilling();
                system.assertEquals(socf.currentMonth, String.valueOf(Date.today().month()));
                system.assertEquals(socf.currentYear,String.valueOf(Date.today().year()));
    }
    
    @isTest static void  testNewDoInits() {
        Utils.setMigrationDoneTest(false); 
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_ReferenceAccount__c rf = new LAT_ReferenceAccount__c();
        rf.Account__c = Acc.id;
        rf.isActive__c = true;
        insert rf;
        
        Product2 p = lat_cota_test.getProduct(); 
        p.LAT_IsRefactorProduct__c = 'Y';
        p.isActive = true;
        p.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
        insert p;
        
        LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c( Name = 'Testing' );
        insert rpg;
        
        LAT_ReferenceProduct__c rp = new LAT_ReferenceProduct__c();
        rp.SKURef__c =p.id;
        rp.Type__c='sku';
        rp.isActive__c = true;
        rp.ReferenceGrouping__c = rpg.id;
        insert rp;
        
        LAT_BR_VFC29_SellOutCollectFilling socf = new LAT_BR_VFC29_SellOutCollectFilling();
        PageReference action = Page.LAT_BR_VFP29_SellOutCollectFilling;
        action.getParameters().put('month',String.valueOf(Date.today().month()));
        action.getParameters().put('year', String.valueOf(Date.today().year()));
        action.getParameters().put('refAId', rf.id);
        action.getParameters().put('action', 'New');
        Test.setCurrentPage(action);
        
        socf.doInit();
        system.assertEquals(1,socf.coletaLista.size());
 
    }
    //MIGRATED 21/11/2016
    @isTest static void  testNewDoInitsB() {
        Utils.setMigrationDoneTest(true); 
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_ReferenceAccount__c rf = new LAT_ReferenceAccount__c();
        rf.Account__c = Acc.id;
        rf.isActive__c = true;
        insert rf;
        
        LAT_Product__c p = lat_cota_test.LAT_getProduct(); 
        p.LAT_IsRefactorProduct__c = 'Y';
        p.LAT_IsActive__c = true;
        p.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
        insert p;
        
        LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c( Name = 'Testing' );
        insert rpg;
        
        LAT_ReferenceProduct__c rp = new LAT_ReferenceProduct__c();
        rp.LAT_Product__c =p.id;
        rp.Type__c='sku';
        rp.isActive__c = true;
        rp.ReferenceGrouping__c = rpg.id;
        insert rp;
        
        LAT_BR_VFC29_SellOutCollectFilling socf = new LAT_BR_VFC29_SellOutCollectFilling();
        PageReference action = Page.LAT_BR_VFP29_SellOutCollectFilling;
        action.getParameters().put('month',String.valueOf(Date.today().month()));
        action.getParameters().put('year', String.valueOf(Date.today().year()));
        action.getParameters().put('refAId', rf.id);
        action.getParameters().put('action', 'New');
        Test.setCurrentPage(action);
        
        socf.doInit();
        system.assertEquals(1,socf.coletaLista.size());
 
    }

    @isTest static void testOldDoInits(){
        LAT_SellOutCollect__c s = logs();
        LAT_BR_VFC29_SellOutCollectFilling socf = new LAT_BR_VFC29_SellOutCollectFilling();
        PageReference colId = Page.LAT_BR_VFP29_SellOutCollectFilling;
        colId.getParameters().put('colId', s.id);
        Test.setCurrentPage(colId);
        socf.doInit();
        system.assert(socf.coletaLista != null);
        system.assertEquals(Integer.valueOF(socf.Month),s.ReferencedMonth__c.month());
        system.assertEquals(Integer.valueOf(socf.Year),s.ReferencedMonth__c.Year());

    }
    @isTest static void testGetFillingColecta(){
        LAT_SellOutCollect__c s = logs();
        LAT_BR_VFC29_SellOutCollectFilling socf = new LAT_BR_VFC29_SellOutCollectFilling();
        PageReference colId = Page.LAT_BR_VFP29_SellOutCollectFilling;
        colId.getParameters().put('colId', s.id);
        Test.setCurrentPage(colId);
        LAT_SellOutCollect__c soc =socf.getFillingColeta(s.id);
        system.Equals(soc,s);
     }

    @isTest static void testGetFillingColetaByMonth(){
        Date.newInstance(Integer.valueOf(Date.today().year()), Integer.valueOf(Date.today().month()), 1);
        LAT_SellOutCollect__c s = logs();
        LAT_BR_VFC29_SellOutCollectFilling socf = new LAT_BR_VFC29_SellOutCollectFilling();
        LAT_SellOutCollect__c s2 = socf.getFillingColetaByMonth(Date.today().month(), Date.today().year(), s.ReferenceAccount__c);
        system.assertEquals(s.id,s2.id);


    }
    @isTest static void testGetColetaListFromColeta(){
        Utils.setMigrationDoneTest(false); 
        LAT_SellOutCollect__c s = logs();
        LAT_BR_VFC29_SellOutCollectFilling socf = new LAT_BR_VFC29_SellOutCollectFilling();
        socf.coletaLista=logs2(s);
        PageReference colId = Page.LAT_BR_VFP29_SellOutCollectFilling;
        colId.getParameters().put('colId', s.id);
        Test.setCurrentPage(colId);
        List<LAT_SellOutCollectLine__c> soc = socf.getColetaListFromColeta(s.id);
        system.assertEquals(1,soc.size());
    }
    //MIGRATED 21/11/2016
    @isTest static void testGetColetaListFromColetaB(){
        Utils.setMigrationDoneTest(true); 
        LAT_SellOutCollect__c s = logs();
        LAT_BR_VFC29_SellOutCollectFilling socf = new LAT_BR_VFC29_SellOutCollectFilling();
        socf.coletaLista=logs2B(s);
        PageReference colId = Page.LAT_BR_VFP29_SellOutCollectFilling;
        colId.getParameters().put('colId', s.id);
        Test.setCurrentPage(colId);
        List<LAT_SellOutCollectLine__c> soc = socf.getColetaListFromColeta(s.id);
        system.assertEquals(1,soc.size());
    }

    @isTest static void testDoSave(){
        LAT_SellOutCollect__c soc = logs();
        LAT_BR_VFC29_SellOutCollectFilling socf = new LAT_BR_VFC29_SellOutCollectFilling();
        socf.coleta=soc;  
        socf.coletaLista = new List<LAT_SellOutCollectLine__c>() ;
        socf.doSave();
        system.assert(socf.coleta != null); 
    }


    @isTest static void testDoFinalize(){
        LAT_SellOutCollect__c soc = logs();
        LAT_BR_VFC29_SellOutCollectFilling socf = new LAT_BR_VFC29_SellOutCollectFilling();
        socf.coleta=soc;  
        socf.coletaLista = new List<LAT_SellOutCollectLine__c>();
        socf.doFinalize();
        system.assertEquals(socf.coleta.Status__c,'Finalized');
    }

    public static LAT_SellOutCollect__c logs(){
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        LAT_ReferenceAccount__c rf = new LAT_ReferenceAccount__c();
        rf.Account__c = Acc.id;
        rf.isActive__c = true;
        insert rf;
        LAT_SellOutCollect__c soc = new LAT_SellOutCollect__c();
        soc.CollectDate__c = Date.today();
        soc.Unit__c='CA';
        soc.ReferencedMonth__c = Date.newInstance(Integer.valueOf(Date.today().year()), Integer.valueOf(Date.today().month()), 1);
        soc.Status__c = 'Filling';
        soc.ReferenceAccount__c = rf.id;
        
        insert soc;
        return soc;
    }

    public static List<LAT_SellOutCollectLine__c> logs2(LAT_SellOutCollect__c padre){

        Utils.setMigrationDoneTest(false); 
        LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c( Name = 'Testing' );
        insert rpg;
        Product2 p = lat_cota_test.getProduct(); 
        p.LAT_IsRefactorProduct__c = 'Y';
        p.isActive = true;
        p.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
        insert p;
        LAT_ReferenceProduct__c rp = new LAT_ReferenceProduct__c();
        rp.SKURef__c =p.id;
        rp.IsActive__c=true;
        rp.Type__c='sku';
        rp.ReferenceGrouping__c = rpg.id;
        insert rp;
        List<LAT_SellOutCollectLine__c> soclList = new List<LAT_SellOutCollectLine__c>();
        LAT_SellOutCollectLine__c socl = new LAT_SellOutCollectLine__c();
        socl.SellOut__c=1234;
        socl.Stock__c =1234;    
        socl.SellOutCollect__c =padre.id;  
        soclList.add(socl);
        
        insert soclList;
        return soclList;
    }
    //MIGRATED 21/11/2016
    public static List<LAT_SellOutCollectLine__c> logs2B(LAT_SellOutCollect__c padre){

        Utils.setMigrationDoneTest(true); 
        LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c( Name = 'Testing' );
        insert rpg;
        LAT_Product__c p = lat_cota_test.LAT_getProduct();  
        p.LAT_IsRefactorProduct__c = 'Y';
        p.LAT_IsActive__c = true;
        p.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
        insert p;

        
        LAT_ReferenceProduct__c rp = new LAT_ReferenceProduct__c();
        rp.LAT_Product__c =p.id;
        rp.IsActive__c=true;
        rp.Type__c='sku';
        rp.ReferenceGrouping__c = rpg.id;
        insert rp;

        List<LAT_SellOutCollectLine__c> soclList = new List<LAT_SellOutCollectLine__c>();
        LAT_SellOutCollectLine__c socl = new LAT_SellOutCollectLine__c();
        socl.SellOut__c=1234;
        socl.Stock__c =1234;    
        socl.SellOutCollect__c =padre.id;  
        soclList.add(socl);
        
        insert soclList;
        return soclList;
    }
    
}