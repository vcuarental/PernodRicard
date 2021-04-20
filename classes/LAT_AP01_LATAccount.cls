/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers de LATPR del objeto LAT_ACCOUNT
*******************************************************************************/
public with sharing class LAT_AP01_LATAccount {
	
	 /*********************************************************************************************************
    * Nombre del metodo: lATAccountCreateCWHAR
    * Descripcion: Creates a LAT_CWH_ClientWorkHour__c for LAT_Account__c
    * Desarrollador: Denis Aranda
    * Fecha: 23/10/2013
    * Modo: After Insert
    *********************************************************************************************************/
    public static void lATAccountCreateCWH(List<LAT_ACCOUNT__c> triggerNew){
        
        List<LAT_CWH_ClientWorkHour__c> listClientWorkHour = new List <LAT_CWH_ClientWorkHour__c>();
        List<Account> listUpdateAcc = new List <Account>();
        
        Id rtAR = Global_RecordTypeCache.getRtId('LAT_ACCOUNT__c'+'LAT_AR_LAC_Standard');
        Id rtUY = Global_RecordTypeCache.getRtId('LAT_ACCOUNT__c'+'LAT_UY_LAC_Standard');
        Id rtBR = Global_RecordTypeCache.getRtId('LAT_ACCOUNT__c'+'LAT_BR_LAC_Standard');
        Id rtMX = Global_RecordTypeCache.getRtId('LAT_ACCOUNT__c'+'LAT_MX_LAC_Standard');
        
        for(LAT_ACCOUNT__c lat: triggerNew){
        	LAT_CWH_ClientWorkHour__c cwh = new LAT_CWH_ClientWorkHour__c(Account__c = lat.LAT_Accountid__c, LATACCOUNT__c = lat.id, AccountId__c = lat.LAT_Accountid__c);
        	if(lat.RecordTypeId == rtAR){
            	cwh.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_CWH_ClientWorkHour__c'+'LAT_AR_CWH_Standard');
        	}else if(lat.RecordTypeId == rtUY){
        		cwh.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_CWH_ClientWorkHour__c'+'LAT_UY_CWH_Standard');
        	}else if(lat.RecordTypeId == rtBR){
        		cwh.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_CWH_ClientWorkHour__c'+'LAT_BR_CWH_Standard');
        	}else if(lat.RecordTypeId == rtMX){
        		cwh.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_CWH_ClientWorkHour__c'+'LAT_MX_CWH_Standard');
        	}
        	listClientWorkHour.add(cwh);
        }
        
        for(LAT_ACCOUNT__c lacc: triggerNew){
            listUpdateAcc.add(new Account(Id = lacc.LAT_Accountid__c, LAT_Account__c = lacc.id ));
        }
        insert listClientWorkHour;
        update listUpdateAcc;
    }
    /*TEST CODE IN LAT_AP01_LATAccount_TEST CLASS*/

}