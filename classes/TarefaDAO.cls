/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* REALIZA FUNÇÕES DML NO OBJETO: Task
* NAME: TarefaDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 21/05/2012
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 17/01/2013
* DESC: INSERIDO CABEÇALHO NO NOVO PADRÃO E COMENTADO CÓDIGO.
*******************************************************************************/
public with sharing class TarefaDAO 
{
	private static final TarefaDAO instance = new TarefaDAO();
	 
	//Construtor privado para impedir a criação de instâncias dessa classe.
	private TarefaDAO()
	{
	}
	
	// Método responsável por prover a instância dessa classe.
	public static TarefaDAO getInstance()
	{
		return instance;
		
	}
	
	//RECUPERA UMA LISTA DE OBJETO TASK
	//@param idRecTypeTarefa = id do tipo de registro de tarefa
	//@param listIdsOwner = lista de ids dos proprietarios das tarefas
	public List<Task> getTaskByRecordTypeAndOwner(String idRecTypeTarefa, List<String> listIdsOwner)
	{
		List<Task> listTask = null;
		
		listTask = [ SELECT Id, 
							Status, 
							OwnerId, 
							WhatId 
							FROM Task 
							WHERE OwnerId =: listIdsOwner 
							AND RecordTypeId =: idRecTypeTarefa
							AND Status <> 'Concluído'
					];
		
		return listTask;
	}
}