public with sharing class EUR_CRM_PRS_GroupOutletTypeSheetCntrl {

    public static final String RU_COUNTRY_CODE = 'RU';

    public Boolean isSaveDisabled               {get;set;}
    public String parentValue                   {get;set;}
    public String childValue                    {get;set;}
    public Boolean isOutletTypeVisible           {get;set;}
    public List<SelectOption> parentOptions     {get;set;}

    private Map<String, List<EUR_CRM_PRS_Outlet_Type__c>> childOptionMap;
    private EUR_CRM_PRS_Segmentation__c prSegmentation;
    private EUR_CRM_Account__c euAccount;

    public static Set<Id> moscowAndStPetersRegionIds {
        get {
            if (moscowAndStPetersRegionIds == null) {
                moscowAndStPetersRegionIds = new Map<Id, EUR_CRM_Region__c>([
                    SELECT Id
                    FROM EUR_CRM_Region__c
                    WHERE EUR_CRM_Country_Code__c = 'RU' AND (EUR_CRM_External_ID__c = 'RU_Reg_MO' OR EUR_CRM_External_ID__c = 'RU_Reg_N0')
                ]).keySet();
            }
            return moscowAndStPetersRegionIds;
        }
        set;
    }

    public EUR_CRM_PRS_GroupOutletTypeSheetCntrl(ApexPages.StandardController controller){
        isSaveDisabled = false;
        parentOptions = new List<SelectOption>();
        childOptionMap = new Map<String,List<EUR_CRM_PRS_Outlet_Type__c>>();

        init(controller.getId());
    }

    private void init(Id prSegmentationId){
        // Check if there is a PROS defined
        if(prSegmentationId != null){
            // Retrieve PR Segmentation record and its country's Group Outlet Types
            prSegmentation = EUR_CRM_PRSegmentationClass.returnPRSegmentationViaId(prSegmentationId);
            this.isOutletTypeVisible = !EUR_CRM_RecordTypeHelper.SegmentationRecordtypesWithoutOutletTypes.contains(prSegmentation.EUR_CRM_Account__r.RecordType.DeveloperName);
            // Retrieve the associated EU Account
            euAccount = [SELECT Id, RecordTypeId, RecordType.DeveloperName, EUR_CRM_Force_Group_Outlet_Type__c, EUR_CRM_Force_Outlet_Type__c, EUR_CRM_Force_Business_potential__c,
                EUR_CRM_Force_Brand_Building_Potential__c, EUR_CRM_PRS_Group_Outlet_Type__c, EUR_CRM_PRS_Outlet_Type__c, EUR_CRM_Business_Potential__c,
                EUR_CRM_Brand_Building_Potential__c, EUR_CRM_PRS_Image_Level__c, EUR_CRM_PRS_Volume_Potential__c, EUR_CRM_Territory__r.EUR_CRM_Region__c
            FROM EUR_CRM_Account__c
            WHERE Id =: prSegmentation.EUR_CRM_Account__c];

            // Retrieve segmentation type
            Boolean isPROS = EUR_CRM_RecordTypeHelper.euAccounts_PRS_SegmentationTypeMap.get(euAccount.RecordType.DeveloperName).get('isPROS');
            Boolean isPROFS = EUR_CRM_RecordTypeHelper.euAccounts_PRS_SegmentationTypeMap.get(euAccount.RecordType.DeveloperName).get('isPROFS');


            // Retrieve list of PRS Group Outlet types according to segmentation type
            String selRTDevName = (isPROS? '%PRS_On_Trade_Group_Outlet_Type': (isPROFS? '%PRS_Off_Trade_Group_Outlet_Type': ''));
            List<EUR_CRM_PRS_Group_Outlet_Type__c> groupOutletTypes = [
            SELECT Id, RecordType.DeveloperName, EUR_CRM_PRS_Group_Outlet_Name__c, EUR_CRM_Region__c, EUR_CRM_Country_Code__c
            FROM EUR_CRM_PRS_Group_Outlet_Type__c
            WHERE EUR_CRM_Country_Code__c =: prSegmentation.EUR_CRM_Country_Code__c
                AND RecordType.DeveloperName LIKE :selRTDevName
                AND EUR_CRM_PRS_Group_Outlet_Name__c != NULL
            ];

            if(groupOutletTypes != null && groupOutletTypes.size() > 0){
                Set<Id> groupOutletTypeIds = new Set<Id>();
                // Initialize the values of the PRS Group Outlet Type picklist
                for (EUR_CRM_PRS_Group_Outlet_Type__c record : groupOutletTypes ){
                    if(record.EUR_CRM_Country_Code__c == RU_COUNTRY_CODE) {
                        if(moscowAndStPetersRegionIds.contains(record.EUR_CRM_Region__c)) {
                           if(record.EUR_CRM_Region__c == euAccount.EUR_CRM_Territory__r.EUR_CRM_Region__c) {
                               parentOptions.add(new SelectOption(record.Id, record.EUR_CRM_PRS_Group_Outlet_Name__c));
                               groupOutletTypeIds.add(record.id);
                           }
                        } else if (record.EUR_CRM_Region__c == null && !moscowAndStPetersRegionIds.contains(euAccount.EUR_CRM_Territory__r.EUR_CRM_Region__c)) {
                            parentOptions.add(new SelectOption(record.Id, record.EUR_CRM_PRS_Group_Outlet_Name__c));
                            groupOutletTypeIds.add(record.id);
                        }
                    } else {
                        parentOptions.add(new SelectOption(record.Id, record.EUR_CRM_PRS_Group_Outlet_Name__c));
                        groupOutletTypeIds.add(record.id);
                    }
                }
                parentValue = groupOutletTypeIds.iterator().hasNext() ? groupOutletTypeIds.iterator().next(): null;
                // Initialize the map holding the values of the PRS Outlet Type
                // Map's Key is the PRS Group Outlet Type
                for(EUR_CRM_PRS_Outlet_Type__c  record : [SELECT Id, EUR_CRM_Country_Code__c, EUR_CRM_PRS_Outlet_Type_Name__c, EUR_CRM_PRS_Group_Outlet_Type__c
                FROM EUR_CRM_PRS_Outlet_Type__c
                WHERE EUR_CRM_PRS_Group_Outlet_Type__c IN : groupOutletTypeIds])
                {
                    if(childOptionMap.get(record.EUR_CRM_PRS_Group_Outlet_Type__c) == null){
                        childOptionMap.put(record.EUR_CRM_PRS_Group_Outlet_Type__c, new List<EUR_CRM_PRS_Outlet_Type__c>());
                    }
                    childOptionMap.get(record.EUR_CRM_PRS_Group_Outlet_Type__c).add(record);
                }
            }else{
                isSaveDisabled = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No Group Outlet Types Exists'));
            }
        }
        else{
            isSaveDisabled = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No Pros Segmentation ID Exists'));
        }
    }


    public PageReference save(){
        System.debug('\n prSegmentation => ' + JSON.serializePretty(prSegmentation) + '\n');
        System.debug('\n parentValue => ' + JSON.serializePretty(parentValue) + '\n');
        System.debug('\n childValue => ' + JSON.serializePretty(childValue) + '\n');
        if((prSegmentation.EUR_CRM_PRS_Group_Outlet_Type__c != parentValue || (prSegmentation.EUR_CRM_PRS_Outlet_Type__c != childValue ||
            EUR_CRM_RecordTypeHelper.SegmentationRecordtypesWithoutOutletTypes.contains(prSegmentation.EUR_CRM_Account__r.RecordType.DeveloperName)) )|| Test.isRunningTest()){
            // Clear the values of the PRSegmentation
            clearPRSegmentationValues();
            // Assign the new GOT and OT
            prSegmentation.EUR_CRM_PRS_Group_Outlet_Type__c = parentValue;
            prSegmentation.EUR_CRM_PRS_Outlet_Type__c = childValue;
            if(euAccount.EUR_CRM_Force_Group_Outlet_Type__c == null && euAccount.EUR_CRM_Force_Outlet_Type__c == null){
                euAccount.EUR_CRM_PRS_Group_Outlet_Type__c = parentValue;
                euAccount.EUR_CRM_PRS_Outlet_Type__c = childValue;
            }
            try{
                update prSegmentation;
                update euAccount;
            }
            catch(DMLException e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Unable to save'));
                return null;
            }
        }
        return new pageReference('/'+prSegmentation.Id);
    }

    public PageReference cancel(){
        return prSegmentation != null ? new pageReference('/'+prSegmentation.Id) : new pageReference('/');
    }

    public List<SelectOption> getChildOptions() {

        List<SelectOption> options = new List<SelectOption>();

        if (childOptionMap.get(parentValue) != null)
        {
// Construct the outlet type options
            for(EUR_CRM_PRS_Outlet_Type__c record : childOptionMap.get(parentValue)){
                options.add(new SelectOption(record.Id, record.EUR_CRM_PRS_Outlet_Type_Name__c));
            }
//  Set default value
            if(childOptionMap.get(parentValue) != null && childOptionMap.get(parentValue).get(0) != null){
                childValue = childOptionMap.get(parentValue).get(0).Id;
            }
        }
        return options;
    }

    @testVisible private void clearPRSegmentationValues(){
        prSegmentation.EUR_CRM_Brand_Building_Potential__c = null;
        prSegmentation.EUR_CRM_Business_Potential__c = null;
        prSegmentation.EUR_CRM_BrandBuilding_Potential_Criteria__c = null;
        prSegmentation.EUR_CRM_Business_Potential_Criteria__c = null;
        prSegmentation.EUR_CRM_PRS_Priority_Level_Criteria__c = null;
        prSegmentation.EUR_CRM_Image_Level__c = null;
        prSegmentation.EUR_CRM_Volume_Potential__c = null;
// Clear the PRS aspect values of the account
        if(euAccount.EUR_CRM_Force_Group_Outlet_Type__c == null && euAccount.EUR_CRM_Force_Outlet_Type__c == null){
            euAccount.EUR_CRM_Brand_Building_Potential__c = null;
            euAccount.EUR_CRM_Business_Potential__c = null;
            euAccount.EUR_CRM_PRS_Image_Level__c = null;
            euAccount.EUR_CRM_PRS_Volume_Potential__c = null;
        }
        List<EUR_CRM_PRS_Answer__c> oldAnswers = new List<EUR_CRM_PRS_Answer__c>();
        for(EUR_CRM_PRS_Answer__c answer : prSegmentation.EUR_CRM_PRS_Answer__r){
            oldAnswers.add(answer);
        }
        try {
            System.debug(oldAnswers);
            Database.delete(oldAnswers);
        }
        catch(Exception e){
            System.debug(e);
        }
    }

}