/*************************************************************************************************
*           Company: Zimmic    Developer: Nicolás Marán    Fecha: 23/3/2016
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers del objeto TXC_TaxCertificates_ARG__c
**************************************************************************************************/

trigger LAT_AR_TaxCertificatesBeforeInsertUpdateDelete on TXC_TaxCertificates_ARG__c (before delete, before update, after insert) {
	


	if (trigger.isUpdate){
      	LAT_AR_TaxCertificates.TaxCertificatesCheckPrintStatus(trigger.newMap);
    }

    if (trigger.isDelete){
       	LAT_AR_TaxCertificates.TaxCertificatesCheckPrintStatus(trigger.oldMap);
    }
	if (trigger.isAfter && trigger.isInsert){
      	LAT_AR_TaxCertificates.updateReceiptBankAccountType(trigger.newMap);
    }
}