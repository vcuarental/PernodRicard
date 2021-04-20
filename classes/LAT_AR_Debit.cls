/*******************************************************************************
*   Company: Zimmic   Developer : Nicolás Marán    Fecha: 23/3/2016
*-------------------------------------------------------------------------------
*   Clase utilizada en los triggers del objeto LAT_AR_Debit
*******************************************************************************/
public with sharing class LAT_AR_Debit {
	

/*******************************************************************************
*   Company: Zimmic   Developer : Nicolás Marán    Fecha: 23/3/2016
*-------------------------------------------------------------------------------
*   //Metodo verifica el estado del padre del débito para ver si el débito puede ser modificado
*******************************************************************************/  

	public static void DebitCheckPrintStatus(Map<id,DBT_Debit_ARG__c> triggerNewMap){
			
		 Map<id,DBT_Debit_ARG__c> mapTemp = new Map<id,DBT_Debit_ARG__c>([Select id , ReceiptNo_AR__r.Status_AR__c from DBT_Debit_ARG__c where id IN : triggerNewMap.keyset()]);
        
        for (DBT_Debit_ARG__c deb : triggerNewMap.values()) { 

        	String statusReceipt = mapTemp.get(deb.id).ReceiptNo_AR__r.Status_AR__c;

        	 if(statusReceipt == null || Lat_RecieptValidationsUtil.checkBothStatus(statusReceipt)) 
                    deb.addError(Label.LAT_AR_TRIGGER_DebitForPrintReciept);
        
        }		
	}

	public static void replicateJDE_ID(Map<id,DBT_Debit_ARG__c> triggerNewMap){
		Set<Id> receiptIDs = new Set<ID>();
		for(DBT_Debit_ARG__c deb : triggerNewMap.values()) {
			receiptIDs.add(deb.ReceiptNo_AR__c);
		}

		Map<Id, RCP_Receipt_ARG__c> recs = new Map<Id, RCP_Receipt_ARG__c>([SELECT ID_JDE_Debito__c, Id FROM RCP_Receipt_ARG__c WHERE Id IN:receiptIDs]);
		List<RCP_Receipt_ARG__c> toUpdate = new List<RCP_Receipt_ARG__c>();
		for(DBT_Debit_ARG__c deb : triggerNewMap.values()) {
			if(recs.get(deb.ReceiptNo_AR__c) != null) {
				if(recs.get(deb.ReceiptNo_AR__c).ID_JDE_Debito__c != deb.LAT_AR_IntegrationStatus__c){
					recs.get(deb.ReceiptNo_AR__c).ID_JDE_Debito__c = deb.LAT_AR_IntegrationStatus__c;
					toUpdate.add(recs.get(deb.ReceiptNo_AR__c));
				}
			}
		}

		if(toUpdate.size() > 0) {
			update toUpdate;
		}

	}

}