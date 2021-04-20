/*********************************************************************************
 * Name:ASI_BRD_Generic_AccDowngradeController
 * Description: Controller for Page ASI_BRD_Generic_AccDowngradePage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 4/5/2016         Laputa: Hank            Created
*********************************************************************************/
public without sharing class ASI_BRD_Generic_AccDowngradeController{
    public Account acc{get;set;}
    public ASI_BRD_Generic_AccDowngradeController(ApexPages.StandardController controller) {
        acc = (Account)controller.getRecord();
        acc =   [Select recordtypeId,
                        ASI_BRD_Acquired_By__pc,
                        ASI_BRD_Brands_Engaged__pc,
                        ASI_LUX_EDM_Opt_in_Email__pc,
                        ASI_LUX_Remarks__c,
                        ASI_BRD_Absolut_AllMkt_OptIn__pc,
                        ASI_BRD_Absolut_Engaged__pc,
                        ASI_BRD_Ballantines_AllMkt_OptIn__pc,
                        ASI_BRD_Ballantines_Engaged__pc,
                        ASI_BRD_GHMumm_AllMkt_OptIn__pc,
                        ASI_BRD_GHMumm_Engaged__pc,
                        ASI_BRD_Martell_AllMkt_OptIn__pc,
                        ASI_BRD_Martell_Engaged__pc,
                        ASI_BRD_OtherBrand1_AllMkt_OptIn__pc,
                        ASI_BRD_OtherBrand1_Engaged__pc,
                        ASI_BRD_OtherBrand3_Engaged__pc,
                        ASI_BRD_OtherBrand3_AllMkt_OptIn__pc,
                        ASI_BRD_OtherBrand2_AllMkt_OptIn__pc,
                        ASI_BRD_OtherBrand2_Engaged__pc,
                        ASI_BRD_PerrierJouet_AllMkt_OptIn__pc,
                        ASI_BRD_PerrierJouet_Engaged__pc,
                        ASI_BRD_RoyalSalute_AllMkt_OptIn__pc,
                        ASI_BRD_RoyalSalute_Engaged__pc,
                        ASI_BRD_TheGlenlivet_AllMkt_OptIn__pc,
                        ASI_BRD_TheGlenlivet_Engaged__pc,
                        ASI_LUX_Occasion_at_First_Meeting__c,
                        ASI_BRD_Sys_Target_Luxury_Account_RT__pc,
                        ASI_BRD_Name_of_OtherBrand1__pc,
                        ASI_BRD_Name_of_OtherBrand2__pc,
                        ASI_BRD_Name_of_OtherBrand3__pc,
                        ASI_LUX_Profile__c,
                        ASI_LUX_Preferred_Language_1__c,
                        ASI_BRD_Beefeater_Engaged__pc,
                        ASI_BRD_Chivas_Engaged__pc,
                        ASI_BRD_HavanaClub_Engaged__pc,
                        ASI_BRD_Jameson_Engaged__pc,
                        ASI_BRD_Kahlua_Engaged__pc,
                        ASI_BRD_Malibu_Engaged__pc,
                        ASI_BRD_Ricard_Engaged__pc,
                        ASI_BRD_Beefeater_AllMkt_OptIn__pc,
                        ASI_BRD_Chivas_AllMkt_OptIn__pc,
                        ASI_BRD_HavanaClub_AllMkt_OptIn__pc,
                        ASI_BRD_Jameson_AllMkt_OptIn__pc,
                        ASI_BRD_Kahlua_AllMkt_OptIn__pc,
                        ASI_BRD_Malibu_AllMkt_OptIn__pc,
                        ASI_BRD_Ricard_AllMkt_OptIn__pc
                From Account 
                Where Id = :acc.Id];
    }
    public PageReference cancelDowngrade(){
        PageReference accPage = new ApexPages.StandardController(acc).view();
        accPage.setRedirect(true);
        return accPage;
    }
    public PageReference confirmDowngrade(){
        if(acc.ASI_BRD_Acquired_By__pc == null){
            acc.ASI_BRD_Acquired_By__pc = '--- From Luxury ---';
        }
        if(acc.ASI_LUX_Remarks__c != null){
            acc.ASI_LUX_Remarks__c += '\nDegraded from a Luxury Account on ' + System.now().format('dd-MMM-yyyy');
        }else{
            acc.ASI_LUX_Remarks__c = 'Degraded from a Luxury Account on ' + System.now().format('dd-MMM-yyyy');
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('Absolut')){
            acc.ASI_BRD_Absolut_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_Absolut_Engaged__pc = null;
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('Ballantine')){
            acc.ASI_BRD_Ballantines_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_Ballantines_Engaged__pc = null;
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('Beefeater')){
            acc.ASI_BRD_Beefeater_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_Beefeater_Engaged__pc = null;
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('Chivas')){
            acc.ASI_BRD_Chivas_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_Chivas_Engaged__pc = null;
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('Mumm')){
            acc.ASI_BRD_GHMumm_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_GHMumm_Engaged__pc = null;
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('Havana Club')){
            acc.ASI_BRD_HavanaClub_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_HavanaClub_Engaged__pc = null;
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('Jameson')){
            acc.ASI_BRD_Jameson_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_Jameson_Engaged__pc = null;
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('Kahlua')){
            acc.ASI_BRD_Kahlua_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_Kahlua_Engaged__pc = null;
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('Malibu')){
            acc.ASI_BRD_Malibu_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_Malibu_Engaged__pc = null;
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('Martell')){
            acc.ASI_BRD_Martell_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_Martell_Engaged__pc = null;
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('Perrier-Jouet') || acc.ASI_BRD_Brands_Engaged__pc.contains('Perrier-Jouët')){
            acc.ASI_BRD_PerrierJouet_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_PerrierJouet_Engaged__pc = null;
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('Ricard')){
            acc.ASI_BRD_Ricard_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_Ricard_Engaged__pc = null;
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('Royal Salute')){
            acc.ASI_BRD_RoyalSalute_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_RoyalSalute_Engaged__pc = null;
        }
        if(acc.ASI_BRD_Brands_Engaged__pc.contains('The Glenlivet')){
            acc.ASI_BRD_TheGlenlivet_Engaged__pc = 'Yes';
        }else{
            acc.ASI_BRD_TheGlenlivet_Engaged__pc = null;
        }
        User u = [Select ASI_BRD_CRM_Market__c From User Where Id = :UserInfo.getUserId()];
        Map<String,ASI_BRD_Generic_CRM_Mapping__c> mktMap = ASI_BRD_Generic_CRM_Mapping__c.getAll();
        Map<String, ASI_BRD_Generic_CRM_Default_Values__c> valuesMap = ASI_BRD_Generic_CRM_Default_Values__c.getAll();
        if(u.ASI_BRD_CRM_Market__c !=null && mktMap.get(u.ASI_BRD_CRM_Market__c).ASI_BRD_Record_Type__c !=null){
            acc.recordtypeId = Global_RecordTypeCache.getRtId('Account' + mktMap.get(u.ASI_BRD_CRM_Market__c).ASI_BRD_Record_Type__c);
        }
        
        if(u.ASI_BRD_CRM_Market__c != null && mktMap.get(u.ASI_BRD_CRM_Market__c) != null && acc.recordtypeId == Global_RecordTypeCache.getRtId('Account' + mktMap.get(u.ASI_BRD_CRM_Market__c).ASI_BRD_Record_Type__c)){
            ASI_BRD_Generic_CRM_Default_Values__c values = valuesMap.get(u.ASI_BRD_CRM_Market__c);
            acc.ASI_BRD_Absolut_AllMkt_OptIn__pc = (acc.ASI_BRD_Absolut_AllMkt_OptIn__pc == null)?values.ASI_BRD_Absolut_AllMkt_OptIn__c:acc.ASI_BRD_Absolut_AllMkt_OptIn__pc;
            acc.ASI_BRD_Absolut_Engaged__pc = (acc.ASI_BRD_Absolut_Engaged__pc == null)?values.ASI_BRD_Absolut_Engaged__c:acc.ASI_BRD_Absolut_Engaged__pc;
            acc.ASI_BRD_Ballantines_AllMkt_OptIn__pc = (acc.ASI_BRD_Ballantines_AllMkt_OptIn__pc == null)?values.ASI_BRD_Ballantines_AllMkt_OptIn__c:acc.ASI_BRD_Ballantines_AllMkt_OptIn__pc;
            acc.ASI_BRD_Ballantines_Engaged__pc = (acc.ASI_BRD_Ballantines_Engaged__pc == null)?values.ASI_BRD_Ballantines_Engaged__c:acc.ASI_BRD_Ballantines_Engaged__pc;
            acc.ASI_BRD_GHMumm_AllMkt_OptIn__pc = (acc.ASI_BRD_GHMumm_AllMkt_OptIn__pc == null)?values.ASI_BRD_GHMumm_AllMkt_OptIn__c:acc.ASI_BRD_GHMumm_AllMkt_OptIn__pc;
            acc.ASI_BRD_GHMumm_Engaged__pc = (acc.ASI_BRD_GHMumm_Engaged__pc == null)?values.ASI_BRD_GHMumm_Engaged__c:acc.ASI_BRD_GHMumm_Engaged__pc;
            acc.ASI_BRD_Martell_AllMkt_OptIn__pc = (acc.ASI_BRD_Martell_AllMkt_OptIn__pc == null)?values.ASI_BRD_Martell_AllMkt_OptIn__c:acc.ASI_BRD_Martell_AllMkt_OptIn__pc;
            acc.ASI_BRD_Martell_Engaged__pc = (acc.ASI_BRD_Martell_Engaged__pc == null)?values.ASI_BRD_Martell_Engaged__c:acc.ASI_BRD_Martell_Engaged__pc;
            acc.ASI_BRD_OtherBrand1_AllMkt_OptIn__pc = (acc.ASI_BRD_OtherBrand1_AllMkt_OptIn__pc == null)?values.ASI_BRD_OtherBrand1_AllMkt_OptIn__c:acc.ASI_BRD_OtherBrand1_AllMkt_OptIn__pc;
            acc.ASI_BRD_OtherBrand1_Engaged__pc = (acc.ASI_BRD_OtherBrand1_Engaged__pc == null)?values.ASI_BRD_OtherBrand1_Engaged__c:acc.ASI_BRD_OtherBrand1_Engaged__pc;
            acc.ASI_BRD_OtherBrand3_Engaged__pc = (acc.ASI_BRD_OtherBrand3_Engaged__pc == null)?values.ASI_BRD_OtherBrand3_Engaged__c:acc.ASI_BRD_OtherBrand3_Engaged__pc;
            acc.ASI_BRD_OtherBrand3_AllMkt_OptIn__pc = (acc.ASI_BRD_OtherBrand3_AllMkt_OptIn__pc == null)?values.ASI_BRD_OtherBrand3_AllMkt_OptIn__c:acc.ASI_BRD_OtherBrand3_AllMkt_OptIn__pc;
            acc.ASI_BRD_OtherBrand2_AllMkt_OptIn__pc = (acc.ASI_BRD_OtherBrand2_AllMkt_OptIn__pc == null)?values.ASI_BRD_OtherBrand2_AllMkt_OptIn__c:acc.ASI_BRD_OtherBrand2_AllMkt_OptIn__pc;
            acc.ASI_BRD_OtherBrand2_Engaged__pc = (acc.ASI_BRD_OtherBrand2_Engaged__pc == null)?values.ASI_BRD_OtherBrand2_Engaged__c:acc.ASI_BRD_OtherBrand2_Engaged__pc;
            acc.ASI_BRD_PerrierJouet_AllMkt_OptIn__pc = (acc.ASI_BRD_PerrierJouet_AllMkt_OptIn__pc == null)?values.ASI_BRD_PerrierJouet_AllMkt_OptIn__c:acc.ASI_BRD_PerrierJouet_AllMkt_OptIn__pc;
            acc.ASI_BRD_PerrierJouet_Engaged__pc = (acc.ASI_BRD_PerrierJouet_Engaged__pc == null)?values.ASI_BRD_PerrierJouet_Engaged__c:acc.ASI_BRD_PerrierJouet_Engaged__pc;
            acc.ASI_BRD_RoyalSalute_AllMkt_OptIn__pc = (acc.ASI_BRD_RoyalSalute_AllMkt_OptIn__pc == null)?values.ASI_BRD_RoyalSalute_AllMkt_OptIn__c:acc.ASI_BRD_RoyalSalute_AllMkt_OptIn__pc;
            acc.ASI_BRD_RoyalSalute_Engaged__pc = (acc.ASI_BRD_RoyalSalute_Engaged__pc == null)?values.ASI_BRD_RoyalSalute_Engaged__c:acc.ASI_BRD_RoyalSalute_Engaged__pc;
            acc.ASI_BRD_TheGlenlivet_AllMkt_OptIn__pc = (acc.ASI_BRD_TheGlenlivet_AllMkt_OptIn__pc == null)?values.ASI_BRD_TheGlenlivet_AllMkt_OptIn__c:acc.ASI_BRD_TheGlenlivet_AllMkt_OptIn__pc;
            acc.ASI_BRD_TheGlenlivet_Engaged__pc = (acc.ASI_BRD_TheGlenlivet_Engaged__pc == null)?values.ASI_BRD_TheGlenlivet_Engaged__c:acc.ASI_BRD_TheGlenlivet_Engaged__pc;
            acc.ASI_LUX_Occasion_at_First_Meeting__c = (acc.ASI_LUX_Occasion_at_First_Meeting__c == null)?values.ASI_LUX_Occasion_at_First_Meeting__c:acc.ASI_LUX_Occasion_at_First_Meeting__c;
            acc.ASI_BRD_Sys_Target_Luxury_Account_RT__pc = (acc.ASI_BRD_Sys_Target_Luxury_Account_RT__pc == null)?values.ASI_BRD_Sys_Target_Luxury_Account_RT__c:acc.ASI_BRD_Sys_Target_Luxury_Account_RT__pc;
            acc.ASI_BRD_Name_of_OtherBrand1__pc = (acc.ASI_BRD_Name_of_OtherBrand1__pc == null)?values.ASI_BRD_Name_of_OtherBrand1__c:acc.ASI_BRD_Name_of_OtherBrand1__pc;
            acc.ASI_BRD_Name_of_OtherBrand2__pc = (acc.ASI_BRD_Name_of_OtherBrand2__pc == null)?values.ASI_BRD_Name_of_OtherBrand2__c:acc.ASI_BRD_Name_of_OtherBrand2__pc;
            acc.ASI_BRD_Name_of_OtherBrand3__pc = (acc.ASI_BRD_Name_of_OtherBrand3__pc == null)?values.ASI_BRD_Name_of_OtherBrand3__c:acc.ASI_BRD_Name_of_OtherBrand3__pc;
            acc.ASI_LUX_Profile__c = (acc.ASI_LUX_Profile__c == null)?values.ASI_BRD_Profile__c:acc.ASI_LUX_Profile__c;   
            acc.ASI_LUX_Preferred_Language_1__c = (acc.ASI_LUX_Preferred_Language_1__c == null)?values.ASI_BRD_Preferred_Language_1__c:acc.ASI_LUX_Preferred_Language_1__c;
            //PR SG Brands (eCRM P2)
            acc.ASI_BRD_Beefeater_Engaged__pc = (acc.ASI_BRD_Beefeater_Engaged__pc == null)?values.ASI_BRD_Beefeater_Engaged__c:acc.ASI_BRD_Beefeater_Engaged__pc; 
            acc.ASI_BRD_Chivas_Engaged__pc = (acc.ASI_BRD_Chivas_Engaged__pc == null)?values.ASI_BRD_Chivas_Engaged__c:acc.ASI_BRD_Chivas_Engaged__pc; 
            acc.ASI_BRD_HavanaClub_Engaged__pc = (acc.ASI_BRD_HavanaClub_Engaged__pc == null)?values.ASI_BRD_HavanaClub_Engaged__c:acc.ASI_BRD_HavanaClub_Engaged__pc; 
            acc.ASI_BRD_Jameson_Engaged__pc = (acc.ASI_BRD_Jameson_Engaged__pc == null)?values.ASI_BRD_Jameson_Engaged__c:acc.ASI_BRD_Jameson_Engaged__pc; 
            acc.ASI_BRD_Kahlua_Engaged__pc = (acc.ASI_BRD_Kahlua_Engaged__pc == null)?values.ASI_BRD_Kahlua_Engaged__c:acc.ASI_BRD_Kahlua_Engaged__pc;
            acc.ASI_BRD_Malibu_Engaged__pc = (acc.ASI_BRD_Malibu_Engaged__pc == null)?values.ASI_BRD_Malibu_Engaged__c:acc.ASI_BRD_Malibu_Engaged__pc;
            acc.ASI_BRD_Ricard_Engaged__pc = (acc.ASI_BRD_Ricard_Engaged__pc == null)?values.ASI_BRD_Ricard_Engaged__c:acc.ASI_BRD_Ricard_Engaged__pc;
            acc.ASI_BRD_Beefeater_AllMkt_OptIn__pc = (acc.ASI_BRD_Beefeater_AllMkt_OptIn__pc == null)?values.ASI_BRD_Beefeater_AllMkt_OptIn__c:acc.ASI_BRD_Beefeater_AllMkt_OptIn__pc;
            acc.ASI_BRD_Chivas_AllMkt_OptIn__pc = (acc.ASI_BRD_Chivas_AllMkt_OptIn__pc == null)?values.ASI_BRD_Chivas_AllMkt_OptIn__c:acc.ASI_BRD_Chivas_AllMkt_OptIn__pc;
            acc.ASI_BRD_HavanaClub_AllMkt_OptIn__pc = (acc.ASI_BRD_HavanaClub_AllMkt_OptIn__pc == null)?values.ASI_BRD_HavanaClub_AllMkt_OptIn__c:acc.ASI_BRD_HavanaClub_AllMkt_OptIn__pc;
            acc.ASI_BRD_Jameson_AllMkt_OptIn__pc = (acc.ASI_BRD_Jameson_AllMkt_OptIn__pc == null)?values.ASI_BRD_Jameson_AllMkt_OptIn__c:acc.ASI_BRD_Jameson_AllMkt_OptIn__pc;
            acc.ASI_BRD_Kahlua_AllMkt_OptIn__pc = (acc.ASI_BRD_Kahlua_AllMkt_OptIn__pc == null)?values.ASI_BRD_Kahlua_AllMkt_OptIn__c:acc.ASI_BRD_Kahlua_AllMkt_OptIn__pc;
            acc.ASI_BRD_Malibu_AllMkt_OptIn__pc = (acc.ASI_BRD_Malibu_AllMkt_OptIn__pc == null)?values.ASI_BRD_Malibu_AllMkt_OptIn__c:acc.ASI_BRD_Malibu_AllMkt_OptIn__pc;
            acc.ASI_BRD_Ricard_AllMkt_OptIn__pc = (acc.ASI_BRD_Ricard_AllMkt_OptIn__pc == null)?values.ASI_BRD_Ricard_AllMkt_OptIn__c:acc.ASI_BRD_Ricard_AllMkt_OptIn__pc;
        }     
        if(acc.ASI_LUX_EDM_Opt_in_Email__pc == 'Yes'){
            acc.ASI_BRD_OtherBrand1_AllMkt_OptIn__pc = (acc.ASI_BRD_OtherBrand1_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_OtherBrand2_AllMkt_OptIn__pc = (acc.ASI_BRD_OtherBrand2_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_OtherBrand3_AllMkt_OptIn__pc = (acc.ASI_BRD_OtherBrand3_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_PerrierJouet_AllMkt_OptIn__pc = (acc.ASI_BRD_PerrierJouet_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_Ricard_AllMkt_OptIn__pc = (acc.ASI_BRD_Ricard_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_RoyalSalute_AllMkt_OptIn__pc = (acc.ASI_BRD_RoyalSalute_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_TheGlenlivet_AllMkt_OptIn__pc = (acc.ASI_BRD_TheGlenlivet_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_Absolut_AllMkt_OptIn__pc = (acc.ASI_BRD_Absolut_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_Ballantines_AllMkt_OptIn__pc = (acc.ASI_BRD_Ballantines_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_Beefeater_AllMkt_OptIn__pc = (acc.ASI_BRD_Beefeater_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_Chivas_AllMkt_OptIn__pc = (acc.ASI_BRD_Chivas_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_GHMumm_AllMkt_OptIn__pc = (acc.ASI_BRD_GHMumm_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_HavanaClub_AllMkt_OptIn__pc = (acc.ASI_BRD_HavanaClub_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_Jameson_AllMkt_OptIn__pc = (acc.ASI_BRD_Jameson_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_Kahlua_AllMkt_OptIn__pc = (acc.ASI_BRD_Kahlua_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_Malibu_AllMkt_OptIn__pc = (acc.ASI_BRD_Malibu_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
            acc.ASI_BRD_Martell_AllMkt_OptIn__pc = (acc.ASI_BRD_Martell_AllMkt_OptIn__pc != 'N/A')?'Yes':'N/A';
        }else{
            acc.ASI_BRD_OtherBrand1_AllMkt_OptIn__pc = (acc.ASI_BRD_OtherBrand1_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_OtherBrand2_AllMkt_OptIn__pc = (acc.ASI_BRD_OtherBrand2_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_OtherBrand3_AllMkt_OptIn__pc = (acc.ASI_BRD_OtherBrand3_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_PerrierJouet_AllMkt_OptIn__pc = (acc.ASI_BRD_PerrierJouet_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_Ricard_AllMkt_OptIn__pc = (acc.ASI_BRD_Ricard_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_RoyalSalute_AllMkt_OptIn__pc = (acc.ASI_BRD_RoyalSalute_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_TheGlenlivet_AllMkt_OptIn__pc = (acc.ASI_BRD_TheGlenlivet_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_Absolut_AllMkt_OptIn__pc = (acc.ASI_BRD_Absolut_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_Ballantines_AllMkt_OptIn__pc = (acc.ASI_BRD_Ballantines_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_Beefeater_AllMkt_OptIn__pc = (acc.ASI_BRD_Beefeater_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_Chivas_AllMkt_OptIn__pc = (acc.ASI_BRD_Chivas_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_GHMumm_AllMkt_OptIn__pc = (acc.ASI_BRD_GHMumm_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_HavanaClub_AllMkt_OptIn__pc = (acc.ASI_BRD_HavanaClub_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_Jameson_AllMkt_OptIn__pc = (acc.ASI_BRD_Jameson_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_Kahlua_AllMkt_OptIn__pc = (acc.ASI_BRD_Kahlua_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_Malibu_AllMkt_OptIn__pc = (acc.ASI_BRD_Malibu_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
            acc.ASI_BRD_Martell_AllMkt_OptIn__pc = (acc.ASI_BRD_Martell_AllMkt_OptIn__pc != 'N/A')?null:'N/A';
        }
        update acc;
        PageReference accPage = new ApexPages.StandardController(acc).view();
        accPage.setRedirect(true);
        return accPage;
    }
}