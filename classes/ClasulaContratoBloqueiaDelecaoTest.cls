@isTest(seeAllData=true)
/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* Realiza teste dos codigos: ClasulaContratoBloqueiaDelecaoTest e 
* DistribuicaoValoresBloqueiaMesmaData
*
* NAME: ClasulaContratoBloqueiaDelecaoTest.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 09/11/2012
*
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 09/01/2013 
*******************************************************************************/
private class ClasulaContratoBloqueiaDelecaoTest {

    static testMethod void myUnitTest() {
        
        //Recupera os Ids dos tipos de registro
        Id idRecTypeCC = RecordTypeForTest.getRecType('Cl_usulas_do_Contrato__c', 'Clausulas_do_Contrato');
        Id idRecTypeDV = RecordTypeForTest.getRecType('Distribui_o_de_Valores__c', 'BRA_Standard');
        Id idRecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato' );
        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
        Id idRecTypeAcc = RecordTypeForTest.getRecType('Account', 'Off_Trade');
        
        Account acc = null;
        LAT_Contract__c latCon = null;
        Profile perfil;
        User gerente, usuario;
        
        //Recupera um Perfil no ambiente 
        gerente = new User();
        gerente = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert gerente;
        
        //Cria novo usuario. 
        usuario = new User();
        usuario.FirstName           = 'nome';
        usuario.LastName            = 'Sobrenome';
        usuario.Alias               = 'NSobreU';
        usuario.Email               = 'usuarioC@sobrenome.com';
        usuario.Username            = 'devtestusercloud2b2@cloud2b.com.br';
        usuario.CommunityNickname   = '1234jjuuu';
        usuario.EmailEncodingKey    = 'ISO-8859-1';
        usuario.TimeZoneSidKey      = 'GMT';
        usuario.LocaleSidKey        = 'en_Us';
        usuario.LanguageLocaleKey   = 'en_Us';
        usuario.C_digo_JDE__c       = '235';
        usuario.ProfileId           = gerente.ProfileId;
        usuario.Gerente_de_area__c  = gerente.Id;
        usuario.Gerente_regional__c = gerente.Id;
        usuario.Country = 'BR';
        insert usuario;
        
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '2';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '01-01';
        regional.RecordTypeId = idRecTypeUdc;
        insert regional;
        
        //Cria novo Account. 
        acc = new Account();
        acc.OwnerId = usuario.Id;
        acc.Name = 'Conta teste Trigger';
        acc.CNPJ__c = '48843971000120';
        acc.Type = 'Outros';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Agency__c = '000';
        acc.Checking_account__c = '000';
        acc.Current_account__c = '0';
        acc.Corporate_Name__c = 'Teste';
        acc.Regional__c = regional.id;
        acc.RecordTypeId = idRecTypeAcc;
        insert acc;
        
        latCon = new LAT_Contract__c();
        latCon.OwnerId = usuario.Id;
        latCon.RecordTypeId = idRecTypeLatCon;
        latCon.Account__c = acc.Id;
        latCon.Status__c = 'Ativo';
        latCon.ROI_Comentarios_Negativo__c = 'Teste';
        latCon.StartDate__c = System.today();
        latCon.ContractTerm__c = 12;
        insert latCon;
        
        String lIdCon = latCon.Id;
        latCon = [ Select Id, EndDate__c From LAT_Contract__c Where Id =: lIdCon ];
        
        Cl_usulas_do_Contrato__c lCla = new Cl_usulas_do_Contrato__c();
        lCla.Contrato__c = latCon.Id;
        lCla.RecordTypeId = idRecTypeCC;
        insert lCla;
        
        Distribui_o_de_Valores__c lDis = new Distribui_o_de_Valores__c();
        lDis.Clausulas_do_Contrato__c = lCla.ID;
        lDis.Data_de_Referencia_para_Apuracao__c = latCon.EndDate__c-5;
        lDis.RecordTypeId = idRecTypeDV;
        insert lDis;
        
        Distribui_o_de_Valores__c lDis2 = new Distribui_o_de_Valores__c();
        lDis2.Clausulas_do_Contrato__c = lCla.ID;
        lDis2.Data_de_Referencia_para_Apuracao__c = latCon.EndDate__c-5;
        lDis2.RecordTypeId = idRecTypeDV;
        
        try{
            insert lDis2;
        }catch(DMLException e){
            System.debug(e.getMessage());
        }
        
        try{
          delete lCla;
        }catch(DMLException e){
          System.debug(e.getMessage());
        }
    }
}