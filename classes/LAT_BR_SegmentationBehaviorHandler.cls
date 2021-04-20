/**
 * Utility class for handle current Account rt mapped with the new types of accounts 
 *
 */
global without sharing class LAT_BR_SegmentationBehaviorHandler {

    // Approval Processes:

    public final static String EVENTOS_APPROVAL_PRCS = 'LAT_BR_ACC_AccountNewClientEventos';
    public final static String COMFATURAMENTE_APPROVAL_PRCS = 'LAT_BR_ACC_AccountConFaturamento';
    public final static String ONTRADE_APPROVAL_PRCS = 'LAT_BR_ACC_AccountNewClientONTrade';
    public final static String SEMFATURAMENTE_APPROVAL_PRCS = 'LAT_BR_ACC_AccountSemFaturamento';

    public static String CHANNEL_ON_TRADE = 'ON TRADE';
    public static String CHANNEL_ONLINE = 'ON LINE';
    public static String CHANNEL_DIST = 'DISTRIBUICAO';
    public static String CHANNEL_DIST2 = 'DISTRIBUIÇÃO';
    public static String CHANNEL_OFF_TRADE = 'OFF TRADE';
    public static String CHANNEL_EVENTOS = 'EVENTOS';



    webservice static String validateAccountData(Id accId) {
        Account acc = [SELECT Id, Name, Rating, Channel__c, Status__c, Type, LAT_InformationUnfilled__c, OwnerId, RecordTypeId, LAT_Account__r.Obtained_Approval__c, LAT_Account__r.Id, LAT_Account__c FROM Account WHERE ID =: accId LIMIT 1];
        List < LAT_BR_ClientChannelSegmentation2__c > draftSegm = [SELECT Id, Client_type__c, channel__c FROM LAT_BR_ClientChannelSegmentation2__c WHERE Status__c = 'Draft'
            AND Account__c =: acc.Id
        ];

        if (!String.isBlank(acc.LAT_InformationUnfilled__c)) {
            return '';
        } else if (draftSegm.size() == 1 && acc.Rating == 'Cliente Inativo') {
            if (draftSegm.size() > 0 && (draftSegm[0].Client_type__c == 'COM FATURAMENTO' || draftSegm[0].Client_type__c == 'COM PAGAMENTO' || draftSegm[0].Client_type__c == 'VENDA DIRETA')) {
                return 'Foi identificada uma nova Segmentação para este cliente, porém como o mesmo está Inativo, além da aprovação dos seus Superiores, o processo passará também pelas áreas de BackOffice. Deseja realmente enviar a aprovação?';
            } else {
                return 'Foi identificada uma nova Segmentação para este cliente. Deseja realmente enviar a aprovação?';
            }
        } else if (draftSegm.size() == 1) {
            return 'Foi identificada uma nova Segmentação para este cliente. Deseja realmente enviar a aprovação?';
            //} else if (){
            //  return '“Foi identificada uma nova Segmentação para este cliente, porém como o mesmo está Inativo, além da aprovação dos seus Superiores, o processo passará também pelas áreas de BackOffice. Deseja realmente enviar a aprovação?”';
        } else return '';



    }


    webservice static String sentToApproval(Id accId) {
        Account acc = [SELECT Id, rating, Name, Channel__c, Recordtype.Name, Status__c, Type, LAT_InformationUnfilled__c, OwnerId, RecordTypeId, LAT_Account__r.Obtained_Approval__c, LAT_Account__r.Id, LAT_Account__c FROM Account WHERE ID =: accId LIMIT 1];
        System.debug('acc++' + accId);
        System.debug('acc2++' + acc);
        return sentAccToApproval(acc);
    }


    /**
     * Identify wich approval process to trigger according to the logic in the rfc
     * 
     * 
     */
    global static String sentAccToApproval(Account acc) {

        AccountSegmentationData accData = new AccountSegmentationData(acc);

        /*
        Status Cliente = Novo Cadastro ou Não Aprovado
        Informações não preenchidas Cliente = null
        Disparar processo de aprovação de acordo as regras abaixo:
        OFF TRADE, DISTRIBUIÇÃO
                Completo: processo de aprovação atual para Off Trade
                Simples: processo de aprovação de Eventos
        ON TRADE, ON LINE, EVENTOS
        Completo: processo de aprovação atual para On Trade
        Simples: processo de aprovação de Eventos
        */




        String obtainedapprovalProcess = '';
        String result = '';

        List < LAT_BR_ClientChannelSegmentation2__c > draftSegm = [SELECT Id,
            Client_type__c,
            channel__c,
            Beneficio_Fiscal__c,
            Estrategia_comercial__c,
            FORMATO__c,
            Perfil__c,
            POLiTICA_DE_PRECO__c,
            PRIOR_DE_INVESTIMENTO__c,
            Sub_channel__c,
            Segment__c
            FROM LAT_BR_ClientChannelSegmentation2__c
            WHERE Status__c = 'Draft'
            AND Account__c =: acc.Id
        ];

        if (!String.isBlank(accData.acc.LAT_InformationUnfilled__c)) {
            result = '<b>Envio a aprovação não permitido</b></br>';    
            result += 'Favor completar os seguintes campos não preenchidos pois são necessários para enviar para aprovar um cliente do tipo <b>'+ acc.Recordtype.Name +'</b> :<br><br>';
            result += acc.LAT_InformationUnfilled__c;
            result += '<br>Preencha os campos e reenvie para aprovar o cliente.';
            

        } else if (draftSegm.size() == 0 && acc.Rating == 'Cliente Inativo') {
            result = 'Não foi identificada nehuma Segmentação com Status = Em Preenchimento para este cliente';
        } else if ((acc.status__c == 'Cliente cadastrado no JDE' || acc.status__c == 'Cliente cadastrado no CRM') && draftSegm.size() > 0) {
            // select segm
            if (draftSegm.size() > 0 && (draftSegm[0].Client_type__c == 'COM FATURAMENTO' || draftSegm[0].Client_type__c == 'COM PAGAMENTO' || draftSegm[0].Client_type__c == 'VENDA DIRETA')) {
                obtainedapprovalProcess = COMFATURAMENTE_APPROVAL_PRCS;
            } else if (draftSegm.size() > 0 && (draftSegm[0].Client_type__c == 'SEM FATURAMENTO' || draftSegm[0].Client_type__c == 'SEM PAGAMENTO')) {
                obtainedapprovalProcess = SEMFATURAMENTE_APPROVAL_PRCS;

            }
            //novo
        } else if (acc.status__c == 'Não aprovado' || acc.status__c == 'Novo cadastro') {
            // select approval
            if ((acc.Type == 'COM FATURAMENTO' || acc.Type == 'COM PAGAMENTO' || acc.Type == 'VENDA DIRETA')) {
                obtainedapprovalProcess = COMFATURAMENTE_APPROVAL_PRCS;
            } else if ((acc.Type == 'SEM FATURAMENTO' || acc.Type == 'SEM PAGAMENTO')) {
                obtainedapprovalProcess = SEMFATURAMENTE_APPROVAL_PRCS;

            }
        }

        if (obtainedapprovalProcess != '') {
            List < LAT_BR_ClientChannelSegmentation2Result__c > lst = [SELECT Account__c,
                Beneficio_Fiscal__c,
                Channel__c,
                Client_type__c,
                Estrategia_comercial__c,
                FORMATO__c,
                Perfil__c,
                POLiTICA_DE_PRECO__c,
                PRIOR_DE_INVESTIMENTO__c,
                Segment__c,
                Sub_channel__c, Obtained_Layout__c,
                TBCI__c,
                Obtained_POLiTICA_DE_PRECO_Udc__c,
                Politica_Preco_Origin__c
                FROM LAT_BR_ClientChannelSegmentation2Result__c
                WHERE Account__c =: acc.Id
            ];
            LAT_BR_ClientChannelSegmentation2Result__c segm = lst[0];

            //draftSegm
            
            system.debug('ApObtained+++ ' + obtainedapprovalProcess);
            accData.acc.Lat_Account__r.Obtained_Approval__c = obtainedapprovalProcess;
            //update accData.acc.Lat_Account__r;
            update new Lat_Account__c(Id = accData.acc.Lat_Account__c,
                Obtained_Approval__c = obtainedapprovalProcess,
                LAT_Rating_Before_Approval__c = accData.acc.Rating,
                //LAT_Status_Before_Approval__c = accData.acc.Status__c,
                Beneficio_Fiscal_revert__c = segm.Beneficio_Fiscal__c,
                Channel_revert__c = segm.Channel__c,
                Client_type_revert__c = segm.Client_type__c,
                Estrategia_comercial_revert__c = segm.Estrategia_comercial__c,
                FORMATO_revert__c = segm.FORMATO__c,
                Sub_channel_revert__c = segm.Sub_channel__c,
                PRIOR_DE_INVESTIMENTO_revert__c = segm.PRIOR_DE_INVESTIMENTO__c,
                Perfil_revert__c = segm.Perfil__c,
                Segment_revert__c = segm.Segment__c,
                Politica_Preco_Origin_revert__c = segm.Politica_Preco_Origin__c,
                TBCI_revert__c = segm.TBCI__c,
                Obtained_POLiTICA_DE_PRECO_Udc_revert__c = segm.Obtained_POLiTICA_DE_PRECO_Udc__c
            );

            //segm

            if(draftSegm.size()>0){
                segm.Client_type__c = draftSegm[0].Client_type__c;
                segm.channel__c = draftSegm[0].channel__c;
                segm.Sub_channel__c = draftSegm[0].Sub_channel__c;
                segm.Beneficio_Fiscal__c = draftSegm[0].Beneficio_Fiscal__c;
                segm.Estrategia_comercial__c = draftSegm[0].Estrategia_comercial__c;
                segm.FORMATO__c = draftSegm[0].FORMATO__c;
                segm.Perfil__c = draftSegm[0].Perfil__c;
                segm.POLiTICA_DE_PRECO__c = draftSegm[0].POLiTICA_DE_PRECO__c;
                segm.PRIOR_DE_INVESTIMENTO__c = draftSegm[0].PRIOR_DE_INVESTIMENTO__c;
                segm.Segment__c = draftSegm[0].Segment__c;
                segm.LAT_IsForApprove__c = true;


            update segm;
            }
            






            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Enviado para aprovação.');
            req.setNextApproverIds(new List < Id > {
                acc.ownerId
            });
            req.setObjectId(acc.Id);

            // submit the approval request for processing
            Approval.ProcessResult approvalRes = Approval.process(req);

            result = 'Enviando a Aprovação';

        } else if (result == '') {
            result = 'Envio a aprovação não permitido.<br>' +
                'Possíveis causas:<br>' +
                '- Status do cliente diferente de Cadastrado no JDE ou Cadastrado no CRM<br>' +
                '- Seção Informações não Preenchidas possui campos que precisam ser completados no cadastro<br>' +
                '- Não há nenhuma Segmentação com Status = Em Preenchimento para o cliente';
        }



        //chequear status
        //novo cadastro o 

        //else if cadastrados jde/crm ratin inatvio y has segmentation

        //else if cadastrados jde/crm ratin <> inatvio y has segmentation


        return result;

        ///Status Cliente = Novo Cadastro ou Não Aprovado
        //Informações não preenchidas Cliente = null
        //Disparar processo de aprovação de acordo as regras abaixo:
        //Completo: processo de aprovação atual para Off Trade
        /*Simples: processo de aprovação de Eventos
            if (String.isBlank(accData.acc.LAT_InformationUnfilled__c) && (accData.acc.Status__c == 'Novo cadastro' || accData.acc.Status__c == 'Não Aprovado' )) {
                


                if (accData.acc.Channel__c == 'OFF TRADE' || accData.acc.Channel__c == 'DISTRIBUIÇÃO' ){
                    if (accData.layoutObt == 'Completo'){
                        obtainedapprovalProcess = OFFTRADE_APPROVAL_PRCS;
                    } else if (accData.layoutObt == 'Simples') {
                        obtainedapprovalProcess = EVENTOS_APPROVAL_PRCS;
                    }
                } else if (accData.acc.Channel__c == 'ON TRADE' || accData.acc.Channel__c == 'ON LINE' || accData.acc.Channel__c == 'EVENTOS') {
                    if (accData.layoutObt == 'Completo'){
                        obtainedapprovalProcess = ONTRADE_APPROVAL_PRCS;
                    } else if (accData.layoutObt == 'Simples') {
                        obtainedapprovalProcess = EVENTOS_APPROVAL_PRCS;
                    }
                }




/*
ouver uma segmentação com Status = Em Preenchimento
Classificação do cliente <> Cliente inativo
Status Cliente = Cliente cadastrado no JDE ou Cliente cadastrado no CRM
Mostrar a Mensagem:
“Foi identificada uma nova Segmentação para este cliente. Deseja realmente enviar a aprovação?”


            } else if( accData.acc.Status__c == 'Em Preenchimento'){
                if (accData.layoutObt == 'Completo'){

                } else if (accData.layoutObt == 'Simples') {

                }
            }




            
            String result = 'Ejecutando aprobacion';
            return result;
            */

    }

    public static void UpdateTBCILatAcc(List < LAT_BR_ClientChannelSegmentation2Result__c > resList) {
        Set < Id > idToUpdate = new Set < Id > ();
        Map<Id,LAT_BR_ClientChannelSegmentation2Result__c> segmResultByAccId = new Map<Id,LAT_BR_ClientChannelSegmentation2Result__c>();
        for (LAT_BR_ClientChannelSegmentation2Result__c res: resList) {
            //if (res.tbci__c) {
             idToUpdate.add(res.Id);
             segmResultByAccId.put(res.Account__c, res);

            //}
        }

        List < Lat_Account__c > lataccs = [Select Id, TbciText__c,Lat_AccountId__c FROM LAT_Account__c WHERE Lat_AccountId__c in :segmResultByAccId.keyset()];
        system.debug('Ernesto+++LATACCS' + lataccs);
        system.debug('Ernesto+++LATACCSID' + lataccs);
        for (Lat_Account__c lat: lataccs) {
            if (segmResultByAccId.get(lat.Lat_AccountId__c)!=null){
                 lat.TbciText__c =  String.valueOf(segmResultByAccId.get(lat.Lat_AccountId__c).Tbci__c);
            }
           
        }
        update lataccs;

    }

    /**
     * check the correct behavior according to the de-parar tabela
     * table:
     * OffTrade\Venda Or OnTrade que hace pedidos - com faturamento / venda direta
     * OnTrade\Outros - sem pagamento / sem faturamento
     * OnTrade\Eventos\LD - com pagamento
     */
    public static void fillObtainedUdc(LAT_BR_ClientChannelSegmentation2Result__c res) {
        UDCSegmentationTables fulltabelas = getUdcMap(res);
        Map < String, Map < String, UDC__c >> tabelas = fulltabelas.rawtabelas;
        Map < String, List < UDC__c >> segmentos = fulltabelas.segmentos;
        Map < String, List < UDC__c >> udcChannel = fulltabelas.udcChannel;
        Map < String, List < UDC__c >> udcSubChannel = fulltabelas.udcSubChannel;
        String chanelChar = '';
        String subChanelChar = '';

        Map < String, String > paramterValue = new Map < String, String > ();

        paramterValue.put('Uf__c', res.Uf__c);


        if (String.isNotBlank(res.Channel__c) && udcChannel.get(res.Channel__c) != null) {
            //fulltabelas

            res.Obtained_Channel_Udc__c = udcChannel.get(res.Channel__c)[0].Id;
            chanelChar = udcChannel.get(res.Channel__c)[0].CodDefUsuario__c;
            paramterValue.put('Channel__c', chanelChar);
        }

        if (String.isNotBlank(res.Sub_channel__c) && udcSubChannel.get(res.Sub_channel__c) != null) {
            //fulltabelas

            for (UDC__C udc: udcSubChannel.get(res.Sub_channel__c)) {
                //if (udc.CodDefUsuario__c.startsWith(chanelChar)) {
                    res.Obtained_SubChannel_Udc__c = udc.Id;
                    subChanelChar = udc.CodDefUsuario__c;
                    paramterValue.put('Sub_channel__c', subChanelChar);
               // }
            }
        }

        if (String.isNotBlank(res.Segment__c) && segmentos.get(res.Segment__c) != null) {


            for (UDC__C udc: segmentos.get(res.Segment__c)) {
                if (udc.CodDefUsuario__c.startsWith(subChanelChar)) {
                    res.Obtained_Segment_Udc__c = udc.Id;
                    paramterValue.put('Segment__c', udc.CodDefUsuario__c);
                }
            }
        }

        if (String.isNotBlank(res.Perfil__c) && tabelas.get('18') != null) {
            if(tabelas.get('18').get(res.Perfil__c) != null){
                res.Obtained_Perfil_Udc__c = tabelas.get('18').get(res.Perfil__c).Id;
                paramterValue.put('Perfil__c', tabelas.get('18').get(res.Perfil__c).CodDefUsuario__c);
            }
            
        }

        if (String.isNotBlank(res.PRIOR_DE_INVESTIMENTO__c) && tabelas.get('09') != null) {
            if(tabelas.get('09').get(res.PRIOR_DE_INVESTIMENTO__c) != null) {
                res.Obtained_PRIOR_DE_INVESTIMENTO_Udc__c = tabelas.get('09').get(res.PRIOR_DE_INVESTIMENTO__c).Id;
                paramterValue.put('PRIOR_DE_INVESTIMENTO__c', tabelas.get('09').get(res.PRIOR_DE_INVESTIMENTO__c).CodDefUsuario__c);
            }
            
        }

        System.debug('%%%% test res.Estrategia_comercial__c : ' + res.Estrategia_comercial__c);
        System.debug('%%%% test tabelas.get(\'21\') : ' + tabelas.get('21'));
        if (String.isNotBlank(res.Estrategia_comercial__c) && tabelas.get('21') != null) {
            if(tabelas.get('21').get(res.Estrategia_comercial__c) != null) {
                res.Obtained_Estrategia_comercial_Udc__c = tabelas.get('21').get(res.Estrategia_comercial__c).Id;
                paramterValue.put('Estrategia_comercial__c', tabelas.get('21').get(res.Estrategia_comercial__c).CodDefUsuario__c);  
            }
            
        }

        if (String.isNotBlank(res.Client_type__c) && tabelas.get('20') != null) {
            if(tabelas.get('20').get(res.Client_type__c) != null){
               res.Obtained_Client_type_Udc__c = tabelas.get('20').get(res.Client_type__c).Id;
                paramterValue.put('Client_type__c', tabelas.get('20').get(res.Client_type__c).CodDefUsuario__c); 
            }
            
        }




        if (String.isNotBlank(res.Beneficio_Fiscal__c) && tabelas.get('25') != null) {
            if(tabelas.get('25').get(res.Beneficio_Fiscal__c) != null) {
                res.Obtained_Beneficio_Fiscal_Udc__c = tabelas.get('25').get(res.Beneficio_Fiscal__c).Id;
                paramterValue.put('Client_type__c', tabelas.get('25').get(res.Beneficio_Fiscal__c).CodDefUsuario__c);
            }
            
        }

        if (String.isNotBlank(res.FORMATO__c) && tabelas.get('19') != null) {
            if(tabelas.get('19').get(res.FORMATO__c) != null){
                res.Obtained_Formato_Udc__c = tabelas.get('19').get(res.FORMATO__c).Id;
                paramterValue.put('FORMATO__c', tabelas.get('19').get(res.FORMATO__c).CodDefUsuario__c);
            }
            
        }

        UDC__c politica = getPolitica(paramterValue);
        if (politica != null) {
            system.debug('politica!=null');


                if(!res.LAT_IsRevert__c){

                    //if (res.Obtained_POLiTICA_DE_PRECO_Udc__c == null || res.LAT_IsForApprove__c) {

                    if (res.Obtained_POLiTICA_DE_PRECO_Udc__c == null || res.LAT_IsForApprove__c) {
                        system.debug('cambiaPol++++NOTISRevert' + res.Politica_Preco_Origin__c);
                        res.Obtained_POLiTICA_DE_PRECO_Udc__c = politica.Id;
                        res.POLiTICA_DE_PRECO_Used__c = politica.Name;
                        res.Tbci__c = false;
                        res.LAT_IsForApprove__c = false;
                    }

                    if (politica.Id != res.Politica_Preco_Origin__c) {
                        res.Obtained_POLiTICA_DE_PRECO_Udc__c = politica.Id;
                        res.POLiTICA_DE_PRECO_Used__c = politica.Name;
                    }

                    res.Politica_Preco_Origin__c = politica.Id;
                    res.POLiTICA_DE_PRECO__c = politica.Name;
                }
               /* if (res.Obtained_POLiTICA_DE_PRECO_Udc__c == null || res.LAT_IsForApprove__c) {
                    system.debug('cambiaPol++++');
                    res.Obtained_POLiTICA_DE_PRECO_Udc__c = politica.Id;
                    res.POLiTICA_DE_PRECO_Used__c = politica.Name;
                    res.LAT_IsForApprove__c = false;
                }

                if (politica.Id != res.Politica_Preco_Origin__c) {
                    res.Obtained_POLiTICA_DE_PRECO_Udc__c = politica.Id;
                    res.POLiTICA_DE_PRECO_Used__c = politica.Name;
                }

                res.Politica_Preco_Origin__c = politica.Id;
                res.POLiTICA_DE_PRECO__c = politica.Name;
            }*/
        } else {
            
            //if (res.Obtained_POLiTICA_DE_PRECO_Udc__c == null) {



            if(res.LAT_IsForApprove__c || !res.LAT_IsRevert__c){
                system.debug('cambiaPol++++');
                res.Obtained_POLiTICA_DE_PRECO_Udc__c = null;
                res.POLiTICA_DE_PRECO_Used__c = '';
                //}
                res.Politica_Preco_Origin__c = null;
                res.POLiTICA_DE_PRECO__c = '';
                res.Tbci__c = false;
            }
        }


        res.LAT_IsRevert__c = false;
        res.LAT_IsForApprove__c = false;
        system.debug('res.Sub_channel__c++++' + res.Sub_channel__c);
        system.debug('cambiaPol++++NOTISRevert' + res.Politica_Preco_Origin__c);
        //res.Obtained_SubChannel_Udc__c = tabelas.get('03').get(res.Sub_channel__c).Id;


    }


    public static void notificateManagers(LAT_BR_ClientChannelSegmentation2Result__c result) {
        system.debug('cambiaPol++++++++123');
        if (result.Politica_Preco_Origin__c != null && (result.Politica_Preco_Origin__c != result.Obtained_POLiTICA_DE_PRECO_Udc__c)) {
            Udc__c politicaNew = [SELECT Name FROM Udc__c where id =: result.Obtained_POLiTICA_DE_PRECO_Udc__c];


            system.debug('entro cambio politica');
            List < Account > accs = [Select owner.Gerente_de_area__c, owner.Gerente_regional__c, Client_code_AN8__c, Name, owner.ManagerId, ownerId FROM ACCOUNT WHERE Id =: result.Account__c];
            //List<LAT_AccountInAction__c> tmpAccs = [Select id,LAT_PromotionalAction__c ,LAT_Account__r.owner.managerId,LAT_Account__r.owner.Gerente_de_area__c,LAT_Account__r.owner.Gerente_regional__c from LAT_AccountInAction__c where LAT_PromotionalAction__c =: id];
            if (accs != null && accs.size() > 0) {
                system.debug('entro cambio politica');
                List < ConnectApi.BatchInput > feedList = new List < ConnectApi.BatchInput > ();
                ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();

                input.subjectId = result.Account__c;


                ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                messageInput.messageSegments = new List < ConnectApi.MessageSegmentInput > ();
                Account acc = accs[0];



                ConnectApi.TextSegmentInput textSegment;
                textSegment = new ConnectApi.TextSegmentInput();
                String accName = (!String.isBlank(acc.Client_code_AN8__c)) ? acc.Client_code_AN8__c + ' - ' + acc.Name : acc.Name;
                system.debug('');
                textSegment.text = ' Política de Preço do cliente ' + accName + ' alterado de ' + result.POLiTICA_DE_PRECO_Used__c + ' para ' + politicaNew.Name + '\r\n';
                system.debug(messageInput.messageSegments);
                //res
                messageInput.messageSegments.add(textSegment);




                // Create mention to Opportunity Owner
                ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();

                mentionSegment = new ConnectApi.MentionSegmentInput();
                mentionSegment.id = acc.OwnerId;
                messageInput.messageSegments.add(mentionSegment);

                mentionSegment = new ConnectApi.MentionSegmentInput();
                mentionSegment.id = acc.owner.managerId;
                messageInput.messageSegments.add(mentionSegment);

                if (acc.owner.Gerente_de_area__c != null) {
                    mentionSegment = new ConnectApi.MentionSegmentInput();
                    mentionSegment.id = acc.owner.Gerente_de_area__c;
                    messageInput.messageSegments.add(mentionSegment);
                }

                if (acc.owner.Gerente_regional__c != null) {
                    mentionSegment = new ConnectApi.MentionSegmentInput();
                    mentionSegment.id = acc.owner.Gerente_regional__c;
                    messageInput.messageSegments.add(mentionSegment);
                }

                if (String.isNotBlank(LAT_Docusign_Utils.getDocusignConfig().LAT_ComercialDirectorId__c)) {
                    mentionSegment = new ConnectApi.MentionSegmentInput();
                    mentionSegment = new ConnectApi.MentionSegmentInput();
                    mentionSegment.id = Id.valueOf(LAT_Docusign_Utils.getDocusignConfig().LAT_ComercialDirectorId__c);
                    messageInput.messageSegments.add(mentionSegment);
                }




                input.body = messageInput;

                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
                feedList.add(batchInput);
                if (!Test.isRunningTest()) {
                    system.debug('debu++g' + feedList);
                    ConnectApi.ChatterFeeds.postFeedElementBatch(null, feedList);
                    system.debug('post');
                } else {
                    system.debug('Test');
                }

            }
        }
    }

    public static UDC__c getPolitica(Map < String, String > paramterValue) {
        String polobt = '';
        List < LAT_BR_PoliticaPrecoConfig__c > politicaConfig;
        String queryStr = 'SELECT Id,Politica_de_Preco__c FROM LAT_BR_PoliticaPrecoConfig__c WHERE ';
        List < LAT_GeneralConfig__c > configs = [SELECT Id, Name, LAT_Value__c from LAT_GeneralConfig__c where Name LIKE '%POLITICA_PRECO_MAPPING%'];
        boolean firstrun = true;
        for (LAT_GeneralConfig__c con: configs) {
            if (paramterValue.get(con.LAT_Value__c) == null) {
                return null;
            }
            if (!firstrun) {
                queryStr += ' AND ';
            }
            queryStr += con.LAT_Value__c + '=\'' + paramterValue.get(con.LAT_Value__c) + '\' ';
            firstrun = FALSE;

        }
        system.debug('query++++' + queryStr);
        politicaConfig = database.query(queryStr);


        if (politicaConfig.isEmpty()) {
            return null;
        }
        system.debug('Polit++++' + politicaConfig[0]);
        List < UDC__c > politica; // = //[SELECT Id,CodUs__c,CodDefUsuario__c,CodProd__c,Name FROM UDC__c WHERE CodProd__c= '01' AND CodProd__c ='05' AND CodDefUsuario__c = :politicaConfig[0].Politica_de_Preco__c];


        String queryStr2 = 'SELECT Id, CodUs__c, CodDefUsuario__c, CodProd__c, Name FROM UDC__c WHERE CodProd__c = \'01\' AND CodUs__c = \'05\' AND CodDefUsuario__c = \'' + politicaConfig[0].Politica_de_Preco__c + '\'';
        system.debug('query++++' + queryStr2);
        politica = database.query(queryStr2);


        if (politica.isEmpty()) {
            return null;
        }

        return politica[0];
    }

    /**
     * Only for migrate:
     *  -Sets the account
     *. -Creates dummy questionarie and set in the segmentation
     */
    public static void ProcessMigrationDataBefore(LAT_BR_ClientChannelSegmentation2Result__c segm) {
        //generate
        //LAT_BR_ClientChannelSegmentation2__c> seegmentQuestionToInsert;
        Account accToUpdate; 
        //Set<String> accsCNPJS = new Set<String>();
        //Map<String, LAT_BR_ClientChannelSegmentation2__c> questinarieByCNPJ = new Map<String, LAT_BR_ClientChannelSegmentation2__c>();
        //for(LAT_BR_ClientChannelSegmentation2Result__c segm:segms) {
        //  accsCNPJS.add(segm.CNPJ__C);
        //}
        // only parent accounts?
        List<Account> allAccs = [SELECT Id,RecordTypeId, Channel__c, Sub_channel__c,Type FROM Account WHERE CNPJ__C = :segm.CNPJ__C];
        if (allAccs.size()!=1){
                segm.CNPJ__C.addError('Mas de un acc con cnpj');
        }else {
            accToUpdate = allAccs[0];
            accToUpdate.TriggerRun__c = true;
            accToUpdate.Channel__c = segm.Channel__c;
            accToUpdate.Type = segm.Client_type__c;
            accToUpdate.RecordTypeId = getRecordTypeId(accToUpdate.Channel__c, accToUpdate.Type);
            LAT_BR_ClientChannelSegmentation2__c questionarie = new LAT_BR_ClientChannelSegmentation2__c();
        questionarie.Status__c = 'Active';
        //questionarie.Name ;= allAccs[0].CNPJ__C + '-Migration Questionarie';
        insert questionarie;
        segm.Account__c = accToUpdate.Id;
        segm.Client_Segmentation_2__c = questionarie.Id;
        update accToUpdate;
        }
        



        //Map<String,Account> accountPerCNPJ = new Map<String,Account>();
        //for(Account acc:allAccs){
                //generate the 
        //      accountPerCNPJ.put(acc.CNPJ__C,acc);
        //}

        //insert questinarieByCNPJ.values();

        //for(LAT_BR_ClientChannelSegmentation2Result__c segm:segms){

            // sets account
            //if (accountPerCNPJ.get(segm.CNPJ__C)!=null){
                
                

        //  } else {
                //segm.Account__c.addError('Account CNPJ NOT FOUND');
        //  }

            
        //}

    }

      /**
     * Only for migrate:
     *  -Sets the account
     *. -Creates dummy questionarie and set in the segmentation
     */
    public static void ProcessMigrationDataAfter(LAT_BR_ClientChannelSegmentation2Result__c segm) {
        //generate
        //LAT_BR_ClientChannelSegmentation2__c> seegmentQuestionToInsert;
        Account accToUpdate; 
        //Set<String> accsCNPJS = new Set<String>();
        //Map<String, LAT_BR_ClientChannelSegmentation2__c> questinarieByCNPJ = new Map<String, LAT_BR_ClientChannelSegmentation2__c>();
        //for(LAT_BR_ClientChannelSegmentation2Result__c segm:segms) {
        //  accsCNPJS.add(segm.CNPJ__C);
        //}
        // only parent accounts?
        List<Lat_Account__c> lata =[SELECT Id,Name FROM LAT_Account__c WHERE Lat_AccountId__c = :segm.Account__c];
        if (lata.size()!=1){
                segm.CNPJ__C.addError('Mas de un acc con cnpj');
        }else {
            lata[0].LAT_BR_Segmentation__c = segm.Id;
            update lata[0];
        }
        //LAT_BR_ClientChannelSegmentation2__c questionarie = new LAT_BR_ClientChannelSegmentation2__c();

        //insert questionarie;
        //segm.Account__c = accToUpdate.Id;
        //segm.Client_Segmentation_2__c = questionarie.Id;



        //Map<String,Account> accountPerCNPJ = new Map<String,Account>();
        //for(Account acc:allAccs){
                //generate the 
        //      accountPerCNPJ.put(acc.CNPJ__C,acc);
        //}

        //insert questinarieByCNPJ.values();

        //for(LAT_BR_ClientChannelSegmentation2Result__c segm:segms){

            // sets account
            //if (accountPerCNPJ.get(segm.CNPJ__C)!=null){
                
                

        //  } else {
                //segm.Account__c.addError('Account CNPJ NOT FOUND');
        //  }

            
        //}

    }

    /**
     * Only for migrate:
     *  -Sets thee Lat account seegmentation pointer
     *  -Update thee accunt data
     *  
     *
    public static void ProcessMigrationDataAfter(LAT_BR_ClientChannelSegmentation2Result__c> segm) {
        
        //generate
        List<LAT_BR_ClientChannelSegmentation2__c>  seegmentQuestionToInsert;

        List<Account> accToUpdate = new List<Account>();
        Set<String> accsCNPJS = new Set<String>();
        for(LAT_BR_ClientChannelSegmentation2Result__c segm:segms) {
            accsCNPJS.add(segm.CNPJ__C);
        }
        // only parent accounts?
        List<Account> allAccs = [SELECT Id,RecordTypeId, Channel__c, Sub_channel__c,Type FROM Account WHERE CNPJ__C IN:accsCNPJS];
        Map<String,Account> accountPerCNPJ = new Map<String,Account>();
        for(Account acc:allAccs){
                accountPerCNPJ.put(acc.CNPJ__C,acc);
        }


        for(LAT_BR_ClientChannelSegmentation2Result__c segm:segms){


            if (accountPerCNPJ.get(segm.CNPJ__C)!= null){
                accountPerCNPJ.get(segm.CNPJ__C).Channel__c = segm.Channel__c;
                accountPerCNPJ.get(segm.CNPJ__C).Sub_channel__c = segm.Sub_channel__c;
                accountPerCNPJ.get(segm.CNPJ__C).Type = segm.Client_type__c;
                accountPerCNPJ.get(segm.CNPJ__C).RecordTypeId = getRecordTypeId(segm.Channel__c,segm.Client_type__c);
                accToUpdate.add(accountPerCNPJ.get(segm.CNPJ__C));
            } else {
                segm.Account__c.addError('Account CNPJ NOT FOUND');
            }

        }

    }*/


    public static String getRecordTypeId(String channel, String typeClient) {
        String retId = '';
        system.debug(channel == 'EVENTOS');
        system.debug(channel == 'EVENTOS');
        system.debug(typeClient == 'SEM PAGAMENTO');
        if (channel == CHANNEL_DIST && typeClient == 'COM FATURAMENTO') {
            retId = Global_RecordTypeCache.getRtId('Account' + 'LAT_Distribucao_Com_Faturamento');
        } else if (channel == CHANNEL_OFF_TRADE && typeClient == 'SEM FATURAMENTO') {
            retId = Global_RecordTypeCache.getRtId('Account' + 'LAT_Off_Trade_Sem_Faturamento');
        } else if (channel == CHANNEL_OFF_TRADE && typeClient == 'COM FATURAMENTO') {
            retId = Global_RecordTypeCache.getRtId('Account' + 'LAT_Off_Trade_Faturamento');
        } else if (channel == CHANNEL_ONLINE && typeClient == 'COM FATURAMENTO') {
            retId = Global_RecordTypeCache.getRtId('Account' + 'LAT_On_Line_Com_Faturamento');
        } else if (channel == CHANNEL_ON_TRADE && typeClient == 'VENDA DIRETA') {
            retId = Global_RecordTypeCache.getRtId('Account' + 'LAT_On_Trade_Venda_Directa');
        } else if (channel == CHANNEL_ON_TRADE && typeClient == 'SEM PAGAMENTO') {
            retId = Global_RecordTypeCache.getRtId('Account' + 'LAT_On_Trade_Sem_Pagamento');
        } else if (channel == CHANNEL_ON_TRADE && typeClient == 'COM PAGAMENTO') {
            retId = Global_RecordTypeCache.getRtId('Account' + 'LAT_On_Trade_Com_Pagamento');
        } else if (channel == CHANNEL_ON_TRADE && typeClient == 'VENDA DIRETA') {
            retId = Global_RecordTypeCache.getRtId('Account' + 'LAT_Eventos_VendaDirecta');
        } else if (channel == CHANNEL_EVENTOS && typeClient == 'COM PAGAMENTO') {
            system.debug('testEntro+++2423424');
            retId = Global_RecordTypeCache.getRtId('Account' + 'LAT_Eventos_com_pagamento');
        } else if (channel == CHANNEL_EVENTOS && typeClient == 'SEM PAGAMENTO') {
            retId = Global_RecordTypeCache.getRtId('Account' + 'LAT_Eventos_sem_pagamento');
        } else if (channel == CHANNEL_EVENTOS && typeClient == 'VENDA DIRETA') {
            retId = Global_RecordTypeCache.getRtId('Account' + 'LAT_Eventos_VendaDirecta');
        } else {
            system.debug('noEntroNinguno +++');
        }
        system.debug('CANAL++: ' + channel + ' + TIPO+++: ' + typeClient);
        system.debug('retId+++' + retId);
        return retId;
    }

    public static String getLayoutSet(String channel, String typeClient) {
        String retLayout = '';

        if (channel == CHANNEL_DIST && typeClient == 'COM FATURAMENTO') {
            retLayout = 'Off-Trade/Completo';
        } else if (channel == CHANNEL_OFF_TRADE && typeClient == 'SEM FATURAMENTO') {
            retLayout = 'Off-Trade/Simples';

        } else if (channel == CHANNEL_OFF_TRADE && typeClient == 'COM FATURAMENTO') {
            retLayout = 'Off-Trade/Completo';
        } else if (channel == 'ON LINE' && typeClient == 'COM FATURAMENTO') {
            retLayout = 'On-Trade/Completo';
        } else if (channel == 'ON TRADE' && typeClient == 'VENDA DIRETA') {
            retLayout = 'On-Trade/Completo';
        } else if (channel == 'ON TRADE' && typeClient == 'SEM PAGAMENTO') {
            retLayout = 'On-Trade/Simples';
        } else if (channel == 'ON TRADE' && typeClient == 'COM PAGAMENTO') {
            retLayout = 'On-Trade/Completo';
        } else if (channel == 'EVENTOS' && typeClient == 'VENDA DIRETA') {
            retLayout = 'On-Trade/Completo';
        } else if (channel == 'EVENTOS' && typeClient == 'COM PAGAMENTO') {
            retLayout = 'On-Trade/Completo';
        } else if (channel == 'EVENTOS' && typeClient == 'SEM PAGAMENTO') {
            retLayout = 'On-Trade/Simples';
        }
        return retLayout;
    }

    private static UDCSegmentationTables getUdcMap(LAT_BR_ClientChannelSegmentation2Result__c res) {
        Set < String > values = new Set < String > ();
        values.add(res.Beneficio_Fiscal__c);
        values.add(res.Estrategia_comercial__c);
        values.add(res.Channel__c);
        values.add(res.Sub_channel__c);
        values.add(res.FORMATO__c);
        values.add(res.Segment__c);
        values.add(res.Client_type__c);
        values.add(res.Perfil__c);
        values.add(res.PRIOR_DE_INVESTIMENTO__c);
        Set < String > udcValues = new Set < String > {
            '03',
            '18',
            '19',
            '20',
            '21',
            '05',
            '09',
            '25'
        };
        UDCSegmentationTables ret = new UDCSegmentationTables();

        Map < String, Map < String, UDC__c >> resultMap = new Map < String, Map < String, UDC__c >> ();
        Map < String, List < UDC__c >> segmentos = new Map < String, List < UDC__c >> ();
        Map < String, List < UDC__c >> udcChannel = new Map < String, List < UDC__c >> ();
        Map < String, List < UDC__c >> udcSubChannel = new Map < String, List < UDC__c >> ();
        List < UDC__C > udcs = [SELECT Id, CodUs__c, CodDefUsuario__c, CodProd__c, Name FROM UDC__c WHERE CodProd__c = '01'
            AND Name IN: values AND CodUs__c IN: udcValues
        ];
        system.debug('udc obtained List+++' + udcs);
        for (UDC__C tabela: udcs) {
            if (resultMap.get(tabela.CodUs__c) == null) {

                resultMap.put(tabela.CodUs__c, new Map < String, UDC__c > ());
            }
            if (tabela.CodUs__c == '03') {
                if (tabela.CodDefUsuario__c.length() == 2) {
                    if (udcSubChannel.get(tabela.Name) == null) {
                        udcSubChannel.put(tabela.Name, new List < UDC__c > ());
                    }
                    udcSubChannel.get(tabela.Name).add(tabela);
                } else if (tabela.CodDefUsuario__c.length() == 1) {
                    if (udcChannel.get(tabela.Name) == null) {
                        udcChannel.put(tabela.Name, new List < UDC__c > ());
                    }
                    udcChannel.get(tabela.Name).add(tabela);
                } else if (tabela.CodDefUsuario__c.length() == 3) {
                    if (segmentos.get(tabela.Name) == null) {
                        segmentos.put(tabela.Name, new List < UDC__c > ());
                    }
                    segmentos.get(tabela.Name).add(tabela);
                }
            }


            resultMap.get(tabela.CodUs__c).put(tabela.Name, tabela);
            system.debug('udc obtained List+++1' + tabela);
        }
        system.debug('udc final List+++1' + resultMap);
        ret.rawtabelas = resultMap;
        ret.udcChannel = udcChannel;
        ret.udcSubChannel = udcSubChannel;
        ret.segmentos = segmentos;
        return ret;
    }


    public class UDCSegmentationTables {
        Map < String, Map < String, UDC__c >> rawtabelas {
            set;
            get;
        }

        // udc 03 with the value and udc
        Map < String, List < UDC__c >> udcChannel {
            set;
            get;
        }

        // udc 03 with the value and udc
        Map < String, List < UDC__c >> udcSubChannel {
            set;
            get;
        }

        Map < String, List < UDC__c >> segmentos {
            set;
            get;
        }

        public UDCSegmentationTables() {
            rawtabelas = new Map < String, Map < String, UDC__c >> ();
            udcChannel = new Map < String, List < UDC__c >> ();
            udcSubChannel = new Map < String, List < UDC__c >> ();
            segmentos = new Map < String, List < UDC__c >> ();
        }
    }

    /**
     * Wrapper Class to handle the full segmentation data
     */
    public class AccountSegmentationData {
        public Account acc {
            get;
            set;
        }
        public LAT_BR_ClientChannelSegmentation2__c segment {
            get;
            set;
        }
        public LAT_BR_ClientChannelSegmentation2Result__c segmentResult {
            get;
            set;
        }
        public String layoutObt {
            get;
            set;
        }

        public AccountSegmentationData(Id accId) {
            acc = [Select Id,
                channel__c,
                Type,
                LAT_InformationUnfilled__c,
                Lat_Account__c,
                Lat_Account__r.Obtained_Approval__c
                FROM Account
                where Id =: accId
            ];
            segment = [SELECT Id,
                Q1_canal_negocio__c,
                Account__c,
                q2_relacao_comercial__c,
                q3_Qual_o_principal_escopo_do_neg_cio__c,
                q4_Qual_a_principal_rea_abordagem__c,
                q5_Qual_o_principal_p_blico__c,
                q6_Qual_o_formato_do_negocio__c,
                q7_Qual_modelo_de_neg_cio_do_cliente__c,
                q8_cliente_possui_benefcio_Fiscal__c,
                q9_Qual_a_importancia_do_cliente_para_PR__c
                FROM LAT_BR_ClientChannelSegmentation2__c WHERE Account__c =: accId LIMIT 1
            ];
            segmentResult = [SELECT Account__c,
                Beneficio_Fiscal__c,
                Channel__c,
                Client_type__c,
                Estrategia_comercial__c,
                FORMATO__c,
                Perfil__c,
                POLiTICA_DE_PRECO__c,
                PRIOR_DE_INVESTIMENTO__c,
                Segment__c,
                Sub_channel__c,
                Obtained_Layout__c
                FROM LAT_BR_ClientChannelSegmentation2Result__c
                WHERE Account__c =: accId LIMIT 1
            ];
            this.layoutObt = segmentResult.Obtained_Layout__c;
        }

        public AccountSegmentationData(Account accId) {
            this.acc = accId;
            segment = [SELECT Id,
                Q1_canal_negocio__c,
                Account__c,
                q2_relacao_comercial__c,
                q3_Qual_o_principal_escopo_do_neg_cio__c,
                q4_Qual_a_principal_rea_abordagem__c,
                q5_Qual_o_principal_p_blico__c,
                q6_Qual_o_formato_do_negocio__c,
                q7_Qual_modelo_de_neg_cio_do_cliente__c,
                q8_cliente_possui_benefcio_Fiscal__c,
                q9_Qual_a_importancia_do_cliente_para_PR__c
                FROM LAT_BR_ClientChannelSegmentation2__c WHERE Account__c =: acc.Id LIMIT 1
            ];
            segmentResult = [SELECT Account__c,
                Beneficio_Fiscal__c,
                Channel__c,
                Client_type__c,
                Estrategia_comercial__c,
                FORMATO__c,
                Perfil__c,
                POLiTICA_DE_PRECO__c,
                PRIOR_DE_INVESTIMENTO__c,
                Segment__c,
                Sub_channel__c, Obtained_Layout__c
                FROM LAT_BR_ClientChannelSegmentation2Result__c
                WHERE Account__c =: acc.Id
            ];
            this.layoutObt = segmentResult.Obtained_Layout__c;
        }
    }


    public static boolean hasCompleteSegmentation(Id accId) {
        List < LAT_BR_ClientChannelSegmentation2Result__c > segmentResult;
        segmentResult = [SELECT Account__c,
            Beneficio_Fiscal__c,
            Channel__c,
            Client_type__c,
            Estrategia_comercial__c,
            FORMATO__c,
            Perfil__c,
            POLiTICA_DE_PRECO__c,
            PRIOR_DE_INVESTIMENTO__c,
            Segment__c,
            Sub_channel__c, Obtained_Layout__c
            FROM LAT_BR_ClientChannelSegmentation2Result__c
            WHERE Account__c =: accId AND Client_Segmentation_2__r.Status__c = 'Active'
        ];
        if (segmentResult == null || segmentResult.isEmpty()) {
            return false;
        } else return hasCompleteSegmentation(segmentResult[0]);
    }

    public static boolean hasCompleteSegmentation(LAT_BR_ClientChannelSegmentation2Result__c segResult) {
        if (String.isNotBlank(segResult.Beneficio_Fiscal__c) &&
            String.isNotBlank(segResult.Channel__c) &&
            String.isNotBlank(segResult.Client_type__c) &&
            String.isNotBlank(segResult.Estrategia_comercial__c) &&
            String.isNotBlank(segResult.FORMATO__c) &&
            String.isNotBlank(segResult.Perfil__c) &&
            //String.isNotBlank(segResult.POLiTICA_DE_PRECO__c) ||
            String.isNotBlank(segResult.PRIOR_DE_INVESTIMENTO__c) &&
            String.isNotBlank(segResult.Segment__c) &&
            String.isNotBlank(segResult.Sub_channel__c) 
            //&& String.isNotBlank(segResult.Obtained_Layout__c)
            ) {
            return true;

        } else {
            return false;
        }

    }



    public static Map < Id, OldAccountTyping > getMapOfOldTyping(List < Account > accList) {
        Map < Id, OldAccountTyping > retMap = new Map < Id, OldAccountTyping > ();
        for (Account acc: accList) {
            retMap.put(acc.Id, new OldAccountTyping(acc));
        }
        return retMap;
    }
    /**
     * Wrapper Class to handle the current class data
     *
     */
    public class OldAccountTyping {
        public String channel;
        public String type;
        public boolean directSales;
        public String recordTypeDeveName;

        public oldAccountTyping(Account acc) {
            // Old type handllytng
            if (acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'Off_Trade')) {
                this.channel = 'Off Trade';
                this.type = acc.type;
                this.recordTypeDeveName = 'Off_Trade';
            } else if (acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'On_Trade')) {
                this.channel = 'Off Trade';
                this.recordTypeDeveName = 'Off_Trade';
                this.directSales = acc.LAT_Account__r.LAT_DirectSale__c;
            } else if (acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'Eventos')) {
                this.channel = 'Eventos';
                this.type = acc.type;
                this.recordTypeDeveName = 'Eventos';
            } else {
                if (acc.channel__c.toUpperCase() == 'OFF TRADE' || acc.channel__c.toUpperCase() == CHANNEL_DIST) {
                    if (acc.type == 'COM FATURAMENTO' || acc.type == 'VENDA DIRETA') {
                        this.channel = 'Off Trade';
                        this.type = 'Venda';
                    }
                } else if (acc.channel__c.toUpperCase() == 'ON TRADE' || acc.channel__c.toUpperCase() == 'ON LINE') {
                    if (acc.type == 'SEM FATURAMENTO' || acc.type == 'SEM PAGAMENTO') {
                        this.channel = 'On Trade';
                        this.type = 'Outros';
                    } else if (acc.type.toUpperCase() == 'VENDA DIRETA' || acc.type.toUpperCase() == 'COM FATURAMENTO') {
                        this.channel = 'On Trade';
                        this.directSales = true;
                    } else if (acc.type.toUpperCase() == 'COM PAGAMENTO') {
                        this.channel = 'On Trade';
                        this.type = 'LD';
                    }
                } else if (acc.channel__c == 'EVENTOS') {
                    this.channel = 'Eventos';
                    if (acc.type.toUpperCase() == 'VENDA DIRETA') {
                        this.directSales = true;
                    } else if (acc.type.toUpperCase() == 'COM PAGAMENTO') {
                        this.type = 'LD';
                    }
                }

                // Get the rt name
                if (this.channel == 'On Trade') {
                    this.recordTypeDeveName = 'On_Trade';
                } else if (this.channel == 'Off Trade') {
                    this.recordTypeDeveName = 'Off_Trade';
                } else if (this.channel == 'Eventos') {
                    this.recordTypeDeveName = 'Eventos';
                }
            }

        }
    }


}