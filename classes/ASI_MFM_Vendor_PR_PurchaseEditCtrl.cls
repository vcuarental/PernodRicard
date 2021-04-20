public with sharing class ASI_MFM_Vendor_PR_PurchaseEditCtrl {

	

	public ASI_MFM_Vendor_PR_PurchaseEditCtrl(ApexPages.StandardController con) {
	}

	public PageReference getPrefix() {
        
        String url = '';
        String recId = apexpages.currentPage().getParameters().get('id');
        System.debug(LoggingLevel.INFO, '*** recId: ' + recId);
        ASI_MFM_Purchase_Request__c pr = [SELECT Id,RecordType.Name FROM ASI_MFM_Purchase_Request__c 
            WHERE Id =:recId];
            System.debug(LoggingLevel.INFO, '*** pr.RecordType.Name: ' + pr.RecordType.Name);
        if(pr.RecordType.Name == 'CN Purchase Request')
        {
           url = '/apex/ASI_CTY_CN_Vendor_PR_PurchaseEditPage?id='+recId;
        }
        else
        {
           url = '/'+ recId + '/e?retURL=%2F'+recId + '%2Fo&nooverride=1';
        }
        

        System.debug(LoggingLevel.INFO, '*** url: ' + url);
        return new pageReference(url);
    }
    
}