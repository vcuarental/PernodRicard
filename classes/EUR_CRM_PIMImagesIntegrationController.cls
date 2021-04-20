public without sharing class EUR_CRM_PIMImagesIntegrationController {

    public String sObjectType {get; set;}
    public String countryCode {get; set;}
    public String zipContentLong {get; set;}

    public List<StatisticWrapper> attachmentStatisticWrapperBQS { get; set; }
    public List<DocumentWrapper> documentsBQS { get; set; }
    public Boolean disableReDownloadImagesForAllCountriesBQS { get; set; }

    public List<StatisticWrapper> attachmentStatisticWrapperBQ { get; set; }
    public List<DocumentWrapper> documentsBQ { get; set; }
    public Boolean disableReDownloadImagesForAllCountriesBQ { get; set; }

    public List<StatisticWrapper> attachmentStatisticWrapperB { get; set; }
    public List<DocumentWrapper> documentsB { get; set; }
    public Boolean disableReDownloadImagesForAllCountriesB { get; set; }

    public List<StatisticWrapper> attachmentStatisticWrapperPOSM { get; set; }
    public List<DocumentWrapper> documentsPOSM { get; set; }
    public Boolean disableReDownloadImagesForAllCountriesPOSM { get; set; }

    private EUR_CRM_PIMIntegrRunBatchesWrapper runBatchesWrapper;

    public EUR_CRM_PIMImagesIntegrationController() {
        this.runBatchesWrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
        this.initBQSInformation();
        this.initBQInformation();
        this.initBInformation();
        this.initPOSMInformation();
    }


    /* ========================================================= */
    /*     Interface
    /* ========================================================= */
    public PageReference reDownloadBQSAttachmentForAllCountries() {
        Database.executeBatch(new EUR_CRM_BrandQualitySizePIMImagesBatch(), 10);
        return null;
    }

    public PageReference reDownloadBQSAttachmentForSpecificCountry() {
        String countryCode = ApexPages.currentPage().getParameters().get('countryCode');
        System.debug('\n\n countryCode => ' + JSON.serializePretty(countryCode) + '\n');
        Database.executeBatch(new EUR_CRM_BrandQualitySizePIMImagesBatch(countryCode), 10);
        return null;
    }


    public PageReference reDownloadBQAttachmentForAllCountries() {
        Database.executeBatch(new EUR_CRM_BrandQualityPIMImagesBatch(), 10);
        return null;
    }

    public PageReference reDownloadBQAttachmentForSpecificCountry() {
        String countryCode = ApexPages.currentPage().getParameters().get('countryCode');
        System.debug('\n\n countryCode => ' + JSON.serializePretty(countryCode) + '\n');
        Database.executeBatch(new EUR_CRM_BrandQualityPIMImagesBatch(countryCode), 10);
        return null;
    }


    public PageReference reDownloadBAttachmentForAllCountries() {
        Database.executeBatch(new EUR_CRM_BrandPIMImagesBatch(), 10);
        return null;
    }

    public PageReference reDownloadBAttachmentForSpecificCountry() {
        String countryCode = ApexPages.currentPage().getParameters().get('countryCode');
        System.debug('\n\n countryCode => ' + JSON.serializePretty(countryCode) + '\n');
        Database.executeBatch(new EUR_CRM_BrandPIMImagesBatch(countryCode), 10);
        return null;
    }


    public PageReference reDownloadPOSMAttachmentForAllCountries() {
        Database.executeBatch(new EUR_CRM_POSMaterialPIMImagesBatch(), 10);
        return null;
    }

    public PageReference reDownloadPOSMAttachmentForSpecificCountry() {
        String countryCode = ApexPages.currentPage().getParameters().get('countryCode');
        System.debug('\n\n countryCode => ' + JSON.serializePretty(countryCode) + '\n');
        Database.executeBatch(new EUR_CRM_POSMaterialPIMImagesBatch(countryCode), 10);
        return null;
    }


    @RemoteAction
    public static List<AttachmentWrapper> getAttachments(String sObjectType, String countryCode) {
        System.debug('\n\n sObjectType => ' + JSON.serializePretty(sObjectType) + '\n');
        System.debug('\n\n countryCode => ' + JSON.serializePretty(countryCode) + '\n');

        if (sObjectType == null || countryCode == null) { return new List<AttachmentWrapper>(); }

        Set<String> rtDevNames = getParentRecordTypeDeveloperNames(sObjectType, countryCode);
        System.debug('\n\n rtDevNames => ' + JSON.serializePretty(rtDevNames) + '\n');

//        List<Attachment> attachments = selectAttachmentsWhereParentRecordTypeDeveloperNameIn(rtDevNames);
//        System.debug('\n\n attachments => ' + JSON.serializePretty(attachments) + '\n');

        List<AttachmentWrapper> attWrappers = new List<AttachmentWrapper>();
        for (Attachment att : [SELECT Id, Name, Body FROM Attachment
                WHERE Parent.RecordType.DeveloperName IN :rtDevNames]) {
            attWrappers.add(new AttachmentWrapper(EncodingUtil.base64Encode(att.body), att.Name));
        }
        return attWrappers;
    }

    public void uploadZipActionFunction() {
        System.debug('\n\n this.sObjectType => ' + JSON.serializePretty(this.sObjectType) + '\n');
        System.debug('\n\n this.countryCode => ' + JSON.serializePretty(this.countryCode) + '\n');

        String fileName = 'EUR_CRM_' + this.countryCode + '_' + this.sObjectType + '_Logos.zip';
        this.deleteOldVersionOfDocument(fileName);

        Document doc = this.makeDocument(fileName);
//        System.debug('\n\n doc => ' + JSON.serializePretty(doc) + '\n');
        insert doc;

        this.sObjectType = null;
        this.countryCode = null;
        this.zipContentLong = null;
    }


    /* ========================================================= */
    /*     Delegate Methods
    /* ========================================================= */
    private void initBQSInformation() {
        Set<String> countryCoderRunning = this.runBatchesWrapper.getCountryCodesForImagesForBrandQualitySizes();

        this.attachmentStatisticWrapperBQS = new List<StatisticWrapper>();
        List<AggregateResult> statistic = this.getAttachmentStatistic('EUR_%_Size');
        for (AggregateResult result : statistic) {
            String countryCode = String.valueOf(result.get('DeveloperName')).substringAfter('EUR_').substringBefore('_Size');
            Integer numberOfRecords = Integer.valueOf(result.get('NumberOfRecords'));
            Boolean isDisabled = countryCoderRunning.contains(countryCode) || countryCoderRunning.contains('All');
            this.attachmentStatisticWrapperBQS.add(new StatisticWrapper(countryCode, numberOfRecords, isDisabled));

            if (this.disableReDownloadImagesForAllCountriesBQS == null && isDisabled) {
                this.disableReDownloadImagesForAllCountriesBQS = true;
            }
        }

        this.documentsBQS = new List<DocumentWrapper>();
        List<Document> documents = this.selectDocuments('EUR_CRM_%_BQS_Logos%.zip');
        System.debug('\n\n documents.size() => ' + JSON.serializePretty(documents.size()) + '\n');
//        System.debug('\n\n documents => ' + JSON.serializePretty(documents) + '\n');
        for (Document doc : documents) {
            String countryCode = doc.Name.substringAfter('EUR_CRM_').substringBefore('_BQS_Logos.zip');
            this.documentsBQS.add(new DocumentWrapper(doc, countryCode));
        }
    }

    private void initBQInformation() {
        Set<String> countryCoderRunning = this.runBatchesWrapper.getCountryCodesForImagesForBrandQualities();

        this.attachmentStatisticWrapperBQ = new List<StatisticWrapper>();
        List<AggregateResult> statistic = this.getAttachmentStatistic('EUR_%_Quality');
        for (AggregateResult result : statistic) {
            String countryCode = String.valueOf(result.get('DeveloperName')).substringAfter('EUR_').substringBefore('_Quality');
            Integer numberOfRecords = Integer.valueOf(result.get('NumberOfRecords'));
            Boolean isDisabled = countryCoderRunning.contains(countryCode) || countryCoderRunning.contains('All');
            this.attachmentStatisticWrapperBQ.add(new StatisticWrapper(countryCode, numberOfRecords, isDisabled));

            if (this.disableReDownloadImagesForAllCountriesBQ == null && isDisabled) {
                this.disableReDownloadImagesForAllCountriesBQ = true;
            }
        }

        this.documentsBQ = new List<DocumentWrapper>();
        List<Document> documents = this.selectDocuments('EUR_CRM_%_BQ_Logos.zip');
        for (Document doc : documents) {
            String countryCode = doc.Name.substringAfter('EUR_CRM_').substringBefore('_BQ_Logos.zip');
            this.documentsBQ.add(new DocumentWrapper(doc, countryCode));
        }
    }

    private void initBInformation() {
        Set<String> countryCoderRunning = this.runBatchesWrapper.getCountryCodesForImagesForBrands();

        this.attachmentStatisticWrapperB = new List<StatisticWrapper>();
        List<AggregateResult> statistic = this.getAttachmentStatistic('EUR_%_Brand');
        for (AggregateResult result : statistic) {
            String countryCode = String.valueOf(result.get('DeveloperName')).substringAfter('EUR_').substringBefore('_Brand');
            Integer numberOfRecords = Integer.valueOf(result.get('NumberOfRecords'));
            Boolean isDisabled = countryCoderRunning.contains(countryCode) || countryCoderRunning.contains('All');
            this.attachmentStatisticWrapperB.add(new StatisticWrapper(countryCode, numberOfRecords, isDisabled));

            if (this.disableReDownloadImagesForAllCountriesB == null && isDisabled) {
                this.disableReDownloadImagesForAllCountriesB = true;
            }
        }

        this.documentsB = new List<DocumentWrapper>();
        List<Document> documents = this.selectDocuments('EUR_CRM_%_B_Logos.zip');
        for (Document doc : documents) {
            String countryCode = doc.Name.substringAfter('EUR_CRM_').substringBefore('_B_Logos.zip');
            this.documentsB.add(new DocumentWrapper(doc, countryCode));
        }
    }

    private void initPOSMInformation() {
        Set<String> countryCoderRunning = this.runBatchesWrapper.getCountryCodesForImagesForPOSMaterials();

        this.attachmentStatisticWrapperPOSM = new List<StatisticWrapper>();
        Map<String, RecordTypeInfo> rtInfoByDN = Schema.SObjectType.EUR_CRM_POS_Material__c.getRecordTypeInfosByDeveloperName();
        List<AggregateResult> statistic = this.getAttachmentStatistic(rtInfoByDN.keySet());
        for (AggregateResult result : statistic) {
            String countryCode = String.valueOf(result.get('DeveloperName')).substringAfter('EUR_').substringBefore('_');
            Integer numberOfRecords = Integer.valueOf(result.get('NumberOfRecords'));
            Boolean isDisabled = countryCoderRunning.contains(countryCode) || countryCoderRunning.contains('All');
            this.attachmentStatisticWrapperPOSM.add(new StatisticWrapper(countryCode, numberOfRecords, isDisabled));

            if (this.disableReDownloadImagesForAllCountriesPOSM == null && isDisabled) {
                this.disableReDownloadImagesForAllCountriesPOSM = true;
            }
        }

        this.documentsPOSM = new List<DocumentWrapper>();
        List<Document> documents = this.selectDocuments('EUR_CRM_%_POSM_Logos.zip');
        for (Document doc : documents) {
            String countryCode = doc.Name.substringAfter('EUR_CRM_').substringBefore('_POSM_Logos.zip');
            this.documentsPOSM.add(new DocumentWrapper(doc, countryCode));
        }
    }


    /* ========================================================= */
    /*     High Level Helpers
    /* ========================================================= */
    public static Set<String> getParentRecordTypeDeveloperNames(String sObjectType, String countryCode) {
        Map<String, String> sObjectNameBySObjectType = new Map<String, String> {
            'B' => 'EUR_CRM_Brand__c'
        ,   'BQ' => 'EUR_CRM_Quality__c'
        ,   'BQS' => 'EUR_CRM_Size__c'
        ,   'POSM' => 'EUR_CRM_POS_Material__c'
        };
        List<DescribeSObjectResult> dsors = Schema.describeSObjects(new List<String>{sObjectNameBySObjectType.get(sObjectType)});

        Set<String> rtDevNames = new Set<String>();
        for (DescribeSObjectResult dsor : dsors) {
            for (String rtDevName : dsor.getRecordTypeInfosByDeveloperName().keySet()) {
                if (countryCode.equalsIgnoreCase('All')) {
                    rtDevNames.add(rtDevName);
                } else if (rtDevName.containsIgnoreCase(countryCode)) {
                    rtDevNames.add(rtDevName);
                    break;
                }

            }
        }

        return rtDevNames;
    }

    private void deleteOldVersionOfDocument(String fileName) {
        List<Document> oldDocuments = [SELECT Id FROM Document WHERE Name = :fileName];
        System.debug('\n\n oldDocuments => ' + JSON.serializePretty(oldDocuments) + '\n');
        if( ! oldDocuments.isEmpty()) {
            delete oldDocuments;
        }
    }


    /* ========================================================= */
    /*     Low Level Helpers
    /* ========================================================= */
    private Document makeDocument(String fileName) {
        return new Document(
            Name = fileName
        ,   ContentType = 'application/zip'
        ,   FolderId = this.getFolderId()
        ,   Body = EncodingUtil.base64Decode(this.zipContentLong)
        );
    }

    private Id getFolderId() {
        List<Folder> folders = this.selectFolders();
        if( ! folders.isEmpty()) {
            return folders[0].Id;
        } else {
            return UserInfo.getUserId();
        }
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<AggregateResult> getAttachmentStatistic(String developerNamePattern) {
        return [
            SELECT COUNT(Id) NumberOfRecords, Parent.RecordType.DeveloperName
            FROM Attachment
            WHERE Parent.RecordType.DeveloperName LIKE :developerNamePattern
            GROUP BY Parent.RecordType.DeveloperName
            ORDER BY Parent.RecordType.DeveloperName
        ];
    }

    private List<AggregateResult> getAttachmentStatistic(Set<String> developerNames) {
        return [
            SELECT COUNT(Id) NumberOfRecords, Parent.RecordType.DeveloperName
            FROM Attachment
            WHERE Parent.RecordType.DeveloperName IN :developerNames
            GROUP BY Parent.RecordType.DeveloperName
            ORDER BY Parent.RecordType.DeveloperName
        ];
    }

    private List<Document> selectDocuments(String namePattern) {
        return [
            SELECT Id
            ,   Name
            ,   BodyLength
            ,   CreatedDate
            FROM Document
            WHERE Name LIKE :namePattern
            ORDER BY Name
        ];
    }

    private static List<RecordType> selectRecordTypesWhereDeveloperNames(String devName) {
        return [
            SELECT Id
            ,   DeveloperName
            FROM RecordType
            WHERE DeveloperName LIKE :devName
        ];
    }

    private static List<Attachment> selectAttachmentsWhereParentRecordTypeDeveloperNameIn(Set<String> rtDevNames) {
        return [
            SELECT Id, Name, Body
            FROM Attachment
            WHERE Parent.RecordType.DeveloperName IN :rtDevNames
        ];
    }

    private List<Folder> selectFolders() {
        return [
            SELECT Id
            FROM Folder
            WHERE DeveloperName = 'EUR_CRM_CTM_Logos'
        ];
    }


    /* ========================================================= */
    /*     Wrappers
    /* ========================================================= */
    public class StatisticWrapper {
        public String countryCode { get; set; }
        public Integer numberOfRecords { get; set; }
        public Boolean disableButton { get; set; }
        public StatisticWrapper(String countryCode, Integer numberOfRecords, Boolean disabled) {
            this.countryCode = countryCode;
            this.numberOfRecords = numberOfRecords;
            this.disableButton = disabled;
        }
    }

    public class DocumentWrapper {
        public String countryCode { get; set; }
        public Document doc { get; set; }
        public DocumentWrapper(Document doc, String countryCode) {
            this.doc = doc;
            this.countryCode = countryCode;
        }
    }

    public class AttachmentWrapper {
        public String attEncodedBody {get; set;}
        public String attName {get; set;}
        public AttachmentWrapper(String body, String name) {
            this.attEncodedBody = body;
            this.attName = name;
        }
    }

}