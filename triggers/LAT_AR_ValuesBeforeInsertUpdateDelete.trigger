/*************************************************************************************************
*           Company: Zimmic    Developer: Nicolás Marán    Fecha: 23/3/2016
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers del objeto VLS_Values_ARG__c
**************************************************************************************************/

trigger LAT_AR_ValuesBeforeInsertUpdateDelete on VLS_Values_ARG__c (before delete,before update) {
      if (trigger.isUpdate){
      	LAT_AR_Values.ValuesCheckPrintStatus(trigger.newMap);
      }

     	if (trigger.isDelete){
       	LAT_AR_Values.ValuesCheckPrintStatus(trigger.oldMap);
      }
}