/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers del objeto RCP_Receipt_ARG__c
*******************************************************************************/

global with sharing class AP01_Receipt_AR {


    /*****************************************************************************************
    * Nombre del metodo: UpdateCurrency
    * Descripcion: Metodo que asigna al recibo el tipo de moneda que utiliza el cliente
    * Desarrollador: Tomás Etchegaray
    * Fecha: Date:04/04/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void UpdateCurrency (List<RCP_Receipt_ARG__c> triggerNew){
        set<Id> setParentIdsAcc = new set<Id>();
        for(RCP_Receipt_ARG__c rec : triggerNew){
            setParentIdsAcc.add(rec.Account_AR__c);
        }

        map<Id, Account> mapParentAccount = new map<Id, Account>([SELECT Id, CurrencyIsoCode, CollectionAgent_AR__r.Name, CollectionAgent_AR__c, Client_code_AN8__c FROM Account WHERE Id IN: setParentIdsAcc]);

        for(RCP_Receipt_ARG__c rec : triggerNew){
            rec.CurrencyIsoCode = mapParentAccount.get(rec.Account_AR__c).CurrencyIsoCode;
            if(trigger.isInsert){
                rec.Date_AR__c = date.today();
                rec.AN8_AR__c = mapParentAccount.get(rec.Account_AR__c).Client_code_AN8__c;
                rec.CollectionAgent_AR__c = mapParentAccount.get(rec.Account_AR__c).CollectionAgent_AR__r.Name;
            }
        }
    }

     /*****************************************************************************************
    * Nombre del metodo: UpdateName
    * Descripcion: Metodo que asigna el siguiente numero disponible al name
    * Desarrollador: Zimmic
    * Fecha: Date:19/03/2015
    * Modo: before insert
    *****************************************************************************************/
    public static void updateName (List<RCP_Receipt_ARG__c> triggerNew){
        RCP_Receipt_ARG__c receiptNew;
        if(triggerNew != null && triggerNew.size() > 0){
            receiptNew = triggerNew[0];
        }

        if(receiptNew != null && receiptNew.origin__c != 'APP'){
            List<LAT_Receipt_Range__c> lstRange = [SELECT id,user__c,origin__c,nextNumber__c,limitNumber__c from LAT_Receipt_Range__c where origin__c = 'WEB' order by nextNumber__c];

            if(lstRange != null && lstRange.size() > 0){
                LAT_Receipt_Range__c range;
                for(LAT_Receipt_Range__c ran : lstRange){
                    if(ran.nextNumber__c <= ran.limitNumber__c){
                        range = ran;
                        break; 
                    }
                }
                if(range != null){
                    for(RCP_Receipt_ARG__c rc : triggerNew){
                        if(range.nextNumber__c <= range.limitNumber__c){
                            rc.name = String.valueOf(range.nextNumber__c);
                            range.nextNumber__c += 1;
                        }else{
                            rc.addError(Label.LAT_AR_AP01_RCP_003);
                        }
                    }
                    update lstRange;
                }else{
                    triggerNew[0].addError(Label.LAT_AR_AP01_RCP_003);
                }
            }else{
                List<LAT_GeneralConfig__c> lstConfig = [Select id,LAT_Value__c,name from LAT_GeneralConfig__c where name = 'RECEIPT_NRO' for update];
               if(lstConfig != null && lstConfig.size() > 0){
                    LAT_GeneralConfig__c config = lstConfig[0];
                    integer receiptNro = Integer.valueOf(config.LAT_Value__c);
                    for(RCP_Receipt_ARG__c rc : triggerNew){
                        receiptNro += 1;
                        rc.name = String.valueOf(receiptNro);
                    }
                    config.LAT_Value__c = String.valueOf(receiptNro);
                    update config;

                    //LAT_Receipt_Range__c ran = createRange('WEB', receiptNro , null);
                    //ran.nextNumber__c += 1;
                    //insert ran;
                    
                }
            }
        }else{
            updateMobileReceipt(receiptNew);
        }
    }



    public static void updateMobileReceipt(RCP_Receipt_ARG__c receiptNew){
        List<LAT_Receipt_Range__c> lstRange;
        if(receiptNew.name != null){
            lstRange = [SELECT id,user__c,origin__c,nextNumber__c,limitNumber__c from LAT_Receipt_Range__c where user__c =: UserInfo.getUserId() and origin__c = 'APP' AND nextNumber__c >=: Integer.valueOf(receiptNew.name) order by nextNumber__c];
        }

        if(lstRange != null && lstRange.size() > 0){
            if(Integer.valueOf(receiptNew.name) + 10 > lstRange[0].limitNumber__c){
                if(lstRange.size() == 1){
                    LAT_Receipt_Range__c maxRange = [SELECT id,user__c,origin__c,nextNumber__c,limitNumber__c from LAT_Receipt_Range__c order by limitNumber__c desc limit 1];

                    insert createRange('APP', UserInfo.getUserId()); 
                }
            }
        }
    }

    public static void validateMobileRange(List<LAT_Receipt_Range__c> triggerNew) {

        for (LAT_Receipt_Range__c rr : triggerNew) {
            if (rr.Origin__c == 'APP') {
                if (rr.nextNumber__c + 10 > rr.limitNumber__c) {
                    if (rr.nextNumber__c > rr.limitNumber__c) {
                        rr.Finished__c = true;
                    }
                    List<LAT_Receipt_Range__c> used =  [SELECT id,User__c,Origin__c,NextNumber__c,LimitNumber__c FROM LAT_Receipt_Range__c 
                                                        WHERE User__c =: rr.User__c AND Origin__c = 'APP' AND NextNumber__c >=: rr.NextNumber__c AND id != :rr.Id];
                    if (used.size() == 0) {
                        insert createRange('APP', rr.User__c);
                    }
                }
            }
        }
    }

    public static LAT_Receipt_Range__c  createRange(String origin, String ownerId){
        LAT_GeneralConfig__c numeroAPP = [Select id,LAT_Value__c,name from LAT_GeneralConfig__c where name = 'RECEIPT_NRO_APP'];
        Decimal value = Decimal.valueOf(numeroAPP.LAT_Value__c);
        LAT_Receipt_Range__c range = new LAT_Receipt_Range__c();
        range.firstNumber__c = value;
        range.nextNumber__c = value;
        range.limitNumber__c = value + 49;
        range.origin__c = origin;
        if(ownerId != null)range.user__c = ownerId;

        numeroAPP.LAT_Value__c = String.valueOf(value + 50);
        update numeroAPP;
        return range;
    }

    /*****************************************************************************************
   * Nombre del metodo: validateCreation
   * Descripcion: Metodo que valida si el customSetting allowCreateReceipt = True
   * Desarrollador: Zimmic
   * Fecha: Date:19/07/2015
   * Modo: before insert
   *****************************************************************************************/
   public static void validateCreation (List<RCP_Receipt_ARG__c> triggerNew){
      Boolean tmpAllow = True;
      String[] allow = LAT_GeneralConfigDao.getValueAsStringArray('ALLOW_CREATE_RECEIPT', ' ');
      try{
        if(allow != null && allow.size()>0)tmpAllow = Boolean.valueOf(allow[0]);
      }catch(Exception ex){

      }
      for(RCP_Receipt_ARG__c rec : triggerNew){
          if(!tmpAllow)rec.addError(Label.LAT_AR_AP01_RCP_002);
      }
   }


     /*****************************************************************************************
    * Nombre del metodo: maintainName
    * Descripcion: Metodo que mantiene el nombre anterior al modificar el recibo
    * Desarrollador: Zimmic
    * Fecha: Date:19/03/2015
    * Modo: before insert
    *****************************************************************************************/

    public static void maintainName (List<RCP_Receipt_ARG__c> triggerNew, List<RCP_Receipt_ARG__c> triggerOld){
        for(integer i = 0; i < triggerNew.size(); i++){
            triggerNew[i].name = triggerOld[i].name;
        }

    }

     /*****************************************************************************************
    * Nombre del metodo: validateCancel
    * Descripcion: Metodo que valida la cancelacion del recibo
    * Desarrollador: Zimmic
    * Fecha: Date:12/08/2016
    * Modo: before update
    *****************************************************************************************/

    public static void validateCancel (List<RCP_Receipt_ARG__c> triggerNew, List<RCP_Receipt_ARG__c> triggerOld){

        for(integer i = 0; i < triggerOld.size(); i++){
            RCP_Receipt_ARG__c recOld = triggerOld[i];
            RCP_Receipt_ARG__c recNew = triggerNew[i];
            List<DCM_Documents_ARG__c> listDocs = new List<DCM_Documents_ARG__c>();
            List<Titulos__c> listTitulos = new List<Titulos__c>();

            if(recNew.Status_AR__c == 'Receipt sent cancel mobile' && recOld.Status_AR__c != 'Receipt sent cancel mobile'){
                if(recOld.Status_AR__c == 'Receipt cancelled'){
                    recNew.addError(label.LAT_AR_BTN02_00001);
                }else if(recOld.Status_AR__c == 'Receipt Sent to Treasury' || recOld.Status_AR__c == 'Receipt Verified'){
                    recNew.addError(label.LAT_AR_BTN02_00002);
                    //LAT_AR_BTN02_00002: Este Recibo no puede ser anulado pues ya está con la área de Tesorería.
                }else{
                    recNew.Status_AR__c = 'Receipt cancelled';
                    recNew.RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'LAT_AR_RCP_ReceiptCancelled');
                    
                }
            }
        }



    }


    public static void receiptCanceled (List<RCP_Receipt_ARG__c> triggerNew, List<RCP_Receipt_ARG__c> triggerOld){ 
        System.debug('%%%%%%%%%%% Ingresamos en receiptCanceled');
        for(integer i = 0; i < triggerOld.size(); i++){
            
            RCP_Receipt_ARG__c recOld = triggerOld[i];
            RCP_Receipt_ARG__c recNew = triggerNew[i];
            System.debug('%%%%%%%%%%% Id Recibo old: ' +  recOld);
            System.debug('%%%%%%%%%%% Id Recibo new: ' + recNew);
            List<DCM_Documents_ARG__c> listDocs = new List<DCM_Documents_ARG__c>();
            List<Titulos__c> listTitulos = new List<Titulos__c>();

            if(recNew.Status_AR__c == 'Receipt cancelled' && recOld.Status_AR__c != 'Receipt cancelled'){
                listDocs = [SELECT Id, Amounttoapply_AR__c, Internal_id_pk_AR__c FROM DCM_Documents_ARG__c WHERE ReceiptNo_AR__c =: recNew.Id];
               Set<String> setInternalIdPk = new Set<String>();
                for(DCM_Documents_ARG__c doc: listDocs ){
                    doc.Amounttoapply_AR__c = 0;
                    setInternalIdPk.add(doc.Internal_id_pk_AR__c);
                }
                if(!setInternalIdPk.isEmpty()){
                    listTitulos = [SELECT Id, Internal_id_pk__c, Ruinusebypendingreceipt_AR__c FROM Titulos__c WHERE Ruinusebypendingreceipt_AR__c =: recNew.Id];
                    if(!listTitulos.isEmpty()){
                        for(Titulos__c titulo: listTitulos){
                            titulo.Ruinusebypendingreceipt_AR__c = null;
                        }
                    }
                }
                try{
                    if(!listDocs.isEmpty()){
                        update listDocs;
                    }
                    if(!listTitulos.isEmpty()){
                        update listTitulos;
                    }
                }catch(DMLException e){
                    recNew.addError('Error: ' + e.getMessage());
                }
                
            }
        }

    }

     /*****************************************************************************************
    * Nombre del metodo: validateRedeemed
    * Descripcion: Metodo que valida la rendicion del recibo
    * Desarrollador: Zimmic
    * Fecha: Date:12/08/2016
    * Modo: before update
    *****************************************************************************************/

    public static void validateRedeemed (List<RCP_Receipt_ARG__c> triggerNew, List<RCP_Receipt_ARG__c> triggerOld){
        
       
        Boolean updateFlag = false;
        
        CS003_ReceiptRedemptionNo_ARG__c csRnum = CS003_ReceiptRedemptionNo_ARG__c.getOrgDefaults();

        integer RedemptionNo;
        if(csRnum.Id == null){
            AggregateResult maximo = [SELECT MAX(RedemptionNo_AR__c) max FROM RCP_Receipt_ARG__c];
            if(maximo.get('max') != null){
                RedemptionNo = integer.valueOf(String.ValueOf(maximo.get('max')).substring(2, 10));
            }else{
                RedemptionNo = Integer.ValueOf(csRnum.RedemptionNo__c);
            }
        }else{
            RedemptionNo = Integer.ValueOf(csRnum.RedemptionNo__c);
        }
        
        

        for(integer i = 0; i < triggerOld.size(); i++){
            RCP_Receipt_ARG__c recOld = triggerOld[i];
            RCP_Receipt_ARG__c recNew = triggerNew[i];
            if(recNew.Status_AR__c == 'Sent to Redeem Mobile' && recOld.Status_AR__c != 'Sent to Redeem Mobile'){
                if(!BTN01_RCPRedeemedBtnController_AR.checkAllowReceiptCreation()){
                    triggerNew[0].addError(Label.LAT_AR_AP01_RCP_002);
                }
                if(recOld.Status_AR__c == 'Receipt printed Deposit done' || recOld.Status_AR__c == 'Receipt printed with Value in Custody'){
                    recNew.Status_AR__c = 'Receipt Sent to Treasury';
                    RedemptionNo++;
                    updateFlag = true;
                    recNew.RedemptionNo_AR__c = getRedemptionNoString(RedemptionNo);
                    recNew.RedemptionDateTime_AR__c = Datetime.now();
                }else if(recOld.Status_AR__c == 'Receipt of Applying Documents'){
                    recNew.Status_AR__c = 'Receipt Verified';
                    RedemptionNo++;
                    updateFlag = true;
                    recNew.RedemptionNo_AR__c = getRedemptionNoString(RedemptionNo);
                    recNew.RedemptionDateTime_AR__c = Datetime.now();
                }else{
                    recNew.addError(Label.BTN01_00002_AR);
                }
            }
        }

        if(updateFlag){
            csRnum.RedemptionNo__c = RedemptionNo;
            upsert csRnum;
        }

    }

    public static String getRedemptionNoString(integer RedemptionNo){
        String RedemptionNoString = 'RE';
        for(Integer i=(String.valueOf(RedemptionNo).length()); i<=7;i++){
            RedemptionNoString += '0';
        }
        return RedemptionNoString + RedemptionNo;
    }




    /*****************************************************************************************
    * Nombre del metodo: UpdateReceiptType
    * Descripcion: keeps the type the same for all the Deposits
    * Desarrollador: Denis Aranda
    * Fecha: Date: 14/05/2014
    * Modo: after update
    *****************************************************************************************/
    public static void UpdateReceiptType (List<RCP_Receipt_ARG__c> triggerNew, Map<Id, RCP_Receipt_ARG__c> triggerOld){
        /*List<String> listIdReceipts = new List<String>();

        for(RCP_Receipt_ARG__c rec: triggerNew){
            if(rec.LAT_AR_DepositAccountType__c != triggerOld.get(rec.Id).LAT_AR_DepositAccountType__c){
                listIdReceipts.add(rec.id);
            }
        }
        system.debug('listIdReceipts: ' + listIdReceipts);

        if(listIdReceipts.size()>0){
            Map<Id, List<DPT_Deposit_ARG__c>> mapIdToDep = new Map<Id, List<DPT_Deposit_ARG__c>>();
            List<DPT_Deposit_ARG__c> listDeposits = [SELECT id, Name, AccType_AR__c, ReceiptNo_AR__c FROM DPT_Deposit_ARG__c WHERE ReceiptNo_AR__c IN: listIdReceipts];
            List<DPT_Deposit_ARG__c> listDepToUpdate = new List<DPT_Deposit_ARG__c>();

            for(DPT_Deposit_ARG__c dep: listDeposits){
                if(mapIdToDep.containsKey(dep.ReceiptNo_AR__c)){
                    mapIdToDep.get(dep.ReceiptNo_AR__c).add(dep);
                }else{
                    mapIdToDep.put(dep.ReceiptNo_AR__c, new List<DPT_Deposit_ARG__c>{dep});
                }
            }

            for(RCP_Receipt_ARG__c rec: triggerNew){
                if(mapIdToDep.containsKey(rec.id)){
                    for(DPT_Deposit_ARG__c dep: mapIdToDep.get(rec.id)){
                        if(rec.LAT_AR_DepositAccountType__c == 'C' && dep.AccType_AR__c != 'Bank Account'){
                            dep.AccType_AR__c = 'Bank Account';
                            listDepToUpdate.add(dep);
                        }
                        if(rec.LAT_AR_DepositAccountType__c == 'R' && dep.AccType_AR__c != 'Collection Bank Account'){
                            dep.AccType_AR__c = 'Collection Bank Account';
                            listDepToUpdate.add(dep);
                        }
                    }
                }
            }
            system.debug('listDepToUpdate: ' +listDepToUpdate);
            //try{update listDepToUpdate;}catch(System.DmlException e){}
            update listDepToUpdate;
        }
*/
    }

    /*****************************************************************************************
    * Nombre del metodo: ReceiptToJDE
    * Descripcion: Sends receipts and relations to JDE
    * Desarrollador: Denis Aranda
    * Fecha: Date: 16/05/2014
    * Modo: after update
    *****************************************************************************************/
    public static void ReceiptToJDE (List<RCP_Receipt_ARG__c> triggerNew, Map<Id, RCP_Receipt_ARG__c> triggerOld){

        List<String> listIdReceipts = new List<String>();


        for(RCP_Receipt_ARG__c rec: triggerNew){
            if(rec.RecordTypeId != Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'LAT_AR_RCP_ReceiptOfApplyingDocuments') && rec.Status_AR__c == 'Receipt Verified' && rec.Status_AR__c != triggerOld.get(rec.Id).Status_AR__c){
                listIdReceipts.add(rec.id);
            }
        }

        if(listIdReceipts.size()>0){

            Set<Id> setRecIdOfSons = new Set<Id>();

            // Query of the Sons of Receipts
            List<TXC_TaxCertificates_ARG__c> listTaxCert =  [SELECT id, Name, WithhRecordedinJDE_AR__c, ReceiptNo_AR__c FROM TXC_TaxCertificates_ARG__c WHERE ReceiptNo_AR__c IN: listIdReceipts];
            List<DPT_Deposit_ARG__c> listDeposits =         [SELECT id, Name, LAT_AR_DepositRecordedJDE__c, ReceiptNo_AR__c FROM DPT_Deposit_ARG__c WHERE ReceiptNo_AR__c IN: listIdReceipts];
            List<VLS_Values_ARG__c> listValues =            [SELECT id, Name, ValueRecordedinJDE_AR__c, ReceiptNo_AR__c FROM VLS_Values_ARG__c WHERE ReceiptNo_AR__c IN: listIdReceipts];


            for(TXC_TaxCertificates_ARG__c tax: listTaxCert){
                if(!setRecIdOfSons.contains(tax.ReceiptNo_AR__c)){
                    setRecIdOfSons.add(tax.ReceiptNo_AR__c);
                }

            }

            for(DPT_Deposit_ARG__c dep: listDeposits){
                if(!setRecIdOfSons.contains(dep.ReceiptNo_AR__c)){
                    setRecIdOfSons.add(dep.ReceiptNo_AR__c);
                }
            }

            for(VLS_Values_ARG__c val: listValues){
                if(!setRecIdOfSons.contains(val.ReceiptNo_AR__c)){
                    setRecIdOfSons.add(val.ReceiptNo_AR__c);
                }
            }

            for(RCP_Receipt_ARG__c rec: triggerNew){
                if(setRecIdOfSons.contains(rec.Id)){
                    LAT_AR_WS01_ReceiptHandlerInterface.ReceiptInterfaceJDE(rec.Id);
                }
            }

        }
    }
    /**********************************************************************************************************
    * Nombre del metodo: ValidatesDepositAccountType
    * Descripcion: checks that there is no value with type '0' when DepositAccountType is updated to 'R'
    * Desarrollador: Denis Aranda
    * Fecha: Date: 23/06/2014
    * Modo: before update
    **********************************************************************************************************/
    public static void ValidatesDepositAccountType (List<RCP_Receipt_ARG__c> triggerNew, Map<Id, RCP_Receipt_ARG__c> triggerOld){

        Map<String, VLS_Values_ARG__c> mapReceiptsIdToValue = new Map<String, VLS_Values_ARG__c>();
        List<String> listIdReceipts = new List<String>();

        for(RCP_Receipt_ARG__c rec: triggerNew){
            if(rec.LAT_AR_DepositAccountType__c == 'R'  && rec.LAT_AR_DepositAccountType__c != triggerOld.get(rec.Id).LAT_AR_DepositAccountType__c){
                listIdReceipts.add(rec.Id);
            }
        }

        List<VLS_Values_ARG__c> listDeposits = [SELECT id, Name, ValueType_AR__c, ReceiptNo_AR__c FROM VLS_Values_ARG__c WHERE ReceiptNo_AR__c IN: listIdReceipts AND ValueType_AR__c = '0'];

        for(VLS_Values_ARG__c dep: listDeposits){
            if(!mapReceiptsIdToValue.containsKey(dep.Id)){
                mapReceiptsIdToValue.put(dep.ReceiptNo_AR__c, dep);
            }
        }

        for(RCP_Receipt_ARG__c rec: triggerNew){
            if(mapReceiptsIdToValue.containsKey(rec.Id)){
                rec.addError(Label.LAT_AR_AP01_RCP_001);
            }
        }
    }


    public static String  ValidarRecibosRendidos() {
        List<RCP_Receipt_ARG__c> toValidate = [SELECT Id, LAT_ValidationStatus__c, Validation_Error_Message__c, Discount_AR__c, Comercial_Discount__c, LAT_AR_DepositAccountType__c,
                                                (SELECT Id, Name, Amount_AR__c FROM Deposits__r),
                                                (SELECT Id, PaymentID_AR__c, Amounttoapply_AR__c, TipoDocumento_AR__c FROM Documents__r WHERE TipoDocumento_AR__c = 'RU')
                                                FROM RCP_Receipt_ARG__c WHERE LAT_ValidationStatus__c != 'Validado' and  LAT_ValidationStatus__c != 'Validado CC' 
                                                AND LAT_ValidationStatus__c != 'Validado Ret' ORDER BY LastModifieddate DESC LIMIT 100];
        System.debug('%%%%%%% Ahora entramos en el LAT_AR_RestBTN01_RCPRedeemedBtn con toValidate.size() : '+toValidate.size());
        //List<RCP_Receipt_ARG__c> toUpdate = new List<RCP_Receipt_ARG__c>();
        for (RCP_Receipt_ARG__c recibo : toValidate) {

            System.debug('%%%%%%%%%%% estamos en for'+ recibo);
            if (recibo.LAT_AR_DepositAccountType__c == 'C') {
                System.debug('%%%%%%%%%%% estamos en C '+ recibo.id);
                recibo.LAT_ValidationStatus__c = 'Validado CC';
                recibo.Validation_Error_Message__c = '';
            } else {
                if (recibo.LAT_AR_DepositAccountType__c == 'T') {
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

    /**********************************************************************************************************
    * Nombre del metodo: ValidateVerifiedStatus
    * Descripcion: checks that if the Receipt has been Verified, it is not possible to revert the Status to Sent to Treasury, 
    * Desarrollador: Zimmic
    * Fecha: Date: 19/09/2017
    * Modo: before update
    **********************************************************************************************************/
    public static void ValidateStatus(List<RCP_Receipt_ARG__c> triggerNew, Map<Id, RCP_Receipt_ARG__c> triggerOld){

        Map<String, VLS_Values_ARG__c> mapReceiptsIdToValue = new Map<String, VLS_Values_ARG__c>();
        List<String> listIdReceipts = new List<String>();
        for(RCP_Receipt_ARG__c rec: triggerNew){
            if(rec.Status_AR__c == 'Receipt Sent to Treasury' && triggerOld.get(rec.Id).Status_AR__c == 'Receipt Verified'){
                rec.addError(Label.LAT_AR_AP01_RCP_004);
            }
        }

    }

    public Static void mantainInvoiceRelatedList(List<RCP_Receipt_ARG__c> triggerNew, Map<Id, RCP_Receipt_ARG__c> triggerOld){
        List<RCP_Receipt_ARG__c> changed   = new List<RCP_Receipt_ARG__c>();
        for (RCP_Receipt_ARG__c receipt : triggerNew) {
            if (receipt.Downpayments_AR__c != triggerOld.get(receipt.Id).Downpayments_AR__c) {
                changed.add(receipt);
            } else if (receipt.Discount_AR__c != triggerOld.get(receipt.Id).Discount_AR__c) {
                changed.add(receipt);
            } else if (receipt.Comercial_Discount__c != triggerOld.get(receipt.Id).Comercial_Discount__c) {
               changed.add(receipt);
            }  
        }
        if (changed.size() > 0) {
            upsertLAT_Invoices(changed);
        }

    }


    public static void upsertLAT_Invoices(List<RCP_Receipt_ARG__c> receipts) {
        Set<Id> recIds = new Set<Id>();
        for (RCP_Receipt_ARG__c r : receipts) {
            recIds.add(r.Id);
        }

        List<LAT_Invoice__c> existingInv = [SELECT Id, Name, LAT_IdCrmDoc__c, LAT_IdCRMval__c, LAT_InvoiceAmount__c, LAT_InvoiceExplanation__c, LAT_InvoiceNumber__c,
                                             LAT_InvoiceTaxableAmount__c, LAT_InvoiceTaxAmount__c, LAT_InvoiceType__c, LAT_Receipt__c
                                             FROM LAT_Invoice__c 
                                             Where LAT_Receipt__c IN: recIds];
        Map<String, LAT_Invoice__c> mapExistingInvoice = new Map<String, LAT_Invoice__c>();
        for (LAT_Invoice__c i : existingInv) {
            mapExistingInvoice.put(i.LAT_Receipt__c+'-'+i.LAT_InvoiceType__c, i);
        }
        List<LAT_Invoice__c> listToUpsert = new List<LAT_Invoice__c>();
        for (RCP_Receipt_ARG__c r : receipts) {

            LAT_Invoice__c invAt = new LAT_Invoice__c();
            if (mapExistingInvoice.get(r.id + '-AT') != null) {
                invAt = mapExistingInvoice.get(r.id + '-AT');
            } else {
                invAt.LAT_Receipt__c              = r.Id;
            }
            if (r.Downpayments_AR__c > 0) {
                invAt.LAT_InvoiceAmount__c        = String.valueOf(r.Downpayments_AR__c*(-1));
            } else {
                invAt.LAT_InvoiceAmount__c        = null;
            }   
            invAt.LAT_InvoiceTaxableAmount__c = invAt.LAT_InvoiceAmount__c;
            invAt.LAT_InvoiceTaxAmount__c     = '0';
            invAt.LAT_InvoiceType__c          = 'AT';
            invAt.LAT_IdCrmDoc__c             = r.Name + 'AT';
            invAt.LAT_InvoiceExplanation__c   = 'Anticipo de Clientes';
            listToUpsert.add(invAt);


            LAT_Invoice__c invDF = new LAT_Invoice__c();
            if (mapExistingInvoice.get(r.id + '-DF') != null) {
                invDF = mapExistingInvoice.get(r.id + '-DF');
            } else {
                invDF.LAT_Receipt__c              = r.Id;
            }
            if (r.Discount_AR__c > 0) {
                invDF.LAT_InvoiceAmount__c        = String.valueOf(r.Discount_AR__c*(-1));
                Double dblDiscountDf              = r.Discount_AR__c / 1.21*(-1);
                invDF.LAT_InvoiceTaxableAmount__c = String.valueOf(Decimal.valueOf(dblDiscountDf).setScale(2));
                Decimal decTaxAmountDf            = (Decimal.valueOf(invDF.LAT_InvoiceAmount__c) - Decimal.valueOf(invDF.LAT_InvoiceTaxableAmount__c)).setScale(2);
                invDF.LAT_InvoiceTaxAmount__c     = String.valueOf(decTaxAmountDf);
            } else {
                invDF.LAT_InvoiceAmount__c        = null;
            } 
            invDF.LAT_InvoiceType__c          = 'DF';
            invDF.LAT_IdCrmDoc__c             = r.Name + 'DF';
            invDF.LAT_InvoiceExplanation__c   = 'Dto. Pronto Pago Rec. ' + r.Name;
            listToUpsert.add(invDF);
            

            LAT_Invoice__c invDC = new LAT_Invoice__c();
            if (mapExistingInvoice.get(r.id + '-DC') != null) {
                invDC = mapExistingInvoice.get(r.id + '-DC');
            } else {
                invDC.LAT_Receipt__c              = r.Id;
            }
            
            if (r.Comercial_Discount__c > 0) {
                invDC.LAT_InvoiceAmount__c        = String.valueOf(r.Comercial_Discount__c*(-1));
                Double dblDiscountDc              = r.Comercial_Discount__c / 1.21*(-1);
                invDC.LAT_InvoiceTaxableAmount__c = String.valueOf(Decimal.valueOf(dblDiscountDc).setScale(2));
                Decimal decTaxAmountDc            = (Decimal.valueOf(invDC.LAT_InvoiceAmount__c) - Decimal.valueOf(invDC.LAT_InvoiceTaxableAmount__c)).setScale(2);
                invDC.LAT_InvoiceTaxAmount__c     = String.valueOf(decTaxAmountDc);
            } else {
                invDC.LAT_InvoiceAmount__c        = null;
            }  
            invDC.LAT_InvoiceType__c          = 'DC';
            invDC.LAT_IdCrmDoc__c             = r.Name + 'DC';
            invDC.LAT_InvoiceExplanation__c   = 'Dto. Pronto Pago Rec. ' + r.Name;
            listToUpsert.add(invDC);
        }

        if (listToUpsert.size() > 0) {
            upsert listToUpsert;
        }

    }

    webservice static String manuallyAdjustReceipt(String idSalesforce) {
        String retorno = '';
        LAT_GeneralConfig__c gc = [SELECT LAT_Value__c FROM LAT_GeneralConfig__c WHERE Name = 'AR_MANUAL_INTEGRATE_RECEIPTS' LIMIT 1];
        if(gc.LAT_Value__c.contains(UserInfo.getName())) {
            RCP_Receipt_ARG__c rec = [SELECT Id, LAT_AR_IntegrationStatus__c FROM RCP_Receipt_ARG__c WHERE Id =:idSalesforce];
            if(rec.LAT_AR_IntegrationStatus__c != 'Registered in JDE') {
                rec.LAT_AR_IntegrationStatus__c = 'Manually Registered in JDE';
                update rec;
                retorno = 'Recibo actualizado correctamente.';
            } else {
                retorno = 'El recibo ya se encuentra Integrado correctamente en JDE.';
            }
        } else {
            retorno = 'Únicamente los siguientes usuarios pueden integrar recibos manualmente : \n' + gc.LAT_Value__c;
        }

        return retorno;
    }

}