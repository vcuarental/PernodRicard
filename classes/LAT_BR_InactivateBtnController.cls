/**
 * Class that handle account innactivation flows
 * 
 */
global class LAT_BR_InactivateBtnController {

	// Possible results for inactivation
	public static final String STATUS_ERROR = 'ERROR';
	public static final String STATUS_INTERNAL_ERROR = 'INTERNAL_ERROR';
	public static final String STATUS_SUBMITED = 'SENT_TO_APPROVE';
	public static final String STATUS_INACTIVATED = 'INACTIVATED';

	/**
	 * validates that the fields for account inactivation are submitted correctly
	 * Used from the detail Button "Inactivate Account" 
	 * @param accountId
	 * @return result Message
	 *
	 */
	webservice static String validateAccInactivation(String accountId) {
		Account accToApprove  = [SELECT Rating, Status__c, Notes_1__c,OwnerId,Reason_for_Inactivation__c from account where Id = :accountId LIMIT 1];
		return validateAccInactivation(accToApprove).msg;
	}

	/**
	 * validates that the fields for account inactivation are submitted correctly
	 * @param accToApprove
	 * @return result Message
	 *
	 */
	global static InactivateResponse validateAccInactivation(Account accToApprove){
		InactivateResponse retData;
		try {
			// first validate the status
			// For crm only there is no need to send jde or to run the approval process
			if (accToApprove.Status__c != 'Cliente cadastrado no CRM' && accToApprove.Status__c != 'Cliente cadastrado no JDE'){
				return new InactivateResponse(Label.LAT_BR_VFC24_AccountInactivation_Error_Msg_03, STATUS_ERROR);
			}

			// For crm only there is no need to send jde or to run the approval process
			if (accToApprove.Status__c == 'Cliente cadastrado no CRM'){
					accToApprove.Rating = 'Cliente Inativo';
					update AccToApprove;
					retData = new InactivateResponse('OK', STATUS_INACTIVATED);
			} else if (accToApprove.Reason_for_Inactivation__c != '--None--' && accToApprove.Reason_for_Inactivation__c != null && accToApprove.Reason_for_Inactivation__c != '') {
		      	if (accToApprove.Notes_1__c != null && accToApprove.Notes_1__c != '') { 
		        
					
					if (accToApprove.Status__c == 'Cliente cadastrado no JDE') {
						accToApprove.Status__c = 'Inativação em Aprovação';
						update AccToApprove;

		                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		                req.setComments('Aprovação para a Inativação do cliente solicitada');
		                req.setNextApproverIds(new List<Id>{accToApprove.ownerId});
		                req.setObjectId (accToApprove.Id);
		                 
		                 // submit the approval request for processing
		                 Approval.ProcessResult result = Approval.process(req);
		                 retData = new InactivateResponse('Aprovação para a Inativação do cliente solicitada', STATUS_SUBMITED);
					} else {
						return new InactivateResponse(Label.LAT_BR_VFC24_AccountInactivation_Error_Msg_03, STATUS_ERROR);
					}
		      	} else {
		      	  retData =  new InactivateResponse('Favor informar o Motivo e Justificativa de inativação para o cliente', STATUS_ERROR);
		      	}  
		    } else {
		    	retData =  new InactivateResponse('Favor informar o Motivo e Justificativa de inativação para o cliente', STATUS_ERROR);		    }
		} catch (Exception e){
			retData =  new InactivateResponse(e.getMessage(), STATUS_ERROR);
		}
		return retData; 
	}

	/**
	 * Class to handle status with appropiate msg
	 */
	global class InactivateResponse{
		public String msg{get; set;}
		// 'SENT_TO_APPROVE' , 'INACTIVATED', 
		public String status{get; set;}

		public InactivateResponse(String msg, String status) {
			this.msg = msg;
			this.status = status;
		}

	}


}