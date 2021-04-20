public class ASI_MFM_KR_PRLine_TriggerClass
{
    public static void beforeUpdateMethod(List<ASI_MFM_Purchase_Request_Line__c> triggerNew)
    {
        Set<Id> lineId = new Set<Id>();
        for(ASI_MFM_Purchase_Request_Line__c obj: triggerNew)
        {
            lineId.add(obj.Id);
        }//end for
        
        List<Attachment> attList = new List<Attachment>([SELECT Id, parentId FROM Attachment WHERE parentId IN: lineId]);
        Map<Id, Integer> attMap = new Map<Id, Integer>();
        for(Attachment att: attList)
        {
            if(!attMap.containsKey(att.parentId))
                attMap.put(att.parentId, 1);
            else
                attMap.put(att.parentId, attMap.get(att.parentId) + 1);
        }//end for
        
        for(ASI_MFM_Purchase_Request_Line__c obj: triggerNew)
        {
            if(attMap.containsKey(obj.Id))
            {
                obj.ASI_MFM_KR_countAttach__c = attMap.get(obj.Id);
            }//end if
            if(obj.ASI_MFM_KR_countAttach__c == null)
            {
                obj.ASI_MFM_KR_countAttach__c = 0;
            }//end if
        }//end for
    }//end method: beforeUpdateMethod
}//end class