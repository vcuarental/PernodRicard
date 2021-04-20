global with sharing class BTN13_Account_Promotion_AR{

    webService static String promoteAccountAR(String idAccount){
    
    string error = '';

    Account acc = [SELECT Id, Name, recordtypeid FROM Account WHERE id=:idAccount];

    String devRecordTypeId = Global_RecordTypeCache.getRtId('Account'+'ACC_3_OnTrade_ARG');

    acc.recordtypeid = devRecordTypeId;

    try{
    	update acc;
    	}catch (Exception e){

    		//system.debug('mensaje ' + e.getMessage());

    		if(e.getMessage().contains('[CNPJ__c]')){
    			error = 'Error: El formato del valor ingresado es incorrecto: [ID Fiscal Nacional]';
    		}else{
    			error = e.getMessage();
    		}
    		
    	}
    
    return error;
    }



}