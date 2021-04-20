@isTest
public class LAT_WS_CustomerHandlerInterface_Test {

      @testSetup
      public static void testSetup(){
            delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
            List<UDC__c> tabelas = new List<UDC__c>();
              Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );  
              // Politicas Preco UDC 05
              tabelas.add(new UDC__c(
                  CodDefUsuario__c = '1JD',
                  CodProd__c = '01',
                  CodUs__c ='05',
                  Name = '102A-SP',
                  Internal_Id__c = '1-1JD-01-05',
                  RecordTypeId = idRecTypeUdc
                  ));
              tabelas.add(new UDC__c(
                  CodDefUsuario__c = '1IO',
                  CodProd__c = '01',
                  CodUs__c ='05',
                  Name = '101A-RJ',
                  Internal_Id__c = '1-1IO-01-05',
                  RecordTypeId = idRecTypeUdc

                  ));

             // UDC 03 (CANAL/SUBCANAL/SEGM)
             tabelas.add(new UDC__c(
                  CodDefUsuario__c = '1',
                  CodProd__c = '01',
                  CodUs__c ='03',
                  Name = 'DISTRIBUICAO',
                  Internal_Id__c = '1-1-01-03',
                  RecordTypeId = idRecTypeUdc
                  ));

             tabelas.add(new UDC__c(
                  CodDefUsuario__c = '11',
                  CodProd__c = '01',
                  CodUs__c ='03',
                  Name = 'ATACADO',
                  Internal_Id__c = '1-11-01-03',
                  RecordTypeId = idRecTypeUdc
                  ));

             tabelas.add(new UDC__c(
                  CodDefUsuario__c = '116',
                  CodProd__c = '01',
                  CodUs__c ='03',
                  Name = 'LOCAL',
                  Internal_Id__c = '1-116-01-03',
                  RecordTypeId = idRecTypeUdc
                  ));

             // udc 20 (client type)
              tabelas.add(new UDC__c(
                  CodDefUsuario__c = '9',
                  CodProd__c = '01',
                  CodUs__c ='20',
                  Name = 'COM FATURAMENTO',
                  Internal_Id__c = '1-9-01-20',
                  RecordTypeId = idRecTypeUdc
                  ));

                  // udc 18 (estrategia)
              tabelas.add(new UDC__c(
                  CodDefUsuario__c = '7',
                  CodProd__c = '01',
                  CodUs__c ='18',
                  Name = 'ESPECIALIZADO',
                  Internal_Id__c = '1-7-01-18',
                  RecordTypeId = idRecTypeUdc
                  ));


             //uf for account

             tabelas.add(new UDC__c(
                  CodDefUsuario__c = '116',
                  CodProd__c = '00',
                  CodUs__c ='CT',
                  Name = 'ABADIA DE GOIAS',
                  Internal_Id__c = '1-5200050-00-CT',
                  Descricao2__c = 'GO',
                  RecordTypeId = idRecTypeUdc
                  ));


             insert tabelas;

             // CONFIG PARAMS
             List<LAT_BR_Segmentation2Params__c> params= new List<LAT_BR_Segmentation2Params__c>();
             params.add(new LAT_BR_Segmentation2Params__c(Name = 'q1_canal_negocio__c',
              QuestionNumber__c = 'q1_canal_negocio__c' ,
              ShortValue__c =  'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.',Longdescription__c ='test', 
              relatedApiField__c = 'Channel__c', relatedFieldValue__c = 'DISTRIBUICAO'));

             params.add(new LAT_BR_Segmentation2Params__c(Name = 'q2_relacao_comercial__c',
              QuestionNumber__c = 'q2_relacao_comercial__c' ,
              ShortValue__c =  '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).',Longdescription__c ='test', 
              relatedApiField__c = 'Client_type__c', relatedFieldValue__c = 'COM FATURAMENTO'));


             params.add(new LAT_BR_Segmentation2Params__c(Name = 'q3_Qual_o_principal_escopo_do_neg_cio__c',
              QuestionNumber__c = 'q3_Qual_o_principal_escopo_do_neg_cio__c' ,
              ShortValue__c =  '132121-Atua como extensão das indústrias na distribuição dos produtos, mas com pouco ou nenhum foco em execução no ponto de venda. A principal característica é a capilaridade de distribuição, com estrutura de custos e margens reduzida',Longdescription__c ='test', 
              relatedApiField__c = 'Sub_channel__c', relatedFieldValue__c = 'ATACADO'));

