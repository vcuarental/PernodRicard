/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Interface de resposável por integrar Pagamentos com a camada SOA
* NAME: PaymentManagerHandler.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 18/09/2012
*
* MAINTENANCE
* AUTHOR:                                           DATE: 
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/

global class PaymentManagerInterface {
    
    private static final Integer COD_EMPRESA = 81;
    private static final Integer COD_PAIS = 1;
       
    @future(callOut=true)

    Webservice static void PaymentManagerInvoke( String idPayment ){
        if(!Utils.wasMigrationDone('1')) {    
            //Verifica se foi passado um id para o método, caso contrário retorna interrompe o processo
            if(idPayment == null || idPayment.trim().equals('')) return;
            
            //Delcaração de variáveis
            Pagamento__c pag;
            ProcessInstanceStep approval;
            List< ProcessInstanceStep > listProcessStep = new List< ProcessInstanceStep >();
            List< Investimento_Bonificacao_e_Pagamento__c > listIBP = new List< Investimento_Bonificacao_e_Pagamento__c >();
            List< Pagamento_da_Verba__c > listPagVerba = new List< Pagamento_da_Verba__c >();
            List< Agrupamento_Fiscal_Year__c > listAgrupamentos = new List< Agrupamento_Fiscal_Year__c >();
            List< Pagamento_da_Verba__c > listPagVerbaPorIBP = new List< Pagamento_da_Verba__c >();
            List< String > listIdsIBP = new List< String>();
            List< String > listIdsContract = new List< String >();
            List< String > listAnosFiscais = new List< String >();
            Map< String, Investimento_Bonificacao_e_Pagamento__c > mapIBP = new Map< String, Investimento_Bonificacao_e_Pagamento__c >();
            Map< String, List< Investimento_Bonificacao_e_Pagamento__c >> mapListIBP = new Map< String , List<Investimento_Bonificacao_e_Pagamento__c>>();
            Map< String, List< Pagamento_da_Verba__c > > mapPagamentoVerba = new Map< String, List< Pagamento_da_Verba__c > >();
            Id idRecTypeDinheiro;
            Id idRecTypeProduto;
            String localidadeCliente;
            String formaPagamento, emitente, solicitante, aprovador, recebedor;
            
            //Recupera tipos de registro de Investimento_Bonificacao_e_Pagamento__c
            idRecTypeDinheiro = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro');
            idRecTypeProduto  = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos');
            
            //Recupera o pagamento
            pag = PagamentoDAO.getInstance().getPagamentoById( idPayment );
            
            if( pag == null ) return;
            
            //Atribui os usuarios Globais de acordo com o sistema
            if( pag.Sistema__c == 'SCV' ){
                emitente       = 'SCVCRMBR';
                solicitante    = 'SCVCRMBR';
                aprovador      = 'SCVCRMBR';
            }else if( pag.Sistema__c == 'ME' ){
                emitente       = 'MECRMBR';
                solicitante    = 'MECRMBR';
                aprovador      = 'MECRMBR';
            }
            
            localidadeCliente = Utils.getCodeFromUDC( pag.Cliente__r.Business_Unit__c );
            
            //Recupera a ultima aprovação do pagamento
            listProcessStep           = [Select Id, CreatedDate, CreatedBy.Username, Comments, StepStatus
                                          from ProcessInstanceStep 
                                          Where ProcessInstance.TargetObjectId =: idPayment
                                          order by CreatedDate Desc];
            if ( listProcessStep.size() == 0 ) return;
            //Recupera aprovação 
            approval = listProcessStep[0];
            
            //Recupera os username dos usuarios
            //emitente = Utils.getUserNameSplit( pag.CreatedBy.Username );
            //solicitante = Utils.getUserNameSplit( pag.Solicitante__r.Username );
            //kaprovador = Utils.getUserNameSplit( approval.CreatedBy.Username );
            
            //Recupera a forma de pagamento
            if( pag.Forma_de_Pagamento__c == 'Deposito em Conta' ) formaPagamento = 'DC';
            else if( pag.Forma_de_Pagamento__c == 'Nota de Crédito' ) formaPagamento = 'NC';
            else formaPagamento = null;
            
            //Recupera o Pagamento de Verba
            listPagVerba = PagamentoVerbaDAO.getInstance().getListPagVerbaByIdPgto( pag.Id );
            if( listPagVerba != null && listPagVerba.size() > 0 ){
               for( Pagamento_da_Verba__c p : listPagVerba){
                   listIdsIBP.add( p.Investimento_Bonifica_o_e_Pagamento__c );
                   List< Pagamento_da_Verba__c > lPag = new List< Pagamento_da_Verba__c >();
                   if( mapPagamentoVerba.containsKey( p.Investimento_Bonifica_o_e_Pagamento__c ) ){
                       lPag = mapPagamentoVerba.get( p.Investimento_Bonifica_o_e_Pagamento__c );
                   }
                   lPag.add( p );
                   mapPagamentoVerba.put( p.Investimento_Bonifica_o_e_Pagamento__c,lPag );
               }
               
               //Recupera os registros de Investimento, bonificação e Pagamento
               listIBP = InvestimentoBonificaoPagamentoDAO.getInstance().getListInvestBonifPagByIdsIBP( listIdsIBP );
               
               if( listIBP != null && listIBP.size() > 0 ){
                   List< Investimento_Bonificacao_e_Pagamento__c > lList = null;
                   for( Investimento_Bonificacao_e_Pagamento__c ibp: listIBP ){
                       listIdsContract.add( ibp.LAT_Contract__c );
                       listAnosFiscais.add( ibp.Ano_Fiscal__c );
                       //mapIBP.put( ibp.Ano_Fiscal__c+ibp.Contrato__c, ibp );
                       
                       lList = mapListIBP.get( ibp.Ano_Fiscal__c+ibp.LAT_Contract__c );
                        if ( lList == null )
                        {
                            lList = new List< Investimento_Bonificacao_e_Pagamento__c >();
                            mapListIBP.put( ibp.Ano_Fiscal__c+ibp.LAT_Contract__c , lList );
                        }
                        lList.add( ibp );
                   }
                   //Recupera os registros de Agrupamento Fiscal Year
                   listAgrupamentos = AgrupamentoFiscalYearDAO.getInstance().getListAgrupByIdContractFiscalYear( listIdsContract, listAnosFiscais );
                   
               } 
            }
            
            PaymentManager.SDTPGT lStr = new PaymentManager.SDTPGT();
            lStr.RVS = new PaymentManager.RVS_element();
            lStr.RVS.RVSItem = new List< PaymentManager.SDTPGT_RVSItem >();
            
            if( listAgrupamentos != null && listAgrupamentos.size() > 0 ){
                for( Agrupamento_Fiscal_Year__c ag : listAgrupamentos ){
                    
                    List< Investimento_Bonificacao_e_Pagamento__c > lListIBP = mapListIBP.get( ag.Ano_Fiscal__c+ag.LAT_Contract__c );
                    if( lListIBP == null || lListIBP.size() == 0 ) continue;
                    
                    for( Investimento_Bonificacao_e_Pagamento__c i : lListIBP ){
                        String lFinalidade = Utils.getCodeFromUDC( i.Finalidade_SCV__c );
                        PaymentManager.SDTPGT_RVSItem lRV = new PaymentManager.SDTPGT_RVSItem();
                        lRV.PrqFinDes = lFinalidade;
                        
                        if( pag.Sistema__c == 'SCV' ){
                            lRV.RqvNroRqv = ( i.Numero_da_RV_criada__c != null ) ? Long.valueOf( i.Numero_da_RV_criada__c ) : null;
                        }else{
                            lRV.RqvNroRqv = ( ag.Numero_da_D_A__c != null ) ? Long.valueOf( String.valueOf( ag.Numero_da_D_A__c ) ) : null;
                        }
                        
                        lRV.TdoCod    = ag.Tipo_de_Workflow__c;
                        
                        //Objeto Dinheiro
                        lRV.PGTDIN = new PaymentManager.PGTDIN_element();
                        lRV.PGTDIN.PGTDINItem = new List< PaymentManager.SDTPGT_RVSItem_PGTDINItem >();
                        PaymentManager.SDTPGT_RVSItem_PGTDINItem din = null;
                        
                        //Objeto produto
                        lRV.PGTPRD = new PaymentManager.PGTPRD_element();
                        lRV.PGTPRD.PGTPRDItem = new List< PaymentManager.SDTPGT_RVSItem_PGTPRDItem >();
                        PaymentManager.SDTPGT_RVSItem_PGTPRDItem prod = null;
                        
                        List< Pagamento_da_Verba__c > lPV = mapPagamentoVerba.get( i.Id );
                        
                        for(Pagamento_da_Verba__c pv : lPV ){
                          if( i.RecordTypeId == idRecTypeDinheiro ){
                              din = new PaymentManager.SDTPGT_RVSItem_PGTDINItem();
                              din.DspDatPgt = i.Data_de_Previsao_do_Pagamento__c;
                              din.DspVal = pv.valor_a_pagar__c;
                              
                          }else if( i.RecordTypeId == idRecTypeProduto ){
                              prod = new PaymentManager.SDTPGT_RVSItem_PGTPRDItem();
                              prod.KspSkuCod = Integer.valueOf( pv.pagar_com_produto__r.SKU__c );
                              prod.KspQtdCai = pv.volume_a_pagar__c;
                              prod.KspDatPgt = i.Data_de_Previsao_do_Pagamento__c;
                              prod.UndCod = 'CA';
                              prod.KspVal = i.Valor_Percebido__c;
                          }
                          if( din != null ) lRV.PGTDIN.PGTDINItem.add( din );
                          if( prod != null ) lRV.PGTPRD.PGTPRDItem.add( prod );
                        }
                      
                        lStr.RVS.RVSItem.add( lRV );
                    }
                }
            }
            
            
            PaymentManager.WBSPGTSoapPort lService = new PaymentManager.WBSPGTSoapPort();
            PaymentManager.WBSPGT_ExecuteResponse_element lResponse;
            
            if ( !Test.isRunningTest() ){
                try{
                    lResponse = lService.Execute(   String.valueOf( pag.Id ), //Idcrm
                                                    COD_PAIS,//Paicod
                                                    COD_EMPRESA, //Empcod
                                                    '03',//localidadeCliente, //Mcu
                                                    solicitante, //Spgsolusr
                                                    emitente, //Spgemiusr
                                                    pag.Observacoes_Complementares__c,//Spgobs
                                                    formaPagamento,//Spgsoltip
                                                    'P', //Spgclirec
                                                    emitente, //User_x Usuario da DA 
                                                    system.today(),//pag.Data_do_Pagamento__c Krqpgtdat
                                                    Integer.valueOf( pag.Cliente__r.Client_code_AN8__c ), //Codcliente
                                                    Date.valueOf( approval.CreatedDate ), //Cavapvrpv
                                                    aprovador,// Cavusrapv
                                                    approval.Comments, //Cavmotrpv
                                                    'H', //Cavhieobr
                                                    pag.Sistema__c,//Codsistema
                                                    lStr);//Sdtpgt
                    if( lResponse.Codret != '0' ){
                        pag.Status__c = 'Erro de Integração';
                        pag.MensagemIntegracao__c = lResponse.Errordesc;
                    }else{
                        pag.Status__c = 'Enviando para SCV/ME';
                        pag.MensagemIntegracao__c = '';
                        //pag.Numero_do_Pagamento_criado__c = lResponse.Nrospgscv;
                    }
                }catch(Exception e){
                    System.debug(e.getMessage());
                    pag.Status__c = 'Erro de Integração';
                    pag.MensagemIntegracao__c = e.getMessage();
                }
                
            }
            
            //Atualiza pagamento
            update pag;
        }
        //MIGRATED 18/11/2016
        else {
            //Verifica se foi passado um id para o método, caso contrário retorna interrompe o processo
            if(idPayment == null || idPayment.trim().equals('')) return;
            
            //Delcaração de variáveis
            Pagamento__c pag;
            ProcessInstanceStep approval;
            List< ProcessInstanceStep > listProcessStep = new List< ProcessInstanceStep >();
            List< Investimento_Bonificacao_e_Pagamento__c > listIBP = new List< Investimento_Bonificacao_e_Pagamento__c >();
            List< Pagamento_da_Verba__c > listPagVerba = new List< Pagamento_da_Verba__c >();
            List< Agrupamento_Fiscal_Year__c > listAgrupamentos = new List< Agrupamento_Fiscal_Year__c >();
            List< Pagamento_da_Verba__c > listPagVerbaPorIBP = new List< Pagamento_da_Verba__c >();
            List< String > listIdsIBP = new List< String>();
            List< String > listIdsContract = new List< String >();
            List< String > listAnosFiscais = new List< String >();
            Map< String, Investimento_Bonificacao_e_Pagamento__c > mapIBP = new Map< String, Investimento_Bonificacao_e_Pagamento__c >();
            Map< String, List< Investimento_Bonificacao_e_Pagamento__c >> mapListIBP = new Map< String , List<Investimento_Bonificacao_e_Pagamento__c>>();
            Map< String, List< Pagamento_da_Verba__c > > mapPagamentoVerba = new Map< String, List< Pagamento_da_Verba__c > >();
            Id idRecTypeDinheiro;
            Id idRecTypeProduto;
            String localidadeCliente;
            String formaPagamento, emitente, solicitante, aprovador, recebedor;
            
            //Recupera tipos de registro de Investimento_Bonificacao_e_Pagamento__c
            idRecTypeDinheiro = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Dinheiro');
            idRecTypeProduto  = RecordTypeForTest.getRecType('Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos');
            
            //Recupera o pagamento
            pag = PagamentoDAO.getInstance().getPagamentoById( idPayment );
            
            if( pag == null ) return;
            
            //Atribui os usuarios Globais de acordo com o sistema
            if( pag.Sistema__c == 'SCV' ){
                emitente       = 'SCVCRMBR';
                solicitante    = 'SCVCRMBR';
                aprovador      = 'SCVCRMBR';
            }else if( pag.Sistema__c == 'ME' ){
                emitente       = 'MECRMBR';
                solicitante    = 'MECRMBR';
                aprovador      = 'MECRMBR';
            }
            
            localidadeCliente = Utils.getCodeFromUDC( pag.Cliente__r.Business_Unit__c );
            
            //Recupera a ultima aprovação do pagamento
            listProcessStep           = [Select Id, CreatedDate, CreatedBy.Username, Comments, StepStatus
                                          from ProcessInstanceStep 
                                          Where ProcessInstance.TargetObjectId =: idPayment
                                          order by CreatedDate Desc];
            if ( listProcessStep.size() == 0 ) return;
            //Recupera aprovação 
            approval = listProcessStep[0];
            
            //Recupera os username dos usuarios
            //emitente = Utils.getUserNameSplit( pag.CreatedBy.Username );
            //solicitante = Utils.getUserNameSplit( pag.Solicitante__r.Username );
            //kaprovador = Utils.getUserNameSplit( approval.CreatedBy.Username );
            
            //Recupera a forma de pagamento
            if( pag.Forma_de_Pagamento__c == 'Deposito em Conta' ) formaPagamento = 'DC';
            else if( pag.Forma_de_Pagamento__c == 'Nota de Crédito' ) formaPagamento = 'NC';
            else formaPagamento = null;
            
            //Recupera o Pagamento de Verba
            listPagVerba = PagamentoVerbaDAO.getInstance().getListPagVerbaByIdPgto( pag.Id );
            if( listPagVerba != null && listPagVerba.size() > 0 ){
               for( Pagamento_da_Verba__c p : listPagVerba){
                   listIdsIBP.add( p.Investimento_Bonifica_o_e_Pagamento__c );
                   List< Pagamento_da_Verba__c > lPag = new List< Pagamento_da_Verba__c >();
                   if( mapPagamentoVerba.containsKey( p.Investimento_Bonifica_o_e_Pagamento__c ) ){
                       lPag = mapPagamentoVerba.get( p.Investimento_Bonifica_o_e_Pagamento__c );
                   }
                   lPag.add( p );
                   mapPagamentoVerba.put( p.Investimento_Bonifica_o_e_Pagamento__c,lPag );
               }
               
               //Recupera os registros de Investimento, bonificação e Pagamento
               listIBP = InvestimentoBonificaoPagamentoDAO.getInstance().getListInvestBonifPagByIdsIBP( listIdsIBP );
               
               if( listIBP != null && listIBP.size() > 0 ){
                   List< Investimento_Bonificacao_e_Pagamento__c > lList = null;
                   for( Investimento_Bonificacao_e_Pagamento__c ibp: listIBP ){
                       listIdsContract.add( ibp.LAT_Contract__c );
                       listAnosFiscais.add( ibp.Ano_Fiscal__c );
                       //mapIBP.put( ibp.Ano_Fiscal__c+ibp.Contrato__c, ibp );
                       
                       lList = mapListIBP.get( ibp.Ano_Fiscal__c+ibp.LAT_Contract__c );
                        if ( lList == null )
                        {
                            lList = new List< Investimento_Bonificacao_e_Pagamento__c >();
                            mapListIBP.put( ibp.Ano_Fiscal__c+ibp.LAT_Contract__c , lList );
                        }
                        lList.add( ibp );
                   }
                   //Recupera os registros de Agrupamento Fiscal Year
                   listAgrupamentos = AgrupamentoFiscalYearDAO.getInstance().getListAgrupByIdContractFiscalYear( listIdsContract, listAnosFiscais );
                   
               } 
            }
            
            PaymentManager.SDTPGT lStr = new PaymentManager.SDTPGT();
            lStr.RVS = new PaymentManager.RVS_element();
            lStr.RVS.RVSItem = new List< PaymentManager.SDTPGT_RVSItem >();
            
            if( listAgrupamentos != null && listAgrupamentos.size() > 0 ){
                for( Agrupamento_Fiscal_Year__c ag : listAgrupamentos ){
                    
                    List< Investimento_Bonificacao_e_Pagamento__c > lListIBP = mapListIBP.get( ag.Ano_Fiscal__c+ag.LAT_Contract__c );
                    if( lListIBP == null || lListIBP.size() == 0 ) continue;
                    
                    for( Investimento_Bonificacao_e_Pagamento__c i : lListIBP ){
                        String lFinalidade = Utils.getCodeFromUDC( i.Finalidade_SCV__c );
                        PaymentManager.SDTPGT_RVSItem lRV = new PaymentManager.SDTPGT_RVSItem();
                        lRV.PrqFinDes = lFinalidade;
                        
                        if( pag.Sistema__c == 'SCV' ){
                            lRV.RqvNroRqv = ( i.Numero_da_RV_criada__c != null ) ? Long.valueOf( i.Numero_da_RV_criada__c ) : null;
                        }else{
                            lRV.RqvNroRqv = ( ag.Numero_da_D_A__c != null ) ? Long.valueOf( String.valueOf( ag.Numero_da_D_A__c ) ) : null;
                        }
                        
                        lRV.TdoCod    = ag.Tipo_de_Workflow__c;
                        
                        //Objeto Dinheiro
                        lRV.PGTDIN = new PaymentManager.PGTDIN_element();
                        lRV.PGTDIN.PGTDINItem = new List< PaymentManager.SDTPGT_RVSItem_PGTDINItem >();
                        PaymentManager.SDTPGT_RVSItem_PGTDINItem din = null;
                        
                        //Objeto produto
                        lRV.PGTPRD = new PaymentManager.PGTPRD_element();
                        lRV.PGTPRD.PGTPRDItem = new List< PaymentManager.SDTPGT_RVSItem_PGTPRDItem >();
                        PaymentManager.SDTPGT_RVSItem_PGTPRDItem prod = null;
                        
                        List< Pagamento_da_Verba__c > lPV = mapPagamentoVerba.get( i.Id );
                        
                        for(Pagamento_da_Verba__c pv : lPV ){
                          if( i.RecordTypeId == idRecTypeDinheiro ){
                              din = new PaymentManager.SDTPGT_RVSItem_PGTDINItem();
                              din.DspDatPgt = i.Data_de_Previsao_do_Pagamento__c;
                              din.DspVal = pv.valor_a_pagar__c;
                              
                          }else if( i.RecordTypeId == idRecTypeProduto ){
                              prod = new PaymentManager.SDTPGT_RVSItem_PGTPRDItem();
                              prod.KspSkuCod = Integer.valueOf( pv.LAT_Product__r.LAT_Sku__c );
                              prod.KspQtdCai = pv.volume_a_pagar__c;
                              prod.KspDatPgt = i.Data_de_Previsao_do_Pagamento__c;
                              prod.UndCod = 'CA';
                              prod.KspVal = i.Valor_Percebido__c;
                          }
                          if( din != null ) lRV.PGTDIN.PGTDINItem.add( din );
                          if( prod != null ) lRV.PGTPRD.PGTPRDItem.add( prod );
                        }
                      
                        lStr.RVS.RVSItem.add( lRV );
                    }
                }
            }
            
            
            PaymentManager.WBSPGTSoapPort lService = new PaymentManager.WBSPGTSoapPort();
            PaymentManager.WBSPGT_ExecuteResponse_element lResponse;
            
            if ( !Test.isRunningTest() ){
                try{
                    lResponse = lService.Execute(   String.valueOf( pag.Id ), //Idcrm
                                                    COD_PAIS,//Paicod
                                                    COD_EMPRESA, //Empcod
                                                    '03',//localidadeCliente, //Mcu
                                                    solicitante, //Spgsolusr
                                                    emitente, //Spgemiusr
                                                    pag.Observacoes_Complementares__c,//Spgobs
                                                    formaPagamento,//Spgsoltip
                                                    'P', //Spgclirec
                                                    emitente, //User_x Usuario da DA 
                                                    system.today(),//pag.Data_do_Pagamento__c Krqpgtdat
                                                    Integer.valueOf( pag.Cliente__r.Client_code_AN8__c ), //Codcliente
                                                    Date.valueOf( approval.CreatedDate ), //Cavapvrpv
                                                    aprovador,// Cavusrapv
                                                    approval.Comments, //Cavmotrpv
                                                    'H', //Cavhieobr
                                                    pag.Sistema__c,//Codsistema
                                                    lStr);//Sdtpgt
                    if( lResponse.Codret != '0' ){
                        pag.Status__c = 'Erro de Integração';
                        pag.MensagemIntegracao__c = lResponse.Errordesc;
                    }else{
                        pag.Status__c = 'Enviando para SCV/ME';
                        pag.MensagemIntegracao__c = '';
                        //pag.Numero_do_Pagamento_criado__c = lResponse.Nrospgscv;
                    }
                }catch(Exception e){
                    System.debug(e.getMessage());
                    pag.Status__c = 'Erro de Integração';
                    pag.MensagemIntegracao__c = e.getMessage();
                }
                
            }
            
            //Atualiza pagamento
            update pag;          
        }
    }
    
    private static PaymentManager.WBSPGT_ExecuteResponse_element calloutMock(){
        PaymentManager.WBSPGT_ExecuteResponse_element lResponse = new PaymentManager.WBSPGT_ExecuteResponse_element();
        lResponse.Codret = '0';
        lResponse.Errordesc = '';
        lResponse.Nrospgscv = 1;
        lResponse.Sdtpgt = null;
        return lResponse;
    }
}