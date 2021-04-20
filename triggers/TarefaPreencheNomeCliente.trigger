/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Após a criação de uma tarefa se o campo WHATID estiver preenchido é recuperado
* o NAME da conta seja relacionado. Objetos previstos para preenchimento
* (Account, Opportunity, Case, Investimento_Bonificacao_e_Pagamento__c,
* Pagamento__c e Pagamento_da_Verba__c).
*
* NAME: TarefaPreencheNomeCliente.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 24/10/2012
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS
* OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 09/01/2013
********************************************************************************/
trigger TarefaPreencheNomeCliente on Task (before insert, before update) {

    //    Check if this trigger is bypassed by SESAME (data migration Brazil)
    if ((UserInfo.getProfileId() != '00eM0000000QNYPIA4') && (UserInfo.getProfileId() != '00eD0000001AnFlIAK')) {

        //Declaração de variáveis
        List< String > listWhatID = new List< String >();
        List< Task > listTask = new List< Task >();
        List< Opportunity > listOpp;
        List< Account > listAcc;
        List< Investimento_Bonificacao_e_Pagamento__c > listIBP;
        List< Pagamento__c > listPag;
        List< Pagamento_da_Verba__c > listPV;
        List< Case > listCase;
        Map< String, String > mapNameAccount = new Map< String, String >();
        Set< Id > setRecTypeTask = new Set< Id >();
        Set< Id > setRecTypeAcc = new Set< Id >();
        Set< Id > setRecTypeOpp = new Set< Id >();
        Set< Id > setRecTypeInv = new Set< Id >();
        Set< Id > setRecTypePag = new Set< Id >();
        Set< Id > setRecTypePV = new Set< Id >();
        Set< Id > setRecTypeCase = new Set< Id >();

        //Recupera ids de tipo de registro
        setRecTypeTask.add( RecordTypeForTest.getRecType('Task', 'Revis_o_de_Planejamento_de_Visita_Semanal'));
        setRecTypeTask.add( RecordTypeForTest.getRecType('Task', 'Planejamento_de_Visitas_Mensal'));
        setRecTypeTask.add( RecordTypeForTest.getRecType('Task', 'Padrao'));
        setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Eventos'));
        setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'Off_Trade'));
        setRecTypeAcc.add( RecordTypeForTest.getRecType( 'Account', 'On_Trade'));


        /*
        setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Bloqueia_alteracao'));
        setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Bloqueia_alteracao_do_cabecalho'));
        setRecTypeOpp.add( RecordTypeForTest.getRecType('Opportunity', 'Nova_oportunidade'));
        setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos') );
        setRecTypeInv.add( RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro') );
        setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Bonificacao_Produtos' ));
        setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Bonifica_o_Produtos_Bloqueado' ));
        setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Dinheiro' ));
        setRecTypePag.add( RecordTypeForTest.getRecType( 'Pagamento__c' , 'Dinheiro_Bloqueado' ));
        setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Bonificacao_Produtos'));
        setRecTypePV.add( RecordTypeForTest.getRecType( 'Pagamento_da_Verba__c', 'Dinheiro'));
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Alteracao_rota_de_promotor') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Alteracao_cadastro_de_clientes') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Cancelar_D_A_no_sistema_ME') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Cliente_inadimplente') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_aprovacao_de_proposta') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_Assinatura_da_diretoria') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_Assinatura_de_distrato_procurador') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_Assinatura_do_procurador') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_Negociacao_de_cancelamento') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_Processo_de_prorrogacao') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_Proposta_de_renovacao') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_assinatura_de_distrato_do_cliente') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_assinatura_de_prorrogacao_de_contrato') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_assinatura_prorroga_o_do_cliente') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_coleta_de_assinatura_do_cliente') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_coleta_de_assinatura_do_cliente_off') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_conferencia_de_documentacao') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_entrega_do_contrato') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_nao_renovacao_de_contrato') );
        setRecTypeCase.add( RecordTypeForTest.getRecType('Case', 'Contrato_renovacao_de_contrato') );
        */

        for ( Task task : trigger.new ) {
            if ( task.WhatId != null && setRecTypeTask.contains( task.RecordTypeId ) ) {
                listWhatID.add( task.WhatId );
                listTask.add( task );
            }
        }
        //If the RT of the task is not between the expected, return.
        if (listTask.size() == 0 ) {
            return;
        }

        if ( listWhatID.size() == 0 ) {
            for (Task t : listTask ) {
                t.Cliente__c = 'Cliente não relacionado';
            }
        } else {

            listAcc = [ SELECT Id, Name
                        FROM Account
                        WHERE Id = : listWhatID
                                   AND RecordTypeId = : setRecTypeAcc];

            if ( listAcc.size() > 0 ) {
                for ( Account acc : listAcc ) {
                    mapNameAccount.put( acc.Id, acc.Name );
                }
            }

            /*
            listOpp = [ SELECT Id, AccountId, Account.Name
                               FROM Opportunity
                               WHERE Id =: listWhatID
                               AND RecordTypeId =: setRecTypeOpp ];

            listIBP = [ SELECT Id, LAT_Contract__r.Account__c, LAT_Contract__r.Account__r.Name
                               FROM Investimento_Bonificacao_e_Pagamento__c
                               WHERE Id =: listWhatID
                               AND RecordTypeId =: setRecTypeInv];

            listPag = [ SELECT Id, Cliente__c, Cliente__r.Name
                               FROM Pagamento__c
                               WHERE Id =: listWhatID
                               AND RecordTypeId =: setRecTypePag];

            listPV = [ SELECT Id, Pagamento__c, Pagamento__r.Cliente__r.Name
                              FROM Pagamento_da_Verba__c
                              WHERE Id =: listWhatID
                              AND RecordTypeId =: setRecTypePV];

            listCase = [ SELECT Id, Account.Name
                                FROM Case
                                WHERE Id =: listWhatID
                                AND RecordTypeId =: setRecTypeCase];
            if( listOpp.size() > 0 ){
                for( Opportunity opp : listOpp ){
                  mapNameAccount.put( opp.Id, opp.Account.Name );
                }
            }

            if( listIBP.size() > 0 ){
                for( Investimento_Bonificacao_e_Pagamento__c i : listIBP ){
                    mapNameAccount.put( i.Id, i.LAT_Contract__r.Account__r.Name );
                }
            }
            if( listPag.size() > 0 ){
                for( Pagamento__c pag : listPag ){
                    mapNameAccount.put( pag.Id, pag.Cliente__r.Name );
                }
            }
            if( listPV.size() > 0 ){
                for( Pagamento_da_Verba__c pv : listPV ){
                    mapNameAccount.put( pv.Id, pv.Pagamento__r.Cliente__r.Name );
                }
            }
            if( listCase.size() > 0 ){
                for( Case c : listCase ){
                    mapNameAccount.put( c.Id, c.Account.Name );
                }
            }
            */


            for ( Task task : listTask ) {
                String lAccName = mapNameAccount.get( task.WhatId );
                if ( lAccName != null ) task.Cliente__c = lAccName;
                else task.Cliente__c = 'Cliente não relacionado';

            }
        }
    }
}