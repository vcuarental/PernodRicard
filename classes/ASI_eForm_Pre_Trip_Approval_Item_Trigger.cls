public with sharing class ASI_eForm_Pre_Trip_Approval_Item_Trigger {

    public static void lowestDate(List<ASI_eForm_Pre_Trip_Approval_Item__c> preTripItemList)
    {
        Set<ID> preTripSet = new Set<ID>();
        
        for (ASI_eForm_Pre_Trip_Approval_Item__c preTripItems : preTripItemList)
            preTripSet.add(preTripItems.ASI_eForm_Pre_Trip_Approval__c);
        
        if (preTripSet.size() > 0)
        {
            List<ASI_eForm_Pre_Trip_Approval__c> preTripToUpdateList = new List<ASI_eForm_Pre_Trip_Approval__c>();
            
            List<ASI_eForm_Pre_Trip_Approval__c> preTripList = [SELECT ID, Name, ASI_eForm_Travel_Begin_Date__c, ASI_eForm_Status__c,
                                                                    (SELECT ID, Name, ASI_eForm_Date__c, ASI_eForm_ETD__c, ASI_eForm_ETA__c, ASI_eForm_Return_Date__c,
                                                                    ASI_eForm_Booking_Status__c 
                                                                    FROM Pre_Trip_Approval_Items__r 
                                                                    Order by ASI_eForm_ETD__c ASC NULLS LAST)
                                                                FROM ASI_eForm_Pre_Trip_Approval__c
                                                                WHERE ID IN : preTripSet];
            
            for (ASI_eForm_Pre_Trip_Approval__c preTrip : preTripList)
            {
                boolean needUpdate = false;
                Set<String> bookingStatus = new Set<String>();
                Datetime lowestDate = null;
                for (ASI_eForm_Pre_Trip_Approval_Item__c preTripItem : preTrip.Pre_Trip_Approval_Items__r)
                {
                    lowestDate = preTripItem.ASI_eForm_ETD__c;
                    break;
                }
                
                List<DateTime> tempDateTimeETA = new List<DateTime>();
                for (ASI_eForm_Pre_Trip_Approval_Item__c preTripItem : preTrip.Pre_Trip_Approval_Items__r)
                {
                    tempDateTimeETA.add(preTripItem.ASI_eForm_ETA__c);
                    tempDateTimeETA.add(preTripItem.ASI_eForm_Return_Date__c);
                    bookingStatus.add(preTripItem.ASI_eForm_Booking_Status__c);
                }
                
                if(bookingStatus.size() == 1 && preTrip.ASI_eForm_Status__c == 'Final')
                {
                    if (bookingStatus.contains('Cancelled'))
                    {
                        preTrip.ASI_eForm_Status__c = 'Cancelled';
                        needUpdate = true;
                    }
                }
                
                if(tempDateTimeETA.size() > 0)
                {
                    tempDateTimeETA.sort();
                    DateTime latestETA = tempDateTimeETA.get(tempDateTimeETA.size()-1);
                    preTrip.ASI_eForm_Travel_Return_Time__c = latestETA;
                    needUpdate = true;
                }
                
                if (preTrip.ASI_eForm_Travel_Begin_Date__c != lowestDate)
                {
                    preTrip.ASI_eForm_Travel_Begin_Date__c = lowestDate;
                    needUpdate = true;
                }
                if (needUpdate)
                    preTripToUpdateList.add(preTrip);
            }
            if (preTripToUpdateList.size() > 0)
                update preTripToUpdateList;
        }
        
    }

}