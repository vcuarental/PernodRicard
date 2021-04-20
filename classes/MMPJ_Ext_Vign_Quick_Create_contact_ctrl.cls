public with sharing class MMPJ_Ext_Vign_Quick_Create_contact_ctrl {
    @AuraEnabled(cacheable=true)
    public static String getSalesforceConfiguration() {
        Schema.DescribeSObjectResult societeContactDescribe = MMPJ_Ext_Vign_Societe_Contact__c.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = societeContactDescribe.fields.getMap();

        Schema.DescribeFieldResult titreDescribe = fieldMap.get('MMPJ_XRM_Titre__c').getDescribe();
        Schema.DescribeFieldResult fonctionDescribe = fieldMap.get('MMPJ_Ext_Vign_Fonction__c').getDescribe();

        Map<Id, Schema.RecordTypeInfo> mapOfRecordTypes = Schema.SObjectType.Contact.getRecordTypeInfosById();
        Id extRecordId = null;
        for(Id recordTypeId : mapOfRecordTypes.keySet()) {
            Schema.RecordTypeInfo recordTypeInfo = mapOfRecordTypes.get(recordTypeId);
            if (recordTypeInfo.getName() == 'MMPJ Extranet Vigneron Viticulteur') {
                extRecordId = recordTypeId;
            }
        }

        if (extRecordId == null) {
            System.debug('Aucun record type correspondant à "MMPJ Extranet Vigneron Viticulteur" n\'a été trouvé');
        }

        User currentUser = [SELECT Id, Username, FirstName, Name, LastName, Email FROM User WHERE Id = :UserInfo.getUserId()];

        // Map<String, String> salutationValues = MMPJ_Ext_Vign_Quick_Create_contact_ctrl.getValues('Contact', extRecordId, 'Salutation');

        return
            '{' +
                '"displayTitle":' + titreDescribe.isCreateable() + ', ' +
                '"displayFunction":' + fonctionDescribe.isCreateable() + ', ' +
                '"contactRecordTypeId":"' + extRecordId + '", ' +
                '"owner":' + JSON.serialize(
                    new LookupSearchResult(
                        currentUser.Id,
                        User.getSObjectType().getDescribe().getName(),
                        'standard:user',
                        currentUser.Name, currentUser.Username + ' - ' + currentUser.Email,
                        currentUser.getPopulatedFieldsAsMap()
                    )
                ) + ' ' +
            '}';
    }

    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchForUser(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
            User (Id, Username, FirstName, Name, LastName, Email WHERE Id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Contacts & convert them into LookupSearchResult
        User[] users = ((List<User>) searchResults[0]);
        for (User userFound : users) {
            results.add(
                new LookupSearchResult(
                    userFound.Id,
                    User.getSObjectType().getDescribe().getName(),
                    'standard:user',
                    userFound.Name, userFound.Username + ' - ' + userFound.Email,
                    userFound.getPopulatedFieldsAsMap()
                )
            );
        }

        return results;
    }

    @AuraEnabled
    public static string quickCreateContact(Id contactId, Id societeId, String fonction, String titre, Boolean espacePerso, Boolean contactPrincipal, Id ownerId) {
        Contact newContact = [SELECT Id, OwnerId, Name, RecordTypeId, MMPJ_Ext_Vign_Contact_Segmentation__c FROM Contact WHERE Id = :contactId LIMIT 1];
        Id rtId = [SELECT Id from RecordType where SobjectType='Contact' and DeveloperName='MMPJ_Ext_Vign_Contact' LIMIT 1].Id;
        newContact.RecordTypeId = rtId;
        newContact.OwnerId = ownerId;
        try {
            update newContact;

            Schema.DescribeSObjectResult societeContactDescribe = MMPJ_Ext_Vign_Societe_Contact__c.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = societeContactDescribe.fields.getMap();

            Schema.DescribeFieldResult titreDescribe = fieldMap.get('MMPJ_XRM_Titre__c').getDescribe();
            Schema.DescribeFieldResult fonctionDescribe = fieldMap.get('MMPJ_Ext_Vign_Fonction__c').getDescribe();

            MMPJ_Ext_Vign_Societe_Contact__c societeContact = new MMPJ_Ext_Vign_Societe_Contact__c(
                // OwnerId = ownerId, // <-- No Owner Id Field
                MMPJ_Ext_Vign_Contact__c = contactId,
                MMPJ_Ext_Vign_Societe__c = societeId,
                MMPJ_Ext_Vign_SocietContact_Segmentation__c = newContact.MMPJ_Ext_Vign_Contact_Segmentation__c,
                MMPJ_XRM_Espace_Personnel_MMPJetMoi__c = espacePerso,
                MMPJ_Ext_Vign_Contact_Principal__c = contactPrincipal
            );

            if (fonctionDescribe.isCreateable()) {
                societeContact.MMPJ_Ext_Vign_Fonction__c = fonction;
            }
            if (titreDescribe.isCreateable()) {
                societeContact.MMPJ_XRM_Titre__c = titre;
            }
            insert societeContact;
            return 'OK:' + societeContact.Id;
        } catch (Exception e) {
            // in case it failed, we delete the contact.
            delete newContact;
            return 'FAILED:' + e.getCause() + ':' + e.getMessage();
        }
    }

    public class LookupSearchResult {
        private Id id;
        private String sObjectType;
        private String icon;
        private String title;
        private String subtitle;
        private Map<String, Object> sObjectValues;

        public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle, Map<String, Object> sObjectValues) {
            this.id = id;
            this.sObjectType = sObjectType;
            this.icon = icon;
            this.title = title;
            this.subtitle = subtitle;
            this.sObjectValues = sObjectValues;
        }

        @AuraEnabled
        public Id getId() {
            return id;
        }

        @AuraEnabled
        public String getSObjectType() {
            return sObjectType;
        }

        @AuraEnabled
        public String getIcon() {
            return icon;
        }

        @AuraEnabled
        public String getTitle() {
            return title;
        }

        @AuraEnabled
        public String getSubtitle() {
            return subtitle;
        }

        @AuraEnabled
        public String getSObjectValues() {
            if (sObjectValues == null || sObjectValues.isEmpty()) {
                return '{}';
            }
            return JSON.serialize(sObjectValues);
        }
    }
}