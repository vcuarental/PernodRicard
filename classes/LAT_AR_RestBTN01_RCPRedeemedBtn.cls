@RestResource(urlMapping='/LAT_AR_RestBTN01_RCPRedeemedBtn/*')
global with sharing class LAT_AR_RestBTN01_RCPRedeemedBtn {
	@HttpPost
	global static void post(String[] idReceipt) {
        System.debug('%%%%%%% entramos en el LAT_AR_RestBTN01_RCPRedeemedBtn con idReceipt : '+idReceipt);
		String retorno = BTN01_RCPRedeemedBtnController_AR.rcpButton(idReceipt);
        Boolean success = retorno.contains('Se ha generado con éxito');
        String strSuccess = 'false';
        if (success) strSuccess = 'true';
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf('{ "id" : "'+idReceipt+'", "success": "'+strSuccess+'", "message": "'+retorno+'"  }');
		
	}
    @HttpGet
    global static String  ValidarRecibosRendidos() {
        List<RCP_Receipt_ARG__c> toValidate = [SELECT Id, LAT_ValidationStatus__c, Validation_Error_Message__c, Discount_AR__c, Comercial_Discount__c, LAT_AR_DepositAccountType__c,
                                                (SELECT Id, Name, Amount_AR__c FROM Deposits__r),
                                                (SELECT Id, PaymentID_AR__c, Amounttoapply_AR__c, TipoDocumento_AR__c FROM Documents__r WHERE TipoDocumento_AR__c = 'RU')
                                                FROM RCP_Receipt_ARG__c WHERE LAT_ValidationStatus__c != 'Validado' AND LAT_ValidationStatus__c != 'Validado CC' 
                                                AND LAT_ValidationStatus__c != 'Validado Ret' ORDER BY LastModifieddate DESC LIMIT 100];
        System.debug('%%%%%%% entramos en el LAT_AR_RestBTN01_RCPRedeemedBtn con toValidate.size() : '+toValidate.size());
        //List<RCP_Receipt_ARG__c> toUpdate = new List<RCP_Receipt_ARG__c>();
        for (RCP_Receipt_ARG__c recibo : toValidate) {

            if (recibo.LAT_AR_DepositAccountType__c == 'C') {
                recibo.LAT_ValidationStatus__c = 'Validado CC';
                recibo.Validation_Error_Message__c = '';
            } else {
                if (recibo.LAT_AR_DepositAccountType__c == 'T') {
                    System.debug('%%%%%%%%%%% estamos en T '+ recibo.id);
                    recibo.LAT_ValidationStatus__c = 'Validado Ret';
                    recibo.Validation_Error_Message__c = '';
                } else {
                    recibo.LAT_ValidationStatus__c = 'Validado';
                    recibo.Validation_Error_Message__c = '';
                    for (DPT_Deposit_ARG__c deposito : recibo.Deposits__r) {
                        String idDeposito = deposito.Name;
                        Decimal totalDeposito = deposito.Amount_AR__c;
                        Decimal totalDocumentos = 0;
                        for (DCM_Documents_ARG__c documento : recibo.Documents__r) {
                            if (documento.PaymentID_AR__c == Decimal.valueOf(idDeposito)) {
                                totalDocumentos = totalDocumentos + documento.Amounttoapply_AR__c;
                            }
                        }
                        if (totalDeposito != totalDocumentos *(-1)) {
                            recibo.LAT_ValidationStatus__c = 'Error en Validacion';
                            recibo.Validation_Error_Message__c = 'El Deposito '+ idDeposito+ ' no tiene documentos que lo cubran completamente.';
                        }
                    }
                }
            }
        }
        System.debug('%%%%%%% salimos en el LAT_AR_RestBTN01_RCPRedeemedBtn con toValidate : '+toValidate);
        update toValidate;
        return 'Termino';    

    }

}