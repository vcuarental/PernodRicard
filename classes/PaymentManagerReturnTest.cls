@isTest/*(seeAllData=true)*/
/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe que faz o teste de cobertura da classe PaymentManagerReturn
* NAME: PaymentManagerReturnTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 24/08/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 16/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/
private class PaymentManagerReturnTest{

    static testMethod void myUnitTest1(){
        Utils.setMigrationDoneTest(false); 
      
        //Cria nova UDC.
        UDC__c regional = new UDC__c(
            CodDefUsuario__c = '2',
            CodProd__c     = '01',
            CodUs__c     = '01',
            Internal_Id__c   = '1234',
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
        );
        //insert regional;
        try{insert regional;}catch(Exception e){}
        
        //Cria nova conta.
        Account acc = new Account(
            Name = 'Conta teste Trigger',
            CNPJ__c = '48843971000120',
            Type = 'Outros',
            Status__c = 'Cliente cadastrado no JDE',
            Agency__c = '000',
            Checking_account__c = '000',
            Current_account__c = '0',
            Corporate_Name__c = 'Teste',
            Regional__c = regional.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Segmentation_Type_on_trade__c = 'Bar',
            Rating = 'Cliente'
        );
        //insert acc;
        try{insert acc;}catch(Exception e){}
        
        //Cria novo contrato.
        LAT_Contract__c lContract = new LAT_Contract__c(
            Account__c = acc.Id,
            Status__c = 'Em elaboração',
            StartDate__c = System.today(),
            ContractTerm__c = 12,
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract__c' + 'Assinatura_de_contrato'),
            ROI_Comentarios_Negativo__c = 'teste'
        );
        //insert lContract;
        try{insert lContract;}catch(Exception e){}
        
        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Investimento_Bonificacao_e_Pagamento__c' + 'Dinheiro'),
            Data_de_Previsao_do_Pagamento__c = system.today() + 10,
            Finalidade__c = 'Contrato',
            LAT_Contract__c = lContract.id,
            Valor_R__c = 100,
            Status_da_Verba__c = 'Reservado',
            Conta_IBP__c = acc.id
        );
        //insert ibp;
        try{insert ibp;}catch(Exception e){}
          
