/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* Classe que realiza funções DML no objeto UserDAO.
*
* NAME: UserDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 13/03/2012
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
public with sharing class UserDAO
{
	 
	private static final UserDAO instance = new UserDAO();
	
	//Construtor privado para impedir a criação de instâncias dessa classe.
	private UserDAO()
	{
	}
	
	// Método responsável por prover a instância dessa classe.
	public static UserDAO getInstance()
	{
		 return instance;
	}
	
	// Responsável por recuperar Ids de usuários com os campos de gerente regional e gerente de área.
	// @param listIdsUsers (Lista de String com os Ids dos usuários necessários.)
	// @author Carlos Carvalho
	public List<User> getListUserById(List<String> listIdsUsers)
	{
		List<User> listUser = new List<User>();
		
		listUser = [Select Id, gerente_regional__c, gerente_de_area__c, ManagerId, Regional_de_vendas__c
		            From User Where Id =: listIdsUsers];
		
		return listUser;
	}
	
	// Responsável por recuperar Ids de usuários.
	// @param listIdsPerfil (Lista de String com os Ids de perfis de usuário que virão no select.)
	// @author Carlos Carvalho
	public List<User> getListUserByIdProfile(String aIdProfile)
	{
		List<User> listUser = new List<User>();
		
		listUser = [Select Id, gerente_regional__c, gerente_de_area__c From User Where ProfileId =: aIdProfile AND isActive = true];
		
		return listUser;
	}
}