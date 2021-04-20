public with sharing class LAT_AR_CreateReceiptRange {

    public String errorMsg {get;set;}
    public static boolean inProgress;
	public LAT_Receipt_Range__c currentRange {get;set;}

    public LAT_AR_CreateReceiptRange(ApexPages.StandardController controller) {
        inProgress = false;
        currentRange = new LAT_Receipt_Range__c();
    } 

    public PageReference createRange(){
        errorMsg = null;
        if (inProgress == null) {
            inProgress = false;
        }    

        if (!inProgress) {
            inProgress = true;
            System.debug('%%%%%%% entramos a crear para el usuario : ' + currentRange.OwnerId);
            if (hasActiveRanges(currentRange.OwnerId)) {
                System.debug('%%%%%%% Ya existen Rangos disponibles para ese Vendedor : ' + currentRange.OwnerId);
                ApexPages.addMessage(new ApexPages.Message(Apexpages.SEVERITY.ERROR,'Ya existen Rangos disponibles para ese Vendedor'));
                errorMsg = 'Ya existen Rangos disponibles para ese Vendedor';
                return null;
            }
            List<Profile> currentProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            String currentProfileName = currentProfile[0].Name;

            Set<String> adminProfiles = LAT_GeneralConfigDao.getValueAsStringSet('AR_PROFILES_CREATE_RANGE', ',' , true);
            if (!adminProfiles.contains(currentProfileName)) {
                System.debug('%%%%%%% El usuario no es Admin, entonces no se le permite crear : ' + currentRange.OwnerId);
                Apexpages.addMessage( new Apexpages.Message( Apexpages.SEVERITY.ERROR, 'Los Rangos solo pueden ser creados por Administradores del Sistema. Por favor póngase en contacto con uno.'));
                errorMsg = 'Los Rangos solo pueden ser creados por Administradores del Sistema. Por favor póngase en contacto con uno.';
                return null;
            }
            if (currentRange.OwnerId == null) {
                System.debug('%%%%%%% no pasamos : ' + currentRange.OwnerId);
                Apexpages.addMessage( new Apexpages.Message( Apexpages.SEVERITY.ERROR, 'Debe seleccionar un Vendedor para el cual crear el Rango.'));
                errorMsg = 'Debe seleccionar un Vendedor para el cual crear el Rango.';
                return null;
            }
            System.debug('%%%%%%% pasamos : ' + currentRange.OwnerId);
            this.currentRange = AP01_Receipt_AR.createRange('APP', currentRange.OwnerId);
            insert currentRange;
        } else {
            System.debug('%%%% no para de cliquear el cabeza este.');
        }
        return new PageReference('/apex/LAT_ReceiptRange_ListView');
    }

    private boolean hasActiveRanges(String ownerId){
        List<LAT_Receipt_Range__c> existing = [SELECT id FROM LAT_Receipt_Range__c WHERE User__c = :ownerId AND Finished__c =false AND Available_Numbers__c > 0];
        if (existing.size() > 0) {
            return true;
        } else {
            return false;
        }

    }
}