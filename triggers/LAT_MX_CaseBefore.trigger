/*******************************************************************************************
*        Company:Valuenet      Developers:Elena Schwarzböck        Date:07/10/2013         *
********************************************************************************************/

trigger LAT_MX_CaseBefore on Case (before insert) {
	String i = '';
/*
    //Filtrado de RecordTypes
    LAT_Trigger trigger_MX = new LAT_Trigger('Case', new set<String>{'LAT_MX_CSE_AccountAlterationStatistical','LAT_MX_CSE_AccountAlterationCreditAndCollections','LAT_MX_CSE_AccountAlterationLegal','LAT_MX_CSE_AccountAlterationLogistics','LAT_MX_CSE_CaseClosed'});
    
    //Ejecucion de metodos especificos para MX
    if(!trigger_MX.getNew().IsEmpty()){
        LAT_MX_AP01_Case.UpdatesCaseFields((List<Case>)trigger_MX.getNew());
        LAT_MX_AP01_Case.UpdateAccountOwnerAndManagerOwner((List<Case>)trigger_MX.getNew());
    }
*/
}