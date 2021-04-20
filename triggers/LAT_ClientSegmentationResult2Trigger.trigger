trigger LAT_ClientSegmentationResult2Trigger on LAT_BR_ClientChannelSegmentation2Result__c (
  before insert, 
  after insert,
  before update,
  after update) {



    if (Trigger.isBefore) {

        //call your handler.before method
        List<Account> AccountToUpdate = new List<Account>();
        //List<LAT_BR_ClientChannelSegmentation2Result__c> = new List<LAT_BR_ClientChannelSegmentation2Result__c>();
        system.debug('isBeforeUpdate++++');
      	for(LAT_BR_ClientChannelSegmentation2Result__c segm: trigger.new){
        	//if(!segm.TriggerRun__c){

          if(!segm.LAT_BR_Dont_Update_After_Owner__c){

            LAT_BR_SegmentationBehaviorHandler.fillObtainedUdc(trigger.new[0]);
            //} else {
            // MIGRATION CODE ONLY
            if(trigger.new.size() == 1 && Trigger.isInsert){

              if(segm.Client_Segmentation_2__c == null && String.isNotBlank(segm.CNPJ__c) ){
              //Create Dummy  segmentations
              LAT_BR_SegmentationBehaviorHandler.ProcessMigrationDataBefore(segm);
                  
              }
            }
          }else{
            segm.LAT_BR_Dont_Update_After_Owner__c = false;
          }
      	}
       
        LAT_BR_SegmentationBehaviorHandler.UpdateTBCILatAcc(trigger.new);
        //Create migration data
      
    } else if (Trigger.isAfter && Trigger.isUpdate) {
       
    } else if (Trigger.isAfter && Trigger.isInsert) {
       if(trigger.new.size() == 1){

              if(String.isNotBlank(trigger.new[0].CNPJ__c)){
              //Create Dummy  segmentations
                  LAT_BR_SegmentationBehaviorHandler.ProcessMigrationDataAfter(trigger.new[0]);
              
              }



            }
    }
}