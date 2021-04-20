public with sharing class EUR_CRM_BatchApexUtilityClass {
	
	public static final String BATCH_APEX_EMAIL_RESULT_TEMPLATE_NAME = 'EUR_CRM_BatchApexResultTemplate';
	
	public static void sendBatchResultEmail(Id userId, Id jobId, String[] ccAddresses){
		System.debug('EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail Check Args:'+userId + '-'+jobId+'-'+ccAddresses);
		EmailTemplate eTemplate = null;
    	if (userId!= null && jobId!=null){
	    	List<EmailTemplate> eTemplates = new List<EmailTemplate>();
			eTemplates = [SELECT Id, Name, Subject, Body, HtmlValue 
									FROM EmailTemplate 
									WHERE name =: BATCH_APEX_EMAIL_RESULT_TEMPLATE_NAME 
									LIMIT 1];
			
			if(eTemplates.size()>0){
				eTemplate = eTemplates.get(0);
				
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setTemplateId(eTemplate.Id);
				mail.setSaveAsActivity(false);
				mail.setTargetObjectId(userId);
				mail.setWhatId(jobId);
				if(ccAddresses!=null)
					mail.setCcAddresses(ccAddresses);
				
				//Send Mail
				sendBatchResultEmail(mail);
			}else{
				System.debug('Error: EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail: Template '+ BATCH_APEX_EMAIL_RESULT_TEMPLATE_NAME + ' does not exist');
			}
		}else{
			System.debug('Invalid: EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail: Incomplete arguments, User Id and Job Id are required');
		}
	}
	
	public static void sendBatchResultEmail(Id userId, Id jobId, String[] ccAddresses, String templateName, List<String> msgs){
		System.debug('EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail Check Args:'+userId + '-'+jobId+'-'+ccAddresses);
		EmailTemplate eTemplate = null;
    	if (userId!= null && jobId!=null){
	    	List<EmailTemplate> eTemplates = new List<EmailTemplate>();
			eTemplates = [SELECT Id, Name, Subject, Body, HtmlValue 
									FROM EmailTemplate 
									WHERE name = :templateName 
									LIMIT 1];
			
			if(eTemplates.size()>0){
				eTemplate = eTemplates.get(0);
				Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(eTemplate.Id, userId, jobId);
				String subjectEmail = email.getSubject();
				String bodyEmail = email.getHTMLBody();
				bodyEmail += '<br/>'+String.join(msgs, '<br/>')+'<br/><br/><br/>';

    			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    			mail.setSubject(subjectEmail);
    			mail.setHtmlBody(bodyEmail);
    			mail.setSaveAsActivity(false);
    			mail.setToAddresses(new String [] {UserInfo.getUserEmail()});
				if(ccAddresses!=null){
					mail.setCcAddresses(ccAddresses);
				}
				
				//Send Mail
				sendBatchResultEmail(mail);
			}else{
				System.debug('Error: EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail: Template '+ BATCH_APEX_EMAIL_RESULT_TEMPLATE_NAME + ' does not exist');
			}
		}else{
			System.debug('Invalid: EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail: Incomplete arguments, User Id and Job Id are required');
		}
	}

	public static void sendBatchResultEmail(Id userId, Id jobId, String[] ccAddresses, String templateName){
		System.debug('EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail Check Args for '+templateName+':'+userId + '-'+jobId+'-'+ccAddresses);
		EmailTemplate eTemplate = null;
    	if (userId!= null && jobId!=null && templateName!=null){
	    	List<EmailTemplate> eTemplates = new List<EmailTemplate>();
			eTemplates = [SELECT Id, Name, Subject, Body, HtmlValue 
									FROM EmailTemplate 
									WHERE name =: templateName 
									LIMIT 1];
			
			if(eTemplates.size()>0){
				eTemplate = eTemplates.get(0);
				
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setTemplateId(eTemplate.Id);
				mail.setSaveAsActivity(false);
				mail.setTargetObjectId(userId);
				mail.setWhatId(jobId);
				if(ccAddresses!=null)
					mail.setCcAddresses(ccAddresses);
				
				//Send Mail
				sendBatchResultEmail(mail);
			}else{
				System.debug('Error: EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail: Template '+ templateName + ' does not exist');
			}
		}else{
			System.debug('Invalid: EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail: Incomplete arguments, User Id, Job Id and Template Name are required');
		}
	}
	
	public static void sendBatchResultEmail(String subject, String plainBody, Id userId, String[] ccAddresses) {
        System.debug('EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail Check Args:'+subject + '-'+plainBody+'-'+userId+'-'+ccAddresses);
        EmailTemplate eTemplate = null;
        if (subject!= null && plainBody!=null && userId!=null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                mail.setSaveAsActivity(false);
                mail.setTargetObjectId(userId);
                mail.setSubject(subject);
                mail.setPlainTextBody(plainBody);
                if(ccAddresses!=null)
                    mail.setCcAddresses(ccAddresses);
                
                //Send Mail
                sendBatchResultEmail(mail);
        }else{
            System.debug('Invalid: EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail: Incomplete arguments, content, subject and recipient/s are required');
        }	    
	}
	
	public static void sendBatchResultEmail(String subject, String plainBody, String[] toAddresses, String[] ccAddresses){
		System.debug('EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail Check Args:'+subject + '-'+toAddresses+'-'+ccAddresses);
		EmailTemplate eTemplate = null;
    	if (subject!= null && plainBody!=null && toAddresses!=null){
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		    	
				mail.setSaveAsActivity(false);
				mail.setToAddresses(toAddresses);
	    		mail.setSubject(subject);
	    		mail.setPlainTextBody(plainBody);
	    		if(ccAddresses!=null)
					mail.setCcAddresses(ccAddresses);
				
				//Send Mail
				sendBatchResultEmail(mail);
		}else{
			System.debug('Invalid: EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail: Incomplete arguments, content, subject and recipient/s are required');
		}	
	}
	
	public static void sendBatchResultEmail(Messaging.SingleEmailMessage mail){
		try{
	    	Set<ID> targetIdsFailed = new Set<ID>();
	    	
	    	List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailmessage[] {mail});
			for(Messaging.SendEmailResult result:results){
		        System.debug('EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail - Email result:' + result.IsSuccess());
		
		        if(!result.IsSuccess())
		        {
					Messaging.SendEmailerror[] errArr = result.getErrors();   
					targetIdsFailed.add(errArr[0].getTargetObjectId()); 
					 
					System.StatusCode statusCode = errArr[0].getStatusCode();
				    String errorMessage = errArr[0].getMessage();
				    System.debug('Error: EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail - Email Error Message:' + statusCode +'-'+errorMessage);
		        }
		    } 
    	}catch(Exception e){
    		System.debug('Exception: EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail:' + e);
    		String strError = e.getTypeName()+':'+ String.valueOf(e.getLineNumber())+'-'+e.getMessage();
    		System.debug('Exception: EUR_CRM_BatchApexUtilityClass-sendBatchResultEmail - Exception Message:'+strError);
    	}		
	}

	@isTest static void testMailSend(){
		Type batchType = Type.forName('EUR_CRM_MassUpdateOPAcctMapEnd');
		Database.Batchable<SObject> batchable = (Database.Batchable<SObject>)batchType.newInstance();
       	Id jobId = Database.executeBatch(batchable);

        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), jobId, new String[]{'test@test.com'});
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), jobId, new String[]{'test@test.com'}, EUR_CRM_BatchApexUtilityClass.BATCH_APEX_EMAIL_RESULT_TEMPLATE_NAME, new String[]{'AAA'});
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), jobId, new String[]{'test@test.com'}, EUR_CRM_BatchApexUtilityClass.BATCH_APEX_EMAIL_RESULT_TEMPLATE_NAME);
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail('Subject', 'Body', UserInfo.getUserId(), new String[]{'test@test.com'});
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail('Subject', 'Body', new String[]{'test@test.com'}, new String[]{'test@test.com'});
	}

}