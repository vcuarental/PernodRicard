public with sharing class ASI_LUX_AutoNumber_Account_Assignment {

    public static void assignLuxLeCercleNumber(List<Account> AccList, string runningNumberName)
    {
        List<ASI_HK_CRM_Running_Number__c> runningNumberList = [SELECT ID, Name, ASI_HK_CRM_Fiscal_Year__c FROM ASI_HK_CRM_Running_Number__c WHERE ASI_HK_CRM_Object_Name__c = : runningNumberName];
        // Check if the fiscal year is empty. If yes, update the running number
        if (runningNumberList.size() > 0)
        {
            ASI_HK_CRM_Running_Number__c runningNumber = runningNumberList.get(0);
            if (runningNumber.ASI_HK_CRM_Fiscal_Year__c != date.today().year())
            {
                runningNumber.ASI_HK_CRM_Fiscal_Year__c = date.today().year();
                update runningNumber;
            }
                
        }
        ASI_HK_CRM_AutoNumberAssignment autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment(runningNumberName);
        for (Account Acc : AccList) 
        {
            Acc.ASI_LUX_Le_Cercle_Member_Number__c = autoNumAssign.nextAutoNumStr();
            Acc.ASI_LUX_LeCercle_Member_Since_Date__c = DateTime.now().date();
        }
        autoNumAssign.writeToDB();
    }

}