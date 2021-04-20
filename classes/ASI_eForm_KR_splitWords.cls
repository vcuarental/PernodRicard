public class ASI_eForm_KR_splitWords
{
    public static void MDMsplitWords(list<ASI_eForm_HR_MDM__c> Trigger_New)
    {
        for(ASI_eForm_HR_MDM__c getDepartment : Trigger_New)
        {
            if(getDepartment.ASI_eForm_Employee_Branch_Code__c!=null)
            {
                string[] splitPickList = getDepartment.ASI_eForm_Employee_Branch_Code__c.split('-',2);
                getDepartment.ASI_eForm_MDM_Department__c=splitPickList[0];
            }//end if
            else
            {
                getDepartment.ASI_eForm_MDM_Department__c=null;
            }//end else
        }//end for
    }//end method
    
    public static void CCsplitWords(list<ASI_eForm_CC_Request__c> Trigger_New)
    {
        integer amount;
        for(ASI_eForm_CC_Request__c getAmount : Trigger_New)
        {
            if(getAmount.ASI_eForm_Leave_Sub_Type__c.contains(','))
            {
                String[] splitAll = getAmount.ASI_eForm_Leave_Sub_Type__c.split(',');
                String[] splitParts = splitAll[splitAll.size()-1].split('원');
                amount = Integer.valueOf(splitParts[0]);
                if(getAmount.ASI_eForm_Replacement__c!=null&&getAmount.ASI_eForm_Replacement__c.contains('원'))
                {
                    String[] splitReplacement = getAmount.ASI_eForm_Replacement__c.split('원');
                    amount += Integer.valueOf(splitReplacement[0]);
                }//end if
                getAmount.ASI_eForm_Amount__c=amount;
            }//end if
            else
            {
                getAmount.ASI_eForm_Amount__c=null;
            }//end else
        }//end for
    }//end method
}//end class