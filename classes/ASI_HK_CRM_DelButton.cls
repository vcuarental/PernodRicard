global class ASI_HK_CRM_DelButton {
	webservice static string DelButton(Id Invoice_HeaderId){
        string returnVal = '';
        ASI_CRM_EDI_Invoice_Header__c delitem = [select id from ASI_CRM_EDI_Invoice_Header__c where id =: Invoice_HeaderId];
        try{
            delete delitem;
            returnVal = 'Success';
        }catch(exception ex){
            returnVal = ex.getMessage();
        }
        //system.debug(returnVal);
        return returnVal;
    }
}