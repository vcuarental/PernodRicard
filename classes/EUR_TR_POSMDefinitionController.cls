/**
 * Created by osman on 15.10.2020.
 */

public with sharing class EUR_TR_POSMDefinitionController {

    public class EUR_TR_POSMDefinitionControllerException extends Exception {

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getPOSMTypesFromMiddleware(String requestBody) {


        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        try {

            if (String.isBlank(requestBody)) {
                throw new EUR_TR_POSMDefinitionControllerException('Id bilgisi boş olamaz.');
            }

            EUR_TR_Account__c account = (EUR_TR_Account__c) JSON.deserialize(requestBody, EUR_TR_Account__c.class);
            System.debug(account.Id);

            if (String.isBlank(account.Id)) {
                throw new EUR_TR_POSMDefinitionControllerException('Id bilgisi boş olamaz.');
            }

            List<EUR_TR_Definition__c> POSMTypes = getPOSMTypes(account.Id);

            List<PicklistItem> activePOSMTypesBySegmentation = new List<PicklistItem>();
            PicklistItem activePOSMTypeBySegmentation = null;
            for (EUR_TR_Definition__c definition : POSMTypes) {
                activePOSMTypeBySegmentation = new PicklistItem();
                {
                    activePOSMTypeBySegmentation.label = (String) definition.get('POSMTypeLabel');
                    activePOSMTypeBySegmentation.value = definition.EUR_TR_POSMType__c;
                }
                activePOSMTypesBySegmentation.add(activePOSMTypeBySegmentation);
            }


            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = activePOSMTypesBySegmentation;

        } catch (Exception ex) {
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;
    }

    public static List<EUR_TR_Definition__c> getPOSMTypes(Id accountId) {

        Map<Id, EUR_TR_Definition__c> definitionMap = new Map<Id, EUR_TR_Definition__c>([
                SELECT
                        Id,
                        EUR_TR_POSMType__c,
                        toLabel(EUR_TR_POSMType__c) POSMTypeLabel
                FROM EUR_TR_Definition__c
                WHERE RecordType.DeveloperName = 'EUR_TR_POSMType' AND EUR_TR_POSMType__c != NULL
                AND EUR_TR_POSMTypeStatus__c != NULL AND EUR_TR_POSMTypeStatus__c = 'Aktif'
        ]);


        Map<String, EUR_TR_Definition__c> POSMNamesToRecordMap = new Map<String, EUR_TR_Definition__c>();
        for (EUR_TR_Definition__c definition : definitionMap.values()) {
            if (definition.EUR_TR_POSMType__c != null) {
                POSMNamesToRecordMap.put(definition.EUR_TR_POSMType__c, definition);
            }
        }

        System.debug(accountId);
        EUR_TR_Account__c account = [
                SELECT Id,
                        EUR_TR_ActivityPoints__c,
                        EUR_TR_SubType__c,
                        EUR_TR_Group__c,
                        EUR_TR_Channel__c,
                        EUR_TR_ONTB__c,
                        EUR_TR_OTPros__c,
                        EUR_TR_OTSponsorship__c,
                        EUR_TR_OTType__c,
                        EUR_TR_Range__c,
                        EUR_TR_SponsorshipStatus__c,
                        EUR_TR_Class__c,
                        EUR_TR_Type__c
                FROM EUR_TR_Account__c
                WHERE Id = :accountId
        ];


        Set<String> POSMTypesByAccountSegmentationFields = getPOSMTypesByAccountSegmentation(account, POSMNamesToRecordMap.keySet());
        Set<String> visiblePOSMTypes = new Set<String>();
        if (!POSMTypesByAccountSegmentationFields.isEmpty()) {
            visiblePOSMTypes.addAll(POSMTypesByAccountSegmentationFields);
        }

        List<EUR_TR_Definition__c> visiblePOSMRecords = new List<EUR_TR_Definition__c>();
        for (String visiblePOSMType : visiblePOSMTypes) {
            if (POSMNamesToRecordMap.containsKey(visiblePOSMType)) {
                visiblePOSMRecords.add(POSMNamesToRecordMap.get(visiblePOSMType));
            }
        }

        return visiblePOSMRecords;


    }

    private static Set<String> getPOSMTypesByAccountSegmentation(EUR_TR_Account__c account, Set<String> allActivePOSMTypes) {

        String querySelect =
                'SELECT ' +
                        'Id,' +
                        'EUR_TR_SegmentationPOSMTypes__c ';
        String queryFrom = 'FROM EUR_TR_Definition__c ';

        String queryWhere = '';

        queryWhere += 'WHERE RecordType.DeveloperName = \'EUR_TR_POSMSegmentation\' ';
        if (String.isNotBlank(account.EUR_TR_ActivityPoints__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_ActivityPoints__c', account.EUR_TR_ActivityPoints__c);
        }

        if (String.isNotBlank(account.EUR_TR_SubType__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_SubType__c', account.EUR_TR_SubType__c);
        }

        if (String.isNotBlank(account.EUR_TR_Group__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_Group__c', account.EUR_TR_Group__c);
        }

        if (String.isNotBlank(account.EUR_TR_Channel__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_Channel__c', account.EUR_TR_Channel__c);
        }

        if (String.isNotBlank(account.EUR_TR_ONTB__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_ONTB__c', account.EUR_TR_ONTB__c);
        }

        if (String.isNotBlank(account.EUR_TR_OTPros__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_OTPros__c', account.EUR_TR_OTPros__c);
        }

        if (String.isNotBlank(account.EUR_TR_OTSponsorship__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_OTSponsorship__c', account.EUR_TR_OTSponsorship__c);
        }

        if (String.isNotBlank(account.EUR_TR_OTType__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_OTType__c', account.EUR_TR_OTType__c);
        }

        if (String.isNotBlank(account.EUR_TR_Range__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_Range__c', account.EUR_TR_Range__c);
        }

        if (String.isNotBlank(account.EUR_TR_SponsorshipStatus__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_SponsorshipStatus__c', account.EUR_TR_SponsorshipStatus__c);
        }

        if (String.isNotBlank(account.EUR_TR_Class__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_Class__c', account.EUR_TR_Class__c);
        }

        if (String.isNotBlank(account.EUR_TR_Type__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_Type__c', account.EUR_TR_Type__c);
        }


        String query = String.format('{0} {1} {2}', new List<String>{
                querySelect,
                queryFrom,
                queryWhere
        });

        System.debug(query);

        List<EUR_TR_Definition__c> definitions = Database.query(query);

        Set<String> allPOSMTypes = new Set<String>();
        Set<String> POSMTypesByField = new Set<String>();
        for (EUR_TR_Definition__c definition : definitions) {
            POSMTypesByField = getPOSMTypesBySelectedPOSMTypeField(definition.EUR_TR_SegmentationPOSMTypes__c, allActivePOSMTypes);
            if (!POSMTypesByField.isEmpty()) {
                allPOSMTypes.addAll(POSMTypesByField);
            }
        }


        return allPOSMTypes;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getPOSMSubTypesByPOSMTypeFromMiddleware(String requestBody) {


        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        try {

            if (String.isBlank(requestBody)) {
                throw new EUR_TR_POSMDefinitionControllerException('Id bilgisi boş olamaz.');
            }

            POSMSubTypeRequestModel requestModel = (POSMSubTypeRequestModel) JSON.deserialize(requestBody, POSMSubTypeRequestModel.class);
            System.debug(JSON.serializePretty(requestModel));

            if (String.isBlank(requestModel.accountId)) {
                throw new EUR_TR_POSMDefinitionControllerException('Nokta bilgisi boş olamaz.');
            }

            if (String.isBlank(requestModel.POSMType)) {
                throw new EUR_TR_POSMDefinitionControllerException('Ürün tipi seçimi boş bırakılamaz');
            }

            List<EUR_TR_Definition__c> POSMTypes = getPOSMSubTypesByPOSMType(requestModel);

            Set<Id> POSMRecordIds = new Set<Id>();
            for (EUR_TR_Definition__c definition : POSMTypes) {
                POSMRecordIds.add(definition.Id);
            }

            Map<Id, List<String>> definitionToImageURLMap = null;
            if (!POSMRecordIds.isEmpty()) {
                definitionToImageURLMap = getPOSMImageURLs(POSMRecordIds);
            }


            List<POSMDefinitionWrapper> POSMSubTypeDefinitionWrappers = new List<POSMDefinitionWrapper>();
            POSMDefinitionWrapper POSMSubTypeDefinitionWrapper = null;
            for (EUR_TR_Definition__c definition : POSMTypes) {
                POSMSubTypeDefinitionWrapper = new POSMDefinitionWrapper();
                POSMSubTypeDefinitionWrapper.definition = definition;
                if (definitionToImageURLMap != null) {
                    List<String> imageURLs = definitionToImageURLMap.get(definition.Id);
                    if (imageURLs != null && !imageURLs.isEmpty()) {
                        POSMSubTypeDefinitionWrapper.imageURL = imageURLs.get(0);
                    }
                }
                POSMSubTypeDefinitionWrappers.add(POSMSubTypeDefinitionWrapper);
            }


            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = POSMSubTypeDefinitionWrappers;

        } catch (Exception ex) {
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
        }

        return serviceResponse;
    }


    public static List<EUR_TR_Definition__c> getPOSMSubTypesByPOSMType(POSMSubTypeRequestModel requestModel) {

        String POSMType = requestModel.POSMType;
        Id accountId = requestModel.accountId;
        String brand = requestModel.brand;
        String brandOther = requestModel.brandOther;

        String querySelect = '' +
                'SELECT ' +
                'Id,' +
                'EUR_TR_POSMType__c,' +
                'Name,' +
                'toLabel(EUR_TR_POSMType__c) POSMTypeLabel,' +
                'EUR_TR_IsCarpenterPOSMType__c,' +
                'EUR_TR_UnitPrice__c,' +
                'EUR_TR_POSMTypeStatus__c,' +
                'EUR_TR_ApprovalProcessIsRequired__c,' +
                'EUR_TR_Budget__c,' +
                'EUR_TR_IsApprovalProcessRequiredToCancel__c,' +
                'EUR_TR_ApproverTitle__c,' +
                'EUR_TR_Brand__c, ' +
                'EUR_TR_BrandOther__c ';
        String queryFrom = 'FROM EUR_TR_Definition__c ';
        String queryWhere = 'WHERE RecordType.DeveloperName = \'EUR_TR_POSMType\' AND EUR_TR_POSMType__c != NULL ' +
                'AND EUR_TR_POSMTypeStatus__c != NULL AND EUR_TR_POSMTypeStatus__c = \'Aktif\' AND EUR_TR_POSMType__c = :POSMType ';
        if (String.isNotBlank(brand)) {
            queryWhere += 'AND EUR_TR_Brand__c=:brand ';
        }
        if (String.isBlank(brand) && String.isNotBlank(brandOther)) {
            queryWhere += 'AND EUR_TR_BrandOther__c=:brandOther ';
        }

        String query = String.format('{0} {1} {2} ', new List<String>{
                querySelect,
                queryFrom,
                queryWhere
        });
        System.debug(query);

        Map<Id, EUR_TR_Definition__c> definitionMap = new Map<Id, EUR_TR_Definition__c>((List<EUR_TR_Definition__c>) Database.query(query));

        // definition.Name == POSM Sub Type
        Map<String, EUR_TR_Definition__c> POSMNamesToRecordMap = new Map<String, EUR_TR_Definition__c>();
        for (EUR_TR_Definition__c definition : definitionMap.values()) {
            POSMNamesToRecordMap.put(definition.Name, definition);
        }

        EUR_TR_Account__c account = [
                SELECT Id,
                        EUR_TR_ActivityPoints__c,
                        EUR_TR_SubType__c,
                        EUR_TR_Group__c,
                        EUR_TR_Channel__c,
                        EUR_TR_ONTB__c,
                        EUR_TR_OTPros__c,
                        EUR_TR_OTSponsorship__c,
                        EUR_TR_OTType__c,
                        EUR_TR_Range__c,
                        EUR_TR_SponsorshipStatus__c,
                        EUR_TR_Class__c,
                        EUR_TR_Type__c
                FROM EUR_TR_Account__c
                WHERE Id = :accountId
        ];


        Set<String> POSMSubTypesByAccountSegmentationFields = getPOSMSubTypesByAccountSegmentationAndSelectedPOSMType(account, requestModel, POSMNamesToRecordMap.keySet());
        Set<String> visiblePOSMSubTypes = new Set<String>();
        if (!POSMSubTypesByAccountSegmentationFields.isEmpty()) {
            visiblePOSMSubTypes.addAll(POSMSubTypesByAccountSegmentationFields);
        }

        List<EUR_TR_Definition__c> visiblePOSMDefinitionRecords = new List<EUR_TR_Definition__c>();
        for (String visiblePOSMSubType : visiblePOSMSubTypes) {
            if (POSMNamesToRecordMap.containsKey(visiblePOSMSubType)) {
                visiblePOSMDefinitionRecords.add(POSMNamesToRecordMap.get(visiblePOSMSubType));
            }
        }

        return visiblePOSMDefinitionRecords;


    }


    private static Set<String> getPOSMSubTypesByAccountSegmentationAndSelectedPOSMType(EUR_TR_Account__c account, POSMSubTypeRequestModel requestModel, Set<String> allValuesBySelectedPOSMType) {

        String querySelect =
                'SELECT ' +
                        'Id,' +
                        'EUR_TR_SegmentationPOSMSubTypes__c ';
        String queryFrom = 'FROM EUR_TR_Definition__c ';

        String queryWhere = '';

        queryWhere += 'WHERE RecordType.DeveloperName = \'EUR_TR_POSMSegmentation\' ';
        if (String.isNotBlank(account.EUR_TR_ActivityPoints__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_ActivityPoints__c', account.EUR_TR_ActivityPoints__c);
        }

        if (String.isNotBlank(account.EUR_TR_SubType__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_SubType__c', account.EUR_TR_SubType__c);
        }

        if (String.isNotBlank(account.EUR_TR_Group__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_Group__c', account.EUR_TR_Group__c);
        }

        if (String.isNotBlank(account.EUR_TR_Channel__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_Channel__c', account.EUR_TR_Channel__c);
        }

        if (String.isNotBlank(account.EUR_TR_ONTB__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_ONTB__c', account.EUR_TR_ONTB__c);
        }

        if (String.isNotBlank(account.EUR_TR_OTPros__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_OTPros__c', account.EUR_TR_OTPros__c);
        }

        if (String.isNotBlank(account.EUR_TR_OTSponsorship__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_OTSponsorship__c', account.EUR_TR_OTSponsorship__c);
        }

        if (String.isNotBlank(account.EUR_TR_OTType__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_OTType__c', account.EUR_TR_OTType__c);
        }

        if (String.isNotBlank(account.EUR_TR_Range__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_Range__c', account.EUR_TR_Range__c);
        }

        if (String.isNotBlank(account.EUR_TR_SponsorshipStatus__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_SponsorshipStatus__c', account.EUR_TR_SponsorshipStatus__c);
        }

        if (String.isNotBlank(account.EUR_TR_Class__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_Class__c', account.EUR_TR_Class__c);
        }

        if (String.isNotBlank(account.EUR_TR_Type__c)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_Type__c', account.EUR_TR_Type__c);
        }

        if (String.isNotBlank(requestModel.POSMType)) {
            queryWhere += getQueryLikeStatementBySegmentationField('EUR_TR_SegmentationPOSMTypes__c', requestModel.POSMType);
        }


        String query = String.format('{0} {1} {2}', new List<String>{
                querySelect,
                queryFrom,
                queryWhere
        });

        System.debug(query);

        List<EUR_TR_Definition__c> definitions = Database.query(query);

        Set<String> allPOSMSubTypes = new Set<String>();
        Set<String> POSMSubTypesByField = new Set<String>();
        for (EUR_TR_Definition__c definition : definitions) {
            POSMSubTypesByField = getPOSMSubTypesBySelectedPOSMSubTypeField(definition.EUR_TR_SegmentationPOSMSubTypes__c, allValuesBySelectedPOSMType);
            if (!POSMSubTypesByField.isEmpty()) {
                allPOSMSubTypes.addAll(POSMSubTypesByField);
            }
        }

        return allPOSMSubTypes;
    }

    private static String getQueryLikeStatementBySegmentationField(String fieldName, String fieldValue) {

        String allValue = '\'%All%\'';
        fieldValue = '\'%' + fieldValue + '%\' ';

        String queryLikeStatement = 'AND ( {0} LIKE {1} OR {0} LIKE {2} ) ';
        queryLikeStatement = String.format(queryLikeStatement, new List<String>{
                fieldName, fieldValue, allValue
        });
        return queryLikeStatement;

    }

    private static Set<String> getPOSMTypesBySelectedPOSMTypeField(String selectedPOSMTypeField, Set<String> allActivePOSMTypes) {

        Set<String> POSMTypes = new Set<String>();
        List<String> POSMTypesBySelectedPOSMTypeField = new List<String>();
        if (String.isNotBlank(selectedPOSMTypeField) && selectedPOSMTypeField != 'All') {
            POSMTypesBySelectedPOSMTypeField = selectedPOSMTypeField.split(';');
        } else if (String.isNotBlank(selectedPOSMTypeField) && selectedPOSMTypeField == 'All') {
            POSMTypesBySelectedPOSMTypeField = new List<String>(allActivePOSMTypes);
        }

        for (String POSMType : POSMTypesBySelectedPOSMTypeField) {
            POSMTypes.add(POSMType);
        }

        return POSMTypes;

    }

    private static Set<String> getPOSMSubTypesBySelectedPOSMSubTypeField(String selectedSegmentationPOSMSubTypes, Set<String> allValuesBySelectedPOSMType) {

        Set<String> POSMTypes = new Set<String>();
        List<String> POSMTypesBySelectedPOSMTypeField = new List<String>();
        if (String.isNotBlank(selectedSegmentationPOSMSubTypes) && selectedSegmentationPOSMSubTypes != 'All') {
            POSMTypesBySelectedPOSMTypeField = selectedSegmentationPOSMSubTypes.split(';');
        } else if (String.isNotBlank(selectedSegmentationPOSMSubTypes) && selectedSegmentationPOSMSubTypes == 'All') {
            POSMTypesBySelectedPOSMTypeField = new List<String>(allValuesBySelectedPOSMType);
        }

        for (String POSMType : POSMTypesBySelectedPOSMTypeField) {
            POSMTypes.add(POSMType);
        }

        return POSMTypes;

    }

    public static Map<String, EUR_TR_Definition__c> getPOSMTypeDefinitionMap(Id accountId) {

        List<EUR_TR_Definition__c> definitionsBySegmentation = getPOSMTypes(accountId);

        Map<String, EUR_TR_Definition__c> POSMTypeDefinitionMap = new Map<String, EUR_TR_Definition__c>();
        for (EUR_TR_Definition__c definition : definitionsBySegmentation) {
            POSMTypeDefinitionMap.put(definition.EUR_TR_POSMType__c, definition);
        }
        return POSMTypeDefinitionMap;

    }

    public static Map<String, EUR_TR_Definition__c> getPOSMSubTypeDefinitionMap(POSMSubTypeRequestModel requestModel) {

        List<EUR_TR_Definition__c> definitionsBySegmentation = getPOSMSubTypesByPOSMType(requestModel);

        Map<String, EUR_TR_Definition__c> POSMTypeDefinitionMap = new Map<String, EUR_TR_Definition__c>();
        for (EUR_TR_Definition__c definition : definitionsBySegmentation) {
            POSMTypeDefinitionMap.put(definition.Id, definition);
        }
        return POSMTypeDefinitionMap;

    }

    @AuraEnabled(Cacheable=true)
    public static List<ContentDocument> getUploadedPOSMImage(Id recordId) {

        Set<Id> contentDocumentIds = new Set<Id>();

        Map<Id, ContentDocumentLink> contentDocumentLinkMap = new Map<Id, ContentDocumentLink>([
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
        ]);

        for (ContentDocumentLink contentDocumentLink : contentDocumentLinkMap.values()) {
            if (contentDocumentLink.ContentDocumentId != null) {
                contentDocumentIds.add(contentDocumentLink.ContentDocumentId);
            }
        }

        Map<Id, ContentDocument> contentDocumentMap = new Map<Id, ContentDocument>([
                SELECT Id, Title, LatestPublishedVersionId
                FROM ContentDocument
                WHERE Id = :contentDocumentIds
        ]);

        Set<Id> latestPublishedVersionIds = new Set<Id>();
        for (ContentDocument contentDocument : contentDocumentMap.values()) {
            if (contentDocument.LatestPublishedVersionId != null) {
                latestPublishedVersionIds.add(contentDocument.LatestPublishedVersionId);
            }
        }

        Map<Id, ContentVersion> POSMImageLatestVersionMap = new Map<Id, ContentVersion>([
                SELECT Id
                FROM ContentVersion
                WHERE EUR_TR_ImageSource__c = 'POSM Type' AND Id = :latestPublishedVersionIds
        ]);

        List<ContentDocument> POSMImages = new List<ContentDocument>();
        for (ContentDocument contentDocument : contentDocumentMap.values()) {
            if (POSMImageLatestVersionMap.keySet().contains(contentDocument.LatestPublishedVersionId)) {
                POSMImages.add(contentDocument);
            }
        }

        return POSMImages;

    }

    @AuraEnabled
    public static List<ContentDocument> handleUploadFinished(Id recordId, Id uploadedContentDocumentId) {

        Savepoint sp = Database.setSavepoint();
        try {

            ContentDocumentLink uploadedContentDocumentLink = [
                    SELECT Id, ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :recordId AND ContentDocumentId = :uploadedContentDocumentId
            ];

            ContentVersion uploadedContentVersion = [
                    SELECT Id, ContentDocumentId, VersionData, PathOnClient,ContentUrl,Title
                    FROM ContentVersion
                    WHERE ContentDocumentId = :uploadedContentDocumentLink.ContentDocumentId
                    AND IsLatest = TRUE
                    LIMIT 1
            ];

            ContentVersion newContentVersionOfUploadedDocument = new ContentVersion();
            newContentVersionOfUploadedDocument = uploadedContentVersion;
            newContentVersionOfUploadedDocument.VersionData = uploadedContentVersion.VersionData;
            newContentVersionOfUploadedDocument.ContentUrl = uploadedContentVersion.ContentUrl;
            newContentVersionOfUploadedDocument.Title = uploadedContentVersion.Title;
            newContentVersionOfUploadedDocument.EUR_TR_ImageSource__c = 'POSM Type';
            newContentVersionOfUploadedDocument.Id = null;
            newContentVersionOfUploadedDocument.ContentBodyId = null;
            newContentVersionOfUploadedDocument.ContentDocumentId = uploadedContentDocumentId;

            insert newContentVersionOfUploadedDocument;

            generateDownloadablePOSMTypeImageURL(new Set<Id>{
                    newContentVersionOfUploadedDocument.Id
            });

            List<ContentDocumentLink> contentDocumentLinksToDelete = [
                    SELECT Id, ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :recordId AND ContentDocumentId != :uploadedContentDocumentId
            ];

            List<ContentDocument> contentDocumentsToDelete = new List<ContentDocument>();
            for (ContentDocumentLink contentDocumentLink : contentDocumentLinksToDelete) {
                if (contentDocumentLink.ContentDocumentId != null) {
                    ContentDocument contentDocumentToDelete = new ContentDocument(Id = contentDocumentLink.ContentDocumentId);
                    contentDocumentsToDelete.add(contentDocumentToDelete);
                }
            }

            if (!contentDocumentsToDelete.isEmpty()) {
                delete contentDocumentsToDelete;
            }

            return getUploadedPOSMImage(recordId);

        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }


    }

    @AuraEnabled
    public static List<ContentDocument> deletePOSMImage(Id recordId, Id latestContentVersionId) {
        ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :latestContentVersionId];
        ContentDocument contentDocumentToDelete = new ContentDocument(Id = contentVersion.ContentDocumentId);
        delete contentDocumentToDelete;
        return getUploadedPOSMImage(recordId);
    }

    @AuraEnabled(cacheable=true)
    public static List<Picklist> getPicklistValues() {

        try {
            Map<String, List<String>> objectToFieldMap = new Map<String, List<String>>{
                    'EUR_TR_POSM__c' => new List<String>{
                            'EUR_TR_POSMType__c'
                    },
                    'EUR_TR_Account__c' => new List<String>{
                            'EUR_TR_ActivityPoints__c',
                            'EUR_TR_SubType__c',
                            'EUR_TR_Group__c',
                            'EUR_TR_Channel__c',
                            'EUR_TR_ONTB__c',
                            'EUR_TR_OTPros__c',
                            'EUR_TR_OTSponsorship__c',
                            'EUR_TR_OTType__c',
                            'EUR_TR_Range__c',
                            'EUR_TR_SponsorshipStatus__c',
                            'EUR_TR_Class__c',
                            'EUR_TR_Type__c'
                    }
            };


            List<Picklist> picklists = new List<Picklist>();
            Picklist picklist = null;
            List<PicklistItem> items = new List<PicklistItem>();

            picklist = new Picklist();
            picklist.objectName = 'EUR_TR_Definition__c';
            picklist.fieldName = 'EUR_TR_SegmentationPOSMSubTypes__c';
            items.add(new PicklistItem('Tümü', 'All'));
            for (AggregateResult aggregateResult : [
                    SELECT Name
                    FROM EUR_TR_Definition__c
                    WHERE
                    RecordType.DeveloperName = 'EUR_TR_POSMType' AND EUR_TR_POSMTypeStatus__c = 'Aktif'
                    GROUP BY Name
            ]) {
                String POSMProduct = (String) aggregateResult.get('Name');
                if (POSMProduct != null) {
                    items.add(new PicklistItem(POSMProduct, POSMProduct));
                }
            }
            picklist.items = items;
            picklists.add(picklist);

            for (String objectName : objectToFieldMap.keySet()) {
                for (String fieldName : objectToFieldMap.get(objectName)) {
                    picklist = new Picklist();
                    picklist.objectName = objectName;
                    if (fieldName == 'EUR_TR_POSMType__c') {
                        picklist.fieldName = 'EUR_TR_SegmentationPOSMTypes__c';
                    } else {
                        picklist.fieldName = fieldName;
                    }
                    items = new List<PicklistItem>();
                    items.add(new PicklistItem('Tümü', 'All'));
                    items.addAll(getPickListItems(objectName, fieldName));
                    picklist.items = items;
                    picklists.add(picklist);
                }
            }

            return picklists;
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }

    }

    @AuraEnabled
    public static DefinitionWrapper getPOSMSegmentationDefinitions(Integer limitSize, Integer offset, String selectedPOSMType, Id POSMRecordId) {

        String querySelect =
                'SELECT ' +
                        'Id,' +
                        'Name,' +
                        'EUR_TR_SegmentationPOSMTypes__c,' +
                        'EUR_TR_ActivityPoints__c,' +
                        'EUR_TR_SubType__c,' +
                        'EUR_TR_Group__c,' +
                        'EUR_TR_Channel__c,' +
                        'EUR_TR_ONTB__c,' +
                        'EUR_TR_OTPros__c,' +
                        'EUR_TR_OTSponsorship__c,' +
                        'EUR_TR_OTType__c,' +
                        'EUR_TR_Range__c,' +
                        'EUR_TR_SponsorshipStatus__c,' +
                        'EUR_TR_Class__c,' +
                        'EUR_TR_Type__c,' +
                        'EUR_TR_SegmentationPOSMSubTypes__c ';
        String queryFrom = 'FROM EUR_TR_Definition__c ';
        String queryWhere = 'WHERE RecordType.DeveloperName = \'EUR_TR_POSMSegmentation\' ';
        String POSMTypeSearchText = '';
        if (POSMRecordId != null) {
            EUR_TR_Definition__c definition = [SELECT Id, EUR_TR_POSMType__c FROM EUR_TR_Definition__c WHERE Id = :POSMRecordId];
            if (definition.EUR_TR_POSMType__c == null) {
                POSMTypeSearchText = '%All%';
                queryWhere += 'AND EUR_TR_SegmentationPOSMTypes__c like :POSMTypeSearchText ';
            } else {
                POSMTypeSearchText = '%' + definition.EUR_TR_POSMType__c + '%';
                queryWhere += 'AND EUR_TR_SegmentationPOSMTypes__c like :POSMTypeSearchText  ';
            }

        } else {
            if (selectedPOSMType != 'All') {
                POSMTypeSearchText = '%' + selectedPOSMType + '%';
                queryWhere += 'AND EUR_TR_SegmentationPOSMTypes__c like :POSMTypeSearchText ';
            }
        }

        String queryOrderBy = 'ORDER BY CreatedDate DESC ';
        String queryLimit = 'LIMIT :limitSize OFFSET :offset';

        String query = String.format('{0} {1} {2} {3}', new List<String>{
                querySelect,
                queryFrom,
                queryWhere,
                queryOrderBy,
                queryLimit
        });

        System.debug(query);

        List<EUR_TR_Definition__c> segmentations = Database.query(query);

        String countQuery = String.format('Select count(Id) total {1} {2}', new List<String>{
                querySelect, queryFrom, queryWhere
        });

        Integer totalRow = (Integer) Database.query(countQuery).get(0).get('total');

        DefinitionWrapper wrapper = new DefinitionWrapper();
        wrapper.totalRow = totalRow;
        wrapper.segmentations = segmentations;

        return wrapper;
    }

    @AuraEnabled
    public static String downloadSegmentationDefinitions() {

        String segmentationColumns =
                String.format('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13}\n',
                        new List<String>{
                                'Ürün Tipi',
                                'Ürün Alt Tipi',
                                'Kanal',
                                'Grup',
                                'Sınıf',
                                'Alt Tipi',
                                'Sponsorluk Durumu',
                                'Büyüklük',
                                'Tipi',
                                'OT Pros',
                                'OT Tipi',
                                'ONTB',
                                'Aktivite Puanı',
                                'OT Sponsorluk'
                        });

        String segmentationExcel = segmentationColumns;
        String segmentationData = '';

        List<EUR_TR_Definition__c> segmentationDefinitions = [
                SELECT
                        Id,
                        EUR_TR_SegmentationPOSMTypes__c,
                        EUR_TR_SegmentationPOSMSubTypes__c,
                        EUR_TR_ActivityPoints__c,
                        EUR_TR_SubType__c,
                        EUR_TR_Group__c,
                        EUR_TR_Channel__c,
                        EUR_TR_ONTB__c,
                        EUR_TR_OTPros__c,
                        EUR_TR_OTSponsorship__c,
                        EUR_TR_OTType__c,
                        EUR_TR_Range__c,
                        EUR_TR_SponsorshipStatus__c,
                        EUR_TR_Class__c,
                        EUR_TR_Type__c
                FROM EUR_TR_Definition__c
                WHERE RecordType.DeveloperName = 'EUR_TR_POSMSegmentation'
                LIMIT 50000
        ];

        for (EUR_TR_Definition__c segmentationDefinition : segmentationDefinitions) {
            if (segmentationDefinition.EUR_TR_SegmentationPOSMTypes__c == null) {
                segmentationDefinition.EUR_TR_SegmentationPOSMTypes__c = '';
            }
            if (segmentationDefinition.EUR_TR_SegmentationPOSMSubTypes__c == null) {
                segmentationDefinition.EUR_TR_SegmentationPOSMSubTypes__c = '';
            }
            if (segmentationDefinition.EUR_TR_Channel__c == null) {
                segmentationDefinition.EUR_TR_Channel__c = '';
            }
            if (segmentationDefinition.EUR_TR_Group__c == null) {
                segmentationDefinition.EUR_TR_Group__c = '';
            }
            if (segmentationDefinition.EUR_TR_Class__c == null) {
                segmentationDefinition.EUR_TR_Class__c = '';
            }
            if (segmentationDefinition.EUR_TR_SubType__c == null) {
                segmentationDefinition.EUR_TR_SubType__c = '';
            }
            if (segmentationDefinition.EUR_TR_SponsorshipStatus__c == null) {
                segmentationDefinition.EUR_TR_SponsorshipStatus__c = '';
            }
            if (segmentationDefinition.EUR_TR_Range__c == null) {
                segmentationDefinition.EUR_TR_Range__c = '';
            }
            if (segmentationDefinition.EUR_TR_Type__c == null) {
                segmentationDefinition.EUR_TR_Type__c = '';
            }
            if (segmentationDefinition.EUR_TR_OTPros__c == null) {
                segmentationDefinition.EUR_TR_OTPros__c = '';
            }
            if (segmentationDefinition.EUR_TR_OTType__c == null) {
                segmentationDefinition.EUR_TR_OTType__c = '';
            }
            if (segmentationDefinition.EUR_TR_ONTB__c == null) {
                segmentationDefinition.EUR_TR_ONTB__c = '';
            }
            if (segmentationDefinition.EUR_TR_ActivityPoints__c == null) {
                segmentationDefinition.EUR_TR_ActivityPoints__c = '';
            }
            if (segmentationDefinition.EUR_TR_OTSponsorship__c == null) {
                segmentationDefinition.EUR_TR_OTSponsorship__c = '';
            }

            segmentationData =
                    String.format('{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12} {13}\n',
                            new List<String>{
                                    segmentationDefinition.EUR_TR_SegmentationPOSMTypes__c.replace(';', ' / '),
                                    segmentationDefinition.EUR_TR_SegmentationPOSMSubTypes__c.replace(';', ' / '),
                                    segmentationDefinition.EUR_TR_Channel__c.replace(';', ' / '),
                                    segmentationDefinition.EUR_TR_Group__c.replace(';', ' / '),
                                    segmentationDefinition.EUR_TR_Class__c.replace(';', ' / '),
                                    segmentationDefinition.EUR_TR_SubType__c.replace(';', ' / '),
                                    segmentationDefinition.EUR_TR_SponsorshipStatus__c.replace(';', ' / '),
                                    segmentationDefinition.EUR_TR_Range__c.replace(';', ' / '),
                                    segmentationDefinition.EUR_TR_Type__c.replace(';', ' / '),
                                    segmentationDefinition.EUR_TR_OTPros__c.replace(';', ' / '),
                                    segmentationDefinition.EUR_TR_OTType__c.replace(';', ' / '),
                                    segmentationDefinition.EUR_TR_ONTB__c.replace(';', ' / '),
                                    segmentationDefinition.EUR_TR_ActivityPoints__c.replace(';', ' / '),
                                    segmentationDefinition.EUR_TR_OTSponsorship__c.replace(';', ' / ')
                            });
            segmentationExcel = segmentationExcel + segmentationData;
        }
        segmentationExcel = '\uFEFF' + segmentationExcel;

        return segmentationExcel;

    }

    public class DefinitionWrapper {
        @AuraEnabled
        public Integer totalRow { get; set; }
        @AuraEnabled
        public List<EUR_TR_Definition__c> segmentations { get; set; }
    }

    @AuraEnabled
    public static void upsertPOSMSegmentationDefinition(EUR_TR_Definition__c segmentationDefinition) {
        Id segmentationRecordTypeId = Schema.SObjectType.EUR_TR_Definition__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_POSMSegmentation').getRecordTypeId();
        segmentationDefinition.RecordTypeId = segmentationRecordTypeId;
        upsert segmentationDefinition;
    }

    private static List<PicklistItem> getPickListItems(String objectName, String fieldName) {
        List<PicklistItem> items = new List<PicklistItem>();
        PicklistItem item = null;
        for (PicklistEntry pe : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
            /*
            if (pe.isActive()) {
                item = new PicklistItem(pe.getLabel(), pe.getValue());
                items.add(item);
            }
            */
            item = new PicklistItem(pe.getLabel(), pe.getValue());
            items.add(item);
        }
        return items;
    }

    private static Map<Id, List<String>> getPOSMImageURLs(Set<Id> linkedEntityIds) {

        Map<Id, List<String>> linkedEntityToPOSMImageURLMap = new Map<Id, List<String>>();

        Set<Id> contentDocumentSet = new Set<Id>();
        Map<Id, ContentDocumentLink> contentDocumentLinksMap = new Map<Id, ContentDocumentLink>();

        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:linkedEntityIds];
        for (ContentDocumentLink cntLink : contentDocumentLinks) {
            contentDocumentLinksMap.put(cntLink.ContentDocumentId, cntLink);
        }
        contentDocumentSet = contentDocumentLinksMap.keySet();

        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>([
                SELECT Title, Id, FileType, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN:contentDocumentSet AND IsLatest = TRUE AND EUR_TR_ImageSource__c = 'POSM Type'
        ]);
        Set<Id> contentVersionSet = contentVersionMap.keySet();

        Map<Id, ContentDistribution> contentDistributionMap = new Map<Id, ContentDistribution>([
                SELECT Id, ContentDownloadUrl, ContentVersionId, ContentDocumentId
                FROM ContentDistribution
                WHERE ContentVersionId IN:contentVersionSet
        ]);
        Set<Id> ContentDistributionSet = contentDistributionMap.keySet();

        Id contentDocumentId = null;
        Id linkedEntityId = null;
        String downloadURL = '';
        for (Id contentDistributionId : ContentDistributionSet) {

            contentDocumentId = contentVersionMap.get(contentDistributionMap.get(contentDistributionId).ContentVersionId).ContentDocumentId;
            linkedEntityId = contentDocumentLinksMap.get(contentDocumentId).LinkedEntityId;
            downloadURL = contentDistributionMap.get(contentDistributionId).ContentDownloadUrl;

            List<String> imageURLs = linkedEntityToPOSMImageURLMap.get(linkedEntityId);
            if (imageURLs == null) {
                imageURLs = new List<String>();
                imageURLs.add(downloadURL);
            } else {
                imageURLs.add(downloadURL);
            }
            linkedEntityToPOSMImageURLMap.put(linkedEntityId, imageURLs);

        }

        for (Id recordId : linkedEntityIds) {
            if (!linkedEntityToPOSMImageURLMap.containsKey(recordId)) {
                linkedEntityToPOSMImageURLMap.put(recordId, null);
            }
        }

        return linkedEntityToPOSMImageURLMap;
    }

    private static void generateDownloadablePOSMTypeImageURL(Set<Id> latestContentVersionId) {

        ContentVersion latestVersion = [
                SELECT Id
                FROM ContentVersion
                WHERE Id = :latestContentVersionId AND EUR_TR_ImageSource__c = 'POSM Type' AND IsLatest = TRUE
                LIMIT 1
        ];

        // created public download link
        ContentDistribution contentDistribution = new ContentDistribution();
        contentDistribution.Name = 'EUR_TR_POSM_IMAGE';
        contentDistribution.ContentVersionId = latestVersion.Id;
        contentDistribution.PreferencesAllowViewInBrowser = true;
        contentDistribution.PreferencesLinkLatestVersion = true;
        contentDistribution.PreferencesNotifyOnVisit = false;
        contentDistribution.PreferencesPasswordRequired = false;
        contentDistribution.PreferencesAllowOriginalDownload = true;
        insert contentDistribution;

    }


    public class POSMDefinitionWrapper {
        EUR_TR_Definition__c definition { get; set; }
        public String imageURL { get; set; }
    }

    public class Picklist {
        @AuraEnabled
        public List<PicklistItem> items { get; set; }
        @AuraEnabled
        public String objectName { get; set; }
        @AuraEnabled
        public String fieldName { get; set; }
    }

    public class PicklistItem {

        public PicklistItem() {
        }

        public PicklistItem(String label, String value) {
            this.label = label;
            this.value = value;
        }

        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
    }

    public class POSMSubTypeRequestModel {

        public POSMSubTypeRequestModel() {

        }

        public POSMSubTypeRequestModel(EUR_TR_POSM__c posm) {
            this.accountId = posm.EUR_TR_RelatedAccount__c;
            this.POSMType = posm.EUR_TR_POSMType__c;
            this.brand = posm.EUR_TR_Brand__c;
            this.brandOther = posm.EUR_TR_BrandOther__c;
        }

        public Id accountId { get; set; }
        public String POSMType { get; set; }
        public String brand { get; set; }
        public String brandOther { get; set; }
    }

}