              params.add(new LAT_BR_Segmentation2Params__c(Name = 'q4_Qual_a_principal_rea_abordagem__c',
              QuestionNumber__c = 'q4_Qual_a_principal_rea_abordagem__c' ,
              ShortValue__c =  '132121-1 Estado',Longdescription__c ='test', 
              relatedApiField__c = 'Segment__c', relatedFieldValue__c = 'LOCAL'));


              params.add(new LAT_BR_Segmentation2Params__c(Name = 'q5_Qual_o_principal_p_blico__c',
              QuestionNumber__c = 'q5_Qual_o_principal_p_blico__c' ,
              ShortValue__c =  '132121-Portfólio especializado na categoria de bebidas alcoólicas',Longdescription__c ='test', 
              relatedApiField__c = 'Perfil__c', relatedFieldValue__c = 'ESPECIALIZADO'));


              params.add(new LAT_BR_Segmentation2Params__c(Name = 'q6_Qual_o_formato_do_negocio__c',
              QuestionNumber__c = 'q6_Qual_o_formato_do_negocio__c' ,
              ShortValue__c =  '131121-N.A',Longdescription__c ='test', 
              relatedApiField__c = 'FORMATO__c', relatedFieldValue__c = 'N.A'));


              params.add(new LAT_BR_Segmentation2Params__c(Name = 'q7_Qual_modelo_de_neg_cio_do_cliente__c',
              QuestionNumber__c = 'q7_Qual_modelo_de_neg_cio_do_cliente__c' ,
              ShortValue__c =  '132121-Clientes que, devido a características específicas da regiões que atuam (ausência de distribuidores), desempenham um papel estratégico de distribuição, chegando a pontos de vendas que normalmente seriam atendidos pelos distribuidores',Longdescription__c ='test', 
              relatedApiField__c = 'Estrategia_comercial__c', relatedFieldValue__c = 'ESTRATEGICO'));


              params.add(new LAT_BR_Segmentation2Params__c(Name = 'q8_cliente_possui_benefcio_Fiscal__c',
              QuestionNumber__c = 'q8_cliente_possui_benefcio_Fiscal__c' ,
              ShortValue__c =  '132121-Possui regime especial de tributação que envolve uma vantagem ou simplesmente um desagravamento fiscal perante o regime normal, assumindo-se como uma forma de isenção, redução de taxas, deduções, amortizações e/ou outras medidas fiscais dessa natur',Longdescription__c ='test', 
              relatedApiField__c = 'Beneficio_Fiscal__c', relatedFieldValue__c = 'COM BENEFÍCIO FISCAL'));

              params.add(new LAT_BR_Segmentation2Params__c(Name = 'q9_Qual_a_importancia_do_cliente_para_PR__c',
              QuestionNumber__c = 'q9_Qual_a_importancia_do_cliente_para_PR__c' ,
              ShortValue__c =  'Cliente estratégico para receber um tratamento diferenciado no que diz respeito a investimentos, confecção de planos e gestão de performance. Troca de informações sistematizada é mandatória.',Longdescription__c ='test', 
              relatedApiField__c = 'PRIOR_DE_INVESTIMENTO__c', relatedFieldValue__c = 'BYE'));

              insert params;

            // Add demantra configs
            LAT_BR_PoliticaPrecoConfig__c config = new LAT_BR_PoliticaPrecoConfig__c(
                  Beneficio_Fiscal__c = '',
                  Channel__c = '1',
                  Client_type__c  = '12',
                  Estrategia_comercial__c = '7',
                  Formato__c  = '17',
                  //Perfil_Codigo_Demantra__c   = '101A-RJ',
                  Perfil_Desc_Demantra__c ='101A-RJ',
                 // Perfil_Portfolio__c  = '1',
                  Politica_de_Preco__c    = '1IO',
                  //Prioridade_de_Investimento__c = '12',   
                  Segment__c  = '116',
                  Sub_channel__c  = '11',
                  UF__c = 'GO'
            );
            insert config;


