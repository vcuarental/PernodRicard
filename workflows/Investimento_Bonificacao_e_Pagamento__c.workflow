<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AtualizaStatusParaReservado</fullName>
        <field>Status_da_Verba__c</field>
        <literalValue>Reservado</literalValue>
        <name>AtualizaStatusParaReservado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_IBP_UpdateDataEncerramen</fullName>
        <description>Update Data de Encerramen for Investimento, Bonificação e Pagamento</description>
        <field>Data_de_Encerramento__c</field>
        <formula>LAT_Contract__r.LAT_BR_RealValidityDate__c</formula>
        <name>LAT_BR_IBP_UpdateDataEncerramen</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LAT_BR_IBP_WF01_DataEncerramento</fullName>
        <actions>
            <name>LAT_BR_IBP_UpdateDataEncerramen</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Outros Pagamentos</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Investimento_Bonificacao_e_Pagamento__c.Outros_Pagamentos__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Gerar uma tarefa 12 dias uteis antes da data prevista para pagamento.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Realizar_Pagamento_Planejado12</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Investimento_Bonificacao_e_Pagamento__c.Data_de_Previsao_do_Pagamento__c</offsetFromField>
            <timeLength>-16</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Primeiro Pagamento</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Investimento_Bonificacao_e_Pagamento__c.Primeiro_Pagamento__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>gerar uma tarefa para o proprietário do registro avisando
que ele deve fazer um pagamento</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Realizar_Pagamento_Planejado</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Investimento_Bonificacao_e_Pagamento__c.Data_de_Previsao_do_Pagamento__c</offsetFromField>
            <timeLength>-40</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Realizar_Pagamento_Planejado</fullName>
        <assignedToType>owner</assignedToType>
        <description>Efetuar pagamento planejado</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Alto</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Realizar Pagamento Planejado</subject>
    </tasks>
    <tasks>
        <fullName>Realizar_Pagamento_Planejado12</fullName>
        <assignedToType>owner</assignedToType>
        <description>Realizar Pagamento Planejado</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Alto</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Realizar Pagamento Planejado</subject>
    </tasks>
</Workflow>
