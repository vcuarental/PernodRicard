@isTest
private class LAT_Account_Changed_Owner_Batch_Test {
    
     @isTest static void test_Change_Owner_Account() {

        Test.startTest();

        Account acc = [select id, ownerid, lat_account__r.LAT_Owner_Changed__c from Account where Corporate_Name__c = 'test' limit 1];

        User user = [SELECT Id, name FROM User WHERE profile.Name = 'LAT_BR2_Vendas' and isActive = true limit 1];

        //acc.ownerid = user.id;
        acc.lat_account__r.LAT_Owner_Changed__c = true;

        update acc;

        LAT_MasiveOwnerHeader__c header = new LAT_MasiveOwnerHeader__c(lat_status__c = 'New');
        insert header;

        LAT_MasiveOwnerLine__c line = new LAT_MasiveOwnerLine__c(LAT_Header__c = header.id, LAT_Account__c = acc.id, LAT_NewValue__c = user.id);
        insert line;

        Database.executeBatch(new LAT_ClientChannelSegmResultOwner_Batch(String.valueOf(header.id)));

        Test.stopTest();

    }
    
    @testSetup
    public static void setup(){

        //DUPLICATED CODE

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

        ///////////////
  
        UDC__c regional = new UDC__c(
           CodDefUsuario__c = '5',
           Name = 'REG ONTRADE',
           CodProd__c = '01',
           CodUs__c = '01',
           Internal_Id__c = '1-5-01-01',
           RecordTypeId = idRecTypeUdc
       );

       insert regional;

       UDC__c micro = new UDC__c(
           Name = 'ME',
           CodDefUsuario__c = '051',
           Internal_Id__c = '1-051-01-07',
           CodProd__c = '01',
           CodUs__c = '07',
           RecordTypeId = idRecTypeUdc
       );

       insert micro;

        Account acc = new Account(
                RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'), 
                CNPJ__c = '58815921000192',
                Name = 'testAccount',
                Overdue__c = false,
                Type = 'LD',
                Corporate_Name__c = 'test',
                Channel_Type__c = 'Direto',
                Sub_Channel__c = 'Delicatessen',
                AddressLine1_AR__c= 'test',
                Shipping_Neighbourhood__c = 'test',
                Revenue_Neighbourhood__c = 'test',
                Billing_Neighbourhood__c ='test',
                Shipping_Country__c ='test',
                Revenue_Country__c ='test', 
                Billing_Country__c ='test',
                Status__c = 'Novo Cadastro');

        insert acc;
        
        LAT_BR_ClientChannelSegmentation2Result__c segm = new LAT_BR_ClientChannelSegmentation2Result__c(Account__c = acc.id, CNPJ__c = acc.CNPJ__c,
            Channel__c = 'DISTRIBUICAO',  Client_type__c = 'COM FATURAMENTO', Sub_channel__c = 'ATACADO', Segment__c = 'LOCAL');

        insert segm;
        
    }

}