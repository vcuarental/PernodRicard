global class EUR_CRM_BrandQualitySizePIMImagesBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

//    Database.executeBatch(new EUR_CRM_BrandQualitySizePIMImagesBatch(), 10);
//    Database.executeBatch(new EUR_CRM_BrandQualitySizePIMImagesBatch('RU'), 10);

    private static final String URL_BASE = 'https://assets.pernod-ricard.io/pim/production/v2/';

    private String countryCode;

    global EUR_CRM_BrandQualitySizePIMImagesBatch() {}

    global EUR_CRM_BrandQualitySizePIMImagesBatch(String countryCode) {
        this.countryCode = countryCode;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (this.countryCode != null) {
            this.writeInfoAboutStartRunningFor(countryCode);

            String rtDevName = 'EUR_' + this.countryCode + '_Size';
            return Database.getQueryLocator([
                SELECT Id
                ,   EUR_CRM_Size_Image_url__c
                ,   EUR_CRM_External_ID__c
                ,   EUR_CRM_ImageID__c
                ,   (
                    SELECT Id
                    ,   Name
                    FROM Attachments
                    WHERE ContentType = 'image/png'
                )
                FROM EUR_CRM_Size__c
                WHERE EUR_CRM_Size_Image_url__c LIKE :URL_BASE + '%'
                    AND RecordType.DeveloperName = :rtDevName
            ]);
        }

        this.writeInfoAboutStartRunningFor('All');

        return Database.getQueryLocator([
            SELECT Id
            ,   EUR_CRM_Size_Image_url__c
            ,   EUR_CRM_External_ID__c
            ,   EUR_CRM_ImageID__c
            ,   (
                SELECT Id
                ,   Name
                FROM Attachments
                WHERE ContentType = 'image/png'
            )
            FROM EUR_CRM_Size__c
            WHERE EUR_CRM_Size_Image_url__c LIKE :URL_BASE + '%'
                AND RecordType.DeveloperName LIKE 'EUR_%_Size'
        ]);
    }

    global void execute(Database.BatchableContext BC, List<EUR_CRM_Size__c> sizes) {
        System.debug('\n\n sizes.size() => ' + JSON.serializePretty(sizes.size()) + '\n');
        System.debug('\n\n sizes => ' + JSON.serializePretty(sizes) + '\n');

        List<Attachment> attachmentsToInsert = new List<Attachment>();
        List<Attachment> attachmentsToDelete = new List<Attachment>();
        for (EUR_CRM_Size__c size : sizes) {
            HttpRequest req = this.makeRequest(size.EUR_CRM_Size_Image_url__c);
            System.debug('\n\n req => ' + req + '\n');

            HttpResponse res = new Http().send(req);
            System.debug('\n\n res => ' + res + '\n');

            Blob image = res.getBodyAsBlob();
            if (image == null) { continue; }

            attachmentsToInsert.add(this.makeAttachment(size, image));
            attachmentsToDelete.addAll(size.Attachments);
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
        runBatchesWrapper.addCountryCodeForImagesForBrandQualitySizes(countryCode);
    }

    private void writeInfoAboutFinishRunningFor(String countryCode) {
        EUR_CRM_PIMIntegrRunBatchesWrapper runBatchesWrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        runBatchesWrapper.removeCountryCodeForImagesForBrandQualitySizes(countryCode);
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

    private Attachment makeAttachment(EUR_CRM_Size__c size, Blob image) {
        return new Attachment(
            ParentId = size.Id
        ,   Name = this.getNormalizedName(size)
        ,   Body = image
        ,   ContentType = 'image/png'
        );
    }

    private String getNormalizedName(EUR_CRM_Size__c size) {
        return size.EUR_CRM_ImageID__c + '.png';
    }

}