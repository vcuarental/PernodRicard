@RestResource(urlMapping='/LAT_Rest_ChecklistMX/*')
global  with sharing class LAT_Rest_ChecklistMX {
	

	@HttpPut
    global static void PUT() {
        RestRequest req = RestContext.request;
        HeaderChecklist checklist = (HeaderChecklist)System.JSON.deserialize(req.requestBody.toString(), HeaderChecklist.class);
        System.debug('checklist : ' + checklist);

        String res = doUpdate(checklist);
        Boolean success = false;

        if (res == '') {
        	success = true;
        }

        LAT_Rest_Contracts.ServiceResponse response = new LAT_Rest_Contracts.ServiceResponse(checklist.Id, res, success);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(response));

        System.debug('response : ' + response);
        if (response.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }
	}
	

	public static String doUpdate(HeaderChecklist checklist) {
		String retorno = '';

		try {
			updateHeader(checklist); 
			upsertLines(checklist); 

		} catch (DMLException e){
            System.debug('Exception e : ' + e);
            //Added check for FIELD_CUSTOM_VALIDATION_EXCEPTION to return user friendly error.
            String errorMsg = e.getMessage();
            if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                retorno = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
            } else {
                retorno = errorMsg;
            }
        } catch (Exception e) {
            System.debug('Exception e2: ' + e);
            System.debug('Exception e2: ' + e.getStackTraceString());
            System.debug('Exception e2: ' + e.getMessage());
            System.debug('Exception e2: ' + e.getCause());
			retorno = ''+ String.valueOf(e.getMessage());
		}

		return retorno;
	}	

	public static void updateHeader(HeaderChecklist checklist) {
		CLV_ChecklistVisita_ARG__c header = new CLV_ChecklistVisita_ARG__c();
		header.Id = checklist.id;

		if(checklist.subtype != null && checklist.subtype != '') header.LAT_MX_Subtype__c	= checklist.subtype;
		if(checklist.startTime != null && checklist.startTime != '') header.LAT_MX_StartTime__c	= checklist.startTime;
		if(checklist.endTime != null && checklist.endTime != '') header.LAT_MX_EndTime__c	= checklist.endTime;
		if(checklist.result != null && checklist.result != '') header.LAT_MX_Result__c	= checklist.result;
		if(checklist.reason != null && checklist.reason != '') header.LAT_MX_Reason__c	= checklist.reason;
		if(checklist.feedback != null && checklist.feedback != '') header.LAT_MX_Feedback__c	= checklist.feedback;

		update header;

	}

	public static void upsertLines(HeaderChecklist checklist) {
		
		List<LAT_ChecklistVisita_Question__c> toUpsert = new List<LAT_ChecklistVisita_Question__c>();
		for (QuestionsChecklist qc : checklist.questionsChecklist) {
			LAT_ChecklistVisita_Question__c nuevaLinea = new LAT_ChecklistVisita_Question__c();
			if(qc.id != null && qc.id != ''){
				if(qc.id.startsWith('aQd')) {
		   			nuevaLinea.Id = qc.id;
		   		} else {
		   			nuevaLinea.Checklist__c = checklist.Id;
		   			if(qc.recordtypeId != null && qc.recordtypeId != '') nuevaLinea.RecordTypeId = qc.recordtypeId;
		   		}
		   	} else {
	   			nuevaLinea.Checklist__c = checklist.Id;
	   			if(qc.recordtypeId != null && qc.recordtypeId != '') nuevaLinea.RecordTypeId = qc.recordtypeId;
	   		}
			
			if(qc.productId != null && qc.productId != '') nuevaLinea.Producto__c = qc.productId;
			if(qc.question != null && qc.question != '') nuevaLinea.LAT_Question__c = qc.question;
			if(qc.answer != null && qc.answer != '') nuevaLinea.LAT_Answer__c = qc.answer;
			if(qc.answerCheckbox != null) nuevaLinea.LAT_Checkbox_Answer__c = qc.answerCheckbox;

			toUpsert.add(nuevaLinea);
		}
		if(toUpsert.size() > 0) {
			upsert toUpsert;
		}


	}

	public class HeaderChecklist {

		public String Id;
		public String subtype;
		public String startTime;
		public String endTime;
		public String result;
		public String reason;
		public String feedback;
		public List<QuestionsChecklist> questionsChecklist;
	}

	public class QuestionsChecklist {
		public String id;
		public String productId;
		public String question;
		public String answer;
		public Boolean answerCheckbox;
		public String recordtypeId;
	}


}