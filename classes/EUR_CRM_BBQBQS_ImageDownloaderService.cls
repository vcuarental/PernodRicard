public with sharing class EUR_CRM_BBQBQS_ImageDownloaderService {

    @TestVisible private static final String DOCUMENT_NAME_PREFIX = 'EUR_CRM_';
    @TestVisible private static final String DOCUMENT_NAME_POSTFIX = '_Logos_heroku_test';
    private static final String URL_BASE = 'https://assets.pernod-ricard.io/pim/production/v2/';


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public void download(List<EUR_CRM_Brand__c> updatedBrands, Map<Id, EUR_CRM_Brand__c> oldBrandById) {
        List<EUR_CRM_Brand__c> brandsWithUpdatedImageURL = this.extractBrandsWithUpdatedImageURL(updatedBrands, oldBrandById);
        System.debug('\n\n brandsWithUpdatedImageURL.size() => ' + JSON.serializePretty(brandsWithUpdatedImageURL.size()) + '\n');
        System.debug('\n\n brandsWithUpdatedImageURL => ' + JSON.serializePretty(brandsWithUpdatedImageURL) + '\n');
        if (brandsWithUpdatedImageURL.isEmpty()) { return ; }

        downloadImages('EUR_CRM_Brand__c', new Map<Id, EUR_CRM_Brand__c>(brandsWithUpdatedImageURL).keySet());
        updateDocuments('EUR_CRM_Brand__c', new Map<Id, EUR_CRM_Brand__c>(brandsWithUpdatedImageURL).keySet());
    }

    public void download(List<EUR_CRM_Quality__c> updatedQualities, Map<Id, EUR_CRM_Quality__c> oldQualityById) {
        List<EUR_CRM_Quality__c> qualitiesWithUpdatedImageURL = this.extractQualitiesWithUpdatedImageURL(updatedQualities, oldQualityById);
        System.debug('\n\n qualitiesWithUpdatedImageURL.size() => ' + JSON.serializePretty(qualitiesWithUpdatedImageURL.size()) + '\n');
        System.debug('\n\n qualitiesWithUpdatedImageURL => ' + JSON.serializePretty(qualitiesWithUpdatedImageURL) + '\n');
        if (qualitiesWithUpdatedImageURL.isEmpty()) { return ; }

        downloadImages('EUR_CRM_Quality__c', new Map<Id, EUR_CRM_Quality__c>(qualitiesWithUpdatedImageURL).keySet());
        updateDocuments('EUR_CRM_Quality__c', new Map<Id, EUR_CRM_Quality__c>(qualitiesWithUpdatedImageURL).keySet());
    }

    public void download(List<EUR_CRM_Size__c> updatedSizes, Map<Id, EUR_CRM_Size__c> oldSizeById) {
        List<EUR_CRM_Size__c> sizesWithUpdatedImageURL = this.extractSizesWithUpdatedImageURL(updatedSizes, oldSizeById);
        System.debug('\n\n sizesWithUpdatedImageURL.size() => ' + JSON.serializePretty(sizesWithUpdatedImageURL.size()) + '\n');
        System.debug('\n\n sizesWithUpdatedImageURL => ' + JSON.serializePretty(sizesWithUpdatedImageURL) + '\n');
        if (sizesWithUpdatedImageURL.isEmpty()) { return ; }

        downloadImages('EUR_CRM_Size__c', new Map<Id, EUR_CRM_Size__c>(sizesWithUpdatedImageURL).keySet());
        updateDocuments('EUR_CRM_Size__c', new Map<Id, EUR_CRM_Size__c>(sizesWithUpdatedImageURL).keySet());
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    @Future(Callout = true)
    private static void downloadImages(String type, Set<Id> sObjectIds) {
        System.debug('\n\n type => ' + JSON.serializePretty(type) + '\n');
        System.debug('\n\n sObjectIds.size() => ' + JSON.serializePretty(sObjectIds.size()) + '\n');
        System.debug('\n\n sObjectIds => ' + JSON.serializePretty(sObjectIds) + '\n');

        if (type.equalsIgnoreCase('EUR_CRM_Brand__c')) {
            invokeBrandPIMImagesBatch(sObjectIds);
        } else if (type.equalsIgnoreCase('EUR_CRM_Quality__c')) {
            invokeBrandQualityPIMImagesBatch(sObjectIds);
        } else if (type.equalsIgnoreCase('EUR_CRM_Size__c')) {
            invokeBrandQualitySizePIMImagesBatch(sObjectIds);
        }
    }

    @Future(Callout = true)
    public static void updateDocuments(String type, Set<Id> sObjectIds) {
        System.debug('\n\n type => ' + JSON.serializePretty(type) + '\n');
        System.debug('\n\n sObjectIds.size() => ' + JSON.serializePretty(sObjectIds.size()) + '\n');
        System.debug('\n\n sObjectIds => ' + JSON.serializePretty(sObjectIds) + '\n');

        if (type.equalsIgnoreCase('EUR_CRM_Brand__c')) {
            updateBrandDocuments(sObjectIds);
        } else if (type.equalsIgnoreCase('EUR_CRM_Quality__c')) {
            updateQualityDocuments(sObjectIds);
        } else if (type.equalsIgnoreCase('EUR_CRM_Size__c')) {
            updateSizeDocuments(sObjectIds);
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    private static void invokeBrandPIMImagesBatch(Set<Id> sObjectIds) {
        new EUR_CRM_BrandPIMImagesBatch().execute(null, selectBrandsWithAttachments(sObjectIds));
    }

    public static void updateBrandDocuments(Set<Id> sObjectIds) {
        Map<String, List<EUR_CRM_Brand__c>> brandsByCountryCode = getBrandsByCountryCode(sObjectIds);
        System.debug('\n\n brandsByCountryCode.size() => ' + JSON.serializePretty(brandsByCountryCode.size()) + '\n');
        System.debug('\n\n brandsByCountryCode => ' + JSON.serializePretty(brandsByCountryCode) + '\n');

        Id folderId = getFolderId();
        Set<String> documentNamesToDelete = new Set<String>();
        List<Document> documentsToInsert = new List<Document>();
        for (String countryCode : brandsByCountryCode.keySet()) {
            String archiveName = DOCUMENT_NAME_PREFIX + countryCode + '_B' + DOCUMENT_NAME_POSTFIX;
            RequestWrapper rw = new RequestWrapper(archiveName, brandsByCountryCode.get(countryCode));
            HttpResponse res = new Http().send(makeRequest(rw));
            System.debug('\n res => ' + res + '\n');
            System.debug('\n res.getBody() => ' + res.getBody() + '\n');
            System.debug('\n res.getBodyAsBlob() => ' + res.getBodyAsBlob() + '\n');

            documentNamesToDelete.add(archiveName + '.zip');
            documentsToInsert.add(makeDocument(folderId, archiveName, res));
        }
        System.debug('\n\n documentNamesToDelete.size() => ' + JSON.serializePretty(documentNamesToDelete.size()) + '\n');
        System.debug('\n\n documentNamesToDelete => ' + JSON.serializePretty(documentNamesToDelete) + '\n');
        deleteOldVersionOfDocument(documentNamesToDelete, folderId);
        System.debug('\n\n documentsToInsert.size() => ' + JSON.serializePretty(documentsToInsert.size()) + '\n');
        System.debug('\n\n documentsToInsert => ' + JSON.serializePretty(documentsToInsert) + '\n');
        insert documentsToInsert;
    }

    private static Map<String, List<EUR_CRM_Brand__c>> getBrandsByCountryCode(Set<Id> sObjectIds) {
        List<EUR_CRM_Brand__c> brands = selectBrandsWithRTDevName(sObjectIds);
        System.debug('\n\n brands.size() => ' + JSON.serializePretty(brands.size()) + '\n');
        System.debug('\n\n brands => ' + JSON.serializePretty(brands) + '\n');

        Set<String> rtDevNames = extractRTDevNames(brands);
        System.debug('\n\n rtDevNames.size() => ' + JSON.serializePretty(rtDevNames.size()) + '\n');
        System.debug('\n\n rtDevNames => ' + JSON.serializePretty(rtDevNames) + '\n');

        List<EUR_CRM_Brand__c> allBrands = selectBrandsWhereRTDevNameIn(rtDevNames);
        System.debug('\n\n allBrands.size() => ' + JSON.serializePretty(allBrands.size()) + '\n');
        System.debug('\n\n allBrands => ' + JSON.serializePretty(allBrands) + '\n');

        Map<String, List<EUR_CRM_Brand__c>> brandsByCountryCode = new Map<String, List<EUR_CRM_Brand__c>>();
        for (EUR_CRM_Brand__c brand : allBrands) {
            String countryCode = brand.RecordType.DeveloperName.removeStart('EUR_').removeEnd('_Brand');
            if (brandsByCountryCode.containsKey(countryCode)) {
                brandsByCountryCode.get(countryCode).add(brand);
            } else {
                brandsByCountryCode.put(countryCode, new List<EUR_CRM_Brand__c> { brand });
            }
        }
        return brandsByCountryCode;
    }

    private static void invokeBrandQualityPIMImagesBatch(Set<Id> sObjectIds) {
        new EUR_CRM_BrandQualityPIMImagesBatch().execute(null, selectQualitiesWithAttachments(sObjectIds));
    }

    private static void updateQualityDocuments(Set<Id> sObjectIds) {
        Map<String, List<EUR_CRM_Quality__c>> qualitiesByCountryCode = getQualitiesByCountryCode(sObjectIds);
        System.debug('\n\n qualitiesByCountryCode.size() => ' + JSON.serializePretty(qualitiesByCountryCode.size()) + '\n');
        System.debug('\n\n qualitiesByCountryCode => ' + JSON.serializePretty(qualitiesByCountryCode) + '\n');

        Id folderId = getFolderId();
        Set<String> documentNamesToDelete = new Set<String>();
        List<Document> documentsToInsert = new List<Document>();
        for (String countryCode : qualitiesByCountryCode.keySet()) {
            String archiveName = DOCUMENT_NAME_PREFIX + countryCode + '_BQ' + DOCUMENT_NAME_POSTFIX;
            RequestWrapper rw = new RequestWrapper(archiveName, qualitiesByCountryCode.get(countryCode));
            HttpResponse res = new Http().send(makeRequest(rw));

            documentNamesToDelete.add(archiveName + '.zip');
            documentsToInsert.add(makeDocument(folderId, archiveName, res));
        }
        System.debug('\n\n documentNamesToDelete.size() => ' + JSON.serializePretty(documentNamesToDelete.size()) + '\n');
        System.debug('\n\n documentNamesToDelete => ' + JSON.serializePretty(documentNamesToDelete) + '\n');
        deleteOldVersionOfDocument(documentNamesToDelete, folderId);
        System.debug('\n\n documentsToInsert.size() => ' + JSON.serializePretty(documentsToInsert.size()) + '\n');
        System.debug('\n\n documentsToInsert => ' + JSON.serializePretty(documentsToInsert) + '\n');
        insert documentsToInsert;
    }

    private static Map<String, List<EUR_CRM_Quality__c>> getQualitiesByCountryCode(Set<Id> sObjectIds) {
        List<EUR_CRM_Quality__c> qualities = selectQualitiesWithRTDevName(sObjectIds);
        System.debug('\n\n qualities.size() => ' + JSON.serializePretty(qualities.size()) + '\n');
        System.debug('\n\n qualities => ' + JSON.serializePretty(qualities) + '\n');

        Set<String> rtDevNames = extractRTDevNames(qualities);
        System.debug('\n\n rtDevNames.size() => ' + JSON.serializePretty(rtDevNames.size()) + '\n');
        System.debug('\n\n rtDevNames => ' + JSON.serializePretty(rtDevNames) + '\n');

        List<EUR_CRM_Quality__c> allQualities = selectQualitiesWhereRTDevNameIn(rtDevNames);
        System.debug('\n\n allQualities.size() => ' + JSON.serializePretty(allQualities.size()) + '\n');
        System.debug('\n\n allQualities => ' + JSON.serializePretty(allQualities) + '\n');

        Map<String, List<EUR_CRM_Quality__c>> qualitiesByCountryCode = new Map<String, List<EUR_CRM_Quality__c>>();
        for (EUR_CRM_Quality__c quality : allQualities) {
            String countryCode = quality.RecordType.DeveloperName.removeStart('EUR_').removeEnd('_Quality');
            if (qualitiesByCountryCode.containsKey(countryCode)) {
                qualitiesByCountryCode.get(countryCode).add(quality);
            } else {
                qualitiesByCountryCode.put(countryCode, new List<EUR_CRM_Quality__c> { quality });
            }
        }
        return qualitiesByCountryCode;
    }

    private static void invokeBrandQualitySizePIMImagesBatch(Set<Id> sObjectIds) {
        new EUR_CRM_BrandQualitySizePIMImagesBatch().execute(null, selectSizesWithAttachments(sObjectIds));
    }

    private static void updateSizeDocuments(Set<Id> sObjectIds) {
        Map<String, List<EUR_CRM_Size__c>> sizesByCountryCode = getSizesByCountryCode(sObjectIds);
        System.debug('\n\n sizesByCountryCode.size() => ' + JSON.serializePretty(sizesByCountryCode.size()) + '\n');
        System.debug('\n\n sizesByCountryCode => ' + JSON.serializePretty(sizesByCountryCode) + '\n');

        Id folderId = getFolderId();
        Set<String> documentNamesToDelete = new Set<String>();
        List<Document> documentsToInsert = new List<Document>();
        for (String countryCode : sizesByCountryCode.keySet()) {
            String archiveName = DOCUMENT_NAME_PREFIX + countryCode + '_BQS' + DOCUMENT_NAME_POSTFIX;
            RequestWrapper rw = new RequestWrapper(archiveName, sizesByCountryCode.get(countryCode));
            HttpResponse res = new Http().send(makeRequest(rw));

            documentNamesToDelete.add(archiveName + '.zip');
            documentsToInsert.add(makeDocument(folderId, archiveName, res));
        }
        System.debug('\n\n documentNamesToDelete.size() => ' + JSON.serializePretty(documentNamesToDelete.size()) + '\n');
        System.debug('\n\n documentNamesToDelete => ' + JSON.serializePretty(documentNamesToDelete) + '\n');
        deleteOldVersionOfDocument(documentNamesToDelete, folderId);
        System.debug('\n\n documentsToInsert.size() => ' + JSON.serializePretty(documentsToInsert.size()) + '\n');
        System.debug('\n\n documentsToInsert => ' + JSON.serializePretty(documentsToInsert) + '\n');
        insert documentsToInsert;
    }

    private static Map<String, List<EUR_CRM_Size__c>> getSizesByCountryCode(Set<Id> sObjectIds) {
        List<EUR_CRM_Size__c> sizes = selectSizesWithRTDevName(sObjectIds);
        System.debug('\n\n sizes.size() => ' + JSON.serializePretty(sizes.size()) + '\n');
        System.debug('\n\n sizes => ' + JSON.serializePretty(sizes) + '\n');

        Set<String> rtDevNames = extractRTDevNames(sizes);
        System.debug('\n\n rtDevNames.size() => ' + JSON.serializePretty(rtDevNames.size()) + '\n');
        System.debug('\n\n rtDevNames => ' + JSON.serializePretty(rtDevNames) + '\n');

        List<EUR_CRM_Size__c> allSizes = selectSizesWhereRTDevNameIn(rtDevNames);
        System.debug('\n\n allSizes.size() => ' + JSON.serializePretty(allSizes.size()) + '\n');
        System.debug('\n\n allSizes => ' + JSON.serializePretty(allSizes) + '\n');

        Map<String, List<EUR_CRM_Size__c>> sizesByCountryCode = new Map<String, List<EUR_CRM_Size__c>>();
        for (EUR_CRM_Size__c size : allSizes) {
            String countryCode = size.RecordType.DeveloperName.removeStart('EUR_').removeEnd('_Size');
            if (sizesByCountryCode.containsKey(countryCode)) {
                sizesByCountryCode.get(countryCode).add(size);
            } else {
                sizesByCountryCode.put(countryCode, new List<EUR_CRM_Size__c> { size });
            }
        }
        return sizesByCountryCode;
    }

    private static void deleteOldVersionOfDocument(Set<String> fileNames, Id folderId) {
        List<Document> oldDocuments = [SELECT Id, Name FROM Document WHERE Name IN :fileNames AND FolderId = :folderId];
        System.debug('\n\n oldDocuments.size() => ' + JSON.serializePretty(oldDocuments.size()) + '\n');
        System.debug('\n\n oldDocuments => ' + JSON.serializePretty(oldDocuments) + '\n');
        if( ! oldDocuments.isEmpty()) { delete oldDocuments; }
    }


    /* ========================================================= */
    /*     Middle Level Helpers
    /* ========================================================= */
    private List<EUR_CRM_Brand__c> extractBrandsWithUpdatedImageURL(List<EUR_CRM_Brand__c> updatedBrands, Map<Id, EUR_CRM_Brand__c> oldBrandById) {
        List<EUR_CRM_Brand__c> brands = new List<EUR_CRM_Brand__c>();
        for (EUR_CRM_Brand__c brand : updatedBrands) {
            if (this.isImageURLchanged(brand, oldBrandById)) {
                brands.add(brand);
            }
        }
        return brands;
    }

    private List<EUR_CRM_Quality__c> extractQualitiesWithUpdatedImageURL(List<EUR_CRM_Quality__c> updatedQualities, Map<Id, EUR_CRM_Quality__c> oldQualityById) {
        List<EUR_CRM_Quality__c> qualities = new List<EUR_CRM_Quality__c>();
        for (EUR_CRM_Quality__c quality : updatedQualities) {
            if (this.isImageURLchanged(quality, oldQualityById)) {
                qualities.add(quality);
            }
        }
        return qualities;
    }

    private List<EUR_CRM_Size__c> extractSizesWithUpdatedImageURL(List<EUR_CRM_Size__c> updatedSizes, Map<Id, EUR_CRM_Size__c> oldSizeById) {
        List<EUR_CRM_Size__c> sizes = new List<EUR_CRM_Size__c>();
        for (EUR_CRM_Size__c size : updatedSizes) {
            if (this.isImageURLchanged(size, oldSizeById)) {
                sizes.add(size);
            }
        }
        return sizes;
    }

    private static Set<String> extractRTDevNames(List<EUR_CRM_Brand__c> brands) {
        Set<String> rtDevNames = new Set<String>();
        for (EUR_CRM_Brand__c brand : brands) {
            rtDevNames.add(brand.RecordType.DeveloperName);
        }
        return rtDevNames;
    }

    private static Set<String> extractRTDevNames(List<EUR_CRM_Quality__c> qualities) {
        Set<String> rtDevNames = new Set<String>();
        for (EUR_CRM_Quality__c quality : qualities) {
            rtDevNames.add(quality.RecordType.DeveloperName);
        }
        return rtDevNames;
    }

    private static Set<String> extractRTDevNames(List<EUR_CRM_Size__c> sizes) {
        Set<String> rtDevNames = new Set<String>();
        for (EUR_CRM_Size__c size : sizes) {
            rtDevNames.add(size.RecordType.DeveloperName);
        }
        return rtDevNames;
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Boolean isImageURLchanged(EUR_CRM_Brand__c brand, Map<Id, EUR_CRM_Brand__c> oldBrandById) {
        return brand.EUR_CRM_Brand_Image_url__c != oldBrandById.get(brand.Id).EUR_CRM_Brand_Image_url__c
            && brand.EUR_CRM_Brand_Image_url__c != null
            && brand.EUR_CRM_Brand_Image_url__c.startsWith(URL_BASE)
        ;
    }

    private Boolean isImageURLchanged(EUR_CRM_Quality__c quality, Map<Id, EUR_CRM_Quality__c> oldQualityById) {
        return quality.EUR_CRM_Quality_Image_URL__c != oldQualityById.get(quality.Id).EUR_CRM_Quality_Image_URL__c
            && quality.EUR_CRM_Quality_Image_URL__c != null
            && quality.EUR_CRM_Quality_Image_URL__c.startsWith(URL_BASE)
        ;
    }

    private Boolean isImageURLchanged(EUR_CRM_Size__c size, Map<Id, EUR_CRM_Size__c> oldSizeById) {
        return size.EUR_CRM_Size_Image_url__c != oldSizeById.get(size.Id).EUR_CRM_Size_Image_url__c
            && size.EUR_CRM_Size_Image_url__c != null
            && size.EUR_CRM_Size_Image_url__c.startsWith(URL_BASE)
        ;
    }

    private static HttpRequest makeRequest(RequestWrapper rw) {
        HttpRequest request = new HttpRequest();

//        request.setEndpoint('https://desolate-coast-88829.herokuapp.com/images');
        request.setEndpoint('https://nameless-scrubland-94550.herokuapp.com/images');

        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(rw));
        request.setCompressed(true);
        request.setTimeout(60000);
        System.debug('\n request => ' + request + '\n');
        return request;
    }

    private static Id getFolderId() {
        List<Folder> folders = selectFolders();
        if( ! folders.isEmpty()) {
            return folders[0].Id;
        } else {
            return UserInfo.getUserId();
        }
    }

    private static Document makeDocument(Id folderId, String name, HttpResponse res) {
        return new Document(
            Name = name + '.zip'
        ,   ContentType = 'application/zip'
        ,   FolderId = folderId
        ,   Body = res.getBodyAsBlob()
        );
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Brand__c> selectBrandsWithAttachments(Set<Id> brandIds) {
        return [
            SELECT Id
            ,   EUR_CRM_Brand_Image_url__c
            ,   EUR_CRM_External_ID__c
            ,   EUR_CRM_ImageID__c
            ,   RecordType.DeveloperName
            ,   (
                SELECT Id
                ,   Name
                FROM Attachments
                WHERE ContentType = 'image/png'
            )
            FROM EUR_CRM_Brand__c
            WHERE Id IN :brandIds
                AND RecordType.DeveloperName LIKE 'EUR_%_Brand'
        ];
    }

    private static List<EUR_CRM_Brand__c> selectBrandsWithRTDevName(Set<Id> sizeIds) {
        return [
            SELECT Id
            ,   RecordType.DeveloperName
            FROM EUR_CRM_Brand__c
            WHERE Id IN :sizeIds
                AND RecordType.DeveloperName LIKE 'EUR_%_Brand'
        ];
    }

    private static List<EUR_CRM_Brand__c> selectBrandsWhereRTDevNameIn(Set<String> rtDevNames) {
        return [
            SELECT Id
            ,   RecordType.DeveloperName
            ,   EUR_CRM_Brand_Image_url__c
            ,   EUR_CRM_External_ID__c
            ,   EUR_CRM_ImageID__c
            FROM EUR_CRM_Brand__c
            WHERE RecordType.DeveloperName IN :rtDevNames
                AND EUR_CRM_Brand_Image_url__c LIKE :URL_BASE + '%'
        ];
    }

    private static List<EUR_CRM_Quality__c> selectQualitiesWithAttachments(Set<Id> qualityIds) {
        return [
            SELECT Id
            ,   EUR_CRM_Quality_Image_URL__c
            ,   EUR_CRM_External_ID__c
            ,   EUR_CRM_ImageID__c
            ,   RecordType.DeveloperName
            ,   (
                SELECT Id
                ,   Name
                FROM Attachments
                WHERE ContentType = 'image/png'
            )
            FROM EUR_CRM_Quality__c
            WHERE Id IN :qualityIds
                AND RecordType.DeveloperName LIKE 'EUR_%_Quality'
        ];
    }

    private static List<EUR_CRM_Quality__c> selectQualitiesWithRTDevName(Set<Id> sizeIds) {
        return [
            SELECT Id
            ,   RecordType.DeveloperName
            FROM EUR_CRM_Quality__c
            WHERE Id IN :sizeIds
                AND RecordType.DeveloperName LIKE 'EUR_%_Quality'
        ];
    }

    private static List<EUR_CRM_Quality__c> selectQualitiesWhereRTDevNameIn(Set<String> rtDevNames) {
        return [
            SELECT Id
            ,   RecordType.DeveloperName
            ,   EUR_CRM_Quality_Image_URL__c
            ,   EUR_CRM_External_ID__c
            ,   EUR_CRM_ImageID__c
            FROM EUR_CRM_Quality__c
            WHERE RecordType.DeveloperName IN :rtDevNames
                AND EUR_CRM_Quality_Image_URL__c LIKE :URL_BASE + '%'
        ];
    }

    private static List<EUR_CRM_Size__c> selectSizesWithAttachments(Set<Id> sizeIds) {
        return [
            SELECT Id
            ,   EUR_CRM_Size_Image_url__c
            ,   EUR_CRM_External_ID__c
            ,   EUR_CRM_ImageID__c
            ,   RecordType.DeveloperName
            ,   (
                SELECT Id
                ,   Name
                FROM Attachments
                WHERE ContentType = 'image/png'
            )
            FROM EUR_CRM_Size__c
            WHERE Id IN :sizeIds
                AND RecordType.DeveloperName LIKE 'EUR_%_Size'
        ];
    }

    private static List<EUR_CRM_Size__c> selectSizesWithRTDevName(Set<Id> sizeIds) {
        return [
            SELECT Id
            ,   RecordType.DeveloperName
            FROM EUR_CRM_Size__c
            WHERE Id IN :sizeIds
                AND RecordType.DeveloperName LIKE 'EUR_%_Size'
        ];
    }

    private static List<EUR_CRM_Size__c> selectSizesWhereRTDevNameIn(Set<String> rtDevNames) {
        return [
            SELECT Id
            ,   RecordType.DeveloperName
            ,   EUR_CRM_Size_Image_url__c
            ,   EUR_CRM_External_ID__c
            ,   EUR_CRM_ImageID__c
            FROM EUR_CRM_Size__c
            WHERE RecordType.DeveloperName IN :rtDevNames
                AND EUR_CRM_Size_Image_url__c LIKE :URL_BASE + '%'
        ];
    }

    private static List<Folder> selectFolders() {
        return [
            SELECT Id
            FROM Folder
            WHERE DeveloperName = 'EUR_CRM_CTM_Logos'
        ];
    }


    /* ========================================================= */
    /*     Wrappers
    /* ========================================================= */
    private class RequestWrapper {
        String zipArchiveName;
        List<ImageWrapper> images;

        public RequestWrapper(String archiveName, List<EUR_CRM_Brand__c> brands) {
            this.zipArchiveName = archiveName;
            this.images = new List<ImageWrapper>();
            for (EUR_CRM_Brand__c brand : brands) {
                this.images.add(new ImageWrapper(brand));
            }
        }

        public RequestWrapper(String archiveName, List<EUR_CRM_Quality__c> qualities) {
            this.zipArchiveName = archiveName;
            this.images = new List<ImageWrapper>();
            for (EUR_CRM_Quality__c quality : qualities) {
                this.images.add(new ImageWrapper(quality));
            }
        }

        public RequestWrapper(String archiveName, List<EUR_CRM_Size__c> sizes) {
            this.zipArchiveName = archiveName;
            this.images = new List<ImageWrapper>();
            for (EUR_CRM_Size__c size : sizes) {
                this.images.add(new ImageWrapper(size));
            }
        }

    }

    private class ImageWrapper {
        String name;
        String url;

        public ImageWrapper(EUR_CRM_Brand__c brand) {
            this.name = brand.EUR_CRM_External_ID__c + '.png';
            this.url = brand.EUR_CRM_Brand_Image_url__c;
            if (this.url.containsIgnoreCase('?')) {
                this.url = this.url.substringBefore('?');
            }
        }

        public ImageWrapper(EUR_CRM_Quality__c quality) {
            this.name = quality.EUR_CRM_External_ID__c + '.png';
            this.url = quality.EUR_CRM_Quality_Image_URL__c;
            if (this.url.containsIgnoreCase('?')) {
                this.url = this.url.substringBefore('?');
            }
        }

        public ImageWrapper(EUR_CRM_Size__c size) {
            this.name = size.EUR_CRM_External_ID__c + '.png';
            this.url = size.EUR_CRM_Size_Image_url__c;
            if (this.url.containsIgnoreCase('?')) {
                this.url = this.url.substringBefore('?');
            }
        }

    }

}