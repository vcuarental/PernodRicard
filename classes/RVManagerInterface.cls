/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Interface responsável pelo envio das solicitações de verba para os sistemas
* ME e SCV
* NAME: RVManagerInterface.cls
* AUTHOR: CARLOS CARVALHO                         DATE: 17/09/2012
*
*-------------------------------------------------------------------------------
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                         DATE: 08/10/2012
*******************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/
global class RVManagerInterface {
    
    private static final Integer COD_EMPRESA = 81;
    private static final Integer COD_PAIS = 1;
    
    @future(callOut=true)
    webservice static void RVManagerInvoke( String aIdIBP, String aIdPagamento )
    {
        if(!Utils.wasMigrationDone('1')) {      
            if( aIdIBP == null || aIdIBP.trim().equals('') ) return;
            
            //Declaração de variaveis
            Long numeroVAD;
            String lAction;
            String tipoRegistro = '';
            Id idRecTypeDinheiro;
            Id idRecTypeProduto;
            Pagamento__c pagamento;
            Investimento_Bonificacao_e_Pagamento__c ibp;
            ProcessInstanceStep app = null;
            List< Rateio_do_Contrato__c > listRateio = new List< Rateio_do_Contrato__c >();
            List< ProcessInstanceStep > listProcessStep = new List< ProcessInstanceStep >();
            Map< String, String > mapTipoVerba = new Map< String, String >();
            String tipoVerba;
            String finalidade;
            String emitente, solicitante, aprovador;
            
            //Recupera um registro de IBP
            ibp = InvestimentoBonificaoPagamentoDAO.getInstance().getIBPById( aIdIBP );
            
            //Verifica se houve retorno de algum registro de IBP
            if( ibp == null ) return;
            
            //Atribui os usuarios Globais de acordo com o sistema
            if( ibp.Sistema__c == 'SCV' ){
              emitente       = 'SCVCRMBR';
              solicitante    = 'SCVCRMBR';
              aprovador      = 'SCVCRMBR';
            }else if( ibp.Sistema__c == 'ME' ){
              emitente       = 'MECRMBR';
              solicitante    = 'MECRMBR';
              aprovador      = 'MECRMBR';
            }
            
            //Recupera aprovação de ibp
            listProcessStep           = [Select Id, CreatedDate, CreatedBy.UserName, Comments, StepStatus
                                          from ProcessInstanceStep 
                                          Where ProcessInstance.TargetObjectId =: aIdPagamento
                                          order by CreatedDate Desc];
            
            //Recupera tipos de registro de Investimento_Bonificacao_e_Pagamento__c
            idRecTypeDinheiro = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro');
            idRecTypeProduto = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos');
            
            try{
              pagamento = PagamentoDAO.getInstance().getPagamentoById( aIdPagamento );
            }catch(QueryException e){
              System.debug(e.getMessage());
            }
            
            //Monta um map com todos os tipos de verba
            mapTipoVerba = setListTipoVerba();
            //Recupera o tipo de verba do contrato
            tipoVerba = mapTipoVerba.get( ibp.LAT_Contract__r.Tipo_de_verba__c );
            
            //Recupera a finalidade
            finalidade = Utils.getCodeFromUDC( ibp.Finalidade_SCV__c );
            
            
            //Preenche a variavel de acordo com o tipo de registro
            if( ibp.RecordTypeId == idRecTypeDinheiro ) tipoRegistro = 'D';
            else if( ibp.RecordTypeId == idRecTypeProduto ) tipoRegistro = 'P';
            
            //VErifica se foram retornadas aprovações.        
            if( listProcessStep == null || listProcessStep.size() == 0 ){
              ibp.MensagemIntegracao__c = 'Não existe aprovação para esta Solicitação.';
              update ibp;
                return;
            }
            //Recupera o ultimo registro de aprovação
            app = listProcessStep[0];
            
            //Recupera os username dos usuarios
            //emitente = Utils.getUserNameSplit( ibp.CreatedBy.Username );
            //solicitante = Utils.getUserNameSplit( ibp.Owner.Username );
            //aprovador = Utils.getUserNameSplit( app.CreatedBy.Username );
            
            //Verifica qual Action é do IBP
            if( ibp.Numero_da_RV_criada__c == null ) lAction = 'I';
            else if( ibp.Numero_da_RV_criada__c != null && ibp.Status_da_Verba__c == 'Encerrada') lAction = 'E';
            else if( ibp.Numero_da_RV_criada__c != null && app.StepStatus == 'Approved') lAction = 'UA';
            else lAction = 'UR';
            
            SYSTEM.DEBUG('CARLOS=lAction= '+lAction);
            //Recupera aprovações
            listRateio = RateioContratoDAO.getInstance().getListRateioByContractId( ibp.LAT_Contract__c );
            
            if( ibp.Verba_Adicional_VAD__r.Numero_da_VAD__c != null ){
                //Atribui o numero da Verba adicional
                numeroVAD = Long.valueOf( String.valueOf( ibp.Verba_Adicional_VAD__r.Numero_da_VAD__c ) );
            }
            
            //Inicializa objeto do webservice
            RVManager.SDTRVS lStr = new RVManager.SDTRVS();
            //Inicializa objeto filho de Dinheiro
            lStr.PGTDIN = new RVManager.PGTDIN_element();
            lStr.PGTDIN.PGTDINITM = new List< RVManager.SDTRVS_PGTDINITM >();
            //Inicializa objeto filho de Produto
            lStr.PGTPRD = new RVManager.PGTPRD_element();
            lStr.PGTPRD.PGTPRDITM = new List< RVManager.SDTRVS_PGTPRDITM >();
            
            if( ibp != null ){
              if( ibp.RecordTypeId == idRecTypeDinheiro ){
                  //Item de Cash Payment
                  RVManager.SDTRVS_PGTDINITM lItemDin = new RVManager.SDTRVS_PGTDINITM();
                  lItemDin.PgpPgtVal = ibp.Valor_R__c;
                  lItemDin.PgpPgtDat = ibp.Data_de_Previsao_do_Pagamento__c;
                  lStr.PGTDIN.PGTDINITM.add( lItemDin );
              }
                if( ibp.RecordTypeId == idRecTypeProduto ){
                  //Item de Product Payment
                  RVManager.SDTRVS_PGTPRDITM lItemProd = new RVManager.SDTRVS_PGTPRDITM();
                  lItemProd.KrqPgtDat   = ibp.Data_de_Previsao_do_Pagamento__c;
                  lItemProd.KrqQtdCai   = ibp.Volume_Cx__c;
                  lItemProd.KrqSkuCod   = Integer.valueOf( ibp.Produto_Bonificado__r.SKU__c );
                    lItemProd.KrqVal      = ibp.Valor_Percebido__c;
                }
            }
            
            //Inicializa objeto filho de Rateio do Contrato
            lStr.SHC = new RVManager.SHC_element();
            lStr.SHC.SHCITM = new List< RVManager.SDTRVS_SHCITM >();
            if( listRateio != null && listRateio.size() > 0 ){
                for( Rateio_do_Contrato__c r : listRateio ){
                    RVManager.SDTRVS_SHCITM lItemRateio = new RVManager.SDTRVS_SHCITM();
                    lItemRateio.SrqPer = r.Perc_de_Rateio__c;
                    /*lItemRateio.SrqShcCod = r.Produto__r.Scheduler_C__c;*/
                    lstr.SHC.SHCITM.add( lItemRateio );
                }
            }
            
            //Inicializa objetos do webservice
            RVManager.WBSRVSSoapPort lService = new RVManager.WBSRVSSoapPort();
            RVManager.WBSRVS_ExecuteResponse_element lResponse;
            
            //Verifica se a chamada é de teste
            if( !Test.isRunningTest() ){
                lResponse = lService.Execute( lAction, 
                                              aIdIBP, 
                                              COD_PAIS, 
                                              COD_EMPRESA, 
                                              Date.valueOf( ibp.CreatedDate ),//system.today()
                                              ibp.Data_de_Encerramento__c, 
                                              tipoVerba, //'BON'
                                              solicitante, 
                                              emitente, 
                                              numeroVAD, 
                                              Integer.valueOf( ibp.LAT_contract__r.Account__r.Client_code_AN8__c ), 
                                              tipoRegistro, 
                                              finalidade, 
                                              ibp.Objetivo__c, 
                                              Integer.valueOf( ibp.Ano_fiscal_calculado__c ), 
                                              Date.valueOf( app.CreatedDate ), 
                                              aprovador, 
                                              app.Comments, 
                                              'H',
                                              lStr );
            }else{
                lResponse = calloutMock();
            }
            if( lResponse.Codret != '0' ){
                ibp.Status_da_Verba__c = '';
                ibp.MensagemIntegracao__c = lResponse.Errordesc;
            }else{
              ibp.Status_da_Integracao__c = 'Enviado para SCV/ME';
                ibp.MensagemIntegracao__c = 'OK';
            }
            //Atualiza Investimento, bonificação e Pagamento
            update ibp;
        }
        //MIGRATED 18/11/2016
        else {
            if( aIdIBP == null || aIdIBP.trim().equals('') ) return;
            
            //Declaração de variaveis
            Long numeroVAD;
            String lAction;
            String tipoRegistro = '';
            Id idRecTypeDinheiro;
            Id idRecTypeProduto;
            Pagamento__c pagamento;
            Investimento_Bonificacao_e_Pagamento__c ibp;
            ProcessInstanceStep app = null;
            List< Rateio_do_Contrato__c > listRateio = new List< Rateio_do_Contrato__c >();
            List< ProcessInstanceStep > listProcessStep = new List< ProcessInstanceStep >();
            Map< String, String > mapTipoVerba = new Map< String, String >();
            String tipoVerba;
            String finalidade;
            String emitente, solicitante, aprovador;
            
            //Recupera um registro de IBP
            ibp = InvestimentoBonificaoPagamentoDAO.getInstance().getIBPById( aIdIBP );
            
            //Verifica se houve retorno de algum registro de IBP
            if( ibp == null ) return;
            
            //Atribui os usuarios Globais de acordo com o sistema
            if( ibp.Sistema__c == 'SCV' ){
              emitente       = 'SCVCRMBR';
              solicitante    = 'SCVCRMBR';
              aprovador      = 'SCVCRMBR';
            }else if( ibp.Sistema__c == 'ME' ){
              emitente       = 'MECRMBR';
              solicitante    = 'MECRMBR';
              aprovador      = 'MECRMBR';
            }
            
            //Recupera aprovação de ibp
            listProcessStep           = [Select Id, CreatedDate, CreatedBy.UserName, Comments, StepStatus
                                          from ProcessInstanceStep 
                                          Where ProcessInstance.TargetObjectId =: aIdPagamento
                                          order by CreatedDate Desc];
            
            //Recupera tipos de registro de Investimento_Bonificacao_e_Pagamento__c
            idRecTypeDinheiro = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro');
            idRecTypeProduto = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos');
            
            try{
              pagamento = PagamentoDAO.getInstance().getPagamentoById( aIdPagamento );
            }catch(QueryException e){
              System.debug(e.getMessage());
            }
            
            //Monta um map com todos os tipos de verba
            mapTipoVerba = setListTipoVerba();
            //Recupera o tipo de verba do contrato
            tipoVerba = mapTipoVerba.get( ibp.LAT_Contract__r.Tipo_de_verba__c );
            
            //Recupera a finalidade
            finalidade = Utils.getCodeFromUDC( ibp.Finalidade_SCV__c );
            
            
            //Preenche a variavel de acordo com o tipo de registro
            if( ibp.RecordTypeId == idRecTypeDinheiro ) tipoRegistro = 'D';
            else if( ibp.RecordTypeId == idRecTypeProduto ) tipoRegistro = 'P';
            
            //VErifica se foram retornadas aprovações.        
            if( listProcessStep == null || listProcessStep.size() == 0 ){
              ibp.MensagemIntegracao__c = 'Não existe aprovação para esta Solicitação.';
              update ibp;
                return;
            }
            //Recupera o ultimo registro de aprovação
            app = listProcessStep[0];
            
            //Recupera os username dos usuarios
            //emitente = Utils.getUserNameSplit( ibp.CreatedBy.Username );
            //solicitante = Utils.getUserNameSplit( ibp.Owner.Username );
            //aprovador = Utils.getUserNameSplit( app.CreatedBy.Username );
            
            //Verifica qual Action é do IBP
            if( ibp.Numero_da_RV_criada__c == null ) lAction = 'I';
            else if( ibp.Numero_da_RV_criada__c != null && ibp.Status_da_Verba__c == 'Encerrada') lAction = 'E';
            else if( ibp.Numero_da_RV_criada__c != null && app.StepStatus == 'Approved') lAction = 'UA';
            else lAction = 'UR';
            
            SYSTEM.DEBUG('CARLOS=lAction= '+lAction);
            //Recupera aprovações
            listRateio = RateioContratoDAO.getInstance().getListRateioByContractId( ibp.LAT_Contract__c );
            
            if( ibp.Verba_Adicional_VAD__r.Numero_da_VAD__c != null ){
                //Atribui o numero da Verba adicional
                numeroVAD = Long.valueOf( String.valueOf( ibp.Verba_Adicional_VAD__r.Numero_da_VAD__c ) );
            }
            
            //Inicializa objeto do webservice
            RVManager.SDTRVS lStr = new RVManager.SDTRVS();
            //Inicializa objeto filho de Dinheiro
            lStr.PGTDIN = new RVManager.PGTDIN_element();
            lStr.PGTDIN.PGTDINITM = new List< RVManager.SDTRVS_PGTDINITM >();
            //Inicializa objeto filho de Produto
            lStr.PGTPRD = new RVManager.PGTPRD_element();
            lStr.PGTPRD.PGTPRDITM = new List< RVManager.SDTRVS_PGTPRDITM >();
            
            if( ibp != null ){
              if( ibp.RecordTypeId == idRecTypeDinheiro ){
                  //Item de Cash Payment
                  RVManager.SDTRVS_PGTDINITM lItemDin = new RVManager.SDTRVS_PGTDINITM();
                  lItemDin.PgpPgtVal = ibp.Valor_R__c;
                  lItemDin.PgpPgtDat = ibp.Data_de_Previsao_do_Pagamento__c;
                  lStr.PGTDIN.PGTDINITM.add( lItemDin );
              }
                if( ibp.RecordTypeId == idRecTypeProduto ){
                  //Item de Product Payment
                  RVManager.SDTRVS_PGTPRDITM lItemProd = new RVManager.SDTRVS_PGTPRDITM();
                  lItemProd.KrqPgtDat   = ibp.Data_de_Previsao_do_Pagamento__c;
                  lItemProd.KrqQtdCai   = ibp.Volume_Cx__c;
                  lItemProd.KrqSkuCod   = Integer.valueOf( ibp.LAT_Product__r.LAT_Sku__c );
                    lItemProd.KrqVal      = ibp.Valor_Percebido__c;
                }
            }
            
            //Inicializa objeto filho de Rateio do Contrato
            lStr.SHC = new RVManager.SHC_element();
            lStr.SHC.SHCITM = new List< RVManager.SDTRVS_SHCITM >();
            if( listRateio != null && listRateio.size() > 0 ){
                for( Rateio_do_Contrato__c r : listRateio ){
                    RVManager.SDTRVS_SHCITM lItemRateio = new RVManager.SDTRVS_SHCITM();
                    lItemRateio.SrqPer = r.Perc_de_Rateio__c;
                    /*lItemRateio.SrqShcCod = r.Produto__r.Scheduler_C__c;*/
                    lstr.SHC.SHCITM.add( lItemRateio );
                }
            }
            
            //Inicializa objetos do webservice
            RVManager.WBSRVSSoapPort lService = new RVManager.WBSRVSSoapPort();
            RVManager.WBSRVS_ExecuteResponse_element lResponse;
            
            //Verifica se a chamada é de teste
            if( !Test.isRunningTest() ){
                lResponse = lService.Execute( lAction, 
                                              aIdIBP, 
                                              COD_PAIS, 
                                              COD_EMPRESA, 
                                              Date.valueOf( ibp.CreatedDate ),//system.today()
                                              ibp.Data_de_Encerramento__c, 
                                              tipoVerba, //'BON'
                                              solicitante, 
                                              emitente, 
                                              numeroVAD, 
                                              Integer.valueOf( ibp.LAT_contract__r.Account__r.Client_code_AN8__c ), 
                                              tipoRegistro, 
                                              finalidade, 
                                              ibp.Objetivo__c, 
                                              Integer.valueOf( ibp.Ano_fiscal_calculado__c ), 
                                              Date.valueOf( app.CreatedDate ), 
                                              aprovador, 
                                              app.Comments, 
                                              'H',
                                              lStr );
            }else{
                lResponse = calloutMock();
            }
            if( lResponse.Codret != '0' ){
                ibp.Status_da_Verba__c = '';
                ibp.MensagemIntegracao__c = lResponse.Errordesc;
            }else{
              ibp.Status_da_Integracao__c = 'Enviado para SCV/ME';
                ibp.MensagemIntegracao__c = 'OK';
            }
            //Atualiza Investimento, bonificação e Pagamento
            update ibp;          
        }
    }
    
    //Monta o map de tipo de verba
    private static Map< String, String > setListTipoVerba(){
        Map< String, String > mapS = new Map< String, String >();
        mapS.put('Allowance', 'ALL');
        mapS.put('Bonificação' , 'BON');
        mapS.put('KA Contratos', 'CTR');
        mapS.put('Off Trade - A&P', '');
        mapS.put('Off Trade - Direto', '');
        mapS.put('Off Trade - Eventos', '');
        mapS.put('Off Trade - Indireto', '');
        mapS.put('Off Trade - KA', '');
        mapS.put('Off Trade - Tático','');
        mapS.put('On Trade - Ativação & Materiais POS','');
        mapS.put('On Trade - Contratos','');
        mapS.put('On Trade - Eventos Nacionais','');
        mapS.put('KA - Verba preço promocionado', 'KAM');
        mapS.put('On trade - Verba venda direta','');
        return mapS;
    }
    
    //Método de teste do retorno do webservice
    private static RVManager.WBSRVS_ExecuteResponse_element calloutMock(){
        RVManager.WBSRVS_ExecuteResponse_element lResponse = new RVManager.WBSRVS_ExecuteResponse_element();
        lResponse.Codret = '0';
        lResponse.Errordesc = 'ERRO';
        lResponse.Nrorqvscv = 123;
        lResponse.Rqvantval = 0;
        lResponse.Rqvvexval = 0;
        return lResponse;
    }

}