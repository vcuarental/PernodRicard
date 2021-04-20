/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe de teste da trigger InvestBonifPagtoROI.trigger
* NAME: InvestBonifPagtoROITest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 24/07/2012
*
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/

@isTest
private class InvestBonifPagtoROITest {

    static testMethod void myUnitTest0() {
        Utils.setMigrationDoneTest(false); 
        //Recupera os IDS de tipo de registro.
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        Id idRecTypeIP = RecordTypeForTest.getRecType( 'Informacoes_do_Produto__c', 'Informacoes_do_Produto' );
        Id idRecTypeICP = RecordTypeForTest.getRecType( 'Informacoes_de_Custo_do_Produto__c', 'Informacoes_de_Custo_do_Produto' );
        Id idRecTypeProd = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
        Id idRecTypeInv = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        try{insert usuario;}catch(Exception e){} 
        
        //insert usuario;
       


        //Cria nova UDC
        
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        //insert regional;
        insert regional;

        Account lAcc = new Account();
        lAcc.Type = 'Outros';
        lAcc.Name = 'Teste';
        lAcc.Agency__c = '000';
        lacc.Checking_account__c = '000';
        lAcc.Current_account__c = '0';
        lAcc.Revenue_UF__c = 'SP';
        lAcc.Corporate_Name__c = 'Teste';
        lAcc.Status__c = 'Cliente cadastrado no JDE';
        lAcc.CNPJ__c = '65746267000178';
        //lAcc.Regional__c = regional.id;
        lAcc.RecordTypeId = idRecTypeAcc;
        lAcc.Segmentation_Type_on_trade__c = 'Bar';
        lAcc.Rating = 'Cliente';
        //insert lAcc;
        insert lAcc;
    
        Test.startTest();
        Utils.setMigrationDoneTest(false); 
        LAT_Contract__c lContrato = new LAT_Contract__c();
        lContrato.Account__c = lAcc.id;
        lContrato.Status__c = 'Em elaboração';
        lContrato.StartDate__c = System.today();
        lContrato.ContractTerm__c = 12;
        lContrato.OwnerId = usuario.Id;
        lContrato.trigger_on__c = true;
        lContrato.RecordTypeId = idrecTypeLatCon;
        insert lContrato;
        //try{insert lContrato;}catch(Exception e){}
        
        Product2 lProd = new Product2();
        lProd.Description = 'Cachaca';
        lProd.Name = 'Cachaca';
        lProd.Internal_id__c = 'asdad';
        lProd.RecordTypeId = idRecTypeProd;
        
        //insert lProd;
        try{insert lProd;}catch(Exception e){}
        
        Informacoes_do_Produto__c IP = new Informacoes_do_Produto__c();
        IP.Scheduler_C__c = lProd.Scheduler__c;
        IP.Tx_Conversao__c = 2;
        IP.RecordTypeId = idRecTypeIP;
        IP.Produto_Bonificado__c = true;
        //insert IP;
        try{insert IP;}catch(Exception e){}
        
        Informacoes_de_Custo_do_Produto__c ICP = new Informacoes_de_Custo_do_Produto__c();
        ICP.UF__c = lAcc.Revenue_UF__c;
        ICP.Scheduler_C__c = IP.id;
        ICP.Custo_LD__c = 1;
        ICP.Custo_Distribuidor__c = 1.2;
        ICP.RecordTypeId = idRecTypeICP;
        //insert ICP;
        try{insert ICP;}catch(Exception e){}
        
        Investimento_Bonificacao_e_Pagamento__c IBP = new Investimento_Bonificacao_e_Pagamento__c();
        IBP.LAT_Contract__c = lContrato.Id;
        IBP.Produto_Bonificado__c = lProd.id;
        IBP.Volume_Cx__c = 10;
        IBP.Data_de_Previsao_do_Pagamento__c = System.today() ;
        IBP.RecordTypeId = idRecTypeInv;
        IBP.ScheduleC_Bonificado__c = IP.Id;
        //insert IBP;
        insert IBP;
        Test.stopTest();
    }


