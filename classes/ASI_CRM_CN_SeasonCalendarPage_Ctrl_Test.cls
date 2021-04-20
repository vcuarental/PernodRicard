/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_SeasonCalendarPage_Ctrl_Test
 * Description:
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 24/7/2019		Wilson Chow				Created
 ****************************************************************************************************************************/

@isTest
public with sharing class ASI_CRM_CN_SeasonCalendarPage_Ctrl_Test {

    private static final String START_DATE = '2019-07-01';
    private static final String END_DATE = '2019-07-31';

    @testSetup
    static void setup() {
        List<String> regionList = grepRegionList(ASI_CRM_CN_SeasonCalendarPage_Ctrl.getRegionPicklist());
        ASI_CRM_CN_SeasonCalendarPage_Ctrl.saveSeasonData(START_DATE, END_DATE, System.JSON.serialize(regionList));
    }

    @isTest
    static void testGetStatusPicklist() {
        ASI_CRM_CN_SeasonCalendarPage_Ctrl.getStatusPicklist();
    }

    @isTest
    static void testSaveSeasonDataEmptyStartDate() {
        try {
            List<String> regionList = grepRegionList(ASI_CRM_CN_SeasonCalendarPage_Ctrl.getRegionPicklist());
            ASI_CRM_CN_SeasonCalendarPage_Ctrl.saveSeasonData(null, END_DATE, System.JSON.serialize(regionList));
        }
        catch(Exception e) {

        }
    }

    @isTest
    static void testSaveSeasonDataEmptyEndDate() {
        try {
            List<String> regionList = grepRegionList(ASI_CRM_CN_SeasonCalendarPage_Ctrl.getRegionPicklist());
            ASI_CRM_CN_SeasonCalendarPage_Ctrl.saveSeasonData(START_DATE, null, System.JSON.serialize(regionList));
        }
        catch(Exception e) {

        }
    }

    @isTest
    static void testSaveSeasonDataEmptyRegion() {
        try {
            ASI_CRM_CN_SeasonCalendarPage_Ctrl.saveSeasonData(START_DATE, END_DATE, null);
        }
        catch(Exception e) {

        }
    }

    @isTest
    static void testSaveSeasonDataOverlap() {
        try {
            List<String> regionList = grepRegionList(ASI_CRM_CN_SeasonCalendarPage_Ctrl.getRegionPicklist());
            ASI_CRM_CN_SeasonCalendarPage_Ctrl.saveSeasonData(START_DATE, END_DATE, System.JSON.serialize(regionList));
        }
        catch(Exception e) {

        }
    }

    @isTest
    static void testGetEventData() {
        List<String> regionList = grepRegionList(ASI_CRM_CN_SeasonCalendarPage_Ctrl.getRegionPicklist());
        ASI_CRM_CN_SeasonCalendarPage_Ctrl.getEventData(START_DATE, END_DATE, System.JSON.serialize(regionList), 'Active');
    }

    @isTest
    static void testGetEventDataEmptyRegion() {
        ASI_CRM_CN_SeasonCalendarPage_Ctrl.getEventData(START_DATE, END_DATE, null, 'Active');
    }

    @isTest
    static void testDeleteSeasonData() {
        List<String> regionList = grepRegionList(ASI_CRM_CN_SeasonCalendarPage_Ctrl.getRegionPicklist());
        ASI_CRM_CN_SeasonCalendarPage_Ctrl.deleteSeasonData(START_DATE, END_DATE, System.JSON.serialize(regionList), 'Active');
    }

    private static List<String> grepRegionList(List<String> regionList) {
        for (Integer i = 0; i < regionList.size(); i++) {
            if (regionList.get(i) == 'All'){
                regionList.remove(i);
                i--;
            }
        }

        return regionList;
    }
}