        //Recupera o ID do perfil desejado.
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        //insert usuario;
        try{insert usuario;}catch(Exception e){}
          
          
        Pagamento__c lPagto = new Pagamento__c(
            Cliente__c = acc.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Pagamento__c' + 'Dinheiro'),
            OwnerId = usuario.Id
        );
        //insert lPagto;
        try{insert lPagto;}catch(Exception e){}
        
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Pagamento_da_Verba__c' + 'Dinheiro'),
            Pagamento__c = lPagto.id,
            Investimento_Bonifica_o_e_Pagamento__c = ibp.id,
            valor_a_pagar__c = 1.45,
            Conta__c = acc.id
        );
        //insert lPagtoVerba;
        try{insert lPagtoVerba;}catch(Exception e){}
      
        try{
            PaymentManagerReturn.paymentReturn( lPagto.id, 'Pago Totalmente', '', 0 );
        }catch(Exception e){
            system.debug(e.getMessage());
        } 
    }

    static testMethod void myUnitTest1B(){
        Utils.setMigrationDoneTest(true); 
      
        //Cria nova UDC.
        UDC__c regional = new UDC__c(
            CodDefUsuario__c = '2',
            CodProd__c     = '01',
            CodUs__c     = '01',
            Internal_Id__c   = '1234',
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
        );
        //insert regional;
        try{insert regional;}catch(Exception e){}
        
        //Cria nova conta.
        Account acc = new Account(
            Name = 'Conta teste Trigger',
            CNPJ__c = '48843971000120',
            Type = 'Outros',
            Status__c = 'Cliente cadastrado no JDE',
            Agency__c = '000',
            Checking_account__c = '000',
            Current_account__c = '0',
            Corporate_Name__c = 'Teste',
            Regional__c = regional.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Segmentation_Type_on_trade__c = 'Bar',
            Rating = 'Cliente'
        );
        //insert acc;
        try{insert acc;}catch(Exception e){}
        
        //Cria novo contrato.
        LAT_Contract__c lContract = new LAT_Contract__c(
            Account__c = acc.Id,
            Status__c = 'Em elaboração',
            StartDate__c = System.today(),
            ContractTerm__c = 12,
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract__c' + 'Assinatura_de_contrato'),
            ROI_Comentarios_Negativo__c = 'teste'
        );
        //insert lContract;
        try{insert lContract;}catch(Exception e){}
        
        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Investimento_Bonificacao_e_Pagamento__c' + 'Dinheiro'),
            Data_de_Previsao_do_Pagamento__c = system.today() + 10,
            Finalidade__c = 'Contrato',
            LAT_Contract__c = lContract.id,
            Valor_R__c = 100,
            Status_da_Verba__c = 'Reservado',
            Conta_IBP__c = acc.id
        );
        //insert ibp;
        try{insert ibp;}catch(Exception e){}
          
        //Recupera o ID do perfil desejado.
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        //insert usuario;
        try{insert usuario;}catch(Exception e){}
          
          
        Pagamento__c lPagto = new Pagamento__c(
            Cliente__c = acc.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Pagamento__c' + 'Dinheiro'),
            OwnerId = usuario.Id
        );
        //insert lPagto;
        try{insert lPagto;}catch(Exception e){}
        
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Pagamento_da_Verba__c' + 'Dinheiro'),
            Pagamento__c = lPagto.id,
            Investimento_Bonifica_o_e_Pagamento__c = ibp.id,
            valor_a_pagar__c = 1.45,
            Conta__c = acc.id
        );
        //insert lPagtoVerba;
        try{insert lPagtoVerba;}catch(Exception e){}
      
        try{
            PaymentManagerReturn.paymentReturn( lPagto.id, 'Pago Totalmente', '', 0 );
        }catch(Exception e){
            system.debug(e.getMessage());
        } 
    }
    
    static testMethod void myUnitTest2(){
        Utils.setMigrationDoneTest(false); 
      
        //Cria nova UDC.
        UDC__c regional = new UDC__c(
            CodDefUsuario__c = '2',
            CodProd__c     = '01',
            CodUs__c     = '01',
            Internal_Id__c   = '1234',
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
        );
        //insert regional;
        try{insert regional;}catch(Exception e){}
        
        //Cria nova conta.
        Account acc = new Account(
            Name = 'Conta teste Trigger',
            CNPJ__c = '48843971000120',
            Type = 'Outros',
            Status__c = 'Cliente cadastrado no JDE',
            Agency__c = '000',
            Checking_account__c = '000',
            Current_account__c = '0',
            Corporate_Name__c = 'Teste',
            Regional__c = regional.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Segmentation_Type_on_trade__c = 'Bar',
            Rating = 'Cliente'
        );
        //insert acc;
        try{insert acc;}catch(Exception e){}
        
        //Cria novo contrato.
        LAT_Contract__c lContract = new LAT_Contract__c(
            Account__c = acc.Id,
            Status__c = 'Em elaboração',
            StartDate__c = System.today(),
            ContractTerm__c = 12,
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract__c' + 'Assinatura_de_contrato'),
            ROI_Comentarios_Negativo__c = 'teste'
        );
        //insert lContract;
        try{insert lContract;}catch(Exception e){}
        
        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Investimento_Bonificacao_e_Pagamento__c' + 'Dinheiro'),
            Data_de_Previsao_do_Pagamento__c = system.today() + 10,
            Finalidade__c = 'Contrato',
            LAT_Contract__c = lContract.id,
            Valor_R__c = 100,
            Status_da_Verba__c = 'Reservado',
            Conta_IBP__c = acc.id
        );
        //insert ibp;
        try{insert ibp;}catch(Exception e){}
          
        //Recupera o ID do perfil desejado.
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        //insert usuario;
        try{insert usuario;}catch(Exception e){}
          
          
        Pagamento__c lPagto = new Pagamento__c(
            Cliente__c = acc.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Pagamento__c' + 'Dinheiro'),
            OwnerId = usuario.Id
        );
        //insert lPagto;
        try{insert lPagto;}catch(Exception e){}
        
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Pagamento_da_Verba__c' + 'Dinheiro'),
            Pagamento__c = lPagto.id,
            Investimento_Bonifica_o_e_Pagamento__c = ibp.id,
            valor_a_pagar__c = 1.45,
            Conta__c = acc.id
        );
        //insert lPagtoVerba;
        try{insert lPagtoVerba;}catch(Exception e){}
      
        try{
            PaymentManagerReturn.paymentReturn( lPagto.id, 'Pago Totalmente', '', 1 );
        }catch(Exception e){
            system.debug(e.getMessage());
        } 
    }

    static testMethod void myUnitTest2B(){
        Utils.setMigrationDoneTest(true); 
      
        //Cria nova UDC.
        UDC__c regional = new UDC__c(
            CodDefUsuario__c = '2',
            CodProd__c     = '01',
            CodUs__c     = '01',
            Internal_Id__c   = '1234',
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
        );
        //insert regional;
        try{insert regional;}catch(Exception e){}
        
        //Cria nova conta.
        Account acc = new Account(
            Name = 'Conta teste Trigger',
            CNPJ__c = '48843971000120',
            Type = 'Outros',
            Status__c = 'Cliente cadastrado no JDE',
            Agency__c = '000',
            Checking_account__c = '000',
            Current_account__c = '0',
            Corporate_Name__c = 'Teste',
            Regional__c = regional.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            Segmentation_Type_on_trade__c = 'Bar',
            Rating = 'Cliente'
        );
        //insert acc;
        try{insert acc;}catch(Exception e){}
        
        //Cria novo contrato.
        LAT_Contract__c lContract = new LAT_Contract__c(
            Account__c = acc.Id,
            Status__c = 'Em elaboração',
            StartDate__c = System.today(),
            ContractTerm__c = 12,
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract__c' + 'Assinatura_de_contrato'),
            ROI_Comentarios_Negativo__c = 'teste'
        );
        //insert lContract;
        try{insert lContract;}catch(Exception e){}
        
        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Investimento_Bonificacao_e_Pagamento__c' + 'Dinheiro'),
            Data_de_Previsao_do_Pagamento__c = system.today() + 10,
            Finalidade__c = 'Contrato',
            LAT_Contract__c = lContract.id,
            Valor_R__c = 100,
            Status_da_Verba__c = 'Reservado',
            Conta_IBP__c = acc.id
        );
        //insert ibp;
        try{insert ibp;}catch(Exception e){}
          
        //Recupera o ID do perfil desejado.
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        //insert usuario;
        try{insert usuario;}catch(Exception e){}
          
          
        Pagamento__c lPagto = new Pagamento__c(
            Cliente__c = acc.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Pagamento__c' + 'Dinheiro'),
            OwnerId = usuario.Id
        );
        //insert lPagto;
        try{insert lPagto;}catch(Exception e){}
        
        Pagamento_da_Verba__c lPagtoVerba = new Pagamento_da_Verba__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Pagamento_da_Verba__c' + 'Dinheiro'),
            Pagamento__c = lPagto.id,
            Investimento_Bonifica_o_e_Pagamento__c = ibp.id,
            valor_a_pagar__c = 1.45,
            Conta__c = acc.id
        );
        //insert lPagtoVerba;
        try{insert lPagtoVerba;}catch(Exception e){}
      
        try{
            PaymentManagerReturn.paymentReturn( lPagto.id, 'Pago Totalmente', '', 1 );
        }catch(Exception e){
            system.debug(e.getMessage());
        } 
    }

}