/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Interface de resposável por integrar os objetos Contract, Tipo_de_Documento__c,
* Cl_usulas_do_Contrato__c, Investimento_Bonificacao_e_Pagamento__c e Approval com
* a camada SOA e atualizar dados no sistema legado (JDE).
* NAME: InvestimentoBonifPagamentoDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 01/08/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 27/09/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 08/10/2012
********************************************************************************/
global class ContractManagerInterface {
    
    private static final Integer COD_EMPRESA = 81;
    private static final Integer COD_PAIS = 1;
    
    @future(callOut=true)
    Webservice static void ContractManagerInvoke( String idContractSF){
        
        //Verifica se foi passado um id para o método, caso contrário retorna interrompe o processo
        if(idContractSF == null || idContractSF.trim().equals('')) return;
        
        //Declara, Instacia e Inicializa variáveis e listas.
        Map< String, Id > mapIdsRecordType = new Map< String, Id >();
        LAT_Contract__c contract = null;
        List< Tipo_de_Documento__c > listTipoDocumento = new List< Tipo_de_Documento__c >();
        List< Cl_usulas_do_Contrato__c > listClausulaContrato = new List< Cl_usulas_do_Contrato__c >();
        List< ProcessInstanceStep > listProcessStep = new List< ProcessInstanceStep >();
        List< Distribui_o_de_Valores__c > listDistribuicao = new List< Distribui_o_de_Valores__c >();
        Map< String , List< Distribui_o_de_Valores__c >> mapDistribuicao = new Map< String , List< Distribui_o_de_Valores__c >>();
        ProcessInstanceStep proc;
        Long aContractNumber;
        Integer aCodAN8 = null;
        String aOrg = null;
        String aBand = null;
        Date approvalCreatedDate;
        String approvalComment;
        String approvalCreatedBy;
        String approvalHierarquia;
        String tipoRegistro = '';
        String emitente, solicitante, aprovador;
        
        //Recupera campos de contrato e de conta com o Id passado ao método.
        contract = ContractDAO.getInstance().getContractById(idContractSF);
        
        //Verifica se a variável "contract" recuperou algum objeto.
        if(contract == null) return;
        
        //Recupera objetos filhos de Contrato
        listProcessStep           = [Select Id, CreatedDate, CreatedBy.UserName, Comments 
                                      from ProcessInstanceStep 
                                      Where ProcessInstance.TargetObjectId =: contract.Id
                                      AND StepStatus = 'Approved'
                                      order by CreatedDate Desc];
        listTipoDocumento         = TipoDocumentoDAO.getInstance().getListTipoDocumento(idContractSF);
        listClausulaContrato      = ClausulaContratoDAO.getInstance().getListClausulaContratoByIdContrato(idContractSF);
        
        if(listClausulaContrato != null && listClausulaContrato.size() > 0){
            List< String > lListIds = new List< String >();
            
            for(Cl_usulas_do_Contrato__c c:listClausulaContrato){
                lListIds.add(c.Id);
            }
            //Recupera objetos filhos de Contrato
            listDistribuicao = DistribuicaoValoresDAO.getInstance().getListDistribuicaoByIdsClausula(lListIds);
            
            if( listDistribuicao != null && listDistribuicao.size() > 0 ){
                List< Distribui_o_de_Valores__c > lList = null;
                for( Distribui_o_de_Valores__c dv: listDistribuicao ){
                  lList = mapDistribuicao.get( dv.Clausulas_do_Contrato__c );
                  if ( lList == null )
                  {
                    lList = new List< Distribui_o_de_Valores__c >();
                    mapDistribuicao.put( dv.Clausulas_do_Contrato__c, lList );
                  }
                  lList.add(dv);
                }
            }
        }
        
        //Inicializa um objeto de aprovação
        ProcessInstanceStep lProcess = null;
        //Recupera a ultima aprovação
        if(listProcessStep != null && listProcessStep.size()>0) lProcess = listProcessStep[0];
        
        if( contract.Contrato_original__r.ContractNumber__c != null )
           aContractNumber = Long.valueOf( contract.Contrato_original__r.ContractNumber__c );
        else if( contract.ContractNumber__c != null )
           aContractNumber = Long.valueOf( contract.ContractNumber__c );
        else
           aContractNumber = 0;
        
        if(contract.Contrato_por__c == 'AN8'){
          aCodAN8 = Integer.valueOf( contract.Account__r.Client_code_AN8__c );
        }else if(contract.Contrato_por__c == 'Bandeira'){
          aBand = Utils.getCodeFromUDC( contract.Account__r.Customer_Flag__c );
        }else if(contract.Contrato_por__c == 'Organização'){
            aOrg = Utils.getCodeFromUDC( contract.Account__r.Customer_Organization__c );
        }
        
        //Recupera os username dos usuarios
        emitente = Utils.getUserNameSplit( contract.CreatedBy.Username );
        solicitante = Utils.getUserNameSplit( contract.Owner.Username );
        if ( lProcess != null && lProcess.CreatedBy != null ) aprovador = Utils.getUserNameSplit( lProcess.CreatedBy.Username );
        
        //Campos de fluxo de aprovação
        if ( lProcess != null ) 
        { 
        	approvalCreatedDate = Date.valueOf( lProcess.CreatedDate );
          approvalComment     = lProcess.Comments;
        }
        approvalCreatedBy   = aprovador;//lProcess.CreatedBy.UserName;
        approvalHierarquia  = 'H';
        
        //*****************************************************************************************
        //************************* PREENCHE OS OBJETOS DO WEBSERVICE *****************************
        //*****************************************************************************************
        ContractManager.SDTCTR lStr = new ContractManager.SDTCTR();
            
        //Cria um objeto do w3eb service de tipo de documento
        lStr.Documento = new ContractManager.Documento_element();
        lStr.Documento.DocumentoItem = new List< ContractManager.SDTCTR_DocumentoItem >();
        if( listTipoDocumento != null && listTipoDocumento.size() > 0 ){
            for( Tipo_de_Documento__c tipo : listTipoDocumento ){
              ContractManager.SDTCTR_DocumentoItem lItem = new ContractManager.SDTCTR_DocumentoItem();
              lItem.DocTipDoc = Utils.getCodeFromUDC( tipo.Codigo_do_Documento__c );
              lStr.Documento.DocumentoItem.add( lItem );
            }
        }
            
        //Cria um objeto do w3eb service do tipo clausula de contrato
        lStr.Clausula = new ContractManager.Clausula_element();
        lStr.Clausula.ClausulaItem = new List< ContractManager.SDTCTR_ClausulaItem >();
        if( listClausulaContrato != null && listClausulaContrato.size() > 0 ){
            for( Cl_usulas_do_Contrato__c cla : listClausulaContrato ){
                ContractManager.SDTCTR_ClausulaItem lItem = new ContractManager.SDTCTR_ClausulaItem();
                //Campos de CLAUSULA
                lItem.TccTipCla = Utils.getCodeFromUDC( cla.C_digo__c );
                if( cla.Tipo_de_Calculo__c == 'Valor' ) lItem.VctTipCal = 'V';
                else if( cla.Tipo_de_Calculo__c == 'Percentual' ) lItem.VctTipCal = 'P';
                lItem.VctBasCal = Utils.getCodeFromUDC( cla.Codigo_Base_de_Calculo__c );
                lItem.VctPrvPer = cla.Percentual__c;
                lItem.VctPrvVal = cla.Valor__c;
                lItem.VctCtaDeb = Utils.getCodeFromUDC( cla.Conta_de_Debito__c );
                lItem.VctCtaCre = Utils.getCodeFromUDC( cla.Conta_de_Credito__c );
                //Cria lista de distribuição
                List< Distribui_o_de_Valores__c > lListDistribuicao;
                lItem.Valor = new ContractManager.Valor_element();
                lItem.Valor.Valor = new List< ContractManager.SDTCTR_ClausulaItem_Valor >();
                lListDistribuicao = mapDistribuicao.get( cla.Id );
                
                if( lListDistribuicao != null && lListDistribuicao.size() > 0 ){
                    for( Distribui_o_de_Valores__c dv : lListDistribuicao ){
                        ContractManager.SDTCTR_ClausulaItem_Valor dist = new ContractManager.SDTCTR_ClausulaItem_Valor();
                        dist.VmcFscAno = Integer.valueOf( dv.Ano_fiscal_formula__c );
                        dist.VmcValAno = Integer.valueOf( dv.Data_de_Referencia_para_Apuracao__c.year() );//Integer.valueOf( dv.Ano_de_Referencia_para_Apuracao__c );
                        dist.VmcValMes = Integer.valueOf( dv.Data_de_Referencia_para_Apuracao__c.month() );//Integer.valueOf( dv.Mes_de_Referencia_para_Apuracao__c );
                        dist.VmcVal    = Double.valueOf( dv.Valor_da_Parcela_R__c );
                        lItem.Valor.Valor.add( dist );
                    }
                }
                
                //Adiciona a clausula a lista
                lStr.Clausula.ClausulaItem.add( lItem );
            }
        }
        
        //Inicializa o webservice
        ContractManager.WBSCTRSoapPort con = new ContractManager.WBSCTRSoapPort();
        //Inicializa o objeto de retorno
        ContractManager.WBSCTR_ExecuteResponse_element retorno = new ContractManager.WBSCTR_ExecuteResponse_element();
        if ( !Test.isRunningTest() )
        {
          //Executa o método do websevice passando os parametros
          retorno = con.Execute( String.valueOf( contract.Id ), 
                                 String.valueOf( contract.Contrato_original__c ),
                                 COD_EMPRESA, 
                                 COD_PAIS, 
                                 aContractNumber, 
                                 'D', 
                                 contract.StartDate__c, 
                                 contract.ProvisionarAte__c,
                                 aCodAN8, 
                                 aBand, 
                                 aOrg, 
                                 'SCVCRMBR',//solicitante, 
                                 'SCVCRMBR',//emitente,
                                 'SCVCRMBR',//aprovador,
                                 contract.LastModifiedDate, 
                                 Date.valueOf( approvalCreatedDate ), 
                                 'SCVCRMBR',//approvalCreatedBy, 
                                 approvalComment, 
                                 approvalHierarquia, 
                                 lStr);
          
        }else{
          retorno = calloutMock();
        }
        
        if( retorno.Codret != '0'){
          contract.Status_da_INtegra_o__c = 'Erro no envio para o SCV';
            contract.MensagemIntegracao__c = retorno.Errordesc;
        }else if( contract.Status_da_INtegra_o__c != 'Enviando para o SCV'){
          contract.Status_da_INtegra_o__c = 'Enviando para o SCV';
          contract.MensagemIntegracao__c = '';
        }
        update contract;
        
    }
    
    private static ContractManager.WBSCTR_ExecuteResponse_element calloutMock(){
        ContractManager.WBSCTR_ExecuteResponse_element lResponse = new ContractManager.WBSCTR_ExecuteResponse_element();
        lResponse.Codret = '0';
        lResponse.Errordesc = '';
        return lResponse;
    }
}