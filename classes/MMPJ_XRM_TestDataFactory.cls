/******************************************************************************
*   @author Simon Gourreau
*   @date 15/02/2021
*   @description Generate test data
*
*/
public with sharing class MMPJ_XRM_TestDataFactory {

    /**
    * @description Create a new standard user
    * @param String Username
    * @return User created
    *
    */
    public static user getStandardUser(String pUserName){
        Profile p = [SELECT Id 
                        FROM Profile 
                        WHERE Name = :MYPJ_Constants.EXT_VIGNERON_MMPJ];

        return new User(Alias = 'sus', Email = 'standarduser@testorg.com',
          EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'fr',
          LocaleSidKey = 'fr_FR_EURO', ProfileId = p.Id,
          TimeZoneSidKey = 'Europe/Paris', UserName = pUserName);
    }

    /**
    * @description Create a new campaign
    * @param String Name
    * @return User created
    *
    */
    public static Campaign getCampaign(String pName, String pRtName){
        List<RecordType> vListRts = [Select Id 
                                        From RecordType 
                                        Where SobjectType = 'Campaign'
                                        AND DeveloperName = :pRtName];

        return new Campaign (
            Name = pName,
            StartDate = date.today().addMonths(-2), 
            endDate = date.today().addMonths(-1),
            recordtypeID = vListRts[0].Id
        );
    }
}