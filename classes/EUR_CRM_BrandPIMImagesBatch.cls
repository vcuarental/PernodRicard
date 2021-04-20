global class EUR_CRM_BrandPIMImagesBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

//    Database.executeBatch(new EUR_CRM_BrandPIMImagesBatch(), 200);
//    Database.executeBatch(new EUR_CRM_BrandPIMImagesBatch('RU'), 200);

    private static final String URL_BASE = 'https://assets.pernod-ricard.io/pim/production/v2/';

    private String countryCode;

    global EUR_CRM_BrandPIMImagesBatch() {}

    global EUR_CRM_BrandPIMImagesBatch(String countryCode) {
        this.countryCode = countryCode;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (this.countryCode != null) {
            this.writeInfoAboutStartRunningFor(countryCode);

            String rtDevName = 'EUR_' + this.countryCode + '_Brand';
            return Database.getQueryLocator([
                SELECT Id
                ,   EUR_CRM_Brand_Image_url__c
                ,   EUR_CRM_External_ID__c
                ,   EUR_CRM_ImageID__c
                ,   (
                    SELECT Id
                    ,   Name
                    FROM Attachments
                    WHERE ContentType = 'image/png'
                )
                FROM EUR_CRM_Brand__c
                WHERE EUR_CRM_Brand_Image_url__c LIKE :URL_BASE + '%'
                    AND RecordType.DeveloperName = :rtDevName
            ]);
        }

        this.writeInfoAboutStartRunningFor('All');

        return Database.getQueryLocator([
            SELECT Id
            ,   EUR_CRM_Brand_Image_url__c
            ,   EUR_CRM_External_ID__c
            ,   EUR_CRM_ImageID__c
            ,   (
                SELECT Id
                ,   Name
                FROM Attachments
                WHERE ContentType = 'image/png'
            )
            FROM EUR_CRM_Brand__c
            WHERE EUR_CRM_Brand_Image_url__c LIKE :URL_BASE + '%'
                AND RecordType.DeveloperName LIKE 'EUR_%_Brand'
        ]);
    }

    global void execute(Database.BatchableContext BC, List<EUR_CRM_Brand__c> brands) {
        System.debug('\n\n brands.size( => ' + JSON.serializePretty(brands.size()) + '\n');
        System.debug('\n\n brands => ' + JSON.serializePretty(brands) + '\n');

        List<Attachment> attachmentsToInsert = new List<Attachment>();
        List<Attachment> attachmentsToDelete = new List<Attachment>();
        for (EUR_CRM_Brand__c brand : brands) {
            HttpRequest req = this.makeRequest(brand.EUR_CRM_Brand_Image_url__c);
            System.debug('\n\n req => ' + req + '\n');

            HttpResponse res = new Http().send(req);
            System.debug('\n\n res => ' + res + '\n');

            Blob image = res.getBodyAsBlob();
            if (image == null) { continue; }

            attachmentsToInsert.add(this.makeAttachment(brand, image));
            attachmentsToDelete.addAll(brand.Attachments);
        }
        System.debug('\n\n attachmentsToInsert => ' + JSON.serializePretty(attachmentsToInsert) + '\n');
        this.upsertRecords(attachmentsToInsert);

        System.debug('\n\n attachmentsToDelete => ' + JSON.serializePretty(attachmentsToDelete) + '\n');
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
        runBatchesWrapper.addCountryCodeForImagesForBrands(countryCode);
    }

    private void writeInfoAboutFinishRunningFor(String countryCode) {
        EUR_CRM_PIMIntegrRunBatchesWrapper runBatchesWrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        runBatchesWrapper.removeCountryCodeForImagesForBrands(countryCode);
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

    private Attachment makeAttachment(EUR_CRM_Brand__c brand, Blob image) {
        return new Attachment(
            ParentId = brand.Id
        ,   Name = this.getNormalizedName(brand)
        ,   Body = image
        ,   ContentType = 'image/png'
        );
    }

    private String getNormalizedName(EUR_CRM_Brand__c brand) {
        return brand.EUR_CRM_ImageID__c + '.png';
    }

}