<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Atualiza_Status_Visita_Cliente</fullName>
        <field>Status_de_visita_cliente__c</field>
        <formula>Text(Visita__r.Status__c)</formula>
        <name>Atualiza Status Visita Cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Atualiza Status Visita Cliente</fullName>
        <actions>
            <name>Atualiza_Status_Visita_Cliente</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
