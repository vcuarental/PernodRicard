/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Faz a clonagem do contrato e todos os objetos relacionados
* NAME: ContractClonagem.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 22/08/2012
*
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 14/01/2013 
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/

global class ContractClonagem {
    
  webservice static String executa( String aContratoID )
  {
    
    Set< Id > setRecTypeLatCon = new Set< Id >();
    //Recupera os Ids dos tipos de registro do objeto LAT_Contract__c
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
    
    List< LAT_Contract__c > lVelhoContrato = 
       [ select Percentual_KPI_financeiro_ROI__c, Porcentagem_custo_Pernod_old__c, A_casa_ja_inaugurou__c, 
                Volume_Absolut_100__c, Absolut_100_periodo__c, Volume_Absolut_Elyx__c, Absolut_Elyx_periodo__c, 
                Volume_Absolut_Flavors__c, Absolut_Flavors_periodo__c, Volume_Absolut_Vodka__c, 
                Absolut_Vodka_periodo__c, Aditamento_ass_cliente__c, Aditamento_encaminhado_ao_cliente__c, 
                Aditamento_entregue_ao_cliente__c, Aditamento_gerado__c, Aditamento_registrado_regional__c, 
                Agencia__c, Alerta__c, Alteracao_de_clausulas_contratuais__c, Aprovado_pelo_cliente__c, 
                Armarios_de_Clube_da_Vodka__c, Armarios_de_Clube_de_Whisky__c, Ass_cliente__c, 
                Assinatura_coordenador__c, Ass_diretoria__c, Ass_gerente_procurador__c, 
                Assinatura_procurador_regional__c, ActivatedBy__c, Ativacao__c, Ativacao_Comentario__c, 
                Volume_Ballantine_s_12Y__c, Ballantines_12Y_periodo__c, Volume_Ballantine_s_17Y__c, 
                Ballantines_17Y_periodo__c, Volume_Ballantine_s_21Y__c, Ballantines_21Y_periodo__c, 
                Volume_Ballantine_s_30Y__c, Ballantines_30Y_periodo__c, Volume_Ballantine_s_Finest__c, 
                Ballantines_Finest_periodo__c, Banco__c, Base_de_calculo__c, Base_de_c_lculo__c, 
                ROI_Bonificacao__c, ROI_CAAP__c, Percentual_CAAP__c, ROI_CAAP_Net__c, BillingPostalCode__c, 
                ShippingPostalCode__c, CNPJ_Conta__c, Fornecedor_CNPJ_1P__c, Fornecedor_CNPJ_2P__c, 
                Fornecedor_CNPJ_3P__c, Fornecedor_CNPJ_4P__c, Fornecedor_CNPJ_5P__c, Cabine_de_DJ__c, 
                Volume_Cachaca_Janeiro__c, Cachaca_Janeiro_periodo__c, Volume_Cachaca_Sao_Francisco__c, 
                Cachaca_Sao_Francisco_periodo__c, Cachaca_Janeiro__c, Cancelado__c, Cardapio__c, 
                Cardapio_Comentario__c, CustomerSignedTitle__c, StatusCode__c, Exclusiv_promoc_Champagne__c, 
                Prioridade_venda_Champagne__c, Exclusiv_visual_Champagne__c, Champagne_Mumm_Cordon_Rouge__c, 
                Champagne_Perrier_Jouet_Belle_Epoque__c, Champagne_Perrier_Jouet_Grand_Brut__c, 
                Volume_Chivas_Regal_12_Years__c, Chivas_Regal_12_Years_periodo__c, Volume_Chivas_Regal_18_Years__c, 
                Chivas_Regal_18_Years_periodo__c, Volume_Chivas_Regal_25_Years__c, Chivas_Regal_25_Years_periodo__c, 
                BillingCity__c, ShippingCity__c, ROI_Class_Potencial_Volume__c, Cliente_inadimplente__c, 
                Cl_usulas_do_Contrato__c, Clausulas_padrao_PRB__c, Cognac_Martell__c, Comentario_Valor_Minimo_de_Caixa__c, 
                Comentario__c, ROI_Comentarios_Negativo__c, Comunicacao__c, Comunica_o_Comentario__c, 
                Conferido_por_coordenador__c, Conferido_por_assinatura_alteracao__c, Conferido_por_ass_diretoria__c, 
                Conferido_por_ass_gerente_procurador__c, Conferido_por_enc_ass__c, Conferido_por_ass_cliente__c, 
                Conferido_por_ass_procurador__c, Conferido_por_apro_cli__c, Conferido_por_pagamento_1a_parc__c, 
                Conferido_por_doc_ok__c, Conferido_por_aditamento_registrado__c, Conferido_por_adt_ass_cliente__c, 
                Conferido_por_adit_entregue_ao_cliente__c, Conferido_por_adit_enc_cliente__c, 
                Conferido_por_aditamento_gerado__c, Consultoria_de_Mixologistas__c, 
                Consultoria_de_Mixologistas_Coment_rio__c, Conta_Card_pio__c, Conta_Exclusividade_Promocional__c, 
                Conta_Prioridade_de_Venda__c, Conta_Tailor_Made__c, Conta_Visibilidade__c, Conta_corrente__c, 
                Conta_cr_dito__c, Conta_d_bito__c, Contrapartidas_concorrencia__c, Contrato_original__c, 
                CreatedById, Custo_Pernod__c, Porcentagem_custo_Pernod__c, Custo_Pernod_old__c, 
                ROI_Custo_Total_Bonificado__c, Calculo_de_data__c, Data_Quality_Description__c, 
                Data_Quality_Score__c, CompanySignedDate__c, CustomerSignedDate__c, LastApprovedDate__c,
                LastModifiedDate, Data_de_assinatura_do_distrato_cliente__c, ActivatedDate__c, CreatedDate, 
                Data_de_cumprimento_contrapartidas__c, Data_de_inicio_da_vigencia_da_alteracao__c, StartDate__c, 
                Data_de_recebimento_carta_distrato__c, EndDate__c, Data_de_vigencia_do_distrato__c, Description__c, 
                ROI_Dinheiro__c, Distrato_Signatario_da_empresa_2__c, Distrato_Signatario_da_empresa__c, 
                Distrato_Signatario_do_cliente_2__c, Distrato_Signatario_do_cliente__c, Documentacao_ok__c, 
                Volume_Domecq_Tradicional__c, Domecq_Tradicional_periodo__c, Digito_conta_corrente__c, 
                ROI_Margem_CAAP_GS__c, ROI_KPI_visibilidade_GS__c, ROI_KPI_visibilidade_GD__c, ROI_Mix_Produto__c, 
                ROI_Potencial_Volume_GS__c, ROI_KPI_Financeiro_GS__c, ROI_KPI_Financeiro_GD__c, 
                Encaminhado_para_assinatura__c, Espumante_Mumm_Cuvee__c, Espumante_Mumm_Petit__c, 
                Exclusiv_visual_Espumantes__c, Exclusiv_promoc_Espumantes__c, Prioridade_venda_Espumantes__c, 
                BillingState__c, ShippingState__c, Exclusividade__c, IsDeleted, Fase__c, Festas_Data1__c, 
                Festas_Data3__c, Festas_Data6__c, Festas_Data5__c, Festas_Data2__c, Festas_Data4__c, 
                Festas_Marcas6__c, Festas_Marcas_4__c, Festas_Marcas_5__c, Festas_Marcas_1__c, Festas_Marcas_2__c, 
                Festas_Marcas_3__c, Festas_Observacao3_c__c, Festas_Observacao1__c, Festas_Observacao2__c, 
                Festas_Observacao4__c, Festas_Observacao5__c, Festas_Observacao6__c, Festas_Quantidade__c, 
                Festas_Eventos__c, Festas_Eventos_Coment_rio__c, Fornecedor_5__c, Fornecedor_1__c, Fornecedor_3__c, 
                Fornecedor_4__c, Fornecedor_2__c, Gerente__c, Contrato_por__c,
                Gerente_Regional__c, Gerente_de_area__c, Gin_Beefeater__c, Volume_Havana_Club_3_Anos__c, 
                Havana_Club_3_Anos_periodo__c, Volume_Havana_Club_7_anos__c, Havana_Club_7_anos_periodo__c, 
                Volume_Havana_Club_Anejo_Reserva__c, Havana_Club_Anejo_Reserva_periodo__c, Id, OwnerId, 
                CompanySigned__c, CustomerSigned__c, RecordTypeId, ID_tipo_de_registro_alteracao__c, 
                ID_tipo_de_registro_cancelamento__c, Incentivo_da_Brigada__c, Incentivo_da_Brigada_Comentario__c, 
                Informacoes_nao_preenchidas_ROI_Negativo__c, Ingressos_por_abertura_da_Parceira__c, 
                Investimento__c, ROI_Investimento__c, ROI_IMS_Formula__c, 
                Investimento_maximo_sugerido__c, Inicio_da_parceria__c, Inicio_da_vigencia__c, 
                Volume_Jameson_Standard__c, Jameson_Standard_periodo__c, Volume_Jim_Beam_Black__c, 
                Jim_Beam_Black_periodo__c, Volume_Jim_Beam_White__c, Jim_Beam_White_periodo__c, 
                KPI_de_visibilidade__c, Volume_Kahlua__c, Kahlua_periodo__c, Licor_Kahlua__c, 
                Licor_Ricard__c, Volume_Malibu_Nacional__c, Malibu_Nacional_periodo__c, Margem_CAAP__c, 
                ROI_Margem_CAAP__c, Margem_CAAP_GD__c, Margem_CAAP_GS__c, Material__c, 
                Material_Funcional_Comentario__c, SystemModstamp, Volume_Montilla_Cristal__c, 
                Montilla_Cristal_periodo__c, Motivo_de_alteracao__c, Motivo_de_cancelamento_do_contrato__c, 
                Motivo_de_nao_aprovacao__c, Volume_Mumm_Champagne__c, Mumm_Champagne_periodo__c, 
                Volume_Mumm_Espumante__c, Mumm_Espumante_periodo__c, Volume_Natu_Nobilis__c, 
                Natu_Nobilis_periodo__c, Nome_concorrente__c, Account__c, OwnerExpirationNotice__c, Numero_de_Contrato_impressao__c, 
                Numero_do_contrato_off__c, Numero_do_contrato__c, ContractNumber__c, Numero_do_contrato_versao__c, 
                Obs_signatarios__c, Observacoes__c, Volume_Olmeca__c, Olmeca_periodo__c, Volume_Orloff__c, 
                Orloff_periodo__c, Outros_descricao__c, Outros_descricao_motivo_nao_aprovacao__c, 
                Pagamento_1a_parcela__c, Volume_Passport_LBS__c, Passport_LBS_periodo__c, BillingCountry__c, 
                ShippingCountry__c, Percentual_provis_o__c, Perfil_de_imagem__c, Volume_Perrier_Jouet_Belle_Epoque__c, 
                Volume_Perrier_Jouet_Belle_Epq1_5L__c, Perrier_Jouet_Belle_Epq1_5L_periodo__c, 
                Perrier_Jouet_Belle_Epoque_periodo__c, Volume_Perrier_Jouet__c, Volume_Perrier_Jouet_1_5L__c, 
                Perrier_Jouet_1_5L_periodo__c, Perrier_Jouet_periodo__c, Pecas_Tailor_Made_Ambiente_Local3__c, 
                Pecas_Tailor_Made_Ambiente_Local2__c, Pecas_Tailor_Made_Ambiente_Local1__c, 
                Pecas_Tailor_Made_Marcas1__c, Pecas_Tailor_Made_Marcas2__c, Pecas_Tailor_Made_Marcas3__c, 
                Pecas_Tailor_Made_Observacao2__c, Pecas_Tailor_Made_Observacao1__c, Pecas_Tailor_Made_Observacao3__c, 
                Pecas_Tailor_Made_Quantidade__c, ROI_Situacao_Pagamento__c, Potencial_de_volume__c, 
                Prateleiras_dos_Bares__c, Prazo_carta_de_nao_renovacao__c, Prazo_de_prorrogacao_meses__c, 
                ContractTerm__c, Prazo_indeterminado__c, Preve_pagamento_em_dinheiro__c, Produtos__c, 
                Projetos_Especiais__c, Projetos_Especiais_Coment_rio__c, Proposta_de_condicoes_de_cancelamento__c, 
                ROI_Perc_ROI_formula__c, ROI_Perc_ROI_formula_Abs__c, 
                ROI_IndicadorDecisao_X__c, ROI_IndicadorDecisao_Y__c, ROI_Margem_CAAP_Texto__c, 
                Recalcula_Contrato__c, Registro_em_processo_de_clonagem__c, Retorno_KPI_Financeiro__c, 
                Volume_Royal_Salute__c, Volume_Royal_Salute_38YO__c, Royal_Salute_38YO_periodo__c, 
                Royal_Salute_periodo__c, BillingStreet__c, ShippingStreet__c, Exclusiv_visual_Rum_Importado__c, 
                Exclusiv_promoc_Rum_Importado__c, Prioridade_venda_Rum_Importado__c, Rum_Importado_Havana_Club__c, 
                Prioridade_venda_Rum_Nacional__c, Exclusiv_promoc_Rum_Nacional__c, Exclusiv_visual_Rum_Nacional__c, 
                Rum_Nacional_Malibu__c, Rum_Nacional_Montila__c, Volume_Sandeman__c, Sandeman_periodo__c, 
                Signatario_da_empresa_2__c, Signatario_da_empresa__c, Signatario_do_cliente__c, ROI_Situacao_Rateio__c, 
                Situacao_do_cliente__c, Solicitacao__c, Status__c, Status_da_INtegra_o__c, Status_do_processo__c, 
                ROI_TInvestment__c, Tailor_made__c, Tailor_Made_Comentario__c, Volume_Teachers__c, Teachers_periodo__c, 
                Telefone_Fornecedor_01__c, Telefone_fornecedor_02__c, Telefone_fornecedor_03__c, Telefone_fornecedor_04__c, 
                Telefone_fornecedor_05__c, Prioridade_venda_Tequila_Std__c, Exclusiv_visual_Tequila__c, 
                Exclusiv_promoc_Tequila__c, Prioridade_venda_Tequila_S_Premium__c, Exclusiv_visual_Tequila_super_premium__c, 
                Exclusiv_promoc_Tequila_super_premium__c, SpecialTerms__c, Volume_Tezon__c, Tezon_periodo__c, 
                Tipo_de_contrato__c, Tipo_de__c, Tipo_de_contrato_on__c, Tipo_de_documento__c, 
                Tipo_de_verba__c, ROI_Total_Contrato__c, Total_Contrato__c, ROI_Total_Contrato_Outros__c, 
                ROI_Total_Contrato_Vodka__c, ROI_Total_Contrato_Whisky__c, ROI_Total_Investimento__c, 
                Total_M_s__c, ROI_Total_Mes_Outros__c, ROI_Total_Mes_Vodka__c, ROI_Total_Mes_Whisky__c, 
                ROI_Total_de_Pontos_Visibilidade__c, ROI_Total_do_Rateio__c, ROI_Total_Dinheiro__c, 
                Termino_da_vigencia__c, Uniforme__c, Uniforme_Comentario__c, Valor_do_contrato__c, 
                Valor_provis_o__c, Valores_e_Pagamentos__c, Venda_de_Garrafa__c, Venda_de_Garrafa_Comentario__c, 
                Verba_disponivel__c, Exclusiv_visual_Vinhos__c, Exclusiv_promoc_Vinhos__c, Prioridade_venda_Vinhos__c, 
                Vinhos_Graffigna__c, Vinhos_Jacobs_Creek__c, Vinhos_Marques_de_Arienzo__c, Visibilidade_do_produto__c, 
                Visibilidade_do_produto_Comentario__c, Exclusiv_promoc_Vodka_Super_Premium__c, 
                Exclusiv_visual_Vodka_Super_Premium__c, Prioridade_venda_Vodka_Super_Premium__c, 
                Prioridade_venda_Vodkas_Importadas__c, Exclusiv_visual_Vodkas_Importadas__c, Exclusiv_promoc_Vodkas_Importadas__c, 
                Vodkas_importadas_Absolut__c, Vodkas_importadas_Absolut_Elyx__c, Vodkas_importadas_Absolut_Flavours__c, 
                Vodkas_importadas_Wyborowa__c, Vodkas_importadas_Wyborowa_Exquisite__c, Exclusiv_promoc_Vodkas_Nacionais__c, 
                Prioridade_venda_Vodkas_Nacionais__c, Exclusiv_visual_Vodkas_Nacionais__c, Vodkas_nacionais_Orloff__c, 
                Volume_do_contrato_CA__c, Volume_Wall_Street__c, Wall_Street_periodo__c, 
                Prioridade_venda_Whiskie_Americano__c, Exclusiv_visual_Whiskie_Bourbon__c, 
                Exclusiv_promoc_Whiskie_Bourbon__c, Exclusiv_visual_Whiskie_Irlandes__c, 
                Exclusiv_promoc_Whiskie_Irlandes__c, Prioridade_venda_Whiskie_Irlandes__c, 
                Exclusiv_promoc_Whisky_12_anos__c, Exclusiv_visual_Whisky_12_anos__c, 
                Prioridade_venda_Whisky_12_anos__c, Whisky_Bourbon_Jim_Bean__c, Exclusiv_promoc_Whisky_Engarrafado__c, 
                Prioridade_venda_Whisky_Engarrafado__c, Exclusiv_visual_Whisky_Engarrafado__c, 
                Whisky_Engarrafado_Passport__c, Whisky_Engarrafado_Teachers__c, Whisky_Irlandes_Jameson__c, 
                Exclusiv_promoc_Whisky_Nacional__c, Prioridade_venda_Whisky_Nacional__c, Exclusiv_visual_Whisky_Nacional__c, 
                Whisky_Nacional_Natu_Nobilis__c, Whisky_Premium_12_anos_Ballantines_12__c, Whisky_Premium_12_anos_Chivas_12__c, 
                Prioridade_venda_Whisky_Std__c, Exclusiv_promoc_Whisky_Std__c, Exclusiv_visual_Whisky_Std__c, 
                Whisky_Std_Ballantines_Finest__c, Exclusiv_visual_Whisky_Super_Premium__c, Exclusiv_promoc_Whisky_Super_Premium__c, 
                Prioridade_venda_Whisky_Super_Premium__c, Whisky_Super_Premium_Ballantines_17__c, 
                Whisky_Super_Premium_Ballantines_21__c, Whisky_Super_Premium_Ballantines_30__c, 
                Whisky_Super_Premium_Chivas_18__c, Whisky_Super_Premium_Chivas_25__c, Whisky_Super_Premium_Royal_Salute__c, 
                Volume_Wyborowa_Exquisite__c, Wyborowa_Exquisite_periodo__c, trigger_on__c, Account__r.Channel__c
            from LAT_Contract__c where id=:aContratoID AND RecordTypeId =: setRecTypeLatCon ];
    if ( lVelhoContrato.size() == 0 ) return 'Erro interno. Contrato não encontrado. Contate o administrador do sistema.';
    LAT_Contract__c lNovoContrato = lVelhoContrato[0].clone( false, true, false, false );
    lNovoContrato.Status_da_INtegra_o__c = '';
    lNovoContrato.MensagemIntegracao__c = '';
    String lRecType;
    if ( lVelhoContrato[0].Account__r.Channel__c == 'On Trade' )
      lRecType = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on' );
    else
      lRecType = RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF' );
    lNovoContrato.RecordTypeId = lRecType;
    lNovoContrato.Status_do_processo__c = 'Estudo de alteração de contrato';
    lNovoContrato.Status__c = 'Em elaboração';
    lNovoContrato.Obs_signatarios__c = '';
    lNovoContrato.Signatario_da_empresa_2__c = '';
    lNovoContrato.Signatario_da_empresa__c = '';
    lNovoContrato.Signatario_do_cliente__c = null;
    lNovoContrato.CustomerSigned__c = null;
    
    String lContratoOriginal;
    if ( lVelhoContrato[0].Contrato_original__c == null ) lContratoOriginal = lVelhoContrato[0].id;
    else lContratoOriginal = lVelhoContrato[0].Contrato_original__c;
    lNovoContrato.Contrato_original__c = lContratoOriginal;
    List< AggregateResult > lContador = [ SELECT max(Numero_do_contrato_versao__c) 
                                                 FROM LAT_Contract__c 
                                                 WHERE Contrato_original__c =: lContratoOriginal 
                                                 AND RecordTypeId =: setRecTypeLatCon ];
                                                 
    Object lNovaVersao = lContador[0].get( 'expr0' );
    if ( lNovaVersao == null ) lNovoContrato.Numero_do_contrato_versao__c = 1;
    else lNovoContrato.Numero_do_contrato_versao__c = Integer.ValueOf(lNovaVersao) + 1;

    insert lNovoContrato;
    
    Map< String, Cl_usulas_do_Contrato__c > lNovasClausulas = new Map< String, Cl_usulas_do_Contrato__c >();
    Map< String, Investimento_Bonificacao_e_Pagamento__c > lNovosIBP = new Map< String, Investimento_Bonificacao_e_Pagamento__c >();
    
    List< Investimento_Bonificacao_e_Pagamento__c > lListaNovosIBP = IBPClone( lVelhoContrato[ 0 ].id, lNovoContrato.id, lNovosIBP );
    List< Rateio_do_Contrato__c > lListaNovosRateios = RateioClone( lVelhoContrato[ 0 ].id, lNovoContrato.id );
    List< Agrupamento_Fiscal_Year__c > lListaAgrupamentos = agrupamentoClone( lVelhoContrato[ 0 ].id, lNovoContrato.id );
    List< Cl_usulas_do_Contrato__c > lListaNovasClausulas = ClausulasClone( lVelhoContrato[ 0 ].id, lNovoContrato.id, lNovasClausulas );
    List< Tipo_de_Documento__c > lListaNovosTipoDoc = TipoDocClone( lVelhoContrato[ 0 ].id, lNovoContrato.id );
    
    // Save all objects
    insert lListaNovosIBP;
    insert lListaNovosRateios;
    //insert lListaAgrupamentos;
    insert lListaNovasClausulas;
    insert lListaNovosTipoDoc;
    
    
    List< Pagamento_da_Verba__c > lListaVerbaPagto = PagtoVerbaClone( lNovosIBP );
    
    
    List< Distribui_o_de_Valores__c > lListaNovosValores = ValoresClone( lNovasClausulas );
    
    insert lListaNovosValores;
    insert lListaVerbaPagto;
    //Pagereference pageR = new Pagereference('/e?'+lNovoContrato.id);
    //return pageR;
    return lNovoContrato.id+'/e?retURL=%2F'+lNovoContrato.id;
  }
  
  private static List< Investimento_Bonificacao_e_Pagamento__c > IBPClone( String aContractId, 
           String aNewContractId, Map< String, Investimento_Bonificacao_e_Pagamento__c > aMapa )
  {
    Set< Id > setRecTypeInv = new Set< Id >();
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
    setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
    
    List< Investimento_Bonificacao_e_Pagamento__c > lListaNovoIBP = new List< Investimento_Bonificacao_e_Pagamento__c >();
    
    List< Investimento_Bonificacao_e_Pagamento__c > lListaVelhoIBP = 
                [ SELECT Perc_de_Rateio__c, Ano_Calendario__c, Ano_Fiscal__c, Cliente__c, Conta__c, 
                         LAT_Contract__c, CreatedById, Custo_Bonificado__c, LastActivityDate, LastModifiedDate, 
                         Data_de_Encerramento__c, Data_de_Previsao_do_Pagamento__c, CreatedDate, 
                         Descricao__c, IsDeleted, Finalidade__c, OwnerId, Id, RecordTypeId, SystemModstamp, 
                         Mes__c, Numero_da_DA__c, Numero_da_RV_criada__c, Objetivo__c, OldFinalidade__c, 
                         Produto_Bonificado__c, Saldo_Caixas__c, Saldo_R__c, ScheduleC_Bonificado__c, Name, 
                         Status_da_Verba__c, Tipo_de_Verba__c, Valor_R__c, Valor_Percebido__c, 
                         Verba_Adiantada__c, Verba_Extra__c, Verba_Normal__c, Verba_Reservada__c, 
                         Verba_do_Sistema__c, Volume_Cx__c, LastModifiedById,
                         Valor_Pago_R__c, Volume_Pago_Cx__c
                 FROM Investimento_Bonificacao_e_Pagamento__c WHERE LAT_Contract__c =: aContractId 
                 AND RecordTypeId =: setRecTypeInv ];
    
    for ( Investimento_Bonificacao_e_Pagamento__c lVelhoIBP : lListaVelhoIBP )
    {
      Investimento_Bonificacao_e_Pagamento__c lNovoIBP = lVelhoIBP.clone( false, true, false, false );
      lNovoIBP.LAT_Contract__c = aNewContractId;
      if( lVelhoIBP.Status_da_Verba__c == 'Em preenchimento' || lVelhoIBP.Status_da_Verba__c == 'Reservado' ){
        lNovoIBP.Status_da_Verba__c = 'Em preenchimento';
      }
      else{
        lNovoIBP.Status_da_Verba__c = 'Encerrado';
      }
      lNovoIBP.Valor_Pago_R__c = 0;
      lNovoIBP.Volume_Pago_Cx__c = 0;
      
      lListaNovoIBP.add( lNovoIBP );
      aMapa.put( lVelhoIBP.id, lNovoIBP );
    }
    return lListaNovoIBP;
  }
  
  private static Map< String, Pagamento__c > pagamentoClone( List< String > aPagtos )
  {
    Set< Id > setRecTypePag = new Set< Id >();
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Bonificacao_Produtos' ));
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Bonifica_o_Produtos_Bloqueado' ));
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Dinheiro' ));
    setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Dinheiro_Bloqueado' ));
    
    List< Pagamento__c > lListaNovoPagto = new List< Pagamento__c >();
    Map< String, Pagamento__c > lMapaVelhoNovo = new Map< String, Pagamento__c >();
    
    List< Pagamento__c > lListVelhoPagto = [ SELECT Cliente__c, CreatedById, LastActivityDate, 
                           LastModifiedDate, CreatedDate, Data_do_Pagamento__c, Emitente__c, IsDeleted, 
                           OwnerId, Id, RecordTypeId, SystemModstamp, Name, Observacoes_Complementares__c, 
                           Possui_Anexo__c, Recebedor__c, Solicitante__c, Status__c, Forma_de_Pagamento__c, 
                           Total_Volume_Cx__c, Valor_Total__c, LastModifiedById 
                           FROM Pagamento__c WHERE id=:aPagtos AND RecordTypeId =: setRecTypePag ];
    for ( Pagamento__c lVelhoPagto : lListVelhoPagto )
    {
      Pagamento__c lNovoPagto = lVelhoPagto.clone( false, true, false, false );
      lListaNovoPagto.add( lNovoPagto );
      lMapaVelhoNovo.put( lVelhoPagto.id, lNovoPagto );
    }
    insert lListaNovoPagto;
    return lMapaVelhoNovo;
  }
  
 private static List< Pagamento_da_Verba__c > PagtoVerbaClone( Map< String, Investimento_Bonificacao_e_Pagamento__c > aMapa )
  {
        if(!Utils.wasMigrationDone('1')) {  
            Set< Id > setRecTypePV = new Set< Id >();
            setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos'));
            setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro'));
            List< Pagamento_da_Verba__c > lListaNovoPagtoVerba = new List< Pagamento_da_Verba__c >();
            
            List< String > lListIBPID = new List< String >();
            lListIBPID.addAll( aMapa.keySet() );
            
            List< Pagamento_da_Verba__c > lListaVelhoVerba =
                         [Select CreatedById, Produto_da_SV__c, LastActivityDate, LastModifiedDate, CreatedDate, 
                                 IsDeleted, Id, RecordTypeId, Investimento_Bonifica_o_e_Pagamento__c, 
                                 MensagemIntegracao__c, SystemModstamp, Numero_retorno_Pagamento__c, 
                                 Pagamento__c, pagar_com_produto__c, Sado_da_SV_R__c, Saldo_da_SV_Volume_cx__c, 
                                 Status__c, Tipo_de_Registro_Pai_del__c, valor_a_pagar__c, Name, volume_a_pagar__c, 
                                 LastModifiedById, trigger_on__c, Investimento_Bonifica_o_e_Pagamento__r.Status_da_verba__c
                          from Pagamento_da_Verba__c where Investimento_Bonifica_o_e_Pagamento__c =:lListIBPID 
                          AND RecordTypeId =: setRecTypePV ];
            
            // Clonagem dos Pagamento 
            List< String > lListPagamento = new List< String >();
            for ( Pagamento_da_Verba__c lVelhoVerba : lListaVelhoVerba )
            {
              lListPagamento.add( lVelhoVerba.Pagamento__c );
            }
            
            Map< String, Pagamento__c > lMapaPagto = pagamentoClone( lListPagamento );
            
            // Clonagem do Pagamento da Verba
            for ( Pagamento_da_Verba__c lVelhoVerba : lListaVelhoVerba )
            {
              Pagamento_da_Verba__c lNovoVerba = lVelhoVerba.clone( false, true, false, false );
              lNovoVerba.Investimento_Bonifica_o_e_Pagamento__c = aMapa.get( lVelhoVerba.Investimento_Bonifica_o_e_Pagamento__c ).Id;
              lNovoVerba.Pagamento__c = lMapaPagto.get( lVelhoVerba.Pagamento__c ).id;
                if(lNovoVerba.Investimento_Bonifica_o_e_Pagamento__r.Status_da_verba__c == 'Em preenchimento'
                || lNovoVerba.Investimento_Bonifica_o_e_Pagamento__r.Status_da_verba__c == 'Reservado'){
                    System.debug('ENTROU!!');
                    lNovoVerba.trigger_on__c = true;
                }
              lListaNovoPagtoVerba.add( lNovoVerba );
            }
            
            return lListaNovoPagtoVerba;
        }
        //MIGRATED 18/11/2016
        else {
            Set< Id > setRecTypePV = new Set< Id >();
            setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos'));
            setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro'));
            List< Pagamento_da_Verba__c > lListaNovoPagtoVerba = new List< Pagamento_da_Verba__c >();
            
            List< String > lListIBPID = new List< String >();
            lListIBPID.addAll( aMapa.keySet() );
            
            List< Pagamento_da_Verba__c > lListaVelhoVerba =
                         [Select CreatedById, Produto_da_SV__c, LastActivityDate, LastModifiedDate, CreatedDate, 
                                 IsDeleted, Id, RecordTypeId, Investimento_Bonifica_o_e_Pagamento__c, 
                                 MensagemIntegracao__c, SystemModstamp, Numero_retorno_Pagamento__c, 
                                 Pagamento__c, LAT_Product__c, Sado_da_SV_R__c, Saldo_da_SV_Volume_cx__c, 
                                 Status__c, Tipo_de_Registro_Pai_del__c, valor_a_pagar__c, Name, volume_a_pagar__c, 
                                 LastModifiedById, trigger_on__c, Investimento_Bonifica_o_e_Pagamento__r.Status_da_verba__c
                          from Pagamento_da_Verba__c where Investimento_Bonifica_o_e_Pagamento__c =:lListIBPID 
                          AND RecordTypeId =: setRecTypePV ];
            
            // Clonagem dos Pagamento 
            List< String > lListPagamento = new List< String >();
            for ( Pagamento_da_Verba__c lVelhoVerba : lListaVelhoVerba )
            {
              lListPagamento.add( lVelhoVerba.Pagamento__c );
            }
            
            Map< String, Pagamento__c > lMapaPagto = pagamentoClone( lListPagamento );
            
            // Clonagem do Pagamento da Verba
            for ( Pagamento_da_Verba__c lVelhoVerba : lListaVelhoVerba )
            {
              Pagamento_da_Verba__c lNovoVerba = lVelhoVerba.clone( false, true, false, false );
              lNovoVerba.Investimento_Bonifica_o_e_Pagamento__c = aMapa.get( lVelhoVerba.Investimento_Bonifica_o_e_Pagamento__c ).Id;
              lNovoVerba.Pagamento__c = lMapaPagto.get( lVelhoVerba.Pagamento__c ).id;
                if(lNovoVerba.Investimento_Bonifica_o_e_Pagamento__r.Status_da_verba__c == 'Em preenchimento'
                || lNovoVerba.Investimento_Bonifica_o_e_Pagamento__r.Status_da_verba__c == 'Reservado'){
                    System.debug('ENTROU!!');
                    lNovoVerba.trigger_on__c = true;
                }
              lListaNovoPagtoVerba.add( lNovoVerba );
            }
            
            return lListaNovoPagtoVerba;
        }
  }
  
  private static List< Rateio_do_Contrato__c > RateioClone( String aContractId, String aNewContractId )
  {
    Id idRecTypeRC = RecordTypeForTest.getRecType( 'Rateio_do_Contrato__c' , 'BRA_Standard' );
    List< Rateio_do_Contrato__c > lListaNovoRateio = new List< Rateio_do_Contrato__c >();
    
    List< Rateio_do_Contrato__c > lListaVelhoRateio = 
                       [ select Perc_de_Rateio__c, Agrupamento_ME__c, LAT_Contract__c, CreatedById, 
                                Custo_Pernod__c, LastActivityDate, LastModifiedDate, CreatedDate, 
                                IsDeleted, OwnerId, Id, SystemModstamp, Name, 
                                Total_Contrato__c, LastModifiedById 
                         from Rateio_do_Contrato__c where LAT_Contract__c =: aContractId ]; //Se quitó del query el campo "Produto__c"
    
    for ( Rateio_do_Contrato__c lVelhoRateio : lListaVelhoRateio )
    {
      Rateio_do_Contrato__c lNovoRateio = lVelhoRateio.clone( false, true, false, false );
      lNovoRateio.LAT_Contract__c = aNewContractId;
      lListaNovoRateio.add( lNovoRateio );
    }
    return lListaNovoRateio;
  }
  
  
  private static List< Cl_usulas_do_Contrato__c > ClausulasClone( String aContractId, 
                String aNewContractId, Map< String, Cl_usulas_do_Contrato__c > aMapa )
  {
    Id idRecTypeRC = RecordTypeForTest.getRecType( 'Cl_usulas_do_Contrato__c' , 'Clausulas_do_Contrato' );
    
    List< Cl_usulas_do_Contrato__c > lListaNovoClausula = new List< Cl_usulas_do_Contrato__c >();
    
    List< Cl_usulas_do_Contrato__c > lListaVelhoClausula =
                              [ Select Ativo__c, Name, 
                                       Conta_de_Credito__c, Conta_de_Debito__c, Contrato__c, 
                                       CreatedById, C_digo__c, Codigo_Base_de_Calculo__c, 
                                       LastActivityDate, LastModifiedDate, CreatedDate, Descricao__c, 
                                       IsDeleted, Id, RecordTypeId, SystemModstamp, 
                                       Percentual__c, Status__c, Tipo_de_Calculo__c, 
                                       Valor__c, LastModifiedById
                               From Cl_usulas_do_Contrato__c where Contrato__c =: aContractId 
                               AND RecordTypeId =: idRecTypeRC ];
    
    for ( Cl_usulas_do_Contrato__c lVelhaClausula : lListaVelhoClausula )
    {
      Cl_usulas_do_Contrato__c lNovaClausula = lVelhaClausula.clone( false, true, false, false );
      lNovaClausula.Contrato__c = aNewContractId;
      lListaNovoClausula.add( lNovaClausula );
      aMapa.put( lVelhaClausula.id, lNovaClausula );
    }
    return lListaNovoClausula;
  }
  
  private static List< Distribui_o_de_Valores__c > ValoresClone( Map< String, Cl_usulas_do_Contrato__c > aMapa )
  {
    Id idRecTypeDV = RecordTypeForTest.getRecType( 'Distribui_o_de_Valores__c', 'BRA_Standard' );
    
    List< Distribui_o_de_Valores__c > lListaNovoValores = new List< Distribui_o_de_Valores__c >();
    
    List< String > lListClausulasID = new List< String >();
    lListClausulasID.addAll( aMapa.keySet() );
    
    List< Distribui_o_de_Valores__c > lListaVelhoValores =
                 [Select Ano_Fiscal_para_Apuracao__c, Ano_de_Referencia_para_Apuracao__c, 
                         Clausulas_do_Contrato__c, CreatedById, LastActivityDate, LastModifiedDate, 
                         CreatedDate, Name, IsDeleted, Id, SystemModstamp, Mes_de_Referencia_para_Apuracao__c, 
                         Valor_da_Parcela_R__c, LastModifiedById, Data_de_Referencia_para_Apuracao__c
                  from Distribui_o_de_Valores__c where Clausulas_do_Contrato__c =:lListClausulasID
                  AND RecordTypeId =: idRecTypeDV ];
    
    for ( Distribui_o_de_Valores__c lVelhoValor : lListaVelhoValores )
    {
        Distribui_o_de_Valores__c lNovoValor = lVelhoValor.clone( false, true, false, false );
        lNovoValor.Clausulas_do_Contrato__c = aMapa.get( lVelhoValor.Clausulas_do_Contrato__c ).Id;
        lListaNovoValores.add( lNovoValor );
    }
    
    return lListaNovoValores;
  }
  
  private static List< Tipo_de_Documento__c > TipoDocClone( String aContractId, String aNewContractId )
  {
    Id idRecTypeTD = RecordTypeForTest.getRecType('Tipo_de_Documento__c', 'Tipo_de_Documento');
    
    List< Tipo_de_Documento__c > lListaNovoTipoDoc = new List< Tipo_de_Documento__c >();
    
    List< Tipo_de_Documento__c > lListaVelhoTipoDoc =
                              [ Select LAT_Contract__c, CreatedById, Codigo_do_Documento__c, 
                                       LastModifiedDate, CreatedDate, IsDeleted, Id, RecordTypeId, 
                                       SystemModstamp, Name, LastModifiedById
                               From Tipo_de_Documento__c where LAT_Contract__c =: aContractId ];
    
    for ( Tipo_de_Documento__c lVelhaTipoDoc : lListaVelhoTipoDoc )
    {
      Tipo_de_Documento__c lNovaTipoDoc = lVelhaTipoDoc.clone( false, true, false, false );
      lNovaTipoDoc.LAT_Contract__c = aNewContractId;
      lListaNovoTipoDoc.add( lNovaTipoDoc );
    }
    return lListaNovoTipoDoc;
  }

  private static List< Agrupamento_Fiscal_Year__c > agrupamentoClone( String aContractId, String aNewContractId )
  {
    Id idRecTypeAgr = RecordTypeForTest.getRecType( 'Agrupamento_Fiscal_Year__c', 'BRA_Standard' );
    
    List< Agrupamento_Fiscal_Year__c > lListaNovoAgrupamento = new List< Agrupamento_Fiscal_Year__c >();
    
    List< Agrupamento_Fiscal_Year__c > lListaVelhoAgrupamento =
                              [ Select Name, Ano_Fiscal__c, LAT_Contract__c, CreatedById, LastActivityDate, 
                                   LastModifiedDate, CreatedDate, IsDeleted, OwnerId, Id, SystemModstamp, 
                                   Numero_da_D_A__c, Numero_da_RV_criada__c, Sistema__c, Status_da_Integra_o__c, 
                                   Tipo_de_Workflow__c, valor_total__c, Verba_Adiantada__c, Verba_Extra__c, 
                                   Verba_Normal__c, Verba_Reservada__c, Volume_Total__c, LastModifiedById
                               From Agrupamento_Fiscal_Year__c where LAT_Contract__c =: aContractId 
                               AND RecordTypeId =: idRecTypeAgr ];
    
    for ( Agrupamento_Fiscal_Year__c lVelhaAgrupamento : lListaVelhoAgrupamento )
    {
      Agrupamento_Fiscal_Year__c lNovaAgrupamento = lVelhaAgrupamento.clone( false, true, false, false );
      lNovaAgrupamento.LAT_Contract__c = aNewContractId;
      lListaNovoAgrupamento.add( lNovaAgrupamento );
    }
    return lListaNovoAgrupamento;
  }

}