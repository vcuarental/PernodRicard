/********************************************************************************
* Helper methods for Available Credit interface calls
*
* NAME: LAT_GetAvailableCreditHelper.cls 
* AUTHOR: Mariano Boezio                           DATE: 09/12/2015
********************************************************************************/
public class LAT_GetAvailableCreditHelper {


	public static String getAvailableCreditList(LAT_Account__c acc) {
		if (acc.LAT_Accountid__r.Client_country_an8__c.startsWith('12-')) {
			return getAvailableCreditListMX(acc);
		} else {
			System.debug('En LAT_GetAvailableCreditHelper.getAvailableCreditList');
		    String[] minsArray = LAT_GeneralConfigDao.getValueAsStringArray('UPDATE_CREDIT_AVAILABLE', ' ');
		    Integer mins = minsArray != null ? Integer.valueOf(minsArray[0]) : 10;

		    if(acc != null){
		        if(acc.LAT_Cred_UpdatedDate__c == null
		            || acc.LAT_Cred_UpdatedDate__c < Datetime.now().addMinutes(-mins)){
		        	System.debug('En LAT_GetAvailableCreditHelper.getAvailableCreditList 2');
		            String msgError = LAT_BR_VFC12_CreditoDisponivelController.updateCreditoDisponible(acc);
		            if(msgError == ''){
		                List<LAT_ACCOUNT__c> tmpAccounts = [SELECT id,LAT_Cred_Debt__c,LAT_Cred_RequestDate__c,
		                                                            LAT_Cred_Limit__c,LAT_Cred_OrderPending__c,
		                                                            LAT_Cred_UpdatedDate__c,LAT_Cred_OrderAppr__c,
		                                                            LAT_Cred_AboveLimit__c,LAT_Accountid__c,
		                                                            LAT_Cred_Limit_Available__c,LAT_Accountid__r.Name,
		                                                            LAT_Accountid__r.Client_code_AN8__c 
		                                                    FROM LAT_ACCOUNT__c 
		                                                    WHERE id =: acc.id];
		                if(tmpAccounts != null && tmpAccounts.size() > 0){
		                    acc = tmpAccounts[0];
		                }
		                return '';
		            } else {
		               return msgError;
		            }
		        }else{
		            return Label.LAT_BR_VFP12_00014;
		        }
		    } else {
		    	return Label.LAT_WS_NoLATAccount;
		    }
			
		}

	}

    //Metodo específico para el calculo en Mobile MX.
    //20/06/2017
	public static String getAvailableCreditListMX(LAT_Account__c acc) {
	    String[] minsArray = LAT_GeneralConfigDao.getValueAsStringArray('UPDATE_CREDIT_AVAILABLE', ' ');
	    Integer mins = minsArray != null ? Integer.valueOf(minsArray[0]) : 10;

	    if(acc != null){
	        if(acc.LAT_Cred_UpdatedDate__c == null || acc.LAT_Cred_UpdatedDate__c < Datetime.now().addMinutes(-mins)){
                List<LAT_ACCOUNT__c> tmpAccounts = [SELECT id,LAT_Cred_Debt__c,LAT_Cred_RequestDate__c,
                                                            LAT_Cred_Limit__c,LAT_Cred_OrderPending__c,
                                                            LAT_Cred_UpdatedDate__c,LAT_Cred_OrderAppr__c,
                                                            LAT_Cred_AboveLimit__c,LAT_Accountid__c,
                                                            LAT_Accountid__r.LAT_MX_AvailableCreditLimit__c,LAT_Accountid__r.Name,
                                                            LAT_Accountid__r.Client_code_AN8__c,LAT_Accountid__r.Amount_due_ARG__c,LAT_Accountid__r.Credit_Line__c 
                                                    FROM LAT_ACCOUNT__c 
                                                    WHERE id =: acc.id];
                if(tmpAccounts != null && tmpAccounts.size() > 0){
                    //acc.LAT_Cred_Limit_Available__c = tmpAccounts.get(0).LAT_Accountid__r.LAT_MX_AvailableCreditLimit__c;
                	acc.LAT_Cred_Debt__c = tmpAccounts.get(0).LAT_Accountid__r.Amount_due_ARG__c;
            		acc.LAT_Cred_Limit__c = tmpAccounts.get(0).LAT_Accountid__r.Credit_Line__c;
        			acc.LAT_Cred_UpdatedDate__c = DateTime.now();
        			update acc;
                }
                return '';
	        }else{
	            return Label.LAT_BR_VFP12_00014;
	        }
	    } else {
	    	return Label.LAT_WS_NoLATAccount;
	    }
	}

	//Metodo específico para el calculo en Mobile AR.
    //20/06/2017
	public static String getAvailableCreditListAR(LAT_Account__c acc) {
	    String[] minsArray = LAT_GeneralConfigDao.getValueAsStringArray('UPDATE_CREDIT_AVAILABLE', ' ');
	    Integer mins = minsArray != null ? Integer.valueOf(minsArray[0]) : 10;

	    if(acc != null){
	        if(acc.LAT_Cred_UpdatedDate__c == null || acc.LAT_Cred_UpdatedDate__c < Datetime.now().addMinutes(-mins)){
                List<LAT_ACCOUNT__c> tmpAccounts = [SELECT id,LAT_Cred_Debt__c,LAT_Cred_RequestDate__c,
                                                            LAT_Cred_Limit__c,LAT_Cred_OrderPending__c,
                                                            LAT_Cred_UpdatedDate__c,LAT_Cred_OrderAppr__c,
                                                            LAT_Cred_AboveLimit__c,LAT_Accountid__c,
                                                            LAT_Accountid__r.LAT_MX_AvailableCreditLimit__c,LAT_Accountid__r.Name,
                                                            LAT_Accountid__r.Client_code_AN8__c,LAT_Accountid__r.Amount_due_ARG__c,LAT_Accountid__r.Credit_Line__c, 
                                                            LAT_Accountid__r.Credit_line_USD_AR__c                                                            	
                                                    FROM LAT_ACCOUNT__c 
                                                    WHERE id =: acc.id];
                if(tmpAccounts != null && tmpAccounts.size() > 0){
                    //acc.LAT_Cred_Limit_Available__c = tmpAccounts.get(0).LAT_Accountid__r.LAT_MX_AvailableCreditLimit__c;
                	acc.LAT_Cred_Debt__c = tmpAccounts.get(0).LAT_Accountid__r.Amount_due_ARG__c;
            		acc.LAT_Cred_Limit__c = tmpAccounts.get(0).LAT_Accountid__r.Credit_Line__c;
            		acc.LAT_Cred_OrderAppr__c = tmpAccounts.get(0).LAT_Accountid__r.Credit_line_USD_AR__c;//Uso este campo como Aux
        			acc.LAT_Cred_UpdatedDate__c = DateTime.now();
        			update acc;
                }
                return '';
	        }else{
	            return Label.LAT_BR_VFP12_00014;
	        }
	    } else {
	    	return Label.LAT_WS_NoLATAccount;
	    }
	}


}