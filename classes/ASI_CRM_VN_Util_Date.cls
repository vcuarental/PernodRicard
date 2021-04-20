/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_Util_Date
 * Description: Apex class for ASI_CRM_VN_Util_Date
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-08       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_VN_Util_Date {
    public static String getDayOfWeek(Date d){
        return DateTime.newInstance(d.year(), d.month(), d.day()).format('EEEEE');
    }

    public static Boolean isWeekend(Date d){
        String dayOfWeek = getDayOfWeek(d);
        return dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday';
    }

    public static Boolean isHoliday(Date d, List<ASI_CRM_Holiday__c> holidays){
        for (ASI_CRM_Holiday__c holiday : holidays) {
            if (d >= holiday.ASI_CRM_Date_From__c && d <= holiday.ASI_CRM_Date_To__c) {
                return true;
            }
        }

        return false;
    }

    public static Integer getNumOfWorkingDays(Date startDate, Date endDate, List<ASI_CRM_Holiday__c> holidays){
        Integer workingDays = 0;
        Date currentDate = startDate;
        while (currentDate <= endDate){
            // No one works on Saturday and Sunday
            if (isWeekend(currentDate)) {
                currentDate = currentDate.addDays(1);
                continue;
            }
            // No one works on Christmas
            if (isHoliday(currentDate, holidays)) {
                currentDate = currentDate.addDays(1);
                continue;
            }

            workingDays++;

            currentDate = currentDate.addDays(1);
        }
        return workingDays;
    }

    public static Date getVisitationPlanStartDate(ASI_HK_CRM_Visitation_Plan__c visitationPlan){
        String period = visitationPlan.ASI_CRM_VN_Period__c;
        Date originalStartDate = visitationPlan.ASI_CRM_TH_Month_Start_Date__c;

        if (period == null || period == 'First Half') {
            return originalStartDate;
        }

        if (period == 'Second Half') {
            return Date.newInstance(originalStartDate.year(), originalStartDate.month(), 16);
        }

        return originalStartDate;
    }

    public static Date getVisitationPlanEndDate(ASI_HK_CRM_Visitation_Plan__c visitationPlan){
        String period = visitationPlan.ASI_CRM_VN_Period__c;
        Date originalEndDate = visitationPlan.ASI_CRM_TH_Month_End_Date__c;

        if (period == null || period == 'Second Half') {
            return originalEndDate;
        }

        if (period == 'First Half') {
            return Date.newInstance(originalEndDate.year(), originalEndDate.month(), 15);
        }

        return originalEndDate;
    }
}