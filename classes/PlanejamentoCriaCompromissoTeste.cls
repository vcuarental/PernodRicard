@isTest(seeAllData=true)
/*******************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* REALIZA TESTE DE COBERTURA DO CÓDIGO: PlanejamentoCriaCompromisso.trigger
*
* NAME: PlanejamentoCriaCompromissoTeste.cls
* AUTHOR: CARLOS CARVALHO                          DATE: 21/05/2012 
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                          DATE: 24/09/2012
* DESC:  INSERIDO STATUS__c NOS OBJETOS DE VISITA__c
*
* AUTHOR: CARLOS CARVALHO                          DATE: 16/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
private class PlanejamentoCriaCompromissoTeste {

    static testMethod void PlanejamentoCriaCompromissoTeste(){
        //Declaração de variáveis.
        Account acc, acc2, acc3                 = null;
        Planejamento__c plan                    = null;
        Profile perfil                          = null;
        List<RecordType> listRecType            = null;
        List<String> developerName              = null;
        Map<String, String> mapRecType          = null;
        UDC__c regional, org, bandeira, classSub, banco, condicao, glCliente, instrumento, areaNielsen, regGeo  = null;
        String idAccount                        = null;
        Par_metro_Produto_Concorr_ncia__c param = null;
        CustomerRSPProducts__c customProd,customProd2,customProd3       = null;
        CustomerRSPProfiles__c customProfile,customProfile2,customProfile3  = null;
        Visitas__c visita, visita2 = null;
        Event compromisso = null;
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
        
        //Recupera os IDS de tipo de registro.
        idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');
        
        
        
        List<UDC__c> listUDC = new List<UDC__c>();
        
        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c   = '4546';
        regional.CodProd__c         = '01';
        regional.CodUs__c           = '01';
        regional.Internal_Id__c     = '4546';
        regional.RecordTypeId = idRecTypeUDC;
        listUDC.add(regional);
        
        //Cria nova UDC.
        org = new UDC__c();
        org.CodDefUsuario__c    = '171';
        org.CodProd__c          = '01';
        org.CodUs__c            = '10';
        org.Internal_Id__c      = '171';
        org.RecordTypeId = idRecTypeUDC;
        listUDC.add(org);
        
        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c   = '179';
        bandeira.CodProd__c         = '01';
        bandeira.CodUs__c           = '06';
        bandeira.Internal_Id__c = '179'; 
        bandeira.RecordTypeId = idRecTypeUDC;
        listUDC.add(bandeira);
        
        //Cria nova UDC.
        classSub = new UDC__c();
        classSub.CodDefUsuario__c   = '1889';
        classSub.CodProd__c         = '01';
        classSub.CodUs__c           = '03';
        classSub.Internal_Id__c     = '1889';
        classSub.RecordTypeId = idRecTypeUDC;
        listUDC.add(classSub);
        
        //Cria nova UDC.
        banco = new UDC__c();
        banco.CodDefUsuario__c  = '1234';
        banco.CodProd__c        = '76';
        banco.CodUs__c          = 'BC';
        banco.Internal_Id__c    = '1234';
        banco.RecordTypeId = idRecTypeUDC;
        listUDC.add(banco);
        
        //Cria nova UDC.
        condicao = new UDC__c();
        condicao.CodDefUsuario__c   = '1235';
        condicao.CodProd__c         = 'CRM';
        condicao.CodUs__c           = 'PT';
        condicao.Internal_Id__c     = '1235';
        condicao.RecordTypeId = idRecTypeUDC;
        listUDC.add(condicao);
        
        //Cria nova UDC.
        glCliente = new UDC__c();
        glCliente.CodDefUsuario__c  = '1236';
        glCliente.CodProd__c        = '55';
        glCliente.CodUs__c          = 'GL';
        glCliente.Internal_Id__c    = '1236';
        glCliente.RecordTypeId = idRecTypeUDC;
        listUDC.add(glCliente);
        
        //Cria nova UDC.
        instrumento = new UDC__c();
        instrumento.CodDefUsuario__c    = '1237';
        instrumento.CodProd__c          = '00';
        instrumento.CodUs__c            = 'PY';
        instrumento.Internal_Id__c      = '1237';
        instrumento.RecordTypeId = idRecTypeUDC;
        listUDC.add(instrumento);
        
        //Cria nova UDC.
        areaNielsen = new UDC__c();
        areaNielsen.CodDefUsuario__c    = '1238';
        areaNielsen.CodProd__c          = '01';
        areaNielsen.CodUs__c            = '04';
        areaNielsen.Internal_Id__c      = '1238';
        areaNielsen.RecordTypeId = idRecTypeUDC;
        listUDC.add(areaNielsen);
        
        //Cria nova UDC.
        regGeo = new UDC__c();
        regGeo.CodDefUsuario__c = '1239';
        regGeo.CodProd__c       = '01';
        regGeo.CodUs__c         = '11';
        regGeo.Internal_Id__c   = '1239';
        regGeo.RecordTypeId = idRecTypeUDC;
        listUDC.add(regGeo);
        
        insert listUDC;
        
        //Recupera o ID do perfil desejado.
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert usuario;  
        
         //Cria novo Account.
        acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'Conta PlanejamentoVisitasCriaVisitasTeste';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.RecordTypeId = idAccount;
        acc.Status__c = 'XXXX';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.Channel__c = 'Off Trade';
        acc.Regional__c = regional.Id;
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '557799';
        acc.Segmentation_Type_on_trade__c = 'Bar';
        acc.Rating = 'Cliente';
        
        try{
        insert acc;
        }
        catch(DMLException e){
            System.debug(e.getMessage());
        }
        
        test.startTest();
        
        //Cria novo planejamento.
        plan = new Planejamento__c();
        plan.Ano_de_Referencia__c = '2012';
        plan.M_s_de_Ref_rencia__c = 'Janeiro';
        plan.Name = 'Teste';
        plan.OwnerId = usuario.Id;
        plan.RecordTypeId = RecordTypeForTest.getRecType('Planejamento__c', 'BRA_Standard');
        insert plan;
        
        //Cria nova visita.
        visita = new Visitas__c();
        visita.Conta__c = acc.Id;
        visita.Name = 'NOME';
        visita.Data_da_Visita__c = System.today();
        visita.Hora_da_Visita__c = '08:00';
        visita.Planejamento__c = plan.Id;
        visita.Status__c = 'Planejada';
        visita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard');
        visita.Resumo_da_Visita__c = 'teste';
        insert visita;
 /*       
        //Cria nova visita.
        visita2 = new Visitas__c();
        visita2.Conta__c = acc.Id;
        visita2.Name = 'NOME';
        visita2.Data_da_Visita__c = System.today()-1;
        visita2.Hora_da_Visita__c = '08:00';
        visita2.Planejamento__c = plan.Id;
        visita2.Status__c = 'Planejada';
        visita2.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard');
        visita2.Resumo_da_Visita__c = 'teste';
        insert visita2;
   
   */    
        //Atualiza planejamento.
        /*plan.Aprovado_semana_1__c = true;
        update plan;*/
        
        //Cria novo compromisso.
        compromisso = new Event();
        compromisso.Subject = 'TESTE';
        compromisso.OwnerId = usuario.Id;
        compromisso.StartDateTime = System.now()-1;
        compromisso.EndDateTime = System.now()-1;
        compromisso.RecordTypeId = RecordTypeForTest.getRecType( 'Event', 'Planejamentovisitas' );
        insert compromisso;
    /*    
        //Atualiza planejamento.
        plan.Aprovado_semana_2__c = true;
        update plan;
    */     
        test.stopTest();  
 
    }
}