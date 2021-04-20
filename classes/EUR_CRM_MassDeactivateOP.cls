/**
Batchable class to turn all OP that meet the Active End Date status to Under Evaluation or Ended.
Trigger another batch job for OPAccMapping after finish.
Active => Under Evaluation
Under Evaluation => Ended
*/
global class EUR_CRM_MassDeactivateOP implements Database.Batchable<sObject>{
 
	global static List<String> validRecordType = New List<String>{'EUR_BE_Off_Trade_Sales_Drive',
												'EUR_BE_Off_Trade_Secondary_placement_Spyder_display',
												'EUR_BE_On_Trade_Display_Placement_For_Special_Cavist',
												'EUR_BE_On_Trade_Promo_Kit_Activation'}; 

    global static List<String> disableByTargetDone = New List<String>{'EUR_BE_On_Trade_Promo_Kit_Activation'} ;

	//RecordType + Status => Target Status
	global static Map<String,String> OPStatusChange = New Map<String,String>{
		'EUR_BE_Off_Trade_Sales_Drive:Active'=>'Ended',
		'EUR_BE_Off_Trade_Secondary_placement_Spyder_display:Active'=>'Under Evaluation',
		'EUR_BE_Off_Trade_Secondary_placement_Spyder_display:Under Evaluation'=>'Ended',
		'EUR_BE_On_Trade_Display_Placement_For_Special_Cavist:Active'=>'Ended',
		'EUR_BE_On_Trade_Promo_Kit_Activation:Active'=>'Ended'};

    String query = 	'SELECT id,Name,EUR_CRM_Active_End_Date__c,EUR_CRM_Status__c,EUR_CRM_Evaluation_Period_End_Date__c,RecordType.DeveloperName ' + 
    				'FROM EUR_CRM_ObjPromo__c ' + 
					'WHERE (((EUR_CRM_Active_End_Date__c <= TODAY AND EUR_CRM_Status__c = \'Active\') or ' + 
					'(EUR_CRM_Evaluation_Period_End_Date__c <= TODAY AND EUR_CRM_Status__c = \'Under Evaluation\')) ' + 
					' AND (RecordType.DeveloperName In : validRecordType )) or' +
                    '(EUR_CRM_Status__c = \'Active\' AND RecordType.DeveloperName In : disableByTargetDone)';
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        System.Debug('>>>EUR_CRM_MassDeactivateOP:execute');
        deactivate((List<EUR_CRM_ObjPromo__c>) scope);
    }
   
    global void finish(Database.BatchableContext BC){
    	//EUR_CRM_BE_MassDeactivateOPAccMapping
        System.Debug('>>>EUR_CRM_MassDeactivateOP:finish');
    	EUR_CRM_BE_MassDeactivateOPAccMapping  batchJob = new EUR_CRM_BE_MassDeactivateOPAccMapping();
    	Id batchId = Database.executeBatch(batchJob,200);
    }
    
    public static void deactivate(List<EUR_CRM_ObjPromo__c> scope){

        Date TodaysDate = Datetime.now().date();

        System.Debug('>>>EUR_CRM_MassDeactivateOP:' + TodaysDate);
        
        List<EUR_CRM_ObjPromo__c> ArchivedPromoKitOP = New List<EUR_CRM_ObjPromo__c>();
        for(EUR_CRM_ObjPromo__c OP: scope){
            String Status = OPStatusChange.get(OP.RecordType.DeveloperName + ':' + OP.EUR_CRM_Status__c);
            If(Status != null && (OP.EUR_CRM_Active_End_Date__c == TodaysDate || OP.EUR_CRM_Evaluation_Period_End_Date__c == TodaysDate)){
            	System.Debug('>>>Target Status:' + Status);
            	System.Debug('>>>UE End Date:' + OP.EUR_CRM_Evaluation_Period_End_Date__c);

                //Second handling for Under Evaluation Ended is the same day
            	If(Status == 'Under Evaluation'){
            		Boolean CP = OP.EUR_CRM_Evaluation_Period_End_Date__c <= System.Today();
            		System.Debug('>>>UE End Date CP(' + System.Today() + '):' + CP);
            		If(OP.EUR_CRM_Evaluation_Period_End_Date__c <= System.Today())
            		{
            			Status = 'Ended';
            		}
            	}
            	OP.EUR_CRM_Status__c = Status;
            }

            
            Set<Id> PromoKitId = New Set<Id>();
            Map<Id,List<EUR_CRM_ObjPromo_Target__c>> OPTargetMap = New Map<Id, List<EUR_CRM_ObjPromo_Target__c>>();


            If(OP.RecordType.DeveloperName == 'EUR_BE_On_Trade_Promo_Kit_Activation'){
                PromoKitId.add(OP.Id);
            }

            for(EUR_CRM_ObjPromo_Target__c OPTarget : [SELECT Id,EUR_CRM_Achieved__c,EUR_CRM_ObjPromo__c FROM EUR_CRM_ObjPromo_Target__c Where EUR_CRM_ObjPromo__c in : PromoKitId]){
                If(!OPTargetMap.containsKey(OPTarget.EUR_CRM_ObjPromo__c)){
                    OPTargetMap.put(OPTarget.EUR_CRM_ObjPromo__c, New List<EUR_CRM_ObjPromo_Target__c>());
                }
                OPTargetMap.get(OPTarget.EUR_CRM_ObjPromo__c).add(OPTarget);
            }
            System.Debug('OPTargetMap:' + OPTargetMap);

            for(Id OPId : OPTargetMap.KeySet()){
                Boolean Archived = True;
                for(EUR_CRM_ObjPromo_Target__c OPTarget : OPTargetMap.get(OPId)){
                    If(OPTarget.EUR_CRM_Achieved__c == False){
                        Archived = False;
                    }
                }
                if(Archived){
                    ArchivedPromoKitOP.add(New EUR_CRM_ObjPromo__c(Id = OPId,EUR_CRM_Status__c = 'Ended'));
                }
            }

        } 
        update scope;
        System.Debug(scope);
        If(ArchivedPromoKitOP.size() > 0){
            System.Debug('ArchivedPromoKitOP:' + ArchivedPromoKitOP);
            update ArchivedPromoKitOP;

        }
    }

}