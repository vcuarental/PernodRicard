/*********************************************************************************
 * Name:ASI_CRM_VN_VisitDetailGPSController
 * Description: save GPS for VN CRM
 *
 * Version History
 * Date               Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 06/10/2015         Laputa: Hank            Created
*********************************************************************************/
public with sharing class ASI_CRM_VN_VisitDetailGPSController{
    public ASI_HK_CRM_Visitation_Plan_Detail__c detail {get;set;}
    public String latitudeStr{get;set;}
    public String longitudeStr{get;set;}
    public String statusDisplay{get;set;}
    public Boolean achieveWithStatusUpdate;
    public String log = '';
    
    public ASI_CRM_VN_VisitDetailGPSController(ApexPages.StandardController stdController){
        detail = (ASI_HK_CRM_Visitation_Plan_Detail__c) stdController.getRecord();
        if(detail != null){
            detail = [Select ASI_HK_CRM_Status__c, ASI_CRM_GPS_Location__c, ASI_CRM_Visit_Address__c From ASI_HK_CRM_Visitation_Plan_Detail__c Where Id = :detail.Id];
            system.debug('Visit Detail: ' + detail);
        }
        
        achieveWithStatusUpdate = true;
    }
    
    public PageReference updateStatus(){
        detail = [Select ASI_HK_CRM_Status__c, ASI_CRM_GPS_Location__c, ASI_CRM_GPS_Location__Latitude__s, ASI_CRM_GPS_Location__Longitude__s, ASI_CRM_Visit_Address__c From ASI_HK_CRM_Visitation_Plan_Detail__c Where Id = :detail.Id];
        
        if (detail.ASI_HK_CRM_Status__c == 'Planned' || detail.ASI_HK_CRM_Status__c == 'Ad-hoc'){
            try{
                detail.ASI_HK_CRM_Status__c = 'Achieved';
                update detail;
                return new PageReference('/' + detail.Id);
            }
            catch(exception e){
                ApexPages.addMessages(e);
                return null;
            }        
        }
        else if (detail.ASI_HK_CRM_Status__c == 'Achieved'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The visit has been achieved before. Click "Cancel" to return.'));
            return null;
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The visit is not planned or ad-hoc. Click "Cancel" to return.'));
            return null;
        }
    }
    
    public void googleMapRequestOnly(){
        achieveWithStatusUpdate = false;
        googleMapRequest();
    }
    
    public void googleMapRequest(){
        system.debug('Start googleMapRequest');
        
        detail = [Select ASI_HK_CRM_Status__c, ASI_CRM_GPS_Location__c, ASI_CRM_GPS_Location__Latitude__s, ASI_CRM_GPS_Location__Longitude__s, ASI_CRM_Visit_Address__c From ASI_HK_CRM_Visitation_Plan_Detail__c Where Id = :detail.Id];
		//Wilken 20161027, add Google API Project Key to allow 2500 API call per day, key can be created at https://console.developers.google.com/apis/credentials?project=_
        //String contentURL = 'http://maps.googleapis.com/maps/api/geocode/xml?latlng=';
		String contentURL = 'https://maps.googleapis.com/maps/api/geocode/xml?key=AIzaSyBzLGY0GBeRFDrWEzcF6noGEtbdgzM7VkQ&latlng=';
        detail.ASI_CRM_GPS_Location__Latitude__s = Decimal.ValueOf(latitudeStr);
        detail.ASI_CRM_GPS_Location__Longitude__s = Decimal.ValueOf(longitudeStr);
        contentURL = contentURL + detail.ASI_CRM_GPS_Location__Latitude__s + ',' + detail.ASI_CRM_GPS_Location__Longitude__s;
        
        system.debug('contentURL ' + contentURL);
        log+= ' contentURL: ' + contentURL;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(contentURL);
        req.setMethod('GET');
        req.setTimeout(30000);
        
        try{
            res = h.send(req);
            Dom.Document doc = new Dom.Document();
            
            system.debug('response.getBody****' + res.getBody());
            log+= ' response.getBody: ' + res.getBody();
            
            doc.load(res.getBody());
            Dom.XMLNode Envelope = doc.getRootElement();
            
            system.debug('Child Element Size: ' + Envelope.getChildElements().size());
            log+= ' Child Element Size: ' + Envelope.getChildElements().size();
            
            for(Dom.XMLNode rst:Envelope.getChildElements()){
                if(rst.getName() == 'result'){
                    for(Dom.XMLNode e:rst.getChildElements()){
                        if(e.getName() == 'formatted_address'){
                            detail.ASI_CRM_Visit_Address__c = e.getText();
                            
                            if (achieveWithStatusUpdate)
                                detail.ASI_HK_CRM_Status__c = 'Achieved';
                            
                            system.debug('Visit Address: ' + detail.ASI_CRM_Visit_Address__c);
                            log+= ' Visit Address: ' + e.getText();
                        }
                    }
                    break;
                }
            }
            detail.ASI_TH_CRM_Activity_Remarks__c = log;
            
            update detail;  
            
            statusDisplay = 'Achieved';
        }
        catch(exception e){
            ApexPages.addMessages(e);
        }
        //return new PageReference('#/sObject/' + detail.Id + '/view');
    } 
}