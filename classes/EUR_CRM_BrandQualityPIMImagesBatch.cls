global class EUR_CRM_BrandQualityPIMImagesBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

//    Database.executeBatch(new EUR_CRM_BrandQualityPIMImagesBatch(), 200);
//    Database.executeBatch(new EUR_CRM_BrandQualityPIMImagesBatch('RU'), 200);

    private static final String URL_BASE = 'https://assets.pernod-ricard.io/pim/production/v2/';

    private String countryCode;

    global EUR_CRM_BrandQualityPIMImagesBatch() {}

    global EUR_CRM_BrandQualityPIMImagesBatch(String countryCode) {
        this.countryCode = countryCode;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (this.countryCode != null) {
            this.writeInfoAboutStartRunningFor(countryCode);

            String rtDevName = 'EUR_' + this.countryCode + '_Quality';
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
                    AND RecordType.DeveloperName = :rtDevName
            ]);
        }

        this.writeInfoAboutStartRunningFor('All');

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
                AND RecordType.DeveloperName LIKE 'EUR_%_Quality'
        ]);
    }

    global void execute(Database.BatchableContext BC, List<EUR_CRM_Quality__c> brandQualities) {
        System.debug('\n\n brandQualities.size() => ' + JSON.serializePretty(brandQualities.size()) + '\n');
//        System.debug('\n\n brandQualities => ' + JSON.serializePretty(brandQualities) + '\n');

        List<Attachment> attachmentsToInsert = new List<Attachment>();
        List<Attachment> attachmentsToDelete = new List<Attachment>();
        for (EUR_CRM_Quality__c quality : brandQualities) {
            HttpRequest req = this.makeRequest(quality.EUR_CRM_Quality_Image_URL__c);
            System.debug('\n\n req => ' + req + '\n');

            HttpResponse res = new Http().send(req);
            System.debug('\n\n res => ' + res + '\n');

            Blob image = res.getBodyAsBlob();
            if (image == null) { continue; }

            attachmentsToInsert.add(this.makeAttachment(quality, image));
            attachmentsToDelete.addAll(quality.Attachments);
        }
//        System.debug('\n\n attachmentsToInsert => ' + JSON.serializePretty(attachmentsToInsert) + '\n');
        this.upsertRecords(attachmentsToInsert);

//        System.debug('\n\n attachmentsToDelete => ' + JSON.serializePretty(attachmentsToDelete) + '\n');
        this.deleteRecords(attachmentsToDelete);
    }

    global override void finish(Database.BatchableContext BC) {
        this.writeInfoAboutFinishRunningFor(this.countryCode != null ? this.countryCode : 'All');
        this.sendEmailReport(BC);
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    private void writeInfoAboutStartRunningFor(String countryCode) {
        EUR_CRM_PIMIntegrRunBatchesWrapper runBatchesWrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        runBatchesWrapper.addCountryCodeForImagesForBrandQualities(countryCode);
    }

    private void writeInfoAboutFinishRunningFor(String countryCode) {
        EUR_CRM_PIMIntegrRunBatchesWrapper runBatchesWrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        runBatchesWrapper.removeCountryCodeForImagesForBrandQualities(countryCode);
    }

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

    private Attachment makeAttachment(EUR_CRM_Quality__c quality, Blob image) {
        return new Attachment(
            ParentId = quality.Id
        ,   Name = this.getNormalizedName(quality)
        ,   Body = image
        ,   ContentType = 'image/png'
        );
    }

    private String getNormalizedName(EUR_CRM_Quality__c quality) {
        return quality.EUR_CRM_ImageID__c + '.png';
    }

}