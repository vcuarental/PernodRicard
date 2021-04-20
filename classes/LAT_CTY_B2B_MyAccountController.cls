public with sharing class LAT_CTY_B2B_MyAccountController {
    private static final String TITULO_API_NAME = 'Titulos__c';

    @AuraEnabled
    public static void updateUserEmailPreferences (boolean emailOptOut) {
        //Contact c = getContact();
        //c.HasOptedOutOfEmail = !emailOptOut;
        //update c;
        //return emailOptOut;
        // el contacto no puede actualiuzar por tema permisos, usamos al usuario
        final String userId = UserInfo.getUserId();
        User u = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        u.ReceivesInfoEmails = emailOptOut;
        update u;
    }
    
    @AuraEnabled
    public static boolean getUserEmailPreferences() {
        final String userId = UserInfo.getUserId();
        final User u = [SELECT Id, ContactId, ReceivesInfoEmails FROM User WHERE Id = :userId];
        return u.ReceivesInfoEmails;
    }
    
    @AuraEnabled
    public static List<ListView> getTitulosListViewNames () {
        List<ListView> listNames = [SELECT DeveloperName FROM ListView WHERE SObjectType = 'Titulos__c' AND DeveloperName = 'b2b' limit 1];
        return listNames;
    }
    
    @AuraEnabled
    public static String getAccountIdFromUser() {
        return LAT_CTY_B2B_MyAccountController.getContact().Account.Id;
    }
    
    @AuraEnabled
    public static String getAccountDetail() {
        return JSON.serialize(LAT_WS_GetAvailableCredit.getAvailableCredit(getContact().account.Client_country_AN8__c));
    }


    @AuraEnabled
    public static String getLastOpportunity() {
        try{
            Contact c = getContact();
            LAT_Opportunity__c latOpportunity= [SELECT Name, LAT_TotalValue__c FROM LAT_Opportunity__c WHERE LAT_Account__r.Id = :c.AccountId ORDER BY LAT_CreationDateTime__c DESC LIMIT 1];
            Opportunity opp = new Opportunity(latOpportunity.Name, latOpportunity.LAT_TotalValue__c);
            return JSON.serialize(opp);
        } catch (Exception ex) {
            return JSON.serialize(getContact());
        } 
        
    }
    
    @AuraEnabled
    public static List<Contact> getRelatedContacts() {
            Contact c = getContact();
            List<Contact> lista= [SELECT Name, Title, Phone, MobilePhone, LAT_DNI__c, Birthdate, Email FROM Contact WHERE accountId = :c.Account.Id ORDER BY name];
        	System.debug('Lista a enviar:' + lista);
            return lista; 
    }
    
    @AuraEnabled
    public static Contact getContact(){
        system.debug('ON getContact');
        final String userId = UserInfo.getUserId();
        system.debug('userId ' + userId);
        User u = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        system.debug('USER ' + u);
        Contact c = [SELECT Account.Id, Account.Client_country_AN8__c FROM Contact WHERE  Id = :u.ContactId LIMIT 1];
        system.debug('Contact ' + c);
        return c;
    }
    
    @AuraEnabled
    public static String getCaseAccountRegistrationRTId(){
        
        return Global_RecordTypeCache.getRtId('LAT_Case__c'+'B2B_New_Account');
    }
    Public class Opportunity {
        public final Decimal value;
        public final String name;

        public Opportunity (String name, Decimal value) {
            this.value = value;
            this.name = name;
        }
    } 
}