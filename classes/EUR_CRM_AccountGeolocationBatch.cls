global without sharing class EUR_CRM_AccountGeolocationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable{

//    Database.executeBatch(new EUR_CRM_AccountGeolocationBatch(), 100);

//    String cronExpression = '0 0 1 * * ?'; // Runs every day at 1 AM
//    EUR_CRM_AccountGeolocationBatch scheduledJob = new EUR_CRM_AccountGeolocationBatch();
//    String jobID = System.schedule('EUR_CRM_AccountGeolocationBatch: Populate Accounts geolocation', cronExpression, scheduledJob);

    public static final Map<String, String> ROLLOUT_COUNTRY_CODES = new Map<String, String>();
    static {
        for(EUR_CRM_Rollout_Country__mdt setting :[SELECT DeveloperName, CountryName__c FROM EUR_CRM_Rollout_Country__mdt]) {
            ROLLOUT_COUNTRY_CODES.put(setting.DeveloperName, setting.CountryName__c);
        }
    }

    global List<ErrorMessage> errorMessages = new List<ErrorMessage>();
    private static final String BAD_REQUEST_ERROR_MESSAGE = 'Bad request';
    private static final String WRONG_ADDRESS_ERROR_MESSAGE = 'Wrong address';
    private static final EUR_CRM_GoogleMapAPIKey__mdt googleApi = selectGoogleMapApiCMT();
    private Boolean isRunForAll = false;


    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EUR_CRM_AccountGeolocationBatch(), 100);
    }

    public static void executeForAll() {
        Database.executeBatch(new EUR_CRM_AccountGeolocationBatch(true), 100);
    }

    public EUR_CRM_AccountGeolocationBatch() {

    }

    public EUR_CRM_AccountGeolocationBatch(Boolean isRunForAll) {
        this.isRunForAll = isRunForAll;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(isRunForAll == false) {
            return Database.getQueryLocator([
                    SELECT Id
                            , Name
                            , EUR_CRM_Country__c
                            , EUR_CRM_Country_Code__c
                            , EUR_CRM_City__c
                            , EUR_CRM_Postal_Code__c
                            , EUR_CRM_Street__c
                            , EUR_CRM_Building_Number__c
                            , EUR_CRM_Outlet_Geolocation__Latitude__s
                            , EUR_CRM_Outlet_Geolocation__Longitude__s
                            , EUR_CRM_Outlet_Geolocation__c
                            , EUR_CRM_OutletGeolocationRecalculation__c
                    FROM EUR_CRM_Account__c
                    WHERE EUR_CRM_OutletGeolocationRecalculation__c = true AND EUR_CRM_Country_Code__c IN :ROLLOUT_COUNTRY_CODES.keySet()
            ]);
        } else {
            return Database.getQueryLocator([
                    SELECT Id
                            , Name
                            , EUR_CRM_Country__c
                            , EUR_CRM_Country_Code__c
                            , EUR_CRM_City__c
                            , EUR_CRM_Postal_Code__c
                            , EUR_CRM_Street__c
                            , EUR_CRM_Building_Number__c
                            , EUR_CRM_Outlet_Geolocation__Latitude__s
                            , EUR_CRM_Outlet_Geolocation__Longitude__s
                            , EUR_CRM_Outlet_Geolocation__c
                            , EUR_CRM_OutletGeolocationRecalculation__c
                    FROM EUR_CRM_Account__c
                    WHERE
                        EUR_CRM_Country_Code__c IN :ROLLOUT_COUNTRY_CODES.keySet() AND
                        EUR_CRM_City__c != null AND
                        EUR_CRM_Street__c != null
            ]);
        }
    }

    global void execute(Database.BatchableContext BC, List<EUR_CRM_Account__c> scope) {
        polulateLocationFromGoogleApi(scope);
    }

    public void polulateLocationFromGoogleApi(List<EUR_CRM_Account__c> scope) {
        Map<Id, EUR_CRM_Account__c> updateAccounts = new Map<Id, EUR_CRM_Account__c>();
        for (EUR_CRM_Account__c acc : scope) {
            Coordinates coordinates = getCoordinates(new GeocodingAPIRequest(acc));
            System.debug('account : ' + acc.Id + ', coordinates : ' + coordinates);

            if (coordinates == null) {
                ErrorMessage message = new ErrorMessage(acc.Id, acc.Name, acc.EUR_CRM_Country__c, acc.EUR_CRM_City__c, acc.EUR_CRM_Street__c, null);
                message.errorMessage = BAD_REQUEST_ERROR_MESSAGE;
                errorMessages.add(message);
                continue;
            } else if (coordinates.Lat == null || coordinates.Lon == null) {
                ErrorMessage message = new ErrorMessage(acc.Id, acc.Name, acc.EUR_CRM_Country__c, acc.EUR_CRM_City__c, acc.EUR_CRM_Street__c, null);
                message.errorMessage = WRONG_ADDRESS_ERROR_MESSAGE;
                errorMessages.add(message);
            } else if(acc.EUR_CRM_Outlet_Geolocation__latitude__s != coordinates.Lat || acc.EUR_CRM_Outlet_Geolocation__longitude__s != coordinates.Lon){
                acc.EUR_CRM_Outlet_Geolocation__latitude__s = coordinates.Lat;
                acc.EUR_CRM_Outlet_Geolocation__longitude__s = coordinates.Lon;
                updateAccounts.put(acc.Id, acc);
            }

            if(acc.EUR_CRM_OutletGeolocationRecalculation__c == true) {
                acc.EUR_CRM_OutletGeolocationRecalculation__c = false;
                updateAccounts.put(acc.Id, acc);
            }
        }
        List<Database.SaveResult> updateResults = Database.update(updateAccounts.values(), false);
        this.getErrorMessages(updateResults, updateAccounts.values());
        System.debug('execute method errorMessages : ' + JSON.serializePretty(errorMessages));
    }

    global void finish(Database.BatchableContext BC) {
        String body = '';
        AsyncApexJob a = this.selectBatchInfo(BC);
        if (Test.isRunningTest()) {
            errorMessages.add(new ErrorMessage(null, 'errorAccName', 'errorCountry', 'errorCity', 'errorStreet', null));
        }

        if (a.ExtendedStatus != null) {
            body += 'Batch Status Detail : ' + a.ExtendedStatus;
            body += 'Number Of Errors : ' + a.NumberOfErrors + '\n';
        }
        if (!errorMessages.isEmpty() && !Test.isRunningTest()) {
            body = 'Accounts size that not updated : ' + errorMessages.size() + '\n\n';
            for (ErrorMessage errorMessage : errorMessages) {
                body += 'Id: ' + errorMessage.accountId + '; ';
                body += 'Name: ' + errorMessage.accountName + '; ';
                body += 'Address: ' + errorMessage.street + ', ' + errorMessage.city + ', ' + errorMessage.country + '; ';
                if (errorMessage.errorMessage != null) {
                    body += 'Error status code: ' + errorMessage.statusCode + ' ' + errorMessage.errorMessage + '; ';
                    body += 'Fields that cause the error: ' + errorMessage.errorFields + '; ';
                }
                body += '\n';
            }
        }
        this.sendEmailReport(BC, body);
    }

    public static void updateLocationOnbeforeInsert(List<EUR_CRM_Account__c> accounts) {
        for(EUR_CRM_Account__c acc: accounts) {
            if(ROLLOUT_COUNTRY_CODES.keySet().contains(acc.EUR_CRM_Country_Code__c) && String.isNotBlank(acc.EUR_CRM_City__c) && String.isNotBlank(acc.EUR_CRM_Street__c)) {
                acc.EUR_CRM_OutletGeolocationRecalculation__c = true;
            }
        }
    }

    public static void updateLocationOnbeforeUpdate(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        for(EUR_CRM_Account__c acc: accounts) {
            EUR_CRM_Account__c oldAcc = oldAccountById.get(acc.Id);
            if(!ROLLOUT_COUNTRY_CODES.keySet().contains(acc.EUR_CRM_Country_Code__c) || String.isBlank(acc.EUR_CRM_City__c) || String.isBlank(acc.EUR_CRM_Street__c)) continue;
            if(acc.EUR_CRM_Country_Code__c != oldAcc.EUR_CRM_Country_Code__c || acc.EUR_CRM_City__c != oldAcc.EUR_CRM_City__c || acc.EUR_CRM_Street__c != oldAcc.EUR_CRM_Street__c) {
                acc.EUR_CRM_OutletGeolocationRecalculation__c = true;
            }
        }
    }

    private void sendEmailReport(Database.BatchableContext BC, String body) {
        AsyncApexJob a = this.selectBatchInfo(BC);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = googleApi.EUR_CRM_EmailRecipients__c.split('[;,]');
        mail.setToAddresses(toAddresses);
        mail.setSubject('AccountGeolocationBatch _ ' + a.Status);
        mail.setPlainTextBody(body);
        if (body.length() > 0 && !Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });
        }
        System.debug('toAddress: ' + JSON.serializePretty(toAddresses));
    }

