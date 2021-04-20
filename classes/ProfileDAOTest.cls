@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura da classe ProfileDAO.cls
* NAME: ProfileDAOTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 05/06/2012
*
********************************************************************************/
private class ProfileDAOTest 
{

    static testMethod void ProfileDAOTest() 
    {
    	User usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
     	List<id> listNameProfiles = new  List<id>();
     	listNameProfiles.add(usuario.ProfileId);
      
      List<Profile> listProfiles = ProfileDAO.getInstance().getListProfileByNameProfile(listNameProfiles);
    }
}