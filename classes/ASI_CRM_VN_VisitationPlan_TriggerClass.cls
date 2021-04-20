/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_VisitationPlan_TriggerClass
 * Description: Apex class for ASI_CRM_VN_VisitationPlan_TriggerClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-22       Jeffrey Cheung          Created before update logic
 ****************************************************************************************************************************/

public class ASI_CRM_VN_VisitationPlan_TriggerClass {
    public static void routineBeforeInsert(List<ASI_HK_CRM_Visitation_Plan__c> trigger_new) {
        Set<Id> set_owner = new Set<Id>();
        Map<String, Double> map_vp_setup = new Map<String, Double>();
        Map<Id, Double> map_new_vp = new Map<Id, Double>();
        for (ASI_HK_CRM_Visitation_Plan__c list_vp : trigger_new) {
            set_owner.add(list_vp.OwnerId);
        }
        List<User> list_user = [SELECT id, name, ASI_CRM_User_Group__c FROM User WHERE Id = :set_owner];
        List<ASI_CRM_Visitation_Plan_Setup__c> list_vp_setup = [SELECT id, name, ASI_CRM_VN_Sales_Target_Factor__c FROM ASI_CRM_Visitation_Plan_Setup__c WHERE recordtype.developername = 'ASI_CRM_VN_Visitation_Plan_Setup'];
        if (list_vp_setup.size() > 0) {
            for (ASI_CRM_Visitation_Plan_Setup__c idx_vp_setup : list_vp_setup) {
                map_vp_setup.put(idx_vp_setup.name, idx_vp_setup.ASI_CRM_VN_Sales_Target_Factor__c);
            }
            if (list_user.size() > 0) {
                for (User idx_user : list_user) {
                    map_new_vp.put(idx_user.id, map_vp_setup.get(idx_user.ASI_CRM_User_Group__c));
                }
            }
        }
        if (map_new_vp.size() > 0) {
            for (ASI_HK_CRM_Visitation_Plan__c list_vp1 : trigger_new) {
                list_vp1.ASI_CRM_VN_Sales_Target_Factor__c = map_new_vp.get(list_vp1.ownerid);
            }
        }

        // Set ASI_CRM_TH_No_of_Target__c
        List<ASI_CRM_Holiday__c> holidays = [
                SELECT Id, Name, ASI_CRM_Date_From__c, ASI_CRM_Date_To__c
                FROM ASI_CRM_Holiday__c
                WHERE RecordType.DeveloperName = 'ASI_CRM_VN_Holiday'
        ];
        for (ASI_HK_CRM_Visitation_Plan__c visitationPlan : trigger_new) {
            // should visit 8 outlet per day
            visitationPlan.ASI_CRM_TH_No_of_Target__c = 8 * ASI_CRM_VN_Util_Date.getNumOfWorkingDays(
                    ASI_CRM_VN_Util_Date.getVisitationPlanStartDate(visitationPlan),
                    ASI_CRM_VN_Util_Date.getVisitationPlanEndDate(visitationPlan),
                    holidays
            );
        }

    }


    public static void routineBeforeUpdate(List<ASI_HK_CRM_Visitation_Plan__c> routineAfterUpdate) {
        ASI_CRM_VN_Settings__c vnSetting = ASI_CRM_VN_Settings__c.getOrgDefaults();
        
        //        update ASI_CRM_Outlet_Visits_Generated__c
        List<Id> planIds = new List<Id>();
        List<Id> ownerIds = new List<Id>();
        for (ASI_HK_CRM_Visitation_Plan__c plan : routineAfterUpdate) {
            if(plan.ASI_HK_CRM_Confirmed__c == false && 
               plan.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan__c' + 'ASI_CRM_VN_Visitation_Plan_Submitted')) {
            	if(plan.ASI_HK_CRM_Visits_Generated__c / plan.ASI_CRM_TH_No_of_Target__c * 100 < vnSetting.ASI_CRM_VN_Visitation_Plan_Target__c) {
                	plan.addError('The generated visits should larger than or equal to ' + vnSetting.ASI_CRM_VN_Visitation_Plan_Target__c + '%');
                }
            }
            planIds.add(plan.Id);
            ownerIds.add(plan.OwnerId);
        }

//        Calculate ASI_CRM_Outlet_Visits_Generated__c
        //        Gonna use this for storing outlet count
        Map<Id, Integer> planIdToVisitOutletCount = new Map<Id, Integer>();
        List<ASI_HK_CRM_Visitation_Plan__c> plansWithDetails = [SELECT Id, (SELECT Id, ASI_CRM_MY_Customer__c FROM ASI_HK_CRM_Visitation_Plan_Details__r) FROM ASI_HK_CRM_Visitation_Plan__c WHERE Id IN :planIds];

        for (ASI_HK_CRM_Visitation_Plan__c planWithDetail : plansWithDetails) {
            //            use Set to remove duplicate values
            Set<Id> customerIds = new Set<Id>();
            for (ASI_HK_CRM_Visitation_Plan_Detail__c detail : planWithDetail.ASI_HK_CRM_Visitation_Plan_Details__r) {
                customerIds.add(detail.ASI_CRM_MY_Customer__c);
            }
            planIdToVisitOutletCount.put(planWithDetail.Id, customerIds.size());
        }
        //        End of ASI_CRM_Outlet_Visits_Generated__c

// Calculate ASI_CRM_Number_of_Outlet__c
        AggregateResult[] groupedResults = [
                SELECT OwnerId, COUNT(Id)
                FROM ASI_CRM_AccountsAdditionalField__c
                WHERE
                OwnerId IN :ownerIds AND
                RecordType.DeveloperName IN ('ASI_CRM_VN_Outlet', 'ASI_CRM_VN_Off_Trade_Outlet')
                GROUP BY OwnerId
        ];
        Map<Id, Integer> ownerIdToOutletCount = new Map<Id, Integer>();
        for (AggregateResult ar : groupedResults) {
            ownerIdToOutletCount.put( (Id)ar.get('OwnerId'), (Integer)ar.get('expr0'));
        }
        // End of ASI_CRM_Number_of_Outlet__c


        for (ASI_HK_CRM_Visitation_Plan__c plan : routineAfterUpdate) {
            plan.ASI_CRM_Outlet_Visits_Generated__c = planIdToVisitOutletCount.get(plan.Id);
            plan.ASI_CRM_Number_of_Outlet__c = ownerIdToOutletCount.get(plan.OwnerId) != null ? ownerIdToOutletCount.get(plan.OwnerId) : 0;
        }


    }
}