//    public static Coordinates getCoordinates(String fullAddress) {
//
//
////        String apiKey = 'AIzaSyBV083cbIW8xcsY521OyhHoDvlcKaCewe0';
////        EUR_CRM_GoogleMapAPIKey__mdt googleApi = [SELECT Id, Label, EUR_CRM_APIkey__c, EUR_CRM_UrlAddress__c FROM EUR_CRM_GoogleMapAPIKey__mdt LIMIT 1];
//        String apiKey = googleApi.EUR_CRM_APIkey__c;
//        String url = googleApi.EUR_CRM_UrlAddress__c;
//        url += 'address=' + fullAddress;
//        url += '&key=' + apiKey;
//
//        Http h = new Http();
//        HttpRequest req = new HttpRequest();
//        req.setMethod('GET');
//        req.setEndpoint(url);
//        HttpResponse res;
//
//        res = h.send(req);
//
//        if (res.getStatusCode() == 200) {
//            JSONParser parser = JSON.createParser(res.getBody());
//            system.debug('response::' + res.getBody());
//            double lat = null;
//            double lon = null;
//            while (parser.nextToken() != null || (lat != null && lon != null)) {
//                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
//                        (parser.getText() == 'location')) {
//                    parser.nextToken();
//                    while (parser.nextToken() != JSONToken.END_OBJECT || (lat != null && lon != null)) {
//                        String txt = parser.getText();
//                        parser.nextToken();
//                        if (txt == 'lat') {
//                            lat = parser.getDoubleValue();
//                        } else if (txt == 'lng') {
//                            lon = parser.getDoubleValue();
//                        }
//                    }
//                }
//            }
//            return new Coordinates(lat, lon);
//        } else {
//            return null;
//        }
//    }

    public static Coordinates getCoordinates(GeocodingAPIRequest apiRequest) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(apiRequest.getURL());
        req.setTimeout(120000);
        HttpResponse res;

        try {
            res = h.send(req);
        } catch(Exception ex) {
            System.debug('Http Exception: ' + ex.getMessage());
            return null;
        }

        if (res.getStatusCode() == 200) {
            System.debug('res.getBody(): ' + res.getBody());
            List<Object> results = (List<Object>)getElementFromJSON(res.getBody(), 'results');
            System.debug('results: ' + results);
            if (results == null || results.isEmpty()) {
                return new Coordinates(null, null);
            }
            Object geometry = getElementFromObject(results[0], 'geometry');
            Object location = getElementFromObject(geometry, 'location');
            Double lat =(Double) getElementFromObject(location, 'lat');
            Double lon =(Double) getElementFromObject(location, 'lng');
            List<Object> types = (List<Object>)getElementFromObject(results[0], 'types');
            for (Object resultType: types) {
                if ((String)resultType == 'country') {
                    return new Coordinates(null, null);
                }
            }
            return new Coordinates(lat, lon);
        } else {
            return null;
        }
    }

    private static Object getElementFromJSON(String jsonString, String element) {
        Map<String, Object> objectMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        return objectMap.get(element);
    }

    private static Object getElementFromObject(Object obj, String element) {
        if (obj == null) {
            return null;
        }

        Map<String, Object> objectMap = (Map<String, Object>) obj;
        return objectMap.get(element);
    }

    public class Coordinates {
        public Double Lat {
            get;
            private set;
        }
        public Double Lon {
            get;
            private set;
        }

        public Coordinates(Double newLat, Double newLong) {
            this.Lat = newLat;
            this.Lon = newLong;
        }
    }

    public class ErrorMessage {
        public Id accountId ;
        public String accountName;
        public String country;
        public String city;
        public String street;
        public String errorMessage;
        public String statusCode;
        public List<String> errorFields;


        public ErrorMessage(Id accountId, String accountName, String country, String city, String street, Database.Error error) {
            this.accountId = accountId;
            this.accountName = accountName;
            this.country = country;
            this.city = city;
            this.street = street;
            this.errorMessage = error == null ? null : error.getMessage();
            this.errorFields = error == null ? null : error.getFields();
            this.statusCode = error == null ? null : error.getStatusCode().name();
        }
    }

    public class GeocodingAPIRequest {
        private String url = googleApi.EUR_CRM_UrlAddress__c;
        private String key = googleApi.EUR_CRM_APIkey__c;
        private String address;
//        private List<GeocodingAPIRequestComponent> components = new List<GeocodingAPIRequestComponent>();

        public GeocodingAPIRequest(EUR_CRM_Account__c acc) {
            String street = acc.EUR_CRM_Street__c == null ?  '' : acc.EUR_CRM_Street__c.replace('&', 'and');
            String country = ROLLOUT_COUNTRY_CODES.get(acc.EUR_CRM_Country_Code__c);
            address = street;

            if(String.isNotBlank(acc.EUR_CRM_Building_Number__c)) {
                address += ', ' + acc.EUR_CRM_Building_Number__c;
            }
            address += ', ' + acc.EUR_CRM_City__c;

            if(String.isNotBlank(acc.EUR_CRM_Postal_Code__c)) {
                address += ', ' + acc.EUR_CRM_Postal_Code__c;
//                components.add(new GeocodingAPIRequestComponent('postal_code', acc.EUR_CRM_Postal_Code__c));
            }
            if(String.isNotBlank(country)) {
                address += ', ' + country;
            }
            if(String.isNotBlank(acc.EUR_CRM_Country_Code__c)) {
//                components.add(new GeocodingAPIRequestComponent('country', country));
            }
            System.debug('address = ' + address);
            address = EncodingUtil.urlEncode(address, 'utf-8');
        }

        public String getURL() {
            String urlWithParamsParams = url;

            urlWithParamsParams += 'address=' + address;

//            if(!components.isEmpty()) {
//                urlWithParamsParams += '&components=' + componentsToString();
//            }
            urlWithParamsParams += '&key=' + key;

            System.debug('URL: ' + urlWithParamsParams);
            return urlWithParamsParams;
        }

//        private String componentsToString() {
//            Set<String> stringCompoments = new Set<String>();
//            for(GeocodingAPIRequestComponent c : components) {
//                stringCompoments.add(c.toString());
//            }
//            return String.join(new List<String>(stringCompoments), '|');        }
//
    }
