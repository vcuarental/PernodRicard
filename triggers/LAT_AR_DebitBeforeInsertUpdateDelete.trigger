/*************************************************************************************************
*           Company: Zimmic    Developer: Nicolás Marán    Fecha: 23/3/2016
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers del objeto DBT_Debit_ARG__c
**************************************************************************************************/


trigger LAT_AR_DebitBeforeInsertUpdateDelete on DBT_Debit_ARG__c (before delete, before update) {
		if (trigger.isUpdate){
			LAT_AR_Debit.DebitCheckPrintStatus(trigger.newMap);
		}

		if (trigger.isDelete){
			LAT_AR_Debit.DebitCheckPrintStatus(trigger.oldMap);
		}
}