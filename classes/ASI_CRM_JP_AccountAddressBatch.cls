/*********************************************************************************
 * Name:ASI_CRM_JP_AccountAddressBatch
 * Description: 
 * Test Class: ASI_CRM_JP_AccountAddressBatch_Test
 * 
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/10/2019       Wilken Lee          	[WL 1.0] Stop sending callOut during test execution
*********************************************************************************/
global class ASI_CRM_JP_AccountAddressBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	public static final Integer TIMEOUT = 20000;
    private ASI_CRM_JP_Settings__c my_cs = ASI_CRM_JP_Settings__c.getInstance();
    public String API_KEY{get; private set;}{API_KEY = my_cs != null && my_cs.ASI_CRM_JP_Google_API_KEY__c != null ? my_cs.ASI_CRM_JP_Google_API_KEY__c : 'AIzaSyAz-G6GDwcN0c4XRvReLmUVImv-spOynU8';}
    
    
    global ASI_CRM_JP_AccountAddressBatch(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
			SELECT Id, ASI_CRM_JP_CONCAT_ADDRESS__c
            FROM ASI_CRM_AccountsAdditionalField__c
            WHERE RecordType.DeveloperName LIKE '%ASI_CRM_JP%'
            AND (ASI_CRM_MY_GeoConverStatus__c = 'Pending' OR ASI_CRM_MY_GeoConverStatus__c = null OR ASI_CRM_MY_GeoConverStatus__c = '')
            AND ASI_CRM_JP_CONCAT_ADDRESS__c != null
        ]);   
    }
    
    
    global void execute(Database.BatchableContext BC, List<ASI_CRM_AccountsAdditionalField__c> scope) {
        
        if(!String.isBlank(API_KEY)){
            
            for(ASI_CRM_AccountsAdditionalField__c account : scope){
                if(!String.isBlank(account.ASI_CRM_JP_CONCAT_ADDRESS__c)){
                    String address = account.ASI_CRM_JP_CONCAT_ADDRESS__c;
                    address = address.toUpperCase();
                    //boolean isContainKeyword = address.contains('MALAYSIA');
					//address = isContainKeyword ? address : (address+', MALAYSIA');          
                    //address = address.replaceAll( '\\s+', '+');
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
						 if (!Test.isRunningTest())	//WL 1.0
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
                        if(Test.isRunningTest()){
                            statusCode = 200;
                        }
                        
                        if(statusCode==200){
                            String bodyString = response.getBody();
                            if(Test.isRunningTest()){
                                bodyString = '{"results":[{"address_components":[{"long_name":"Muir Lane","short_name":"Muir Ln","types":["route"]},{"long_name":"Torrey Pines","short_name":"Torrey Pines","types":["neighborhood","political"]},{"long_name":"San Diego","short_name":"San Diego","types":["locality","political"]},{"long_name":"San Diego County","short_name":"San Diego County","types":["administrative_area_level_2","political"]},{"long_name":"California","short_name":"CA","types":["administrative_area_level_1","political"]},{"long_name":"United States","short_name":"US","types":["country","political"]},{"long_name":"92161","short_name":"92161","types":["postal_code"]}],"formatted_address":"Muir Ln, San Diego, CA 92161, USA","geometry":{"location":{"lat":32.8790299,"lng":-117.2413533},"location_type":"GEOMETRIC_CENTER","viewport":{"northeast":{"lat":32.8803788802915,"lng":-117.2400043197085},"southwest":{"lat":32.8776809197085,"lng":-117.2427022802915}}},"place_id":"ChIJV1aG1sAG3IAR6EsgRezpoa0","plus_code":{"compound_code":"VQH5+JF San Diego, California, United States","global_code":"8544VQH5+JF"},"types":["establishment","point_of_interest","school"]}],"status":"OK"}';
                            }
                            system.debug('response.getBody()='+bodyString);
                            ASI_CRM_JP_AddressMap addressMap = ASI_CRM_JP_AddressMap.parse(bodyString);
                            if(addressMap.status == 'OK'){
                                if(addressMap.results.size() > 0){
                                    ASI_CRM_JP_AddressMap.Results result = addressMap.results[0];
                                    ASI_CRM_JP_AddressMap.Geometry geometry = result.geometry;
                                    Double latitude = geometry.location.lat;
                                    Double longitude = geometry.location.lng;
                                    system.debug('@@@latitude: '+latitude);
                                    system.debug('@@@longitude: '+longitude);
                                    account.ASI_CRM_MY_GeoConverStatus__c = 'Completed';
                                    account.ASI_CRM_CN_GPS_info__Latitude__s = latitude;
                                    account.ASI_CRM_Latitude__c  = latitude;
                                    account.ASI_CRM_CN_GPS_info__Longitude__s = longitude;
                                    account.ASI_CRM_Longitude__c = longitude;
                                }
                                else{
                                    account.ASI_CRM_MY_GeoConverStatus__c = 'Failed';
                                }
                            }
                            else{
                                account.ASI_CRM_MY_GeoConverStatus__c = 'Failed';
                                account.ASI_CRM_CN_GPS_info__Latitude__s = null;
                                account.ASI_CRM_Latitude__c = null;
                                account.ASI_CRM_CN_GPS_info__Longitude__s = null;
                                account.ASI_CRM_Longitude__c = null;
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