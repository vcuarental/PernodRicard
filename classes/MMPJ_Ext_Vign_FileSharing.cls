public class MMPJ_Ext_Vign_FileSharing {
    public static void insertDocuments(Map<Id, Id> mapOfContentDocumentIdsWithEntityIds) {
        List<ContentDistribution> listOfContentDistributions = new List<ContentDistribution>();

        String docPrefix = Schema.getGlobalDescribe().get('MMPJ_Ext_Vign_Documents_Fournis__c').getDescribe().getKeyPrefix();

        for (ContentVersion cv : [
            SELECT Id, Title, ContentDocumentId, ContentDocument.FileExtension
            FROM ContentVersion
            WHERE ContentDocumentId IN :mapOfContentDocumentIdsWithEntityIds.keySet()   AND
                IsLatest = true                                                         //AND
                // (
                //     Title LIKE '%Couverture%'                                           OR
                //     Title LIKE '%Vignette%'                                             
                // )
        ]) {

            if (((String)mapOfContentDocumentIdsWithEntityIds.get(cv.ContentDocumentId)).startsWith(docPrefix) ||
                (cv.Title.contains('Couverture') || cv.Title.contains('Vignette'))) {

                listOfContentDistributions.add(
                    new ContentDistribution(
                        Name = cv.Title + '.' + cv.ContentDocument.FileExtension,
                        ContentVersionId = cv.Id,
                        PreferencesAllowOriginalDownload = true,
                        PreferencesAllowPDFDownload = false,
                        PreferencesAllowViewInBrowser = true
                    )
                );
            }
        }

        insert listOfContentDistributions;

        Pattern pCounverture = Pattern.compile('(.*)Couverture(.*)');
        Pattern pVignette = Pattern.compile('(.*)Vignette(.*)');
        // Pattern pDocument = Pattern.compile('(.*)Document(.*)');

        Map<Id, SObject> updatedEntities = new Map<Id, SObject>();
        Id orgId = UserInfo.getOrganizationId();
        String orgName = [SELECT InstanceName FROM Organization LIMIT 1].InstanceName;
        String urlprefix = System.URL.getSalesforceBaseURL().getHost();
        System.debug(LoggingLevel.DEBUG, '### instance host=' + urlprefix);
        String urlsuffix = null;
        String fullUrl = null;
        Schema.SObjectType campaignSObjType = Campaign.getSObjectType();
        Schema.SObjectType documentFourniSObjType = MMPJ_Ext_Vign_Documents_Fournis__c.getSObjectType();
        Schema.SObjectType currentLinkedSObjType = null;

        for (ContentDistribution cd : [
            SELECT ContentVersionId, ContentDocumentId, ContentVersion.Title, DistributionPublicUrl
            FROM ContentDistribution
            WHERE Id IN :listOfContentDistributions
        ]) {
            Id linkedEntityId = mapOfContentDocumentIdsWithEntityIds.get(cd.ContentDocumentId);
            currentLinkedSObjType = linkedEntityId.getSobjectType();
            if (currentLinkedSObjType != campaignSObjType && 
                currentLinkedSObjType != documentFourniSObjType) {
                // Do not update Campaign object.
                continue;
            }

            urlsuffix = cd.DistributionPublicUrl.split('sfc/p/')[1];
            urlsuffix = urlsuffix.substring(12);
            fullUrl = 'https://' + urlprefix.split('\\.')[0] + '--c.' + orgName + '.content.force.com/sfc/dist/version/download/?oid=' + orgId + '&ids=' + cd.ContentVersionId + '&d=' + urlsuffix;
            System.debug(LoggingLevel.DEBUG, '### url generated=' + fullURL);

            SObject entity = updatedEntities.get(linkedEntityId);
            if (entity == null) {
                if (currentLinkedSObjType == campaignSObjType) {
                    entity = campaignSObjType.newSObject(linkedEntityId);
                } else if (currentLinkedSObjType == documentFourniSObjType) {
                    entity = documentFourniSObjType.newSObject(linkedEntityId);                
                }
                updatedEntities.put(linkedEntityId, entity);
            }
            if (pCounverture.matcher(cd.ContentVersion.Title).matches() && currentLinkedSObjType == campaignSObjType) {
                entity.put('MMPJ_Ext_Vign_Lien_Public__c',fullURL);
            }
            if (pVignette.matcher(cd.ContentVersion.Title).matches() && currentLinkedSObjType == campaignSObjType) {
                entity.put('MMPJ_Ext_Vign_Lien_Public_Image_Vignette__c',fullURL);
            }
            if (//pDocument.matcher(cd.ContentVersion.Title).matches() && 
                currentLinkedSObjType == documentFourniSObjType) {
                entity.put('MMPJ_Ext_Vign_Lien_Public__c',fullURL);
            }
        }

        if (!updatedEntities.isEmpty()) {
            update updatedEntities.values();
        }
    }
}