//
//    public class GeocodingAPIRequestComponent {
//        public String component;
//        public String value;
//
//        public GeocodingAPIRequestComponent(String component, String value) {
//            this.component = EncodingUtil.urlEncode(component, 'utf-8');
//            this.value = EncodingUtil.urlEncode(value, 'utf-8');
//        }
//
//        override public String toString() {
//            return component + ':' + value;
//        }
//    }

    /* ========================================================= */
    /*     Error messages handling
    /* ========================================================= */
    @TestVisible
    private void getErrorMessages(List<Database.SaveResult> updateResults, List<EUR_CRM_Account__c> updateAccounts) {
        for (Integer i = 0; i < updateAccounts.size(); i++) {
            Database.SaveResult updateResult = updateResults.get(i);
            EUR_CRM_Account__c acc = updateAccounts.get(i);
            if (!updateResult.isSuccess()) {
                for (Database.Error error : updateResult.getErrors()) {
                    errorMessages.add(new ErrorMessage(acc.Id, acc.Name, acc.EUR_CRM_Country__c, acc.EUR_CRM_City__c, acc.EUR_CRM_Street__c, error));
                }
            }
        }
    }

    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private AsyncApexJob selectBatchInfo(Database.BatchableContext BC) {
        return [
                SELECT Id
                        , Status
                        , NumberOfErrors
                        , JobItemsProcessed
                        , TotalJobItems
                        , ApexClass.Name
                        , ExtendedStatus
                FROM AsyncApexJob
                WHERE Id = :BC.getJobId()
        ];
    }

    private static EUR_CRM_GoogleMapAPIKey__mdt selectGoogleMapApiCMT() {
        return [
                SELECT Id
                        , Label
                        , EUR_CRM_APIkey__c
                        , EUR_CRM_UrlAddress__c
                        , EUR_CRM_EmailRecipients__c
                FROM EUR_CRM_GoogleMapAPIKey__mdt
                LIMIT 1
        ];
    }


}