/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Account
*******************************************************************************/

public without sharing class LAT_BR_AP01_AccountWOS {
	
    private static Map<String, UDC__c> mapUdcRegionales;
    private static Map<Id, List<LAT_BR_RegionalConfig__c>> mapMicroRegionalConfigsXUdcId;
	
    /*****************************************************************************************
    * Nombre del metodo: ValidateDuplicatesCNPJ
    * Descripcion: Valida que no se inserten cnpj duplicados.
    * Desarrollador: Tomás Etchegaray
    * Fecha: 21/03/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void validateDuplicatesCNPJ(List<Account> lstAccounts){
        Set<string> setCNPJsOnTrigger = null;
        Set<string> setCNPJsOnTriggerRepeted = null;
        Map<String, Account> mapCNPJAcc = null;
        Set<Id> setIdsRT = null;

        System.debug('validateDuplicatesCNPJ [lstAccounts : ' + lstAccounts + '] ->');
        setCNPJsOnTrigger = new Set<string>();
        setCNPJsOnTriggerRepeted = new Set<string>();

        for(Account objAccount : lstAccounts){
            System.debug('validateDuplicatesCNPJ [objAccount.CNPJ__c : ' + objAccount.CNPJ__c + ']');
            System.debug('validateDuplicatesCNPJ [objAccount.SaveDuplicatedFiscalID_AR__c : ' + objAccount.SaveDuplicatedFiscalID_AR__c + ']');

            if(String.isNotBlank(objAccount.CNPJ__c)){
                if(setCNPJsOnTrigger.contains(objAccount.CNPJ__c)){
                    setCNPJsOnTriggerRepeted.add(objAccount.CNPJ__c);
                }
                setCNPJsOnTrigger.add(objAccount.CNPJ__c);
            } 
        }

        System.debug('validateDuplicatesCNPJ [setCNPJsOnTrigger : ' + setCNPJsOnTrigger + ']');
        System.debug('validateDuplicatesCNPJ [setCNPJsOnTriggerRepeted : ' + setCNPJsOnTriggerRepeted + ']');

        //Verifico que en el mismo lstAccounts no vengan repetidos
        for (Account objAccount : lstAccounts) {
            if(String.isNotBlank(objAccount.CNPJ__c) && setCNPJsOnTriggerRepeted.contains(objAccount.CNPJ__c) && objAccount.SaveDuplicatedFiscalID_AR__c == false){
                objAccount.adderror(Label.AP01_00010_AR + ' ' + objAccount.CNPJ__c);
            }
        }
        
        //Verifico que en la base de datos no haya otro CNPJ igual
        mapCNPJAcc = new Map<String, Account>();
        setIdsRT =  Global_RecordTypeCache.getRtIdSet('Account', AP01_Account_BR.BR_RECORDTYPES);
        
        for(Account objAccount : [SELECT Id, CNPJ__c, OwnerId, Owner.Name, Client_Code_AN8__c FROM Account WHERE CNPJ__c IN: setCNPJsOnTrigger AND RecordTypeId IN: setIdsRT]){
            mapCNPJAcc.put(objAccount.CNPJ__c , objAccount);
        }
        
        if(! mapCNPJAcc.isEmpty()) {
            //Aca se valida que no se esten actualizando una cuenta ya existente con otro CNPJ
            for (Account objAccount : lstAccounts){
                if(String.isNotBlank(objAccount.CNPJ__c)) {
                    if(mapCNPJAcc.containsKey(objAccount.CNPJ__c) && objAccount.Id != mapCNPJAcc.get(objAccount.CNPJ__c).Id && objAccount.SaveDuplicatedFiscalID_AR__c == false) {
                        objAccount.addError(label.AP01_00001_AR + mapCNPJAcc.get(objAccount.CNPJ__c).Client_code_AN8__c + '  -  ' + mapCNPJAcc.get(objAccount.CNPJ__c).Owner.Name);
                    }
                }
            }
        }

        System.debug('validateDuplicatesCNPJ [] <-');
    }

    /*****************************************************************************************
    * Nombre del metodo: completeAgencyAccount
    * Descripcion: Valida que no se inserten cnpj duplicados.
    * Desarrollador: Tomás Etchegaray
    * Fecha: 21/03/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void completeAgencyAccount(List<Account> triggerNew){
        for (Account acc: triggerNew) {
            if (acc.Agency__c != null) {
                Integer agLength = acc.Agency__c.length();
                if (agLength < 4) {
                    for (Integer i = agLength; i < 4; i++) {
                        acc.Agency__c = 0 + acc.Agency__c; 
                    }
                }
            }
        }
    }

    /*********************************************************************************************************
    * Nombre del metodo: completeAgencyAccount
    * Descripcion: Calcultates the Regional and Micro Regional Fields for the Account Object
    * Desarrollador: Zimmic
    * Fecha: 26/04/2019
    * Modo: before update
    *********************************************************************************************************/
    public static void updateRegionalAndMicroRegional(LAT_AccountOneTriggerHandler handler) {
        Map<Id, LAT_Account__c> latAccByAccId = handler.latAccountByAccountId;
        List<Account> triggerNew = handler.getAccountsForRts(AP01_Account_BR.BR_RECORDTYPES);
        Map<Id, Account> triggerOldMap = handler.oldAccountMap;
        List<LAT_Account__c>  lataToUpdate = new List<LAT_Account__c>();

        system.debug('entre metodo OwnerChangedFlagCheck');
        Set<Id> usersInBatch = new Set<Id>();
        for(Account acc: triggerNew){
            usersInBatch.add(acc.OwnerId);
        }

        Map<Id, User> mapUsersById = new Map<Id, User> ([SELECT Id, C_digo_JDE__c FROM User WHERE Id IN :usersInBatch]);
        for(Account acc: triggerNew){
            if(acc.Client_code_An8__C == null && acc.Status__c <> 'Cliente cadastrado no CRM') {
                system.debug('%%%% Cuenta en proceso de Alta/Registro');
                setRegional(acc, mapUsersById.get(acc.OwnerId).C_digo_JDE__c);
                setMicroRegional(acc, mapUsersById.get(acc.OwnerId).C_digo_JDE__c);
                

            } else {
                if (acc.OwnerId != triggerOldMap.get(acc.Id).OwnerId){
                    system.debug('%%%% Cambio el owner de una cuenta ya registrada');
                    setRegional(acc, mapUsersById.get(acc.OwnerId).C_digo_JDE__c);
                    setMicroRegional(acc, mapUsersById.get(acc.OwnerId).C_digo_JDE__c);
                    
                }
            }
            
        }

    }

    public static void setRegionalAndMicroRegional(LAT_AccountOneTriggerHandler handler) {
        List<Account> triggerNew = handler.getAccountsForRts(AP01_Account_BR.BR_RECORDTYPES);

        Set<Id> usersInBatch = new Set<Id>();
        for(Account acc: triggerNew){
            usersInBatch.add(acc.OwnerId);
        }

        Map<Id, User> mapUsersById = new Map<Id, User> ([SELECT Id, C_digo_JDE__c FROM User WHERE Id IN :usersInBatch]);
        for(Account acc: triggerNew){
            if(mapUsersById.get(acc.OwnerId).C_digo_JDE__c != null && mapUsersById.get(acc.OwnerId).C_digo_JDE__c != ''){
                setRegional(acc, mapUsersById.get(acc.OwnerId).C_digo_JDE__c);
                setMicroRegional(acc, mapUsersById.get(acc.OwnerId).C_digo_JDE__c);
            }
            
        }
    }

    public static void setRegional(Account acc, String jde_Code){
        
        if(mapUdcRegionales == null) {
            List<UDC__c> listRegionales = [SELECT ID, Name, CodDefUsuario__c FROM UDC__c WHERE RecordType.Developername = 'BRA_Standard' AND CodUs__c = '01' AND CodProd__c = '01'];
            mapUdcRegionales = new Map<String, UDC__c>();
            for (UDC__c udc : listRegionales){
                mapUdcRegionales.put(udc.CodDefUsuario__c, udc);
            }
        }
        System.debug('%%%% mapUdcRegionales : '+ mapUdcRegionales);

        System.debug('%%%% jde_Code : ' + jde_Code);
        System.debug('%%%% acc.Id : ' + acc.Id);
        if(mapUdcRegionales.get(jde_Code.substring(0, 1)) != null) {
            acc.Regional__c = mapUdcRegionales.get(jde_Code.substring(0, 1)).Id;
        }

    }

    public static void setMicroRegional(Account acc, String jde_Code){

        if(mapMicroRegionalConfigsXUdcId == null) {
            List<LAT_BR_RegionalConfig__c> configs = [SELECT ID, LAT_ExecutiveCode__c, LAT_MicroRegional__c, LAT_Regional__c FROM LAT_BR_RegionalConfig__c];
            mapMicroRegionalConfigsXUdcId = new Map<Id, List<LAT_BR_RegionalConfig__c>>();
            for (LAT_BR_RegionalConfig__c c : configs){
                if(mapMicroRegionalConfigsXUdcId.get(c.LAT_Regional__c) == null) mapMicroRegionalConfigsXUdcId.put(c.LAT_Regional__c, new List<LAT_BR_RegionalConfig__c>());
                mapMicroRegionalConfigsXUdcId.get(c.LAT_Regional__c).add(c);
            }
        }

        if(mapMicroRegionalConfigsXUdcId.get(acc.Regional__c) != null) {
            for(LAT_BR_RegionalConfig__c c : mapMicroRegionalConfigsXUdcId.get(acc.Regional__c)){
                if(c.LAT_ExecutiveCode__c == jde_Code) {
                    acc.LAT_BR_RegionalClientOnPremise__c = c.LAT_MicroRegional__c;
                    break;
                }
            }
        }
    }
}