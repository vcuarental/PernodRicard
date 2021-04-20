/**
 * Created by illia on 14.08.18.
 */

global class EUR_CRM_AmazonImagesBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    //    Database.executeBatch(new EUR_CRM_AmazonImagesBatch(), 200);
//    Database.executeBatch(new EUR_CRM_AmazonImagesBatch('EUR_CRM_Brand__c','RU'), 1);
//    Database.executeBatch(new EUR_CRM_AmazonImagesBatch('EUR_CRM_Quality__c',null), 1);

    private static final String URL_BASE = 'https://s3-eu-west-1.amazonaws.com/';

    private String countryCode;
    private String objectType;



    global EUR_CRM_AmazonImagesBatch() {

    }

    global EUR_CRM_AmazonImagesBatch(String objectType, String countryCode) {
        this.countryCode = countryCode;
        this.objectType = objectType;
    }


    global Database.QueryLocator start(Database.BatchableContext BC) {
        String rtDevName = '';
        String query = '';
        if (objectType == 'EUR_CRM_Brand__c') {
            rtDevName = this.countryCode == null ? 'EUR_%_Brand' : 'EUR_' + this.countryCode + '_Brand';
            Set<Id> attachmentParentId = new Set<Id>();
            for (Attachment attach : [SELECT ParentId,ContentType FROM Attachment WHERE Parent.Type = 'EUR_CRM_Brand__c']){
                attachmentParentId.add(attach.ParentId);
            }
            return Database.getQueryLocator([
                    SELECT Id
                            ,   Name
                            ,   EUR_CRM_Brand_Image_url__c
                            ,   EUR_CRM_External_ID__c
                            ,   EUR_CRM_ImageID__c
                            , RecordType.DeveloperName
                            ,   (
                            SELECT Id
                                    ,   Name
                            FROM Attachments
                            WHERE ContentType = 'image/png'
                    )
                    FROM EUR_CRM_Brand__c
                    WHERE  EUR_CRM_Brand_Image_url__c LIKE :URL_BASE +'%'
                    AND RecordType.DeveloperName LIKE 'EUR_%_Brand'
                    AND Id NOT IN :attachmentParentId LIMIT 10
            ]);
        }

        if (objectType == 'EUR_CRM_Quality__c') {
            rtDevName = this.countryCode == null ? 'EUR_%_Quality' : 'EUR_' + this.countryCode + '_Quality';

        }
        Set<Id> attachmentParentId = new Set<Id>();
        for (Attachment attach : [SELECT ParentId,ContentType FROM Attachment WHERE Parent.Type = 'EUR_CRM_Brand__c']){
            attachmentParentId.add(attach.ParentId);
        }

        return Database.getQueryLocator([
                SELECT Id
                ,   EUR_CRM_Quality_Image_URL__c
                ,   EUR_CRM_External_ID__c
                ,   EUR_CRM_ImageID__c
                ,   (
                SELECT Id
                ,   Name
                FROM Attachments
                WHERE ContentType = 'image/png'
                )
                FROM EUR_CRM_Quality__c
                WHERE EUR_CRM_Quality_Image_URL__c LIKE :URL_BASE + '%'
                AND RecordType.DeveloperName LIKE :rtDevName
                AND Id NOT IN :attachmentParentId LIMIT 10

        ]);

    }

    global void execute(Database.BatchableContext BC, List<SObject> sObjects) {
        System.debug('\n\n brandQualities.size() => ' + JSON.serializePretty(sObjects.size()) + '\n');
        System.debug('\n\n brandQualities => ' + JSON.serializePretty(sObjects) + '\n');
        List<Attachment> attachmentsToInsert = new List<Attachment>();
        List<Attachment> attachmentsToDelete = new List<Attachment>();
        if (sObjects[0].getSObjectType() == EUR_CRM_Brand__c.getSObjectType()) {
            List<EUR_CRM_Brand__c> brands = (List<EUR_CRM_Brand__c>) sObjects;
            for (EUR_CRM_Brand__c brand : brands) {
                HttpRequest req = this.makeRequest(brand.EUR_CRM_Brand_Image_url__c);
                System.debug('\n\n req => ' + req + '\n');

                HttpResponse res = new Http().send(req);
                System.debug('\n\n res => ' + res + '\n');

                Blob image = res.getBodyAsBlob();
                if (image == null) {
                    continue;
                }

                attachmentsToInsert.add(this.makeBrandAttachment(brand, image));
                attachmentsToDelete.addAll(brand.Attachments);
            }
        }

        if (sObjects[0].getSObjectType() == EUR_CRM_Quality__c.getSObjectType()) {
            List<EUR_CRM_Quality__c> brandQualities = (List<EUR_CRM_Quality__c>) sObjects;
            for (EUR_CRM_Quality__c quality : brandQualities) {
                HttpRequest req = this.makeRequest(quality.EUR_CRM_Quality_Image_URL__c);
                System.debug('\n\n req => ' + req + '\n');

                HttpResponse res = new Http().send(req);
                System.debug('\n\n res => ' + res + '\n');

                Blob image = res.getBodyAsBlob();
                if (image == null) {
                    continue;
                }

                attachmentsToInsert.add(this.makeBrandQualityAttachment(quality, image));
                attachmentsToDelete.addAll(quality.Attachments);
            }
        }


        System.debug('\n\n attachmentsToInsert => ' + JSON.serializePretty(attachmentsToInsert) + '\n');
        this.upsertRecords(attachmentsToInsert);

        System.debug('\n\n attachmentsToDelete => ' + JSON.serializePretty(attachmentsToDelete) + '\n');
        this.deleteRecords(attachmentsToDelete);
    }

    global override void finish(Database.BatchableContext BC) {
        this.sendEmailReport(BC);
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */


    private HttpRequest makeRequest(String imageURL) {
        HttpRequest request = new HttpRequest();

        imageURL = imageURL.replace(' ', '%20');
        request.setEndpoint(imageURL);

        request.setMethod('GET');
        request.setHeader('Content-Type', 'image/jpeg');
        request.setCompressed(true);
        request.setTimeout(60000);

        return request;
    }

    private Attachment makeBrandQualityAttachment(EUR_CRM_Quality__c quality, Blob image) {
        return new Attachment(
                ParentId = quality.Id
        , Name = this.getBrandQualityNormalizedName(quality)
        , Body = image
        , ContentType = 'image/png'
        );
    }

    private String getBrandQualityNormalizedName(EUR_CRM_Quality__c quality) {
        return quality.EUR_CRM_ImageID__c + '.png';
    }

    private Attachment makeBrandAttachment(EUR_CRM_Brand__c brand, Blob image) {
        return new Attachment(
                ParentId = brand.Id
        , Name = this.getBrandNormalizedName(brand)
        , Body = image
        , ContentType = 'image/png'
        );
    }

    private String getBrandNormalizedName(EUR_CRM_Brand__c brand) {
        return brand.EUR_CRM_ImageID__c + '.png';
    }


}