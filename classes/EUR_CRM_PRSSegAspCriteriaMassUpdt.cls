public with sharing class EUR_CRM_PRSSegAspCriteriaMassUpdt implements Database.Batchable<sObject>{

    private static final String IMAGE_LEVEL_TOTAL_ANSW_WGT_FIELD_NAME = 'EUR_CRM_PRS_ImageLevel_TotalAnswWgt__c';
    private static final String VOLUME_POTENTIAL_TOTAL_ANSW_WGT_FIELD_NAME = 'EUR_CRM_PRS_VolumePot_TotalAnswWgt__c';

    private String countryCode;
    private String fieldToUpdate;
    private String segAspCriteriaRTnamePart;

    public EUR_CRM_PRSSegAspCriteriaMassUpdt(String countryCode, String fieldToUpdate) {
        this.countryCode = countryCode;
        this.fieldToUpdate = fieldToUpdate;
        this.segAspCriteriaRTnamePart = '%' + fieldToUpdate.substringBetween('EUR_CRM_', '__c');
    }

    private static final Map<String, String> DEPENDENT_FIELD_BY_FIELD_TO_UPDATE = new Map<String, String> {
            'EUR_CRM_Image_Level__c' => 'EUR_CRM_PRS_ImageLevel_TotalAnswWgt__c'
        ,   'EUR_CRM_Volume_Potential__c' => 'EUR_CRM_PRS_VolumePot_TotalAnswWgt__c'
    };

    public Iterable<sObject> start(Database.BatchableContext BC) {
        String query = 'SELECT Id' +
                        ', EUR_CRM_PRS_ImageLevel_TotalAnswWgt__c' +
                        ', EUR_CRM_PRS_VolumePot_TotalAnswWgt__c' +
                        ', EUR_CRM_PRS_Group_Outlet_Type__c ' +
                    'FROM EUR_CRM_PRS_Segmentation__c ' +
                    'WHERE EUR_CRM_PRS_Group_Outlet_Type__c IN ' +
                        '(' +
                            'SELECT EUR_CRM_PRS_Group_Outlet_Type__c ' +
                            'FROM EUR_CRM_PRS_Seg_Aspect_Criteria__c ' +
                            'WHERE EUR_CRM_Is_Weight_Changed__c = true ' +
                            'AND RecordType.DeveloperName LIKE \'' + this.segAspCriteriaRTnamePart + '\'' +
                        ')';
        if(countryCode!= null){
            query +=' AND EUR_CRM_PRS_Segmentation__c.EUR_CRM_Country_Code__c =\'' + countryCode+'\'';
        }
        System.debug('\n query => ' + JSON.serializePretty(query) + '\n');
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('EUR_CRM_PRSSegAspCriteriaMassUpdt scope => ' + JSON.serializePretty(scope));
        this.processSegmentationAspectCriterias((List<EUR_CRM_PRS_Segmentation__c>) scope);
    }

    public void finish(Database.BatchableContext BC) {
        AsyncApexJob apexJob = [SELECT Id FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), apexJob.id, new String[] {});
    }


    /*==========================================
    *   High Level Helpers
    * ==========================================*/
    private void processSegmentationAspectCriterias(List<EUR_CRM_PRS_Segmentation__c> segmentations){
        Set<Id> groupOutletTypeIds = this.extractGroupOutletTypeIds(segmentations);
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> segAspectCriterias = this.selectSegAspectCriteriasWhereGroupOutletTypeIds(groupOutletTypeIds);
        System.debug('\n segAspectCriterias => ' + JSON.serializePretty(segAspectCriterias) + '\n');

        Map<Id,List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>> segAspectCriteriasByGroupOutletTypeId = new Map<Id,List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>>();
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> segAspectCriteriasToUpdate = new List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>();

        for (EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria : segAspectCriterias) {
            if(segAspectCriteriasByGroupOutletTypeId.get(segAspectCriteria.EUR_CRM_PRS_Group_Outlet_Type__c) != null) {
                segAspectCriteriasByGroupOutletTypeId.get(segAspectCriteria.EUR_CRM_PRS_Group_Outlet_Type__c).add(segAspectCriteria);
            } else {
                segAspectCriteriasByGroupOutletTypeId.put(segAspectCriteria.EUR_CRM_PRS_Group_Outlet_Type__c, new List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>{ segAspectCriteria });
            }
            if(segAspectCriteria.EUR_CRM_Is_Weight_Changed__c) {
                segAspectCriteria.EUR_CRM_Is_Weight_Changed__c = false;
                segAspectCriteriasToUpdate.add (segAspectCriteria);
            }
        }

        System.debug('\n segAspectCriteriasByGroupOutletTypeId => ' + JSON.serializePretty(segAspectCriteriasByGroupOutletTypeId) + '\n');
        System.debug('\n segmentations => ' + JSON.serializePretty(segmentations) + '\n');
        List<EUR_CRM_PRS_Segmentation__c> segmentationsToUpdate = this.getSegmentationsToUpdate(segmentations, segAspectCriteriasByGroupOutletTypeId);
        System.debug('\n segmentationsToUpdate => ' + JSON.serializePretty(segmentationsToUpdate) + '\n');
        System.debug('\n segAspectCriteriasToUpdate => ' + JSON.serializePretty(segAspectCriteriasToUpdate) + '\n');

        Savepoint sp = Database.setSavepoint();
        try {
            EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update', segmentationsToUpdate);
            EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update', segAspectCriteriasToUpdate);
        } catch(Exception e) {
            System.debug('Exception while update segmentations => ' + e.getStackTraceString() + e.getMessage());
            Database.rollback(sp);
        }
    }


    /*==========================================
    *   Middle Level Helpers
    * ==========================================*/
    private Set<Id> extractGroupOutletTypeIds(List<EUR_CRM_PRS_Segmentation__c> segmentations) {
        Set<Id> groupOutletTypeIds = new Set<Id>();
        for (EUR_CRM_PRS_Segmentation__c pros : segmentations) {
            groupOutletTypeIds.add(pros.EUR_CRM_PRS_Group_Outlet_Type__c);
        }
        return groupOutletTypeIds;
    }

    private List<EUR_CRM_PRS_Segmentation__c> getSegmentationsToUpdate(List<EUR_CRM_PRS_Segmentation__c> segmentations, Map<Id, List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>> segAspectCriteriasByGroupOutletTypeId) {
        List<EUR_CRM_PRS_Segmentation__c> segmentationsToUpdate = new List<EUR_CRM_PRS_Segmentation__c>();
        for (EUR_CRM_PRS_Segmentation__c segmentation : segmentations) {
            Decimal imgLvlOrVolPotTotalAnsWeight = (Decimal) segmentation.get(DEPENDENT_FIELD_BY_FIELD_TO_UPDATE.get(fieldToUpdate));
            EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria = this.retrieveSegAspectCriteria(
                imgLvlOrVolPotTotalAnsWeight, segAspectCriteriasByGroupOutletTypeId.get(segmentation.EUR_CRM_PRS_Group_Outlet_Type__c));
            if (segAspectCriteria == null) { continue; }

            EUR_CRM_PRS_Segmentation__c updatedSegmentation = this.updateSegmentationFields(segmentation, segAspectCriteria);
            if (updatedSegmentation == null) { continue; }

            segmentationsToUpdate.add(updatedSegmentation);
        }
        return segmentationsToUpdate;
    }


    /*==========================================
   *   Low Level Helpers
   * ==========================================*/
    private EUR_CRM_PRS_Seg_Aspect_Criteria__c retrieveSegAspectCriteria(Decimal weight, List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> segAspectCriterias){
        Decimal tempWeight = 0;
        EUR_CRM_PRS_Seg_Aspect_Criteria__c tempSegAspectCriteria = null;
        for(EUR_CRM_PRS_Seg_Aspect_Criteria__c segAspectCriteria : segAspectCriterias){
            if(weight >= segAspectCriteria.EUR_CRM_Minimum_Weight__c && tempWeight<= segAspectCriteria.EUR_CRM_Minimum_Weight__c) {
                tempWeight= segAspectCriteria.EUR_CRM_Minimum_Weight__c;
                tempSegAspectCriteria = segAspectCriteria;
            }
        }
        return tempSegAspectCriteria;
    }

    private EUR_CRM_PRS_Segmentation__c updateSegmentationFields(EUR_CRM_PRS_Segmentation__c segm, EUR_CRM_PRS_Seg_Aspect_Criteria__c segmAspCriteria) {
        String dependentField = DEPENDENT_FIELD_BY_FIELD_TO_UPDATE.get(fieldToUpdate);
        if (dependentField.equalsIgnoreCase(IMAGE_LEVEL_TOTAL_ANSW_WGT_FIELD_NAME)) {
            segm.EUR_CRM_Image_Level_Criteria__c = segmAspCriteria.Id;
            segm.EUR_CRM_Image_Level__c = segmAspCriteria.EUR_CRM_Image_Level__c;
        } else if (dependentField.equalsIgnoreCase(VOLUME_POTENTIAL_TOTAL_ANSW_WGT_FIELD_NAME)) {
            segm.EUR_CRM_Volume_Potential_Criteria__c = segmAspCriteria.Id;
            segm.EUR_CRM_Volume_Potential__c = segmAspCriteria.EUR_CRM_Volume_Potential__c;
        } else { return null; }

        return segm;
    }


    /*==========================================
    *   SOQL Selectors
    * ==========================================*/
    private List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> selectSegAspectCriteriasWhereGroupOutletTypeIds(Set<Id> groupOutletTypeIds) {
        return [
            SELECT Id
                , EUR_CRM_PRS_Group_Outlet_Type__c
                , EUR_CRM_Image_Level__c
                , EUR_CRM_Volume_Potential__c
                , EUR_CRM_Minimum_Weight__c
                , EUR_CRM_Is_Weight_Changed__c
            FROM EUR_CRM_PRS_Seg_Aspect_Criteria__c
            WHERE EUR_CRM_PRS_Group_Outlet_Type__c IN :groupOutletTypeIds
            AND RecordType.DeveloperName LIKE :this.segAspCriteriaRTnamePart
        ];
    }

}