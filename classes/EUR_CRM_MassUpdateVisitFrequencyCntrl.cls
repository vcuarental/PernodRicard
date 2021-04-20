/*
*   EUR_CRM_MassUpdateVisitFrequencyCntrl
*   Controller of : EUR_CR<_MassUpdateVisitFrequency.Component
*
*   Calls the batch file to mass update account's visit frequencies 
*/
public class EUR_CRM_MassUpdateVisitFrequencyCntrl {

    public string countryCodeStr {get;set;}

    public EUR_CRM_MassUpdateVisitFrequencyCntrl(){}

    public void updateVF(){
        try{
            EUR_CRM_MassUpdateVisitFrequencyBatch batch = new EUR_CRM_MassUpdateVisitFrequencyBatch(countryCodeStr);
            Database.executeBatch(batch, 200);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Batch job has been successfully submitted. You will receive a notification when the job is finished.'));
        }catch(Exception ex){
            System.debug('Exception: ' + ex);
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Fatal, ex.getMessage()));
        }
    }
}