            List<LAT_GeneralConfig__c>  generalConfigs= new List<LAT_GeneralConfig__c> ();
            generalConfigs.add( new LAT_GeneralConfig__c(
                              Name = 'POLITICA_PRECO_MAPPING',
                              LAT_Value__c = 'Channel__c'));
            generalConfigs.add( new LAT_GeneralConfig__c(
                              Name = 'POLITICA_PRECO_MAPPING1',
                              LAT_Value__c = 'Sub_channel__c'));
            generalConfigs.add( new LAT_GeneralConfig__c(
                              Name = 'POLITICA_PRECO_MAPPING2',
                              LAT_Value__c = 'Segment__c'));
            generalConfigs.add( new LAT_GeneralConfig__c(
                              Name = 'POLITICA_PRECO_MAPPING3',
                              LAT_Value__c = 'Uf__c'));
            generalConfigs.add( new LAT_GeneralConfig__c(
                              Name = 'POLITICA_PRECO_MAPPING4',
                              LAT_Value__c = 'Estrategia_comercial__c'));
            generalConfigs.add(new LAT_GeneralConfig__c(
                  Name = 'AR_CANT_UPDATE_BASIC_INFO_FIELDS_PROF',
                        LAT_Value__c = 'LAT_AR2_Vendedor'));
            insert generalConfigs;

      }
      
      public static Account createAccountFromScratch() {
            PageReference pageRef = Page.LAT_BR_SegmentationSlct;
            Test.setCurrentPage(pageRef);
            LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
            controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
            controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
            controllerNew.brAcc.Name = 'testAcc';
            controllerNew.brAcc.TriggerRun__c = true;
            controllerNew.brAcc.Revenue_UF__c         = 'SP';
            controllerNew.brAcc.State_registration__c = '110.042.490.114';
            controllerNew.CreateClient();
            return controllerNew.brAcc;

      }
      
      @isTest 
      static void customerHandlerInterfaceTest () {
            //Declaração de variáveis.
            Account acc, acc2                  = null;
            UDC__c regional, bandeira, cidade  = null;
            Profile perfil                     = null;
            User usuario                       = null;
            List <RecordType> listRecType      = null;
            List <String> developerName        = null;
            Map <String, String> mapRecType    = null;
            String idAccount                   = null;
            
            //Load RecordTypes
            idAccount = RecordTypeForTest.getRecType('Account','On_Trade');
            
            //Load Profile
            usuario = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' LIMIT 1];
            //Creates UDC
            regional                  = new UDC__c();//
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c       = '01';
            regional.CodUs__c         = '01';
            regional.Internal_Id__c   = '1234';
            regional.RecordTypeId     = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
            insert regional;
            
            //Creates UDC
            bandeira                  = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c       = '01';
            bandeira.CodUs__c         = '06';
            bandeira.Internal_Id__c   = '1236';
            bandeira.RecordTypeId     = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
            insert bandeira;
          
            //Create Account to Update
            Account argOnTrade               = LAT_Account_TestFactory.getAccountOnTradeArgComplete();
            argOnTrade.OwnerId               = usuario.Id;
            argOnTrade.Regional__c           = regional.Id;
            argOnTrade.Customer_Flag__c      = bandeira.Id;
            argOnTrade.Revenue_UF__c         = 'SP';
            argOnTrade.State_registration__c = '110.042.490.114';
            try {insert argOnTrade;} catch (Exception e){}
            Test.startTest();
            //Account a = [SELECT Id FROM Account WHERE RecordTypeId IN :]
            
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
            try{LAT_WS_CustomerHandlerInterface.CustomerInterfaceJDESync(argOnTrade);}catch(Exception e){}
            Test.stopTest();
      }

      
      @isTest 
      static void customerHandlerInterfaceTest2 () {
            //Declaração de variáveis.
            Account acc, acc2                  = null;
            UDC__c regional, bandeira, cidade  = null;
            Profile perfil                     = null;
            User usuario                       = null;
            List <RecordType> listRecType      = null;
            List <String> developerName        = null;
            Map <String, String> mapRecType    = null;
            String idAccount                   = null;
            
            //Load RecordTypes
            idAccount = RecordTypeForTest.getRecType('Account','ACC_1_OffTrade_ARG');
            
            //Load Profile
            usuario = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' LIMIT 1];
                  
            //Creates UDC
            regional                  = new UDC__c();//
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c       = '01';
            regional.CodUs__c         = '01';
            regional.Internal_Id__c   = '1234';
            regional.RecordTypeId     = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
            insert regional;
            
            //Creates UDC
            bandeira                  = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c       = '01';
            bandeira.CodUs__c         = '06';
            bandeira.Internal_Id__c   = '1236';
            bandeira.RecordTypeId     = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
            insert bandeira;
          
            //Create Account to Update
            Account argOnTrade               = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
            argOnTrade.OwnerId               = usuario.Id;
            //braOnTrade.Regional__c           = regional.Id;
            //braOnTrade.Customer_Flag__c      = bandeira.Id;
            //argOnTrade.Revenue_UF__c         = 'SP';
            argOnTrade.State_registration__c = '110.042.490.114';
            insert argOnTrade;
            Test.startTest();
            argOnTrade.State_registration__c = '110.042.490.115';
            update argOnTrade;

                        
            //try {insert argOnTrade;} catch (Exception e){}

            //Account a = [SELECT Id FROM Account WHERE RecordTypeId IN :]
            
            
            
            
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
            try{LAT_WS_CustomerHandlerInterface.CustomerInterfaceJDESync(argOnTrade);}catch(Exception e){}
            //LAT_WS_CustomerHandlerInterface.CustomerInterfaceJDE(argOnTrade.Id);
            LAT_WS_CustomerHandlerInterface.getAccounts(new List<String>{argOnTrade.id});
            LAT_WS_CustomerHandlerInterface.updateCustomerStatus(new List<String>{argOnTrade.id});
                  
            Test.stopTest();
      }
      
      @isTest 
      static void customerHandlerInterfaceTest3 () {
            //Declaração de variáveis.
            Account acc, acc2                  = null;
            UDC__c regional, bandeira, cidade    = null;
            Profile perfil                     = null;
            User usuario                       = null;
            List <RecordType> listRecType      = null;
            List <String> developerName        = null;
            Map <String, String> mapRecType    = null;
            String idAccount                   = null;
            
            //Load RecordTypes
            idAccount = RecordTypeForTest.getRecType('Account','ACC_1_OffTrade_ARG');
            
            //Load Profile
            usuario = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' LIMIT 1]; 

            //Creates UDC
            regional                  = new UDC__c();//
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c       = '01';
            regional.CodUs__c         = '01';
            regional.Internal_Id__c   = '1234';
            regional.RecordTypeId     = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
            insert regional;
            
            //Creates UDC
            bandeira                  = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c       = '01';
            bandeira.CodUs__c         = '06';
            bandeira.Internal_Id__c   = '1236';
            bandeira.RecordTypeId     = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
            insert bandeira;
          
            //Create Account to Update
            String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
              
            Account accMx = new Account(
                  Name = 'TEST',
                  AccountNumber = '1000', 
                  Type = 'Payer',
                  Phone = '1-11-1111-1111',
                  Fax = '11-1111-1111',
                  Notes__c = 'TEST',
                  AddressLine1_AR__c = 'TEST',
                  CNPJ__c = 'LOZM701213E52',
                  Corporate_Name__c = 'TEST',
                  Channel__c = 'WS',
                  Status__c = 'Cliente cadastrado no JDE',
                  Segmentation_Type_on_trade__c = 'MOP',
                  RecordTypeId = rtOffMX
            );
            accMx.State_registration__c = '110.042.490.114';
            insert accMx;
            accMx.State_registration__c = '110.042.490.115';
            Test.startTest(); 
            update accMx;

                        
            //try {insert argOnTrade;} catch (Exception e){}

            //Account a = [SELECT Id FROM Account WHERE RecordTypeId IN :]
            
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
            try{LAT_WS_CustomerHandlerInterface.CustomerInterfaceJDESync(accMx);}catch(Exception e){}
            //LAT_WS_CustomerHandlerInterface.CustomerInterfaceJDE(argOnTrade.Id);
            LAT_WS_CustomerHandlerInterface.getAccounts(new List<String>{accMx.id});
            LAT_WS_CustomerHandlerInterface.updateCustomerStatus(new List<String>{accMx.id});
                  
            Test.stopTest();
      }

      @isTest 
      static void customerHandlerInterfaceTest8 () { 
            LAT_WS_CustomerHandlerRequestResponseTyp.AsyncIntegrationResponseType response = new LAT_WS_CustomerHandlerRequestResponseTyp.AsyncIntegrationResponseType(); 
            try { LAT_WS_CustomerHandlerInterface.decodePhone('jejeje');} catch(Exception Ex) {}
            try { LAT_WS_CustomerHandlerInterface.castBooleantoJDE(true);} catch(Exception Ex) {}
            try { LAT_WS_CustomerHandlerInterface.getConnectionParameter('mx');} catch(Exception Ex) {}
            try { LAT_WS_CustomerHandlerInterface.CustomerInterfaceJDE('mx');} catch(Exception Ex) {}
            
            try {LAT_WS_CustomerHandlerInterface.getConnectionParameter('mx');} catch(Exception Ex) {}

            response.errorCode = '0';
            try { LAT_WS_CustomerHandlerInterface.parseResponse(response,new Account());} catch(Exception Ex) {}
            
            response.errorCode = '-2';
            try { LAT_WS_CustomerHandlerInterface.parseResponse(response,new Account());} catch(Exception Ex) {}
            
            response.errorCode = '-4';
            try { LAT_WS_CustomerHandlerInterface.parseResponse(response,new Account());} catch(Exception Ex) {}
            
            response.errorCode = '-5';
            try { LAT_WS_CustomerHandlerInterface.parseResponse(response,new Account());} catch(Exception Ex) {}
            
            response.errorCode = '-6';
            try { LAT_WS_CustomerHandlerInterface.parseResponse(response,new Account());} catch(Exception Ex) {}
            
            response.errorCode = '-9';
            try { LAT_WS_CustomerHandlerInterface.parseResponse(response,new Account()); } catch(Exception Ex) {}
            
            response.errorCode = '-45';
            try { LAT_WS_CustomerHandlerInterface.parseResponse(response,new Account()); } catch(Exception Ex) {}
      }
      @isTest 
      static void customerHandlerInterfaceTest4 () {
            //Declaração de variáveis.
            Account acc, acc2                  = null;
            UDC__c regional, bandeira, cidade  = null;
            Profile perfil                     = null;
            User usuario                       = null;
            List <RecordType> listRecType      = null;
            List <String> developerName        = null;
            Map <String, String> mapRecType    = null;
            String idAccount                   = null;
            
            //Load RecordTypes
            idAccount = RecordTypeForTest.getRecType('Account','On_Trade');
            
            //Load Profile
            usuario = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' LIMIT 1];
            //Creates UDC
            regional                  = new UDC__c();//
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c       = '01';
            regional.CodUs__c         = '01';
            regional.Internal_Id__c   = '1234';
            regional.RecordTypeId     = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
            
            //Creates UDC
            bandeira                  = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c       = '01';
            bandeira.CodUs__c         = '06';
            bandeira.Internal_Id__c   = '1236';
            bandeira.RecordTypeId     = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');

            insert new List<UDC__c>{bandeira, regional};
            //Create Account to Update
            Test.startTest();
            Account braOnTrade               = createAccountFromScratch();
            braOnTrade.OwnerId               = usuario.Id;

            //Account a = [SELECT Id FROM Account WHERE RecordTypeId IN :]
            
            Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.stopTest();
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
            try{LAT_WS_CustomerHandlerInterface.CustomerInterfaceJDESync(braOnTrade);}catch(Exception e){}
                  
            
      }

      @isTest 
      static void customerHandlerInterfaceTest5 () {
            LAT_WS_CustomerHandlerRequestResponseTyp.AsyncIntegrationResponseType resp = new LAT_WS_CustomerHandlerRequestResponseTyp.AsyncIntegrationResponseType();
            resp.errorCode = '-9';
            
            //Declaração de variáveis.
            Account acc, acc2                  = null;
            UDC__c regional, bandeira, cidade  = null;
            Profile perfil                     = null;
            User usuario                       = null;
            List <RecordType> listRecType      = null;
            List <String> developerName        = null;
            Map <String, String> mapRecType    = null;
            String idAccount                   = null;
            
            //Load RecordTypes
            idAccount = RecordTypeForTest.getRecType('Account','On_Trade');
            
            //Load Profile
            usuario = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' LIMIT 1];
            //Creates UDC
            regional                  = new UDC__c();//
            regional.CodDefUsuario__c = '4546';
            regional.CodProd__c       = '01';
            regional.CodUs__c         = '01';
            regional.Internal_Id__c   = '1234';
            regional.RecordTypeId     = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
            
            //Creates UDC
            bandeira                  = new UDC__c();
            bandeira.CodDefUsuario__c = '179';
            bandeira.CodProd__c       = '01';
            bandeira.CodUs__c         = '06';
            bandeira.Internal_Id__c   = '1236';
            bandeira.RecordTypeId     = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');

            insert new List<UDC__c>{bandeira, regional};
            //Create Account to Update
            Test.startTest();
            Account braOnTrade               = createAccountFromScratch();
            braOnTrade.OwnerId               = usuario.Id;
            Test.stopTest();
            LAT_WS_CustomerHandlerInterface.parseResponse(resp, braOnTrade);
                  
            
      }
}