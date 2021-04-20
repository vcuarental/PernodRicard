public with sharing class LAT_WS_TR_CustomerAfterUpdateProcesses {

	// Submits the customer for Approval as per the Send to JDE AR flow
	public static void submitCustomerForApprovalAR(List <Account> triggerNew) {
		List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
		Map<id, id> PiList = new Map<id, id>();
		for (ProcessInstance pi: [SELECT Id, TargetObjectId
                                    FROM ProcessInstance 
                                    WHERE TargetObjectId IN : triggerNew
                                        AND (Status = 'Pending' OR Status = 'Submitted')]) {
			PiList.put(pi.TargetObjectId, pi.id);
		}

		Set<Id> accIds = new Set<Id>();

		for (Account a :triggerNew) {
			accIds.add(a.id);
		}

		Map<Id, Lat_Account__c> accountAndLatAccountMap = new Map<Id, Lat_Account__c>();

		for(Lat_Account__c latacc :[Select Id, LAT_Accountid__c, LAT_IsAdmin__c 
									from Lat_Account__c 
									where LAT_Accountid__c in :accIds]){

			accountAndLatAccountMap.put(latacc.lat_accountid__c, latacc);
		}
		
		List<Lat_Account__c> lataccountToUpdate = new List<Lat_Account__c>();

		for (Account a : triggerNew) {
			if(accountAndLatAccountMap.get(a.id) != null) {
				if(accountAndLatAccountMap.get(a.id).LAT_IsAdmin__c == null) {
					continue;
				}
				System.debug('%%% a.Status__c : ' + a.Status__c);
				System.debug('%%% \'Account to Review in JDE\'.equalsIgnoreCase(a.Status__c) : ' + 'Account to Review in JDE'.equalsIgnoreCase(a.Status__c));
				System.debug('%%% accountAndLatAccountMap.get(a.id) : ' + accountAndLatAccountMap.get(a.id));
				System.debug('%%% accountAndLatAccountMap.get(a.id).LAT_IsAdmin__c : ' + accountAndLatAccountMap.get(a.id).LAT_IsAdmin__c);
				if('Account to Review in JDE'.equalsIgnoreCase(a.Status__c) && accountAndLatAccountMap.get(a.id).LAT_IsAdmin__c == true){

					a.Status__c = 'Cliente cadastrado no JDE';
					accountAndLatAccountMap.get(a.id).LAT_IsAdmin__c = false;
					lataccountToUpdate.add(accountAndLatAccountMap.get(a.id));

				}else if ('Account to Review in JDE'.equalsIgnoreCase(a.Status__c)
					&& PiList.get(a.id) == null 
					&& (LAT_WS_Utils.getWSEndpoint('6').startsWith('https') 
					   || LAT_WS_Utils.getWSEndpoint('5').startsWith('https'))) {
					// Check that the account updated correctly
					//Creates approval
					a.Status__c = 'Cliente cadastrado no JDE';
				    //Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
				    //req.setObjectId(a.Id);
				    //requests.add(req);
				}
			}
		}
		
	    try{
	    	if (!requests.isEmpty()) {
	    		Approval.ProcessResult[] proc = Approval.process(requests, true);

	    	}else if(!lataccountToUpdate.isEmpty()){

	    		update lataccountToUpdate;
	    	}
	    } catch (Exception e) { 
	    	if (System.Test.isRunningTest()) return;
			System.Debug('Exception!!!');
			System.Debug(e);
			/*for (Account a : triggerNew) {
				a.Status__c = 'Erro JDE';
				a.Return_JDE_Integration__c = e.getMessage();
				a.Is_interface_Process_AR__c = true;
			}*/
			LAT_DebugUtil debugUtil = new LAT_DebugUtil();
			debugUtil.setOrigin('LAT_WS_TR_CustomerAfterUpdateProcesses.submitCustomerForApprovalAR.EXCEPTION');
			debugUtil.addTitle('submitCustomerForApprovalAR');
			debugUtil.addException(e);
			debugUtil.insertDebug();
			//update triggerNew;
	    }
	}

	// Updates customer status after send to JDE in Brasil and Mexico
	public static void updateCustomerStatusToRegisteredBR(List <Account> triggerNew) {
		for (Account a : triggerNew) {
			if ('Account to Review in JDE'.equalsIgnoreCase(a.Status__c)) {
				a.Status__c = 'Cliente cadastrado no JDE';
			}
		}
		//update triggerNew;
	}

	// Sends customer information after updated in JDE
	public static void sendCustomerEmailMX(List <Account> triggerNew, map<Id, Account> oldMap) {
		List<User> tmpUsers = new List<User>();
		List<String> userIds = new List<String>();
		for (Account acc : triggerNew) {
			userIds.add(acc.ownerId);
		}
		Map<String,User> userMap = new Map<String,User>();
		for(User u : [Select id,email,name from User where id in :userIds]){
			userMap.put(u.id,u); 
		}

		Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[]{};
		for (Account a : triggerNew) {
			// Validate that this is an insert operation (inserts do not have AN8)
			if (a.Is_Interface_Process_AR__c && a.Client_code_AN8__c != null && Integer.valueOf(a.Client_code_AN8__c.trim()) > 0 && oldMap.get(a.Id).Client_code_AN8__c == null) {
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			    //String[] toAddresses = new String[] {a.Owner.Email};
			    String[] toAddresses = LAT_GeneralConfigDao.getValueAsStringArray('ACC_SUCCESS_EMAIL_JDE_RECEIPT',',');
			    if (toAddresses != null) {
	        		toAddresses.add(userMap.get(a.OwnerId).email);
	        	} else {
	        		toAddresses = new String[]{userMap.get(a.OwnerId).email};
	        	}
	        	mail.setToAddresses(toAddresses);
			    mail.setSubject('Cliente registrado en el sistema JDE');
			    String cuerpoDeMail = '';
			    cuerpoDeMail += 'Estimado(a) ' + userMap.get(a.OwnerId).Name + ',<br/><br/><br/>';
			    cuerpoDeMail += 'El cliente ' + a.Name + ' fue registrado en el sistema.<br/><br/>';
			    cuerpoDeMail += 'AN8: ' + a.Client_code_AN8__c + '<br/><br/>';
			    cuerpoDeMail += 'Código CRM: ' + a.LAT_MX_CRMClientCode__c + '<br/><br/><br/>';                 
			    cuerpoDeMail += 'Para mirar el estado del mismo, clique sobre el siguiente link: <a href=' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + a.Id + '>haga click aquí</a> <br/><br/><br/>';
			    cuerpoDeMail += 'Cordialmente,<br/><br/><br/>';
			    cuerpoDeMail += 'Equipo CRM';
			    mail.setHTMLBody(cuerpoDeMail);
			    emails.add(mail);
			}
	  }
	  	if(!emails.isEmpty()){
    		try{ Messaging.sendEmail(emails); } catch( Exception e ) {LAT_DebugUtil.insertDebug('LAT_WS_Utils', 'Exception:' + e.getMessage() + ' Line: ' + e.getLineNumber() + ' Cause: ' + e.getCause(), '');}
	  	}
	}
}