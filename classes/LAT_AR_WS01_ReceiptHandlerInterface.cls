/******************************************************************************************************
*     Company:Valuenet     Developer:Denis Aranda / Elena J. Schwarzböck      Date:25/05/2014         *
*******************************************************************************************************/

global class LAT_AR_WS01_ReceiptHandlerInterface{
    
    private static RCP_Receipt_ARG__c receiptBackUp;
    
    @Future(callout = true)
    Webservice static void ReceiptInterfaceJDE(String idSalesforce){
        

        List<RCP_Receipt_ARG__c> listReceipts = [SELECT Id,  Name, Account_AR__c, AmountsControl_AR__c, LAT_AR_DepositAccountType__c, AN8_AR__c, 
                                                        CollectionAgent_AR__c, Comment_AR__c, CustomerPaymentOrder_AR__c, Date_AR__c, 
                                                        Debit_AR__c, DepositsAmount_AR__c, Discount_AR__c, DocumentsAmount_AR__c, Downpayments_AR__c, 
                                                        Id_TXT_Aplications_Document_AR__c, Id_TXT_Values_Document_AR__c, LAT_AR_IntegrationStatus__c, 
                                                        LAT_AR_JDEReturnCode__c, ManualReceiptNumber_AR__c, RedemptionDateTime_AR__c, RedemptionNo_AR__c, 
                                                        Status_AR__c,Comercial_Discount__c, TXT_Aplications_AR__c, TXT_Values_AR__c, ValuesAmount_AR__c, WithholdingsAmount_AR__c,
                                                        CurrencyIsoCode
                                                 FROM RCP_Receipt_ARG__c 
                                                 WHERE Id =: idSalesforce];
                                                 
        if(listReceipts.isEmpty()){return;}     
                                                                
        List<DPT_Deposit_ARG__c> listDeposits = [SELECT Id,  Name, AccType_AR__c, Amount_AR__c, Bank_AR__c, Branch_AR__c, Comment_AR__c, Date_AR__c, 
                                                        LAT_AR_DepositRecordedJDE__c, ReceiptNo_AR__c, RecNumberInterfaceOk_AR__c, ReceiptNo_AR__r.Name,
                                                        (SELECT Id, Amount_AR__c, BankSlipNumber__c, Company__c, DocumentNumber__c FROM LAT_RU_Deposits__r)
                                                 FROM DPT_Deposit_ARG__c 
                                                 WHERE ReceiptNo_AR__c =: idSalesforce];
        
        List<VLS_Values_ARG__c> listValues = [SELECT Id,Deposit_AR__r.Branch_AR__c, Deposit_AR__r.Bank_AR__c, Name, AccType_AR__c, Amount_AR__c, Bank_AR__c, BranBranch_AR__c, CommeComment_AR__c, 
                                                     Deposit_AR__c, DueDate_AR__c, IssueDate_AR_c__c, ReceiptNo_AR__c, ValueRecordedinJDE_AR__c, 
                                                     ValueTXTissued_AR__c, ValueType_AR__c, ReceiptNo_AR__r.Name, Deposit_AR__r.Name, Deposit_AR__r.Date_AR__c, Deposit_AR__r.AccType_AR__c
                                              FROM VLS_Values_ARG__c 
                                              WHERE ReceiptNo_AR__c =: idSalesforce];   
                                                     
        List<TXC_TaxCertificates_ARG__c> listTaxCert = [SELECT Id, Name, Amount_AR__c, Comment_AR__c, Date_AR__c, RateRate_AR__c,Rate_AR__c, ReceiptNo_AR__c, 
                                                               TaxableAmount_AR__c, ValueType_AR__c, AplicationsTXTissued_AR__c, WithhRecordedinJDE_AR__c,
                                                               ReceiptNo_AR__r.Name
                                                        FROM TXC_TaxCertificates_ARG__c 
                                                        WHERE ReceiptNo_AR__c =: idSalesforce];     
                                                        
        List<DCM_Documents_ARG__c> listDocs = [SELECT Id, Name, ReceiptNo_AR__c, LegalInvoice_AR__c, ReceiptNo_AR__r.Name, tipoDocumento_AR__c,
                                               OrderNumber_AR__c,PaymentID_AR__c, Amounttoapply_AR__c, observacoesTitulo_AR__c, Internal_id_pk_AR__c
                                               FROM DCM_Documents_ARG__c
                                               WHERE ReceiptNo_AR__c =: idSalesforce]; 
                                               
        List<DBT_Debit_ARG__c> ListInvoice = [Select Id, Name, Comment_AR__c, DebitAmount_AR__c, DebitNo_AR__c, Serial_AR__c,DebitNoteType_AR__c,
                                             IssueDate_AR__c
                                             FROM DBT_Debit_ARG__c 
                                             Where ReceiptNo_AR__c =: idSalesforce];

        List<LAT_Invoice__c> ListLAT_Invoice = [Select Id, Name, LAT_IdCrmDoc__c, LAT_IdCRMval__c, LAT_InvoiceAmount__c, LAT_InvoiceExplanation__c, LAT_InvoiceNumber__c,
                                             LAT_InvoiceTaxableAmount__c, LAT_InvoiceTaxAmount__c, LAT_InvoiceType__c, LAT_Receipt__c
                                             FROM LAT_Invoice__c 
                                             Where LAT_Receipt__c =: idSalesforce];
        
        RCP_Receipt_ARG__c receipt = listReceipts[0];
        
        receiptBackUp = receipt.clone(true);
        

        LAT_ReceiptHandelerTypes.ReceiptType receiptArguments;
 
        try{    
            //Mapeo de recibo y sus hijos
            receiptArguments = mapReceipt(receipt,listDeposits,listValues,listTaxCert,listDocs, ListInvoice, ListLAT_Invoice);
            
            system.debug('SEND CODE: ' + receiptArguments);
            //Llamado a la interfase
            LAT_ReceiptHandelerTypes.CollectionManagerSFDCReqSOAPQSPort request = new LAT_ReceiptHandelerTypes.CollectionManagerSFDCReqSOAPQSPort();
            request.timeout_x = 120000;
            LAT_ReceiptHandelerTypes.CollectionManagerResponse_element response = request.CollectionManager(getConnectionParameter(), receiptArguments);
            
            system.debug('RETURN CODE: ' + String.valueOf(response.code));
            system.debug('RETURN MESSAGE: ' + String.valueOf(response.description));
            
            //Mapeo el retorno
            if(response.code == 0){
                receipt.LAT_AR_IntegrationStatus__c = 'Sent to JDE';
            }else{
                receipt.LAT_AR_MessageJDEIntegration__c = String.valueOf(response.description);
                receipt.LAT_AR_IntegrationStatus__c = 'Error en JDE';
            }        
        }catch(DMLException e){
            withError(receipt, e.getMessage());
            return;
        }
  
        //Actualizacion del recibo
        try{update receipt;}catch(Exception e){withError(receipt, e.getMessage());return;}

    }

    private static LAT_ReceiptHandelerTypes.ReceiptType mapReceipt(RCP_Receipt_ARG__c receipt, List<DPT_Deposit_ARG__c> listDeposits, List<VLS_Values_ARG__c> listValues, 
                            List<TXC_TaxCertificates_ARG__c> listTaxCert, List<DCM_Documents_ARG__c> listDocs, List<DBT_Debit_ARG__c> ListInvoice, List<LAT_Invoice__c> ListLAT_Invoice){
        
        LAT_ReceiptHandelerTypes.ReceiptType receiptArguments = new LAT_ReceiptHandelerTypes.ReceiptType();
        //Datetime recDatetime = receipt.Date_AR__c;
        //Campos Recibo
        receiptArguments.actionCode           = '1';
        receiptArguments.receiptAmount        = receipt.AmountsControl_AR__c;
        receiptArguments.receiptCurrency      = receipt.CurrencyIsoCode;
        receiptArguments.receiptCompany       = '00100';
        receiptArguments.receiptNo            = receipt.Name;
        receiptArguments.amountsControl       = receipt.AmountsControl_AR__c;
        receiptArguments.clientAN8            = receipt.AN8_AR__c;
        receiptArguments.idCRM                = receipt.Id;
        //receiptArguments.depositAccountType   = receipt.LAT_AR_DepositAccountType__c; //Se quita a pedido de marcin, para ser incluido a nivel de linea en los listvalues
        receiptArguments.collectionAgent      = receipt.CollectionAgent_AR__c;
        receiptArguments.comment              = receipt.Comment_AR__c;
        receiptArguments.customerPaymentOrder = receipt.CustomerPaymentOrder_AR__c;
        //receiptArguments.recDate              = recDatetime.addHours(12);
        receiptArguments.recDate              = receipt.Date_AR__c;
        receiptArguments.debit                = receipt.Debit_AR__c;
        receiptArguments.depositsAmount       = receipt.DepositsAmount_AR__c;
        receiptArguments.discount             = receipt.Discount_AR__c;
        receiptArguments.documentsAmount      = receipt.DocumentsAmount_AR__c;  
        receiptArguments.downpayments         = receipt.Downpayments_AR__c;
        receiptArguments.manualReceiptNumber  = integer.valueOf(receipt.ManualReceiptNumber_AR__c);
        receiptArguments.redemptionDateTime   = receipt.RedemptionDateTime_AR__c;
        receiptArguments.redemptionNo         = receipt.RedemptionNo_AR__c;
        receiptArguments.status               = receipt.Status_AR__c;
        receiptArguments.valuesAmount         = receipt.ValuesAmount_AR__c;
        receiptArguments.withholdingsAmount   = receipt.WithholdingsAmount_AR__c;         
        
        receiptArguments.listDeposits = new LAT_ReceiptHandelerTypes.listDeposits_element();
        receiptArguments.listDeposits.deposit = new List<LAT_ReceiptHandelerTypes.DepositType>();
         
        if(!listDeposits.isEmpty()){            
            LAT_ReceiptHandelerTypes.DepositType depositArguments;
            for(DPT_Deposit_ARG__c deposit: listDeposits){
                depositArguments = new LAT_ReceiptHandelerTypes.DepositType();
                //se completan los campos de Depositos
                depositArguments.bankSlipNo = deposit.Name;
                depositArguments.accType    = deposit.AccType_AR__c;
                depositArguments.amount     = deposit.Amount_AR__c;
                depositArguments.bank       = deposit.Bank_AR__c;
                depositArguments.branch     = deposit.Branch_AR__c;
                depositArguments.comment    = deposit.Comment_AR__c;
                depositArguments.depDate    = deposit.Date_AR__c;
                depositArguments.receiptNo  = deposit.ReceiptNo_AR__r.Name;
                depositArguments.idCRMdep   = deposit.Id;
                
                //receiptArguments.listDeposits.deposit.add(depositArguments); 
            }
        }  
        
        receiptArguments.listValues= new LAT_ReceiptHandelerTypes.listValues_element();
        receiptArguments.listValues.value = new List<LAT_ReceiptHandelerTypes.ValueType>();
        Integer i = 1;
        if(!listValues.isEmpty()){           
            LAT_ReceiptHandelerTypes.ValueType valueArguments;
            for(VLS_Values_ARG__c value: listValues){   
                if(value.Deposit_AR__r.AccType_AR__c != 'Bank Account' && receipt.LAT_AR_DepositAccountType__c != 'R') {
                    valueArguments = new LAT_ReceiptHandelerTypes.ValueType();
                    //se completan los campos de Valores
                    //Datetime myDate = value.Deposit_AR__r.Date_AR__c;

                    valueArguments.chequeNo             = getDateStringFormated(value.Deposit_AR__r.Date_AR__c)+'-'+i;
                    valueArguments.accType              = value.AccType_AR__c;
                    valueArguments.amount               = value.Amount_AR__c;
                    //valueArguments.bank                 = value.Deposit_AR__r.Bank_AR__c;
                    valueArguments.bank                 = value.Bank_AR__c;
                    valueArguments.branch               = value.BranBranch_AR__c;
                    valueArguments.comment              = value.CommeComment_AR__c;
                    valueArguments.dueDate              = value.Deposit_AR__r.Date_AR__c;
                    valueArguments.issueDate            = value.Deposit_AR__r.Date_AR__c;
                    //valueArguments.dueDate              = myDate.addHours(12); //Para que en GMT-3 aparezca a las 00 en vez de las 21 del dia anterior
                    //valueArguments.issueDate            = myDate.addHours(12);
                    valueArguments.receiptNo            = value.ReceiptNo_AR__r.Name;
                    valueArguments.valueType            = value.Deposit_AR__r.Bank_AR__c + '-' +value.ValueType_AR__c;
                    valueArguments.idCRMval             = value.Id;
                    valueArguments.depositBankSlipNo    = value.Deposit_AR__r.Name;
                    valueArguments.depositBank          = value.Deposit_AR__r.Bank_AR__c;
                    valueArguments.depositBranch        = value.Deposit_AR__r.Branch_AR__c;
                    valueArguments.depositAccountType   = receipt.LAT_AR_DepositAccountType__c;
                    
                    receiptArguments.listValues.value.add(valueArguments); 
                    i++;
                }
            }
        }
        //Para el caso de que existan depósitos pero no existan valores, creo un "Valor" con los datos
        //del depósito, de forma que a JDE le llegue la información.
        //if(listValues.isEmpty()&&!listDeposits.isEmpty()){   
        if(!listDeposits.isEmpty()) {        
            LAT_ReceiptHandelerTypes.ValueType valueArguments;
            
            for(DPT_Deposit_ARG__c deposit: listDeposits){  
                if (receipt.LAT_AR_DepositAccountType__c == 'R' || deposit.AccType_AR__c == 'Bank Account') {
                    valueArguments = new LAT_ReceiptHandelerTypes.ValueType();
                    //se completan los campos de Valores
                    if (deposit.LAT_RU_Deposits__r.size() > 0) {
                        //recorro los RUs relacionados para enviar el detalle.
                        for (LAT_RUDeposit__c ruDep : deposit.LAT_RU_Deposits__r) {
                            LAT_ReceiptHandelerTypes.ValueType ruDepositValueArguments = new LAT_ReceiptHandelerTypes.ValueType();
                            
                            //ruDepositValueArguments.chequeNo             = getDateStringFormated(deposit.Date_AR__c)+'-'+i;
                            ruDepositValueArguments.accType              = deposit.AccType_AR__c;
                            ruDepositValueArguments.branch               = deposit.Branch_AR__c;
                            ruDepositValueArguments.comment              = deposit.Comment_AR__c;
                            //ruDepositValueArguments.dueDate              = deposit.Date_AR__c;//Sacado a Pedido de Martin Deniard 24/4/18
                            //ruDepositValueArguments.issueDate            = deposit.Date_AR__c;//Sacado a Pedido de Martin Deniard 24/4/18
                            ruDepositValueArguments.receiptNo            = deposit.ReceiptNo_AR__r.Name;
                            ruDepositValueArguments.depositBankSlipNo    = deposit.Name;
                            ruDepositValueArguments.depositBranch        = deposit.Branch_AR__c;
                            ruDepositValueArguments.depositBank          = deposit.Bank_AR__c;
                            ruDepositValueArguments.bank                 = deposit.Bank_AR__c;
                            ruDepositValueArguments.depositAccountType   = receipt.LAT_AR_DepositAccountType__c;
                            ruDepositValueArguments.amount               = ruDep.Amount_AR__c;
                            ruDepositValueArguments.idCRMval             = ruDep.Id;
                            ruDepositValueArguments.valueType            = ''; //Cuando es Recaudadora mandar ''
                            ruDepositValueArguments.docCo                = ruDep.Company__c; 
                            ruDepositValueArguments.docType              = 'RU'; //Siempre mandar RU
                            ruDepositValueArguments.docNo                = ruDep.DocumentNumber__c; 
                            receiptArguments.listValues.value.add(ruDepositValueArguments);
                            i++;
                        }
                    } else {
                        //es un deposito en cuenta corriente, mando el deposito.
                        //Datetime myDate = deposit.Date_AR__c;
                        valueArguments.chequeNo             = getDateStringFormated(deposit.Date_AR__c)+'-'+i;
                        valueArguments.accType              = deposit.AccType_AR__c;
                        valueArguments.branch               = deposit.Branch_AR__c;
                        valueArguments.comment              = deposit.Comment_AR__c;
                        valueArguments.dueDate              = deposit.Date_AR__c;
                        valueArguments.issueDate            = deposit.Date_AR__c;
                        //valueArguments.dueDate              = myDate.addHours(12); //Para que en GMT-3 aparezca a las 00 en vez de las 21 del dia anterior
                        //valueArguments.issueDate            = myDate.addHours(12);
                        valueArguments.receiptNo            = deposit.ReceiptNo_AR__r.Name;
                        valueArguments.depositBankSlipNo    = deposit.Name;
                        valueArguments.depositBranch        = deposit.Branch_AR__c;
                        valueArguments.depositBank          = deposit.Bank_AR__c;
                        valueArguments.bank                 = deposit.Bank_AR__c;
                        valueArguments.depositAccountType   = receipt.LAT_AR_DepositAccountType__c;
                        valueArguments.amount               = deposit.Amount_AR__c;
                        valueArguments.idCRMval             = deposit.Id;
                        valueArguments.valueType            = deposit.Bank_AR__c + '-5'; 
                        receiptArguments.listValues.value.add(valueArguments);
                        i++; 
                    }
                }          
            }
        }

        if(!listTaxCert.isEmpty()){         
            LAT_ReceiptHandelerTypes.ValueType taxCertArguments;
            for(TXC_TaxCertificates_ARG__c taxCert: listTaxCert){               
                taxCertArguments = new  LAT_ReceiptHandelerTypes.ValueType();
                //se completan los campos de Retenciones
                //Datetime myDate = taxCert.Date_AR__c;
                taxCertArguments.chequeNo           = taxCert.Name;
                taxCertArguments.amount             = taxCert.Amount_AR__c;
                taxCertArguments.comment            = taxCert.Comment_AR__c;
                taxCertArguments.dueDate            = taxCert.Date_AR__c;
                taxCertArguments.issueDate          = taxCert.Date_AR__c;
                //taxCertArguments.dueDate            = myDate.addHours(12); //Para que en GMT-3 aparezca a las 00 en vez de las 21 del dia anterior
                //taxCertArguments.issueDate          = myDate.addHours(12); 
                taxCertArguments.receiptNo          = taxCert.ReceiptNo_AR__r.Name;
                taxCertArguments.valueType          = taxCert.ValueType_AR__c + '-6'; 
                taxCertArguments.idCRMval           = taxCert.Id;
                taxCertArguments.taxCode	        = taxCert.ValueType_AR__c;
                taxCertArguments.bank               = taxCert.ValueType_AR__c;
                taxCertArguments.depositBank        = taxCert.ValueType_AR__c;
                taxCertArguments.depositAccountType = receipt.LAT_AR_DepositAccountType__c;
                
                receiptArguments.listValues.value.add(taxCertArguments); 
            }
        } 


        
       

        receiptArguments.listDocuments = new LAT_ReceiptHandelerTypes.listDocuments_element(); 
        receiptArguments.listDocuments.document= new List<LAT_ReceiptHandelerTypes.DocumentType>();
        
        if(!listDocs.isEmpty()){         
            LAT_ReceiptHandelerTypes.DocumentType documentArguments;
            for(DCM_Documents_ARG__c document: listDocs){               
                documentArguments = new LAT_ReceiptHandelerTypes.DocumentType();
                //se completan los campos de Documentos
                String[] auxInternalId = document.Internal_id_pk_AR__c.split('-');
                System.debug('$$$$$$ auxInternalId[] : '+auxInternalId);
                
                if(auxInternalId[5].length() ==1){
                    auxInternalId[5] = '00'+auxInternalId[5];
                }else {
                	auxInternalId[5] = '0'+auxInternalId[5];            
                }
                documentArguments.legalInvoice     = document.LegalInvoice_AR__c;
                documentArguments.receiptNo        = document.ReceiptNo_AR__r.Name;
                documentArguments.idCRMval         = document.Id; //Se cambia para poner el ID del recibo según solicitud de Marcin 26/3/18
                documentArguments.docCo            = '00'+auxInternalId[2];// EJ: 00100
                documentArguments.docType          = document.tipoDocumento_AR__c;
                documentArguments.docNo            = document.Name;
                documentArguments.paymentItem      = auxInternalId[5];// Ej: '001'|| antes --> string.valueOf(document.PaymentID_AR__c);
                documentArguments.docAmountApply   = string.valueOf(document.Amounttoapply_AR__c);
                documentArguments.docExplanation   = document.observacoesTitulo_AR__c;

                //Si es un Documento tipo RU no lo envio a JDE, a pedido de Martin Deniard.
                if (document.tipoDocumento_AR__c != 'RU') {
                    receiptArguments.listDocuments.document.add(documentArguments);
                } 
            }
        }
        
        receiptArguments.InvoiceList = new LAT_ReceiptHandelerTypes.invoiceList_element ();
        receiptArguments.InvoiceList.invoiceDetail = new List<LAT_ReceiptHandelerTypes.InvoiceDetailType>();
         
        for (LAT_Invoice__c inv : ListLAT_Invoice) {
            System.debug('%%%%%% entramos en la lista de invoices');
            if (inv.LAT_InvoiceAmount__c != null ) {
                if (Decimal.valueOf(inv.LAT_InvoiceAmount__c) != 0) {
                    System.debug('%%%%%% hay un invoice que no es null ni 0 : '+inv);
                    LAT_ReceiptHandelerTypes.InvoiceDetailType invDP = new LAT_ReceiptHandelerTypes.InvoiceDetailType();
                    invDP.invoiceAmount             = inv.LAT_InvoiceAmount__c;
                    invDP.invoiceTaxableAmount      = inv.LAT_InvoiceTaxableAmount__c; 
                    invDP.invoiceTaxAmount          = inv.LAT_InvoiceTaxAmount__c;
                    invDP.invoiceType               = inv.LAT_InvoiceType__c;
                    invDP.idCRMdoc                  = inv.LAT_IdCrmDoc__c;
                    invDP.idCRMval                  = inv.Id;
                    invDP.invoiceExplanation        = inv.LAT_InvoiceExplanation__c;

                    receiptArguments.InvoiceList.invoiceDetail.add(invDP);

                }
            }
        }

        /*
        if (receipt.Downpayments_AR__c != null && receipt.Downpayments_AR__c != 0){
            LAT_Invoice__c aux = new LAT_Invoice__c();
            if (mapLAT_Invoice.get('AT') != null) {
                aux = mapLAT_Invoice.get('AT');
            }
            aux.LAT_InvoiceAmount__c        = String.valueOf(receipt.Downpayments_AR__c*(-1));
            aux.LAT_InvoiceTaxableAmount__c = aux.LAT_InvoiceAmount__c;
            aux.LAT_InvoiceTaxAmount__c     = '0';
            aux.LAT_InvoiceType__c          = 'AT';
            aux.LAT_IdCrmDoc__c             = receipt.Name + 'AT';
            aux.LAT_InvoiceExplanation__c   = 'Anticipo de Clientes';
            aux.LAT_Receipt__c              = receipt.Id;
            upsert aux;

            LAT_ReceiptHandelerTypes.InvoiceDetailType invDP = new LAT_ReceiptHandelerTypes.InvoiceDetailType();
            invDP.invoiceAmount             = aux.LAT_InvoiceAmount__c;
            invDP.invoiceTaxableAmount      = aux.LAT_InvoiceTaxableAmount__c; 
            invDP.invoiceTaxAmount          = aux.LAT_InvoiceTaxAmount__c;
            invDP.invoiceType               = aux.LAT_InvoiceType__c;
            invDP.idCRMdoc                  = aux.LAT_IdCrmDoc__c;
            invDP.idCRMval                  = aux.Id;
            invDP.invoiceExplanation        = aux.LAT_InvoiceExplanation__c;

            receiptArguments.InvoiceList.invoiceDetail.add(invDP);
        }
       

        if (receipt.Discount_AR__c != null && receipt.Discount_AR__c != 0){
            LAT_Invoice__c aux = new LAT_Invoice__c();
            if (mapLAT_Invoice.get('DF') != null) {
                aux = mapLAT_Invoice.get('DF');
            }
            aux.LAT_InvoiceAmount__c        = String.valueOf(receipt.Discount_AR__c*(-1));
            Double dblDiscount              = receipt.Discount_AR__c / 1.21*(-1);
            aux.LAT_InvoiceTaxableAmount__c = String.valueOf(Decimal.valueOf(dblDiscount).setScale(2));
            Decimal decTaxAmount            = (Decimal.valueOf(aux.LAT_InvoiceAmount__c) - Decimal.valueOf(aux.LAT_InvoiceTaxableAmount__c)).setScale(2);
            aux.LAT_InvoiceTaxAmount__c     = String.valueOf(decTaxAmount);
            aux.LAT_InvoiceType__c          = 'DF';
            aux.LAT_IdCrmDoc__c             = receipt.Name + 'DF';
            aux.LAT_InvoiceExplanation__c   = 'Dto. Pronto Pago Rec. ' + receipt.Name;
            aux.LAT_Receipt__c              = receipt.Id;
            upsert aux;

            LAT_ReceiptHandelerTypes.InvoiceDetailType invDP = new LAT_ReceiptHandelerTypes.InvoiceDetailType();
            invDP.invoiceAmount             = aux.LAT_InvoiceAmount__c;
            invDP.invoiceTaxableAmount      = aux.LAT_InvoiceTaxableAmount__c;
            invDP.invoiceTaxAmount          = aux.LAT_InvoiceTaxAmount__c;
            invDP.invoiceType               = aux.LAT_InvoiceType__c;
            invDP.idCRMdoc                  = aux.LAT_IdCrmDoc__c;
            invDP.idCRMval                  = aux.Id;
            invDP.invoiceExplanation        = aux.LAT_InvoiceExplanation__c;
            receiptArguments.InvoiceList.invoiceDetail.add(invDP);
        }
        
        if (receipt.Comercial_Discount__c != null && receipt.Comercial_Discount__c != 0){
            LAT_Invoice__c aux = new LAT_Invoice__c();
            if (mapLAT_Invoice.get('DC') != null) {
                aux = mapLAT_Invoice.get('DC');
            }
            aux.LAT_InvoiceAmount__c        = String.valueOf(receipt.Comercial_Discount__c*(-1));
            Double dblDiscount              = receipt.Comercial_Discount__c / 1.21*(-1);
            aux.LAT_InvoiceTaxableAmount__c = String.valueOf(Decimal.valueOf(dblDiscount).setScale(2));
            Decimal decTaxAmount            = (Decimal.valueOf(aux.LAT_InvoiceAmount__c) - Decimal.valueOf(aux.LAT_InvoiceTaxableAmount__c)).setScale(2);
            aux.LAT_InvoiceTaxAmount__c     = String.valueOf(decTaxAmount);
            aux.LAT_InvoiceType__c          = 'DC';
            aux.LAT_IdCrmDoc__c             = receipt.Name + 'DC';
            aux.LAT_InvoiceExplanation__c   = 'Dto. Pronto Pago Rec. ' + receipt.Name;
            aux.LAT_Receipt__c              = receipt.Id;
            upsert aux;

            LAT_ReceiptHandelerTypes.InvoiceDetailType invDP = new LAT_ReceiptHandelerTypes.InvoiceDetailType();
            invDP.invoiceAmount             = aux.LAT_InvoiceAmount__c;
            invDP.invoiceTaxableAmount      = aux.LAT_InvoiceTaxableAmount__c;
            invDP.invoiceTaxAmount          = aux.LAT_InvoiceTaxAmount__c;
            invDP.invoiceType               = aux.LAT_InvoiceType__c;
            invDP.idCRMdoc                  = aux.LAT_IdCrmDoc__c;
            invDP.idCRMval                  = aux.Id;    
            invDP.invoiceExplanation        = aux.LAT_InvoiceExplanation__c;
            receiptArguments.InvoiceList.invoiceDetail.add(invDP);
        }        
        */
        
        if(!ListInvoice.isEmpty()){
            LAT_ReceiptHandelerTypes.InvoiceDetailType inv;

            Integer j =1;
            for(DBT_Debit_ARG__c RelatedInv : ListInvoice) {
                inv = new LAT_ReceiptHandelerTypes.InvoiceDetailType();
                Inv.idCRMdoc = receipt.Name + 'DD-'+j;
                Inv.idCRMval     = RelatedInv.Id;
                j++; 
                Inv.invoiceType = 'DD';
                Inv.invoiceNumber = string.valueOf(RelatedInv.DebitNo_AR__c);
                Inv.invoiceAmount = string.valueOf(RelatedInv.DebitAmount_AR__c);
                Inv.invoiceTaxableAmount = Inv.invoiceAmount;
                Inv.invoiceTaxAmount = '0';
                Inv.invoiceExplanation = RelatedInv.Name;
                
                receiptArguments.InvoiceList.invoiceDetail.add(inv);
            }
        }
        
        system.debug('aaaa ' + receiptArguments);
        return receiptArguments;        
    }
    
    private static void withError(RCP_Receipt_ARG__c receipt, String error){       
        receipt = receiptBackUp;
        receipt.LAT_AR_IntegrationStatus__c = 'Error in JDE';
        update receipt;       
    }
    
    private static LAT_ReceiptHandelerTypes.ClientInfoType getConnectionParameter(){
        
        TimeZone tz = UserInfo.getTimeZone();
        DateTime localTime = Datetime.now().AddSeconds(tz.getOffset(Datetime.now())/1000);
        System.debug('hora convertida: ' + localTime);
    
        LAT_ReceiptHandelerTypes.ClientInfoType connParms = new LAT_ReceiptHandelerTypes.ClientInfoType();
        CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance('Argentina');
        if(cred != null){
            connParms.country = cred.Country__c;
            connParms.remoteHostIP = cred.RemoteHostIP__c;
            connParms.system_x = cred.System__c;
            connParms.systemUserID = cred.SystemUserID__c;
            connParms.time_x = localTime;
        }
        return connParms;
        
    }

    public static String getDateStringFormated(Date fecha) {
        String retorno = String.valueOf(fecha);
        String[] aux = retorno.split('-');
        retorno = aux[2]+aux[1]+aux[0];
        return retorno;
    }
    
    
}