    static testMethod void myUnitTest() {
        Utils.setMigrationDoneTest(false); 
        //Recupera os IDS de tipo de registro.
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        Id idRecTypeIP = RecordTypeForTest.getRecType( 'Informacoes_do_Produto__c', 'Informacoes_do_Produto' );
        Id idRecTypeICP = RecordTypeForTest.getRecType( 'Informacoes_de_Custo_do_Produto__c', 'Informacoes_de_Custo_do_Produto' );
        Id idRecTypeProd = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
        Id idRecTypeInv = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        try{insert usuario;}catch(Exception e){} 
        
        //insert usuario;
       


        //Cria nova UDC
        
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        //insert regional;
        try{insert regional;}catch(Exception e){}
        
        Account lAcc = new Account();
        lAcc.Name = 'Teste';
        lAcc.Revenue_UF__c = 'SP';
        lAcc.Corporate_Name__c = 'Teste';
        lAcc.Status__c = 'Cliente cadastrado no JDE';
        lAcc.CNPJ__c = '65746267000178';
        lAcc.Regional__c = regional.id;
        lAcc.RecordTypeId = idRecTypeAcc;
        lAcc.Segmentation_Type_on_trade__c = 'Bar';
        lAcc.Rating = 'Cliente';
        //insert lAcc;
        try{insert lAcc;}catch(Exception e){}
        
        LAT_Contract__c lContrato = new LAT_Contract__c();
        lContrato.Account__c = lAcc.id;
        lContrato.Status__c = 'Em elaboração';
        lContrato.StartDate__c = System.today();
        lContrato.ContractTerm__c = 12;
        lContrato.OwnerId = usuario.Id;
        lContrato.trigger_on__c = true;
        lContrato.RecordTypeId = idrecTypeLatCon;
        //insert lContrato;
        //try{insert lContrato;}catch(Exception e){}
        
        Product2 lProd = new Product2();
        lProd.Description = 'Cachaca';
        lProd.Name = 'Cachaca';
        lProd.Internal_id__c = 'asdad';
        lProd.RecordTypeId = idRecTypeProd;
        
        //insert lProd;
        try{insert lProd;}catch(Exception e){}
        
        Informacoes_do_Produto__c IP = new Informacoes_do_Produto__c();
        IP.Scheduler_C__c = lProd.Scheduler__c;
        IP.Tx_Conversao__c = 2;
        IP.RecordTypeId = idRecTypeIP;
        IP.Produto_Bonificado__c = true;
        //insert IP;
        try{insert IP;}catch(Exception e){}
        
        Informacoes_de_Custo_do_Produto__c ICP = new Informacoes_de_Custo_do_Produto__c();
        ICP.UF__c = lAcc.Revenue_UF__c;
        ICP.Scheduler_C__c = IP.id;
        ICP.Custo_LD__c = 1;
        ICP.Custo_Distribuidor__c = 1.2;
        ICP.RecordTypeId = idRecTypeICP;
        //insert ICP;
        try{insert ICP;}catch(Exception e){}
        
        Investimento_Bonificacao_e_Pagamento__c IBP = new Investimento_Bonificacao_e_Pagamento__c();
        IBP.LAT_Contract__c = lContrato.Id;
        IBP.Produto_Bonificado__c = lProd.id;
        IBP.Volume_Cx__c = 10;
        IBP.Data_de_Previsao_do_Pagamento__c = System.today() ;
        IBP.RecordTypeId = idRecTypeInv;
        //IBP.ScheduleC_Bonificado__c = IP.Id;
        //insert IBP;
        insert IBP;
    }
    //MIGRATED 21/11/2016
    static testMethod void myUnitTest2() {
        Utils.setMigrationDoneTest(true); 
        //Recupera os IDS de tipo de registro.
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
        Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        Id idRecTypeIP = RecordTypeForTest.getRecType( 'Informacoes_do_Produto__c', 'Informacoes_do_Produto' );
        Id idRecTypeICP = RecordTypeForTest.getRecType( 'Informacoes_de_Custo_do_Produto__c', 'Informacoes_de_Custo_do_Produto' );
        Id idRecTypeProd = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
        Id idRecTypeInv = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro' );
        
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        try{insert usuario;}catch(Exception e){} 
        
        //insert usuario;
       


        //Cria nova UDC
        
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        //insert regional;
        try{insert regional;}catch(Exception e){}
        
        Account lAcc = new Account();
        lAcc.Name = 'Teste';
        lAcc.Revenue_UF__c = 'SP';
        lAcc.Corporate_Name__c = 'Teste';
        lAcc.Status__c = 'Cliente cadastrado no JDE';
        lAcc.CNPJ__c = '65746267000178';
        lAcc.Regional__c = regional.id;
        lAcc.RecordTypeId = idRecTypeAcc;
        lAcc.Segmentation_Type_on_trade__c = 'Bar';
        lAcc.Rating = 'Cliente';
        //insert lAcc;
        try{insert lAcc;}catch(Exception e){}
        
        LAT_Contract__c lContrato = new LAT_Contract__c();
        lContrato.Account__c = lAcc.id;
        lContrato.Status__c = 'Em elaboração';
        lContrato.StartDate__c = System.today();
        lContrato.ContractTerm__c = 12;
        lContrato.OwnerId = usuario.Id;
        lContrato.trigger_on__c = true;
        lContrato.RecordTypeId = idrecTypeLatCon;
        //insert lContrato;
        //try{insert lContrato;}catch(Exception e){}
        
        LAT_Product__c lProd = new LAT_Product__c();
        lProd.LAT_Description__c = 'Cachaca';
        lProd.Name = 'Cachaca';
        lProd.LAT_ExternalID__c = 'asdad';
        lProd.RecordTypeId = idRecTypeProd;
        
        //insert lProd;
        try{insert lProd;}catch(Exception e){}
        
        Informacoes_do_Produto__c IP = new Informacoes_do_Produto__c();
        IP.Scheduler_C__c = lProd.LAT_Scheduler__c;
        IP.Tx_Conversao__c = 2;
        IP.RecordTypeId = idRecTypeIP;
        IP.Produto_Bonificado__c = true;
        //insert IP;
        try{insert IP;}catch(Exception e){}
        
        Informacoes_de_Custo_do_Produto__c ICP = new Informacoes_de_Custo_do_Produto__c();
        ICP.UF__c = lAcc.Revenue_UF__c;
        ICP.Scheduler_C__c = IP.id;
        ICP.Custo_LD__c = 1;
        ICP.Custo_Distribuidor__c = 1.2;
        ICP.RecordTypeId = idRecTypeICP;
        //insert ICP;
        try{insert ICP;}catch(Exception e){}
        
        Investimento_Bonificacao_e_Pagamento__c IBP = new Investimento_Bonificacao_e_Pagamento__c();
        IBP.LAT_Contract__c = lContrato.Id;
        IBP.LAT_Product__c = lProd.id;
        IBP.Volume_Cx__c = 10;
        IBP.Data_de_Previsao_do_Pagamento__c = System.today() ;
        IBP.RecordTypeId = idRecTypeInv;
        IBP.ScheduleC_Bonificado__c = IP.Id;
        //insert IBP;
        try{insert IBP;}catch(Exception e){}
    }
}