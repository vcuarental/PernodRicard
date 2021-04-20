trigger LAT_Price_Channel_ARG on LAT_Price_Channel_ARG__c (before insert, after insert, after update) {
    if(Trigger.IsBefore) {
        if(Trigger.IsInsert){
            LAT_Price_Channel_ARG_Controller.validateOnlyOneChannelIsActive(Trigger.new);
        }
    } else if(Trigger.IsAfter) {
        LAT_Price_Channel_ARG_Controller.updateAN8Patron(Trigger.new, Trigger.oldMap);
    }
}