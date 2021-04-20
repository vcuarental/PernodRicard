public with sharing class EUR_CRM_PIMIntegrRunBatchesWrapper {

    private final String IMAGES = 'Images';
    private final String ARCHIVES = 'Archives';
    private final String BRAND = 'B';
    private final String BRAND_QUALITY = 'BQ';
    private final String BRAND_QUALITY_SIZE = 'BQS';
    private final String POSM = 'POSM';

    private List<EUR_CRM_PIMIntegrationRunningBatches__c> runningBatchesInfo;

    public EUR_CRM_PIMIntegrRunBatchesWrapper() {
        this.runningBatchesInfo = this.selectPIMIntegrationRunningBatches();
    }

    /* ========================================================= */
    /*     Interface - get country codes of running batches
    /* ========================================================= */
    public Set<String> getCountryCodesForImagesForBrands() {
        return this.getCountryCodesFor(IMAGES, BRAND);
    }

    public Set<String> getCountryCodesForImagesForBrandQualities() {
        return this.getCountryCodesFor(IMAGES, BRAND_QUALITY);
    }

    public Set<String> getCountryCodesForImagesForBrandQualitySizes() {
        return this.getCountryCodesFor(IMAGES, BRAND_QUALITY_SIZE);
    }

    public Set<String> getCountryCodesForImagesForPOSMaterials() {
        return this.getCountryCodesFor(IMAGES, POSM);
    }


    /* ========================================================= */
    /*     Interface - add country codes of running batches
    /* ========================================================= */
    public void addCountryCodeForImagesForBrands(String countryCode) {
        this.addCountryCodeFor(IMAGES, BRAND, countryCode);
    }

    public void addCountryCodeForImagesForBrandQualities(String countryCode) {
        this.addCountryCodeFor(IMAGES, BRAND_QUALITY, countryCode);
    }

    public void addCountryCodeForImagesForBrandQualitySizes(String countryCode) {
        this.addCountryCodeFor(IMAGES, BRAND_QUALITY_SIZE, countryCode);
    }

    public void addCountryCodeForImagesForPOSMaterials(String countryCode) {
        this.addCountryCodeFor(IMAGES, POSM, countryCode);
    }


    /* ========================================================= */
    /*     Interface - remove country codes of running batches
    /* ========================================================= */
    public void removeCountryCodeForImagesForBrands(String countryCode) {
        this.removeCountryCodeFor(IMAGES, BRAND, countryCode);
    }

    public void removeCountryCodeForImagesForBrandQualities(String countryCode) {
        this.removeCountryCodeFor(IMAGES, BRAND_QUALITY, countryCode);
    }

    public void removeCountryCodeForImagesForBrandQualitySizes(String countryCode) {
        this.removeCountryCodeFor(IMAGES, BRAND_QUALITY_SIZE, countryCode);
    }

    public void removeCountryCodeForImagesForPOSMaterials(String countryCode) {
        this.removeCountryCodeFor(IMAGES, POSM, countryCode);
    }


    /* ========================================================= */
    /*     Helpers
    /* ========================================================= */
    public Set<String> getCountryCodesFor(String typeOfData, String typeOfObject) {
        String fieldAPI = this.getFieldApi(typeOfData, typeOfObject);

        if (this.runningBatchesInfo.isEmpty() || String.isBlank((String.valueOf(this.runningBatchesInfo[0].get(fieldAPI))))) { return new Set<String>(); }
        return new Set<String>(String.valueOf(this.runningBatchesInfo[0].get(fieldAPI)).split(','));
    }

    private void addCountryCodeFor(String typeOfData, String typeOfObject, String countryCode) {
        String fieldAPI = this.getFieldApi(typeOfData, typeOfObject);

        System.debug('\n\n before this.runningBatchesInfo => ' + JSON.serializePretty(this.runningBatchesInfo) + '\n');
        if (this.runningBatchesInfo.isEmpty()) {
            this.runningBatchesInfo = new List<EUR_CRM_PIMIntegrationRunningBatches__c>();
            this.runningBatchesInfo.add(new EUR_CRM_PIMIntegrationRunningBatches__c());
            this.runningBatchesInfo[0].put(fieldAPI, countryCode + ',');
        } else if (String.isBlank(String.valueOf(this.runningBatchesInfo[0].get(fieldAPI)))) {
            this.runningBatchesInfo[0].put(fieldAPI, countryCode + ',');
        } else if (String.valueOf(this.runningBatchesInfo[0].get(fieldAPI)).containsIgnoreCase('All,')) {
            return ;
        } else {
            this.runningBatchesInfo[0].put(fieldAPI, String.valueOf(this.runningBatchesInfo[0].get(fieldAPI)) + countryCode + ',');
        }
        System.debug('\n\n after this.runningBatchesInfo => ' + JSON.serializePretty(this.runningBatchesInfo) + '\n');
        upsert this.runningBatchesInfo[0];
    }

    private void removeCountryCodeFor(String typeOfData, String typeOfObject, String countryCode) {
        String fieldAPI = this.getFieldApi(typeOfData, typeOfObject);

        System.debug('\n\n before this.runningBatchesInfo => ' + JSON.serializePretty(this.runningBatchesInfo) + '\n');
        if (this.runningBatchesInfo.isEmpty() || String.isBlank(String.valueOf(this.runningBatchesInfo[0].get(fieldAPI)))) {
            return ;
        } else {
            Set<String> countryCodes = new Set<String>(String.valueOf(this.runningBatchesInfo[0].get(fieldAPI)).split(','));
            if (countryCodes.contains(countryCode)) {
                countryCodes.remove(countryCode);
                String countryCodesAsString = String.join(new List<String>(countryCodes), ',');
                if ( ! String.isBlank(countryCodesAsString)) { countryCodesAsString += ','; }
                this.runningBatchesInfo[0].put(fieldAPI, String.valueOf(countryCodesAsString));
                System.debug('\n\n after this.runningBatchesInfo => ' + JSON.serializePretty(this.runningBatchesInfo) + '\n');
                update this.runningBatchesInfo[0];
            }
        }
    }

    private String getFieldApi(String typeOfData, String typeOfObject) {
        return 'EUR_CRM_' + typeOfData + 'For' + typeOfObject + '__c';
    }


    /* ========================================================= */
    /*     SOQL Selectors
    /* ========================================================= */
    private List<EUR_CRM_PIMIntegrationRunningBatches__c> selectPIMIntegrationRunningBatches() {
        return [
            SELECT Id
            ,   EUR_CRM_ImagesForB__c
            ,   EUR_CRM_ImagesForBQ__c
            ,   EUR_CRM_ImagesForBQS__c
            ,   EUR_CRM_ImagesForPOSM__c
            FROM EUR_CRM_PIMIntegrationRunningBatches__c
        ];
    }

}