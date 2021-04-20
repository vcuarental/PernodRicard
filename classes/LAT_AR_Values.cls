/*******************************************************************************
*   Company: Zimmic   Developer : Nicolás Marán    Fecha: 23/3/2016
*-------------------------------------------------------------------------------
*   Clase utilizada en los triggers del objeto LAT_AR_Values
*******************************************************************************/


public with sharing class LAT_AR_Values {

/*******************************************************************************
*   Company: Zimmic   Developer : Nicolás Marán    Fecha: 23/3/2016
*-------------------------------------------------------------------------------
*   //Metodo verifica el estado del padre del value para ver si el value puede ser modificado
*******************************************************************************/  

	public static void ValuesCheckPrintStatus(Map<id,VLS_Values_ARG__c> triggerNewMap){
			
		 Map<id,VLS_Values_ARG__c> mapTemp = new Map<id,VLS_Values_ARG__c>([Select id , ReceiptNo_AR__r.Status_AR__c, ReceiptNo_AR__r.Origin__c from VLS_Values_ARG__c where id IN : triggerNewMap.keyset()]);
        
        for (VLS_Values_ARG__c val : triggerNewMap.values()) { 


            String statusReceipt = mapTemp.get(val.id).ReceiptNo_AR__r.Status_AR__c;
            String origenReceipt = mapTemp.get(val.id).ReceiptNo_AR__r.Origin__c;
           
        	 if((statusReceipt == null || Lat_RecieptValidationsUtil.checkBothStatus(statusReceipt)) && BTN12_VlsBtnController_AR.isRelacionarActive == false && origenReceipt != 'APP') 
                    val.addError(Label.LAT_AR_TRIGGER_ValuesForPrintedReceipts);
        }

    }
}