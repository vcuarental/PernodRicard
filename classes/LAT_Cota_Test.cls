@isTest

/*******************************************************************************
*                           Company: Zimmic
*-------------------------------------------------------------------------------
*   Clase de test del objeto LAT_CotaMarket__c
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 09/11/2016
*
********************************************************************************/

public class LAT_Cota_Test {

    @testSetup
    public static void setup(){
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];

    }

    
    static testMethod void validateCotaCreation(){
        Utils.setMigrationDoneTest(false);
        Product2 lProd = getProduct();
        insert lProd;
        
        
        LAT_CotaMarket__c cota = getCota(lProd.id);
        cota.startDate__c = Date.today() - 1;
        try{
            insert cota;
        }catch(Exception e){
            System.assertEquals(e.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, A &quot;Data Inicio&quot; e &quot;Data Fim&quot; deve ser maior ou igual a data do dia.: []');
        }
        
        cota.startDate__c = Date.today() + 1;
        insert cota;
        
        LAT_CotaMarket__c cota3 = getCota(lProd.id);
        cota3.startDate__c = Date.today() +6;
        cota3.endDate__c = Date.today() +9;
        insert cota3;
        
        LAT_CotaMarket__c cota2 = getCota(lProd.id);
        try{
            insert cota2;
        }catch(Exception e){
            System.assertEquals(e.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Já existe uma cota cadastrada para esse produto: []');
        }
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.startDate__c = Date.Today() - 1;
        try{
            insert detalheCota;
        }catch(Exception e){
            System.assertEquals(e.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, A &quot;Data Inicio&quot; e a &quot;Data Fim&quot; devem estar entre as &quot;Data Inicio&quot; e &quot;Data Fim&quot; do cabecalho (Cota New to Market).: []');
        }
        detalheCota.startDate__c = Date.Today() + 2;
        insert detalheCota;
    }
    //MIGRATED 9/11/2016
    static testMethod void validateCotaCreation2(){
        Utils.setMigrationDoneTest(true);
        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        cota.startDate__c = Date.today() - 1;
        try{
            insert cota;
        }catch(Exception e){
            System.assertEquals(e.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, A &quot;Data Inicio&quot; e &quot;Data Fim&quot; deve ser maior ou igual a data do dia.: []');
        }
        
        cota.startDate__c = Date.today() + 1;
        insert cota;
        
        LAT_CotaMarket__c cota3 = LAT_getCota(lProd.id);
        cota3.startDate__c = Date.today() +6;
        cota3.endDate__c = Date.today() +9;
        insert cota3;
        
        LAT_CotaMarket__c cota2 = LAT_getCota(lProd.id);
        try{
            insert cota2;
        }catch(Exception e){
            System.assertEquals(e.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Já existe uma cota cadastrada para esse produto: []');
        }
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.startDate__c = Date.Today() - 1;
        try{
            insert detalheCota;
        }catch(Exception e){
            System.assertEquals(e.getMessage(), 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, A &quot;Data Inicio&quot; e a &quot;Data Fim&quot; devem estar entre as &quot;Data Inicio&quot; e &quot;Data Fim&quot; do cabecalho (Cota New to Market).: []');
        }
        detalheCota.startDate__c = Date.Today() + 2;
        insert detalheCota;
    }
    static testMethod void validateConsumeCotaInsuficiente(){
        Utils.setMigrationDoneTest(false);
    
        Product2 lProd = getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_CotaMarket__c cota = getCota(lProd.id); 
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        insert detalheCota;
        
        PricebookEntry entradaCatalogoPreco = getPriceBookEntry(lprod.Id);   
        insert entradaCatalogoPreco;   
        Test.startTest();
        Opportunity opp = getOppty(acc.id);
        insert opp;
        
        
        
        //Cria um novo produto da oportunidade.      
        OpportunityLineItem Oppl = getOpptyLine(entradaCatalogoPreco.Id, Opp.Id);
        Oppl.quantity = 2000;
        insert Oppl;
        
        
        Utils.setMigrationDoneTest(false); 
        Lat_Cota.validateConsumeCota(opp.id);
        
        delete detalheCota;
        
        Oppl = [Select id,Cota_Consumida__c,cantidadCotaConsumida__c from OpportunityLineItem where id =: oppl.id limit 1];
        System.assertEquals(oppl.Cota_Consumida__c , null);
        
        
        Test.stopTest(); 
    }
    //MIGRATED 9/11/2016    
    static testMethod void validateConsumeCotaInsuficiente2(){
        Utils.setMigrationDoneTest(true);

        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id); 
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        insert detalheCota;
        Test.startTest();
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        
        
        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_Quantity__c = 2000;
        insert Oppl;
        
        
        Utils.setMigrationDoneTest(true); 
        Lat_Cota.validateConsumeCota(opp.id);
        
        delete detalheCota;
        
        Oppl = [Select id,LAT_ConsumedQuote__c,LAT_ConsumedQuoteQuantity__c from LAT_OpportunityLineItem__c where id =: oppl.id limit 1];
        System.assertEquals(oppl.LAT_ConsumedQuote__c , null);
        
        
        Test.stopTest(); 
    }

    static testMethod void validateConsumeCotaInsuficienteMobile(){
        Utils.setMigrationDoneTest(true);

        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id); 
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        insert detalheCota;
        Test.startTest();
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        
        
        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_Quantity__c = 2000;
        insert Oppl;
        
        
        Utils.setMigrationDoneTest(true); 
        Lat_Cota.validateConsumeCotaForMobile(opp.id);
        
        delete detalheCota;
        
        Oppl = [Select id,LAT_ConsumedQuote__c,LAT_ConsumedQuoteQuantity__c from LAT_OpportunityLineItem__c where id =: oppl.id limit 1];
        System.assertEquals(oppl.LAT_ConsumedQuote__c , null);
        
        
        Test.stopTest(); 
    }
/*
    static testMethod void validateDeleteCota(){
        Utils.setMigrationDoneTest(false);


        Group testGroup = new Group();
        testGroup.Name = 'LAT_BR_Vendas_Restringido';
        testGroup.DeveloperName = 'LAT_BR_Vendas_RestringidoTest';
        INSERT testGroup;

        GroupMember GM = new GroupMember();
        GM.GroupId = testGroup.id;
        GM.UserOrGroupId = UserInfo.getUserId();
        insert GM; 
        Id profileId = LAT_GlobalProfileCache.getProfileIdByName('PR BRAZIL System Administrator');     
        User usuario = new User(FirstName = 'Nome', LastName = 'Sobrenome', Alias = 'NSobre', Email = 'gerente@sobrenome.com', Username = 'devtestusercloud2b@cloud2b.com.br', CommunityNickname = '123jjjuuuG', EmailEncodingKey = 'ISO-8859-1', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_Us', LanguageLocaleKey = 'en_Us', C_digo_JDE__c = '234', ProfileId = ProfileId, Country = 'BR' );
        insert usuario;
        system.runAs(usuario){
        try{  
                 
         
        


            //Cria novo Account.      
            Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
            insert Acc;
            Test.startTest();
            Product2 lProd = getProduct();
                insert lProd;
            
            LAT_CotaMarket__c cota = getCota(lProd.id);
            insert cota;
            
            LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
            detalheCota.cliente__c = acc.id;
            insert detalheCota;
            
            PricebookEntry entradaCatalogoPreco = getPriceBookEntry(lprod.Id);   
            insert entradaCatalogoPreco;   
            
            Opportunity opp = getOppty(acc.id);
            insert opp;
            
            //Cria um novo produto da oportunidade.      
            OpportunityLineItem Oppl = getOpptyLine(entradaCatalogoPreco.Id, Opp.Id);
            Oppl.Quantity = 15;
            insert Oppl;
            
            Utils.setMigrationDoneTest(false); 
            
            Lat_Cota.validateConsumeCota(opp.id);
            
            delete detalheCota;
            
            Test.stopTest(); 
               }catch(exception e){}
        }
    }  
    //MIGRATED 9/11/2016
    static testMethod void validateDeleteCota2(){
        Utils.setMigrationDoneTest(true);


        



        Group testGroup = new Group();
        testGroup.Name = 'LAT_BR_Vendas_Restringido';
        testGroup.DeveloperName = 'LAT_BR_Vendas_RestringidoTest';
        INSERT testGroup;

        GroupMember GM = new GroupMember();
        GM.GroupId = testGroup.id;
        GM.UserOrGroupId = UserInfo.getUserId();
        insert GM; 
        Id profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator');     
        User usuario = new User(FirstName = 'Nome', LastName = 'Sobrenome', Alias = 'NSobre', Email = 'gerente@sobrenome.com', Username = 'devtestusercloud2b@cloud2b.com.br', CommunityNickname = '123jjjuuuG', EmailEncodingKey = 'ISO-8859-1', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_Us', LanguageLocaleKey = 'en_Us', C_digo_JDE__c = '234', ProfileId = ProfileId, Country = 'BR' );
        insert usuario;
        system.runAs(usuario){
            try{  
                
           
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        Test.startTest();
        LAT_Product__c lProd = LAT_getProduct();
        insert lProd; 
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        insert detalheCota;  
        
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_Quantity__c = 15;
        insert Oppl;
        
        Utils.setMigrationDoneTest(true); 
        
        Lat_Cota.validateConsumeCota(opp.id);
        
        delete detalheCota;
        
        Test.stopTest(); 
         }catch(exception e){}
        }
    }
*/
    static testMethod void validateConsumeCota(){
        Utils.setMigrationDoneTest(false);        

        Product2 lProd = getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_CotaMarket__c cota = getCota(lProd.id);
        insert cota;
        
        PricebookEntry entradaCatalogoPreco = getPriceBookEntry(lprod.Id);   
        insert entradaCatalogoPreco;   
        Test.startTest();
        Opportunity opp = getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        OpportunityLineItem Oppl = getOpptyLine(entradaCatalogoPreco.Id, Opp.Id);
        Oppl.Quantity = 15;
        insert Oppl;
        
        Lat_Cota.validateConsumeCota(opp.id);
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        insert detalheCota;
        
        
        Utils.setMigrationDoneTest(false); 
        Lat_Cota.validateConsumeCota(opp.id);

        Oppl = [Select id,Cota_Consumida__c,cantidadCotaConsumida__c from OpportunityLineItem where id =: oppl.id limit 1];
        //System.assertNotEquals(oppl.Cota_Consumida__c , null);
        //System.assertEquals(oppl.cantidadCotaConsumida__c , 15);
        
        Lat_Cota.deleteOpportunityLine(new List<OpportunityLineItem>{Oppl});
        
        
        
       
        Test.stopTest(); 
    }
    //MIGRATED 9/11/2016
    static testMethod void validateConsumeCota2(){
        Utils.setMigrationDoneTest(true);        

        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        Test.startTest();
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_Quantity__c = 15;
        insert Oppl;
        
        Lat_Cota.validateConsumeCota(opp.id);
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        insert detalheCota;
        
        
        Utils.setMigrationDoneTest(true); 
        Lat_Cota.validateConsumeCota(opp.id);

        Oppl = [Select id,LAT_ConsumedQuote__c,LAT_ConsumedQuoteQuantity__c from LAT_OpportunityLineItem__c where id =: oppl.id limit 1];
        //System.assertNotEquals(oppl.Cota_Consumida__c , null);
        //System.assertEquals(oppl.cantidadCotaConsumida__c , 15);
        
        Lat_Cota.deleteOpportunityLine(new List<LAT_OpportunityLineItem__c>{Oppl});
        
       
        Test.stopTest(); 
    }

    static testMethod void testRest(){
        Utils.setMigrationDoneTest(true);        

        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        Test.startTest();
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        
         RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    req.requestURI = 'https://na11.salesforce.com';  // sample Endpoint
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_Quantity__c = 15;
        insert Oppl;
        
        Lat_Cota.validateConsumeCota(opp.id);
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        insert detalheCota;
        
        
        Utils.setMigrationDoneTest(true); 

        List<LAT_BR_ValidateCotaRest.LineaPedido> pedidos = new List<LAT_BR_ValidateCotaRest.LineaPedido>();
        LAT_BR_ValidateCotaRest.LineaPedido ped1 =  New LAT_BR_ValidateCotaRest.LineaPedido();
        ped1.product = lProd.Id;
        ped1.quantity = 1000;
        pedidos.add(ped1);
        LAT_BR_ValidateCotaRest.post(pedidos, Date.today(), acc.Id);

        //Oppl = [Select id,LAT_ConsumedQuote__c,LAT_ConsumedQuoteQuantity__c from LAT_OpportunityLineItem__c where id =: oppl.id limit 1];
        //System.assertNotEquals(oppl.Cota_Consumida__c , null);
        //System.assertEquals(oppl.cantidadCotaConsumida__c , 15);
        
        //Lat_Cota.deleteOpportunityLine(new List<LAT_OpportunityLineItem__c>{Oppl});
        
       
        Test.stopTest(); 
    }

       static testMethod void testRest2(){
        Utils.setMigrationDoneTest(true);        

        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        Test.startTest();
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        
         RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();

    req.requestURI = 'https://na11.salesforce.com';  // sample Endpoint
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_Quantity__c = 15;
        insert Oppl;
        
        Lat_Cota.validateConsumeCota(opp.id);
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = null;
        insert detalheCota;
        
        
        Utils.setMigrationDoneTest(true); 

        List<LAT_BR_ValidateCotaRest.LineaPedido> pedidos = new List<LAT_BR_ValidateCotaRest.LineaPedido>();
        LAT_BR_ValidateCotaRest.LineaPedido ped1 =  New LAT_BR_ValidateCotaRest.LineaPedido();
        ped1.product = lProd.Id;
        ped1.quantity = 1000;
        pedidos.add(ped1);
        LAT_BR_ValidateCotaRest.post(pedidos, Date.today(), acc.Id);

        //Oppl = [Select id,LAT_ConsumedQuote__c,LAT_ConsumedQuoteQuantity__c from LAT_OpportunityLineItem__c where id =: oppl.id limit 1];
        //System.assertNotEquals(oppl.Cota_Consumida__c , null);
        //System.assertEquals(oppl.cantidadCotaConsumida__c , 15);
        
        //Lat_Cota.deleteOpportunityLine(new List<LAT_OpportunityLineItem__c>{Oppl});
        
       
        Test.stopTest(); 
    }

    //MIGRATED 9/11/2016
    static testMethod void validateConsumeCota2Mobile(){
        Utils.setMigrationDoneTest(true);        

        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        Test.startTest();
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_Quantity__c = 15;
        insert Oppl;
        
        Lat_Cota.validateConsumeCotaForMobile(opp.id);
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        insert detalheCota;
        
        
        Utils.setMigrationDoneTest(true); 
        Lat_Cota.validateConsumeCota(opp.id);

        Oppl = [Select id,LAT_ConsumedQuote__c,LAT_ConsumedQuoteQuantity__c from LAT_OpportunityLineItem__c where id =: oppl.id limit 1];
        //System.assertNotEquals(oppl.Cota_Consumida__c , null);
        //System.assertEquals(oppl.cantidadCotaConsumida__c , 15);
        
        Lat_Cota.deleteOpportunityLine(new List<LAT_OpportunityLineItem__c>{Oppl});
        
        
        
       
        Test.stopTest(); 
    }
    
    static testMethod void validateConsumeCotaSegmento(){
        Utils.setMigrationDoneTest(false); 
        Product2 lProd = getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        
        LAT_CotaMarket__c cota = getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota;
        
        PricebookEntry entradaCatalogoPreco = getPriceBookEntry(lprod.Id);   
        insert entradaCatalogoPreco;   
        Test.startTest();
        Opportunity opp = getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        OpportunityLineItem Oppl = getOpptyLine(entradaCatalogoPreco.Id, Opp.Id);
        Oppl.Quantity = 15;
        insert Oppl;
        Lat_Cota.validateConsumeCota(opp.id);
        
        
        Utils.setMigrationDoneTest(false); 
        Oppl.Quantity = 17;
        update Oppl;
        Lat_Cota.validateConsumeCota(opp.id);
        
      
        
        Test.stopTest(); 
    }
    //MIGRATED 9/11/2016   
    static testMethod void validateConsumeCotaSegmento2(){
        Utils.setMigrationDoneTest(true); 
        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota; 
        Test.startTest();
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_Quantity__c = 15;
        insert Oppl;
        Lat_Cota.validateConsumeCota(opp.id);
        
        
        Utils.setMigrationDoneTest(true); 
        Oppl.LAT_Quantity__c = 17;
        update Oppl;
        Lat_Cota.validateConsumeCota(opp.id);
        
      
        
        Test.stopTest(); 
    }

    //MIGRATED 9/11/2016   
    static testMethod void validateConsumeCotaSegmento2Mobile(){
        Utils.setMigrationDoneTest(true); 
        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota; 
        Test.startTest();
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_Quantity__c = 15;
        insert Oppl;
        Lat_Cota.validateConsumeCotaForMobile(opp.id);
        
        
        Utils.setMigrationDoneTest(true); 
        Oppl.LAT_Quantity__c = 17;
        update Oppl;
        Lat_Cota.validateConsumeCota(opp.id);
        
      
        
        Test.stopTest(); 
    }

    static testMethod void validateConsumeCotaSegmentoInsuficiente(){
        
        Utils.setMigrationDoneTest(false);
        Product2 lProd = getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        Test.startTest();
        LAT_CotaMarket__c cota = getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota;
        
        PricebookEntry entradaCatalogoPreco = getPriceBookEntry(lprod.Id);   
        insert entradaCatalogoPreco;   
        
        Opportunity opp = getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        OpportunityLineItem Oppl = getOpptyLine(entradaCatalogoPreco.Id, Opp.Id);
        Oppl.Quantity = 1500;
        insert Oppl;
        Lat_Cota.validateConsumeCota(opp.id);
        
        
      
        
        Test.stopTest(); 
    }
    //MIGRATED 9/11/2016 
    static testMethod void validateConsumeCotaSegmentoInsuficiente2(){
        
        Utils.setMigrationDoneTest(true);
        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        Test.startTest();
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota;
        
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_Quantity__c = 1500;
        insert Oppl;
        Lat_Cota.validateConsumeCota(opp.id);
        
        
      
        
        Test.stopTest(); 
    }

    //MIGRATED 9/11/2016 
    static testMethod void validateConsumeCotaSegmentoInsuficiente2Mobile(){
        
        Utils.setMigrationDoneTest(true);
        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        Test.startTest();
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota;
        
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_Quantity__c = 1500;
        insert Oppl;
        Lat_Cota.validateConsumeCotaForMobile(opp.id);
        
        
      
        
        Test.stopTest(); 
    }
    
    
    static testMethod void consumeReturn(){
        
        Utils.setMigrationDoneTest(false);

        Product2 lProd = getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        Test.startTest();
        
        LAT_CotaMarket__c cota = getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota;
        
        PricebookEntry entradaCatalogoPreco = getPriceBookEntry(lprod.Id);   
        insert entradaCatalogoPreco;   
        
        Opportunity opp = getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        OpportunityLineItem Oppl = getOpptyLine(entradaCatalogoPreco.Id, Opp.Id);
        Oppl.Descricao_do_status__c = 'Test';
        Oppl.Quantity = 15;
        insert Oppl;
        
       
        Lat_Cota.consumeReturn(new List<OpportunityLineItem>{Oppl});
        
        Test.stopTest(); 
    }
    //MIGRATED 9/11/2016     
    static testMethod void consumeReturn2(){
        
        Utils.setMigrationDoneTest(true);
        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        Test.startTest();
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota;
        
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_StatusDescription__c = 'Test';
        Oppl.LAT_Quantity__c = 15;
        insert Oppl;
        
       
        Lat_Cota.consumeReturn(new List<LAT_OpportunityLineItem__c>{Oppl});
        
        Test.stopTest(); 
    }

        static testMethod void consumeReturnBulk(){
        
        Utils.setMigrationDoneTest(false);

        Product2 lProd = getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        
        LAT_CotaMarket__c cota = getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota;
        
        PricebookEntry entradaCatalogoPreco = getPriceBookEntry(lprod.Id);   
        insert entradaCatalogoPreco;   
        Test.startTest();
        Opportunity opp = getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        OpportunityLineItem Oppl = getOpptyLine(entradaCatalogoPreco.Id, Opp.Id);
        Oppl.Descricao_do_status__c = 'Test';
        Oppl.Quantity = 15;
        insert Oppl;
        
       
        Lat_Cota.consumeReturnBulk(new List<OpportunityLineItem>{Oppl});
        
        Test.stopTest(); 
    }
    //MIGRATED 9/11/2016     
    static testMethod void consumeReturnBulk2(){
        
        Utils.setMigrationDoneTest(true);
        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota;
        Test.startTest();
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_StatusDescription__c = 'Test';
        Oppl.LAT_Quantity__c = 15;
        insert Oppl;
        
       
        Lat_Cota.consumeReturnBulk(new List<LAT_OpportunityLineItem__c>{Oppl});
        Lat_Cota.getDetalhesList(new List<LAT_DetalheCotaMarket__c>{detalheCota},Date.today());
        Test.stopTest(); 
    }
    

    static testMethod void consumeReturnCancelado(){
        
        Utils.setMigrationDoneTest(false);
        Product2 lProd = getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        
        LAT_CotaMarket__c cota = getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota;
        Test.startTest();
        PricebookEntry entradaCatalogoPreco = getPriceBookEntry(lprod.Id);   
        insert entradaCatalogoPreco;   
        
        Opportunity opp = getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        OpportunityLineItem Oppl = getOpptyLine(entradaCatalogoPreco.Id, Opp.Id);
        Oppl.Descricao_do_status__c = 'Test';
        Oppl.Quantity = 15;
        insert Oppl;
        Lat_Cota.validateConsumeCota(opp.id);
        
        Utils.setMigrationDoneTest(false);
        Oppl.cd_line_status__c = '999';
        Oppl.Descricao_do_status__c = 'Cancelado';
        update oppl;

        

        Lat_Cota.consumeReturn(new List<OpportunityLineItem>{Oppl});
        
        Test.stopTest(); 
    }
    
    //MIGRATED 9/11/2016 
    static testMethod void consumeReturnCancelado2(){
        
        Utils.setMigrationDoneTest(true);
        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota;
        Test.startTest();
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_StatusDescription__c = 'Test';
        Oppl.LAT_Quantity__c = 15;
        insert Oppl;
        Lat_Cota.validateConsumeCota(opp.id);
        
        
        Utils.setMigrationDoneTest(true);
        Oppl.LAT_CdLineStatus__c = '999';
        Oppl.LAT_StatusDescription__c = 'Cancelado';
        update oppl;

        

        Lat_Cota.consumeReturn(new List<LAT_OpportunityLineItem__c>{Oppl});
        
        Test.stopTest(); 
    }

    

    static testMethod void consumeReturnUpdate(){
        
        Utils.setMigrationDoneTest(false);
        Product2 lProd = getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        
        LAT_CotaMarket__c cota = getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota;
        
        PricebookEntry entradaCatalogoPreco = getPriceBookEntry(lprod.Id);   
        insert entradaCatalogoPreco;   
        Test.startTest();
        Opportunity opp = getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        OpportunityLineItem Oppl = getOpptyLine(entradaCatalogoPreco.Id, Opp.Id);
        Oppl.Descricao_do_status__c = 'Test';
        Oppl.Quantity = 15;
        insert Oppl;
        Lat_Cota.validateConsumeCota(opp.id);
        
        Oppl.Quantity = 17;

        
        Utils.setMigrationDoneTest(false);
        Lat_Cota.consumeReturn(new List<OpportunityLineItem>{Oppl});
        
        Test.stopTest(); 
    }

    //MIGRATED 9/11/2016     
    static testMethod void consumeReturnUpdate2(){
        
        Utils.setMigrationDoneTest(true);
        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.sub_Canal__c = 'Atacadista';
        insert detalheCota;
        Test.startTest();
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;

        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_StatusDescription__c = 'Test';
        Oppl.LAT_Quantity__c = 15;
        insert Oppl;
        Lat_Cota.validateConsumeCota(opp.id);
        
        Oppl.LAT_Quantity__c = 17;

        
        Utils.setMigrationDoneTest(true);
        Lat_Cota.consumeReturn(new List<LAT_OpportunityLineItem__c>{Oppl});
        
        Test.stopTest(); 
    }
    
    static testMethod void consumeReturnUpdateClient(){
        
        Utils.setMigrationDoneTest(true);
        Product2 lProd = getProduct();
        insert lProd;
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        
        LAT_CotaMarket__c cota = getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        insert detalheCota;
        
        PricebookEntry entradaCatalogoPreco = getPriceBookEntry(lprod.Id);   
        insert entradaCatalogoPreco;   
        Test.startTest();
        Opportunity opp = getOppty(acc.id);
        insert opp;
        
        //Cria um novo produto da oportunidade.      
        OpportunityLineItem Oppl = getOpptyLine(entradaCatalogoPreco.Id, Opp.Id);
        Oppl.Descricao_do_status__c = 'Test';
        Oppl.Quantity = 15;
        insert Oppl;
        
       
        Lat_Cota.consumeReturn(new List<OpportunityLineItem>{Oppl});
        
        Test.stopTest(); 
    }

    //MIGRATED 9/11/2016  
    static testMethod void consumeReturnUpdateClient2(){
        
        Utils.setMigrationDoneTest(true);
        LAT_Product__c lProd = LAT_getProduct();
        insert lProd;
        
        //Cria novo Account.      
        Account Acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Sub_Channel__c = 'Atacadista';
        insert Acc;
        
        LAT_CotaMarket__c cota = LAT_getCota(lProd.id);
        insert cota;
        
        LAT_DetalheCotaMarket__c detalheCota = getDetalheCota(cota.id);
        detalheCota.cliente__c = acc.id;
        insert detalheCota;
        Test.startTest();
        LAT_Opportunity__c opp = LAT_getOppty(acc.id);
        insert opp;

        
        //Cria um novo produto da oportunidade.      
        LAT_OpportunityLineItem__c Oppl = LAT_getOpptyLine(lProd.Id, Opp.Id);
        Oppl.LAT_StatusDescription__c = 'Test';
        Oppl.LAT_Quantity__c = 15;
        insert Oppl;
        
       
        Lat_Cota.consumeReturn(new List<LAT_OpportunityLineItem__c>{Oppl});
        
        Test.stopTest(); 
    }
    
    
    //MIGRATED 9/11/2016
    public static LAT_Product__c LAT_getProduct(){
        LAT_Product__c lProd = new LAT_Product__c();
        lProd.Name = 'Cachaca';
        lProd.LAT_ExternalId__c = '1234569';
        return lProd;
    }
    
   
    
    public static Product2 getProduct(){
        Product2 lProd = new Product2();
        lProd.Name = 'Cachaca';
        lProd.Internal_id__c = '1234569';
        return lProd;
    }
    
    public static Opportunity getOppty(String accId){
        return LAT_Opportunity_TestFactory.getCRMOppty(accId);   
    } 
    //MIGRATED 9/11/2016
    public static LAT_Opportunity__c LAT_getOppty(String accId){
        return LAT_Opportunity_TestFactory.LAT_getCRMOppty(accId);   
    } 
    
    public static OpportunityLineItem getOpptyLine(String entryId, String oppId){
        OpportunityLineItem Oppl = new OpportunityLineItem();      
        Oppl.PricebookEntryId = entryId;      
        Oppl.OpportunityId    = oppId;      
        Oppl.UnitPrice        = 12;      
        Oppl.Quantity         = 150;      
        return oppl;    
    }
    
    //MIGRATED 9/11/2016
    public static LAT_OpportunityLineItem__c LAT_getOpptyLine(String entryId, String oppId){
        LAT_OpportunityLineItem__c Oppl = new LAT_OpportunityLineItem__c();      
        Oppl.LAT_Product__c = entryId;      
        Oppl.LAT_Opportunity__c    = oppId;      
        Oppl.LAT_UnitPrice__c        = 12;      
        Oppl.LAT_Quantity__c         = 150;      
        return oppl;    
    }

    public static PricebookEntry getPriceBookEntry(String prodId){
        PricebookEntry entradaCatalogoPreco = new PricebookEntry();      
        entradaCatalogoPreco.Pricebook2Id = '01sD0000000h8wyIAA';        
        entradaCatalogoPreco.Product2Id = prodId;      
        entradaCatalogoPreco.UnitPrice = 1000.00;      
        entradaCatalogoPreco.IsActive = true;      
        entradaCatalogoPreco.UseStandardPrice = false;  
        return entradaCatalogoPreco;
    }

    
    public static LAT_CotaMarket__c getCota(String prodID){
        LAT_CotaMarket__c cota = new LAT_CotaMarket__c();
        cota.totalCota__c = 100;
        cota.sku__c = prodID;
        cota.startDate__c = Date.today();
        cota.endDate__c = Date.today() + 4;
        return cota;
    }
    //MIGRATED 9/11/2016
    public static LAT_CotaMarket__c LAT_getCota(String prodID){
        LAT_CotaMarket__c cota = new LAT_CotaMarket__c();
        cota.totalCota__c = 100;
        cota.LAT_Product__c = prodID;
        cota.startDate__c = Date.today();
        cota.endDate__c = Date.today() + 4;
        return cota;
    }

    public static LAT_DetalheCotaMarket__c getDetalheCota(String cotaId){
        LAT_DetalheCotaMarket__c detalheCota = new LAT_DetalheCotaMarket__c();
        detalheCota.cotaMarket__c = cotaId;
        detalheCota.cotaMarket__c = cotaId;
        detalheCota.startDate__c = Date.today();
        detalheCota.endDate__c = Date.today() + 3;
        detalheCota.cota__c = 90;
        detalheCota.consumo__c = 0;
        return detalheCota;
    }

}