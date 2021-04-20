/**********************************************************************************************************************************
*   Company:Valuenet    Developers:   Elena J. Schwarzböck                                                                        *
*   Date:13/05/2014     Descripcion:  Metodo que valida la cancelacion de recibos. Si esta todo ok cancela el recibo              *
*                                     y actualiza los documentos hijos.                                                           *  
***********************************************************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/
global without sharing class LAT_AR_BTN02_ValidatesCancelReceipts{
   
    webService static String ValidatesCancelReceipt(String IdRec){
    
        RCP_Receipt_ARG__c recibo = [SELECT Id,ValuesAmount_AR__c, Status_AR__c,WithholdingsAmount_AR__c, Account_AR__r.Owner.Email, Name, Account_AR__r.OwnerId, RecordTypeId FROM RCP_Receipt_ARG__c WHERE Id =: IdRec];
        
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Developername = 'LAT_AR_ReceiptsRejectedTreasury'];
        
        List<DCM_Documents_ARG__c> listDocs = new List<DCM_Documents_ARG__c>();
        List<Titulos__c> listTitulos = new List<Titulos__c>();
        
        if(recibo.Status_AR__c == 'Receipt cancelled'){
            return label.LAT_AR_BTN02_00001;
            //LAT_AR_BTN02_00001: Recibo ya cancelado.
        }
                       
        if(userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('AR_Vendedor') || userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('LAT_AR2_Vendedor') 
            || userInfo.getProfileId() == LAT_GlobalProfileCache.getStandardAdminProfileId() ||
             userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('AR_System Administrator') || userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator') 
             || userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('LAT_BusinessAdministrator')){
            if((recibo.Status_AR__c == 'Receipt Sent to Treasury' || recibo.Status_AR__c == 'Receipt Verified') && userInfo.getProfileId() != LAT_GlobalProfileCache.getStandardAdminProfileId() && userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('AR_System Administrator')){
                return label.LAT_AR_BTN02_00002;
                //LAT_AR_BTN02_00002: Este Recibo no puede ser anulado pues ya está con la área de Tesorería.
            }else{
                recibo.Status_AR__c = 'Receipt cancelled';
                recibo.RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'LAT_AR_RCP_ReceiptCancelled');
                listDocs = [SELECT Id, Amounttoapply_AR__c, Internal_id_pk_AR__c FROM DCM_Documents_ARG__c WHERE ReceiptNo_AR__c =: recibo.Id];
                Set<String> setInternalIdPk = new Set<String>();
                for(DCM_Documents_ARG__c doc: listDocs ){
                    doc.Amounttoapply_AR__c = 0;
                    setInternalIdPk.add(doc.Internal_id_pk_AR__c);
                }
                if(!setInternalIdPk.isEmpty()){
                    listTitulos = [SELECT Id, Internal_id_pk__c, Ruinusebypendingreceipt_AR__c FROM Titulos__c WHERE Ruinusebypendingreceipt_AR__c != NULL];
                    if(!listTitulos.isEmpty()){
                        for(Titulos__c titulo: listTitulos){
                            titulo.Ruinusebypendingreceipt_AR__c = null;
                        }
                    }
                }
                try{
                    update recibo;
                    if(!listDocs.isEmpty()){
                        update listDocs;
                    }
                    if(!listTitulos.isEmpty()){
                        update listTitulos;
                    }
                }catch(DMLException e){
                    return 'Error: ' + e.getMessage();
                }

            }        
        }else if(userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('ARG_Tesorería') || userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('LAT_AR2_Tesoreria') ){
            if(recibo.Status_AR__c == 'Receipt Verified'){
                return label.LAT_AR_BTN02_00003;
                //LAT_AR_BTN02_00003: Este Recibo no puede ser anulado pues ya está Verificado.
            }else{
                if(recibo.WithholdingsAmount_AR__c != 0){
                    recibo.LAT_AR_SendMail__c = true;
                    recibo.Status_AR__c = 'Receipt withholding certificates';
                    recibo.RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'Receipt_withholding_certificates_AR');
                }else if (recibo.ValuesAmount_AR__c != 0){
                    recibo.LAT_AR_SendMail__c = true;
                    recibo.Status_AR__c = 'Receipt Value with Guarantee';
                    recibo.RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'LAT_AR_RCP_ReceiptValueGuarantee');
                }else{
                    recibo.LAT_AR_SendMail__c = true;
                    recibo.Status_AR__c = 'Receipt Issued Deposit done';
                    recibo.RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR');

                }

                try{
                    update recibo;
                    return label.LAT_AR_BTN02_00004;
                    //LAT_AR_BTN02_00004: Se envió un mail al dueño del cliente.
                }catch(DMLException e){
                    return 'Error: ' + e.getMessage();
                } 
            }        
        }else{
            return label.LAT_AR_BTN02_00005;
            //LAT_AR_BTN02_00005: Solo usuarios con perfil AR_Vendedor, ARG_Tesorería o administradores puede realizar esta operacion.
        }   
        return null;
    }

    webService static String ValidatesCancelReceipts(List<Id> idsReceipts){
    
        List<RCP_Receipt_ARG__c> listRecibos = [SELECT Id,ValuesAmount_AR__c,WithholdingsAmount_AR__c, Status_AR__c, Account_AR__r.Owner.Email, Account_AR__r.OwnerId, Name, RecordTypeId FROM RCP_Receipt_ARG__c WHERE Id =: idsReceipts];
        
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Developername = 'LAT_AR_ReceiptsRejectedTreasury'];
        
        List<DCM_Documents_ARG__c> listDocs = new List<DCM_Documents_ARG__c>();
        List<Titulos__c> listTitulos = new List<Titulos__c>();
        
        String receiptsTreasury = '';
        String receiptsAlreadyVerified = '';
        String recieptsAlreadyCancelled = '';
        Boolean isVendedor = false;
        Boolean isTreasury = false;
        Boolean isAdmin = false;
        Boolean isMailSend = false;
        List<RCP_Receipt_ARG__c> listReceiptsMail = new List<RCP_Receipt_ARG__c>();
        Set<Id> setIdReceiptsToCancell = new Set<Id>();
        List<RCP_Receipt_ARG__c> listReceiptsUpdate = new List<RCP_Receipt_ARG__c>();
        if(userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('AR_Vendedor')||userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('LAT_AR2_Vendedor')){
            isVendedor = true;
        }else if(userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('ARG_Tesorería')|| userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('LAT_AR2_Tesoreria')){
            isTreasury = true;
        }else if(userInfo.getProfileId() == LAT_GlobalProfileCache.getStandardAdminProfileId() || userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('AR_System Administrator')|| userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator')
            || userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('LAT_BusinessAdministrator')){
            isAdmin = true;
        }else{
            return label.LAT_AR_BTN02_00005;
            //LAT_AR_BTN02_00005: Solo usuarios con perfil AR_Vendedor, ARG_Tesorería o administradores puede realizar esta operacion.
        }
        
        for(RCP_Receipt_ARG__c receipt: listRecibos){
            if(receipt.Status_AR__c == 'Receipt cancelled'){
                if(recieptsAlreadyCancelled == ''){
                    recieptsAlreadyCancelled += receipt.Name;
                }else{
                    recieptsAlreadyCancelled += ', ' + receipt.Name;
                }
            }
            if(receipt.RecordTypeId == Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_UY') ||
                receipt.RecordTypeId == Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositPending_UY') ||
                receipt.RecordTypeId == Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptPrintedDepositDone_UY') ||
                receipt.RecordTypeId == Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptPrintedDepositPending_UY')){
                    return label.LAT_AR_BTN02_00009;
                    //LAT_AR_BTN02_00009: Solo se pueden anular recibos AR.    
            }
                        
            if((isVendedor || isAdmin)){
                if((receipt.Status_AR__c == 'Receipt Sent to Treasury' || receipt.Status_AR__c == 'Receipt Verified') && !isAdmin){
                    if(receiptsTreasury == ''){
                        receiptsTreasury += receipt.Name;
                    }else{
                        receiptsTreasury += ', ' + receipt.Name;
                    }
                }else{
                    receipt.Status_AR__c = 'Receipt cancelled';
                    receipt.RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'LAT_AR_RCP_ReceiptCancelled');
                    listReceiptsUpdate.add(receipt);
                    setIdReceiptsToCancell.add(receipt.Id);
                }
            }
            if(isTreasury){
                if(receipt.Status_AR__c == 'Receipt Verified'){
                    if(receiptsAlreadyVerified == ''){
                        receiptsAlreadyVerified += receipt.Name;
                    }else{
                        receiptsAlreadyVerified += ', ' + receipt.Name;
                    }
                }else{
                    listReceiptsMail.add(receipt);                    
                    isMailSend = true;     
                }        
            }
        }
        if(recieptsAlreadyCancelled != ''){
            return label.LAT_AR_BTN02_00006 + ' ' + recieptsAlreadyCancelled;
            //LAT_AR_BTN02_00006: No se puede realizar la operacion debido a que los siguientes recibos ya estan cancelados:        
        }
        if(receiptsTreasury != ''){
            return label.LAT_AR_BTN02_00007 + ' ' + receiptsTreasury;
            //LAT_AR_BTN02_00007: No se puede realizar la operacion debido a que los siguientes recibos ya estan con la área de Tesorería:
        }
        if(receiptsAlreadyVerified != ''){
            return label.LAT_AR_BTN02_00008 + ' ' + receiptsAlreadyVerified;
            //LAT_AR_BTN02_00008: No se puede realizar la operacion debido a que los siguientes recibos ya estan Verificados:
        }
        if(isMailSend){
            for(RCP_Receipt_ARG__c receipt: listReceiptsMail){
                if(receipt.WithholdingsAmount_AR__c != 0){
                    receipt.LAT_AR_SendMail__c = true;
                    receipt.Status_AR__c = 'Receipt withholding certificates';
                    receipt.RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'Receipt_withholding_certificates_AR');
                }else if (receipt.ValuesAmount_AR__c != 0){
                    receipt.LAT_AR_SendMail__c = true;
                    receipt.Status_AR__c = 'Receipt Value with Guarantee';
                    receipt.RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'LAT_AR_RCP_ReceiptValueGuarantee');
                }else{
                    receipt.LAT_AR_SendMail__c = true;
                    receipt.Status_AR__c = 'Receipt Issued Deposit done';
                    receipt.RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR');
                }
            }
            try{
                update listReceiptsMail;
                return label.LAT_AR_BTN02_00004;
                //LAT_AR_BTN02_00004: Se envió un mail al dueño del cliente.
            }catch(DMLException e){
                return 'Error: ' + e.getMessage();
            }         
        }
        
        if(!setIdReceiptsToCancell.isEmpty()){       
            listDocs = [SELECT Id, Amounttoapply_AR__c, Internal_id_pk_AR__c FROM DCM_Documents_ARG__c WHERE ReceiptNo_AR__c IN: setIdReceiptsToCancell];
            Set<String> setInternalIdPk = new Set<String>();
            for(DCM_Documents_ARG__c doc: listDocs ){
                doc.Amounttoapply_AR__c = 0;
                setInternalIdPk .add(doc.Internal_id_pk_AR__c);              
            }
            if(!setInternalIdPk.isEmpty()){
                listTitulos = [SELECT Id, Internal_id_pk__c, Ruinusebypendingreceipt_AR__c FROM Titulos__c WHERE Ruinusebypendingreceipt_AR__c != NULL];
                if(!listTitulos.isEmpty()){
                    for(Titulos__c titulo: listTitulos){
                        titulo.Ruinusebypendingreceipt_AR__c = null;
                    }
                }
            }
            try{
                if(!listReceiptsUpdate.isEmpty()){
                    update listReceiptsUpdate;
                }
                if(!listDocs.isEmpty()){
                    update listDocs;
                }
                if(!listTitulos.isEmpty()){
                    update listTitulos;
                }
            }catch(DMLException e){
                return 'Error: ' + e.getMessage();
            }
        }   
        return null;
    } 
}