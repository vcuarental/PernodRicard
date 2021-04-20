/*******************************************************************************************
*   Company:Valuenet    Developer:   Tomás Etchegaray               Date:04/04/2013        *
*******************************************************************************************/


public with sharing class VFC01_ReceiptSelectController_AR {
  
    public String prefixObj = RCP_Receipt_ARG__c.SObjectType.getDescribe().getKeyPrefix();
    public list<RecordType> rtS = Global_RecordTypeCache.getRtList('RCP_Receipt_ARG__c');
    public map<String,id> developNameId = new map<String,id>();
    public List<SelectOption> Items {get;set;}
    public String value {get;set;}
    
    public VFC01_ReceiptSelectController_AR() {
        items = new List<SelectOption>();
        Schema.DescribeSObjectResult d = Schema.SObjectType.RCP_Receipt_ARG__c;
        Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
        
        for(RecordType rt: [select id, RecordType.DeveloperName, toLabel(Name) from recordtype where sobjecttype=:'RCP_Receipt_ARG__c']){
          if(rtMapById.get(rT.id).isAvailable()){
            system.debug('Recordtype: ' + rt.DeveloperName);
            items.add(new SelectOption(rt.id,rt.Name));
            }
        }
    }
    
    public PageReference doContinue(){
      Savepoint sp = Database.setSavepoint();
      String idAcc=Apexpages.currentPage().getParameters().get('idAcc');
      String idArray=Apexpages.currentPage().getParameters().get('idArray');
      
      Account acc =  [SELECT Id, Name,Client_code_AN8__c,CollectionAgent_AR__c,OwnerId FROM Account WHERE id =: idAcc];
      String OwnerId = acc.OwnerId;
      User use =  [SELECT Id, C_digo_JDE__c FROM User WHERE id =: OwnerId];
      String DevelopName;
      
      for(RecordType r: rtS){
        developNameId.put(r.DeveloperName,r.id);
      }
      string reciboID;
      
      if((value == developNameId.get('RCP_ReceiptGeneratedDepositDone_AR')) || (value == developNameId.get('RCP_ReceiptGeneratedDepositDone_UY')) || (value == developNameId.get('RCP_ReceiptGeneratedDepositPending_AR')) || (value == developNameId.get('LAT_AR_RCP_ReceiptValueGuarantee')) || (value == developNameId.get('RCP_ReceiptGeneratedDepositPending_UY')) || (value == developNameId.get('Receipt_withholding_certificates_AR')) || (value == developNameId.get('LAT_AR_RCP_ReceiptOfApplyingDocuments'))){
          RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Date_AR__c=date.today(), Account_AR__c=idAcc, AN8_AR__c=acc.Client_code_AN8__c);
          
          if((value == developNameId.get('RCP_ReceiptGeneratedDepositDone_AR')) || (value == developNameId.get('RCP_ReceiptGeneratedDepositDone_UY'))){
            recibo.Status_AR__c= 'Receipt Issued Deposit done';
            if (value == developNameId.get('RCP_ReceiptGeneratedDepositDone_AR')){
              DevelopName = 'RCP_ReceiptGeneratedDepositDone_AR';
            }else{
              DevelopName = 'RCP_ReceiptGeneratedDepositDone_UY';
            }
      }
      
      if((value == developNameId.get('RCP_ReceiptGeneratedDepositPending_AR')) || (value == developNameId.get('RCP_ReceiptGeneratedDepositPending_UY'))){
        recibo.Status_AR__c= 'Receipt Issued Deposit pending';
        if (value == developNameId.get('RCP_ReceiptGeneratedDepositPending_AR')){
          DevelopName = 'RCP_ReceiptGeneratedDepositPending_AR';
        }else{
          DevelopName = 'RCP_ReceiptGeneratedDepositPending_UY';
        }
      }
      
      if((value == developNameId.get('LAT_AR_RCP_ReceiptValueGuarantee'))){
        recibo.Status_AR__c= 'Receipt Value with Guarantee';
        if((value == developNameId.get('LAT_AR_RCP_ReceiptValueGuarantee'))){
          DevelopName = 'LAT_AR_RCP_ReceiptValueGuarantee';
        }
      }
      
      if((value == developNameId.get('Receipt_withholding_certificates_AR'))){
        recibo.Status_AR__c= 'Receipt withholding certificates';
        DevelopName = 'Receipt_withholding_certificates_AR';
      }
      
      if((value == developNameId.get('LAT_AR_RCP_ReceiptOfApplyingDocuments'))){
        recibo.Status_AR__c= 'Receipt of Applying Documents';
        DevelopName = 'LAT_AR_RCP_ReceiptOfApplyingDocuments';
      }
      
      if(acc.CollectionAgent_AR__c != null){
        string idtabela = acc.CollectionAgent_AR__c;
        UDC__c udc =  [SELECT Id,Name FROM UDC__c WHERE id =: idtabela];
        recibo.CollectionAgent_AR__c = udc.Name;
      }
      
      if(recibo.DepositsAmount_AR__c == 0){
        Database.rollback(sp);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, label.VFC01_00001_AR));
        return null;
      }
      
      recibo.recordtypeid = developNameId.get(DevelopName);
      
      try { insert recibo; }catch (exception e) { Database.rollback(sp); ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, decodeMessage(e.getMessage())));return null; }
      
      reciboID = recibo.id;
      
      if(idArray != null && idArray != ''){
        list<id> listIdss= idArray.split(',');
        set<id>setIdsTitulo = new set<id>();
        
        for(id var : listIdss){
          setIdsTitulo.add(var);
        }

        //Cambios
        List<Decimal> payIds = new List<Decimal>();
        List<Id> tmpIds = new List<Id>();

        //Cambios
        for(Titulos__c t : [SELECT id, AN8__c, dataEmissao__c, dataVencimentoAtual__c,dataVencimentoOriginal__c,DeliveryNote_AR__c,Internal_id_pk__c,LegalInvoice_AR__c,Name, NetOpenBalance_AR__c,NetSRReceipts_AR__c,numeroDocumento__c, observacoesTitulo__c,OrderNumber_AR__c,OrderType_AR__c, PaymentID_AR__c,tipoDocumento__c,valorOriginalTitulo__c,valorSaldo__c,ReceiptNumber_AR__c FROM Titulos__c WHERE id IN: setIdsTitulo AND tipoDocumento__c = 'RU']){
            payIds.add(t.PaymentID_AR__c);
        }

        map<Id, Titulos__c> tmpMapIdTitulo = new map<Id, Titulos__c>();

        for(Titulos__c t : [SELECT id, AN8__c, dataEmissao__c, dataVencimentoAtual__c,dataVencimentoOriginal__c,DeliveryNote_AR__c,Internal_id_pk__c,LegalInvoice_AR__c,Name, NetOpenBalance_AR__c,NetSRReceipts_AR__c,numeroDocumento__c, observacoesTitulo__c,OrderNumber_AR__c,OrderType_AR__c, PaymentID_AR__c,tipoDocumento__c,valorOriginalTitulo__c,valorSaldo__c,ReceiptNumber_AR__c FROM Titulos__c WHERE PaymentID_AR__c IN: payIds AND tipoDocumento__c = 'RU' AND NetOpenBalance_AR__c != 0]){
            tmpMapIdTitulo.put(t.id,t);
            if(!setIdsTitulo.contains(t.id))tmpIds.add(t.id);
        }
        //Cambios
        listIdss.addAll(tmpIds);


           
        // hago nu mapa de id a titulo en aberto
        map<Id, Titulos__c> mapIdTitulo = new map<Id, Titulos__c>([SELECT id, AN8__c, dataEmissao__c, dataVencimentoAtual__c,dataVencimentoOriginal__c,DeliveryNote_AR__c,Internal_id_pk__c,LegalInvoice_AR__c,Name, NetOpenBalance_AR__c,NetSRReceipts_AR__c,numeroDocumento__c, observacoesTitulo__c,OrderNumber_AR__c,OrderType_AR__c, PaymentID_AR__c,tipoDocumento__c,valorOriginalTitulo__c,valorSaldo__c,ReceiptNumber_AR__c FROM Titulos__c WHERE id IN: setIdsTitulo]);
        mapIdTitulo.putAll(tmpMapIdTitulo);
          
          
        for(id var : listIdss){
          if((mapIdTitulo.get(var).tipoDocumento__c == 'RU') && (value == developNameId.get('RCP_ReceiptGeneratedDepositPending_AR')) || (value == developNameId.get('RCP_ReceiptGeneratedDepositPending_UY'))){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, label.VFC01_00002_AR));
            return null;
          }
          if((mapIdTitulo.get(var).tipoDocumento__c == 'RU') && (value == developNameId.get('LAT_AR_RCP_ReceiptValueGuarantee'))){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, label.LAT_AR_VFC01_00001));
            return null;
          }
          if((mapIdTitulo.get(var).tipoDocumento__c == 'RU') &&  (mapIdTitulo.get(var).ReceiptNumber_AR__c == null)){
            Titulos__c tit= mapIdTitulo.get(var);
            tit.Ruinusebypendingreceipt_AR__c = recibo.id;
            
            try{ update tit; }catch(Exception e){ Database.rollback(sp); ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,decodeMessage(e.getMessage()))); return null;}
          }
        }
        
        list<DCM_Documents_ARG__c> listadeDOcs = new list<DCM_Documents_ARG__c>();
        
        for(id var : listIdss){
          if(mapIdTitulo.containsKey(var)){
              Titulos__c ti = mapIdTitulo.get(var);
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
              doc.ReceiptNo_AR__c              = recibo.id;
              listadeDOcs.add(doc);
          }
        }

        try {insert listadeDOcs; }catch (exception e) { Database.rollback(sp); ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, decodeMessage(e.getMessage()))); return null; }
        

        list<DPT_Deposit_ARG__c> listadeDepo = new list<DPT_Deposit_ARG__c>();
        Map<String,Double> mapDocs = new Map<String,Double>();

        for(DCM_Documents_ARG__c inDoc: listadeDOcs){
            if(inDoc.tipoDocumento_AR__c == 'RU'){
                String payId = (inDoc.PaymentID_AR__c == null) ? '' : inDoc.PaymentID_AR__c + '';

                if(mapDocs.get(payId) == null){
                  mapDocs.put(payId,inDoc.Amounttoapply_AR__c);
                }else{
                  mapDocs.put(payId, mapDocs.get(payId) + inDoc.Amounttoapply_AR__c);
                }
            }
        }
        for(String pId : mapDocs.keySet()){
          DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c();
          dep.ReceiptNo_AR__c = reciboID;
          dep.From_Document__c = True;
          dep.Comment_AR__c = 'Depósito creado automáticamente.';
          dep.AccType_AR__c = 'Collection Bank Account';
          dep.Date_AR__c = Date.today();
          dep.Amount_AR__c = mapDocs.get(pId);
          if(dep.Amount_AR__c < 0)dep.Amount_AR__c *= -1;
          dep.name = pId;
          listadeDepo.add(dep);
        }


            
        
        try {insert listadeDepo; }catch (exception e) { Database.rollback(sp); ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, decodeMessage(e.getMessage()))); return null; }


      }
        }
        PageReference pag =  new pagereference ('/' + reciboID);
        return pag;
  }
  
  public PageReference cancel() {
        String idAcc=Apexpages.currentPage().getParameters().get('idAcc');
        return new pagereference ('/' + idAcc);
    }
    
    public String decodeMessage(String error){
      if(error.contains('ENTITY_IS_LOCKED')){
        return label.VFC01_00008_AR;
      }
      if(error.contains('REQUIRED_FIELD_MISSING')){
        return 'Faltan campos obligatorios';
      }
      return error;
  }
}