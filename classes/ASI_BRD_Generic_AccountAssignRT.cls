/*********************************************************************************
 * Name:ASI_BRD_Generic_AccountAssignRT
 * Description: Assign Account record type after Lead conversion
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 14/09/2015       Laputa: Hank          Created
 * 2017-03-09		Laputa: Vincent			Update mkto2__Acquisition_Program__pc to mkto71_Acquisition_Program__pc
*********************************************************************************/

public with sharing class ASI_BRD_Generic_AccountAssignRT extends ASI_BRD_Generic_TriggerAbstract {

    public ASI_BRD_Generic_AccountAssignRT() {
        super('ASI_BRD_Generic_AccountAssignRT');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        Map<String, ASI_BRD_Generic_CRM_Mapping__c> mappingMap = ASI_BRD_Generic_CRM_Mapping__c.getAll(); 
        List<Account> accList = (List<Account>)sObjList;
        Map<String, ASI_BRD_Generic_CRM_Default_Values__c> valuesMap = ASI_BRD_Generic_CRM_Default_Values__c.getAll();
        if (oldMap == null) {
            for(Account acc:accList){
                system.debug('KKTest 1: ' + acc.ASI_BRD_Converted_Lead_Record_Type__pc);
                if(acc.ASI_BRD_Converted_Lead_Record_Type__pc != null){
                    system.debug('KKTest 2: ' + acc.ASI_BRD_Primary_Market__pc + ' ' + acc.ASI_BRD_Converted_Lead_Record_Type__pc);
                    if(acc.ASI_BRD_Primary_Market__pc != null && acc.ASI_BRD_Converted_Lead_Record_Type__pc == 'ASI_BRD_Generic_CRM_Lead'){
                        acc.recordtypeId = Global_RecordTypeCache.getRtId('Account' + mappingMap.get(acc.ASI_BRD_Primary_Market__pc).ASI_BRD_Record_Type__c);
                    }else if(acc.ASI_BRD_Converted_Lead_Record_Type__pc.startsWith('ASI_LUX') && acc.mkto71_Acquisition_Program__pc.startsWith('ASI_') && !acc.mkto71_Acquisition_Program__pc.contains('_BRD_')){
                        acc.recordtypeId = Global_RecordTypeCache.getRtId('AccountASI_Luxury_Account_Regional_First_Contact');
                    }else if(acc.ASI_BRD_Converted_Lead_Record_Type__pc.startsWith('ASI_LUX') && acc.mkto71_Acquisition_Program__pc.startsWith('HKG_') && !acc.mkto71_Acquisition_Program__pc.contains('_BRD_')){
                        acc.recordtypeId = Global_RecordTypeCache.getRtId('AccountASI_Luxury_Account_HK_First_Contact');
                    }else if(acc.ASI_BRD_Converted_Lead_Record_Type__pc.startsWith('ASI_LUX') && acc.mkto71_Acquisition_Program__pc.startsWith('MYA_') && !acc.mkto71_Acquisition_Program__pc.contains('_BRD_')){
                        acc.recordtypeId = Global_RecordTypeCache.getRtId('AccountASI_Luxury_Account_MY_First_Contact');
                    }else if(acc.ASI_BRD_Converted_Lead_Record_Type__pc.startsWith('ASI_LUX') && acc.mkto71_Acquisition_Program__pc.startsWith('TWN_') && !acc.mkto71_Acquisition_Program__pc.contains('_BRD_')){
                        acc.recordtypeId = Global_RecordTypeCache.getRtId('AccountASI_Luxury_Account_TW_First_Contact');
                    }else if(acc.ASI_BRD_Converted_Lead_Record_Type__pc.startsWith('ASI_LUX') && acc.mkto71_Acquisition_Program__pc.startsWith('JPN_') && !acc.mkto71_Acquisition_Program__pc.contains('_BRD_')){
                        acc.recordtypeId = Global_RecordTypeCache.getRtId('AccountASI_Luxury_Account_JP');
                    }else if(acc.ASI_BRD_Converted_Lead_Record_Type__pc.startsWith('ASI_LUX') && acc.mkto71_Acquisition_Program__pc.startsWith('SGN_') &&
                            !acc.mkto71_Acquisition_Program__pc.contains('TGL') && !acc.mkto71_Acquisition_Program__pc.contains('GHM') && !acc.mkto71_Acquisition_Program__pc.contains('_BRD_')){
                        acc.recordtypeId = Global_RecordTypeCache.getRtId('AccountASI_LUX_SG_Account_First_Contact');
                    }else if((acc.ASI_BRD_Converted_Lead_Record_Type__pc.startsWith('ASI_Brand') || acc.ASI_BRD_Converted_Lead_Record_Type__pc.startsWith('ASI_LUX')) && 
                            acc.mkto71_Acquisition_Program__pc.startsWith('SGN_TGL_')){
                        acc.recordtypeId = Global_RecordTypeCache.getRtId('AccountASI_LUX_SG_Account_First_Contact');
                    }else if((acc.ASI_BRD_Converted_Lead_Record_Type__pc.startsWith('ASI_Brand') || acc.ASI_BRD_Converted_Lead_Record_Type__pc.startsWith('ASI_LUX')) && 
                            acc.mkto71_Acquisition_Program__pc.startsWith('SGN_GHM_')){
                        acc.recordtypeId = Global_RecordTypeCache.getRtId('AccountASI_LUX_SG_Account_First_Contact');
                    }
                    
                    if(acc.ASI_BRD_Primary_Market__pc != null && mappingMap.get(acc.ASI_BRD_Primary_Market__pc) != null && acc.recordtypeId == Global_RecordTypeCache.getRtId('Account' + mappingMap.get(acc.ASI_BRD_Primary_Market__pc).ASI_BRD_Record_Type__c)){
                            ASI_BRD_Generic_CRM_Default_Values__c values = valuesMap.get(acc.ASI_BRD_Primary_Market__pc);
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
                            acc.ASI_BRD_OtherBrand3_Engaged__pc = (acc.ASI_BRD_OtherBrand3_Engaged__pc == null)?values.ASI_BRD_OtherBrand3_Engaged__c:acc.ASI_BRD_OtherBrand3_Engaged__pc;
                            acc.ASI_BRD_OtherBrand3_AllMkt_OptIn__pc = (acc.ASI_BRD_OtherBrand3_AllMkt_OptIn__pc == null)?values.ASI_BRD_OtherBrand3_AllMkt_OptIn__c:acc.ASI_BRD_OtherBrand3_AllMkt_OptIn__pc;
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
                }
                if(acc.ASI_BRD_Acquired_By__pc != null && acc.ASI_BRD_Primary_Market__pc != null && valuesMap.get(acc.ASI_BRD_Primary_Market__pc) != null){
                    ASI_BRD_Generic_CRM_Default_Values__c values = valuesMap.get(acc.ASI_BRD_Primary_Market__pc);
                    System.debug('Acquired By: ' + acc.ASI_BRD_Acquired_By__pc + ' Other Brand 1: ' + values.ASI_BRD_Name_of_OtherBrand1__c);
                    if(acc.ASI_BRD_Acquired_By__pc == values.ASI_BRD_Name_of_OtherBrand1__c){
                        acc.ASI_BRD_OtherBrand1_Engaged__pc = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc == values.ASI_BRD_Name_of_OtherBrand2__c){
                        acc.ASI_BRD_OtherBrand2_Engaged__pc = 'Yes';    
                    }else if(acc.ASI_BRD_Acquired_By__pc == values.ASI_BRD_Name_of_OtherBrand3__c){
                        acc.ASI_BRD_OtherBrand3_Engaged__pc = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('Beefeater')){
                        acc.ASI_BRD_Beefeater_Engaged__pc = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('Chivas')){
                        acc.ASI_BRD_Chivas_Engaged__pc= 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('Havana Club')){
                        acc.ASI_BRD_HavanaClub_Engaged__pc = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('Jameson')){
                        acc.ASI_BRD_Jameson_Engaged__pc = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('Kahlua')){
                        acc.ASI_BRD_Kahlua_Engaged__pc = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('Malibu')){
                        acc.ASI_BRD_Malibu_Engaged__pc = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('Ricard')){
                        acc.ASI_BRD_Ricard_Engaged__pc = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('Absolut')){
                        acc.ASI_BRD_Absolut_Engaged__pc = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('Ballantine')){
                        acc.ASI_BRD_Ballantines_Engaged__pc = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('G.H.Mumm')){
                        acc.ASI_BRD_GHMumm_Engaged__pc = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('Martell')){
                        acc.ASI_BRD_Martell_Engaged__pc = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('Perrier-Jouet') || acc.ASI_BRD_Acquired_By__pc.contains('Perrier-Jouët')){
                        acc.ASI_BRD_PerrierJouet_Engaged__pc = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('Royal Salute')){
                        acc.ASI_BRD_RoyalSalute_Engaged__pc  = 'Yes';
                    }else if(acc.ASI_BRD_Acquired_By__pc.contains('The Glenlivet')){
                        acc.ASI_BRD_TheGlenlivet_Engaged__pc = 'Yes';
                    }
                }
            }
            
            Map<String, ASI_HK_CRM_AutoNumberAssignment> autoNumAssign = new Map<String, ASI_HK_CRM_AutoNumberAssignment>();
            for (Account acc: accList){
                if(acc.ASI_BRD_Converted_Lead_Record_Type__pc != null && acc.ASI_BRD_Primary_Market__pc != null){
                    if (autoNumAssign.get(acc.ASI_BRD_Primary_Market__pc) == null) 
                    {    
                        if(mappingMap != null && acc.ASI_BRD_Primary_Market__pc != null && mappingMap.get(acc.ASI_BRD_Primary_Market__pc) != null && mappingMap.get(acc.ASI_BRD_Primary_Market__pc).ASI_BRD_Running_Number__c != null){
                            autoNumAssign.put(acc.ASI_BRD_Primary_Market__pc, new ASI_HK_CRM_AutoNumberAssignment(mappingMap.get(acc.ASI_BRD_Primary_Market__pc).ASI_BRD_Running_Number__c));
                        }
                    }
                    if(autoNumAssign.get(acc.ASI_BRD_Primary_Market__pc) != null){
                        acc.ASI_LUX_Internal_Member_No__c = autoNumAssign.get(acc.ASI_BRD_Primary_Market__pc).nextAutoNumStr();
                    }
                }
            }
            
            for(ASI_HK_CRM_AutoNumberAssignment assign:autoNumAssign.values()){
                assign.writeToDB();
            }
        }
    }
}