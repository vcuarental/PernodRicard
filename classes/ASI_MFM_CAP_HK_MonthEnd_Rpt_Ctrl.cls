public class ASI_MFM_CAP_HK_MonthEnd_Rpt_Ctrl {
	public List<ResultSetWrapper> ListResultSet{get;set;}
	public ASI_MFM_CAP_HK_MonthEnd_Rpt_Ctrl(){
        ListResultSet = getResultSet();
	}
    
    // Return 1 : M relationship between BOI Payment, and BOI Processing Log
    public class ResultSetWrapper {
        public ASI_MFM_Payment__c Payment {get;set;}
        public List<ASI_MFM_CAP_OV_Creation_Log__c> ListOVLog {get;set;}
    }
    
    public List<ResultSetWrapper> getResultSet() {
		List<ResultSetWrapper> outputListResultSet = new List<ResultSetWrapper>();
        
        //Query Outstanding BOI with Status = 'Draft'
        List<ASI_MFM_Payment__c> Listpayment = [ SELECT id, name, ASI_MFM_PO_Number__c, ASI_MFM_PO_Type__c, ASI_MFM_Status__c, ASI_MFM_Payment_Date__c FROM ASI_MFM_Payment__c WHERE ASI_MFM_Status__c IN ('Draft', 'Cancelled') AND ASI_MFM_Payment_Date__c = THIS_MONTH AND RecordType.Name = 'OPEX HK Payment' ];
        
        //Query BOI Log of the month
        List <ASI_MFM_CAP_OV_Creation_Log__c> ListMonthlyLog = [ select id, ASI_Brand_Owner_SKU__c, ASI_PO_Number__c, ASI_PO_Type__c, ASI_PR_SKU_Found__c, ASI_PO_Line_Found__c, ASI_ETL_Process_Date__c from ASI_MFM_CAP_OV_Creation_Log__c where (ASI_PO_Type__c = 'OP' OR ASI_PO_Type__c = '2P') AND ASI_ETL_Process_Date__c = THIS_MONTH ORDER BY ASI_ETL_Process_Date__c DESC, ASI_PO_Number__c ASC ];
		
        for ( ASI_MFM_Payment__c idx : Listpayment ) {
			ResultSetWrapper RecResultSet = new ResultSetWrapper();
			List<ASI_MFM_CAP_OV_Creation_Log__c> ListResultSetChild = new List<ASI_MFM_CAP_OV_Creation_Log__c>();
			
            RecResultSet.Payment = idx;
            
            for ( ASI_MFM_CAP_OV_Creation_Log__c idx1 : ListMonthlyLog ) {
                if (idx1.ASI_PO_Number__c == idx.ASI_MFM_PO_Number__c && idx.ASI_MFM_PO_Type__c == idx1.ASI_PO_Type__c) {
                    ListResultSetChild.add(idx1);
                }
            }
            RecResultSet.ListOVLog = ListResultSetChild;
            outputListResultSet.add(RecResultSet);
        }
        return outputListResultSet;
    }
}