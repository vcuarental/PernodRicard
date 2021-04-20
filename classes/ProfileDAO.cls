/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza funções DML no objeto Profile.
* NAME: ProfileDAO.cls
* AUTHOR: CARLOS CARVALHO                         DATE: 14/05/2012
*
* MAINTENANCE
* AUTHOR:                                           DATE: 
********************************************************************************/
public with sharing class ProfileDAO 
{
  private static final ProfileDAO instance = new ProfileDAO();
  
  //Construtor privado para impedir a criação de instâncias dessa classe.
  private ProfileDAO()
  {
  }
  
  // Método responsável por prover a instância dessa classe.
  public static ProfileDAO getInstance()
  {
    return instance;
  }
  
  // Recupera um lista de perfis.
  // @param listIdsProfiles
  // @author Carlos Carvalho
  public List<Profile> getListProfileByNameProfile(List<String> listNameProfiles)
  {
    List<Profile> listProfiles = null;
    
    listProfiles = [Select Id, Name From Profile Where Name =: listNameprofiles];
    
    return listProfiles;
  }
}