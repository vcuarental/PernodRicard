/*******************************************************************************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del boton: RCP_PrintReceipt_AR
* Descripcion: valida los campos DepositsAmount_AR__c, AmountsControl_AR__c, ValuesAmount_AR__c y que todos los valores tengan un
*              deposito relacionado para permitir la impresion del recibo. si no hay error genera el pdf del recibo VFC02_PrintReceipt_AR.
* Fecha: 09/04/2013 
********************************************************************************************************************************/


global with sharing class BTN09_ValidUpdPrintReceipt_AR {
    
    webService static String ValidUpdPrintReceipt (Id IdRec) {
    
        map<Id, RecordType> mapIdRt = new map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='RCP_Receipt_ARG__c']);
        RecordType RecordTypeARDone = [SELECT Id FROM RecordType WHERE DeveloperName = 'RCP_ReceiptPrintedDepositDone_AR' AND SobjectType ='RCP_Receipt_ARG__c'];
        RecordType RecordTypeUYDone = [SELECT Id FROM RecordType WHERE DeveloperName = 'RCP_ReceiptPrintedDepositDone_UY' AND SobjectType ='RCP_Receipt_ARG__c'];
        RecordType RecordTypeARPend = [SELECT Id FROM RecordType WHERE DeveloperName = 'RCP_ReceiptPrintedDepositPending_AR' AND SobjectType ='RCP_Receipt_ARG__c'];
        RecordType RecordTypeUYPend = [SELECT Id FROM RecordType WHERE DeveloperName = 'RCP_ReceiptPrintedDepositPending_UY' AND SobjectType ='RCP_Receipt_ARG__c'];
        RecordType RecordTypeARGuarantee = [SELECT Id FROM RecordType WHERE DeveloperName = 'LAT_AR_RCP_ReceiptPrintedValueGuarantee' AND SobjectType ='RCP_Receipt_ARG__c'];

        
        RCP_Receipt_ARG__c receipt = [SELECT Id, AmountsControl_AR__c, DepositsAmount_AR__c, RecordtypeId, ValuesAmount_AR__c ,Name ,Account_AR__c, LAT_AR_DepositAccountType__c FROM RCP_Receipt_ARG__c WHERE Id =: IdRec];
        list<VLS_Values_ARG__c> listValues = [SELECT Id, Deposit_AR__c FROM VLS_Values_ARG__c WHERE ReceiptNo_AR__c =: IdRec];
        
        String Error = '';
        Boolean HayError = false;
        Boolean ErrorValues = false;
        
        if(mapIdRt.get(receipt.RecordtypeId).DeveloperName == 'RCP_ReceiptGeneratedDepositDone_AR' || mapIdRt.get(receipt.RecordtypeId).DeveloperName == 'RCP_ReceiptGeneratedDepositDone_UY'){
            if(receipt.AmountsControl_AR__c != 0){
                Error = label.BTN09_00004_AR + '\r\n';
                HayError = true;
            }
            if (receipt.DepositsAmount_AR__c == 0){
                Error = Error + label.BTN09_00002_AR + '\r\n';
                HayError = true;
            }                
            
            for (VLS_Values_ARG__c val: listValues){
                if (val.Deposit_AR__c == NULL) {
                    if(!ErrorValues){                
                        Error = Error + label.BTN09_00003_AR;
                        HayError = true;
                        ErrorValues = true;
                    }
                }        
            }
        }
        if(mapIdRt.get(receipt.RecordtypeId).DeveloperName == 'RCP_ReceiptGeneratedDepositPending_AR' || mapIdRt.get(receipt.RecordtypeId).DeveloperName == 'RCP_ReceiptGeneratedDepositPending_UY'){
            if(receipt.AmountsControl_AR__c != 0){
                Error = label.BTN09_00004_AR + '\r\n';
                HayError = true;
            }
            if (receipt.DepositsAmount_AR__c != 0){
                Error = Error + label.BTN09_00001_AR + '\r\n';
                HayError = true;
            }
        } 
        if(mapIdRt.get(receipt.RecordtypeId).DeveloperName == 'LAT_AR_RCP_ReceiptValueGuarantee'){
            if(receipt.AmountsControl_AR__c != 0){
                Error = label.BTN09_00004_AR + '\r\n';
                //BTN09_00004_AR: 'Amounts Control' must be 0 to allow the requested action. Review the amounts entered in the receipt.
                HayError = true;
            }
            if (receipt.DepositsAmount_AR__c != 0){
                Error = Error + label.BTN09_00001_AR + '\r\n';
                //BTN09_00001_AR: 'Deposit Amounts' must be 0 to allow the requested action. Review the amounts entered in the receipt.
                HayError = true;
            }
        }  
        if(mapIdRt.get(receipt.RecordtypeId).DeveloperName == 'Receipt_withholding_certificates_AR'){
            if(receipt.AmountsControl_AR__c != 0){
                Error = label.BTN09_00004_AR + '\r\n';
                HayError = true;
            }
            if (receipt.DepositsAmount_AR__c != 0){
                Error = Error + label.BTN09_00001_AR + '\r\n';
                HayError = true;
            }                
            
            if (receipt.ValuesAmount_AR__c != 0){
                Error = Error + label.BTN09_00005_AR;
                HayError = true;      
            }
        }

        if(mapIdRt.get(receipt.RecordtypeId).DeveloperName == 'LAT_AR_RCP_ReceiptOfApplyingDocuments'){
            if(receipt.AmountsControl_AR__c != 0){
                Error = label.BTN09_00004_AR + '\r\n';
                //BTN09_00004_AR: 'Amounts Control' must be 0 to allow the requested action. Review the amounts entered in the receipt.
                HayError = true;
            }        
        }

        // Changes required by Leoardo 29/6
        // Don't allow print if Values with ValueType = 3 AND Deposit.AccountType = C
        // Don't allow print if Values with ValueType = 4 AND Deposit.AccountType = R
        // Don't allow print if there are no deposits
        // C = Bank Account
        // R = Collection Bank Account
        List <DPT_Deposit_ARG__c> deposits = [SELECT Id, AccType_AR__c 
                                                FROM DPT_Deposit_ARG__c 
                                                WHERE ReceiptNo_AR__c =: receipt.Id];
        List <Id> depositsWC = new List <Id>();
        List <Id> depositsWR = new List <Id>();
        List <VLS_Values_ARG__c> valuesTypeThree = new List <VLS_Values_ARG__c> ();
        List <VLS_Values_ARG__c> valuesTypeFour = new List <VLS_Values_ARG__c> ();
        List <VLS_Values_ARG__c> valuesTypeFourWDeposits = new List <VLS_Values_ARG__c> ();

        if (!deposits.isEmpty()) {
            for (DPT_Deposit_ARG__c d : deposits) {
                if (d.AccType_AR__c == 'Bank Account') {
                    depositsWC.add(d.Id);
                } else if (d.AccType_AR__c == 'Collection Bank Account') {
                    depositsWR.add(d.Id);
                }
            }
            valuesTypeThree = [SELECT Id 
                                FROM VLS_Values_ARG__c 
                                WHERE ValueType_AR__c =: '3'
                                AND Deposit_AR__c IN :depositsWC];
            valuesTypeFour = [SELECT Id 
                                FROM VLS_Values_ARG__c 
                                WHERE ValueType_AR__c =: '4'
                                AND Deposit_AR__c IN :depositsWR];
            valuesTypeFourWDeposits = [SELECT Id 
                                        FROM VLS_Values_ARG__c 
                                        WHERE ValueType_AR__c =: '4'
                                        AND ReceiptNo_AR__c =: receipt.Id];                    
        }

        if (deposits.isEmpty() && !valuesTypeFourWDeposits.isEmpty()) {
            Error = Error + label.BTN09_00007_AR;
            HayError = true; 
        }
        if (!valuesTypeThree.isEmpty()) {
            Error = Error + label.BTN09_00007_AR;
            HayError = true; 
        }
        if (!valuesTypeFour.isEmpty()) {
            Error = Error + label.BTN09_00007_AR;
            HayError = true; 
        }


        if(HayError == false){
            if( mapIdRt.get(receipt.RecordtypeId).DeveloperName == 'RCP_ReceiptGeneratedDepositDone_AR' || mapIdRt.get(receipt.RecordtypeId).DeveloperName == 'Receipt_withholding_certificates_AR'){
                receipt.Status_AR__c = 'Receipt printed Deposit done';
                receipt.RecordTypeId = RecordTypeARDone.id;
            }else if( mapIdRt.get(receipt.RecordtypeId).DeveloperName == 'RCP_ReceiptGeneratedDepositDone_UY'){
                receipt.Status_AR__c = 'Receipt printed Deposit done';
                receipt.RecordTypeId = RecordTypeUYDone.id;
            } else if( mapIdRt.get(receipt.RecordtypeId).DeveloperName == 'RCP_ReceiptGeneratedDepositPending_AR'){
                receipt.Status_AR__c = 'Receipt printed Deposit pending'; 
                receipt.RecordTypeId = RecordTypeARPend.id;
            } else if( mapIdRt.get(receipt.RecordtypeId).DeveloperName == 'RCP_ReceiptGeneratedDepositPending_UY'){
                receipt.Status_AR__c = 'Receipt printed Deposit pending';  
                receipt.RecordTypeId = RecordTypeUYPend.id;
            } else if( mapIdRt.get(receipt.RecordtypeId).DeveloperName == 'LAT_AR_RCP_ReceiptValueGuarantee'){
                receipt.Status_AR__c = 'Receipt printed with Value in Custody';  
                receipt.RecordTypeId = RecordTypeARGuarantee.id;
            }
            update receipt; 
            
            Account acc = [SELECT Id, Name FROM Account WHERE Id =: receipt.Account_AR__c];
            
            PageReference pdf = Page.VFC02_PrintReceipt_AR;
            pdf.getParameters().put('IdRec',receipt.Id);
            Attachment attach = new Attachment();
            Blob body = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
            //Blob body = pdf.getContent();
            DateTime d = DateTime.now() ;
            if( acc.Name.length() > 40){
                attach.Name = receipt.Name + '-' + d.format('dd/MM/yyyy HH:mm:ss') + '-' + acc.Name.left(40) + '.pdf';
            } else {
                attach.Name = receipt.Name + '-' + d.format('dd/MM/yyyy HH:mm:ss') + '-' + acc.Name + '.pdf';
            }
            attach.Body = body;
            attach.IsPrivate = false;
            attach.ParentId = receipt.Id;
            insert attach;
            relateAttachmentToFiscalNotes(receipt.Id, attach);   
        }
                             
        return Error;    
    }   

    public static void relateAttachmentToFiscalNotes(String recId, Attachment att){
        List<DCM_Documents_ARG__c> docs = [SELECT Id, LegalInvoice_AR__c, tipoDocumento_AR__c FROM DCM_Documents_ARG__c WHERE ReceiptNo_AR__c = :recId];
        Set<String> setInvoiceIds = new Set<String>();
        for(DCM_Documents_ARG__c doc : docs){
            if(doc.tipoDocumento_AR__c == 'FA'){
                setInvoiceIds.add(doc.LegalInvoice_AR__c);
            }
        }
        if(setInvoiceIds.size() > 0){
            List<Attachment> toInsert = new List<Attachment>();
            List<LAT_FiscalNote__c> fnotes = [SELECT Id, LAT_LegalInvoice__c FROM LAT_FiscalNote__c WHERE LAT_LegalInvoice__c IN:setInvoiceIds];
            for(LAT_FiscalNote__c fn: fnotes){
                Attachment nuevo = att.clone();
                nuevo.ParentId = fn.Id;
                nuevo.Name = 'Recibo_'+att.Name;
                toInsert.add(nuevo);
            }
            if (toInsert.size() > 0) {
                insert toInsert;
            }
        }
        
    }
    
}