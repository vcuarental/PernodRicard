/*******************************************************************************
*   Company: Zimmic   Developer : Nicolás Marán    Fecha: 23/3/2016
*-------------------------------------------------------------------------------
*   Clase utilizada en los triggers del objeto LAT_AR_TaxCertificates
*******************************************************************************/
public with sharing class LAT_AR_TaxCertificates {

/*******************************************************************************
*   Company: Zimmic   Developer : Nicolás Marán    Fecha: 23/3/2016
*-------------------------------------------------------------------------------
*   //Metodo verifica el estado del padre del taxCertificate para ver si el taxCertificate puede ser modificado
*******************************************************************************/ 
	public static void TaxCertificatesCheckPrintStatus(MAp<id,TXC_TaxCertificates_ARG__c> triggerNewMap){
			
		 Map<id,TXC_TaxCertificates_ARG__c> mapTemp = new Map<id,TXC_TaxCertificates_ARG__c>([Select id , ReceiptNo_AR__r.Status_AR__c from TXC_TaxCertificates_ARG__c where id IN : triggerNewMap.keyset()]);
        
        for (TXC_TaxCertificates_ARG__c tax : triggerNewMap.values()) { 

            String statusReceipt = mapTemp.get(tax.id).ReceiptNo_AR__r.Status_AR__c;

             if((statusReceipt == null || Lat_RecieptValidationsUtil.checkBothStatus(statusReceipt))
             	&& !Lat_RecieptValidationsUtil.allowUpdate()) 
                    tax.addError(Label.LAT_AR_TRIGGER_TaxCertificateForPrintReciept);
        }

    }
    public static void updateReceiptBankAccountType(MAp<id,TXC_TaxCertificates_ARG__c> triggerNewMap){
        Set<Id> idsRecibos = new Set<Id> ();
        for (TXC_TaxCertificates_ARG__c tax : triggerNewMap.values()) {
            idsRecibos.add(tax.ReceiptNo_AR__c);

        }
        List<RCP_Receipt_ARG__c> toUpdate = [SELECT Id, LAT_AR_DepositAccountType__c FROM RCP_Receipt_ARG__c WHERE id IN :idsRecibos];
        for (RCP_Receipt_ARG__c r : toUpdate) {
            r.LAT_AR_DepositAccountType__c = 'T';
        }
        if (toUpdate.size() > 0) {
            update toUpdate;
        }

    }
}