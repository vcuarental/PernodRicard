public with sharing class GDT_ManageActivity_Line_Request {

	public GDT_Activity_Line__c request{get;set;}
	public String lineJSON {get;set;}
	public Boolean isAdmin{get;set;}
	public Boolean editable{get;set;}


	public GDT_ManageActivity_Line_Request(ApexPages.standardController controller) {
		isAdmin = GDT_ManageActivity_Activity_Request.isAdminQuery();
		lineJSON = '';
		if(controller.getRecord().id != null){
			request = [Select id, GDT_Activity_Relationship__r.Services__c,GDT_Activity_Relationship__r.Status__c, GDT_Activity_Relationship__r.Service_Code__c, GDT_Activity_Relationship__r.Activity_Name__c, Release_Type_Line__c,Deployment_Type__c,Commentary__c,Status__c,Date_of_request__c,Date_expected__c,Date_delivery__c,Performed_By__r.Name from GDT_Activity_Line__c where id =: controller.getRecord().id];
			lineJSON = JSON.serialize(request);
		}else{
			request = new GDT_Activity_Line__c();
		}
		editable = (request.GDT_Activity_Relationship__r.status__c == 'Created' || request.GDT_Activity_Relationship__r.Status__c == 'Rejected' || request.GDT_Activity_Relationship__r.Status__c == 'Waiting for user' || request.GDT_Activity_Relationship__r.Status__c == 'Resolved' || isAdmin);
		system.debug(lineJSON);
	}

	@AuraEnabled
    public static List<Attachment> getAttachments(String parentId) { 
    	return [Select id, Name from Attachment where parentId =: parentid];
    }

    @AuraEnabled
    public static Attachment saveAttachment(Id parentId, String fileName, String base64Data, String contentType) { 
        Attachment attachment = new Attachment();
        attachment.parentId = parentId;
        attachment.body = EncodingUtil.base64Decode(base64Data);
        attachment.name = fileName;
		attachment.contentType = contentType;
        insert attachment;
        return attachment;
    }

     @AuraEnabled
    public static String deleteAttachments(String pId) { 
        try{
        	Attachment attachment = new Attachment();
	        attachment.id = pId;
	        delete attachment;
        	return '';
    	}catch(Exception ex){
    		return ex.getMessage();
    	}
    }


}