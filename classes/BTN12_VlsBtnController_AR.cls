/***************************************************************************
*Dev: Tomas Garcia   Version: 1       Consulting: Valuenet  16/05/2013*
****************************************************************************/

global with sharing class BTN12_VlsBtnController_AR {

     
    webService static String idPage(String idDeposito, list<id> idsRegister ){
        
        //Validamos que el parametro idDeposito este correcto
        List<DPT_Deposit_ARG__c> deposito = [SELECT Id,ReceiptNo_AR__c,Amount_AR__c FROM DPT_Deposit_ARG__c WHERE id =:idDeposito];
        RCP_Receipt_ARG__c reciboo = [SELECT Id,Account_AR__c FROM RCP_Receipt_ARG__c WHERE id =: deposito[0].ReceiptNo_AR__c];
        Account acc = [SELECT Id,RecordType.DeveloperName FROM Account WHERE id =:reciboo.Account_AR__c];
        
        if(deposito.isEmpty()){
            return Label.BTN12_00004_AR;            
        }
        
        //Hacemos el query a RecordType y validamos que exista
        RecordType recordtAR = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName ='VLS_tandard_AR'];
        RecordType recordUY = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName ='VLS_Standard_UY'];
        
        Id recordTOfCountry;
        if(acc.RecordType.DeveloperName == 'ACC_1_OffTrade_ARG' || acc.RecordType.DeveloperName == 'ACC_3_OnTrade_ARG' || acc.RecordType.DeveloperName == 'ACC_5_Events_ARG'){
            recordTOfCountry = recordtAR.Id;
        }else if( acc.RecordType.DeveloperName == 'ACC_2_OffTrade_URU' || acc.RecordType.DeveloperName == 'ACC_4_OnTrade_URU' || acc.RecordType.DeveloperName == 'ACC_6_Events_URU'){
            recordTOfCountry = recordUY.Id;
        }else{
            //Msg: RecordType desconocido
            return Label.BTN12_00003_AR;   
        }
        
        //Query a los titulos seleccionados
        map<String, Titulos__c> internaIdpkAndNameMap = new map<String, Titulos__c>();
        List<VLS_Values_ARG__c>values = [SELECT Id,Deposit_AR__c,Amount_AR__c,RecordTypeid FROM VLS_Values_ARG__c WHERE Id =: idsRegister];

        Double SumValueAmount = 0;

        if(values.isEmpty()){
            return Label.BTN12_00002_AR;                       
        }
        
        for(VLS_Values_ARG__c val: values){
            if(val.Deposit_AR__c != null){
                 return Label.BTN12_00005_AR; 
            }
            if  (val.Amount_AR__c != null){
                SumValueAmount =  SumValueAmount + val.Amount_AR__c;
            }
        }
        
        if (SumValueAmount != deposito[0].Amount_AR__c){
            return label.BTN12_00006_AR;
        }
        
        List<VLS_Values_ARG__c> Vals = new List<VLS_Values_ARG__c>();
        
        for(VLS_Values_ARG__c val: values){
            val.Deposit_AR__c = deposito[0].id; 
            val.RecordTypeid =  recordTOfCountry;
        }
        
        String mensajeReturn = '';

        try{
            isRelacionarActive = true;
            update values;   
            return 'OK'; 
        }catch(Exception e){return 'Error: '+e.getMessage();}       
        
        return null;
    }

    public static Boolean isRelacionarActive = false;
    
    @RemoteAction
     global static String relateValues(String idDeposito, list<id> idsRegister ){
        
        //Validamos que el parametro idDeposito este correcto
        List<DPT_Deposit_ARG__c> deposito = [SELECT Id,ReceiptNo_AR__c,Amount_AR__c FROM DPT_Deposit_ARG__c WHERE id =:idDeposito];
        RCP_Receipt_ARG__c reciboo = [SELECT Id,Account_AR__c FROM RCP_Receipt_ARG__c WHERE id =: deposito[0].ReceiptNo_AR__c];
        Account acc = [SELECT Id,RecordType.DeveloperName FROM Account WHERE id =:reciboo.Account_AR__c];
        
        if(deposito.isEmpty()){
            return Label.BTN12_00004_AR;            
        }
        
        //Hacemos el query a RecordType y validamos que exista
        RecordType recordtAR = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName ='VLS_tandard_AR'];
        RecordType recordUY = [SELECT id, DeveloperName FROM RecordType WHERE DeveloperName ='VLS_Standard_UY'];
        
        Id recordTOfCountry;
        if(acc.RecordType.DeveloperName == 'ACC_1_OffTrade_ARG' || acc.RecordType.DeveloperName == 'ACC_3_OnTrade_ARG' || acc.RecordType.DeveloperName == 'ACC_5_Events_ARG'){
            recordTOfCountry = recordtAR.Id;
        }else if( acc.RecordType.DeveloperName == 'ACC_2_OffTrade_URU' || acc.RecordType.DeveloperName == 'ACC_4_OnTrade_URU' || acc.RecordType.DeveloperName == 'ACC_6_Events_URU'){
            recordTOfCountry = recordUY.Id;
        }else{
            //Msg: RecordType desconocido
            return Label.BTN12_00003_AR;   
        }
        
        //Query a los titulos seleccionados
        map<String, Titulos__c> internaIdpkAndNameMap = new map<String, Titulos__c>();
        List<VLS_Values_ARG__c>values = [SELECT Id,Deposit_AR__c,Amount_AR__c,RecordTypeid FROM VLS_Values_ARG__c WHERE Id =: idsRegister];

        Double SumValueAmount = 0;

        if(values.isEmpty()){
            return Label.BTN12_00002_AR;                       
        }
        
        for(VLS_Values_ARG__c val: values){
            if(val.Deposit_AR__c != null){
                 return Label.BTN12_00005_AR; 
            }
            if  (val.Amount_AR__c != null){
                SumValueAmount =  SumValueAmount + val.Amount_AR__c;
            }
        }
        
        if (SumValueAmount != deposito[0].Amount_AR__c){
            return label.BTN12_00006_AR;
        }
        
        List<VLS_Values_ARG__c> Vals = new List<VLS_Values_ARG__c>();
        
        for(VLS_Values_ARG__c val: values){
            val.Deposit_AR__c = deposito[0].id; 
            val.RecordTypeid =  recordTOfCountry;
        }
        
        String mensajeReturn = '';

        try{
            isRelacionarActive = true;
            update values;   
            return 'OK'; 
        }catch(Exception e){return 'Error: '+e.getMessage();}       
        
        return null;
    }
        
     @RemoteAction
     global static List<VLS_Values_ARG__c> getValues(String idDeposito){
        List<DPT_Deposit_ARG__c> deposito = [SELECT Id,ReceiptNo_AR__c,Amount_AR__c FROM DPT_Deposit_ARG__c WHERE id =:idDeposito];
        List<VLS_Values_ARG__c>values = [SELECT Id,Name,ReceiptNo_AR__r.Name,ValueType_AR__c , Bank_AR__c ,Deposit_AR__r.ReceiptNo_AR__c,Amount_AR__c,RecordTypeid FROM VLS_Values_ARG__c WHERE ReceiptNo_AR__c =: deposito[0].ReceiptNo_AR__c and Deposit_AR__c = null];
        return values;
        
    }

    webservice static String getValuesURL(String idRecibo, Double amount) {
        String idCampoAmmount =[SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='Amount_AR__c' AND ObjectApiName__c='VLS_Values_ARG__c'].FieldId__c;
        String idCampoReceipt =[SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='ReceiptNo_AR__c' AND ObjectApiName__c='VLS_Values_ARG__c'].FieldId__c;
        
        return '/' + VLS_Values_ARG__c.getSObjectType().getDescribe().getKeyPrefix() + '/e?'+
                                    idCampoAmmount+'='+encodingUtil.urlEncode(amount.format(), 'UTF-8')+'&'+idCampoReceipt+'='+idRecibo;
    }

    webservice static String createNewDeposit(List<String> idValues, String idRecibo) {
        List<VLS_Values_ARG__c> listValue = [SELECT Id, Name, ReceiptNo_AR__c, ReceiptNo_AR__r.LAT_AR_DepositAccountType__c, ValueType_AR__c , Bank_AR__c, Deposit_AR__c, Amount_AR__c 
                                                FROM VLS_Values_ARG__c WHERE id IN: idValues];

        if (!listValue.isEmpty()) {
            Double totalAmount = 0;

            String depositType = '';
            if(listValue.get(0).ReceiptNo_AR__r.LAT_AR_DepositAccountType__c == 'C'){
                depositType = 'Bank Account';
            }else{
                depositType = 'Collection Bank Account';
            }
            
            String bank = listValue.get(0).Bank_AR__c;

            Boolean errorDeposit =  false;
            Boolean errorBank =  false;

            for (VLS_Values_ARG__c val: listValue) {
                totalAmount += val.Amount_AR__c;
                if (val.Deposit_AR__c != null) {
                    errorDeposit = true;
                }
                if ( bank != val.Bank_AR__c ) {
                    errorBank = true;
                }
            }

            if (!errorDeposit && !errorBank) {
                DPT_Deposit_ARG__c deposit = new DPT_Deposit_ARG__c();
                deposit.ReceiptNo_AR__c = idRecibo;
                deposit.Amount_AR__c = totalAmount;
                deposit.Bank_AR__c = bank;
                deposit.AccType_AR__c = depositType;
                insert deposit;

                for (VLS_Values_ARG__c val: listValue) {
                    val.Deposit_AR__c = deposit.id;
                }

                update listValue;

                return 'OK';
            } else {
                String errorMsg = '';
                if ( errorDeposit ) {
                    errorMsg += '- Uno de los valores selecionados ya pertenece a un deposito  \n';
                }
                if ( errorBank ) {
                    errorMsg += '- Todos los valores selecionados tienen que pertenecer al mismo banco \n';
                }

                return errorMsg;
            }
        } else {
            return 'Porfavor Seleccionar un Valor';
        }
    }
}