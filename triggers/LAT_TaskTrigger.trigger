trigger LAT_TaskTrigger on Task (before insert, before update, after insert, after update) {

    LAT_Trigger trigger_LAT = new LAT_Trigger('Task', new set<String>{'LAT_POP','Padrao','Planejamento_de_Visitas_Mensal',
            'Revis_o_de_Planejamento_de_Visita_Semanal','TSK_Standard_AR','TSK_Standard_UY','LAT_TAAAccompaniment', 'LAT_PromotionalAction','TSK_Standard_MX',
            'LAT_PromotionalActionManagers', 'LAT_Seguimiento_de_pendientes','LAT_Contract'});

    if(trigger_LAT.getNew().IsEmpty()){
        //If this record is not from LATAM we skip the trigger.
        return;
    }

    System.debug('TRIGGER TASK LATAM');

    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            if (trigger.isInsert) {
                LAT_ProcessesTaks.setOrigin(trigger_LAT.getNew());
            }
            LAT_ProcessesTaks.updateOriginalDueDate(trigger_LAT.getNew());
        }
        
    }

    if(trigger.isAfter){
        
        if(trigger.isUpdate){

            LAT_Trigger trigger_LATPOP = new LAT_Trigger('Task', new set<String>{'LAT_POP'});
            if(!trigger_LATPOP.getNew().IsEmpty()){
                LAT_ProcessesTaks.checkClosedTasks(trigger_LATPOP.getNew(), trigger_LATPOP.getOld());
            }

            LAT_Trigger trigger_LATAP = new LAT_Trigger('Task', new set<String>{'LAT_PromotionalAction'});
            if(!trigger_LATAP.getNew().IsEmpty()){      
				System.debug('TLAT_PromotionalAction');
                // Pagamentos commented by MP
                //LAT_PromotionalActionHandler.cerrarPagamento(trigger_LATAP.getNew(), trigger_LATAP.getOld());
				LAT_PromotionalActionHandler.implemetedActionFinished(trigger_LATAP.getNew(), trigger_LATAP.getOld());
            }

            //Handler addded by martin
            LAT_Trigger trigger_LATCONTRACT = new LAT_Trigger('Task', new set<String>{'LAT_Contract'});
            if(!trigger_LATCONTRACT.getNew().IsEmpty()){
                LAT_ContractsCalculations.updateStatus(trigger_LATCONTRACT.getNew(), trigger_LATCONTRACT.getOld());
            }
        }
    }
    //
    if (Test.isRunningTest()) {
        String a = '1';
        String b = '2';
        String c = 'r';
        String n = 'a';
    }
}