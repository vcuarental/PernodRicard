/*******************************************************************************************************************************
* Company:Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del boton: RCP_ConfirmaDeposits_AR
* Descripcion: valida los campos AmountsControl_AR__c y DepositsAmount_AR__c de recibo y que todos los registros de valores tengan
*              un deposito asociado en el campo Deposit_AR__c. Si no hay error modifica el RT. 
* Fecha: 08/04/2013
********************************************************************************************************************************/

global with sharing class BTN08_ConfirmDeposits_AR {
    
    webService static String ConfirmDeposits (Id IdRec) {

        map<Id, RecordType> mapIdRt = new map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='RCP_Receipt_ARG__c']);
        RecordType RecordTypeAR = [SELECT Id FROM RecordType WHERE DeveloperName = 'RCP_ReceiptPrintedDepositDone_AR' AND SobjectType ='RCP_Receipt_ARG__c'];
        RecordType RecordTypeUY = [SELECT Id FROM RecordType WHERE DeveloperName = 'RCP_ReceiptPrintedDepositDone_UY' AND SobjectType ='RCP_Receipt_ARG__c'];
    
        RCP_Receipt_ARG__c receipt = [SELECT Id, RecordTypeId, Status_AR__c, AmountsControl_AR__c, DepositsAmount_AR__c FROM RCP_Receipt_ARG__c WHERE Id =: IdRec];
        list<VLS_Values_ARG__c> listValues = [SELECT Id, Deposit_AR__c FROM VLS_Values_ARG__c WHERE ReceiptNo_AR__c =: IdRec];
        String Error = '';
        Boolean HayError = false;
        Boolean ErrorValues = false;
        
        if(receipt.AmountsControl_AR__c != 0){
            Error = label.BTN08_00001_AR + '\r\n';
            HayError = true;
        }
        if (receipt.DepositsAmount_AR__c == 0){
            Error = Error + label.BTN08_00002_AR + '\r\n';
            HayError = true;
        }                
        
        for (VLS_Values_ARG__c val: listValues){
            if (val.Deposit_AR__c == NULL) {
                if(!ErrorValues){
                    Error = Error + label.BTN08_00003_AR;
                    HayError = true;
                    ErrorValues = true;
                }
            }        
        }
                
        if(HayError == false){
            receipt.Status_AR__c = 'Receipt printed Deposit done';
            if ( mapIdRt.get(receipt.RecordTypeId).DeveloperName =='RCP_ReceiptPrintedDepositPending_AR'){
                receipt.RecordTypeId = RecordTypeAR.Id;
            }
            
            if( mapIdRt.get(receipt.RecordTypeId).DeveloperName =='RCP_ReceiptPrintedDepositPending_UY'){
                receipt.RecordTypeId = RecordTypeUY.Id;
            }
            update receipt;
        }
        system.debug(error);
        return Error;    
    }
    
}