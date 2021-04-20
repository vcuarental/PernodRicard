trigger EUR_CRM_ObjPromo_Trade_Fair_Participant_Trigger on EUR_CRM_ObjPromo_Trade_Fair_Participant__c (after Insert, before Delete) {
    if(Trigger.isInsert){
        EUR_CRM_OP_Participants_AccTeam_Handler.processObjPromoTradeFair_Insert(Trigger.new);
    }
    
    if(Trigger.isDelete){
        EUR_CRM_OP_Participants_AccTeam_Handler.processObjPromoTradeFair_Delete(Trigger.old);
    }
}