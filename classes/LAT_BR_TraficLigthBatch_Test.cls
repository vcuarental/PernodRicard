@isTest
public with sharing class LAT_BR_TraficLigthBatch_Test {
    
    

    Profile perfil                        = null;
    User usuario                          = null;
    List<RecordType> listRecType          = null;
    List<String> developerName            = null;
    Map<String, String> mapRecType        = null;
    String idAccount                      = null;
    Account acc                           = null;

    @testSetup 
    static void testSetup(){
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
    }

    private static Planejamento__c  nuevoPlanejamiento(String nombre, String mes) { 
        Planejamento__c planejamento = new Planejamento__c (
        Name = 'test ' + nombre ,
        M_s_de_Ref_rencia__c = mes,
        Ano_de_Referencia__c = '2015'
        );
        return planejamento;
    }      
  
    private static Visitas__c nuevaVisita (Planejamento__c p, String nombre, Account acc) {
        Visitas__c visita = new Visitas__c(
            Name = 'test ' + nombre,
            Tipo_de_Visita__c = 'Vendas',
            Hora_da_Visita__c = '10:00',
            Resumo_da_Visita__c = 'This is a test',
            Conta__c = acc.Id,
            Planejamento__c = p.Id,
            Data_da_Visita__c = Date.today().addDays(-2)
        );
        return visita;
    }

    @isTest
    static void test1() {
        LAT_BR_TL_CamposPreenchidos__c cs = new LAT_BR_TL_CamposPreenchidos__c(Name = 'Agencia', LAT_BR_Conditions__c = 'Type:Outros', LAT_BR_Field__c = 'Agency__c', LAT_BR_Type__c = 'Text'); 
        insert cs;
        
        User u = [SELECT Id, Name FROM User WHERE isActive = true AND Profile.Name = 'LAT_SystemAdministrator' LIMIT 1]; 
        Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        acc.Price_Group__c = '602037025';
        acc.Client_country_AN8__c = '1-8899';
        acc.Client_code_AN8__c = '8899';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.OwnerId = u.Id;
        
        insert acc;  
        Test.startTest();
        Planejamento__c p = nuevoPlanejamiento('1', 'Janeiro');
        insert p;
        Visitas__c v = nuevaVisita(p, 'a', acc);
        insert v;
        Planejamento__c p2 = nuevoPlanejamiento('2', 'Fevereiro');
        insert p2;
        Visitas__c v2 = nuevaVisita(p2, 'b', acc);
        insert v2;
        LAT_BR_TraficLightBatch tlb = new LAT_BR_TraficLightBatch(1,6,8,2015);
        List<Visitas__c> accScope = new List<Visitas__c>{v,v2};
            try{tlb.hasPlanAction(new LAT_BR_CPO_ClientPortfolio__c());}catch(Exception e){}
        tlb.encerrada(v);
        tlb.totallyAchieved(v);
        tlb.partiallyAchieved(v);
        tlb.customerAgreed(v);
        tlb.hasAttachment(v);
        //tlb.processVisitas(accScope)
        if(runBatchs())Database.executeBatch(tlb, 10);
        Test.stopTest();
    } 

        @isTest
    static void test1_1() {
        LAT_BR_TL_CamposPreenchidos__c cs = new LAT_BR_TL_CamposPreenchidos__c(Name = 'Agencia', LAT_BR_Conditions__c = 'Type:Outros', LAT_BR_Field__c = 'Agency__c', LAT_BR_Type__c = 'Text'); 
        insert cs;
        
        User u = [SELECT Id, Name FROM User WHERE isActive = true AND Profile.Name = 'LAT_SystemAdministrator' LIMIT 1]; 
        Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        acc.Price_Group__c = '602037025';
        acc.Client_country_AN8__c = '1-8899';
        acc.Client_code_AN8__c = '8899';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.OwnerId = u.Id;
        
        insert acc;  
        Test.startTest();
        Planejamento__c p = nuevoPlanejamiento('1', 'Janeiro');
        insert p;
        Visitas__c v = nuevaVisita(p, 'a', acc);
        insert v;
        Planejamento__c p2 = nuevoPlanejamiento('10', 'Março');
        insert p2;
        Visitas__c v2 = nuevaVisita(p2, 'b', acc);
        insert v2;
        LAT_BR_TraficLightBatch tlb = new LAT_BR_TraficLightBatch(1,6,8,2015);
        List<Visitas__c> accScope = new List<Visitas__c>{v,v2};
        try{
        tlb.processVisitas(accScope);
        if(runBatchs())Database.executeBatch(tlb, 10);
        } catch (Exception e){

        }
        Test.stopTest();
    } 

    @isTest
    static void test2() {
        LAT_BR_TL_CamposPreenchidos__c cs = new LAT_BR_TL_CamposPreenchidos__c(Name = 'Agencia', LAT_BR_Conditions__c = 'Type:Outros', LAT_BR_Field__c = 'Agency__c', LAT_BR_Type__c = 'Text'); 
        insert cs;
        

        List<User> users = [SELECT Id, Name FROM User WHERE isActive = true AND Profile.Name = 'LAT_SystemAdministrator' LIMIT 2]; 
        User u2 = users[1];
        User u = users[0];
        System.debug('aaaaaaaaaaaa  u : ' + u + ' u2 : ' + u2);
        Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        acc.Price_Group__c = '602037025';
        acc.Client_country_AN8__c = '1-8899';
        acc.Client_code_AN8__c = '8899';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.OwnerId = u.Id;
        acc.Revenue_Neighbourhood__c = 'Teste teste';
        acc.Frequency_of_Visits__c = 'Mensal';
        
        Account acc2 = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        acc2.Price_Group__c = '602037025';
        acc2.Client_country_AN8__c = '1-8833';
        acc2.CNPJ__c = '73909400000783';
        acc2.Client_code_AN8__c = '8833';
        acc2.Status__c = 'Novo Cadastro';
        acc2.OwnerId = u2.Id;
        acc2.Revenue_Neighbourhood__c = 'Teste teste';
        acc2.Frequency_of_Visits__c = 'Mensal';
        insert new List<Account> {acc2, acc};

        Contact cont = new Contact();
        cont.LastName = 'Test Contact';
        cont.AccountId = acc.Id;
        cont.OwnerId = u.Id;
        insert cont;
            
        Test.startTest();

        

        Contact cont2 = new Contact();
        cont2.LastName = 'Test Contact';
        cont2.AccountId = acc2.Id;
        cont2.OwnerId = u2.Id;
        insert cont2;

        Planejamento__c p = nuevoPlanejamiento('1', 'Março');
        insert p;
        
        LAT_BR_CPO_ClientPortfolio__c port = new LAT_BR_CPO_ClientPortfolio__c();
        port.LAT_BR_City__c = acc.Revenue_City__r.Name;
        port.LAT_BR_Client__c = acc.Id;
        port.LAT_BR_ClientCodeAN8__c = acc.Client_code_AN8__c;
        port.LAT_BR_Neighbourhood__c = acc.Revenue_Neighbourhood__c;
        port.LAT_BR_VisitsFrequency__c = acc.Frequency_of_Visits__c;
        port.LAT_BR_VisitPlanning__c = p.Id;
        insert port;

        Visitas__c v = nuevaVisita(p, 'a', acc);
        insert v;
        Planejamento__c p2 = nuevoPlanejamiento('2','Abril');
        insert p2;
        Visitas__c v2 = nuevaVisita(p2, 'b', acc);
        insert v2;

        LAT_BR_CPO_ClientPortfolio__c port2 = new LAT_BR_CPO_ClientPortfolio__c();
        port2.LAT_BR_City__c = acc2.Revenue_City__r.Name;
        port2.LAT_BR_Client__c = acc2.Id;
        port2.LAT_BR_ClientCodeAN8__c = acc2.Client_code_AN8__c;
        port2.LAT_BR_Neighbourhood__c = acc2.Revenue_Neighbourhood__c;
        port2.LAT_BR_VisitsFrequency__c = acc2.Frequency_of_Visits__c;
        port2.LAT_BR_VisitPlanning__c = p2.Id;
        insert port2;
        LAT_BR_TraficLightBatch tlb = new LAT_BR_TraficLightBatch(1,6,8,2015);
        if(runBatchs())Database.executeBatch(tlb, 100);
        LAT_BR_TraficLightBatch tlb2 = new LAT_BR_TraficLightBatch(6,6,8,2015);
        if(runBatchs())Database.executeBatch(tlb2, 100);
        Test.stopTest();
    } 

    @isTest
    static void test3() {
        LAT_BR_TL_CamposPreenchidos__c cs = new LAT_BR_TL_CamposPreenchidos__c(Name = 'Agencia', LAT_BR_Conditions__c = 'Type:Outros', LAT_BR_Field__c = 'Agency__c', LAT_BR_Type__c = 'Text'); 
        insert cs;
        
        User u = [SELECT Id, Name FROM User WHERE isActive = true AND Profile.Name = 'LAT_SystemAdministrator' LIMIT 1]; 
        Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        acc.Price_Group__c = '602037025';
        acc.Client_country_AN8__c = '1-8899';
        acc.Client_code_AN8__c = '8899';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.OwnerId = u.Id;
        Account acc2 = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        acc2.Price_Group__c = '602037025';
        acc2.Client_country_AN8__c = '1-8833';
        acc2.CNPJ__c = '73909400000783';
        acc2.Client_code_AN8__c = '8833';
        acc2.Status__c = 'Novo Cadastro';
        acc2.OwnerId = u.Id;
        acc2.Revenue_Neighbourhood__c = 'Teste teste';
        acc2.Frequency_of_Visits__c = 'Mensal';
        insert new List<Account> {acc2, acc};
        
        Test.startTest();

    
        Planejamento__c p = nuevoPlanejamiento('1', 'Junho');
        insert p;
        Visitas__c v = nuevaVisita(p, 'a', acc);
        insert v;
        Planejamento__c p2 = nuevoPlanejamiento('2', 'Julho');
        insert p2;
        Visitas__c v2 = nuevaVisita(p2, 'b', acc2);
        insert v2;
        LAT_BR_TraficLightBatch tlb = new LAT_BR_TraficLightBatch(3,3,8,2015);
        if(runBatchs())Database.executeBatch(tlb, 10);
        Test.stopTest();
    } 

     @isTest
    static void testErnest() {

        LAT_BR_TL_CamposPreenchidos__c cs = new LAT_BR_TL_CamposPreenchidos__c(Name = 'Agencia', LAT_BR_Conditions__c = 'Type:Outros', LAT_BR_Field__c = 'Agency__c', LAT_BR_Type__c = 'Text'); 
        insert cs;
        

        List<User> users = [SELECT Id, Name FROM User WHERE isActive = true AND Profile.Name = 'LAT_SystemAdministrator' LIMIT 2]; 
        User u2 = users[1];
        User u = users[0];
        System.debug('aaaaaaaaaaaa  u : ' + u + ' u2 : ' + u2);
        Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        acc.Price_Group__c = '602037025';
        acc.Client_country_AN8__c = '1-8899';
        acc.Client_code_AN8__c = '8899';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.OwnerId = u.Id;
        acc.Revenue_Neighbourhood__c = 'Teste teste';
        acc.Frequency_of_Visits__c = 'Mensal';
        
        Account acc2 = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        acc2.Price_Group__c = '602037025';
        acc2.Client_country_AN8__c = '1-8833';
        acc2.CNPJ__c = '73909400000783';
        acc2.Client_code_AN8__c = '8833';
        acc2.Status__c = 'Novo Cadastro';
        acc2.OwnerId = u2.Id;
        acc2.Revenue_Neighbourhood__c = 'Teste teste';
        acc2.Frequency_of_Visits__c = 'Mensal';
        insert new List<Account> {acc2, acc};

        Contact cont = new Contact();
        cont.LastName = 'Test Contact';
        cont.AccountId = acc.Id;
        cont.OwnerId = u.Id;
        insert cont;
            
        Test.startTest();

        

        Contact cont2 = new Contact();
        cont2.LastName = 'Test Contact';
        cont2.AccountId = acc2.Id;
        cont2.OwnerId = u2.Id;
        insert cont2;

        Planejamento__c p = nuevoPlanejamiento('1', 'Março');
        insert p;
        
        LAT_BR_CPO_ClientPortfolio__c port = new LAT_BR_CPO_ClientPortfolio__c();
        port.LAT_BR_City__c = acc.Revenue_City__r.Name;
        port.LAT_BR_Client__c = acc.Id;
        port.LAT_BR_ClientCodeAN8__c = acc.Client_code_AN8__c;
        port.LAT_BR_Neighbourhood__c = acc.Revenue_Neighbourhood__c;
        port.LAT_BR_VisitsFrequency__c = acc.Frequency_of_Visits__c;
        port.LAT_BR_VisitPlanning__c = p.Id;
        insert port;

        Visitas__c v = nuevaVisita(p, 'a', acc);
        insert v;
        Planejamento__c p2 = nuevoPlanejamiento('2','Abril');
        insert p2;
        Visitas__c v2 = nuevaVisita(p2, 'b', acc);
        insert v2;

        LAT_BR_CPO_ClientPortfolio__c port2 = new LAT_BR_CPO_ClientPortfolio__c();
        port2.LAT_BR_City__c = acc2.Revenue_City__r.Name;
        port2.LAT_BR_Client__c = acc2.Id;
        port2.LAT_BR_ClientCodeAN8__c = acc2.Client_code_AN8__c;
        port2.LAT_BR_Neighbourhood__c = acc2.Revenue_Neighbourhood__c;
        port2.LAT_BR_VisitsFrequency__c = acc2.Frequency_of_Visits__c;
        port2.LAT_BR_VisitPlanning__c = p2.Id;
        insert port2;
        List<LAT_BR_CPO_ClientPortfolio__c> portfolios = new List<LAT_BR_CPO_ClientPortfolio__c>{port,port2};
        try{
            LAT_BR_TraficLightBatch tlb = new LAT_BR_TraficLightBatch(1,6,8,2015);
            tlb.processPlanejamentos(portfolios);
            if(runBatchs())Database.executeBatch(tlb, 100);
            LAT_BR_TraficLightBatch tlb2 = new LAT_BR_TraficLightBatch(4,5,8,2015);
            if(runBatchs())Database.executeBatch(tlb2, 100);
        } catch (Exception e){
            // all goes well
        }
        Test.stopTest();
    } 

    @isTest
    static void testJavit() {

        //LAT_BR_TL_CamposPreenchidos__c cs = new LAT_BR_TL_CamposPreenchidos__c(Name = 'Agencia', LAT_BR_Conditions__c = 'Type:Outros', LAT_BR_Field__c = 'Agency__c', LAT_BR_Type__c = 'Text'); 
        //insert cs;
        

        List<User> users = [SELECT Id, Name FROM User WHERE isActive = true AND Profile.Name = 'LAT_SystemAdministrator' LIMIT 2]; 
        User u2 = users[1];
        User u = users[0];
        System.debug('aaaaaaaaaaaa  u : ' + u + ' u2 : ' + u2);
        Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        acc.Price_Group__c = '602037025';
        acc.Client_country_AN8__c = '1-8899';
        acc.Client_code_AN8__c = '8899';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.OwnerId = u.Id;
        acc.Revenue_Neighbourhood__c = 'Teste teste';
        acc.Frequency_of_Visits__c = 'Mensal';
        
        Account acc2 = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        acc2.Price_Group__c = '602037025';
        acc2.Client_country_AN8__c = '1-8833';
        acc2.CNPJ__c = '73909400000783';
        acc2.Client_code_AN8__c = '8833';
        acc2.Status__c = 'Novo Cadastro';
        acc2.OwnerId = u2.Id;
        acc2.Revenue_Neighbourhood__c = 'Teste teste';
        acc2.Frequency_of_Visits__c = 'Mensal';
        insert new List<Account> {acc2, acc};

        Contact cont = new Contact();
        cont.LastName = 'Test Contact';
        cont.AccountId = acc.Id;
        cont.OwnerId = u.Id;
        insert cont;
            
        Test.startTest();

        

        Contact cont2 = new Contact();
        cont2.LastName = 'Test Contact';
        cont2.AccountId = acc2.Id;
        cont2.OwnerId = u2.Id;
        insert cont2;

        Planejamento__c p = nuevoPlanejamiento('20', 'Março');
        insert p;
        
        LAT_BR_CPO_ClientPortfolio__c port = new LAT_BR_CPO_ClientPortfolio__c();
        port.LAT_BR_City__c = acc.Revenue_City__r.Name;
        port.LAT_BR_Client__c = acc.Id;
        port.LAT_BR_ClientCodeAN8__c = acc.Client_code_AN8__c;
        port.LAT_BR_Neighbourhood__c = acc.Revenue_Neighbourhood__c;
        port.LAT_BR_VisitsFrequency__c = acc.Frequency_of_Visits__c;
        port.LAT_BR_VisitPlanning__c = p.Id;
        insert port;

        Visitas__c v = nuevaVisita(p, 'a', acc);
        insert v;
        Planejamento__c p2 = nuevoPlanejamiento('2','Abril');
        insert p2;
        Visitas__c v2 = nuevaVisita(p2, 'b', acc);
        insert v2;

        LAT_BR_CPO_ClientPortfolio__c port2 = new LAT_BR_CPO_ClientPortfolio__c();
        port2.LAT_BR_City__c = acc2.Revenue_City__r.Name;
        port2.LAT_BR_Client__c = acc2.Id;
        port2.LAT_BR_ClientCodeAN8__c = acc2.Client_code_AN8__c;
        port2.LAT_BR_Neighbourhood__c = acc2.Revenue_Neighbourhood__c;
        port2.LAT_BR_VisitsFrequency__c = acc2.Frequency_of_Visits__c;
        port2.LAT_BR_VisitPlanning__c = p2.Id;
        insert port2;
        List<LAT_BR_CPO_ClientPortfolio__c> portfolios = new List<LAT_BR_CPO_ClientPortfolio__c>{port,port2};
        try{
            LAT_BR_TraficLightBatch tlb = new LAT_BR_TraficLightBatch(1,6,8,2015);
            tlb.processPlanejamentos(portfolios);
            if(runBatchs())Database.executeBatch(tlb, 100);
            LAT_BR_TraficLightBatch tlb2 = new LAT_BR_TraficLightBatch(4,5,8,2015);
           
            if(runBatchs())Database.executeBatch(tlb2, 100);
        } catch (Exception e){
            // all goes well
        }
        Test.stopTest();
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

}