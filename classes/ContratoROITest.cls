/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Classe de teste para a trigger ContratoROI.trigger e classe ContratoROI_Aux.cls
* NAME: ContratoROITest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 24/07/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE: REMOVIDO CÓDIGOS COMENTADOS QUE NÃO ESTAVAM EM UTILIZAÇÃO.
* AUTHOR: CARLOS CARVALHO                                      DATE: 10/01/2013
*
* AUTHOR: CARLOS CARVALHO                               DATE: 14/01/2013 
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS. 
*
* AUTHOR: CARLOS CARVALHO                               DATE: 28/01/2013
* DESC: CORRIGIDO TIPO DE REGISTRO PARA LAT_Contract__c.
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
@isTest
private class ContratoROITest {
    //MIGRATED 21/11/2016
    static testMethod void myUnitTest() {
      Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
      Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );

      Profile perfil =  [SELECT Id, Name, Description FROM Profile WHERE UserType = 'Standard' AND PermissionsAuthorApex = true AND name != 'System Administrator SESAME'  LIMIT 1];     
     

      User gerente = new User();
      gerente.FirstName           = 'Nome';
      gerente.LastName            = 'SobrenomeC';
      gerente.Alias               = 'NSobreC';
      gerente.Email               = 'gerenteC@sobrenome.com';
      gerente.Username            = 'devtestusercloud2b@cloud2b.com.br';
      gerente.CommunityNickname   = '123jjjuuu';
      gerente.EmailEncodingKey    = 'ISO-8859-1';
      gerente.TimeZoneSidKey      = 'GMT';
      gerente.LocaleSidKey        = 'en_Us';
      gerente.LanguageLocaleKey   = 'en_Us';
      gerente.C_digo_JDE__c       = '234';
      gerente.ProfileId           = perfil.Id;
      gerente.Country = 'BR';
        
      insert gerente;
      User usuario = new User();
      usuario.FirstName = 'nome';
      usuario.LastName = 'Sobrenome';
      usuario.Alias = 'NSobreU';
      usuario.Email = 'usuarioC@sobrenome.com';
      usuario.Username = 'devtestusercloud2b2@cloud2b.com.br';
      usuario.CommunityNickname = '1234jjuuu';
      usuario.EmailEncodingKey = 'ISO-8859-1';
      usuario.TimeZoneSidKey = 'GMT';
      usuario.LocaleSidKey = 'en_Us';
      usuario.LanguageLocaleKey = 'en_Us';
      usuario.C_digo_JDE__c = '235';
      usuario.ProfileId = perfil.Id;
      usuario.Country = 'BR';
      usuario.Gerente_de_area__c  = gerente.Id;
      usuario.Gerente_regional__c = gerente.Id;

    
      insert usuario;

      Account acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'Conta teste Trigger';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.Status__c = 'Cliente cadastrado no CRM';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade');
      acc.Segmentation_Type_on_trade__c  = 'Bar';
      acc.Area_Manager__c = gerente.Id;
      acc.Regional_Manager__c = gerente.Id;   
      
      insert acc;       

