/*************************************************************************************
*     Company:Valuenet    Developer: Elena J. Schwarzböck     Date:25/05/2014        *
**************************************************************************************/
global class LAT_AR_WS02_ReceiptReturn{
     
    global class ReceiptReturn{
        webservice String idCRMrec;
        webservice Integer returnCode;
        webservice String messageJDEIntegration;
        webservice List<LAT_AR_WS02_ReceiptReturn.DocumentType> listDocs;
        webservice List<LAT_AR_WS02_ReceiptReturn.ValueType> listValues;
        webservice List<LAT_AR_WS02_ReceiptReturn.DepositType> listDeposits;
        webservice List<LAT_AR_WS02_ReceiptReturn.TaxCertificateType> listTaxCertificates;
    }
    global class DocumentType{
        webservice String idCRMdoc;
        webservice Boolean DocAppliedinJDE;
    }
    global class ValueType{
        webservice String idCRMval;
        webservice Boolean ValueRecordedinJDE;
    }   
    global class DepositType{
        webservice String idCRMdep;
        webservice Boolean DepositRecordedJDE;
        webservice Boolean RecNumberInterfaceOk;
    }   
    global class TaxCertificateType{
        webservice String idCRMtax;
        webservice Boolean WithhRecordedinJDE;
    }    
    
    //Return codes
    public static integer success          =  0;
    public static integer notFound_receipt = -1;
    public static integer otherError       = -2; 
    
    
    webservice static Integer ReceiptReturn(ReceiptReturn receiptRet){
        
        Integer codeRet = 0;
        String error = null;

        List<RCP_Receipt_ARG__c> listReceipts = [SELECT Id, LAT_AR_JDEReturnCode__c, LAT_AR_IntegrationStatus__c
                                                 FROM RCP_Receipt_ARG__c 
                                                 WHERE Id =: receiptRet.idCRMrec.trim()];

        system.debug(logginglevel.error,'receiptRet.returnCode: ' + receiptRet.returnCode);

        RCP_Receipt_ARG__c receipt;

        if(!listReceipts.isEmpty()){                
            receipt = listReceipts[0];
        }else{
            codeRet = notFound_receipt;       
        }

        if(codeRet != notFound_receipt){

            if(receiptRet.returnCode == 0){                                                                                        
    
                Set<Id> setValueIds = new Set<Id>();
                Set<Id> setDepIds = new Set<Id>();
                Set<Id> setTaxIds = new Set<Id>();
                Set<Id> setDocIds = new Set<Id>();
                
                Map<Id,VLS_Values_ARG__c> mapValues = null;
                Map<Id,DPT_Deposit_ARG__c> mapDeps = null;
                Map<Id,TXC_TaxCertificates_ARG__c> mapTaxs = null;
                Map<Id,DCM_Documents_ARG__c> mapDocs = null;
    
                //se obtienen los valores a actualizar
                if(receiptRet.listValues != null && !receiptRet.listValues.isEmpty()){
                    for(LAT_AR_WS02_ReceiptReturn.ValueType value: receiptRet.listValues){
                        setValueIds.add(value.idCRMval.trim());
                    }
                    if(!setValueIds.isEmpty()){           
                        mapValues = new Map<Id,VLS_Values_ARG__c>([SELECT Id, ValueRecordedinJDE_AR__c
                                                                    FROM VLS_Values_ARG__c
                                                                    WHERE Id IN: setValueIds]);                                                               
                        for(LAT_AR_WS02_ReceiptReturn.ValueType value: receiptRet.listValues){
                            if(mapValues.containsKey(value.idCRMval.trim())){
                                mapValues.get(value.idCRMval.trim()).ValueRecordedinJDE_AR__c = value.ValueRecordedinJDE;
                            }
                        }
                    }
                }
                
                //se obtienen los depositos a actualizar
                if(receiptRet.listDeposits != null && !receiptRet.listDeposits.isEmpty()){
                    for(LAT_AR_WS02_ReceiptReturn.DepositType dep: receiptRet.listDeposits){
                        setDepIds.add(dep.idCRMdep.trim());
                    }
                    if(!setDepIds.isEmpty()){           
                        mapDeps = new Map<Id,DPT_Deposit_ARG__c>([SELECT Id, LAT_AR_DepositRecordedJDE__c, RecNumberInterfaceOk_AR__c
                                                                    FROM DPT_Deposit_ARG__c
                                                                    WHERE Id IN: setDepIds]);                                                              
                        for(LAT_AR_WS02_ReceiptReturn.DepositType dep: receiptRet.listDeposits){
                            if(mapDeps.containsKey(dep.idCRMdep.trim())){
                                mapDeps.get(dep.idCRMdep.trim()).LAT_AR_DepositRecordedJDE__c = dep.DepositRecordedJDE;
                                mapDeps.get(dep.idCRMdep.trim()).RecNumberInterfaceOk_AR__c = dep.RecNumberInterfaceOk;
                            }
                        }
                    }
                }
    
                //se obtienen los certificados a actualizar
                if(receiptRet.listTaxCertificates != null && !receiptRet.listTaxCertificates.isEmpty()){
                    for(LAT_AR_WS02_ReceiptReturn.TaxCertificateType tax: receiptRet.listTaxCertificates){
                        setTaxIds.add(tax.idCRMtax.trim());
                    }
                    if(!setTaxIds.isEmpty()){           
                        mapTaxs = new Map<Id,TXC_TaxCertificates_ARG__c>([SELECT Id, WithhRecordedinJDE_AR__c
                                                                    FROM TXC_TaxCertificates_ARG__c
                                                                    WHERE Id IN: setTaxIds]);                                                              
                        for(LAT_AR_WS02_ReceiptReturn.TaxCertificateType tax: receiptRet.listTaxCertificates){
                            if(mapTaxs.containsKey(tax.idCRMtax.trim())){
                                mapTaxs.get(tax.idCRMtax.trim()).WithhRecordedinJDE_AR__c = tax.WithhRecordedinJDE;
                            }
                        }
                    }
                }            
                
                //se obtienen los documentos a actualizar                                                        
                if(receiptRet.listDocs != null && !receiptRet.listDocs.isEmpty()){
                    for(LAT_AR_WS02_ReceiptReturn.DocumentType doc: receiptRet.listDocs){
                        setDocIds.add(doc.idCRMdoc.trim());
                    }
                    if(!setDocIds.isEmpty()){           
                        mapDocs = new Map<Id,DCM_Documents_ARG__c>([SELECT Id, DocAppliedinJDE_AR__c
                                                                    FROM DCM_Documents_ARG__c
                                                                    WHERE Id IN: setDocIds]);                                                               
                        for(LAT_AR_WS02_ReceiptReturn.DocumentType doc: receiptRet.listDocs){
                            if(mapDocs.containsKey(doc.idCRMdoc.trim())){
                                mapDocs.get(doc.idCRMdoc.trim()).DocAppliedinJDE_AR__c = doc.DocAppliedinJDE;
                            }
                        }
                    }
                }
                
                receipt.LAT_AR_IntegrationStatus__c = 'Registered in JDE';
                if(receiptRet.messageJDEIntegration != null && receiptRet.messageJDEIntegration != ''){
                    receipt.LAT_AR_MessageJDEIntegration__c = receiptRet.messageJDEIntegration;
                }else{
                    receipt.LAT_AR_MessageJDEIntegration__c = null;
                }
                receipt.LAT_AR_JDEReturnCode__c = string.valueOf(receiptRet.returnCode);
                
                try{
                    update receipt;
                    if(mapValues != null && !mapValues.isEmpty()){                    
                        update mapValues.values();
                    }
                    if(mapDeps != null && !mapDeps.isEmpty()){ 
                        update mapDeps.values();
                    }
                    if(mapTaxs != null && !mapTaxs.isEmpty()){ 
                        update mapTaxs.values();
                    }
                    if(mapDocs != null && !mapDocs.isEmpty()){ 
                        update mapDocs.values();
                    }
                }catch(DMLException e){
                    error = e.getMessage();
                    codeRet = otherError;         
                }
                                         
            }else{
                receipt.LAT_AR_IntegrationStatus__c = 'Error in JDE';
                if(receiptRet.messageJDEIntegration != null && receiptRet.messageJDEIntegration != ''){
                    receipt.LAT_AR_MessageJDEIntegration__c = receiptRet.messageJDEIntegration;
                }else{
                    receipt.LAT_AR_MessageJDEIntegration__c = null;
                }
                receipt.LAT_AR_JDEReturnCode__c = string.valueOf(receiptRet.returnCode);
                try{
                    update receipt;
                 }catch(DMLException e){
                    error = e.getMessage();
                    codeRet = otherError;                   
                 }           
            }
        }           
                
        if(codeRet != 0){
            //DebugLog
            try{
                LAT_DebugUtil debug = new LAT_DebugUtil();
                debug.setOrigin('LAT_AR_WS02_ReceiptReturn');
                debug.addTitle('Parameters');
                debug.addData('idCRMrec', receiptRet.idCRMrec);
                debug.addData('returnCode', String.ValueOf(receiptRet.returnCode));

                if(receiptRet.listValues != null && !receiptRet.listValues.isEmpty()){
                    debug.addTitle('Values');
                    for(LAT_AR_WS02_ReceiptReturn.ValueType value: receiptRet.listValues){
                        debug.addData('idCRMval', value.idCRMval.trim());
                        debug.addData('ValueRecordedinJDE', String.ValueOf(value.ValueRecordedinJDE));
                    }
                }
                
                if(receiptRet.listDeposits != null && !receiptRet.listDeposits.isEmpty()){
                    debug.addTitle('Deposits');
                    for(LAT_AR_WS02_ReceiptReturn.DepositType dep: receiptRet.listDeposits){
                        debug.addData('idCRMdep', dep.idCRMdep.trim());
                        debug.addData('DepositRecordedJDE', String.ValueOf(dep.DepositRecordedJDE));
                        debug.addData('RecNumberInterfaceOk', String.ValueOf(dep.RecNumberInterfaceOk));
                    }
                }
                
                if(receiptRet.listTaxCertificates != null && !receiptRet.listTaxCertificates.isEmpty()){
                    debug.addTitle('Tax Certificates');
                    for(LAT_AR_WS02_ReceiptReturn.TaxCertificateType tax: receiptRet.listTaxCertificates){
                        debug.addData('idCRMtax', tax.idCRMtax.trim());
                        debug.addData('WithhRecordedinJDE', String.ValueOf(tax.WithhRecordedinJDE));
                    }
                }
                
                if(receiptRet.listDocs != null && !receiptRet.listDocs.isEmpty()){
                    debug.addTitle('Documents');
                    for(LAT_AR_WS02_ReceiptReturn.DocumentType doc: receiptRet.listDocs){
                        debug.addData('idCRMdoc', doc.idCRMdoc);
                        debug.addData('DocAppliedinJDE', String.ValueOf(doc.DocAppliedinJDE));
                    }
                }
              
                debug.setResult(String.ValueOf(codeRet));
                
                if(error != null){
                    debug.addTitle('Error');
                    debug.addData('error', String.ValueOf(error));
                }
                debug.insertDebug();
            }catch(Exception e){}

        }
    
        return codeRet;
    }      

}