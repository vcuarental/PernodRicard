/*********************************************************************************
 * Name:ASI_BRD_Generic_AccountUpgradeController
 * Description: Controller for Page ASI_BRD_Generic_AccountUpgradePage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 9/9/2015         Laputa: Hank            Created
*********************************************************************************/
public without sharing class ASI_BRD_Generic_AccountUpgradeController{
    public Account acc{get;set;}
    public ASI_BRD_Generic_AccountUpgradeController(ApexPages.StandardController controller) {
        acc = (Account)controller.getRecord();
        acc = [Select ASI_BRD_Sys_Target_Luxury_Account_RT__pc, ASI_BRD_Change_Account_Owner_To__pc From Account Where Id = :acc.Id];
    }
    public PageReference cancelUpgrade(){
        PageReference accPage = new ApexPages.StandardController(acc).view();
        accPage.setRedirect(true);
        return accPage;
    }
    public PageReference confirmUpgrade(){
        //If no owner to, return null
        if(acc.ASI_BRD_Change_Account_Owner_To__pc == null){
            return null;
        }
        //get user input
        String rtAPIName = acc.ASI_BRD_Sys_Target_Luxury_Account_RT__pc;
        String ownerTo = acc.ASI_BRD_Change_Account_Owner_To__pc;
        //get record type Id
        acc.recordTypeId = Global_RecordTypeCache.getRtId('Account' + rtAPIName);
        //get owner to username
        String[] strArr = ownerTo.Split('\\(');
        String userEmail = strArr[1];
        //get owner to record id
        userEmail = userEmail.subString(0,userEmail.length()-1) + '%';
        List<User> useList = [Select Id From User Where Username like :userEmail];
        User u = useList[0];
        acc.ownerId = u.Id;
        Database.DmlOptions options = new Database.DmlOptions();
        options.emailHeader.triggerUserEmail = true;
        //set all engaged to No
        
        acc.ASI_BRD_Absolut_Engaged__pc = (acc.ASI_BRD_Absolut_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_Ballantines_Engaged__pc = (acc.ASI_BRD_Ballantines_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_Beefeater_Engaged__pc = (acc.ASI_BRD_Beefeater_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_Chivas_Engaged__pc = (acc.ASI_BRD_Chivas_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_GHMumm_Engaged__pc = (acc.ASI_BRD_GHMumm_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_HavanaClub_Engaged__pc = (acc.ASI_BRD_HavanaClub_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_Jameson_Engaged__pc = (acc.ASI_BRD_Jameson_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_Kahlua_Engaged__pc = (acc.ASI_BRD_Kahlua_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_Malibu_Engaged__pc = (acc.ASI_BRD_Malibu_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_Martell_Engaged__pc = (acc.ASI_BRD_Martell_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_PerrierJouet_Engaged__pc = (acc.ASI_BRD_PerrierJouet_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_Ricard_Engaged__pc = (acc.ASI_BRD_Ricard_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_RoyalSalute_Engaged__pc = (acc.ASI_BRD_RoyalSalute_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_TheGlenlivet_Engaged__pc = (acc.ASI_BRD_TheGlenlivet_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_OtherBrand1_Engaged__pc = (acc.ASI_BRD_OtherBrand1_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_OtherBrand2_Engaged__pc = (acc.ASI_BRD_OtherBrand2_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_OtherBrand3_Engaged__pc = (acc.ASI_BRD_OtherBrand3_Engaged__pc != 'N/A')?null:'N/A';
        acc.ASI_BRD_Brands_Engaged__pc = null;
        Database.update(acc, options);
        //delete all the territories
        List<ObjectTerritory2Association> ttList = [Select Id From ObjectTerritory2Association Where ObjectId = :acc.Id];
        delete ttList;
        PageReference accPage = new PageReference('/001/o');
        accPage.setRedirect(true);
        return accPage;
    }
}