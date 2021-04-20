global class ASI_CRM_SG_AccountAddressBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	public static final Integer TIMEOUT = 20000;
    private ASI_CRM_SG_Settings__c my_cs = ASI_CRM_SG_Settings__c.getInstance();
    public String API_KEY{get; private set;}{API_KEY = my_cs != null && my_cs.ASI_CRM_SG_Google_API_KEY__c != null ? my_cs.ASI_CRM_SG_Google_API_KEY__c : 'AIzaSyAz-G6GDwcN0c4XRvReLmUVImv-spOynU8';}
    
    
    global ASI_CRM_SG_AccountAddressBatch(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
			SELECT Id, ASI_CRM_JP_Address__c
            FROM ASI_CRM_AccountsAdditionalField__c
            WHERE RecordType.DeveloperName LIKE '%ASI_CRM_SG%'
            AND (ASI_CRM_MY_GeoConverStatus__c = 'Pending' OR ASI_CRM_MY_GeoConverStatus__c = null OR ASI_CRM_MY_GeoConverStatus__c = '')
            AND ASI_CRM_JP_Address__c != null
        ]);   
    }
    
    
    global void execute(Database.BatchableContext BC, List<ASI_CRM_AccountsAdditionalField__c> scope) {
        
        if(!String.isBlank(API_KEY)){
            
            for(ASI_CRM_AccountsAdditionalField__c account : scope){
                if(!String.isBlank(account.ASI_CRM_JP_Address__c)){
                    String address = account.ASI_CRM_JP_Address__c;
                    address = address.toUpperCase();
                    boolean isContainKeyword = address.contains('SINGAPORE');
					address = isContainKeyword ? address : (address+', SINGAPORE');          
                    address = address.replaceAll( '\\s+', '+');
                    //String encoded = EncodingUtil.urlEncode(url, 'UTF-8');
					address = EncodingUtil.urlEncode(address, 'UTF-8');
                    system.debug('@@@address: '+address);
                    String endPoint = 'https://maps.googleapis.com/maps/api/geocode/json?address='+address+'&key='+API_KEY;
                    Boolean isTimeOut = false;
                    Integer statusCode;
                    HttpRequest request = new HttpRequest();
                    //String requestBody =JSON.serialize(pointAdj_Wrapper);
                    //system.debug('@@@requestBody: '+requestBody);
                    request.setMethod('GET');
                    request.setEndpoint(endPoint);
                    request.setHeader('Content-Type', 'application/json');
                    //request.setHeader('Authorization', token);
                    request.setTimeout(TIMEOUT); // timeout in milliseconds
                    //request.setBody(requestBody);
                    
                    HttpResponse response = new HttpResponse();
                    Http http = new Http();
                    
                    try {    
                        //Call out to Heroku to authen (RESTFUL)
                        response = http.send(request);
                        //System.debug('responseBody: '+response.getBody());
                    }
                    catch(System.CalloutException e){
                        //if time-out
                        if (e.getmessage().containsIgnoreCase('read timed out')){
                            isTimeOut = true;
            
                        }
                        else{
            
                        }
                        System.debug('Error::'+e.getMessage());
                    }
                    finally{
                        statusCode=response.getStatusCode();
                        system.debug('statusCode='+statusCode);
                        if(statusCode==200){
                            system.debug('response.getBody()='+response.getBody());
                            //ASI_CRM_MY_AddressMap addressMap = (ASI_CRM_MY_AddressMap) JSON.deserialize(response.getBody(), ASI_CRM_MY_AddressMap.Class);
                            ASI_CRM_MY_AddressMap addressMap = ASI_CRM_MY_AddressMap.parse(response.getBody());
                            if(addressMap.status == 'OK'){
                                if(addressMap.results.size() > 0){
                                    ASI_CRM_MY_AddressMap.Results result = addressMap.results[0];
                                    ASI_CRM_MY_AddressMap.Geometry geometry = result.geometry;
                                    Double latitude = geometry.location.lat;
                                    Double longitude = geometry.location.lng;
                                    system.debug('@@@latitude: '+latitude);
                                    system.debug('@@@longitude: '+longitude);
                                    account.ASI_CRM_MY_GeoConverStatus__c = 'Completed';
                                    account.ASI_CRM_CN_GPS_info__Latitude__s = latitude;
                                    account.ASI_CRM_CN_GPS_info__Longitude__s = longitude;
                                }
                                else{
                                    account.ASI_CRM_MY_GeoConverStatus__c = 'Failed';
                                }
                            }
                            else{
                                account.ASI_CRM_MY_GeoConverStatus__c = 'Failed';
                                account.ASI_CRM_CN_GPS_info__Latitude__s = null;
                                account.ASI_CRM_CN_GPS_info__Longitude__s = null;
                            }
                        }
                        else{
                            account.ASI_CRM_MY_GeoConverStatus__c = 'Failed';
                        }
                    }
                    
                }
            }
            
            Database.update(scope, false);
            /*
            Database.SaveResult[] l_update = Database.Insert(scope, false);
            for(Integer i=0; i<l_update.size(); i++){
                Database.SaveResult sr = l_update[i];
                if (!sr.isSuccess()) {
                    
                }
            }
            */
        }
    }
    
    
    
    global void finish(Database.BatchableContext BC) {
        
    }
	    
}