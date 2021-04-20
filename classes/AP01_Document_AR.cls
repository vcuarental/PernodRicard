/*******************************************************************************
*   Company: Zimmic   Developer : Nicolás Marán    Fecha: 23/3/2016
*-------------------------------------------------------------------------------
*   Clase utilizada en los triggers del objeto LAT_AR_TaxCertificates
*******************************************************************************/

global with sharing class AP01_Document_AR {
    
    public static map<Id, RecordType> mapIdRt = new map<Id, RecordType>(Global_RecordTypeCache.getRtList('DCM_Documents_ARG__c'));  
    
    /*****************************************************************************************
    * Nombre del metodo: InsertAmountApply_ARG
    * Descripcion: Metodo que actualiza el campo NetSRReceipts_AR__c cuando se inserta un Documento
    * Desarrollador: Elena Schwarzböck
    * Fecha: 04/04/2013
    * Modo: before insert
    *****************************************************************************************/
    public static void InsertAmountApply_ARG (List<DCM_Documents_ARG__c> triggerNew){
        
        set<String> setInternalIdPk = new set<String>();
        for (DCM_Documents_ARG__c doc: triggerNew){             
            if((mapIdRt.get(doc.RecordTypeId).DeveloperName == 'DCM_Standard_AR' || mapIdRt.get(doc.RecordTypeId).DeveloperName == 'DCM_Standard_UY') ){      
                if( doc.Amounttoapply_AR__c != NULL ){      
                   setInternalIdPk.add(doc.Internal_id_pk_AR__c);
                }
            }
        }
        map<Id,Titulos__c> mapIdTitulos= new map<Id, Titulos__c>([SELECT Id, Internal_id_pk__c, NetSRReceipts_AR__c FROM Titulos__c WHERE Internal_id_pk__c IN: setInternalIdPk]);
        map<String,Titulos__c> mapInternalIdTitulos = new map<String,Titulos__c>();
        map<String, Decimal> mapInternatIdSumAmount = new map<String, Decimal>();
        Decimal SumAux;
        
        if(!mapIdTitulos.isEmpty()){
                for(Id id1: mapIdTitulos.keyset()){
                mapInternalIdTitulos.put(mapIdTitulos.get(id1).Internal_id_pk__c, mapIdTitulos.get(id1));
            }
        }        

        list<Titulos__c> listTitulos = new list<Titulos__c>();              

        if(!mapInternalIdTitulos.isEmpty()){
           for (DCM_Documents_ARG__c doc: triggerNew){
                if(mapIdRt.get(doc.RecordTypeId).DeveloperName == 'DCM_Standard_AR' || mapIdRt.get(doc.RecordTypeId).DeveloperName == 'DCM_Standard_UY'){  
                    if( doc.Amounttoapply_AR__c != NULL ){        
                        if(!mapInternatIdSumAmount.containsKey(doc.Internal_id_pk_AR__c) ){
                            mapInternatIdSumAmount.put(doc.Internal_id_pk_AR__c, doc.Amounttoapply_AR__c);
                        } else {
                            SumAux = doc.Amounttoapply_AR__c + mapInternatIdSumAmount.get(doc.Internal_id_pk_AR__c);
                            mapInternatIdSumAmount.put(doc.Internal_id_pk_AR__c, SumAux);
                        }
                    }       
                }
           }
           for(String IntId: mapInternalIdTitulos .keyset()){
                if(mapInternalIdTitulos.get(IntId).NetSRReceipts_AR__c != NULL){
                    mapInternalIdTitulos.get(IntId).NetSRReceipts_AR__c = mapInternalIdTitulos.get(IntId).NetSRReceipts_AR__c + mapInternatIdSumAmount.get(IntId);
                } else {
                    mapInternalIdTitulos.get(IntId).NetSRReceipts_AR__c = mapInternatIdSumAmount.get(IntId);
               }
               listTitulos.add(mapInternalIdTitulos.get(IntId));
            }               

        }
        
        if(!listTitulos.isEmpty()){
            update listTitulos;
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: UpdateAmountApply_ARG
    * Descripcion: Metodo que actualiza el campo NetSRReceipts_AR__c cuando se modifica un Documento
    * Desarrollador: Elena Schwarzböck
    * Fecha: 
    * Modo: before update
    *****************************************************************************************/
    public static void UpdateAmountApply_ARG (List<DCM_Documents_ARG__c> triggerNew, Map<Id, DCM_Documents_ARG__c> triggerOld){
        
        Map<String, Decimal> mapTituloSumaAmounttoapplyNuevos = new Map<String, Decimal>();
        Map<String, Decimal> mapTituloSumaAmounttoapplyViejos = new Map<String, Decimal>();
        set<String> setInternalIdPk = new set<String>();
        List<Titulos__c> listTitulosUpdate = new List<Titulos__c>();
        Decimal amountToApply = 0;
        for (DCM_Documents_ARG__c doc: triggerNew){             
            if((mapIdRt.get(doc.RecordTypeId).DeveloperName == 'DCM_Standard_AR' || mapIdRt.get(doc.RecordTypeId).DeveloperName == 'DCM_Standard_UY') && !doc.DocAppliedinJDE_AR__c){      
                if( doc.Amounttoapply_AR__c != triggerOld.get(doc.Id).Amounttoapply_AR__c ){        
                    if(mapTituloSumaAmounttoapplyNuevos.containskey(doc.Internal_id_pk_AR__c)){
                        amountToApply = mapTituloSumaAmounttoapplyNuevos.get(doc.Internal_id_pk_AR__c) + doc.Amounttoapply_AR__c;
                        mapTituloSumaAmounttoapplyNuevos.put(doc.Internal_id_pk_AR__c, amountToApply);
                        amountToApply = mapTituloSumaAmounttoapplyViejos.get(doc.Internal_id_pk_AR__c) + triggerOld.get(doc.Id).Amounttoapply_AR__c;
                        mapTituloSumaAmounttoapplyViejos.put(doc.Internal_id_pk_AR__c, amountToApply);
                    }else{
                        mapTituloSumaAmounttoapplyNuevos.put(doc.Internal_id_pk_AR__c, doc.Amounttoapply_AR__c);
                        mapTituloSumaAmounttoapplyViejos.put(doc.Internal_id_pk_AR__c, triggerOld.get(doc.Id).Amounttoapply_AR__c);
                    }
                }
            }
        }

        list<Titulos__c> listTitulos = [SELECT Id, Internal_id_pk__c, NetSRReceipts_AR__c FROM Titulos__c WHERE Internal_id_pk__c IN: mapTituloSumaAmounttoapplyNuevos.keyset()];

        map<String,Titulos__c> mapInternalIdTitulos = new map<String,Titulos__c>();

        if(!listTitulos.isEmpty()){
            for (Titulos__c tit:  listTitulos){
                if(mapTituloSumaAmounttoapplyViejos.containsKey(tit.Internal_id_pk__c)){
                    if(mapTituloSumaAmounttoapplyViejos.get(tit.Internal_id_pk__c) != null){
                        if(tit.NetSRReceipts_AR__c == null){tit.NetSRReceipts_AR__c = 0;}
                        tit.NetSRReceipts_AR__c -= mapTituloSumaAmounttoapplyViejos.get(tit.Internal_id_pk__c);
                    }
                }
                if(mapTituloSumaAmounttoapplyNuevos.containsKey(tit.Internal_id_pk__c)){
                    if(mapTituloSumaAmounttoapplyNuevos.get(tit.Internal_id_pk__c) != null){
                        if(tit.NetSRReceipts_AR__c == null){tit.NetSRReceipts_AR__c = 0;}
                        tit.NetSRReceipts_AR__c += mapTituloSumaAmounttoapplyNuevos.get(tit.Internal_id_pk__c);
                    }
                }
                listTitulosUpdate.add(tit);
            }
        }
        
        if(listTitulosUpdate.size() > 0){
           
            update listTitulosUpdate;
        }
    }
    
   
    /*****************************************************************************************
    * Nombre del metodo: DeleteRecordReceiptsPendingSF_ARG
    * Descripcion: Metodo que actualiza el campo NetSRReceipts_AR__c cuando se borra un Documento
    * Desarrollador: Elena Schwarzböck
    * Fecha: 
    * Modo: before delete
    *****************************************************************************************/
    public static void DeleteRecordReceiptsPendingSF_ARG (List<DCM_Documents_ARG__c> triggerOld){
            
        set<String> setInternalIdPk = new set<String>();
            
        for (DCM_Documents_ARG__c doc: triggerOld){             
            if((mapIdRt.get(doc.RecordTypeId).DeveloperName == 'DCM_Standard_AR' || mapIdRt.get(doc.RecordTypeId).DeveloperName == 'DCM_Standard_UY') && !doc.DocAppliedinJDE_AR__c){      
                setInternalIdPk.add(doc.Internal_id_pk_AR__c);
            }
        }
    
        list<Titulos__c> listTitulos = [SELECT Id, Internal_id_pk__c, NetSRReceipts_AR__c FROM Titulos__c WHERE Internal_id_pk__c IN: setInternalIdPk];
    
        map<String,Titulos__c> mapInternalIdTitulos = new map<String,Titulos__c>();
    
        if(!listTitulos.isEmpty() ){
            for (Titulos__c tit:  listTitulos){
                mapInternalIdTitulos.put(tit.Internal_id_pk__c, tit);
            }
        }
    
        map<String, Decimal> mapNetBorrados = new map<String, Decimal>(); 
        Decimal SumAux;
        
        if(!mapInternalIdTitulos.isEmpty() ){
            for (DCM_Documents_ARG__c doc: triggerOld){
                if((mapIdRt.get(doc.RecordTypeId).DeveloperName == 'DCM_Standard_AR' || mapIdRt.get(doc.RecordTypeId).DeveloperName == 'DCM_Standard_UY') && !doc.DocAppliedinJDE_AR__c){  
                    if(!mapNetBorrados.containsKey(doc.Internal_id_pk_AR__c) ){
                        mapNetBorrados.put(doc.Internal_id_pk_AR__c, doc.Amounttoapply_AR__c);
                    } else {
                        SumAux = doc.Amounttoapply_AR__c + mapNetBorrados.get(doc.Internal_id_pk_AR__c);
                        mapNetBorrados.put(doc.Internal_id_pk_AR__c, SumAux);
                    }
               }       
            }
    
            for(Titulos__c tit: listTitulos){
                if(tit.NetSRReceipts_AR__c != NULL){
                    tit.NetSRReceipts_AR__c = tit.NetSRReceipts_AR__c - mapNetBorrados.get(tit.Internal_id_pk__c);
                } else {
                    tit.NetSRReceipts_AR__c = mapNetBorrados.get(tit.Internal_id_pk__c);
               }
            }               
        }
        
        if(!listTitulos.isEmpty()){
            update listTitulos;
        }
    }
    
    public static boolean isDeletingFirst = true;

    public static void deleteDocuments (List<DCM_Documents_ARG__c> triggerOld){
        if(isDeletingFirst){
            List<Id> tmpIds = new List<Id>();
            List<String> tmpNames = new List<String>();
            List<Decimal> paymentsIds = new List<Decimal>();
            Set<DCM_Documents_ARG__c> toDelete = new Set<DCM_Documents_ARG__c>();
            List<Titulos__c> titulosToUpdate = new List<Titulos__c>();
            List<DPT_Deposit_ARG__c> depositsToDelete = new List<DPT_Deposit_ARG__c>();
            for (DCM_Documents_ARG__c doc : triggerOld) {
                system.debug('66666 ' + doc.tipoDocumento_AR__c);
                if(doc.tipoDocumento_AR__c == 'RU'){
                    tmpIds.add(doc.ReceiptNo_AR__c);
                    paymentsIds.add(doc.PaymentID_AR__c);
                    
                    String depName = (doc.PaymentID_AR__c == null) ? '' : doc.PaymentID_AR__c + '';
                    Integer NameLength = depName.length();
                    for (Integer i = NameLength; i < 9; i++) {
                        depName = '0' + depName;
                    }
                    tmpNames.add(depName);

                }
            }

            for(DPT_Deposit_ARG__c tmpD : [Select id from DPT_Deposit_ARG__c where From_Document__c = True and Name in: tmpNames]){
                depositsToDelete.add(tmpD);
            }

            
            
            for(Titulos__c tmpT : [Select id,Ruinusebypendingreceipt_AR__c from Titulos__c where Ruinusebypendingreceipt_AR__c in: tmpIds and PaymentID_AR__c in: paymentsIds]){
                tmpT.Ruinusebypendingreceipt_AR__c = null;
                titulosToUpdate.add(tmpT);
            }
    
            Map<id,RCP_Receipt_ARG__c> receipts = new Map<Id,RCP_Receipt_ARG__c>([Select id,(Select id,PaymentID_AR__c from Documents__r) from RCP_Receipt_ARG__c where id in: tmpIds]);
    
            for (DCM_Documents_ARG__c doc : triggerOld) {
                if(receipts.get(doc.ReceiptNo_AR__c) != null && receipts.get(doc.ReceiptNo_AR__c).Documents__r != null){
                    for(DCM_Documents_ARG__c childDocs : receipts.get(doc.ReceiptNo_AR__c).Documents__r){
                        if(doc.id != childDocs.id && doc.PaymentID_AR__c == childDocs.PaymentID_AR__c){
                            toDelete.add(childDocs);
                        }
                    }
                }
            }
            system.debug('dddd ' + toDelete);
            AP01_Document_AR.isDeletingFirst = false;
            delete new List<DCM_Documents_ARG__c>(toDelete);
            delete depositsToDelete;
            AP01_Document_AR.isDeletingFirst = true;
            update titulosToUpdate;
            
        }

    }

    webservice static String createDocumentRetentions (List<String> docIds){
        String returnText = '';
        String idCampoAmmount =[SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Amount_AR__c' AND ObjectApiName__c='TXC_TaxCertificates_ARG__c'].FieldId__c;
        String idCampoReceipt =[SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='ReceiptNo_AR__c' AND ObjectApiName__c='TXC_TaxCertificates_ARG__c'].FieldId__c;
            
        if (docIds != null && !docIds.isEmpty()) {
            List<DCM_Documents_ARG__c> docs = [SELECT id, Amounttoapply_AR__c, ReceiptNo_AR__r.Name FROM DCM_Documents_ARG__c WHERE id IN: docIds];
            if (!docs.isEmpty()) {
                Double totalAmmount = 0;
                for (DCM_Documents_ARG__c doc: docs) {
                    if (doc.Amounttoapply_AR__c != null) {
                        totalAmmount += doc.Amounttoapply_AR__c;
                    }
                    
                }
                returnText = '/'+TXC_TaxCertificates_ARG__c.getSObjectType().getDescribe().getKeyPrefix()+'/e?'+
                                    idCampoAmmount+'='+totalAmmount.format()+'&'+idCampoReceipt+'='+docs.get(0).ReceiptNo_AR__r.Name;
            }
        }

        return returnText;
    }
    /*******************************************************************************
    *   Company: Zimmic   Developer : Nicolás Marán    Fecha: 23/3/2016
    *   --------------------------------------------------------------- ----------------
    *   //Metodo verifica el estado del padre del documento para ver si el documento puede ser modificado
    *******************************************************************************/ 

    public static void DocumentCheckPrintStatus(Map<id,DCM_Documents_ARG__c> triggerNewMap){
        
        Map<id,DCM_Documents_ARG__c> mapTemp = new Map<id,DCM_Documents_ARG__c>([Select id , ReceiptNo_AR__r.Status_AR__c from DCM_Documents_ARG__c where id IN : triggerNewMap.keyset()]);

        for (DCM_Documents_ARG__c doc : triggerNewMap.values()) { 

            String statusReceipt = mapTemp.get(doc.id).ReceiptNo_AR__r.Status_AR__c;

            if(statusReceipt == null || Lat_RecieptValidationsUtil.checkBothStatus(statusReceipt)) 
                    doc.addError(Label.LAT_AR_TRIGGER_DocumentForPrintReciept);
        
        }

    }



}