      System.runAs(usuario){     

         LAT_Contract__c lContract = new LAT_Contract__c();
         lContract.OwnerId = usuario.Id;
         lContract.Account__c = acc.Id;
         lContract.Status__c = 'Em elaboração';
         lContract.StartDate__c = System.today();
         lContract.ContractTerm__c = 12;
         lContract.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Alteracao_de_contrato_on');
         lContract.Motivo_de_cancelamento_do_contrato__c = 'Fechamento da casa';
         lContract.Status_do_processo__c = 'Solicitação de cancelamento de contrato';
    
        Test.startTest();
        insert lContract;
        Test.stopTest();
      }   
    }

    //MIGRATED 21/11/2016
    static testMethod void myUnitTest2()
    {
        //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
        Set< Id > setRecTypeLatCon = new Set< Id >();
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
        setRecTypeLatCon.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));
      
      
                //Cria Regional
                Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
                UDC__c regional = new UDC__c(
                  CodDefUsuario__c = '2',
                  CodProd__c     = '01',
                  CodUs__c     = '01',
                  Internal_Id__c   = '1234',
                  RecordTypeId = idRecTypeUdc
                );
                //insert regional;
                try{insert regional;}catch(Exception e){}
                
                //Cria novo Account. 
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
                  Channel_Type__c = 'Indireto',
                  RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade')
                );
                //insert acc;
                try{insert acc;}catch(Exception e){}
                
                
                // Cria um contrato
                LAT_Contract__c lContrato = new LAT_Contract__c(
                  Account__c = acc.Id,
                  Status__c = 'Em elaboração',
                  StartDate__c = System.today(),
                  ContractTerm__c = 12,
                  Status_do_processo__c='Estudo em elaboração', 
                  RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Assinatura_de_contrato'),
                  ROI_Comentarios_Negativo__c = 'teste'
                );
                //insert lContrato;
                //try{insert lContrato;}catch(Exception e){}
      
        /*LAT_Contract__c c = [Select Account__c, Volume_absolut_100__c, Volume_Absolut_Elyx__c, Volume_Absolut_Flavors__c,
             Volume_Absolut_Vodka__c,*/ /*Volume_Ballantines_12Y__c, Volume_Ballantines_17Y__c,
             Volume_Ballantines_21Y__c, Volume_Ballantines_30Y__c, Volume_Ballantines_Finest__c,*/
           /*  Volume_Cachaca_Janeiro__c, Volume_Cachaca_Sao_Francisco__c, Volume_Chivas_Regal_12_Years__c,
             Volume_Chivas_Regal_18_Years__c, Volume_Chivas_Regal_25_Years__c, Volume_Domecq_Tradicional__c,
             Volume_Havana_Club_3_Anos__c, Volume_Havana_Club_7_anos__c, Volume_Havana_Club_Anejo_Reserva__c,
             Volume_Jameson_Standard__c, Volume_Jim_Beam_Black__c, Volume_Jim_Beam_White__c,
             Volume_Kahlua__c, Volume_Malibu_Nacional__c, Volume_Montilla_Cristal__c,
             Volume_Mumm_Champagne__c, Volume_Mumm_Espumante__c, Volume_Natu_Nobilis__c,
             Volume_Olmeca__c, Volume_Orloff__c, Volume_Passport_LBS__c, Volume_Perrier_Jouet__c,
             Volume_Perrier_Jouet_1_5L__c, Volume_Perrier_Jouet_Belle_Epoque__c, */
             /*Volume_Perrier_Jouet_Belle_Epoque_1_5L__c,*/ /*Volume_Royal_Salute__c, Volume_Royal_Salute_38YO__c,
             Volume_Sandeman__c, Volume_Teachers__c, Volume_Tezon__c, Volume_Wall_Street__c,
             Volume_Wyborowa_Exquisite__c, */
             
             //Portifolio Pernod Ricard
             /*Vodkas_importadas_Absolut__c, Vodkas_importadas_Absolut_Flavours__c,
             Vodkas_importadas_Wyborowa_Exquisite__c, Vodkas_importadas_Wyborowa__c,
             Vodkas_importadas_Absolut_Elyx__c, Vodkas_nacionais_Orloff__c,
             Whisky_Std_Ballantines_Finest__c,  Whisky_Premium_12_anos_Chivas_12__c,
             Whisky_Premium_12_anos_Ballantines_12__c, Whisky_Super_Premium_Chivas_18__c,
             Whisky_Super_Premium_Chivas_25__c, Whisky_Super_Premium_Royal_Salute__c,
             Whisky_Super_Premium_Ballantines_17__c,  Whisky_Super_Premium_Ballantines_21__c,
             Whisky_Super_Premium_Ballantines_30__c,  Whisky_Irlandes_Jameson__c,
             Whisky_Engarrafado_Passport__c,  Whisky_Engarrafado_Teachers__c,
             Whisky_Nacional_Natu_Nobilis__c, Whisky_Bourbon_Jim_Bean__c,
             Champagne_Perrier_Jouet_Belle_Epoque__c, Champagne_Perrier_Jouet_Grand_Brut__c,
             Champagne_Mumm_Cordon_Rouge__c,  Espumante_Mumm_Cuvee__c, Espumante_Mumm_Petit__c, 
             Rum_Importado_Havana_Club__c,  Rum_Nacional_Malibu__c, Rum_Nacional_Montila__c,
             Gin_Beefeater__c, Cachaca_Janeiro__c,  Licor_Kahlua__c, Licor_Ricard__c,
             Vinhos_Jacobs_Creek__c,  Vinhos_Marques_de_Arienzo__c, Vinhos_Graffigna__c,
             Cognac_Martell__c,
             
             //Contrapartidas de Visibilidade
             Visibilidade_do_produto__c, Tailor_made__c, Uniforme__c, Material__c,
             Venda_de_Garrafa__c, Incentivo_da_Brigada__c, Comunicacao__c, Festas_Eventos__c,
             Cardapio__c, Consultoria_de_Mixologistas__c, Projetos_Especiais__c, Ativacao__c,
             
             // Visibilidade
             Armarios_de_Clube_da_Vodka__c, Armarios_de_Clube_de_Whisky__c,
             Prateleiras_dos_Bares__c, Cabine_de_DJ__c,
             
             // Acordo Promocional
             Prioridade_venda_Vodkas_Nacionais__c, Prioridade_venda_Vodka_Super_Premium__c,
             Prioridade_venda_Whisky_Nacional__c, Prioridade_venda_Whiskie_Americano__c,
             Prioridade_venda_Whiskie_Irlandes__c, Prioridade_venda_Whisky_12_anos__c,
             Prioridade_venda_Rum_Nacional__c, Prioridade_venda_Champagne__c,
             Prioridade_venda_Vinhos__c, Exclusiv_promoc_Vodkas_Nacionais__c,
             Exclusiv_promoc_Vodka_Super_Premium__c, Exclusiv_promoc_Whisky_Nacional__c,
             Exclusiv_promoc_Whiskie_Bourbon__c, Exclusiv_promoc_Whiskie_Irlandes__c,
             Exclusiv_promoc_Whisky_12_anos__c, Exclusiv_promoc_Rum_Nacional__c, Exclusiv_promoc_Champagne__c,
             Exclusiv_promoc_Vinhos__c, Exclusiv_visual_Vodkas_Nacionais__c, Exclusiv_visual_Vodka_Super_Premium__c,
             Exclusiv_visual_Whisky_Nacional__c, Exclusiv_visual_Whiskie_Bourbon__c,
             Exclusiv_visual_Whiskie_Irlandes__c, Exclusiv_visual_Whisky_12_anos__c,
             Exclusiv_visual_Rum_Nacional__c, Exclusiv_visual_Champagne__c, Exclusiv_visual_Vinhos__c,
             Prioridade_venda_Vodkas_Importadas__c, Prioridade_venda_Tequila_Std__c,
             Prioridade_venda_Whisky_Engarrafado__c, Prioridade_venda_Tequila_S_Premium__c,
             Prioridade_venda_Whisky_Std__c, Prioridade_venda_Whisky_Super_Premium__c,
             Prioridade_venda_Rum_Importado__c, Prioridade_venda_Espumantes__c,
             Exclusiv_promoc_Vodkas_Importadas__c, Exclusiv_promoc_Tequila__c, Exclusiv_promoc_Whisky_Engarrafado__c,
             Exclusiv_promoc_Tequila_super_premium__c, Exclusiv_promoc_Whisky_Std__c,
             Exclusiv_promoc_Whisky_Super_Premium__c, Exclusiv_promoc_Rum_Importado__c,
             Exclusiv_promoc_Espumantes__c, Exclusiv_visual_Vodkas_Importadas__c, Exclusiv_visual_Tequila__c,
             Exclusiv_visual_Whisky_Engarrafado__c, Exclusiv_visual_Tequila_super_premium__c,
             Exclusiv_visual_Whisky_Std__c, Exclusiv_visual_Whisky_Super_Premium__c,
             Exclusiv_visual_Rum_Importado__c, Exclusiv_visual_Espumantes__c,
             
             // Detalhamento
             Pecas_Tailor_Made_Quantidade__c, Pecas_Tailor_Made_Ambiente_Local1__c,
             Pecas_Tailor_Made_Ambiente_Local2__c, Pecas_Tailor_Made_Ambiente_Local3__c, 
             Pecas_Tailor_Made_Marcas1__c, Pecas_Tailor_Made_Marcas2__c,
             Pecas_Tailor_Made_Marcas3__c,
             
             Volume_Ballantine_s_12Y__c, Volume_Ballantine_s_17Y__c, Volume_Ballantine_s_21Y__c,
             Volume_Ballantine_s_30Y__c, Volume_Ballantine_s_Finest__c, 
             Volume_Perrier_Jouet_Belle_Epq1_5L__c
             
             From LAT_Contract__c WHERE RecordTypeId =: setRecTypeLatCon limit 1];*/
             
          ContratoROI_Aux.getClassPotencial( 1 );
          ContratoROI_Aux.getKPIFinanceiro( 1 );
          //ContratoROI_Aux.getPontosVisibilidade( c, 'Bar' );
          ContratoROI_Aux.getClassifVisibilidade( 'Bar', 1 );
          ContratoROI_Aux.getNetSales( 1, 'ROI_NetSales_Absolut_100__c', 'SP' );
          ContratoROI_Aux.getGMDC( 1, 'ROI_NetSales_Absolut_100__c', 'SP' );
          ContratoROI_Aux.getVMA( 1, 'ROI_NetSales_Absolut_100__c', 'SP' );
          //ContratoROI_Aux.getMixProdutos( c, 'SP' );
    }
}