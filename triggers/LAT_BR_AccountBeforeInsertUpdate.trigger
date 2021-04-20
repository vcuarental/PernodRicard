trigger LAT_BR_AccountBeforeInsertUpdate on Account (before insert, before update) {

	//Filtrado de RecordTypes de Brasil
    LAT_Trigger trigger_BR = new LAT_Trigger('Account', new set<String>{'On_Trade', 'Off_Trade', 'Eventos'});
    
    //Llamadas a metodos unicos para BR
    if(!trigger_BR.getNew().isEmpty()){
    	LAT_BR_AP01_AccountWOS.completeAgencyAccount(trigger_BR.getNew());
    }
}