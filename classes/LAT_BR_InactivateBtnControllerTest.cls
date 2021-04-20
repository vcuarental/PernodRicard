/**
 *
 */
@isTest
public with sharing class LAT_BR_InactivateBtnControllerTest {

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

	 static testMethod void testMethodNoCadastrado() {
        Utils.setMigrationDoneTest(true);  
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Status__c = 'no cadastrado';
        acc.Reason_for_Inactivation__c = 'test';
        acc.Notes_1__c = 'test';
        insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(true);  

        LAT_BR_InactivateBtnController.validateAccInactivation(acc.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(acc);
        
        List <Account> returnList = [SELECT Id, Rating FROM Account WHERE id = :acc.Id LIMIT 1];
        //System.assertEquals('Cliente inativo', returnList[0].Rating);

        Test.stopTest();
    }

    static testMethod void testMethodcadastradoAllFilled() {
        Utils.setMigrationDoneTest(true);  
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        acc.Status__c = 'Cliente cadastrado no CRM';
        acc.Reason_for_Inactivation__c =  '123';
        acc.Notes_1__c = 'test';
        insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(true);  

        LAT_BR_InactivateBtnController.validateAccInactivation(acc.Id);
        ApexPages.StandardController con = new ApexPages.StandardController(acc);
        
        List <Account> returnList = [SELECT Id, Rating FROM Account WHERE id = :acc.Id LIMIT 1];
        //System.assertEquals('Cliente inativo', returnList[0].Rating);

        Test.stopTest();
    }

    static testMethod void testMethodcadastradoJDEAllFilled() {
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        Utils.setMigrationDoneTest(true);  




        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        //Account acc = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
        


        PageReference pageRef = Page.LAT_BR_SegmentationSlct;
        Test.setCurrentPage(pageRef);
        LAT_BR_SegmentationSlctController controllerNew = new LAT_BR_SegmentationSlctController();
        controllerNew.newSegmentation.q1_canal_negocio__c = 'É um intermediário que terá a responsabilidade de entregar os produtos da empresa para o ponto de venda final (CNPJ). Canais utilizados para alcançar pontos de venda On-Trade, Off Trade e Eventos.';
        controllerNew.newSegmentation.q2_relacao_comercial__c = '121-Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).';
        controllerNew.brAcc.Name = 'testAcc';
        controllerNew.brAcc.CNPJ__C = '81896829000116'    ;                
        controllerNew.brAcc.TriggerRun__c = true;
        controllerNew.brAcc.Status__c = 'Cliente cadastrado no JDE';
        controllerNew.brAcc.Reason_for_Inactivation__c =  '123';
        controllerNew.brAcc.Notes_1__c = 'test';
        controllerNew.isNew = true;
        controllerNew.CreateClient();
         Account acc = controllerNew.brAcc;
        //insert acc;
        Test.startTest();
        Utils.setMigrationDoneTest(true);  
        try {
        LAT_BR_InactivateBtnController.validateAccInactivation(acc.Id);
        } catch (Exception e){}
        ApexPages.StandardController con = new ApexPages.StandardController(acc);
        
        List <Account> returnList = [SELECT Id, Rating FROM Account WHERE id = :acc.Id LIMIT 1];
        //System.assertEquals('Cliente inativo', returnList[0].Rating);

        Test.stopTest();
    }
}