/*********************************************************************************
 * Name:ASI_CRM_SG_VisitDetailGPSController
 * Description: save GPS for SG CRM
 *
 * Version History
 * Date               Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 28/08/2017       Wilken Lee          	Created
*********************************************************************************/
public with sharing class ASI_CRM_SG_VisitDetailGPSController{
    public ASI_HK_CRM_Visitation_Plan_Detail__c detail {get;set;}
    public String latitudeStr{get;set;}
    public String longitudeStr{get;set;}
	public Boolean isCheckIn = false;
	public Boolean isCheckOut = false;
	
    public String log = '';
    
    public ASI_CRM_SG_VisitDetailGPSController(ApexPages.StandardController stdController){
        detail = (ASI_HK_CRM_Visitation_Plan_Detail__c) stdController.getRecord();
        if(detail != null){
            detail = [Select ASI_HK_CRM_Status__c, ASI_CRM_GPS_Location__c, ASI_CRM_Visit_Address__c From ASI_HK_CRM_Visitation_Plan_Detail__c Where Id = :detail.Id];
            system.debug('Visit Detail: ' + detail);
        }
    }
    
	public void googleMapRequestCheckIn(){
        isCheckIn = true;
        googleMapRequest();
    }
	
	public void googleMapRequestCheckOut(){
        isCheckOut = true;
        googleMapRequest();
    }
	
    public void googleMapRequest(){
        system.debug('Start googleMapRequest');
        
        detail = [Select ASI_TH_CRM_Visit_Date_Time_From__c, ASI_TH_CRM_Visit_Date_Time_To__c, 
			ASI_CRM_Check_In_Location__c, ASI_CRM_Check_In_Geolocation__Latitude__s, ASI_CRM_Check_In_Geolocation__Longitude__s,
				ASI_CRM_Check_Out_Location__c, ASI_CRM_Check_Out_Geolocation__Latitude__s, ASI_CRM_Check_Out_Geolocation__Longitude__s 
					From ASI_HK_CRM_Visitation_Plan_Detail__c Where Id = :detail.Id];
		//Wilken 20161027, add Google API Project Key to allow 2500 API call per day, key can be created at https://console.developers.google.com/apis/credentials?project=_
        //String contentURL = 'http://maps.googleapis.com/maps/api/geocode/xml?latlng=';
		String contentURL = 'https://maps.googleapis.com/maps/api/geocode/xml?key=AIzaSyBzLGY0GBeRFDrWEzcF6noGEtbdgzM7VkQ&latlng=';
		
		if (isCheckIn){
			detail.ASI_CRM_Check_In_Geolocation__Latitude__s = Decimal.ValueOf(latitudeStr);
			detail.ASI_CRM_Check_In_Geolocation__Longitude__s = Decimal.ValueOf(longitudeStr);
			contentURL = contentURL + detail.ASI_CRM_Check_In_Geolocation__Latitude__s + ',' + detail.ASI_CRM_Check_In_Geolocation__Longitude__s;
		}
		else if (isCheckOut){
			detail.ASI_CRM_Check_Out_Geolocation__Latitude__s = Decimal.ValueOf(latitudeStr);
			detail.ASI_CRM_Check_Out_Geolocation__Longitude__s = Decimal.ValueOf(longitudeStr);
			contentURL = contentURL + detail.ASI_CRM_Check_Out_Geolocation__Latitude__s + ',' + detail.ASI_CRM_Check_Out_Geolocation__Longitude__s;
		}
        
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
                            if (isCheckIn){
								detail.ASI_CRM_Check_In_Location__c = e.getText();
								detail.ASI_TH_CRM_Visit_Date_Time_From__c = Datetime.Now();
								system.debug('Check In: ' + detail.ASI_CRM_Check_In_Location__c);
							}
							else if (isCheckOut){
								detail.ASI_CRM_Check_Out_Location__c = e.getText();
								detail.ASI_TH_CRM_Visit_Date_Time_To__c = Datetime.Now();
								system.debug('Check Out: ' + detail.ASI_CRM_Check_Out_Location__c);
							}							
                            log+= ' Visit Address: ' + e.getText();
                        }
                    }
                    break;
                }
            }
            update detail;  
        }
        catch(exception e){
            ApexPages.addMessages(e);
        }
    } 
}