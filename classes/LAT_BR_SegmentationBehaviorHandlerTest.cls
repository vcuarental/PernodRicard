/**
 * Test class for cover the new Segmentation BR handler code
 *
 */
@isTest
public with sharing class LAT_BR_SegmentationBehaviorHandlerTest {

    @testSetup
    public static void testSetup() {
         LAT_Docusign_Config__c dSconfig = new LAT_Docusign_Config__c
            (ds_Username__c = 'testUsername',
             ds_password__c='test',
             ds_integrationKey__c = 'test'
            );
        dSconfig.LAT_ComercialDirectorId__c = UserInfo.getUserId();
        dSconfig.LAT_FinancialDirectorId__c = UserInfo.getUserId();
        dSconfig.LAT_PresidentId__c = UserInfo.getUserId();
        dSconfig.LAT_TradeManagerId__c = UserInfo.getUserId();
        dSconfig.LAT_Testemunha_PRB_Id__c = UserInfo.getUserId();
        dSconfig.LAT_ComercialDirectorId_PRESTIGE__c = UserInfo.getUserId();
        dSconfig.LAT_FinancialDirectorId__c = UserInfo.getUserId();
        dSconfig.LAT_PresidentId__c = UserInfo.getUserId();
        dSconfig.LAT_TradeManagerId__c = UserInfo.getUserId();
        dSconfig.LAT_Testemunha_PRB_Id_PRESTIGE__c = UserInfo.getUserId();
        insert dSconfig;
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        List < UDC__c > tabelas = new List < UDC__c > ();
        
        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
        // Politicas Preco UDC 05
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '1JD',
            CodProd__c = '01',
            CodUs__c = '05',
            Name = '102A-SP',
            Internal_Id__c = '1-1JD-01-05',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '1',
            CodProd__c = '01',
            CodUs__c = '01',
            Name = 'REG SP',
            Internal_Id__c = '1-1-01-01',
            RecordTypeId = idRecTypeUdc
        ));
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '2',
            CodProd__c = '01',
            CodUs__c = '01',
            Name = 'REG NE',
            Internal_Id__c = '1-2-01-01',
            RecordTypeId = idRecTypeUdc
        ));
            
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '1IO',
            CodProd__c = '01',
            CodUs__c = '05',
            Name = '101A-RJ',
            Internal_Id__c = '1-1IO-01-05',
            RecordTypeId = idRecTypeUdc

        ));

        // UDC 03 (CANAL/SUBCANAL/SEGM)
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '1',
            CodProd__c = '01',
            CodUs__c = '03',
            Name = 'DISTRIBUICAO',
            Internal_Id__c = '1-1-01-03',
            RecordTypeId = idRecTypeUdc
        ));




        tabelas.add(new UDC__c(
            CodDefUsuario__c = '11',
            CodProd__c = '01',
            CodUs__c = '03',
            Name = 'ATACADO',
            Internal_Id__c = '1-11-01-03',
            RecordTypeId = idRecTypeUdc
        ));


        tabelas.add(new UDC__c(
            CodDefUsuario__c = '116',
            CodProd__c = '01',
            CodUs__c = '03',
            Name = 'LOCAL',
            Internal_Id__c = '1-116-01-03',
            RecordTypeId = idRecTypeUdc
        ));

        // udc 20 (client type)
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '9',
            CodProd__c = '01',
            CodUs__c = '20',
            Name = 'COM FATURAMENTO',
            Internal_Id__c = '1-9-01-20',
            RecordTypeId = idRecTypeUdc
        ));

        // udc 18 (estrategia)
        tabelas.add(new UDC__c(
            CodDefUsuario__c = '7',
            CodProd__c = '01',
            CodUs__c = '18',
            Name = 'ESPECIALIZADO',
            Internal_Id__c = '1-7-01-18',
            RecordTypeId = idRecTypeUdc
        ));


        //uf for account

        tabelas.add(new UDC__c(
            CodDefUsuario__c = '116',
            CodProd__c = '00',
            CodUs__c = 'CT',
            Name = 'ABADIA DE GOIAS',
            Internal_Id__c = '1-5200050-00-CT',
            Descricao2__c = 'GO',
            RecordTypeId = idRecTypeUdc
        ));


        insert tabelas;

        //q1

        // '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';

        // '132121-Atua como extensão das indústrias na distribuição dos produtos, mas com pouco ou nenhum foco em execução no ponto de venda. A principal característica é a capilaridade de distribuição, com estrutura de custos e margens reduzida';

        // '132121-1 Estado';

        // CONFIG PARAMS
        List < LAT_BR_Segmentation2Params__c > params = new List < LAT_BR_Segmentation2Params__c > ();
        params.add(new LAT_BR_Segmentation2Params__c(Name = 'q1_canal_negocio__c',
            QuestionNumber__c = 'q1_canal_negocio__c',
            ShortValue__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.', Longdescription__c = 'test',
            relatedApiField__c = 'Channel__c', relatedFieldValue__c = 'DISTRIBUICAO'));

        params.add(new LAT_BR_Segmentation2Params__c(Name = 'q2_relacao_comercial__c',
            QuestionNumber__c = 'q2_relacao_comercial__c',
            ShortValue__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).', Longdescription__c = 'test',
            relatedApiField__c = 'Client_type__c', relatedFieldValue__c = 'COM FATURAMENTO'));


        params.add(new LAT_BR_Segmentation2Params__c(Name = 'q3_Qual_o_principal_escopo_do_neg_cio__c',
            QuestionNumber__c = 'q3_Qual_o_principal_escopo_do_neg_cio__c',
            ShortValue__c = '132121-Atua como extensão das indústrias na distribuição dos produtos, mas com pouco ou nenhum foco em execução no ponto de venda. A principal característica é a capilaridade de distribuição, com estrutura de custos e margens reduzida', Longdescription__c = 'test',
            relatedApiField__c = 'Sub_channel__c', relatedFieldValue__c = 'ATACADO'));

        params.add(new LAT_BR_Segmentation2Params__c(Name = 'q4_Qual_a_principal_rea_abordagem__c',
            QuestionNumber__c = 'q4_Qual_a_principal_rea_abordagem__c',
            ShortValue__c = '132121-1 Estado', Longdescription__c = 'test',
            relatedApiField__c = 'Segment__c', relatedFieldValue__c = 'LOCAL'));


        params.add(new LAT_BR_Segmentation2Params__c(Name = 'q5_Qual_o_principal_p_blico__c',
            QuestionNumber__c = 'q5_Qual_o_principal_p_blico__c',
            ShortValue__c = '132121-Portfólio especializado na categoria de bebidas alcoólicas', Longdescription__c = 'test',
            relatedApiField__c = 'Perfil__c', relatedFieldValue__c = 'ESPECIALIZADO'));


        params.add(new LAT_BR_Segmentation2Params__c(Name = 'q6_Qual_o_formato_do_negocio__c',
            QuestionNumber__c = 'q6_Qual_o_formato_do_negocio__c',
            ShortValue__c = '131121-N.A', Longdescription__c = 'test',
            relatedApiField__c = 'FORMATO__c', relatedFieldValue__c = 'N.A'));


        params.add(new LAT_BR_Segmentation2Params__c(Name = 'q7_Qual_modelo_de_neg_cio_do_cliente__c',
            QuestionNumber__c = 'q7_Qual_modelo_de_neg_cio_do_cliente__c',
            ShortValue__c = '132121-Clientes que, devido a características específicas da regiões que atuam (ausência de distribuidores), desempenham um papel estratégico de distribuição, chegando a pontos de vendas que normalmente seriam atendidos pelos distribuidores', Longdescription__c = 'test',
            relatedApiField__c = 'Estrategia_comercial__c', relatedFieldValue__c = 'ESTRATEGICO'));


        params.add(new LAT_BR_Segmentation2Params__c(Name = 'q8_cliente_possui_benefcio_Fiscal__c',
            QuestionNumber__c = 'q8_cliente_possui_benefcio_Fiscal__c',
            ShortValue__c = '132121-Possui regime especial de tributação que envolve uma vantagem ou simplesmente um desagravamento fiscal perante o regime normal, assumindo-se como uma forma de isenção, redução de taxas, deduções, amortizações e/ou outras medidas fiscais dessa natur', Longdescription__c = 'test',
            relatedApiField__c = 'Beneficio_Fiscal__c', relatedFieldValue__c = 'COM BENEFÍCIO FISCAL'));

        params.add(new LAT_BR_Segmentation2Params__c(Name = 'q9_Qual_a_importancia_do_cliente_para_PR__c',
            QuestionNumber__c = 'q9_Qual_a_importancia_do_cliente_para_PR__c',
            ShortValue__c = 'Cliente estratégico para receber um tratamento diferenciado no que diz respeito a investimentos, confecção de planos e gestão de performance. Troca de informações sistematizada é mandatória.', Longdescription__c = 'test',
            relatedApiField__c = 'PRIOR_DE_INVESTIMENTO__c', relatedFieldValue__c = 'BYE'));


        /*

               params.add(new LAT_BR_Segmentation2Params__c(Name = 'q1_canal_negocio__c',
                QuestionNumber__c = 'q1_canal_negocio__c' ,
                ShortValue__c =  '',Longdescription__c ='test', 
                relatedApiField__c = '', relatedFieldValue__c = ''));


               params.add(new LAT_BR_Segmentation2Params__c(Name = 'q1_canal_negocio__c',
                QuestionNumber__c = 'q1_canal_negocio__c' ,
                ShortValue__c =  '',Longdescription__c ='test', 
                relatedApiField__c = '', relatedFieldValue__c = ''));


               params.add(new LAT_BR_Segmentation2Params__c(Name = 'q1_canal_negocio__c',
                QuestionNumber__c = 'q1_canal_negocio__c' ,
                ShortValue__c =  '',Longdescription__c ='test', 
                relatedApiField__c = '', relatedFieldValue__c = ''));


                params.add(new LAT_BR_Segmentation2Params__c(Name = 'q1_canal_negocio__c',
                QuestionNumber__c = 'q1_canal_negocio__c' ,
                ShortValue__c =  '',Longdescription__c ='test', 
                relatedApiField__c = '', relatedFieldValue__c = ''));
        */
        insert params;

        // Add demantra configs
        LAT_BR_PoliticaPrecoConfig__c config = new LAT_BR_PoliticaPrecoConfig__c(
            Beneficio_Fiscal__c = '',
            Channel__c = '1',
            Client_type__c = '12',
            Estrategia_comercial__c = '7',
            Formato__c = '17',
            //Perfil_Codigo_Demantra__c   = '101A-RJ',
            Perfil_Desc_Demantra__c = '101A-RJ',
            // Perfil_Portfolio__c  = '1',
            Politica_de_Preco__c = '1IO',
            //Prioridade_de_Investimento__c = '12',   
            Segment__c = '116',
            Sub_channel__c = '11',
            UF__c = 'GO'
        );
        insert config;


        List < LAT_GeneralConfig__c > generalConfigs = new List < LAT_GeneralConfig__c > ();
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'POLITICA_PRECO_MAPPING',
            LAT_Value__c = 'Channel__c'));
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'POLITICA_PRECO_MAPPING1',
            LAT_Value__c = 'Sub_channel__c'));
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'POLITICA_PRECO_MAPPING2',
            LAT_Value__c = 'Segment__c'));
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'POLITICA_PRECO_MAPPING3',
            LAT_Value__c = 'Uf__c'));
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'POLITICA_PRECO_MAPPING4',
            LAT_Value__c = 'Estrategia_comercial__c'));
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'AR_CANT_UPDATE_BASIC_INFO_FIELDS_PROF',
            LAT_Value__c = 'LAT_AR2_Vendedor'));
        generalConfigs.add(new LAT_GeneralConfig__c(
            name = 'BR_CAN_UPDATE_BASIC_INFO_FIELDS_PROF',
            lat_value__c = 'LAT_SystemAdministrator'));
        insert generalConfigs;


        /* (Name =   QuestionNumber__c =  ,ShortValue__c =  ,Longdescription__c ='test' relatedApiField__c  relatedFieldValue__c);
q1_canal_negocio__c q1_canal_negocio__c É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.    É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.    Channel__c  DISTRIBUICAO
q1_canal_negocio__c q1_canal_negocio__c São Pontos de Vendas intermediários que fazem ligação direta com o Shopper ou consumidor final. Último negociante que liga fabricantes a consumidores para consumo ou venda posterior. Podem ser atendidos direta ou indiretamente. "São Pontos de Vendas intermediários que fazem ligação direta com o Shopper ou consumidor final (CPF). Vende produtos e serviços de uso pessoal ou familiar aos Shoppers ou  consumidores, sendo o último negociante que liga fabricantes a consumidores para consumo ou venda posterior.
Podem ser atendidos direta ou indiretamente."   Channel__c  OFF TRADE
q1_canal_negocio__c q1_canal_negocio__c Comércio eletrônico ou e-commerce como também é chamado. Realização de negócios no ambiente on-line, por meio de ferramentas eletrônicas. Podem ser atendidos Direta ou Indiretamente.  Comércio eletrônico ou e-commerce como também é chamado. Surgiu com uma nova forma de comercialização de produtos e serviços entre consumidores, empresas e governo, possibilitando aos mesmos, a realização de negócios no ambiente on-line, por meio de ferramentas eletrônicas. Podem ser atendidos Direta ou Indiretamente. Channel__c  ON LINE
q1_canal_negocio__c q1_canal_negocio__c São Pontos de Vendas de alimentos e bebidas para consumo imediato, preparados por operadores (restaurantes, bares, casas noturnas, eventos, etc.) e consumido no próprio estabelecimento.   "São Pontos de Vendas de alimentos e bebidas para consumo imediato, preparados por operadores (restaurantes, bares, casas noturnas, eventos, etc.)
e consumido no próprio estabelecimento. "   Channel__c  ON TRADE
q1_canal_negocio__c q1_canal_negocio__c Acontecimento pode ser social, artístico ou desportivo, festas de pequeno, médio ou grande porte, que envolvem experiências diferenciadas ao público e possível vivência de marca.  Uma atividade social determinada que está programado. Esse acontecimento pode ser social, artístico ou desportivo, festas de pequeno, médio ou grande porte, que envolvem experiências diferenciadas ao público e possível vivência de marca. Em sua maioria é divulgado ou comentado, apresenta repercussão. Ou mesmo que não apresente esta característica de influência externa, pode ter caráter interno, por exemplo uma confraternização de fim de ano em uma empresa, uma convenção e etc.   Channel__c  EVENTOS
q2_relacao_comercial__c q2_relacao_comercial__c Cliente no qual emitimos pagamentos (Dinheiro e "ou" Produto).  Cliente no qual emitimos pagamentos (Dinheiro e "ou" Produto).  Client_type__c  COM PAGAMENTO
q2_relacao_comercial__c q2_relacao_comercial__c 121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).   Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).   Client_type__c  COM FATURAMENTO
q2_relacao_comercial__c q2_relacao_comercial__c EVE-Cliente no qual emitimos pagamentos (Dinheiro e "ou" Produto).  Cliente no qual emitimos pagamentos (Dinheiro e "ou" Produto).  Client_type__c  COM PAGAMENTO
q2_relacao_comercial__c q2_relacao_comercial__c Cliente no qual emitimos pedidos de VENDA DIRETA. Ou seja, fazemos a venda de nossos produtos sem o uso de distribuidores/atacados. Cliente no qual emitimos pedidos de VENDA DIRETA. Ou seja, fazemos a venda de nossos produtos sem o uso de distribuidores/atacados. Client_type__c  VENDA DIRETA
q2_relacao_comercial__c q2_relacao_comercial__c EVE-Cliente no qual emitimos pedidos de VENDA DIRETA. Ou seja, fazemos a venda de nossos produtos sem o uso de distribuidores/atacados. Cliente no qual emitimos pedidos de VENDA DIRETA. Ou seja, fazemos a venda de nossos produtos sem o uso de distribuidores/atacados. Client_type__c  VENDA DIRETA
q2_relacao_comercial__c q2_relacao_comercial__c Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).   Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).   Client_type__c  COM FATURAMENTO
*/




    }

    /**
     * this method covers:
     * -LAT_BR_SegmentationSlctController
     * -
     * -
     */
    @isTest
    static void createAccountFromScratch() {
        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.isNew = true;
        controllerNew.CreateClient();

    }


    /**
     * this method covers:
     * -LAT_BR_SegmentationSlctController
     * -
     * -
     */
    @isTest
    static void createAccountHasCompleteSegm() {
        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.isNew = true;
        controllerNew.CreateClient();
        Test.startTest();
        LAT_BR_SegmentationBehaviorHandler.hasCompleteSegmentation(controllerNew.segmentResult);
        LAT_BR_SegmentationBehaviorHandler.hasCompleteSegmentation(controllerNew.segmentResult.Id);
        Test.stopTest();

    }

    @isTest
    static void addSegmentationNew() {


        User usuario = Utils_TestMethods.createUserWithProfile('Teste', 'LAT_SystemAdministrator');
        insert usuario;


        System.runAs(usuario) {
            PageReference pageRef = Page.LAT_BR_SegmentationSlct;
            Test.setCurrentPageReference(pageRef);
            //System.currentPageReference().getParameters().put('id', idVariable);

            Test.setCurrentPage(pageRef);
            LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
            controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
            controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
            controllerNew.brAcc.Name = 'testAcc';
            controllerNew.isNew = true;
            controllerNew.brAcc.TriggerRun__c = true;
            controllerNew.CreateClient();
            controllerNew.brAcc.status__c = 'Cliente cadastrado no CRM';
            controllerNew.brAcc.CNPJ__c = '48843971000120';
            /*  acc.Type = 'Outros';
              acc.RecordTypeId = idAccount;
              acc.Status__c = 'Cliente cadastrado no JDE';
              acc.Agency__c = '000';
              acc.Checking_account__c = '000';
              acc.Current_account__c = '0';
              acc.Corporate_Name__c = 'Teste';
              acc.Channel__c = 'Off Trade';
              //acc.Regional__c = regional.Id;
              acc.Frequency_of_Visits__c = 'Semanal';
              acc.Client_code_AN8__c = '557798';
              acc.Price_Group__c = '1';*/



            Test.startTest();
            update controllerNew.brAcc;
            PageReference pageRef2 = Page.LAT_BR_SegmentationSlctNew;
            Test.setCurrentPageReference(pageRef2);
            System.currentPageReference().getParameters().put('accId', controllerNew.brAcc.Id);
            LAT_BR_SegmentationSlctNewController controllerNew2 = new LAT_BR_SegmentationSlctNewController();
            try {
                LAT_BR_SegmentationSlctNewController.getObtainedField('q1_canal_negocio__c', controllerNew.newSegmentation.q1_canal_negocio__c);
            } catch (Exception e) {
                // do
            }

            try {
                controllerNew2.CreateClient();
            } catch (Exception e) {
                // do
            }
            //PageReference pageRef = Page.LAT_BR_SegmentationSlct;
            //Test.setCurrentPage(pageRef);

        }
    }

    @isTest
    static void buttonActions() {
        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.isNew = true;
        controllerNew.CreateClient();
        Test.startTest();
        String testA = LAT_BR_SegmentationBehaviorHandler.EVENTOS_APPROVAL_PRCS;
        testA= LAT_BR_SegmentationBehaviorHandler.COMFATURAMENTE_APPROVAL_PRCS;
        testA = LAT_BR_SegmentationBehaviorHandler.ONTRADE_APPROVAL_PRCS;
        testA = LAT_BR_SegmentationBehaviorHandler.SEMFATURAMENTE_APPROVAL_PRCS;
        try {
        LAT_BR_SegmentationBehaviorHandler.validateAccountData(controllerNew.brAcc.Id);

        LAT_BR_SegmentationBehaviorHandler.sentToApproval(controllerNew.brAcc.Id);
        } catch (Exception e){
            
        }
        Test.stopTest();
    }

    @isTest
    static void buttonActions2() {
        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.isNew = true;
        controllerNew.CreateClient();
        Test.startTest();
        try {
            
        
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.brAcc.LAT_InformationUnfilled__c = '';

        update controllerNew.brAcc;
        LAT_BR_SegmentationBehaviorHandler.validateAccountData(controllerNew.brAcc.Id);

        LAT_BR_SegmentationBehaviorHandler.sentToApproval(controllerNew.brAcc.Id);
        } catch (Exception e){
            
        }
        Test.stopTest();
    }

    @isTest
    static void getRT() {
        LAT_BR_SegmentationBehaviorHandler.getLayoutSet('OFF TRADE', 'SEM FATURAMENTO');
        LAT_BR_SegmentationBehaviorHandler.getLayoutSet('OFF TRADE', 'COM FATURAMENTO');
        LAT_BR_SegmentationBehaviorHandler.getLayoutSet('ON TRADE', 'SEM PAGAMENTO');
        LAT_BR_SegmentationBehaviorHandler.getLayoutSet('ON TRADE', 'COM PAGAMENTO');
        LAT_BR_SegmentationBehaviorHandler.getLayoutSet('ON TRADE', 'VENDA DIRETA');
        LAT_BR_SegmentationBehaviorHandler.getLayoutSet('EVENTOS', 'SEM PAGAMENTO');
        LAT_BR_SegmentationBehaviorHandler.getLayoutSet('EVENTOS', 'COM PAGAMENTO');
        LAT_BR_SegmentationBehaviorHandler.getLayoutSet('EVENTOS', 'VENDA DIRETA');

        LAT_BR_SegmentationBehaviorHandler.getRecordTypeId('OFF TRADE', 'SEM FATURAMENTO');
        LAT_BR_SegmentationBehaviorHandler.getRecordTypeId('OFF TRADE', 'COM FATURAMENTO');
        LAT_BR_SegmentationBehaviorHandler.getRecordTypeId('ON TRADE', 'SEM PAGAMENTO');
        LAT_BR_SegmentationBehaviorHandler.getRecordTypeId('ON TRADE', 'COM PAGAMENTO');
        LAT_BR_SegmentationBehaviorHandler.getRecordTypeId('ON TRADE', 'VENDA DIRETA');
        LAT_BR_SegmentationBehaviorHandler.getRecordTypeId('EVENTOS', 'SEM PAGAMENTO');
        LAT_BR_SegmentationBehaviorHandler.getRecordTypeId('EVENTOS', 'COM PAGAMENTO');
        LAT_BR_SegmentationBehaviorHandler.getRecordTypeId('EVENTOS', 'VENDA DIRETA');
    }

    @isTest
    static void migration() {
        Account acc = Lat_account_TestFactory.getAccountOffTradeBraComplete();
        List<UDC__c> regionales  = [SELECT Id FROM UDC__c WHERE CodProd__c = '01' AND CodUs__c = '01' LIMIT 2]; 
        acc.Regional__c = regionales[0].Id;
        insert acc;

        LAT_BR_AP01_AccountWOS.setRegional(acc, '14');
        LAT_BR_AP01_AccountWOS.setMicroRegional(acc, '14');




        Test.startTest();
        acc.Regional__c = regionales[1].Id;
        update acc;
        LAT_BR_ClientChannelSegmentation2Result__c migrateRec = new LAT_BR_ClientChannelSegmentation2Result__c(CNPJ__c = acc.CNPJ__c,
            Channel__c = 'DISTRIBUICAO',
            Client_type__c = 'COM FATURAMENTO',
            Sub_channel__c = 'ATACADO', Segment__c = 'LOCAL');
        insert migrateRec;
        Test.stopTest();
    }


    @isTest
    static void addSegmentationData() {
        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.isNew = true;
        controllerNew.CreateClient();
        Test.startTest();
        String testA = LAT_BR_SegmentationBehaviorHandler.EVENTOS_APPROVAL_PRCS;
        testA= LAT_BR_SegmentationBehaviorHandler.COMFATURAMENTE_APPROVAL_PRCS;
        testA = LAT_BR_SegmentationBehaviorHandler.ONTRADE_APPROVAL_PRCS;
        testA = LAT_BR_SegmentationBehaviorHandler.SEMFATURAMENTE_APPROVAL_PRCS;
        update controllerNew.newSegmentation;

        LAT_BR_SegmentationBehaviorHandler.AccountSegmentationData data = new LAT_BR_SegmentationBehaviorHandler.AccountSegmentationData(controllerNew.brAcc.Id);
        LAT_BR_SegmentationBehaviorHandler.getMapOfOldTyping(new List < Account > {
            controllerNew.brAcc
        });
        Test.stopTest();
    }


    @isTest
    static void emailTemplateControllerTest() {
        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.isNew = true;
        controllerNew.CreateClient();
        Test.startTest();
        LAT_BR_ShowSegmentationController show = new LAT_BR_ShowSegmentationController();
        show.value = controllerNew.brAcc.Id;
        show.init();
        Test.stopTest();
    }

    @isTest
    static void emailTemplateControllerTest2() {
        User usuario = Utils_TestMethods.createUserWithProfile('Teste', 'LAT_SystemAdministrator');
        
        insert usuario;

        System.runAs(usuario) {
            PageReference pageRef = Page.LAT_BR_SegmentationSlct;
            Test.setCurrentPage(pageRef);
            LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
            controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
            controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
            controllerNew.brAcc.Name = 'testAcc';
            controllerNew.brAcc.TriggerRun__c = true;
            controllerNew.isNew = true;
            controllerNew.CreateClient();
            controllerNew.brAcc.TriggerRun__c = true;
            controllerNew.brAcc.rating = 'Cliente';
            controllerNew.brAcc.status__c = 'Cliente cadastrado no JDE';
            controllerNew.brAcc.CNPJ__c = '48843971000120';
            /*  acc.Type = 'Outros';
              acc.RecordTypeId = idAccount;
              acc.Status__c = 'Cliente cadastrado no JDE';
              acc.Agency__c = '000';
              acc.Checking_account__c = '000';
              acc.Current_account__c = '0';
              acc.Corporate_Name__c = 'Teste';
              acc.Channel__c = 'Off Trade';
              //acc.Regional__c = regional.Id;
              acc.Frequency_of_Visits__c = 'Semanal';
              acc.Client_code_AN8__c = '557798';
              acc.Price_Group__c = '1';*/



            Test.startTest();
            update controllerNew.brAcc;
            LAT_BR_ShowSegmentationController show = new LAT_BR_ShowSegmentationController();
            show.value = controllerNew.brAcc.Id;
            show.init();
            Test.stopTest();
        }
    }



    @isTest
    static void segmentationResultController() {
        User usuario = Utils_TestMethods.createUserWithProfile('Teste', 'LAT_SystemAdministrator');
        insert usuario;
        try{

        System.runAs(usuario) {
            PageReference pageRef = Page.LAT_BR_SegmentationSlct;
            Test.setCurrentPage(pageRef);
            LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
            controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
            controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
            controllerNew.brAcc.Name = 'testAcc';
            controllerNew.brAcc.TriggerRun__c = true;
            controllerNew.isNew = true;
            controllerNew.CreateClient();

            controllerNew.brAcc.TriggerRun__c = true;
            controllerNew.brAcc.status__c = 'Cliente cadastrado no JDE';
            controllerNew.brAcc.CNPJ__c = '48843971000120';
            
            Udc__c pol = [select id from Udc__c where name = '102A-SP'];
            LAT_BR_PoliticaComercial__c dpc = new LAT_BR_PoliticaComercial__c(LAT_BR_CodigoPoliticaComercial__c = pol.Id,
                                                                              LAT_BR_DescricaoPoliticaComercial__c = 'Descrição Politica de Preço');    
			insert dpc;
            
            Test.startTest();

            try{update controllerNew.brAcc;}catch(Exception e){}
            ApexPages.StandardController controller = new ApexPages.StandardController(controllerNew.brAcc);
            LAT_BR_SegmentationResultController controllerNew2 = new LAT_BR_SegmentationResultController(controller);

            controllerNew2.doEdit();
            controllerNew2.tbciBefore = false;
            controllerNew2.segment.TBCI__c = true;
            controllerNew2.segment.Obtained_POLiTICA_DE_PRECO_Udc__c = pol.id;
            try{controllerNew2.changeSegmentation();}catch(Exception e){}
			
            Test.stopTest();
        }
        }catch(Exception e){}
    }

    @isTest
    static void segmentationResultController2() {
        User usuario = Utils_TestMethods.createUserWithProfile('Teste', 'LAT_SystemAdministrator');
        insert usuario;

        /*  acc.Type = 'Outros';
          acc.RecordTypeId = idAccount;
          acc.Status__c = 'Cliente cadastrado no JDE';
          acc.Agency__c = '000';
          acc.Checking_account__c = '000';
          acc.Current_account__c = '0';
          acc.Corporate_Name__c = 'Teste';
          acc.Channel__c = 'Off Trade';
          //acc.Regional__c = regional.Id;
          acc.Frequency_of_Visits__c = 'Semanal';
          acc.Client_code_AN8__c = '557798';
          acc.Price_Group__c = '1';*/


        System.runAs(usuario) {

            PageReference pageRef = Page.LAT_BR_SegmentationSlct;
            Test.setCurrentPage(pageRef);

            //PageReference pageRef = Page.LAT_BR_SegmentationResultController;
            //Test.setCurrentPage(pageRef);
            LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
            controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
            controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
            controllerNew.brAcc.Name = 'testAcc';
            controllerNew.brAcc.TriggerRun__c = true;
            controllerNew.isNew = true;
            controllerNew.CreateClient();

            controllerNew.brAcc.TriggerRun__c = true;
            controllerNew.brAcc.status__c = 'Cliente cadastrado no CRM';
            controllerNew.brAcc.CNPJ__c = '48843971000120';
            
            Test.startTest();
            update controllerNew.brAcc;
            ApexPages.StandardController controller = new ApexPages.StandardController(controllerNew.brAcc);
            LAT_BR_SegmentationResultController controllerNew2 = new LAT_BR_SegmentationResultController(controller);

            controllerNew2.doEdit();
            controllerNew2.tbciBefore = false;
            controllerNew2.segment.TBCI__c = true;
            controllerNew2.changeSegmentation();
            controllerNew2.doCancel();
            controllerNew2.updateAccount();
        }

        Test.stopTest();
    }
    
    @isTest
    static void segmentationResultController3() {
        User usuario = Utils_TestMethods.createUserWithProfile('Teste', 'LAT_SystemAdministrator');
        insert usuario;
        try{

        System.runAs(usuario) {
            PageReference pageRef = Page.LAT_BR_SegmentationSlct;
            Test.setCurrentPage(pageRef);
            LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
            controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
            controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
            controllerNew.brAcc.Name = 'testAcc';
            controllerNew.brAcc.TriggerRun__c = true;
            controllerNew.isNew = true;
            controllerNew.CreateClient();

            controllerNew.brAcc.TriggerRun__c = true;
            controllerNew.brAcc.status__c = 'Cliente cadastrado no JDE';
            controllerNew.brAcc.CNPJ__c = '48843971000120';

            Udc__c pol = [select id from Udc__c where name = '102A-SP'];
            LAT_BR_PoliticaComercial__c dpc = new LAT_BR_PoliticaComercial__c(LAT_BR_CodigoPoliticaComercial__c = pol.Id,
                                                                              LAT_BR_DescricaoPoliticaComercial__c = 'Descrição Politica de Preço');    
			insert dpc;
            
            Test.startTest();

            try{update controllerNew.brAcc;}catch(Exception e){}
            ApexPages.StandardController controller = new ApexPages.StandardController(controllerNew.brAcc);
            LAT_BR_SegmentationResultController controllerNew2 = new LAT_BR_SegmentationResultController(controller);

            controllerNew2.doEdit();
            controllerNew2.tbciBefore = false;
            controllerNew2.segment.Obtained_POLiTICA_DE_PRECO_Udc__c = pol.id;
            try{controllerNew2.changeSegmentation();}catch(Exception e){}

            Test.stopTest();
        }
        }catch(Exception e){}
    }

    @isTest
    static void segmentationResultController4() {
        User usuario = Utils_TestMethods.createUserWithProfile('Teste', 'LAT_SystemAdministrator');
        insert usuario;

        System.runAs(usuario) {
            PageReference pageRef = Page.LAT_BR_SegmentationSlct;
            Test.setCurrentPage(pageRef);

            LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
            controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
            controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
            controllerNew.brAcc.Name = 'testAcc';
            controllerNew.brAcc.TriggerRun__c = true;
            controllerNew.isNew = true;
            controllerNew.CreateClient();

            controllerNew.brAcc.TriggerRun__c = true;
            controllerNew.brAcc.status__c = 'Cliente cadastrado no CRM';
            controllerNew.brAcc.CNPJ__c = '48843971000120';
            
            Udc__c pol = [select id from Udc__c where name = '102A-SP'];
            LAT_BR_PoliticaComercial__c dpc = new LAT_BR_PoliticaComercial__c(LAT_BR_CodigoPoliticaComercial__c = pol.Id,
                                                                              LAT_BR_DescricaoPoliticaComercial__c = 'Descrição Politica de Preço');    
			insert dpc;
            
            Test.startTest();
            update controllerNew.brAcc;
            ApexPages.StandardController controller = new ApexPages.StandardController(controllerNew.brAcc);
            LAT_BR_SegmentationResultController controllerNew2 = new LAT_BR_SegmentationResultController(controller);

            controllerNew2.doEdit();
            controllerNew2.tbciBefore = false;
            controllerNew2.segment.TBCI__c = true;
            controllerNew2.segment.Obtained_POLiTICA_DE_PRECO_Udc__c = pol.id;
            controllerNew2.changeSegmentation();
            controllerNew2.doCancel();
            controllerNew2.updateAccount();
        }

        Test.stopTest();
    }
    
    @isTest
    static void testnotificate22() {

        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        User vendas = [SELECT id from USer Where Gerente_regional__c <> null and Gerente_de_area__c <>null and c_digo_jde__C <>null and isactive = true and profile.name='LAT_BR2_Vendas' LIMIT 1];
        
        System.runas(vendas){
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.isNew = true;
        controllerNew.CreateClient();
        controllerNew.segmentResult.Lat_isrevert__c = true;
        Udc__c pol1 = [select id from Udc__c where name = '101A-RJ'];
        Udc__c pol2 = [select id from Udc__c where name = '102A-SP'];
        controllerNew.segmentResult.Politica_Preco_Origin__c = pol1.Id;
        controllerNew.segmentResult.Obtained_POLiTICA_DE_PRECO_Udc__c = pol2.Id;
        
        Test.startTest();
        //update controllerNew.newSegmentation; 
        LAT_BR_SegmentationBehaviorHandler.notificateManagers(controllerNew.segmentResult);
        Test.stopTest();
        }
    }

    @isTest
    static void testnotificate() {

        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.isNew = true;
        controllerNew.CreateClient();
        controllerNew.segmentResult.Lat_isrevert__c = true;
        Udc__c pol1 = [select id from Udc__c where name = '101A-RJ'];
        Udc__c pol2 = [select id from Udc__c where name = '102A-SP'];
        controllerNew.segmentResult.Politica_Preco_Origin__c = pol1.Id;
        controllerNew.segmentResult.Obtained_POLiTICA_DE_PRECO_Udc__c = pol2.Id;
        Test.startTest();
        //update controllerNew.newSegmentation; 
        LAT_BR_SegmentationBehaviorHandler.notificateManagers(controllerNew.segmentResult);
        Test.stopTest();
    }

    @isTest
    static void testnotificate2() {

        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.isNew = true;
        controllerNew.CreateClient();
        controllerNew.segmentResult.Lat_isrevert__c = true;
        Udc__c pol1 = [select id from Udc__c where name = '101A-RJ'];
        Udc__c pol2 = [select id from Udc__c where name = '102A-SP'];
        controllerNew.segmentResult.Politica_Preco_Origin__c = pol1.Id;
        controllerNew.segmentResult.Obtained_POLiTICA_DE_PRECO_Udc__c = pol2.Id;
        Test.startTest();
        //update controllerNew.newSegmentation; 
        controllerNew.isNew = false;
        controllerNew.CreateClient();
        controllerNew.isNew = true;
        controllerNew.retornar();
        LAT_BR_SegmentationBehaviorHandler.notificateManagers(controllerNew.segmentResult);
        Test.stopTest();
    }

            @isTest
    static void testnotificate3() {

        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.isNew = true;
        controllerNew.CreateClient();
        controllerNew.segmentResult.Lat_isrevert__c = true;
        Udc__c pol1 = [select id from Udc__c where name = '101A-RJ'];
        Udc__c pol2 = [select id from Udc__c where name = '102A-SP'];
        controllerNew.segmentResult.Politica_Preco_Origin__c = pol1.Id;
        controllerNew.segmentResult.Obtained_POLiTICA_DE_PRECO_Udc__c = pol2.Id;
        Test.startTest();
        //update controllerNew.newSegmentation; 
        LAT_BR_SegmentationSlctController.checkCNPJ('fruli', true);
        LAT_BR_SegmentationSlctController.checkCNPJ('74008164000100', true);
        LAT_BR_SegmentationSlctController.checkCNPJ('fruli', false);
        LAT_BR_SegmentationSlctController.checkCNPJ('74008164000100', false);


         try {
                LAT_BR_SegmentationSlctController.getObtainedField('q1_canal_negocio__c', controllerNew.newSegmentation.q1_canal_negocio__c);
            } catch (Exception e) {
                // do
            }
        controllerNew.retornar();
        LAT_BR_SegmentationBehaviorHandler.notificateManagers(controllerNew.segmentResult);
        Test.stopTest();
    }

    static void testnotificate4() {

        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.isNew = true;
        //controllerNew.CreateClient();
        controllerNew.segmentResult.Lat_isrevert__c = true;
        Udc__c pol1 = [select id from Udc__c where name = '101A-RJ'];
        Udc__c pol2 = [select id from Udc__c where name = '102A-SP'];
        controllerNew.segmentResult.Politica_Preco_Origin__c = pol1.Id;
        controllerNew.segmentResult.Obtained_POLiTICA_DE_PRECO_Udc__c = pol2.Id;
        Test.startTest();
        //update controllerNew.newSegmentation; 
        controllerNew.deleteClient();
        LAT_BR_SegmentationBehaviorHandler.notificateManagers(controllerNew.segmentResult);
        Test.stopTest();
    }

    @isTest
    static void basicfields() {
        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.isNew = true;
        controllerNew.CreateClient();


        ApexPages.StandardController controller = new ApexPages.StandardController(controllerNew.brAcc);
        LAT_BR_AccountBasicInfoFieldsCONT testPage = new LAT_BR_AccountBasicInfoFieldsCONT(controller);
        try {
            testPage.doEdit();
        } catch (Exception e) {}
        try {
            testPage.doSave();
        } catch (Exception e) {}
        try {
            testPage.doCancel();
        } catch (Exception e) {}



    }


}