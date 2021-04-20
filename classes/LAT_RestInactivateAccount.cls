@RestResource(urlMapping='/LAT_RestInactivateAccount/*')
global with sharing class LAT_RestInactivateAccount  {


    @HttpPost
    global static RestResponse sendAccountInactivation(Id accountId, String inactivationNote, String reason) {
        
        // Create a savepoint to revert if something goes wrong
        Savepoint sp = Database.setSavepoint();
        LAT_BR_InactivateBtnController.InactivateResponse resp;
        try {
            Account accToApprove  = [SELECT Rating, Status__c, Notes_1__c,OwnerId,Reason_for_Inactivation__c from account where Id = :accountId LIMIT 1];
            

            accToApprove.Reason_for_Inactivation__c = reason;
            accToApprove.Notes_1__c = inactivationNote;
            

            update accToApprove;
            resp = LAT_BR_InactivateBtnController.validateAccInactivation(accToApprove);
        } catch (Exception e) {
            Database.rollback(sp);
            resp = new LAT_BR_InactivateBtnController.InactivateResponse(e.getMessage(), LAT_BR_InactivateBtnController.STATUS_INTERNAL_ERROR);
        }

        // if an error occurs rollback the update
        if (resp == null || resp.status == LAT_BR_InactivateBtnController.STATUS_ERROR || resp.status == LAT_BR_InactivateBtnController.STATUS_INTERNAL_ERROR){
            Database.rollback(sp);
            if (resp == null){
                resp = new LAT_BR_InactivateBtnController.InactivateResponse('An Error has occured(empty answer)', LAT_BR_InactivateBtnController.STATUS_INTERNAL_ERROR);
            }
        }
        return new RestResponse(resp);
    }

    /**
     * wrapper class to handle responses
     * TODO: Move to it's own class and use in all ws
     */
    global class RestResponse {
        public boolean success{get; set;}
        public String message{get;set;}


        /**
         *
         */
        public RestResponse(boolean success, String message){
            this.success = success;
            this.message = message; 
        }

        /**
         * Convert inactivate resp to generic Rest response
         */
        public RestResponse(LAT_BR_InactivateBtnController.InactivateResponse inactiveResp){
            this.success = (inactiveResp.status != LAT_BR_InactivateBtnController.STATUS_INTERNAL_ERROR &&
                inactiveResp.status != LAT_BR_InactivateBtnController.STATUS_ERROR);
            this.message = inactiveResp.msg;
        }
    }

}