/**
 * Test Class : Test_EUR_TR_CensusController
 */

public with sharing class EUR_TR_CensusControllerUtil {

    @Future(callout=TRUE)
    public static void doCallout() {
        EUR_TR_ApplicationConfiguration__c prefs = [SELECT EUR_TR_AutoStartVisit__c,
                EUR_TR_Census_Password__c,
                EUR_TR_Census_Url__c,
                EUR_TR_Census_Username__c,
                EUR_TR_CollectContacts__c,
                EUR_TR_GPSVerificationRange__c,
                EUR_TR_iOSTabletForceUpdate__c,
                EUR_TR_iOSTabletVersion__c,
                EUR_TR_RemPeople_Password__c,
                EUR_TR_RemPeople_Url__c,
                EUR_TR_RemPeople_Username__c,
                EUR_TR_SetupUrliOSTablet__c,
                EUR_TR_SMS_Service_Url__c FROM EUR_TR_ApplicationConfiguration__c WHERE RecordType.DeveloperName ='ApplicationConfiguration' LIMIT 1];

        String url = prefs.EUR_TR_Census_Url__c;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        CensusRequest reqBody = new CensusRequest();
        reqBody.Username = prefs.EUR_TR_Census_Username__c;
        reqBody.Password = prefs.EUR_TR_Census_Password__c;
        req.setEndpoint(url);
        req.setBody(JSON.serialize(reqBody));
        req.setMethod('POST');
        req.setTimeout(60000);
        req.setHeader('content-type', 'application/json');
        HttpResponse res = new HttpResponse();
        List<List<EUR_TR_Account__c>> audits = new List<List<EUR_TR_Account__c>>();
        try {
            res = h.send(req);
            if (res.getStatusCode() == 200) {
                if (String.isNotBlank(res.getBody())) {
                    String responseTest = res.getBody().replace('"long":', '"lng":');
                    CensusResult response = (CensusResult) JSON.deserialize(responseTest, CensusResult.class);
                    if (String.isBlank(response.error)) {
                        Integer index = 0;
                        Integer recordCount = 0;
                        for (CensusResultItem item : response.items) {
                            if (math.mod(recordCount, 10000) == 0) {
                                audits.add(new List<EUR_TR_Account__c>());
                                index = recordCount / 10000;
                            }

                            EUR_TR_Account__c account = new EUR_TR_Account__c();
                            account.EUR_TR_TAPDKNo__c = item.companyCode;
                            account.Name = item.name.length() > 80 ? item.name.substring(80) : item.name;
                            account.EUR_TR_LocalName__c = item.name.length() > 255 ? item.name.substring(255) : item.name;
                            account.EUR_TR_RegisteredName__c = item.nameOnBoard.length() > 255 ? item.nameOnBoard.substring(255) : item.nameOnBoard;
                            account.EUR_TR_CensusDate__c = item.completedDateTimeFormatted;
                            account.EUR_TR_CensusLocation__Latitude__s = item.lat;
                            account.EUR_TR_CensusLocation__Longitude__s = item.lng;
                            account.EUR_TR_CensusImageUrl__c = item.photoUrlsFormatted;
                            account.EUR_TR_CensusChannel__c = item.channelName;
                            account.EUR_TR_CensusId__c = String.valueOf(item.remId);
                            account.EUR_TR_CensusType__c = item.distributionType;
                            account.EUR_TR_CensusScore__c = String.valueOf(item.censusScore);
                            account.EUR_TR_HasCensus__c = true;

                            recordCount++;
                            audits.get(index).add(account);
                        }

                        System.debug('audit size: ' + audits.size());
                        for (Integer i = 0; i < audits.size(); i++) {
                            //upsert audits.get(i) EUR_TR_RemId__c;
                            List<Database.UpsertResult> result = Database.Upsert(audits.get(i), EUR_TR_Account__c.Fields.EUR_TR_TAPDKNo__c, false);

                            System.debug('audit i size: ' + audits.get(i).size());

                            for (Database.UpsertResult re : result) {
                                Database.Error[] errors = re.getErrors();
                                for (Database.Error e : errors) {
                                    System.debug('e: ' + e.getMessage());
                                }
                            }


                        }
                    } else {
                        System.debug('Census service returned an error: ' + response.error);
                    }
                } else {
                    //response has empty body
                    System.debug('Census service returned empty result');
                }
            } else {
                //response not 200
                System.debug('Census service returned http status code : ' + res.getStatusCode() + ' - ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('Census service execution error: ' + e.getMessage());
        }
    }

    public class CensusRequest {
        public String Username { get; set; }
        public String Password { get; set; }
    }

    public class CensusResult {
        public String error { get; set; }
        public List<CensusResultItem> items { get; set; }
    }

    public class CensusResultItem {
        public String companyCode { get; set; } //"85221"
        public String name { get; set; }
        public String nameOnBoard { get; set; }
        public Decimal lat { get; set; }
        public Decimal lng { get; set; }
        public String channelName { get; set; }
        public String distributionType { get; set; }
        public Integer remId { get; set; } //564175
        public Decimal censusScore { get; set; }
        public String completedDateTime { get; set; } //"2019-03-24T09:59:56+00:00"
        public List<String> photos { get; set; }
        public String photoUrlsFormatted {
            get {
                return String.join(photos, ' ');
            }
        }
        public Datetime completedDateTimeFormatted {
            get {
                if (String.isNotBlank(completedDateTime)) {
                    Integer year = Integer.valueOf(completedDateTime.substring(0, 4));
                    Integer month = Integer.valueOf(completedDateTime.substring(5, 7));
                    Integer day = Integer.valueOf(completedDateTime.substring(8, 10));
                    Integer hour = Integer.valueOf(completedDateTime.substring(11, 13));
                    Integer minute = Integer.valueOf(completedDateTime.substring(14, 16));
                    Integer second = Integer.valueOf(completedDateTime.substring(17, 19));
                    return Datetime.newInstance(year, month, day, hour, minute, second);
                } else {
                    return Datetime.now();
                }
            }
        }
    }
}