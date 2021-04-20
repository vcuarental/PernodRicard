/**
 * Created by osman on 15.10.2019.
 */

public with sharing class EUR_TR_RemPeopleControllerUtil {

    @Future(callout=TRUE)
    public static void doCallout(){
        RecordType r = [select Id from RecordType where DeveloperName = 'EUR_TR_RemPeople' and sObjectType = 'EUR_TR_RemPeople__c'][0];
        EUR_TR_ApplicationConfiguration__c prefs = [SELECT  EUR_TR_AutoStartVisit__c,
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

        String url = prefs.EUR_TR_RemPeople_Url__c;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        RemPeopleRequest reqBody = new RemPeopleRequest();
        reqBody.Username = prefs.EUR_TR_RemPeople_Username__c;
        reqBody.Password = prefs.EUR_TR_RemPeople_Password__c;
        req.setEndpoint(url);
        req.setBody(JSON.serialize(reqBody));
        req.setMethod('POST');
        req.setTimeout(60000);
        req.setHeader('content-type', 'application/json');
        HttpResponse res = new HttpResponse();
        List<List<EUR_TR_RemPeople__c>> audits = new List<List<EUR_TR_RemPeople__c>>();
        try{
            res = h.send(req);
            if (res.getStatusCode() == 200){
                if (String.isNotBlank(res.getBody())) {
                    RemPeopleResult response = (RemPeopleResult) JSON.deserialize(res.getBody(), RemPeopleResult.class);
                    if (String.isBlank(response.error)){
                        System.debug('response:' + response.items[0].bluepassScore + '\r\n' + response.items[0].photos);
                        Integer index = 0;
                        Integer recordCount = 0;
                        for (RemPeopleResultItem item: response.items){
                            if (math.mod(recordCount, 10000) == 0) {
                                audits.add(new List<EUR_TR_RemPeople__c>());
                                index = recordCount / 10000;
                            }
                            EUR_TR_RemPeople__c audit = new EUR_TR_RemPeople__c();
                            EUR_TR_Account__c account = new EUR_TR_Account__c(EUR_TR_AccountCode__c = item.companyCode);
                            audit.EUR_TR_RelatedAccount__r = account;
                            audit.EUR_TR_BluePassScore__c = item.bluepassScore;
                            audit.EUR_TR_CompletedDate__c = item.completedDateTimeFormatted;
                            audit.EUR_TR_MyTequilaScore__c = item.myTequilaScore;
                            audit.EUR_TR_MyVodkaScore__c = item.myVodkaScore;
                            audit.EUR_TR_MyWhiskeyScore__c = item.myWhiskeyScore;
                            audit.EUR_TR_PassportAvailabilityScore__c = item.passportAvailabilityScore;
                            audit.EUR_TR_PhotoUrls__c = item.photoUrlsFormatted;
                            audit.EUR_TR_PlacementScore__c = item.placementScore;
                            audit.EUR_TR_RemId__c = item.remId;
                            audit.EUR_TR_WhiteCriteriaScore__c = item.whiteCriteriaScore;
                            audit.RecordTypeId = r.Id;

                            recordCount++;
                            audits.get(index).add(audit);
                        }

                        System.debug('audit size: ' + audits.size());
                        for (Integer i = 0; i < audits.size(); i++){
                            //upsert audits.get(i) EUR_TR_RemId__c;
                            List<Database.UpsertResult> result = Database.Upsert(audits.get(i), EUR_TR_RemPeople__c.Fields.EUR_TR_RemId__c, false);

                            System.debug('audit i size: ' + audits.get(i).size());

                            for (Database.UpsertResult re: result){
                                Database.Error[] errors = re.getErrors();
                                for (Database.Error e: errors){
                                    System.debug('e: ' + e.getMessage());
                                }
                            }


                        }
                    }
                    else{
                        System.debug('Rem People service returned an error: ' + response.error);
                    }
                }
                else{
                    //response has empty body
                    System.debug('Rem People service returned empty result');
                }
            }
            else{
                //response not 200
                System.debug('Rem People service returned http status code : ' + res.getStatusCode() + ' - ' + res.getStatus());
            }
        }
        catch(Exception e){
            System.debug('Rem People service execution error: ' + e.getMessage());
        }

    }


    public class RemPeopleRequest{
        public String Username {get;set;}
        public String Password {get;set;}
    }

    public class RemPeopleResult{
        public String error {get;set;}
        public List<RemPeopleResultItem> items {get;set;}
    }

    public class RemPeopleResultItem{
        public String companyCode {get;set;} //"85221"
        public Integer remId {get;set;} //564175
        public Decimal bluepassScore {get;set;} //69.52
        public String completedDateTime {get;set;} //"2019-03-24T09:59:56+00:00"
        public Decimal myWhiskeyScore {get;set;} //42.86
        public Decimal myVodkaScore {get;set;} //96.8
        public Decimal whiteCriteriaScore {get;set;} //0
        public Decimal myTequilaScore {get;set;} //100
        public Decimal placementScore {get;set;} //100
        public Decimal passportAvailabilityScore {get;set;} //0
        public List<String> photos {get;set;}
        public String photoUrlsFormatted {
            get {
                return String.join(photos, ' ');
            }
        }
        public Datetime completedDateTimeFormatted {
            get {
                if (String.isNotBlank(completedDateTime)){
                    Integer year = Integer.valueOf(completedDateTime.substring(0,4));
                    Integer month = Integer.valueOf(completedDateTime.substring(5,7));
                    Integer day = Integer.valueOf(completedDateTime.substring(8,10));
                    Integer hour = Integer.valueOf(completedDateTime.substring(11,13));
                    Integer minute = Integer.valueOf(completedDateTime.substring(14,16));
                    Integer second = Integer.valueOf(completedDateTime.substring(17,19));
                    return Datetime.newInstance(year, month, day, hour, minute, second);
                }
                else{
                    return Datetime.now();
                }
            }
        }
    }

}