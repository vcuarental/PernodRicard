/**
 * Name     :   GDT_ManageActivity_Activity_Request.cls
 *  This class contains functions used in GDT activity requests process.
 *
 * Author   :   Bruno Vuono
 * Date     :   2019
 *
 *******************************************************/
public with sharing class GDT_ManageActivity_Activity_Request {

    public GDT_Activity__c request{get;set;}
    public String requestJSON {get;set;}
    public Boolean isAdmin{get;set;}
    public Boolean editable{get;set;}
    public static final Set<String> disabledFields = new Set<String> {'Status__c', 'Approval_Process_Comments__c'};

    public final String viewURL = '/apex/GDT_ManageActivity_NewActivityRequest?id=';
    public final String newURL = '/apex/GDT_ManageActivity_NewActivityRequest';


    //Class constructor
    public GDT_ManageActivity_Activity_Request(ApexPages.standardController controller) {
        isAdmin = isAdminQuery();
        requestJSON = '';
        if(controller.getRecord().id != null){
            request = [Select id,Services__c,Status__c,Service_Code__c,GDT_Services__r.Code__c,Activity_Name__c, (Select id,Release_Type_Line__c,Deployment_Type__c,Commentary__c,Status__c,Date_of_request__c,Date_expected__c,Date_delivery__c,Performed_By__r.Name from GDT_Activity_LineItems__r order by CreatedDate desc) from GDT_Activity__c where id =: controller.getRecord().id];
            if(request.Service_Code__c == null){
                request.Service_Code__c = request.GDT_Services__r.Code__c;
            }
            requestJSON = JSON.serialize(request);
        }else{
            request = new GDT_Activity__c();
        }
        editable = (request.Status__c == 'Created' || request.Status__c == 'Rejected' || request.Status__c == 'Waiting for user' || isAdmin);
        system.debug(requestJSON);

    }



    //Method to get the service types options
    @AuraEnabled
    public static List<GDT_Services__c> getServiceOptions() { 

        List<GDT_Services__c> options  = new List<GDT_Services__c>();
        String  defaultService  =   '- - - - - - - - - - - - - - - - Select Service - - - - - - - - - - - - - - - - -';

        //Default value
        options.add(new GDT_Services__c(Name = defaultService, Code__c = 'SFDC_S00',Label__c = defaultService));

        try {
            List<GDT_Services__c> arServices = [SELECT Name,Code__c,Label__c FROM GDT_Services__c ORDER BY Label__c ASC NULLS FIRST];
            //All Services
            for (GDT_Services__c ar : arServices) {
                options.add(ar);
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
        }

        return options;
    }

    //Method to get the fields for the different fieldSets. Every service type uses differents fields.
    @AuraEnabled
    public static String getFields(String fieldSetName) { 
        List<FieldOption> ret = new List<FieldOption>();
        for(Schema.FieldSetMember f : SObjectType.GDT_Activity__c.FieldSets.GDT_shared.getFields()) {    
            ret.add(new FieldOption('1' , f.getFieldPath(), disabledFields.contains(f.getFieldPath())));
        }
        
        String fsn = 'GDT_' + fieldSetName.replace('-', '_');
        if(SObjectType.GDT_Activity__c.FieldSets.getMap().containsKey(fsn)){
            for(Schema.FieldSetMember f : SObjectType.GDT_Activity__c.FieldSets.getMap().get(fsn).getFields()) {    
                ret.add(new FieldOption('2' , f.getFieldPath(),disabledFields.contains(f.getFieldPath())));
            }
        }
        return System.JSON.serializePretty(ret);
    }

    //Get all the activity requests order by date
    @AuraEnabled
    public static List<GDT_Activity__c> getActivityRequests() {
        return [SELECT Id,Activity_Name__c,Name,CreatedDate,Project_Name__c,Environment_Destination__c,Services__c,Affiliate__c,Application_Name__c,Project_Description__c,Date_Request__c,Date_Expected__c,Status__c FROM GDT_Activity__c order by CreatedDate desc];
    }

    //Get all the attachments for an activity request
    @AuraEnabled
    public static List<Attachment> getAttachments(String parentId) { 
        return [Select id, Name from Attachment where parentId =: parentid];
    }

    //Get all the attachments for an activity request
    @AuraEnabled
    public static String setStatus(String pId,String pStatus) { 
        GDT_Activity__c req = [Select id,Status__c from GDT_Activity__c where id =: pId];
        req.Status__c = pStatus;
        update req;
        return '';
    }

    
    //Save attachment uploaded by the user.
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

    //Insert a new deployment line for a certain activity request
    @AuraEnabled
    public static List<GDT_Activity_Line__c> createLine(Id parentId) { 
        GDT_Activity_Line__c line = new GDT_Activity_Line__c();
        line.GDT_Activity_Relationship__c = parentid;
        line.status__c = 'New';
        line.Deployment_Type__c = 'Deploy';
        line.Date_of_request__c = Date.today();
        insert line;
        return [Select id,Release_Type_Line__c,Deployment_Type__c,Commentary__c,Status__c,Date_of_request__c,Date_expected__c,Date_delivery__c,Performed_By__r.Name from GDT_Activity_Line__c where GDT_Activity_Relationship__c =: parentId order by CreatedDate desc];
    }
    
    //Delete deployment line.
    @AuraEnabled
    public static List<GDT_Activity_Line__c> deleteLineCtr(Id lineId, Id parentId) { 
        GDT_Activity_Line__c line = new GDT_Activity_Line__c();
        line.id = lineId;
        system.debug(lineId);
        delete line;
        return [Select id,Release_Type_Line__c,Deployment_Type__c,Commentary__c,Status__c,Date_of_request__c,Date_expected__c,Date_delivery__c,Performed_By__r.Name from GDT_Activity_Line__c where GDT_Activity_Relationship__c =: parentId order by CreatedDate desc];
    }
    
    //Delete attachment by Id.
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
    


    //Delete activity request by Id.
    @AuraEnabled
    public static String deleteActivity(String recordId) { 
        GDT_Activity__c act = new GDT_Activity__c();
        act.id = recordId;
        delete act;
        return '';
    }




       
    public PageReference redirectView(){
        String url = '/' + request.Id +'?retURL=%2F'+ String.valueOf(request.Id)+'&nooverride=1';
        return redirect(url, viewURL);
    }

    public PageReference redirectEdit(){
        String url = '/' + request.Id +'/e?retURL=%2F'+ String.valueOf(request.Id)+'&nooverride=1';
        return redirect(url, viewURL);
    }

    public PageReference redirectNew(){
        String prefix = Schema.getGlobalDescribe().get('GDT_Activity__c').getDescribe().getKeyPrefix();
        return redirect('/' + prefix + '/e?retURL=%2F'+ prefix +'&nooverride=1' , newURL);
    }

    
    //Redirect logic for the differents pages
    public PageReference redirect(String pAdminUrl, String pViewUrl){
        String retUrl = '';
        if(isAdminQuery()){
            retUrl  = pAdminUrl;
        }else{
            retUrl = pViewUrl;
            if(request.Id != null )retUrl = (pViewUrl + request.Id);
        } 
        PageReference retPage =  new PageReference(retUrl);
        retPage.setRedirect(true);    
        return retPage;
    }


    //Checks if the user is admin
    public Static Boolean isAdminQuery(){
        Set<String> gmembers = new Set<String>();
        for(GroupMember gm : [Select userOrGroupId from GroupMember where group.developername = 'GDT_group']){
            gmembers.add(gm.userOrGroupId);
        }
        if(gmembers.contains(UserInfo.getUserId())){
            return true;
        }
        return false;
    }



    //Inner class used to show the fields on the screen
    public class FieldOption{        
        public String name { get; set; }
        public String index { get; set; }
        public Boolean disabled {get;set;}

        public FieldOption(String ind, String nam, Boolean tdisabled){
            index = ind;
            name = nam;
            disabled = tdisabled;
        }

    }
}