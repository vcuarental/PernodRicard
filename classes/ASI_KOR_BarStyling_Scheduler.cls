/***************************************************************************************************************************
* Name:        ASI_KOR_BarStyling_Scheduler
* Description: Schduler for ASI_KOR_POSM_Order_Request
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-12-19       Alan Lau                Created
****************************************************************************************************************************/

global class ASI_KOR_BarStyling_Scheduler implements Schedulable {

    global void execute(SchedulableContext ctx) {
        System.debug('Bar Styling Schedule Job START');
        setActualVolumeForNextSixMonthsFromInstallationCompletionDate();
        System.debug('Bar Styling Schedule Job END');
    }

    private void setActualVolumeForNextSixMonthsFromInstallationCompletionDate () { //TODO: try to make it shorter
        List<ASI_KOR_POSM_Order_Request__c> posmHeaderList = getPosmHeaderList();
        Map<Id, Id> mapOfVenueToSubBrand = getMapOfVenueToSubBrand(posmHeaderList);
        List<String> itemGroupIdList = getItemGroupIdList(mapOfVenueToSubBrand);
        List<ASI_KOR_Venue_Depletion_Detail__c> depletionDetailList = getDepletionDetailList(mapOfVenueToSubBrand, itemGroupIdList);

        for (ASI_KOR_POSM_Order_Request__c posmHeader : posmHeaderList) {
            posmHeader.ASI_KOR_Actual_Volume_M1__c = 0;
            posmHeader.ASI_KOR_Actual_Volume_M2__c = 0;
            posmHeader.ASI_KOR_Actual_Volume_M3__c = 0;
            posmHeader.ASI_KOR_Actual_Volume_M4__c = 0;
            posmHeader.ASI_KOR_Actual_Volume_M5__c = 0;
            posmHeader.ASI_KOR_Actual_Volume_M6__c = 0;
            for (ASI_KOR_Venue_Depletion_Detail__c depletionDetail : depletionDetailList) {
                if (posmHeader.ASI_KOR_POSM_TO_Venue__c == depletionDetail.ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c
                        && posmHeader.ASI_KOR_Sub_brand__c == depletionDetail.ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__c) {
                    Date installationCompletionDate = Date.newInstance(
                            posmHeader.ASI_KOR_Installation_Completion_Date__c.year(),
                            posmHeader.ASI_KOR_Installation_Completion_Date__c.month(),
                            1
                    );

                    Date depletionDate = Date.newInstance(
                            Integer.valueOf(depletionDetail.ASI_KOR_Venue_Depletion__r.ASI_KOR_Year__c),
                            ASI_KOR_CommonUtils.getMonthNumber(depletionDetail.ASI_KOR_Venue_Depletion__r.ASI_KOR_Month__c),
                            1
                    );

                    if (installationCompletionDate.isSameDay(depletionDate)) {
                        posmHeader.ASI_KOR_Actual_Volume_M1__c += getQuantityInBottleOrActualCase(posmHeader.ASI_KOR_UOM__c, depletionDetail);
                        continue;
                    } else if (installationCompletionDate.addMonths(1).isSameDay(depletionDate)) {
                        posmHeader.ASI_KOR_Actual_Volume_M2__c += getQuantityInBottleOrActualCase(posmHeader.ASI_KOR_UOM__c, depletionDetail);
                        continue;
                    } else if (installationCompletionDate.addMonths(2).isSameDay(depletionDate)) {
                        posmHeader.ASI_KOR_Actual_Volume_M3__c += getQuantityInBottleOrActualCase(posmHeader.ASI_KOR_UOM__c, depletionDetail);
                        continue;
                    } else if (installationCompletionDate.addMonths(3).isSameDay(depletionDate)) {
                        posmHeader.ASI_KOR_Actual_Volume_M4__c += getQuantityInBottleOrActualCase(posmHeader.ASI_KOR_UOM__c, depletionDetail);
                        continue;
                    } else if (installationCompletionDate.addMonths(4).isSameDay(depletionDate)) {
                        posmHeader.ASI_KOR_Actual_Volume_M5__c += getQuantityInBottleOrActualCase(posmHeader.ASI_KOR_UOM__c, depletionDetail);
                        continue;
                    } else if (installationCompletionDate.addMonths(5).isSameDay(depletionDate)) {
                        posmHeader.ASI_KOR_Actual_Volume_M6__c += getQuantityInBottleOrActualCase(posmHeader.ASI_KOR_UOM__c, depletionDetail);
                        continue;
                    }
                }
            }
        }

        update posmHeaderList;

    }

    private List<ASI_KOR_Venue_Depletion_Detail__c> getDepletionDetailList(Map<Id, Id> mapOfVenueToSubBrand, List<String> itemGroupIdList) {
        List<ASI_KOR_Venue_Depletion_Detail__c> depletionDetailList = [
                SELECT Id,
                        ASI_KOR_Item_Group_Code__c,
                        ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__c,
                        ASI_KOR_Venue_Depletion__r.ASI_KOR_Year__c,
                        ASI_KOR_Venue_Depletion__r.ASI_KOR_Month__c,
                        ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c,
                        ASI_KOR_Venue_Depl_Info_Depletion_Case__c,
                        ASI_KOR_Venue_Depl_Info_Depletion_Volume__c
                FROM ASI_KOR_Venue_Depletion_Detail__c
                WHERE ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c IN :mapOfVenueToSubBrand.keySet()
                AND ASI_KOR_Item_Group_Code__c IN :itemGroupIdList
                AND ASI_KOR_Venue_Depletion__r.ASI_KOR_Year__c != NULL
                AND ASI_KOR_Venue_Depletion__r.ASI_KOR_Month__c != NULL
        ];
        return depletionDetailList;
    }

    private List<ASI_KOR_POSM_Order_Request__c> getPosmHeaderList() {
        final List<String> recordTypeDeveloperNameList = new List<String>{
                'ASI_KOR_Locked_Bar_Styling_Item_Request', 'ASI_KOR_Finalized_Bar_Styling_Item_Request'
        };
        List<ASI_KOR_POSM_Order_Request__c> posmHeaderList = [
                SELECT Id,
                        ASI_KOR_POSM_TO_Venue__c,
                        ASI_KOR_Sub_brand__c,
                        ASI_KOR_UOM__c,
                        ASI_KOR_Installation_Completion_Date__c,
                        ASI_KOR_Actual_Volume_M1__c,
                        ASI_KOR_Actual_Volume_M2__c,
                        ASI_KOR_Actual_Volume_M3__c,
                        ASI_KOR_Actual_Volume_M4__c,
                        ASI_KOR_Actual_Volume_M5__c,
                        ASI_KOR_Actual_Volume_M6__c
                FROM ASI_KOR_POSM_Order_Request__c
                WHERE ASI_KOR_Installation_Completion_Date__c != NULL
                AND RecordType.DeveloperName IN :recordTypeDeveloperNameList
        ];
        return posmHeaderList;
    }

    private List<String> getItemGroupIdList(Map<Id, Id> mapOfVenueToSubBrand) {
        List<ASI_KOR_Item_Group__c> itemGroupList = [
                SELECT Id
                FROM ASI_KOR_Item_Group__c
                WHERE ASI_KOR_Sub_Brand__c IN :mapOfVenueToSubBrand.values()
        ];

        return ASI_KOR_CommonUtils.getStringFieldList(itemGroupList, 'Id');
    }

    private Map<Id, Id> getMapOfVenueToSubBrand(List<ASI_KOR_POSM_Order_Request__c> posmHeaderList) {
        Map<Id, Id> mapOfVenueToSubBrand = new Map<Id, Id>();

        for (ASI_KOR_POSM_Order_Request__c posmHeader : posmHeaderList) {
            mapOfVenueToSubBrand.put(posmHeader.ASI_KOR_POSM_TO_Venue__c, posmHeader.ASI_KOR_Sub_brand__c);
        }

        return mapOfVenueToSubBrand;
    }

    private Decimal getQuantityInBottleOrActualCase(String uom, ASI_KOR_Venue_Depletion_Detail__c venueDepletionDetail) {
        Decimal quantity = 0;

        if ('Actual Case' == uom && venueDepletionDetail.ASI_KOR_Venue_Depl_Info_Depletion_Case__c != null) {
            quantity = venueDepletionDetail.ASI_KOR_Venue_Depl_Info_Depletion_Case__c;
        } else if ('Bottle' == uom && venueDepletionDetail.ASI_KOR_Venue_Depl_Info_Depletion_Volume__c != null) {
            quantity = venueDepletionDetail.ASI_KOR_Venue_Depl_Info_Depletion_Volume__c;
        }

        return quantity;
    }

}