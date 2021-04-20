/********************************************************************************
* Service Invoque to get Available Credit information for a given account
* Error Codes:
*	 0 - Success
*	-1 - No LAT Account
*	-2 - No Account
*	-3 - Error return by JDE 
*
* NAME: LAT_WS_GetAvailableCredit.cls
* AUTHOR: Mariano Boezio                           DATE: 09/12/2015
********************************************************************************/
global class LAT_WS_GetAvailableCredit {
	
	// This will be returned by the service		
	global class creditItem{
		// Credit Information
		webservice Decimal credDebt;
        webservice Decimal credLimit;
        webservice Decimal credOrderPending;
        webservice DateTime credUpdatedDate;
        webservice Decimal credOrderAppr;
        webservice Decimal credAboveLimit;
        // Error information
        webservice String errorCode;
        webservice String errorMessage;
    }

    // This method will return de credit information. 
    // The parameter must be in the form <Coutnry Number>-<Client AN8>
	webservice static creditItem getAvailableCredit(String accountKey){
	    creditItem returnItem = new creditItem();

	    // Retrive account and LAT Account
	    List<Account> accList = [SELECT id FROM Account WHERE Client_country_AN8__c =: accountKey];
	    List<LAT_Account__c> latAccList = [SELECT id, LAT_Accountid__c, LAT_Cred_Debt__c, LAT_Cred_Limit__c, LAT_Cred_OrderPending__c, LAT_Cred_UpdatedDate__c,
	                                                        LAT_Cred_OrderAppr__c, LAT_Cred_AboveLimit__c, LAT_Cred_RequestDate__c, LAT_Accountid__r.Client_country_an8__c,LAT_Accountid__r.LAT_MX_AvailableCreditLimit__c
	                                                    FROM LAT_Account__c 
	                                                    WHERE LAT_Accountid__c =: accList];

	    // Validate if there is an Account and LAT Account
	    if (!accList.isEmpty()) {
	        if (!latAccList.isEmpty()) {
	        	// Get Available Credit from JDE
	            LAT_Account__c latAcc = latAccList.get(0);
	            String error = LAT_GetAvailableCreditHelper.getAvailableCreditList(latAcc);
	            
	            // return results
	            //if (error == '') {
	                returnItem.credDebt = latAcc.LAT_Cred_Debt__c;	
	                returnItem.credLimit = latAcc.LAT_Cred_Limit__c;
	                returnItem.credOrderPending = latAcc.LAT_Cred_OrderPending__c;
	                returnItem.credUpdatedDate = latAcc.LAT_Cred_UpdatedDate__c;
	                returnItem.credOrderAppr = latAcc.LAT_Cred_OrderAppr__c;
	                returnItem.credAboveLimit = latAcc.LAT_Cred_AboveLimit__c;
	                if (latAcc.LAT_Accountid__r.Client_country_an8__c.startsWith('12-')){ 
	                	//Solo cargo este dato si es una cuenta de Mexico
	                	returnItem.credAboveLimit = latAcc.LAT_Accountid__r.LAT_MX_AvailableCreditLimit__c;
	                } 
	                returnItem.errorMessage = error;
	                returnItem.errorCode = '0';
	            //}
	        } else {
	            returnItem.errorMessage = Label.LAT_WS_NoLATAccount;
	            returnItem.errorCode = '-1';
	        }
	    }else{
	        returnItem.errorMessage = Label.LAT_WS_NoAccountForGivenAN8;
	        returnItem.errorCode = '-2';    
	    }

	    return returnItem;
	}
}