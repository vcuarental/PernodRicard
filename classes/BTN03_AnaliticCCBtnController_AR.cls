/****************************************************
*Dev: Denis Aranda  Version: 1  Consulting: Valuenet*
*Descripción:Boton en el tab Recibo objeto Documento*
* que deja al usuario crear registros de documentos *
*         basados en los titulos en aberto          *
****************************************************/

global with sharing class BTN03_AnaliticCCBtnController_AR {

    @RemoteAction
    webservice  static String idPage(String idRecibo, list<id> idTitulos ){
        
        //Validamos que el parametro idRecibo este correcto
        List<RCP_Receipt_ARG__c> recibo = [SELECT Id, Name, Account_AR__c, Account_AR__r.RecordTypeId, Account_AR__r.RecordType.DeveloperName, (SELECT Id, Name, ReceiptNo_AR__c, Internal_id_pk_AR__c FROM Documents__r) FROM RCP_Receipt_ARG__c WHERE id =:idRecibo];
        if(recibo.isEmpty()){
            return Label.BTN03_00001_AR;
            //Label BTN03_00001_AR: El parámetro de identificación se ha perdido, por favor regrese a la página anterior e iniciar el proceso de nuevo.
        }
        
        //Hacemos el query a RecordType y validamos que exista
        RecordType recordtAR = Global_RecordTypeCache.getRtRec('DCM_Documents_ARG__c'+'DCM_Standard_AR');
        RecordType recordUY = Global_RecordTypeCache.getRtRec('DCM_Documents_ARG__c'+'DCM_Standard_UY');
        Id recordTOfCountry;
        if(recibo[0].Account_AR__r.RecordType.DeveloperName == 'ACC_1_OffTrade_ARG' || recibo[0].Account_AR__r.RecordType.DeveloperName == 'ACC_3_OnTrade_ARG' || recibo[0].Account_AR__r.RecordType.DeveloperName == 'ACC_5_Events_ARG'){
            recordTOfCountry = recordtAR.Id;
        }else if( recibo[0].Account_AR__r.RecordType.DeveloperName == 'ACC_2_OffTrade_URU' || recibo[0].Account_AR__r.RecordType.DeveloperName == 'ACC_4_OnTrade_URU' || recibo[0].Account_AR__r.RecordType.DeveloperName == 'ACC_6_Events_URU'){
            recordTOfCountry = recordUY.Id;
        }else{
            return Label.BTN03_00005_AR;
            //Label BTN03_00005_AR: El país que está tratando de aplicar esto se desconoce
        }
        
        //Guardamos los internal Id que ya existen en el recibo
        set<String> internalIds = new set<String>();
        for(DCM_Documents_ARG__c document : recibo[0].Documents__r){
            internalIds.add(document.Internal_id_pk_AR__c);
        }
         
        //Cambios
        List<Decimal> payIds = new List<Decimal>();
        List<Id> tmpIds = new List<Id>();


        //Query a los titulos seleccionados
        map<String, Titulos__c> internaIdpkAndNameMap = new map<String, Titulos__c>();
        List<Titulos__c> titulo = [SELECT Id, Name, AN8__c, dataEmissao__c, dataVencimentoAtual__c, dataVencimentoOriginal__c, DeliveryNote_AR__c, Internal_id_pk__c, LegalInvoice_AR__c, NetOpenBalance_AR__c, NetSRReceipts_AR__c, numeroDocumento__c, observacoesTitulo__c, OrderNumber_AR__c, OrderType_AR__c, PaymentID_AR__c, tipoDocumento__c, valorOriginalTitulo__c, valorSaldo__c FROM Titulos__c WHERE Id =: idTitulos];
        for(Titulos__c tit: titulo){
            internaIdpkAndNameMap.put(tit.Internal_id_pk__c, tit);
            payIds.add(tit.PaymentID_AR__c);
        }

        

        for(Titulos__c t : [SELECT id, AN8__c, dataEmissao__c, dataVencimentoAtual__c,dataVencimentoOriginal__c,DeliveryNote_AR__c,Internal_id_pk__c,LegalInvoice_AR__c,Name, NetOpenBalance_AR__c,NetSRReceipts_AR__c,numeroDocumento__c, observacoesTitulo__c,OrderNumber_AR__c,OrderType_AR__c, PaymentID_AR__c,tipoDocumento__c,valorOriginalTitulo__c,valorSaldo__c,ReceiptNumber_AR__c FROM Titulos__c WHERE PaymentID_AR__c IN: payIds AND tipoDocumento__c = 'RU' AND NetOpenBalance_AR__c != 0 AND id not in: idTitulos]){
            titulo.add(t);
        }





        
        if(titulo.isEmpty()){
            return Label.BTN03_00004_AR;
            //Label BTN03_00004_AR: No se hizo una selección.
        }
        
        //Generamos los Docmuentos a partir de los Analiticos C/C
        String analiticosRepetidos;
        String netMenosCero;
        
        List<DCM_Documents_ARG__c> documents = new List<DCM_Documents_ARG__c>();
        
        for(Titulos__c ti: titulo){
            //Verificamos que los seleccionados no esten repetidos
            if(internalIds.contains(ti.Internal_id_pk__c)){
                if(analiticosRepetidos==null){analiticosRepetidos=ti.Name;}else{analiticosRepetidos += ', '+ti.Name;}
                continue;
            }
            //Verificamos que los seleccionados tengan el NetOpenBalance mayor que 0
            if(ti.NetOpenBalance_AR__c == 0 || ti.NetOpenBalance_AR__c == null ){
                if(netMenosCero==null){netMenosCero=ti.Name;}else{netMenosCero += ', '+ti.Name;}
                continue;
            }
            
            DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c();
            try{doc.AN8_AR__c                = decimal.valueOf(ti.AN8__c);}catch(Exception e){}
            doc.dataEmissao_AR__c            = ti.dataEmissao__c;
            doc.dataVencimentoAtual_AR__c    = ti.dataVencimentoAtual__c;
            doc.dataVencimentoOriginal_AR__c = ti.dataVencimentoOriginal__c;
            doc.DeliveryNote_AR__c           = ti.DeliveryNote_AR__c;
            doc.Internal_id_pk_AR__c         = ti.Internal_id_pk__c;
            doc.LegalInvoice_AR__c           = ti.LegalInvoice_AR__c;
            doc.NetOpenBalance_AR__c         = ti.NetOpenBalance_AR__c;
            doc.NetCRMReceipts_AR__c         = ti.NetSRReceipts_AR__c;
            doc.Name                         = string.valueof(ti.numeroDocumento__c);
            doc.observacoesTitulo_AR__c      = ti.observacoesTitulo__c;
            doc.OrderNumber_AR__c            = ti.OrderNumber_AR__c;
            doc.OrderType_AR__c              = ti.OrderType_AR__c;
            doc.PaymentID_AR__c              = ti.PaymentID_AR__c;
            doc.tipoDocumento_AR__c          = ti.tipoDocumento__c;
            doc.valorOriginalTitulo_AR__c    = ti.valorOriginalTitulo__c;
            doc.valorSaldo_AR__c             = ti.valorSaldo__c;
            doc.Amounttoapply_AR__c          = ti.NetOpenBalance_AR__c;
            doc.ReceiptNo_AR__c              = idRecibo;
            doc.RecordTypeid                 = recordTOfCountry;
            documents.add(doc);
        }
        
        String mensajeReturn = '';
        try{
            insert documents;
            if(analiticosRepetidos!=null || netMenosCero!=null){
                if(analiticosRepetidos!=null){
                    mensajeReturn += Label.BTN03_00002_AR+' '+analiticosRepetidos + '. ';
                    //Label BTN03_00002_AR: Los siguientes analíticos ya fueron aplicados:
                }
                if(mensajeReturn !=''){mensajeReturn += '\n' + '\n';}
                if(netMenosCero!=null){
                    mensajeReturn += Label.BTN03_00003_AR+' '+netMenosCero + '. ' + '\n' + '\n' ;
                    //Label BTN03_00003_AR: Los siguientes analíticos no fueron agregados debido a que el saldo neto debe ser mayor a 0:
                }
                
                if(documents.isEmpty()){
                    mensajeReturn += 'Warning0 ' + Label.BTN03_00010_AR;
                    //Label BTN03_00010_AR: No se agregaron analiticos.
                }else{
                    mensajeReturn += 'Warning1 ' + Label.BTN03_00011_AR;
                    //Label BTN03_00011_AR: Los analiticos restantes fueron agregados exitosamente.
                }
                return mensajeReturn;
            }
            return 'OK';
        }catch(Exception e){return 'Error: '+e.getMessage();}
        
        return null;
    }

    @RemoteAction
     global static List<Titulos__c> getTitulos(String idRecibo,String idAccount){
        List<LAT_Blocked_Document__c> docs = [SELECT Internal_id_pk__c FROM LAT_Blocked_Document__c];
        Set<String> blockedDocuments = new Set<String>();
        for(LAT_Blocked_Document__c bd : docs) {
            blockedDocuments.add(bd.Internal_id_pk__c);
        }

        if(idAccount != null){
            List<Titulos__c>titulos = [SELECT Id, TipoDocumento__c,LegalInvoice_AR__c, ValorOriginalTitulo__c,NetSRReceipts_AR__c,NetOpenBalance_AR__c,PaymentID_AR__c, 
                                            Ruinusebypendingreceipt_AR__c,Ruinusebypendingreceipt_AR__r.Name,CurrencyIsoCode,Cliente__c,Name,AN8__c,Cliente__r.Name, 
                                            DataEmissao__c, DataVencimentoOriginal__c, DataVencimentoAtual__c, DiasAtraso__c, ValorSaldo__c  
                                            FROM Titulos__c WHERE Cliente__c =: idAccount AND Internal_id_pk__c NOT IN :blockedDocuments];
            return titulos;
        }else{
            List<RCP_Receipt_ARG__c> recibos = [Select id,Account_AR__c from RCP_Receipt_ARG__c where id =: idRecibo];
            if(!recibos.isEmpty()){
                List<Titulos__c>titulos = [SELECT Id, TipoDocumento__c,LegalInvoice_AR__c, ValorOriginalTitulo__c,NetSRReceipts_AR__c,NetOpenBalance_AR__c,PaymentID_AR__c,
                                            Ruinusebypendingreceipt_AR__c,Ruinusebypendingreceipt_AR__r.Name,CurrencyIsoCode,Cliente__c,Name,AN8__c,Cliente__r.Name, DataEmissao__c,    
                                            DataVencimentoOriginal__c, DataVencimentoAtual__c, DiasAtraso__c, ValorSaldo__c  
                                            FROM Titulos__c WHERE Cliente__c =:recibos[0].Account_AR__c AND Internal_id_pk__c NOT IN :blockedDocuments];
                return titulos;
            }
            return new List<Titulos__c>();
       }
    }   

    @RemoteAction
    webService static String GenerateReceipt(list<id> ids_Register){

       list<id> listDeIdsREgistros = ids_Register;

        
        set<String> setDeBusqueda = new set<String>();
    
        for ( id a :listDeIdsREgistros ){
            setDeBusqueda.add(a);
        }
       system.debug('setDeBusquedaASD'+setDeBusqueda.size());
       system.debug('listDeIdsREgistrosASD'+listDeIdsREgistros.size());
      
       
       list<Titulos__c> tit = [SELECT Id , Name, NetOpenBalance_AR__c, tipoDocumento__c, ReceiptNumber_AR__c, Internal_id_pk__c FROM Titulos__c WHERE id IN : setDeBusqueda];
       List<LAT_Blocked_Document__c> docs = [SELECT Internal_id_pk__c, LAT_Receipt__r.Name FROM LAT_Blocked_Document__c];
       Map<String, String> mapRecibosXInternalId = new Map<String, String>();
       for(LAT_Blocked_Document__c doc : docs) {
          mapRecibosXInternalId.put(doc.Internal_id_pk__c, doc.LAT_Receipt__r.Name);
       }

       system.debug('sizeQuery'+ tit.size());
       system.debug('titit'+ tit);
              
       String error = '';
       
       set<Id> setIdAccounts = new set<Id>();
       
       for (Titulos__c t : tit){
       
           // validacion 2.1
           if (  (t.tipoDocumento__c == 'RU') &&  (t.ReceiptNumber_AR__c != null) ){
               error = label.BTN04_00001_AR;
               return error;
           } 
           
           // validacion 2.2
            if (  t.tipoDocumento__c == 'R1' ){
               error = label.BTN04_00002_AR;
               return error;
           } 
            // validacion 2.3
            if (  t.tipoDocumento__c == 'AA' ){
               error = 'No se pueden seleccionar Analíticos de tipo AA.';
               return error;
           }
           // validacion 2.4
           if(mapRecibosXInternalId.keySet().contains(t.Internal_id_pk__c)) {
              error = 'Existen Recibos pendientes de Integración que incluyen este Analítico (Recibo:' + mapRecibosXInternalId.get(t.Internal_id_pk__c) + ', Analítico: '+t.Name +').';
              return error;
           } 
       }
       
       
       boolean flag = false;

       for (Titulos__c t : tit){
           if (  t.NetOpenBalance_AR__c == 0 ){
               if (flag == false){
                   error = label.BTN04_00006_AR;
                   flag = true;
               }
           error = error + '  ' + t.Name + ' ';
           } 
       }
     
       
       return error;
    
    } 


    /*TEST CODE IN BTN03_AnaliticCCButtonController_ARG_Tes CLASS*/
    
}