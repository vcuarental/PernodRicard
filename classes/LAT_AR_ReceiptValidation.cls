global with sharing class LAT_AR_ReceiptValidation {


webservice static String  ValidarRecibosRendidos() {
        List<RCP_Receipt_ARG__c> toValidate = [SELECT Id, Account_AR__c, LAT_ValidationStatus__c, Validation_Error_Message__c, Discount_AR__c, Comercial_Discount__c, LAT_AR_DepositAccountType__c,
                                                (SELECT Id, Name, Amount_AR__c FROM Deposits__r),
                                                (SELECT Id, PaymentID_AR__c, Amounttoapply_AR__c, TipoDocumento_AR__c FROM Documents__r WHERE TipoDocumento_AR__c = 'RU')
                                                FROM RCP_Receipt_ARG__c WHERE LAT_ValidationStatus__c != 'Validado' AND LAT_ValidationStatus__c != 'Validado CC' 
                                                AND LAT_ValidationStatus__c != 'Validado Ret' AND LAT_ValidationStatus__c != 'Cancelado' /*and id='a848E000000CrwY'*/ ORDER BY LastModifieddate DESC LIMIT 50];
        Set<Id> accountIds = new Set<Id>();
        Set<Id> receiptIds = new Set<Id>();
        for (RCP_Receipt_ARG__c rec : toValidate) {
            accountIds.add(rec.Account_AR__c);
            receiptIds.add(rec.Id);
        }
        Map<Id, DPT_Deposit_ARG__c> mapDepositsById = new Map<Id, DPT_Deposit_ARG__c>([SELECT Id, Name, Amount_AR__c, (SELECT Id FROM LAT_RU_Deposits__r) FROM DPT_Deposit_ARG__c WHERE ReceiptNo_AR__c IN: receiptIds]);

        List<Titulos__c> titulos = [SELECT Id, Cliente__c, PaymentID_AR__c, NetOpenBalance_AR__c, NetSRReceipts_AR__c, Internal_id_pk__c  FROM Titulos__c WHERE TipoDocumento__c = 'RU' AND Cliente__c IN :accountIds];
        Map<Id, List<Titulos__c>> mapTitulosByAccount = new Map<Id, List<Titulos__c>>();
        List<LAT_RUDeposit__c> toInsert = new List<LAT_RUDeposit__c>();
        List<Titulos__c>       titulosToUpdate = new List<Titulos__c>();
        for (Titulos__c t: titulos) {
            if(mapTitulosByAccount.get(t.Cliente__c) == null) {
                mapTitulosByAccount.put(t.Cliente__c, new List<Titulos__c>{t});
            } else {
                mapTitulosByAccount.get(t.Cliente__c).add(t);
            }
        }
        System.debug('%%%%%%% entramos en el LAT_AR_RestBTN01_RCPRedeemedBtn con toValidate.size() : '+toValidate.size());
        //List<RCP_Receipt_ARG__c> toUpdate = new List<RCP_Receipt_ARG__c>();
        for (RCP_Receipt_ARG__c recibo : toValidate) {
            if (recibo.LAT_AR_DepositAccountType__c == 'C') {
                System.debug('%%%%%%%%%%% estamos en C '+ recibo.id);
                recibo.LAT_ValidationStatus__c = 'Validado CC';
                recibo.Validation_Error_Message__c = '';
            } else {
                if (recibo.LAT_AR_DepositAccountType__c == 'T') {
                    System.debug('%%%%%%%%%%% estamos en T '+ recibo.id);
                    recibo.LAT_ValidationStatus__c = 'Validado Ret';
                    recibo.Validation_Error_Message__c = '';
                } else {
                    System.debug('%%%%%%%%%%% estamos en else '+ recibo.id);
                    recibo.LAT_ValidationStatus__c = 'Validado';
                    recibo.Validation_Error_Message__c = '';
                    for (DPT_Deposit_ARG__c deposito : recibo.Deposits__r) {
                        String idDeposito = deposito.Name;
                        Decimal totalDeposito = deposito.Amount_AR__c;
                        Decimal totalDocumentos = 0;
                        System.debug('%%%%%%%%%%% mapTitulosByAccount: '+ mapTitulosByAccount);
                        if(mapTitulosByAccount.get(recibo.Account_AR__c) != null) {
                            for (Titulos__c t : mapTitulosByAccount.get(recibo.Account_AR__c)) {
                                System.debug('%%%%%%%%%%% t.PaymentID_AR__c: '+ t.PaymentID_AR__c +' || Decimal.valueOf(idDeposito):'+ Decimal.valueOf(idDeposito) + ' || true?' + (String.valueOf(t.PaymentID_AR__c) == idDeposito));
                                if (t.PaymentID_AR__c == Decimal.valueOf(idDeposito)) {
                                    System.debug('%%%%%%%%%%% t.NetOpenBalance_AR__c : ' + t.NetOpenBalance_AR__c);
                                    System.debug('%%%%%%%%%%% t.NetSRReceipts_AR__c : ' + t.NetSRReceipts_AR__c);
                                    if(t.NetSRReceipts_AR__c != null) {
                                        if(t.NetSRReceipts_AR__c != 0) {
                                            totalDocumentos = totalDocumentos + t.NetSRReceipts_AR__c;
                                        } else {
                                            totalDocumentos = totalDocumentos + t.NetOpenBalance_AR__c;
                                        }  
                                    } else {
                                        totalDocumentos = totalDocumentos + t.NetOpenBalance_AR__c;
                                    }
                                    
                                }
                            }
                            System.debug('%%%%%%%%%%% totalDeposito : ' + totalDeposito);
                            System.debug('%%%%%%%%%%% totalDocumentos : ' + totalDocumentos);
                            System.debug('%%%%%%%%%%% totalDeposito.setScale(2) : ' + totalDeposito.setScale(2));
                            System.debug('%%%%%%%%%%% totalDocumentos.setScale(2) : ' + totalDocumentos.setScale(2));
                            if (totalDeposito.setScale(2) != totalDocumentos.setScale(2) *(-1)) {
                                recibo.LAT_ValidationStatus__c = 'Error en Validacion';
                                recibo.Validation_Error_Message__c = 'El Deposito '+ idDeposito+ ' no tiene documentos que lo cubran completamente.';
                            }
                        } else {
                            recibo.LAT_ValidationStatus__c = 'Error en Validacion';
                            recibo.Validation_Error_Message__c = 'El Deposito '+ idDeposito+ ' no tiene documentos que lo cubran completamente.';
                        }
                        
                    }
                    if(recibo.LAT_ValidationStatus__c == 'Validado') {
                        setRUDeposits(recibo, mapTitulosByAccount, mapDepositsById, titulosToUpdate, toInsert);
                    }
                }
            }
        }
        if(toInsert.size() >0) {
            insert toInsert;
        }
        if(titulosToUpdate.size() >0) {
            update titulosToUpdate;
        }
        System.debug('%%%%%%% salimos en el LAT_AR_RestBTN01_RCPRedeemedBtn con toValidate : '+toValidate);
        update toValidate;
        return 'Termino';    

    }

    public static void setRUDeposits(RCP_Receipt_ARG__c recibo, Map<Id, List<Titulos__c>> mapTitulosByAccount, Map<Id, DPT_Deposit_ARG__c> mapDepositsById, List<Titulos__c> titulosToUpdate, List<LAT_RUDeposit__c> toInsert) {
        for(DPT_Deposit_ARG__c deposito : recibo.Deposits__r) {
            System.debug('%%%%%% entramos[] : ');
            System.debug('%%%%%% mapDepositsById.get(deposito.Id).LAT_RU_Deposits__r : ' + mapDepositsById.get(deposito.Id).LAT_RU_Deposits__r);
            if(mapDepositsById.get(deposito.Id).LAT_RU_Deposits__r.size() == 0) {
                String idDeposito = deposito.Name;
                for(Titulos__c tit : mapTitulosByAccount.get(recibo.Account_AR__c)) {
                    System.debug('%%%%%%  tit : '+ tit);
                    System.debug('%%%%%%  tit.PaymentID_AR__c : '+ tit.PaymentID_AR__c +' || Decimal.valueOf(idDeposito) :' + Decimal.valueOf(idDeposito));
                    if(tit.PaymentID_AR__c == Decimal.valueOf(idDeposito)) {
                        String[] auxInternalId   = tit.Internal_id_pk__c.split('-');
                        System.debug('$$$$$$ auxInternalId[] : '+auxInternalId);
                        LAT_RUDeposit__c nuevo = new LAT_RUDeposit__c();
                        nuevo.LAT_Deposit__c    = deposito.Id;
                        if(!Test.isRunningTest()){
                            if (tit.NetOpenBalance_AR__c == 0) {
                                nuevo.Amount_AR__c      = tit.NetSRReceipts_AR__c * (-1);
                            } else {
                                nuevo.Amount_AR__c      = tit.NetOpenBalance_AR__c * (-1);
                                tit.NetSRReceipts_AR__c    = tit.NetOpenBalance_AR__c;
                            }
                        }
                        
                        nuevo.Company__c        = '00'+auxInternalId[2];
                        nuevo.DocumentNumber__c = auxInternalId[4];
                        nuevo.BankSlipNumber__c = deposito.Name;
                        toInsert.add(nuevo);

                        tit.Ruinusebypendingreceipt_AR__c    = recibo.Id;
                        titulosToUpdate.add(tit);
                    }
                }
            }
        }

    }
}