public with sharing class EUR_CRM_PRSegmentationClass {

    /*
        Returns the PRSegmentation record
        Queries all needed fields
    */
    public static EUR_CRM_PRS_Segmentation__c returnPRSegmentationViaId(Id prSegmentationId) {
        if (prSegmentationId != null) {
            EUR_CRM_PRS_Segmentation__c prSegmentation = [
                    SELECT Id, RecordTypeId, RecordType.DeveloperName,
                            EUR_CRM_Account__c, EUR_CRM_Account__r.RecordTypeId, EUR_CRM_Account__r.RecordType.DeveloperName,
                            EUR_CRM_Brand_Building_Potential__c,
                            EUR_CRM_Brand_Building_Potential__r.RecordTypeId,
                            EUR_CRM_BrandBuilding_Potential_Criteria__c,
                            EUR_CRM_Business_Potential__c,
                            EUR_CRM_Business_Potential__r.RecordTypeId,
                            EUR_CRM_Business_Potential_Criteria__c,
                            EUR_CRM_Image_Level__c,
                            EUR_CRM_Image_Level_Criteria__c,
                            EUR_CRM_Volume_Potential__c,
                            EUR_CRM_Volume_Potential_Criteria__c,
                            EUR_CRM_Country_Code__c,
                            EUR_CRM_PRS_Group_Outlet_Type__c,
                            EUR_CRM_PRS_Outlet_Type__c,
                            EUR_CRM_PRS_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Type_Name__c, EUR_CRM_PRS_Outlet_Type__r.EUR_CRM_PRS_Outlet_Type_Name__c,
                            EUR_CRM_Brand_Building_Potential__r.EUR_CRM_Segmentation_BBP_Aspect_Name__c,
                            EUR_CRM_Business_Potential__r.EUR_CRM_Segmentation_BP_Aspect_Name__c,
                            EUR_CRM_Image_Level__r.EUR_CRM_Segmentation_IL_Aspect_Name__c,
                            EUR_CRM_Image_Level__r.RecordTypeId,
                            EUR_CRM_Volume_Potential__r.EUR_CRM_Segmentation_VP_Aspect_Name__c,
                            EUR_CRM_Volume_Potential__r.RecordTypeId,
                            EUR_CRM_PRS_Priority_Level_Criteria__c,
                            EUR_CRM_PRS_Priority_Level_Criteria__r.EUR_CRM_Priority_Level__c,
                            EUR_CRM_PRS_Priority_Level_Criteria__r.EUR_CRM_Brand_Building_Potential__c,
                            EUR_CRM_PRS_Priority_Level_Criteria__r.EUR_CRM_Business_Potential__c, (
                            SELECT Id, EUR_CRM_Answer__c, EUR_CRM_Weight__c, RecordTypeId, RecordType.DeveloperName,
                                    EUR_CRM_PRS_Question__c, EUR_CRM_PRS_Question__r.EUR_CRM_Question_Statement__c
                            FROM EUR_CRM_PRS_Answer__r
                    )
                    FROM EUR_CRM_PRS_Segmentation__c
                    WHERE Id = :prSegmentationId
            ];
            System.debug('PR Segmentation via ID:' + prSegmentation);
            return prSegmentation;
        }

        return null;
    }

    /*
        Returns the PRS Group Outlet Type record
        Queries all needed fields
    */
    public static EUR_CRM_PRS_Group_Outlet_Type__c returnPRSGroupOutletTypeViaId(Id prsGroupOutletTypeId) {
        if (prsGroupOutletTypeId != null) {
            EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType = [
                    SELECT Id, RecordTypeId, RecordType.DeveloperName,
                            EUR_CRM_Country_Code__c,
                            EUR_CRM_External_ID__c,
                            EUR_CRM_Name__c,
                            EUR_CRM_Group_Outlet_Type_Name__c,
                            EUR_CRM_BrandBuildPotQuestionSet__c,
                            EUR_CRM_BusinessPotentialQuestionSet__c,
                            EUR_CRM_Image_Level_Question_Set__c,
                            EUR_CRM_Volume_Potential_Question_Set__c,
                            EUR_CRM_BrandBuildPotQuestionSet__r.EUR_CRM_Total_Weight_of_All_Questions__c,
                            EUR_CRM_BusinessPotentialQuestionSet__r.EUR_CRM_Total_Weight_of_All_Questions__c,
                            EUR_CRM_Image_Level_Question_Set__r.EUR_CRM_Total_Weight_of_All_Questions__c,
                            EUR_CRM_Volume_Potential_Question_Set__r.EUR_CRM_Total_Weight_of_All_Questions__c
                    FROM EUR_CRM_PRS_Group_Outlet_Type__c
                    WHERE Id = :prsGroupOutletTypeId
            ];
            System.debug('PRS Group Outlet Type: ' + prsGroupOutletType);
            return prsGroupOutletType;
        }

        return null;
    }

    /*
        Returns the values of the Brand Building Potential Name picklist values
    */
    public static List<String> returnBrandBuildingPotentialLabels() {
        List<String> bbpLabels = new List<String>();

        Schema.DescribeFieldResult fieldResult = EUR_CRM_PRS_Seg_Aspect__c.EUR_CRM_Segmentation_BBP_Aspect_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        for (Schema.PicklistEntry potential : fieldResult.getPicklistValues()) {
            bbpLabels.add(potential.getValue());
        }

        System.debug('bbpLabels : ' + bbpLabels);
        return bbpLabels;
    }

    /*
        Returns the values of the Business Potential Name picklist values
    */
    public static List<String> returnBusinessPotentialLabels() {
        List<String> bpLabels = new List<String>();

        Schema.DescribeFieldResult fieldResult = EUR_CRM_PRS_Seg_Aspect__c.EUR_CRM_Segmentation_BP_Aspect_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        for (Schema.PicklistEntry potential : fieldResult.getPicklistValues()) {
            bpLabels.add(potential.getValue());
        }

        System.debug('bpLabels : ' + bpLabels);
        return bpLabels;
    }

    /*
        Returns the values of the Image Level Name picklist values
    */
    public static List<String> returnImageLevelLabels() {
        List<String> imageLevelLabels = new List<String>();

        Schema.DescribeFieldResult fieldResult = EUR_CRM_PRS_Seg_Aspect__c.EUR_CRM_Segmentation_IL_Aspect_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        for (Schema.PicklistEntry potential : fieldResult.getPicklistValues()) {
            imageLevelLabels.add(potential.getValue());
        }

        System.debug('imageLevelLabels : ' + imageLevelLabels);
        return imageLevelLabels;
    }

    public static List<String> returnPicklistValuesDependOnRTidAndFieldName(Id segAspectRTid, String fieldName) {
        String endPoint = System.URL.getSalesforceBaseUrl().toExternalForm() +
            '/services/data/v41.0/ui-api/object-info/EUR_CRM_PRS_Seg_Aspect__c/picklist-values/' + segAspectRTid + '/' + fieldName;
        List<String> picklistValues = new List<String>();
        try {
            picklistValues = returnPicklistValuesViaREST(endPoint);
        } catch(Exception e) {
            if (fieldName.equalsIgnoreCase('EUR_CRM_Segmentation_IL_Aspect_Name__c')) {
                return returnImageLevelLabels();
            }
            if (fieldName.equalsIgnoreCase('EUR_CRM_Segmentation_VP_Aspect_Name__c')) {
                return returnVolumePotentialLabels();
            }
            if (fieldName.equalsIgnoreCase('EUR_CRM_Segmentation_BP_Aspect_Name__c')) {
                return returnBusinessPotentialLabels();
            }
            if (fieldName.equalsIgnoreCase('EUR_CRM_Segmentation_BBP_Aspect_Name__c')) {
                return returnBrandBuildingPotentialLabels();
            }
        }
        return picklistValues;
    }

    private static List<String> returnPicklistValuesViaREST(String endPoint) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response;
        request.setEndpoint(endPoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

        response = http.send(request);
        List<String> picklistLabels = new List<String>();

        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> picklistValues = (List<Object>) results.get('values');
            for (Object p : picklistValues) {
                picklistLabels.add((String)((Map<String, Object>) p).get('value'));
            }
        }
        return picklistLabels;
    }

    /*
        Returns the values of the Volume Potential Name picklist values
    */
    public static List<String> returnVolumePotentialLabels() {
        List<String> volumePotentialLabels = new List<String>();

        Schema.DescribeFieldResult fieldResult = EUR_CRM_PRS_Seg_Aspect__c.EUR_CRM_Segmentation_VP_Aspect_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        for (Schema.PicklistEntry potential : fieldResult.getPicklistValues()) {
            volumePotentialLabels.add(potential.getValue());
        }

        System.debug('volumePotentialLabels : ' + volumePotentialLabels);
        return volumePotentialLabels;
    }


    /*
        Returns the Brand Building Potentials by country
    */
    public static List<EUR_CRM_PRS_Seg_Aspect__c> returnBrandBuildingPotentialByCountry(Set<String> countryCodes) {
        return (List<EUR_CRM_PRS_Seg_Aspect__c>) [
                SELECT Id, EUR_CRM_Segmentation_BBP_Aspect_Name__c, EUR_CRM_Country_Code__c, RecordType.DeveloperName
                FROM EUR_CRM_PRS_Seg_Aspect__c
                WHERE EUR_CRM_Country_Code__c IN :countryCodes
                AND recordType.DeveloperName LIKE '%PRS_Segmentation_Aspect_BBP'
        ];
    }


    /*
        Returns the Business Potentials by country
    */
    public static List<EUR_CRM_PRS_Seg_Aspect__c> returnBusinessPotentialsByCountry(Set<String> countryCodes) {
        return (List<EUR_CRM_PRS_Seg_Aspect__c>) [
                SELECT Id, EUR_CRM_Segmentation_BP_Aspect_Name__c, EUR_CRM_Country_Code__c, RecordType.DeveloperName
                FROM EUR_CRM_PRS_Seg_Aspect__c
                WHERE EUR_CRM_Country_Code__c IN :countryCodes
                AND recordType.DeveloperName LIKE '%PRS_Segmentation_Aspect_BP'
        ];
    }


    /*
        Returns the Image Levels by country
    */
    public static List<EUR_CRM_PRS_Seg_Aspect__c> returnImageLevelsByCountry(Set<String> countryCodes) {
        return (List<EUR_CRM_PRS_Seg_Aspect__c>) [
                SELECT Id, EUR_CRM_Segmentation_IL_Aspect_Name__c, EUR_CRM_Country_Code__c, RecordType.DeveloperName
                FROM EUR_CRM_PRS_Seg_Aspect__c
                WHERE EUR_CRM_Country_Code__c IN :countryCodes
                AND recordType.DeveloperName LIKE '%PRS_Segmentation_Aspect_Image_Level'
        ];
    }


    /*
        Returns the Volume Potentials by country
    */
    public static List<EUR_CRM_PRS_Seg_Aspect__c> returnVolumePotentialsByCountry(Set<String> countryCodes) {
        return (List<EUR_CRM_PRS_Seg_Aspect__c>) [
                SELECT Id, EUR_CRM_Segmentation_VP_Aspect_Name__c, EUR_CRM_Country_Code__c, RecordType.DeveloperName
                FROM EUR_CRM_PRS_Seg_Aspect__c
                WHERE EUR_CRM_Country_Code__c IN :countryCodes
                AND recordType.DeveloperName LIKE '%PRS_Segmentation_Aspect_Volume_Potential'
        ];
    }


    /*
        Returns the PRS Group Outlet Types by country
    */
    public static List<EUR_CRM_PRS_Group_Outlet_Type__c> returnGroupOutletTypeByCountry(Set<String> countryCodes) {
        return (List<EUR_CRM_PRS_Group_Outlet_Type__c>) [
                SELECT Id, EUR_CRM_Group_Outlet_Type_Name__c, EUR_CRM_Country_Code__c
                FROM EUR_CRM_PRS_Group_Outlet_Type__c
                WHERE EUR_CRM_Country_Code__c IN :countryCodes
        ];
    }

    /*
        Returns the PRS Outlet Types by country code
    */
    public static List<EUR_CRM_PRS_Outlet_Type__c> returnOutletTypeByCountry(Set<String> countryCodes) {
        return (List<EUR_CRM_PRS_Outlet_Type__c>) [
                SELECT Id, EUR_CRM_PRS_Outlet_Type_Name__c, EUR_CRM_Country_Code__c
                FROM EUR_CRM_PRS_Outlet_Type__c
                WHERE EUR_CRM_Country_Code__c IN :countryCodes
        ];
    }


    /*
        Returns the Potential Map for the PROFS Segmentation
    */
    public static Map<String, Boolean> returnPROFSPotentialMatrix(EUR_CRM_PRS_Segmentation__c prSegmentation, List<String> bbpLabels, List<String> bpLabels) {
        Map<String, Boolean> potentialMap = new Map<String, Boolean>();

//        List<String> bbpLabels = returnbrandBuildingPotentialLabels();
//        List<String> bpLabels = returnbusinessPotentialLabels();

        for (String bbp : bbpLabels) {
            for (String bp : bpLabels) {
                if (bbp.equalsIgnoreCase(prSegmentation.EUR_CRM_Brand_Building_Potential__r.EUR_CRM_Segmentation_BBP_Aspect_Name__c) &&
                        bp.equalsIgnoreCase(prSegmentation.EUR_CRM_Business_Potential__r.EUR_CRM_Segmentation_BP_Aspect_Name__c)) {
                    potentialMap.put(bbp + bp, true);
                } else {
                    potentialMap.put(bbp + bp, false);
                }
            }
        }

        system.debug('Potential Map: ' + potentialMap);
        return potentialMap;
    }


    /*
        Returns the Potential Map for the PROS Segmentation
    */
    public static Map<String, Boolean> returnPROSPotentialMatrix(EUR_CRM_PRS_Segmentation__c prSegmentation, List<String> ilLabels, List<String> vpLabels) {
        Map<String, Boolean> potentialMap = new Map<String, Boolean>();

//        List<String> ilLabels = returnImageLevelLabels(prSegmentation.EUR_CRM_Image_Level__r.RecordTypeId);
//        List<String> vpLabels = returnVolumePotentialLabels();

        for (String il : ilLabels) {
            for (String vp : vpLabels) {
                if (il.equalsIgnoreCase(prSegmentation.EUR_CRM_Image_Level__r.EUR_CRM_Segmentation_IL_Aspect_Name__c) &&
                        vp.equalsIgnoreCase(prSegmentation.EUR_CRM_Volume_Potential__r.EUR_CRM_Segmentation_VP_Aspect_Name__c)) {
                    potentialMap.put(il + vp, true);
                } else {
                    potentialMap.put(il + vp, false);
                }
            }
        }

        system.debug('Potential Map: ' + potentialMap);
        return potentialMap;
    }

    /*
        Returns the Potential Map for the EU Account PROFS Segmentation
    */
    public static Map<String, Boolean> returnEUAccountPROFSPotentialMatrix(EUR_CRM_Account__c euAccount, List<String> bbpLabels, List<String> bpLabels) {
        Map<String, Boolean> potentialMap = new Map<String, Boolean>();

//        List<String> bbpLabels = returnbrandBuildingPotentialLabels();
//        List<String> bpLabels = returnbusinessPotentialLabels();

        system.debug('BBP Value: ' + euAccount.EUR_CRM_Brand_Building_Potential__r.EUR_CRM_Segmentation_BBP_Aspect_Name__c + '|' + euAccount.EUR_CRM_Brand_Building_Potential__c);
        system.debug('BP Value: ' + euAccount.EUR_CRM_Business_Potential__r.EUR_CRM_Segmentation_BP_Aspect_Name__c + '|' + euAccount.EUR_CRM_Business_Potential__c);

        for (String bbp : bbpLabels) {
            for (String bp : bpLabels) {
                if (bbp.equalsIgnoreCase(euAccount.EUR_CRM_Brand_Building_Potential__r.EUR_CRM_Segmentation_BBP_Aspect_Name__c) &&
                        bp.equalsIgnoreCase(euAccount.EUR_CRM_Business_Potential__r.EUR_CRM_Segmentation_BP_Aspect_Name__c)) {
                    potentialMap.put(bbp + bp, true);
                } else {
                    potentialMap.put(bbp + bp, false);
                }
            }
        }

        system.debug('EU Account Potential Map: ' + potentialMap);
        return potentialMap;
    }

    /*
        Returns the Potential Map for the EU Account PROS Segmentation
    */
    public static Map<String, Boolean> returnEUAccountPROSPotentialMatrix(EUR_CRM_Account__c euAccount, List<String> ilLabels, List<String> vpLabels) {
        Map<String, Boolean> potentialMap = new Map<String, Boolean>();

//        List<String> ilLabels = returnImageLevelLabels();
//        List<String> vpLabels = returnVolumePotentialLabels();

        for (String il : ilLabels) {
            for (String vp : vpLabels) {
                if (il.equalsIgnoreCase(euAccount.EUR_CRM_PRS_Image_Level__r.EUR_CRM_Segmentation_IL_Aspect_Name__c) &&
                        vp.equalsIgnoreCase(euAccount.EUR_CRM_PRS_Volume_Potential__r.EUR_CRM_Segmentation_VP_Aspect_Name__c)) {
                    potentialMap.put(il + vp, true);
                } else {
                    potentialMap.put(il + vp, false);
                }
            }
        }

        system.debug('EU Account Potential Map: ' + potentialMap);
        return potentialMap;
    }

    /*
        Returns the Questions and possible answers related to a specific PRS group outlet type
        and matching the specified recordtype 

        Params: EUR_CRM_PRS_Question_Set__c Id
    */
    public static List<EUR_CRM_PRS_Question__c> returnPRSQuestionsAndPossibleAnswersList(Id questionSetId) {
        if (questionSetId != null) {
            List<EUR_CRM_PRS_Question__c> prsQuestionsList = [
                    SELECT Id, RecordTypeId, RecordType.DeveloperName,
                            EUR_CRM_Country_Code__c,
                            EUR_CRM_External_ID__c,
                            EUR_CRM_Weight_Has_Changed__c,
                            EUR_CRM_PRS_Question_Set__c,
                            EUR_CRM_Question_Statement__c,
                            EUR_CRM_Question_Sequence__c,
                            EUR_CRM_Question_Weight__c, (
                            SELECT Id, RecordTypeId, RecordType.DeveloperName,
                                    EUR_CRM_Answer_Condition__c,
                                    EUR_CRM_Answer_Statement__c,
                                    EUR_CRM_Country_Code__c,
                                    EUR_CRM_Criteria_Threshold_Currency__c,
                                    EUR_CRM_Criteria_Picklist_Label__c,
                                    EUR_CRM_Criteria_Threshold_Number__c,
                                    EUR_CRM_Criteria_Picklist_Value__c,
                                    EUR_CRM_PRS_Question__c,
                                    EUR_CRM_Criteria_Weight__c
                            FROM EUR_CRM_PRS_Question_Criteria__r
                            ORDER BY EUR_CRM_Criteria_Threshold_Currency__c desc,
                                    EUR_CRM_Criteria_Threshold_Number__c desc,
                                    EUR_CRM_Criteria_Picklist_Label__c
                    )
                    FROM EUR_CRM_PRS_Question__c
                    WHERE EUR_CRM_PRS_Question_Set__c = :questionSetId
                    ORDER BY EUR_CRM_Question_Sequence__c, CreatedDate
            ];
            System.debug('PRS Questions: ' + prsQuestionsList);
            return prsQuestionsList;
        }

        return null;
    }

    /************************************************************************************************************************
    *   returnBrandBuildingPotentialFinalResultsCriteria
    *   returns a list of Brand Building Potential Final Result Criteria 
    *   @param:
    *           groupOutletType [String] : PRS Group Outlet Type Id
    *           countryCode [String] : country code of PRS Group Outlet Type
    *   @returns:
    *            finalResultsCriteria [List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>] : List of SOQLed Final Result Criteria
    *************************************************************************************************************************/
    public static List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> returnBrandBuildingPotentialFinalResultsCriteria(String groupOutletType, String countryCode) {
        if (!(String.isBlank(groupOutletType) && String.isBlank(countryCode))) {
            String developerName = 'EUR_PRS_Segmentation_Aspect_Criteria_BBP';
            List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> finalResultsCriteria = [
                    SELECT EUR_CRM_Brand_Building_Potential__c, EUR_CRM_Business_Potential__c,
                            EUR_CRM_Minimum_Weight__c, EUR_CRM_PRS_Group_Outlet_Type__c, EUR_CRM_Country_Code__c
                    FROM EUR_CRM_PRS_Seg_Aspect_Criteria__c
                    WHERE EUR_CRM_PRS_Group_Outlet_Type__c = :groupOutletType
                    AND EUR_CRM_Country_Code__c = :countryCode
                    AND RecordType.DeveloperName = :developerName
                    ORDER BY EUR_CRM_Minimum_Weight__c
            ];
            System.debug('PRS Final Result Criteria: ' + finalResultsCriteria);
            return finalResultsCriteria;
        }

        return null;
    }

    /************************************************************************************************************************
    *   returnBusinessPotentialFinalResultsCriteria
    *   returns a list of Business Potential Final Result Criteria 
    *   @param:
    *           groupOutletType [String] : PRS Group Outlet Type Id
    *           countryCode [String] : country code of PRS Group Outlet Type
    *   @returns:
    *            finalResultsCriteria [List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>] : List of SOQLed Final Result Criteria
    *************************************************************************************************************************/
    public static List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> returnBusinessPotentialFinalResultsCriteria(String groupOutletType, String countryCode) {
        if (!(String.isBlank(groupOutletType) && String.isBlank(countryCode))) {
            String developerName = 'EUR_PRS_Segmentation_Aspect_Criteria_BP';
            List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> finalResultsCriteria = [
                    SELECT EUR_CRM_Brand_Building_Potential__c, EUR_CRM_Business_Potential__c,
                            EUR_CRM_Minimum_Weight__c, EUR_CRM_PRS_Group_Outlet_Type__c, EUR_CRM_Country_Code__c
                    FROM EUR_CRM_PRS_Seg_Aspect_Criteria__c
                    WHERE EUR_CRM_PRS_Group_Outlet_Type__c = :groupOutletType
//                    WHERE EUR_CRM_PRS_Group_Outlet_Type__r.Name = :groupOutletType
                    AND EUR_CRM_Country_Code__c = :countryCode
                    AND RecordType.DeveloperName = :developerName
                    ORDER BY EUR_CRM_Minimum_Weight__c
            ];
            System.debug('PRS Final Result Criteria: ' + finalResultsCriteria);
            return finalResultsCriteria;
        }

        return null;
    }

    /************************************************************************************************************************
    *   returnImageLevelFinalResultsCriteria
    *   returns a list of Volume Level Final Result Criteria 
    *   @param:
    *           groupOutletType [String] : PRS Group Outlet Type Id
    *           countryCode [String] : country code of PRS Group Outlet Type
    *   @returns:
    *            finalResultsCriteria [List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>] : List of SOQLed Final Result Criteria
    *************************************************************************************************************************/
    public static List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> returnImageLevelFinalResultsCriteria(String groupOutletType, String countryCode) {
        if (!(String.isBlank(groupOutletType) && String.isBlank(countryCode))) {
            String developerName = 'EUR_PRS_Segmentation_Aspect_Criteria_Image_Level';
            List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> finalResultsCriteria = [
                    SELECT EUR_CRM_Image_Level__c, EUR_CRM_Volume_Potential__c,
                            EUR_CRM_Minimum_Weight__c, EUR_CRM_PRS_Group_Outlet_Type__c, EUR_CRM_Country_Code__c
                    FROM EUR_CRM_PRS_Seg_Aspect_Criteria__c
//                    WHERE EUR_CRM_PRS_Group_Outlet_Type__r.Name = :groupOutletType
                    WHERE EUR_CRM_PRS_Group_Outlet_Type__c = :groupOutletType
                    AND EUR_CRM_Country_Code__c = :countryCode
                    AND RecordType.DeveloperName = :developerName
                    ORDER BY EUR_CRM_Minimum_Weight__c
            ];
            System.debug('PRS Final Result Criteria: ' + finalResultsCriteria);
            return finalResultsCriteria;
        }

        return null;
    }

    /************************************************************************************************************************
    *   returnVolumePotentialFinalResultsCriteria
    *   returns a list of Volume Potential Final Result Criteria 
    *   @param:
    *           groupOutletType [String] : PRS Group Outlet Type Id
    *           countryCode [String] : country code of PRS Group Outlet Type
    *   @returns:
    *            finalResultsCriteria [List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>] : List of SOQLed Final Result Criteria
    *************************************************************************************************************************/
    public static List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> returnVolumePotentialFinalResultsCriteria(String groupOutletType, String countryCode) {
        if (!(String.isBlank(groupOutletType) && String.isBlank(countryCode))) {
            String developerName = 'EUR_PRS_Segmentation_Aspect_Criteria_Volume_Potential';
            List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> finalResultsCriteria = [
                    SELECT EUR_CRM_Image_Level__c, EUR_CRM_Volume_Potential__c,
                            EUR_CRM_Minimum_Weight__c, EUR_CRM_PRS_Group_Outlet_Type__c, EUR_CRM_Country_Code__c
                    FROM EUR_CRM_PRS_Seg_Aspect_Criteria__c
//                    WHERE EUR_CRM_PRS_Group_Outlet_Type__r.Name = :groupOutletType
                    WHERE EUR_CRM_PRS_Group_Outlet_Type__c = :groupOutletType
                    AND EUR_CRM_Country_Code__c = :countryCode
                    AND RecordType.DeveloperName = :developerName
                    ORDER BY EUR_CRM_Minimum_Weight__c
            ];
            System.debug('PRS Final Result Criteria: ' + finalResultsCriteria);
            return finalResultsCriteria;
        }

        return null;
    }

    /************************************************************************************************************************
    *   returnPriorityLevelMatrices
    *   returns a list of PRS Priority Level Matrix 
    *   @param:
    *           countryCode [String] : The country code of the affiliate
    *   @returns:
    *            priorityLevelMatrices [List<EUR_CRM_PRS_Priority_Level_Criteria__c>] : List of SOQLed Priority Level Matrices
    *************************************************************************************************************************/
    public static List<EUR_CRM_PRS_Priority_Level_Criteria__c> returnPriorityLevelMatrices(String countryCode) {
        if (!String.isBlank(countryCode)) {
            List<EUR_CRM_PRS_Priority_Level_Criteria__c> priorityLevelMatrices = [
                    SELECT EUR_CRM_Brand_Building_Potential__c, EUR_CRM_Business_Potential__c,
                            EUR_CRM_Brand_Building_Potential_Name__c, EUR_CRM_Business_Potential_Name__c,
                            EUR_CRM_Country_Code__c, EUR_CRM_Priority_Level__c
                    FROM EUR_CRM_PRS_Priority_Level_Criteria__c
                    WHERE EUR_CRM_Country_Code__c = :countryCode
            ];
            System.debug('PRS Priority Level Criteria: ' + priorityLevelMatrices);
            return priorityLevelMatrices;
        }

        return null;
    }

}